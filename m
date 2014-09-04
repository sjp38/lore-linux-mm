Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 306CD6B0035
	for <linux-mm@kvack.org>; Wed,  3 Sep 2014 21:38:28 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id lj1so18751459pab.14
        for <linux-mm@kvack.org>; Wed, 03 Sep 2014 18:38:27 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id ey7si268268pdb.175.2014.09.03.18.38.25
        for <linux-mm@kvack.org>;
        Wed, 03 Sep 2014 18:38:27 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 2/3] mm: add swap_get_free hint for zram
Date: Thu,  4 Sep 2014 10:39:45 +0900
Message-Id: <1409794786-10951-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1409794786-10951-1-git-send-email-minchan@kernel.org>
References: <1409794786-10951-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Nitin Gupta <ngupta@vflare.org>, Luigi Semenzato <semenzato@google.com>, Minchan Kim <minchan@kernel.org>

VM uses nr_swap_pages as one of information when it does
anonymous reclaim so that VM is able to throttle amount of swap.

Normally, the nr_swap_pages is equal to freeable space of swap disk
but for zram, it doesn't match because zram can limit memory usage
by knob(ie, mem_limit) so although VM can see lots of free space
from zram disk, zram can make fail intentionally once the allocated
space is over to limit. If it happens, VM should notice it and
stop reclaimaing until zram can obtain more free space but there
is a good way to do at the moment.

This patch adds new hint SWAP_GET_FREE which zram can return how
many of freeable space it has. With using that, this patch adds
__swap_full which returns true if the zram is full and substract
remained freeable space of the zram-swap from nr_swap_pages.
IOW, VM sees there is no more swap space of zram so that it stops
anonymous reclaiming until swap_entry_free free a page and increase
nr_swap_pages again.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/blkdev.h |  1 +
 mm/swapfile.c          | 45 +++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 44 insertions(+), 2 deletions(-)

diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index 17437b2c18e4..c1199806e0f1 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -1611,6 +1611,7 @@ static inline bool blk_integrity_is_initialized(struct gendisk *g)
 
 enum swap_blk_hint {
 	SWAP_SLOT_FREE,
+	SWAP_GET_FREE,
 };
 
 struct block_device_operations {
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 4bff521e649a..72737e6dd5e5 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -484,6 +484,22 @@ new_cluster:
 	*scan_base = tmp;
 }
 
+static bool __swap_full(struct swap_info_struct *si)
+{
+	if (si->flags & SWP_BLKDEV) {
+		long free;
+		struct gendisk *disk = si->bdev->bd_disk;
+
+		if (disk->fops->swap_hint)
+			if (!disk->fops->swap_hint(si->bdev,
+						SWAP_GET_FREE,
+						&free))
+				return free <= 0;
+	}
+
+	return si->inuse_pages == si->pages;
+}
+
 static unsigned long scan_swap_map(struct swap_info_struct *si,
 				   unsigned char usage)
 {
@@ -583,11 +599,21 @@ checks:
 	if (offset == si->highest_bit)
 		si->highest_bit--;
 	si->inuse_pages++;
-	if (si->inuse_pages == si->pages) {
+	if (__swap_full(si)) {
+		struct gendisk *disk = si->bdev->bd_disk;
+
 		si->lowest_bit = si->max;
 		si->highest_bit = 0;
 		spin_lock(&swap_avail_lock);
 		plist_del(&si->avail_list, &swap_avail_head);
+		/*
+		 * If zram is full, it decreases nr_swap_pages
+		 * for stopping anonymous page reclaim until
+		 * zram has free space. Look at swap_entry_free
+		 */
+		if (disk->fops->swap_hint)
+			atomic_long_sub(si->pages - si->inuse_pages,
+				&nr_swap_pages);
 		spin_unlock(&swap_avail_lock);
 	}
 	si->swap_map[offset] = usage;
@@ -796,6 +822,7 @@ static unsigned char swap_entry_free(struct swap_info_struct *p,
 
 	/* free if no reference */
 	if (!usage) {
+		struct gendisk *disk = p->bdev->bd_disk;
 		dec_cluster_info_page(p, p->cluster_info, offset);
 		if (offset < p->lowest_bit)
 			p->lowest_bit = offset;
@@ -808,6 +835,21 @@ static unsigned char swap_entry_free(struct swap_info_struct *p,
 				if (plist_node_empty(&p->avail_list))
 					plist_add(&p->avail_list,
 						  &swap_avail_head);
+				if ((p->flags & SWP_BLKDEV) &&
+					disk->fops->swap_hint) {
+					atomic_long_add(p->pages -
+							p->inuse_pages,
+							&nr_swap_pages);
+					/*
+					 * reset [highest|lowest]_bit to avoid
+					 * scan_swap_map infinite looping if
+					 * cached free cluster's index by
+					 * scan_swap_map_try_ssd_cluster is
+					 * above p->highest_bit.
+					 */
+					p->highest_bit = p->max - 1;
+					p->lowest_bit = 1;
+				}
 				spin_unlock(&swap_avail_lock);
 			}
 		}
@@ -815,7 +857,6 @@ static unsigned char swap_entry_free(struct swap_info_struct *p,
 		p->inuse_pages--;
 		frontswap_invalidate_page(p->type, offset);
 		if (p->flags & SWP_BLKDEV) {
-			struct gendisk *disk = p->bdev->bd_disk;
 			if (disk->fops->swap_hint)
 				disk->fops->swap_hint(p->bdev,
 						SWAP_SLOT_FREE,
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
