Received: from internal-mail-relay1.corp.sgi.com (internal-mail-relay1.corp.sgi.com [198.149.32.52])
	by omx2.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k5LI9b6R027661
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 11:09:37 -0700
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by internal-mail-relay1.corp.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id k5LFkr8s14894066
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 08:46:53 -0700 (PDT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id k5LFkrnB42468997
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 08:46:53 -0700 (PDT)
Received: from christoph (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1Ft4ur-0004wo-00
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 08:46:53 -0700
Date: Wed, 21 Jun 2006 08:44:56 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060621154456.18741.49166.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060621154419.18741.76233.sendpatchset@schroedinger.engr.sgi.com>
References: <20060621154419.18741.76233.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 07/14] zone_reclaim: remove /proc/sys/vm/zone_reclaim_interval
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.64.0606210846531.18960@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Subject: zoned vm counters: use per zone counters to remove zone_reclaim_interval
From: Christoph Lameter <clameter@sgi.com>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Martin Bligh <mbligh@google.com>, linux-mm@vger.kernel.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

The zone_reclaim_interval was necessary because we were not able to determine
how many unmapped pages exist in a zone.  Therefore we had to scan in
intervals to figure out if any pages were unmapped.

With the zoned counters and NR_ANON_PAGES we now know the number of pagecache pages
and the number of mapped pages in a zone. So we can simply skip the reclaim
if there is an insufficient number of unmapped pages. We use SWAP_CLUSTER_MAX
as the boundary.

Drop all support for /proc/sys/vm/zone_reclaim_interval.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>

Index: linux-2.6.17-mm1/include/linux/mmzone.h
===================================================================
--- linux-2.6.17-mm1.orig/include/linux/mmzone.h	2006-06-21 07:37:46.333038070 -0700
+++ linux-2.6.17-mm1/include/linux/mmzone.h	2006-06-21 07:38:54.090553468 -0700
@@ -179,12 +179,6 @@ struct zone {
 
 	/* Zone statistics */
 	atomic_long_t		vm_stat[NR_VM_ZONE_STAT_ITEMS];
-	/*
-	 * timestamp (in jiffies) of the last zone reclaim that did not
-	 * result in freeing of pages. This is used to avoid repeated scans
-	 * if all memory in the zone is in use.
-	 */
-	unsigned long		last_unsuccessful_zone_reclaim;
 
 	/*
 	 * prev_priority holds the scanning priority for this zone.  It is
Index: linux-2.6.17-mm1/include/linux/swap.h
===================================================================
--- linux-2.6.17-mm1.orig/include/linux/swap.h	2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.17-mm1/include/linux/swap.h	2006-06-21 07:38:54.091529970 -0700
@@ -194,7 +194,6 @@ extern pageout_t pageout(struct page *pa
 
 #ifdef CONFIG_NUMA
 extern int zone_reclaim_mode;
-extern int zone_reclaim_interval;
 extern int zone_reclaim(struct zone *, gfp_t, unsigned int);
 #else
 #define zone_reclaim_mode 0
Index: linux-2.6.17-mm1/kernel/sysctl.c
===================================================================
--- linux-2.6.17-mm1.orig/kernel/sysctl.c	2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.17-mm1/kernel/sysctl.c	2006-06-21 07:38:54.094459475 -0700
@@ -905,15 +905,6 @@ static ctl_table vm_table[] = {
 		.strategy	= &sysctl_intvec,
 		.extra1		= &zero,
 	},
-	{
-		.ctl_name	= VM_ZONE_RECLAIM_INTERVAL,
-		.procname	= "zone_reclaim_interval",
-		.data		= &zone_reclaim_interval,
-		.maxlen		= sizeof(zone_reclaim_interval),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
-		.strategy	= &sysctl_jiffies,
-	},
 #endif
 	{ .ctl_name = 0 }
 };
Index: linux-2.6.17-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/vmscan.c	2006-06-21 07:38:28.451518977 -0700
+++ linux-2.6.17-mm1/mm/vmscan.c	2006-06-21 07:38:54.095435977 -0700
@@ -1384,11 +1384,6 @@ int zone_reclaim_mode __read_mostly;
 #define RECLAIM_SLAB (1<<3)	/* Do a global slab shrink if the zone is out of memory */
 
 /*
- * Mininum time between zone reclaim scans
- */
-int zone_reclaim_interval __read_mostly = 30*HZ;
-
-/*
  * Priority for ZONE_RECLAIM. This determines the fraction of pages
  * of a node considered for each zone_reclaim. 4 scans 1/16th of
  * a zone.
@@ -1452,16 +1447,6 @@ static int __zone_reclaim(struct zone *z
 
 	p->reclaim_state = NULL;
 	current->flags &= ~(PF_MEMALLOC | PF_SWAPWRITE);
-
-	if (nr_reclaimed == 0) {
-		/*
-		 * We were unable to reclaim enough pages to stay on node.  We
-		 * now allow off node accesses for a certain time period before
-		 * trying again to reclaim pages from the local zone.
-		 */
-		zone->last_unsuccessful_zone_reclaim = jiffies;
-	}
-
 	return nr_reclaimed >= nr_pages;
 }
 
@@ -1471,13 +1456,17 @@ int zone_reclaim(struct zone *zone, gfp_
 	int node_id;
 
 	/*
-	 * Do not reclaim if there was a recent unsuccessful attempt at zone
-	 * reclaim.  In that case we let allocations go off node for the
-	 * zone_reclaim_interval.  Otherwise we would scan for each off-node
-	 * page allocation.
+	 * Do not reclaim if there are not enough reclaimable pages in this
+	 * zone that would satify this allocations.
+	 *
+	 * All unmapped pagecache pages are reclaimable.
+	 *
+	 * Both counters may be temporarily off a bit so we use
+	 * SWAP_CLUSTER_MAX as the boundary. It may also be good to
+	 * leave a few frequently used unmapped pagecache pages around.
 	 */
-	if (time_before(jiffies,
-		zone->last_unsuccessful_zone_reclaim + zone_reclaim_interval))
+	if (zone_page_state(zone, NR_FILE_PAGES) -
+		zone_page_state(zone, NR_FILE_MAPPED) < SWAP_CLUSTER_MAX)
 			return 0;
 
 	/*
Index: linux-2.6.17-mm1/Documentation/sysctl/vm.txt
===================================================================
--- linux-2.6.17-mm1.orig/Documentation/sysctl/vm.txt	2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.17-mm1/Documentation/sysctl/vm.txt	2006-06-21 07:39:34.186698961 -0700
@@ -28,7 +28,6 @@ Currently, these files are in /proc/sys/
 - block_dump
 - drop-caches
 - zone_reclaim_mode
-- zone_reclaim_interval
 
 ==============================================================
 
@@ -166,15 +165,3 @@ use of files and builds up large slab ca
 shrink operation is global, may take a long time and free slabs
 in all nodes of the system.
 
-================================================================
-
-zone_reclaim_interval:
-
-The time allowed for off node allocations after zone reclaim
-has failed to reclaim enough pages to allow a local allocation.
-
-Time is set in seconds and set by default to 30 seconds.
-
-Reduce the interval if undesired off node allocations occur. However, too
-frequent scans will have a negative impact onoff node allocation performance.
-

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
