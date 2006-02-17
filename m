From: Andi Kleen <ak@suse.de>
Subject: [PATCH for 2.6.16] Handle all and empty zones when setting up custom zonelists for mbind
Date: Fri, 17 Feb 2006 01:39:16 +0100
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200602170139.17253.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
Cc: Linus Torvalds <torvalds@osdl.org>, akpm@osdl.org, linux-mm@kvack.org, Christoph Lameter <clameter@engr.sgi.com>
List-ID: <linux-mm.kvack.org>

The memory allocator doesn't like empty zones (which have an 
uninitialized freelist), so a x86-64 system with a node fully
in GFP_DMA32 only would crash on mbind.

Fix that up by putting all possible zones as fallback into the zonelist
and skipping the empty ones.

In fact the code always enough allocated space for all zones,
but only used it for the highest. This change just uses all the
memory that was allocated before.

This should work fine for now, but whoever implements node hot removal
needs to fix this somewhere else too (or make sure zone datastructures 
by itself never go away, only their memory)

Signed-off-by: Andi Kleen <ak@suse.de>

Index: linux/mm/mempolicy.c
===================================================================
--- linux.orig/mm/mempolicy.c
+++ linux/mm/mempolicy.c
@@ -132,19 +132,29 @@ static int mpol_check_policy(int mode, n
 	}
 	return nodes_subset(*nodes, node_online_map) ? 0 : -EINVAL;
 }
+
 /* Generate a custom zonelist for the BIND policy. */
 static struct zonelist *bind_zonelist(nodemask_t *nodes)
 {
 	struct zonelist *zl;
-	int num, max, nd;
+	int num, max, nd, k;
 
 	max = 1 + MAX_NR_ZONES * nodes_weight(*nodes);
-	zl = kmalloc(sizeof(void *) * max, GFP_KERNEL);
+	zl = kmalloc(sizeof(struct zone *) * max, GFP_KERNEL);
 	if (!zl)
 		return NULL;
 	num = 0;
-	for_each_node_mask(nd, *nodes)
-		zl->zones[num++] = &NODE_DATA(nd)->node_zones[policy_zone];
+	/* First put in the highest zones from all nodes, then all the next 
+	   lower zones etc. Avoid empty zones because the memory allocator
+	   doesn't like them. If you implement node hot removal you
+	   have to fix that. */
+	for (k = policy_zone; k >= 0; k--) { 
+		for_each_node_mask(nd, *nodes) { 
+			struct zone *z = &NODE_DATA(nd)->node_zones[k];
+			if (z->present_pages > 0) 
+				zl->zones[num++] = z;
+		}
+	}
 	zl->zones[num] = NULL;
 	return zl;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
