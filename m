Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id EEDE36B0038
	for <linux-mm@kvack.org>; Thu,  2 Feb 2017 14:20:16 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id v77so170613wmv.5
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 11:20:16 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 65si22378257wrb.336.2017.02.02.11.20.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Feb 2017 11:20:15 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 1/7] mm: vmscan: scan dirty pages even in laptop mode
Date: Thu,  2 Feb 2017 14:19:51 -0500
Message-Id: <20170202191957.22872-2-hannes@cmpxchg.org>
In-Reply-To: <20170202191957.22872-1-hannes@cmpxchg.org>
References: <20170202191957.22872-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Patch series "mm: vmscan: fix kswapd writeback regression".

We noticed a regression on multiple hadoop workloads when moving from 3.10
to 4.0 and 4.6, which involves kswapd getting tangled up in page writeout,
causing direct reclaim herds that also don't make progress.

I tracked it down to the thrash avoidance efforts after 3.10 that make the
kernel better at keeping use-once cache and use-many cache sorted on the
inactive and active list, with more aggressive protection of the active
list as long as there is inactive cache.  Unfortunately, our workload's
use-once cache is mostly from streaming writes.  Waiting for writes to
avoid potential reloads in the future is not a good tradeoff.

These patches do the following:

1. Wake the flushers when kswapd sees a lump of dirty pages. It's
   possible to be below the dirty background limit and still have
   cache velocity push them through the LRU. So start a-flushin'.

2. Let kswapd only write pages that have been rotated twice. This
   makes sure we really tried to get all the clean pages on the
   inactive list before resorting to horrible LRU-order writeback.

3. Move rotating dirty pages off the inactive list. Instead of
   churning or waiting on page writeback, we'll go after clean active
   cache. This might lead to thrashing, but in this state memory
   demand outstrips IO speed anyway, and reads are faster than writes.

Mel backported the series to 4.10-rc5 with one minor conflict and ran a
couple of tests on it.  Mix of read/write random workload didn't show
anything interesting.  Write-only database didn't show much difference
in performance but there were slight reductions in IO -- probably in
the noise.

simoop did show big differences although not as big as Mel expected.
This is Chris Mason's workload that similate the VM activity of hadoop.
Mel won't go through the full details but over the samples measured
during an hour it reported

                                         4.10.0-rc5            4.10.0-rc5
                                            vanilla         johannes-v1r1
Amean    p50-Read             21346531.56 (  0.00%) 21697513.24 ( -1.64%)
Amean    p95-Read             24700518.40 (  0.00%) 25743268.98 ( -4.22%)
Amean    p99-Read             27959842.13 (  0.00%) 28963271.11 ( -3.59%)
Amean    p50-Write                1138.04 (  0.00%)      989.82 ( 13.02%)
Amean    p95-Write             1106643.48 (  0.00%)    12104.00 ( 98.91%)
Amean    p99-Write             1569213.22 (  0.00%)    36343.38 ( 97.68%)
Amean    p50-Allocation          85159.82 (  0.00%)    79120.70 (  7.09%)
Amean    p95-Allocation         204222.58 (  0.00%)   129018.43 ( 36.82%)
Amean    p99-Allocation         278070.04 (  0.00%)   183354.43 ( 34.06%)
Amean    final-p50-Read       21266432.00 (  0.00%) 21921792.00 ( -3.08%)
Amean    final-p95-Read       24870912.00 (  0.00%) 26116096.00 ( -5.01%)
Amean    final-p99-Read       28147712.00 (  0.00%) 29523968.00 ( -4.89%)
Amean    final-p50-Write          1130.00 (  0.00%)      977.00 ( 13.54%)
Amean    final-p95-Write       1033216.00 (  0.00%)     2980.00 ( 99.71%)
Amean    final-p99-Write       1517568.00 (  0.00%)    32672.00 ( 97.85%)
Amean    final-p50-Allocation    86656.00 (  0.00%)    78464.00 (  9.45%)
Amean    final-p95-Allocation   211712.00 (  0.00%)   116608.00 ( 44.92%)
Amean    final-p99-Allocation   287232.00 (  0.00%)   168704.00 ( 41.27%)

The latencies are actually completely horrific in comparison to 4.4
(and 4.10-rc5 is worse than 4.9 according to historical data for
reasons Mel hasn't analysed yet).

Still, 95% of write latency (p95-write) is halved by the series and
allocation latency is way down.  Direct reclaim activity is one fifth
of what it was according to vmstats.  Kswapd activity is higher but
this is not necessarily surprising.  Kswapd efficiency is unchanged at
99% (99% of pages scanned were reclaimed) but direct reclaim efficiency
went from 77% to 99%

In the vanilla kernel, 627MB of data was written back from reclaim
context.  With the series, no data was written back.  With or without
the patch, pages are being immediately reclaimed after writeback
completes.  However, with the patch, only 1/8th of the pages are
reclaimed like this.

This patch (of 5):

We have an elaborate dirty/writeback throttling mechanism inside the
reclaim scanner, but for that to work the pages have to go through
shrink_page_list() and get counted for what they are.  Otherwise, we mess
up the LRU order and don't match reclaim speed to writeback.

Especially during deactivation, there is never a reason to skip dirty
pages; nothing is even trying to write them out from there.  Don't mess up
the LRU order for nothing, shuffle these pages along.

Link: http://lkml.kernel.org/r/20170123181641.23938-2-hannes@cmpxchg.org
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Minchan Kim <minchan@kernel.org>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/mmzone.h |  2 --
 mm/vmscan.c            | 14 ++------------
 2 files changed, 2 insertions(+), 14 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index df992831fde7..338a786a993f 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -236,8 +236,6 @@ struct lruvec {
 #define LRU_ALL_ANON (BIT(LRU_INACTIVE_ANON) | BIT(LRU_ACTIVE_ANON))
 #define LRU_ALL	     ((1 << NR_LRU_LISTS) - 1)
 
-/* Isolate clean file */
-#define ISOLATE_CLEAN		((__force isolate_mode_t)0x1)
 /* Isolate unmapped file */
 #define ISOLATE_UNMAPPED	((__force isolate_mode_t)0x2)
 /* Isolate for asynchronous migration */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7bb23ff229b6..0d05f7f3b532 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -87,6 +87,7 @@ struct scan_control {
 	/* The highest zone to isolate pages for reclaim from */
 	enum zone_type reclaim_idx;
 
+	/* Writepage batching in laptop mode; RECLAIM_WRITE */
 	unsigned int may_writepage:1;
 
 	/* Can mapped pages be reclaimed? */
@@ -1373,13 +1374,10 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode)
 	 * wants to isolate pages it will be able to operate on without
 	 * blocking - clean pages for the most part.
 	 *
-	 * ISOLATE_CLEAN means that only clean pages should be isolated. This
-	 * is used by reclaim when it is cannot write to backing storage
-	 *
 	 * ISOLATE_ASYNC_MIGRATE is used to indicate that it only wants to pages
 	 * that it is possible to migrate without blocking
 	 */
-	if (mode & (ISOLATE_CLEAN|ISOLATE_ASYNC_MIGRATE)) {
+	if (mode & ISOLATE_ASYNC_MIGRATE) {
 		/* All the caller can do on PageWriteback is block */
 		if (PageWriteback(page))
 			return ret;
@@ -1387,10 +1385,6 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode)
 		if (PageDirty(page)) {
 			struct address_space *mapping;
 
-			/* ISOLATE_CLEAN means only clean pages */
-			if (mode & ISOLATE_CLEAN)
-				return ret;
-
 			/*
 			 * Only pages without mappings or that have a
 			 * ->migratepage callback are possible to migrate
@@ -1731,8 +1725,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 
 	if (!sc->may_unmap)
 		isolate_mode |= ISOLATE_UNMAPPED;
-	if (!sc->may_writepage)
-		isolate_mode |= ISOLATE_CLEAN;
 
 	spin_lock_irq(&pgdat->lru_lock);
 
@@ -1929,8 +1921,6 @@ static void shrink_active_list(unsigned long nr_to_scan,
 
 	if (!sc->may_unmap)
 		isolate_mode |= ISOLATE_UNMAPPED;
-	if (!sc->may_writepage)
-		isolate_mode |= ISOLATE_CLEAN;
 
 	spin_lock_irq(&pgdat->lru_lock);
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
