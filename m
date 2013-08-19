Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 81ED36B003B
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 08:24:14 -0400 (EDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 7/7] mm: munlock: manual pte walk in fast path instead of follow_page_mask()
Date: Mon, 19 Aug 2013 14:23:42 +0200
Message-Id: <1376915022-12741-8-git-send-email-vbabka@suse.cz>
In-Reply-To: <1376915022-12741-1-git-send-email-vbabka@suse.cz>
References: <1376915022-12741-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: =?UTF-8?q?J=C3=B6rn=20Engel?= <joern@logfs.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

Currently munlock_vma_pages_range() calls follow_page_mask() to obtain each
struct page. This entails repeated full page table translations and page table
lock taken for each page separately.

This patch attempts to avoid the costly follow_page_mask() where possible, by
iterating over ptes within single pmd under single page table lock. The first
pte is obtained by get_locked_pte() for non-THP page acquired by the initial
follow_page_mask(). The latter function is also used as a fallback in case
simple pte_present() and vm_normal_page() are not sufficient to obtain the
struct page.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/mlock.c | 79 +++++++++++++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 68 insertions(+), 11 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index 77ddd6a..f9f21f4 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -377,33 +377,73 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
 {
 	struct pagevec pvec;
 	struct zone *zone = NULL;
+	pte_t *pte = NULL;
+	spinlock_t *ptl;
+	unsigned long pmd_end;
 
 	pagevec_init(&pvec, 0);
 	vma->vm_flags &= ~VM_LOCKED;
 
 	while (start < end) {
-		struct page *page;
+		struct page *page = NULL;
 		unsigned int page_mask, page_increm;
 		struct zone *pagezone;
 
+		/* If we can, try pte walk instead of follow_page_mask() */
+		if (pte && start < pmd_end) {
+			pte++;
+			if (pte_present(*pte))
+				page = vm_normal_page(vma, start, *pte);
+			if (page) {
+				get_page(page);
+				page_mask = 0;
+			}
+		}
+
 		/*
-		 * Although FOLL_DUMP is intended for get_dump_page(),
-		 * it just so happens that its special treatment of the
-		 * ZERO_PAGE (returning an error instead of doing get_page)
-		 * suits munlock very well (and if somehow an abnormal page
-		 * has sneaked into the range, we won't oops here: great).
+		 * If we did sucessful pte walk step, use that page.
+		 * Otherwise (NULL pte, !pte_present or vm_normal_page failed
+		 * due to e.g. zero page), fallback to follow_page_mask() which
+		 * handles all exceptions.
 		 */
-		page = follow_page_mask(vma, start, FOLL_GET | FOLL_DUMP,
-					&page_mask);
+		if (!page) {
+			if (pte) {
+				pte_unmap_unlock(pte, ptl);
+				pte = NULL;
+			}
+
+			/*
+			 * Although FOLL_DUMP is intended for get_dump_page(),
+			 * it just so happens that its special treatment of the
+			 * ZERO_PAGE (returning an error instead of doing
+			 * get_page) suits munlock very well (and if somehow an
+			 * abnormal page has sneaked into the range, we won't
+			 * oops here: great).
+			 */
+			page = follow_page_mask(vma, start,
+					FOLL_GET | FOLL_DUMP, &page_mask);
+			pmd_end = pmd_addr_end(start, end);
+		}
+
 		if (page && !IS_ERR(page)) {
 			pagezone = page_zone(page);
 			/* The whole pagevec must be in the same zone */
 			if (pagezone != zone) {
-				if (pagevec_count(&pvec))
+				if (pagevec_count(&pvec)) {
+					if (pte) {
+						pte_unmap_unlock(pte, ptl);
+						pte = NULL;
+					}
 					__munlock_pagevec(&pvec, zone);
+				}
 				zone = pagezone;
 			}
 			if (PageTransHuge(page)) {
+				/* 
+				 * We could not have stumbled upon a THP page
+				 * using the pte walk.
+				 */
+				VM_BUG_ON(pte);
 				/*
 				 * THP pages are not handled by pagevec due
 				 * to their possible split (see below).
@@ -422,19 +462,36 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
 				put_page(page); /* follow_page_mask() */
 			} else {
 				/*
+				 * Initialize pte walk for further pages. We
+				 * can do this here since we know the current
+				 * page is not THP.
+				 */
+				if (!pte)
+					pte = get_locked_pte(vma->vm_mm, start,
+							&ptl);
+				/*
 				 * Non-huge pages are handled in batches
 				 * via pagevec. The pin from
 				 * follow_page_mask() prevents them from
 				 * collapsing by THP.
 				 */
-				if (pagevec_add(&pvec, page) == 0)
+				if (pagevec_add(&pvec, page) == 0) {
+					if (pte) {
+						pte_unmap_unlock(pte, ptl);
+						pte = NULL;
+					}
 					__munlock_pagevec(&pvec, zone);
+				}
 			}
 		}
 		page_increm = 1 + (~(start >> PAGE_SHIFT) & page_mask);
 		start += page_increm * PAGE_SIZE;
-		cond_resched();
+		/* Don't resched while ptl is held */
+		if (!pte)
+			cond_resched();
 	}
+	if (pte)
+		pte_unmap_unlock(pte, ptl);
 	if (pagevec_count(&pvec))
 		__munlock_pagevec(&pvec, zone);
 }
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
