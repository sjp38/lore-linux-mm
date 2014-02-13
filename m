Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id BDC956B0035
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 21:41:08 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id v10so9945421pde.27
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 18:41:08 -0800 (PST)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id bq5si346555pbb.138.2014.02.12.18.41.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 12 Feb 2014 18:41:07 -0800 (PST)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N0W00IY0Y4HQ250@mailout1.samsung.com> for
 linux-mm@kvack.org; Thu, 13 Feb 2014 11:41:05 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH 1/2] mm/vmscan: restore sc->gfp_mask after promoting it to
 __GFP_HIGHMEM
Date: Thu, 13 Feb 2014 10:39:58 +0800
Message-id: <000001cf2865$0aa2c0c0$1fe84240$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mel Gorman' <mgorman@suse.de>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, riel@redhat.com, 'Minchan Kim' <minchan@kernel.org>, weijie.yang.kh@gmail.com, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>

We promote sc->gfp_mask to __GFP_HIGHMEM to forcibly scan highmem if
there are too many buffer_heads pinning highmem. see: cc715d99e5

This patch restores sc->gfp_mask to its caller original value after
finishing the scan job, to avoid the impact on other invocations from
its upper caller, such as vmpressure_prio(), shrink_slab().

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 mm/vmscan.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)
 mode change 100644 => 100755 mm/vmscan.c

diff --git a/mm/vmscan.c b/mm/vmscan.c
old mode 100644
new mode 100755
index a9c74b4..35879f0
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2298,14 +2298,17 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 	unsigned long nr_soft_reclaimed;
 	unsigned long nr_soft_scanned;
 	bool aborted_reclaim = false;
+	bool promoted_mask = false;
 
 	/*
 	 * If the number of buffer_heads in the machine exceeds the maximum
 	 * allowed level, force direct reclaim to scan the highmem zone as
 	 * highmem pages could be pinning lowmem pages storing buffer_heads
 	 */
-	if (buffer_heads_over_limit)
+	if (buffer_heads_over_limit) {
+		promoted_mask = !(sc->gfp_mask & __GFP_HIGHMEM);
 		sc->gfp_mask |= __GFP_HIGHMEM;
+	}
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 					gfp_zone(sc->gfp_mask), sc->nodemask) {
@@ -2354,6 +2357,9 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 		shrink_zone(zone, sc);
 	}
 
+	if (promoted_mask)
+		sc->gfp_mask &= ~__GFP_HIGHMEM;
+
 	return aborted_reclaim;
 }
 
-- 
1.7.10.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
