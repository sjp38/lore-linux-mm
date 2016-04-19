Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id CD9516B025E
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 05:48:49 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l6so11233369wml.3
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 02:48:49 -0700 (PDT)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id if5si55704430wjb.27.2016.04.19.02.48.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Apr 2016 02:48:48 -0700 (PDT)
Received: by mail-wm0-x22e.google.com with SMTP id n3so19956190wmn.0
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 02:48:47 -0700 (PDT)
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH v2] z3fold: the 3-fold allocator for compressed pages
Message-ID: <5715FEFD.9010001@gmail.com>
Date: Tue, 19 Apr 2016 11:48:45 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>

This patch introduces z3fold, a special purpose allocator for storing
compressed pages. It is designed to store up to three compressed pages per
physical page. It is a ZBUD derivative which allows for higher compression
ratio keeping the simplicity and determinism of its predecessor.

The main differences between z3fold and zbud are:
* unlike zbud, z3fold allows for up to PAGE_SIZE allocations
* z3fold can hold up to 3 compressed pages in its page

This patch comes as a follow-up to the discussions at the Embedded Linux
Conference in San-Diego related to the talk [1]. The outcome of these
discussions was that it would be good to have a compressed page allocator
as stable and deterministic as zbud with with higher compression ratio.

To keep the determinism and simplicity, z3fold, just like zbud, always
stores an integral number of compressed pages per page, but it can store
up to 3 pages unlike zbud which can store at most 2. Therefore the
compression ratio goes to around 2.5x while zbud's one is around 1.7x.

The patch is based on the latest linux.git tree.

This version of the patch has updates related to various concurrency fixes
made after intensive testing on SMP/HMP platforms.

[1]https://openiotelc2016.sched.org/event/6DAC/swapping-and-embedded-compression-relieves-the-pressure-vitaly-wool-softprise-consulting-ou

Signed-off-by: Vitaly Wool<vitalywool@gmail.com>
---
  mm/Kconfig  |   9 +
  mm/Makefile |   1 +
  mm/z3fold.c | 806 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  3 files changed, 816 insertions(+)
  create mode 100644 mm/z3fold.c

diff --git a/mm/Kconfig b/mm/Kconfig
index 989f8f3..ffcd93a 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -565,6 +565,15 @@ config ZBUD
  	  deterministic reclaim properties that make it preferable to a higher
  	  density approach when reclaim will be used.
  
+config Z3FOLD
+	tristate "Low density storage for compressed pages"
+	default n
+	help
+	  A special purpose allocator for storing compressed pages.
+	  It is designed to store up to three compressed pages per physical
+	  page. It is a ZBUD derivative so the simplicity and determinism are
+	  still there.
+
  config ZSMALLOC
  	tristate "Memory allocator for compressed pages"
  	depends on MMU
diff --git a/mm/Makefile b/mm/Makefile
index deb467e..78c6f7d 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -89,6 +89,7 @@ obj-$(CONFIG_MEMORY_ISOLATION) += page_isolation.o
  obj-$(CONFIG_ZPOOL)	+= zpool.o
  obj-$(CONFIG_ZBUD)	+= zbud.o
  obj-$(CONFIG_ZSMALLOC)	+= zsmalloc.o
+obj-$(CONFIG_Z3FOLD)	+= z3fold.o
  obj-$(CONFIG_GENERIC_EARLY_IOREMAP) += early_ioremap.o
  obj-$(CONFIG_CMA)	+= cma.o
  obj-$(CONFIG_MEMORY_BALLOON) += balloon_compaction.o
diff --git a/mm/z3fold.c b/mm/z3fold.c
new file mode 100644
index 0000000..4b473d5
--- /dev/null
+++ b/mm/z3fold.c
@@ -0,0 +1,806 @@
+/*
+ * z3fold.c
+ *
+ * Copyright (C) 2016, Vitaly Wool <vitalywool@gmail.com>
+ *
+ * This implementation is heavily based on zbud written by Seth Jennings.
+ *
+ * z3fold is an special purpose allocator for storing compressed pages. It
+ * can store up to three compressed pages per page which improves the
+ * compression ratio of zbud while pertaining its concept and simplicity.
+ * It still has simple and deterministic reclaim properties that make it
+ * preferable to a higher density approach when reclaim is used.
+ *
+ * As in zbud, pages are divided into "chunks".  The size of the chunks is
+ * fixed at compile time and determined by NCHUNKS_ORDER below.
+ *
+ * The z3fold API doesn't differ from zbud API and zpool is also supported.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/atomic.h>
+#include <linux/list.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/preempt.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/zpool.h>
+
+/*****************
+ * Structures
+*****************/
+/*
+ * NCHUNKS_ORDER determines the internal allocation granularity, effectively
+ * adjusting internal fragmentation.  It also determines the number of
+ * freelists maintained in each pool. NCHUNKS_ORDER of 6 means that the
+ * allocation granularity will be in chunks of size PAGE_SIZE/64. As one chunk
+ * in allocated page is occupied by z3fold header, NCHUNKS will be calculated to
+ * 63 which shows the max number of free chunks in z3fold page, also there will be
+ * 63 freelists per pool.
+ */
+#define NCHUNKS_ORDER	6
+
+#define CHUNK_SHIFT	(PAGE_SHIFT - NCHUNKS_ORDER)
+#define CHUNK_SIZE	(1 << CHUNK_SHIFT)
+#define ZHDR_SIZE_ALIGNED CHUNK_SIZE
+#define NCHUNKS		((PAGE_SIZE - ZHDR_SIZE_ALIGNED) >> CHUNK_SHIFT)
+
+#define BUDDY_MASK	((1 << NCHUNKS_ORDER) - 1)
+
+struct z3fold_pool;
+struct z3fold_ops {
+	int (*evict)(struct z3fold_pool *pool, unsigned long handle);
+};
+
+/* Forward declarations */
+struct z3fold_pool *z3fold_create_pool(gfp_t gfp, const struct z3fold_ops *ops);
+void z3fold_destroy_pool(struct z3fold_pool *pool);
+int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
+	unsigned long *handle);
+void z3fold_free(struct z3fold_pool *pool, unsigned long handle);
+int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries);
+void *z3fold_map(struct z3fold_pool *pool, unsigned long handle);
+void z3fold_unmap(struct z3fold_pool *pool, unsigned long handle);
+u64 z3fold_get_pool_size(struct z3fold_pool *pool);
+
+/**
+ * struct z3fold_pool - stores metadata for each z3fold pool
+ * @lock:	protects all pool fields and first|last_chunk fields of any
+ *		z3fold page in the pool
+ * @unbuddied:	array of lists tracking z3fold pages that contain 2- buddies;
+ *		the lists each z3fold page is added to depends on the size of
+ *		its free region.
+ * @buddied:	list tracking the z3fold pages that contain 3 buddies;
+ *		these z3fold pages are full
+ * @lru:	list tracking the z3fold pages in LRU order by most recently
+ *		added buddy.
+ * @pages_nr:	number of z3fold pages in the pool.
+ * @ops:	pointer to a structure of user defined operations specified at
+ *		pool creation time.
+ *
+ * This structure is allocated at pool creation time and maintains metadata
+ * pertaining to a particular z3fold pool.
+ */
+struct z3fold_pool {
+	spinlock_t lock;
+	struct list_head unbuddied[NCHUNKS];
+	struct list_head buddied;
+	struct list_head lru;
+	u64 pages_nr;
+	const struct z3fold_ops *ops;
+#ifdef CONFIG_ZPOOL
+	struct zpool *zpool;
+	const struct zpool_ops *zpool_ops;
+#endif
+};
+
+enum buddy {
+	HEADLESS = 0,
+	FIRST,
+	MIDDLE,
+	LAST,
+	BUDDIES_MAX
+};
+
+/*
+ * struct z3fold_header - z3fold page metadata occupying the first chunk of each
+ *			z3fold page, except for HEADLESS pages
+ * @buddy:	links the z3fold page into the relevant list in the pool
+ * @first_chunks:	the size of the first buddy in chunks, 0 if free
+ * @middle_chunks:	the size of the middle buddy in chunks, 0 if free
+ * @last_chunks:	the size of the last buddy in chunks, 0 if free
+ * @first_num:		the starting number (for the first handle)
+ */
+struct z3fold_header {
+	struct list_head buddy;
+	unsigned short first_chunks;
+	unsigned short middle_chunks;
+	unsigned short last_chunks;
+	unsigned short start_middle;
+	unsigned short first_num:NCHUNKS_ORDER;
+};
+
+/*
+ * Internal z3fold page flags
+ */
+enum z3fold_page_flags {
+	UNDER_RECLAIM = 0,
+	PAGE_HEADLESS,
+	MIDDLE_CHUNK_MAPPED,
+};
+
+/*****************
+ * zpool
+ ****************/
+
+#ifdef CONFIG_ZPOOL
+
+static int z3fold_zpool_evict(struct z3fold_pool *pool, unsigned long handle)
+{
+	if (pool->zpool && pool->zpool_ops && pool->zpool_ops->evict)
+		return pool->zpool_ops->evict(pool->zpool, handle);
+	else
+		return -ENOENT;
+}
+
+static const struct z3fold_ops z3fold_zpool_ops = {
+	.evict =	z3fold_zpool_evict
+};
+
+static void *z3fold_zpool_create(const char *name, gfp_t gfp,
+			       const struct zpool_ops *zpool_ops,
+			       struct zpool *zpool)
+{
+	struct z3fold_pool *pool;
+
+	pool = z3fold_create_pool(gfp, zpool_ops ? &z3fold_zpool_ops : NULL);
+	if (pool) {
+		pool->zpool = zpool;
+		pool->zpool_ops = zpool_ops;
+	}
+	return pool;
+}
+
+static void z3fold_zpool_destroy(void *pool)
+{
+	z3fold_destroy_pool(pool);
+}
+
+static int z3fold_zpool_malloc(void *pool, size_t size, gfp_t gfp,
+			unsigned long *handle)
+{
+	return z3fold_alloc(pool, size, gfp, handle);
+}
+static void z3fold_zpool_free(void *pool, unsigned long handle)
+{
+	z3fold_free(pool, handle);
+}
+
+static int z3fold_zpool_shrink(void *pool, unsigned int pages,
+			unsigned int *reclaimed)
+{
+	unsigned int total = 0;
+	int ret = -EINVAL;
+
+	while (total < pages) {
+		ret = z3fold_reclaim_page(pool, 8);
+		if (ret < 0)
+			break;
+		total++;
+	}
+
+	if (reclaimed)
+		*reclaimed = total;
+
+	return ret;
+}
+
+static void *z3fold_zpool_map(void *pool, unsigned long handle,
+			enum zpool_mapmode mm)
+{
+	return z3fold_map(pool, handle);
+}
+static void z3fold_zpool_unmap(void *pool, unsigned long handle)
+{
+	z3fold_unmap(pool, handle);
+}
+
+static u64 z3fold_zpool_total_size(void *pool)
+{
+	return z3fold_get_pool_size(pool) * PAGE_SIZE;
+}
+
+static struct zpool_driver z3fold_zpool_driver = {
+	.type =		"z3fold",
+	.owner =	THIS_MODULE,
+	.create =	z3fold_zpool_create,
+	.destroy =	z3fold_zpool_destroy,
+	.malloc =	z3fold_zpool_malloc,
+	.free =		z3fold_zpool_free,
+	.shrink =	z3fold_zpool_shrink,
+	.map =		z3fold_zpool_map,
+	.unmap =	z3fold_zpool_unmap,
+	.total_size =	z3fold_zpool_total_size,
+};
+
+MODULE_ALIAS("zpool-z3fold");
+#endif /* CONFIG_ZPOOL */
+
+/*****************
+ * Helpers
+*****************/
+
+/* Converts an allocation size in bytes to size in z3fold chunks */
+static int size_to_chunks(size_t size)
+{
+	return (size + CHUNK_SIZE - 1) >> CHUNK_SHIFT;
+}
+
+#define for_each_unbuddied_list(_iter, _begin) \
+	for ((_iter) = (_begin); (_iter) < NCHUNKS; (_iter)++)
+
+/* Initializes the z3fold header of a newly allocated z3fold page */
+static struct z3fold_header *init_z3fold_page(struct page *page)
+{
+	struct z3fold_header *zhdr = page_address(page);
+
+	INIT_LIST_HEAD(&page->lru);
+	clear_bit(UNDER_RECLAIM, &page->private);
+	clear_bit(PAGE_HEADLESS, &page->private);
+
+	zhdr->first_chunks = 0;
+	zhdr->middle_chunks = 0;
+	zhdr->last_chunks = 0;
+	zhdr->first_num = 0;
+	zhdr->start_middle = 0;
+	INIT_LIST_HEAD(&zhdr->buddy);
+	return zhdr;
+}
+
+/* Resets the struct page fields and frees the page */
+static void free_z3fold_page(struct z3fold_header *zhdr)
+{
+	__free_page(virt_to_page(zhdr));
+}
+
+/*
+ * Encodes the handle of a particular buddy within a z3fold page
+ * Pool lock should be held as this function accesses first_num
+ */
+static unsigned long encode_handle(struct z3fold_header *zhdr, enum buddy bud)
+{
+	unsigned long handle;
+
+ 	handle = (unsigned long)zhdr;
+	if (bud != HEADLESS)
+		handle += (bud + zhdr->first_num) & BUDDY_MASK;
+	return handle;
+}
+
+/* Returns the z3fold page where a given handle is stored */
+static struct z3fold_header *handle_to_z3fold_header(unsigned long handle)
+{
+	return (struct z3fold_header *)(handle & PAGE_MASK);
+}
+
+/*
+ * Returns the number of free chunks in a z3fold page.
+ * NB: can't be used with HEADLESS pages.
+ */
+static int num_free_chunks(struct z3fold_header *zhdr)
+{
+	int nfree;
+	/*
+	 * There is one special case, where first_chunks == 0 and
+	 * middle_chunks != 0. In this case there may be a hole between
+	 * the middle and the last objects, or middle object may be in use
+	 * and thus temporarily unmovable.
+	 */
+	if (zhdr->first_chunks == 0 && zhdr->middle_chunks != 0)
+		nfree = zhdr->start_middle - 1;
+	else
+		nfree = NCHUNKS - zhdr->first_chunks -
+			zhdr->middle_chunks - zhdr->last_chunks;
+	return nfree;
+}
+
+/*****************
+ * API Functions
+*****************/
+/**
+ * z3fold_create_pool() - create a new z3fold pool
+ * @gfp:	gfp flags when allocating the z3fold pool structure
+ * @ops:	user-defined operations for the z3fold pool
+ *
+ * Return: pointer to the new z3fold pool or NULL if the metadata allocation
+ * failed.
+ */
+struct z3fold_pool *z3fold_create_pool(gfp_t gfp, const struct z3fold_ops *ops)
+{
+	struct z3fold_pool *pool;
+	int i;
+
+	pool = kzalloc(sizeof(struct z3fold_pool), gfp);
+	if (!pool)
+		return NULL;
+	spin_lock_init(&pool->lock);
+	for_each_unbuddied_list(i, 0)
+		INIT_LIST_HEAD(&pool->unbuddied[i]);
+	INIT_LIST_HEAD(&pool->buddied);
+	INIT_LIST_HEAD(&pool->lru);
+	pool->pages_nr = 0;
+	pool->ops = ops;
+	return pool;
+}
+
+/**
+ * z3fold_destroy_pool() - destroys an existing z3fold pool
+ * @pool:	the z3fold pool to be destroyed
+ *
+ * The pool should be emptied before this function is called.
+ */
+void z3fold_destroy_pool(struct z3fold_pool *pool)
+{
+	kfree(pool);
+}
+
+/* Has to be called with lock held */
+static int z3fold_compact_page(struct z3fold_header *zhdr)
+{
+	struct page *page = virt_to_page(zhdr);
+
+	if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0 &&
+	    zhdr->middle_chunks != 0 &&
+	    !test_bit(MIDDLE_CHUNK_MAPPED, &page->private)) {
+		/* move middle chunk to the first chunk */
+		memmove((void *)zhdr + ZHDR_SIZE_ALIGNED,
+			(void *)zhdr + (zhdr->start_middle << CHUNK_SHIFT),
+			zhdr->middle_chunks << CHUNK_SHIFT);
+		zhdr->first_chunks = zhdr->middle_chunks;
+		zhdr->middle_chunks = 0;
+		zhdr->start_middle = 0;
+		zhdr->first_num++;
+		return 1;
+	}
+	return 0;
+}
+
+/**
+ * z3fold_alloc() - allocates a region of a given size
+ * @pool:	z3fold pool from which to allocate
+ * @size:	size in bytes of the desired allocation
+ * @gfp:	gfp flags used if the pool needs to grow
+ * @handle:	handle of the new allocation
+ *
+ * This function will attempt to find a free region in the pool large enough to
+ * satisfy the allocation request.  A search of the unbuddied lists is
+ * performed first. If no suitable free region is found, then a new page is
+ * allocated and added to the pool to satisfy the request.
+ *
+ * gfp should not set __GFP_HIGHMEM as highmem pages cannot be used
+ * as z3fold pool pages.
+ *
+ * Return: 0 if success and handle is set, otherwise -EINVAL if the size or
+ * gfp arguments are invalid or -ENOMEM if the pool was unable to allocate
+ * a new page.
+ */
+int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
+			unsigned long *handle)
+{
+	int chunks = 0, i, freechunks;
+	struct z3fold_header *zhdr = NULL;
+	enum buddy bud;
+	struct page *page;
+
+	if (!size || (gfp & __GFP_HIGHMEM))
+		return -EINVAL;
+
+	if (size > PAGE_SIZE)
+		return -ENOSPC;
+
+	if (size > PAGE_SIZE - ZHDR_SIZE_ALIGNED - CHUNK_SIZE)
+		bud = HEADLESS;
+	else {
+		chunks = size_to_chunks(size);
+		spin_lock(&pool->lock);
+
+		/* First, try to find an unbuddied z3fold page. */
+		zhdr = NULL;
+		for_each_unbuddied_list(i, chunks) {
+			if (!list_empty(&pool->unbuddied[i])) {
+				zhdr = list_first_entry(&pool->unbuddied[i],
+						struct z3fold_header, buddy);
+				page = virt_to_page(zhdr);
+				if (zhdr->first_chunks == 0) {
+					if (zhdr->middle_chunks == 0)
+						bud = FIRST;
+					else if (zhdr->last_chunks == 0 &&
+						 z3fold_compact_page(zhdr))
+						bud = LAST;
+					else
+						continue;
+				} else if (zhdr->last_chunks == 0)
+					bud = LAST;
+				else if (zhdr->middle_chunks == 0)
+					bud = MIDDLE;
+				else {
+					pr_err("No free chunks in unbuddied\n");
+					BUG();
+				}
+				list_del(&zhdr->buddy);
+				goto found;
+			}
+		}
+		bud = FIRST;
+		spin_unlock(&pool->lock);
+	}
+
+	/* Couldn't find unbuddied z3fold page, create new one */
+	page = alloc_page(gfp);
+	if (!page)
+		return -ENOMEM;
+	spin_lock(&pool->lock);
+	pool->pages_nr++;
+	zhdr = init_z3fold_page(page);
+
+	if (bud == HEADLESS) {
+		set_bit(PAGE_HEADLESS, &page->private);
+		goto headless;
+	}
+
+found:
+	if (bud == FIRST)
+		zhdr->first_chunks = chunks;
+	else if (bud == LAST)
+		zhdr->last_chunks = chunks;
+	else {
+		zhdr->middle_chunks = chunks;
+		zhdr->start_middle = zhdr->first_chunks + 1;
+	}
+
+	if (zhdr->first_chunks == 0 || zhdr->last_chunks == 0 ||
+			zhdr->middle_chunks == 0) {
+		/* Add to unbuddied list */
+		freechunks = num_free_chunks(zhdr);
+		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
+	} else {
+		/* Add to buddied list */
+		list_add(&zhdr->buddy, &pool->buddied);
+	}
+
+headless:
+	/* Add/move z3fold page to beginning of LRU */
+	if (!list_empty(&page->lru))
+		list_del(&page->lru);
+
+	list_add(&page->lru, &pool->lru);
+
+	*handle = encode_handle(zhdr, bud);
+	spin_unlock(&pool->lock);
+
+	return 0;
+}
+
+/**
+ * z3fold_free() - frees the allocation associated with the given handle
+ * @pool:	pool in which the allocation resided
+ * @handle:	handle associated with the allocation returned by z3fold_alloc()
+ *
+ * In the case that the z3fold page in which the allocation resides is under
+ * reclaim, as indicated by the PG_reclaim flag being set, this function
+ * only sets the first|last_chunks to 0.  The page is actually freed
+ * once both buddies are evicted (see z3fold_reclaim_page() below).
+ */
+void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
+{
+	struct z3fold_header *zhdr;
+	int freechunks;
+	struct page *page;
+	enum buddy bud;
+
+	spin_lock(&pool->lock);
+	zhdr = handle_to_z3fold_header(handle);
+	page = virt_to_page(zhdr);
+
+	if (test_bit(PAGE_HEADLESS, &page->private)) {
+		/* HEADLESS page stored */
+		bud = HEADLESS;
+	} else {
+		bud = (handle - zhdr->first_num) & BUDDY_MASK;
+
+		switch (bud) {
+		case FIRST:
+			zhdr->first_chunks = 0;
+			break;
+		case MIDDLE:
+			zhdr->middle_chunks = 0;
+			zhdr->start_middle = 0;
+			break;
+		case LAST:
+			zhdr->last_chunks = 0;
+			break;
+		default:
+			pr_err("%s: unknown bud %d\n", __func__, bud);
+			BUG();
+			break;
+		}
+	}
+
+	if (test_bit(UNDER_RECLAIM, &page->private)) {
+		/* z3fold page is under reclaim, reclaim will free */
+		spin_unlock(&pool->lock);
+		return;
+	}
+
+	if (bud != HEADLESS) {
+		/* Remove from existing buddy list */
+		list_del(&zhdr->buddy);
+	}
+
+	if (bud == HEADLESS ||
+	    (zhdr->first_chunks == 0 && zhdr->middle_chunks == 0 &&
+			zhdr->last_chunks == 0)) {
+		/* z3fold page is empty, free */
+		list_del(&page->lru);
+		clear_bit(PAGE_HEADLESS, &page->private);
+		free_z3fold_page(zhdr);
+		pool->pages_nr--;
+	} else {
+		z3fold_compact_page(zhdr);
+		/* Add to the unbuddied list */
+		freechunks = num_free_chunks(zhdr);
+		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
+	}
+
+	spin_unlock(&pool->lock);
+}
+
+#define list_tail_entry(ptr, type, member) \
+	list_entry((ptr)->prev, type, member)
+
+/**
+ * z3fold_reclaim_page() - evicts allocations from a pool page and frees it
+ * @pool:	pool from which a page will attempt to be evicted
+ * @retires:	number of pages on the LRU list for which eviction will
+ *		be attempted before failing
+ *
+ * z3fold reclaim is different from normal system reclaim in that it is done
+ * from the bottom, up. This is because only the bottom layer, z3fold, has
+ * information on how the allocations are organized within each z3fold page.
+ * This has the potential to create interesting locking situations between
+ * z3fold and the user, however.
+ *
+ * To avoid these, this is how z3fold_reclaim_page() should be called:
+
+ * The user detects a page should be reclaimed and calls z3fold_reclaim_page().
+ * z3fold_reclaim_page() will remove a z3fold page from the pool LRU list and
+ * call the user-defined eviction handler with the pool and handle as
+ * arguments.
+ *
+ * If the handle can not be evicted, the eviction handler should return
+ * non-zero. z3fold_reclaim_page() will add the z3fold page back to the
+ * appropriate list and try the next z3fold page on the LRU up to
+ * a user defined number of retries.
+ *
+ * If the handle is successfully evicted, the eviction handler should
+ * return 0 _and_ should have called z3fold_free() on the handle. z3fold_free()
+ * contains logic to delay freeing the page if the page is under reclaim,
+ * as indicated by the setting of the PG_reclaim flag on the underlying page.
+ *
+ * If all buddies in the z3fold page are successfully evicted, then the
+ * z3fold page can be freed.
+ *
+ * Returns: 0 if page is successfully freed, otherwise -EINVAL if there are
+ * no pages to evict or an eviction handler is not registered, -EAGAIN if
+ * the retry limit was hit.
+ */
+int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
+{
+	int i, ret = 0, freechunks;
+	struct z3fold_header *zhdr;
+	struct page *page;
+	unsigned long first_handle = 0, middle_handle = 0, last_handle = 0;
+
+	spin_lock(&pool->lock);
+	if (!pool->ops || !pool->ops->evict || list_empty(&pool->lru) ||
+			retries == 0) {
+		spin_unlock(&pool->lock);
+		return -EINVAL;
+	}
+	for (i = 0; i < retries; i++) {
+		page = list_tail_entry(&pool->lru, struct page, lru);
+		list_del(&page->lru);
+
+		/* Protect z3fold page against free */
+		set_bit(UNDER_RECLAIM, &page->private);
+		zhdr = page_address(page);
+		if (!test_bit(PAGE_HEADLESS, &page->private)) {
+			list_del(&zhdr->buddy);
+			/*
+			 * We need encode the handles before unlocking, since
+			 * we can race with free that will set
+			 * (first|last)_chunks to 0
+			 */
+			first_handle = 0;
+			last_handle = 0;
+			middle_handle = 0;
+			if (zhdr->first_chunks)
+				first_handle = encode_handle(zhdr, FIRST);
+			if (zhdr->middle_chunks)
+				middle_handle = encode_handle(zhdr, MIDDLE);
+			if (zhdr->last_chunks)
+				last_handle = encode_handle(zhdr, LAST);
+		} else {
+			first_handle = encode_handle(zhdr, HEADLESS);
+			last_handle = middle_handle = 0;
+		}
+
+		spin_unlock(&pool->lock);
+
+		/* Issue the eviction callback(s) */
+		if (middle_handle) {
+			ret = pool->ops->evict(pool, middle_handle);
+			if (ret)
+				goto next;
+		}
+		if (first_handle) {
+			ret = pool->ops->evict(pool, first_handle);
+			if (ret)
+				goto next;
+		}
+		if (last_handle) {
+			ret = pool->ops->evict(pool, last_handle);
+			if (ret)
+				goto next;
+		}
+next:
+		spin_lock(&pool->lock);
+		clear_bit(UNDER_RECLAIM, &page->private);
+		if (test_bit(PAGE_HEADLESS, &page->private)) {
+			if (ret == 0) {
+				clear_bit(PAGE_HEADLESS, &page->private);
+				free_z3fold_page(zhdr);
+				pool->pages_nr--;
+				spin_unlock(&pool->lock);
+				return 0;
+			}
+		} else if (zhdr->middle_chunks != 0) {
+			/* Full, add to buddied list */
+			freechunks = num_free_chunks(zhdr);
+			list_add(&zhdr->buddy, &pool->buddied);
+		} else if (zhdr->first_chunks == 0 &&
+				zhdr->last_chunks == 0 &&
+				zhdr->middle_chunks == 0) {
+			/*
+			 * All buddies are now free, free the z3fold page and
+			 * return success.
+			 */
+			free_z3fold_page(zhdr);
+			pool->pages_nr--;
+			spin_unlock(&pool->lock);
+			return 0;
+		} else {
+			/* add to unbuddied list */
+			freechunks = num_free_chunks(zhdr);
+			list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
+		}
+
+		/* add to beginning of LRU */
+		list_add(&page->lru, &pool->lru);
+	}
+	spin_unlock(&pool->lock);
+	return -EAGAIN;
+}
+
+/**
+ * z3fold_map() - maps the allocation associated with the given handle
+ * @pool:	pool in which the allocation resides
+ * @handle:	handle associated with the allocation to be mapped
+ *
+ * Extracts the buddy number from handle and constructs the pointer to the
+ * correct starting chunk within the page.
+ *
+ * Returns: a pointer to the mapped allocation
+ */
+void *z3fold_map(struct z3fold_pool *pool, unsigned long handle)
+{
+	struct z3fold_header *zhdr;
+	struct page *page;
+	void *addr;
+	enum buddy buddy;
+
+	spin_lock(&pool->lock);
+	zhdr = handle_to_z3fold_header(handle);
+	addr = zhdr;
+	page = virt_to_page(zhdr);
+
+	if (test_bit(PAGE_HEADLESS, &page->private))
+		goto out;
+
+	buddy = (handle - zhdr->first_num) & BUDDY_MASK;
+	switch (buddy) {
+	case FIRST:
+		addr += ZHDR_SIZE_ALIGNED;
+		break;
+	case MIDDLE:
+		addr += zhdr->start_middle << CHUNK_SHIFT;
+		set_bit(MIDDLE_CHUNK_MAPPED, &page->private);
+		break;
+	case LAST:
+		addr += PAGE_SIZE - (zhdr->last_chunks << CHUNK_SHIFT);
+		break;
+	default:
+		pr_err("unknown buddy id %d\n", buddy);
+		BUG();
+		break;
+	}
+out:
+	spin_unlock(&pool->lock);
+	return addr;
+}
+
+/**
+ * z3fold_unmap() - unmaps the allocation associated with the given handle
+ * @pool:	pool in which the allocation resides
+ * @handle:	handle associated with the allocation to be unmapped
+ */
+void z3fold_unmap(struct z3fold_pool *pool, unsigned long handle)
+{
+	struct z3fold_header *zhdr;
+	struct page *page;
+	enum buddy buddy;
+
+	spin_lock(&pool->lock);
+	zhdr = handle_to_z3fold_header(handle);
+	page = virt_to_page(zhdr);
+
+	if (test_bit(PAGE_HEADLESS, &page->private)) {
+		spin_unlock(&pool->lock);
+		return;
+	}
+
+	buddy = (handle - zhdr->first_num) & BUDDY_MASK;
+	if (buddy == MIDDLE)
+		clear_bit(MIDDLE_CHUNK_MAPPED, &page->private);
+	spin_unlock(&pool->lock);
+}
+
+/**
+ * z3fold_get_pool_size() - gets the z3fold pool size in pages
+ * @pool:	pool whose size is being queried
+ *
+ * Returns: size in pages of the given pool.  The pool lock need not be
+ * taken to access pages_nr.
+ */
+u64 z3fold_get_pool_size(struct z3fold_pool *pool)
+{
+	return pool->pages_nr;
+}
+
+static int __init init_z3fold(void)
+{
+	/* Make sure the z3fold header will fit in one chunk */
+	BUILD_BUG_ON(sizeof(struct z3fold_header) > ZHDR_SIZE_ALIGNED);
+
+#ifdef CONFIG_ZPOOL
+	zpool_register_driver(&z3fold_zpool_driver);
+#endif
+
+	return 0;
+}
+
+static void __exit exit_z3fold(void)
+{
+#ifdef CONFIG_ZPOOL
+	zpool_unregister_driver(&z3fold_zpool_driver);
+#endif
+}
+
+module_init(init_z3fold);
+module_exit(exit_z3fold);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Vitaly Wool <vitalywool@gmail.com>");
+MODULE_DESCRIPTION("3-Fold Allocator for Compressed Pages");
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
