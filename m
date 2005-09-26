Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j8QKCRBk001106
	for <linux-mm@kvack.org>; Mon, 26 Sep 2005 16:12:27 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8QKEirJ398670
	for <linux-mm@kvack.org>; Mon, 26 Sep 2005 14:14:44 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j8QKEiBn011832
	for <linux-mm@kvack.org>; Mon, 26 Sep 2005 14:14:44 -0600
Message-ID: <433856B2.8030906@austin.ibm.com>
Date: Mon, 26 Sep 2005 15:14:42 -0500
From: Joel Schopp <jschopp@austin.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 7/9] try harder on large allocations
References: <4338537E.8070603@austin.ibm.com>
In-Reply-To: <4338537E.8070603@austin.ibm.com>
Content-Type: multipart/mixed;
 boundary="------------000108080207090403000102"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Joel Schopp <jschopp@austin.ibm.com>, lhms <lhms-devel@lists.sourceforge.net>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Mike Kravetz <kravetz@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------000108080207090403000102
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Fragmentation avoidance patches increase our chances of satisfying high order
allocations.  So this patch takes more than one iteration at trying to fulfill
those allocations because unlike before the extra iterations are often useful.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Joel Schopp <jschopp@austin.ibm.com>

--------------000108080207090403000102
Content-Type: text/plain;
 name="7_large_alloc_try_harder"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="7_large_alloc_try_harder"

Index: 2.6.13-joel2/mm/page_alloc.c
===================================================================
--- 2.6.13-joel2.orig/mm/page_alloc.c	2005-09-21 11:13:14.%N -0500
+++ 2.6.13-joel2/mm/page_alloc.c	2005-09-21 11:14:49.%N -0500
@@ -944,7 +944,8 @@ __alloc_pages(unsigned int __nocast gfp_
 	int can_try_harder;
 	int did_some_progress;
 	int alloctype;
- 
+	int highorder_retry = 3;
+
 	alloctype = (gfp_mask & __GFP_RCLM_BITS);
 	might_sleep_if(wait);
 
@@ -1090,7 +1091,14 @@ rebalance:
 				goto got_pg;
 		}
 
-		out_of_memory(gfp_mask, order);
+		if (order < MAX_ORDER/2) out_of_memory(gfp_mask, order);
+		/*
+		 * Due to low fragmentation efforts, we should try a little
+		 * harder to satisfy high order allocations
+		 */
+		if (order >= MAX_ORDER/2 && --highorder_retry > 0)
+			goto rebalance;
+
 		goto restart;
 	}
 
@@ -1107,6 +1115,8 @@ rebalance:
 			do_retry = 1;
 		if (gfp_mask & __GFP_NOFAIL)
 			do_retry = 1;
+		if (order >= MAX_ORDER/2 && --highorder_retry > 0)
+			do_retry = 1;
 	}
 	if (do_retry) {
 		blk_congestion_wait(WRITE, HZ/50);

--------------000108080207090403000102--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
