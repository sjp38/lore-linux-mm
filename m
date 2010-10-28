Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CF3AD8D0015
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 18:40:19 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp06.in.ibm.com (8.14.4/8.13.1) with ESMTP id o9SMeEM2010373
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 04:10:14 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o9SMeEgR3981522
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 04:10:14 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o9SMeEG6032093
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 09:40:14 +1100
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Fri, 29 Oct 2010 04:10:13 +0530
Message-Id: <20101028224013.32626.42073.sendpatchset@localhost.localdomain>
In-Reply-To: <20101028224002.32626.13015.sendpatchset@localhost.localdomain>
References: <20101028224002.32626.13015.sendpatchset@localhost.localdomain>
Subject: [RFC][PATCH 2/3] Linux/Guest cooperative unmapped page cache control
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, qemu-devel@nongnu.org
List-ID: <linux-mm.kvack.org>

Balloon unmapped page cache pages first

From: Balbir Singh <balbir@linux.vnet.ibm.com>

This patch builds on the ballooning infrastructure by ballooning unmapped
page cache pages first. It looks for low hanging fruit first and tries
to reclaim clean unmapped pages first.

This patch brings zone_reclaim() and other dependencies out of CONFIG_NUMA
and then reuses the zone_reclaim_mode logic if __GFP_FREE_CACHE is passed
in the gfp_mask. The virtio balloon driver has been changed to use
__GFP_FREE_CACHE. During fill_balloon(), the driver looks for hints
provided by the hypervisor to reclaim cached memory. By default the hint
is off and can be turned on by passing an argument that specifies that
we intend to reclaim cached memory.

Tests:

Test 1
------
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

Test 2
------
I ran kernbench under the memory overcommit manager (6 VM's with 2 vCPUs, 2GB)
with KSM and ksmtuned enabled. memory overcommit manager details are at
http://github.com/aglitke/mom/wiki. The command line for kernbench was
kernbench -M.

The tests showed the following

Withchanges

Elapsed Time 842.936 (12.2247)
Elapsed Time 844.266 (25.8047)
Elapsed Time 844.696 (11.2433)
Elapsed Time 846.08 (14.0249)
Elapsed Time 838.58 (7.44609)
Elapsed Time 842.362 (4.37463)

Withoutchanges

Elapsed Time 837.604 (14.1311)
Elapsed Time 839.322 (17.1772)
Elapsed Time 843.744 (9.21541)
Elapsed Time 842.592 (7.48622)
Elapsed Time 844.272 (25.486)
Elapsed Time 838.858 (7.5044)

General observations

1. Free memory in each of guests was higher with changes.
   The additional free memory was of the order of 120MB per VM
2. Cached memory in each guest was lesser with changes
3. Host free memory was almost constant (independent of
   changes)
4. Host anonymous memory usage was lesser with the changes

The goal of this patch is to free up memory locked up in
duplicated cache contents and (1) above shows that we are
able to successfully free it up.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 drivers/virtio/virtio_balloon.c |   17 +++++++++++++++--
 include/linux/gfp.h             |    8 +++++++-
 include/linux/swap.h            |    9 +++------
 include/linux/virtio_balloon.h  |    3 +++
 mm/page_alloc.c                 |    3 ++-
 mm/vmscan.c                     |    2 +-
 6 files changed, 31 insertions(+), 11 deletions(-)


diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 0f1da45..70f97ea 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -99,12 +99,24 @@ static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
 
 static void fill_balloon(struct virtio_balloon *vb, size_t num)
 {
+	u32 reclaim_cache_first;
+	int err;
+	gfp_t mask = GFP_HIGHUSER | __GFP_NORETRY | __GFP_NOMEMALLOC |
+			__GFP_NOWARN;
+
+	err = virtio_config_val(vb->vdev, VIRTIO_BALLOON_F_BALLOON_HINT,
+				offsetof(struct virtio_balloon_config,
+						reclaim_cache_first),
+				&reclaim_cache_first);
+
+	if (!err && reclaim_cache_first)
+		mask |= __GFP_FREE_CACHE;
+
 	/* We can only do one array worth at a time. */
 	num = min(num, ARRAY_SIZE(vb->pfns));
 
 	for (vb->num_pfns = 0; vb->num_pfns < num; vb->num_pfns++) {
-		struct page *page = alloc_page(GFP_HIGHUSER | __GFP_NORETRY |
-					__GFP_NOMEMALLOC | __GFP_NOWARN);
+		struct page *page = alloc_page(mask);
 		if (!page) {
 			if (printk_ratelimit())
 				dev_printk(KERN_INFO, &vb->vdev->dev,
@@ -358,6 +370,7 @@ static void __devexit virtballoon_remove(struct virtio_device *vdev)
 static unsigned int features[] = {
 	VIRTIO_BALLOON_F_MUST_TELL_HOST,
 	VIRTIO_BALLOON_F_STATS_VQ,
+	VIRTIO_BALLOON_F_BALLOON_HINT,
 };
 
 static struct virtio_driver virtio_balloon_driver = {
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
index 5d29097..e77db75 100644
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
diff --git a/include/linux/virtio_balloon.h b/include/linux/virtio_balloon.h
index a50ecd1..6e405b4 100644
--- a/include/linux/virtio_balloon.h
+++ b/include/linux/virtio_balloon.h
@@ -8,6 +8,7 @@
 /* The feature bitmap for virtio balloon */
 #define VIRTIO_BALLOON_F_MUST_TELL_HOST	0 /* Tell before reclaiming pages */
 #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
+#define VIRTIO_BALLOON_F_BALLOON_HINT	2 /* Reclaim hint */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12
@@ -18,6 +19,8 @@ struct virtio_balloon_config
 	__le32 num_pages;
 	/* Number of pages we've actually got in balloon. */
 	__le32 actual;
+	/* Hint, should we reclaim cached pages first? */
+	__le32 reclaim_cache_first;
 };
 
 #define VIRTIO_BALLOON_S_SWAP_IN  0   /* Amount of memory swapped in */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d8fe29f..2cdf4a9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1650,7 +1650,8 @@ zonelist_scan:
 				    classzone_idx, alloc_flags))
 				goto try_this_zone;
 
-			if (zone_reclaim_mode == 0)
+			if (zone_reclaim_mode == 0 &&
+				!(gfp_mask & __GFP_FREE_CACHE))
 				goto this_zone_full;
 
 			ret = zone_reclaim(zone, gfp_mask, order);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 02346ad..9a11e5a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2705,6 +2705,7 @@ module_init(kswapd_init)
  * the watermarks.
  */
 int zone_reclaim_mode __read_mostly;
+#endif
 
 /*
  * If the number of slab pages in a zone grows beyond this percentage then
@@ -2870,7 +2871,6 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 
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
