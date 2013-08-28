Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 42EE66B0033
	for <linux-mm@kvack.org>; Wed, 28 Aug 2013 15:48:18 -0400 (EDT)
Message-ID: <00000140c6781c1f-b60cbd61-ad4c-4ddd-a6ef-0b69dd9e0d9d-000000@email.amazonses.com>
Date: Wed, 28 Aug 2013 19:48:16 +0000
From: Christoph Lameter <cl@linux.com>
Subject: [gcv v3 07/35] mm: Replace __get_cpu_var uses
References: <20130828193457.140443630@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: akpm@linuxfoundation.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Steven Rostedt <srostedt@redhat.com>, linux-kernel@vger.kernel.org

__get_cpu_var() is used for multiple purposes in the kernel source. One of them is
address calculation via the form &__get_cpu_var(x). This calculates the address for
the instance of the percpu variable of the current processor based on an offset.

Other use cases are for storing and retrieving data from the current processors percpu area.
__get_cpu_var() can be used as an lvalue when writing data or on the right side of an assignment.

__get_cpu_var() is defined as :


#define __get_cpu_var(var) (*this_cpu_ptr(&(var)))



__get_cpu_var() always only does an address determination. However, store and retrieve operations
could use a segment prefix (or global register on other platforms) to avoid the address calculation.

this_cpu_write() and this_cpu_read() can directly take an offset into a percpu area and use
optimized assembly code to read and write per cpu variables.


This patch converts __get_cpu_var into either an explicit address calculation using this_cpu_ptr()
or into a use of this_cpu operations that use the offset. Thereby address calcualtions are avoided
and less registers are used when code is generated.

At the end of the patchset all uses of __get_cpu_var have been removed so the macro is removed too.

The patchset includes passes over all arches as well. Once these operations are used throughout then
specialized macros can be defined in non -x86 arches as well in order to optimize per cpu access by
f.e. using a global register that may be set to the per cpu base.




Transformations done to __get_cpu_var()


1. Determine the address of the percpu instance of the current processor.

	DEFINE_PER_CPU(int, y);
	int *x = &__get_cpu_var(y);

    Converts to

	int *x = this_cpu_ptr(&y);


2. Same as #1 but this time an array structure is involved.

	DEFINE_PER_CPU(int, y[20]);
	int *x = __get_cpu_var(y);

    Converts to

	int *x = this_cpu_ptr(y);


3. Retrieve the content of the current processors instance of a per cpu variable.

	DEFINE_PER_CPU(int, u);
	int x = __get_cpu_var(y)

   Converts to

	int x = __this_cpu_read(y);


4. Retrieve the content of a percpu struct

	DEFINE_PER_CPU(struct mystruct, y);
	struct mystruct x = __get_cpu_var(y);

   Converts to

	memcpy(this_cpu_ptr(&x), y, sizeof(x));


5. Assignment to a per cpu variable

	DEFINE_PER_CPU(int, y)
	__get_cpu_var(y) = x;

   Converts to

	this_cpu_write(y, x);


6. Increment/Decrement etc of a per cpu variable

	DEFINE_PER_CPU(int, y);
	__get_cpu_var(y)++

   Converts to

	this_cpu_inc(y)

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/lib/radix-tree.c
===================================================================
--- linux.orig/lib/radix-tree.c	2013-08-26 14:24:48.000000000 -0500
+++ linux/lib/radix-tree.c	2013-08-26 14:25:30.709616290 -0500
@@ -215,7 +215,7 @@ radix_tree_node_alloc(struct radix_tree_
 		 * succeed in getting a node here (and never reach
 		 * kmem_cache_alloc)
 		 */
-		rtp = &__get_cpu_var(radix_tree_preloads);
+		rtp = this_cpu_ptr(&radix_tree_preloads);
 		if (rtp->nr) {
 			ret = rtp->nodes[rtp->nr - 1];
 			rtp->nodes[rtp->nr - 1] = NULL;
@@ -271,14 +271,14 @@ int radix_tree_preload(gfp_t gfp_mask)
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
--- linux.orig/mm/memcontrol.c	2013-08-26 14:24:48.000000000 -0500
+++ linux/mm/memcontrol.c	2013-08-26 14:25:30.713616248 -0500
@@ -2398,7 +2398,7 @@ static void drain_stock(struct memcg_sto
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
--- linux.orig/mm/memory-failure.c	2013-08-26 14:24:48.000000000 -0500
+++ linux/mm/memory-failure.c	2013-08-26 14:25:30.713616248 -0500
@@ -1279,7 +1279,7 @@ static void memory_failure_work_func(str
 	unsigned long proc_flags;
 	int gotten;
 
-	mf_cpu = &__get_cpu_var(memory_failure_cpu);
+	mf_cpu = this_cpu_ptr(&memory_failure_cpu);
 	for (;;) {
 		spin_lock_irqsave(&mf_cpu->lock, proc_flags);
 		gotten = kfifo_get(&mf_cpu->fifo, &entry);
Index: linux/mm/page-writeback.c
===================================================================
--- linux.orig/mm/page-writeback.c	2013-08-26 14:24:48.000000000 -0500
+++ linux/mm/page-writeback.c	2013-08-26 14:25:30.713616248 -0500
@@ -1487,7 +1487,7 @@ void balance_dirty_pages_ratelimited(str
 	 * 1000+ tasks, all of them start dirtying pages at exactly the same
 	 * time, hence all honoured too large initial task->nr_dirtied_pause.
 	 */
-	p =  &__get_cpu_var(bdp_ratelimits);
+	p =  this_cpu_ptr(&bdp_ratelimits);
 	if (unlikely(current->nr_dirtied >= ratelimit))
 		*p = 0;
 	else if (unlikely(*p >= ratelimit_pages)) {
@@ -1499,7 +1499,7 @@ void balance_dirty_pages_ratelimited(str
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
--- linux.orig/mm/swap.c	2013-08-26 14:24:48.000000000 -0500
+++ linux/mm/swap.c	2013-08-26 14:25:30.717616206 -0500
@@ -359,7 +359,7 @@ void rotate_reclaimable_page(struct page
 
 		page_cache_get(page);
 		local_irq_save(flags);
-		pvec = &__get_cpu_var(lru_rotate_pvecs);
+		pvec = this_cpu_ptr(&lru_rotate_pvecs);
 		if (!pagevec_add(pvec, page))
 			pagevec_move_tail(pvec);
 		local_irq_restore(flags);
Index: linux/mm/vmalloc.c
===================================================================
--- linux.orig/mm/vmalloc.c	2013-08-26 14:24:48.000000000 -0500
+++ linux/mm/vmalloc.c	2013-08-26 14:25:30.717616206 -0500
@@ -1487,7 +1487,7 @@ void vfree(const void *addr)
 	if (!addr)
 		return;
 	if (unlikely(in_interrupt())) {
-		struct vfree_deferred *p = &__get_cpu_var(vfree_deferred);
+		struct vfree_deferred *p = this_cpu_ptr(&vfree_deferred);
 		if (llist_add((struct llist_node *)addr, &p->list))
 			schedule_work(&p->wq);
 	} else
Index: linux/mm/vmstat.c
===================================================================
--- linux.orig/mm/vmstat.c	2013-08-26 14:24:48.000000000 -0500
+++ linux/mm/vmstat.c	2013-08-26 14:25:30.717616206 -0500
@@ -1178,7 +1178,7 @@ int sysctl_stat_interval __read_mostly =
 static void vmstat_update(struct work_struct *w)
 {
 	refresh_cpu_vm_stats(smp_processor_id());
-	schedule_delayed_work(&__get_cpu_var(vmstat_work),
+	schedule_delayed_work(this_cpu_ptr(&vmstat_work),
 		round_jiffies_relative(sysctl_stat_interval));
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
