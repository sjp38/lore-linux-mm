From: KUROSAWA Takahiro <kurosawa@valinux.co.jp>
Message-Id: <20060131023035.7915.47645.sendpatchset@debian>
In-Reply-To: <20060131023000.7915.71955.sendpatchset@debian>
References: <20060131023000.7915.71955.sendpatchset@debian>
Subject: [PATCH 7/8] Make the number of pages in pzones resizable
Date: Tue, 31 Jan 2006 11:30:35 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ckrm-tech@lists.sourceforge.net
Cc: linux-mm@kvack.org, KUROSAWA Takahiro <kurosawa@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

This patch makes the number of pages in the pzones resizable by adding
the pzone_set_numpages() function.

Signed-off-by: KUROSAWA Takahiro <kurosawa@valinux.co.jp>

---
 include/linux/mmzone.h |    1 
 mm/page_alloc.c        |  111 +++++++++++++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c            |   29 ++++++++++++
 3 files changed, 141 insertions(+)

diff -urNp a/include/linux/mmzone.h b/include/linux/mmzone.h
--- a/include/linux/mmzone.h	2006-01-27 15:30:45.000000000 +0900
+++ b/include/linux/mmzone.h	2006-01-27 15:14:37.000000000 +0900
@@ -363,6 +363,7 @@ extern struct pzone_table pzone_table[];
 
 struct zone *pzone_create(struct zone *z, char *name, int npages);
 void pzone_destroy(struct zone *z);
+int pzone_set_numpages(struct zone *z, int npages);
 
 static inline void zone_init_pzone_link(struct zone *z)
 {
diff -urNp a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c	2006-01-27 15:29:03.000000000 +0900
+++ b/mm/page_alloc.c	2006-01-27 15:14:37.000000000 +0900
@@ -3228,6 +3228,117 @@ retry:
 	setup_per_zone_lowmem_reserve();
 }
 
+extern int shrink_zone_memory(struct zone *zone, int nr_pages);
+
+static int pzone_move_free_pages(struct zone *dst, struct zone *src,
+					int npages)
+{
+	struct zonelist zonelist;
+	struct list_head pagelist;
+	struct page *page;
+	unsigned long flags;
+	int err;
+	int i;
+
+	err = 0;
+	spin_lock_irqsave(&src->lock, flags);
+	if (npages > src->present_pages)
+		err = -ENOMEM;
+	spin_unlock_irqrestore(&src->lock, flags);
+	if (err)
+		return err;
+
+	smp_call_function(pzone_flush_percpu, src, 0, 1);
+	pzone_flush_percpu(src);
+
+	INIT_LIST_HEAD(&pagelist);
+	memset(&zonelist, 0, sizeof(zonelist));
+	zonelist.zones[0] = src;
+	for (i = 0; i < npages; i++) {
+		/*
+		 * XXX to prevent myself from being arrested by oom-killer...
+		 *     should be replaced to the cleaner code.
+		 */
+		if (src->free_pages < npages - i) {
+			shrink_zone_memory(src, npages - i);
+			smp_call_function(pzone_flush_percpu, src, 0, 1);
+			pzone_flush_percpu(src);
+			blk_congestion_wait(WRITE, HZ/50);
+		}
+
+		page = __alloc_pages(GFP_KERNEL, 0, &zonelist);
+		if (!page) {
+			err = -ENOMEM;
+			goto bad;
+		}
+		list_add(&page->lru, &pagelist);
+	}
+
+	while (!list_empty(&pagelist)) {
+		page = list_entry(pagelist.next, struct page, lru);
+		list_del(&page->lru);
+		if (zone_is_pseudo(dst))
+			pzone_setup_page_flags(dst, page);
+		else
+			pzone_restore_page_flags(dst, page);
+
+		set_page_count(page, 1);
+		spin_lock_irqsave(&dst->lock, flags);
+		dst->present_pages++;
+		spin_unlock_irqrestore(&dst->lock, flags);
+		__free_pages(page, 0);
+	}
+
+	spin_lock_irqsave(&src->lock, flags);
+	src->present_pages -= npages;
+	spin_unlock_irqrestore(&src->lock, flags);
+
+	return 0;
+bad:
+	while (!list_empty(&pagelist)) {
+		page = list_entry(pagelist.next, struct page, lru);
+		list_del(&page->lru);
+		__free_pages(page, 0);
+	}
+
+	return err;
+}
+
+int pzone_set_numpages(struct zone *z, int npages)
+{
+	struct zone *src, *dst;
+	unsigned long flags;
+	int err;
+	int n;
+
+	/*
+	 * This function must not be called simultaneously so far.
+	 * The caller should make sure that.
+	 */
+	if (z->present_pages == npages) {
+		return 0;
+	} else if (z->present_pages > npages) {
+		n = z->present_pages - npages;
+		src = z;
+		dst = z->parent;
+	} else {
+		n = npages - z->present_pages;
+		src = z->parent;
+		dst = z;
+	}
+
+	/* XXX  Preventing oom-killer from complaining */
+	spin_lock_irqsave(&z->lock, flags);
+	z->pages_min = z->pages_low = z->pages_high = 0;
+	spin_unlock_irqrestore(&z->lock, flags);
+
+	err = pzone_move_free_pages(dst, src, n);
+	setup_per_zone_pages_min();
+	setup_per_zone_lowmem_reserve();
+
+	return err;
+}
+
 static int pzone_init(void)
 {
 	struct work_struct *wp;
diff -urNp a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c	2006-01-27 15:29:03.000000000 +0900
+++ b/mm/vmscan.c	2006-01-27 15:14:37.000000000 +0900
@@ -1328,6 +1328,35 @@ int shrink_all_memory(int nr_pages)
 }
 #endif
 
+#ifdef CONFIG_PSEUDO_ZONE
+int shrink_zone_memory(struct zone *zone, int nr_pages)
+{
+	struct scan_control sc;
+
+	sc.gfp_mask = GFP_KERNEL;
+	sc.may_writepage = 1;
+	sc.may_swap = 1;
+	sc.nr_mapped = read_page_state(nr_mapped);
+	sc.nr_scanned = 0;
+	sc.nr_reclaimed = 0;
+	sc.priority = 0;
+
+	if (nr_pages < SWAP_CLUSTER_MAX)
+		sc.swap_cluster_max = nr_pages;
+	else
+		sc.swap_cluster_max = SWAP_CLUSTER_MAX;
+
+	sc.nr_to_reclaim = sc.swap_cluster_max;
+	sc.nr_to_scan = sc.swap_cluster_max;
+	sc.nr_mapped = total_memory;	/* XXX  to make vmscan aggressive */
+	refill_inactive_zone(zone, &sc);
+	sc.nr_to_scan = sc.swap_cluster_max;
+	shrink_cache(zone, &sc);
+
+	return sc.nr_reclaimed;
+}
+#endif
+
 #ifdef CONFIG_HOTPLUG_CPU
 /* It's optimal to keep kswapds on the same CPUs as their memory, but
    not required for correctness.  So if the last cpu in a node goes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
