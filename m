Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 948696B005C
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 06:23:30 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 24 Jun 2013 20:08:57 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 1C3CD3578045
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 20:23:21 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5OANB8h4784554
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 20:23:12 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5OANJVl012497
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 20:23:20 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 1/3] mm/slab: Fix drain freelist excessively
Date: Mon, 24 Jun 2013 18:23:12 +0800
Message-Id: <1372069394-26167-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>
Cc: Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

The drain_freelist is called to drain slabs_free lists for cache reap, 
cache shrink, memory hotplug callback etc. The tofree parameter is the 
number of slab objects to free instead of the number of slabs to free. 
The parameter transfered from callers is n->free_objects or n->freelimit 
+ 5 * (searchp->num - 1) / (5 * searchp->num), and both of them mean 
the number of slabs objects. I add printk to dump drain information:

[  122.864255] tofree is 2, actually free is 52, cache size is 26

The number of objects which caller prefer to drain is 2, however, actually 
52 objects are drained, this destroy the cache locality.This patch fix it 
by compare the number of slabs objects which already drained instead of 
compare the number of slabs to the number of slab objects prefer to drain.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/slab.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index be12f68..18628da 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2479,7 +2479,7 @@ static void drain_cpu_caches(struct kmem_cache *cachep)
 
 /*
  * Remove slabs from the list of free slabs.
- * Specify the number of slabs to drain in tofree.
+ * Specify the number of slab objects to drain in tofree.
  *
  * Returns the actual number of slabs released.
  */
@@ -2491,7 +2491,7 @@ static int drain_freelist(struct kmem_cache *cache,
 	struct slab *slabp;
 
 	nr_freed = 0;
-	while (nr_freed < tofree && !list_empty(&n->slabs_free)) {
+	while (nr_freed * cache->num < tofree && !list_empty(&n->slabs_free)) {
 
 		spin_lock_irq(&n->list_lock);
 		p = n->slabs_free.prev;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
