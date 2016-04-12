Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id EE22C6B0261
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 00:51:45 -0400 (EDT)
Received: by mail-pf0-f172.google.com with SMTP id c20so6239454pfc.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 21:51:45 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id g70si7648744pfg.32.2016.04.11.21.51.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 21:51:45 -0700 (PDT)
Received: by mail-pa0-x22b.google.com with SMTP id bx7so6043854pad.3
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 21:51:45 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v2 05/11] mm/slab: clean-up kmem_cache_node setup
Date: Tue, 12 Apr 2016 13:51:00 +0900
Message-Id: <1460436666-20462-6-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1460436666-20462-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1460436666-20462-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

There are mostly same code for setting up kmem_cache_node either in
cpuup_prepare() or alloc_kmem_cache_node().  Factor out and clean-up them.

v2
o Rename setup_kmem_cache_node_node to setup_kmem_cache_nodes
o Fix suspend-to-ram issue reported by Nishanth

Tested-by: Nishanth Menon <nm@ti.com>
Tested-by: Jon Hunter <jonathanh@nvidia.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c | 168 +++++++++++++++++++++++++-------------------------------------
 1 file changed, 68 insertions(+), 100 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 49af685..27cb390 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -898,6 +898,63 @@ static int init_cache_node_node(int node)
 	return 0;
 }
 
+static int setup_kmem_cache_node(struct kmem_cache *cachep,
+				int node, gfp_t gfp, bool force_change)
+{
+	int ret = -ENOMEM;
+	struct kmem_cache_node *n;
+	struct array_cache *old_shared = NULL;
+	struct array_cache *new_shared = NULL;
+	struct alien_cache **new_alien = NULL;
+	LIST_HEAD(list);
+
+	if (use_alien_caches) {
+		new_alien = alloc_alien_cache(node, cachep->limit, gfp);
+		if (!new_alien)
+			goto fail;
+	}
+
+	if (cachep->shared) {
+		new_shared = alloc_arraycache(node,
+			cachep->shared * cachep->batchcount, 0xbaadf00d, gfp);
+		if (!new_shared)
+			goto fail;
+	}
+
+	ret = init_cache_node(cachep, node, gfp);
+	if (ret)
+		goto fail;
+
+	n = get_node(cachep, node);
+	spin_lock_irq(&n->list_lock);
+	if (n->shared && force_change) {
+		free_block(cachep, n->shared->entry,
+				n->shared->avail, node, &list);
+		n->shared->avail = 0;
+	}
+
+	if (!n->shared || force_change) {
+		old_shared = n->shared;
+		n->shared = new_shared;
+		new_shared = NULL;
+	}
+
+	if (!n->alien) {
+		n->alien = new_alien;
+		new_alien = NULL;
+	}
+
+	spin_unlock_irq(&n->list_lock);
+	slabs_destroy(cachep, &list);
+
+fail:
+	kfree(old_shared);
+	kfree(new_shared);
+	free_alien_cache(new_alien);
+
+	return ret;
+}
+
 static void cpuup_canceled(long cpu)
 {
 	struct kmem_cache *cachep;
@@ -969,7 +1026,6 @@ free_slab:
 static int cpuup_prepare(long cpu)
 {
 	struct kmem_cache *cachep;
-	struct kmem_cache_node *n = NULL;
 	int node = cpu_to_mem(cpu);
 	int err;
 
@@ -988,44 +1044,9 @@ static int cpuup_prepare(long cpu)
 	 * array caches
 	 */
 	list_for_each_entry(cachep, &slab_caches, list) {
-		struct array_cache *shared = NULL;
-		struct alien_cache **alien = NULL;
-
-		if (cachep->shared) {
-			shared = alloc_arraycache(node,
-				cachep->shared * cachep->batchcount,
-				0xbaadf00d, GFP_KERNEL);
-			if (!shared)
-				goto bad;
-		}
-		if (use_alien_caches) {
-			alien = alloc_alien_cache(node, cachep->limit, GFP_KERNEL);
-			if (!alien) {
-				kfree(shared);
-				goto bad;
-			}
-		}
-		n = get_node(cachep, node);
-		BUG_ON(!n);
-
-		spin_lock_irq(&n->list_lock);
-		if (!n->shared) {
-			/*
-			 * We are serialised from CPU_DEAD or
-			 * CPU_UP_CANCELLED by the cpucontrol lock
-			 */
-			n->shared = shared;
-			shared = NULL;
-		}
-#ifdef CONFIG_NUMA
-		if (!n->alien) {
-			n->alien = alien;
-			alien = NULL;
-		}
-#endif
-		spin_unlock_irq(&n->list_lock);
-		kfree(shared);
-		free_alien_cache(alien);
+		err = setup_kmem_cache_node(cachep, node, GFP_KERNEL, false);
+		if (err)
+			goto bad;
 	}
 
 	return 0;
@@ -3676,72 +3697,19 @@ EXPORT_SYMBOL(kfree);
 /*
  * This initializes kmem_cache_node or resizes various caches for all nodes.
  */
-static int alloc_kmem_cache_node(struct kmem_cache *cachep, gfp_t gfp)
+static int setup_kmem_cache_nodes(struct kmem_cache *cachep, gfp_t gfp)
 {
+	int ret;
 	int node;
 	struct kmem_cache_node *n;
-	struct array_cache *new_shared;
-	struct alien_cache **new_alien = NULL;
 
 	for_each_online_node(node) {
-
-		if (use_alien_caches) {
-			new_alien = alloc_alien_cache(node, cachep->limit, gfp);
-			if (!new_alien)
-				goto fail;
-		}
-
-		new_shared = NULL;
-		if (cachep->shared) {
-			new_shared = alloc_arraycache(node,
-				cachep->shared*cachep->batchcount,
-					0xbaadf00d, gfp);
-			if (!new_shared) {
-				free_alien_cache(new_alien);
-				goto fail;
-			}
-		}
-
-		n = get_node(cachep, node);
-		if (n) {
-			struct array_cache *shared = n->shared;
-			LIST_HEAD(list);
-
-			spin_lock_irq(&n->list_lock);
-
-			if (shared)
-				free_block(cachep, shared->entry,
-						shared->avail, node, &list);
-
-			n->shared = new_shared;
-			if (!n->alien) {
-				n->alien = new_alien;
-				new_alien = NULL;
-			}
-			n->free_limit = (1 + nr_cpus_node(node)) *
-					cachep->batchcount + cachep->num;
-			spin_unlock_irq(&n->list_lock);
-			slabs_destroy(cachep, &list);
-			kfree(shared);
-			free_alien_cache(new_alien);
-			continue;
-		}
-		n = kmalloc_node(sizeof(struct kmem_cache_node), gfp, node);
-		if (!n) {
-			free_alien_cache(new_alien);
-			kfree(new_shared);
+		ret = setup_kmem_cache_node(cachep, node, gfp, true);
+		if (ret)
 			goto fail;
-		}
 
-		kmem_cache_node_init(n);
-		n->next_reap = jiffies + REAPTIMEOUT_NODE +
-				((unsigned long)cachep) % REAPTIMEOUT_NODE;
-		n->shared = new_shared;
-		n->alien = new_alien;
-		n->free_limit = (1 + nr_cpus_node(node)) *
-					cachep->batchcount + cachep->num;
-		cachep->node[node] = n;
 	}
+
 	return 0;
 
 fail:
@@ -3783,7 +3751,7 @@ static int __do_tune_cpucache(struct kmem_cache *cachep, int limit,
 	cachep->shared = shared;
 
 	if (!prev)
-		goto alloc_node;
+		goto setup_node;
 
 	for_each_online_cpu(cpu) {
 		LIST_HEAD(list);
@@ -3800,8 +3768,8 @@ static int __do_tune_cpucache(struct kmem_cache *cachep, int limit,
 	}
 	free_percpu(prev);
 
-alloc_node:
-	return alloc_kmem_cache_node(cachep, gfp);
+setup_node:
+	return setup_kmem_cache_nodes(cachep, gfp);
 }
 
 static int do_tune_cpucache(struct kmem_cache *cachep, int limit,
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
