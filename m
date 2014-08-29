Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id BD9C86B0044
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 03:04:24 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id bj1so5817390pad.4
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 00:04:24 -0700 (PDT)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id gp10si10879632pbc.44.2014.08.29.00.04.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 29 Aug 2014 00:04:23 -0700 (PDT)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NB2002U73N8M280@mailout3.samsung.com> for
 linux-mm@kvack.org; Fri, 29 Aug 2014 16:04:21 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH] mm: page_alloc: avoid wakeup kswapd on the unintended node
Date: Fri, 29 Aug 2014 15:03:19 +0800
Message-id: <000001cfc357$74db64a0$5e922de0$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mel Gorman' <mgorman@suse.de>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Rik van Riel' <riel@redhat.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, rientjes@google.com, 'Weijie Yang' <weijie.yang.kh@gmail.com>, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>

When enter page_alloc slowpath, we wakeup kswapd on every pgdat
according to the zonelist and high_zoneidx. However, this doesn't
take nodemask into account, and could prematurely wakeup kswapd on
some unintended nodes.

This patch uses for_each_zone_zonelist_nodemask() instead of
for_each_zone_zonelist() in wake_all_kswapds() to avoid the above situation.

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 mm/page_alloc.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 18cee0d..29b595a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2457,12 +2457,14 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
 static void wake_all_kswapds(unsigned int order,
 			     struct zonelist *zonelist,
 			     enum zone_type high_zoneidx,
-			     struct zone *preferred_zone)
+			     struct zone *preferred_zone,
+			     nodemask_t *nodemask)
 {
 	struct zoneref *z;
 	struct zone *zone;
 
-	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
+	for_each_zone_zonelist_nodemask(zone, z, zonelist,
+						high_zoneidx, nodemask)
 		wakeup_kswapd(zone, order, zone_idx(preferred_zone));
 }
 
@@ -2560,7 +2562,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 
 restart:
 	if (!(gfp_mask & __GFP_NO_KSWAPD))
-		wake_all_kswapds(order, zonelist, high_zoneidx, preferred_zone);
+		wake_all_kswapds(order, zonelist, high_zoneidx,
+				preferred_zone, nodemask);
 
 	/*
 	 * OK, we're below the kswapd watermark and have kicked background
-- 
1.7.10.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
