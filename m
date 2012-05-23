Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 8DB486B0092
	for <linux-mm@kvack.org>; Wed, 23 May 2012 03:23:26 -0400 (EDT)
Received: from euspt2 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0M4G000SPSIQ2S@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Wed, 23 May 2012 08:23:14 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M4G00DVQSIYYM@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 23 May 2012 08:23:22 +0100 (BST)
Date: Wed, 23 May 2012 09:23:02 +0200
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH] cma: retry on test_pages_isolated() failure
Message-id: <201205230923.02142.b.zolnierkie@samsung.com>
MIME-version: 1.0
Content-type: Text/Plain; charset=us-ascii
Content-transfer-encoding: 7BIT
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@suse.de>

From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH] cma: retry on test_pages_isolated() failure

Retry (once) migration on test_pages_isolated() failure.

Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Mel Gorman <mgorman@suse.de>
Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 mm/page_alloc.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c	2012-05-15 12:40:54.199127705 +0200
+++ b/mm/page_alloc.c	2012-05-15 12:41:25.335127686 +0200
@@ -5796,7 +5796,7 @@
 {
 	struct zone *zone = page_zone(pfn_to_page(start));
 	unsigned long outer_start, outer_end;
-	int ret = 0, order;
+	int ret = 0, order, retry = 0;
 
 	/*
 	 * What we do here is we mark all pageblocks in range as
@@ -5826,7 +5826,7 @@
 				       pfn_max_align_up(end), migratetype);
 	if (ret)
 		goto done;
-
+migrate:
 	ret = __alloc_contig_migrate_range(start, end);
 	if (ret)
 		goto done;
@@ -5863,6 +5863,8 @@
 
 	/* Make sure the range is really isolated. */
 	if (test_pages_isolated(outer_start, end)) {
+		if (retry++ < 1)
+			goto migrate;
 		pr_warn("alloc_contig_range test_pages_isolated(%lx, %lx) failed\n",
 		       outer_start, end);
 		ret = -EBUSY;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
