Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id DA06D9003CD
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 11:17:05 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so44740684pac.0
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 08:17:05 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id wn1si29036817pab.131.2015.09.03.08.17.04
        for <linux-mm@kvack.org>;
        Thu, 03 Sep 2015 08:17:05 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv10 37/36, RFC] thp: allow mlocked THP again
Date: Thu,  3 Sep 2015 18:16:28 +0300
Message-Id: <1441293388-137552-1-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1441293202-137314-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1441293202-137314-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch brings back mlocked THP. Instead of forbidding mlocked pages
altogether, we just avoid mlocking PTE-mapped THPs and munlock THPs on
split_huge_pmd().

This means PTE-mapped THPs will be on normal lru lists and will be
split under memory pressure by vmscan. After the split vmscan will
detect unevictable small pages and mlock them.

This way we can void leaking mlocked pages into non-VM_LOCKED VMAs.

Not-Yet-Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---

I'm not yet 100% certain that this approch is correct. Review would be appriciated.
More testing is required.

---
 mm/gup.c         |  6 ++++--
 mm/huge_memory.c | 33 +++++++++++++++++++++++-------
 mm/memory.c      |  3 +--
 mm/mlock.c       | 61 +++++++++++++++++++++++++++++++++++++-------------------
 4 files changed, 71 insertions(+), 32 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 70d65e4015a4..e95b0cb6ed81 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -143,6 +143,10 @@ retry:
 		mark_page_accessed(page);
 	}
 	if ((flags & FOLL_MLOCK) && (vma->vm_flags & VM_LOCKED)) {
+		/* Do not mlock pte-mapped THP */
+		if (PageTransCompound(page))
+			goto out;
+
 		/*
 		 * The preliminary mapping check is mainly to avoid the
 		 * pointless overhead of lock_page on the ZERO_PAGE
@@ -920,8 +924,6 @@ long populate_vma_page_range(struct vm_area_struct *vma,
 	gup_flags = FOLL_TOUCH | FOLL_POPULATE | FOLL_MLOCK;
 	if (vma->vm_flags & VM_LOCKONFAULT)
 		gup_flags &= ~FOLL_POPULATE;
-	if (vma->vm_flags & VM_LOCKED)
-		gup_flags |= FOLL_SPLIT;
 	/*
 	 * We want to touch writable mappings with a write fault in order
 	 * to break COW, except for shared mappings because these don't COW
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 2cc99f9096a8..d714de02473b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -846,8 +846,6 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
 		return VM_FAULT_FALLBACK;
-	if (vma->vm_flags & VM_LOCKED)
-		return VM_FAULT_FALLBACK;
 	if (unlikely(anon_vma_prepare(vma)))
 		return VM_FAULT_OOM;
 	if (unlikely(khugepaged_enter(vma, vma->vm_flags)))
@@ -1316,7 +1314,16 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 			update_mmu_cache_pmd(vma, addr, pmd);
 	}
 	if ((flags & FOLL_MLOCK) && (vma->vm_flags & VM_LOCKED)) {
-		if (page->mapping && trylock_page(page)) {
+		/*
+		 * We don't mlock() pte-mapped THPs. This way we can avoid
+		 * leaking mlocked pages into non-VM_LOCKED VMAs.
+		 * In most cases the pmd is the only mapping of the page: we
+		 * break COW for the mlock(). The only scenario when we have
+		 * the page shared here is if we mlocking read-only mapping
+		 * shared over fork(). We skip mlocking such pages.
+		 */
+		if (compound_mapcount(page) == 1 && !PageDoubleMap(page) &&
+				page->mapping && trylock_page(page)) {
 			lru_add_drain();
 			if (page->mapping)
 				mlock_vma_page(page);
@@ -2194,8 +2201,6 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
 	if ((!(vma->vm_flags & VM_HUGEPAGE) && !khugepaged_always()) ||
 	    (vma->vm_flags & VM_NOHUGEPAGE))
 		return false;
-	if (vma->vm_flags & VM_LOCKED)
-		return false;
 	if (!vma->anon_vma || vma->vm_ops)
 		return false;
 	if (is_vma_temporary_stack(vma))
@@ -2755,14 +2760,28 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 {
 	spinlock_t *ptl;
 	struct mm_struct *mm = vma->vm_mm;
+	struct page *page = NULL;
 	unsigned long haddr = address & HPAGE_PMD_MASK;
 
 	mmu_notifier_invalidate_range_start(mm, haddr, haddr + HPAGE_PMD_SIZE);
 	ptl = pmd_lock(mm, pmd);
-	if (likely(pmd_trans_huge(*pmd)))
-		__split_huge_pmd_locked(vma, pmd, haddr, false);
+	if (unlikely(!pmd_trans_huge(*pmd)))
+		goto out;
+	page = pmd_page(*pmd);
+	__split_huge_pmd_locked(vma, pmd, haddr, false);
+	if (PageMlocked(page))
+		get_page(page);
+	else
+		page = NULL;
+out:
 	spin_unlock(ptl);
 	mmu_notifier_invalidate_range_end(mm, haddr, haddr + HPAGE_PMD_SIZE);
+	if (page) {
+		lock_page(page);
+		munlock_vma_page(page);
+		unlock_page(page);
+		put_page(page);
+	}
 }
 
 static void split_huge_pmd_address(struct vm_area_struct *vma,
diff --git a/mm/memory.c b/mm/memory.c
index 5a9e9399d935..6356b316ddda 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2155,8 +2155,7 @@ static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	pte_unmap_unlock(page_table, ptl);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
-	/* THP pages are never mlocked */
-	if (old_page && !PageTransCompound(old_page)) {
+	if (old_page) {
 		/*
 		 * Don't let another task, with possibly unlocked vma,
 		 * keep the mlocked page.
diff --git a/mm/mlock.c b/mm/mlock.c
index 8314cd3eee87..c37bbc1d3774 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -82,6 +82,9 @@ void mlock_vma_page(struct page *page)
 	/* Serialize with page migration */
 	BUG_ON(!PageLocked(page));
 
+	VM_BUG_ON_PAGE(PageTail(page), page);
+	VM_BUG_ON_PAGE(PageCompound(page) && PageDoubleMap(page), page);
+
 	if (!TestSetPageMlocked(page)) {
 		mod_zone_page_state(page_zone(page), NR_MLOCK,
 				    hpage_nr_pages(page));
@@ -178,6 +181,8 @@ unsigned int munlock_vma_page(struct page *page)
 	/* For try_to_munlock() and to serialize with page migration */
 	BUG_ON(!PageLocked(page));
 
+	VM_BUG_ON_PAGE(PageTail(page), page);
+
 	/*
 	 * Serialize with any parallel __split_huge_page_refcount() which
 	 * might otherwise copy PageMlocked to part of the tail pages before
@@ -443,29 +448,43 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
 		page = follow_page_mask(vma, start, FOLL_GET | FOLL_DUMP,
 				&page_mask);
 
-		if (page && !IS_ERR(page) && !PageTransCompound(page)) {
-			/*
-			 * Non-huge pages are handled in batches via
-			 * pagevec. The pin from follow_page_mask()
-			 * prevents them from collapsing by THP.
-			 */
-			pagevec_add(&pvec, page);
-			zone = page_zone(page);
-			zoneid = page_zone_id(page);
+		if (page && !IS_ERR(page)) {
+			if (PageTransTail(page)) {
+				VM_BUG_ON_PAGE(PageMlocked(page), page);
+				put_page(page); /* follow_page_mask() */
+			} else if (PageTransHuge(page)) {
+				lock_page(page);
+				/*
+				 * Any THP page found by follow_page_mask() may
+				 * have gotten split before reaching
+				 * munlock_vma_page(), so we need to recompute
+				 * the page_mask here.
+				 */
+				page_mask = munlock_vma_page(page);
+				unlock_page(page);
+				put_page(page); /* follow_page_mask() */
+			} else {
+				/*
+				 * Non-huge pages are handled in batches via
+				 * pagevec. The pin from follow_page_mask()
+				 * prevents them from collapsing by THP.
+				 */
+				pagevec_add(&pvec, page);
+				zone = page_zone(page);
+				zoneid = page_zone_id(page);
 
-			/*
-			 * Try to fill the rest of pagevec using fast
-			 * pte walk. This will also update start to
-			 * the next page to process. Then munlock the
-			 * pagevec.
-			 */
-			start = __munlock_pagevec_fill(&pvec, vma,
-					zoneid, start, end);
-			__munlock_pagevec(&pvec, zone);
-			goto next;
+				/*
+				 * Try to fill the rest of pagevec using fast
+				 * pte walk. This will also update start to
+				 * the next page to process. Then munlock the
+				 * pagevec.
+				 */
+				start = __munlock_pagevec_fill(&pvec, vma,
+						zoneid, start, end);
+				__munlock_pagevec(&pvec, zone);
+				goto next;
+			}
 		}
-		/* It's a bug to munlock in the middle of a THP page */
-		VM_BUG_ON((start >> PAGE_SHIFT) & page_mask);
 		page_increm = 1 + page_mask;
 		start += page_increm * PAGE_SIZE;
 next:
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
