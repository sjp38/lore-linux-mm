Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id BCF296B0035
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 15:19:21 -0500 (EST)
Received: by mail-qc0-f172.google.com with SMTP id c9so21024075qcz.3
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 12:19:21 -0800 (PST)
Received: from qmta06.emeryville.ca.mail.comcast.net (qmta06.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:56])
        by mx.google.com with ESMTP id p10si4717060qag.22.2014.02.14.12.19.20
        for <linux-mm@kvack.org>;
        Fri, 14 Feb 2014 12:19:21 -0800 (PST)
Message-Id: <20140214201904.550201104@linux.com>
Date: Fri, 14 Feb 2014 14:18:47 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [PATCH 06/48] mm: Replace __get_cpu_var uses with this_cpu_ptr
References: <20140214201841.826179349@linux.com>
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=this_mm
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: akpm@linuxfoundation.org, rostedt@goodmis.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, akpm@linux-foundation.org, linux-mm@kvack.org

Replace places where __get_cpu_var() is used for an address calculation
with this_cpu_ptr().

Cc: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/lib/radix-tree.c
===================================================================
--- linux.orig/lib/radix-tree.c	2014-02-03 13:41:17.832645984 -0600
+++ linux/lib/radix-tree.c	2014-02-03 13:41:17.822646194 -0600
@@ -221,7 +221,7 @@
 		 * succeed in getting a node here (and never reach
 		 * kmem_cache_alloc)
 		 */
-		rtp = &__get_cpu_var(radix_tree_preloads);
+		rtp = this_cpu_ptr(&radix_tree_preloads);
 		if (rtp->nr) {
 			ret = rtp->nodes[rtp->nr - 1];
 			rtp->nodes[rtp->nr - 1] = NULL;
@@ -277,14 +277,14 @@
 	int ret = -ENOMEM;
 
 	preempt_disable();
-	rtp = &__get_cpu_var(radix_tree_preloads);
+	rtp = this_cpu_ptr(&radix_tree_preloads);
 	while (rtp->nr < ARRAY_SIZE(rtp->nodes)) {
 		preempt_enable();
 		node = kmem_cache_alloc(radix_tree_node_cachep, gfp_mask);
 		if (node == NULL)
 			goto out;
 		preempt_disable();
-		rtp = &__get_cpu_var(radix_tree_preloads);
+		rtp = this_cpu_ptr(&radix_tree_preloads);
 		if (rtp->nr < ARRAY_SIZE(rtp->nodes))
 			rtp->nodes[rtp->nr++] = node;
 		else
Index: linux/mm/memcontrol.c
===================================================================
--- linux.orig/mm/memcontrol.c	2014-02-03 13:41:17.832645984 -0600
+++ linux/mm/memcontrol.c	2014-02-03 13:41:17.822646194 -0600
@@ -2475,7 +2475,7 @@
  */
 static void drain_local_stock(struct work_struct *dummy)
 {
-	struct memcg_stock_pcp *stock = &__get_cpu_var(memcg_stock);
+	struct memcg_stock_pcp *stock = this_cpu_ptr(&memcg_stock);
 	drain_stock(stock);
 	clear_bit(FLUSHING_CACHED_CHARGE, &stock->flags);
 }
Index: linux/mm/memory-failure.c
===================================================================
--- linux.orig/mm/memory-failure.c	2014-02-03 13:41:17.832645984 -0600
+++ linux/mm/memory-failure.c	2014-02-03 13:41:17.822646194 -0600
@@ -1297,7 +1297,7 @@
 	unsigned long proc_flags;
 	int gotten;
 
-	mf_cpu = &__get_cpu_var(memory_failure_cpu);
+	mf_cpu = this_cpu_ptr(&memory_failure_cpu);
 	for (;;) {
 		spin_lock_irqsave(&mf_cpu->lock, proc_flags);
 		gotten = kfifo_get(&mf_cpu->fifo, &entry);
Index: linux/mm/page-writeback.c
===================================================================
--- linux.orig/mm/page-writeback.c	2014-02-03 13:41:17.832645984 -0600
+++ linux/mm/page-writeback.c	2014-02-03 13:41:17.822646194 -0600
@@ -1623,7 +1623,7 @@
 	 * 1000+ tasks, all of them start dirtying pages at exactly the same
 	 * time, hence all honoured too large initial task->nr_dirtied_pause.
 	 */
-	p =  &__get_cpu_var(bdp_ratelimits);
+	p =  this_cpu_ptr(&bdp_ratelimits);
 	if (unlikely(current->nr_dirtied >= ratelimit))
 		*p = 0;
 	else if (unlikely(*p >= ratelimit_pages)) {
@@ -1635,7 +1635,7 @@
 	 * short-lived tasks (eg. gcc invocations in a kernel build) escaping
 	 * the dirty throttling and livelock other long-run dirtiers.
 	 */
-	p = &__get_cpu_var(dirty_throttle_leaks);
+	p = this_cpu_ptr(&dirty_throttle_leaks);
 	if (*p > 0 && current->nr_dirtied < ratelimit) {
 		unsigned long nr_pages_dirtied;
 		nr_pages_dirtied = min(*p, ratelimit - current->nr_dirtied);
Index: linux/mm/swap.c
===================================================================
--- linux.orig/mm/swap.c	2014-02-03 13:41:17.832645984 -0600
+++ linux/mm/swap.c	2014-02-03 13:41:17.822646194 -0600
@@ -441,7 +441,7 @@
 
 		page_cache_get(page);
 		local_irq_save(flags);
-		pvec = &__get_cpu_var(lru_rotate_pvecs);
+		pvec = this_cpu_ptr(&lru_rotate_pvecs);
 		if (!pagevec_add(pvec, page))
 			pagevec_move_tail(pvec);
 		local_irq_restore(flags);
Index: linux/mm/vmalloc.c
===================================================================
--- linux.orig/mm/vmalloc.c	2014-02-03 13:41:17.832645984 -0600
+++ linux/mm/vmalloc.c	2014-02-03 13:41:17.822646194 -0600
@@ -1488,7 +1488,7 @@
 	if (!addr)
 		return;
 	if (unlikely(in_interrupt())) {
-		struct vfree_deferred *p = &__get_cpu_var(vfree_deferred);
+		struct vfree_deferred *p = this_cpu_ptr(&vfree_deferred);
 		if (llist_add((struct llist_node *)addr, &p->list))
 			schedule_work(&p->wq);
 	} else
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2014-02-03 13:41:17.832645984 -0600
+++ linux/mm/slub.c	2014-02-03 13:41:17.822646194 -0600
@@ -2190,7 +2190,7 @@
 
 	page = new_slab(s, flags, node);
 	if (page) {
-		c = __this_cpu_ptr(s->cpu_slab);
+		c = raw_cpu_ptr(s->cpu_slab);
 		if (c->page)
 			flush_slab(s, c);
 
@@ -2410,7 +2410,7 @@
 	 * and the retrieval of the tid.
 	 */
 	preempt_disable();
-	c = __this_cpu_ptr(s->cpu_slab);
+	c = this_cpu_ptr(s->cpu_slab);
 
 	/*
 	 * The transaction ids are globally unique per cpu and per operation on
@@ -2666,7 +2666,7 @@
 	 * during the cmpxchg then the free will succedd.
 	 */
 	preempt_disable();
-	c = __this_cpu_ptr(s->cpu_slab);
+	c = this_cpu_ptr(s->cpu_slab);
 
 	tid = c->tid;
 	preempt_enable();
Index: linux/mm/vmstat.c
===================================================================
--- linux.orig/mm/vmstat.c	2014-02-03 13:41:17.832645984 -0600
+++ linux/mm/vmstat.c	2014-02-03 13:41:17.822646194 -0600
@@ -489,7 +489,7 @@
 			continue;
 
 		if (__this_cpu_read(p->pcp.count))
-			drain_zone_pages(zone, __this_cpu_ptr(&p->pcp));
+			drain_zone_pages(zone, this_cpu_ptr(&p->pcp));
 #endif
 	}
 	fold_diff(global_diff);
@@ -1218,7 +1218,7 @@
 static void vmstat_update(struct work_struct *w)
 {
 	refresh_cpu_vm_stats();
-	schedule_delayed_work(&__get_cpu_var(vmstat_work),
+	schedule_delayed_work(this_cpu_ptr(&vmstat_work),
 		round_jiffies_relative(sysctl_stat_interval));
 }
 
Index: linux/mm/zsmalloc.c
===================================================================
--- linux.orig/mm/zsmalloc.c	2014-01-31 09:15:37.674121110 -0600
+++ linux/mm/zsmalloc.c	2014-02-03 13:42:11.281526141 -0600
@@ -1071,7 +1071,7 @@
 	class = &pool->size_class[class_idx];
 	off = obj_idx_to_offset(page, obj_idx, class->size);
 
-	area = &__get_cpu_var(zs_map_area);
+	area = this_cpu_ptr(&zs_map_area);
 	if (off + class->size <= PAGE_SIZE)
 		kunmap_atomic(area->vm_addr);
 	else {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
