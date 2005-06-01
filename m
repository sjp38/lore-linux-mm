Date: Wed, 1 Jun 2005 10:23:01 -0400
From: Martin Hicks <mort@sgi.com>
Subject: [PATCH 2/4] VM: early zone reclaim
Message-ID: <20050601142301.GU14894@localhost>
References: <20050601141154.GN14894@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050601141154.GN14894@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
Cc: Ray Bryant <raybry@engr.sgi.com>
List-ID: <linux-mm.kvack.org>

This is the core of the (much simplified) early reclaim.  The goal of
this patch is to reclaim some easily-freed pages from a zone before
falling back onto another zone.

One of the major uses of this is NUMA machines.  With the default
allocator behavior the allocator would look for memory in another
zone, which might be off-node, before trying to reclaim from the
current zone.

This adds a zone tuneable to enable early zone reclaim.  It is selected
on a per-zone basis and is turned on/off via syscall.

Signed-off-by: Martin Hicks <mort@sgi.com>

 arch/i386/kernel/syscall_table.S |    2 -
 arch/ia64/kernel/entry.S         |    2 -
 include/asm-i386/unistd.h        |    2 -
 include/asm-ia64/unistd.h        |    1 
 include/linux/mmzone.h           |    6 +++
 include/linux/swap.h             |    1 
 kernel/sys_ni.c                  |    1 
 mm/page_alloc.c                  |   31 ++++++++++++++++--
 mm/vmscan.c                      |   64 +++++++++++++++++++++++++++++++++++++++
 9 files changed, 103 insertions(+), 7 deletions(-)

Index: linux-2.6.12-rc5-mm1/arch/ia64/kernel/entry.S
===================================================================
--- linux-2.6.12-rc5-mm1.orig/arch/ia64/kernel/entry.S	2005-05-26 12:26:59.000000000 -0700
+++ linux-2.6.12-rc5-mm1/arch/ia64/kernel/entry.S	2005-05-26 12:27:11.000000000 -0700
@@ -1573,7 +1573,7 @@ sys_call_table:
 	data8 sys_keyctl
 	data8 sys_ni_syscall
 	data8 sys_ni_syscall			// 1275
-	data8 sys_ni_syscall
+	data8 sys_set_zone_reclaim
 	data8 sys_ni_syscall
 	data8 sys_ni_syscall
 	data8 sys_ni_syscall
Index: linux-2.6.12-rc5-mm1/include/linux/mmzone.h
===================================================================
--- linux-2.6.12-rc5-mm1.orig/include/linux/mmzone.h	2005-05-26 12:26:59.000000000 -0700
+++ linux-2.6.12-rc5-mm1/include/linux/mmzone.h	2005-05-26 12:27:11.000000000 -0700
@@ -145,6 +145,12 @@ struct zone {
 	int			all_unreclaimable; /* All pages pinned */
 
 	/*
+	 * Does the allocator try to reclaim pages from the zone as soon
+	 * as it fails a watermark_ok() in __alloc_pages?
+	 */
+	int			reclaim_pages;
+
+	/*
 	 * prev_priority holds the scanning priority for this zone.  It is
 	 * defined as the scanning priority at which we achieved our reclaim
 	 * target at the previous try_to_free_pages() or balance_pgdat()
Index: linux-2.6.12-rc5-mm1/include/linux/swap.h
===================================================================
--- linux-2.6.12-rc5-mm1.orig/include/linux/swap.h	2005-05-26 12:26:59.000000000 -0700
+++ linux-2.6.12-rc5-mm1/include/linux/swap.h	2005-05-26 12:27:11.000000000 -0700
@@ -173,6 +173,7 @@ extern void swap_setup(void);
 
 /* linux/mm/vmscan.c */
 extern int try_to_free_pages(struct zone **, unsigned int, unsigned int);
+extern int zone_reclaim(struct zone *, unsigned int, unsigned int);
 extern int shrink_all_memory(int);
 extern int vm_swappiness;
 
Index: linux-2.6.12-rc5-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.12-rc5-mm1.orig/mm/page_alloc.c	2005-05-26 12:26:59.000000000 -0700
+++ linux-2.6.12-rc5-mm1/mm/page_alloc.c	2005-05-26 12:27:11.000000000 -0700
@@ -724,6 +724,14 @@ int zone_watermark_ok(struct zone *z, in
 	return 1;
 }
 
+static inline int
+check_zone_reclaim(struct zone *z, unsigned int gfp_mask)
+{
+	if (!z->reclaim_pages)
+		return 0;
+	return 1;
+}
+
 /*
  * This is the 'heart' of the zoned buddy allocator.
  */
@@ -763,14 +771,29 @@ __alloc_pages(unsigned int __nocast gfp_
  restart:
 	/* Go through the zonelist once, looking for a zone with enough free */
 	for (i = 0; (z = zones[i]) != NULL; i++) {
-
-		if (!zone_watermark_ok(z, order, z->pages_low,
-				       classzone_idx, 0, 0))
-			continue;
+		int do_reclaim = check_zone_reclaim(z, gfp_mask);
 
 		if (!cpuset_zone_allowed(z))
 			continue;
 
+		/*
+		 * If the zone is to attempt early page reclaim then this loop
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
Index: linux-2.6.12-rc5-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.12-rc5-mm1.orig/mm/vmscan.c	2005-05-26 12:27:05.000000000 -0700
+++ linux-2.6.12-rc5-mm1/mm/vmscan.c	2005-05-26 12:27:11.000000000 -0700
@@ -1326,3 +1326,67 @@ static int __init kswapd_init(void)
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
+	int total_reclaimed = 0;
+
+	/* The reclaim may sleep, so don't do it if sleep isn't allowed */
+	if (!(gfp_mask & __GFP_WAIT))
+		return 0;
+	if (zone->all_unreclaimable)
+		return 0;
+
+	sc.gfp_mask = gfp_mask;
+	sc.may_writepage = 0;
+	sc.may_swap = 0;
+	sc.nr_mapped = read_page_state(nr_mapped);
+	sc.nr_scanned = 0;
+	sc.nr_reclaimed = 0;
+	/* scan at the highest priority */
+	sc.priority = 0;
+
+	if (nr_pages > SWAP_CLUSTER_MAX)
+		sc.swap_cluster_max = nr_pages;
+	else
+		sc.swap_cluster_max = SWAP_CLUSTER_MAX;
+
+	shrink_zone(zone, &sc);
+	total_reclaimed = sc.nr_reclaimed;
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
Index: linux-2.6.12-rc5-mm1/kernel/sys_ni.c
===================================================================
--- linux-2.6.12-rc5-mm1.orig/kernel/sys_ni.c	2005-05-26 12:26:59.000000000 -0700
+++ linux-2.6.12-rc5-mm1/kernel/sys_ni.c	2005-05-26 12:27:11.000000000 -0700
@@ -77,6 +77,7 @@ cond_syscall(sys_request_key);
 cond_syscall(sys_keyctl);
 cond_syscall(compat_sys_keyctl);
 cond_syscall(compat_sys_socketcall);
+cond_syscall(sys_set_zone_reclaim);
 
 /* arch-specific weak syscall entries */
 cond_syscall(sys_pciconfig_read);
Index: linux-2.6.12-rc5-mm1/include/asm-i386/unistd.h
===================================================================
--- linux-2.6.12-rc5-mm1.orig/include/asm-i386/unistd.h	2005-05-26 12:26:59.000000000 -0700
+++ linux-2.6.12-rc5-mm1/include/asm-i386/unistd.h	2005-05-26 12:27:11.000000000 -0700
@@ -256,7 +256,7 @@
 #define __NR_io_submit		248
 #define __NR_io_cancel		249
 #define __NR_fadvise64		250
-
+#define __NR_set_zone_reclaim	251
 #define __NR_exit_group		252
 #define __NR_lookup_dcookie	253
 #define __NR_epoll_create	254
Index: linux-2.6.12-rc5-mm1/include/asm-ia64/unistd.h
===================================================================
--- linux-2.6.12-rc5-mm1.orig/include/asm-ia64/unistd.h	2005-05-26 12:26:59.000000000 -0700
+++ linux-2.6.12-rc5-mm1/include/asm-ia64/unistd.h	2005-05-26 12:27:11.000000000 -0700
@@ -263,6 +263,7 @@
 #define __NR_add_key			1271
 #define __NR_request_key		1272
 #define __NR_keyctl			1273
+#define __NR_set_zone_reclaim		1276
 
 #ifdef __KERNEL__
 
Index: linux-2.6.12-rc5-mm1/arch/i386/kernel/syscall_table.S
===================================================================
--- linux-2.6.12-rc5-mm1.orig/arch/i386/kernel/syscall_table.S	2005-05-26 12:26:59.000000000 -0700
+++ linux-2.6.12-rc5-mm1/arch/i386/kernel/syscall_table.S	2005-05-26 12:27:11.000000000 -0700
@@ -251,7 +251,7 @@ ENTRY(sys_call_table)
 	.long sys_io_submit
 	.long sys_io_cancel
 	.long sys_fadvise64	/* 250 */
-	.long sys_ni_syscall
+	.long sys_set_zone_reclaim
 	.long sys_exit_group
 	.long sys_lookup_dcookie
 	.long sys_epoll_create
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
