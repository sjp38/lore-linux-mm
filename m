Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 7C2366B00C5
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 07:58:27 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3, RFC 31/34] thp: initial implementation of do_huge_linear_fault()
Date: Fri,  5 Apr 2013 14:59:55 +0300
Message-Id: <1365163198-29726-32-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The function tries to create a new page mapping using huge pages. It
only called for not yet mapped pages.

As usual in THP, we fallback to small pages if we fail to allocate huge
page.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/huge_mm.h |    3 +
 mm/huge_memory.c        |  196 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 199 insertions(+)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index b53e295..aa52c48 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -5,6 +5,9 @@ extern int do_huge_pmd_anonymous_page(struct mm_struct *mm,
 				      struct vm_area_struct *vma,
 				      unsigned long address, pmd_t *pmd,
 				      unsigned int flags);
+extern int do_huge_linear_fault(struct mm_struct *mm,
+		struct vm_area_struct *vma, unsigned long address, pmd_t *pmd,
+		unsigned int flags);
 extern int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 			 pmd_t *dst_pmd, pmd_t *src_pmd, unsigned long addr,
 			 struct vm_area_struct *vma);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index c1d5f2b..ed4389b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -21,6 +21,7 @@
 #include <linux/pagemap.h>
 #include <linux/migrate.h>
 #include <linux/hashtable.h>
+#include <linux/writeback.h>
 
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
@@ -864,6 +865,201 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	return 0;
 }
 
+int do_huge_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
+		unsigned long address, pmd_t *pmd, unsigned int flags)
+{
+	unsigned long haddr = address & HPAGE_PMD_MASK;
+	struct page *cow_page, *page, *dirty_page = NULL;
+	bool anon = false, fallback = false, page_mkwrite = false;
+	pgtable_t pgtable = NULL;
+	struct vm_fault vmf;
+	int ret;
+
+	/* Fallback if vm_pgoff and vm_start are not suitable */
+	if (((vma->vm_start >> PAGE_SHIFT) & HPAGE_CACHE_INDEX_MASK) !=
+			(vma->vm_pgoff & HPAGE_CACHE_INDEX_MASK))
+		return do_fallback(mm, vma, address, pmd, flags);
+
+	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
+		return do_fallback(mm, vma, address, pmd, flags);
+
+	if (unlikely(khugepaged_enter(vma)))
+		return VM_FAULT_OOM;
+
+	/*
+	 * If we do COW later, allocate page before taking lock_page()
+	 * on the file cache page. This will reduce lock holding time.
+	 */
+	if ((flags & FAULT_FLAG_WRITE) && !(vma->vm_flags & VM_SHARED)) {
+		if (unlikely(anon_vma_prepare(vma)))
+			return VM_FAULT_OOM;
+
+		cow_page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
+				vma, haddr, numa_node_id(), 0);
+		if (!cow_page) {
+			count_vm_event(THP_FAULT_FALLBACK);
+			return do_fallback(mm, vma, address, pmd, flags);
+		}
+		count_vm_event(THP_FAULT_ALLOC);
+		if (mem_cgroup_newpage_charge(cow_page, mm, GFP_KERNEL)) {
+			page_cache_release(cow_page);
+			return do_fallback(mm, vma, address, pmd, flags);
+		}
+	} else
+		cow_page = NULL;
+
+	pgtable = pte_alloc_one(mm, haddr);
+	if (unlikely(!pgtable)) {
+		ret = VM_FAULT_OOM;
+		goto uncharge_out;
+	}
+
+	vmf.virtual_address = (void __user *)haddr;
+	vmf.pgoff = ((haddr - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
+	vmf.flags = flags;
+	vmf.page = NULL;
+
+	ret = vma->vm_ops->huge_fault(vma, &vmf);
+	if (unlikely(ret & VM_FAULT_OOM))
+		goto uncharge_out_fallback;
+	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
+		goto uncharge_out;
+
+	if (unlikely(PageHWPoison(vmf.page))) {
+		if (ret & VM_FAULT_LOCKED)
+			unlock_page(vmf.page);
+		ret = VM_FAULT_HWPOISON;
+		goto uncharge_out;
+	}
+
+	/*
+	 * For consistency in subsequent calls, make the faulted page always
+	 * locked.
+	 */
+	if (unlikely(!(ret & VM_FAULT_LOCKED)))
+		lock_page(vmf.page);
+	else
+		VM_BUG_ON(!PageLocked(vmf.page));
+
+	/*
+	 * Should we do an early C-O-W break?
+	 */
+	page = vmf.page;
+	if (flags & FAULT_FLAG_WRITE) {
+		if (!(vma->vm_flags & VM_SHARED)) {
+			page = cow_page;
+			anon = true;
+			copy_user_huge_page(page, vmf.page, haddr, vma,
+					HPAGE_PMD_NR);
+			__SetPageUptodate(page);
+		} else if (vma->vm_ops->page_mkwrite) {
+			int tmp;
+
+			unlock_page(page);
+			vmf.flags = FAULT_FLAG_WRITE | FAULT_FLAG_MKWRITE;
+			tmp = vma->vm_ops->page_mkwrite(vma, &vmf);
+			if (unlikely(tmp &
+				  (VM_FAULT_ERROR | VM_FAULT_NOPAGE))) {
+				ret = tmp;
+				goto unwritable_page;
+			}
+			if (unlikely(!(tmp & VM_FAULT_LOCKED))) {
+				lock_page(page);
+				if (!page->mapping) {
+					ret = 0; /* retry the fault */
+					unlock_page(page);
+					goto unwritable_page;
+				}
+			} else
+				VM_BUG_ON(!PageLocked(page));
+			page_mkwrite = true;
+		}
+	}
+
+	VM_BUG_ON(!PageCompound(page));
+
+	spin_lock(&mm->page_table_lock);
+	if (likely(pmd_none(*pmd))) {
+		pmd_t entry;
+
+		flush_icache_page(vma, page);
+		entry = mk_huge_pmd(page, vma->vm_page_prot);
+		if (flags & FAULT_FLAG_WRITE)
+			entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
+		if (anon) {
+			add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
+			page_add_new_anon_rmap(page, vma, haddr);
+		} else {
+			add_mm_counter(mm, MM_FILEPAGES, HPAGE_PMD_NR);
+			page_add_file_rmap(page);
+			if (flags & FAULT_FLAG_WRITE) {
+				dirty_page = page;
+				get_page(dirty_page);
+			}
+		}
+		set_pmd_at(mm, haddr, pmd, entry);
+		pgtable_trans_huge_deposit(mm, pgtable);
+		mm->nr_ptes++;
+
+		/* no need to invalidate: a not-present page won't be cached */
+		update_mmu_cache_pmd(vma, address, pmd);
+	} else {
+		if (cow_page)
+			mem_cgroup_uncharge_page(cow_page);
+		if (anon)
+			page_cache_release(page);
+		else
+			anon = true; /* no anon but release faulted_page */
+	}
+	spin_unlock(&mm->page_table_lock);
+
+	if (dirty_page) {
+		struct address_space *mapping = page->mapping;
+		bool dirtied = false;
+
+		if (set_page_dirty(dirty_page))
+			dirtied = true;
+		unlock_page(dirty_page);
+		put_page(dirty_page);
+		if ((dirtied || page_mkwrite) && mapping) {
+			/*
+			 * Some device drivers do not set page.mapping but still
+			 * dirty their pages
+			 */
+			balance_dirty_pages_ratelimited(mapping);
+		}
+
+		/* file_update_time outside page_lock */
+		if (vma->vm_file && !page_mkwrite)
+			file_update_time(vma->vm_file);
+	} else {
+		unlock_page(vmf.page);
+		if (anon)
+			page_cache_release(vmf.page);
+	}
+
+	return ret;
+
+unwritable_page:
+	pte_free(mm, pgtable);
+	page_cache_release(page);
+	return ret;
+uncharge_out_fallback:
+	fallback = true;
+uncharge_out:
+	if (pgtable)
+		pte_free(mm, pgtable);
+	if (cow_page) {
+		mem_cgroup_uncharge_page(cow_page);
+		page_cache_release(cow_page);
+	}
+
+	if (fallback)
+		return do_fallback(mm, vma, address, pmd, flags);
+	else
+		return ret;
+}
+
 int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		  pmd_t *dst_pmd, pmd_t *src_pmd, unsigned long addr,
 		  struct vm_area_struct *vma)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
