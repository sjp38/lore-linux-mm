Date: Fri, 11 May 2007 21:36:11 +0100
Subject: Re: [Bug 8464] New: autoreconf: page allocation failure. order:2, mode:0x84020
Message-ID: <20070511203610.GA12136@skynet.ie>
References: <20070510224441.GA15332@skynet.ie> <Pine.LNX.4.64.0705101547020.14064@schroedinger.engr.sgi.com> <20070510230044.GB15332@skynet.ie> <Pine.LNX.4.64.0705101601220.14471@schroedinger.engr.sgi.com> <1178863002.24635.4.camel@rousalka.dyndns.org> <20070511090823.GA29273@skynet.ie> <1178884283.27195.1.camel@rousalka.dyndns.org> <20070511173811.GA8529@skynet.ie> <1178905541.2473.2.camel@rousalka.dyndns.org> <1178908210.4360.21.camel@rousalka.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1178908210.4360.21.camel@rousalka.dyndns.org>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nicolas Mailhot <nicolas.mailhot@laposte.net>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "bugme-daemon@kernel-bugs.osdl.org" <bugme-daemon@bugzilla.kernel.org>
List-ID: <linux-mm.kvack.org>

On (11/05/07 20:30), Nicolas Mailhot didst pronounce:
> Le vendredi 11 mai 2007 a 19:45 +0200, Nicolas Mailhot a ecrit :
> > Le vendredi 11 mai 2007 a 18:38 +0100, Mel Gorman a ecrit :
> 
> > > so I'd like to look at the
> > > alternative option with kswapd as well. Could you put that patch back in again
> > > please and try the following patch instead? 
> > 
> > I'll try this one now (if it applies)
> 
> Well it doesn't seem to apply. Are you sure you have a clean tree?
> (I have vanilla mm2 + revert of
> md-improve-partition-detection-in-md-array.patch for another bug)
> 

I'm pretty sure I have. I recreated the tree and reverted the same patch as
you and regenerated the diff below. I sent it to myself and it appeared ok
and another automated system was able to use it.

In case it's a mailer problem, the patch can be downloaded from
http://www.csn.ul.ie/~mel/kswapd-minorder.patch . Here is a rediff
against the tree you describe.

Sorry for the confusion.

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-revertmd/include/linux/mmzone.h linux-2.6.21-mm2-kswapdorder/include/linux/mmzone.h
--- linux-2.6.21-mm2-revertmd/include/linux/mmzone.h	2007-05-11 21:16:56.000000000 +0100
+++ linux-2.6.21-mm2-kswapdorder/include/linux/mmzone.h	2007-05-11 21:23:00.000000000 +0100
@@ -499,6 +499,8 @@ typedef struct pglist_data {
 void get_zone_counts(unsigned long *active, unsigned long *inactive,
 			unsigned long *free);
 void build_all_zonelists(void);
+int kswapd_order(unsigned int order);
+void set_kswapd_order(unsigned int order);
 void wakeup_kswapd(struct zone *zone, int order);
 int zone_watermark_ok(struct zone *z, int order, unsigned long mark,
 		int classzone_idx, int alloc_flags);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-revertmd/mm/slub.c linux-2.6.21-mm2-kswapdorder/mm/slub.c
--- linux-2.6.21-mm2-revertmd/mm/slub.c	2007-05-11 21:16:57.000000000 +0100
+++ linux-2.6.21-mm2-kswapdorder/mm/slub.c	2007-05-11 21:23:00.000000000 +0100
@@ -2131,6 +2131,7 @@ static struct kmem_cache *kmalloc_caches
 static int __init setup_slub_min_order(char *str)
 {
 	get_option (&str, &slub_min_order);
+	set_kswapd_order(slub_min_order);
 	user_override = 1;
 	return 1;
 }
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-revertmd/mm/vmscan.c linux-2.6.21-mm2-kswapdorder/mm/vmscan.c
--- linux-2.6.21-mm2-revertmd/mm/vmscan.c	2007-05-11 21:16:57.000000000 +0100
+++ linux-2.6.21-mm2-kswapdorder/mm/vmscan.c	2007-05-11 21:23:00.000000000 +0100
@@ -1407,6 +1407,32 @@ out:
 	return nr_reclaimed;
 }
 
+static unsigned int kswapd_min_order __read_mostly;
+
+/**
+ * set_kswapd_order - Set the minimum order that kswapd reclaims at
+ * @order: The new minimum order
+ *
+ * kswapd normally reclaims at order 0 unless there is a higher-order
+ * allocation under way. However, in some cases, it is known that there
+ * are a minimum order size of general interest such as the SLUB allocator
+ * requiring regular high-order allocations. This allows a minimum order
+ * to be set to that min_free_kbytes is kept at higher orders
+ */
+void set_kswapd_order(unsigned int order)
+{
+	if (order >= MAX_ORDER)
+		return;
+	
+	printk(KERN_INFO "kswapd reclaim order set to %d\n", order);
+	kswapd_min_order = order;
+}
+	
+int kswapd_order(unsigned int order)
+{
+	return max(kswapd_min_order, order);
+}
+
 /*
  * The background pageout daemon, started as a kernel thread
  * from the init process. 
@@ -1450,13 +1476,13 @@ static int kswapd(void *p)
 	 */
 	tsk->flags |= PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD;
 
-	order = 0;
+	order = kswapd_order(0);
 	for ( ; ; ) {
 		unsigned long new_order;
 
 		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
-		new_order = pgdat->kswapd_max_order;
-		pgdat->kswapd_max_order = 0;
+		new_order = kswapd_order(pgdat->kswapd_max_order);
+		pgdat->kswapd_max_order = kswapd_order(0);
 		if (order < new_order) {
 			/*
 			 * Don't sleep if someone wants a larger 'order'
@@ -1467,7 +1493,7 @@ static int kswapd(void *p)
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
