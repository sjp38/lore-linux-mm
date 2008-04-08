From: Nitin Gupta <nitingupta910@gmail.com>
Subject: [PATCH 2/3] compcache: TLSF Allocator
Date: Tue, 8 Apr 2008 15:05:55 +0530
Message-ID: <200804081505.55195.nitingupta910@gmail.com>
References: <200804081459.27382.nitingupta910@gmail.com>
Reply-To: nitingupta910@gmail.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752295AbYDHJsZ@vger.kernel.org>
In-Reply-To: <200804081459.27382.nitingupta910@gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Two Level Segregate Fit (TLSF) Allocator is used to allocate memory for
variable size compressed pages. Its fast and gives low fragmentation.
Following links give details on this allocator:
 - http://rtportal.upv.es/rtmalloc/files/tlsf_paper_spe_2007.pdf

In tests, it shows ~43% less memory usage than SLUB!
See: http://code.google.com/p/compcache/wiki/AllocatorsComparison

This kernel port of TLSF (v2.3.2) introduces several changes but underlying
algorithm remains the same.

Changelog TLSF v2.3.2 vs this kernel port
 - Pool now dynamically expands/shrinks.
  It is collection of contiguous memory regions.
 - Changes to pool create interface as a result of above change.
 - It is not scalable (lack of per-cpu data structures etc.)
 - Collect and export stats (/proc/tlsfinfo)
 - Cleanups: kernel coding style, added comments, macros -> static inline, etc.

Signed-off-by: Nitin Gupta <nitingupta910 at gmail dot com>
---
 include/linux/tlsf.h |   93 +++++++
 init/Kconfig         |   28 ++
 mm/Makefile          |    1 +
 mm/tlsf.c            |  676 ++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/tlsf_int.h        |  145 +++++++++++
 5 files changed, 943 insertions(+), 0 deletions(-)

diff --git a/include/linux/tlsf.h b/include/linux/tlsf.h
new file mode 100644
index 0000000..bc224b5
--- /dev/null
+++ b/include/linux/tlsf.h
@@ -0,0 +1,93 @@
+/*
+ * Two Levels Segregate Fit memory allocator (TLSF)
+ * Version 2.3.2
+ *
+ * Written by Miguel Masmano Tello <mimastel@doctor.upv.es>
+ *
+ * Thanks to Ismael Ripoll for his suggestions and reviews
+ *
+ * Copyright (C) 2007, 2006, 2005, 2004
+ *
+ * This code is released using a dual license strategy: GPL/LGPL
+ * You can choose the licence that better fits your requirements.
+ *
+ * Released under the terms of the GNU General Public License Version 2.0
+ * Released under the terms of the GNU Lesser General Public License Version 2.1
+ *
+ * This is kernel port of TLSF allocator.
+ * Original code can be found at: http://rtportal.upv.es/rtmalloc/
+ * 	- Nitin Gupta (nitingupta910@gmail.com)
+ */
+
+#ifndef _TLSF_H_
+#define _TLSF_H_
+
+typedef void* (get_memory)(size_t bytes);
+typedef void (put_memory)(void *ptr);
+
+/**
+ * tlsf_create_memory_pool - create dynamic memory pool
+ * @name: name of the pool
+ * @get_mem: callback function used to expand pool
+ * @put_mem: callback function used to shrink pool
+ * @init_size: inital pool size (in bytes)
+ * @max_size: maximum pool size (in bytes) - set this as 0 for no limit
+ * @grow_size: amount of memory (in bytes) added to pool whenever required
+ *
+ * All size values are rounded up to next page boundary.
+ */
+extern void *tlsf_create_memory_pool(const char *name,
+					get_memory get_mem,
+					put_memory put_mem,
+					size_t init_size,
+					size_t max_size,
+					size_t grow_size);
+/**
+ * tlsf_destory_memory_pool - cleanup given pool
+ * @mem_pool: Pool to be destroyed
+ *
+ * Data structures associated with pool are freed.
+ * All memory allocated from pool must be freed before
+ * destorying it.
+ */
+extern void tlsf_destroy_memory_pool(void *mem_pool);
+
+/**
+ * tlsf_malloc - allocate memory from given pool
+ * @size: no. of bytes
+ * @mem_pool: pool to allocate from
+ */
+extern void *tlsf_malloc(size_t size, void *mem_pool);
+
+/**
+ * tlsf_calloc - allocate and zero-out memory from given pool
+ * @size: no. of bytes
+ * @mem_pool: pool to allocate from
+ */
+extern void *tlsf_calloc(size_t nelem, size_t elem_size, void *mem_pool);
+
+/**
+ * tlsf_free - free memory from given pool
+ * @ptr: address of memory to be freed
+ * @mem_pool: pool to free from
+ */
+extern void tlsf_free(void *ptr, void *mem_pool);
+
+/**
+ * tlsf_get_used_size - get memory currently used by given pool
+ *
+ * Used memory includes stored data + metadata + internal fragmentation
+ */
+extern size_t tlsf_get_used_size(void *mem_pool);
+
+/**
+ * tlsf_get_total_size - get total memory currently allocated for given pool
+ *
+ * This is the total memory currently allocated for this pool which includes
+ * used size + free size.
+ *
+ * (Total - Used) is good indicator of memory efficiency of allocator.
+ */
+extern size_t tlsf_get_total_size(void *mem_pool);
+
+#endif
diff --git a/init/Kconfig b/init/Kconfig
index a97924b..d51d476 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -734,6 +734,34 @@ config SLOB
 
 endchoice
 
+config TLSF
+	depends on EMBEDDED
+	tristate "TLSF Allocator"
+	help
+	  Two Level Segregate Fit Allocator. Its fast and gives low
+	  fragmentation. See:
+		http://rtportal.upv.es/rtmalloc/
+		http://code.google.com/p/compcache/wiki/TLSFAllocator
+	  for more information.
+
+config TLSF_DEBUG
+	default y
+	depends on TLSF
+	bool "Enable TLSF allocator debugging" if EMBEDDED
+	help
+	  Enable TLSF debugging.
+	  This causes negligible performance loss and size increase.
+	  If unusure, say Y. 
+
+config TLSF_STATS
+	default N
+	depends on TLSF
+	bool "Collect TLSF statistics" if EMBEDDED
+	help
+	  Creates /proc/tlsfinfo to export various tlsf statistics.
+	  This adds about 30K to size with significant performance loss.
+	  If unsure, say N.
+
 config PROFILING
 	bool "Profiling support (EXPERIMENTAL)"
 	help
diff --git a/mm/Makefile b/mm/Makefile
index a5b0dd9..4e2398f 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -27,6 +27,7 @@ obj-$(CONFIG_TINY_SHMEM) += tiny-shmem.o
 obj-$(CONFIG_SLOB) += slob.o
 obj-$(CONFIG_SLAB) += slab.o
 obj-$(CONFIG_SLUB) += slub.o
+obj-$(CONFIG_TLSF) += tlsf.o
 obj-$(CONFIG_MEMORY_HOTPLUG) += memory_hotplug.o
 obj-$(CONFIG_FS_XIP) += filemap_xip.o
 obj-$(CONFIG_MIGRATION) += migrate.o
diff --git a/mm/tlsf.c b/mm/tlsf.c
new file mode 100644
index 0000000..e3b517d
--- /dev/null
+++ b/mm/tlsf.c
@@ -0,0 +1,676 @@
+/*
+ * Two Levels Segregate Fit memory allocator (TLSF)
+ * Version 2.3.2
+ *
+ * Written by Miguel Masmano Tello <mimastel@doctor.upv.es>
+ *
+ * Thanks to Ismael Ripoll for his suggestions and reviews
+ *
+ * Copyright (C) 2007, 2006, 2005, 2004
+ *
+ * This code is released using a dual license strategy: GPL/LGPL
+ * You can choose the licence that better fits your requirements.
+ *
+ * Released under the terms of the GNU General Public License Version 2.0
+ * Released under the terms of the GNU Lesser General Public License Version 2.1
+ *
+ * This is kernel port of TLSF allocator.
+ * Original code can be found at: http://rtportal.upv.es/rtmalloc/
+ * 	- Nitin Gupta (nitingupta910@gmail.com)
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
+#include <linux/string.h>
+#include <linux/tlsf.h>
+
+#include "tlsf_int.h"
+
+static struct mutex pool_list_lock;
+static struct list_head pool_list_head;
+
+#if defined(CONFIG_TLSF_STATS)
+static struct proc_dir_entry *proc;
+
+/* Print in format similar to /proc/slabinfo -- easy to awk */
+static void print_tlsfinfo_header(struct seq_file *tlsf)
+{
+	seq_puts(tlsf, "# Size in kB\n");
+	seq_puts(tlsf, "# name         <init_size> <max_size> <grow_size>"
+			" <used_size> <total_size> <extra>");
+#if defined(CONFIG_TLSF_STATS)
+	seq_puts(tlsf, " <peak_used> <peak_total> <peak_extra>"
+		" <count_alloc> <count_free> <count_region_alloc>"
+		" <count_region_free> <failed_alloc>");
+#endif
+#if defined(CONFIG_TLSF_DEBUG)
+	seq_puts(tlsf, " <valid>");
+#endif
+
+	seq_putc(tlsf, '\n');
+}
+
+/* Get pool no. (*pos) from pool list */
+static void *tlsf_start(struct seq_file *tlsf, loff_t *pos)
+{
+	struct list_head *lp;
+	loff_t p = *pos;
+
+	mutex_lock(&pool_list_lock);
+	if (!p)
+		return SEQ_START_TOKEN;
+
+	list_for_each(lp, &pool_list_head) {
+		if (!--p)
+			return lp;
+	}
+
+	return NULL;
+}
+
+/* Get pool next to the one given by tlsf_start()/previous tlsf_next() */
+static void *tlsf_next(struct seq_file *tlsf, void *v, loff_t *pos)
+{
+	struct list_head *lp;
+
+	if (v == SEQ_START_TOKEN)
+		lp = &pool_list_head;
+	else
+		lp = v;
+
+	lp = lp->next;
+	if (lp == &pool_list_head)
+		return NULL;
+
+	++*pos;
+	return lp;
+}
+
+static void tlsf_stop(struct seq_file *tlsf, void *v)
+{
+	mutex_unlock(&pool_list_lock);
+}
+
+/* Display stats for pool given by tlsf_next() */
+static int tlsf_show(struct seq_file *tlsf, void *v)
+{
+	struct pool *pool;
+	size_t used, total;
+	if (v == SEQ_START_TOKEN) {
+		print_tlsfinfo_header(tlsf);
+		return 0;
+	}
+
+	pool = list_entry(v, struct pool, list);
+	used = tlsf_get_used_size(pool);
+	total = tlsf_get_total_size(pool);
+#define K(x)	((x) >> 10)
+	seq_printf(tlsf, "%-16s %6zu %6zu %6zu %6zu %6zu %6zu",
+			pool->name,
+			K(pool->init_size),
+			K(pool->max_size),
+			K(pool->grow_size),
+			K(used),
+			K(total),
+			K(total - used));
+
+#if defined(CONFIG_TLSF_STATS)
+	seq_printf(tlsf, " %6zu %6zu %6zu %6zu %6zu %6zu %6zu %6zu",
+			K(pool->peak_used),
+			K(pool->peak_total),
+			K(pool->peak_extra),
+			pool->count_alloc,
+			pool->count_free,
+			pool->count_region_alloc,
+			pool->count_region_free,
+			pool->count_failed_alloc);
+#endif
+
+#if defined(CONFIG_TLSF_DEBUG)
+	seq_printf(tlsf, " %u", pool->valid);
+#endif
+
+	seq_putc(tlsf, '\n');
+	return 0;
+}
+
+static struct seq_operations tlsfinfo_op = {
+	.start = tlsf_start,
+	.next = tlsf_next,
+	.stop = tlsf_stop,
+	.show = tlsf_show,
+};
+
+static int tlsfinfo_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &tlsfinfo_op);
+}
+
+static const struct file_operations proc_tlsfinfo_operations = {
+	.open		= tlsfinfo_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+#endif	/* CONFIG_TLSF_STATS */
+
+/*
+ * Helping functions
+ */
+
+/**
+ * Returns indexes (fl, sl) of the list used to serve request of size r
+ */
+static inline void MAPPING_SEARCH(size_t *r, int *fl, int *sl)
+{
+	int t;
+
+	if (*r < SMALL_BLOCK) {
+		*fl = 0;
+		*sl = *r / (SMALL_BLOCK / MAX_SLI);
+	} else {
+		t = (1 << (fls(*r) - 1 - MAX_LOG2_SLI)) - 1;
+		*r = *r + t;
+		*fl = fls(*r) - 1;
+		*sl = (*r >> (*fl - MAX_LOG2_SLI)) - MAX_SLI;
+		*fl -= FLI_OFFSET;
+		/*if ((*fl -= FLI_OFFSET) < 0) // FL will be always >0!
+		 *fl = *sl = 0;
+		 */
+		*r &= ~t;
+	}
+}
+
+/**
+ * Returns indexes (fl, sl) which is used as starting point to search
+ * for a block of size r. It also rounds up requested size(r) to the
+ * next list.
+ */
+static inline void MAPPING_INSERT(size_t r, int *fl, int *sl)
+{
+	if (r < SMALL_BLOCK) {
+		*fl = 0;
+		*sl = r / (SMALL_BLOCK / MAX_SLI);
+	} else {
+		*fl = fls(r) - 1;
+		*sl = (r >> (*fl - MAX_LOG2_SLI)) - MAX_SLI;
+		*fl -= FLI_OFFSET;
+	}
+}
+
+/**
+ * Returns first block from a list that hold blocks larger than or
+ * equal to the one pointed by the indexes (fl, sl)
+ */
+static inline struct bhdr *FIND_SUITABLE_BLOCK(struct pool *p, int *fl,
+						int *sl)
+{
+	u32 tmp = p->sl_bitmap[*fl] & (~0 << *sl);
+	struct bhdr *b = NULL;
+
+	if (tmp) {
+		*sl = ffs(tmp) - 1;
+		b = p->matrix[*fl][*sl];
+	} else {
+		*fl = ffs(p->fl_bitmap & (~0 << (*fl + 1))) - 1;
+		if (*fl > 0) {		/* likely */
+			*sl = ffs(p->sl_bitmap[*fl]) - 1;
+			b = p->matrix[*fl][*sl];
+		}
+	}
+	return b;
+}
+
+/**
+ * Remove first free block(b) from free list with indexes (fl, sl).
+ */
+static inline void EXTRACT_BLOCK_HDR(struct bhdr *b, struct pool *p, int fl,
+					int sl)
+{
+	p->matrix[fl][sl] = b->ptr.free_ptr.next;
+	if (p->matrix[fl][sl])
+		p->matrix[fl][sl]->ptr.free_ptr.prev = NULL;
+	else {
+		clear_bit(sl, (void *)&p->sl_bitmap[fl]);
+		if(!p->sl_bitmap[fl])
+			clear_bit (fl, (void *)&p->fl_bitmap);
+	}
+	b->ptr.free_ptr = (struct free_ptr) {NULL, NULL};
+}
+
+/**
+ * Removes block(b) from free list with indexes (fl, sl)
+ */
+static inline void EXTRACT_BLOCK(struct bhdr *b, struct pool *p, int fl,
+					int sl)
+{
+	if (b->ptr.free_ptr.next)
+		b->ptr.free_ptr.next->ptr.free_ptr.prev =
+					b->ptr.free_ptr.prev;
+	if (b->ptr.free_ptr.prev)
+		b->ptr.free_ptr.prev->ptr.free_ptr.next =
+					b->ptr.free_ptr.next;
+	if (p->matrix[fl][sl] == b) {
+		p->matrix[fl][sl] = b->ptr.free_ptr.next;
+		if (!p->matrix[fl][sl]) {
+			clear_bit(sl, (void *)&p->sl_bitmap[fl]);
+			if (!p->sl_bitmap[fl])
+				clear_bit (fl, (void *)&p->fl_bitmap);
+		}
+	}
+	b->ptr.free_ptr = (struct free_ptr) {NULL, NULL};
+}
+
+/**
+ * Insert block(b) in free list with indexes (fl, sl)
+ */
+static inline void INSERT_BLOCK(struct bhdr *b, struct pool *p, int fl, int sl)
+{
+	b->ptr.free_ptr = (struct free_ptr) {NULL, p->matrix[fl][sl]};
+	if (p->matrix[fl][sl])
+		p->matrix[fl][sl]->ptr.free_ptr.prev = b;
+	p->matrix[fl][sl] = b;
+	set_bit(sl, (void *)&p->sl_bitmap[fl]);
+	set_bit(fl, (void *)&p->fl_bitmap);
+}
+
+/**
+ * Region is a virtually contiguous memory region and Pool is
+ * collection of such regions
+ */
+static inline void ADD_REGION(void *region, size_t region_size,
+					struct pool *pool)
+{
+	int fl, sl;
+	struct bhdr *b, *lb;
+
+	b = (struct bhdr *)(region);
+	b->prev_hdr = NULL;
+	b->size = ROUNDDOWN_SIZE(region_size - 2 * BHDR_OVERHEAD)
+						| FREE_BLOCK | PREV_USED;
+	MAPPING_INSERT(b->size & BLOCK_SIZE_MASK, &fl, &sl);
+	INSERT_BLOCK(b, pool, fl, sl);
+	/* The sentinel block: allows us to know when we're in the last block */
+	lb = GET_NEXT_BLOCK(b->ptr.buffer, b->size & BLOCK_SIZE_MASK);
+	lb->prev_hdr = b;
+	lb->size = 0 | USED_BLOCK | PREV_FREE;
+	pool->used_size += BHDR_OVERHEAD; /* only sentinel block is "used" */
+	pool->num_regions++;
+	stat_inc(pool->count_region_alloc);
+}
+
+/*
+ * Allocator code start
+ */
+
+/**
+ * tlsf_create_memory_pool - create dynamic memory pool
+ * @name: name of the pool
+ * @get_mem: callback function used to expand pool
+ * @put_mem: callback function used to shrink pool
+ * @init_size: inital pool size (in bytes)
+ * @max_size: maximum pool size (in bytes) - set this as 0 for no limit
+ * @grow_size: amount of memory (in bytes) added to pool whenever required
+ *
+ * All size values are rounded up to next page boundary.
+ */
+void *tlsf_create_memory_pool(const char *name,
+			get_memory get_mem,
+			put_memory put_mem,
+			size_t init_size,
+			size_t max_size,
+			size_t grow_size)
+{
+	struct pool *pool;
+	void *region;
+#if defined(CONFIG_TLSF_STATS)
+	size_t used, total;
+#endif
+
+	if (max_size)	
+		BUG_ON(max_size < init_size);
+
+	pool = get_mem(ROUNDUP_SIZE(sizeof(*pool)));
+	if (pool == NULL)
+		goto out;
+	memset(pool, 0, ROUNDUP_SIZE(sizeof(*pool)));
+
+	/* Round to next page boundary */
+	init_size = ROUNDUP_PAGE(init_size);
+	max_size = ROUNDUP_PAGE(max_size);
+	grow_size = ROUNDUP_PAGE(grow_size);
+	pr_info(T "pool: %p, init_size=%zu, max_size=%zu, grow_size=%zu\n",
+			pool, init_size, max_size, grow_size);
+
+	/* pool global overhead not included in used size */
+	pool->used_size = 0;
+
+	pool->init_size = init_size;
+	pool->max_size = max_size;
+	pool->grow_size = grow_size;
+	pool->get_mem = get_mem;
+	pool->put_mem = put_mem;
+	strncpy(pool->name, name, MAX_POOL_NAME_LEN);
+	pool->name[MAX_POOL_NAME_LEN - 1] = '\0';
+#if defined(CONFIG_TLSF_DEBUG)
+	pool->valid = 1;
+#endif
+	region = get_mem(init_size);
+	if (region == NULL)
+		goto out_region;
+	ADD_REGION(region, init_size, pool);
+	pool->init_region = region;
+
+	mutex_init(&pool->lock);
+
+	mutex_lock(&pool_list_lock);
+	list_add_tail(&pool->list, &pool_list_head);
+	mutex_unlock(&pool_list_lock);
+
+	/* Pool created: update stats */
+	stat_set(used, tlsf_get_used_size(pool));
+	stat_set(total, tlsf_get_total_size(pool));
+	stat_inc(pool->count_alloc);
+	stat_setmax(pool->peak_extra, total - used);
+	stat_setmax(pool->peak_used, used);
+	stat_setmax(pool->peak_total, total);
+
+	return pool;
+
+out_region:
+	put_mem(pool);
+
+out:
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(tlsf_create_memory_pool);
+
+/**
+ * tlsf_get_used_size - get memory currently used by given pool
+ *
+ * Used memory includes stored data + metadata + internal fragmentation
+ */
+size_t tlsf_get_used_size(void *mem_pool)
+{
+	struct pool *pool = (struct pool *)mem_pool;
+	return pool->used_size;
+}
+EXPORT_SYMBOL_GPL(tlsf_get_used_size);
+
+/**
+ * tlsf_get_total_size - get total memory currently allocated for given pool
+ *
+ * This is the total memory currently allocated for this pool which includes
+ * used size + free size.
+ *
+ * (Total - Used) is good indicator of memory efficiency of allocator.
+ */
+size_t tlsf_get_total_size(void *mem_pool)
+{
+	size_t total;
+	struct pool *pool = (struct pool *)mem_pool;
+	total = ROUNDUP_SIZE(sizeof(*pool))
+		+ pool->init_size
+		+ (pool->num_regions - 1) * pool->grow_size;
+	return total;
+}
+EXPORT_SYMBOL_GPL(tlsf_get_total_size);
+
+/**
+ * tlsf_destory_memory_pool - cleanup given pool
+ * @mem_pool: Pool to be destroyed
+ *
+ * Data structures associated with pool are freed.
+ * All memory allocated from pool must be freed before
+ * destorying it.
+ */
+void tlsf_destroy_memory_pool(void *mem_pool) 
+{
+	struct pool *pool;
+
+	if (mem_pool == NULL)
+		return;
+
+	pool = (struct pool *)mem_pool;
+
+	/* User is destorying without ever allocating from this pool */
+	if (tlsf_get_used_size(pool) == BHDR_OVERHEAD) {
+		pool->put_mem(pool->init_region);
+		pool->used_size -= BHDR_OVERHEAD;
+		stat_inc(pool->count_region_free);
+	}
+
+	/* Check for memory leaks in this pool */
+	if (tlsf_get_used_size(pool)) {
+		pr_warning(T "memory leak in pool: %s (%p). "
+			"%zu bytes still in use.\n",
+			pool->name, pool, tlsf_get_used_size(pool));
+
+#if defined(CONFIG_TLSF_DEBUG)
+		pool->valid = 0;
+		/* Invalid pools stay in list for debugging purpose */
+		return;
+#endif
+	}
+	mutex_lock(&pool_list_lock);
+	list_del_init(&pool->list);
+	mutex_unlock(&pool_list_lock);
+	pool->put_mem(pool);
+}
+EXPORT_SYMBOL_GPL(tlsf_destroy_memory_pool);
+
+/**
+ * tlsf_malloc - allocate memory from given pool
+ * @size: no. of bytes
+ * @mem_pool: pool to allocate from
+ */
+void *tlsf_malloc(size_t size, void *mem_pool)
+{
+	struct pool *pool = (struct pool *)mem_pool;
+	struct bhdr *b, *b2, *next_b, *region;
+	int fl, sl;
+	size_t tmp_size;
+#if defined(CONFIG_TLSF_STATS)
+	size_t used, total;
+#endif
+
+#if defined(CONFIG_TLSF_DEBUG)
+	unsigned int retries = 0;
+#endif
+
+	size = (size < MIN_BLOCK_SIZE) ? MIN_BLOCK_SIZE : ROUNDUP_SIZE(size);
+	/* Rounding up the requested size and calculating fl and sl */
+
+	mutex_lock(&pool->lock);
+retry_find:
+	MAPPING_SEARCH(&size, &fl, &sl);
+
+	/* Searching a free block */
+	if (!(b = FIND_SUITABLE_BLOCK(pool, &fl, &sl))) {
+#if defined(CONFIG_TLSF_DEBUG)
+		/*
+		 * This can happen if there are too many users
+		 * allocating from this pool simultaneously.
+		 */
+		if (unlikely(retries == MAX_RETRY_EXPAND))
+			goto out_locked;
+		retries++;
+#endif
+		/* Not found */
+		if (size > (pool->grow_size - 2 * BHDR_OVERHEAD))
+			goto out_locked;
+		if (pool->max_size && (pool->init_size +
+				pool->num_regions * pool->grow_size
+				> pool->max_size))
+			goto out_locked;
+		mutex_unlock(&pool->lock);
+		if ((region = pool->get_mem(pool->grow_size)) == NULL)
+			goto out;
+		mutex_lock(&pool->lock);
+		ADD_REGION(region, pool->grow_size, pool);
+		goto retry_find;
+	}
+	EXTRACT_BLOCK_HDR(b, pool, fl, sl);
+
+	/*-- found: */
+	next_b = GET_NEXT_BLOCK(b->ptr.buffer, b->size & BLOCK_SIZE_MASK);
+	/* Should the block be split? */
+	tmp_size = (b->size & BLOCK_SIZE_MASK) - size;
+	if (tmp_size >= sizeof(struct bhdr) ) {
+		tmp_size -= BHDR_OVERHEAD;
+		b2 = GET_NEXT_BLOCK(b->ptr.buffer, size);
+
+		b2->size = tmp_size | FREE_BLOCK | PREV_USED;
+		b2->prev_hdr = b;
+
+		next_b->prev_hdr = b2;
+
+		MAPPING_INSERT(tmp_size, &fl, &sl);
+		INSERT_BLOCK(b2, pool, fl, sl);
+
+		b->size = size | (b->size & PREV_STATE);
+	} else {
+		next_b->size &= (~PREV_FREE);
+		b->size &= (~FREE_BLOCK);	/* Now it's used */
+	}
+
+	pool->used_size += (b->size & BLOCK_SIZE_MASK) + BHDR_OVERHEAD;
+
+	/* Successful alloc: update stats. */
+	stat_set(used, tlsf_get_used_size(pool));
+	stat_set(total, tlsf_get_total_size(pool));
+	stat_inc(pool->count_alloc);
+	stat_setmax(pool->peak_extra, total - used);
+	stat_setmax(pool->peak_used, used);
+	stat_setmax(pool->peak_total, total);
+
+	mutex_unlock(&pool->lock);
+	return (void *)b->ptr.buffer;
+
+	/* Failed alloc */
+out_locked:
+	mutex_unlock(&pool->lock);
+
+out:
+	stat_inc(pool->count_failed_alloc);
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(tlsf_malloc);
+
+/**
+ * tlsf_free - free memory from given pool
+ * @ptr: address of memory to be freed
+ * @mem_pool: pool to free from
+ */
+void tlsf_free(void *ptr, void *mem_pool)
+{
+	struct pool *pool = (struct pool *)mem_pool;
+	struct bhdr *b, *tmp_b;
+	int fl = 0, sl = 0;
+#if defined(CONFIG_TLSF_STATS)
+	size_t used, total;
+#endif
+	if (unlikely(ptr == NULL))
+		return;
+
+	b = (struct bhdr *) ((char *) ptr - BHDR_OVERHEAD);
+
+	mutex_lock(&pool->lock);
+	b->size |= FREE_BLOCK;
+	pool->used_size -= (b->size & BLOCK_SIZE_MASK) + BHDR_OVERHEAD;
+	b->ptr.free_ptr = (struct free_ptr) { NULL, NULL};
+	tmp_b = GET_NEXT_BLOCK(b->ptr.buffer, b->size & BLOCK_SIZE_MASK);
+	if (tmp_b->size & FREE_BLOCK) {
+		MAPPING_INSERT(tmp_b->size & BLOCK_SIZE_MASK, &fl, &sl);
+		EXTRACT_BLOCK(tmp_b, pool, fl, sl);
+		b->size += (tmp_b->size & BLOCK_SIZE_MASK) + BHDR_OVERHEAD;
+	}
+	if (b->size & PREV_FREE) {
+		tmp_b = b->prev_hdr;
+		MAPPING_INSERT(tmp_b->size & BLOCK_SIZE_MASK, &fl, &sl);
+		EXTRACT_BLOCK(tmp_b, pool, fl, sl);
+		tmp_b->size += (b->size & BLOCK_SIZE_MASK) + BHDR_OVERHEAD;
+		b = tmp_b;
+	}
+	tmp_b = GET_NEXT_BLOCK(b->ptr.buffer, b->size & BLOCK_SIZE_MASK);
+	tmp_b->prev_hdr = b;
+
+	MAPPING_INSERT(b->size & BLOCK_SIZE_MASK, &fl, &sl);
+
+	if ((b->prev_hdr == NULL) && ((tmp_b->size & BLOCK_SIZE_MASK) == 0)) {
+		pool->put_mem(b);
+		pool->num_regions--;
+		pool->used_size -= BHDR_OVERHEAD; /* sentinel block header */
+		stat_inc(pool->count_region_free);
+		goto out;
+	}
+	
+	INSERT_BLOCK(b, pool, fl, sl);
+
+	tmp_b->size |= PREV_FREE;
+	tmp_b->prev_hdr = b;
+out:
+	/* Update stats */
+	stat_set(used, tlsf_get_used_size(pool));
+	stat_set(total, tlsf_get_total_size(pool));
+	stat_inc(pool->count_free);
+	stat_setmax(pool->peak_extra, total - used);
+	stat_setmax(pool->peak_used, used);
+	stat_setmax(pool->peak_total, total);
+
+	mutex_unlock(&pool->lock);
+}
+EXPORT_SYMBOL_GPL(tlsf_free);
+
+/**
+ * tlsf_calloc - allocate and zero-out memory from given pool
+ * @size: no. of bytes
+ * @mem_pool: pool to allocate from
+ */
+void *tlsf_calloc(size_t nelem, size_t elem_size, void *mem_pool)
+{
+	void *ptr;
+
+	if (nelem == 0 || elem_size == 0)
+		return NULL;
+
+	if ((ptr = tlsf_malloc(nelem * elem_size, mem_pool)) == NULL)
+		return NULL;
+	memset(ptr, 0, nelem * elem_size);
+
+	return ptr;
+}
+EXPORT_SYMBOL_GPL(tlsf_calloc);
+
+static int __init tlsf_init(void)
+{
+	INIT_LIST_HEAD(&pool_list_head);
+	mutex_init(&pool_list_lock);
+#if defined(CONFIG_TLSF_STATS)
+	proc = create_proc_entry("tlsfinfo", S_IRUGO, NULL);
+	if (proc)
+		proc->proc_fops = &proc_tlsfinfo_operations;
+	else
+		pr_warning(T "error creating proc entry\n");
+#endif
+	return 0;
+}
+
+static void __exit tlsf_exit(void)
+{
+#if defined(CONFIG_TLSF_STATS)
+	if (proc)
+		remove_proc_entry("tlsfinfo", &proc_root);
+#endif
+	return;
+}
+
+module_init(tlsf_init);
+module_exit(tlsf_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Nitin Gupta <nitingupta910@gmail.com>");
+MODULE_DESCRIPTION("TLSF Memory Allocator");
diff --git a/mm/tlsf_int.h b/mm/tlsf_int.h
new file mode 100644
index 0000000..377eb8a
--- /dev/null
+++ b/mm/tlsf_int.h
@@ -0,0 +1,145 @@
+/*
+ * To be used internally by TLSF allocator.
+ */
+
+#ifndef _TLSF_INT_H_
+#define _TLSF_INT_H_
+
+#include <linux/tlsf.h>
+#include <asm/types.h>
+
+/* Debugging and Stats */
+#define NOP	do { } while(0)
+
+#if defined(CONFIG_TLSF_STATS)
+#define stat_inc(stat)		(stat++)
+#define stat_set(stat, val)	(stat = val)
+#define stat_setmax(stat, curr)	(stat = (curr) > stat ? (curr) : stat) 
+
+#else	/* STATS */
+#define stat_inc(x)		NOP
+#define stat_dec(x)		NOP
+#define stat_set(x, v)		NOP
+#define stat_setmax(x, v)	NOP
+#endif	/* STATS */
+
+/* Messsage prefix */
+#define T "TLSF: "
+
+#define MAX_POOL_NAME_LEN	16
+
+/*-- TLSF structures */
+
+/* Some IMPORTANT TLSF parameters */
+#define MEM_ALIGN	(sizeof(void *) * 2)
+#define MEM_ALIGN_MASK	(~(MEM_ALIGN - 1))
+
+#define MAX_FLI		(30)
+#define MAX_LOG2_SLI	(5)
+#define MAX_SLI		(1 << MAX_LOG2_SLI)
+
+#define FLI_OFFSET	(6)
+/* tlsf structure just will manage blocks bigger than 128 bytes */
+#define SMALL_BLOCK	(128)
+#define REAL_FLI	(MAX_FLI - FLI_OFFSET)
+#define MIN_BLOCK_SIZE	(sizeof(struct free_ptr))
+#define BHDR_OVERHEAD	(sizeof(struct bhdr) - MIN_BLOCK_SIZE)
+
+#define	PTR_MASK	(sizeof(void *) - 1)
+#define BLOCK_SIZE_MASK	(0xFFFFFFFF - PTR_MASK)
+
+#define GET_NEXT_BLOCK(addr, r)	((struct bhdr *) \
+				((char *)(addr) + (r)))
+#define ROUNDUP_SIZE(r)		(((r) + MEM_ALIGN - 1) & MEM_ALIGN_MASK)
+#define ROUNDDOWN_SIZE(r)	((r) & MEM_ALIGN_MASK)
+#define ROUNDUP_PAGE(r)		(((r) + PAGE_SIZE - 1) & PAGE_MASK)
+
+#define BLOCK_STATE	(0x1)
+#define PREV_STATE	(0x2)
+
+/* bit 0 of the block size */
+#define FREE_BLOCK	(0x1)
+#define USED_BLOCK	(0x0)
+
+/* bit 1 of the block size */
+#define PREV_FREE	(0x2)
+#define PREV_USED	(0x0)
+
+#if defined(CONFIG_TLSF_DEBUG)
+#define MAX_RETRY_EXPAND	10
+#endif
+
+struct free_ptr {
+	struct bhdr *prev;
+	struct bhdr *next;
+};
+
+struct bhdr {
+	/* All blocks in a region are linked in order of physical address */
+	struct bhdr *prev_hdr;
+	/*
+	 * The size is stored in bytes
+	 * 	bit 0: block is free, if set
+	 * 	bit 1: previous block is free, if set
+	 */
+	u32 size;
+	/* Free blocks in individual freelists are linked */
+	union {
+		struct free_ptr free_ptr;
+		u8 buffer[sizeof(struct free_ptr)];
+	} ptr;
+};
+
+struct pool {
+	/* First level bitmap (REAL_FLI bits) */
+	u32 fl_bitmap;
+
+	/* Second level bitmap */
+	u32 sl_bitmap[REAL_FLI];
+
+	/* Free lists */
+	struct bhdr *matrix[REAL_FLI][MAX_SLI];
+
+	struct mutex lock;
+
+	size_t init_size;
+	size_t max_size;
+	size_t grow_size;
+
+	/* Basic stats */
+	size_t used_size;
+	size_t num_regions;
+
+	/* User provided functions for expanding/shrinking pool */
+	get_memory *get_mem;
+	put_memory *put_mem;
+
+	struct list_head list;
+
+#if defined(CONFIG_TLSF_STATS)
+	/* Extra stats */
+	size_t peak_used;
+	size_t peak_total;
+	size_t peak_extra;	/* MAX(Total - Used) */
+	size_t count_alloc;
+	size_t count_free;
+	size_t count_region_alloc;
+	size_t count_region_free;
+	size_t count_failed_alloc;
+#endif
+
+#if defined(CONFIG_TLSF_DEBUG)
+	/*
+	 * Pool used size must be 0 when its destroyed.
+	 * When non-empty pool is destroyed, it suggests
+	 * memory leak. Such pools are marked invalid
+	 * and kept in pool list for later debugging.
+	 */
+	unsigned int valid;
+#endif
+	void *init_region;
+	char name[MAX_POOL_NAME_LEN];
+};
+/*-- TLSF structures end */
+
+#endif
