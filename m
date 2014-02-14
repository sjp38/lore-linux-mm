Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id EE82E6B0031
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 01:42:35 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa1so11927571pad.0
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 22:42:35 -0800 (PST)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id bp2si4603591pab.156.2014.02.13.22.42.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 13 Feb 2014 22:42:34 -0800 (PST)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N0Z00EN63YVPE00@mailout3.samsung.com> for
 linux-mm@kvack.org; Fri, 14 Feb 2014 15:42:31 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH V2 1/2] mm/vmscan: restore sc->gfp_mask after promoting it to
 __GFP_HIGHMEM
Date: Fri, 14 Feb 2014 14:41:33 +0800
Message-id: <000101cf294f$eef39610$ccdac230$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8
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
Changes since v1:
	- use orig_mask to record the caller's orininal mask and restore
	 it after finishing scan, according to Riel's suggestion.

V1: https://lkml.org/lkml/2014/2/12/764

 mm/vmscan.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a9c74b4..da0a87c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2298,6 +2298,7 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 	unsigned long nr_soft_reclaimed;
 	unsigned long nr_soft_scanned;
 	bool aborted_reclaim = false;
+	gfp_t orig_mask = sc->gfp_mask;
 
 	/*
 	 * If the number of buffer_heads in the machine exceeds the maximum
@@ -2354,6 +2355,12 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 		shrink_zone(zone, sc);
 	}
 
+	/*
+	 * restore to original mask to avoid the impact on its caller
+	 * if we promote it to __GFP_HIGHMEM.
+	 */
+	sc->gfp_mask = orig_mask;
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
