Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0E9A76B0169
	for <linux-mm@kvack.org>; Thu,  4 Aug 2011 23:50:43 -0400 (EDT)
Date: Fri, 5 Aug 2011 11:50:40 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH] readahead: add comments on PG_readahead
Message-ID: <20110805035040.GB11532@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@linux.intel.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Add comments to clarify the easily misunderstood PG_readahead timing.

PG_readahead is a trigger to say, when you get this far, it's time to
think about kicking off the _next_ readahead.            -- Hugh

CC: Hugh Dickins <hughd@google.com>
CC: Matthew Wilcox <willy@linux.intel.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/readahead.c |   27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

--- linux-next.orig/mm/readahead.c	2011-08-05 10:53:01.000000000 +0800
+++ linux-next/mm/readahead.c	2011-08-05 11:40:06.000000000 +0800
@@ -185,6 +185,14 @@ __do_page_cache_readahead(struct address
 			break;
 		page->index = page_offset;
 		list_add(&page->lru, &page_pool);
+		/*
+		 * set PG_readahead to trigger the _next_ ASYNC readahead.
+		 *
+		 *     |----------------- nr_to_read ---------------->|
+		 *     |==================#===========================|
+		 *                        |<---- lookahead_size ------|
+		 *       PG_readahead mark^
+		 */
 		if (page_idx == nr_to_read - lookahead_size)
 			SetPageReadahead(page);
 		ret++;
@@ -321,6 +329,25 @@ static unsigned long get_next_ra_size(st
  * indicator. The flag won't be set on already cached pages, to avoid the
  * readahead-for-nothing fuss, saving pointless page cache lookups.
  *
+ * A typical readahead time chart for a sequential read stream. Note that when
+ * read(2) hits the PG_readahead mark, a new readahead will be started and the
+ * PG_readahead mark will be "pushed forward" by clearing the old PG_readahead
+ * and setting a new PG_readahead in the new readahead window.
+ *
+ * t0
+ * t1 +#__                         ==>  SYNC readahead triggered by page miss
+ * t2 -+__#_______                 ==> ASYNC readahead triggered by PG_readahead
+ * t3 --+_#_______
+ * t4 ---+#_______
+ * t5 ----+_______#_______________ ==> ASYNC readahead triggered by PG_readahead
+ * t6 -----+______#_______________
+ * t7 ------+_____#_______________
+ *
+ * [-] accessed page
+ * [+] the page read(2) is accessing
+ * [#] the PG_readahead mark
+ * [_] readahead page (newly brought into page cache but not yet accessed)
+ *
  * prev_pos tracks the last visited byte in the _previous_ read request.
  * It should be maintained by the caller, and will be used for detecting
  * small random reads. Note that the readahead algorithm checks loosely

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
