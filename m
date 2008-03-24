Received: by rn-out-0910.google.com with SMTP id i24so1645484rng.0
        for <linux-mm@kvack.org>; Mon, 24 Mar 2008 08:07:22 -0700 (PDT)
From: Nitin Gupta <nitingupta910@gmail.com>
Reply-To: nitingupta910@gmail.com
Subject: [PATCH 1/6] compcache: compressed RAM block device
Date: Mon, 24 Mar 2008 20:32:40 +0530
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Message-Id: <200803242032.40589.nitingupta910@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This creates RAM based block device (called ramzswap0) which is used as swap disk.

On write (swap-out):
 - compress page (using LZO)
 - Allocate required amount of memory (using TLSF)
 - Store reference to its location in simple array.

On read (swap-in):
 - Get compressed page location from array
 - Decompress this page.

It also makes required Makefile changes.

Signed-off-by: Nitin Gupta <nitingupta910 at gmail dot com>
---
 drivers/block/Kconfig     |   10 +
 drivers/block/Makefile    |    1 +
 drivers/block/compcache.c |  440 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 451 insertions(+), 0 deletions(-)

diff --git a/drivers/block/Kconfig b/drivers/block/Kconfig
index 0d1d213..0cba42f 100644
--- a/drivers/block/Kconfig
+++ b/drivers/block/Kconfig
@@ -347,6 +347,16 @@ config BLK_DEV_RAM_SIZE
 	  The default value is 4096 kilobytes. Only change this if you know
 	  what you are doing.
 
+config BLK_DEV_COMPCACHE
+	tristate "Compressed RAM based swap device"
+	select TLSF
+	select LZO_COMPRESS
+	select LZO_DECOMPRESS
+	help
+	  This creates RAM based block device which acts as swap disk. Pages
+	  swapped to this disk are compressed and stored in memory itself.
+	  Project Home: http://code.google.com/p/compcache/
+
 config BLK_DEV_XIP
 	bool "Support XIP filesystems on RAM block device"
 	depends on BLK_DEV_RAM
diff --git a/drivers/block/Makefile b/drivers/block/Makefile
index 5e58430..b6d3dd2 100644
--- a/drivers/block/Makefile
+++ b/drivers/block/Makefile
@@ -12,6 +12,7 @@ obj-$(CONFIG_PS3_DISK)		+= ps3disk.o
 obj-$(CONFIG_ATARI_FLOPPY)	+= ataflop.o
 obj-$(CONFIG_AMIGA_Z2RAM)	+= z2ram.o
 obj-$(CONFIG_BLK_DEV_RAM)	+= brd.o
+obj-$(CONFIG_BLK_DEV_COMPCACHE)	+= compcache.o
 obj-$(CONFIG_BLK_DEV_LOOP)	+= loop.o
 obj-$(CONFIG_BLK_DEV_XD)	+= xd.o
 obj-$(CONFIG_BLK_CPQ_DA)	+= cpqarray.o
diff --git a/drivers/block/compcache.c b/drivers/block/compcache.c
new file mode 100644
index 0000000..4ffcd63
--- /dev/null
+++ b/drivers/block/compcache.c
@@ -0,0 +1,440 @@
+/*
+ * Compressed RAM based swap device
+ *
+ * (C) Nitin Gupta
+ *
+ * This RAM based block device acts as swap disk.
+ * Pages swapped to this device are compressed and
+ * stored in memory.
+ *
+ * Project home: http://code.google.com/p/compcache
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/blkdev.h>
+#include <linux/buffer_head.h>
+#include <linux/device.h>
+#include <linux/genhd.h>
+#include <linux/highmem.h>
+#include <linux/lzo.h>
+#include <linux/mutex.h>
+#include <linux/proc_fs.h>
+#include <linux/swap.h>
+#include <linux/tlsf.h>
+#include <linux/vmalloc.h>
+#include <asm/pgtable.h>
+#include <asm/string.h>
+
+#include "compcache.h"
+
+static struct block_device_operations compcache_devops = {
+	.owner = THIS_MODULE,
+};
+
+static struct compcache compcache;
+static unsigned long compcache_size_kbytes;
+#if STATS
+static struct compcache_stats stats;
+#endif
+
+#ifdef CONFIG_COMPCACHE_PROC
+static struct proc_dir_entry *proc;
+
+static int proc_compcache_read(char *page, char **start, off_t off,
+				int count, int *eof, void *data)
+{
+	int len;
+#if STATS
+	size_t succ_writes;
+	unsigned int good_compress_perc = 0, no_compress_perc = 0;
+#endif
+
+	if (off > 0) {
+		*eof = 1;
+		return 0;
+	}
+
+	len = sprintf(page,
+		"DiskSize:	%8u kB\n",
+		compcache.size >> (10 - SECTOR_SHIFT));
+#if STATS
+	succ_writes = stats.num_writes - stats.failed_writes;
+	if (succ_writes) {
+		good_compress_perc = stats.good_compress * 100 / succ_writes;
+		no_compress_perc = stats.pages_expand * 100 / succ_writes;
+	}
+
+	len += sprintf(page + len,
+		"NumReads:	%8u\n"
+		"NumWrites:	%8u\n"
+		"FailedReads:	%8u\n"
+		"FailedWrites:	%8u\n"
+		"InvalidIO:	%8u\n"
+		"GoodCompress:	%8u %%\n"
+		"NoCompress:	%8u %%\n"
+		"CurrentPages:	%8zu\n"
+		"CurrentMem:	%8zu kB\n"
+		"PeakMem:	%8zu kB\n",
+		stats.num_reads,
+		stats.num_writes,
+		stats.failed_reads,
+		stats.failed_writes,
+		stats.invalid_io,
+		good_compress_perc,
+		no_compress_perc,
+		stats.curr_pages,
+		K(stats.curr_mem),
+		K(stats.peak_mem));
+#endif
+	return len;
+}
+#endif	/* CONFIG_COMPCACHE_PROC */
+
+/* Check if request is within bounds and page aligned */
+static inline int valid_swap_request(struct bio *bio)
+{
+	if (unlikely((bio->bi_sector >= compcache.size) ||
+			(bio->bi_sector & (SECTORS_PER_PAGE - 1)) ||
+			(bio->bi_vcnt != 1) ||
+			(bio->bi_size != PAGE_SIZE) ||
+			(bio->bi_io_vec[0].bv_offset != 0)))
+		return 0;
+	return 1;
+}
+
+static int compcache_make_request(struct request_queue *queue, struct bio *bio)
+{
+	int ret;
+	size_t clen, page_no;
+	void *user_mem;
+	struct page *page;
+
+	if (!valid_swap_request(bio)) {
+		stat_inc(&stats.invalid_io);
+		goto out_nomap;
+	}
+
+	CC_DEBUG2("bio sector: %lu (%s)\n", (unsigned long)bio->bi_sector,
+				bio_data_dir(bio) == READ ? "R" : "W");
+
+	page = bio->bi_io_vec[0].bv_page;
+	page_no = bio->bi_sector >> SECTORS_PER_PAGE_SHIFT;
+	user_mem = kmap(page);
+
+	if (bio_data_dir(bio) == READ) {
+		stat_inc(&stats.num_reads);
+		/*
+		 * This is attempt to read before any previous write
+		 * to this location. This happens due to readahead when
+		 * swap device is read from user-space (e.g. during swapon)
+		 */
+		if (unlikely(compcache.table[page_no].addr == NULL)) {
+			CC_DEBUG("Read before write on swap device: "
+				"sector=%lu, size=%zu, offset=%zu\n",
+				(unsigned long)(bio->bi_sector),
+				bio->bi_size,
+				bio->bi_io_vec[0].bv_offset);
+			memset(user_mem, 0, PAGE_SIZE);
+			kunmap(page);
+			set_bit(BIO_UPTODATE, &bio->bi_flags);
+			bio_endio(bio, 0);
+			return 0;
+		}
+
+		/* Page is stored uncompressed since its incompressible */
+		if (unlikely(compcache.table[page_no].len == PAGE_SIZE)) {
+			memcpy(user_mem, compcache.table[page_no].addr,
+							PAGE_SIZE);
+			kunmap(page);
+			set_bit(BIO_UPTODATE, &bio->bi_flags);
+			bio_endio(bio, 0);
+			return 0;
+		}
+
+		clen = PAGE_SIZE;
+		ret = lzo1x_decompress_safe(
+			compcache.table[page_no].addr,
+			compcache.table[page_no].len,
+			user_mem,
+			&clen);
+
+		/* should NEVER happen */
+		if (unlikely(ret != LZO_E_OK)) {
+			pr_err(C "Decompression failed! "
+				"err=%d, page=%zu, len=%u\n", ret, page_no,
+				compcache.table[page_no].len);
+			stat_inc(&stats.failed_reads);
+			goto out;
+		}
+
+		CC_DEBUG2("Page decompressed: page_no=%zu\n", page_no);
+		kunmap(page);
+		set_bit(BIO_UPTODATE, &bio->bi_flags);
+		bio_endio(bio, 0);
+		return 0;
+	} else {	/* Write */
+		unsigned char *src = compcache.compress_buffer;
+		stat_inc(&stats.num_writes);
+		/*
+		 * System swaps to same sector again when the stored page
+		 * is no longer referenced by any process. So, its now safe
+		 * to free the memory that was allocated for this page.
+		 */
+		if (compcache.table[page_no].addr) {
+			CC_DEBUG2("Freeing page: %zu\n", page_no);
+			tlsf_free(compcache.table[page_no].addr,
+				compcache.mem_pool);
+			stat_dec(&stats.curr_pages);
+			compcache.table[page_no].addr = NULL;
+			compcache.table[page_no].len = 0;
+		}
+
+		mutex_lock(&compcache.lock);
+		ret = lzo1x_1_compress(user_mem, PAGE_SIZE,
+			src, &clen, compcache.compress_workmem);
+		if (unlikely(ret != LZO_E_OK)) {
+			mutex_unlock(&compcache.lock);
+			pr_err(C "Compression failed! err=%d\n", ret);
+			compcache.table[page_no].addr = NULL;
+			compcache.table[page_no].len = 0;
+			stat_inc(&stats.failed_writes);
+			goto out;
+		}
+
+		/* Page is incompressible - store it as is */
+		if (clen >= PAGE_SIZE) {
+			CC_DEBUG("Page expand on compression: "
+				"page=%zu, size=%zu\n", page_no, clen);
+			clen = PAGE_SIZE;
+			src = user_mem;
+		} else {
+			CC_DEBUG2("Page compressed: page_no=%zu, len=%zu\n",
+				page_no, clen);
+		}
+		if ((compcache.table[page_no].addr = tlsf_malloc(clen,
+					compcache.mem_pool)) == NULL) {
+			mutex_unlock(&compcache.lock);
+			pr_err(C "Error allocating memory for compressed "
+				"page: %zu, size=%zu \n", page_no, clen);
+			compcache.table[page_no].len = 0;
+			stat_inc(&stats.failed_writes);
+			goto out;
+		}
+		
+		memcpy(compcache.table[page_no].addr, src, clen);
+
+		/* Update stats */
+		stat_inc(&stats.curr_pages);
+		stat_set(&stats.curr_mem, stats.curr_mem + clen);
+		stat_setmax(&stats.peak_mem, stats.curr_mem);
+		stat_inc_if_less(&stats.pages_expand, PAGE_SIZE - 1, clen);
+		stat_inc_if_less(&stats.good_compress, clen,
+						PAGE_SIZE / 2 + 1);
+		mutex_unlock(&compcache.lock);
+		
+		compcache.table[page_no].len = clen;
+
+		kunmap(page);
+		set_bit(BIO_UPTODATE, &bio->bi_flags);
+		bio_endio(bio, 0);
+		return 0;
+	}
+out:
+	kunmap(page);
+out_nomap:
+	bio_io_error(bio);
+	return 0;
+}
+
+static void setup_swap_header(union swap_header *s)
+{
+	s->info.version = 1;
+	s->info.last_page = compcache.size >> SECTORS_PER_PAGE_SHIFT;
+	s->info.nr_badpages = 0;
+	memcpy(s->magic.magic, "SWAPSPACE2", 10);
+}
+
+static void *get_mem(size_t size)
+{
+	return __vmalloc(size, GFP_NOIO, PAGE_KERNEL);
+}
+
+static void put_mem(void *ptr)
+{
+	vfree(ptr);
+}
+
+static int __init compcache_init(void)
+{
+	int ret;
+	size_t num_pages;
+	struct sysinfo i;
+
+	mutex_init(&compcache.lock);
+
+	if (compcache_size_kbytes == 0) {
+		pr_info(C "compcache size not provided."
+			" Using default: (%u%% of Total RAM).\n"
+			"Use compcache_size_kbytes module param to specify"
+			" custom size\n", DEFAULT_COMPCACHE_PERCENT);
+		si_meminfo(&i);
+		compcache_size_kbytes = ((DEFAULT_COMPCACHE_PERCENT *
+				i.totalram) / 100) << (PAGE_SHIFT - 10);
+	}
+	
+	CC_DEBUG2("compcache_size_kbytes=%lu\n", compcache_size_kbytes);
+	compcache.size = compcache_size_kbytes << 10;
+	compcache.size = (compcache.size + PAGE_SIZE - 1) & PAGE_MASK;
+	pr_info(C "Compressed swap size set to: %zu KB\n", compcache.size >> 10);
+	compcache.size >>= SECTOR_SHIFT;
+
+	compcache.compress_workmem = kmalloc(LZO1X_MEM_COMPRESS, GFP_KERNEL);
+	if (compcache.compress_workmem == NULL) {
+		pr_err(C "Error allocating compressor working memory\n");
+		ret = -ENOMEM;
+		goto fail;
+	}
+
+	compcache.compress_buffer = kmalloc(2 * PAGE_SIZE, GFP_KERNEL);
+	if (compcache.compress_buffer == NULL) {
+		pr_err(C "Error allocating compressor buffer space\n");
+		ret = -ENOMEM;
+		goto fail;
+	}
+
+	num_pages = compcache.size >> SECTORS_PER_PAGE_SHIFT;
+        compcache.table = vmalloc(num_pages * sizeof(*compcache.table));
+        if (compcache.table == NULL) {
+                pr_err(C "Error allocating compcache address table\n");
+                ret = -ENOMEM;
+                goto fail;
+        }
+        memset(compcache.table, 0, num_pages * sizeof(*compcache.table));
+
+	compcache.table[0].addr = (void *)get_zeroed_page(GFP_KERNEL);
+	if (compcache.table[0].addr == NULL) {
+		pr_err(C "Error allocating swap header page\n");
+		ret = -ENOMEM;
+		goto fail;
+	}
+	compcache.table[0].len = PAGE_SIZE;
+	setup_swap_header((union swap_header *)(compcache.table[0].addr));
+
+	compcache.disk = alloc_disk(1);
+	if (compcache.disk == NULL) {
+		pr_err(C "Error allocating disk structure\n");
+		ret = -ENOMEM;
+		goto fail;
+	}
+
+	compcache.disk->first_minor = 0;
+	compcache.disk->fops = &compcache_devops;
+	/*
+	 * It is named like this to prevent distro installers
+	 * from offering compcache as installation target. They
+	 * seem to ignore all devices beginning with 'ram'
+	 */
+	sprintf(compcache.disk->disk_name, "%s", "ramzswap0");
+
+	compcache.disk->major = register_blkdev(0, compcache.disk->disk_name);
+	if (compcache.disk->major < 0) {
+		pr_err(C "Cannot register block device\n");
+		ret = -EFAULT;
+		goto fail;
+	}
+
+	compcache.disk->queue = blk_alloc_queue(GFP_KERNEL);
+	if (compcache.disk->queue == NULL) {
+		pr_err(C "Cannot register disk queue\n");
+		ret = -EFAULT;
+		goto fail;
+	}
+
+	set_capacity(compcache.disk, compcache.size);
+	blk_queue_make_request(compcache.disk->queue, compcache_make_request);
+	blk_queue_hardsect_size(compcache.disk->queue, PAGE_SIZE);
+	add_disk(compcache.disk);
+
+	compcache.mem_pool = tlsf_create_memory_pool("compcache",
+				get_mem, put_mem,
+				INIT_SIZE, 0, GROW_SIZE);
+	if (compcache.mem_pool == NULL) {
+		pr_err(C "Error creating memory pool\n");
+		ret = -ENOMEM;
+		goto fail;
+	}
+
+#ifdef CONFIG_COMPCACHE_PROC
+	proc = create_proc_entry("compcache", S_IRUGO, NULL);
+	if (proc)
+		proc->read_proc = &proc_compcache_read;
+	else {
+		ret = -ENOMEM;
+		pr_warning(C "Error creating proc entry\n");
+		goto fail;
+	}
+#endif
+
+	CC_DEBUG(C "Initialization done!\n");
+	return 0;
+
+fail:
+	if (compcache.disk != NULL) {
+		if (compcache.disk->major > 0)
+			unregister_blkdev(compcache.disk->major,
+					compcache.disk->disk_name);
+		del_gendisk(compcache.disk);
+	}
+
+	if (compcache.table[0].addr)
+		free_page((unsigned long)compcache.table[0].addr);
+	if (compcache.compress_workmem)
+		kfree(compcache.compress_workmem);
+	if (compcache.compress_buffer)
+		kfree(compcache.compress_buffer);
+	if (compcache.table)
+		vfree(compcache.table);
+	if (compcache.mem_pool)
+		tlsf_destroy_memory_pool(compcache.mem_pool);
+#ifdef CONFIG_COMPCACHE_PROC
+	if (proc)
+		remove_proc_entry("compcache", &proc_root);
+#endif
+	pr_err(C "Initialization failed: err=%d\n", ret);
+	return ret;
+}
+
+static void __exit compcache_exit(void)
+{
+	size_t i, num_pages;
+	num_pages = compcache.size >> SECTORS_PER_PAGE_SHIFT;
+
+	unregister_blkdev(compcache.disk->major, compcache.disk->disk_name);
+	del_gendisk(compcache.disk);
+	free_page((unsigned long)compcache.table[0].addr);
+	kfree(compcache.compress_workmem);
+	kfree(compcache.compress_buffer);
+
+	/* Free all pages that are still in compcache */
+	for (i = 1; i < num_pages; i++)
+		if (compcache.table[i].addr)
+			tlsf_free(compcache.table[i].addr, compcache.mem_pool);
+	vfree(compcache.table);
+	tlsf_destroy_memory_pool(compcache.mem_pool);
+
+#ifdef CONFIG_COMPCACHE_PROC
+	remove_proc_entry("compcache", &proc_root);
+#endif
+	CC_DEBUG("cleanup done!\n");
+}
+
+module_param(compcache_size_kbytes, ulong, 0);
+MODULE_PARM_DESC(compcache_size_kbytes, "compcache device size (in KB)");
+
+module_init(compcache_init);
+module_exit(compcache_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Nitin Gupta <nitingupta910 at gmail dot com>");
+MODULE_DESCRIPTION("Compressed RAM Based Swap Device");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
