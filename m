Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id ADD7E6B025F
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 17:09:33 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id a2so2169023uak.0
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 14:09:33 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id h32si2809318uae.350.2017.12.27.14.09.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Dec 2017 14:09:33 -0800 (PST)
Message-Id: <20171227220652.718663523@linux.com>
Date: Wed, 27 Dec 2017 16:06:43 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [RFC 7/8] xarray: Implement migration function for objects
References: <20171227220636.361857279@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=xarray
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>

Implement functions to migrate objects. This is based on
initial code by Matthew Wilcox and was modified to work with
slab object migration.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/lib/radix-tree.c
===================================================================
--- linux.orig/lib/radix-tree.c
+++ linux/lib/radix-tree.c
@@ -1754,6 +1754,18 @@ static int radix_tree_cpu_dead(unsigned
 	return 0;
 }
 
+
+extern void xa_object_migrate(void *tree_node, int numa_node);
+
+static void radix_tree_migrate(struct kmem_cache *s, void **objects, int nr,
+		int node, void *private)
+{
+	int i;
+
+	for (i=0; i<nr; i++)
+		xa_object_migrate(objects[i], node);
+}
+
 void __init radix_tree_init(void)
 {
 	int ret;
@@ -1766,4 +1778,7 @@ void __init radix_tree_init(void)
 	ret = cpuhp_setup_state_nocalls(CPUHP_RADIX_DEAD, "lib/radix:dead",
 					NULL, radix_tree_cpu_dead);
 	WARN_ON(ret < 0);
+	kmem_cache_setup_mobility(radix_tree_node_cachep,
+					NULL,
+					radix_tree_migrate);
 }
Index: linux/include/linux/xarray.h
===================================================================
--- linux.orig/include/linux/xarray.h
+++ linux/include/linux/xarray.h
@@ -62,6 +62,8 @@ struct xarray {
 
 void __xa_init(struct xarray *, gfp_t flags);
 
+#define XA_FREE ((struct xarray *)1)
+
 /**
  * xa_init() - Initialise an empty XArray.
  * @xa: XArray.
Index: linux/lib/xarray.c
===================================================================
--- linux.orig/lib/xarray.c
+++ linux/lib/xarray.c
@@ -186,6 +186,7 @@ extern void radix_tree_node_rcu_free(str
 static void xa_node_free(struct xa_node *node)
 {
 	XA_BUG_ON(node, !list_empty(&node->private_list));
+	node->array = XA_FREE;
 	call_rcu(&node->rcu_head, radix_tree_node_rcu_free);
 }
 
@@ -1569,6 +1570,51 @@ void xa_destroy(struct xarray *xa)
 }
 EXPORT_SYMBOL(xa_destroy);
 
+void xa_object_migrate(struct xa_node *node, int numa_node)
+{
+	struct xarray *xa = READ_ONCE(node->array);
+	void __rcu **slot;
+	struct xa_node *new_node;
+	int i;
+
+	/* Freed or not yet in tree then skip */
+	if (!xa || xa == XA_FREE)
+		return;
+
+	new_node = kmem_cache_alloc_node(radix_tree_node_cachep, GFP_KERNEL, numa_node);
+
+	xa_lock_irq(xa);
+
+	/* Check again..... */
+	if (xa != node->array || !list_empty(&node->private_list)) {
+		node = new_node;
+		goto unlock;
+	}
+
+	memcpy(new_node, node, sizeof(struct xa_node));
+
+	/* Move pointers to new node */
+	INIT_LIST_HEAD(&new_node->private_list);
+	for (i = 0; i < XA_CHUNK_SIZE; i++) {
+		void *x = xa_entry_locked(xa, new_node, i);
+
+		if (xa_is_node(x))
+			rcu_assign_pointer(xa_to_node(x)->parent, new_node);
+	}
+	if (!new_node->parent)
+		slot = &xa->xa_head;
+	else
+		slot = &xa_parent_locked(xa, new_node)->slots[new_node->offset];
+	rcu_assign_pointer(*slot, xa_mk_node(new_node));
+
+unlock:
+	xa_unlock_irq(xa);
+	xa_node_free(node);
+	rcu_barrier();
+	return;
+
+}
+
 #ifdef XA_DEBUG
 void xa_dump_node(const struct xa_node *node)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
