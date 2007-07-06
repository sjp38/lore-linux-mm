Date: Fri, 6 Jul 2007 12:50:11 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Slab allocators: Replace explicit zeroing with __GFP_ZERO
Message-ID: <Pine.LNX.4.64.0707061249500.24312@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

kmalloc_node() and kmem_cache_alloc_node() were not available in
a zeroing variant in the past. But with __GFP_ZERO it is possible
now to do zeroing while allocating.

Use __GFP_ZERO to remove the explicit clearing of memory via memset whereever
we can.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 block/as-iosched.c       |    3 +--
 block/cfq-iosched.c      |   18 +++++++++---------
 block/deadline-iosched.c |    3 +--
 block/elevator.c         |    3 +--
 block/genhd.c            |    8 ++++----
 block/ll_rw_blk.c        |    4 ++--
 drivers/ide/ide-probe.c  |    4 ++--
 kernel/timer.c           |    4 ++--
 lib/genalloc.c           |    3 +--
 mm/allocpercpu.c         |    9 +++------
 mm/mempool.c             |    3 +--
 mm/vmalloc.c             |    6 +++---
 12 files changed, 30 insertions(+), 38 deletions(-)

Index: linux-2.6.22-rc6-mm1/block/as-iosched.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/block/as-iosched.c	2007-07-03 17:23:15.000000000 -0700
+++ linux-2.6.22-rc6-mm1/block/as-iosched.c	2007-07-03 17:25:33.000000000 -0700
@@ -1322,10 +1322,9 @@ static void *as_init_queue(request_queue
 {
 	struct as_data *ad;
 
-	ad = kmalloc_node(sizeof(*ad), GFP_KERNEL, q->node);
+	ad = kmalloc_node(sizeof(*ad), GFP_KERNEL | __GFP_ZERO, q->node);
 	if (!ad)
 		return NULL;
-	memset(ad, 0, sizeof(*ad));
 
 	ad->q = q; /* Identify what queue the data belongs to */
 
Index: linux-2.6.22-rc6-mm1/block/cfq-iosched.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/block/cfq-iosched.c	2007-07-03 17:23:15.000000000 -0700
+++ linux-2.6.22-rc6-mm1/block/cfq-iosched.c	2007-07-03 17:25:33.000000000 -0700
@@ -1249,9 +1249,9 @@ cfq_alloc_io_context(struct cfq_data *cf
 {
 	struct cfq_io_context *cic;
 
-	cic = kmem_cache_alloc_node(cfq_ioc_pool, gfp_mask, cfqd->queue->node);
+	cic = kmem_cache_alloc_node(cfq_ioc_pool, gfp_mask | __GFP_ZERO,
+							cfqd->queue->node);
 	if (cic) {
-		memset(cic, 0, sizeof(*cic));
 		cic->last_end_request = jiffies;
 		INIT_LIST_HEAD(&cic->queue_list);
 		cic->dtor = cfq_free_io_context;
@@ -1377,17 +1377,19 @@ retry:
 			 * free memory.
 			 */
 			spin_unlock_irq(cfqd->queue->queue_lock);
-			new_cfqq = kmem_cache_alloc_node(cfq_pool, gfp_mask|__GFP_NOFAIL, cfqd->queue->node);
+			new_cfqq = kmem_cache_alloc_node(cfq_pool,
+					gfp_mask | __GFP_NOFAIL | __GFP_ZERO,
+					cfqd->queue->node);
 			spin_lock_irq(cfqd->queue->queue_lock);
 			goto retry;
 		} else {
-			cfqq = kmem_cache_alloc_node(cfq_pool, gfp_mask, cfqd->queue->node);
+			cfqq = kmem_cache_alloc_node(cfq_pool,
+					gfp_mask | __GFP_ZERO,
+					cfqd->queue->node);
 			if (!cfqq)
 				goto out;
 		}
 
-		memset(cfqq, 0, sizeof(*cfqq));
-
 		RB_CLEAR_NODE(&cfqq->rb_node);
 		INIT_LIST_HEAD(&cfqq->fifo);
 
@@ -2049,12 +2051,10 @@ static void *cfq_init_queue(request_queu
 {
 	struct cfq_data *cfqd;
 
-	cfqd = kmalloc_node(sizeof(*cfqd), GFP_KERNEL, q->node);
+	cfqd = kmalloc_node(sizeof(*cfqd), GFP_KERNEL | __GFP_ZERO, q->node);
 	if (!cfqd)
 		return NULL;
 
-	memset(cfqd, 0, sizeof(*cfqd));
-
 	cfqd->service_tree = CFQ_RB_ROOT;
 	INIT_LIST_HEAD(&cfqd->cic_list);
 
Index: linux-2.6.22-rc6-mm1/block/deadline-iosched.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/block/deadline-iosched.c	2007-07-03 17:23:15.000000000 -0700
+++ linux-2.6.22-rc6-mm1/block/deadline-iosched.c	2007-07-03 17:25:33.000000000 -0700
@@ -360,10 +360,9 @@ static void *deadline_init_queue(request
 {
 	struct deadline_data *dd;
 
-	dd = kmalloc_node(sizeof(*dd), GFP_KERNEL, q->node);
+	dd = kmalloc_node(sizeof(*dd), GFP_KERNEL | __GFP_ZERO, q->node);
 	if (!dd)
 		return NULL;
-	memset(dd, 0, sizeof(*dd));
 
 	INIT_LIST_HEAD(&dd->fifo_list[READ]);
 	INIT_LIST_HEAD(&dd->fifo_list[WRITE]);
Index: linux-2.6.22-rc6-mm1/block/elevator.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/block/elevator.c	2007-07-03 17:23:15.000000000 -0700
+++ linux-2.6.22-rc6-mm1/block/elevator.c	2007-07-03 17:25:33.000000000 -0700
@@ -177,11 +177,10 @@ static elevator_t *elevator_alloc(reques
 	elevator_t *eq;
 	int i;
 
-	eq = kmalloc_node(sizeof(elevator_t), GFP_KERNEL, q->node);
+	eq = kmalloc_node(sizeof(elevator_t), GFP_KERNEL | __GFP_ZERO, q->node);
 	if (unlikely(!eq))
 		goto err;
 
-	memset(eq, 0, sizeof(*eq));
 	eq->ops = &e->ops;
 	eq->elevator_type = e;
 	kobject_init(&eq->kobj);
Index: linux-2.6.22-rc6-mm1/block/genhd.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/block/genhd.c	2007-07-03 17:23:15.000000000 -0700
+++ linux-2.6.22-rc6-mm1/block/genhd.c	2007-07-03 17:25:33.000000000 -0700
@@ -726,21 +726,21 @@ struct gendisk *alloc_disk_node(int mino
 {
 	struct gendisk *disk;
 
-	disk = kmalloc_node(sizeof(struct gendisk), GFP_KERNEL, node_id);
+	disk = kmalloc_node(sizeof(struct gendisk),
+				GFP_KERNEL | __GFP_ZERO, node_id);
 	if (disk) {
-		memset(disk, 0, sizeof(struct gendisk));
 		if (!init_disk_stats(disk)) {
 			kfree(disk);
 			return NULL;
 		}
 		if (minors > 1) {
 			int size = (minors - 1) * sizeof(struct hd_struct *);
-			disk->part = kmalloc_node(size, GFP_KERNEL, node_id);
+			disk->part = kmalloc_node(size,
+				GFP_KERNEL | __GFP_ZERO, node_id);
 			if (!disk->part) {
 				kfree(disk);
 				return NULL;
 			}
-			memset(disk->part, 0, size);
 		}
 		disk->minors = minors;
 		kobj_set_kset_s(disk,block_subsys);
Index: linux-2.6.22-rc6-mm1/block/ll_rw_blk.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/block/ll_rw_blk.c	2007-07-03 17:23:15.000000000 -0700
+++ linux-2.6.22-rc6-mm1/block/ll_rw_blk.c	2007-07-03 17:25:33.000000000 -0700
@@ -1828,11 +1828,11 @@ request_queue_t *blk_alloc_queue_node(gf
 {
 	request_queue_t *q;
 
-	q = kmem_cache_alloc_node(requestq_cachep, gfp_mask, node_id);
+	q = kmem_cache_alloc_node(requestq_cachep,
+				gfp_mask | __GFP_ZERO, node_id);
 	if (!q)
 		return NULL;
 
-	memset(q, 0, sizeof(*q));
 	init_timer(&q->unplug_timer);
 
 	snprintf(q->kobj.name, KOBJ_NAME_LEN, "%s", "queue");
Index: linux-2.6.22-rc6-mm1/drivers/ide/ide-probe.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/drivers/ide/ide-probe.c	2007-07-03 17:23:15.000000000 -0700
+++ linux-2.6.22-rc6-mm1/drivers/ide/ide-probe.c	2007-07-03 17:25:33.000000000 -0700
@@ -1073,14 +1073,14 @@ static int init_irq (ide_hwif_t *hwif)
 		hwgroup->hwif->next = hwif;
 		spin_unlock_irq(&ide_lock);
 	} else {
-		hwgroup = kmalloc_node(sizeof(ide_hwgroup_t), GFP_KERNEL,
+		hwgroup = kmalloc_node(sizeof(ide_hwgroup_t),
+					GFP_KERNEL | __GFP_ZERO,
 					hwif_to_node(hwif->drives[0].hwif));
 		if (!hwgroup)
 	       		goto out_up;
 
 		hwif->hwgroup = hwgroup;
 
-		memset(hwgroup, 0, sizeof(ide_hwgroup_t));
 		hwgroup->hwif     = hwif->next = hwif;
 		hwgroup->rq       = NULL;
 		hwgroup->handler  = NULL;
Index: linux-2.6.22-rc6-mm1/kernel/timer.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/kernel/timer.c	2007-07-03 17:23:15.000000000 -0700
+++ linux-2.6.22-rc6-mm1/kernel/timer.c	2007-07-03 17:25:33.000000000 -0700
@@ -1225,7 +1225,8 @@ static int __devinit init_timers_cpu(int
 			/*
 			 * The APs use this path later in boot
 			 */
-			base = kmalloc_node(sizeof(*base), GFP_KERNEL,
+			base = kmalloc_node(sizeof(*base),
+						GFP_KERNEL | __GFP_ZERO,
 						cpu_to_node(cpu));
 			if (!base)
 				return -ENOMEM;
@@ -1236,7 +1237,6 @@ static int __devinit init_timers_cpu(int
 				kfree(base);
 				return -ENOMEM;
 			}
-			memset(base, 0, sizeof(*base));
 			per_cpu(tvec_bases, cpu) = base;
 		} else {
 			/*
Index: linux-2.6.22-rc6-mm1/lib/genalloc.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/lib/genalloc.c	2007-07-03 17:23:15.000000000 -0700
+++ linux-2.6.22-rc6-mm1/lib/genalloc.c	2007-07-03 17:25:33.000000000 -0700
@@ -54,11 +54,10 @@ int gen_pool_add(struct gen_pool *pool, 
 	int nbytes = sizeof(struct gen_pool_chunk) +
 				(nbits + BITS_PER_BYTE - 1) / BITS_PER_BYTE;
 
-	chunk = kmalloc_node(nbytes, GFP_KERNEL, nid);
+	chunk = kmalloc_node(nbytes, GFP_KERNEL | __GFP_ZERO, nid);
 	if (unlikely(chunk == NULL))
 		return -1;
 
-	memset(chunk, 0, nbytes);
 	spin_lock_init(&chunk->lock);
 	chunk->start_addr = addr;
 	chunk->end_addr = addr + size;
Index: linux-2.6.22-rc6-mm1/mm/allocpercpu.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/mm/allocpercpu.c	2007-07-03 17:23:15.000000000 -0700
+++ linux-2.6.22-rc6-mm1/mm/allocpercpu.c	2007-07-03 17:25:33.000000000 -0700
@@ -53,12 +53,9 @@ void *percpu_populate(void *__pdata, siz
 	int node = cpu_to_node(cpu);
 
 	BUG_ON(pdata->ptrs[cpu]);
-	if (node_online(node)) {
-		/* FIXME: kzalloc_node(size, gfp, node) */
-		pdata->ptrs[cpu] = kmalloc_node(size, gfp, node);
-		if (pdata->ptrs[cpu])
-			memset(pdata->ptrs[cpu], 0, size);
-	} else
+	if (node_online(node))
+		pdata->ptrs[cpu] = kmalloc_node(size, gfp|__GFP_ZERO, node);
+	else
 		pdata->ptrs[cpu] = kzalloc(size, gfp);
 	return pdata->ptrs[cpu];
 }
Index: linux-2.6.22-rc6-mm1/mm/mempool.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/mm/mempool.c	2007-07-03 17:23:15.000000000 -0700
+++ linux-2.6.22-rc6-mm1/mm/mempool.c	2007-07-03 17:25:33.000000000 -0700
@@ -62,10 +62,9 @@ mempool_t *mempool_create_node(int min_n
 			mempool_free_t *free_fn, void *pool_data, int node_id)
 {
 	mempool_t *pool;
-	pool = kmalloc_node(sizeof(*pool), GFP_KERNEL, node_id);
+	pool = kmalloc_node(sizeof(*pool), GFP_KERNEL | __GFP_ZERO, node_id);
 	if (!pool)
 		return NULL;
-	memset(pool, 0, sizeof(*pool));
 	pool->elements = kmalloc_node(min_nr * sizeof(void *),
 					GFP_KERNEL, node_id);
 	if (!pool->elements) {
Index: linux-2.6.22-rc6-mm1/mm/vmalloc.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/mm/vmalloc.c	2007-07-03 17:23:15.000000000 -0700
+++ linux-2.6.22-rc6-mm1/mm/vmalloc.c	2007-07-03 17:25:33.000000000 -0700
@@ -434,11 +434,12 @@ void *__vmalloc_area_node(struct vm_stru
 	area->nr_pages = nr_pages;
 	/* Please note that the recursion is strictly bounded. */
 	if (array_size > PAGE_SIZE) {
-		pages = __vmalloc_node(array_size, gfp_mask, PAGE_KERNEL, node);
+		pages = __vmalloc_node(array_size, gfp_mask | __GFP_ZERO,
+					PAGE_KERNEL, node);
 		area->flags |= VM_VPAGES;
 	} else {
 		pages = kmalloc_node(array_size,
-				(gfp_mask & GFP_LEVEL_MASK),
+				(gfp_mask & GFP_LEVEL_MASK) | __GFP_ZERO,
 				node);
 	}
 	area->pages = pages;
@@ -447,7 +448,6 @@ void *__vmalloc_area_node(struct vm_stru
 		kfree(area);
 		return NULL;
 	}
-	memset(area->pages, 0, array_size);
 
 	for (i = 0; i < area->nr_pages; i++) {
 		if (node < 0)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
