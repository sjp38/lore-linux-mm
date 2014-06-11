Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id 761DE6B016D
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 15:15:26 -0400 (EDT)
Received: by mail-qc0-f181.google.com with SMTP id x13so318283qcv.26
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 12:15:26 -0700 (PDT)
Received: from qmta01.emeryville.ca.mail.comcast.net (qmta01.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:16])
        by mx.google.com with ESMTP id 46si31631090qgo.12.2014.06.11.12.15.25
        for <linux-mm@kvack.org>;
        Wed, 11 Jun 2014 12:15:26 -0700 (PDT)
Message-Id: <20140611191519.070677452@linux.com>
Date: Wed, 11 Jun 2014 14:15:12 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [PATCH 2/3] slub: Use new node functions
References: <20140611191510.082006044@linux.com>
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=common_slub_node
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

Make use of the new node functions in mm/slab.h to
reduce code size and simplify.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2014-06-10 13:49:22.154458193 -0500
+++ linux/mm/slub.c	2014-06-10 13:51:03.959192299 -0500
@@ -2157,6 +2157,7 @@ slab_out_of_memory(struct kmem_cache *s,
 	static DEFINE_RATELIMIT_STATE(slub_oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 				      DEFAULT_RATELIMIT_BURST);
 	int node;
+	struct kmem_cache_node *n;
 
 	if ((gfpflags & __GFP_NOWARN) || !__ratelimit(&slub_oom_rs))
 		return;
@@ -2171,15 +2172,11 @@ slab_out_of_memory(struct kmem_cache *s,
 		pr_warn("  %s debugging increased min order, use slub_debug=O to disable.\n",
 			s->name);
 
-	for_each_online_node(node) {
-		struct kmem_cache_node *n = get_node(s, node);
+	for_each_kmem_cache_node(s, node, n) {
 		unsigned long nr_slabs;
 		unsigned long nr_objs;
 		unsigned long nr_free;
 
-		if (!n)
-			continue;
-
 		nr_free  = count_partial(n, count_free);
 		nr_slabs = node_nr_slabs(n);
 		nr_objs  = node_nr_objs(n);
@@ -2923,13 +2920,10 @@ static void early_kmem_cache_node_alloc(
 static void free_kmem_cache_nodes(struct kmem_cache *s)
 {
 	int node;
+	struct kmem_cache_node *n;
 
-	for_each_node_state(node, N_NORMAL_MEMORY) {
-		struct kmem_cache_node *n = s->node[node];
-
-		if (n)
-			kmem_cache_free(kmem_cache_node, n);
-
+	for_each_kmem_cache_node(s, node, n) {
+		kmem_cache_free(kmem_cache_node, n);
 		s->node[node] = NULL;
 	}
 }
@@ -3217,11 +3211,11 @@ static void free_partial(struct kmem_cac
 static inline int kmem_cache_close(struct kmem_cache *s)
 {
 	int node;
+	struct kmem_cache_node *n;
 
 	flush_all(s);
 	/* Attempt to free all objects */
-	for_each_node_state(node, N_NORMAL_MEMORY) {
-		struct kmem_cache_node *n = get_node(s, node);
+	for_each_kmem_cache_node(s, node, n) {
 
 		free_partial(s, n);
 		if (n->nr_partial || slabs_node(s, node))
@@ -3407,11 +3401,7 @@ int __kmem_cache_shrink(struct kmem_cach
 		return -ENOMEM;
 
 	flush_all(s);
-	for_each_node_state(node, N_NORMAL_MEMORY) {
-		n = get_node(s, node);
-
-		if (!n->nr_partial)
-			continue;
+	for_each_kmem_cache_node(s, node, n) {
 
 		for (i = 0; i < objects; i++)
 			INIT_LIST_HEAD(slabs_by_inuse + i);
@@ -3581,6 +3571,7 @@ static struct kmem_cache * __init bootst
 {
 	int node;
 	struct kmem_cache *s = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
+	struct kmem_cache_node *n;
 
 	memcpy(s, static_cache, kmem_cache->object_size);
 
@@ -3590,19 +3581,16 @@ static struct kmem_cache * __init bootst
 	 * IPIs around.
 	 */
 	__flush_cpu_slab(s, smp_processor_id());
-	for_each_node_state(node, N_NORMAL_MEMORY) {
-		struct kmem_cache_node *n = get_node(s, node);
+	for_each_kmem_cache_node(s, node, n) {
 		struct page *p;
 
-		if (n) {
-			list_for_each_entry(p, &n->partial, lru)
-				p->slab_cache = s;
+		list_for_each_entry(p, &n->partial, lru)
+			p->slab_cache = s;
 
 #ifdef CONFIG_SLUB_DEBUG
-			list_for_each_entry(p, &n->full, lru)
-				p->slab_cache = s;
+		list_for_each_entry(p, &n->full, lru)
+			p->slab_cache = s;
 #endif
-		}
 	}
 	list_add(&s->list, &slab_caches);
 	return s;
@@ -3955,16 +3943,14 @@ static long validate_slab_cache(struct k
 	unsigned long count = 0;
 	unsigned long *map = kmalloc(BITS_TO_LONGS(oo_objects(s->max)) *
 				sizeof(unsigned long), GFP_KERNEL);
+	struct kmem_cache_node *n;
 
 	if (!map)
 		return -ENOMEM;
 
 	flush_all(s);
-	for_each_node_state(node, N_NORMAL_MEMORY) {
-		struct kmem_cache_node *n = get_node(s, node);
-
+	for_each_kmem_cache_node(s, node, n)
 		count += validate_slab_node(s, n, map);
-	}
 	kfree(map);
 	return count;
 }
@@ -4118,6 +4104,7 @@ static int list_locations(struct kmem_ca
 	int node;
 	unsigned long *map = kmalloc(BITS_TO_LONGS(oo_objects(s->max)) *
 				     sizeof(unsigned long), GFP_KERNEL);
+	struct kmem_cache_node *n;
 
 	if (!map || !alloc_loc_track(&t, PAGE_SIZE / sizeof(struct location),
 				     GFP_TEMPORARY)) {
@@ -4127,8 +4114,7 @@ static int list_locations(struct kmem_ca
 	/* Push back cpu slabs */
 	flush_all(s);
 
-	for_each_node_state(node, N_NORMAL_MEMORY) {
-		struct kmem_cache_node *n = get_node(s, node);
+	for_each_kmem_cache_node(s, node, n) {
 		unsigned long flags;
 		struct page *page;
 
@@ -4327,8 +4313,9 @@ static ssize_t show_slab_objects(struct
 	get_online_mems();
 #ifdef CONFIG_SLUB_DEBUG
 	if (flags & SO_ALL) {
-		for_each_node_state(node, N_NORMAL_MEMORY) {
-			struct kmem_cache_node *n = get_node(s, node);
+		struct kmem_cache_node *n;
+
+		for_each_kmem_cache_node(s, node, n) {
 
 			if (flags & SO_TOTAL)
 				x = atomic_long_read(&n->total_objects);
@@ -4344,8 +4331,9 @@ static ssize_t show_slab_objects(struct
 	} else
 #endif
 	if (flags & SO_PARTIAL) {
-		for_each_node_state(node, N_NORMAL_MEMORY) {
-			struct kmem_cache_node *n = get_node(s, node);
+		struct kmem_cache_node *n;
+
+		for_each_kmem_cache_node(s, node, n) {
 
 			if (flags & SO_TOTAL)
 				x = count_partial(n, count_total);
@@ -4359,7 +4347,7 @@ static ssize_t show_slab_objects(struct
 	}
 	x = sprintf(buf, "%lu", total);
 #ifdef CONFIG_NUMA
-	for_each_node_state(node, N_NORMAL_MEMORY)
+	for(node = 0; node < nr_node_ids; node++)
 		if (nodes[node])
 			x += sprintf(buf + x, " N%d=%lu",
 					node, nodes[node]);
@@ -4373,16 +4361,12 @@ static ssize_t show_slab_objects(struct
 static int any_slab_objects(struct kmem_cache *s)
 {
 	int node;
+	struct kmem_cache_node *n;
 
-	for_each_online_node(node) {
-		struct kmem_cache_node *n = get_node(s, node);
-
-		if (!n)
-			continue;
-
+	for_each_kmem_cache_node(s, node, n)
 		if (atomic_long_read(&n->total_objects))
 			return 1;
-	}
+
 	return 0;
 }
 #endif
@@ -5337,12 +5321,9 @@ void get_slabinfo(struct kmem_cache *s,
 	unsigned long nr_objs = 0;
 	unsigned long nr_free = 0;
 	int node;
+	struct kmem_cache_node *n;
 
-	for_each_online_node(node) {
-		struct kmem_cache_node *n = get_node(s, node);
-
-		if (!n)
-			continue;
+	for_each_kmem_cache_node(s, node, n) {
 
 		nr_slabs += node_nr_slabs(n);
 		nr_objs += node_nr_objs(n);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
