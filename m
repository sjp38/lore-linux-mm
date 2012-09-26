Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id D91996B006C
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 04:47:15 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 2/3] zram: promote zram from staging
Date: Wed, 26 Sep 2012 17:50:18 +0900
Message-Id: <1348649419-16494-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1348649419-16494-1-git-send-email-minchan@kernel.org>
References: <1348649419-16494-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>

It's time to promote zram from staging because zram is in staging
for a long time and is improved by many contributors so code is
very clean. Most important issue, zram's dependency with x86 is
solved by making zsmalloc portable. In addition, many embedded
product uses zram in real practive so I think there is no reason
to prevent promotion now.

Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Nitin Gupta <ngupta@vflare.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/block/Kconfig             |    1 +
 drivers/block/Makefile            |    1 +
 drivers/block/zram/Kconfig        |   25 ++
 drivers/block/zram/Makefile       |    3 +
 drivers/block/zram/zram.txt       |   76 ++++
 drivers/block/zram/zram_drv.c     |  785 +++++++++++++++++++++++++++++++++++++
 drivers/block/zram/zram_drv.h     |  119 ++++++
 drivers/block/zram/zram_sysfs.c   |  225 +++++++++++
 drivers/staging/Kconfig           |    2 -
 drivers/staging/Makefile          |    1 -
 drivers/staging/zram/Kconfig      |   25 --
 drivers/staging/zram/Makefile     |    3 -
 drivers/staging/zram/zram.txt     |   76 ----
 drivers/staging/zram/zram_drv.c   |  785 -------------------------------------
 drivers/staging/zram/zram_drv.h   |  119 ------
 drivers/staging/zram/zram_sysfs.c |  225 -----------
 16 files changed, 1235 insertions(+), 1236 deletions(-)
 create mode 100644 drivers/block/zram/Kconfig
 create mode 100644 drivers/block/zram/Makefile
 create mode 100644 drivers/block/zram/zram.txt
 create mode 100644 drivers/block/zram/zram_drv.c
 create mode 100644 drivers/block/zram/zram_drv.h
 create mode 100644 drivers/block/zram/zram_sysfs.c
 delete mode 100644 drivers/staging/zram/Kconfig
 delete mode 100644 drivers/staging/zram/Makefile
 delete mode 100644 drivers/staging/zram/zram.txt
 delete mode 100644 drivers/staging/zram/zram_drv.c
 delete mode 100644 drivers/staging/zram/zram_drv.h
 delete mode 100644 drivers/staging/zram/zram_sysfs.c

diff --git a/drivers/block/Kconfig b/drivers/block/Kconfig
index f7de322..3e3087e 100644
--- a/drivers/block/Kconfig
+++ b/drivers/block/Kconfig
@@ -290,6 +290,7 @@ config BLK_DEV_CRYPTOLOOP
 	  cryptoloop device.
 
 source "drivers/block/drbd/Kconfig"
+source "drivers/block/zram/Kconfig"
 
 config BLK_DEV_NBD
 	tristate "Network block device support"
diff --git a/drivers/block/Makefile b/drivers/block/Makefile
index 17e82df..0751c43 100644
--- a/drivers/block/Makefile
+++ b/drivers/block/Makefile
@@ -30,6 +30,7 @@ obj-$(CONFIG_BLK_DEV_UMEM)	+= umem.o
 obj-$(CONFIG_BLK_DEV_NBD)	+= nbd.o
 obj-$(CONFIG_BLK_DEV_CRYPTOLOOP) += cryptoloop.o
 obj-$(CONFIG_VIRTIO_BLK)	+= virtio_blk.o
+obj-$(CONFIG_ZRAM)	+= zram/
 
 obj-$(CONFIG_VIODASD)		+= viodasd.o
 obj-$(CONFIG_BLK_DEV_SX8)	+= sx8.o
diff --git a/drivers/block/zram/Kconfig b/drivers/block/zram/Kconfig
new file mode 100644
index 0000000..be5abe8
--- /dev/null
+++ b/drivers/block/zram/Kconfig
@@ -0,0 +1,25 @@
+config ZRAM
+	tristate "Compressed RAM block device support"
+	depends on BLOCK && SYSFS && ZSMALLOC
+	select LZO_COMPRESS
+	select LZO_DECOMPRESS
+	default n
+	help
+	  Creates virtual block devices called /dev/zramX (X = 0, 1, ...).
+	  Pages written to these disks are compressed and stored in memory
+	  itself. These disks allow very fast I/O and compression provides
+	  good amounts of memory savings.
+
+	  It has several use cases, for example: /tmp storage, use as swap
+	  disks and maybe many more.
+
+	  See zram.txt for more information.
+	  Project home: http://compcache.googlecode.com/
+
+config ZRAM_DEBUG
+	bool "Compressed RAM block device debug support"
+	depends on ZRAM
+	default n
+	help
+	  This option adds additional debugging code to the compressed
+	  RAM block device driver.
diff --git a/drivers/block/zram/Makefile b/drivers/block/zram/Makefile
new file mode 100644
index 0000000..7f4a301
--- /dev/null
+++ b/drivers/block/zram/Makefile
@@ -0,0 +1,3 @@
+zram-y	:=	zram_drv.o zram_sysfs.o
+
+obj-$(CONFIG_ZRAM)	+=	zram.o
diff --git a/drivers/block/zram/zram.txt b/drivers/block/zram/zram.txt
new file mode 100644
index 0000000..5f75d29
--- /dev/null
+++ b/drivers/block/zram/zram.txt
@@ -0,0 +1,76 @@
+zram: Compressed RAM based block devices
+----------------------------------------
+
+Project home: http://compcache.googlecode.com/
+
+* Introduction
+
+The zram module creates RAM based block devices named /dev/zram<id>
+(<id> = 0, 1, ...). Pages written to these disks are compressed and stored
+in memory itself. These disks allow very fast I/O and compression provides
+good amounts of memory savings. Some of the usecases include /tmp storage,
+use as swap disks, various caches under /var and maybe many more :)
+
+Statistics for individual zram devices are exported through sysfs nodes at
+/sys/block/zram<id>/
+
+* Usage
+
+Following shows a typical sequence of steps for using zram.
+
+1) Load Module:
+	modprobe zram num_devices=4
+	This creates 4 devices: /dev/zram{0,1,2,3}
+	(num_devices parameter is optional. Default: 1)
+
+2) Set Disksize (Optional):
+	Set disk size by writing the value to sysfs node 'disksize'
+	(in bytes). If disksize is not given, default value of 25%
+	of RAM is used.
+
+	# Initialize /dev/zram0 with 50MB disksize
+	echo $((50*1024*1024)) > /sys/block/zram0/disksize
+
+	NOTE: disksize cannot be changed if the disk contains any
+	data. So, for such a disk, you need to issue 'reset' (see below)
+	before you can change its disksize.
+
+3) Activate:
+	mkswap /dev/zram0
+	swapon /dev/zram0
+
+	mkfs.ext4 /dev/zram1
+	mount /dev/zram1 /tmp
+
+4) Stats:
+	Per-device statistics are exported as various nodes under
+	/sys/block/zram<id>/
+		disksize
+		num_reads
+		num_writes
+		invalid_io
+		notify_free
+		discard
+		zero_pages
+		orig_data_size
+		compr_data_size
+		mem_used_total
+
+5) Deactivate:
+	swapoff /dev/zram0
+	umount /dev/zram1
+
+6) Reset:
+	Write any positive value to 'reset' sysfs node
+	echo 1 > /sys/block/zram0/reset
+	echo 1 > /sys/block/zram1/reset
+
+	(This frees all the memory allocated for the given device).
+
+
+Please report any problems at:
+ - Mailing list: linux-mm-cc at laptop dot org
+ - Issue tracker: http://code.google.com/p/compcache/issues/list
+
+Nitin Gupta
+ngupta@vflare.org
diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
new file mode 100644
index 0000000..653b074
--- /dev/null
+++ b/drivers/block/zram/zram_drv.c
@@ -0,0 +1,785 @@
+/*
+ * Compressed RAM block device
+ *
+ * Copyright (C) 2008, 2009, 2010  Nitin Gupta
+ *
+ * This code is released using a dual license strategy: BSD/GPL
+ * You can choose the licence that better fits your requirements.
+ *
+ * Released under the terms of 3-clause BSD License
+ * Released under the terms of GNU General Public License Version 2.0
+ *
+ * Project home: http://compcache.googlecode.com
+ */
+
+#define KMSG_COMPONENT "zram"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
+#ifdef CONFIG_ZRAM_DEBUG
+#define DEBUG
+#endif
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/bio.h>
+#include <linux/bitops.h>
+#include <linux/blkdev.h>
+#include <linux/buffer_head.h>
+#include <linux/device.h>
+#include <linux/genhd.h>
+#include <linux/highmem.h>
+#include <linux/slab.h>
+#include <linux/lzo.h>
+#include <linux/string.h>
+#include <linux/vmalloc.h>
+
+#include "zram_drv.h"
+
+/* Globals */
+static int zram_major;
+struct zram *zram_devices;
+
+/* Module params (documentation at end) */
+static unsigned int num_devices;
+
+static void zram_stat_inc(u32 *v)
+{
+	*v = *v + 1;
+}
+
+static void zram_stat_dec(u32 *v)
+{
+	*v = *v - 1;
+}
+
+static void zram_stat64_add(struct zram *zram, u64 *v, u64 inc)
+{
+	spin_lock(&zram->stat64_lock);
+	*v = *v + inc;
+	spin_unlock(&zram->stat64_lock);
+}
+
+static void zram_stat64_sub(struct zram *zram, u64 *v, u64 dec)
+{
+	spin_lock(&zram->stat64_lock);
+	*v = *v - dec;
+	spin_unlock(&zram->stat64_lock);
+}
+
+static void zram_stat64_inc(struct zram *zram, u64 *v)
+{
+	zram_stat64_add(zram, v, 1);
+}
+
+static int zram_test_flag(struct zram *zram, u32 index,
+			enum zram_pageflags flag)
+{
+	return zram->table[index].flags & BIT(flag);
+}
+
+static void zram_set_flag(struct zram *zram, u32 index,
+			enum zram_pageflags flag)
+{
+	zram->table[index].flags |= BIT(flag);
+}
+
+static void zram_clear_flag(struct zram *zram, u32 index,
+			enum zram_pageflags flag)
+{
+	zram->table[index].flags &= ~BIT(flag);
+}
+
+static int page_zero_filled(void *ptr)
+{
+	unsigned int pos;
+	unsigned long *page;
+
+	page = (unsigned long *)ptr;
+
+	for (pos = 0; pos != PAGE_SIZE / sizeof(*page); pos++) {
+		if (page[pos])
+			return 0;
+	}
+
+	return 1;
+}
+
+static void zram_set_disksize(struct zram *zram, size_t totalram_bytes)
+{
+	if (!zram->disksize) {
+		pr_info(
+		"disk size not provided. You can use disksize_kb module "
+		"param to specify size.\nUsing default: (%u%% of RAM).\n",
+		default_disksize_perc_ram
+		);
+		zram->disksize = default_disksize_perc_ram *
+					(totalram_bytes / 100);
+	}
+
+	if (zram->disksize > 2 * (totalram_bytes)) {
+		pr_info(
+		"There is little point creating a zram of greater than "
+		"twice the size of memory since we expect a 2:1 compression "
+		"ratio. Note that zram uses about 0.1%% of the size of "
+		"the disk when not in use so a huge zram is "
+		"wasteful.\n"
+		"\tMemory Size: %zu kB\n"
+		"\tSize you selected: %llu kB\n"
+		"Continuing anyway ...\n",
+		totalram_bytes >> 10, zram->disksize
+		);
+	}
+
+	zram->disksize &= PAGE_MASK;
+}
+
+static void zram_free_page(struct zram *zram, size_t index)
+{
+	unsigned long handle = zram->table[index].handle;
+	u16 size = zram->table[index].size;
+
+	if (unlikely(!handle)) {
+		/*
+		 * No memory is allocated for zero filled pages.
+		 * Simply clear zero page flag.
+		 */
+		if (zram_test_flag(zram, index, ZRAM_ZERO)) {
+			zram_clear_flag(zram, index, ZRAM_ZERO);
+			zram_stat_dec(&zram->stats.pages_zero);
+		}
+		return;
+	}
+
+	if (unlikely(size > max_zpage_size))
+		zram_stat_dec(&zram->stats.bad_compress);
+
+	zs_free(zram->mem_pool, handle);
+
+	if (size <= PAGE_SIZE / 2)
+		zram_stat_dec(&zram->stats.good_compress);
+
+	zram_stat64_sub(zram, &zram->stats.compr_size,
+			zram->table[index].size);
+	zram_stat_dec(&zram->stats.pages_stored);
+
+	zram->table[index].handle = 0;
+	zram->table[index].size = 0;
+}
+
+static void handle_zero_page(struct bio_vec *bvec)
+{
+	struct page *page = bvec->bv_page;
+	void *user_mem;
+
+	user_mem = kmap_atomic(page);
+	memset(user_mem + bvec->bv_offset, 0, bvec->bv_len);
+	kunmap_atomic(user_mem);
+
+	flush_dcache_page(page);
+}
+
+static inline int is_partial_io(struct bio_vec *bvec)
+{
+	return bvec->bv_len != PAGE_SIZE;
+}
+
+static int zram_bvec_read(struct zram *zram, struct bio_vec *bvec,
+			  u32 index, int offset, struct bio *bio)
+{
+	int ret;
+	size_t clen;
+	struct page *page;
+	unsigned char *user_mem, *cmem, *uncmem = NULL;
+
+	page = bvec->bv_page;
+
+	if (zram_test_flag(zram, index, ZRAM_ZERO)) {
+		handle_zero_page(bvec);
+		return 0;
+	}
+
+	/* Requested page is not present in compressed area */
+	if (unlikely(!zram->table[index].handle)) {
+		pr_debug("Read before write: sector=%lu, size=%u",
+			 (ulong)(bio->bi_sector), bio->bi_size);
+		handle_zero_page(bvec);
+		return 0;
+	}
+
+	if (is_partial_io(bvec)) {
+		/* Use  a temporary buffer to decompress the page */
+		uncmem = kmalloc(PAGE_SIZE, GFP_KERNEL);
+		if (!uncmem) {
+			pr_info("Error allocating temp memory!\n");
+			return -ENOMEM;
+		}
+	}
+
+	user_mem = kmap_atomic(page);
+	if (!is_partial_io(bvec))
+		uncmem = user_mem;
+	clen = PAGE_SIZE;
+
+	cmem = zs_map_object(zram->mem_pool, zram->table[index].handle,
+				ZS_MM_RO);
+
+	ret = lzo1x_decompress_safe(cmem, zram->table[index].size,
+				    uncmem, &clen);
+
+	if (is_partial_io(bvec)) {
+		memcpy(user_mem + bvec->bv_offset, uncmem + offset,
+		       bvec->bv_len);
+		kfree(uncmem);
+	}
+
+	zs_unmap_object(zram->mem_pool, zram->table[index].handle);
+	kunmap_atomic(user_mem);
+
+	/* Should NEVER happen. Return bio error if it does. */
+	if (unlikely(ret != LZO_E_OK)) {
+		pr_err("Decompression failed! err=%d, page=%u\n", ret, index);
+		zram_stat64_inc(zram, &zram->stats.failed_reads);
+		return ret;
+	}
+
+	flush_dcache_page(page);
+
+	return 0;
+}
+
+static int zram_read_before_write(struct zram *zram, char *mem, u32 index)
+{
+	int ret;
+	size_t clen = PAGE_SIZE;
+	unsigned char *cmem;
+	unsigned long handle = zram->table[index].handle;
+
+	if (zram_test_flag(zram, index, ZRAM_ZERO) || !handle) {
+		memset(mem, 0, PAGE_SIZE);
+		return 0;
+	}
+
+	cmem = zs_map_object(zram->mem_pool, handle, ZS_MM_RO);
+	ret = lzo1x_decompress_safe(cmem, zram->table[index].size,
+				    mem, &clen);
+	zs_unmap_object(zram->mem_pool, handle);
+
+	/* Should NEVER happen. Return bio error if it does. */
+	if (unlikely(ret != LZO_E_OK)) {
+		pr_err("Decompression failed! err=%d, page=%u\n", ret, index);
+		zram_stat64_inc(zram, &zram->stats.failed_reads);
+		return ret;
+	}
+
+	return 0;
+}
+
+static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
+			   int offset)
+{
+	int ret;
+	size_t clen;
+	unsigned long handle;
+	struct page *page;
+	unsigned char *user_mem, *cmem, *src, *uncmem = NULL;
+
+	page = bvec->bv_page;
+	src = zram->compress_buffer;
+
+	if (is_partial_io(bvec)) {
+		/*
+		 * This is a partial IO. We need to read the full page
+		 * before to write the changes.
+		 */
+		uncmem = kmalloc(PAGE_SIZE, GFP_KERNEL);
+		if (!uncmem) {
+			pr_info("Error allocating temp memory!\n");
+			ret = -ENOMEM;
+			goto out;
+		}
+		ret = zram_read_before_write(zram, uncmem, index);
+		if (ret) {
+			kfree(uncmem);
+			goto out;
+		}
+	}
+
+	/*
+	 * System overwrites unused sectors. Free memory associated
+	 * with this sector now.
+	 */
+	if (zram->table[index].handle ||
+	    zram_test_flag(zram, index, ZRAM_ZERO))
+		zram_free_page(zram, index);
+
+	user_mem = kmap_atomic(page);
+
+	if (is_partial_io(bvec))
+		memcpy(uncmem + offset, user_mem + bvec->bv_offset,
+		       bvec->bv_len);
+	else
+		uncmem = user_mem;
+
+	if (page_zero_filled(uncmem)) {
+		kunmap_atomic(user_mem);
+		if (is_partial_io(bvec))
+			kfree(uncmem);
+		zram_stat_inc(&zram->stats.pages_zero);
+		zram_set_flag(zram, index, ZRAM_ZERO);
+		ret = 0;
+		goto out;
+	}
+
+	ret = lzo1x_1_compress(uncmem, PAGE_SIZE, src, &clen,
+			       zram->compress_workmem);
+
+	kunmap_atomic(user_mem);
+	if (is_partial_io(bvec))
+			kfree(uncmem);
+
+	if (unlikely(ret != LZO_E_OK)) {
+		pr_err("Compression failed! err=%d\n", ret);
+		goto out;
+	}
+
+	if (unlikely(clen > max_zpage_size))
+		zram_stat_inc(&zram->stats.bad_compress);
+
+	handle = zs_malloc(zram->mem_pool, clen);
+	if (!handle) {
+		pr_info("Error allocating memory for compressed "
+			"page: %u, size=%zu\n", index, clen);
+		ret = -ENOMEM;
+		goto out;
+	}
+	cmem = zs_map_object(zram->mem_pool, handle, ZS_MM_WO);
+
+	memcpy(cmem, src, clen);
+
+	zs_unmap_object(zram->mem_pool, handle);
+
+	zram->table[index].handle = handle;
+	zram->table[index].size = clen;
+
+	/* Update stats */
+	zram_stat64_add(zram, &zram->stats.compr_size, clen);
+	zram_stat_inc(&zram->stats.pages_stored);
+	if (clen <= PAGE_SIZE / 2)
+		zram_stat_inc(&zram->stats.good_compress);
+
+	return 0;
+
+out:
+	if (ret)
+		zram_stat64_inc(zram, &zram->stats.failed_writes);
+	return ret;
+}
+
+static int zram_bvec_rw(struct zram *zram, struct bio_vec *bvec, u32 index,
+			int offset, struct bio *bio, int rw)
+{
+	int ret;
+
+	if (rw == READ) {
+		down_read(&zram->lock);
+		ret = zram_bvec_read(zram, bvec, index, offset, bio);
+		up_read(&zram->lock);
+	} else {
+		down_write(&zram->lock);
+		ret = zram_bvec_write(zram, bvec, index, offset);
+		up_write(&zram->lock);
+	}
+
+	return ret;
+}
+
+static void update_position(u32 *index, int *offset, struct bio_vec *bvec)
+{
+	if (*offset + bvec->bv_len >= PAGE_SIZE)
+		(*index)++;
+	*offset = (*offset + bvec->bv_len) % PAGE_SIZE;
+}
+
+static void __zram_make_request(struct zram *zram, struct bio *bio, int rw)
+{
+	int i, offset;
+	u32 index;
+	struct bio_vec *bvec;
+
+	switch (rw) {
+	case READ:
+		zram_stat64_inc(zram, &zram->stats.num_reads);
+		break;
+	case WRITE:
+		zram_stat64_inc(zram, &zram->stats.num_writes);
+		break;
+	}
+
+	index = bio->bi_sector >> SECTORS_PER_PAGE_SHIFT;
+	offset = (bio->bi_sector & (SECTORS_PER_PAGE - 1)) << SECTOR_SHIFT;
+
+	bio_for_each_segment(bvec, bio, i) {
+		int max_transfer_size = PAGE_SIZE - offset;
+
+		if (bvec->bv_len > max_transfer_size) {
+			/*
+			 * zram_bvec_rw() can only make operation on a single
+			 * zram page. Split the bio vector.
+			 */
+			struct bio_vec bv;
+
+			bv.bv_page = bvec->bv_page;
+			bv.bv_len = max_transfer_size;
+			bv.bv_offset = bvec->bv_offset;
+
+			if (zram_bvec_rw(zram, &bv, index, offset, bio, rw) < 0)
+				goto out;
+
+			bv.bv_len = bvec->bv_len - max_transfer_size;
+			bv.bv_offset += max_transfer_size;
+			if (zram_bvec_rw(zram, &bv, index+1, 0, bio, rw) < 0)
+				goto out;
+		} else
+			if (zram_bvec_rw(zram, bvec, index, offset, bio, rw)
+			    < 0)
+				goto out;
+
+		update_position(&index, &offset, bvec);
+	}
+
+	set_bit(BIO_UPTODATE, &bio->bi_flags);
+	bio_endio(bio, 0);
+	return;
+
+out:
+	bio_io_error(bio);
+}
+
+/*
+ * Check if request is within bounds and aligned on zram logical blocks.
+ */
+static inline int valid_io_request(struct zram *zram, struct bio *bio)
+{
+	if (unlikely(
+		(bio->bi_sector >= (zram->disksize >> SECTOR_SHIFT)) ||
+		(bio->bi_sector & (ZRAM_SECTOR_PER_LOGICAL_BLOCK - 1)) ||
+		(bio->bi_size & (ZRAM_LOGICAL_BLOCK_SIZE - 1)))) {
+
+		return 0;
+	}
+
+	/* I/O request is valid */
+	return 1;
+}
+
+/*
+ * Handler function for all zram I/O requests.
+ */
+static void zram_make_request(struct request_queue *queue, struct bio *bio)
+{
+	struct zram *zram = queue->queuedata;
+
+	if (unlikely(!zram->init_done) && zram_init_device(zram))
+		goto error;
+
+	down_read(&zram->init_lock);
+	if (unlikely(!zram->init_done))
+		goto error_unlock;
+
+	if (!valid_io_request(zram, bio)) {
+		zram_stat64_inc(zram, &zram->stats.invalid_io);
+		goto error_unlock;
+	}
+
+	__zram_make_request(zram, bio, bio_data_dir(bio));
+	up_read(&zram->init_lock);
+
+	return;
+
+error_unlock:
+	up_read(&zram->init_lock);
+error:
+	bio_io_error(bio);
+}
+
+void __zram_reset_device(struct zram *zram)
+{
+	size_t index;
+
+	zram->init_done = 0;
+
+	/* Free various per-device buffers */
+	kfree(zram->compress_workmem);
+	free_pages((unsigned long)zram->compress_buffer, 1);
+
+	zram->compress_workmem = NULL;
+	zram->compress_buffer = NULL;
+
+	/* Free all pages that are still in this zram device */
+	for (index = 0; index < zram->disksize >> PAGE_SHIFT; index++) {
+		unsigned long handle = zram->table[index].handle;
+		if (!handle)
+			continue;
+
+		zs_free(zram->mem_pool, handle);
+	}
+
+	vfree(zram->table);
+	zram->table = NULL;
+
+	zs_destroy_pool(zram->mem_pool);
+	zram->mem_pool = NULL;
+
+	/* Reset stats */
+	memset(&zram->stats, 0, sizeof(zram->stats));
+
+	zram->disksize = 0;
+}
+
+void zram_reset_device(struct zram *zram)
+{
+	down_write(&zram->init_lock);
+	__zram_reset_device(zram);
+	up_write(&zram->init_lock);
+}
+
+int zram_init_device(struct zram *zram)
+{
+	int ret;
+	size_t num_pages;
+
+	down_write(&zram->init_lock);
+
+	if (zram->init_done) {
+		up_write(&zram->init_lock);
+		return 0;
+	}
+
+	zram_set_disksize(zram, totalram_pages << PAGE_SHIFT);
+
+	zram->compress_workmem = kzalloc(LZO1X_MEM_COMPRESS, GFP_KERNEL);
+	if (!zram->compress_workmem) {
+		pr_err("Error allocating compressor working memory!\n");
+		ret = -ENOMEM;
+		goto fail_no_table;
+	}
+
+	zram->compress_buffer =
+		(void *)__get_free_pages(GFP_KERNEL | __GFP_ZERO, 1);
+	if (!zram->compress_buffer) {
+		pr_err("Error allocating compressor buffer space\n");
+		ret = -ENOMEM;
+		goto fail_no_table;
+	}
+
+	num_pages = zram->disksize >> PAGE_SHIFT;
+	zram->table = vzalloc(num_pages * sizeof(*zram->table));
+	if (!zram->table) {
+		pr_err("Error allocating zram address table\n");
+		ret = -ENOMEM;
+		goto fail_no_table;
+	}
+
+	set_capacity(zram->disk, zram->disksize >> SECTOR_SHIFT);
+
+	/* zram devices sort of resembles non-rotational disks */
+	queue_flag_set_unlocked(QUEUE_FLAG_NONROT, zram->disk->queue);
+
+	zram->mem_pool = zs_create_pool("zram", GFP_NOIO | __GFP_HIGHMEM);
+	if (!zram->mem_pool) {
+		pr_err("Error creating memory pool\n");
+		ret = -ENOMEM;
+		goto fail;
+	}
+
+	zram->init_done = 1;
+	up_write(&zram->init_lock);
+
+	pr_debug("Initialization done!\n");
+	return 0;
+
+fail_no_table:
+	/* To prevent accessing table entries during cleanup */
+	zram->disksize = 0;
+fail:
+	__zram_reset_device(zram);
+	up_write(&zram->init_lock);
+	pr_err("Initialization failed: err=%d\n", ret);
+	return ret;
+}
+
+static void zram_slot_free_notify(struct block_device *bdev,
+				unsigned long index)
+{
+	struct zram *zram;
+
+	zram = bdev->bd_disk->private_data;
+	zram_free_page(zram, index);
+	zram_stat64_inc(zram, &zram->stats.notify_free);
+}
+
+static const struct block_device_operations zram_devops = {
+	.swap_slot_free_notify = zram_slot_free_notify,
+	.owner = THIS_MODULE
+};
+
+static int create_device(struct zram *zram, int device_id)
+{
+	int ret = 0;
+
+	init_rwsem(&zram->lock);
+	init_rwsem(&zram->init_lock);
+	spin_lock_init(&zram->stat64_lock);
+
+	zram->queue = blk_alloc_queue(GFP_KERNEL);
+	if (!zram->queue) {
+		pr_err("Error allocating disk queue for device %d\n",
+			device_id);
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	blk_queue_make_request(zram->queue, zram_make_request);
+	zram->queue->queuedata = zram;
+
+	 /* gendisk structure */
+	zram->disk = alloc_disk(1);
+	if (!zram->disk) {
+		blk_cleanup_queue(zram->queue);
+		pr_warn("Error allocating disk structure for device %d\n",
+			device_id);
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	zram->disk->major = zram_major;
+	zram->disk->first_minor = device_id;
+	zram->disk->fops = &zram_devops;
+	zram->disk->queue = zram->queue;
+	zram->disk->private_data = zram;
+	snprintf(zram->disk->disk_name, 16, "zram%d", device_id);
+
+	/* Actual capacity set using syfs (/sys/block/zram<id>/disksize */
+	set_capacity(zram->disk, 0);
+
+	/*
+	 * To ensure that we always get PAGE_SIZE aligned
+	 * and n*PAGE_SIZED sized I/O requests.
+	 */
+	blk_queue_physical_block_size(zram->disk->queue, PAGE_SIZE);
+	blk_queue_logical_block_size(zram->disk->queue,
+					ZRAM_LOGICAL_BLOCK_SIZE);
+	blk_queue_io_min(zram->disk->queue, PAGE_SIZE);
+	blk_queue_io_opt(zram->disk->queue, PAGE_SIZE);
+
+	add_disk(zram->disk);
+
+	ret = sysfs_create_group(&disk_to_dev(zram->disk)->kobj,
+				&zram_disk_attr_group);
+	if (ret < 0) {
+		pr_warn("Error creating sysfs group");
+		goto out;
+	}
+
+	zram->init_done = 0;
+
+out:
+	return ret;
+}
+
+static void destroy_device(struct zram *zram)
+{
+	sysfs_remove_group(&disk_to_dev(zram->disk)->kobj,
+			&zram_disk_attr_group);
+
+	if (zram->disk) {
+		del_gendisk(zram->disk);
+		put_disk(zram->disk);
+	}
+
+	if (zram->queue)
+		blk_cleanup_queue(zram->queue);
+}
+
+unsigned int zram_get_num_devices(void)
+{
+	return num_devices;
+}
+
+static int __init zram_init(void)
+{
+	int ret, dev_id;
+
+	if (num_devices > max_num_devices) {
+		pr_warn("Invalid value for num_devices: %u\n",
+				num_devices);
+		ret = -EINVAL;
+		goto out;
+	}
+
+	zram_major = register_blkdev(0, "zram");
+	if (zram_major <= 0) {
+		pr_warn("Unable to get major number\n");
+		ret = -EBUSY;
+		goto out;
+	}
+
+	if (!num_devices) {
+		pr_info("num_devices not specified. Using default: 1\n");
+		num_devices = 1;
+	}
+
+	/* Allocate the device array and initialize each one */
+	pr_info("Creating %u devices ...\n", num_devices);
+	zram_devices = kzalloc(num_devices * sizeof(struct zram), GFP_KERNEL);
+	if (!zram_devices) {
+		ret = -ENOMEM;
+		goto unregister;
+	}
+
+	for (dev_id = 0; dev_id < num_devices; dev_id++) {
+		ret = create_device(&zram_devices[dev_id], dev_id);
+		if (ret)
+			goto free_devices;
+	}
+
+	return 0;
+
+free_devices:
+	while (dev_id)
+		destroy_device(&zram_devices[--dev_id]);
+	kfree(zram_devices);
+unregister:
+	unregister_blkdev(zram_major, "zram");
+out:
+	return ret;
+}
+
+static void __exit zram_exit(void)
+{
+	int i;
+	struct zram *zram;
+
+	for (i = 0; i < num_devices; i++) {
+		zram = &zram_devices[i];
+
+		destroy_device(zram);
+		if (zram->init_done)
+			zram_reset_device(zram);
+	}
+
+	unregister_blkdev(zram_major, "zram");
+
+	kfree(zram_devices);
+	pr_debug("Cleanup done!\n");
+}
+
+module_param(num_devices, uint, 0);
+MODULE_PARM_DESC(num_devices, "Number of zram devices");
+
+module_init(zram_init);
+module_exit(zram_exit);
+
+MODULE_LICENSE("Dual BSD/GPL");
+MODULE_AUTHOR("Nitin Gupta <ngupta@vflare.org>");
+MODULE_DESCRIPTION("Compressed RAM Block Device");
diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
new file mode 100644
index 0000000..f6d0925
--- /dev/null
+++ b/drivers/block/zram/zram_drv.h
@@ -0,0 +1,119 @@
+/*
+ * Compressed RAM block device
+ *
+ * Copyright (C) 2008, 2009, 2010  Nitin Gupta
+ *
+ * This code is released using a dual license strategy: BSD/GPL
+ * You can choose the licence that better fits your requirements.
+ *
+ * Released under the terms of 3-clause BSD License
+ * Released under the terms of GNU General Public License Version 2.0
+ *
+ * Project home: http://compcache.googlecode.com
+ */
+
+#ifndef _ZRAM_DRV_H_
+#define _ZRAM_DRV_H_
+
+#include <linux/spinlock.h>
+#include <linux/mutex.h>
+#include <linux/zsmalloc.h>
+
+/*
+ * Some arbitrary value. This is just to catch
+ * invalid value for num_devices module parameter.
+ */
+static const unsigned max_num_devices = 32;
+
+/*-- Configurable parameters */
+
+/* Default zram disk size: 25% of total RAM */
+static const unsigned default_disksize_perc_ram = 25;
+
+/*
+ * Pages that compress to size greater than this are stored
+ * uncompressed in memory.
+ */
+static const size_t max_zpage_size = PAGE_SIZE / 4 * 3;
+
+/*
+ * NOTE: max_zpage_size must be less than or equal to:
+ *   ZS_MAX_ALLOC_SIZE - sizeof(struct zobj_header)
+ * otherwise, xv_malloc() would always return failure.
+ */
+
+/*-- End of configurable params */
+
+#define SECTOR_SHIFT		9
+#define SECTOR_SIZE		(1 << SECTOR_SHIFT)
+#define SECTORS_PER_PAGE_SHIFT	(PAGE_SHIFT - SECTOR_SHIFT)
+#define SECTORS_PER_PAGE	(1 << SECTORS_PER_PAGE_SHIFT)
+#define ZRAM_LOGICAL_BLOCK_SHIFT 12
+#define ZRAM_LOGICAL_BLOCK_SIZE	(1 << ZRAM_LOGICAL_BLOCK_SHIFT)
+#define ZRAM_SECTOR_PER_LOGICAL_BLOCK	\
+	(1 << (ZRAM_LOGICAL_BLOCK_SHIFT - SECTOR_SHIFT))
+
+/* Flags for zram pages (table[page_no].flags) */
+enum zram_pageflags {
+	/* Page consists entirely of zeros */
+	ZRAM_ZERO,
+
+	__NR_ZRAM_PAGEFLAGS,
+};
+
+/*-- Data structures */
+
+/* Allocated for each disk page */
+struct table {
+	unsigned long handle;
+	u16 size;	/* object size (excluding header) */
+	u8 count;	/* object ref count (not yet used) */
+	u8 flags;
+} __aligned(4);
+
+struct zram_stats {
+	u64 compr_size;		/* compressed size of pages stored */
+	u64 num_reads;		/* failed + successful */
+	u64 num_writes;		/* --do-- */
+	u64 failed_reads;	/* should NEVER! happen */
+	u64 failed_writes;	/* can happen when memory is too low */
+	u64 invalid_io;		/* non-page-aligned I/O requests */
+	u64 notify_free;	/* no. of swap slot free notifications */
+	u32 pages_zero;		/* no. of zero filled pages */
+	u32 pages_stored;	/* no. of pages currently stored */
+	u32 good_compress;	/* % of pages with compression ratio<=50% */
+	u32 bad_compress;	/* % of pages with compression ratio>=75% */
+};
+
+struct zram {
+	struct zs_pool *mem_pool;
+	void *compress_workmem;
+	void *compress_buffer;
+	struct table *table;
+	spinlock_t stat64_lock;	/* protect 64-bit stats */
+	struct rw_semaphore lock; /* protect compression buffers and table
+				   * against concurrent read and writes */
+	struct request_queue *queue;
+	struct gendisk *disk;
+	int init_done;
+	/* Prevent concurrent execution of device init, reset and R/W request */
+	struct rw_semaphore init_lock;
+	/*
+	 * This is the limit on amount of *uncompressed* worth of data
+	 * we can store in a disk.
+	 */
+	u64 disksize;	/* bytes */
+
+	struct zram_stats stats;
+};
+
+extern struct zram *zram_devices;
+unsigned int zram_get_num_devices(void);
+#ifdef CONFIG_SYSFS
+extern struct attribute_group zram_disk_attr_group;
+#endif
+
+extern int zram_init_device(struct zram *zram);
+extern void __zram_reset_device(struct zram *zram);
+
+#endif
diff --git a/drivers/block/zram/zram_sysfs.c b/drivers/block/zram/zram_sysfs.c
new file mode 100644
index 0000000..edb0ed4
--- /dev/null
+++ b/drivers/block/zram/zram_sysfs.c
@@ -0,0 +1,225 @@
+/*
+ * Compressed RAM block device
+ *
+ * Copyright (C) 2008, 2009, 2010  Nitin Gupta
+ *
+ * This code is released using a dual license strategy: BSD/GPL
+ * You can choose the licence that better fits your requirements.
+ *
+ * Released under the terms of 3-clause BSD License
+ * Released under the terms of GNU General Public License Version 2.0
+ *
+ * Project home: http://compcache.googlecode.com/
+ */
+
+#include <linux/device.h>
+#include <linux/genhd.h>
+#include <linux/mm.h>
+
+#include "zram_drv.h"
+
+static u64 zram_stat64_read(struct zram *zram, u64 *v)
+{
+	u64 val;
+
+	spin_lock(&zram->stat64_lock);
+	val = *v;
+	spin_unlock(&zram->stat64_lock);
+
+	return val;
+}
+
+static struct zram *dev_to_zram(struct device *dev)
+{
+	int i;
+	struct zram *zram = NULL;
+
+	for (i = 0; i < zram_get_num_devices(); i++) {
+		zram = &zram_devices[i];
+		if (disk_to_dev(zram->disk) == dev)
+			break;
+	}
+
+	return zram;
+}
+
+static ssize_t disksize_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct zram *zram = dev_to_zram(dev);
+
+	return sprintf(buf, "%llu\n", zram->disksize);
+}
+
+static ssize_t disksize_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t len)
+{
+	int ret;
+	u64 disksize;
+	struct zram *zram = dev_to_zram(dev);
+
+	ret = kstrtoull(buf, 10, &disksize);
+	if (ret)
+		return ret;
+
+	down_write(&zram->init_lock);
+	if (zram->init_done) {
+		up_write(&zram->init_lock);
+		pr_info("Cannot change disksize for initialized device\n");
+		return -EBUSY;
+	}
+
+	zram->disksize = PAGE_ALIGN(disksize);
+	set_capacity(zram->disk, zram->disksize >> SECTOR_SHIFT);
+	up_write(&zram->init_lock);
+
+	return len;
+}
+
+static ssize_t initstate_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct zram *zram = dev_to_zram(dev);
+
+	return sprintf(buf, "%u\n", zram->init_done);
+}
+
+static ssize_t reset_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t len)
+{
+	int ret;
+	unsigned short do_reset;
+	struct zram *zram;
+	struct block_device *bdev;
+
+	zram = dev_to_zram(dev);
+	bdev = bdget_disk(zram->disk, 0);
+
+	/* Do not reset an active device! */
+	if (bdev->bd_holders)
+		return -EBUSY;
+
+	ret = kstrtou16(buf, 10, &do_reset);
+	if (ret)
+		return ret;
+
+	if (!do_reset)
+		return -EINVAL;
+
+	/* Make sure all pending I/O is finished */
+	if (bdev)
+		fsync_bdev(bdev);
+
+	down_write(&zram->init_lock);
+	if (zram->init_done)
+		__zram_reset_device(zram);
+	up_write(&zram->init_lock);
+
+	return len;
+}
+
+static ssize_t num_reads_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct zram *zram = dev_to_zram(dev);
+
+	return sprintf(buf, "%llu\n",
+		zram_stat64_read(zram, &zram->stats.num_reads));
+}
+
+static ssize_t num_writes_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct zram *zram = dev_to_zram(dev);
+
+	return sprintf(buf, "%llu\n",
+		zram_stat64_read(zram, &zram->stats.num_writes));
+}
+
+static ssize_t invalid_io_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct zram *zram = dev_to_zram(dev);
+
+	return sprintf(buf, "%llu\n",
+		zram_stat64_read(zram, &zram->stats.invalid_io));
+}
+
+static ssize_t notify_free_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct zram *zram = dev_to_zram(dev);
+
+	return sprintf(buf, "%llu\n",
+		zram_stat64_read(zram, &zram->stats.notify_free));
+}
+
+static ssize_t zero_pages_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct zram *zram = dev_to_zram(dev);
+
+	return sprintf(buf, "%u\n", zram->stats.pages_zero);
+}
+
+static ssize_t orig_data_size_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct zram *zram = dev_to_zram(dev);
+
+	return sprintf(buf, "%llu\n",
+		(u64)(zram->stats.pages_stored) << PAGE_SHIFT);
+}
+
+static ssize_t compr_data_size_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct zram *zram = dev_to_zram(dev);
+
+	return sprintf(buf, "%llu\n",
+		zram_stat64_read(zram, &zram->stats.compr_size));
+}
+
+static ssize_t mem_used_total_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	u64 val = 0;
+	struct zram *zram = dev_to_zram(dev);
+
+	if (zram->init_done)
+		val = zs_get_total_size_bytes(zram->mem_pool);
+
+	return sprintf(buf, "%llu\n", val);
+}
+
+static DEVICE_ATTR(disksize, S_IRUGO | S_IWUSR,
+		disksize_show, disksize_store);
+static DEVICE_ATTR(initstate, S_IRUGO, initstate_show, NULL);
+static DEVICE_ATTR(reset, S_IWUSR, NULL, reset_store);
+static DEVICE_ATTR(num_reads, S_IRUGO, num_reads_show, NULL);
+static DEVICE_ATTR(num_writes, S_IRUGO, num_writes_show, NULL);
+static DEVICE_ATTR(invalid_io, S_IRUGO, invalid_io_show, NULL);
+static DEVICE_ATTR(notify_free, S_IRUGO, notify_free_show, NULL);
+static DEVICE_ATTR(zero_pages, S_IRUGO, zero_pages_show, NULL);
+static DEVICE_ATTR(orig_data_size, S_IRUGO, orig_data_size_show, NULL);
+static DEVICE_ATTR(compr_data_size, S_IRUGO, compr_data_size_show, NULL);
+static DEVICE_ATTR(mem_used_total, S_IRUGO, mem_used_total_show, NULL);
+
+static struct attribute *zram_disk_attrs[] = {
+	&dev_attr_disksize.attr,
+	&dev_attr_initstate.attr,
+	&dev_attr_reset.attr,
+	&dev_attr_num_reads.attr,
+	&dev_attr_num_writes.attr,
+	&dev_attr_invalid_io.attr,
+	&dev_attr_notify_free.attr,
+	&dev_attr_zero_pages.attr,
+	&dev_attr_orig_data_size.attr,
+	&dev_attr_compr_data_size.attr,
+	&dev_attr_mem_used_total.attr,
+	NULL,
+};
+
+struct attribute_group zram_disk_attr_group = {
+	.attrs = zram_disk_attrs,
+};
diff --git a/drivers/staging/Kconfig b/drivers/staging/Kconfig
index 4316ef5..9fc23d9 100644
--- a/drivers/staging/Kconfig
+++ b/drivers/staging/Kconfig
@@ -74,8 +74,6 @@ source "drivers/staging/sep/Kconfig"
 
 source "drivers/staging/iio/Kconfig"
 
-source "drivers/staging/zram/Kconfig"
-
 source "drivers/staging/zcache/Kconfig"
 
 source "drivers/staging/wlags49_h2/Kconfig"
diff --git a/drivers/staging/Makefile b/drivers/staging/Makefile
index db18726..3aee49a 100644
--- a/drivers/staging/Makefile
+++ b/drivers/staging/Makefile
@@ -32,7 +32,6 @@ obj-$(CONFIG_VME_BUS)		+= vme/
 obj-$(CONFIG_IPACK_BUS)		+= ipack/
 obj-$(CONFIG_DX_SEP)            += sep/
 obj-$(CONFIG_IIO)		+= iio/
-obj-$(CONFIG_ZRAM)		+= zram/
 obj-$(CONFIG_ZCACHE)		+= zcache/
 obj-$(CONFIG_WLAGS49_H2)	+= wlags49_h2/
 obj-$(CONFIG_WLAGS49_H25)	+= wlags49_h25/
diff --git a/drivers/staging/zram/Kconfig b/drivers/staging/zram/Kconfig
deleted file mode 100644
index be5abe8..0000000
--- a/drivers/staging/zram/Kconfig
+++ /dev/null
@@ -1,25 +0,0 @@
-config ZRAM
-	tristate "Compressed RAM block device support"
-	depends on BLOCK && SYSFS && ZSMALLOC
-	select LZO_COMPRESS
-	select LZO_DECOMPRESS
-	default n
-	help
-	  Creates virtual block devices called /dev/zramX (X = 0, 1, ...).
-	  Pages written to these disks are compressed and stored in memory
-	  itself. These disks allow very fast I/O and compression provides
-	  good amounts of memory savings.
-
-	  It has several use cases, for example: /tmp storage, use as swap
-	  disks and maybe many more.
-
-	  See zram.txt for more information.
-	  Project home: http://compcache.googlecode.com/
-
-config ZRAM_DEBUG
-	bool "Compressed RAM block device debug support"
-	depends on ZRAM
-	default n
-	help
-	  This option adds additional debugging code to the compressed
-	  RAM block device driver.
diff --git a/drivers/staging/zram/Makefile b/drivers/staging/zram/Makefile
deleted file mode 100644
index 7f4a301..0000000
--- a/drivers/staging/zram/Makefile
+++ /dev/null
@@ -1,3 +0,0 @@
-zram-y	:=	zram_drv.o zram_sysfs.o
-
-obj-$(CONFIG_ZRAM)	+=	zram.o
diff --git a/drivers/staging/zram/zram.txt b/drivers/staging/zram/zram.txt
deleted file mode 100644
index 5f75d29..0000000
--- a/drivers/staging/zram/zram.txt
+++ /dev/null
@@ -1,76 +0,0 @@
-zram: Compressed RAM based block devices
-----------------------------------------
-
-Project home: http://compcache.googlecode.com/
-
-* Introduction
-
-The zram module creates RAM based block devices named /dev/zram<id>
-(<id> = 0, 1, ...). Pages written to these disks are compressed and stored
-in memory itself. These disks allow very fast I/O and compression provides
-good amounts of memory savings. Some of the usecases include /tmp storage,
-use as swap disks, various caches under /var and maybe many more :)
-
-Statistics for individual zram devices are exported through sysfs nodes at
-/sys/block/zram<id>/
-
-* Usage
-
-Following shows a typical sequence of steps for using zram.
-
-1) Load Module:
-	modprobe zram num_devices=4
-	This creates 4 devices: /dev/zram{0,1,2,3}
-	(num_devices parameter is optional. Default: 1)
-
-2) Set Disksize (Optional):
-	Set disk size by writing the value to sysfs node 'disksize'
-	(in bytes). If disksize is not given, default value of 25%
-	of RAM is used.
-
-	# Initialize /dev/zram0 with 50MB disksize
-	echo $((50*1024*1024)) > /sys/block/zram0/disksize
-
-	NOTE: disksize cannot be changed if the disk contains any
-	data. So, for such a disk, you need to issue 'reset' (see below)
-	before you can change its disksize.
-
-3) Activate:
-	mkswap /dev/zram0
-	swapon /dev/zram0
-
-	mkfs.ext4 /dev/zram1
-	mount /dev/zram1 /tmp
-
-4) Stats:
-	Per-device statistics are exported as various nodes under
-	/sys/block/zram<id>/
-		disksize
-		num_reads
-		num_writes
-		invalid_io
-		notify_free
-		discard
-		zero_pages
-		orig_data_size
-		compr_data_size
-		mem_used_total
-
-5) Deactivate:
-	swapoff /dev/zram0
-	umount /dev/zram1
-
-6) Reset:
-	Write any positive value to 'reset' sysfs node
-	echo 1 > /sys/block/zram0/reset
-	echo 1 > /sys/block/zram1/reset
-
-	(This frees all the memory allocated for the given device).
-
-
-Please report any problems at:
- - Mailing list: linux-mm-cc at laptop dot org
- - Issue tracker: http://code.google.com/p/compcache/issues/list
-
-Nitin Gupta
-ngupta@vflare.org
diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
deleted file mode 100644
index 653b074..0000000
--- a/drivers/staging/zram/zram_drv.c
+++ /dev/null
@@ -1,785 +0,0 @@
-/*
- * Compressed RAM block device
- *
- * Copyright (C) 2008, 2009, 2010  Nitin Gupta
- *
- * This code is released using a dual license strategy: BSD/GPL
- * You can choose the licence that better fits your requirements.
- *
- * Released under the terms of 3-clause BSD License
- * Released under the terms of GNU General Public License Version 2.0
- *
- * Project home: http://compcache.googlecode.com
- */
-
-#define KMSG_COMPONENT "zram"
-#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
-
-#ifdef CONFIG_ZRAM_DEBUG
-#define DEBUG
-#endif
-
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/bio.h>
-#include <linux/bitops.h>
-#include <linux/blkdev.h>
-#include <linux/buffer_head.h>
-#include <linux/device.h>
-#include <linux/genhd.h>
-#include <linux/highmem.h>
-#include <linux/slab.h>
-#include <linux/lzo.h>
-#include <linux/string.h>
-#include <linux/vmalloc.h>
-
-#include "zram_drv.h"
-
-/* Globals */
-static int zram_major;
-struct zram *zram_devices;
-
-/* Module params (documentation at end) */
-static unsigned int num_devices;
-
-static void zram_stat_inc(u32 *v)
-{
-	*v = *v + 1;
-}
-
-static void zram_stat_dec(u32 *v)
-{
-	*v = *v - 1;
-}
-
-static void zram_stat64_add(struct zram *zram, u64 *v, u64 inc)
-{
-	spin_lock(&zram->stat64_lock);
-	*v = *v + inc;
-	spin_unlock(&zram->stat64_lock);
-}
-
-static void zram_stat64_sub(struct zram *zram, u64 *v, u64 dec)
-{
-	spin_lock(&zram->stat64_lock);
-	*v = *v - dec;
-	spin_unlock(&zram->stat64_lock);
-}
-
-static void zram_stat64_inc(struct zram *zram, u64 *v)
-{
-	zram_stat64_add(zram, v, 1);
-}
-
-static int zram_test_flag(struct zram *zram, u32 index,
-			enum zram_pageflags flag)
-{
-	return zram->table[index].flags & BIT(flag);
-}
-
-static void zram_set_flag(struct zram *zram, u32 index,
-			enum zram_pageflags flag)
-{
-	zram->table[index].flags |= BIT(flag);
-}
-
-static void zram_clear_flag(struct zram *zram, u32 index,
-			enum zram_pageflags flag)
-{
-	zram->table[index].flags &= ~BIT(flag);
-}
-
-static int page_zero_filled(void *ptr)
-{
-	unsigned int pos;
-	unsigned long *page;
-
-	page = (unsigned long *)ptr;
-
-	for (pos = 0; pos != PAGE_SIZE / sizeof(*page); pos++) {
-		if (page[pos])
-			return 0;
-	}
-
-	return 1;
-}
-
-static void zram_set_disksize(struct zram *zram, size_t totalram_bytes)
-{
-	if (!zram->disksize) {
-		pr_info(
-		"disk size not provided. You can use disksize_kb module "
-		"param to specify size.\nUsing default: (%u%% of RAM).\n",
-		default_disksize_perc_ram
-		);
-		zram->disksize = default_disksize_perc_ram *
-					(totalram_bytes / 100);
-	}
-
-	if (zram->disksize > 2 * (totalram_bytes)) {
-		pr_info(
-		"There is little point creating a zram of greater than "
-		"twice the size of memory since we expect a 2:1 compression "
-		"ratio. Note that zram uses about 0.1%% of the size of "
-		"the disk when not in use so a huge zram is "
-		"wasteful.\n"
-		"\tMemory Size: %zu kB\n"
-		"\tSize you selected: %llu kB\n"
-		"Continuing anyway ...\n",
-		totalram_bytes >> 10, zram->disksize
-		);
-	}
-
-	zram->disksize &= PAGE_MASK;
-}
-
-static void zram_free_page(struct zram *zram, size_t index)
-{
-	unsigned long handle = zram->table[index].handle;
-	u16 size = zram->table[index].size;
-
-	if (unlikely(!handle)) {
-		/*
-		 * No memory is allocated for zero filled pages.
-		 * Simply clear zero page flag.
-		 */
-		if (zram_test_flag(zram, index, ZRAM_ZERO)) {
-			zram_clear_flag(zram, index, ZRAM_ZERO);
-			zram_stat_dec(&zram->stats.pages_zero);
-		}
-		return;
-	}
-
-	if (unlikely(size > max_zpage_size))
-		zram_stat_dec(&zram->stats.bad_compress);
-
-	zs_free(zram->mem_pool, handle);
-
-	if (size <= PAGE_SIZE / 2)
-		zram_stat_dec(&zram->stats.good_compress);
-
-	zram_stat64_sub(zram, &zram->stats.compr_size,
-			zram->table[index].size);
-	zram_stat_dec(&zram->stats.pages_stored);
-
-	zram->table[index].handle = 0;
-	zram->table[index].size = 0;
-}
-
-static void handle_zero_page(struct bio_vec *bvec)
-{
-	struct page *page = bvec->bv_page;
-	void *user_mem;
-
-	user_mem = kmap_atomic(page);
-	memset(user_mem + bvec->bv_offset, 0, bvec->bv_len);
-	kunmap_atomic(user_mem);
-
-	flush_dcache_page(page);
-}
-
-static inline int is_partial_io(struct bio_vec *bvec)
-{
-	return bvec->bv_len != PAGE_SIZE;
-}
-
-static int zram_bvec_read(struct zram *zram, struct bio_vec *bvec,
-			  u32 index, int offset, struct bio *bio)
-{
-	int ret;
-	size_t clen;
-	struct page *page;
-	unsigned char *user_mem, *cmem, *uncmem = NULL;
-
-	page = bvec->bv_page;
-
-	if (zram_test_flag(zram, index, ZRAM_ZERO)) {
-		handle_zero_page(bvec);
-		return 0;
-	}
-
-	/* Requested page is not present in compressed area */
-	if (unlikely(!zram->table[index].handle)) {
-		pr_debug("Read before write: sector=%lu, size=%u",
-			 (ulong)(bio->bi_sector), bio->bi_size);
-		handle_zero_page(bvec);
-		return 0;
-	}
-
-	if (is_partial_io(bvec)) {
-		/* Use  a temporary buffer to decompress the page */
-		uncmem = kmalloc(PAGE_SIZE, GFP_KERNEL);
-		if (!uncmem) {
-			pr_info("Error allocating temp memory!\n");
-			return -ENOMEM;
-		}
-	}
-
-	user_mem = kmap_atomic(page);
-	if (!is_partial_io(bvec))
-		uncmem = user_mem;
-	clen = PAGE_SIZE;
-
-	cmem = zs_map_object(zram->mem_pool, zram->table[index].handle,
-				ZS_MM_RO);
-
-	ret = lzo1x_decompress_safe(cmem, zram->table[index].size,
-				    uncmem, &clen);
-
-	if (is_partial_io(bvec)) {
-		memcpy(user_mem + bvec->bv_offset, uncmem + offset,
-		       bvec->bv_len);
-		kfree(uncmem);
-	}
-
-	zs_unmap_object(zram->mem_pool, zram->table[index].handle);
-	kunmap_atomic(user_mem);
-
-	/* Should NEVER happen. Return bio error if it does. */
-	if (unlikely(ret != LZO_E_OK)) {
-		pr_err("Decompression failed! err=%d, page=%u\n", ret, index);
-		zram_stat64_inc(zram, &zram->stats.failed_reads);
-		return ret;
-	}
-
-	flush_dcache_page(page);
-
-	return 0;
-}
-
-static int zram_read_before_write(struct zram *zram, char *mem, u32 index)
-{
-	int ret;
-	size_t clen = PAGE_SIZE;
-	unsigned char *cmem;
-	unsigned long handle = zram->table[index].handle;
-
-	if (zram_test_flag(zram, index, ZRAM_ZERO) || !handle) {
-		memset(mem, 0, PAGE_SIZE);
-		return 0;
-	}
-
-	cmem = zs_map_object(zram->mem_pool, handle, ZS_MM_RO);
-	ret = lzo1x_decompress_safe(cmem, zram->table[index].size,
-				    mem, &clen);
-	zs_unmap_object(zram->mem_pool, handle);
-
-	/* Should NEVER happen. Return bio error if it does. */
-	if (unlikely(ret != LZO_E_OK)) {
-		pr_err("Decompression failed! err=%d, page=%u\n", ret, index);
-		zram_stat64_inc(zram, &zram->stats.failed_reads);
-		return ret;
-	}
-
-	return 0;
-}
-
-static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
-			   int offset)
-{
-	int ret;
-	size_t clen;
-	unsigned long handle;
-	struct page *page;
-	unsigned char *user_mem, *cmem, *src, *uncmem = NULL;
-
-	page = bvec->bv_page;
-	src = zram->compress_buffer;
-
-	if (is_partial_io(bvec)) {
-		/*
-		 * This is a partial IO. We need to read the full page
-		 * before to write the changes.
-		 */
-		uncmem = kmalloc(PAGE_SIZE, GFP_KERNEL);
-		if (!uncmem) {
-			pr_info("Error allocating temp memory!\n");
-			ret = -ENOMEM;
-			goto out;
-		}
-		ret = zram_read_before_write(zram, uncmem, index);
-		if (ret) {
-			kfree(uncmem);
-			goto out;
-		}
-	}
-
-	/*
-	 * System overwrites unused sectors. Free memory associated
-	 * with this sector now.
-	 */
-	if (zram->table[index].handle ||
-	    zram_test_flag(zram, index, ZRAM_ZERO))
-		zram_free_page(zram, index);
-
-	user_mem = kmap_atomic(page);
-
-	if (is_partial_io(bvec))
-		memcpy(uncmem + offset, user_mem + bvec->bv_offset,
-		       bvec->bv_len);
-	else
-		uncmem = user_mem;
-
-	if (page_zero_filled(uncmem)) {
-		kunmap_atomic(user_mem);
-		if (is_partial_io(bvec))
-			kfree(uncmem);
-		zram_stat_inc(&zram->stats.pages_zero);
-		zram_set_flag(zram, index, ZRAM_ZERO);
-		ret = 0;
-		goto out;
-	}
-
-	ret = lzo1x_1_compress(uncmem, PAGE_SIZE, src, &clen,
-			       zram->compress_workmem);
-
-	kunmap_atomic(user_mem);
-	if (is_partial_io(bvec))
-			kfree(uncmem);
-
-	if (unlikely(ret != LZO_E_OK)) {
-		pr_err("Compression failed! err=%d\n", ret);
-		goto out;
-	}
-
-	if (unlikely(clen > max_zpage_size))
-		zram_stat_inc(&zram->stats.bad_compress);
-
-	handle = zs_malloc(zram->mem_pool, clen);
-	if (!handle) {
-		pr_info("Error allocating memory for compressed "
-			"page: %u, size=%zu\n", index, clen);
-		ret = -ENOMEM;
-		goto out;
-	}
-	cmem = zs_map_object(zram->mem_pool, handle, ZS_MM_WO);
-
-	memcpy(cmem, src, clen);
-
-	zs_unmap_object(zram->mem_pool, handle);
-
-	zram->table[index].handle = handle;
-	zram->table[index].size = clen;
-
-	/* Update stats */
-	zram_stat64_add(zram, &zram->stats.compr_size, clen);
-	zram_stat_inc(&zram->stats.pages_stored);
-	if (clen <= PAGE_SIZE / 2)
-		zram_stat_inc(&zram->stats.good_compress);
-
-	return 0;
-
-out:
-	if (ret)
-		zram_stat64_inc(zram, &zram->stats.failed_writes);
-	return ret;
-}
-
-static int zram_bvec_rw(struct zram *zram, struct bio_vec *bvec, u32 index,
-			int offset, struct bio *bio, int rw)
-{
-	int ret;
-
-	if (rw == READ) {
-		down_read(&zram->lock);
-		ret = zram_bvec_read(zram, bvec, index, offset, bio);
-		up_read(&zram->lock);
-	} else {
-		down_write(&zram->lock);
-		ret = zram_bvec_write(zram, bvec, index, offset);
-		up_write(&zram->lock);
-	}
-
-	return ret;
-}
-
-static void update_position(u32 *index, int *offset, struct bio_vec *bvec)
-{
-	if (*offset + bvec->bv_len >= PAGE_SIZE)
-		(*index)++;
-	*offset = (*offset + bvec->bv_len) % PAGE_SIZE;
-}
-
-static void __zram_make_request(struct zram *zram, struct bio *bio, int rw)
-{
-	int i, offset;
-	u32 index;
-	struct bio_vec *bvec;
-
-	switch (rw) {
-	case READ:
-		zram_stat64_inc(zram, &zram->stats.num_reads);
-		break;
-	case WRITE:
-		zram_stat64_inc(zram, &zram->stats.num_writes);
-		break;
-	}
-
-	index = bio->bi_sector >> SECTORS_PER_PAGE_SHIFT;
-	offset = (bio->bi_sector & (SECTORS_PER_PAGE - 1)) << SECTOR_SHIFT;
-
-	bio_for_each_segment(bvec, bio, i) {
-		int max_transfer_size = PAGE_SIZE - offset;
-
-		if (bvec->bv_len > max_transfer_size) {
-			/*
-			 * zram_bvec_rw() can only make operation on a single
-			 * zram page. Split the bio vector.
-			 */
-			struct bio_vec bv;
-
-			bv.bv_page = bvec->bv_page;
-			bv.bv_len = max_transfer_size;
-			bv.bv_offset = bvec->bv_offset;
-
-			if (zram_bvec_rw(zram, &bv, index, offset, bio, rw) < 0)
-				goto out;
-
-			bv.bv_len = bvec->bv_len - max_transfer_size;
-			bv.bv_offset += max_transfer_size;
-			if (zram_bvec_rw(zram, &bv, index+1, 0, bio, rw) < 0)
-				goto out;
-		} else
-			if (zram_bvec_rw(zram, bvec, index, offset, bio, rw)
-			    < 0)
-				goto out;
-
-		update_position(&index, &offset, bvec);
-	}
-
-	set_bit(BIO_UPTODATE, &bio->bi_flags);
-	bio_endio(bio, 0);
-	return;
-
-out:
-	bio_io_error(bio);
-}
-
-/*
- * Check if request is within bounds and aligned on zram logical blocks.
- */
-static inline int valid_io_request(struct zram *zram, struct bio *bio)
-{
-	if (unlikely(
-		(bio->bi_sector >= (zram->disksize >> SECTOR_SHIFT)) ||
-		(bio->bi_sector & (ZRAM_SECTOR_PER_LOGICAL_BLOCK - 1)) ||
-		(bio->bi_size & (ZRAM_LOGICAL_BLOCK_SIZE - 1)))) {
-
-		return 0;
-	}
-
-	/* I/O request is valid */
-	return 1;
-}
-
-/*
- * Handler function for all zram I/O requests.
- */
-static void zram_make_request(struct request_queue *queue, struct bio *bio)
-{
-	struct zram *zram = queue->queuedata;
-
-	if (unlikely(!zram->init_done) && zram_init_device(zram))
-		goto error;
-
-	down_read(&zram->init_lock);
-	if (unlikely(!zram->init_done))
-		goto error_unlock;
-
-	if (!valid_io_request(zram, bio)) {
-		zram_stat64_inc(zram, &zram->stats.invalid_io);
-		goto error_unlock;
-	}
-
-	__zram_make_request(zram, bio, bio_data_dir(bio));
-	up_read(&zram->init_lock);
-
-	return;
-
-error_unlock:
-	up_read(&zram->init_lock);
-error:
-	bio_io_error(bio);
-}
-
-void __zram_reset_device(struct zram *zram)
-{
-	size_t index;
-
-	zram->init_done = 0;
-
-	/* Free various per-device buffers */
-	kfree(zram->compress_workmem);
-	free_pages((unsigned long)zram->compress_buffer, 1);
-
-	zram->compress_workmem = NULL;
-	zram->compress_buffer = NULL;
-
-	/* Free all pages that are still in this zram device */
-	for (index = 0; index < zram->disksize >> PAGE_SHIFT; index++) {
-		unsigned long handle = zram->table[index].handle;
-		if (!handle)
-			continue;
-
-		zs_free(zram->mem_pool, handle);
-	}
-
-	vfree(zram->table);
-	zram->table = NULL;
-
-	zs_destroy_pool(zram->mem_pool);
-	zram->mem_pool = NULL;
-
-	/* Reset stats */
-	memset(&zram->stats, 0, sizeof(zram->stats));
-
-	zram->disksize = 0;
-}
-
-void zram_reset_device(struct zram *zram)
-{
-	down_write(&zram->init_lock);
-	__zram_reset_device(zram);
-	up_write(&zram->init_lock);
-}
-
-int zram_init_device(struct zram *zram)
-{
-	int ret;
-	size_t num_pages;
-
-	down_write(&zram->init_lock);
-
-	if (zram->init_done) {
-		up_write(&zram->init_lock);
-		return 0;
-	}
-
-	zram_set_disksize(zram, totalram_pages << PAGE_SHIFT);
-
-	zram->compress_workmem = kzalloc(LZO1X_MEM_COMPRESS, GFP_KERNEL);
-	if (!zram->compress_workmem) {
-		pr_err("Error allocating compressor working memory!\n");
-		ret = -ENOMEM;
-		goto fail_no_table;
-	}
-
-	zram->compress_buffer =
-		(void *)__get_free_pages(GFP_KERNEL | __GFP_ZERO, 1);
-	if (!zram->compress_buffer) {
-		pr_err("Error allocating compressor buffer space\n");
-		ret = -ENOMEM;
-		goto fail_no_table;
-	}
-
-	num_pages = zram->disksize >> PAGE_SHIFT;
-	zram->table = vzalloc(num_pages * sizeof(*zram->table));
-	if (!zram->table) {
-		pr_err("Error allocating zram address table\n");
-		ret = -ENOMEM;
-		goto fail_no_table;
-	}
-
-	set_capacity(zram->disk, zram->disksize >> SECTOR_SHIFT);
-
-	/* zram devices sort of resembles non-rotational disks */
-	queue_flag_set_unlocked(QUEUE_FLAG_NONROT, zram->disk->queue);
-
-	zram->mem_pool = zs_create_pool("zram", GFP_NOIO | __GFP_HIGHMEM);
-	if (!zram->mem_pool) {
-		pr_err("Error creating memory pool\n");
-		ret = -ENOMEM;
-		goto fail;
-	}
-
-	zram->init_done = 1;
-	up_write(&zram->init_lock);
-
-	pr_debug("Initialization done!\n");
-	return 0;
-
-fail_no_table:
-	/* To prevent accessing table entries during cleanup */
-	zram->disksize = 0;
-fail:
-	__zram_reset_device(zram);
-	up_write(&zram->init_lock);
-	pr_err("Initialization failed: err=%d\n", ret);
-	return ret;
-}
-
-static void zram_slot_free_notify(struct block_device *bdev,
-				unsigned long index)
-{
-	struct zram *zram;
-
-	zram = bdev->bd_disk->private_data;
-	zram_free_page(zram, index);
-	zram_stat64_inc(zram, &zram->stats.notify_free);
-}
-
-static const struct block_device_operations zram_devops = {
-	.swap_slot_free_notify = zram_slot_free_notify,
-	.owner = THIS_MODULE
-};
-
-static int create_device(struct zram *zram, int device_id)
-{
-	int ret = 0;
-
-	init_rwsem(&zram->lock);
-	init_rwsem(&zram->init_lock);
-	spin_lock_init(&zram->stat64_lock);
-
-	zram->queue = blk_alloc_queue(GFP_KERNEL);
-	if (!zram->queue) {
-		pr_err("Error allocating disk queue for device %d\n",
-			device_id);
-		ret = -ENOMEM;
-		goto out;
-	}
-
-	blk_queue_make_request(zram->queue, zram_make_request);
-	zram->queue->queuedata = zram;
-
-	 /* gendisk structure */
-	zram->disk = alloc_disk(1);
-	if (!zram->disk) {
-		blk_cleanup_queue(zram->queue);
-		pr_warn("Error allocating disk structure for device %d\n",
-			device_id);
-		ret = -ENOMEM;
-		goto out;
-	}
-
-	zram->disk->major = zram_major;
-	zram->disk->first_minor = device_id;
-	zram->disk->fops = &zram_devops;
-	zram->disk->queue = zram->queue;
-	zram->disk->private_data = zram;
-	snprintf(zram->disk->disk_name, 16, "zram%d", device_id);
-
-	/* Actual capacity set using syfs (/sys/block/zram<id>/disksize */
-	set_capacity(zram->disk, 0);
-
-	/*
-	 * To ensure that we always get PAGE_SIZE aligned
-	 * and n*PAGE_SIZED sized I/O requests.
-	 */
-	blk_queue_physical_block_size(zram->disk->queue, PAGE_SIZE);
-	blk_queue_logical_block_size(zram->disk->queue,
-					ZRAM_LOGICAL_BLOCK_SIZE);
-	blk_queue_io_min(zram->disk->queue, PAGE_SIZE);
-	blk_queue_io_opt(zram->disk->queue, PAGE_SIZE);
-
-	add_disk(zram->disk);
-
-	ret = sysfs_create_group(&disk_to_dev(zram->disk)->kobj,
-				&zram_disk_attr_group);
-	if (ret < 0) {
-		pr_warn("Error creating sysfs group");
-		goto out;
-	}
-
-	zram->init_done = 0;
-
-out:
-	return ret;
-}
-
-static void destroy_device(struct zram *zram)
-{
-	sysfs_remove_group(&disk_to_dev(zram->disk)->kobj,
-			&zram_disk_attr_group);
-
-	if (zram->disk) {
-		del_gendisk(zram->disk);
-		put_disk(zram->disk);
-	}
-
-	if (zram->queue)
-		blk_cleanup_queue(zram->queue);
-}
-
-unsigned int zram_get_num_devices(void)
-{
-	return num_devices;
-}
-
-static int __init zram_init(void)
-{
-	int ret, dev_id;
-
-	if (num_devices > max_num_devices) {
-		pr_warn("Invalid value for num_devices: %u\n",
-				num_devices);
-		ret = -EINVAL;
-		goto out;
-	}
-
-	zram_major = register_blkdev(0, "zram");
-	if (zram_major <= 0) {
-		pr_warn("Unable to get major number\n");
-		ret = -EBUSY;
-		goto out;
-	}
-
-	if (!num_devices) {
-		pr_info("num_devices not specified. Using default: 1\n");
-		num_devices = 1;
-	}
-
-	/* Allocate the device array and initialize each one */
-	pr_info("Creating %u devices ...\n", num_devices);
-	zram_devices = kzalloc(num_devices * sizeof(struct zram), GFP_KERNEL);
-	if (!zram_devices) {
-		ret = -ENOMEM;
-		goto unregister;
-	}
-
-	for (dev_id = 0; dev_id < num_devices; dev_id++) {
-		ret = create_device(&zram_devices[dev_id], dev_id);
-		if (ret)
-			goto free_devices;
-	}
-
-	return 0;
-
-free_devices:
-	while (dev_id)
-		destroy_device(&zram_devices[--dev_id]);
-	kfree(zram_devices);
-unregister:
-	unregister_blkdev(zram_major, "zram");
-out:
-	return ret;
-}
-
-static void __exit zram_exit(void)
-{
-	int i;
-	struct zram *zram;
-
-	for (i = 0; i < num_devices; i++) {
-		zram = &zram_devices[i];
-
-		destroy_device(zram);
-		if (zram->init_done)
-			zram_reset_device(zram);
-	}
-
-	unregister_blkdev(zram_major, "zram");
-
-	kfree(zram_devices);
-	pr_debug("Cleanup done!\n");
-}
-
-module_param(num_devices, uint, 0);
-MODULE_PARM_DESC(num_devices, "Number of zram devices");
-
-module_init(zram_init);
-module_exit(zram_exit);
-
-MODULE_LICENSE("Dual BSD/GPL");
-MODULE_AUTHOR("Nitin Gupta <ngupta@vflare.org>");
-MODULE_DESCRIPTION("Compressed RAM Block Device");
diff --git a/drivers/staging/zram/zram_drv.h b/drivers/staging/zram/zram_drv.h
deleted file mode 100644
index f6d0925..0000000
--- a/drivers/staging/zram/zram_drv.h
+++ /dev/null
@@ -1,119 +0,0 @@
-/*
- * Compressed RAM block device
- *
- * Copyright (C) 2008, 2009, 2010  Nitin Gupta
- *
- * This code is released using a dual license strategy: BSD/GPL
- * You can choose the licence that better fits your requirements.
- *
- * Released under the terms of 3-clause BSD License
- * Released under the terms of GNU General Public License Version 2.0
- *
- * Project home: http://compcache.googlecode.com
- */
-
-#ifndef _ZRAM_DRV_H_
-#define _ZRAM_DRV_H_
-
-#include <linux/spinlock.h>
-#include <linux/mutex.h>
-#include <linux/zsmalloc.h>
-
-/*
- * Some arbitrary value. This is just to catch
- * invalid value for num_devices module parameter.
- */
-static const unsigned max_num_devices = 32;
-
-/*-- Configurable parameters */
-
-/* Default zram disk size: 25% of total RAM */
-static const unsigned default_disksize_perc_ram = 25;
-
-/*
- * Pages that compress to size greater than this are stored
- * uncompressed in memory.
- */
-static const size_t max_zpage_size = PAGE_SIZE / 4 * 3;
-
-/*
- * NOTE: max_zpage_size must be less than or equal to:
- *   ZS_MAX_ALLOC_SIZE - sizeof(struct zobj_header)
- * otherwise, xv_malloc() would always return failure.
- */
-
-/*-- End of configurable params */
-
-#define SECTOR_SHIFT		9
-#define SECTOR_SIZE		(1 << SECTOR_SHIFT)
-#define SECTORS_PER_PAGE_SHIFT	(PAGE_SHIFT - SECTOR_SHIFT)
-#define SECTORS_PER_PAGE	(1 << SECTORS_PER_PAGE_SHIFT)
-#define ZRAM_LOGICAL_BLOCK_SHIFT 12
-#define ZRAM_LOGICAL_BLOCK_SIZE	(1 << ZRAM_LOGICAL_BLOCK_SHIFT)
-#define ZRAM_SECTOR_PER_LOGICAL_BLOCK	\
-	(1 << (ZRAM_LOGICAL_BLOCK_SHIFT - SECTOR_SHIFT))
-
-/* Flags for zram pages (table[page_no].flags) */
-enum zram_pageflags {
-	/* Page consists entirely of zeros */
-	ZRAM_ZERO,
-
-	__NR_ZRAM_PAGEFLAGS,
-};
-
-/*-- Data structures */
-
-/* Allocated for each disk page */
-struct table {
-	unsigned long handle;
-	u16 size;	/* object size (excluding header) */
-	u8 count;	/* object ref count (not yet used) */
-	u8 flags;
-} __aligned(4);
-
-struct zram_stats {
-	u64 compr_size;		/* compressed size of pages stored */
-	u64 num_reads;		/* failed + successful */
-	u64 num_writes;		/* --do-- */
-	u64 failed_reads;	/* should NEVER! happen */
-	u64 failed_writes;	/* can happen when memory is too low */
-	u64 invalid_io;		/* non-page-aligned I/O requests */
-	u64 notify_free;	/* no. of swap slot free notifications */
-	u32 pages_zero;		/* no. of zero filled pages */
-	u32 pages_stored;	/* no. of pages currently stored */
-	u32 good_compress;	/* % of pages with compression ratio<=50% */
-	u32 bad_compress;	/* % of pages with compression ratio>=75% */
-};
-
-struct zram {
-	struct zs_pool *mem_pool;
-	void *compress_workmem;
-	void *compress_buffer;
-	struct table *table;
-	spinlock_t stat64_lock;	/* protect 64-bit stats */
-	struct rw_semaphore lock; /* protect compression buffers and table
-				   * against concurrent read and writes */
-	struct request_queue *queue;
-	struct gendisk *disk;
-	int init_done;
-	/* Prevent concurrent execution of device init, reset and R/W request */
-	struct rw_semaphore init_lock;
-	/*
-	 * This is the limit on amount of *uncompressed* worth of data
-	 * we can store in a disk.
-	 */
-	u64 disksize;	/* bytes */
-
-	struct zram_stats stats;
-};
-
-extern struct zram *zram_devices;
-unsigned int zram_get_num_devices(void);
-#ifdef CONFIG_SYSFS
-extern struct attribute_group zram_disk_attr_group;
-#endif
-
-extern int zram_init_device(struct zram *zram);
-extern void __zram_reset_device(struct zram *zram);
-
-#endif
diff --git a/drivers/staging/zram/zram_sysfs.c b/drivers/staging/zram/zram_sysfs.c
deleted file mode 100644
index edb0ed4..0000000
--- a/drivers/staging/zram/zram_sysfs.c
+++ /dev/null
@@ -1,225 +0,0 @@
-/*
- * Compressed RAM block device
- *
- * Copyright (C) 2008, 2009, 2010  Nitin Gupta
- *
- * This code is released using a dual license strategy: BSD/GPL
- * You can choose the licence that better fits your requirements.
- *
- * Released under the terms of 3-clause BSD License
- * Released under the terms of GNU General Public License Version 2.0
- *
- * Project home: http://compcache.googlecode.com/
- */
-
-#include <linux/device.h>
-#include <linux/genhd.h>
-#include <linux/mm.h>
-
-#include "zram_drv.h"
-
-static u64 zram_stat64_read(struct zram *zram, u64 *v)
-{
-	u64 val;
-
-	spin_lock(&zram->stat64_lock);
-	val = *v;
-	spin_unlock(&zram->stat64_lock);
-
-	return val;
-}
-
-static struct zram *dev_to_zram(struct device *dev)
-{
-	int i;
-	struct zram *zram = NULL;
-
-	for (i = 0; i < zram_get_num_devices(); i++) {
-		zram = &zram_devices[i];
-		if (disk_to_dev(zram->disk) == dev)
-			break;
-	}
-
-	return zram;
-}
-
-static ssize_t disksize_show(struct device *dev,
-		struct device_attribute *attr, char *buf)
-{
-	struct zram *zram = dev_to_zram(dev);
-
-	return sprintf(buf, "%llu\n", zram->disksize);
-}
-
-static ssize_t disksize_store(struct device *dev,
-		struct device_attribute *attr, const char *buf, size_t len)
-{
-	int ret;
-	u64 disksize;
-	struct zram *zram = dev_to_zram(dev);
-
-	ret = kstrtoull(buf, 10, &disksize);
-	if (ret)
-		return ret;
-
-	down_write(&zram->init_lock);
-	if (zram->init_done) {
-		up_write(&zram->init_lock);
-		pr_info("Cannot change disksize for initialized device\n");
-		return -EBUSY;
-	}
-
-	zram->disksize = PAGE_ALIGN(disksize);
-	set_capacity(zram->disk, zram->disksize >> SECTOR_SHIFT);
-	up_write(&zram->init_lock);
-
-	return len;
-}
-
-static ssize_t initstate_show(struct device *dev,
-		struct device_attribute *attr, char *buf)
-{
-	struct zram *zram = dev_to_zram(dev);
-
-	return sprintf(buf, "%u\n", zram->init_done);
-}
-
-static ssize_t reset_store(struct device *dev,
-		struct device_attribute *attr, const char *buf, size_t len)
-{
-	int ret;
-	unsigned short do_reset;
-	struct zram *zram;
-	struct block_device *bdev;
-
-	zram = dev_to_zram(dev);
-	bdev = bdget_disk(zram->disk, 0);
-
-	/* Do not reset an active device! */
-	if (bdev->bd_holders)
-		return -EBUSY;
-
-	ret = kstrtou16(buf, 10, &do_reset);
-	if (ret)
-		return ret;
-
-	if (!do_reset)
-		return -EINVAL;
-
-	/* Make sure all pending I/O is finished */
-	if (bdev)
-		fsync_bdev(bdev);
-
-	down_write(&zram->init_lock);
-	if (zram->init_done)
-		__zram_reset_device(zram);
-	up_write(&zram->init_lock);
-
-	return len;
-}
-
-static ssize_t num_reads_show(struct device *dev,
-		struct device_attribute *attr, char *buf)
-{
-	struct zram *zram = dev_to_zram(dev);
-
-	return sprintf(buf, "%llu\n",
-		zram_stat64_read(zram, &zram->stats.num_reads));
-}
-
-static ssize_t num_writes_show(struct device *dev,
-		struct device_attribute *attr, char *buf)
-{
-	struct zram *zram = dev_to_zram(dev);
-
-	return sprintf(buf, "%llu\n",
-		zram_stat64_read(zram, &zram->stats.num_writes));
-}
-
-static ssize_t invalid_io_show(struct device *dev,
-		struct device_attribute *attr, char *buf)
-{
-	struct zram *zram = dev_to_zram(dev);
-
-	return sprintf(buf, "%llu\n",
-		zram_stat64_read(zram, &zram->stats.invalid_io));
-}
-
-static ssize_t notify_free_show(struct device *dev,
-		struct device_attribute *attr, char *buf)
-{
-	struct zram *zram = dev_to_zram(dev);
-
-	return sprintf(buf, "%llu\n",
-		zram_stat64_read(zram, &zram->stats.notify_free));
-}
-
-static ssize_t zero_pages_show(struct device *dev,
-		struct device_attribute *attr, char *buf)
-{
-	struct zram *zram = dev_to_zram(dev);
-
-	return sprintf(buf, "%u\n", zram->stats.pages_zero);
-}
-
-static ssize_t orig_data_size_show(struct device *dev,
-		struct device_attribute *attr, char *buf)
-{
-	struct zram *zram = dev_to_zram(dev);
-
-	return sprintf(buf, "%llu\n",
-		(u64)(zram->stats.pages_stored) << PAGE_SHIFT);
-}
-
-static ssize_t compr_data_size_show(struct device *dev,
-		struct device_attribute *attr, char *buf)
-{
-	struct zram *zram = dev_to_zram(dev);
-
-	return sprintf(buf, "%llu\n",
-		zram_stat64_read(zram, &zram->stats.compr_size));
-}
-
-static ssize_t mem_used_total_show(struct device *dev,
-		struct device_attribute *attr, char *buf)
-{
-	u64 val = 0;
-	struct zram *zram = dev_to_zram(dev);
-
-	if (zram->init_done)
-		val = zs_get_total_size_bytes(zram->mem_pool);
-
-	return sprintf(buf, "%llu\n", val);
-}
-
-static DEVICE_ATTR(disksize, S_IRUGO | S_IWUSR,
-		disksize_show, disksize_store);
-static DEVICE_ATTR(initstate, S_IRUGO, initstate_show, NULL);
-static DEVICE_ATTR(reset, S_IWUSR, NULL, reset_store);
-static DEVICE_ATTR(num_reads, S_IRUGO, num_reads_show, NULL);
-static DEVICE_ATTR(num_writes, S_IRUGO, num_writes_show, NULL);
-static DEVICE_ATTR(invalid_io, S_IRUGO, invalid_io_show, NULL);
-static DEVICE_ATTR(notify_free, S_IRUGO, notify_free_show, NULL);
-static DEVICE_ATTR(zero_pages, S_IRUGO, zero_pages_show, NULL);
-static DEVICE_ATTR(orig_data_size, S_IRUGO, orig_data_size_show, NULL);
-static DEVICE_ATTR(compr_data_size, S_IRUGO, compr_data_size_show, NULL);
-static DEVICE_ATTR(mem_used_total, S_IRUGO, mem_used_total_show, NULL);
-
-static struct attribute *zram_disk_attrs[] = {
-	&dev_attr_disksize.attr,
-	&dev_attr_initstate.attr,
-	&dev_attr_reset.attr,
-	&dev_attr_num_reads.attr,
-	&dev_attr_num_writes.attr,
-	&dev_attr_invalid_io.attr,
-	&dev_attr_notify_free.attr,
-	&dev_attr_zero_pages.attr,
-	&dev_attr_orig_data_size.attr,
-	&dev_attr_compr_data_size.attr,
-	&dev_attr_mem_used_total.attr,
-	NULL,
-};
-
-struct attribute_group zram_disk_attr_group = {
-	.attrs = zram_disk_attrs,
-};
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
