Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 4E76A6B00B2
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 07:58:28 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3, RFC 32/34] thp: handle write-protect exception to file-backed huge pages
Date: Fri,  5 Apr 2013 14:59:56 +0300
Message-Id: <1365163198-29726-33-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c |   69 ++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 67 insertions(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index ed4389b..6dde87f 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1339,7 +1339,6 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
 
-	VM_BUG_ON(!vma->anon_vma);
 	haddr = address & HPAGE_PMD_MASK;
 	if (is_huge_zero_pmd(orig_pmd))
 		goto alloc;
@@ -1349,7 +1348,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	page = pmd_page(orig_pmd);
 	VM_BUG_ON(!PageCompound(page) || !PageHead(page));
-	if (page_mapcount(page) == 1) {
+	if (PageAnon(page) && page_mapcount(page) == 1) {
 		pmd_t entry;
 		entry = pmd_mkyoung(orig_pmd);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
@@ -1357,10 +1356,72 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			update_mmu_cache_pmd(vma, address, pmd);
 		ret |= VM_FAULT_WRITE;
 		goto out_unlock;
+	} else if ((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
+			(VM_WRITE|VM_SHARED)) {
+		struct vm_fault vmf;
+		pmd_t entry;
+		struct address_space *mapping;
+
+		/* not yet impemented */
+		VM_BUG_ON(!vma->vm_ops || !vma->vm_ops->page_mkwrite);
+
+		vmf.virtual_address = (void __user *)haddr;
+		vmf.pgoff = page->index;
+		vmf.flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
+		vmf.page = page;
+
+		page_cache_get(page);
+		spin_unlock(&mm->page_table_lock);
+
+		ret = vma->vm_ops->page_mkwrite(vma, &vmf);
+		if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE))) {
+			page_cache_release(page);
+			goto out;
+		}
+		if (unlikely(!(ret & VM_FAULT_LOCKED))) {
+			lock_page(page);
+			if (!page->mapping) {
+				ret = 0; /* retry */
+				unlock_page(page);
+				page_cache_release(page);
+				goto out;
+			}
+		} else
+			VM_BUG_ON(!PageLocked(page));
+		spin_lock(&mm->page_table_lock);
+		if (unlikely(!pmd_same(*pmd, orig_pmd))) {
+			unlock_page(page);
+			page_cache_release(page);
+			goto out_unlock;
+		}
+
+		flush_cache_page(vma, address, pmd_pfn(orig_pmd));
+		entry = pmd_mkyoung(orig_pmd);
+		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
+		if (pmdp_set_access_flags(vma, haddr, pmd, entry,  1))
+			update_mmu_cache_pmd(vma, address, pmd);
+		ret = VM_FAULT_WRITE;
+		spin_unlock(&mm->page_table_lock);
+
+		mapping = page->mapping;
+		set_page_dirty(page);
+		unlock_page(page);
+		page_cache_release(page);
+		if (mapping)	{
+			/*
+			 * Some device drivers do not set page.mapping
+			 * but still dirty their pages
+			 */
+			balance_dirty_pages_ratelimited(mapping);
+		}
+		return ret;
 	}
 	get_page(page);
 	spin_unlock(&mm->page_table_lock);
 alloc:
+	if (unlikely(anon_vma_prepare(vma)))
+		return VM_FAULT_OOM;
+
 	if (transparent_hugepage_enabled(vma) &&
 	    !transparent_hugepage_debug_cow())
 		new_page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
@@ -1424,6 +1485,10 @@ alloc:
 			add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
 			put_huge_zero_page();
 		} else {
+			if (!PageAnon(page)) {
+				add_mm_counter(mm, MM_FILEPAGES, -HPAGE_PMD_NR);
+				add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
+			}
 			VM_BUG_ON(!PageHead(page));
 			page_remove_rmap(page);
 			put_page(page);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
