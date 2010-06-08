Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 37FE16B01C1
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 11:52:04 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp04.in.ibm.com (8.14.4/8.13.1) with ESMTP id o58Fpwfw029238
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 21:21:58 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o58FpwNN3317798
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 21:21:58 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o58FpwK1015994
	for <linux-mm@kvack.org>; Wed, 9 Jun 2010 01:51:58 +1000
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Tue, 08 Jun 2010 21:21:53 +0530
Message-Id: <20100608155153.3749.31669.sendpatchset@L34Z31A.ibm.com>
In-Reply-To: <20100608155140.3749.74418.sendpatchset@L34Z31A.ibm.com>
References: <20100608155140.3749.74418.sendpatchset@L34Z31A.ibm.com>
Subject: [RFC/T/D][PATCH 2/2] Linux/Guest cooperative unmapped page cache control
Sender: owner-linux-mm@kvack.org
To: kvm <kvm@vger.kernel.org>
Cc: Avi Kivity <avi@redhat.com>, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Balloon unmapped page cache pages first

From: Balbir Singh <balbir@linux.vnet.ibm.com>

This patch builds on the ballooning infrastructure by ballooning unmapped
page cache pages first. It looks for low hanging fruit first and tries
to reclaim clean unmapped pages first.

This patch brings zone_reclaim() and other dependencies out of CONFIG_NUMA
and then reuses the zone_reclaim_mode logic if __GFP_FREE_CACHE is passed
in the gfp_mask. The virtio balloon driver has been changed to use
__GFP_FREE_CACHE.

Tests:

I ran a simple filter function that kept frequently ballon a single VM
running kernbench. The VM was configured with 2GB of memory and 2 VCPUs.
The filter function was a triangular wave function that ballooned
the VM under study from 500MB to 1500MB using a triangular wave function
continously. The run times of the VM with and without changes are shown
below. The run times showed no significant impact of the changes.

Withchanges

Elapsed Time 223.86 (1.52822)
User Time 191.01 (0.65395)
System Time 199.468 (2.43616)
Percent CPU 174 (1)
Context Switches 103182 (595.05)
Sleeps 39107.6 (1505.67)

Without changes

Elapsed Time 225.526 (2.93102)
User Time 193.53 (3.53626)
System Time 199.832 (3.26281)
Percent CPU 173.6 (1.14018)
Context Switches 103744 (1311.53)
Sleeps 39383.2 (831.865)

The key advantage was that it resulted in lesser RSS usage in the host and
more cached usage, indicating that the caching had been pushed towards
the host. The guest cached memory usage was lower and free memory in
the guest was also higher.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 drivers/virtio/virtio_balloon.c |    3 ++-
 include/linux/gfp.h             |    8 +++++++-
 include/linux/swap.h            |    9 +++------
 mm/page_alloc.c                 |    3 ++-
 mm/vmscan.c                     |    2 +-
 5 files changed, 15 insertions(+), 10 deletions(-)


diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 0f1da45..609a9c2 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -104,7 +104,8 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
 
 	for (vb->num_pfns = 0; vb->num_pfns < num; vb->num_pfns++) {
 		struct page *page = alloc_page(GFP_HIGHUSER | __GFP_NORETRY |
-					__GFP_NOMEMALLOC | __GFP_NOWARN);
+					__GFP_NOMEMALLOC | __GFP_NOWARN |
+					__GFP_FREE_CACHE);
 		if (!page) {
 			if (printk_ratelimit())
 				dev_printk(KERN_INFO, &vb->vdev->dev,
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 975609c..9048259 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -61,12 +61,18 @@ struct vm_area_struct;
 #endif
 
 /*
+ * While allocating pages, try to free cache pages first. Note the
+ * heavy dependency on zone_reclaim_mode logic
+ */
+#define __GFP_FREE_CACHE ((__force gfp_t)0x400000u) /* Free cache first */
+
+/*
  * This may seem redundant, but it's a way of annotating false positives vs.
  * allocations that simply cannot be supported (e.g. page tables).
  */
 #define __GFP_NOTRACK_FALSE_POSITIVE (__GFP_NOTRACK)
 
-#define __GFP_BITS_SHIFT 22	/* Room for 22 __GFP_FOO bits */
+#define __GFP_BITS_SHIFT 23	/* Room for 22 __GFP_FOO bits */
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
 
 /* This equals 0, but use constants in case they ever change */
diff --git a/include/linux/swap.h b/include/linux/swap.h
index f92f1ee..f77c603 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -254,16 +254,13 @@ extern long vm_total_pages;
 extern bool should_balance_unmapped_pages(struct zone *zone);
 
 extern int sysctl_min_unmapped_ratio;
-#ifdef CONFIG_NUMA
-extern int zone_reclaim_mode;
 extern int sysctl_min_slab_ratio;
 extern int zone_reclaim(struct zone *, gfp_t, unsigned int);
+
+#ifdef CONFIG_NUMA
+extern int zone_reclaim_mode;
 #else
 #define zone_reclaim_mode 0
-static inline int zone_reclaim(struct zone *z, gfp_t mask, unsigned int order)
-{
-	return 0;
-}
 #endif
 
 extern int page_evictable(struct page *page, struct vm_area_struct *vma);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fee9420..d977b36 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1649,7 +1649,8 @@ zonelist_scan:
 				    classzone_idx, alloc_flags))
 				goto try_this_zone;
 
-			if (zone_reclaim_mode == 0)
+			if (zone_reclaim_mode == 0 &&
+				!(gfp_mask & __GFP_FREE_CACHE))
 				goto this_zone_full;
 
 			ret = zone_reclaim(zone, gfp_mask, order);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 27bc536..393bee5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2624,6 +2624,7 @@ module_init(kswapd_init)
  * the watermarks.
  */
 int zone_reclaim_mode __read_mostly;
+#endif
 
 /*
  * If the number of slab pages in a zone grows beyond this percentage then
@@ -2780,7 +2781,6 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 
 	return ret;
 }
-#endif
 
 /*
  * page_evictable - test whether a page is evictable

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
