Date: Fri, 10 Mar 2006 16:15:40 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: drain_node_pages: interrupt latency reduction / optimization
In-Reply-To: <20060310160527.5ddfc610.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0603101605410.31461@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603101258290.29954@schroedinger.engr.sgi.com>
 <20060310160527.5ddfc610.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 10 Mar 2006, Andrew Morton wrote:

> But I _think_ we're OK for now because these functions are only ever called
> from pinned-to-cpu kernel threads.

Right. This function must be called that way otherwise it is useless. We 
should use raw_smp_processor_id().

> Please test all this with CONFIG_PREEMPT_DEBUG, confirm that it's OK.

Will do that on Monday but if this would not stay on a processor then 
other things in the slab allocator would also break.

Here is a fixup adding some comments and raw_smp_processor_id()

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2006-03-10 16:09:10.000000000 -0800
+++ linux-2.6/mm/page_alloc.c	2006-03-10 16:10:07.000000000 -0800
@@ -593,6 +593,8 @@ static int rmqueue_bulk(struct zone *zon
 /*
  * Called from the slab reaper to drain pagesets on a particular node that
  * belong to the currently executing processor.
+ * Note that this function must be called with the thread pinned to
+ * a processor.
  */
 void drain_node_pages(int nodeid)
 {
@@ -603,7 +605,7 @@ void drain_node_pages(int nodeid)
 		struct zone *zone = NODE_DATA(nodeid)->node_zones + z;
 		struct per_cpu_pageset *pset;
 
-		pset = zone_pcp(zone, smp_processor_id());
+		pset = zone_pcp(zone, raw_smp_processor_id());
 		for (i = 0; i < ARRAY_SIZE(pset->pcp); i++) {
 			struct per_cpu_pages *pcp;
 
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
