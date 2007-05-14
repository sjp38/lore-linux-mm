Date: Mon, 14 May 2007 19:24:56 +0100
Subject: Re: [PATCH 1/2] Have kswapd keep a minimum order free other than order-0
Message-ID: <20070514182456.GA9006@skynet.ie>
References: <20070514173218.6787.56089.sendpatchset@skynet.skynet.ie> <20070514173238.6787.57003.sendpatchset@skynet.skynet.ie> <Pine.LNX.4.64.0705141058590.11319@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0705141111400.11411@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705141111400.11411@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: apw@shadowen.org, nicolas.mailhot@laposte.net, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (14/05/07 11:13), Christoph Lameter didst pronounce:
> I think the slub fragment may have to be this way? This calls 
> raise_kswapd_order on each kmem_cache_create with the order of the cache 
> that was created thus insuring that the min_order is correctly.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 

Good plan. Revised patch as follows;


kswapd normally reclaims at order 0 unless there is a higher-order allocation
currently being serviced. However, in some cases it is known that there is a
minimum order size that is generally required such as when SLUB is configured
to use higher orders for performance reasons.  This patch allows a minumum
order to be set, such that min_free_kbytes pages are kept at higher orders.
This depends on lumpy-reclaim to work.

[clameter@sgi.com: Call raise_kswapd_order() on kmem_cache_open()]
Acked-by: Andy Whitcroft <apw@shadowen.org>

---
 include/linux/mmzone.h |    1 +
 mm/slub.c              |    1 +
 mm/vmscan.c            |   34 +++++++++++++++++++++++++++++++---
 3 files changed, 33 insertions(+), 3 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-clean/include/linux/mmzone.h linux-2.6.21-mm2-001_kswapd_minorder/include/linux/mmzone.h
--- linux-2.6.21-mm2-clean/include/linux/mmzone.h	2007-05-11 21:16:11.000000000 +0100
+++ linux-2.6.21-mm2-001_kswapd_minorder/include/linux/mmzone.h	2007-05-14 19:04:48.000000000 +0100
@@ -499,6 +499,7 @@ typedef struct pglist_data {
 void get_zone_counts(unsigned long *active, unsigned long *inactive,
 			unsigned long *free);
 void build_all_zonelists(void);
+void raise_kswapd_order(unsigned int order);
 void wakeup_kswapd(struct zone *zone, int order);
 int zone_watermark_ok(struct zone *z, int order, unsigned long mark,
 		int classzone_idx, int alloc_flags);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-clean/mm/slub.c linux-2.6.21-mm2-001_kswapd_minorder/mm/slub.c
--- linux-2.6.21-mm2-clean/mm/slub.c	2007-05-11 21:16:11.000000000 +0100
+++ linux-2.6.21-mm2-001_kswapd_minorder/mm/slub.c	2007-05-14 19:20:23.000000000 +0100
@@ -2001,6 +2001,7 @@ static int kmem_cache_open(struct kmem_c
 #ifdef CONFIG_NUMA
 	s->defrag_ratio = 100;
 #endif
+	raise_kswapd_order(s->order);
 
 	if (init_kmem_cache_nodes(s, gfpflags & ~SLUB_DMA))
 		return 1;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-clean/mm/vmscan.c linux-2.6.21-mm2-001_kswapd_minorder/mm/vmscan.c
--- linux-2.6.21-mm2-clean/mm/vmscan.c	2007-05-11 21:16:11.000000000 +0100
+++ linux-2.6.21-mm2-001_kswapd_minorder/mm/vmscan.c	2007-05-14 19:04:48.000000000 +0100
@@ -1407,6 +1407,34 @@ out:
 	return nr_reclaimed;
 }
 
+static unsigned int kswapd_min_order __read_mostly;
+
+static inline int kswapd_order(unsigned int order)
+{
+	return max(kswapd_min_order, order);
+}
+
+/**
+ * raise_kswapd_order - Raise the minimum order that kswapd reclaims
+ * @order: The minimum order kswapd should reclaim at
+ *
+ * kswapd normally reclaims at order 0 unless there is a higher-order
+ * allocation being serviced. This function is used to set the minimum
+ * order that kswapd reclaims at when it is known there will be regular
+ * high-order allocations at a given order.
+ */
+void raise_kswapd_order(unsigned int order)
+{
+	if (order >= MAX_ORDER)
+		return;
+
+	/* Update order if necessary and inform if changed */
+	if (order > kswapd_min_order) {
+		kswapd_min_order = order;
+		printk(KERN_INFO "kswapd reclaim order set to %d\n", order);
+	}
+}
+
 /*
  * The background pageout daemon, started as a kernel thread
  * from the init process. 
@@ -1450,12 +1478,12 @@ static int kswapd(void *p)
 	 */
 	tsk->flags |= PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD;
 
-	order = 0;
+	order = kswapd_order(0);
 	for ( ; ; ) {
 		unsigned long new_order;
 
 		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
-		new_order = pgdat->kswapd_max_order;
+		new_order = kswapd_order(pgdat->kswapd_max_order);
 		pgdat->kswapd_max_order = 0;
 		if (order < new_order) {
 			/*
@@ -1467,7 +1495,7 @@ static int kswapd(void *p)
 			if (!freezing(current))
 				schedule();
 
-			order = pgdat->kswapd_max_order;
+			order = kswapd_order(pgdat->kswapd_max_order);
 		}
 		finish_wait(&pgdat->kswapd_wait, &wait);
 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
