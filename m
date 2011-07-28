Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 444FB900137
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 04:13:10 -0400 (EDT)
Subject: [patch 2/3]vmscan: count pages into balanced for zone with good
 watermark
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 28 Jul 2011 16:13:05 +0800
Message-ID: <1311840785.15392.408.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, mgorman@suse.de, Minchan Kim <minchan.kim@gmail.com>

It's possible a zone watermark is ok at entering balance_pgdat loop, while the
zone is within requested classzone_idx. Countering pages from the zone into
balanced. In this way, we can skip shrinking zones too much for high
order allocation.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 mm/vmscan.c |    2 ++
 1 file changed, 2 insertions(+)

Index: linux/mm/vmscan.c
===================================================================
--- linux.orig/mm/vmscan.c	2011-07-28 15:17:56.000000000 +0800
+++ linux/mm/vmscan.c	2011-07-28 15:34:48.000000000 +0800
@@ -2497,6 +2497,8 @@ loop_again:
 			} else {
 				/* If balanced, clear the congested flag */
 				zone_clear_flag(zone, ZONE_CONGESTED);
+				if (i <= *classzone_idx)
+					balanced += zone->present_pages;
 			}
 		}
 		if (i < 0)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
