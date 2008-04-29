Date: Tue, 29 Apr 2008 16:11:12 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: slub: Whitespace cleanup and use of strict_strtoul
Message-ID: <Pine.LNX.4.64.0804291609380.15406@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[This is material that I found in your testing tree interspersed with slub 
defrag stuff. Separated out. Maybe merge this earlier]

Fix some issues with wrapping and use strict_strtoul to make parameter
passing from sysfs safer.

Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   38 +++++++++++++++++++++++++-------------
 1 file changed, 25 insertions(+), 13 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2008-04-28 21:20:44.642390610 -0700
+++ linux-2.6/mm/slub.c	2008-04-28 21:21:08.983640178 -0700
@@ -812,7 +812,8 @@ static int on_freelist(struct kmem_cache
 	return search == NULL;
 }
 
-static void trace(struct kmem_cache *s, struct page *page, void *object, int alloc)
+static void trace(struct kmem_cache *s, struct page *page, void *object,
+								int alloc)
 {
 	if (s->flags & SLAB_TRACE) {
 		printk(KERN_INFO "TRACE %s %s 0x%p inuse=%d fp=0x%p\n",
@@ -1265,8 +1266,7 @@ static void add_partial(struct kmem_cach
 	spin_unlock(&n->list_lock);
 }
 
-static void remove_partial(struct kmem_cache *s,
-						struct page *page)
+static void remove_partial(struct kmem_cache *s, struct page *page)
 {
 	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
 
@@ -1281,7 +1281,8 @@ static void remove_partial(struct kmem_c
  *
  * Must hold list_lock.
  */
-static inline int lock_and_freeze_slab(struct kmem_cache_node *n, struct page *page)
+static inline int lock_and_freeze_slab(struct kmem_cache_node *n,
+							struct page *page)
 {
 	if (slab_trylock(page)) {
 		list_del(&page->lru);
@@ -1418,8 +1419,8 @@ static void unfreeze_slab(struct kmem_ca
 			 * so that the others get filled first. That way the
 			 * size of the partial list stays small.
 			 *
-			 * kmem_cache_shrink can reclaim any empty slabs from the
-			 * partial list.
+			 * kmem_cache_shrink can reclaim any empty slabs from
+			 * the partial list.
 			 */
 			add_partial(n, page, 1);
 			slab_unlock(page);
@@ -2905,7 +2906,7 @@ static int slab_mem_going_online_callbac
 		return 0;
 
 	/*
-	 * We are bringing a node online. No memory is availabe yet. We must
+	 * We are bringing a node online. No memory is available yet. We must
 	 * allocate a kmem_cache_node structure in order to bring the node
 	 * online.
 	 */
@@ -3810,7 +3811,12 @@ SLAB_ATTR_RO(objs_per_slab);
 static ssize_t order_store(struct kmem_cache *s,
 				const char *buf, size_t length)
 {
-	int order = simple_strtoul(buf, NULL, 10);
+	unsigned long order;
+	int err;
+
+	err = strict_strtoul(buf, 10, &order);
+	if (err)
+		return err;
 
 	if (order > slub_max_order || order < slub_min_order)
 		return -EINVAL;
@@ -4063,10 +4069,16 @@ static ssize_t remote_node_defrag_ratio_
 static ssize_t remote_node_defrag_ratio_store(struct kmem_cache *s,
 				const char *buf, size_t length)
 {
-	int n = simple_strtoul(buf, NULL, 10);
+	unsigned long ratio;
+	int err;
+
+	err = strict_strtoul(buf, 10, &ratio);
+	if (err)
+		return err;
+
+	if (ratio < 100)
+		s->remote_node_defrag_ratio = ratio * 10;
 
-	if (n < 100)
-		s->remote_node_defrag_ratio = n * 10;
 	return length;
 }
 SLAB_ATTR(remote_node_defrag_ratio);
@@ -4423,8 +4435,8 @@ __initcall(slab_sysfs_init);
  */
 #ifdef CONFIG_SLABINFO
 
-ssize_t slabinfo_write(struct file *file, const char __user * buffer,
-                       size_t count, loff_t *ppos)
+ssize_t slabinfo_write(struct file *file, const char __user *buffer,
+		       size_t count, loff_t *ppos)
 {
 	return -EINVAL;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
