Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id DCCE36B0036
	for <linux-mm@kvack.org>; Sun, 21 Sep 2014 20:02:42 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id r10so3201119pdi.26
        for <linux-mm@kvack.org>; Sun, 21 Sep 2014 17:02:42 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id cf1si13241124pdb.231.2014.09.21.17.02.40
        for <linux-mm@kvack.org>;
        Sun, 21 Sep 2014 17:02:41 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v1 1/5] zram: generalize swap_slot_free_notify
Date: Mon, 22 Sep 2014 09:03:07 +0900
Message-Id: <1411344191-2842-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1411344191-2842-1-git-send-email-minchan@kernel.org>
References: <1411344191-2842-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Nitin Gupta <ngupta@vflare.org>, Luigi Semenzato <semenzato@google.com>, juno.choi@lge.com, Minchan Kim <minchan@kernel.org>

Currently, swap_slot_free_notify is used for zram to free
duplicated copy page for memory efficiency when it knows
there is no reference to the swap slot.

This patch generalizes it to be able to use for other
swap hint to communicate with VM.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 Documentation/filesystems/Locking |  4 ++--
 drivers/block/zram/zram_drv.c     | 18 ++++++++++++++++--
 include/linux/blkdev.h            |  7 +++++--
 mm/page_io.c                      |  6 +++---
 mm/swapfile.c                     |  6 +++---
 5 files changed, 29 insertions(+), 12 deletions(-)

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index 94d93b1f8b53..c262bfbeafa9 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -405,7 +405,7 @@ prototypes:
 	void (*unlock_native_capacity) (struct gendisk *);
 	int (*revalidate_disk) (struct gendisk *);
 	int (*getgeo)(struct block_device *, struct hd_geometry *);
-	void (*swap_slot_free_notify) (struct block_device *, unsigned long);
+	int (*swap_hint) (struct block_device *, unsigned int, void *);
 
 locking rules:
 			bd_mutex
@@ -418,7 +418,7 @@ media_changed:		no
 unlock_native_capacity:	no
 revalidate_disk:	no
 getgeo:			no
-swap_slot_free_notify:	no	(see below)
+swap_hint:		no	(see below)
 
 media_changed, unlock_native_capacity and revalidate_disk are called only from
 check_disk_change().
diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index d78b245bae06..22a37764c409 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -926,7 +926,8 @@ error:
 	bio_io_error(bio);
 }
 
-static void zram_slot_free_notify(struct block_device *bdev,
+/* this callback is with swap_lock and sometimes page table lock held */
+static int zram_slot_free_notify(struct block_device *bdev,
 				unsigned long index)
 {
 	struct zram *zram;
@@ -939,10 +940,23 @@ static void zram_slot_free_notify(struct block_device *bdev,
 	zram_free_page(zram, index);
 	bit_spin_unlock(ZRAM_ACCESS, &meta->table[index].value);
 	atomic64_inc(&zram->stats.notify_free);
+
+	return 0;
+}
+
+static int zram_swap_hint(struct block_device *bdev,
+				unsigned int hint, void *arg)
+{
+	int ret = -EINVAL;
+
+	if (hint == SWAP_FREE)
+		ret = zram_slot_free_notify(bdev, (unsigned long)arg);
+
+	return ret;
 }
 
 static const struct block_device_operations zram_devops = {
-	.swap_slot_free_notify = zram_slot_free_notify,
+	.swap_hint = zram_swap_hint,
 	.owner = THIS_MODULE
 };
 
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index e267bf0db559..c7220409456c 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -1609,6 +1609,10 @@ static inline bool blk_integrity_is_initialized(struct gendisk *g)
 
 #endif /* CONFIG_BLK_DEV_INTEGRITY */
 
+enum swap_blk_hint {
+	SWAP_FREE,
+};
+
 struct block_device_operations {
 	int (*open) (struct block_device *, fmode_t);
 	void (*release) (struct gendisk *, fmode_t);
@@ -1624,8 +1628,7 @@ struct block_device_operations {
 	void (*unlock_native_capacity) (struct gendisk *);
 	int (*revalidate_disk) (struct gendisk *);
 	int (*getgeo)(struct block_device *, struct hd_geometry *);
-	/* this callback is with swap_lock and sometimes page table lock held */
-	void (*swap_slot_free_notify) (struct block_device *, unsigned long);
+	int (*swap_hint)(struct block_device *, unsigned int, void *);
 	struct module *owner;
 };
 
diff --git a/mm/page_io.c b/mm/page_io.c
index 955db8b0d497..c6cc19655e97 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -114,7 +114,7 @@ void end_swap_bio_read(struct bio *bio, int err)
 			 * we again wish to reclaim it.
 			 */
 			struct gendisk *disk = sis->bdev->bd_disk;
-			if (disk->fops->swap_slot_free_notify) {
+			if (disk->fops->swap_hint) {
 				swp_entry_t entry;
 				unsigned long offset;
 
@@ -122,8 +122,8 @@ void end_swap_bio_read(struct bio *bio, int err)
 				offset = swp_offset(entry);
 
 				SetPageDirty(page);
-				disk->fops->swap_slot_free_notify(sis->bdev,
-						offset);
+				disk->fops->swap_hint(sis->bdev,
+						SWAP_FREE, (void *)offset);
 			}
 		}
 	}
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 8798b2e0ac59..c07f7f4912e9 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -816,9 +816,9 @@ static unsigned char swap_entry_free(struct swap_info_struct *p,
 		frontswap_invalidate_page(p->type, offset);
 		if (p->flags & SWP_BLKDEV) {
 			struct gendisk *disk = p->bdev->bd_disk;
-			if (disk->fops->swap_slot_free_notify)
-				disk->fops->swap_slot_free_notify(p->bdev,
-								  offset);
+			if (disk->fops->swap_hint)
+				disk->fops->swap_hint(p->bdev,
+						SWAP_FREE, (void *)offset);
 		}
 	}
 
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
