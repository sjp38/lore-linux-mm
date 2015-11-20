Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1133E6B025D
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 03:03:07 -0500 (EST)
Received: by ioc74 with SMTP id 74so115794787ioc.2
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 00:03:06 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id qe3si2146767igb.8.2015.11.20.00.02.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 20 Nov 2015 00:02:57 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v4 12/16] mm: don't split THP page when syscall is called
Date: Fri, 20 Nov 2015 17:02:44 +0900
Message-Id: <1448006568-16031-13-git-send-email-minchan@kernel.org>
In-Reply-To: <1448006568-16031-1-git-send-email-minchan@kernel.org>
References: <1448006568-16031-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Andy Lutomirski <luto@amacapital.net>, Minchan Kim <minchan@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>

We don't need to split THP page when MADV_FREE syscall is called.
It could be done when VM decide to free it in reclaim path when
memory pressure is heavy so we could avoid unnecessary THP split.

For that, this patch changes two things

1. __split_huge_page_map

It does pte_mkdirty to subpages only if pmd_dirty is true.

2. __split_huge_page_refcount

It removes marking PG_dirty to subpages unconditionally.

Cc: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/huge_mm.h |  3 +++
 mm/huge_memory.c        | 54 +++++++++++++++++++++++++++++++++++++++++++++----
 mm/madvise.c            | 12 ++++++++++-
 3 files changed, 64 insertions(+), 5 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index ecb080d6ff42..e9db238a75c1 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -19,6 +19,9 @@ extern struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 					  unsigned long addr,
 					  pmd_t *pmd,
 					  unsigned int flags);
+extern int madvise_free_huge_pmd(struct mmu_gather *tlb,
+			struct vm_area_struct *vma,
+			pmd_t *pmd, unsigned long addr);
 extern int zap_huge_pmd(struct mmu_gather *tlb,
 			struct vm_area_struct *vma,
 			pmd_t *pmd, unsigned long addr);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index bbac913f96bc..83bc4ce53e19 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1453,6 +1453,49 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	return 0;
 }
 
+int madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
+		pmd_t *pmd, unsigned long addr)
+
+{
+	spinlock_t *ptl;
+	pmd_t orig_pmd;
+	struct page *page;
+	struct mm_struct *mm = tlb->mm;
+
+	if (__pmd_trans_huge_lock(pmd, vma, &ptl) != 1)
+		return 1;
+
+	orig_pmd = *pmd;
+	if (is_huge_zero_pmd(orig_pmd))
+		goto out;
+
+	page = pmd_page(orig_pmd);
+	if (page_mapcount(page) != 1)
+		goto out;
+	if (!trylock_page(page))
+		goto out;
+	if (PageDirty(page))
+		ClearPageDirty(page);
+	unlock_page(page);
+
+	if (PageActive(page))
+		deactivate_page(page);
+
+	if (pmd_young(orig_pmd) || pmd_dirty(orig_pmd)) {
+		orig_pmd = pmdp_huge_get_and_clear_full(tlb->mm, addr, pmd,
+			tlb->fullmm);
+		orig_pmd = pmd_mkold(orig_pmd);
+		orig_pmd = pmd_mkclean(orig_pmd);
+
+		set_pmd_at(mm, addr, pmd, orig_pmd);
+		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
+	}
+out:
+	spin_unlock(ptl);
+
+	return 0;
+}
+
 int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		 pmd_t *pmd, unsigned long addr)
 {
@@ -1752,8 +1795,8 @@ static void __split_huge_page_refcount(struct page *page,
 				      (1L << PG_mlocked) |
 				      (1L << PG_uptodate) |
 				      (1L << PG_active) |
-				      (1L << PG_unevictable)));
-		page_tail->flags |= (1L << PG_dirty);
+				      (1L << PG_unevictable) |
+				      (1L << PG_dirty)));
 
 		/* clear PageTail before overwriting first_page */
 		smp_wmb();
@@ -1787,7 +1830,6 @@ static void __split_huge_page_refcount(struct page *page,
 
 		BUG_ON(!PageAnon(page_tail));
 		BUG_ON(!PageUptodate(page_tail));
-		BUG_ON(!PageDirty(page_tail));
 		BUG_ON(!PageSwapBacked(page_tail));
 
 		lru_add_page_tail(page, page_tail, lruvec, list);
@@ -1831,10 +1873,12 @@ static int __split_huge_page_map(struct page *page,
 	int ret = 0, i;
 	pgtable_t pgtable;
 	unsigned long haddr;
+	bool dirty;
 
 	pmd = page_check_address_pmd(page, mm, address,
 			PAGE_CHECK_ADDRESS_PMD_SPLITTING_FLAG, &ptl);
 	if (pmd) {
+		dirty = pmd_dirty(*pmd);
 		pgtable = pgtable_trans_huge_withdraw(mm, pmd);
 		pmd_populate(mm, &_pmd, pgtable);
 		if (pmd_write(*pmd))
@@ -1850,7 +1894,9 @@ static int __split_huge_page_map(struct page *page,
 			 * permissions across VMAs.
 			 */
 			entry = mk_pte(page + i, vma->vm_page_prot);
-			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+			if (dirty)
+				entry = pte_mkdirty(entry);
+			entry = maybe_mkwrite(entry, vma);
 			if (!pmd_write(*pmd))
 				entry = pte_wrprotect(entry);
 			if (!pmd_young(*pmd))
diff --git a/mm/madvise.c b/mm/madvise.c
index 60e4d7f8ea16..982484fb44ca 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -271,8 +271,17 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 	pte_t *pte, ptent;
 	struct page *page;
 	int nr_swap = 0;
+	unsigned long next;
+
+	next = pmd_addr_end(addr, end);
+	if (pmd_trans_huge(*pmd)) {
+		if (next - addr != HPAGE_PMD_SIZE)
+			split_huge_page_pmd(vma, addr, pmd);
+		else if (!madvise_free_huge_pmd(tlb, vma, pmd, addr))
+			goto next;
+		/* fall through */
+	}
 
-	split_huge_page_pmd(vma, addr, pmd);
 	if (pmd_trans_unstable(pmd))
 		return 0;
 
@@ -356,6 +365,7 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(pte - 1, ptl);
 	cond_resched();
+next:
 	return 0;
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
