Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 737906B0287
	for <linux-mm@kvack.org>; Fri, 21 Mar 2014 17:18:09 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id fb1so2921502pad.29
        for <linux-mm@kvack.org>; Fri, 21 Mar 2014 14:18:09 -0700 (PDT)
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
        by mx.google.com with ESMTPS id ha5si4390811pbc.129.2014.03.21.14.18.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 21 Mar 2014 14:18:08 -0700 (PDT)
Received: by mail-pd0-f176.google.com with SMTP id r10so2837822pdi.35
        for <linux-mm@kvack.org>; Fri, 21 Mar 2014 14:18:08 -0700 (PDT)
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 5/5] vmscan: Age anonymous memory even when swap is off.
Date: Fri, 21 Mar 2014 14:17:35 -0700
Message-Id: <1395436655-21670-6-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1395436655-21670-1-git-send-email-john.stultz@linaro.org>
References: <1395436655-21670-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Currently we don't shrink/scan the anonymous lrus when swap is off.
This is problematic for volatile range purging on swapless systems/

This patch naievely changes the vmscan code to continue scanning
and shrinking the lrus even when there is no swap.

It obviously has performance issues.

Thoughts on how best to implement this would be appreciated.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Android Kernel Team <kernel-team@android.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Robert Love <rlove@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave@sr71.net>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
Cc: Neil Brown <neilb@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mike Hommey <mh@glandium.org>
Cc: Taras Glek <tglek@mozilla.com>
Cc: Jan Kara <jack@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 mm/vmscan.c | 26 ++++----------------------
 1 file changed, 4 insertions(+), 22 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 34f159a..07b0a8c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -155,9 +155,8 @@ static unsigned long zone_reclaimable_pages(struct zone *zone)
 	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
 	     zone_page_state(zone, NR_INACTIVE_FILE);
 
-	if (get_nr_swap_pages() > 0)
-		nr += zone_page_state(zone, NR_ACTIVE_ANON) +
-		      zone_page_state(zone, NR_INACTIVE_ANON);
+	nr += zone_page_state(zone, NR_ACTIVE_ANON) +
+	      zone_page_state(zone, NR_INACTIVE_ANON);
 
 	return nr;
 }
@@ -1764,13 +1763,6 @@ static int inactive_anon_is_low_global(struct zone *zone)
  */
 static int inactive_anon_is_low(struct lruvec *lruvec)
 {
-	/*
-	 * If we don't have swap space, anonymous page deactivation
-	 * is pointless.
-	 */
-	if (!total_swap_pages)
-		return 0;
-
 	if (!mem_cgroup_disabled())
 		return mem_cgroup_inactive_anon_is_low(lruvec);
 
@@ -1880,12 +1872,6 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 	if (!global_reclaim(sc))
 		force_scan = true;
 
-	/* If we have no swap space, do not bother scanning anon pages. */
-	if (!sc->may_swap || (get_nr_swap_pages() <= 0)) {
-		scan_balance = SCAN_FILE;
-		goto out;
-	}
-
 	/*
 	 * Global reclaim will swap to prevent OOM even with no
 	 * swappiness, but memcg users want to use this knob to
@@ -2048,7 +2034,6 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
 			if (nr[lru]) {
 				nr_to_scan = min(nr[lru], SWAP_CLUSTER_MAX);
 				nr[lru] -= nr_to_scan;
-
 				nr_reclaimed += shrink_list(lru, nr_to_scan,
 							    lruvec, sc);
 			}
@@ -2181,8 +2166,8 @@ static inline bool should_continue_reclaim(struct zone *zone,
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
@@ -2726,9 +2711,6 @@ static void age_active_anon(struct zone *zone, struct scan_control *sc)
 {
 	struct mem_cgroup *memcg;
 
-	if (!total_swap_pages)
-		return;
-
 	memcg = mem_cgroup_iter(NULL, NULL, NULL);
 	do {
 		struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
