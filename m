Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id AFAD06B003A
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 21:04:42 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id ma3so8885384pbc.26
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 18:04:42 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id ya10si12006440pab.66.2013.12.10.18.04.38
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 18:04:40 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v9 4/4] zram: promote zram from staging
Date: Wed, 11 Dec 2013 11:04:39 +0900
Message-Id: <1386727479-18502-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1386727479-18502-1-git-send-email-minchan@kernel.org>
References: <1386727479-18502-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Luigi Semenzato <semenzato@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Bob Liu <bob.liu@oracle.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>

Zram has lived in staging for a LONG LONG time and have been
fixed/improved by many contributors so code is clean and stable now.
Of course, there are lots of product using zram in real practice.

The major TV companys have used zram as swap since two years ago
and recently our production team released android smart phone with zram
which is used as swap, too and recently Android Kitkat start to use zram
for small memory smart phone.  And there was a report Google released
their ChromeOS with zram, too and cyanogenmod have been used zram
long time ago. And I heard some disto have used zram block device
for tmpfs. In addition, I saw many report from many other peoples.
For example, Lubuntu start to use it.

The benefit of zram is very clear. With my experience, one of the benefit
was to remove jitter of video application with backgroud memory pressure.
It would be effect of efficient memory usage by compression but more issue
is whether swap is there or not in the system. Recent mobile platforms have
used JAVA so there are many anonymous pages. But embedded system normally
are reluctant to use eMMC or SDCard as swap because there is wear-leveling
and latency issues so if we do not use swap, it means we can't reclaim
anoymous pages and at last, we could encounter OOM kill. :(

Although we have real storage as swap, it was a problem, too. Because
it sometime ends up making system very unresponsible caused by slow
swap storage performance.

Quote from Luigi on Google
"
Since Chrome OS was mentioned: the main reason why we don't use swap
to a disk (rotating or SSD) is because it doesn't degrade gracefully
and leads to a bad interactive experience.  Generally we prefer to
manage RAM at a higher level, by transparently killing and restarting
processes.  But we noticed that zram is fast enough to be competitive
with the latter, and it lets us make more efficient use of the
available RAM.
"
and he announced. http://www.spinics.net/lists/linux-mm/msg57717.html

Other uses case is to use zram for block device. Zram is block device
so anyone can format the block device and mount on it so some guys
on the internet start zram as /var/tmp.
http://forums.gentoo.org/viewtopic-t-838198-start-0.html

Let's promote zram and enhance/maintain it instead of removing.

Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Acked-by: Nitin Gupta <ngupta@vflare.org>
Acked-by: Pekka Enberg <penberg@kernel.org>

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 Documentation/blockdev/zram.txt |   77 +++
 drivers/block/Kconfig           |    2 +
 drivers/block/Makefile          |    1 +
 drivers/block/zram/Kconfig      |   25 +
 drivers/block/zram/Makefile     |    3 +
 drivers/block/zram/zram_drv.c   |  994 +++++++++++++++++++++++++++++++++++++++
 drivers/block/zram/zram_drv.h   |  124 +++++
 drivers/staging/Kconfig         |    2 -
 drivers/staging/Makefile        |    1 -
 drivers/staging/zram/Kconfig    |   25 -
 drivers/staging/zram/Makefile   |    3 -
 drivers/staging/zram/zram.txt   |   77 ---
 drivers/staging/zram/zram_drv.c |  994 ---------------------------------------
 drivers/staging/zram/zram_drv.h |  124 -----
 14 files changed, 1226 insertions(+), 1226 deletions(-)
 create mode 100644 Documentation/blockdev/zram.txt
 create mode 100644 drivers/block/zram/Kconfig
 create mode 100644 drivers/block/zram/Makefile
 create mode 100644 drivers/block/zram/zram_drv.c
 create mode 100644 drivers/block/zram/zram_drv.h
 delete mode 100644 drivers/staging/zram/Kconfig
 delete mode 100644 drivers/staging/zram/Makefile
 delete mode 100644 drivers/staging/zram/zram.txt
 delete mode 100644 drivers/staging/zram/zram_drv.c
 delete mode 100644 drivers/staging/zram/zram_drv.h

diff --git a/Documentation/blockdev/zram.txt b/Documentation/blockdev/zram.txt
new file mode 100644
index 000000000000..765d790ae831
--- /dev/null
+++ b/Documentation/blockdev/zram.txt
@@ -0,0 +1,77 @@
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
+2) Set Disksize
+        Set disk size by writing the value to sysfs node 'disksize'.
+        The value can be either in bytes or you can use mem suffixes.
+        Examples:
+            # Initialize /dev/zram0 with 50MB disksize
+            echo $((50*1024*1024)) > /sys/block/zram0/disksize
+
+            # Using mem suffixes
+            echo 256K > /sys/block/zram0/disksize
+            echo 512M > /sys/block/zram0/disksize
+            echo 1G > /sys/block/zram0/disksize
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
+	This frees all the memory allocated for the given device and
+	resets the disksize to zero. You must set the disksize again
+	before reusing the device.
+
+Please report any problems at:
+ - Mailing list: linux-mm-cc at laptop dot org
+ - Issue tracker: http://code.google.com/p/compcache/issues/list
+
+Nitin Gupta
+ngupta@vflare.org
diff --git a/drivers/block/Kconfig b/drivers/block/Kconfig
index 86b9f37d102e..28b6bf2fe886 100644
--- a/drivers/block/Kconfig
+++ b/drivers/block/Kconfig
@@ -108,6 +108,8 @@ source "drivers/block/paride/Kconfig"
 
 source "drivers/block/mtip32xx/Kconfig"
 
+source "drivers/block/zram/Kconfig"
+
 config BLK_CPQ_DA
 	tristate "Compaq SMART2 support"
 	depends on PCI && VIRT_TO_BUS && 0
diff --git a/drivers/block/Makefile b/drivers/block/Makefile
index 816d979c3266..02b688d1438d 100644
--- a/drivers/block/Makefile
+++ b/drivers/block/Makefile
@@ -42,6 +42,7 @@ obj-$(CONFIG_BLK_DEV_PCIESSD_MTIP32XX)	+= mtip32xx/
 
 obj-$(CONFIG_BLK_DEV_RSXX) += rsxx/
 obj-$(CONFIG_BLK_DEV_NULL_BLK)	+= null_blk.o
+obj-$(CONFIG_ZRAM) += zram/
 
 nvme-y		:= nvme-core.o nvme-scsi.o
 skd-y		:= skd_main.o
diff --git a/drivers/block/zram/Kconfig b/drivers/block/zram/Kconfig
new file mode 100644
index 000000000000..983314c41349
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
+	  Project home: <https://compcache.googlecode.com/>
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
index 000000000000..cb0f9ced6a93
--- /dev/null
+++ b/drivers/block/zram/Makefile
@@ -0,0 +1,3 @@
+zram-y	:=	zram_drv.o
+
+obj-$(CONFIG_ZRAM)	+=	zram.o
diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
new file mode 100644
index 000000000000..108f2733106d
--- /dev/null
+++ b/drivers/block/zram/zram_drv.c
@@ -0,0 +1,994 @@
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
+static struct zram *zram_devices;
+
+/* Module params (documentation at end) */
+static unsigned int num_devices = 1;
+
+static inline struct zram *dev_to_zram(struct device *dev)
+{
+	return (struct zram *)dev_to_disk(dev)->private_data;
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
+static ssize_t initstate_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct zram *zram = dev_to_zram(dev);
+
+	return sprintf(buf, "%u\n", zram->init_done);
+}
+
+static ssize_t num_reads_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct zram *zram = dev_to_zram(dev);
+
+	return sprintf(buf, "%llu\n",
+			(u64)atomic64_read(&zram->stats.num_reads));
+}
+
+static ssize_t num_writes_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct zram *zram = dev_to_zram(dev);
+
+	return sprintf(buf, "%llu\n",
+			(u64)atomic64_read(&zram->stats.num_writes));
+}
+
+static ssize_t invalid_io_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct zram *zram = dev_to_zram(dev);
+
+	return sprintf(buf, "%llu\n",
+			(u64)atomic64_read(&zram->stats.invalid_io));
+}
+
+static ssize_t notify_free_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct zram *zram = dev_to_zram(dev);
+
+	return sprintf(buf, "%llu\n",
+			(u64)atomic64_read(&zram->stats.notify_free));
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
+			(u64)atomic64_read(&zram->stats.compr_size));
+}
+
+static ssize_t mem_used_total_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	u64 val = 0;
+	struct zram *zram = dev_to_zram(dev);
+	struct zram_meta *meta = zram->meta;
+
+	down_read(&zram->init_lock);
+	if (zram->init_done)
+		val = zs_get_total_size_bytes(meta->mem_pool);
+	up_read(&zram->init_lock);
+
+	return sprintf(buf, "%llu\n", val);
+}
+
+static int zram_test_flag(struct zram_meta *meta, u32 index,
+			enum zram_pageflags flag)
+{
+	return meta->table[index].flags & BIT(flag);
+}
+
+static void zram_set_flag(struct zram_meta *meta, u32 index,
+			enum zram_pageflags flag)
+{
+	meta->table[index].flags |= BIT(flag);
+}
+
+static void zram_clear_flag(struct zram_meta *meta, u32 index,
+			enum zram_pageflags flag)
+{
+	meta->table[index].flags &= ~BIT(flag);
+}
+
+static inline int is_partial_io(struct bio_vec *bvec)
+{
+	return bvec->bv_len != PAGE_SIZE;
+}
+
+/*
+ * Check if request is within bounds and aligned on zram logical blocks.
+ */
+static inline int valid_io_request(struct zram *zram, struct bio *bio)
+{
+	u64 start, end, bound;
+
+	/* unaligned request */
+	if (unlikely(bio->bi_iter.bi_sector &
+		     (ZRAM_SECTOR_PER_LOGICAL_BLOCK - 1)))
+		return 0;
+	if (unlikely(bio->bi_iter.bi_size & (ZRAM_LOGICAL_BLOCK_SIZE - 1)))
+		return 0;
+
+	start = bio->bi_iter.bi_sector;
+	end = start + (bio->bi_iter.bi_size >> SECTOR_SHIFT);
+	bound = zram->disksize >> SECTOR_SHIFT;
+	/* out of range range */
+	if (unlikely(start >= bound || end > bound || start > end))
+		return 0;
+
+	/* I/O request is valid */
+	return 1;
+}
+
+static void zram_meta_free(struct zram_meta *meta)
+{
+	zs_destroy_pool(meta->mem_pool);
+	kfree(meta->compress_workmem);
+	free_pages((unsigned long)meta->compress_buffer, 1);
+	vfree(meta->table);
+	kfree(meta);
+}
+
+static struct zram_meta *zram_meta_alloc(u64 disksize)
+{
+	size_t num_pages;
+	struct zram_meta *meta = kmalloc(sizeof(*meta), GFP_KERNEL);
+	if (!meta)
+		goto out;
+
+	meta->compress_workmem = kzalloc(LZO1X_MEM_COMPRESS, GFP_KERNEL);
+	if (!meta->compress_workmem)
+		goto free_meta;
+
+	meta->compress_buffer =
+		(void *)__get_free_pages(GFP_KERNEL | __GFP_ZERO, 1);
+	if (!meta->compress_buffer) {
+		pr_err("Error allocating compressor buffer space\n");
+		goto free_workmem;
+	}
+
+	num_pages = disksize >> PAGE_SHIFT;
+	meta->table = vzalloc(num_pages * sizeof(*meta->table));
+	if (!meta->table) {
+		pr_err("Error allocating zram address table\n");
+		goto free_buffer;
+	}
+
+	meta->mem_pool = zs_create_pool(GFP_NOIO | __GFP_HIGHMEM);
+	if (!meta->mem_pool) {
+		pr_err("Error creating memory pool\n");
+		goto free_table;
+	}
+
+	return meta;
+
+free_table:
+	vfree(meta->table);
+free_buffer:
+	free_pages((unsigned long)meta->compress_buffer, 1);
+free_workmem:
+	kfree(meta->compress_workmem);
+free_meta:
+	kfree(meta);
+	meta = NULL;
+out:
+	return meta;
+}
+
+static void update_position(u32 *index, int *offset, struct bio_vec *bvec)
+{
+	if (*offset + bvec->bv_len >= PAGE_SIZE)
+		(*index)++;
+	*offset = (*offset + bvec->bv_len) % PAGE_SIZE;
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
+static void handle_zero_page(struct bio_vec *bvec)
+{
+	struct page *page = bvec->bv_page;
+	void *user_mem;
+
+	user_mem = kmap_atomic(page);
+	if (is_partial_io(bvec))
+		memset(user_mem + bvec->bv_offset, 0, bvec->bv_len);
+	else
+		clear_page(user_mem);
+	kunmap_atomic(user_mem);
+
+	flush_dcache_page(page);
+}
+
+static void zram_free_page(struct zram *zram, size_t index)
+{
+	struct zram_meta *meta = zram->meta;
+	unsigned long handle = meta->table[index].handle;
+	u16 size = meta->table[index].size;
+
+	if (unlikely(!handle)) {
+		/*
+		 * No memory is allocated for zero filled pages.
+		 * Simply clear zero page flag.
+		 */
+		if (zram_test_flag(meta, index, ZRAM_ZERO)) {
+			zram_clear_flag(meta, index, ZRAM_ZERO);
+			zram->stats.pages_zero--;
+		}
+		return;
+	}
+
+	if (unlikely(size > max_zpage_size))
+		zram->stats.bad_compress--;
+
+	zs_free(meta->mem_pool, handle);
+
+	if (size <= PAGE_SIZE / 2)
+		zram->stats.good_compress--;
+
+	atomic64_sub(meta->table[index].size, &zram->stats.compr_size);
+	zram->stats.pages_stored--;
+
+	meta->table[index].handle = 0;
+	meta->table[index].size = 0;
+}
+
+static int zram_decompress_page(struct zram *zram, char *mem, u32 index)
+{
+	int ret = LZO_E_OK;
+	size_t clen = PAGE_SIZE;
+	unsigned char *cmem;
+	struct zram_meta *meta = zram->meta;
+	unsigned long handle = meta->table[index].handle;
+
+	if (!handle || zram_test_flag(meta, index, ZRAM_ZERO)) {
+		clear_page(mem);
+		return 0;
+	}
+
+	cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_RO);
+	if (meta->table[index].size == PAGE_SIZE)
+		copy_page(mem, cmem);
+	else
+		ret = lzo1x_decompress_safe(cmem, meta->table[index].size,
+						mem, &clen);
+	zs_unmap_object(meta->mem_pool, handle);
+
+	/* Should NEVER happen. Return bio error if it does. */
+	if (unlikely(ret != LZO_E_OK)) {
+		pr_err("Decompression failed! err=%d, page=%u\n", ret, index);
+		atomic64_inc(&zram->stats.failed_reads);
+		return ret;
+	}
+
+	return 0;
+}
+
+static int zram_bvec_read(struct zram *zram, struct bio_vec *bvec,
+			  u32 index, int offset, struct bio *bio)
+{
+	int ret;
+	struct page *page;
+	unsigned char *user_mem, *uncmem = NULL;
+	struct zram_meta *meta = zram->meta;
+	page = bvec->bv_page;
+
+	if (unlikely(!meta->table[index].handle) ||
+			zram_test_flag(meta, index, ZRAM_ZERO)) {
+		handle_zero_page(bvec);
+		return 0;
+	}
+
+	if (is_partial_io(bvec))
+		/* Use  a temporary buffer to decompress the page */
+		uncmem = kmalloc(PAGE_SIZE, GFP_NOIO);
+
+	user_mem = kmap_atomic(page);
+	if (!is_partial_io(bvec))
+		uncmem = user_mem;
+
+	if (!uncmem) {
+		pr_info("Unable to allocate temp memory\n");
+		ret = -ENOMEM;
+		goto out_cleanup;
+	}
+
+	ret = zram_decompress_page(zram, uncmem, index);
+	/* Should NEVER happen. Return bio error if it does. */
+	if (unlikely(ret != LZO_E_OK))
+		goto out_cleanup;
+
+	if (is_partial_io(bvec))
+		memcpy(user_mem + bvec->bv_offset, uncmem + offset,
+				bvec->bv_len);
+
+	flush_dcache_page(page);
+	ret = 0;
+out_cleanup:
+	kunmap_atomic(user_mem);
+	if (is_partial_io(bvec))
+		kfree(uncmem);
+	return ret;
+}
+
+static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
+			   int offset)
+{
+	int ret = 0;
+	size_t clen;
+	unsigned long handle;
+	struct page *page;
+	unsigned char *user_mem, *cmem, *src, *uncmem = NULL;
+	struct zram_meta *meta = zram->meta;
+
+	page = bvec->bv_page;
+	src = meta->compress_buffer;
+
+	if (is_partial_io(bvec)) {
+		/*
+		 * This is a partial IO. We need to read the full page
+		 * before to write the changes.
+		 */
+		uncmem = kmalloc(PAGE_SIZE, GFP_NOIO);
+		if (!uncmem) {
+			ret = -ENOMEM;
+			goto out;
+		}
+		ret = zram_decompress_page(zram, uncmem, index);
+		if (ret)
+			goto out;
+	}
+
+	user_mem = kmap_atomic(page);
+
+	if (is_partial_io(bvec)) {
+		memcpy(uncmem + offset, user_mem + bvec->bv_offset,
+		       bvec->bv_len);
+		kunmap_atomic(user_mem);
+		user_mem = NULL;
+	} else {
+		uncmem = user_mem;
+	}
+
+	if (page_zero_filled(uncmem)) {
+		kunmap_atomic(user_mem);
+		/* Free memory associated with this sector now. */
+		zram_free_page(zram, index);
+
+		zram->stats.pages_zero++;
+		zram_set_flag(meta, index, ZRAM_ZERO);
+		ret = 0;
+		goto out;
+	}
+
+	/*
+	 * zram_slot_free_notify could miss free so that let's
+	 * double check.
+	 */
+	if (unlikely(meta->table[index].handle ||
+			zram_test_flag(meta, index, ZRAM_ZERO)))
+		zram_free_page(zram, index);
+
+	ret = lzo1x_1_compress(uncmem, PAGE_SIZE, src, &clen,
+			       meta->compress_workmem);
+
+	if (!is_partial_io(bvec)) {
+		kunmap_atomic(user_mem);
+		user_mem = NULL;
+		uncmem = NULL;
+	}
+
+	if (unlikely(ret != LZO_E_OK)) {
+		pr_err("Compression failed! err=%d\n", ret);
+		goto out;
+	}
+
+	if (unlikely(clen > max_zpage_size)) {
+		zram->stats.bad_compress++;
+		clen = PAGE_SIZE;
+		src = NULL;
+		if (is_partial_io(bvec))
+			src = uncmem;
+	}
+
+	handle = zs_malloc(meta->mem_pool, clen);
+	if (!handle) {
+		pr_info("Error allocating memory for compressed page: %u, size=%zu\n",
+			index, clen);
+		ret = -ENOMEM;
+		goto out;
+	}
+	cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_WO);
+
+	if ((clen == PAGE_SIZE) && !is_partial_io(bvec)) {
+		src = kmap_atomic(page);
+		copy_page(cmem, src);
+		kunmap_atomic(src);
+	} else {
+		memcpy(cmem, src, clen);
+	}
+
+	zs_unmap_object(meta->mem_pool, handle);
+
+	/*
+	 * Free memory associated with this sector
+	 * before overwriting unused sectors.
+	 */
+	zram_free_page(zram, index);
+
+	meta->table[index].handle = handle;
+	meta->table[index].size = clen;
+
+	/* Update stats */
+	atomic64_add(clen, &zram->stats.compr_size);
+	zram->stats.pages_stored++;
+	if (clen <= PAGE_SIZE / 2)
+		zram->stats.good_compress++;
+
+out:
+	if (is_partial_io(bvec))
+		kfree(uncmem);
+
+	if (ret)
+		atomic64_inc(&zram->stats.failed_writes);
+	return ret;
+}
+
+static void handle_pending_slot_free(struct zram *zram)
+{
+	struct zram_slot_free *free_rq;
+
+	spin_lock(&zram->slot_free_lock);
+	while (zram->slot_free_rq) {
+		free_rq = zram->slot_free_rq;
+		zram->slot_free_rq = free_rq->next;
+		zram_free_page(zram, free_rq->index);
+		kfree(free_rq);
+	}
+	spin_unlock(&zram->slot_free_lock);
+}
+
+static int zram_bvec_rw(struct zram *zram, struct bio_vec *bvec, u32 index,
+			int offset, struct bio *bio, int rw)
+{
+	int ret;
+
+	if (rw == READ) {
+		down_read(&zram->lock);
+		handle_pending_slot_free(zram);
+		ret = zram_bvec_read(zram, bvec, index, offset, bio);
+		up_read(&zram->lock);
+	} else {
+		down_write(&zram->lock);
+		handle_pending_slot_free(zram);
+		ret = zram_bvec_write(zram, bvec, index, offset);
+		up_write(&zram->lock);
+	}
+
+	return ret;
+}
+
+static void zram_reset_device(struct zram *zram, bool reset_capacity)
+{
+	size_t index;
+	struct zram_meta *meta;
+
+	flush_work(&zram->free_work);
+
+	down_write(&zram->init_lock);
+	if (!zram->init_done) {
+		up_write(&zram->init_lock);
+		return;
+	}
+
+	meta = zram->meta;
+	zram->init_done = 0;
+
+	/* Free all pages that are still in this zram device */
+	for (index = 0; index < zram->disksize >> PAGE_SHIFT; index++) {
+		unsigned long handle = meta->table[index].handle;
+		if (!handle)
+			continue;
+
+		zs_free(meta->mem_pool, handle);
+	}
+
+	zram_meta_free(zram->meta);
+	zram->meta = NULL;
+	/* Reset stats */
+	memset(&zram->stats, 0, sizeof(zram->stats));
+
+	zram->disksize = 0;
+	if (reset_capacity)
+		set_capacity(zram->disk, 0);
+	up_write(&zram->init_lock);
+}
+
+static void zram_init_device(struct zram *zram, struct zram_meta *meta)
+{
+	if (zram->disksize > 2 * (totalram_pages << PAGE_SHIFT)) {
+		pr_info(
+		"There is little point creating a zram of greater than "
+		"twice the size of memory since we expect a 2:1 compression "
+		"ratio. Note that zram uses about 0.1%% of the size of "
+		"the disk when not in use so a huge zram is "
+		"wasteful.\n"
+		"\tMemory Size: %lu kB\n"
+		"\tSize you selected: %llu kB\n"
+		"Continuing anyway ...\n",
+		(totalram_pages << PAGE_SHIFT) >> 10, zram->disksize >> 10
+		);
+	}
+
+	/* zram devices sort of resembles non-rotational disks */
+	queue_flag_set_unlocked(QUEUE_FLAG_NONROT, zram->disk->queue);
+
+	zram->meta = meta;
+	zram->init_done = 1;
+
+	pr_debug("Initialization done!\n");
+}
+
+static ssize_t disksize_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t len)
+{
+	u64 disksize;
+	struct zram_meta *meta;
+	struct zram *zram = dev_to_zram(dev);
+
+	disksize = memparse(buf, NULL);
+	if (!disksize)
+		return -EINVAL;
+
+	disksize = PAGE_ALIGN(disksize);
+	meta = zram_meta_alloc(disksize);
+	down_write(&zram->init_lock);
+	if (zram->init_done) {
+		up_write(&zram->init_lock);
+		zram_meta_free(meta);
+		pr_info("Cannot change disksize for initialized device\n");
+		return -EBUSY;
+	}
+
+	zram->disksize = disksize;
+	set_capacity(zram->disk, zram->disksize >> SECTOR_SHIFT);
+	zram_init_device(zram, meta);
+	up_write(&zram->init_lock);
+
+	return len;
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
+	if (!bdev)
+		return -ENOMEM;
+
+	/* Do not reset an active device! */
+	if (bdev->bd_holders) {
+		ret = -EBUSY;
+		goto out;
+	}
+
+	ret = kstrtou16(buf, 10, &do_reset);
+	if (ret)
+		goto out;
+
+	if (!do_reset) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	/* Make sure all pending I/O is finished */
+	fsync_bdev(bdev);
+	bdput(bdev);
+
+	zram_reset_device(zram, true);
+	return len;
+
+out:
+	bdput(bdev);
+	return ret;
+}
+
+static void __zram_make_request(struct zram *zram, struct bio *bio, int rw)
+{
+	int offset;
+	u32 index;
+	struct bio_vec bvec;
+	struct bvec_iter iter;
+
+	switch (rw) {
+	case READ:
+		atomic64_inc(&zram->stats.num_reads);
+		break;
+	case WRITE:
+		atomic64_inc(&zram->stats.num_writes);
+		break;
+	}
+
+	index = bio->bi_iter.bi_sector >> SECTORS_PER_PAGE_SHIFT;
+	offset = (bio->bi_iter.bi_sector &
+		  (SECTORS_PER_PAGE - 1)) << SECTOR_SHIFT;
+
+	bio_for_each_segment(bvec, bio, iter) {
+		int max_transfer_size = PAGE_SIZE - offset;
+
+		if (bvec.bv_len > max_transfer_size) {
+			/*
+			 * zram_bvec_rw() can only make operation on a single
+			 * zram page. Split the bio vector.
+			 */
+			struct bio_vec bv;
+
+			bv.bv_page = bvec.bv_page;
+			bv.bv_len = max_transfer_size;
+			bv.bv_offset = bvec.bv_offset;
+
+			if (zram_bvec_rw(zram, &bv, index, offset, bio, rw) < 0)
+				goto out;
+
+			bv.bv_len = bvec.bv_len - max_transfer_size;
+			bv.bv_offset += max_transfer_size;
+			if (zram_bvec_rw(zram, &bv, index+1, 0, bio, rw) < 0)
+				goto out;
+		} else
+			if (zram_bvec_rw(zram, &bvec, index, offset, bio, rw)
+			    < 0)
+				goto out;
+
+		update_position(&index, &offset, &bvec);
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
+ * Handler function for all zram I/O requests.
+ */
+static void zram_make_request(struct request_queue *queue, struct bio *bio)
+{
+	struct zram *zram = queue->queuedata;
+
+	down_read(&zram->init_lock);
+	if (unlikely(!zram->init_done))
+		goto error;
+
+	if (!valid_io_request(zram, bio)) {
+		atomic64_inc(&zram->stats.invalid_io);
+		goto error;
+	}
+
+	__zram_make_request(zram, bio, bio_data_dir(bio));
+	up_read(&zram->init_lock);
+
+	return;
+
+error:
+	up_read(&zram->init_lock);
+	bio_io_error(bio);
+}
+
+static void zram_slot_free(struct work_struct *work)
+{
+	struct zram *zram;
+
+	zram = container_of(work, struct zram, free_work);
+	down_write(&zram->lock);
+	handle_pending_slot_free(zram);
+	up_write(&zram->lock);
+}
+
+static void add_slot_free(struct zram *zram, struct zram_slot_free *free_rq)
+{
+	spin_lock(&zram->slot_free_lock);
+	free_rq->next = zram->slot_free_rq;
+	zram->slot_free_rq = free_rq;
+	spin_unlock(&zram->slot_free_lock);
+}
+
+static void zram_slot_free_notify(struct block_device *bdev,
+				unsigned long index)
+{
+	struct zram *zram;
+	struct zram_slot_free *free_rq;
+
+	zram = bdev->bd_disk->private_data;
+	atomic64_inc(&zram->stats.notify_free);
+
+	free_rq = kmalloc(sizeof(struct zram_slot_free), GFP_ATOMIC);
+	if (!free_rq)
+		return;
+
+	free_rq->index = index;
+	add_slot_free(zram, free_rq);
+	schedule_work(&zram->free_work);
+}
+
+static const struct block_device_operations zram_devops = {
+	.swap_slot_free_notify = zram_slot_free_notify,
+	.owner = THIS_MODULE
+};
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
+static struct attribute_group zram_disk_attr_group = {
+	.attrs = zram_disk_attrs,
+};
+
+static int create_device(struct zram *zram, int device_id)
+{
+	int ret = -ENOMEM;
+
+	init_rwsem(&zram->lock);
+	init_rwsem(&zram->init_lock);
+
+	INIT_WORK(&zram->free_work, zram_slot_free);
+	spin_lock_init(&zram->slot_free_lock);
+	zram->slot_free_rq = NULL;
+
+	zram->queue = blk_alloc_queue(GFP_KERNEL);
+	if (!zram->queue) {
+		pr_err("Error allocating disk queue for device %d\n",
+			device_id);
+		goto out;
+	}
+
+	blk_queue_make_request(zram->queue, zram_make_request);
+	zram->queue->queuedata = zram;
+
+	 /* gendisk structure */
+	zram->disk = alloc_disk(1);
+	if (!zram->disk) {
+		pr_warn("Error allocating disk structure for device %d\n",
+			device_id);
+		goto out_free_queue;
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
+		goto out_free_disk;
+	}
+
+	zram->init_done = 0;
+	return 0;
+
+out_free_disk:
+	del_gendisk(zram->disk);
+	put_disk(zram->disk);
+out_free_queue:
+	blk_cleanup_queue(zram->queue);
+out:
+	return ret;
+}
+
+static void destroy_device(struct zram *zram)
+{
+	sysfs_remove_group(&disk_to_dev(zram->disk)->kobj,
+			&zram_disk_attr_group);
+
+	del_gendisk(zram->disk);
+	put_disk(zram->disk);
+
+	blk_cleanup_queue(zram->queue);
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
+	/* Allocate the device array and initialize each one */
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
+	pr_info("Created %u device(s) ...\n", num_devices);
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
+		/*
+		 * Shouldn't access zram->disk after destroy_device
+		 * because destroy_device already released zram->disk.
+		 */
+		zram_reset_device(zram, false);
+	}
+
+	unregister_blkdev(zram_major, "zram");
+
+	kfree(zram_devices);
+	pr_debug("Cleanup done!\n");
+}
+
+module_init(zram_init);
+module_exit(zram_exit);
+
+module_param(num_devices, uint, 0);
+MODULE_PARM_DESC(num_devices, "Number of zram devices");
+
+MODULE_LICENSE("Dual BSD/GPL");
+MODULE_AUTHOR("Nitin Gupta <ngupta@vflare.org>");
+MODULE_DESCRIPTION("Compressed RAM Block Device");
diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
new file mode 100644
index 000000000000..d8f6596513c3
--- /dev/null
+++ b/drivers/block/zram/zram_drv.h
@@ -0,0 +1,124 @@
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
+/*
+ * Pages that compress to size greater than this are stored
+ * uncompressed in memory.
+ */
+static const size_t max_zpage_size = PAGE_SIZE / 4 * 3;
+
+/*
+ * NOTE: max_zpage_size must be less than or equal to:
+ *   ZS_MAX_ALLOC_SIZE. Otherwise, zs_malloc() would
+ * always return failure.
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
+/*
+ * All 64bit fields should only be manipulated by 64bit atomic accessors.
+ * All modifications to 32bit counter should be protected by zram->lock.
+ */
+struct zram_stats {
+	atomic64_t compr_size;	/* compressed size of pages stored */
+	atomic64_t num_reads;	/* failed + successful */
+	atomic64_t num_writes;	/* --do-- */
+	atomic64_t failed_reads;	/* should NEVER! happen */
+	atomic64_t failed_writes;	/* can happen when memory is too low */
+	atomic64_t invalid_io;	/* non-page-aligned I/O requests */
+	atomic64_t notify_free;	/* no. of swap slot free notifications */
+	u32 pages_zero;		/* no. of zero filled pages */
+	u32 pages_stored;	/* no. of pages currently stored */
+	u32 good_compress;	/* % of pages with compression ratio<=50% */
+	u32 bad_compress;	/* % of pages with compression ratio>=75% */
+};
+
+struct zram_meta {
+	void *compress_workmem;
+	void *compress_buffer;
+	struct table *table;
+	struct zs_pool *mem_pool;
+};
+
+struct zram_slot_free {
+	unsigned long index;
+	struct zram_slot_free *next;
+};
+
+struct zram {
+	struct zram_meta *meta;
+	struct rw_semaphore lock; /* protect compression buffers, table,
+				   * 32bit stat counters against concurrent
+				   * notifications, reads and writes */
+
+	struct work_struct free_work;  /* handle pending free request */
+	struct zram_slot_free *slot_free_rq; /* list head of free request */
+
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
+	spinlock_t slot_free_lock;
+
+	struct zram_stats stats;
+};
+#endif
diff --git a/drivers/staging/Kconfig b/drivers/staging/Kconfig
index f113e674edeb..03dad89dbf3d 100644
--- a/drivers/staging/Kconfig
+++ b/drivers/staging/Kconfig
@@ -76,8 +76,6 @@ source "drivers/staging/sep/Kconfig"
 
 source "drivers/staging/iio/Kconfig"
 
-source "drivers/staging/zram/Kconfig"
-
 source "drivers/staging/wlags49_h2/Kconfig"
 
 source "drivers/staging/wlags49_h25/Kconfig"
diff --git a/drivers/staging/Makefile b/drivers/staging/Makefile
index acda4f5491f4..66a8d01823b4 100644
--- a/drivers/staging/Makefile
+++ b/drivers/staging/Makefile
@@ -32,7 +32,6 @@ obj-$(CONFIG_VT6656)		+= vt6656/
 obj-$(CONFIG_VME_BUS)		+= vme/
 obj-$(CONFIG_DX_SEP)            += sep/
 obj-$(CONFIG_IIO)		+= iio/
-obj-$(CONFIG_ZRAM)		+= zram/
 obj-$(CONFIG_WLAGS49_H2)	+= wlags49_h2/
 obj-$(CONFIG_WLAGS49_H25)	+= wlags49_h25/
 obj-$(CONFIG_FB_SM7XX)		+= sm7xxfb/
diff --git a/drivers/staging/zram/Kconfig b/drivers/staging/zram/Kconfig
deleted file mode 100644
index 983314c41349..000000000000
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
-	  Project home: <https://compcache.googlecode.com/>
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
index cb0f9ced6a93..000000000000
--- a/drivers/staging/zram/Makefile
+++ /dev/null
@@ -1,3 +0,0 @@
-zram-y	:=	zram_drv.o
-
-obj-$(CONFIG_ZRAM)	+=	zram.o
diff --git a/drivers/staging/zram/zram.txt b/drivers/staging/zram/zram.txt
deleted file mode 100644
index 765d790ae831..000000000000
--- a/drivers/staging/zram/zram.txt
+++ /dev/null
@@ -1,77 +0,0 @@
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
-2) Set Disksize
-        Set disk size by writing the value to sysfs node 'disksize'.
-        The value can be either in bytes or you can use mem suffixes.
-        Examples:
-            # Initialize /dev/zram0 with 50MB disksize
-            echo $((50*1024*1024)) > /sys/block/zram0/disksize
-
-            # Using mem suffixes
-            echo 256K > /sys/block/zram0/disksize
-            echo 512M > /sys/block/zram0/disksize
-            echo 1G > /sys/block/zram0/disksize
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
-	This frees all the memory allocated for the given device and
-	resets the disksize to zero. You must set the disksize again
-	before reusing the device.
-
-Please report any problems at:
- - Mailing list: linux-mm-cc at laptop dot org
- - Issue tracker: http://code.google.com/p/compcache/issues/list
-
-Nitin Gupta
-ngupta@vflare.org
diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
deleted file mode 100644
index 108f2733106d..000000000000
--- a/drivers/staging/zram/zram_drv.c
+++ /dev/null
@@ -1,994 +0,0 @@
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
-static struct zram *zram_devices;
-
-/* Module params (documentation at end) */
-static unsigned int num_devices = 1;
-
-static inline struct zram *dev_to_zram(struct device *dev)
-{
-	return (struct zram *)dev_to_disk(dev)->private_data;
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
-static ssize_t initstate_show(struct device *dev,
-		struct device_attribute *attr, char *buf)
-{
-	struct zram *zram = dev_to_zram(dev);
-
-	return sprintf(buf, "%u\n", zram->init_done);
-}
-
-static ssize_t num_reads_show(struct device *dev,
-		struct device_attribute *attr, char *buf)
-{
-	struct zram *zram = dev_to_zram(dev);
-
-	return sprintf(buf, "%llu\n",
-			(u64)atomic64_read(&zram->stats.num_reads));
-}
-
-static ssize_t num_writes_show(struct device *dev,
-		struct device_attribute *attr, char *buf)
-{
-	struct zram *zram = dev_to_zram(dev);
-
-	return sprintf(buf, "%llu\n",
-			(u64)atomic64_read(&zram->stats.num_writes));
-}
-
-static ssize_t invalid_io_show(struct device *dev,
-		struct device_attribute *attr, char *buf)
-{
-	struct zram *zram = dev_to_zram(dev);
-
-	return sprintf(buf, "%llu\n",
-			(u64)atomic64_read(&zram->stats.invalid_io));
-}
-
-static ssize_t notify_free_show(struct device *dev,
-		struct device_attribute *attr, char *buf)
-{
-	struct zram *zram = dev_to_zram(dev);
-
-	return sprintf(buf, "%llu\n",
-			(u64)atomic64_read(&zram->stats.notify_free));
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
-			(u64)atomic64_read(&zram->stats.compr_size));
-}
-
-static ssize_t mem_used_total_show(struct device *dev,
-		struct device_attribute *attr, char *buf)
-{
-	u64 val = 0;
-	struct zram *zram = dev_to_zram(dev);
-	struct zram_meta *meta = zram->meta;
-
-	down_read(&zram->init_lock);
-	if (zram->init_done)
-		val = zs_get_total_size_bytes(meta->mem_pool);
-	up_read(&zram->init_lock);
-
-	return sprintf(buf, "%llu\n", val);
-}
-
-static int zram_test_flag(struct zram_meta *meta, u32 index,
-			enum zram_pageflags flag)
-{
-	return meta->table[index].flags & BIT(flag);
-}
-
-static void zram_set_flag(struct zram_meta *meta, u32 index,
-			enum zram_pageflags flag)
-{
-	meta->table[index].flags |= BIT(flag);
-}
-
-static void zram_clear_flag(struct zram_meta *meta, u32 index,
-			enum zram_pageflags flag)
-{
-	meta->table[index].flags &= ~BIT(flag);
-}
-
-static inline int is_partial_io(struct bio_vec *bvec)
-{
-	return bvec->bv_len != PAGE_SIZE;
-}
-
-/*
- * Check if request is within bounds and aligned on zram logical blocks.
- */
-static inline int valid_io_request(struct zram *zram, struct bio *bio)
-{
-	u64 start, end, bound;
-
-	/* unaligned request */
-	if (unlikely(bio->bi_iter.bi_sector &
-		     (ZRAM_SECTOR_PER_LOGICAL_BLOCK - 1)))
-		return 0;
-	if (unlikely(bio->bi_iter.bi_size & (ZRAM_LOGICAL_BLOCK_SIZE - 1)))
-		return 0;
-
-	start = bio->bi_iter.bi_sector;
-	end = start + (bio->bi_iter.bi_size >> SECTOR_SHIFT);
-	bound = zram->disksize >> SECTOR_SHIFT;
-	/* out of range range */
-	if (unlikely(start >= bound || end > bound || start > end))
-		return 0;
-
-	/* I/O request is valid */
-	return 1;
-}
-
-static void zram_meta_free(struct zram_meta *meta)
-{
-	zs_destroy_pool(meta->mem_pool);
-	kfree(meta->compress_workmem);
-	free_pages((unsigned long)meta->compress_buffer, 1);
-	vfree(meta->table);
-	kfree(meta);
-}
-
-static struct zram_meta *zram_meta_alloc(u64 disksize)
-{
-	size_t num_pages;
-	struct zram_meta *meta = kmalloc(sizeof(*meta), GFP_KERNEL);
-	if (!meta)
-		goto out;
-
-	meta->compress_workmem = kzalloc(LZO1X_MEM_COMPRESS, GFP_KERNEL);
-	if (!meta->compress_workmem)
-		goto free_meta;
-
-	meta->compress_buffer =
-		(void *)__get_free_pages(GFP_KERNEL | __GFP_ZERO, 1);
-	if (!meta->compress_buffer) {
-		pr_err("Error allocating compressor buffer space\n");
-		goto free_workmem;
-	}
-
-	num_pages = disksize >> PAGE_SHIFT;
-	meta->table = vzalloc(num_pages * sizeof(*meta->table));
-	if (!meta->table) {
-		pr_err("Error allocating zram address table\n");
-		goto free_buffer;
-	}
-
-	meta->mem_pool = zs_create_pool(GFP_NOIO | __GFP_HIGHMEM);
-	if (!meta->mem_pool) {
-		pr_err("Error creating memory pool\n");
-		goto free_table;
-	}
-
-	return meta;
-
-free_table:
-	vfree(meta->table);
-free_buffer:
-	free_pages((unsigned long)meta->compress_buffer, 1);
-free_workmem:
-	kfree(meta->compress_workmem);
-free_meta:
-	kfree(meta);
-	meta = NULL;
-out:
-	return meta;
-}
-
-static void update_position(u32 *index, int *offset, struct bio_vec *bvec)
-{
-	if (*offset + bvec->bv_len >= PAGE_SIZE)
-		(*index)++;
-	*offset = (*offset + bvec->bv_len) % PAGE_SIZE;
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
-static void handle_zero_page(struct bio_vec *bvec)
-{
-	struct page *page = bvec->bv_page;
-	void *user_mem;
-
-	user_mem = kmap_atomic(page);
-	if (is_partial_io(bvec))
-		memset(user_mem + bvec->bv_offset, 0, bvec->bv_len);
-	else
-		clear_page(user_mem);
-	kunmap_atomic(user_mem);
-
-	flush_dcache_page(page);
-}
-
-static void zram_free_page(struct zram *zram, size_t index)
-{
-	struct zram_meta *meta = zram->meta;
-	unsigned long handle = meta->table[index].handle;
-	u16 size = meta->table[index].size;
-
-	if (unlikely(!handle)) {
-		/*
-		 * No memory is allocated for zero filled pages.
-		 * Simply clear zero page flag.
-		 */
-		if (zram_test_flag(meta, index, ZRAM_ZERO)) {
-			zram_clear_flag(meta, index, ZRAM_ZERO);
-			zram->stats.pages_zero--;
-		}
-		return;
-	}
-
-	if (unlikely(size > max_zpage_size))
-		zram->stats.bad_compress--;
-
-	zs_free(meta->mem_pool, handle);
-
-	if (size <= PAGE_SIZE / 2)
-		zram->stats.good_compress--;
-
-	atomic64_sub(meta->table[index].size, &zram->stats.compr_size);
-	zram->stats.pages_stored--;
-
-	meta->table[index].handle = 0;
-	meta->table[index].size = 0;
-}
-
-static int zram_decompress_page(struct zram *zram, char *mem, u32 index)
-{
-	int ret = LZO_E_OK;
-	size_t clen = PAGE_SIZE;
-	unsigned char *cmem;
-	struct zram_meta *meta = zram->meta;
-	unsigned long handle = meta->table[index].handle;
-
-	if (!handle || zram_test_flag(meta, index, ZRAM_ZERO)) {
-		clear_page(mem);
-		return 0;
-	}
-
-	cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_RO);
-	if (meta->table[index].size == PAGE_SIZE)
-		copy_page(mem, cmem);
-	else
-		ret = lzo1x_decompress_safe(cmem, meta->table[index].size,
-						mem, &clen);
-	zs_unmap_object(meta->mem_pool, handle);
-
-	/* Should NEVER happen. Return bio error if it does. */
-	if (unlikely(ret != LZO_E_OK)) {
-		pr_err("Decompression failed! err=%d, page=%u\n", ret, index);
-		atomic64_inc(&zram->stats.failed_reads);
-		return ret;
-	}
-
-	return 0;
-}
-
-static int zram_bvec_read(struct zram *zram, struct bio_vec *bvec,
-			  u32 index, int offset, struct bio *bio)
-{
-	int ret;
-	struct page *page;
-	unsigned char *user_mem, *uncmem = NULL;
-	struct zram_meta *meta = zram->meta;
-	page = bvec->bv_page;
-
-	if (unlikely(!meta->table[index].handle) ||
-			zram_test_flag(meta, index, ZRAM_ZERO)) {
-		handle_zero_page(bvec);
-		return 0;
-	}
-
-	if (is_partial_io(bvec))
-		/* Use  a temporary buffer to decompress the page */
-		uncmem = kmalloc(PAGE_SIZE, GFP_NOIO);
-
-	user_mem = kmap_atomic(page);
-	if (!is_partial_io(bvec))
-		uncmem = user_mem;
-
-	if (!uncmem) {
-		pr_info("Unable to allocate temp memory\n");
-		ret = -ENOMEM;
-		goto out_cleanup;
-	}
-
-	ret = zram_decompress_page(zram, uncmem, index);
-	/* Should NEVER happen. Return bio error if it does. */
-	if (unlikely(ret != LZO_E_OK))
-		goto out_cleanup;
-
-	if (is_partial_io(bvec))
-		memcpy(user_mem + bvec->bv_offset, uncmem + offset,
-				bvec->bv_len);
-
-	flush_dcache_page(page);
-	ret = 0;
-out_cleanup:
-	kunmap_atomic(user_mem);
-	if (is_partial_io(bvec))
-		kfree(uncmem);
-	return ret;
-}
-
-static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
-			   int offset)
-{
-	int ret = 0;
-	size_t clen;
-	unsigned long handle;
-	struct page *page;
-	unsigned char *user_mem, *cmem, *src, *uncmem = NULL;
-	struct zram_meta *meta = zram->meta;
-
-	page = bvec->bv_page;
-	src = meta->compress_buffer;
-
-	if (is_partial_io(bvec)) {
-		/*
-		 * This is a partial IO. We need to read the full page
-		 * before to write the changes.
-		 */
-		uncmem = kmalloc(PAGE_SIZE, GFP_NOIO);
-		if (!uncmem) {
-			ret = -ENOMEM;
-			goto out;
-		}
-		ret = zram_decompress_page(zram, uncmem, index);
-		if (ret)
-			goto out;
-	}
-
-	user_mem = kmap_atomic(page);
-
-	if (is_partial_io(bvec)) {
-		memcpy(uncmem + offset, user_mem + bvec->bv_offset,
-		       bvec->bv_len);
-		kunmap_atomic(user_mem);
-		user_mem = NULL;
-	} else {
-		uncmem = user_mem;
-	}
-
-	if (page_zero_filled(uncmem)) {
-		kunmap_atomic(user_mem);
-		/* Free memory associated with this sector now. */
-		zram_free_page(zram, index);
-
-		zram->stats.pages_zero++;
-		zram_set_flag(meta, index, ZRAM_ZERO);
-		ret = 0;
-		goto out;
-	}
-
-	/*
-	 * zram_slot_free_notify could miss free so that let's
-	 * double check.
-	 */
-	if (unlikely(meta->table[index].handle ||
-			zram_test_flag(meta, index, ZRAM_ZERO)))
-		zram_free_page(zram, index);
-
-	ret = lzo1x_1_compress(uncmem, PAGE_SIZE, src, &clen,
-			       meta->compress_workmem);
-
-	if (!is_partial_io(bvec)) {
-		kunmap_atomic(user_mem);
-		user_mem = NULL;
-		uncmem = NULL;
-	}
-
-	if (unlikely(ret != LZO_E_OK)) {
-		pr_err("Compression failed! err=%d\n", ret);
-		goto out;
-	}
-
-	if (unlikely(clen > max_zpage_size)) {
-		zram->stats.bad_compress++;
-		clen = PAGE_SIZE;
-		src = NULL;
-		if (is_partial_io(bvec))
-			src = uncmem;
-	}
-
-	handle = zs_malloc(meta->mem_pool, clen);
-	if (!handle) {
-		pr_info("Error allocating memory for compressed page: %u, size=%zu\n",
-			index, clen);
-		ret = -ENOMEM;
-		goto out;
-	}
-	cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_WO);
-
-	if ((clen == PAGE_SIZE) && !is_partial_io(bvec)) {
-		src = kmap_atomic(page);
-		copy_page(cmem, src);
-		kunmap_atomic(src);
-	} else {
-		memcpy(cmem, src, clen);
-	}
-
-	zs_unmap_object(meta->mem_pool, handle);
-
-	/*
-	 * Free memory associated with this sector
-	 * before overwriting unused sectors.
-	 */
-	zram_free_page(zram, index);
-
-	meta->table[index].handle = handle;
-	meta->table[index].size = clen;
-
-	/* Update stats */
-	atomic64_add(clen, &zram->stats.compr_size);
-	zram->stats.pages_stored++;
-	if (clen <= PAGE_SIZE / 2)
-		zram->stats.good_compress++;
-
-out:
-	if (is_partial_io(bvec))
-		kfree(uncmem);
-
-	if (ret)
-		atomic64_inc(&zram->stats.failed_writes);
-	return ret;
-}
-
-static void handle_pending_slot_free(struct zram *zram)
-{
-	struct zram_slot_free *free_rq;
-
-	spin_lock(&zram->slot_free_lock);
-	while (zram->slot_free_rq) {
-		free_rq = zram->slot_free_rq;
-		zram->slot_free_rq = free_rq->next;
-		zram_free_page(zram, free_rq->index);
-		kfree(free_rq);
-	}
-	spin_unlock(&zram->slot_free_lock);
-}
-
-static int zram_bvec_rw(struct zram *zram, struct bio_vec *bvec, u32 index,
-			int offset, struct bio *bio, int rw)
-{
-	int ret;
-
-	if (rw == READ) {
-		down_read(&zram->lock);
-		handle_pending_slot_free(zram);
-		ret = zram_bvec_read(zram, bvec, index, offset, bio);
-		up_read(&zram->lock);
-	} else {
-		down_write(&zram->lock);
-		handle_pending_slot_free(zram);
-		ret = zram_bvec_write(zram, bvec, index, offset);
-		up_write(&zram->lock);
-	}
-
-	return ret;
-}
-
-static void zram_reset_device(struct zram *zram, bool reset_capacity)
-{
-	size_t index;
-	struct zram_meta *meta;
-
-	flush_work(&zram->free_work);
-
-	down_write(&zram->init_lock);
-	if (!zram->init_done) {
-		up_write(&zram->init_lock);
-		return;
-	}
-
-	meta = zram->meta;
-	zram->init_done = 0;
-
-	/* Free all pages that are still in this zram device */
-	for (index = 0; index < zram->disksize >> PAGE_SHIFT; index++) {
-		unsigned long handle = meta->table[index].handle;
-		if (!handle)
-			continue;
-
-		zs_free(meta->mem_pool, handle);
-	}
-
-	zram_meta_free(zram->meta);
-	zram->meta = NULL;
-	/* Reset stats */
-	memset(&zram->stats, 0, sizeof(zram->stats));
-
-	zram->disksize = 0;
-	if (reset_capacity)
-		set_capacity(zram->disk, 0);
-	up_write(&zram->init_lock);
-}
-
-static void zram_init_device(struct zram *zram, struct zram_meta *meta)
-{
-	if (zram->disksize > 2 * (totalram_pages << PAGE_SHIFT)) {
-		pr_info(
-		"There is little point creating a zram of greater than "
-		"twice the size of memory since we expect a 2:1 compression "
-		"ratio. Note that zram uses about 0.1%% of the size of "
-		"the disk when not in use so a huge zram is "
-		"wasteful.\n"
-		"\tMemory Size: %lu kB\n"
-		"\tSize you selected: %llu kB\n"
-		"Continuing anyway ...\n",
-		(totalram_pages << PAGE_SHIFT) >> 10, zram->disksize >> 10
-		);
-	}
-
-	/* zram devices sort of resembles non-rotational disks */
-	queue_flag_set_unlocked(QUEUE_FLAG_NONROT, zram->disk->queue);
-
-	zram->meta = meta;
-	zram->init_done = 1;
-
-	pr_debug("Initialization done!\n");
-}
-
-static ssize_t disksize_store(struct device *dev,
-		struct device_attribute *attr, const char *buf, size_t len)
-{
-	u64 disksize;
-	struct zram_meta *meta;
-	struct zram *zram = dev_to_zram(dev);
-
-	disksize = memparse(buf, NULL);
-	if (!disksize)
-		return -EINVAL;
-
-	disksize = PAGE_ALIGN(disksize);
-	meta = zram_meta_alloc(disksize);
-	down_write(&zram->init_lock);
-	if (zram->init_done) {
-		up_write(&zram->init_lock);
-		zram_meta_free(meta);
-		pr_info("Cannot change disksize for initialized device\n");
-		return -EBUSY;
-	}
-
-	zram->disksize = disksize;
-	set_capacity(zram->disk, zram->disksize >> SECTOR_SHIFT);
-	zram_init_device(zram, meta);
-	up_write(&zram->init_lock);
-
-	return len;
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
-	if (!bdev)
-		return -ENOMEM;
-
-	/* Do not reset an active device! */
-	if (bdev->bd_holders) {
-		ret = -EBUSY;
-		goto out;
-	}
-
-	ret = kstrtou16(buf, 10, &do_reset);
-	if (ret)
-		goto out;
-
-	if (!do_reset) {
-		ret = -EINVAL;
-		goto out;
-	}
-
-	/* Make sure all pending I/O is finished */
-	fsync_bdev(bdev);
-	bdput(bdev);
-
-	zram_reset_device(zram, true);
-	return len;
-
-out:
-	bdput(bdev);
-	return ret;
-}
-
-static void __zram_make_request(struct zram *zram, struct bio *bio, int rw)
-{
-	int offset;
-	u32 index;
-	struct bio_vec bvec;
-	struct bvec_iter iter;
-
-	switch (rw) {
-	case READ:
-		atomic64_inc(&zram->stats.num_reads);
-		break;
-	case WRITE:
-		atomic64_inc(&zram->stats.num_writes);
-		break;
-	}
-
-	index = bio->bi_iter.bi_sector >> SECTORS_PER_PAGE_SHIFT;
-	offset = (bio->bi_iter.bi_sector &
-		  (SECTORS_PER_PAGE - 1)) << SECTOR_SHIFT;
-
-	bio_for_each_segment(bvec, bio, iter) {
-		int max_transfer_size = PAGE_SIZE - offset;
-
-		if (bvec.bv_len > max_transfer_size) {
-			/*
-			 * zram_bvec_rw() can only make operation on a single
-			 * zram page. Split the bio vector.
-			 */
-			struct bio_vec bv;
-
-			bv.bv_page = bvec.bv_page;
-			bv.bv_len = max_transfer_size;
-			bv.bv_offset = bvec.bv_offset;
-
-			if (zram_bvec_rw(zram, &bv, index, offset, bio, rw) < 0)
-				goto out;
-
-			bv.bv_len = bvec.bv_len - max_transfer_size;
-			bv.bv_offset += max_transfer_size;
-			if (zram_bvec_rw(zram, &bv, index+1, 0, bio, rw) < 0)
-				goto out;
-		} else
-			if (zram_bvec_rw(zram, &bvec, index, offset, bio, rw)
-			    < 0)
-				goto out;
-
-		update_position(&index, &offset, &bvec);
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
- * Handler function for all zram I/O requests.
- */
-static void zram_make_request(struct request_queue *queue, struct bio *bio)
-{
-	struct zram *zram = queue->queuedata;
-
-	down_read(&zram->init_lock);
-	if (unlikely(!zram->init_done))
-		goto error;
-
-	if (!valid_io_request(zram, bio)) {
-		atomic64_inc(&zram->stats.invalid_io);
-		goto error;
-	}
-
-	__zram_make_request(zram, bio, bio_data_dir(bio));
-	up_read(&zram->init_lock);
-
-	return;
-
-error:
-	up_read(&zram->init_lock);
-	bio_io_error(bio);
-}
-
-static void zram_slot_free(struct work_struct *work)
-{
-	struct zram *zram;
-
-	zram = container_of(work, struct zram, free_work);
-	down_write(&zram->lock);
-	handle_pending_slot_free(zram);
-	up_write(&zram->lock);
-}
-
-static void add_slot_free(struct zram *zram, struct zram_slot_free *free_rq)
-{
-	spin_lock(&zram->slot_free_lock);
-	free_rq->next = zram->slot_free_rq;
-	zram->slot_free_rq = free_rq;
-	spin_unlock(&zram->slot_free_lock);
-}
-
-static void zram_slot_free_notify(struct block_device *bdev,
-				unsigned long index)
-{
-	struct zram *zram;
-	struct zram_slot_free *free_rq;
-
-	zram = bdev->bd_disk->private_data;
-	atomic64_inc(&zram->stats.notify_free);
-
-	free_rq = kmalloc(sizeof(struct zram_slot_free), GFP_ATOMIC);
-	if (!free_rq)
-		return;
-
-	free_rq->index = index;
-	add_slot_free(zram, free_rq);
-	schedule_work(&zram->free_work);
-}
-
-static const struct block_device_operations zram_devops = {
-	.swap_slot_free_notify = zram_slot_free_notify,
-	.owner = THIS_MODULE
-};
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
-static struct attribute_group zram_disk_attr_group = {
-	.attrs = zram_disk_attrs,
-};
-
-static int create_device(struct zram *zram, int device_id)
-{
-	int ret = -ENOMEM;
-
-	init_rwsem(&zram->lock);
-	init_rwsem(&zram->init_lock);
-
-	INIT_WORK(&zram->free_work, zram_slot_free);
-	spin_lock_init(&zram->slot_free_lock);
-	zram->slot_free_rq = NULL;
-
-	zram->queue = blk_alloc_queue(GFP_KERNEL);
-	if (!zram->queue) {
-		pr_err("Error allocating disk queue for device %d\n",
-			device_id);
-		goto out;
-	}
-
-	blk_queue_make_request(zram->queue, zram_make_request);
-	zram->queue->queuedata = zram;
-
-	 /* gendisk structure */
-	zram->disk = alloc_disk(1);
-	if (!zram->disk) {
-		pr_warn("Error allocating disk structure for device %d\n",
-			device_id);
-		goto out_free_queue;
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
-		goto out_free_disk;
-	}
-
-	zram->init_done = 0;
-	return 0;
-
-out_free_disk:
-	del_gendisk(zram->disk);
-	put_disk(zram->disk);
-out_free_queue:
-	blk_cleanup_queue(zram->queue);
-out:
-	return ret;
-}
-
-static void destroy_device(struct zram *zram)
-{
-	sysfs_remove_group(&disk_to_dev(zram->disk)->kobj,
-			&zram_disk_attr_group);
-
-	del_gendisk(zram->disk);
-	put_disk(zram->disk);
-
-	blk_cleanup_queue(zram->queue);
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
-	/* Allocate the device array and initialize each one */
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
-	pr_info("Created %u device(s) ...\n", num_devices);
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
-		/*
-		 * Shouldn't access zram->disk after destroy_device
-		 * because destroy_device already released zram->disk.
-		 */
-		zram_reset_device(zram, false);
-	}
-
-	unregister_blkdev(zram_major, "zram");
-
-	kfree(zram_devices);
-	pr_debug("Cleanup done!\n");
-}
-
-module_init(zram_init);
-module_exit(zram_exit);
-
-module_param(num_devices, uint, 0);
-MODULE_PARM_DESC(num_devices, "Number of zram devices");
-
-MODULE_LICENSE("Dual BSD/GPL");
-MODULE_AUTHOR("Nitin Gupta <ngupta@vflare.org>");
-MODULE_DESCRIPTION("Compressed RAM Block Device");
diff --git a/drivers/staging/zram/zram_drv.h b/drivers/staging/zram/zram_drv.h
deleted file mode 100644
index d8f6596513c3..000000000000
--- a/drivers/staging/zram/zram_drv.h
+++ /dev/null
@@ -1,124 +0,0 @@
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
-/*
- * Pages that compress to size greater than this are stored
- * uncompressed in memory.
- */
-static const size_t max_zpage_size = PAGE_SIZE / 4 * 3;
-
-/*
- * NOTE: max_zpage_size must be less than or equal to:
- *   ZS_MAX_ALLOC_SIZE. Otherwise, zs_malloc() would
- * always return failure.
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
-/*
- * All 64bit fields should only be manipulated by 64bit atomic accessors.
- * All modifications to 32bit counter should be protected by zram->lock.
- */
-struct zram_stats {
-	atomic64_t compr_size;	/* compressed size of pages stored */
-	atomic64_t num_reads;	/* failed + successful */
-	atomic64_t num_writes;	/* --do-- */
-	atomic64_t failed_reads;	/* should NEVER! happen */
-	atomic64_t failed_writes;	/* can happen when memory is too low */
-	atomic64_t invalid_io;	/* non-page-aligned I/O requests */
-	atomic64_t notify_free;	/* no. of swap slot free notifications */
-	u32 pages_zero;		/* no. of zero filled pages */
-	u32 pages_stored;	/* no. of pages currently stored */
-	u32 good_compress;	/* % of pages with compression ratio<=50% */
-	u32 bad_compress;	/* % of pages with compression ratio>=75% */
-};
-
-struct zram_meta {
-	void *compress_workmem;
-	void *compress_buffer;
-	struct table *table;
-	struct zs_pool *mem_pool;
-};
-
-struct zram_slot_free {
-	unsigned long index;
-	struct zram_slot_free *next;
-};
-
-struct zram {
-	struct zram_meta *meta;
-	struct rw_semaphore lock; /* protect compression buffers, table,
-				   * 32bit stat counters against concurrent
-				   * notifications, reads and writes */
-
-	struct work_struct free_work;  /* handle pending free request */
-	struct zram_slot_free *slot_free_rq; /* list head of free request */
-
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
-	spinlock_t slot_free_lock;
-
-	struct zram_stats stats;
-};
-#endif
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
