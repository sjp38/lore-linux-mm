Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 382565F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 12:44:02 -0400 (EDT)
Date: Tue, 14 Apr 2009 18:44:39 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 1/5] slqb: irq section fix
Message-ID: <20090414164439.GA14873@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


slqb: irq section fix

flush_free_list can be called with interrupts enabled, from
kmem_cache_destroy. Fix this.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/mm/slqb.c
===================================================================
--- linux-2.6.orig/mm/slqb.c	2009-04-01 00:57:13.000000000 +1100
+++ linux-2.6/mm/slqb.c	2009-04-01 01:02:02.000000000 +1100
@@ -1087,7 +1087,6 @@ static void slab_free_to_remote(struct k
  */
 static void flush_free_list(struct kmem_cache *s, struct kmem_cache_list *l)
 {
-	struct kmem_cache_cpu *c;
 	void **head;
 	int nr;
 
@@ -1100,8 +1099,6 @@ static void flush_free_list(struct kmem_
 	slqb_stat_inc(l, FLUSH_FREE_LIST);
 	slqb_stat_add(l, FLUSH_FREE_LIST_OBJECTS, nr);
 
-	c = get_cpu_slab(s, smp_processor_id());
-
 	l->freelist.nr -= nr;
 	head = l->freelist.head;
 
@@ -1116,6 +1113,10 @@ static void flush_free_list(struct kmem_
 
 #ifdef CONFIG_SMP
 		if (page->list != l) {
+			struct kmem_cache_cpu *c;
+
+			c = get_cpu_slab(s, smp_processor_id());
+
 			slab_free_to_remote(s, page, object, c);
 			slqb_stat_inc(l, FLUSH_FREE_LIST_REMOTE);
 		} else
@@ -2251,6 +2252,7 @@ void kmem_cache_destroy(struct kmem_cach
 	down_write(&slqb_lock);
 	list_del(&s->list);
 
+	local_irq_disable();
 #ifdef CONFIG_SMP
 	for_each_online_cpu(cpu) {
 		struct kmem_cache_cpu *c = get_cpu_slab(s, cpu);
@@ -2297,6 +2299,7 @@ void kmem_cache_destroy(struct kmem_cach
 
 	free_kmem_cache_nodes(s);
 #endif
+	local_irq_enable();
 
 	sysfs_slab_remove(s);
 	up_write(&slqb_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
