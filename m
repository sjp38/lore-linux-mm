From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070410191916.8011.97158.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070410191910.8011.76133.sendpatchset@schroedinger.engr.sgi.com>
References: <20070410191910.8011.76133.sendpatchset@schroedinger.engr.sgi.com>
Subject: [SLUB 2/5] Enable tracking of full slabs
Date: Tue, 10 Apr 2007 12:19:16 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Track full slabs if free/alloc tracking is on

If slab tracking is on then build a list of full slabs so that we can
verify the integrity of all slabs and are also able to built list of
alloc/free callers.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/slub_def.h |    1 +
 mm/slub.c                |   38 ++++++++++++++++++++++++++++++++++----
 2 files changed, 35 insertions(+), 4 deletions(-)

Index: linux-2.6.21-rc6-mm1/mm/slub.c
===================================================================
--- linux-2.6.21-rc6-mm1.orig/mm/slub.c	2007-04-09 19:55:32.000000000 -0700
+++ linux-2.6.21-rc6-mm1/mm/slub.c	2007-04-09 21:08:48.000000000 -0700
@@ -572,6 +572,36 @@ static int on_freelist(struct kmem_cache
 	return 0;
 }
 
+/*
+ * Tracking of fully allocated slabs for debugging
+ */
+static void add_full(struct kmem_cache *s, struct page *page)
+{
+	struct kmem_cache_node *n;
+
+	if (!(s->flags & SLAB_STORE_USER))
+		return;
+
+	n = get_node(s, page_to_nid(page));
+	spin_lock(&n->list_lock);
+	list_add(&page->lru, &n->full);
+	spin_unlock(&n->list_lock);
+}
+
+static void remove_full(struct kmem_cache *s, struct page *page)
+{
+	struct kmem_cache_node *n;
+
+	if (!(s->flags & SLAB_STORE_USER))
+		return;
+
+	n = get_node(s, page_to_nid(page));
+
+	spin_lock(&n->list_lock);
+	list_del(&page->lru);
+	spin_unlock(&n->list_lock);
+}
+
 static int alloc_object_checks(struct kmem_cache *s, struct page *page,
 							void *object)
 {
@@ -990,6 +1020,9 @@ static void putback_slab(struct kmem_cac
 	if (page->inuse) {
 		if (page->freelist)
 			add_partial(s, page);
+		else
+		if (PageError(page))
+			add_full(s, page);
 		slab_unlock(page);
 	} else {
 		slab_unlock(page);
@@ -1253,7 +1286,7 @@ out_unlock:
 slab_empty:
 	if (prior)
 		/*
-		 * Partially used slab that is on the partial list.
+		 * Slab on the partial list.
 		 */
 		remove_partial(s, page);
 
@@ -1265,6 +1298,8 @@ slab_empty:
 debug:
 	if (!free_object_checks(s, page, x))
 		goto out_unlock;
+	if (!PageActive(page) && !page->freelist)
+		remove_full(s, page);
 	if (s->flags & SLAB_STORE_USER)
 		set_track(s, x, TRACK_FREE, addr);
 	goto checks_ok;
@@ -1383,6 +1418,7 @@ static void init_kmem_cache_node(struct 
 	atomic_long_set(&n->nr_slabs, 0);
 	spin_lock_init(&n->list_lock);
 	INIT_LIST_HEAD(&n->partial);
+	INIT_LIST_HEAD(&n->full);
 }
 
 #ifdef CONFIG_NUMA
Index: linux-2.6.21-rc6-mm1/include/linux/slub_def.h
===================================================================
--- linux-2.6.21-rc6-mm1.orig/include/linux/slub_def.h	2007-04-09 19:26:38.000000000 -0700
+++ linux-2.6.21-rc6-mm1/include/linux/slub_def.h	2007-04-09 20:59:25.000000000 -0700
@@ -16,6 +16,7 @@ struct kmem_cache_node {
 	unsigned long nr_partial;
 	atomic_long_t nr_slabs;
 	struct list_head partial;
+	struct list_head full;
 };
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
