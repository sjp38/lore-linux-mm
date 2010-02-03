Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B96E96004A5
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 16:39:16 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
References: <201002031039.710275915@firstfloor.org>
In-Reply-To: <201002031039.710275915@firstfloor.org>
Subject: [PATCH] [1/4] SLAB: Handle node-not-up case in fallback_alloc()
Message-Id: <20100203213912.D3081B1620@basil.firstfloor.org>
Date: Wed,  3 Feb 2010 22:39:12 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: submit@firstfloor.org, linux-kernel@vger.kernel.org, haicheng.li@intel.com, penberg@cs.helsinki.fi, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


When fallback_alloc() runs the node of the CPU might not be initialized yet.
Handle this case by allocating in another node.

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 mm/slab.c |   19 ++++++++++++++++++-
 1 file changed, 18 insertions(+), 1 deletion(-)

Index: linux-2.6.33-rc3-ak/mm/slab.c
===================================================================
--- linux-2.6.33-rc3-ak.orig/mm/slab.c
+++ linux-2.6.33-rc3-ak/mm/slab.c
@@ -3210,7 +3210,24 @@ retry:
 		if (local_flags & __GFP_WAIT)
 			local_irq_enable();
 		kmem_flagcheck(cache, flags);
-		obj = kmem_getpages(cache, local_flags, numa_node_id());
+
+		/*
+		 * Node not set up yet? Try one that the cache has been set up
+		 * for.
+		 */
+		nid = numa_node_id();
+		if (cache->nodelists[nid] == NULL) {
+			for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
+				nid = zone_to_nid(zone);
+				if (cache->nodelists[nid])
+					break;
+			}
+			if (!cache->nodelists[nid])
+				return NULL;
+		}
+
+
+		obj = kmem_getpages(cache, local_flags, nid);
 		if (local_flags & __GFP_WAIT)
 			local_irq_disable();
 		if (obj) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
