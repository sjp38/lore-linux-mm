Date: Mon, 13 Sep 2004 18:57:53 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: [PATCH] Do not mark being-truncated-pages as cache hot
Message-ID: <20040913215753.GA23119@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, akpm@osdl.org
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Nick Piggin <piggin@cyberone.com.au>
List-ID: <linux-mm.kvack.org>

Hi, 

The truncate VM functions use pagevec's for operation batching, but they mark
the pagevec used to hold being-truncated-pages as "cache hot". 

There is nothing which indicates such pages are likely to be "cache hot" - the
following patch marks being-truncated-pages as cold instead. 

Please apply.


BTW Martin, I'm wondering on a few performance points about the per_cpu_page lists, 
as we talked on chat before. Here they are:

- I wonder if the size of the lists are optimal. They might be too big to fit into the caches.

- Making the allocation policy FIFO should drastically increase the chances "hot" pages
are handed to the allocator. AFAIK the policy now is LIFO.

- When we we hit the high per_cpu_pages watermark, which can easily happen,
further hot pages being freed are send down to the SLAB manager, until 
the pcp count goes below the high watermark. Meaning that during this period 
the hot/cold logic goes down the drain.

But the main point of the pcp lists, which is to avoid locking AFAIK, is not affected
by the issues I describe.

Comments?

--- linux-2.6.9-rc1-mm5/mm/truncate.c.orig	2004-09-13 19:43:08.454659904 -0300
+++ linux-2.6.9-rc1-mm5/mm/truncate.c	2004-09-13 19:45:00.765586048 -0300
@@ -133,7 +133,7 @@ void truncate_inode_pages_range(struct a
 	BUG_ON((lend & (PAGE_CACHE_SIZE - 1)) != (PAGE_CACHE_SIZE - 1));
 	end = (lend >> PAGE_CACHE_SHIFT);
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec, 1);
 	next = start;
 	while (next <= end &&
 	       pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
@@ -237,7 +237,7 @@ unsigned long invalidate_mapping_pages(s
 	unsigned long ret = 0;
 	int i;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec, 1);
 	while (next <= end &&
 			pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
 		for (i = 0; i < pagevec_count(&pvec); i++) {
@@ -293,7 +293,7 @@ void invalidate_inode_pages2(struct addr
 	pgoff_t next = 0;
 	int i;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec, 1);
 	while (pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
