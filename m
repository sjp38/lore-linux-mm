Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 739906B0088
	for <linux-mm@kvack.org>; Sun, 12 Sep 2010 11:55:02 -0400 (EDT)
Message-Id: <20100912155204.774257544@intel.com>
Date: Sun, 12 Sep 2010 23:49:59 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 14/17] vmscan: add scan_control.priority
References: <20100912154945.758129106@intel.com>
Content-Disposition: inline; filename=mm-sc-priority.patch
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Li Shaohua <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

It seems most vmscan functions need the priority parameter.
It will simplify code to put it into scan_control.

It will be referenced in the next patch. This patch could convert
the many exising functnions, but let's keep it simple at first.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/vmscan.c |    4 ++++
 1 file changed, 4 insertions(+)

--- linux-next.orig/mm/vmscan.c	2010-09-10 13:13:41.000000000 +0800
+++ linux-next/mm/vmscan.c	2010-09-10 13:17:01.000000000 +0800
@@ -78,6 +78,8 @@ struct scan_control {
 
 	int order;
 
+	int priority;
+
 	/*
 	 * Intend to reclaim enough continuous memory rather than reclaim
 	 * enough amount of memory. i.e, mode for high order allocation.
@@ -1875,6 +1877,7 @@ static unsigned long do_try_to_free_page
 
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
 		sc->nr_scanned = 0;
+		sc->priority = priority;
 		if (!priority)
 			disable_swap_token();
 		all_unreclaimable = shrink_zones(priority, zonelist, sc);
@@ -2127,6 +2130,7 @@ loop_again:
 			disable_swap_token();
 
 		all_zones_ok = 1;
+		sc.priority = priority;
 
 		/*
 		 * Scan in the highmem->dma direction for the highest


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
