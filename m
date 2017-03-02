Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 76D8C6B0038
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 23:12:45 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 65so78951272pgi.7
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 20:12:45 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id d198si6372775pga.192.2017.03.01.20.12.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Mar 2017 20:12:44 -0800 (PST)
Date: Wed, 1 Mar 2017 20:12:38 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [LSF/MM TOPIC] Movable memory and reliable higher order
 allocations
Message-ID: <20170302041238.GM16328@bombadil.infradead.org>
References: <alpine.DEB.2.20.1702281526170.31946@east.gentwo.org>
 <20170228231733.GI16328@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170228231733.GI16328@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Jesper Dangaard Brouer <brouer@redhat.com>, riel@redhat.com, Mel Gorman <mel@csn.ul.ie>

On Tue, Feb 28, 2017 at 03:17:33PM -0800, Matthew Wilcox wrote:
> This was one of my motivations for the xarray.  The xarray handles its own
> locking, so we can always lock out other CPUs from modifying the array.
> We still have to take care of RCU walkers, but that's straightforward
> to handle.  I have a prototype patch for the radix tree (ignoring the
> locking problem), so I can port that over to the xarray and post that
> for comment tomorrow.

This should do the trick ... untested.

I use the ->array member of the xa_node to distinguish between the
three states of the node -- allocated, in use, waiting for rcu free.
Most of the nodes will be in use, and most of them can be moved.

Let me know whether the assumptions I listed above xa_reclaim() are
reasonable ... also, do you want me returning a bool to indicate whether
I freed the node, or is that not useful because you'll know that anyway?

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 646ff84b4444..931f17a69807 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -380,6 +380,12 @@ static inline bool xa_is_relative(void *entry)
 #define XA_RESTART_FIND		((struct xa_node *)1)
 #define XA_RESTART_NEXT		((struct xa_node *)2)
 
+/*
+ * Also not an array entry.  This is found in node->array and informs
+ * the reclaim routine that the node is waiting for RCU
+ */
+#define XA_RCU_FREE		((struct xarray *)1)
+
 static inline bool xa_is_retry(void *entry)
 {
 	return unlikely(entry == XA_RETRY_ENTRY);
@@ -423,14 +429,14 @@ static inline void *xa_entry_locked(const struct xarray *xa,
 					lockdep_is_held(&xa->xa_lock));
 }
 
-static inline void *xa_parent(const struct xarray *xa,
+static inline struct xa_node *xa_parent(const struct xarray *xa,
 		const struct xa_node *node)
 {
 	return rcu_dereference_check(node->parent,
 					lockdep_is_held(&xa->xa_lock));
 }
 
-static inline void *xa_parent_locked(const struct xarray *xa,
+static inline struct xa_node *xa_parent_locked(const struct xarray *xa,
 		const struct xa_node *node)
 {
 	return rcu_dereference_protected(node->parent,
diff --git a/lib/xarray.c b/lib/xarray.c
index fd33b5b91013..d8004c8014c9 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -182,6 +182,7 @@ static void xa_node_ctor(void *p)
 	memset(&node->tags, 0, sizeof(node->tags));
 	memset(&node->slots, 0, sizeof(node->slots));
 	INIT_LIST_HEAD(&node->private_list);
+	node->array = NULL;
 }
 
 static void xa_node_rcu_free(struct rcu_head *head)
@@ -194,9 +195,72 @@ static void xa_node_rcu_free(struct rcu_head *head)
 
 static void xa_node_free(struct xa_node *node)
 {
+	node->array = XA_RCU_FREE;
 	call_rcu(&node->rcu_head, xa_node_rcu_free);
 }
 
+/*
+ * We rely on the following assumptions:
+ *  - The slab allocator calls us in process context with IRQs enabled and
+ *    no locks held (not even the RCU lock)
+ *  - We can allocate a replacement using GFP_KERNEL
+ *  - If the victim is freed while reclaim is running,
+ *    - The slab allocator will not overwrite any fields in the victim
+ *    - The page will not be returned to the page allocator until we return
+ *    - The victim will not be reallocated until we return
+ */
+static bool xa_reclaim(void *arg)
+{
+	struct xa_node *node, *victim = arg;
+	struct xarray *xa = READ_ONCE(victim->array);
+	void __rcu **slot;
+	unsigned int i;
+
+	/* Node has been allocated, but not yet placed in a tree. */
+	if (!xa)
+		return false;
+	/* If the node has already been freed, we only need to wait for RCU */
+	if (xa == XA_RCU_FREE)
+		goto out;
+
+	node = kmem_cache_alloc(xa_node_cache, GFP_KERNEL);
+
+	xa_lock_irq(xa);
+
+	/* Might have been freed since we last checked */
+	xa = victim->array;
+	if (xa == XA_RCU_FREE)
+		goto unlock;
+
+	/* Can't grab the LRU list lock here */
+	if (!list_empty(&victim->private_list))
+		goto busy;
+
+	memcpy(node, victim, sizeof(*node));
+	INIT_LIST_HEAD(&node->private_list);
+	for (i = 0; i < XA_CHUNK_SIZE; i++) {
+		void *entry = xa_entry_locked(xa, node, i);
+		if (xa_is_node(entry))
+			rcu_assign_pointer(xa_node(entry)->parent, node);
+	}
+	if (!node->parent)
+		slot = &xa->xa_head;
+	else
+		slot = &xa_parent_locked(xa, node)->slots[node->offset];
+	rcu_assign_pointer(*slot, xa_mk_node(node));
+unlock:
+	xa_unlock_irq(xa);
+	xa_node_free(victim);
+
+out:
+	rcu_barrier();
+	return true;
+
+busy:
+	xa_unlock_irq(xa);
+	return false;
+}
+
 /**
  * xas_destroy() - Dispose of any resources used during the xarray operation
  * @xas: Array operation state.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
