Date: Thu, 12 May 2005 14:57:05 -0400
From: Martin Hicks <mort@sgi.com>
Subject: Re: [PATCH/RFC 0/4] VM: Manual and Automatic page cache reclaim
Message-ID: <20050512185705.GP19244@localhost>
References: <20050427150848.GR8018@localhost> <20050427233335.492d0b6f.akpm@osdl.org> <4277259C.6000207@engr.sgi.com> <20050503010846.508bbe62.akpm@osdl.org> <20050512185302.GO19244@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050512185302.GO19244@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Hicks <mort@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Ray Bryant <raybry@engr.sgi.com>, linux-mm@kvack.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Thu, May 12, 2005 at 02:53:02PM -0400, Martin Hicks wrote:
> 
> So, I did this as an exercise.  A few things came up:

and this time here's the patch.  Its against something like
2.6.12-rc3-mm3

mh

Index: linux-2.6.12-rc3/arch/ia64/kernel/entry.S
===================================================================
--- linux-2.6.12-rc3.orig/arch/ia64/kernel/entry.S	2005-05-12 10:07:56.000000000 -0700
+++ linux-2.6.12-rc3/arch/ia64/kernel/entry.S	2005-05-12 10:08:14.000000000 -0700
@@ -1573,7 +1573,7 @@ sys_call_table:
 	data8 sys_keyctl
 	data8 sys_ni_syscall
 	data8 sys_ni_syscall			// 1275
-	data8 sys_ni_syscall
+	data8 sys_set_zone_reclaim
 	data8 sys_ni_syscall
 	data8 sys_ni_syscall
 	data8 sys_ni_syscall
Index: linux-2.6.12-rc3/include/linux/mmzone.h
===================================================================
--- linux-2.6.12-rc3.orig/include/linux/mmzone.h	2005-05-12 10:07:56.000000000 -0700
+++ linux-2.6.12-rc3/include/linux/mmzone.h	2005-05-12 10:12:20.000000000 -0700
@@ -163,6 +163,12 @@ struct zone {
 	int temp_priority;
 	int prev_priority;
 
+	/*
+	 * Does the zone try to reclaim before giving allowing the allocator
+	 * to try the next zone?
+	 */
+	int reclaim_pages;
+	int reclaim_pages_failed;
 
 	ZONE_PADDING(_pad2_)
 	/* Rarely used or read-mostly fields */
Index: linux-2.6.12-rc3/include/linux/swap.h
===================================================================
--- linux-2.6.12-rc3.orig/include/linux/swap.h	2005-05-12 10:07:56.000000000 -0700
+++ linux-2.6.12-rc3/include/linux/swap.h	2005-05-12 10:08:14.000000000 -0700
@@ -173,6 +173,7 @@ extern void swap_setup(void);
 
 /* linux/mm/vmscan.c */
 extern int try_to_free_pages(struct zone **, unsigned int, unsigned int);
+extern int zone_reclaim(struct zone *, unsigned int, unsigned int);
 extern int shrink_all_memory(int);
 extern int vm_swappiness;
 
Index: linux-2.6.12-rc3/mm/page_alloc.c
===================================================================
--- linux-2.6.12-rc3.orig/mm/page_alloc.c	2005-05-12 10:07:56.000000000 -0700
+++ linux-2.6.12-rc3/mm/page_alloc.c	2005-05-12 10:13:30.000000000 -0700
@@ -349,6 +349,7 @@ free_pages_bulk(struct zone *zone, int c
 
 	spin_lock_irqsave(&zone->lock, flags);
 	zone->all_unreclaimable = 0;
+	zone->reclaim_pages_failed = 0;
 	zone->pages_scanned = 0;
 	while (!list_empty(list) && count--) {
 		page = list_entry(list->prev, struct page, lru);
@@ -761,14 +762,29 @@ __alloc_pages(unsigned int __nocast gfp_
  restart:
 	/* Go through the zonelist once, looking for a zone with enough free */
 	for (i = 0; (z = zones[i]) != NULL; i++) {
-
-		if (!zone_watermark_ok(z, order, z->pages_low,
-				       classzone_idx, 0, 0))
-			continue;
+		int do_reclaim = z->reclaim_pages;
 
 		if (!cpuset_zone_allowed(z))
 			continue;
 
+		/*
+		 * If the zone is to attempt early page reclaim hen this loop
+		 * will try to reclaim pages and check the watermark a second
+		 * time before giving up and falling back to the next zone.
+		 */
+	zone_reclaim_retry:
+		if (!zone_watermark_ok(z, order, z->pages_low,
+				       classzone_idx, 0, 0)) {
+			if (!do_reclaim)
+				continue;
+			else {
+				zone_reclaim(z, gfp_mask, order);
+				/* Only try reclaim once */
+				do_reclaim = 0;
+				goto zone_reclaim_retry;
+			}
+		}
+
 		page = buffered_rmqueue(z, order, gfp_mask);
 		if (page)
 			goto got_pg;
Index: linux-2.6.12-rc3/mm/vmscan.c
===================================================================
--- linux-2.6.12-rc3.orig/mm/vmscan.c	2005-05-12 10:07:56.000000000 -0700
+++ linux-2.6.12-rc3/mm/vmscan.c	2005-05-12 10:11:31.000000000 -0700
@@ -73,6 +73,7 @@ struct scan_control {
 	unsigned int gfp_mask;
 
 	int may_writepage;
+	int may_swap;
 
 	/* This context's SWAP_CLUSTER_MAX. If freeing memory for
 	 * suspend, we effectively ignore SWAP_CLUSTER_MAX.
@@ -414,7 +415,7 @@ static int shrink_list(struct list_head 
 		 * Anonymous process memory has backing store?
 		 * Try to allocate it some swap space here.
 		 */
-		if (PageAnon(page) && !PageSwapCache(page)) {
+		if (PageAnon(page) && !PageSwapCache(page) && sc->may_swap) {
 			void *cookie = page->mapping;
 			pgoff_t index = page->index;
 
@@ -944,6 +945,7 @@ int try_to_free_pages(struct zone **zone
 
 	sc.gfp_mask = gfp_mask;
 	sc.may_writepage = 0;
+	sc.may_swap = 1;
 
 	inc_page_state(allocstall);
 
@@ -1044,6 +1046,7 @@ loop_again:
 	total_reclaimed = 0;
 	sc.gfp_mask = GFP_KERNEL;
 	sc.may_writepage = 0;
+	sc.may_swap = 1;
 	sc.nr_mapped = read_page_state(nr_mapped);
 
 	inc_page_state(pageoutrun);
@@ -1335,3 +1338,69 @@ static int __init kswapd_init(void)
 }
 
 module_init(kswapd_init)
+
+
+/*
+ * Try to free up some pages from this zone through reclaim.
+ */
+int zone_reclaim(struct zone *zone, unsigned int gfp_mask, unsigned int order)
+{
+	struct scan_control sc;
+	int nr_pages = 1 << order;
+	int priority;
+	int total_reclaimed = 0;
+
+	/* The reclaim may sleep, so don't do it if sleep isn't allowed */
+	if (!(gfp_mask & __GFP_WAIT))
+		return 0;
+	if (zone->reclaim_pages_failed)
+		return 0;
+
+	sc.gfp_mask = gfp_mask;
+	sc.may_writepage = 0;
+	sc.may_swap = 0;
+	sc.nr_mapped = read_page_state(nr_mapped);
+	sc.nr_scanned = 0;
+	sc.nr_reclaimed = 0;
+	sc.priority = 0;  /* scan at the highest priority */
+
+	if (nr_pages > SWAP_CLUSTER_MAX)
+		sc.swap_cluster_max = nr_pages;
+	else
+		sc.swap_cluster_max = SWAP_CLUSTER_MAX;
+
+	shrink_zone(zone, &sc);
+
+	if (sc.nr_reclaimed < nr_pages)
+		zone->reclaim_pages_failed = 1;
+
+	return total_reclaimed;
+}
+
+asmlinkage long sys_set_zone_reclaim(unsigned int node, unsigned int zone,
+				     unsigned int state)
+{
+	struct zone *z;
+	int i;
+
+	if (node >= MAX_NUMNODES || !node_online(node))
+		return -EINVAL;
+
+	/* This will break if we ever add more zones */
+	if (!(zone & (1<<ZONE_DMA|1<<ZONE_NORMAL|1<<ZONE_HIGHMEM)))
+		return -EINVAL;
+
+	for (i = 0; i < MAX_NR_ZONES; i++) {
+		if (!(zone & 1<<i))
+			continue;
+
+		z = &NODE_DATA(node)->node_zones[i];
+
+		if (state)
+			z->reclaim_pages = 1;
+		else
+			z->reclaim_pages = 0;
+	}
+
+	return 0;
+}
Index: linux-2.6.12-rc3/kernel/sys_ni.c
===================================================================
--- linux-2.6.12-rc3.orig/kernel/sys_ni.c	2005-05-12 10:07:56.000000000 -0700
+++ linux-2.6.12-rc3/kernel/sys_ni.c	2005-05-12 10:09:18.000000000 -0700
@@ -77,6 +77,7 @@ cond_syscall(sys_request_key);
 cond_syscall(sys_keyctl);
 cond_syscall(compat_sys_keyctl);
 cond_syscall(compat_sys_socketcall);
+cond_syscall(sys_set_zone_reclaim);
 
 /* arch-specific weak syscall entries */
 cond_syscall(sys_pciconfig_read);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
