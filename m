Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id 0F6DF6B0031
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 12:33:00 -0400 (EDT)
Received: by mail-qc0-f181.google.com with SMTP id x13so4252513qcv.40
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 09:32:59 -0700 (PDT)
Received: from qmta12.emeryville.ca.mail.comcast.net (qmta12.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:227])
        by mx.google.com with ESMTP id k10si5157569qaj.33.2014.06.13.09.32.58
        for <linux-mm@kvack.org>;
        Fri, 13 Jun 2014 09:32:59 -0700 (PDT)
Date: Fri, 13 Jun 2014 11:32:56 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH 3/3] slab: Use get_node() and kmem_cache_node()
 functions
In-Reply-To: <20140612063530.GB19918@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.10.1406131108530.913@gentwo.org>
References: <20140611191510.082006044@linux.com> <20140611191519.182409067@linux.com> <20140612063530.GB19918@js1304-P5Q-DELUXE>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 12 Jun 2014, Joonsoo Kim wrote:

> > @@ -3759,8 +3746,8 @@ fail:
> >  		/* Cache is not active yet. Roll back what we did */
> >  		node--;
> >  		while (node >= 0) {
> > -			if (cachep->node[node]) {
> > -				n = cachep->node[node];
> > +			if (get_node(cachep, node)) {
> > +				n = get_node(cachep, node);
>
> Could you do this as following?
>
> n = get_node(cachep, node);
> if (n) {
>         ...
> }

Sure....

Subject: slab: Fixes to earlier patch

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c	2014-06-13 11:12:05.018384359 -0500
+++ linux/mm/slab.c	2014-06-13 11:11:57.970611243 -0500
@@ -528,8 +528,8 @@ static inline void on_slab_lock_classes(
 	struct kmem_cache_node *n;

 	VM_BUG_ON(OFF_SLAB(cachep));
-	for_each_kmem_cache_node(cachep, node, h)
-		on_slab_lock_classes_node(cachep, h);
+	for_each_kmem_cache_node(cachep, node, n)
+		on_slab_lock_classes_node(cachep, n);
 }

 static inline void init_lock_keys(void)
@@ -553,7 +553,7 @@ static inline void on_slab_lock_classes(
 }

 static inline void on_slab_lock_classes_node(struct kmem_cache *cachep,
-	int node, struct kmem_cache_node *n)
+	struct kmem_cache_node *n)
 {
 }

@@ -771,7 +771,7 @@ static inline bool is_slab_pfmemalloc(st
 static void recheck_pfmemalloc_active(struct kmem_cache *cachep,
 						struct array_cache *ac)
 {
-	struct kmem_cache_node *n = get_node(cachep,numa_mem_id());
+	struct kmem_cache_node *n = get_node(cachep, numa_mem_id());
 	struct page *page;
 	unsigned long flags;

@@ -1256,7 +1256,7 @@ static int cpuup_prepare(long cpu)
 			slab_set_debugobj_lock_classes_node(cachep, node);
 		else if (!OFF_SLAB(cachep) &&
 			 !(cachep->flags & SLAB_DESTROY_BY_RCU))
-			on_slab_lock_classes_node(cachep, node, n);
+			on_slab_lock_classes_node(cachep, n);
 	}
 	init_node_lock_keys(node);

@@ -3746,9 +3746,8 @@ fail:
 		/* Cache is not active yet. Roll back what we did */
 		node--;
 		while (node >= 0) {
-			if (get_node(cachep, node)) {
-				n = get_node(cachep, node);
-
+			n = get_node(cachep, node);
+			if (n) {
 				kfree(n->shared);
 				free_alien_cache(n->alien);
 				kfree(n);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
