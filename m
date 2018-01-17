Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5CB7E280281
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:23:06 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id j6so12163427pgp.21
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 12:23:06 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id f4si5131809plm.700.2018.01.17.12.23.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Jan 2018 12:23:04 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 86/99] btrfs: Convert reada_zones to XArray
Date: Wed, 17 Jan 2018 12:21:50 -0800
Message-Id: <20180117202203.19756-87-willy@infradead.org>
In-Reply-To: <20180117202203.19756-1-willy@infradead.org>
References: <20180117202203.19756-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, Bjorn Andersson <bjorn.andersson@linaro.org>, Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, linux-remoteproc@vger.kernel.org, linux-s390@vger.kernel.org, intel-gfx@lists.freedesktop.org, cgroups@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

The use of the reada_lock means we have to use the xa_reserve() API.
If we can avoid using reada_lock to protect this xarray, we can drop
the use of that function.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/btrfs/reada.c   | 54 +++++++++++++++++++-----------------------------------
 fs/btrfs/volumes.c |  2 +-
 fs/btrfs/volumes.h |  2 +-
 3 files changed, 21 insertions(+), 37 deletions(-)

diff --git a/fs/btrfs/reada.c b/fs/btrfs/reada.c
index ab852b8e3e37..ef8e84ff2012 100644
--- a/fs/btrfs/reada.c
+++ b/fs/btrfs/reada.c
@@ -239,17 +239,16 @@ static struct reada_zone *reada_find_zone(struct btrfs_device *dev, u64 logical,
 {
 	struct btrfs_fs_info *fs_info = dev->fs_info;
 	int ret;
-	struct reada_zone *zone;
+	struct reada_zone *curr, *zone;
 	struct btrfs_block_group_cache *cache = NULL;
 	u64 start;
 	u64 end;
+	unsigned long index = logical >> PAGE_SHIFT;
 	int i;
 
-	zone = NULL;
 	spin_lock(&fs_info->reada_lock);
-	ret = radix_tree_gang_lookup(&dev->reada_zones, (void **)&zone,
-				     logical >> PAGE_SHIFT, 1);
-	if (ret == 1 && logical >= zone->start && logical <= zone->end) {
+	zone = xa_find(&dev->reada_zones, &index, ULONG_MAX, XA_PRESENT);
+	if (zone && logical >= zone->start && logical <= zone->end) {
 		kref_get(&zone->refcnt);
 		spin_unlock(&fs_info->reada_lock);
 		return zone;
@@ -269,7 +268,8 @@ static struct reada_zone *reada_find_zone(struct btrfs_device *dev, u64 logical,
 	if (!zone)
 		return NULL;
 
-	ret = radix_tree_preload(GFP_KERNEL);
+	ret = xa_reserve(&dev->reada_zones,
+			 (unsigned long)(end >> PAGE_SHIFT), GFP_KERNEL);
 	if (ret) {
 		kfree(zone);
 		return NULL;
@@ -290,21 +290,18 @@ static struct reada_zone *reada_find_zone(struct btrfs_device *dev, u64 logical,
 	zone->ndevs = bbio->num_stripes;
 
 	spin_lock(&fs_info->reada_lock);
-	ret = radix_tree_insert(&dev->reada_zones,
+	curr = xa_cmpxchg(&dev->reada_zones,
 				(unsigned long)(zone->end >> PAGE_SHIFT),
-				zone);
-
-	if (ret == -EEXIST) {
+				NULL, zone, GFP_NOWAIT | __GFP_NOWARN);
+	if (curr) {
 		kfree(zone);
-		ret = radix_tree_gang_lookup(&dev->reada_zones, (void **)&zone,
-					     logical >> PAGE_SHIFT, 1);
-		if (ret == 1 && logical >= zone->start && logical <= zone->end)
+		zone = curr;
+		if (logical >= zone->start && logical <= zone->end)
 			kref_get(&zone->refcnt);
 		else
 			zone = NULL;
 	}
 	spin_unlock(&fs_info->reada_lock);
-	radix_tree_preload_end();
 
 	return zone;
 }
@@ -537,9 +534,7 @@ static void reada_zone_release(struct kref *kref)
 {
 	struct reada_zone *zone = container_of(kref, struct reada_zone, refcnt);
 
-	radix_tree_delete(&zone->device->reada_zones,
-			  zone->end >> PAGE_SHIFT);
-
+	xa_erase(&zone->device->reada_zones, zone->end >> PAGE_SHIFT);
 	kfree(zone);
 }
 
@@ -592,7 +587,7 @@ static void reada_peer_zones_set_lock(struct reada_zone *zone, int lock)
 
 	for (i = 0; i < zone->ndevs; ++i) {
 		struct reada_zone *peer;
-		peer = radix_tree_lookup(&zone->devs[i]->reada_zones, index);
+		peer = xa_load(&zone->devs[i]->reada_zones, index);
 		if (peer && peer->device != zone->device)
 			peer->locked = lock;
 	}
@@ -603,12 +598,11 @@ static void reada_peer_zones_set_lock(struct reada_zone *zone, int lock)
  */
 static int reada_pick_zone(struct btrfs_device *dev)
 {
-	struct reada_zone *top_zone = NULL;
+	struct reada_zone *zone, *top_zone = NULL;
 	struct reada_zone *top_locked_zone = NULL;
 	u64 top_elems = 0;
 	u64 top_locked_elems = 0;
 	unsigned long index = 0;
-	int ret;
 
 	if (dev->reada_curr_zone) {
 		reada_peer_zones_set_lock(dev->reada_curr_zone, 0);
@@ -616,14 +610,7 @@ static int reada_pick_zone(struct btrfs_device *dev)
 		dev->reada_curr_zone = NULL;
 	}
 	/* pick the zone with the most elements */
-	while (1) {
-		struct reada_zone *zone;
-
-		ret = radix_tree_gang_lookup(&dev->reada_zones,
-					     (void **)&zone, index, 1);
-		if (ret == 0)
-			break;
-		index = (zone->end >> PAGE_SHIFT) + 1;
+	xa_for_each(&dev->reada_zones, zone, index, ULONG_MAX, XA_PRESENT) {
 		if (zone->locked) {
 			if (zone->elems > top_locked_elems) {
 				top_locked_elems = zone->elems;
@@ -819,15 +806,13 @@ static void dump_devs(struct btrfs_fs_info *fs_info, int all)
 
 	spin_lock(&fs_info->reada_lock);
 	list_for_each_entry(device, &fs_devices->devices, dev_list) {
+		struct reada_zone *zone;
+
 		btrfs_debug(fs_info, "dev %lld has %d in flight", device->devid,
 			atomic_read(&device->reada_in_flight));
 		index = 0;
-		while (1) {
-			struct reada_zone *zone;
-			ret = radix_tree_gang_lookup(&device->reada_zones,
-						     (void **)&zone, index, 1);
-			if (ret == 0)
-				break;
+		xa_for_each(&dev->reada_zones, zone, index, ULONG_MAX,
+								XA_PRESENT) {
 			pr_debug("  zone %llu-%llu elems %llu locked %d devs",
 				    zone->start, zone->end, zone->elems,
 				    zone->locked);
@@ -839,7 +824,6 @@ static void dump_devs(struct btrfs_fs_info *fs_info, int all)
 				pr_cont(" curr off %llu",
 					device->reada_next - zone->start);
 			pr_cont("\n");
-			index = (zone->end >> PAGE_SHIFT) + 1;
 		}
 		cnt = 0;
 		index = 0;
diff --git a/fs/btrfs/volumes.c b/fs/btrfs/volumes.c
index cba286183ff9..8e683799b436 100644
--- a/fs/btrfs/volumes.c
+++ b/fs/btrfs/volumes.c
@@ -247,7 +247,7 @@ static struct btrfs_device *__alloc_device(void)
 	atomic_set(&dev->reada_in_flight, 0);
 	atomic_set(&dev->dev_stats_ccnt, 0);
 	btrfs_device_data_ordered_init(dev);
-	INIT_RADIX_TREE(&dev->reada_zones, GFP_NOFS & ~__GFP_DIRECT_RECLAIM);
+	xa_init(&dev->reada_zones);
 	INIT_RADIX_TREE(&dev->reada_extents, GFP_NOFS & ~__GFP_DIRECT_RECLAIM);
 
 	return dev;
diff --git a/fs/btrfs/volumes.h b/fs/btrfs/volumes.h
index 335fd1590458..aeabe03d3e44 100644
--- a/fs/btrfs/volumes.h
+++ b/fs/btrfs/volumes.h
@@ -139,7 +139,7 @@ struct btrfs_device {
 	atomic_t reada_in_flight;
 	u64 reada_next;
 	struct reada_zone *reada_curr_zone;
-	struct radix_tree_root reada_zones;
+	struct xarray reada_zones;
 	struct radix_tree_root reada_extents;
 
 	/* disk I/O failure stats. For detailed description refer to
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
