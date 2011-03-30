Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B8B238D0047
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 01:32:47 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp01.au.ibm.com (8.14.4/8.13.1) with ESMTP id p2U5SoS7011720
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 16:28:50 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2U5WhCC2535536
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 16:32:43 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2U5Wg4D008301
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 16:32:43 +1100
Subject: [PATCH 3/3] Provide control over unmapped pages (v5)
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Wed, 30 Mar 2011 11:02:38 +0530
Message-ID: <20110330053129.8212.81574.stgit@localhost6.localdomain6>
In-Reply-To: <20110330052819.8212.1359.stgit@localhost6.localdomain6>
References: <20110330052819.8212.1359.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com

Changelog v4
1. Added documentation for max_unmapped_pages
2. Better #ifdef'ing of max_unmapped_pages and min_unmapped_pages

Changelog v2
1. Use a config option to enable the code (Andrew Morton)
2. Explain the magic tunables in the code or at-least attempt
   to explain them (General comment)
3. Hint uses of the boot parameter with unlikely (Andrew Morton)
4. Use better names (balanced is not a good naming convention)

Provide control using zone_reclaim() and a boot parameter. The
code reuses functionality from zone_reclaim() to isolate unmapped
pages and reclaim them as a priority, ahead of other mapped pages.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
Reviewed-by: Christoph Lameter <cl@linux.com>
---
 Documentation/kernel-parameters.txt |    8 +++
 Documentation/sysctl/vm.txt         |   19 +++++++-
 include/linux/mmzone.h              |    7 +++
 include/linux/swap.h                |   25 ++++++++--
 init/Kconfig                        |   12 +++++
 kernel/sysctl.c                     |   13 +++++
 mm/page_alloc.c                     |   29 ++++++++++++
 mm/vmscan.c                         |   88 +++++++++++++++++++++++++++++++++++
 8 files changed, 194 insertions(+), 7 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index d4e67a5..f522c34 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -2520,6 +2520,14 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			[X86]
 			Set unknown_nmi_panic=1 early on boot.
 
+	unmapped_page_control
+			[KNL] Available if CONFIG_UNMAPPED_PAGECACHE_CONTROL
+			is enabled. It controls the amount of unmapped memory
+			that is present in the system. This boot option plus
+			vm.min_unmapped_ratio (sysctl) provide granular control
+			over how much unmapped page cache can exist in the system
+			before kswapd starts reclaiming unmapped page cache pages.
+
 	usbcore.autosuspend=
 			[USB] The autosuspend time delay (in seconds) used
 			for newly-detected USB devices (default 2).  This
diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 30289fa..1c722f7 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -381,11 +381,14 @@ and may not be fast.
 
 min_unmapped_ratio:
 
-This is available only on NUMA kernels.
+This is available only on NUMA kernels or when unmapped page cache
+control is enabled.
 
 This is a percentage of the total pages in each zone. Zone reclaim will
 only occur if more than this percentage of pages are in a state that
-zone_reclaim_mode allows to be reclaimed.
+zone_reclaim_mode allows to be reclaimed. If unmapped page cache control
+is enabled, this is the minimum level to which the cache will be shrunk
+down to.
 
 If zone_reclaim_mode has the value 4 OR'd, then the percentage is compared
 against all file-backed unmapped pages including swapcache pages and tmpfs
@@ -396,6 +399,18 @@ The default is 1 percent.
 
 ==============================================================
 
+max_unmapped_ratio:
+
+This is available only when unmapped page cache control is enabled.
+
+This is a percentage of the total pages in each zone. Zone reclaim will
+only occur if more than this percentage of pages are in a state and
+unmapped page cache control is enabled.
+
+The default is 16 percent.
+
+==============================================================
+
 mmap_min_addr
 
 This file indicates the amount of address space  which a user process will
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 59cbed0..caa29ad 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -309,7 +309,12 @@ struct zone {
 	/*
 	 * zone reclaim becomes active if more unmapped pages exist.
 	 */
+#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL) || defined(CONFIG_NUMA)
 	unsigned long		min_unmapped_pages;
+#endif
+#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL)
+	unsigned long		max_unmapped_pages;
+#endif
 #ifdef CONFIG_NUMA
 	int node;
 	unsigned long		min_slab_pages;
@@ -776,6 +781,8 @@ int percpu_pagelist_fraction_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
 int sysctl_min_unmapped_ratio_sysctl_handler(struct ctl_table *, int,
 			void __user *, size_t *, loff_t *);
+int sysctl_max_unmapped_ratio_sysctl_handler(struct ctl_table *, int,
+			void __user *, size_t *, loff_t *);
 int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *, int,
 			void __user *, size_t *, loff_t *);
 
diff --git a/include/linux/swap.h b/include/linux/swap.h
index ce8f686..86cafc5 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -264,19 +264,36 @@ extern int vm_swappiness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
 extern long vm_total_pages;
 
+#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL) || defined(CONFIG_NUMA)
 extern int sysctl_min_unmapped_ratio;
+#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL)
+extern int sysctl_max_unmapped_ratio;
+#endif
+
 extern int zone_reclaim(struct zone *, gfp_t, unsigned int);
-#ifdef CONFIG_NUMA
-extern int zone_reclaim_mode;
-extern int sysctl_min_slab_ratio;
 #else
-#define zone_reclaim_mode 0
 static inline int zone_reclaim(struct zone *z, gfp_t mask, unsigned int order)
 {
 	return 0;
 }
 #endif
 
+#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL)
+extern bool should_reclaim_unmapped_pages(struct zone *zone);
+#else
+static inline bool should_reclaim_unmapped_pages(struct zone *zone)
+{
+	return false;
+}
+#endif
+
+#ifdef CONFIG_NUMA
+extern int zone_reclaim_mode;
+extern int sysctl_min_slab_ratio;
+#else
+#define zone_reclaim_mode 0
+#endif
+
 extern int page_evictable(struct page *page, struct vm_area_struct *vma);
 extern void scan_mapping_unevictable_pages(struct address_space *);
 
diff --git a/init/Kconfig b/init/Kconfig
index 41b2431..222b3af 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -811,6 +811,18 @@ config SCHED_AUTOGROUP
 config MM_OWNER
 	bool
 
+config UNMAPPED_PAGECACHE_CONTROL
+	bool "Provide control over unmapped page cache"
+	default n
+	help
+	  This option adds support for controlling unmapped page cache
+	  via a boot parameter (unmapped_page_control). The boot parameter
+	  with sysctl (vm.min_unmapped_ratio) control the total number
+	  of unmapped pages in the system. This feature is useful if
+	  you want to limit the amount of unmapped page cache or want
+	  to reduce page cache duplication in a virtualized environment.
+	  If unsure say 'N'
+
 config SYSFS_DEPRECATED
 	bool "Enable deprecated sysfs features to support old userspace tools"
 	depends on SYSFS
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index e3a8ce4..d9e77da 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1214,6 +1214,7 @@ static struct ctl_table vm_table[] = {
 		.proc_handler	= proc_dointvec_unsigned,
 	},
 #endif
+#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL) || defined(CONFIG_NUMA)
 	{
 		.procname	= "min_unmapped_ratio",
 		.data		= &sysctl_min_unmapped_ratio,
@@ -1223,6 +1224,18 @@ static struct ctl_table vm_table[] = {
 		.extra1		= &zero,
 		.extra2		= &one_hundred,
 	},
+#endif
+#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL)
+	{
+		.procname	= "max_unmapped_ratio",
+		.data		= &sysctl_max_unmapped_ratio,
+		.maxlen		= sizeof(sysctl_max_unmapped_ratio),
+		.mode		= 0644,
+		.proc_handler	= sysctl_max_unmapped_ratio_sysctl_handler,
+		.extra1		= &zero,
+		.extra2		= &one_hundred,
+	},
+#endif
 #ifdef CONFIG_NUMA
 	{
 		.procname	= "zone_reclaim_mode",
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1d32865..5b89e5b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1669,6 +1669,9 @@ zonelist_scan:
 			unsigned long mark;
 			int ret;
 
+			if (should_reclaim_unmapped_pages(zone))
+				wakeup_kswapd(zone, order, classzone_idx);
+
 			mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
 			if (zone_watermark_ok(zone, order, mark,
 				    classzone_idx, alloc_flags))
@@ -4249,8 +4252,14 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 
 		zone->spanned_pages = size;
 		zone->present_pages = realsize;
+#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL) || defined(CONFIG_NUMA)
 		zone->min_unmapped_pages = (realsize*sysctl_min_unmapped_ratio)
 						/ 100;
+#endif
+#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL)
+		zone->max_unmapped_pages = (realsize*sysctl_max_unmapped_ratio)
+						/ 100;
+#endif
 #ifdef CONFIG_NUMA
 		zone->node = nid;
 		zone->min_slab_pages = (realsize * sysctl_min_slab_ratio) / 100;
@@ -5157,6 +5166,7 @@ int min_free_kbytes_sysctl_handler(ctl_table *table, int write,
 	return 0;
 }
 
+#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL) || defined(CONFIG_NUMA)
 int sysctl_min_unmapped_ratio_sysctl_handler(ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
@@ -5173,6 +5183,25 @@ int sysctl_min_unmapped_ratio_sysctl_handler(ctl_table *table, int write,
 	return 0;
 }
 
+#endif
+#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL)
+int sysctl_max_unmapped_ratio_sysctl_handler(ctl_table *table, int write,
+	void __user *buffer, size_t *length, loff_t *ppos)
+{
+	struct zone *zone;
+	int rc;
+
+	rc = proc_dointvec_minmax(table, write, buffer, length, ppos);
+	if (rc)
+		return rc;
+
+	for_each_zone(zone)
+		zone->max_unmapped_pages = (zone->present_pages *
+				sysctl_max_unmapped_ratio) / 100;
+	return 0;
+}
+#endif
+
 #ifdef CONFIG_NUMA
 int sysctl_min_slab_ratio_sysctl_handler(ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5b24e74..bb06710 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -158,6 +158,29 @@ static DECLARE_RWSEM(shrinker_rwsem);
 #define scanning_global_lru(sc)	(1)
 #endif
 
+#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL)
+static void reclaim_unmapped_pages(int priority, struct zone *zone,
+						struct scan_control *sc);
+static int unmapped_page_control __read_mostly;
+
+static int __init unmapped_page_control_parm(char *str)
+{
+	unmapped_page_control = 1;
+	/*
+	 * XXX: Should we tweak swappiness here?
+	 */
+	return 1;
+}
+__setup("unmapped_page_control", unmapped_page_control_parm);
+
+#else /* !CONFIG_UNMAPPED_PAGECACHE_CONTROL */
+static inline void reclaim_unmapped_pages(int priority,
+				struct zone *zone, struct scan_control *sc)
+{
+	return 0;
+}
+#endif
+
 static struct zone_reclaim_stat *get_reclaim_stat(struct zone *zone,
 						  struct scan_control *sc)
 {
@@ -2371,6 +2394,12 @@ loop_again:
 				shrink_active_list(SWAP_CLUSTER_MAX, zone,
 							&sc, priority, 0);
 
+			/*
+			 * We do unmapped page reclaim once here and once
+			 * below, so that we don't lose out
+			 */
+			reclaim_unmapped_pages(priority, zone, &sc);
+
 			if (!zone_watermark_ok_safe(zone, order,
 					high_wmark_pages(zone), 0, 0)) {
 				end_zone = i;
@@ -2408,6 +2437,11 @@ loop_again:
 				continue;
 
 			sc.nr_scanned = 0;
+			/*
+			 * Reclaim unmapped pages upfront, this should be
+			 * really cheap
+			 */
+			reclaim_unmapped_pages(priority, zone, &sc);
 
 			/*
 			 * Call soft limit reclaim before calling shrink_zone.
@@ -2721,7 +2755,8 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 	}
 	if (!waitqueue_active(&pgdat->kswapd_wait))
 		return;
-	if (zone_watermark_ok_safe(zone, order, low_wmark_pages(zone), 0, 0))
+	if (zone_watermark_ok_safe(zone, order, low_wmark_pages(zone), 0, 0) &&
+		!should_reclaim_unmapped_pages(zone))
 		return;
 
 	trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone), order);
@@ -2874,6 +2909,7 @@ static int __init kswapd_init(void)
 
 module_init(kswapd_init)
 
+#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL) || defined(CONFIG_NUMA)
 /*
  * Zone reclaim mode
  *
@@ -2900,6 +2936,10 @@ int zone_reclaim_mode __read_mostly;
  */
 int sysctl_min_unmapped_ratio = 1;
 
+#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL)
+int sysctl_max_unmapped_ratio = 16;
+#endif
+
 /*
  * If the number of slab pages in a zone grows beyond this percentage then
  * slab reclaim needs to occur.
@@ -3094,6 +3134,52 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 
 	return ret;
 }
+#endif
+
+#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL)
+/*
+ * Routine to reclaim unmapped pages, inspired from the code under
+ * CONFIG_NUMA that does unmapped page and slab page control by keeping
+ * min_unmapped_pages in the zone. We currently reclaim just unmapped
+ * pages, slab control will come in soon, at which point this routine
+ * should be called reclaim cached pages
+ */
+void reclaim_unmapped_pages(int priority, struct zone *zone,
+						struct scan_control *sc)
+{
+	if (unlikely(unmapped_page_control) &&
+		(zone_unmapped_file_pages(zone) > zone->min_unmapped_pages)) {
+		struct scan_control nsc;
+		unsigned long nr_pages;
+
+		nsc = *sc;
+
+		nsc.swappiness = 0;
+		nsc.may_writepage = 0;
+		nsc.may_unmap = 0;
+		nsc.nr_reclaimed = 0;
+
+		nr_pages = zone_unmapped_file_pages(zone) -
+				zone->min_unmapped_pages;
+		/*
+		 * We don't want to be too aggressive with our
+		 * reclaim, it is our best effort to control
+		 * unmapped pages
+		 */
+		nr_pages >>= 3;
+
+		zone_reclaim_pages(zone, &nsc, nr_pages);
+	}
+}
+
+bool should_reclaim_unmapped_pages(struct zone *zone)
+{
+	if (unlikely(unmapped_page_control) &&
+		(zone_unmapped_file_pages(zone) > zone->max_unmapped_pages))
+		return true;
+	return false;
+}
+#endif
 
 /*
  * page_evictable - test whether a page is evictable

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
