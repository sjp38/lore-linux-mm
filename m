Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0B86C6B00E8
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 12:43:03 -0500 (EST)
Date: Wed, 26 Jan 2011 17:42:37 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: too big min_free_kbytes
Message-ID: <20110126174236.GV18984@csn.ul.ie>
References: <1295841406.1949.953.camel@sli10-conroe> <20110124150033.GB9506@random.random> <20110126141746.GS18984@csn.ul.ie> <20110126152302.GT18984@csn.ul.ie> <20110126154203.GS926@random.random> <20110126163655.GU18984@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110126163655.GU18984@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 26, 2011 at 04:36:55PM +0000, Mel Gorman wrote:
> > But the wmarks don't
> > seem the real offender, maybe it's something related to the tiny pci32
> > zone that materialize on 4g systems that relocate some little memory
> > over 4g to make space for the pci32 mmio. I didn't yet finish to debug
> > it.
> > 
> 
> This has to be it. What I think is happening is that we're in balance_pgdat(),
> the "Normal" zone is never hitting the watermark and we constantly call
> "goto loop_again" trying to "rebalance" all zones.
> 

Confirmed. The following "patch" should fix allow the number of free pages to
drop to a sensible level. Note, this is not intended as a fix because it's
the utterly wrong approach to take. It's only to illustrate where things
are going wrong when the top-most zone is very small.

diff --git a/mm/vmscan.c b/mm/vmscan.c
index f5d90de..477cb77 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2259,7 +2259,8 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
 		}
 
 		if (!zone_watermark_ok_safe(zone, order, high_wmark_pages(zone),
-							classzone_idx, 0))
+							classzone_idx, 0) &&
+				zone->present_pages >= pgdat->node_present_pages >> 2)
 			all_zones_ok = false;
 		else
 			balanced += zone->present_pages;
@@ -2446,15 +2447,18 @@ loop_again:
 
 			if (!zone_watermark_ok_safe(zone, order,
 					high_wmark_pages(zone), end_zone, 0)) {
-				all_zones_ok = 0;
-				/*
-				 * We are still under min water mark.  This
-				 * means that we have a GFP_ATOMIC allocation
-				 * failure risk. Hurry up!
-				 */
-				if (!zone_watermark_ok_safe(zone, order,
-					    min_wmark_pages(zone), end_zone, 0))
-					has_under_min_watermark_zone = 1;
+				if (zone->present_pages >= pgdat->node_present_pages >> 2) {
+					all_zones_ok = 0;
+
+					/*
+					 * We are still under min water mark.  This
+					 * means that we have a GFP_ATOMIC allocation
+					 * failure risk. Hurry up!
+					 */
+					if (!zone_watermark_ok_safe(zone, order,
+						    min_wmark_pages(zone), end_zone, 0))
+						has_under_min_watermark_zone = 1;
+				}
 			} else {
 				/*
 				 * If a zone reaches its high watermark,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
