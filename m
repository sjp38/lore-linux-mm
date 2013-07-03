Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id E216A6B0031
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 20:50:16 -0400 (EDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 3 Jul 2013 10:42:49 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id B053E357804E
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 10:50:04 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r630ns0s60293312
	for <linux-mm@kvack.org>; Wed, 3 Jul 2013 10:49:55 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r630o2mt006743
	for <linux-mm@kvack.org>; Wed, 3 Jul 2013 10:50:03 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v2 1/5] mm/slab: Fix drain freelist excessively
Date: Wed,  3 Jul 2013 08:49:49 +0800
Message-Id: <1372812593-7617-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>
Cc: Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Changelog:
 v1 -> v2:
  * Fix the callers that pass # of objects. Make sure they pass # of slabs.

The drain_freelist is called to drain slabs_free lists for cache reap,
cache shrink, memory hotplug callback etc. The tofree parameter should
be the number of slab to free instead of the number of slab objects to
free.

This patch fix the callers that pass # of objects. Make sure they pass #
of slabs.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/slab.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 17298c1..13f5ecc 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1241,7 +1241,8 @@ free_array_cache:
 		n = cachep->node[node];
 		if (!n)
 			continue;
-		drain_freelist(cachep, n, n->free_objects);
+		drain_freelist(cachep, n, (n->free_objects +
+						cachep->num - 1) / cachep->num);
 	}
 }
 
@@ -1408,7 +1409,8 @@ static int __meminit drain_cache_node_node(int node)
 		if (!n)
 			continue;
 
-		drain_freelist(cachep, n, n->free_objects);
+		drain_freelist(cachep, n, (n->free_objects +
+						cachep->num - 1) / cachep->num);
 
 		if (!list_empty(&n->slabs_full) ||
 		    !list_empty(&n->slabs_partial)) {
@@ -2532,7 +2534,8 @@ static int __cache_shrink(struct kmem_cache *cachep)
 		if (!n)
 			continue;
 
-		drain_freelist(cachep, n, n->free_objects);
+		drain_freelist(cachep, n, (n->free_objects +
+						cachep->num - 1) / cachep->num);
 
 		ret += !list_empty(&n->slabs_full) ||
 			!list_empty(&n->slabs_partial);
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
