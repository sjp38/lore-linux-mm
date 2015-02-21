Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id BF8006B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 23:18:14 -0500 (EST)
Received: by pdjy10 with SMTP id y10so12005986pdj.13
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:18:14 -0800 (PST)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com. [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id oc3si5668086pbb.130.2015.02.20.20.18.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Feb 2015 20:18:13 -0800 (PST)
Received: by pdjz10 with SMTP id z10so12003222pdj.12
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:18:13 -0800 (PST)
Date: Fri, 20 Feb 2015 20:18:11 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 17/24] huge tmpfs: map shmem by huge page pmd or by page team
 ptes
In-Reply-To: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1502202016420.14414@eggly.anvils>
References: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ning Qu <quning@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is the commit which at last gets huge mappings of tmpfs working,
as can be seen from the ShmemPmdMapped line of /proc/meminfo.

The main thing here is the trio of functions map_team_by_pmd(),
unmap_team_by_pmd() and remap_team_by_ptes() added to huge_memory.c;
and of course the enablement of FAULT_FLAG_MAY_HUGE from memory.c
to shmem.c, with VM_FAULT_HUGE back from shmem.c to memory.c.  But
one-line and few-line changes scattered throughout huge_memory.c.

Huge tmpfs is relying on the pmd_trans_huge() page table hooks which
the original Anonymous THP project placed throughout mm; but skips
almost all of its complications, going to its own simpler handling.

One odd little change: removal of the VM_NOHUGEPAGE check from
move_huge_pmd().  That's a helper for mremap() move: the new_vma
should be following the same rules as the old vma, so if there's a
trans_huge pmd in the old vma, then it can go in the new, alignment
permitting.  It was a very minor optimization for Anonymous THP; but
now we can reach the same code for huge tmpfs, which is nowhere else
respecting VM_NOHUGEPAGE (whether it should is a different question;
but for now it's simplest to ignore all the various THP switches).

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/pageteam.h |   41 ++++++
 mm/huge_memory.c         |  238 ++++++++++++++++++++++++++++++++++---
 mm/memory.c              |   11 +
 3 files changed, 273 insertions(+), 17 deletions(-)

--- thpfs.orig/include/linux/pageteam.h	2015-02-20 19:34:37.851932430 -0800
+++ thpfs/include/linux/pageteam.h	2015-02-20 19:34:48.083909034 -0800
@@ -29,10 +29,49 @@ static inline struct page *team_head(str
 	return head;
 }
 
-/* Temporary stub for mm/rmap.c until implemented in mm/huge_memory.c */
+/*
+ * Returns true if this team is mapped by pmd somewhere.
+ */
+static inline bool team_hugely_mapped(struct page *head)
+{
+	return atomic_long_read(&head->team_usage) > HPAGE_PMD_NR;
+}
+
+/*
+ * Returns true if this was the first mapping by pmd, whereupon mapped stats
+ * need to be updated.
+ */
+static inline bool inc_hugely_mapped(struct page *head)
+{
+	return atomic_long_inc_return(&head->team_usage) == HPAGE_PMD_NR+1;
+}
+
+/*
+ * Returns true if this was the last mapping by pmd, whereupon mapped stats
+ * need to be updated.
+ */
+static inline bool dec_hugely_mapped(struct page *head)
+{
+	return atomic_long_dec_return(&head->team_usage) == HPAGE_PMD_NR;
+}
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+int map_team_by_pmd(struct vm_area_struct *vma,
+			unsigned long addr, pmd_t *pmd, struct page *page);
+void unmap_team_by_pmd(struct vm_area_struct *vma,
+			unsigned long addr, pmd_t *pmd, struct page *page);
+#else
+static inline int map_team_by_pmd(struct vm_area_struct *vma,
+			unsigned long addr, pmd_t *pmd, struct page *page)
+{
+	VM_BUG_ON_PAGE(1, page);
+	return 0;
+}
 static inline void unmap_team_by_pmd(struct vm_area_struct *vma,
 			unsigned long addr, pmd_t *pmd, struct page *page)
 {
+	VM_BUG_ON_PAGE(1, page);
 }
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 #endif /* _LINUX_PAGETEAM_H */
--- thpfs.orig/mm/huge_memory.c	2015-02-20 19:34:32.367944969 -0800
+++ thpfs/mm/huge_memory.c	2015-02-20 19:34:48.083909034 -0800
@@ -21,6 +21,7 @@
 #include <linux/freezer.h>
 #include <linux/mman.h>
 #include <linux/pagemap.h>
+#include <linux/pageteam.h>
 #include <linux/migrate.h>
 #include <linux/hashtable.h>
 
@@ -28,6 +29,10 @@
 #include <asm/pgalloc.h>
 #include "internal.h"
 
+static void page_remove_team_rmap(struct page *);
+static void remap_team_by_ptes(struct vm_area_struct *vma, unsigned long addr,
+			       pmd_t *pmd, struct page *page);
+
 /*
  * By default transparent hugepage support is disabled in order that avoid
  * to risk increase the memory footprint of applications without a guaranteed
@@ -901,13 +906,19 @@ int copy_huge_pmd(struct mm_struct *dst_
 		goto out;
 	}
 	src_page = pmd_page(pmd);
-	VM_BUG_ON_PAGE(!PageHead(src_page), src_page);
 	get_page(src_page);
 	page_dup_rmap(src_page);
-	add_mm_counter(dst_mm, MM_ANONPAGES, HPAGE_PMD_NR);
-
-	pmdp_set_wrprotect(src_mm, addr, src_pmd);
-	pmd = pmd_mkold(pmd_wrprotect(pmd));
+	if (PageAnon(src_page)) {
+		VM_BUG_ON_PAGE(!PageHead(src_page), src_page);
+		pmdp_set_wrprotect(src_mm, addr, src_pmd);
+		pmd = pmd_wrprotect(pmd);
+	} else {
+		VM_BUG_ON_PAGE(!PageTeam(src_page), src_page);
+		inc_hugely_mapped(src_page);
+	}
+	add_mm_counter(dst_mm, PageAnon(src_page) ?
+		MM_ANONPAGES : MM_FILEPAGES, HPAGE_PMD_NR);
+	pmd = pmd_mkold(pmd);
 	pgtable_trans_huge_deposit(dst_mm, dst_pmd, pgtable);
 	set_pmd_at(dst_mm, addr, dst_pmd, pmd);
 	atomic_long_inc(&dst_mm->nr_ptes);
@@ -1088,22 +1099,28 @@ int do_huge_pmd_wp_page(struct mm_struct
 {
 	spinlock_t *ptl;
 	int ret = 0;
-	struct page *page = NULL, *new_page;
+	struct page *page, *new_page;
 	struct mem_cgroup *memcg;
 	unsigned long haddr;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
 
 	ptl = pmd_lockptr(mm, pmd);
-	VM_BUG_ON_VMA(!vma->anon_vma, vma);
 	haddr = address & HPAGE_PMD_MASK;
-	if (is_huge_zero_pmd(orig_pmd))
+	page = pmd_page(orig_pmd);
+	if (is_huge_zero_page(page)) {
+		page = NULL;
 		goto alloc;
+	}
+	if (!PageAnon(page)) {
+		remap_team_by_ptes(vma, address, pmd, page);
+		/* Let's just take another fault to do the COW */
+		return 0;
+	}
 	spin_lock(ptl);
 	if (unlikely(!pmd_same(*pmd, orig_pmd)))
 		goto out_unlock;
 
-	page = pmd_page(orig_pmd);
 	VM_BUG_ON_PAGE(!PageCompound(page) || !PageHead(page), page);
 	if (page_mapcount(page) == 1) {
 		pmd_t entry;
@@ -1117,6 +1134,7 @@ int do_huge_pmd_wp_page(struct mm_struct
 	get_user_huge_page(page);
 	spin_unlock(ptl);
 alloc:
+	VM_BUG_ON(!vma->anon_vma);
 	if (transparent_hugepage_enabled(vma) &&
 	    !transparent_hugepage_debug_cow())
 		new_page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
@@ -1226,7 +1244,7 @@ struct page *follow_trans_huge_pmd(struc
 		goto out;
 
 	page = pmd_page(*pmd);
-	VM_BUG_ON_PAGE(!PageHead(page), page);
+	VM_BUG_ON_PAGE(!PageHead(page) && !PageTeam(page), page);
 	if (flags & FOLL_TOUCH) {
 		pmd_t _pmd;
 		/*
@@ -1251,7 +1269,7 @@ struct page *follow_trans_huge_pmd(struc
 		}
 	}
 	page += (addr & ~HPAGE_PMD_MASK) >> PAGE_SHIFT;
-	VM_BUG_ON_PAGE(!PageCompound(page), page);
+	VM_BUG_ON_PAGE(!PageCompound(page) && !PageTeam(page), page);
 	if (flags & FOLL_GET)
 		get_page_foll(page);
 
@@ -1409,10 +1427,12 @@ int zap_huge_pmd(struct mmu_gather *tlb,
 			put_huge_zero_page();
 		} else {
 			page = pmd_page(orig_pmd);
+			if (!PageAnon(page))
+				page_remove_team_rmap(page);
 			page_remove_rmap(page);
 			VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
-			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
-			VM_BUG_ON_PAGE(!PageHead(page), page);
+			add_mm_counter(tlb->mm, PageAnon(page) ?
+				MM_ANONPAGES : MM_FILEPAGES, -HPAGE_PMD_NR);
 			atomic_long_dec(&tlb->mm->nr_ptes);
 			spin_unlock(ptl);
 			tlb_remove_page(tlb, page);
@@ -1456,8 +1476,7 @@ int move_huge_pmd(struct vm_area_struct
 
 	if ((old_addr & ~HPAGE_PMD_MASK) ||
 	    (new_addr & ~HPAGE_PMD_MASK) ||
-	    old_end - old_addr < HPAGE_PMD_SIZE ||
-	    (new_vma->vm_flags & VM_NOHUGEPAGE))
+	    old_end - old_addr < HPAGE_PMD_SIZE)
 		goto out;
 
 	/*
@@ -1518,7 +1537,6 @@ int change_huge_pmd(struct vm_area_struc
 			entry = pmd_modify(entry, newprot);
 			ret = HPAGE_PMD_NR;
 			set_pmd_at(mm, addr, pmd, entry);
-			BUG_ON(pmd_write(entry));
 		} else {
 			struct page *page = pmd_page(*pmd);
 
@@ -2864,6 +2882,17 @@ void __split_huge_page_pmd(struct vm_are
 	unsigned long haddr = address & HPAGE_PMD_MASK;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
+	pmd_t pmdval;
+
+	pmdval = *pmd;
+	barrier();
+	if (!pmd_present(pmdval) || !pmd_trans_huge(pmdval))
+		return;
+	page = pmd_page(pmdval);
+	if (!PageAnon(page) && !is_huge_zero_page(page)) {
+		remap_team_by_ptes(vma, address, pmd, page);
+		return;
+	}
 
 	BUG_ON(vma->vm_start > haddr || vma->vm_end < haddr + HPAGE_PMD_SIZE);
 
@@ -2976,3 +3005,180 @@ void __vma_adjust_trans_huge(struct vm_a
 			split_huge_page_address(next->vm_mm, nstart);
 	}
 }
+
+/*
+ * huge pmd support for huge tmpfs
+ */
+
+static void page_add_team_rmap(struct page *page)
+{
+	VM_BUG_ON_PAGE(PageAnon(page), page);
+	VM_BUG_ON_PAGE(!PageTeam(page), page);
+	if (inc_hugely_mapped(page))
+		__inc_zone_page_state(page, NR_SHMEM_PMDMAPPED);
+}
+
+static void page_remove_team_rmap(struct page *page)
+{
+	VM_BUG_ON_PAGE(PageAnon(page), page);
+	VM_BUG_ON_PAGE(!PageTeam(page), page);
+	if (dec_hugely_mapped(page))
+		__dec_zone_page_state(page, NR_SHMEM_PMDMAPPED);
+}
+
+int map_team_by_pmd(struct vm_area_struct *vma, unsigned long addr,
+		    pmd_t *pmd, struct page *page)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pgtable_t pgtable;
+	spinlock_t *pml;
+	pmd_t pmdval;
+	int ret = VM_FAULT_NOPAGE;
+
+	/*
+	 * Another task may have mapped it in just ahead of us; but we
+	 * have the huge page locked, so others will wait on us now... or,
+	 * is there perhaps some way another might still map in a single pte?
+	 */
+	VM_BUG_ON_PAGE(!PageTeam(page), page);
+	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	if (!pmd_none(*pmd))
+		goto raced2;
+
+	addr &= HPAGE_PMD_MASK;
+	pgtable = pte_alloc_one(mm, addr);
+	if (!pgtable) {
+		ret = VM_FAULT_OOM;
+		goto raced2;
+	}
+
+	pml = pmd_lock(mm, pmd);
+	if (!pmd_none(*pmd))
+		goto raced1;
+	pmdval = mk_pmd(page, vma->vm_page_prot);
+	pmdval = pmd_mkhuge(pmd_mkdirty(pmdval));
+	set_pmd_at(mm, addr, pmd, pmdval);
+	page_add_file_rmap(page);
+	page_add_team_rmap(page);
+	update_mmu_cache_pmd(vma, addr, pmd);
+	pgtable_trans_huge_deposit(mm, pmd, pgtable);
+	atomic_long_inc(&mm->nr_ptes);
+	spin_unlock(pml);
+
+	unlock_page(page);
+	add_mm_counter(mm, MM_FILEPAGES, HPAGE_PMD_NR);
+	return ret;
+raced1:
+	spin_unlock(pml);
+	pte_free(mm, pgtable);
+raced2:
+	unlock_page(page);
+	page_cache_release(page);
+	return ret;
+}
+
+void unmap_team_by_pmd(struct vm_area_struct *vma, unsigned long addr,
+		       pmd_t *pmd, struct page *page)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pgtable_t pgtable = NULL;
+	unsigned long end;
+	spinlock_t *pml;
+
+	VM_BUG_ON_PAGE(!PageTeam(page), page);
+	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	/*
+	 * But even so there might be a racing zap_huge_pmd() or
+	 * remap_team_by_ptes() while the page_table_lock is dropped.
+	 */
+
+	addr &= HPAGE_PMD_MASK;
+	end = addr + HPAGE_PMD_SIZE;
+
+	mmu_notifier_invalidate_range_start(mm, addr, end);
+	pml = pmd_lock(mm, pmd);
+	if (pmd_trans_huge(*pmd) && pmd_page(*pmd) == page) {
+		pmdp_clear_flush(vma, addr, pmd);
+		pgtable = pgtable_trans_huge_withdraw(mm, pmd);
+		page_remove_team_rmap(page);
+		page_remove_rmap(page);
+		atomic_long_dec(&mm->nr_ptes);
+	}
+	spin_unlock(pml);
+	mmu_notifier_invalidate_range_end(mm, addr, end);
+
+	if (!pgtable)
+		return;
+
+	pte_free(mm, pgtable);
+	update_hiwater_rss(mm);
+	add_mm_counter(mm, MM_FILEPAGES, -HPAGE_PMD_NR);
+	page_cache_release(page);
+}
+
+static void remap_team_by_ptes(struct vm_area_struct *vma, unsigned long addr,
+			       pmd_t *pmd, struct page *page)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	struct page *head = page;
+	pgtable_t pgtable;
+	unsigned long end;
+	spinlock_t *pml;
+	spinlock_t *ptl;
+	pte_t *pte;
+	pmd_t pmdval;
+	pte_t pteval;
+
+	addr &= HPAGE_PMD_MASK;
+	end = addr + HPAGE_PMD_SIZE;
+
+	mmu_notifier_invalidate_range_start(mm, addr, end);
+	pml = pmd_lock(mm, pmd);
+	if (!pmd_trans_huge(*pmd) || pmd_page(*pmd) != page)
+		goto raced;
+
+	pmdval = pmdp_clear_flush(vma, addr, pmd);
+	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
+	pmd_populate(mm, pmd, pgtable);
+	ptl = pte_lockptr(mm, pmd);
+	if (ptl != pml)
+		spin_lock_nested(ptl, SINGLE_DEPTH_NESTING);
+	page_remove_team_rmap(page);
+	update_mmu_cache_pmd(vma, addr, pmd);
+
+	/*
+	 * It would be nice to have prepared this page table in advance,
+	 * so we could just switch from pmd to ptes under one lock.
+	 * But a comment in zap_huge_pmd() warns that ppc64 needs
+	 * to look at the deposited page table when clearing the pmd.
+	 */
+	pte = pte_offset_map(pmd, addr);
+	do {
+		pteval = pte_mkdirty(mk_pte(page, vma->vm_page_prot));
+		if (!pmd_young(pmdval))
+			pteval = pte_mkold(pteval);
+		set_pte_at(mm, addr, pte, pteval);
+		if (page != head) {
+			/*
+			 * We did not remove the head's rmap count above: that
+			 * seems better than letting it slip to 0 for a moment.
+			 */
+			page_add_file_rmap(page);
+			page_cache_get(page);
+		}
+		/*
+		 * Move page flags from head to page,
+		 * as __split_huge_page_refcount() does for anon?
+		 * Start off by assuming not, but reconsider later.
+		 */
+	} while (pte++, page++, addr += PAGE_SIZE, addr != end);
+
+	pte -= HPAGE_PMD_NR;
+	addr -= HPAGE_PMD_NR;
+	if (ptl != pml)
+		spin_unlock(ptl);
+	pte_unmap(pte);
+raced:
+	spin_unlock(pml);
+	mmu_notifier_invalidate_range_end(mm, addr, end);
+}
--- thpfs.orig/mm/memory.c	2015-02-20 19:34:42.875920943 -0800
+++ thpfs/mm/memory.c	2015-02-20 19:34:48.083909034 -0800
@@ -45,6 +45,7 @@
 #include <linux/swap.h>
 #include <linux/highmem.h>
 #include <linux/pagemap.h>
+#include <linux/pageteam.h>
 #include <linux/ksm.h>
 #include <linux/rmap.h>
 #include <linux/export.h>
@@ -2716,9 +2717,19 @@ static int __do_fault(struct vm_area_str
 	vmf.flags = flags;
 	vmf.page = NULL;
 
+	/*
+	 * Give huge pmd a chance before allocating pte or trying fault around.
+	 */
+	if (unlikely(pmd_none(*pmd)))
+		vmf.flags |= FAULT_FLAG_MAY_HUGE;
+
 	ret = vma->vm_ops->fault(vma, &vmf);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
+	if (unlikely(ret & VM_FAULT_HUGE)) {
+		ret |= map_team_by_pmd(vma, address, pmd, vmf.page);
+		return ret;
+	}
 
 	if (unlikely(!(ret & VM_FAULT_LOCKED)))
 		lock_page(vmf.page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
