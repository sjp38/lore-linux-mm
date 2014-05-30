Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f169.google.com (mail-vc0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1BCDD6B0039
	for <linux-mm@kvack.org>; Fri, 30 May 2014 14:28:12 -0400 (EDT)
Received: by mail-vc0-f169.google.com with SMTP id ij19so2546378vcb.14
        for <linux-mm@kvack.org>; Fri, 30 May 2014 11:28:11 -0700 (PDT)
Received: from qmta11.emeryville.ca.mail.comcast.net (qmta11.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:211])
        by mx.google.com with ESMTP id cj7si3736634vdb.40.2014.05.30.11.28.11
        for <linux-mm@kvack.org>;
        Fri, 30 May 2014 11:28:11 -0700 (PDT)
Message-Id: <20140530182801.678250467@linux.com>
Date: Fri, 30 May 2014 13:27:57 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [PATCH 4/4] slab: Use for_each_kmem_cache_node function
References: <20140530182753.191965442@linux.com>
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=common_slab_foreach
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>

Reduce code somewhat by the use of kmem_cache_node.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c	2014-05-30 13:08:32.986856450 -0500
+++ linux/mm/slab.c	2014-05-30 13:08:32.986856450 -0500
@@ -2415,17 +2415,12 @@ static void drain_cpu_caches(struct kmem
 
 	on_each_cpu(do_drain, cachep, 1);
 	check_irq_on();
-	for_each_online_node(node) {
-		n = get_node(cachep, node);
-		if (n && n->alien)
+	for_each_kmem_cache_node(cachep, node, n)
+		if (n->alien)
 			drain_alien_cache(cachep, n->alien);
-	}
 
-	for_each_online_node(node) {
-		n = get_node(cachep, node);
-		if (n)
-			drain_array(cachep, n, n->shared, 1, node);
-	}
+	for_each_kmem_cache_node(cachep, node, n)
+		drain_array(cachep, n, n->shared, 1, node);
 }
 
 /*
@@ -2478,11 +2473,7 @@ static int __cache_shrink(struct kmem_ca
 	drain_cpu_caches(cachep);
 
 	check_irq_on();
-	for_each_online_node(i) {
-		n = get_node(cachep, i);
-		if (!n)
-			continue;
-
+	for_each_kmem_cache_node(cachep, i, n) {
 		drain_freelist(cachep, n, slabs_tofree(cachep, n));
 
 		ret += !list_empty(&n->slabs_full) ||
@@ -2525,13 +2516,10 @@ int __kmem_cache_shutdown(struct kmem_ca
 	    kfree(cachep->array[i]);
 
 	/* NUMA: free the node structures */
-	for_each_online_node(i) {
-		n = get_node(cachep, i);
-		if (n) {
-			kfree(n->shared);
-			free_alien_cache(n->alien);
-			kfree(n);
-		}
+	for_each_kmem_cache_node(cachep, i, n) {
+		kfree(n->shared);
+		free_alien_cache(n->alien);
+		kfree(n);
 	}
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
