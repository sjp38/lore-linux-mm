Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id E3AED6B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 13:43:32 -0400 (EDT)
Received: by mail-qg0-f41.google.com with SMTP id j5so11263370qga.28
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 10:43:32 -0700 (PDT)
Received: from qmta02.emeryville.ca.mail.comcast.net (qmta02.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:24])
        by mx.google.com with ESMTP id c13si18950567qaw.132.2014.06.02.10.43.31
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 10:43:32 -0700 (PDT)
Date: Mon, 2 Jun 2014 12:43:29 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH 4/4] slab: Use for_each_kmem_cache_node function
In-Reply-To: <20140602051254.GD17964@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.10.1406021236020.4737@gentwo.org>
References: <20140530182753.191965442@linux.com> <20140530182801.678250467@linux.com> <20140602051254.GD17964@js1304-P5Q-DELUXE>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>

On Mon, 2 Jun 2014, Joonsoo Kim wrote:

> Meanwhile, I think that this change is not good for readability. There
> are many for_each_online_node() usage that we can't replace, so I don't

We can replace many of them if we do not pass "node" around but a pointer
to the node structure. Like here:


Subject: slab: Use for_each_kmem_cache_work by reworking call chain fopr slab_set_lock_classes

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c	2014-06-02 10:50:26.631319986 -0500
+++ linux/mm/slab.c	2014-06-02 12:34:15.279952487 -0500
@@ -455,16 +455,11 @@ static struct lock_class_key debugobj_al

 static void slab_set_lock_classes(struct kmem_cache *cachep,
 		struct lock_class_key *l3_key, struct lock_class_key *alc_key,
-		int q)
+		struct kmem_cache_node *n)
 {
 	struct array_cache **alc;
-	struct kmem_cache_node *n;
 	int r;

-	n = get_node(cachep, q);
-	if (!n)
-		return;
-
 	lockdep_set_class(&n->list_lock, l3_key);
 	alc = n->alien;
 	/*
@@ -482,17 +477,19 @@ static void slab_set_lock_classes(struct
 	}
 }

-static void slab_set_debugobj_lock_classes_node(struct kmem_cache *cachep, int node)
+static void slab_set_debugobj_lock_classes_node(struct kmem_cache *cachep,
+	struct kmem_cache_node *ne)
 {
-	slab_set_lock_classes(cachep, &debugobj_l3_key, &debugobj_alc_key, node);
+	slab_set_lock_classes(cachep, &debugobj_l3_key, &debugobj_alc_key, n);
 }

 static void slab_set_debugobj_lock_classes(struct kmem_cache *cachep)
 {
 	int node;
+	struct kmem_cache_node *n;

-	for_each_online_node(node)
-		slab_set_debugobj_lock_classes_node(cachep, node);
+	for_each_kmem_cache_node(cachep, node, h)
+		slab_set_debugobj_lock_classes_node(cachep, n);
 }

 static void init_node_lock_keys(int q)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
