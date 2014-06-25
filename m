Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9F3476B0036
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 03:58:55 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id n15so1962313wiw.17
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 00:58:55 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u9si10292810wiy.4.2014.06.25.00.58.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Jun 2014 00:58:54 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/6] mm: vmscan: Do not reclaim from lower zones if they are balanced
Date: Wed, 25 Jun 2014 08:58:46 +0100
Message-Id: <1403683129-10814-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1403683129-10814-1-git-send-email-mgorman@suse.de>
References: <1403683129-10814-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <axboe@kernel.dk>, Jeff Moyer <jmoyer@redhat.com>, Dave Chinner <david@fromorbit.com>, Mel Gorman <mgorman@suse.de>

Historically kswapd scanned from DMA->Movable in the opposite direction
to the page allocator to avoid allocating behind kswapd direction of
progress. The fair zone allocation policy altered this in a non-obvious
manner.

Traditionally, the page allocator prefers to use the highest eligible zone
until the watermark is depleted, woke kswapd and moved onto the next zone.
kswapd scans zones in the opposite direction so the scanning lists on
64-bit look like this;

Page alloc		Kswapd
----------              ------
Movable			DMA
Normal			DMA32
DMA32			Normal
DMA			Movable

If kswapd scanned in the same direction as the page allocator then it is
possible that kswapd would proportionally reclaim the lower zones that
were never used as the page allocator was always allocating behind the
reclaim. This would work as follows

	pgalloc hits Normal low wmark
					kswapd reclaims Normal
					kswapd reclaims DMA32
	pgalloc hits Normal low wmark
					kswapd reclaims Normal
					kswapd reclaims DMA32

The introduction of the fair zone allocation policy fundamentally altered
this problem by interleaving between zones until the low watermark is
reached. There are at least two issues with this

o The page allocator can allocate behind kswapds progress (scans/reclaims
  lower zone and fair zone allocation policy then uses those pages)
o When the low watermark of the high zone is reached there may recently
  allocated pages allocated from the lower zone but as kswapd scans
  dma->highmem to the highest zone needing balancing it'll reclaim the
  lower zone even if it was balanced.

The problem is fundamental to the fact we have per-zone LRU and allocation
policies and ideally we would only have per-node allocation and LRU lists.
This would avoid the need for the fair zone allocation policy but the
low-memory-starvation issue would have to be addressed again from scratch.

This patch will only scan/reclaim from lower zones if they have not
reached their watermark. This should not break the normal page aging
as the proportional allocations due to the fair zone allocation policy
should compensate.

tiobench was used to evaluate this because it includes a simple
sequential reader which is the most obvious regression. It also has threaded
readers that produce reasonably steady figures.

                                      3.16.0-rc2            3.16.0-rc2                 3.0.0
                                         vanilla        checklow-v2r14               vanilla
Min    SeqRead-MB/sec-1         120.96 (  0.00%)      140.63 ( 16.26%)      134.04 ( 10.81%)
Min    SeqRead-MB/sec-2         100.73 (  0.00%)      117.95 ( 17.10%)      120.76 ( 19.88%)
Min    SeqRead-MB/sec-4          96.05 (  0.00%)      109.54 ( 14.04%)      114.49 ( 19.20%)
Min    SeqRead-MB/sec-8          82.46 (  0.00%)       88.22 (  6.99%)       98.04 ( 18.89%)
Min    SeqRead-MB/sec-16         66.37 (  0.00%)       69.14 (  4.17%)       79.49 ( 19.77%)
Mean   RandWrite-MB/sec-16        1.34 (  0.00%)        1.34 (  0.00%)        1.34 (  0.25%)

Note that this patch makes a large performance difference for lower
numbers of threads and brings performance closer to 3.0 figures. It was
also tested against xfs and there are similar gains although I don't have
3.0 figures to compare against. There are still regressions for higher
number of threads but this is related to changes in the CFQ IO scheduler.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0f16ffe..40c3af8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3124,12 +3124,13 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 
 		/*
 		 * Now scan the zone in the dma->highmem direction, stopping
-		 * at the last zone which needs scanning.
-		 *
-		 * We do this because the page allocator works in the opposite
-		 * direction.  This prevents the page allocator from allocating
-		 * pages behind kswapd's direction of progress, which would
-		 * cause too much scanning of the lower zones.
+		 * at the last zone which needs scanning. We do this because
+		 * the page allocators prefers to work in the opposite
+		 * direction and we want to avoid the page allocator reclaiming
+		 * behind kswapd's direction of progress. Due to the fair zone
+		 * allocation policy interleaving allocations between zones
+		 * we no longer proportionally scan the lower zones if the
+		 * watermarks are ok.
 		 */
 		for (i = 0; i <= end_zone; i++) {
 			struct zone *zone = pgdat->node_zones + i;
@@ -3152,6 +3153,9 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 							&nr_soft_scanned);
 			sc.nr_reclaimed += nr_soft_reclaimed;
 
+			if (zone_balanced(zone, order, 0, 0))
+				continue;
+
 			/*
 			 * There should be no need to raise the scanning
 			 * priority if enough pages are already being scanned
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
