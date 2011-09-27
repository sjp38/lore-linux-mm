Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 6A6349000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 03:18:16 -0400 (EDT)
Subject: [patch 2/2]vmscan: correctly detect GFP_ATOMIC allocation failure
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 27 Sep 2011 15:23:07 +0800
Message-ID: <1317108187.29510.201.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, mel <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

has_under_min_watermark_zone is used to detect if there is GFP_ATOMIC allocation
failure risk. For a high end_zone, if any zone below or equal to it has min
matermark ok, we have no risk. But current logic is any zone has min watermark
not ok, then we have risk. This is wrong to me.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 mm/vmscan.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

Index: linux/mm/vmscan.c
===================================================================
--- linux.orig/mm/vmscan.c	2011-09-27 15:09:29.000000000 +0800
+++ linux/mm/vmscan.c	2011-09-27 15:14:45.000000000 +0800
@@ -2463,7 +2463,7 @@ loop_again:
 
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
 		unsigned long lru_pages = 0;
-		int has_under_min_watermark_zone = 0;
+		int has_under_min_watermark_zone = 1;
 
 		/* The swap token gets in the way of swapout... */
 		if (!priority)
@@ -2594,9 +2594,10 @@ loop_again:
 				 * means that we have a GFP_ATOMIC allocation
 				 * failure risk. Hurry up!
 				 */
-				if (!zone_watermark_ok_safe(zone, order,
+				if (has_under_min_watermark_zone &&
+					    zone_watermark_ok_safe(zone, order,
 					    min_wmark_pages(zone), end_zone, 0))
-					has_under_min_watermark_zone = 1;
+					has_under_min_watermark_zone = 0;
 			} else {
 				/*
 				 * If a zone reaches its high watermark,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
