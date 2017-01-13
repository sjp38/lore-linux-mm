Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E0E266B0253
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 06:52:03 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id s63so15067422wms.7
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 03:52:03 -0800 (PST)
Received: from metis.ext.pengutronix.de (metis.ext.pengutronix.de. [2001:67c:670:201:290:27ff:fe1d:cc33])
        by mx.google.com with ESMTPS id w133si1884891wmf.48.2017.01.13.03.52.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 03:52:02 -0800 (PST)
From: Lucas Stach <l.stach@pengutronix.de>
Subject: [PATCH] mm: alloc_contig: re-allow CMA to compact FS pages
Date: Fri, 13 Jan 2017 12:51:55 +0100
Message-Id: <20170113115155.24335-1-l.stach@pengutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, kernel@pengutronix.de, patchwork-lst@pengutronix.de

Commit 73e64c51afc5 (mm, compaction: allow compaction for GFP_NOFS requests)
changed compation to skip FS pages if not explicitly allowed to touch them,
but missed to update the CMA compact_control.

This leads to a very high isolation failure rate, crippling performance of
CMA even on a lightly loaded system. Re-allow CMA to compact FS pages by
setting the correct GFP flags, restoring CMA behavior and performance to
the kernel 4.9 level.

Fixes: 73e64c51afc5 (mm, compaction: allow compaction for GFP_NOFS requests)
Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
---
 mm/page_alloc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8d5d82c8a85a..eced9fee582b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7255,6 +7255,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 		.zone = page_zone(pfn_to_page(start)),
 		.mode = MIGRATE_SYNC,
 		.ignore_skip_hint = true,
+		.gfp_mask = GFP_KERNEL,
 	};
 	INIT_LIST_HEAD(&cc.migratepages);
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
