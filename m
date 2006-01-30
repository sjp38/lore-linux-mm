Received: from internal-mail-relay1.corp.sgi.com (internal-mail-relay1.corp.sgi.com [198.149.32.52])
	by omx2.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k0UMNdkk002545
	for <linux-mm@kvack.org>; Mon, 30 Jan 2006 14:23:39 -0800
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by internal-mail-relay1.corp.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id k0UKPSo3100029383
	for <linux-mm@kvack.org>; Mon, 30 Jan 2006 12:25:28 -0800 (PST)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id k0UKLhOT21177734
	for <linux-mm@kvack.org>; Mon, 30 Jan 2006 12:21:43 -0800 (PST)
Date: Mon, 30 Jan 2006 12:19:44 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: [PATCH] zone_reclaim: configurable off node allocation period.
Message-ID: <Pine.LNX.4.62.0601301219001.4821@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.62.0601301221370.4821@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Currently the zone_reclaim code has a fixed window of 30 seconds of
off node allocations should a local zone have no unused pagecache pages left.
Reclaim will be attempted again after this timeout period to avoid repeated
useless scans for memory. This is also useful to established sufficiently large
off node allocation chunks to relieve the local node.

It may be beneficial to adjust that time period for some special situations.
For example if memory use was exceeding node capacity one may want to give
up for longer periods of time. If memory spikes intermittendly then one may
want to shorten the time period to reduce the number of off node allocations.

This patch allows just that....

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16-rc1-mm4/include/linux/swap.h
===================================================================
--- linux-2.6.16-rc1-mm4.orig/include/linux/swap.h	2006-01-30 11:27:37.000000000 -0800
+++ linux-2.6.16-rc1-mm4/include/linux/swap.h	2006-01-30 11:31:18.000000000 -0800
@@ -178,6 +178,7 @@ extern int vm_swappiness;
 
 #ifdef CONFIG_NUMA
 extern int zone_reclaim_mode;
+extern int zone_reclaim_interval;
 extern int zone_reclaim(struct zone *, gfp_t, unsigned int);
 #else
 #define zone_reclaim_mode 0
Index: linux-2.6.16-rc1-mm4/mm/vmscan.c
===================================================================
--- linux-2.6.16-rc1-mm4.orig/mm/vmscan.c	2006-01-30 11:27:37.000000000 -0800
+++ linux-2.6.16-rc1-mm4/mm/vmscan.c	2006-01-30 11:31:31.000000000 -0800
@@ -1834,7 +1834,7 @@ int zone_reclaim_mode __read_mostly;
 /*
  * Mininum time between zone reclaim scans
  */
-#define ZONE_RECLAIM_INTERVAL 30*HZ
+int zone_reclaim_interval __read_mostly = 30*HZ;
 
 /*
  * Priority for ZONE_RECLAIM. This determines the fraction of pages
@@ -1856,7 +1856,7 @@ int zone_reclaim(struct zone *zone, gfp_
 	int node_id;
 
 	if (time_before(jiffies,
-		zone->last_unsuccessful_zone_reclaim + ZONE_RECLAIM_INTERVAL))
+		zone->last_unsuccessful_zone_reclaim + zone_reclaim_interval))
 			return 0;
 
 	if (!(gfp_mask & __GFP_WAIT) ||
Index: linux-2.6.16-rc1-mm4/Documentation/sysctl/vm.txt
===================================================================
--- linux-2.6.16-rc1-mm4.orig/Documentation/sysctl/vm.txt	2006-01-30 11:27:34.000000000 -0800
+++ linux-2.6.16-rc1-mm4/Documentation/sysctl/vm.txt	2006-01-30 12:13:33.000000000 -0800
@@ -28,6 +28,7 @@ Currently, these files are in /proc/sys/
 - block_dump
 - drop-caches
 - zone_reclaim_mode
+- zone_reclaim_interval
 
 ==============================================================
 
@@ -137,4 +138,15 @@ of memory should be used for caching fil
 
 It may be beneficial to switch this on if one wants to do zone
 reclaim regardless of the numa distances in the system.
+================================================================
+
+zone_reclaim_interval:
+
+The time allowed for off node allocations after zone reclaim
+has failed to reclaim enough pages to allow a local allocation.
+
+Time is set in seconds and set by default to 30 seconds.
+
+Reduce the interval if undesired off node allocations occur. However, too
+frequent scans will have a negative impact onoff node allocation performance.
 
Index: linux-2.6.16-rc1-mm4/kernel/sysctl.c
===================================================================
--- linux-2.6.16-rc1-mm4.orig/kernel/sysctl.c	2006-01-30 11:27:37.000000000 -0800
+++ linux-2.6.16-rc1-mm4/kernel/sysctl.c	2006-01-30 11:31:18.000000000 -0800
@@ -888,6 +888,15 @@ static ctl_table vm_table[] = {
 		.strategy	= &sysctl_intvec,
 		.extra1		= &zero,
 	},
+	{
+		.ctl_name	= VM_ZONE_RECLAIM_INTERVAL,
+		.procname	= "zone_reclaim_interval",
+		.data		= &zone_reclaim_interval,
+		.maxlen		= sizeof(zone_reclaim_interval),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_jiffies,
+		.strategy	= &sysctl_jiffies,
+	},
 #endif
 	{ .ctl_name = 0 }
 };
Index: linux-2.6.16-rc1-mm4/include/linux/sysctl.h
===================================================================
--- linux-2.6.16-rc1-mm4.orig/include/linux/sysctl.h	2006-01-30 11:27:37.000000000 -0800
+++ linux-2.6.16-rc1-mm4/include/linux/sysctl.h	2006-01-30 11:35:20.000000000 -0800
@@ -183,7 +183,8 @@ enum
 	VM_SWAP_TOKEN_TIMEOUT=28, /* default time for token time out */
 	VM_DROP_PAGECACHE=29,	/* int: nuke lots of pagecache */
 	VM_PERCPU_PAGELIST_FRACTION=30,/* int: fraction of pages in each percpu_pagelist */
-	VM_ZONE_RECLAIM_MODE=31,/* reclaim local zone memory before going off node */
+	VM_ZONE_RECLAIM_MODE=31, /* reclaim local zone memory before going off node */
+	VM_ZONE_RECLAIM_INTERVAL=32, /* time period to wait after reclaim failure */
 };
 
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
