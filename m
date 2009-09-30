Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9748A6B005D
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 16:50:48 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [rfc patch 3/3] mm: munlock COW pages on truncation unmap
Date: Wed, 30 Sep 2009 23:09:24 +0200
Message-Id: <1254344964-8124-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1254344964-8124-1-git-send-email-hannes@cmpxchg.org>
References: <1254344964-8124-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

When truncating, VMAs are not explicitely munlocked before unmap.  The
truncation code munlocks page cache pages only and we can end up
freeing mlocked private COW pages.

This patch makes sure we munlock and move them from the unevictable
list before dropping the page table reference.  We know they are going
away with the last reference, so simply clearing the mlock (and
accounting for it) is okay.

We can not grab the page lock from the unmapping context, so this
tries to move the page to the evictable list optimistically and makes
sure a racing reclaimer moves the page instead if we fail.

Rare case: the anon_vma is unlocked when encountering private pages
because the first one in the VMA was faulted in only after we tried
locking the anon_vma.  But we can handle it: on the second unmapping
iteration, page cache will be truncated and vma->anon_vma will be
stable, so just skip the page on non-present anon_vma.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/memory.c |   47 +++++++++++++++++++++++++++++++++++++++++------
 mm/vmscan.c |    7 +++++++
 2 files changed, 48 insertions(+), 6 deletions(-)

--- a/mm/memory.c
+++ b/mm/memory.c
@@ -819,13 +819,13 @@ static unsigned long zap_pte_range(struc
 
 			page = vm_normal_page(vma, addr, ptent);
 			if (unlikely(details) && page) {
+				int private = details->mapping != page->mapping;
 				/*
 				 * unmap_shared_mapping_pages() wants to
 				 * invalidate cache without truncating:
 				 * unmap shared but keep private pages.
 				 */
-				if (details->keep_private &&
-				    details->mapping != page->mapping)
+				if (details->keep_private && private)
 					continue;
 				/*
 				 * Each page->index must be checked when
@@ -835,6 +835,43 @@ static unsigned long zap_pte_range(struc
 				    (page->index < details->first_index ||
 				     page->index > details->last_index))
 					continue;
+				/*
+				 * When truncating, private COW pages may be
+				 * mlocked in VM_LOCKED VMAs, so they need
+				 * munlocking here before getting freed.
+				 *
+				 * Skip them completely if we don't have the
+				 * anon_vma locked.  We will get it the second
+				 * time.  When page cache is truncated, no more
+				 * private pages can show up against this VMA
+				 * and the anon_vma is either present or will
+				 * never be.
+				 *
+				 * Otherwise, we still have to synchronize
+				 * against concurrent reclaimers.  We can not
+				 * grab the page lock, but with correct
+				 * ordering of page flag accesses we can get
+				 * away without it.
+				 *
+				 * A concurrent isolator may add the page to
+				 * the unevictable list, set PG_lru and then
+				 * recheck PG_mlocked to verify it chose the
+				 * right list and conditionally move it again.
+				 *
+				 * TestClearPageMlocked() provides one half of
+				 * the barrier: when we do not see the page on
+				 * the LRU and fail isolation, the isolator
+				 * must see PG_mlocked cleared and move the
+				 * page on its own back to the evictable list.
+				 */
+				if (private && !details->anon_vma)
+					continue;
+				if (private && TestClearPageMlocked(page)) {
+					dec_zone_page_state(page, NR_MLOCK);
+					count_vm_event(UNEVICTABLE_PGCLEARED);
+					if (!isolate_lru_page(page))
+						putback_lru_page(page);
+				}
 			}
 			ptent = ptep_get_and_clear_full(mm, addr, pte,
 							tlb->fullmm);
@@ -866,7 +903,8 @@ static unsigned long zap_pte_range(struc
 		 * If details->keep_private, we leave swap entries;
 		 * if details->nonlinear_vma, we leave file entries.
 		 */
-		if (unlikely(details))
+		if (unlikely(details && (details->keep_private ||
+					 details->nonlinear_vma)))
 			continue;
 		if (pte_file(ptent)) {
 			if (unlikely(!(vma->vm_flags & VM_NONLINEAR)))
@@ -936,9 +974,6 @@ static unsigned long unmap_page_range(st
 	pgd_t *pgd;
 	unsigned long next;
 
-	if (details && !details->keep_private && !details->nonlinear_vma)
-		details = NULL;
-
 	BUG_ON(addr >= end);
 	tlb_start_vma(tlb, vma);
 	pgd = pgd_offset(vma->vm_mm, addr);
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -544,6 +544,13 @@ redo:
 		 */
 		lru = LRU_UNEVICTABLE;
 		add_page_to_unevictable_list(page);
+		/*
+		 * See the TestClearPageMlocked() in zap_pte_range():
+		 * if a racing unmapper did not see the above setting
+		 * of PG_lru, we must see its clearing of PG_locked
+		 * and move the page back to the evictable list.
+		 */
+		smp_mb();
 	}
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
