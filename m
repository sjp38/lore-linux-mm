Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id DED646B0072
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 03:18:22 -0500 (EST)
Received: by pdev10 with SMTP id v10so31759757pde.7
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 00:18:22 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id eb2si9302059pbc.59.2015.02.24.00.18.16
        for <linux-mm@kvack.org>;
        Tue, 24 Feb 2015 00:18:17 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH RFC 4/4] mm: support MADV_FREE in swapless system
Date: Tue, 24 Feb 2015 17:18:17 +0900
Message-Id: <1424765897-27377-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1424765897-27377-1-git-send-email-minchan@kernel.org>
References: <1424765897-27377-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Shaohua Li <shli@kernel.org>, Yalin.Wang@sonymobile.com, Minchan Kim <minchan@kernel.org>

Historically, we have disabled reclaiming completely with swapoff
or non-swap configurable system. It did make sense but problem
for lazy free pages is that we couldn't get a chance to discard
hinted pages in reclaim path in those systems.

That's why current MADV_FREE implmentation drop pages instantly
like MADV_DONTNNED in swapless system so that users on those
systems couldn't get the benefit of MADV_FREE.

This patch makes VM try to reclaim anonymous pages on swapless
system. Basic strategy is to try reclaim anonymous pages
if there are pages in *inactive anon*.

In non-swap config system, VM doesn't do aging/reclaiming
anonymous LRU list so inactive anon LRU list should be always
empty. So, if there are some pages in inactive anon LRU,
it means they are MADV_FREE hinted pages so VM try to reclaim
them and discard or promote them onto active list.

In swap-config-but-not-yet-swapon, VM doesn't do aging/reclaiming
anonymous LRU list so inactive anon LRU list would be empty but
it might be not always true because some pages could remain
inactive anon list if the admin had swapon before. So, if there
are some pages in inactive anon LRU, it means they are MADV_FREE
hinted pages or non-hinted pages which have stayed before.
VM try to reclaim them and discard or promote them onto active list
so we could have only hinted pages on inactive anon LRU list
after a while.

In swap-enabled-and-full, VM does aging but not try to reclaim
in current implementation. However, we try to reclaim them by
this patch so reclaim efficiency would be worse than old.
I don't know how many such workloads(ie, doing a job with
full-swap for a long time)  we should take care of are.

Hope the comment.

On swapoff system with 3G ram, there are 10 processes with below

loop = 12;
mmap(256M);
while (loop--) {
	memset(256M);
	madvise(MADV_FREE or MADV_DONTNEED);
	sleep(1);
}

1) dontneed: 5.40user 24.75system 0:15.36elapsed
2) madvfree + this patch: 5.18user 6.90system 0:13.39elapsed

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/madvise.c | 21 ++++++++-------------
 mm/vmscan.c  | 32 +++++++++++++++++++++-----------
 2 files changed, 29 insertions(+), 24 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 6176039c69e4..b3937e8012e6 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -515,6 +515,8 @@ static long
 madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 		unsigned long start, unsigned long end, int behavior)
 {
+	unsigned long free_threshold;
+
 	switch (behavior) {
 	case MADV_REMOVE:
 		return madvise_remove(vma, prev, start, end);
@@ -522,20 +524,13 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 		return madvise_willneed(vma, prev, start, end);
 	case MADV_FREE:
 		/*
-		 * XXX: In this implementation, MADV_FREE works like
-		 * MADV_DONTNEED on swapless system or full swap.
+		 * If we have trobule with memory pressure(ie,
+		 * under high watermark), free pages instantly.
 		 */
-		if (get_nr_swap_pages() > 0) {
-			unsigned long threshold;
-			/*
-			 * If we have trobule with memory pressure(ie,
-			 * under high watermark), free pages instantly.
-			 */
-			threshold = min_free_kbytes >> (PAGE_SHIFT - 10);
-			threshold = threshold + (threshold >> 1);
-			if (nr_free_pages() > threshold)
-				return madvise_free(vma, prev, start, end);
-		}
+		free_threshold = min_free_kbytes >> (PAGE_SHIFT - 10);
+		free_threshold = free_threshold + (free_threshold >> 1);
+		if (nr_free_pages() > free_threshold)
+			return madvise_free(vma, prev, start, end);
 		/* passthrough */
 	case MADV_DONTNEED:
 		return madvise_dontneed(vma, prev, start, end);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 671e47edb584..1574cd783ab9 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -163,16 +163,23 @@ static bool global_reclaim(struct scan_control *sc)
 
 static unsigned long zone_reclaimable_pages(struct zone *zone)
 {
-	int nr;
+	unsigned long file, anon;
 
-	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
-	     zone_page_state(zone, NR_INACTIVE_FILE);
+	file = zone_page_state(zone, NR_ACTIVE_FILE) +
+		zone_page_state(zone, NR_INACTIVE_FILE);
 
-	if (get_nr_swap_pages() > 0)
-		nr += zone_page_state(zone, NR_ACTIVE_ANON) +
-		      zone_page_state(zone, NR_INACTIVE_ANON);
+	/*
+	 * Although there is no swap space, we should consider
+	 * lazy free pages in inactive anon LRU list.
+	 */
+	if (total_swap_pages > 0) {
+		anon = zone_page_state(zone, NR_ACTIVE_ANON) +
+			zone_page_state(zone, NR_INACTIVE_ANON);
+	} else {
+		anon = zone_page_state(zone, NR_INACTIVE_ANON);
+	}
 
-	return nr;
+	return file + anon;
 }
 
 bool zone_reclaimable(struct zone *zone)
@@ -2002,8 +2009,11 @@ static void get_scan_count(struct lruvec *lruvec, int swappiness,
 	if (!global_reclaim(sc))
 		force_scan = true;
 
-	/* If we have no swap space, do not bother scanning anon pages. */
-	if (!sc->may_swap || (get_nr_swap_pages() <= 0)) {
+	/*
+	 * If we have no inactive anon page, do not bother scanning
+	 * anon pages.
+	 */
+	if (!sc->may_swap || !zone_page_state(zone, NR_INACTIVE_ANON)) {
 		scan_balance = SCAN_FILE;
 		goto out;
 	}
@@ -2344,8 +2354,8 @@ static inline bool should_continue_reclaim(struct zone *zone,
 	 */
 	pages_for_compaction = (2UL << sc->order);
 	inactive_lru_pages = zone_page_state(zone, NR_INACTIVE_FILE);
-	if (get_nr_swap_pages() > 0)
-		inactive_lru_pages += zone_page_state(zone, NR_INACTIVE_ANON);
+	inactive_lru_pages += zone_page_state(zone, NR_INACTIVE_ANON);
+
 	if (sc->nr_reclaimed < pages_for_compaction &&
 			inactive_lru_pages > pages_for_compaction)
 		return true;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
