Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id CD0E26B0070
	for <linux-mm@kvack.org>; Sat, 11 May 2013 21:21:40 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 32/39] mm: cleanup __do_fault() implementation
Date: Sun, 12 May 2013 04:23:29 +0300
Message-Id: <1368321816-17719-33-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Let's cleanup __do_fault() to prepare it for transparent huge pages
support injection.

Cleanups:
 - int -> bool where appropriate;
 - unindent some code by reverting 'if' condition;
 - extract !pte_same() path to get it clear;
 - separate pte update from mm stats update;
 - some comments reformated;

Functionality is not changed.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/memory.c |  157 +++++++++++++++++++++++++++++------------------------------
 1 file changed, 76 insertions(+), 81 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 4008d93..97b22c7 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3301,21 +3301,18 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	pte_t *page_table;
 	spinlock_t *ptl;
-	struct page *page;
-	struct page *cow_page;
+	struct page *page, *cow_page, *dirty_page = NULL;
 	pte_t entry;
-	int anon = 0;
-	struct page *dirty_page = NULL;
+	bool anon = false, page_mkwrite = false;
+	bool write = flags & FAULT_FLAG_WRITE;
 	struct vm_fault vmf;
 	int ret;
-	int page_mkwrite = 0;
 
 	/*
 	 * If we do COW later, allocate page befor taking lock_page()
 	 * on the file cache page. This will reduce lock holding time.
 	 */
-	if ((flags & FAULT_FLAG_WRITE) && !(vma->vm_flags & VM_SHARED)) {
-
+	if (write && !(vma->vm_flags & VM_SHARED)) {
 		if (unlikely(anon_vma_prepare(vma)))
 			return VM_FAULT_OOM;
 
@@ -3336,8 +3333,7 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	vmf.page = NULL;
 
 	ret = vma->vm_ops->fault(vma, &vmf);
-	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE |
-			    VM_FAULT_RETRY)))
+	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		goto uncharge_out;
 
 	if (unlikely(PageHWPoison(vmf.page))) {
@@ -3356,98 +3352,89 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	else
 		VM_BUG_ON(!PageLocked(vmf.page));
 
+	page = vmf.page;
+	if (!write)
+		goto update_pgtable;
+
 	/*
 	 * Should we do an early C-O-W break?
 	 */
-	page = vmf.page;
-	if (flags & FAULT_FLAG_WRITE) {
-		if (!(vma->vm_flags & VM_SHARED)) {
-			page = cow_page;
-			anon = 1;
-			copy_user_highpage(page, vmf.page, address, vma);
-			__SetPageUptodate(page);
-		} else {
-			/*
-			 * If the page will be shareable, see if the backing
-			 * address space wants to know that the page is about
-			 * to become writable
-			 */
-			if (vma->vm_ops->page_mkwrite) {
-				int tmp;
-
+	if (!(vma->vm_flags & VM_SHARED)) {
+		page = cow_page;
+		anon = true;
+		copy_user_highpage(page, vmf.page, address, vma);
+		__SetPageUptodate(page);
+	} else if (vma->vm_ops->page_mkwrite) {
+		/*
+		 * If the page will be shareable, see if the backing address
+		 * space wants to know that the page is about to become writable
+		 */
+		int tmp;
+
+		unlock_page(page);
+		vmf.flags = FAULT_FLAG_WRITE | FAULT_FLAG_MKWRITE;
+		tmp = vma->vm_ops->page_mkwrite(vma, &vmf);
+		if (unlikely(tmp & (VM_FAULT_ERROR | VM_FAULT_NOPAGE))) {
+			ret = tmp;
+			goto unwritable_page;
+		}
+		if (unlikely(!(tmp & VM_FAULT_LOCKED))) {
+			lock_page(page);
+			if (!page->mapping) {
+				ret = 0; /* retry the fault */
 				unlock_page(page);
-				vmf.flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
-				tmp = vma->vm_ops->page_mkwrite(vma, &vmf);
-				if (unlikely(tmp &
-					  (VM_FAULT_ERROR | VM_FAULT_NOPAGE))) {
-					ret = tmp;
-					goto unwritable_page;
-				}
-				if (unlikely(!(tmp & VM_FAULT_LOCKED))) {
-					lock_page(page);
-					if (!page->mapping) {
-						ret = 0; /* retry the fault */
-						unlock_page(page);
-						goto unwritable_page;
-					}
-				} else
-					VM_BUG_ON(!PageLocked(page));
-				page_mkwrite = 1;
+				goto unwritable_page;
 			}
-		}
-
+		} else
+			VM_BUG_ON(!PageLocked(page));
+		page_mkwrite = true;
 	}
 
+update_pgtable:
 	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+	/* Only go through if we didn't race with anybody else... */
+	if (unlikely(!pte_same(*page_table, orig_pte))) {
+		pte_unmap_unlock(page_table, ptl);
+		goto race_out;
+	}
+
+	flush_icache_page(vma, page);
+	if (anon) {
+		inc_mm_counter_fast(mm, MM_ANONPAGES);
+		page_add_new_anon_rmap(page, vma, address);
+	} else {
+		inc_mm_counter_fast(mm, MM_FILEPAGES);
+		page_add_file_rmap(page);
+		if (write) {
+			dirty_page = page;
+			get_page(dirty_page);
+		}
+	}
 
 	/*
-	 * This silly early PAGE_DIRTY setting removes a race
-	 * due to the bad i386 page protection. But it's valid
-	 * for other architectures too.
+	 * This silly early PAGE_DIRTY setting removes a race due to the bad
+	 * i386 page protection. But it's valid for other architectures too.
 	 *
-	 * Note that if FAULT_FLAG_WRITE is set, we either now have
-	 * an exclusive copy of the page, or this is a shared mapping,
-	 * so we can make it writable and dirty to avoid having to
-	 * handle that later.
+	 * Note that if FAULT_FLAG_WRITE is set, we either now have an
+	 * exclusive copy of the page, or this is a shared mapping, so we can
+	 * make it writable and dirty to avoid having to handle that later.
 	 */
-	/* Only go through if we didn't race with anybody else... */
-	if (likely(pte_same(*page_table, orig_pte))) {
-		flush_icache_page(vma, page);
-		entry = mk_pte(page, vma->vm_page_prot);
-		if (flags & FAULT_FLAG_WRITE)
-			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-		if (anon) {
-			inc_mm_counter_fast(mm, MM_ANONPAGES);
-			page_add_new_anon_rmap(page, vma, address);
-		} else {
-			inc_mm_counter_fast(mm, MM_FILEPAGES);
-			page_add_file_rmap(page);
-			if (flags & FAULT_FLAG_WRITE) {
-				dirty_page = page;
-				get_page(dirty_page);
-			}
-		}
-		set_pte_at(mm, address, page_table, entry);
+	entry = mk_pte(page, vma->vm_page_prot);
+	if (write)
+		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+	set_pte_at(mm, address, page_table, entry);
 
-		/* no need to invalidate: a not-present page won't be cached */
-		update_mmu_cache(vma, address, page_table);
-	} else {
-		if (cow_page)
-			mem_cgroup_uncharge_page(cow_page);
-		if (anon)
-			page_cache_release(page);
-		else
-			anon = 1; /* no anon but release faulted_page */
-	}
+	/* no need to invalidate: a not-present page won't be cached */
+	update_mmu_cache(vma, address, page_table);
 
 	pte_unmap_unlock(page_table, ptl);
 
 	if (dirty_page) {
 		struct address_space *mapping = page->mapping;
-		int dirtied = 0;
+		bool dirtied = false;
 
 		if (set_page_dirty(dirty_page))
-			dirtied = 1;
+			dirtied = true;
 		unlock_page(dirty_page);
 		put_page(dirty_page);
 		if ((dirtied || page_mkwrite) && mapping) {
@@ -3479,6 +3466,14 @@ uncharge_out:
 		page_cache_release(cow_page);
 	}
 	return ret;
+race_out:
+	if (cow_page)
+		mem_cgroup_uncharge_page(cow_page);
+	if (anon)
+		page_cache_release(page);
+	unlock_page(vmf.page);
+	page_cache_release(vmf.page);
+	return ret;
 }
 
 static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
