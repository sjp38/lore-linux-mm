Received: from internal-mail-relay1.corp.sgi.com (internal-mail-relay1.corp.sgi.com [198.149.32.52])
	by omx2.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k4Q2LdkT012168
	for <linux-mm@kvack.org>; Thu, 25 May 2006 19:21:39 -0700
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by internal-mail-relay1.corp.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id k4Q02n8s7733820
	for <linux-mm@kvack.org>; Thu, 25 May 2006 17:02:49 -0700 (PDT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id k4Q02nnB38263370
	for <linux-mm@kvack.org>; Thu, 25 May 2006 17:02:49 -0700 (PDT)
Received: from christoph (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1FjPmz-00078i-00
	for <linux-mm@kvack.org>; Thu, 25 May 2006 17:02:49 -0700
Date: Thu, 25 May 2006 16:56:13 -0700 (PDT)
From: Christoph Lameter <christoph@engr.sgi.com>
Subject: Add /proc/sys/vm/drop_node_caches
Message-ID: <Pine.LNX.4.64.0605251653090.27354@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.64.0605251702430.27447@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

drop_node_caches works similar to drop_caches. It allows the dropping of 
all pagecache pages for a certain node in a NUMA system. Explicit clearing 
a node may be desirable to get consistent placement of pages and new 
pagecache pages or may be useful if zone reclaim is disabled.

This works by writing the node number for which to clear the pagecache
to /proc/sys/vm/drop_node_caches.

F.e. to clear the pagecache on node 3 do:

echo 3 >/proc/sys/vm/drop_node_caches

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc4-mm3/include/linux/swap.h
===================================================================
--- linux-2.6.17-rc4-mm3.orig/include/linux/swap.h	2006-05-23 15:10:22.012855010 -0700
+++ linux-2.6.17-rc4-mm3/include/linux/swap.h	2006-05-24 15:55:16.925742236 -0700
@@ -191,6 +191,7 @@ extern int remove_mapping(struct address
 extern int zone_reclaim_mode;
 extern int zone_reclaim_interval;
 extern int zone_reclaim(struct zone *, gfp_t, unsigned int);
+extern void drop_node_pagecache(int node);
 #else
 #define zone_reclaim_mode 0
 static inline int zone_reclaim(struct zone *z, gfp_t mask, unsigned int order)
Index: linux-2.6.17-rc4-mm3/mm/vmscan.c
===================================================================
--- linux-2.6.17-rc4-mm3.orig/mm/vmscan.c	2006-05-24 15:54:19.484968187 -0700
+++ linux-2.6.17-rc4-mm3/mm/vmscan.c	2006-05-25 13:29:03.617251720 -0700
@@ -1652,4 +1652,32 @@ int zone_reclaim(struct zone *zone, gfp_
 		return 0;
 	return __zone_reclaim(zone, gfp_mask, order);
 }
+
+/*
+ * Drop all unmapped pages from the indicated node.
+ */
+void drop_node_pagecache(int node) {
+	struct zone *zone;
+	struct scan_control sc = {
+		.may_writepage = 0,
+		.may_swap = 0,
+		.nr_mapped = read_page_state(nr_mapped),
+		.swap_cluster_max = SWAP_CLUSTER_MAX,
+		.gfp_mask = GFP_USER,
+		.swappiness = vm_swappiness,
+	};
+
+	disable_swap_token();
+	current->flags |= PF_MEMALLOC;
+	for (zone = NODE_DATA(node)->node_zones;
+		zone < NODE_DATA(node)->node_zones + MAX_NR_ZONES;
+		zone++) {
+
+		if (!populated_zone(zone) || zone->all_unreclaimable)
+			continue;
+
+		shrink_zone(0, zone, &sc);
+	}
+	current->flags &= ~PF_MEMALLOC;
+}
 #endif
Index: linux-2.6.17-rc4-mm3/fs/drop_caches.c
===================================================================
--- linux-2.6.17-rc4-mm3.orig/fs/drop_caches.c	2006-05-11 16:31:53.000000000 -0700
+++ linux-2.6.17-rc4-mm3/fs/drop_caches.c	2006-05-24 15:59:43.061583393 -0700
@@ -8,6 +8,7 @@
 #include <linux/writeback.h>
 #include <linux/sysctl.h>
 #include <linux/gfp.h>
+#include <linux/swap.h>
 
 /* A global variable is a bit ugly, but it keeps the code simple */
 int sysctl_drop_caches;
@@ -66,3 +67,20 @@ int drop_caches_sysctl_handler(ctl_table
 	}
 	return 0;
 }
+
+#ifdef CONFIG_NUMA
+int sysctl_drop_node_caches;
+
+int drop_node_caches_sysctl_handler(ctl_table *table, int write,
+	struct file *file, void __user *buffer, size_t *length, loff_t *ppos)
+{
+	proc_dointvec_minmax(table, write, file, buffer, length, ppos);
+
+	if (!node_online(sysctl_drop_node_caches))
+		return -ENODEV;
+
+	drop_node_pagecache(sysctl_drop_node_caches);
+	return 0;
+}
+#endif
+
Index: linux-2.6.17-rc4-mm3/kernel/sysctl.c
===================================================================
--- linux-2.6.17-rc4-mm3.orig/kernel/sysctl.c	2006-05-23 15:10:22.416150348 -0700
+++ linux-2.6.17-rc4-mm3/kernel/sysctl.c	2006-05-24 15:59:35.908706608 -0700
@@ -73,6 +73,7 @@ extern int printk_ratelimit_jiffies;
 extern int printk_ratelimit_burst;
 extern int pid_max_min, pid_max_max;
 extern int sysctl_drop_caches;
+extern int sysctl_drop_node_caches;
 extern int percpu_pagelist_fraction;
 extern int compat_log;
 extern int print_fatal_signals;
@@ -874,6 +875,17 @@ static ctl_table vm_table[] = {
 		.proc_handler	= drop_caches_sysctl_handler,
 		.strategy	= &sysctl_intvec,
 	},
+#ifdef CONFIG_NUMA
+	{
+		.ctl_name	= VM_DROP_NODE_CACHES,
+		.procname	= "drop_node_caches",
+		.data		= &sysctl_drop_node_caches,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= drop_node_caches_sysctl_handler,
+		.strategy	= &sysctl_intvec,
+	},
+#endif
 	{
 		.ctl_name	= VM_MIN_FREE_KBYTES,
 		.procname	= "min_free_kbytes",
Index: linux-2.6.17-rc4-mm3/include/linux/sysctl.h
===================================================================
--- linux-2.6.17-rc4-mm3.orig/include/linux/sysctl.h	2006-05-23 15:10:22.056797601 -0700
+++ linux-2.6.17-rc4-mm3/include/linux/sysctl.h	2006-05-24 15:56:44.819706081 -0700
@@ -194,6 +194,7 @@ enum
 	VM_ZONE_RECLAIM_INTERVAL=32, /* time period to wait after reclaim failure */
 	VM_PANIC_ON_OOM=33,	/* panic at out-of-memory */
 	VM_SWAP_PREFETCH=34,	/* swap prefetch */
+	VM_DROP_NODE_CACHES=35,	/* drop node pagecache */
 };
 
 /* CTL_NET names: */
Index: linux-2.6.17-rc4-mm3/include/linux/mm.h
===================================================================
--- linux-2.6.17-rc4-mm3.orig/include/linux/mm.h	2006-05-24 15:54:33.032956202 -0700
+++ linux-2.6.17-rc4-mm3/include/linux/mm.h	2006-05-24 15:59:22.354859542 -0700
@@ -1110,6 +1110,8 @@ int in_gate_area_no_task(unsigned long a
 
 int drop_caches_sysctl_handler(struct ctl_table *, int, struct file *,
 					void __user *, size_t *, loff_t *);
+int drop_node_caches_sysctl_handler(struct ctl_table *, int, struct file *,
+					void __user *, size_t *, loff_t *);
 unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
 			unsigned long lru_pages);
 void drop_pagecache(void);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
