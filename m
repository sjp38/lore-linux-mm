Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f182.google.com (mail-ve0-f182.google.com [209.85.128.182])
	by kanga.kvack.org (Postfix) with ESMTP id 4232D6B0038
	for <linux-mm@kvack.org>; Fri, 30 May 2014 14:28:08 -0400 (EDT)
Received: by mail-ve0-f182.google.com with SMTP id sa20so2630217veb.27
        for <linux-mm@kvack.org>; Fri, 30 May 2014 11:28:08 -0700 (PDT)
Received: from qmta02.emeryville.ca.mail.comcast.net (qmta02.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:24])
        by mx.google.com with ESMTP id na9si3755940vcb.64.2014.05.30.11.28.07
        for <linux-mm@kvack.org>;
        Fri, 30 May 2014 11:28:07 -0700 (PDT)
Message-Id: <20140530182801.436674724@linux.com>
Date: Fri, 30 May 2014 13:27:55 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [PATCH 2/4] slub: Use new node functions
References: <20140530182753.191965442@linux.com>
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=common_slub_node
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>

Make use of the new node functions in mm/slab.h

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2014-05-30 13:15:30.541864121 -0500
+++ linux/mm/slub.c	2014-05-30 13:15:30.541864121 -0500
@@ -2148,6 +2148,7 @@ static noinline void
 slab_out_of_memory(struct kmem_cache *s, gfp_t gfpflags, int nid)
 {
 	int node;
+	struct kmem_cache_node *n;
 
 	printk(KERN_WARNING
 		"SLUB: Unable to allocate memory on node %d (gfp=0x%x)\n",
@@ -2160,15 +2161,11 @@ slab_out_of_memory(struct kmem_cache *s,
 		printk(KERN_WARNING "  %s debugging increased min order, use "
 		       "slub_debug=O to disable.\n", s->name);
 
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
@@ -4376,16 +4373,12 @@ static ssize_t show_slab_objects(struct
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
@@ -5340,12 +5333,9 @@ void get_slabinfo(struct kmem_cache *s,
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
