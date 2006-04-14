Date: Fri, 14 Apr 2006 20:37:07 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] slab: stop using list_for_each
Message-ID: <20060414183707.GB21144@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Use the _entry variant everywhere to clean the code up a tiny bit.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2006-04-13 16:48:58.000000000 +0200
+++ linux-2.6/mm/slab.c	2006-04-13 16:52:59.000000000 +0200
@@ -1904,8 +1904,7 @@
 	void (*dtor)(void*, struct kmem_cache *, unsigned long))
 {
 	size_t left_over, slab_size, ralign;
-	struct kmem_cache *cachep = NULL;
-	struct list_head *p;
+	struct kmem_cache *cachep = NULL, *pc;
 
 	/*
 	 * Sanity checks... these are all serious usage bugs.
@@ -1925,8 +1924,7 @@
 
 	mutex_lock(&cache_chain_mutex);
 
-	list_for_each(p, &cache_chain) {
-		struct kmem_cache *pc = list_entry(p, struct kmem_cache, next);
+	list_for_each_entry(pc, &cache_chain, next) {
 		mm_segment_t old_fs = get_fs();
 		char tmp;
 		int res;
@@ -3668,7 +3666,7 @@
  */
 static void cache_reap(void *unused)
 {
-	struct list_head *walk;
+	struct kmem_cache *searchp;
 	struct kmem_list3 *l3;
 	int node = numa_node_id();
 
@@ -3679,13 +3677,11 @@
 		return;
 	}
 
-	list_for_each(walk, &cache_chain) {
-		struct kmem_cache *searchp;
+	list_for_each_entry(searchp, &cache_chain, next) {
 		struct list_head *p;
 		int tofree;
 		struct slab *slabp;
 
-		searchp = list_entry(walk, struct kmem_cache, next);
 		check_irq_on();
 
 		/*
@@ -3813,7 +3809,6 @@
 static int s_show(struct seq_file *m, void *p)
 {
 	struct kmem_cache *cachep = p;
-	struct list_head *q;
 	struct slab *slabp;
 	unsigned long active_objs;
 	unsigned long num_objs;
@@ -3834,15 +3829,13 @@
 		check_irq_on();
 		spin_lock_irq(&l3->list_lock);
 
-		list_for_each(q, &l3->slabs_full) {
-			slabp = list_entry(q, struct slab, list);
+		list_for_each_entry(slabp, &l3->slabs_full, list) {
 			if (slabp->inuse != cachep->num && !error)
 				error = "slabs_full accounting error";
 			active_objs += cachep->num;
 			active_slabs++;
 		}
-		list_for_each(q, &l3->slabs_partial) {
-			slabp = list_entry(q, struct slab, list);
+		list_for_each_entry(slabp, &l3->slabs_partial, list) {
 			if (slabp->inuse == cachep->num && !error)
 				error = "slabs_partial inuse accounting error";
 			if (!slabp->inuse && !error)
@@ -3850,8 +3843,7 @@
 			active_objs += slabp->inuse;
 			active_slabs++;
 		}
-		list_for_each(q, &l3->slabs_free) {
-			slabp = list_entry(q, struct slab, list);
+		list_for_each_entry(slabp, &l3->slabs_free, list) {
 			if (slabp->inuse && !error)
 				error = "slabs_free/inuse accounting error";
 			num_slabs++;
@@ -3944,7 +3936,7 @@
 {
 	char kbuf[MAX_SLABINFO_WRITE + 1], *tmp;
 	int limit, batchcount, shared, res;
-	struct list_head *p;
+	struct kmem_cache *cachep;
 
 	if (count > MAX_SLABINFO_WRITE)
 		return -EINVAL;
@@ -3963,10 +3955,7 @@
 	/* Find the cache in the chain of caches. */
 	mutex_lock(&cache_chain_mutex);
 	res = -EINVAL;
-	list_for_each(p, &cache_chain) {
-		struct kmem_cache *cachep;
-
-		cachep = list_entry(p, struct kmem_cache, next);
+	list_for_each_entry(cachep, &cache_chain, next) {
 		if (!strcmp(cachep->name, kbuf)) {
 			if (limit < 1 || batchcount < 1 ||
 					batchcount > limit || shared < 0) {
@@ -4093,14 +4082,10 @@
 		check_irq_on();
 		spin_lock_irq(&l3->list_lock);
 
-		list_for_each(q, &l3->slabs_full) {
-			slabp = list_entry(q, struct slab, list);
+		list_for_each_entry(slabp, &l3->slabs_full, list)
 			handle_slab(n, cachep, slabp);
-		}
-		list_for_each(q, &l3->slabs_partial) {
-			slabp = list_entry(q, struct slab, list);
+		list_for_each_entry(slabp, &l3->slabs_partial, list)
 			handle_slab(n, cachep, slabp);
-		}
 		spin_unlock_irq(&l3->list_lock);
 	}
 	name = cachep->name;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
