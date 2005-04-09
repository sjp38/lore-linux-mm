Message-ID: <4257E0A9.5010609@yahoo.com.au>
Date: Sun, 10 Apr 2005 00:03:21 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [patch] clamp batch size to (2^n)-1
Content-Type: multipart/mixed;
 boundary="------------000400080508040903000503"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------000400080508040903000503
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Oh, this is the other thing.

I'm thinking it would be a good idea to get this into -mm ASAP,
even before you guys have fully tested it. Just to get the wheels
in motion early.

Yeah? Or did you have something else in mind?

(It is actually against the previous patchset, but obviously that
won't be merged before this patch).

-- 
SUSE Labs, Novell Inc.

--------------000400080508040903000503
Content-Type: text/plain;
 name="pcp-modify-batch.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="pcp-modify-batch.patch"

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2005-04-09 23:13:53.000000000 +1000
+++ linux-2.6/mm/page_alloc.c	2005-04-09 23:59:36.000000000 +1000
@@ -1623,6 +1623,18 @@ void __init build_percpu_pagelists(void)
 			if (batch < 1)
 				batch = 1;
 
+			/*
+			 * Clamp the batch to a 2^n - 1 value. Having a power
+			 * of 2 value was found to be more likely to have
+			 * suboptimal cache aliasing properties in some cases.
+			 *
+			 * For example if 2 tasks are alternately allocating
+			 * batches of pages, one task can end up with a lot
+			 * of pages of one half of the possible page colors
+			 * and the other with pages of the other colors.
+			 */
+			batch = (1 << fls(batch + batch/2)) - 1;
+
 			init_percpu_pageset(&zone->pageset, batch);
 			for (cpu = 0; cpu < NR_CPUS; cpu++) {
 				struct zone_pagesets *zp;

--------------000400080508040903000503--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
