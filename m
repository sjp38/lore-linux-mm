Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id AC0636B0266
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 01:39:53 -0500 (EST)
Received: by padhx2 with SMTP id hx2so174829548pad.1
        for <linux-mm@kvack.org>; Sun, 29 Nov 2015 22:39:53 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id gt3si7153994pac.72.2015.11.29.22.39.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 29 Nov 2015 22:39:31 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v5 12/12] mm: don't split THP page when syscall is called
Date: Mon, 30 Nov 2015 15:39:43 +0900
Message-Id: <1448865583-2446-13-git-send-email-minchan@kernel.org>
In-Reply-To: <1448865583-2446-1-git-send-email-minchan@kernel.org>
References: <1448865583-2446-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Andy Lutomirski <luto@amacapital.net>, Minchan Kim <minchan@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>

We don't need to split THP page when MADV_FREE syscall is called
if [start, len] is aligned with THP size. The split could be done
when VM decide to free it in reclaim path if memory pressure is
heavy. With that, we could avoid unnecessary THP split.

For the feature, this patch changes pte dirtness marking logic of THP.
Now, it marks every ptes of pages dirty unconditionally in splitting,
which makes MADV_FREE void. So, instead, this patch propagates pmd
dirtiness to all pages via PG_dirty and restores pte dirtiness from
PG_dirty. With this, if pmd is clean(ie, MADV_FREEed) when split
happens(e,g, shrink_page_list), all of pages are clean too so we
could discard them.

Cc: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/huge_mm.h |  3 ++
 mm/huge_memory.c        | 87 ++++++++++++++++++++++++++++++++++++++++++++++---
 mm/madvise.c            |  8 ++++-
 3 files changed, 92 insertions(+), 6 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 72cd942edb22..0160201993d4 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -19,6 +19,9 @@ extern struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 					  unsigned long addr,
 					  pmd_t *pmd,
 					  unsigned int flags);
+extern int madvise_free_huge_pmd(struct mmu_gather *tlb,
+			struct vm_area_struct *vma,
+			pmd_t *pmd, unsigned long addr, unsigned long next);
 extern int zap_huge_pmd(struct mmu_gather *tlb,
 			struct vm_area_struct *vma,
 			pmd_t *pmd, unsigned long addr);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b41793b12a2d..2aa28cbe7263 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1530,6 +1530,77 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	return 0;
 }
 
+int madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
+		pmd_t *pmd, unsigned long addr, unsigned long next)
+
+{
+	spinlock_t *ptl;
+	pmd_t orig_pmd;
+	struct page *page;
+	struct mm_struct *mm = tlb->mm;
+	int ret = 0;
+
+	if (!pmd_trans_huge_lock(pmd, vma, &ptl))
+		goto out;
+
+	orig_pmd = *pmd;
+	if (is_huge_zero_pmd(orig_pmd)) {
+		ret = 1;
+		goto out;
+	}
+
+	page = pmd_page(orig_pmd);
+	/*
+	 * If other processes are mapping this page, we couldn't discard
+	 * the page unless they all do MADV_FREE so let's skip the page.
+	 */
+	if (page_mapcount(page) != 1)
+		goto out;
+
+	if (!trylock_page(page))
+		goto out;
+
+	/*
+	 * If user want to discard part-pages of THP, split it so MADV_FREE
+	 * will deactivate only them.
+	 */
+	if (next - addr != HPAGE_PMD_SIZE) {
+		get_page(page);
+		spin_unlock(ptl);
+		if (split_huge_page(page)) {
+			put_page(page);
+			unlock_page(page);
+			goto out_unlocked;
+		}
+		put_page(page);
+		unlock_page(page);
+		ret = 1;
+		goto out_unlocked;
+	}
+
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
+	ret = 1;
+out:
+	spin_unlock(ptl);
+out_unlocked:
+	return ret;
+}
+
 int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		 pmd_t *pmd, unsigned long addr)
 {
@@ -2784,7 +2855,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	struct page *page;
 	pgtable_t pgtable;
 	pmd_t _pmd;
-	bool young, write;
+	bool young, write, dirty;
 	int i;
 
 	VM_BUG_ON(haddr & ~HPAGE_PMD_MASK);
@@ -2808,6 +2879,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	atomic_add(HPAGE_PMD_NR - 1, &page->_count);
 	write = pmd_write(*pmd);
 	young = pmd_young(*pmd);
+	dirty = pmd_dirty(*pmd);
 
 	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
 	pmd_populate(mm, &_pmd, pgtable);
@@ -2825,12 +2897,14 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 			entry = swp_entry_to_pte(swp_entry);
 		} else {
 			entry = mk_pte(page + i, vma->vm_page_prot);
-			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+			entry = maybe_mkwrite(entry, vma);
 			if (!write)
 				entry = pte_wrprotect(entry);
 			if (!young)
 				entry = pte_mkold(entry);
 		}
+		if (dirty)
+			SetPageDirty(page + i);
 		pte = pte_offset_map(&_pmd, haddr);
 		BUG_ON(!pte_none(*pte));
 		set_pte_at(mm, haddr, pte, entry);
@@ -3028,6 +3102,8 @@ static void freeze_page_vma(struct vm_area_struct *vma, struct page *page,
 			continue;
 		flush_cache_page(vma, address, page_to_pfn(page));
 		entry = ptep_clear_flush(vma, address, pte + i);
+		if (pte_dirty(entry))
+			SetPageDirty(page);
 		swp_entry = make_migration_entry(page, pte_write(entry));
 		swp_pte = swp_entry_to_pte(swp_entry);
 		if (pte_soft_dirty(entry))
@@ -3086,7 +3162,8 @@ static void unfreeze_page_vma(struct vm_area_struct *vma, struct page *page,
 		page_add_anon_rmap(page, vma, address, false);
 
 		entry = pte_mkold(mk_pte(page, vma->vm_page_prot));
-		entry = pte_mkdirty(entry);
+		if (PageDirty(page))
+			entry = pte_mkdirty(entry);
 		if (is_write_migration_entry(swp_entry))
 			entry = maybe_mkwrite(entry, vma);
 
@@ -3147,8 +3224,8 @@ static int __split_huge_page_tail(struct page *head, int tail,
 			 (1L << PG_uptodate) |
 			 (1L << PG_active) |
 			 (1L << PG_locked) |
-			 (1L << PG_unevictable)));
-	page_tail->flags |= (1L << PG_dirty);
+			 (1L << PG_unevictable) |
+			 (1L << PG_dirty)));
 
 	/*
 	 * After clearing PageTail the gup refcount can be released.
diff --git a/mm/madvise.c b/mm/madvise.c
index 975e24e4c134..563d6c145d75 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -271,8 +271,13 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 	pte_t *orig_pte, *pte, ptent;
 	struct page *page;
 	int nr_swap = 0;
+	unsigned long next;
+
+	next = pmd_addr_end(addr, end);
+	if (pmd_trans_huge(*pmd))
+		if (madvise_free_huge_pmd(tlb, vma, pmd, addr, next))
+			goto next;
 
-	split_huge_pmd(vma, pmd, addr);
 	if (pmd_trans_unstable(pmd))
 		return 0;
 
@@ -381,6 +386,7 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(orig_pte, ptl);
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
