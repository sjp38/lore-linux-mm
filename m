Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id AA59E6B00E9
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 20:13:33 -0500 (EST)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p0C1DVoX004920
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 17:13:31 -0800
Received: from pzk34 (pzk34.prod.google.com [10.243.19.162])
	by hpaq11.eem.corp.google.com with ESMTP id p0C1DT4k028165
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 17:13:29 -0800
Received: by pzk34 with SMTP id 34so20604pzk.24
        for <linux-mm@kvack.org>; Tue, 11 Jan 2011 17:13:28 -0800 (PST)
Date: Tue, 11 Jan 2011 17:13:26 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 3/3] oom: suppress nodes that are not allowed from meminfo
 on page alloc failure
In-Reply-To: <alpine.DEB.2.00.1101111712190.20611@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1101111713000.20611@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1101111712190.20611@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Displaying extremely verbose meminfo for all nodes on the system is
overkill for page allocation failures when the context restricts that
allocation to only a subset of nodes.  We don't particularly care about
the state of all nodes when some are not allowed in the current context,
they can have an abundance of memory but we can't allocate from that part
of memory.

This patch suppresses disallowed nodes from the meminfo dump on a page
allocation failure if the context requires it.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c |   19 ++++++++++++++++---
 1 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2120,12 +2120,25 @@ rebalance:
 
 nopage:
 	if (!(gfp_mask & __GFP_NOWARN) && printk_ratelimit()) {
-		printk(KERN_WARNING "%s: page allocation failure."
-			" order:%d, mode:0x%x\n",
+		unsigned int filter = SHOW_MEM_FILTER_NODES;
+
+		/*
+		 * This documents exceptions given to allocations in certain
+		 * contexts that are allowed to allocate outside current's set
+		 * of allowed nodes.
+		 */
+		if (!(gfp_mask & __GFP_NOMEMALLOC))
+			if (test_thread_flag(TIF_MEMDIE) ||
+			    (current->flags & (PF_MEMALLOC | PF_EXITING)))
+				filter &= ~SHOW_MEM_FILTER_NODES;
+		if (in_interrupt() || !wait)
+			filter &= ~SHOW_MEM_FILTER_NODES;
+
+		pr_warning("%s: page allocation failure. order:%d, mode:0x%x\n",
 			p->comm, order, gfp_mask);
 		dump_stack();
 		if (!should_suppress_show_mem())
-			show_mem();
+			__show_mem(filter);
 	}
 	return page;
 got_pg:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
