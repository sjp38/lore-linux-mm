Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 332EA6B0002
	for <linux-mm@kvack.org>; Thu, 18 Apr 2013 12:08:24 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <516F1D3C.1060804@sr71.net>
References: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1365163198-29726-32-git-send-email-kirill.shutemov@linux.intel.com>
 <51631206.3060605@sr71.net>
 <20130417143842.1A76CE0085@blue.fi.intel.com>
 <516F1D3C.1060804@sr71.net>
Subject: Re: [PATCHv3, RFC 31/34] thp: initial implementation of
 do_huge_linear_fault()
Content-Transfer-Encoding: 7bit
Message-Id: <20130418160920.4A00DE0085@blue.fi.intel.com>
Date: Thu, 18 Apr 2013 19:09:20 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Dave Hansen wrote:
> On 04/17/2013 07:38 AM, Kirill A. Shutemov wrote:
> Are you still sure you can't do _any_ better than a verbatim copy of 129
> lines?

It seems I was too lazy. Shame on me. :(
Here's consolidated version. Only build tested. Does it look better?

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 1c25b90..47651d4 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -186,6 +186,28 @@ static inline struct page *compound_trans_head(struct page *page)
 	return page;
 }
 
+static inline gfp_t alloc_hugepage_gfpmask(int defrag, gfp_t extra_gfp)
+{
+	return (GFP_TRANSHUGE & ~(defrag ? 0 : __GFP_WAIT)) | extra_gfp;
+}
+
+static inline struct page *alloc_hugepage_vma(int defrag,
+					      struct vm_area_struct *vma,
+					      unsigned long haddr, int nd,
+					      gfp_t extra_gfp)
+{
+	return alloc_pages_vma(alloc_hugepage_gfpmask(defrag, extra_gfp),
+			       HPAGE_PMD_ORDER, vma, haddr, nd);
+}
+
+static inline pmd_t mk_huge_pmd(struct page *page, pgprot_t prot)
+{
+	pmd_t entry;
+	entry = mk_pmd(page, prot);
+	entry = pmd_mkhuge(entry);
+	return entry;
+}
+
 extern int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 				unsigned long addr, pmd_t pmd, pmd_t *pmdp);
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index c8a8626..4669c19 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -165,6 +165,11 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_RETRY_NOWAIT	0x10	/* Don't drop mmap_sem and wait when retrying */
 #define FAULT_FLAG_KILLABLE	0x20	/* The fault task is in SIGKILL killable region */
 #define FAULT_FLAG_TRIED	0x40	/* second try */
+#ifdef CONFIG_CONFIG_TRANSPARENT_HUGEPAGE
+#define	FAULT_FLAG_TRANSHUGE	0x80	/* Try to allocate transhuge page */
+#else
+#define FAULT_FLAG_TRANSHUGE	0	/* Optimize out THP code if disabled*/
+#endif
 
 /*
  * vm_fault is filled by the the pagefault handler and passed to the vma's
@@ -880,6 +885,7 @@ static inline int page_mapped(struct page *page)
 #define VM_FAULT_NOPAGE	0x0100	/* ->fault installed the pte, not return page */
 #define VM_FAULT_LOCKED	0x0200	/* ->fault locked the returned page */
 #define VM_FAULT_RETRY	0x0400	/* ->fault blocked, must retry */
+#define VM_FAULT_FALLBACK 0x0800	/* large page fault failed, fall back to small */
 
 #define VM_FAULT_HWPOISON_LARGE_MASK 0xf000 /* encodes hpage index for large hwpoison */
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 73691a3..e14fa81 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -692,14 +692,6 @@ pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma)
 	return pmd;
 }
 
-static inline pmd_t mk_huge_pmd(struct page *page, pgprot_t prot)
-{
-	pmd_t entry;
-	entry = mk_pmd(page, prot);
-	entry = pmd_mkhuge(entry);
-	return entry;
-}
-
 static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 					struct vm_area_struct *vma,
 					unsigned long haddr, pmd_t *pmd,
@@ -742,20 +734,6 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 	return 0;
 }
 
-static inline gfp_t alloc_hugepage_gfpmask(int defrag, gfp_t extra_gfp)
-{
-	return (GFP_TRANSHUGE & ~(defrag ? 0 : __GFP_WAIT)) | extra_gfp;
-}
-
-static inline struct page *alloc_hugepage_vma(int defrag,
-					      struct vm_area_struct *vma,
-					      unsigned long haddr, int nd,
-					      gfp_t extra_gfp)
-{
-	return alloc_pages_vma(alloc_hugepage_gfpmask(defrag, extra_gfp),
-			       HPAGE_PMD_ORDER, vma, haddr, nd);
-}
-
 #ifndef CONFIG_NUMA
 static inline struct page *alloc_hugepage(int defrag)
 {
diff --git a/mm/memory.c b/mm/memory.c
index 5f782d6..e6efd8c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -59,6 +59,7 @@
 #include <linux/gfp.h>
 #include <linux/migrate.h>
 #include <linux/string.h>
+#include <linux/khugepaged.h>
 
 #include <asm/io.h>
 #include <asm/pgalloc.h>
@@ -3229,6 +3230,53 @@ oom:
 	return VM_FAULT_OOM;
 }
 
+static inline bool transhuge_vma_suitable(struct vm_area_struct *vma,
+		unsigned long addr)
+{
+	unsigned long haddr = addr & HPAGE_PMD_MASK;
+
+	if (((vma->vm_start >> PAGE_SHIFT) & HPAGE_CACHE_INDEX_MASK) !=
+	    (vma->vm_pgoff & HPAGE_CACHE_INDEX_MASK)) {
+		return false;
+	}
+	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end) {
+		return false;
+	}
+	return true;
+}
+
+static struct page *alloc_fault_page_vma(struct vm_area_struct *vma,
+		unsigned long addr, unsigned int flags)
+{
+
+	if (flags & FAULT_FLAG_TRANSHUGE) {
+		struct page *page;
+		unsigned long haddr = addr & HPAGE_PMD_MASK;
+
+		page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
+				vma, haddr, numa_node_id(), 0);
+		if (page)
+			count_vm_event(THP_FAULT_ALLOC);
+		else
+			count_vm_event(THP_FAULT_FALLBACK);
+		return page;
+	}
+	return alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, addr);
+}
+
+static inline bool ptl_lock_and_check_entry(struct mm_struct *mm, pmd_t *pmd,
+	       unsigned long address, spinlock_t **ptl, pte_t **page_table,
+	       pte_t orig_pte, unsigned int flags)
+{
+	if (flags & FAULT_FLAG_TRANSHUGE) {
+		spin_lock(&mm->page_table_lock);
+		return !pmd_none(*pmd);
+	} else {
+		*page_table  = pte_offset_map_lock(mm, pmd, address, ptl);
+		return !pte_same(**page_table, orig_pte);
+	}
+}
+
 /*
  * __do_fault() tries to create a new page mapping. It aggressively
  * tries to share with existing pages, but makes a separate copy if
@@ -3246,45 +3294,61 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pmd_t *pmd,
 		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
 {
+	unsigned long haddr = address & PAGE_MASK;
 	pte_t *page_table;
 	spinlock_t *ptl;
-	struct page *page;
-	struct page *cow_page;
-	pte_t entry;
-	int anon = 0;
-	struct page *dirty_page = NULL;
+	struct page *page, *cow_page, *dirty_page = NULL;
+	bool anon = false, page_mkwrite = false;
+	bool try_huge_pages = !!(flags & FAULT_FLAG_TRANSHUGE);
+	pgtable_t pgtable = NULL;
 	struct vm_fault vmf;
-	int ret;
-	int page_mkwrite = 0;
+	int nr = 1, ret;
+
+	if (try_huge_pages) {
+		if (!transhuge_vma_suitable(vma, haddr))
+			return VM_FAULT_FALLBACK;
+		if (unlikely(khugepaged_enter(vma)))
+			return VM_FAULT_OOM;
+		nr = HPAGE_PMD_NR;
+		haddr = address & HPAGE_PMD_MASK;
+		pgoff = linear_page_index(vma, haddr);
+	}
 
 	/*
 	 * If we do COW later, allocate page befor taking lock_page()
 	 * on the file cache page. This will reduce lock holding time.
 	 */
 	if ((flags & FAULT_FLAG_WRITE) && !(vma->vm_flags & VM_SHARED)) {
-
 		if (unlikely(anon_vma_prepare(vma)))
 			return VM_FAULT_OOM;
 
-		cow_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
+		cow_page = alloc_fault_page_vma(vma, address, flags);
 		if (!cow_page)
-			return VM_FAULT_OOM;
+			return VM_FAULT_OOM | VM_FAULT_FALLBACK;
 
 		if (mem_cgroup_newpage_charge(cow_page, mm, GFP_KERNEL)) {
 			page_cache_release(cow_page);
-			return VM_FAULT_OOM;
+			return VM_FAULT_OOM | VM_FAULT_FALLBACK;
 		}
 	} else
 		cow_page = NULL;
 
-	vmf.virtual_address = (void __user *)(address & PAGE_MASK);
+	vmf.virtual_address = (void __user *)haddr;
 	vmf.pgoff = pgoff;
 	vmf.flags = flags;
 	vmf.page = NULL;
 
-	ret = vma->vm_ops->fault(vma, &vmf);
+	if (try_huge_pages) {
+		pgtable = pte_alloc_one(mm, haddr);
+		if (unlikely(!pgtable)) {
+			ret = VM_FAULT_OOM;
+			goto uncharge_out;
+		}
+		ret = vma->vm_ops->huge_fault(vma, &vmf);
+	} else
+		ret = vma->vm_ops->fault(vma, &vmf);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE |
-			    VM_FAULT_RETRY)))
+			    VM_FAULT_RETRY | VM_FAULT_FALLBACK)))
 		goto uncharge_out;
 
 	if (unlikely(PageHWPoison(vmf.page))) {
@@ -3310,42 +3374,69 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (flags & FAULT_FLAG_WRITE) {
 		if (!(vma->vm_flags & VM_SHARED)) {
 			page = cow_page;
-			anon = 1;
-			copy_user_highpage(page, vmf.page, address, vma);
+			anon = true;
+			if (try_huge_pages)
+				copy_user_highpage(page, vmf.page,
+						address, vma);
+			else
+				copy_user_huge_page(page, vmf.page, haddr, vma,
+						HPAGE_PMD_NR);
 			__SetPageUptodate(page);
-		} else {
+		} else if (vma->vm_ops->page_mkwrite) {
 			/*
 			 * If the page will be shareable, see if the backing
 			 * address space wants to know that the page is about
 			 * to become writable
 			 */
-			if (vma->vm_ops->page_mkwrite) {
-				int tmp;
-
-				unlock_page(page);
-				vmf.flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
-				tmp = vma->vm_ops->page_mkwrite(vma, &vmf);
-				if (unlikely(tmp &
-					  (VM_FAULT_ERROR | VM_FAULT_NOPAGE))) {
-					ret = tmp;
+			int tmp;
+
+			unlock_page(page);
+			vmf.flags = FAULT_FLAG_WRITE | FAULT_FLAG_MKWRITE;
+			tmp = vma->vm_ops->page_mkwrite(vma, &vmf);
+			if (unlikely(tmp &
+					(VM_FAULT_ERROR | VM_FAULT_NOPAGE))) {
+				ret = tmp;
+				goto unwritable_page;
+			}
+			if (unlikely(!(tmp & VM_FAULT_LOCKED))) {
+				lock_page(page);
+				if (!page->mapping) {
+					ret = 0; /* retry the fault */
+					unlock_page(page);
 					goto unwritable_page;
 				}
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
-			}
+			} else
+				VM_BUG_ON(!PageLocked(page));
+			page_mkwrite = true;
 		}
+	}
 
+	if (unlikely(ptl_lock_and_check_entry(mm, pmd, address,
+					&ptl, &page_table, orig_pte, flags))) {
+		/* pte/pmd has changed. do not touch it */
+		if (pgtable)
+			pte_free(mm, pgtable);
+		if (cow_page)
+			mem_cgroup_uncharge_page(cow_page);
+		if (anon)
+			page_cache_release(page);
+		unlock_page(vmf.page);
+		page_cache_release(vmf.page);
+		return ret;
 	}
 
-	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+	flush_icache_page(vma, page);
+	if (anon) {
+		add_mm_counter_fast(mm, MM_ANONPAGES, nr);
+		page_add_new_anon_rmap(page, vma, address);
+	} else {
+		add_mm_counter_fast(mm, MM_FILEPAGES, nr);
+		page_add_file_rmap(page);
+		if (flags & FAULT_FLAG_WRITE) {
+			dirty_page = page;
+			get_page(dirty_page);
+		}
+	}
 
 	/*
 	 * This silly early PAGE_DIRTY setting removes a race
@@ -3358,43 +3449,28 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * handle that later.
 	 */
 	/* Only go through if we didn't race with anybody else... */
-	if (likely(pte_same(*page_table, orig_pte))) {
-		flush_icache_page(vma, page);
-		entry = mk_pte(page, vma->vm_page_prot);
+	if (try_huge_pages) {
+		pmd_t entry = mk_huge_pmd(page, vma->vm_page_prot);
 		if (flags & FAULT_FLAG_WRITE)
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
-
-		/* no need to invalidate: a not-present page won't be cached */
+			entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
+		set_pmd_at(mm, address, pmd, entry);
 		update_mmu_cache(vma, address, page_table);
+		spin_lock(&mm->page_table_lock);
 	} else {
-		if (cow_page)
-			mem_cgroup_uncharge_page(cow_page);
-		if (anon)
-			page_cache_release(page);
-		else
-			anon = 1; /* no anon but release faulted_page */
+		pte_t entry = mk_pte(page, vma->vm_page_prot);
+		if (flags & FAULT_FLAG_WRITE)
+			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		set_pte_at(mm, address, page_table, entry);
+		update_mmu_cache_pmd(vma, address, pmd);
+		pte_unmap_unlock(page_table, ptl);
 	}
 
-	pte_unmap_unlock(page_table, ptl);
-
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
@@ -3413,13 +3489,16 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		if (anon)
 			page_cache_release(vmf.page);
 	}
-
 	return ret;
 
 unwritable_page:
+	if (pgtable)
+		pte_free(mm, pgtable);
 	page_cache_release(page);
 	return ret;
 uncharge_out:
+	if (pgtable)
+		pte_free(mm, pgtable);
 	/* fs's fault handler get error */
 	if (cow_page) {
 		mem_cgroup_uncharge_page(cow_page);
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
