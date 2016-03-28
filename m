Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 29BB56B0262
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 01:27:25 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fe3so90065433pab.1
        for <linux-mm@kvack.org>; Sun, 27 Mar 2016 22:27:25 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id d82si10735402pfj.52.2016.03.27.22.27.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Mar 2016 22:27:24 -0700 (PDT)
Received: by mail-pa0-x22c.google.com with SMTP id zm5so4455458pac.0
        for <linux-mm@kvack.org>; Sun, 27 Mar 2016 22:27:24 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 04/11] mm/slab: factor out kmem_cache_node initialization code
Date: Mon, 28 Mar 2016 14:26:54 +0900
Message-Id: <1459142821-20303-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1459142821-20303-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1459142821-20303-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

It can be reused on other place, so factor out it. Following
patch will use it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c | 68 ++++++++++++++++++++++++++++++++++++---------------------------
 1 file changed, 39 insertions(+), 29 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index ba2eacf..569d7db 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -841,6 +841,40 @@ static inline gfp_t gfp_exact_node(gfp_t flags)
 }
 #endif
 
+static int init_cache_node(struct kmem_cache *cachep, int node, gfp_t gfp)
+{
+	struct kmem_cache_node *n;
+
+	/*
+	 * Set up the kmem_cache_node for cpu before we can
+	 * begin anything. Make sure some other cpu on this
+	 * node has not already allocated this
+	 */
+	n = get_node(cachep, node);
+	if (n)
+		return 0;
+
+	n = kmalloc_node(sizeof(struct kmem_cache_node), gfp, node);
+	if (!n)
+		return -ENOMEM;
+
+	kmem_cache_node_init(n);
+	n->next_reap = jiffies + REAPTIMEOUT_NODE +
+		    ((unsigned long)cachep) % REAPTIMEOUT_NODE;
+
+	n->free_limit =
+		(1 + nr_cpus_node(node)) * cachep->batchcount + cachep->num;
+
+	/*
+	 * The kmem_cache_nodes don't come and go as CPUs
+	 * come and go.  slab_mutex is sufficient
+	 * protection here.
+	 */
+	cachep->node[node] = n;
+
+	return 0;
+}
+
 /*
  * Allocates and initializes node for a node on each slab cache, used for
  * either memory or cpu hotplug.  If memory is being hot-added, the kmem_cache_node
@@ -852,39 +886,15 @@ static inline gfp_t gfp_exact_node(gfp_t flags)
  */
 static int init_cache_node_node(int node)
 {
+	int ret;
 	struct kmem_cache *cachep;
-	struct kmem_cache_node *n;
-	const size_t memsize = sizeof(struct kmem_cache_node);
 
 	list_for_each_entry(cachep, &slab_caches, list) {
-		/*
-		 * Set up the kmem_cache_node for cpu before we can
-		 * begin anything. Make sure some other cpu on this
-		 * node has not already allocated this
-		 */
-		n = get_node(cachep, node);
-		if (!n) {
-			n = kmalloc_node(memsize, GFP_KERNEL, node);
-			if (!n)
-				return -ENOMEM;
-			kmem_cache_node_init(n);
-			n->next_reap = jiffies + REAPTIMEOUT_NODE +
-			    ((unsigned long)cachep) % REAPTIMEOUT_NODE;
-
-			/*
-			 * The kmem_cache_nodes don't come and go as CPUs
-			 * come and go.  slab_mutex is sufficient
-			 * protection here.
-			 */
-			cachep->node[node] = n;
-		}
-
-		spin_lock_irq(&n->list_lock);
-		n->free_limit =
-			(1 + nr_cpus_node(node)) *
-			cachep->batchcount + cachep->num;
-		spin_unlock_irq(&n->list_lock);
+		ret = init_cache_node(cachep, node, GFP_KERNEL);
+		if (ret)
+			return ret;
 	}
+
 	return 0;
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
