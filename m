Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id DC76D6B0038
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 13:45:43 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v52so107125wrb.14
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 10:45:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 35si3536585wrj.58.2017.04.06.10.45.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 06 Apr 2017 10:45:42 -0700 (PDT)
Date: Thu, 6 Apr 2017 18:45:38 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm, vmscan: prevent kswapd sleeping prematurely due to
 mismatched classzone_idx -fix
Message-ID: <20170406174538.5msrznj6nt6qpbx5@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Reza Arbab <arbab@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

The patch "mm, vmscan: prevent kswapd sleeping prematurely due to mismatched
classzone_idx" has different initial starting conditions when kswapd
is asleep. kswapd initialises it properly when it starts but the patch
initialises kswapd_classzone_idx early and trips on a warning in
free_area_init_node. This patch leaves the kswapd_classzone_idx as zero
and defers to kswapd to initialise it properly when it starts.

This is a fix to the mmotm patch
mm-vmscan-prevent-kswapd-sleeping-prematurely-due-to-mismatched-classzone_idx.patch

Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 mm/memory_hotplug.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 2309a7fbec93..76d4745513ee 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1214,10 +1214,14 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
 
 		arch_refresh_nodedata(nid, pgdat);
 	} else {
-		/* Reset the nr_zones, order and classzone_idx before reuse */
+		/*
+		 * Reset the nr_zones, order and classzone_idx before reuse.
+		 * Note that kswapd will init kswapd_classzone_idx properly
+		 * when it starts in the near future.
+		 */
 		pgdat->nr_zones = 0;
 		pgdat->kswapd_order = 0;
-		pgdat->kswapd_classzone_idx = MAX_NR_ZONES;
+		pgdat->kswapd_classzone_idx = 0;
 	}
 
 	/* we can use NODE_DATA(nid) from here */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
