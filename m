Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f177.google.com (mail-ve0-f177.google.com [209.85.128.177])
	by kanga.kvack.org (Postfix) with ESMTP id 6B42E6B0037
	for <linux-mm@kvack.org>; Fri, 30 May 2014 14:28:06 -0400 (EDT)
Received: by mail-ve0-f177.google.com with SMTP id db11so2547274veb.22
        for <linux-mm@kvack.org>; Fri, 30 May 2014 11:28:06 -0700 (PDT)
Received: from qmta10.emeryville.ca.mail.comcast.net (qmta10.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:17])
        by mx.google.com with ESMTP id fa1si3742187vcb.39.2014.05.30.11.28.05
        for <linux-mm@kvack.org>;
        Fri, 30 May 2014 11:28:06 -0700 (PDT)
Message-Id: <20140530182801.319225508@linux.com>
Date: Fri, 30 May 2014 13:27:54 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [PATCH 1/4] slab common: Add functions for kmem_cache_node access
References: <20140530182753.191965442@linux.com>
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=common_node_functions
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>

These functions allow to eliminate repeatedly used code in both
SLAB and SLUB and also allow for the insertion of debugging code
that may be needed in the development process.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slab.h
===================================================================
--- linux.orig/mm/slab.h	2014-05-30 13:12:01.444370238 -0500
+++ linux/mm/slab.h	2014-05-30 13:12:01.444370238 -0500
@@ -288,5 +288,14 @@ struct kmem_cache_node {
 
 };
 
+static inline struct kmem_cache_node *get_node(struct kmem_cache *s, int node)
+{
+	return s->node[node];
+}
+
+#define for_each_kmem_cache_node(s, node, n) \
+	for (node = 0; n = get_node(s, node), node < nr_node_ids; node++) \
+		 if (n)
+
 void *slab_next(struct seq_file *m, void *p, loff_t *pos);
 void slab_stop(struct seq_file *m, void *p);
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2014-05-30 13:10:55.000000000 -0500
+++ linux/mm/slub.c	2014-05-30 13:12:12.628022255 -0500
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
