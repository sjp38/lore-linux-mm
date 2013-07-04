Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 131BE6B0032
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 20:33:39 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 4 Jul 2013 10:21:44 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 0B2CE2BB0054
	for <linux-mm@kvack.org>; Thu,  4 Jul 2013 10:33:31 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r640XLxt66126054
	for <linux-mm@kvack.org>; Thu, 4 Jul 2013 10:33:21 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r640XTLZ026927
	for <linux-mm@kvack.org>; Thu, 4 Jul 2013 10:33:30 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v3 1/5] mm/slab: Fix drain freelist excessively
Date: Thu,  4 Jul 2013 08:33:22 +0800
Message-Id: <1372898006-6308-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>
Cc: Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Changelog:
 v1 -> v2:
  * Fix the callers that pass # of objects. Make sure they pass # of slabs.
 v2 -> v3:
  * introduce helper function slabs_tofree 

The drain_freelist is called to drain slabs_free lists for cache reap,
cache shrink, memory hotplug callback etc. The tofree parameter should
be the number of slab to free instead of the number of slab objects to
free.

This patch fix the callers that pass # of objects. Make sure they pass #
of slabs.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/slab.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index e6122b2..3002771 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1180,6 +1180,12 @@ static int init_cache_node_node(int node)
 	return 0;
 }
 
+static inline int slabs_tofree(struct kmem_cache *cachep,
+						struct kmem_cache_node *n)
+{
+	return (n->free_objects + cachep->num - 1) / cachep->num;
+}
+
 static void cpuup_canceled(long cpu)
 {
 	struct kmem_cache *cachep;
@@ -1241,7 +1247,7 @@ free_array_cache:
 		n = cachep->node[node];
 		if (!n)
 			continue;
-		drain_freelist(cachep, n, n->free_objects);
+		drain_freelist(cachep, n, slabs_tofree(cachep, n));
 	}
 }
 
@@ -1408,7 +1414,7 @@ static int __meminit drain_cache_node_node(int node)
 		if (!n)
 			continue;
 
-		drain_freelist(cachep, n, n->free_objects);
+		drain_freelist(cachep, n, slabs_tofree(cachep, n));
 
 		if (!list_empty(&n->slabs_full) ||
 		    !list_empty(&n->slabs_partial)) {
@@ -2532,7 +2538,7 @@ static int __cache_shrink(struct kmem_cache *cachep)
 		if (!n)
 			continue;
 
-		drain_freelist(cachep, n, n->free_objects);
+		drain_freelist(cachep, n, slabs_tofree(cachep, n));
 
 		ret += !list_empty(&n->slabs_full) ||
 			!list_empty(&n->slabs_partial);
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
