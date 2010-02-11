Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0C0FF6B0078
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 15:54:04 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
References: <20100211953.850854588@firstfloor.org>
In-Reply-To: <20100211953.850854588@firstfloor.org>
Subject: [PATCH] [1/4] SLAB: Handle node-not-up case in fallback_alloc() v2
Message-Id: <20100211205401.002CFB1978@basil.firstfloor.org>
Date: Thu, 11 Feb 2010 21:54:00 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: penberg@cs.helsinki.fi, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com, rientjes@google.com
List-ID: <linux-mm.kvack.org>


When fallback_alloc() runs the node of the CPU might not be initialized yet.
Handle this case by allocating in another node.

v2: Try to allocate from all nodes (David Rientjes)

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 mm/slab.c |   19 ++++++++++++++++++-
 1 file changed, 18 insertions(+), 1 deletion(-)

Index: linux-2.6.32-memhotadd/mm/slab.c
===================================================================
--- linux-2.6.32-memhotadd.orig/mm/slab.c
+++ linux-2.6.32-memhotadd/mm/slab.c
@@ -3188,7 +3188,24 @@ retry:
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
+				if (cache->nodelists[nid]) {
+					obj = kmem_getpages(cache, local_flags, nid);
+					if (obj)
+						break;
+				}
+			}
+		} else
+			obj = kmem_getpages(cache, local_flags, nid);
+
 		if (local_flags & __GFP_WAIT)
 			local_irq_disable();
 		if (obj) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
