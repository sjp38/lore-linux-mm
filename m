Date: Wed, 29 Nov 2006 15:07:35 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: [PATCH] GFP_THISNODE must not trigger global reclaim
Message-ID: <Pine.LNX.4.64.0611291503320.17858@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The intent of GFP_THISNODE is to make sure that an allocation occurs on a 
particular node. If this is not possible then NULL needs to be returned so 
that the caller can choose what to do next on its own (the slab allocator 
depends on that).

However, GFP_THISNODE currently triggers reclaim before returning a 
failure (GFP_THISNODE means GFP_NORETRY is set). If we have over allocated 
a node then we will currently do some reclaim before returning NULL. The 
caller may want memory from other nodes before reclaim should be 
triggered. (If the caller wants reclaim then he can directly use 
__GFP_THISNODE instead).

There is no flag to avoid reclaim in the page allocator and adding yet 
another GFP_xx flag would be difficult given that we are out of available 
flags.

So just compare and see if all bits for GFP_THISNODE (__GFP_THISNODE, 
__GFP_NORETRY and __GFP_NOWARN) are set. If so then we return NULL before 
waking up kswapd.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc6-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/mm/page_alloc.c	2006-11-29 16:10:30.257282914 -0600
+++ linux-2.6.19-rc6-mm1/mm/page_alloc.c	2006-11-29 16:10:56.697054927 -0600
@@ -1307,6 +1307,17 @@ restart:
 	if (page)
 		goto got_pg;
 
+	/*
+	 * GFP_THISNODE (meaning __GFP_THISNODE, __GFP_NORETRY and
+	 * __GFP_NOWARN set) should not cause reclaim since the subsystem
+	 * (f.e. slab) using GFP_THISNODE may choose to trigger reclaim
+	 * using a larger set of nodes after it has established that the
+	 * allowed per node queues are empty and that nodes are
+	 * over allocated.
+	 */
+	if (NUMA_BUILD && (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
+		goto nopage;
+
 	for (z = zonelist->zones; *z; z++)
 		wakeup_kswapd(*z, order);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
