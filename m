Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 4755D6B0037
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 01:51:15 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v6 5/5] zram: promote zram from staging
Date: Wed, 14 Aug 2013 14:51:14 +0900
Message-Id: <1376459474-6495-6-git-send-email-minchan@kernel.org>
In-Reply-To: <1376459474-6495-1-git-send-email-minchan@kernel.org>
References: <1376459474-6495-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Luigi Semenzato <semenzato@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan@kernel.org>

Zram has lived in staging for a LONG LONG time and have been
fixed/improved by many contributors so code is clean and stable now.
Of course, there are lots of product using zram in real practice.

The major TV companys have used zram as swap since two years ago
and recently our production team released android smart phone with zram
which is used as swap, too. And there was a report Google released their
ChromeOS with zram, too and cyanogenmod have been used zram long time ago.
And I heard some disto have used zram block device for tmpfs.
In addition, I saw many report from many other peoples. For example,
Lubuntu start to use it.

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

It's time to promote it and we should accept more new features because
some enhance patches have been pended until zram complete to promote
from staging

In addition, block subsystem maintainer Jens already acked it so I guess
there is no reason to prevent zram promotion any more and it would be
one of good example to prove how staging stuffs evolve.

Acked-by: Pekka Enberg <penberg@kernel.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/block/Kconfig           |    2 +
 drivers/block/Makefile          |    1 +
 drivers/block/zram/Kconfig      |   37 ++
 drivers/block/zram/Makefile     |    3 +
 drivers/block/zram/zram.txt     |   71 +++
 drivers/block/zram/zram_drv.c   |  987 +++++++++++++++++++++++++++++++++++
 drivers/block/zram/zsmalloc.c   | 1084 +++++++++++++++++++++++++++++++++++++++
 drivers/staging/Kconfig         |    2 -
 drivers/staging/Makefile        |    1 -
 drivers/staging/zram/Kconfig    |   38 --
 drivers/staging/zram/Makefile   |    3 -
 drivers/staging/zram/zram.txt   |   77 ---
 drivers/staging/zram/zram_drv.c |  989 -----------------------------------
 drivers/staging/zram/zram_drv.h |  124 -----
 drivers/staging/zram/zsmalloc.c | 1084 ---------------------------------------
 include/linux/zram.h            |  123 +++++
 16 files changed, 2308 insertions(+), 2318 deletions(-)
 create mode 100644 drivers/block/zram/Kconfig
 create mode 100644 drivers/block/zram/Makefile
 create mode 100644 drivers/block/zram/zram.txt
 create mode 100644 drivers/block/zram/zram_drv.c
 create mode 100644 drivers/block/zram/zsmalloc.c
 delete mode 100644 drivers/staging/zram/Kconfig
 delete mode 100644 drivers/staging/zram/Makefile
 delete mode 100644 drivers/staging/zram/zram.txt
 delete mode 100644 drivers/staging/zram/zram_drv.c
 delete mode 100644 drivers/staging/zram/zram_drv.h
 delete mode 100644 drivers/staging/zram/zsmalloc.c
 create mode 100644 include/linux/zram.h

diff --git a/drivers/block/Kconfig b/drivers/block/Kconfig
index bb237c4..e5ea1ba 100644
--- a/drivers/block/Kconfig
+++ b/drivers/block/Kconfig
@@ -105,6 +105,8 @@ source "drivers/block/paride/Kconfig"
 
 source "drivers/block/mtip32xx/Kconfig"
 
+source "drivers/block/zram/Kconfig"
+
 config BLK_CPQ_DA
 	tristate "Compaq SMART2 support"
 	depends on PCI && VIRT_TO_BUS
diff --git a/drivers/block/Makefile b/drivers/block/Makefile
index 2a63ed3..d26b6de 100644
--- a/drivers/block/Makefile
+++ b/drivers/block/Makefile
@@ -29,6 +29,7 @@ obj-$(CONFIG_BLK_DEV_UMEM)	+= umem.o
 obj-$(CONFIG_BLK_DEV_NBD)	+= nbd.o
 obj-$(CONFIG_BLK_DEV_CRYPTOLOOP) += cryptoloop.o
 obj-$(CONFIG_VIRTIO_BLK)	+= virtio_blk.o
+obj-$(CONFIG_ZRAM)		+= zram/
 
 obj-$(CONFIG_VIODASD)		+= viodasd.o
 obj-$(CONFIG_BLK_DEV_SX8)	+= sx8.o
diff --git a/drivers/block/zram/Kconfig b/drivers/block/zram/Kconfig
new file mode 100644
index 0000000..0c6fae1
--- /dev/null
+++ b/drivers/block/zram/Kconfig
@@ -0,0 +1,37 @@
+config ZRAM
+	tristate "Compressed RAM block device support"
+	depends on BLOCK && SYSFS
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
+
+config ZRAM_DEBUG
+	bool "Compressed RAM block device debug support"
+	depends on ZRAM
+	default n
+	help
+	  This option adds additional debugging code to the compressed
+	  RAM block device driver.
+
+config PGTABLE_MAPPING
+	bool "Use page table mapping to access object in zsmalloc"
+	depends on ZRAM
+	help
+	  By default, zsmalloc uses a copy-based object mapping method to
+	  access allocations that span two pages. However, if a particular
+	  architecture (ex, ARM) performs VM mapping faster than copying,
+	  then you should select this. This causes zsmalloc to use page table
+	  mapping rather than copying for object mapping.
+
+	  You can check speed with zsmalloc benchmark[1].
+	  [1] https://github.com/spartacus06/zsmalloc
diff --git a/drivers/block/zram/Makefile b/drivers/block/zram/Makefile
new file mode 100644
index 0000000..8c36ddd
--- /dev/null
+++ b/drivers/block/zram/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_ZRAM) := zram.o
+
+zram-y := zram_drv.o zsmalloc.o
diff --git a/drivers/block/zram/zram.txt b/drivers/block/zram/zram.txt
new file mode 100644
index 0000000..2eccddf
--- /dev/null
+++ b/drivers/block/zram/zram.txt
@@ -0,0 +1,71 @@
+zram: Compressed RAM based block devices
+----------------------------------------
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
+Nitin Gupta
+ngupta@vflare.org
diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
new file mode 100644
index 0000000..8906ae2
--- /dev/null
+++ b/drivers/block/zram/zram_drv.c
@@ -0,0 +1,987 @@
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
+#include <linux/zram.h>
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
+	if (unlikely(bio->bi_sector & (ZRAM_SECTOR_PER_LOGICAL_BLOCK - 1)))
+		return 0;
+	if (unlikely(bio->bi_size & (ZRAM_LOGICAL_BLOCK_SIZE - 1)))
+		return 0;
+
+	start = bio->bi_sector;
+	end = start + (bio->bi_size >> SECTOR_SHIFT);
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
+	zram_reset_device(zram, true);
+	return len;
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
+		atomic64_inc(&zram->stats.num_reads);
+		break;
+	case WRITE:
+		atomic64_inc(&zram->stats.num_writes);
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
+	if (zram->disk) {
+		del_gendisk(zram->disk);
+		put_disk(zram->disk);
+	}
+
+	if (zram->queue)
+		blk_cleanup_queue(zram->queue);
+}
+
+static int __init zram_init(void)
+{
+	int ret, dev_id;
+
+	ret = zs_init();
+	if (ret)
+		return ret;
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
+	zs_exit();
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
+MODULE_ALIAS("devname:zram");
diff --git a/drivers/block/zram/zsmalloc.c b/drivers/block/zram/zsmalloc.c
new file mode 100644
index 0000000..b3a58c8
--- /dev/null
+++ b/drivers/block/zram/zsmalloc.c
@@ -0,0 +1,1084 @@
+/*
+ * zsmalloc memory allocator
+ *
+ * Copyright (C) 2011  Nitin Gupta
+ *
+ * This code is released using a dual license strategy: BSD/GPL
+ * You can choose the license that better fits your requirements.
+ *
+ * Released under the terms of 3-clause BSD License
+ * Released under the terms of GNU General Public License Version 2.0
+ */
+
+/*
+ * This allocator is designed for use with zram. Thus, the allocator is
+ * supposed to work well under low memory conditions. In particular, it
+ * never attempts higher order page allocation which is very likely to
+ * fail under memory pressure. On the other hand, if we just use single
+ * (0-order) pages, it would suffer from very high fragmentation --
+ * any object of size PAGE_SIZE/2 or larger would occupy an entire page.
+ * This was one of the major issues with its predecessor (xvmalloc).
+ *
+ * To overcome these issues, zsmalloc allocates a bunch of 0-order pages
+ * and links them together using various 'struct page' fields. These linked
+ * pages act as a single higher-order page i.e. an object can span 0-order
+ * page boundaries. The code refers to these linked pages as a single entity
+ * called zspage.
+ *
+ * For simplicity, zsmalloc can only allocate objects of size up to PAGE_SIZE
+ * since this satisfies the requirements of all its current users (in the
+ * worst case, page is incompressible and is thus stored "as-is" i.e. in
+ * uncompressed form). For allocation requests larger than this size, failure
+ * is returned (see zs_malloc).
+ *
+ * Additionally, zs_malloc() does not return a dereferenceable pointer.
+ * Instead, it returns an opaque handle (unsigned long) which encodes actual
+ * location of the allocated object. The reason for this indirection is that
+ * zsmalloc does not keep zspages permanently mapped since that would cause
+ * issues on 32-bit systems where the VA region for kernel space mappings
+ * is very small. So, before using the allocating memory, the object has to
+ * be mapped using zs_map_object() to get a usable pointer and subsequently
+ * unmapped using zs_unmap_object().
+ *
+ * Following is how we use various fields and flags of underlying
+ * struct page(s) to form a zspage.
+ *
+ * Usage of struct page fields:
+ *	page->first_page: points to the first component (0-order) page
+ *	page->index (union with page->freelist): offset of the first object
+ *		starting in this page. For the first page, this is
+ *		always 0, so we use this field (aka freelist) to point
+ *		to the first free object in zspage.
+ *	page->lru: links together all component pages (except the first page)
+ *		of a zspage
+ *
+ *	For _first_ page only:
+ *
+ *	page->private (union with page->first_page): refers to the
+ *		component page after the first page
+ *	page->freelist: points to the first free object in zspage.
+ *		Free objects are linked together using in-place
+ *		metadata.
+ *	page->objects: maximum number of objects we can store in this
+ *		zspage (class->zspage_order * PAGE_SIZE / class->size)
+ *	page->lru: links together first pages of various zspages.
+ *		Basically forming list of zspages in a fullness group.
+ *	page->mapping: class index and fullness group of the zspage
+ *
+ * Usage of struct page flags:
+ *	PG_private: identifies the first component page
+ *	PG_private2: identifies the last component page
+ *
+ */
+
+#ifdef CONFIG_ZSMALLOC_DEBUG
+#define DEBUG
+#endif
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/bitops.h>
+#include <linux/errno.h>
+#include <linux/highmem.h>
+#include <linux/init.h>
+#include <linux/string.h>
+#include <linux/slab.h>
+#include <asm/tlbflush.h>
+#include <asm/pgtable.h>
+#include <linux/cpumask.h>
+#include <linux/cpu.h>
+#include <linux/vmalloc.h>
+#include <linux/hardirq.h>
+#include <linux/spinlock.h>
+#include <linux/types.h>
+#include <linux/zsmalloc.h>
+
+/*
+ * This must be power of 2 and greater than of equal to sizeof(link_free).
+ * These two conditions ensure that any 'struct link_free' itself doesn't
+ * span more than 1 page which avoids complex case of mapping 2 pages simply
+ * to restore link_free pointer values.
+ */
+#define ZS_ALIGN		8
+
+/*
+ * A single 'zspage' is composed of up to 2^N discontiguous 0-order (single)
+ * pages. ZS_MAX_ZSPAGE_ORDER defines upper limit on N.
+ */
+#define ZS_MAX_ZSPAGE_ORDER 2
+#define ZS_MAX_PAGES_PER_ZSPAGE (_AC(1, UL) << ZS_MAX_ZSPAGE_ORDER)
+
+/*
+ * Object location (<PFN>, <obj_idx>) is encoded as
+ * as single (unsigned long) handle value.
+ *
+ * Note that object index <obj_idx> is relative to system
+ * page <PFN> it is stored in, so for each sub-page belonging
+ * to a zspage, obj_idx starts with 0.
+ *
+ * This is made more complicated by various memory models and PAE.
+ */
+
+#ifndef MAX_PHYSMEM_BITS
+#ifdef CONFIG_HIGHMEM64G
+#define MAX_PHYSMEM_BITS 36
+#else /* !CONFIG_HIGHMEM64G */
+/*
+ * If this definition of MAX_PHYSMEM_BITS is used, OBJ_INDEX_BITS will just
+ * be PAGE_SHIFT
+ */
+#define MAX_PHYSMEM_BITS BITS_PER_LONG
+#endif
+#endif
+#define _PFN_BITS		(MAX_PHYSMEM_BITS - PAGE_SHIFT)
+#define OBJ_INDEX_BITS	(BITS_PER_LONG - _PFN_BITS)
+#define OBJ_INDEX_MASK	((_AC(1, UL) << OBJ_INDEX_BITS) - 1)
+
+#define MAX(a, b) ((a) >= (b) ? (a) : (b))
+/* ZS_MIN_ALLOC_SIZE must be multiple of ZS_ALIGN */
+#define ZS_MIN_ALLOC_SIZE \
+	MAX(32, (ZS_MAX_PAGES_PER_ZSPAGE << PAGE_SHIFT >> OBJ_INDEX_BITS))
+#define ZS_MAX_ALLOC_SIZE	PAGE_SIZE
+
+/*
+ * On systems with 4K page size, this gives 254 size classes! There is a
+ * trader-off here:
+ *  - Large number of size classes is potentially wasteful as free page are
+ *    spread across these classes
+ *  - Small number of size classes causes large internal fragmentation
+ *  - Probably its better to use specific size classes (empirically
+ *    determined). NOTE: all those class sizes must be set as multiple of
+ *    ZS_ALIGN to make sure link_free itself never has to span 2 pages.
+ *
+ *  ZS_MIN_ALLOC_SIZE and ZS_SIZE_CLASS_DELTA must be multiple of ZS_ALIGN
+ *  (reason above)
+ */
+#define ZS_SIZE_CLASS_DELTA	(PAGE_SIZE >> 8)
+#define ZS_SIZE_CLASSES		((ZS_MAX_ALLOC_SIZE - ZS_MIN_ALLOC_SIZE) / \
+					ZS_SIZE_CLASS_DELTA + 1)
+
+/*
+ * We do not maintain any list for completely empty or full pages
+ */
+enum fullness_group {
+	ZS_ALMOST_FULL,
+	ZS_ALMOST_EMPTY,
+	_ZS_NR_FULLNESS_GROUPS,
+
+	ZS_EMPTY,
+	ZS_FULL
+};
+
+/*
+ * We assign a page to ZS_ALMOST_EMPTY fullness group when:
+ *	n <= N / f, where
+ * n = number of allocated objects
+ * N = total number of objects zspage can store
+ * f = 1/fullness_threshold_frac
+ *
+ * Similarly, we assign zspage to:
+ *	ZS_ALMOST_FULL	when n > N / f
+ *	ZS_EMPTY	when n == 0
+ *	ZS_FULL		when n == N
+ *
+ * (see: fix_fullness_group())
+ */
+static const int fullness_threshold_frac = 4;
+
+struct size_class {
+	/*
+	 * Size of objects stored in this class. Must be multiple
+	 * of ZS_ALIGN.
+	 */
+	int size;
+	unsigned int index;
+
+	/* Number of PAGE_SIZE sized pages to combine to form a 'zspage' */
+	int pages_per_zspage;
+
+	spinlock_t lock;
+
+	/* stats */
+	u64 pages_allocated;
+
+	struct page *fullness_list[_ZS_NR_FULLNESS_GROUPS];
+};
+
+/*
+ * Placed within free objects to form a singly linked list.
+ * For every zspage, first_page->freelist gives head of this list.
+ *
+ * This must be power of 2 and less than or equal to ZS_ALIGN
+ */
+struct link_free {
+	/* Handle of next free chunk (encodes <PFN, obj_idx>) */
+	void *next;
+};
+
+struct zs_pool {
+	struct size_class size_class[ZS_SIZE_CLASSES];
+
+	gfp_t flags;	/* allocation flags used when growing pool */
+};
+
+/*
+ * A zspage's class index and fullness group
+ * are encoded in its (first)page->mapping
+ */
+#define CLASS_IDX_BITS	28
+#define FULLNESS_BITS	4
+#define CLASS_IDX_MASK	((1 << CLASS_IDX_BITS) - 1)
+#define FULLNESS_MASK	((1 << FULLNESS_BITS) - 1)
+
+struct mapping_area {
+#ifdef CONFIG_PGTABLE_MAPPING
+	struct vm_struct *vm; /* vm area for mapping object that span pages */
+#else
+	char *vm_buf; /* copy buffer for objects that span pages */
+#endif
+	char *vm_addr; /* address of kmap_atomic()'ed pages */
+	enum zs_mapmode vm_mm; /* mapping mode */
+};
+
+
+/* per-cpu VM mapping areas for zspage accesses that cross page boundaries */
+static DEFINE_PER_CPU(struct mapping_area, zs_map_area);
+
+static int is_first_page(struct page *page)
+{
+	return PagePrivate(page);
+}
+
+static int is_last_page(struct page *page)
+{
+	return PagePrivate2(page);
+}
+
+static void get_zspage_mapping(struct page *page, unsigned int *class_idx,
+				enum fullness_group *fullness)
+{
+	unsigned long m;
+	BUG_ON(!is_first_page(page));
+
+	m = (unsigned long)page->mapping;
+	*fullness = m & FULLNESS_MASK;
+	*class_idx = (m >> FULLNESS_BITS) & CLASS_IDX_MASK;
+}
+
+static void set_zspage_mapping(struct page *page, unsigned int class_idx,
+				enum fullness_group fullness)
+{
+	unsigned long m;
+	BUG_ON(!is_first_page(page));
+
+	m = ((class_idx & CLASS_IDX_MASK) << FULLNESS_BITS) |
+			(fullness & FULLNESS_MASK);
+	page->mapping = (struct address_space *)m;
+}
+
+/*
+ * zsmalloc divides the pool into various size classes where each
+ * class maintains a list of zspages where each zspage is divided
+ * into equal sized chunks. Each allocation falls into one of these
+ * classes depending on its size. This function returns index of the
+ * size class which has chunk size big enough to hold the give size.
+ */
+static int get_size_class_index(int size)
+{
+	int idx = 0;
+
+	if (likely(size > ZS_MIN_ALLOC_SIZE))
+		idx = DIV_ROUND_UP(size - ZS_MIN_ALLOC_SIZE,
+				ZS_SIZE_CLASS_DELTA);
+
+	return idx;
+}
+
+/*
+ * For each size class, zspages are divided into different groups
+ * depending on how "full" they are. This was done so that we could
+ * easily find empty or nearly empty zspages when we try to shrink
+ * the pool (not yet implemented). This function returns fullness
+ * status of the given page.
+ */
+static enum fullness_group get_fullness_group(struct page *page)
+{
+	int inuse, max_objects;
+	enum fullness_group fg;
+	BUG_ON(!is_first_page(page));
+
+	inuse = page->inuse;
+	max_objects = page->objects;
+
+	if (inuse == 0)
+		fg = ZS_EMPTY;
+	else if (inuse == max_objects)
+		fg = ZS_FULL;
+	else if (inuse <= max_objects / fullness_threshold_frac)
+		fg = ZS_ALMOST_EMPTY;
+	else
+		fg = ZS_ALMOST_FULL;
+
+	return fg;
+}
+
+/*
+ * Each size class maintains various freelists and zspages are assigned
+ * to one of these freelists based on the number of live objects they
+ * have. This functions inserts the given zspage into the freelist
+ * identified by <class, fullness_group>.
+ */
+static void insert_zspage(struct page *page, struct size_class *class,
+				enum fullness_group fullness)
+{
+	struct page **head;
+
+	BUG_ON(!is_first_page(page));
+
+	if (fullness >= _ZS_NR_FULLNESS_GROUPS)
+		return;
+
+	head = &class->fullness_list[fullness];
+	if (*head)
+		list_add_tail(&page->lru, &(*head)->lru);
+
+	*head = page;
+}
+
+/*
+ * This function removes the given zspage from the freelist identified
+ * by <class, fullness_group>.
+ */
+static void remove_zspage(struct page *page, struct size_class *class,
+				enum fullness_group fullness)
+{
+	struct page **head;
+
+	BUG_ON(!is_first_page(page));
+
+	if (fullness >= _ZS_NR_FULLNESS_GROUPS)
+		return;
+
+	head = &class->fullness_list[fullness];
+	BUG_ON(!*head);
+	if (list_empty(&(*head)->lru))
+		*head = NULL;
+	else if (*head == page)
+		*head = (struct page *)list_entry((*head)->lru.next,
+					struct page, lru);
+
+	list_del_init(&page->lru);
+}
+
+/*
+ * Each size class maintains zspages in different fullness groups depending
+ * on the number of live objects they contain. When allocating or freeing
+ * objects, the fullness status of the page can change, say, from ALMOST_FULL
+ * to ALMOST_EMPTY when freeing an object. This function checks if such
+ * a status change has occurred for the given page and accordingly moves the
+ * page from the freelist of the old fullness group to that of the new
+ * fullness group.
+ */
+static enum fullness_group fix_fullness_group(struct zs_pool *pool,
+						struct page *page)
+{
+	int class_idx;
+	struct size_class *class;
+	enum fullness_group currfg, newfg;
+
+	BUG_ON(!is_first_page(page));
+
+	get_zspage_mapping(page, &class_idx, &currfg);
+	newfg = get_fullness_group(page);
+	if (newfg == currfg)
+		goto out;
+
+	class = &pool->size_class[class_idx];
+	remove_zspage(page, class, currfg);
+	insert_zspage(page, class, newfg);
+	set_zspage_mapping(page, class_idx, newfg);
+
+out:
+	return newfg;
+}
+
+/*
+ * We have to decide on how many pages to link together
+ * to form a zspage for each size class. This is important
+ * to reduce wastage due to unusable space left at end of
+ * each zspage which is given as:
+ *	wastage = Zp - Zp % size_class
+ * where Zp = zspage size = k * PAGE_SIZE where k = 1, 2, ...
+ *
+ * For example, for size class of 3/8 * PAGE_SIZE, we should
+ * link together 3 PAGE_SIZE sized pages to form a zspage
+ * since then we can perfectly fit in 8 such objects.
+ */
+static int get_pages_per_zspage(int class_size)
+{
+	int i, max_usedpc = 0;
+	/* zspage order which gives maximum used size per KB */
+	int max_usedpc_order = 1;
+
+	for (i = 1; i <= ZS_MAX_PAGES_PER_ZSPAGE; i++) {
+		int zspage_size;
+		int waste, usedpc;
+
+		zspage_size = i * PAGE_SIZE;
+		waste = zspage_size % class_size;
+		usedpc = (zspage_size - waste) * 100 / zspage_size;
+
+		if (usedpc > max_usedpc) {
+			max_usedpc = usedpc;
+			max_usedpc_order = i;
+		}
+	}
+
+	return max_usedpc_order;
+}
+
+/*
+ * A single 'zspage' is composed of many system pages which are
+ * linked together using fields in struct page. This function finds
+ * the first/head page, given any component page of a zspage.
+ */
+static struct page *get_first_page(struct page *page)
+{
+	if (is_first_page(page))
+		return page;
+	else
+		return page->first_page;
+}
+
+static struct page *get_next_page(struct page *page)
+{
+	struct page *next;
+
+	if (is_last_page(page))
+		next = NULL;
+	else if (is_first_page(page))
+		next = (struct page *)page_private(page);
+	else
+		next = list_entry(page->lru.next, struct page, lru);
+
+	return next;
+}
+
+/* Encode <page, obj_idx> as a single handle value */
+static void *obj_location_to_handle(struct page *page, unsigned long obj_idx)
+{
+	unsigned long handle;
+
+	if (!page) {
+		BUG_ON(obj_idx);
+		return NULL;
+	}
+
+	handle = page_to_pfn(page) << OBJ_INDEX_BITS;
+	handle |= (obj_idx & OBJ_INDEX_MASK);
+
+	return (void *)handle;
+}
+
+/* Decode <page, obj_idx> pair from the given object handle */
+static void obj_handle_to_location(unsigned long handle, struct page **page,
+				unsigned long *obj_idx)
+{
+	*page = pfn_to_page(handle >> OBJ_INDEX_BITS);
+	*obj_idx = handle & OBJ_INDEX_MASK;
+}
+
+static unsigned long obj_idx_to_offset(struct page *page,
+				unsigned long obj_idx, int class_size)
+{
+	unsigned long off = 0;
+
+	if (!is_first_page(page))
+		off = page->index;
+
+	return off + obj_idx * class_size;
+}
+
+static void reset_page(struct page *page)
+{
+	clear_bit(PG_private, &page->flags);
+	clear_bit(PG_private_2, &page->flags);
+	set_page_private(page, 0);
+	page->mapping = NULL;
+	page->freelist = NULL;
+	page_mapcount_reset(page);
+}
+
+static void free_zspage(struct page *first_page)
+{
+	struct page *nextp, *tmp, *head_extra;
+
+	BUG_ON(!is_first_page(first_page));
+	BUG_ON(first_page->inuse);
+
+	head_extra = (struct page *)page_private(first_page);
+
+	reset_page(first_page);
+	__free_page(first_page);
+
+	/* zspage with only 1 system page */
+	if (!head_extra)
+		return;
+
+	list_for_each_entry_safe(nextp, tmp, &head_extra->lru, lru) {
+		list_del(&nextp->lru);
+		reset_page(nextp);
+		__free_page(nextp);
+	}
+	reset_page(head_extra);
+	__free_page(head_extra);
+}
+
+/* Initialize a newly allocated zspage */
+static void init_zspage(struct page *first_page, struct size_class *class)
+{
+	unsigned long off = 0;
+	struct page *page = first_page;
+
+	BUG_ON(!is_first_page(first_page));
+	while (page) {
+		struct page *next_page;
+		struct link_free *link;
+		unsigned int i, objs_on_page;
+
+		/*
+		 * page->index stores offset of first object starting
+		 * in the page. For the first page, this is always 0,
+		 * so we use first_page->index (aka ->freelist) to store
+		 * head of corresponding zspage's freelist.
+		 */
+		if (page != first_page)
+			page->index = off;
+
+		link = (struct link_free *)kmap_atomic(page) +
+						off / sizeof(*link);
+		objs_on_page = (PAGE_SIZE - off) / class->size;
+
+		for (i = 1; i <= objs_on_page; i++) {
+			off += class->size;
+			if (off < PAGE_SIZE) {
+				link->next = obj_location_to_handle(page, i);
+				link += class->size / sizeof(*link);
+			}
+		}
+
+		/*
+		 * We now come to the last (full or partial) object on this
+		 * page, which must point to the first object on the next
+		 * page (if present)
+		 */
+		next_page = get_next_page(page);
+		link->next = obj_location_to_handle(next_page, 0);
+		kunmap_atomic(link);
+		page = next_page;
+		off = (off + class->size) % PAGE_SIZE;
+	}
+}
+
+/*
+ * Allocate a zspage for the given size class
+ */
+static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
+{
+	int i, error;
+	struct page *first_page = NULL, *uninitialized_var(prev_page);
+
+	/*
+	 * Allocate individual pages and link them together as:
+	 * 1. first page->private = first sub-page
+	 * 2. all sub-pages are linked together using page->lru
+	 * 3. each sub-page is linked to the first page using page->first_page
+	 *
+	 * For each size class, First/Head pages are linked together using
+	 * page->lru. Also, we set PG_private to identify the first page
+	 * (i.e. no other sub-page has this flag set) and PG_private_2 to
+	 * identify the last page.
+	 */
+	error = -ENOMEM;
+	for (i = 0; i < class->pages_per_zspage; i++) {
+		struct page *page;
+
+		page = alloc_page(flags);
+		if (!page)
+			goto cleanup;
+
+		INIT_LIST_HEAD(&page->lru);
+		if (i == 0) {	/* first page */
+			SetPagePrivate(page);
+			set_page_private(page, 0);
+			first_page = page;
+			first_page->inuse = 0;
+		}
+		if (i == 1)
+			set_page_private(first_page, (unsigned long)page);
+		if (i >= 1)
+			page->first_page = first_page;
+		if (i >= 2)
+			list_add(&page->lru, &prev_page->lru);
+		if (i == class->pages_per_zspage - 1)	/* last page */
+			SetPagePrivate2(page);
+		prev_page = page;
+	}
+
+	init_zspage(first_page, class);
+
+	first_page->freelist = obj_location_to_handle(first_page, 0);
+	/* Maximum number of objects we can store in this zspage */
+	first_page->objects = class->pages_per_zspage * PAGE_SIZE / class->size;
+
+	error = 0; /* Success */
+
+cleanup:
+	if (unlikely(error) && first_page) {
+		free_zspage(first_page);
+		first_page = NULL;
+	}
+
+	return first_page;
+}
+
+static struct page *find_get_zspage(struct size_class *class)
+{
+	int i;
+	struct page *page;
+
+	for (i = 0; i < _ZS_NR_FULLNESS_GROUPS; i++) {
+		page = class->fullness_list[i];
+		if (page)
+			break;
+	}
+
+	return page;
+}
+
+#ifdef CONFIG_PGTABLE_MAPPING
+static inline int __zs_cpu_up(struct mapping_area *area)
+{
+	/*
+	 * Make sure we don't leak memory if a cpu UP notification
+	 * and zs_init() race and both call zs_cpu_up() on the same cpu
+	 */
+	if (area->vm)
+		return 0;
+	area->vm = alloc_vm_area(PAGE_SIZE * 2, NULL);
+	if (!area->vm)
+		return -ENOMEM;
+	return 0;
+}
+
+static inline void __zs_cpu_down(struct mapping_area *area)
+{
+	if (area->vm)
+		free_vm_area(area->vm);
+	area->vm = NULL;
+}
+
+static inline void *__zs_map_object(struct mapping_area *area,
+				struct page *pages[2], int off, int size)
+{
+	BUG_ON(map_vm_area(area->vm, PAGE_KERNEL, &pages));
+	area->vm_addr = area->vm->addr;
+	return area->vm_addr + off;
+}
+
+static inline void __zs_unmap_object(struct mapping_area *area,
+				struct page *pages[2], int off, int size)
+{
+	unsigned long addr = (unsigned long)area->vm_addr;
+
+	unmap_kernel_range(addr, PAGE_SIZE * 2);
+}
+
+#else /* CONFIG_PGTABLE_MAPPING */
+
+static inline int __zs_cpu_up(struct mapping_area *area)
+{
+	/*
+	 * Make sure we don't leak memory if a cpu UP notification
+	 * and zs_init() race and both call zs_cpu_up() on the same cpu
+	 */
+	if (area->vm_buf)
+		return 0;
+	area->vm_buf = (char *)__get_free_page(GFP_KERNEL);
+	if (!area->vm_buf)
+		return -ENOMEM;
+	return 0;
+}
+
+static inline void __zs_cpu_down(struct mapping_area *area)
+{
+	if (area->vm_buf)
+		free_page((unsigned long)area->vm_buf);
+	area->vm_buf = NULL;
+}
+
+static void *__zs_map_object(struct mapping_area *area,
+			struct page *pages[2], int off, int size)
+{
+	int sizes[2];
+	void *addr;
+	char *buf = area->vm_buf;
+
+	/* disable page faults to match kmap_atomic() return conditions */
+	pagefault_disable();
+
+	/* no read fastpath */
+	if (area->vm_mm == ZS_MM_WO)
+		goto out;
+
+	sizes[0] = PAGE_SIZE - off;
+	sizes[1] = size - sizes[0];
+
+	/* copy object to per-cpu buffer */
+	addr = kmap_atomic(pages[0]);
+	memcpy(buf, addr + off, sizes[0]);
+	kunmap_atomic(addr);
+	addr = kmap_atomic(pages[1]);
+	memcpy(buf + sizes[0], addr, sizes[1]);
+	kunmap_atomic(addr);
+out:
+	return area->vm_buf;
+}
+
+static void __zs_unmap_object(struct mapping_area *area,
+			struct page *pages[2], int off, int size)
+{
+	int sizes[2];
+	void *addr;
+	char *buf = area->vm_buf;
+
+	/* no write fastpath */
+	if (area->vm_mm == ZS_MM_RO)
+		goto out;
+
+	sizes[0] = PAGE_SIZE - off;
+	sizes[1] = size - sizes[0];
+
+	/* copy per-cpu buffer to object */
+	addr = kmap_atomic(pages[0]);
+	memcpy(addr + off, buf, sizes[0]);
+	kunmap_atomic(addr);
+	addr = kmap_atomic(pages[1]);
+	memcpy(addr, buf + sizes[0], sizes[1]);
+	kunmap_atomic(addr);
+
+out:
+	/* enable page faults to match kunmap_atomic() return conditions */
+	pagefault_enable();
+}
+
+#endif /* CONFIG_PGTABLE_MAPPING */
+
+static int zs_cpu_notifier(struct notifier_block *nb, unsigned long action,
+				void *pcpu)
+{
+	int ret, cpu = (long)pcpu;
+	struct mapping_area *area;
+
+	switch (action) {
+	case CPU_UP_PREPARE:
+		area = &per_cpu(zs_map_area, cpu);
+		ret = __zs_cpu_up(area);
+		if (ret)
+			return notifier_from_errno(ret);
+		break;
+	case CPU_DEAD:
+	case CPU_UP_CANCELED:
+		area = &per_cpu(zs_map_area, cpu);
+		__zs_cpu_down(area);
+		break;
+	}
+
+	return NOTIFY_OK;
+}
+
+static struct notifier_block zs_cpu_nb = {
+	.notifier_call = zs_cpu_notifier
+};
+
+void zs_exit(void)
+{
+	int cpu;
+
+	for_each_online_cpu(cpu)
+		zs_cpu_notifier(NULL, CPU_DEAD, (void *)(long)cpu);
+	unregister_cpu_notifier(&zs_cpu_nb);
+}
+
+int zs_init(void)
+{
+	int cpu, ret;
+
+	register_cpu_notifier(&zs_cpu_nb);
+	for_each_online_cpu(cpu) {
+		ret = zs_cpu_notifier(NULL, CPU_UP_PREPARE, (void *)(long)cpu);
+		if (notifier_to_errno(ret))
+			goto fail;
+	}
+	return 0;
+fail:
+	zs_exit();
+	return notifier_to_errno(ret);
+}
+
+/**
+ * zs_create_pool - Creates an allocation pool to work from.
+ * @flags: allocation flags used to allocate pool metadata
+ *
+ * This function must be called before anything when using
+ * the zsmalloc allocator.
+ *
+ * On success, a pointer to the newly created pool is returned,
+ * otherwise NULL.
+ */
+struct zs_pool *zs_create_pool(gfp_t flags)
+{
+	int i, ovhd_size;
+	struct zs_pool *pool;
+
+	ovhd_size = roundup(sizeof(*pool), PAGE_SIZE);
+	pool = kzalloc(ovhd_size, GFP_KERNEL);
+	if (!pool)
+		return NULL;
+
+	for (i = 0; i < ZS_SIZE_CLASSES; i++) {
+		int size;
+		struct size_class *class;
+
+		size = ZS_MIN_ALLOC_SIZE + i * ZS_SIZE_CLASS_DELTA;
+		if (size > ZS_MAX_ALLOC_SIZE)
+			size = ZS_MAX_ALLOC_SIZE;
+
+		class = &pool->size_class[i];
+		class->size = size;
+		class->index = i;
+		spin_lock_init(&class->lock);
+		class->pages_per_zspage = get_pages_per_zspage(size);
+
+	}
+
+	pool->flags = flags;
+
+	return pool;
+}
+
+void zs_destroy_pool(struct zs_pool *pool)
+{
+	int i;
+
+	for (i = 0; i < ZS_SIZE_CLASSES; i++) {
+		int fg;
+		struct size_class *class = &pool->size_class[i];
+
+		for (fg = 0; fg < _ZS_NR_FULLNESS_GROUPS; fg++) {
+			if (class->fullness_list[fg]) {
+				pr_info("Freeing non-empty class with size %db, fullness group %d\n",
+					class->size, fg);
+			}
+		}
+	}
+	kfree(pool);
+}
+
+/**
+ * zs_malloc - Allocate block of given size from pool.
+ * @pool: pool to allocate from
+ * @size: size of block to allocate
+ *
+ * On success, handle to the allocated object is returned,
+ * otherwise 0.
+ * Allocation requests with size > ZS_MAX_ALLOC_SIZE will fail.
+ */
+unsigned long zs_malloc(struct zs_pool *pool, size_t size)
+{
+	unsigned long obj;
+	struct link_free *link;
+	int class_idx;
+	struct size_class *class;
+
+	struct page *first_page, *m_page;
+	unsigned long m_objidx, m_offset;
+
+	if (unlikely(!size || size > ZS_MAX_ALLOC_SIZE))
+		return 0;
+
+	class_idx = get_size_class_index(size);
+	class = &pool->size_class[class_idx];
+	BUG_ON(class_idx != class->index);
+
+	spin_lock(&class->lock);
+	first_page = find_get_zspage(class);
+
+	if (!first_page) {
+		spin_unlock(&class->lock);
+		first_page = alloc_zspage(class, pool->flags);
+		if (unlikely(!first_page))
+			return 0;
+
+		set_zspage_mapping(first_page, class->index, ZS_EMPTY);
+		spin_lock(&class->lock);
+		class->pages_allocated += class->pages_per_zspage;
+	}
+
+	obj = (unsigned long)first_page->freelist;
+	obj_handle_to_location(obj, &m_page, &m_objidx);
+	m_offset = obj_idx_to_offset(m_page, m_objidx, class->size);
+
+	link = (struct link_free *)kmap_atomic(m_page) +
+					m_offset / sizeof(*link);
+	first_page->freelist = link->next;
+	memset(link, POISON_INUSE, sizeof(*link));
+	kunmap_atomic(link);
+
+	first_page->inuse++;
+	/* Now move the zspage to another fullness group, if required */
+	fix_fullness_group(pool, first_page);
+	spin_unlock(&class->lock);
+
+	return obj;
+}
+
+void zs_free(struct zs_pool *pool, unsigned long obj)
+{
+	struct link_free *link;
+	struct page *first_page, *f_page;
+	unsigned long f_objidx, f_offset;
+
+	int class_idx;
+	struct size_class *class;
+	enum fullness_group fullness;
+
+	if (unlikely(!obj))
+		return;
+
+	obj_handle_to_location(obj, &f_page, &f_objidx);
+	first_page = get_first_page(f_page);
+
+	get_zspage_mapping(first_page, &class_idx, &fullness);
+	class = &pool->size_class[class_idx];
+	f_offset = obj_idx_to_offset(f_page, f_objidx, class->size);
+
+	spin_lock(&class->lock);
+
+	/* Insert this object in containing zspage's freelist */
+	link = (struct link_free *)((unsigned char *)kmap_atomic(f_page)
+							+ f_offset);
+	link->next = first_page->freelist;
+	kunmap_atomic(link);
+	first_page->freelist = (void *)obj;
+
+	first_page->inuse--;
+	fullness = fix_fullness_group(pool, first_page);
+
+	if (fullness == ZS_EMPTY)
+		class->pages_allocated -= class->pages_per_zspage;
+
+	spin_unlock(&class->lock);
+
+	if (fullness == ZS_EMPTY)
+		free_zspage(first_page);
+}
+
+/**
+ * zs_map_object - get address of allocated object from handle.
+ * @pool: pool from which the object was allocated
+ * @handle: handle returned from zs_malloc
+ *
+ * Before using an object allocated from zs_malloc, it must be mapped using
+ * this function. When done with the object, it must be unmapped using
+ * zs_unmap_object.
+ *
+ * Only one object can be mapped per cpu at a time. There is no protection
+ * against nested mappings.
+ *
+ * This function returns with preemption and page faults disabled.
+ */
+void *zs_map_object(struct zs_pool *pool, unsigned long handle,
+			enum zs_mapmode mm)
+{
+	struct page *page;
+	unsigned long obj_idx, off;
+
+	unsigned int class_idx;
+	enum fullness_group fg;
+	struct size_class *class;
+	struct mapping_area *area;
+	struct page *pages[2];
+
+	BUG_ON(!handle);
+
+	/*
+	 * Because we use per-cpu mapping areas shared among the
+	 * pools/users, we can't allow mapping in interrupt context
+	 * because it can corrupt another users mappings.
+	 */
+	BUG_ON(in_interrupt());
+
+	obj_handle_to_location(handle, &page, &obj_idx);
+	get_zspage_mapping(get_first_page(page), &class_idx, &fg);
+	class = &pool->size_class[class_idx];
+	off = obj_idx_to_offset(page, obj_idx, class->size);
+
+	area = &get_cpu_var(zs_map_area);
+	area->vm_mm = mm;
+	if (off + class->size <= PAGE_SIZE) {
+		/* this object is contained entirely within a page */
+		area->vm_addr = kmap_atomic(page);
+		return area->vm_addr + off;
+	}
+
+	/* this object spans two pages */
+	pages[0] = page;
+	pages[1] = get_next_page(page);
+	BUG_ON(!pages[1]);
+
+	return __zs_map_object(area, pages, off, class->size);
+}
+
+void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
+{
+	struct page *page;
+	unsigned long obj_idx, off;
+
+	unsigned int class_idx;
+	enum fullness_group fg;
+	struct size_class *class;
+	struct mapping_area *area;
+
+	BUG_ON(!handle);
+
+	obj_handle_to_location(handle, &page, &obj_idx);
+	get_zspage_mapping(get_first_page(page), &class_idx, &fg);
+	class = &pool->size_class[class_idx];
+	off = obj_idx_to_offset(page, obj_idx, class->size);
+
+	area = &__get_cpu_var(zs_map_area);
+	if (off + class->size <= PAGE_SIZE)
+		kunmap_atomic(area->vm_addr);
+	else {
+		struct page *pages[2];
+
+		pages[0] = page;
+		pages[1] = get_next_page(page);
+		BUG_ON(!pages[1]);
+
+		__zs_unmap_object(area, pages, off, class->size);
+	}
+	put_cpu_var(zs_map_area);
+}
+
+u64 zs_get_total_size_bytes(struct zs_pool *pool)
+{
+	int i;
+	u64 npages = 0;
+
+	for (i = 0; i < ZS_SIZE_CLASSES; i++)
+		npages += pool->size_class[i].pages_allocated;
+
+	return npages << PAGE_SHIFT;
+}
diff --git a/drivers/staging/Kconfig b/drivers/staging/Kconfig
index dcf6622..db6992a 100644
--- a/drivers/staging/Kconfig
+++ b/drivers/staging/Kconfig
@@ -72,8 +72,6 @@ source "drivers/staging/sep/Kconfig"
 
 source "drivers/staging/iio/Kconfig"
 
-source "drivers/staging/zram/Kconfig"
-
 source "drivers/staging/wlags49_h2/Kconfig"
 
 source "drivers/staging/wlags49_h25/Kconfig"
diff --git a/drivers/staging/Makefile b/drivers/staging/Makefile
index e5c2951..0504418 100644
--- a/drivers/staging/Makefile
+++ b/drivers/staging/Makefile
@@ -30,7 +30,6 @@ obj-$(CONFIG_VT6656)		+= vt6656/
 obj-$(CONFIG_VME_BUS)		+= vme/
 obj-$(CONFIG_DX_SEP)            += sep/
 obj-$(CONFIG_IIO)		+= iio/
-obj-$(CONFIG_ZRAM)		+= zram/
 obj-$(CONFIG_WLAGS49_H2)	+= wlags49_h2/
 obj-$(CONFIG_WLAGS49_H25)	+= wlags49_h25/
 obj-$(CONFIG_FB_SM7XX)		+= sm7xxfb/
diff --git a/drivers/staging/zram/Kconfig b/drivers/staging/zram/Kconfig
deleted file mode 100644
index 5f1a2c9..0000000
--- a/drivers/staging/zram/Kconfig
+++ /dev/null
@@ -1,38 +0,0 @@
-config ZRAM
-	bool "Compressed RAM block device support"
-	depends on BLOCK && SYSFS
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
-
-config PGTABLE_MAPPING
-	bool "Use page table mapping to access object in zsmalloc"
-	depends on ZRAM
-	help
-	  By default, zsmalloc uses a copy-based object mapping method to
-	  access allocations that span two pages. However, if a particular
-	  architecture (ex, ARM) performs VM mapping faster than copying,
-	  then you should select this. This causes zsmalloc to use page table
-	  mapping rather than copying for object mapping.
-
-	  You can check speed with zsmalloc benchmark[1].
-	  [1] https://github.com/spartacus06/zsmalloc
diff --git a/drivers/staging/zram/Makefile b/drivers/staging/zram/Makefile
deleted file mode 100644
index bec726d..0000000
--- a/drivers/staging/zram/Makefile
+++ /dev/null
@@ -1,3 +0,0 @@
-zram-y	:=	zram_drv.o
-
-obj-$(CONFIG_ZRAM)	+=	zram.o zsmalloc.o
diff --git a/drivers/staging/zram/zram.txt b/drivers/staging/zram/zram.txt
deleted file mode 100644
index 765d790..0000000
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
index 7741a7e..0000000
--- a/drivers/staging/zram/zram_drv.c
+++ /dev/null
@@ -1,989 +0,0 @@
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
-	if (unlikely(bio->bi_sector & (ZRAM_SECTOR_PER_LOGICAL_BLOCK - 1)))
-		return 0;
-	if (unlikely(bio->bi_size & (ZRAM_LOGICAL_BLOCK_SIZE - 1)))
-		return 0;
-
-	start = bio->bi_sector;
-	end = start + (bio->bi_size >> SECTOR_SHIFT);
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
-	zram_reset_device(zram, true);
-	return len;
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
-		atomic64_inc(&zram->stats.num_reads);
-		break;
-	case WRITE:
-		atomic64_inc(&zram->stats.num_writes);
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
-	if (zram->disk) {
-		del_gendisk(zram->disk);
-		put_disk(zram->disk);
-	}
-
-	if (zram->queue)
-		blk_cleanup_queue(zram->queue);
-}
-
-static int __init zram_init(void)
-{
-	int ret, dev_id;
-
-	ret = zs_init();
-	if (ret)
-		return ret;
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
-	zs_exit();
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
-MODULE_ALIAS("devname:zram");
diff --git a/drivers/staging/zram/zram_drv.h b/drivers/staging/zram/zram_drv.h
deleted file mode 100644
index d8f6596..0000000
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
diff --git a/drivers/staging/zram/zsmalloc.c b/drivers/staging/zram/zsmalloc.c
deleted file mode 100644
index b3a58c8..0000000
--- a/drivers/staging/zram/zsmalloc.c
+++ /dev/null
@@ -1,1084 +0,0 @@
-/*
- * zsmalloc memory allocator
- *
- * Copyright (C) 2011  Nitin Gupta
- *
- * This code is released using a dual license strategy: BSD/GPL
- * You can choose the license that better fits your requirements.
- *
- * Released under the terms of 3-clause BSD License
- * Released under the terms of GNU General Public License Version 2.0
- */
-
-/*
- * This allocator is designed for use with zram. Thus, the allocator is
- * supposed to work well under low memory conditions. In particular, it
- * never attempts higher order page allocation which is very likely to
- * fail under memory pressure. On the other hand, if we just use single
- * (0-order) pages, it would suffer from very high fragmentation --
- * any object of size PAGE_SIZE/2 or larger would occupy an entire page.
- * This was one of the major issues with its predecessor (xvmalloc).
- *
- * To overcome these issues, zsmalloc allocates a bunch of 0-order pages
- * and links them together using various 'struct page' fields. These linked
- * pages act as a single higher-order page i.e. an object can span 0-order
- * page boundaries. The code refers to these linked pages as a single entity
- * called zspage.
- *
- * For simplicity, zsmalloc can only allocate objects of size up to PAGE_SIZE
- * since this satisfies the requirements of all its current users (in the
- * worst case, page is incompressible and is thus stored "as-is" i.e. in
- * uncompressed form). For allocation requests larger than this size, failure
- * is returned (see zs_malloc).
- *
- * Additionally, zs_malloc() does not return a dereferenceable pointer.
- * Instead, it returns an opaque handle (unsigned long) which encodes actual
- * location of the allocated object. The reason for this indirection is that
- * zsmalloc does not keep zspages permanently mapped since that would cause
- * issues on 32-bit systems where the VA region for kernel space mappings
- * is very small. So, before using the allocating memory, the object has to
- * be mapped using zs_map_object() to get a usable pointer and subsequently
- * unmapped using zs_unmap_object().
- *
- * Following is how we use various fields and flags of underlying
- * struct page(s) to form a zspage.
- *
- * Usage of struct page fields:
- *	page->first_page: points to the first component (0-order) page
- *	page->index (union with page->freelist): offset of the first object
- *		starting in this page. For the first page, this is
- *		always 0, so we use this field (aka freelist) to point
- *		to the first free object in zspage.
- *	page->lru: links together all component pages (except the first page)
- *		of a zspage
- *
- *	For _first_ page only:
- *
- *	page->private (union with page->first_page): refers to the
- *		component page after the first page
- *	page->freelist: points to the first free object in zspage.
- *		Free objects are linked together using in-place
- *		metadata.
- *	page->objects: maximum number of objects we can store in this
- *		zspage (class->zspage_order * PAGE_SIZE / class->size)
- *	page->lru: links together first pages of various zspages.
- *		Basically forming list of zspages in a fullness group.
- *	page->mapping: class index and fullness group of the zspage
- *
- * Usage of struct page flags:
- *	PG_private: identifies the first component page
- *	PG_private2: identifies the last component page
- *
- */
-
-#ifdef CONFIG_ZSMALLOC_DEBUG
-#define DEBUG
-#endif
-
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/bitops.h>
-#include <linux/errno.h>
-#include <linux/highmem.h>
-#include <linux/init.h>
-#include <linux/string.h>
-#include <linux/slab.h>
-#include <asm/tlbflush.h>
-#include <asm/pgtable.h>
-#include <linux/cpumask.h>
-#include <linux/cpu.h>
-#include <linux/vmalloc.h>
-#include <linux/hardirq.h>
-#include <linux/spinlock.h>
-#include <linux/types.h>
-#include <linux/zsmalloc.h>
-
-/*
- * This must be power of 2 and greater than of equal to sizeof(link_free).
- * These two conditions ensure that any 'struct link_free' itself doesn't
- * span more than 1 page which avoids complex case of mapping 2 pages simply
- * to restore link_free pointer values.
- */
-#define ZS_ALIGN		8
-
-/*
- * A single 'zspage' is composed of up to 2^N discontiguous 0-order (single)
- * pages. ZS_MAX_ZSPAGE_ORDER defines upper limit on N.
- */
-#define ZS_MAX_ZSPAGE_ORDER 2
-#define ZS_MAX_PAGES_PER_ZSPAGE (_AC(1, UL) << ZS_MAX_ZSPAGE_ORDER)
-
-/*
- * Object location (<PFN>, <obj_idx>) is encoded as
- * as single (unsigned long) handle value.
- *
- * Note that object index <obj_idx> is relative to system
- * page <PFN> it is stored in, so for each sub-page belonging
- * to a zspage, obj_idx starts with 0.
- *
- * This is made more complicated by various memory models and PAE.
- */
-
-#ifndef MAX_PHYSMEM_BITS
-#ifdef CONFIG_HIGHMEM64G
-#define MAX_PHYSMEM_BITS 36
-#else /* !CONFIG_HIGHMEM64G */
-/*
- * If this definition of MAX_PHYSMEM_BITS is used, OBJ_INDEX_BITS will just
- * be PAGE_SHIFT
- */
-#define MAX_PHYSMEM_BITS BITS_PER_LONG
-#endif
-#endif
-#define _PFN_BITS		(MAX_PHYSMEM_BITS - PAGE_SHIFT)
-#define OBJ_INDEX_BITS	(BITS_PER_LONG - _PFN_BITS)
-#define OBJ_INDEX_MASK	((_AC(1, UL) << OBJ_INDEX_BITS) - 1)
-
-#define MAX(a, b) ((a) >= (b) ? (a) : (b))
-/* ZS_MIN_ALLOC_SIZE must be multiple of ZS_ALIGN */
-#define ZS_MIN_ALLOC_SIZE \
-	MAX(32, (ZS_MAX_PAGES_PER_ZSPAGE << PAGE_SHIFT >> OBJ_INDEX_BITS))
-#define ZS_MAX_ALLOC_SIZE	PAGE_SIZE
-
-/*
- * On systems with 4K page size, this gives 254 size classes! There is a
- * trader-off here:
- *  - Large number of size classes is potentially wasteful as free page are
- *    spread across these classes
- *  - Small number of size classes causes large internal fragmentation
- *  - Probably its better to use specific size classes (empirically
- *    determined). NOTE: all those class sizes must be set as multiple of
- *    ZS_ALIGN to make sure link_free itself never has to span 2 pages.
- *
- *  ZS_MIN_ALLOC_SIZE and ZS_SIZE_CLASS_DELTA must be multiple of ZS_ALIGN
- *  (reason above)
- */
-#define ZS_SIZE_CLASS_DELTA	(PAGE_SIZE >> 8)
-#define ZS_SIZE_CLASSES		((ZS_MAX_ALLOC_SIZE - ZS_MIN_ALLOC_SIZE) / \
-					ZS_SIZE_CLASS_DELTA + 1)
-
-/*
- * We do not maintain any list for completely empty or full pages
- */
-enum fullness_group {
-	ZS_ALMOST_FULL,
-	ZS_ALMOST_EMPTY,
-	_ZS_NR_FULLNESS_GROUPS,
-
-	ZS_EMPTY,
-	ZS_FULL
-};
-
-/*
- * We assign a page to ZS_ALMOST_EMPTY fullness group when:
- *	n <= N / f, where
- * n = number of allocated objects
- * N = total number of objects zspage can store
- * f = 1/fullness_threshold_frac
- *
- * Similarly, we assign zspage to:
- *	ZS_ALMOST_FULL	when n > N / f
- *	ZS_EMPTY	when n == 0
- *	ZS_FULL		when n == N
- *
- * (see: fix_fullness_group())
- */
-static const int fullness_threshold_frac = 4;
-
-struct size_class {
-	/*
-	 * Size of objects stored in this class. Must be multiple
-	 * of ZS_ALIGN.
-	 */
-	int size;
-	unsigned int index;
-
-	/* Number of PAGE_SIZE sized pages to combine to form a 'zspage' */
-	int pages_per_zspage;
-
-	spinlock_t lock;
-
-	/* stats */
-	u64 pages_allocated;
-
-	struct page *fullness_list[_ZS_NR_FULLNESS_GROUPS];
-};
-
-/*
- * Placed within free objects to form a singly linked list.
- * For every zspage, first_page->freelist gives head of this list.
- *
- * This must be power of 2 and less than or equal to ZS_ALIGN
- */
-struct link_free {
-	/* Handle of next free chunk (encodes <PFN, obj_idx>) */
-	void *next;
-};
-
-struct zs_pool {
-	struct size_class size_class[ZS_SIZE_CLASSES];
-
-	gfp_t flags;	/* allocation flags used when growing pool */
-};
-
-/*
- * A zspage's class index and fullness group
- * are encoded in its (first)page->mapping
- */
-#define CLASS_IDX_BITS	28
-#define FULLNESS_BITS	4
-#define CLASS_IDX_MASK	((1 << CLASS_IDX_BITS) - 1)
-#define FULLNESS_MASK	((1 << FULLNESS_BITS) - 1)
-
-struct mapping_area {
-#ifdef CONFIG_PGTABLE_MAPPING
-	struct vm_struct *vm; /* vm area for mapping object that span pages */
-#else
-	char *vm_buf; /* copy buffer for objects that span pages */
-#endif
-	char *vm_addr; /* address of kmap_atomic()'ed pages */
-	enum zs_mapmode vm_mm; /* mapping mode */
-};
-
-
-/* per-cpu VM mapping areas for zspage accesses that cross page boundaries */
-static DEFINE_PER_CPU(struct mapping_area, zs_map_area);
-
-static int is_first_page(struct page *page)
-{
-	return PagePrivate(page);
-}
-
-static int is_last_page(struct page *page)
-{
-	return PagePrivate2(page);
-}
-
-static void get_zspage_mapping(struct page *page, unsigned int *class_idx,
-				enum fullness_group *fullness)
-{
-	unsigned long m;
-	BUG_ON(!is_first_page(page));
-
-	m = (unsigned long)page->mapping;
-	*fullness = m & FULLNESS_MASK;
-	*class_idx = (m >> FULLNESS_BITS) & CLASS_IDX_MASK;
-}
-
-static void set_zspage_mapping(struct page *page, unsigned int class_idx,
-				enum fullness_group fullness)
-{
-	unsigned long m;
-	BUG_ON(!is_first_page(page));
-
-	m = ((class_idx & CLASS_IDX_MASK) << FULLNESS_BITS) |
-			(fullness & FULLNESS_MASK);
-	page->mapping = (struct address_space *)m;
-}
-
-/*
- * zsmalloc divides the pool into various size classes where each
- * class maintains a list of zspages where each zspage is divided
- * into equal sized chunks. Each allocation falls into one of these
- * classes depending on its size. This function returns index of the
- * size class which has chunk size big enough to hold the give size.
- */
-static int get_size_class_index(int size)
-{
-	int idx = 0;
-
-	if (likely(size > ZS_MIN_ALLOC_SIZE))
-		idx = DIV_ROUND_UP(size - ZS_MIN_ALLOC_SIZE,
-				ZS_SIZE_CLASS_DELTA);
-
-	return idx;
-}
-
-/*
- * For each size class, zspages are divided into different groups
- * depending on how "full" they are. This was done so that we could
- * easily find empty or nearly empty zspages when we try to shrink
- * the pool (not yet implemented). This function returns fullness
- * status of the given page.
- */
-static enum fullness_group get_fullness_group(struct page *page)
-{
-	int inuse, max_objects;
-	enum fullness_group fg;
-	BUG_ON(!is_first_page(page));
-
-	inuse = page->inuse;
-	max_objects = page->objects;
-
-	if (inuse == 0)
-		fg = ZS_EMPTY;
-	else if (inuse == max_objects)
-		fg = ZS_FULL;
-	else if (inuse <= max_objects / fullness_threshold_frac)
-		fg = ZS_ALMOST_EMPTY;
-	else
-		fg = ZS_ALMOST_FULL;
-
-	return fg;
-}
-
-/*
- * Each size class maintains various freelists and zspages are assigned
- * to one of these freelists based on the number of live objects they
- * have. This functions inserts the given zspage into the freelist
- * identified by <class, fullness_group>.
- */
-static void insert_zspage(struct page *page, struct size_class *class,
-				enum fullness_group fullness)
-{
-	struct page **head;
-
-	BUG_ON(!is_first_page(page));
-
-	if (fullness >= _ZS_NR_FULLNESS_GROUPS)
-		return;
-
-	head = &class->fullness_list[fullness];
-	if (*head)
-		list_add_tail(&page->lru, &(*head)->lru);
-
-	*head = page;
-}
-
-/*
- * This function removes the given zspage from the freelist identified
- * by <class, fullness_group>.
- */
-static void remove_zspage(struct page *page, struct size_class *class,
-				enum fullness_group fullness)
-{
-	struct page **head;
-
-	BUG_ON(!is_first_page(page));
-
-	if (fullness >= _ZS_NR_FULLNESS_GROUPS)
-		return;
-
-	head = &class->fullness_list[fullness];
-	BUG_ON(!*head);
-	if (list_empty(&(*head)->lru))
-		*head = NULL;
-	else if (*head == page)
-		*head = (struct page *)list_entry((*head)->lru.next,
-					struct page, lru);
-
-	list_del_init(&page->lru);
-}
-
-/*
- * Each size class maintains zspages in different fullness groups depending
- * on the number of live objects they contain. When allocating or freeing
- * objects, the fullness status of the page can change, say, from ALMOST_FULL
- * to ALMOST_EMPTY when freeing an object. This function checks if such
- * a status change has occurred for the given page and accordingly moves the
- * page from the freelist of the old fullness group to that of the new
- * fullness group.
- */
-static enum fullness_group fix_fullness_group(struct zs_pool *pool,
-						struct page *page)
-{
-	int class_idx;
-	struct size_class *class;
-	enum fullness_group currfg, newfg;
-
-	BUG_ON(!is_first_page(page));
-
-	get_zspage_mapping(page, &class_idx, &currfg);
-	newfg = get_fullness_group(page);
-	if (newfg == currfg)
-		goto out;
-
-	class = &pool->size_class[class_idx];
-	remove_zspage(page, class, currfg);
-	insert_zspage(page, class, newfg);
-	set_zspage_mapping(page, class_idx, newfg);
-
-out:
-	return newfg;
-}
-
-/*
- * We have to decide on how many pages to link together
- * to form a zspage for each size class. This is important
- * to reduce wastage due to unusable space left at end of
- * each zspage which is given as:
- *	wastage = Zp - Zp % size_class
- * where Zp = zspage size = k * PAGE_SIZE where k = 1, 2, ...
- *
- * For example, for size class of 3/8 * PAGE_SIZE, we should
- * link together 3 PAGE_SIZE sized pages to form a zspage
- * since then we can perfectly fit in 8 such objects.
- */
-static int get_pages_per_zspage(int class_size)
-{
-	int i, max_usedpc = 0;
-	/* zspage order which gives maximum used size per KB */
-	int max_usedpc_order = 1;
-
-	for (i = 1; i <= ZS_MAX_PAGES_PER_ZSPAGE; i++) {
-		int zspage_size;
-		int waste, usedpc;
-
-		zspage_size = i * PAGE_SIZE;
-		waste = zspage_size % class_size;
-		usedpc = (zspage_size - waste) * 100 / zspage_size;
-
-		if (usedpc > max_usedpc) {
-			max_usedpc = usedpc;
-			max_usedpc_order = i;
-		}
-	}
-
-	return max_usedpc_order;
-}
-
-/*
- * A single 'zspage' is composed of many system pages which are
- * linked together using fields in struct page. This function finds
- * the first/head page, given any component page of a zspage.
- */
-static struct page *get_first_page(struct page *page)
-{
-	if (is_first_page(page))
-		return page;
-	else
-		return page->first_page;
-}
-
-static struct page *get_next_page(struct page *page)
-{
-	struct page *next;
-
-	if (is_last_page(page))
-		next = NULL;
-	else if (is_first_page(page))
-		next = (struct page *)page_private(page);
-	else
-		next = list_entry(page->lru.next, struct page, lru);
-
-	return next;
-}
-
-/* Encode <page, obj_idx> as a single handle value */
-static void *obj_location_to_handle(struct page *page, unsigned long obj_idx)
-{
-	unsigned long handle;
-
-	if (!page) {
-		BUG_ON(obj_idx);
-		return NULL;
-	}
-
-	handle = page_to_pfn(page) << OBJ_INDEX_BITS;
-	handle |= (obj_idx & OBJ_INDEX_MASK);
-
-	return (void *)handle;
-}
-
-/* Decode <page, obj_idx> pair from the given object handle */
-static void obj_handle_to_location(unsigned long handle, struct page **page,
-				unsigned long *obj_idx)
-{
-	*page = pfn_to_page(handle >> OBJ_INDEX_BITS);
-	*obj_idx = handle & OBJ_INDEX_MASK;
-}
-
-static unsigned long obj_idx_to_offset(struct page *page,
-				unsigned long obj_idx, int class_size)
-{
-	unsigned long off = 0;
-
-	if (!is_first_page(page))
-		off = page->index;
-
-	return off + obj_idx * class_size;
-}
-
-static void reset_page(struct page *page)
-{
-	clear_bit(PG_private, &page->flags);
-	clear_bit(PG_private_2, &page->flags);
-	set_page_private(page, 0);
-	page->mapping = NULL;
-	page->freelist = NULL;
-	page_mapcount_reset(page);
-}
-
-static void free_zspage(struct page *first_page)
-{
-	struct page *nextp, *tmp, *head_extra;
-
-	BUG_ON(!is_first_page(first_page));
-	BUG_ON(first_page->inuse);
-
-	head_extra = (struct page *)page_private(first_page);
-
-	reset_page(first_page);
-	__free_page(first_page);
-
-	/* zspage with only 1 system page */
-	if (!head_extra)
-		return;
-
-	list_for_each_entry_safe(nextp, tmp, &head_extra->lru, lru) {
-		list_del(&nextp->lru);
-		reset_page(nextp);
-		__free_page(nextp);
-	}
-	reset_page(head_extra);
-	__free_page(head_extra);
-}
-
-/* Initialize a newly allocated zspage */
-static void init_zspage(struct page *first_page, struct size_class *class)
-{
-	unsigned long off = 0;
-	struct page *page = first_page;
-
-	BUG_ON(!is_first_page(first_page));
-	while (page) {
-		struct page *next_page;
-		struct link_free *link;
-		unsigned int i, objs_on_page;
-
-		/*
-		 * page->index stores offset of first object starting
-		 * in the page. For the first page, this is always 0,
-		 * so we use first_page->index (aka ->freelist) to store
-		 * head of corresponding zspage's freelist.
-		 */
-		if (page != first_page)
-			page->index = off;
-
-		link = (struct link_free *)kmap_atomic(page) +
-						off / sizeof(*link);
-		objs_on_page = (PAGE_SIZE - off) / class->size;
-
-		for (i = 1; i <= objs_on_page; i++) {
-			off += class->size;
-			if (off < PAGE_SIZE) {
-				link->next = obj_location_to_handle(page, i);
-				link += class->size / sizeof(*link);
-			}
-		}
-
-		/*
-		 * We now come to the last (full or partial) object on this
-		 * page, which must point to the first object on the next
-		 * page (if present)
-		 */
-		next_page = get_next_page(page);
-		link->next = obj_location_to_handle(next_page, 0);
-		kunmap_atomic(link);
-		page = next_page;
-		off = (off + class->size) % PAGE_SIZE;
-	}
-}
-
-/*
- * Allocate a zspage for the given size class
- */
-static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
-{
-	int i, error;
-	struct page *first_page = NULL, *uninitialized_var(prev_page);
-
-	/*
-	 * Allocate individual pages and link them together as:
-	 * 1. first page->private = first sub-page
-	 * 2. all sub-pages are linked together using page->lru
-	 * 3. each sub-page is linked to the first page using page->first_page
-	 *
-	 * For each size class, First/Head pages are linked together using
-	 * page->lru. Also, we set PG_private to identify the first page
-	 * (i.e. no other sub-page has this flag set) and PG_private_2 to
-	 * identify the last page.
-	 */
-	error = -ENOMEM;
-	for (i = 0; i < class->pages_per_zspage; i++) {
-		struct page *page;
-
-		page = alloc_page(flags);
-		if (!page)
-			goto cleanup;
-
-		INIT_LIST_HEAD(&page->lru);
-		if (i == 0) {	/* first page */
-			SetPagePrivate(page);
-			set_page_private(page, 0);
-			first_page = page;
-			first_page->inuse = 0;
-		}
-		if (i == 1)
-			set_page_private(first_page, (unsigned long)page);
-		if (i >= 1)
-			page->first_page = first_page;
-		if (i >= 2)
-			list_add(&page->lru, &prev_page->lru);
-		if (i == class->pages_per_zspage - 1)	/* last page */
-			SetPagePrivate2(page);
-		prev_page = page;
-	}
-
-	init_zspage(first_page, class);
-
-	first_page->freelist = obj_location_to_handle(first_page, 0);
-	/* Maximum number of objects we can store in this zspage */
-	first_page->objects = class->pages_per_zspage * PAGE_SIZE / class->size;
-
-	error = 0; /* Success */
-
-cleanup:
-	if (unlikely(error) && first_page) {
-		free_zspage(first_page);
-		first_page = NULL;
-	}
-
-	return first_page;
-}
-
-static struct page *find_get_zspage(struct size_class *class)
-{
-	int i;
-	struct page *page;
-
-	for (i = 0; i < _ZS_NR_FULLNESS_GROUPS; i++) {
-		page = class->fullness_list[i];
-		if (page)
-			break;
-	}
-
-	return page;
-}
-
-#ifdef CONFIG_PGTABLE_MAPPING
-static inline int __zs_cpu_up(struct mapping_area *area)
-{
-	/*
-	 * Make sure we don't leak memory if a cpu UP notification
-	 * and zs_init() race and both call zs_cpu_up() on the same cpu
-	 */
-	if (area->vm)
-		return 0;
-	area->vm = alloc_vm_area(PAGE_SIZE * 2, NULL);
-	if (!area->vm)
-		return -ENOMEM;
-	return 0;
-}
-
-static inline void __zs_cpu_down(struct mapping_area *area)
-{
-	if (area->vm)
-		free_vm_area(area->vm);
-	area->vm = NULL;
-}
-
-static inline void *__zs_map_object(struct mapping_area *area,
-				struct page *pages[2], int off, int size)
-{
-	BUG_ON(map_vm_area(area->vm, PAGE_KERNEL, &pages));
-	area->vm_addr = area->vm->addr;
-	return area->vm_addr + off;
-}
-
-static inline void __zs_unmap_object(struct mapping_area *area,
-				struct page *pages[2], int off, int size)
-{
-	unsigned long addr = (unsigned long)area->vm_addr;
-
-	unmap_kernel_range(addr, PAGE_SIZE * 2);
-}
-
-#else /* CONFIG_PGTABLE_MAPPING */
-
-static inline int __zs_cpu_up(struct mapping_area *area)
-{
-	/*
-	 * Make sure we don't leak memory if a cpu UP notification
-	 * and zs_init() race and both call zs_cpu_up() on the same cpu
-	 */
-	if (area->vm_buf)
-		return 0;
-	area->vm_buf = (char *)__get_free_page(GFP_KERNEL);
-	if (!area->vm_buf)
-		return -ENOMEM;
-	return 0;
-}
-
-static inline void __zs_cpu_down(struct mapping_area *area)
-{
-	if (area->vm_buf)
-		free_page((unsigned long)area->vm_buf);
-	area->vm_buf = NULL;
-}
-
-static void *__zs_map_object(struct mapping_area *area,
-			struct page *pages[2], int off, int size)
-{
-	int sizes[2];
-	void *addr;
-	char *buf = area->vm_buf;
-
-	/* disable page faults to match kmap_atomic() return conditions */
-	pagefault_disable();
-
-	/* no read fastpath */
-	if (area->vm_mm == ZS_MM_WO)
-		goto out;
-
-	sizes[0] = PAGE_SIZE - off;
-	sizes[1] = size - sizes[0];
-
-	/* copy object to per-cpu buffer */
-	addr = kmap_atomic(pages[0]);
-	memcpy(buf, addr + off, sizes[0]);
-	kunmap_atomic(addr);
-	addr = kmap_atomic(pages[1]);
-	memcpy(buf + sizes[0], addr, sizes[1]);
-	kunmap_atomic(addr);
-out:
-	return area->vm_buf;
-}
-
-static void __zs_unmap_object(struct mapping_area *area,
-			struct page *pages[2], int off, int size)
-{
-	int sizes[2];
-	void *addr;
-	char *buf = area->vm_buf;
-
-	/* no write fastpath */
-	if (area->vm_mm == ZS_MM_RO)
-		goto out;
-
-	sizes[0] = PAGE_SIZE - off;
-	sizes[1] = size - sizes[0];
-
-	/* copy per-cpu buffer to object */
-	addr = kmap_atomic(pages[0]);
-	memcpy(addr + off, buf, sizes[0]);
-	kunmap_atomic(addr);
-	addr = kmap_atomic(pages[1]);
-	memcpy(addr, buf + sizes[0], sizes[1]);
-	kunmap_atomic(addr);
-
-out:
-	/* enable page faults to match kunmap_atomic() return conditions */
-	pagefault_enable();
-}
-
-#endif /* CONFIG_PGTABLE_MAPPING */
-
-static int zs_cpu_notifier(struct notifier_block *nb, unsigned long action,
-				void *pcpu)
-{
-	int ret, cpu = (long)pcpu;
-	struct mapping_area *area;
-
-	switch (action) {
-	case CPU_UP_PREPARE:
-		area = &per_cpu(zs_map_area, cpu);
-		ret = __zs_cpu_up(area);
-		if (ret)
-			return notifier_from_errno(ret);
-		break;
-	case CPU_DEAD:
-	case CPU_UP_CANCELED:
-		area = &per_cpu(zs_map_area, cpu);
-		__zs_cpu_down(area);
-		break;
-	}
-
-	return NOTIFY_OK;
-}
-
-static struct notifier_block zs_cpu_nb = {
-	.notifier_call = zs_cpu_notifier
-};
-
-void zs_exit(void)
-{
-	int cpu;
-
-	for_each_online_cpu(cpu)
-		zs_cpu_notifier(NULL, CPU_DEAD, (void *)(long)cpu);
-	unregister_cpu_notifier(&zs_cpu_nb);
-}
-
-int zs_init(void)
-{
-	int cpu, ret;
-
-	register_cpu_notifier(&zs_cpu_nb);
-	for_each_online_cpu(cpu) {
-		ret = zs_cpu_notifier(NULL, CPU_UP_PREPARE, (void *)(long)cpu);
-		if (notifier_to_errno(ret))
-			goto fail;
-	}
-	return 0;
-fail:
-	zs_exit();
-	return notifier_to_errno(ret);
-}
-
-/**
- * zs_create_pool - Creates an allocation pool to work from.
- * @flags: allocation flags used to allocate pool metadata
- *
- * This function must be called before anything when using
- * the zsmalloc allocator.
- *
- * On success, a pointer to the newly created pool is returned,
- * otherwise NULL.
- */
-struct zs_pool *zs_create_pool(gfp_t flags)
-{
-	int i, ovhd_size;
-	struct zs_pool *pool;
-
-	ovhd_size = roundup(sizeof(*pool), PAGE_SIZE);
-	pool = kzalloc(ovhd_size, GFP_KERNEL);
-	if (!pool)
-		return NULL;
-
-	for (i = 0; i < ZS_SIZE_CLASSES; i++) {
-		int size;
-		struct size_class *class;
-
-		size = ZS_MIN_ALLOC_SIZE + i * ZS_SIZE_CLASS_DELTA;
-		if (size > ZS_MAX_ALLOC_SIZE)
-			size = ZS_MAX_ALLOC_SIZE;
-
-		class = &pool->size_class[i];
-		class->size = size;
-		class->index = i;
-		spin_lock_init(&class->lock);
-		class->pages_per_zspage = get_pages_per_zspage(size);
-
-	}
-
-	pool->flags = flags;
-
-	return pool;
-}
-
-void zs_destroy_pool(struct zs_pool *pool)
-{
-	int i;
-
-	for (i = 0; i < ZS_SIZE_CLASSES; i++) {
-		int fg;
-		struct size_class *class = &pool->size_class[i];
-
-		for (fg = 0; fg < _ZS_NR_FULLNESS_GROUPS; fg++) {
-			if (class->fullness_list[fg]) {
-				pr_info("Freeing non-empty class with size %db, fullness group %d\n",
-					class->size, fg);
-			}
-		}
-	}
-	kfree(pool);
-}
-
-/**
- * zs_malloc - Allocate block of given size from pool.
- * @pool: pool to allocate from
- * @size: size of block to allocate
- *
- * On success, handle to the allocated object is returned,
- * otherwise 0.
- * Allocation requests with size > ZS_MAX_ALLOC_SIZE will fail.
- */
-unsigned long zs_malloc(struct zs_pool *pool, size_t size)
-{
-	unsigned long obj;
-	struct link_free *link;
-	int class_idx;
-	struct size_class *class;
-
-	struct page *first_page, *m_page;
-	unsigned long m_objidx, m_offset;
-
-	if (unlikely(!size || size > ZS_MAX_ALLOC_SIZE))
-		return 0;
-
-	class_idx = get_size_class_index(size);
-	class = &pool->size_class[class_idx];
-	BUG_ON(class_idx != class->index);
-
-	spin_lock(&class->lock);
-	first_page = find_get_zspage(class);
-
-	if (!first_page) {
-		spin_unlock(&class->lock);
-		first_page = alloc_zspage(class, pool->flags);
-		if (unlikely(!first_page))
-			return 0;
-
-		set_zspage_mapping(first_page, class->index, ZS_EMPTY);
-		spin_lock(&class->lock);
-		class->pages_allocated += class->pages_per_zspage;
-	}
-
-	obj = (unsigned long)first_page->freelist;
-	obj_handle_to_location(obj, &m_page, &m_objidx);
-	m_offset = obj_idx_to_offset(m_page, m_objidx, class->size);
-
-	link = (struct link_free *)kmap_atomic(m_page) +
-					m_offset / sizeof(*link);
-	first_page->freelist = link->next;
-	memset(link, POISON_INUSE, sizeof(*link));
-	kunmap_atomic(link);
-
-	first_page->inuse++;
-	/* Now move the zspage to another fullness group, if required */
-	fix_fullness_group(pool, first_page);
-	spin_unlock(&class->lock);
-
-	return obj;
-}
-
-void zs_free(struct zs_pool *pool, unsigned long obj)
-{
-	struct link_free *link;
-	struct page *first_page, *f_page;
-	unsigned long f_objidx, f_offset;
-
-	int class_idx;
-	struct size_class *class;
-	enum fullness_group fullness;
-
-	if (unlikely(!obj))
-		return;
-
-	obj_handle_to_location(obj, &f_page, &f_objidx);
-	first_page = get_first_page(f_page);
-
-	get_zspage_mapping(first_page, &class_idx, &fullness);
-	class = &pool->size_class[class_idx];
-	f_offset = obj_idx_to_offset(f_page, f_objidx, class->size);
-
-	spin_lock(&class->lock);
-
-	/* Insert this object in containing zspage's freelist */
-	link = (struct link_free *)((unsigned char *)kmap_atomic(f_page)
-							+ f_offset);
-	link->next = first_page->freelist;
-	kunmap_atomic(link);
-	first_page->freelist = (void *)obj;
-
-	first_page->inuse--;
-	fullness = fix_fullness_group(pool, first_page);
-
-	if (fullness == ZS_EMPTY)
-		class->pages_allocated -= class->pages_per_zspage;
-
-	spin_unlock(&class->lock);
-
-	if (fullness == ZS_EMPTY)
-		free_zspage(first_page);
-}
-
-/**
- * zs_map_object - get address of allocated object from handle.
- * @pool: pool from which the object was allocated
- * @handle: handle returned from zs_malloc
- *
- * Before using an object allocated from zs_malloc, it must be mapped using
- * this function. When done with the object, it must be unmapped using
- * zs_unmap_object.
- *
- * Only one object can be mapped per cpu at a time. There is no protection
- * against nested mappings.
- *
- * This function returns with preemption and page faults disabled.
- */
-void *zs_map_object(struct zs_pool *pool, unsigned long handle,
-			enum zs_mapmode mm)
-{
-	struct page *page;
-	unsigned long obj_idx, off;
-
-	unsigned int class_idx;
-	enum fullness_group fg;
-	struct size_class *class;
-	struct mapping_area *area;
-	struct page *pages[2];
-
-	BUG_ON(!handle);
-
-	/*
-	 * Because we use per-cpu mapping areas shared among the
-	 * pools/users, we can't allow mapping in interrupt context
-	 * because it can corrupt another users mappings.
-	 */
-	BUG_ON(in_interrupt());
-
-	obj_handle_to_location(handle, &page, &obj_idx);
-	get_zspage_mapping(get_first_page(page), &class_idx, &fg);
-	class = &pool->size_class[class_idx];
-	off = obj_idx_to_offset(page, obj_idx, class->size);
-
-	area = &get_cpu_var(zs_map_area);
-	area->vm_mm = mm;
-	if (off + class->size <= PAGE_SIZE) {
-		/* this object is contained entirely within a page */
-		area->vm_addr = kmap_atomic(page);
-		return area->vm_addr + off;
-	}
-
-	/* this object spans two pages */
-	pages[0] = page;
-	pages[1] = get_next_page(page);
-	BUG_ON(!pages[1]);
-
-	return __zs_map_object(area, pages, off, class->size);
-}
-
-void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
-{
-	struct page *page;
-	unsigned long obj_idx, off;
-
-	unsigned int class_idx;
-	enum fullness_group fg;
-	struct size_class *class;
-	struct mapping_area *area;
-
-	BUG_ON(!handle);
-
-	obj_handle_to_location(handle, &page, &obj_idx);
-	get_zspage_mapping(get_first_page(page), &class_idx, &fg);
-	class = &pool->size_class[class_idx];
-	off = obj_idx_to_offset(page, obj_idx, class->size);
-
-	area = &__get_cpu_var(zs_map_area);
-	if (off + class->size <= PAGE_SIZE)
-		kunmap_atomic(area->vm_addr);
-	else {
-		struct page *pages[2];
-
-		pages[0] = page;
-		pages[1] = get_next_page(page);
-		BUG_ON(!pages[1]);
-
-		__zs_unmap_object(area, pages, off, class->size);
-	}
-	put_cpu_var(zs_map_area);
-}
-
-u64 zs_get_total_size_bytes(struct zs_pool *pool)
-{
-	int i;
-	u64 npages = 0;
-
-	for (i = 0; i < ZS_SIZE_CLASSES; i++)
-		npages += pool->size_class[i].pages_allocated;
-
-	return npages << PAGE_SHIFT;
-}
diff --git a/include/linux/zram.h b/include/linux/zram.h
new file mode 100644
index 0000000..92f70e8
--- /dev/null
+++ b/include/linux/zram.h
@@ -0,0 +1,123 @@
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
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
