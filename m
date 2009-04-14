Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AAD505F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 12:45:35 -0400 (EDT)
Date: Tue, 14 Apr 2009 18:46:15 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 3/5] slqb: cap remote free list size
Message-ID: <20090414164615.GC14873@wotan.suse.de>
References: <20090414164439.GA14873@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090414164439.GA14873@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


slqb: cap remote free list size

SLQB has a design flaw noticed by Yanmin Zhang when doing network packet
stress testing.

My intention with lockless slab lists had been to try to balance
producer/consumer type activity on the object queues just at allocation-time
with the producer and free-time with the consumer. But that breaks down if you
have a huge number of objects in-flight and then free them after activity is
reduced at the producer-side.

Basically just objects being allocated on CPU0 are then freed by CPU1 but then
rely on activity from CPU0 (or periodic trimming) to free them back to the page
allocator. If there is infrequent activity on CPU0, then it can take a long
time for the periodic trimming to free up unused objects.

Fix this by adding a lock to the page list queues and allowing CPU1 to do the
freeing work synchronously if queues get too large. It allows "nice"
producer/consumer type patterns to still fit within the fast object queues,
without the possibility to build up a lot of objects... The spinlock should
not be a big problem for nice workloads, as it is at least an order of
magnitude less frequent than an object allocation/free operation.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/include/linux/slqb_def.h
===================================================================
--- linux-2.6.orig/include/linux/slqb_def.h	2009-04-01 03:10:27.000000000 +1100
+++ linux-2.6/include/linux/slqb_def.h	2009-04-01 04:06:58.000000000 +1100
@@ -77,6 +77,9 @@ struct kmem_cache_list {
 				/* Total number of slabs allocated */
 	unsigned long		nr_slabs;
 
+				/* Protects nr_partial, nr_slabs, and partial */
+	spinlock_t		page_lock;
+
 #ifdef CONFIG_SMP
 	/*
 	 * In the case of per-cpu lists, remote_free is for objects freed by
Index: linux-2.6/mm/slqb.c
===================================================================
--- linux-2.6.orig/mm/slqb.c	2009-04-01 03:11:25.000000000 +1100
+++ linux-2.6/mm/slqb.c	2009-04-01 04:24:05.000000000 +1100
@@ -1089,6 +1089,7 @@ static void flush_free_list(struct kmem_
 {
 	void **head;
 	int nr;
+	int locked = 0;
 
 	nr = l->freelist.nr;
 	if (unlikely(!nr))
@@ -1115,17 +1116,31 @@ static void flush_free_list(struct kmem_
 		if (page->list != l) {
 			struct kmem_cache_cpu *c;
 
+			if (locked) {
+				spin_unlock(&l->page_lock);
+				locked = 0;
+			}
+
 			c = get_cpu_slab(s, smp_processor_id());
 
 			slab_free_to_remote(s, page, object, c);
 			slqb_stat_inc(l, FLUSH_FREE_LIST_REMOTE);
 		} else
 #endif
+		{
+			if (!locked) {
+				spin_lock(&l->page_lock);
+				locked = 1;
+			}
 			free_object_to_page(s, l, page, object);
+		}
 
 		nr--;
 	} while (nr);
 
+	if (locked)
+		spin_unlock(&l->page_lock);
+
 	l->freelist.head = head;
 	if (!l->freelist.nr)
 		l->freelist.tail = NULL;
@@ -1272,6 +1287,21 @@ static noinline void *__cache_list_get_p
 	return object;
 }
 
+static void *cache_list_get_page(struct kmem_cache *s,
+				struct kmem_cache_list *l)
+{
+	void *object;
+
+	if (unlikely(!l->nr_partial))
+		return NULL;
+
+	spin_lock(&l->page_lock);
+	object = __cache_list_get_page(s, l);
+	spin_unlock(&l->page_lock);
+
+	return object;
+}
+
 /*
  * Allocation slowpath. Allocate a new slab page from the page allocator, and
  * put it on the list's partial list. Must be followed by an allocation so
@@ -1315,12 +1345,14 @@ static noinline void *__slab_alloc_page(
 		l = &c->list;
 		page->list = l;
 
+		spin_lock(&l->page_lock);
 		l->nr_slabs++;
 		l->nr_partial++;
 		list_add(&page->lru, &l->partial);
 		slqb_stat_inc(l, ALLOC);
 		slqb_stat_inc(l, ALLOC_SLAB_NEW);
 		object = __cache_list_get_page(s, l);
+		spin_unlock(&l->page_lock);
 	} else {
 #ifdef CONFIG_NUMA
 		struct kmem_cache_node *n;
@@ -1378,7 +1410,7 @@ static void *__remote_slab_alloc_node(st
 
 	object = __cache_list_get_object(s, l);
 	if (unlikely(!object)) {
-		object = __cache_list_get_page(s, l);
+		object = cache_list_get_page(s, l);
 		if (unlikely(!object)) {
 			spin_unlock(&n->list_lock);
 			return __slab_alloc_page(s, gfpflags, node);
@@ -1441,7 +1473,7 @@ try_remote:
 	l = &c->list;
 	object = __cache_list_get_object(s, l);
 	if (unlikely(!object)) {
-		object = __cache_list_get_page(s, l);
+		object = cache_list_get_page(s, l);
 		if (unlikely(!object)) {
 			object = __slab_alloc_page(s, gfpflags, node);
 #ifdef CONFIG_NUMA
@@ -1544,6 +1576,37 @@ static void flush_remote_free_cache(stru
 
 	dst = c->remote_cache_list;
 
+	/*
+	 * Less common case, dst is filling up so free synchronously.
+	 * No point in having remote CPU free thse as it will just
+	 * free them back to the page list anyway.
+	 */
+	if (unlikely(dst->remote_free.list.nr > (slab_hiwater(s) >> 1))) {
+		void **head;
+
+		head = src->head;
+		spin_lock(&dst->page_lock);
+		do {
+			struct slqb_page *page;
+			void **object;
+
+			object = head;
+			VM_BUG_ON(!object);
+			head = get_freepointer(s, object);
+			page = virt_to_head_slqb_page(object);
+
+			free_object_to_page(s, dst, page, object);
+			nr--;
+		} while (nr);
+		spin_unlock(&dst->page_lock);
+
+		src->head = NULL;
+		src->tail = NULL;
+		src->nr = 0;
+
+		return;
+	}
+
 	spin_lock(&dst->remote_free.lock);
 
 	if (!dst->remote_free.list.head)
@@ -1598,7 +1661,7 @@ static noinline void slab_free_to_remote
 	r->tail = object;
 	r->nr++;
 
-	if (unlikely(r->nr > slab_freebatch(s)))
+	if (unlikely(r->nr >= slab_freebatch(s)))
 		flush_remote_free_cache(s, c);
 }
 #endif
@@ -1777,6 +1840,7 @@ static void init_kmem_cache_list(struct 
 	l->nr_partial		= 0;
 	l->nr_slabs		= 0;
 	INIT_LIST_HEAD(&l->partial);
+	spin_lock_init(&l->page_lock);
 
 #ifdef CONFIG_SMP
 	l->remote_free_check	= 0;
@@ -3059,6 +3123,7 @@ static void __gather_stats(void *arg)
 	int i;
 #endif
 
+	spin_lock(&l->page_lock);
 	nr_slabs = l->nr_slabs;
 	nr_partial = l->nr_partial;
 	nr_inuse = (nr_slabs - nr_partial) * s->objects;
@@ -3066,6 +3131,7 @@ static void __gather_stats(void *arg)
 	list_for_each_entry(page, &l->partial, lru) {
 		nr_inuse += page->inuse;
 	}
+	spin_unlock(&l->page_lock);
 
 	spin_lock(&gather->lock);
 	gather->nr_slabs += nr_slabs;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
