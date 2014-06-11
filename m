Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id 572CB6B016B
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 15:15:24 -0400 (EDT)
Received: by mail-qc0-f182.google.com with SMTP id m20so335551qcx.13
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 12:15:24 -0700 (PDT)
Received: from qmta07.emeryville.ca.mail.comcast.net (qmta07.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:64])
        by mx.google.com with ESMTP id z19si32607875qaq.59.2014.06.11.12.15.23
        for <linux-mm@kvack.org>;
        Wed, 11 Jun 2014 12:15:23 -0700 (PDT)
Message-Id: <20140611191518.964245135@linux.com>
Date: Wed, 11 Jun 2014 14:15:11 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [PATCH 1/3] slab common: Add functions for kmem_cache_node access
References: <20140611191510.082006044@linux.com>
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=common_node_functions
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

These functions allow to eliminate repeatedly used code in both
SLAB and SLUB and also allow for the insertion of debugging code
that may be needed in the development process.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slab.h
===================================================================
--- linux.orig/mm/slab.h	2014-06-10 14:18:11.506956436 -0500
+++ linux/mm/slab.h	2014-06-10 14:21:51.279893231 -0500
@@ -294,5 +294,18 @@ struct kmem_cache_node {
 
 };
 
+static inline struct kmem_cache_node *get_node(struct kmem_cache *s, int node)
+{
+	return s->node[node];
+}
+
+/*
+ * Iterator over all nodes. The body will be executed for each node that has
+ * a kmem_cache_node structure allocated (which is true for all online nodes)
+ */
+#define for_each_kmem_cache_node(__s, __node, __n) \
+	for (__node = 0; __n = get_node(__s, __node), __node < nr_node_ids; __node++) \
+		 if (__n)
+
 void *slab_next(struct seq_file *m, void *p, loff_t *pos);
 void slab_stop(struct seq_file *m, void *p);
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2014-06-10 14:18:11.506956436 -0500
+++ linux/mm/slub.c	2014-06-10 14:19:58.000000000 -0500
@@ -233,11 +233,6 @@ static inline void stat(const struct kme
  * 			Core slab cache functions
  *******************************************************************/
 
-static inline struct kmem_cache_node *get_node(struct kmem_cache *s, int node)
-{
-	return s->node[node];
-}
-
 /* Verify that a pointer has an address that is valid within a slab page */
 static inline int check_valid_pointer(struct kmem_cache *s,
 				struct page *page, const void *object)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
