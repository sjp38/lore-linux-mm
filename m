Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 5D5256B0260
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 00:51:42 -0400 (EDT)
Received: by mail-pf0-f177.google.com with SMTP id 184so6282981pff.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 21:51:42 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id 75si7645631pfs.118.2016.04.11.21.51.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 21:51:41 -0700 (PDT)
Received: by mail-pa0-x231.google.com with SMTP id ot11so6101930pab.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 21:51:41 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v2 04/11] mm/slab: factor out kmem_cache_node initialization code
Date: Tue, 12 Apr 2016 13:50:59 +0900
Message-Id: <1460436666-20462-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1460436666-20462-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1460436666-20462-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

It can be reused on other place, so factor out it.  Following patch will
use it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c | 68 ++++++++++++++++++++++++++++++++++++---------------------------
 1 file changed, 39 insertions(+), 29 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 5451929..49af685 100644
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
