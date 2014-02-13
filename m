Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id B7FAA6B0036
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 21:42:10 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id g10so9873367pdj.2
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 18:42:10 -0800 (PST)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id yh9si366507pab.34.2014.02.12.18.42.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 12 Feb 2014 18:42:09 -0800 (PST)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N0W00DD3Y63PC50@mailout2.samsung.com> for
 linux-mm@kvack.org; Thu, 13 Feb 2014 11:42:03 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH 2/2] mm/vmscan: not check compaction_ready on promoted zones
Date: Thu, 13 Feb 2014 10:41:21 +0800
Message-id: <000101cf2865$2a8411a0$7f8c34e0$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mel Gorman' <mgorman@suse.de>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, riel@redhat.com, 'Minchan Kim' <minchan@kernel.org>, weijie.yang.kh@gmail.com, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>

We abort direct reclaim if find the zone is ready for compaction.

Sometimes the zone is just a promoted highmem zone to force scan
pinning highmem, which is not the intended zone the caller want to
alloc page from. In this situation, setting aborted_reclaim to
indicate the caller turn back to retry allocation is waste of time
and could cause a loop in __alloc_pages_slowpath().

This patch do not check compaction_ready() on promoted zones to avoid
the above situation, only set aborted_reclaim if the caller intended
zone is ready to compaction.

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 mm/vmscan.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 35879f0..73e2577 100755
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2299,6 +2299,7 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 	unsigned long nr_soft_scanned;
 	bool aborted_reclaim = false;
 	bool promoted_mask = false;
+	enum zone_type requested_highidx = gfp_zone(sc->gfp_mask);
 
 	/*
 	 * If the number of buffer_heads in the machine exceeds the maximum
@@ -2334,7 +2335,8 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 				 * noticeable problem, like transparent huge
 				 * page allocations.
 				 */
-				if (compaction_ready(zone, sc)) {
+				if ((zonelist_zone_idx(z) <= requested_highidx)
+				    && compaction_ready(zone, sc)) {
 					aborted_reclaim = true;
 					continue;
 				}
-- 
1.7.10.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
