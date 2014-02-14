Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7047E6B0035
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 01:43:15 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id uo5so11865904pbc.41
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 22:43:15 -0800 (PST)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id vb2si4580467pbc.337.2014.02.13.22.43.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 13 Feb 2014 22:43:14 -0800 (PST)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N0Z00EQ6400PE00@mailout3.samsung.com> for
 linux-mm@kvack.org; Fri, 14 Feb 2014 15:43:12 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH V2 2/2] mm/vmscan: not check compaction_ready on promoted zones
Date: Fri, 14 Feb 2014 14:42:34 +0800
Message-id: <000201cf2950$07a17ce0$16e476a0$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8
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

Acked-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 mm/vmscan.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index da0a87c..9ec6519 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2299,6 +2299,7 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 	unsigned long nr_soft_scanned;
 	bool aborted_reclaim = false;
 	gfp_t orig_mask = sc->gfp_mask;
+	enum zone_type requested_highidx = gfp_zone(sc->gfp_mask);
 
 	/*
 	 * If the number of buffer_heads in the machine exceeds the maximum
@@ -2332,7 +2333,8 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
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
