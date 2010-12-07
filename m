Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1B7B46B0087
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 13:08:18 -0500 (EST)
Date: Tue, 7 Dec 2010 10:07:54 -0800
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH V0 3/4] Kztmem: tmem host services and PAM services
Message-ID: <20101207180754.GA28170@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: chris.mason@oracle.com, akpm@linux-foundation.org, matthew@wil.cx, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, kurt.hackel@oracle.com, npiggin@kernel.dk, riel@redhat.com, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, mel@csn.ul.ie, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

[PATCH V0 3/4] Kztmem: tmem host services and PAM services

Kztmem provides host services (initialization, memory
allocation, and single-client pool callback) and two
different page-addressable memory implemenations using
lzo1x compression.  The first, "compression buddies" ("zbud")
compresses pairs of pages and supplies a shrinker interface
that allows entire pages to be reclaimed.  The second is
a shim to xvMalloc which is more space-efficient but
less receptive to page reclamation.  The first is used
for ephemeral pools and the second for persistent pools.
All ephemeral pools share the same memory, that is, even
pages from different pools can share the same page.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

---

Diffstat:
 drivers/staging/kztmem/kztmem.c          | 1318 +++++++++++++++++++++
 1 file changed, 1318 insertions(+)

--- linux-2.6.36/drivers/staging/kztmem/kztmem.c	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.36-kztmem/drivers/staging/kztmem/kztmem.c	2010-12-07 10:15:04.000000000 -0700
@@ -0,0 +1,1318 @@
+/*
+ * kztmem.c
+ *
+ * Copyright (c) 2010, Dan Magenheimer, Oracle Corp.
+ *
+ * Kztmem provides an in-kernel "host implementation" for transcendent memory
+ * and, thus indirectly, for cleancache and frontswap.  Kztmem includes two
+ * page-accessible memory [1] interfaces, both utilizing lzo1x compression:
+ * 1) "compression buddies" ("zbud") is used for ephemeral pages
+ * 2) xvmalloc is used for persistent pages.
+ * Xvmalloc (based on the TLSF allocator) has very low fragmentation
+ * so maximizes space efficiency, while zbud allows pairs (and potentially,
+ * in the future, more than a pair of) compressed pages to be closely linked
+ * so that reclaiming can be done via the kernel's physical-page-oriented
+ * "shrinker" interface.
+ *
+ * [1] For a definition of page-accessible memory (aka PAM), see:
+ *   http://marc.info/?l=linux-mm&m=127811271605009 
+ */
+
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/lzo.h>
+#include <linux/highmem.h>
+#include <linux/cpu.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <asm/atomic.h>
+
+#include "../zram/xvmalloc.h"
+#include "tmem.h"
+
+#if (!defined(CONFIG_CLEANCACHE) && !defined(CONFIG_FRONTSWAP))
+#error "kztmem is useless without CONFIG_CLEANCACHE or CONFIG_FRONTSWAP"
+#endif
+#ifdef CONFIG_CLEANCACHE
+#include <linux/cleancache.h>
+#endif
+#ifdef CONFIG_FRONTSWAP
+#include <linux/frontswap.h>
+#endif
+
+/* for debugging */
+#define ASSERT(_x) WARN_ON(unlikely(!(_x)))	/* CHANGE TO BUG_ON LATER */
+#define ASSERT_SPINLOCK(_l)	ASSERT(shrinking || spin_is_locked(_l))
+
+/*
+ * sentinels have proven very useful for debugging but can be removed
+ * or disabled before final merge
+ */
+#ifdef SENTINELS
+#define SET_SENTINEL(_x, _y) (_x->sentinel = _y##_SENTINEL)
+#define INVERT_SENTINEL(_x, _y) (_x->sentinel = ~_y##_SENTINEL)
+#define ASSERT_SENTINEL(_x, _y) ASSERT(_x->sentinel == _y##_SENTINEL)
+#define ASSERT_INVERTED_SENTINEL(_x, _y) ASSERT(_x->sentinel == ~_y##_SENTINEL)
+#else
+#define SET_SENTINEL(_x, _y) do { } while (0)
+#define ASSERT_SENTINEL(_x, _y) do { } while (0)
+#define INVERT_SENTINEL(_x, _y) do { } while (0)
+#endif
+
+/* OK, the real code finally starts here */
+
+/**********
+ * Compression buddies ("zbud") provides for packing two (or, possibly
+ * in the future, more) compressed ephemeral pages into a single "raw"
+ * (physical) page and tracking them with data structures so that 
+ * the raw pages can be easily reclaimed.
+ *
+ * A zbud page ("zbpg") is an aligned page containing a list_head,
+ * a lock, and two "zbud headers".  The remainder of the physical
+ * page is divided up into aligned 64-byte "chunks" which contain
+ * the compressed data for zero, one, or two zbuds.  Each zbpg
+ * resides on: (1) an "unused list" if it has no zbuds; (2) a
+ * "buddied" list if it is fully populated  with two zbuds; or
+ * (3) one of PAGE_SIZE/64 "unbuddied" lists indexed by how many chunks
+ * the one unbuddied zbud uses.
+ */
+
+#define ZBH_SENTINEL  0x43214321
+#define ZBPG_SENTINEL  0xdeadbeef
+
+#define ZBUD_MAX_BUDS 2
+
+struct zbud_hdr {
+	void *obj;
+	uint32_t index;
+	uint16_t size; /* compressed size in bytes, zero means unused */
+	DECL_SENTINEL
+};
+
+struct zbud_page {
+	struct list_head bud_list;
+	spinlock_t lock;
+	struct zbud_hdr buddy[ZBUD_MAX_BUDS];
+	DECL_SENTINEL
+	/* followed by NUM_CHUNK aligned CHUNK_SIZE-byte chunks */
+};
+
+#define CHUNK_SHIFT	6
+#define CHUNK_SIZE	(1 << CHUNK_SHIFT)
+#define CHUNK_MASK	(~(CHUNK_SIZE-1))
+#define NCHUNKS		(((PAGE_SIZE - sizeof(struct zbud_page)) & \
+				CHUNK_MASK) >> CHUNK_SHIFT)
+#define MAX_CHUNK	(NCHUNKS-1)
+
+static struct {
+	struct list_head list;
+	unsigned count;
+} zbud_unbuddied[NCHUNKS];
+/* list N contains pages with N chunks USED and NCHUNKS-N unused */
+/* element 0 is never used but optimizing that isn't worth it */
+static unsigned long zbud_cumul_chunk_counts[NCHUNKS];
+
+struct list_head zbud_buddied_list;
+static unsigned long kztmem_zbud_buddied_count;
+
+static DEFINE_SPINLOCK(zbud_budlists_spinlock);
+
+static DEFINE_SPINLOCK(zbpg_unused_list_spinlock);
+static LIST_HEAD(zbpg_unused_list);
+static unsigned long kztmem_zbpg_unused_list_count;
+
+static atomic_t kztmem_zbud_curr_raw_pages;
+static atomic_t kztmem_zbud_curr_zpages;
+static unsigned long kztmem_zbud_curr_zbytes;
+static unsigned long kztmem_zbud_cumul_zpages;
+static unsigned long kztmem_zbud_cumul_zbytes;
+static unsigned long kztmem_compress_poor;
+
+/* forward references */
+static void *kztmem_get_free_page(void);
+static void kztmem_free_page(void *p);
+
+static int shrinking;
+
+/*
+ * zbud helper functions
+ */
+
+static unsigned zbud_max_buddy_size(void)
+{
+	return MAX_CHUNK << CHUNK_SHIFT;
+}
+
+static inline unsigned zbud_size_to_chunks(unsigned size)
+{
+	ASSERT(size > 0 && size <= zbud_max_buddy_size());
+	return (size + CHUNK_SIZE - 1) >> CHUNK_SHIFT;
+}
+
+static inline int zbud_budnum(struct zbud_hdr *zh)
+{
+	unsigned offset = (unsigned long)zh & (PAGE_SIZE - 1);
+	struct zbud_page *zbpg = NULL;
+	unsigned budnum = -1U;
+	int i;
+
+	for (i = 0; i < ZBUD_MAX_BUDS; i++)
+		if (offset == offsetof(typeof(*zbpg), buddy[i])) {
+			budnum = i;
+			break;
+		}
+	ASSERT(budnum != -1U);
+	return budnum;
+}
+
+static char *zbud_data(struct zbud_hdr *zh, unsigned size)
+{
+	struct zbud_page *zbpg;
+	char *p;
+	unsigned budnum;
+
+	ASSERT_SENTINEL(zh, ZBH);
+	budnum = zbud_budnum(zh);
+	ASSERT(size > 0 && size <= zbud_max_buddy_size());
+	zbpg = container_of(zh, struct zbud_page, buddy[budnum]);
+	ASSERT_SPINLOCK(&zbpg->lock);
+	p = (char *)zbpg;
+	if (budnum == 0)
+		p += ((sizeof(struct zbud_page) + CHUNK_SIZE - 1) &
+							CHUNK_MASK);
+	else if (budnum == 1)
+		p += PAGE_SIZE - ((size + CHUNK_SIZE - 1) & CHUNK_MASK);
+	ASSERT(((((unsigned long)p) & (CHUNK_SIZE-1)) == 0) &&
+		(p >= (char *)zbpg + CHUNK_SIZE) &&
+		(p + size <= (char *)zbpg + PAGE_SIZE));
+	ASSERT(((unsigned long)p & PAGE_MASK) ==
+		((unsigned long)(p + size - 1) & PAGE_MASK));
+	return p;
+}
+
+/*
+ * zbud locking
+ */
+
+static void zbpg_lock(struct zbud_page *zbpg)
+{
+	if (!shrinking)
+		while (!spin_trylock(&zbpg->lock))
+			ASSERT_SENTINEL(zbpg, ZBPG);
+}
+
+static void zbpg_unlock(struct zbud_page *zbpg)
+{
+	ASSERT_SENTINEL(zbpg, ZBPG);
+	if (!shrinking)
+		spin_unlock(&zbpg->lock);
+}
+
+static void zbpg_unlock_free(struct zbud_page *zbpg)
+{
+	ASSERT(zbpg->sentinel == ~ZBPG_SENTINEL);
+	if (!shrinking)
+		spin_unlock(&zbpg->lock);
+}
+
+static int zbpg_trylock(struct zbud_page *zbpg)
+{
+	ASSERT_SENTINEL(zbpg, ZBPG);
+	return shrinking ? 1 : spin_trylock(&zbpg->lock);
+}
+
+static void zbud_budlists_lock(void)
+{
+	if (!shrinking)
+		spin_lock(&zbud_budlists_spinlock);
+}
+
+static void zbud_budlists_unlock(void)
+{
+	if (!shrinking)
+		spin_unlock(&zbud_budlists_spinlock);
+}
+
+static void zbpg_unused_list_lock(void)
+{
+	if (!shrinking)
+		spin_lock(&zbpg_unused_list_spinlock);
+}
+
+static void zbpg_unused_list_unlock(void)
+{
+	if (!shrinking)
+		spin_unlock(&zbpg_unused_list_spinlock);
+}
+
+/*
+ * zbud raw page management
+ */
+
+static struct zbud_page *zbud_alloc_raw_page(void)
+{
+	struct zbud_page *zbpg = NULL;
+	struct zbud_hdr *zh0, *zh1;
+	bool recycled = 0;
+
+	/* if any pages on the zbpg list, use one */
+	zbpg_unused_list_lock();
+	if (!list_empty(&zbpg_unused_list)) {
+		zbpg = list_entry((&zbpg_unused_list)->next,
+				struct zbud_page, bud_list);
+		list_del_init(&zbpg->bud_list);
+		kztmem_zbpg_unused_list_count--;
+		recycled = 1;
+	}
+	zbpg_unused_list_unlock();
+	if (zbpg == NULL)
+		/* none on zbpg list, try to get a kernel page */
+		zbpg = kztmem_get_free_page();
+	if (likely(zbpg != NULL)) {
+		INIT_LIST_HEAD(&zbpg->bud_list);
+		zh0 = &zbpg->buddy[0]; zh1 = &zbpg->buddy[1];
+		spin_lock_init(&zbpg->lock);
+		if (recycled) {
+			ASSERT_INVERTED_SENTINEL(zbpg, ZBPG);
+			SET_SENTINEL(zbpg, ZBPG);
+			ASSERT(zh0->size == 0 && zh0->obj == NULL);
+			ASSERT(zh1->size == 0 && zh1->obj == NULL);
+		} else {
+			atomic_inc(&kztmem_zbud_curr_raw_pages);
+			INIT_LIST_HEAD(&zbpg->bud_list);
+			SET_SENTINEL(zbpg, ZBPG);
+			zh0->size = 0; zh1->size = 0;
+		}
+	}
+	return zbpg;
+}
+
+static void zbud_free_raw_page(struct zbud_page *zbpg)
+{
+	struct zbud_hdr *zh0 = &zbpg->buddy[0], *zh1 = &zbpg->buddy[1];
+
+	ASSERT_SENTINEL(zbpg, ZBPG);
+	ASSERT(list_empty(&zbpg->bud_list));
+	ASSERT_SPINLOCK(&zbpg->lock);
+	ASSERT(zh0->size == 0 && zh0->obj == NULL);
+	ASSERT(zh1->size == 0 && zh1->obj == NULL);
+	INVERT_SENTINEL(zbpg, ZBPG);
+	zbpg_unlock_free(zbpg);
+	zbpg_unused_list_lock();
+	list_add(&zbpg->bud_list, &zbpg_unused_list);
+	kztmem_zbpg_unused_list_count++;
+	zbpg_unused_list_unlock();
+}
+
+/*
+ * core zbud handling routines
+ */
+
+static unsigned zbud_free(struct zbud_hdr *zh)
+{
+	unsigned size;
+
+	ASSERT_SENTINEL(zh, ZBH);
+	ASSERT(zh->obj != NULL);
+	size = zh->size;
+	ASSERT(zh->size > 0 && zh->size <= zbud_max_buddy_size());
+	zh->size = 0;
+	zh->obj = NULL;
+	INVERT_SENTINEL(zh, ZBH);
+	kztmem_zbud_curr_zbytes -= size;
+	atomic_dec(&kztmem_zbud_curr_zpages);
+	return size;
+}
+
+static void zbud_free_and_delist(struct zbud_hdr *zh)
+{
+	unsigned chunks;
+	struct zbud_hdr *zh_other;
+	unsigned budnum = zbud_budnum(zh), size;
+	struct zbud_page *zbpg =
+		container_of(zh, struct zbud_page, buddy[budnum]);
+
+	zbpg_lock(zbpg);
+	size = zbud_free(zh);
+	ASSERT_SPINLOCK(&zbpg->lock);
+	zh_other = &zbpg->buddy[(budnum == 0) ? 1 : 0];
+	if (zh_other->size == 0) { /* was unbuddied: unlist and free */
+		chunks = zbud_size_to_chunks(size) ;
+		zbud_budlists_lock();
+		ASSERT(!list_empty(&zbud_unbuddied[chunks].list));
+		list_del_init(&zbpg->bud_list);
+		zbud_unbuddied[chunks].count--;
+		zbud_budlists_unlock();
+		zbud_free_raw_page(zbpg);
+	} else { /* was buddied: move remaining buddy to unbuddied list */
+		chunks = zbud_size_to_chunks(zh_other->size) ;
+		zbud_budlists_lock();
+		list_del_init(&zbpg->bud_list);
+		kztmem_zbud_buddied_count--;
+		list_add_tail(&zbpg->bud_list, &zbud_unbuddied[chunks].list);
+		zbud_unbuddied[chunks].count++;
+		zbud_budlists_unlock();
+		zbpg_unlock(zbpg);
+	}
+}
+
+static struct zbud_hdr *zbud_create(uint32_t index, void *obj,
+					struct page *page, void *cdata,
+					unsigned size)
+{
+	struct zbud_hdr *zh0, *zh1, *zh = NULL;
+	struct zbud_page *zbpg = NULL, *ztmp;
+	unsigned nchunks;
+	char *to;
+	int i, found_good_buddy = 0;
+
+	nchunks = zbud_size_to_chunks(size) ;
+	for (i = MAX_CHUNK - nchunks + 1; i > 0; i--) {
+		ASSERT(i > 0 && i < NCHUNKS);
+		zbud_budlists_lock();
+		if (!list_empty(&zbud_unbuddied[i].list)) {
+			ASSERT(zbud_unbuddied[i].count > 0);
+			list_for_each_entry_safe(zbpg, ztmp,
+				    &zbud_unbuddied[i].list, bud_list) {
+				if (zbpg_trylock(zbpg)) {
+					found_good_buddy = i;
+					goto found_unbuddied;
+				}
+			}
+		}
+		zbud_budlists_unlock();
+	}
+	/* didn't find a good buddy, try allocating a new page */
+	zbpg = zbud_alloc_raw_page();
+	if (unlikely(zbpg == NULL))
+		goto out;
+	/* ok, have a page, now compress the data before taking locks */
+	zbpg_lock(zbpg);
+	zbud_budlists_lock();
+	list_add_tail(&zbpg->bud_list, &zbud_unbuddied[nchunks].list);
+	zbud_unbuddied[nchunks].count++;
+	zh = &zbpg->buddy[0];
+	ASSERT(found_good_buddy == 0);
+	goto init_zh;
+
+found_unbuddied:
+	ASSERT(found_good_buddy > 0 && found_good_buddy < NCHUNKS);
+	ASSERT_SPINLOCK(&zbpg->lock);
+	zh0 = &zbpg->buddy[0]; zh1 = &zbpg->buddy[1];
+	ASSERT((zh0->size == 0) ^ (zh1->size == 0));
+	if (zh0->size != 0) { /* buddy0 in use, buddy1 is vacant */
+		ASSERT_SENTINEL(zh0, ZBH);
+		zh = zh1;
+	} else if (zh1->size != 0) { /* buddy1 in use, buddy0 is vacant */
+		ASSERT_SENTINEL(zh1, ZBH);
+		zh = zh0;
+	} else
+		BUG();
+	list_del_init(&zbpg->bud_list);
+	zbud_unbuddied[found_good_buddy].count--;
+	list_add_tail(&zbpg->bud_list, &zbud_buddied_list);
+	kztmem_zbud_buddied_count++;
+
+init_zh:
+	SET_SENTINEL(zh, ZBH);
+	zh->size = size;
+	zh->index = index;
+	zh->obj = obj;
+	/* can wait to copy the data until the list locks are dropped */
+	zbud_budlists_unlock();
+
+	to = zbud_data(zh, size);
+	memcpy(to, cdata, size);
+	zbpg_unlock(zbpg);
+	zbud_cumul_chunk_counts[nchunks]++;
+	atomic_inc(&kztmem_zbud_curr_zpages);
+	kztmem_zbud_cumul_zpages++;
+	kztmem_zbud_curr_zbytes += size;
+	kztmem_zbud_cumul_zbytes += size;
+out:
+	return zh;
+}
+
+static void zbud_decompress(struct page *page, struct zbud_hdr *zh)
+{
+	struct zbud_page *zbpg;
+	unsigned budnum = zbud_budnum(zh);
+	size_t out_len = PAGE_SIZE;
+	char *to_va, *from_va;
+	unsigned size;
+	int ret;
+
+	zbpg = container_of(zh, struct zbud_page, buddy[budnum]);
+	zbpg_lock(zbpg);
+	ASSERT_SENTINEL(zh, ZBH);
+	ASSERT(zh->size > 0 && zh->size <= zbud_max_buddy_size());
+	to_va = kmap_atomic(page, KM_USER0);
+	size = zh->size;
+	from_va = zbud_data(zh, size);
+	ret = lzo1x_decompress_safe(from_va, size, to_va, &out_len);
+	ASSERT(ret == LZO_E_OK);
+	ASSERT(out_len == PAGE_SIZE);
+	kunmap_atomic(to_va, KM_USER0);
+	zbpg_unlock(zbpg);
+}
+
+static unsigned long evicted_pgs;
+
+/*
+ * First free the pageframes of anything in the zbpg list.  Then
+ * walk through all ephemeral pampd's (starting with least efficiently
+ * stored), prune them from all tmem data structures, and free the
+ * pageframes.  Should only be called when all tmem and zbud operations
+ * are locked out (ie. when the tmem_rwlock is held for writing)
+ */
+static void zbud_evict_pages(int nr)
+{
+	struct zbud_page *zbpg, *ztmp;
+	int i, j;
+
+	if (list_empty(&zbpg_unused_list)) {
+		list_for_each_entry_safe(zbpg, ztmp, &zbpg_unused_list,
+						bud_list) {
+			list_del_init(&zbpg->bud_list);
+			kztmem_zbpg_unused_list_count--;
+			atomic_dec(&kztmem_zbud_curr_raw_pages);
+			kztmem_free_page(zbpg);
+			if (--nr <= 0)
+				break;
+		}
+	}
+	if (nr <= 0)
+		goto out;
+	for (i = 0; i < MAX_CHUNK; i++) {
+		if (list_empty(&zbud_unbuddied[i].list))
+			continue;
+		list_for_each_entry_safe(zbpg, ztmp,
+				&zbud_unbuddied[i].list, bud_list) {
+			for (j = 0; j < ZBUD_MAX_BUDS; j++)
+				if (zbpg->buddy[j].size)
+					tmem_pampd_prune(&zbpg->buddy[j]);
+			list_del_init(&zbpg->bud_list);
+			ASSERT_SENTINEL(zbpg, ZBPG);
+			zbud_free_raw_page(zbpg);
+			evicted_pgs++;
+			zbud_unbuddied[i].count--;
+			if (--nr <= 0)
+				goto out;
+		}
+	}
+	if (nr > 0 && !list_empty(&zbud_buddied_list)) {
+		list_for_each_entry_safe(zbpg, ztmp,
+				&zbud_buddied_list, bud_list) {
+			for (j = 0; j < ZBUD_MAX_BUDS; j++) {
+				ASSERT(zbpg->buddy[j].size);
+				tmem_pampd_prune(&zbpg->buddy[j]);
+			}
+			list_del_init(&zbpg->bud_list);
+			ASSERT_SENTINEL(zbpg, ZBPG);
+			zbud_free_raw_page(zbpg);
+			evicted_pgs++;
+			kztmem_zbud_buddied_count--;
+			if (--nr <= 0)
+				goto out;
+		}
+	}
+out:
+	return;
+}
+
+#ifdef CONFIG_SYSFS
+static int zbud_show_unbuddied_list_counts(char *buf)
+{
+	int i;
+	char *p = buf;
+
+	for (i = 0; i < NCHUNKS - 1; i++)
+		p += sprintf(p, "%u ", zbud_unbuddied[i].count);
+	p += sprintf(p, "%d\n", zbud_unbuddied[i].count);
+	return p - buf;
+}
+
+static int zbud_show_cumul_chunk_counts(char *buf)
+{
+	unsigned long i, chunks = 0, total_chunks = 0, sum_total_chunks = 0;
+	unsigned long total_chunks_lte_21 = 0, total_chunks_lte_32 = 0;
+	unsigned long total_chunks_lte_42 = 0;
+	char *p = buf;
+
+	for (i = 0; i < NCHUNKS; i++) {
+		p += sprintf(p, "%lu ", zbud_cumul_chunk_counts[i]);
+		chunks += zbud_cumul_chunk_counts[i];
+		total_chunks += zbud_cumul_chunk_counts[i];
+		sum_total_chunks += i * zbud_cumul_chunk_counts[i];
+		if (i == 21)
+			total_chunks_lte_21 = total_chunks;
+		if (i == 32)
+			total_chunks_lte_32 = total_chunks;
+		if (i == 42)
+			total_chunks_lte_42 = total_chunks;
+	}
+	p += sprintf(p, "<=21:%lu <=32:%lu <=42:%lu, mean:%lu\n",
+		total_chunks_lte_21, total_chunks_lte_32, total_chunks_lte_42,
+		chunks == 0 ? 0 : sum_total_chunks / chunks);
+	return p - buf;
+}
+#endif
+
+static void zbud_init(void)
+{
+	int i;
+
+	INIT_LIST_HEAD(&zbud_buddied_list);
+	kztmem_zbud_buddied_count = 0;
+	for (i = 0; i < NCHUNKS; i++) {
+		INIT_LIST_HEAD(&zbud_unbuddied[i].list);
+		zbud_unbuddied[i].count = 0;
+	}
+	pr_info("kztmem: zbud: NCHUNKS=%d, MAX_CHUNK=%d, max_buddy_size=%d\n",
+		(int)NCHUNKS, (int)MAX_CHUNK, (int)zbud_max_buddy_size());
+}
+
+/**********
+ * This "zv" PAM implementation combines the TLSF-based xvMalloc
+ * with lzo1x compression to maximize the amount of data that can
+ * be packed into a physical page.
+ *
+ * Zv represents a PAM page with the index and object (plus a "size" value
+ * necessary for decompression) immediately preceding the compressed data.
+ */
+
+#define ZVH_SENTINEL  0x43214321
+
+struct zv_hdr {
+	void *obj;
+	uint32_t index;
+	DECL_SENTINEL
+};
+
+static const int zv_max_page_size = (PAGE_SIZE / 8) * 7;
+
+static struct zv_hdr *zv_create(struct xv_pool *xvpool, uint32_t index,
+				void *obj, void *cdata, unsigned clen)
+{
+	struct page *page;
+	unsigned long flags;
+	struct zv_hdr *zv = NULL;
+	uint32_t offset;
+	int ret;
+
+	local_irq_save(flags);
+	ret = xv_malloc(xvpool, clen + sizeof(struct zv_hdr),
+			&page, &offset, GFP_NOWAIT);
+	local_irq_restore(flags);
+	if (unlikely(ret))
+		goto out;
+	zv = kmap_atomic(page, KM_USER0) + offset;
+	zv->index = index;
+	zv->obj = obj;
+	SET_SENTINEL(zv, ZVH);
+	memcpy((char *)zv + sizeof(struct zv_hdr), cdata, clen);
+	kunmap_atomic(zv, KM_USER0);
+out:
+	return zv;
+}
+
+static void zv_free(struct xv_pool *xvpool, struct zv_hdr *zv)
+{
+	unsigned long flags;
+	struct page *page;
+	uint32_t offset;
+	uint16_t size;
+
+	ASSERT_SENTINEL(zv, ZVH);
+	ASSERT(zv->obj != NULL);
+	size = xv_get_object_size(zv) - sizeof(*zv);
+	ASSERT(size > 0 && size <= zv_max_page_size);
+	zv->obj = NULL;
+	INVERT_SENTINEL(zv, ZVH);
+	page = virt_to_page(zv);
+	offset = (unsigned long)zv & ~PAGE_MASK;
+	local_irq_save(flags);
+	xv_free(xvpool, page, offset);
+	local_irq_restore(flags);
+}
+
+static void zv_decompress(struct page *page, struct zv_hdr *zv)
+{
+	size_t clen = PAGE_SIZE;
+	char *to_va;
+	unsigned size;
+	int ret;
+
+	ASSERT_SENTINEL(zv, ZVH);
+	size = xv_get_object_size(zv) - sizeof(*zv);
+	ASSERT(size > 0 && size <= zv_max_page_size);
+	to_va = kmap_atomic(page, KM_USER0);
+	ret = lzo1x_decompress_safe((char *)zv + sizeof(*zv),
+					size, to_va, &clen);
+	kunmap_atomic(to_va, KM_USER0);
+	ASSERT(ret == LZO_E_OK);
+	ASSERT(clen == PAGE_SIZE);
+}
+
+/*
+ * kztmem implementation for tmem host ops
+ */
+
+#define MAX_POOLS_PER_CLIENT 16
+
+static struct {
+	struct tmem_pool *tmem_pools[MAX_POOLS_PER_CLIENT];
+	struct xv_pool *xvpool;
+} kztmem_client;
+
+/*
+ * Tmem operations assume the poolid refers to the invoking client.
+ * Kztmem only has one client (the kernel itself), so translate
+ * the poolid into the tmem_pool allocated for it
+ */
+static struct tmem_pool *kztmem_get_pool_by_id(uint32_t poolid)
+{
+	struct tmem_pool *pool = NULL;
+
+	if (poolid >= 0) {
+		pool = kztmem_client.tmem_pools[poolid];
+		if (!pool->is_valid)
+			pool = NULL;
+	}
+	return pool;
+}
+
+/*
+ * Ensure that memory allocation requests in kztmem don't result
+ * in direct reclaim requests via the shrinker, which would cause
+ * an infinite loop.  Maybe a GFP flag would be better?
+ */
+static DEFINE_SPINLOCK(kztmem_direct_reclaim_lock);
+
+/*
+ * for now, used named slabs so can easily track usage; later can
+ * probably just use kmalloc
+ */
+static struct kmem_cache *kztmem_objnode_cache;
+static struct kmem_cache *kztmem_obj_cache;
+static atomic_t kztmem_curr_obj_count = ATOMIC_INIT(0);
+static unsigned long kztmem_curr_obj_count_max;
+static atomic_t kztmem_curr_objnode_count = ATOMIC_INIT(0);
+static unsigned long kztmem_curr_objnode_count_max;
+
+static void *kztmem_get_free_page(void)
+{
+	void *page = NULL;
+
+	if (spin_trylock(&kztmem_direct_reclaim_lock)) {
+		page = (void *)__get_free_page(
+				GFP_KERNEL | __GFP_ZERO | __GFP_NORETRY);
+		spin_unlock(&kztmem_direct_reclaim_lock);
+	}
+	return page;
+}
+
+static void kztmem_free_page(void *p)
+{
+	free_page((unsigned long)p);
+}
+
+static struct tmem_objnode *kztmem_objnode_alloc(struct tmem_pool *pool)
+{
+	struct tmem_objnode *objnode = NULL;
+	unsigned long count;
+
+	if (unlikely(kztmem_objnode_cache == NULL)) {
+		kztmem_objnode_cache =
+			kmem_cache_create("kztmem_objnode",
+				sizeof(struct tmem_objnode), 0, 0, NULL);
+		if (unlikely(kztmem_objnode_cache == NULL))
+			goto out;
+	}
+	if (spin_trylock(&kztmem_direct_reclaim_lock)) {
+		objnode = kmem_cache_alloc(kztmem_objnode_cache,
+					GFP_KERNEL | __GFP_NORETRY);
+		count = atomic_inc_return(&kztmem_curr_objnode_count);
+		if (count > kztmem_curr_objnode_count_max)
+			kztmem_curr_objnode_count_max = count;
+		spin_unlock(&kztmem_direct_reclaim_lock);
+	}
+out:
+	return objnode;
+}
+
+static void kztmem_objnode_free(struct tmem_objnode *objnode,
+					struct tmem_pool *pool)
+{
+	atomic_dec(&kztmem_curr_objnode_count);
+	ASSERT(atomic_read(&kztmem_curr_objnode_count) >= 0);
+	kmem_cache_free(kztmem_objnode_cache, objnode);
+}
+
+static struct tmem_obj *kztmem_obj_alloc(struct tmem_pool *pool)
+{
+	struct tmem_obj *obj = NULL;
+	unsigned long count;
+
+	if (unlikely(kztmem_obj_cache == NULL)) {
+		kztmem_obj_cache = kmem_cache_create("kztmem_obj",
+					sizeof(struct tmem_obj), 0, 0, NULL);
+		if (unlikely(kztmem_obj_cache == NULL))
+			goto out;
+	}
+	if (spin_trylock(&kztmem_direct_reclaim_lock)) {
+		obj = kmem_cache_alloc(kztmem_obj_cache,
+					GFP_KERNEL | __GFP_NORETRY);
+		spin_unlock(&kztmem_direct_reclaim_lock);
+		count = atomic_inc_return(&kztmem_curr_obj_count);
+		if (count > kztmem_curr_obj_count_max)
+			kztmem_curr_obj_count_max = count;
+	}
+out:
+	return obj;
+}
+
+static void kztmem_obj_free(struct tmem_obj *obj, struct tmem_pool *pool)
+{
+	atomic_dec(&kztmem_curr_obj_count);
+	ASSERT(atomic_read(&kztmem_curr_obj_count) >= 0);
+	kmem_cache_free(kztmem_obj_cache, obj);
+}
+
+static struct tmem_pool *kztmem_pool_alloc(uint32_t flags, uint32_t *ppoolid)
+{
+	int persistent = flags & TMEM_POOL_PERSIST;
+	int pagebits = (flags >> TMEM_POOL_PAGESIZE_SHIFT)
+		& TMEM_POOL_PAGESIZE_MASK;
+	struct tmem_pool *pool = NULL;
+	int shared = 0;
+	uint32_t poolid;
+
+	pr_info("tmem: allocating %s-%s tmem pool...",
+		persistent ? "persistent" : "ephemeral" ,
+		shared ? "shared" : "private");
+	pool = (struct tmem_pool *)kmalloc(sizeof(struct tmem_pool),
+						GFP_KERNEL);
+	if (pool == NULL) {
+		pr_info("failed... out of memory\n");
+		goto out;
+	}
+	if (pagebits != (PAGE_SHIFT - 12)) {
+		pr_info("failed... unsupported pagesize %d\n",
+			1<<(pagebits+12));
+		goto fail;
+	}
+	if (flags & TMEM_POOL_PRECOMPRESSED) {
+		pr_info("failed... precompression flag set "
+			"but unsupported\n");
+		goto fail;
+	}
+	if (flags & TMEM_POOL_RESERVED_BITS) {
+		pr_info("failed... reserved bits must be zero\n");
+		goto fail;
+	}
+
+	for (poolid = 0; poolid < MAX_POOLS_PER_CLIENT; poolid++)
+		if (kztmem_client.tmem_pools[poolid] == NULL)
+			break;
+	if (poolid >= MAX_POOLS_PER_CLIENT) {
+		pr_info("failed no more pool slots available\n");
+		goto fail;
+	}
+	pool->is_valid = 0; /* avoid races */
+	kztmem_client.tmem_pools[poolid] = pool;
+	pool->client = &kztmem_client;
+	*ppoolid = poolid;
+	pr_info("pool_id=%d\n", poolid);
+	goto out;
+fail:
+	kfree(pool);
+	pool = NULL;
+out:
+	return pool;
+}
+
+static void kztmem_pool_free(struct tmem_pool *pool)
+{
+	kztmem_client.tmem_pools[pool->pool_id] = NULL;
+	kfree(pool);
+}
+
+static struct tmem_hostops kztmem_hostops = {
+	.get_pool_by_id = kztmem_get_pool_by_id,
+	.obj_alloc = kztmem_obj_alloc,
+	.obj_free = kztmem_obj_free,
+	.objnode_alloc = kztmem_objnode_alloc,
+	.objnode_free = kztmem_objnode_free,
+	.pool_alloc = kztmem_pool_alloc,
+	.pool_free = kztmem_pool_free
+};
+
+/*
+ * kztmem implementations for PAM page descriptor ops
+ */
+
+static atomic_t kztmem_curr_eph_pampd_count = ATOMIC_INIT(0);
+static unsigned long kztmem_curr_eph_pampd_count_max;
+static atomic_t kztmem_curr_pers_pampd_count = ATOMIC_INIT(0);
+static unsigned long kztmem_curr_pers_pampd_count_max;
+
+/* forward reference */
+static int kztmem_compress(struct page *from, void **out_va, unsigned *out_len);
+
+static void *kztmem_pampd_create(void *obj, uint32_t index,
+				struct page *page, void *vpool)
+{
+	void *pampd = NULL, *cdata;
+	unsigned clen;
+	int ret;
+	struct tmem_pool *pool = (struct tmem_pool *)vpool;
+	bool ephemeral = is_ephemeral(pool);
+	unsigned long count;
+
+	if (ephemeral) {
+		preempt_disable(); /* compressed data is per-cpu */
+		ret = kztmem_compress(page, &cdata, &clen);
+		if (ret == 0)
+
+			goto enable_out;
+		if (clen == 0 || clen > zbud_max_buddy_size())
+			goto bad_compress;
+		pampd = (void *)zbud_create(index, obj, page, cdata, clen);
+		if (pampd != NULL) {
+			count = atomic_inc_return(&kztmem_curr_eph_pampd_count);
+			if (count > kztmem_curr_eph_pampd_count_max)
+				kztmem_curr_eph_pampd_count_max = count;
+		}
+	} else {
+		/*
+		 * FIXME: This is all the "policy" there is for now.
+		 * 3/4 totpages should allow ~37% of RAM to be filled with
+		 * compressed frontswap pages
+		 */
+		if (atomic_read(&kztmem_curr_pers_pampd_count) >
+							3 * totalram_pages / 4)
+			goto out;
+		preempt_disable(); /* compressed data is per-cpu */
+		ret = kztmem_compress(page, &cdata, &clen);
+		if (ret == 0)
+			goto enable_out;
+		if (clen > zv_max_page_size)
+			goto bad_compress;
+		pampd = (void *)zv_create(kztmem_client.xvpool, index, obj,
+						cdata, clen);
+		if (pampd != NULL) {
+			count = atomic_inc_return(&kztmem_curr_pers_pampd_count);
+			if (count > kztmem_curr_pers_pampd_count_max)
+				kztmem_curr_pers_pampd_count_max = count;
+		}
+	}
+	goto enable_out;
+
+bad_compress:
+	kztmem_compress_poor++;
+enable_out:
+	preempt_enable_no_resched();
+out:
+	return pampd;
+}
+
+/*
+ * fill the pageframe corresponding to the struct page with the data
+ * from the passed pampd
+ */
+static void kztmem_pampd_get_data(struct page *page, void *pampd, void *vpool)
+{
+	struct tmem_pool *pool = (struct tmem_pool *)vpool;
+
+	if (is_ephemeral(pool))
+		zbud_decompress(page, pampd);
+	else
+		zv_decompress(page, pampd);
+}
+
+/* return the pampd's index */
+static uint32_t kztmem_pampd_get_index(void *pampd, void *vpool)
+{
+	struct tmem_pool *pool = (struct tmem_pool *)vpool;
+	uint32_t ret = -1;
+
+	if (pool == NULL || is_ephemeral(pool)) {
+		struct zbud_hdr *zh = (struct zbud_hdr *)pampd;
+
+		if (zh == NULL)
+			goto out;
+		ASSERT_SENTINEL(zh, ZBH);
+		ret = zh->index;
+	} else {
+		struct zv_hdr *zv = (struct zv_hdr *)pampd;
+		if (zv == NULL)
+			goto out;
+		ASSERT_SENTINEL(zv, ZVH);
+		ret = zv->index;
+	}
+out:
+	return ret;
+}
+
+/* return the pampd's object */
+static struct tmem_obj *kztmem_pampd_get_obj(void *pampd, void *vpool)
+{
+	struct tmem_pool *pool = (struct tmem_pool *)vpool;
+	struct tmem_obj *obj = NULL;
+
+	if (pool == NULL || is_ephemeral(pool)) {
+		struct zbud_hdr *zh = (struct zbud_hdr *)pampd;
+
+		if (zh == NULL)
+			goto out;
+		ASSERT_SENTINEL(zh, ZBH);
+		obj = zh->obj;
+	} else {
+		struct zv_hdr *zv = (struct zv_hdr *)pampd;
+
+		if (zv == NULL)
+			goto out;
+		ASSERT_SENTINEL(zv, ZVH);
+		obj = (struct tmem_obj *)zv->obj;
+	}
+out:
+	return obj;
+}
+
+/*
+ * free the pampd and remove it from any kztmem lists
+ * pampd must no longer be pointed to from any tmem data structures!
+ */
+static void kztmem_pampd_free(void *pampd, struct tmem_pool *pool)
+{
+	if (is_ephemeral(pool)) {
+		zbud_free_and_delist((struct zbud_hdr *)pampd);
+		atomic_dec(&kztmem_curr_eph_pampd_count);
+		ASSERT(atomic_read(&kztmem_curr_eph_pampd_count) >= 0);
+	} else {
+		zv_free(kztmem_client.xvpool, (struct zv_hdr *)pampd);
+		atomic_dec(&kztmem_curr_pers_pampd_count);
+		ASSERT(atomic_read(&kztmem_curr_pers_pampd_count) >= 0);
+	}
+}
+
+/*
+ * free the pampd... delisting is done later by caller. Should only be
+ * called when all zbud operations are locked out (ie. when the tmem_rwlock
+ * is held for writing).  prune can only be used on ephemeral pampds.
+ */
+static void kztmem_pampd_prune(void *pampd)
+{
+	zbud_free((struct zbud_hdr *)pampd);
+	atomic_dec(&kztmem_curr_eph_pampd_count);
+	ASSERT(atomic_read(&kztmem_curr_eph_pampd_count) >= 0);
+}
+
+static struct tmem_pamops kztmem_pamops = {
+	.get_data = kztmem_pampd_get_data,
+	.get_index = kztmem_pampd_get_index,
+	.get_obj = kztmem_pampd_get_obj,
+	.free = kztmem_pampd_free,
+	.prune = kztmem_pampd_prune,
+	.create = kztmem_pampd_create
+};
+
+/*
+ * kztmem compression/decompression and related per-cpu stuff
+ */
+
+#define LZO_WORKMEM_BYTES LZO1X_1_MEM_COMPRESS
+#define LZO_DSTMEM_PAGE_ORDER 1
+static DEFINE_PER_CPU(unsigned char *, kztmem_workmem);
+static DEFINE_PER_CPU(unsigned char *, kztmem_dstmem);
+
+static int kztmem_compress(struct page *from, void **out_va,
+				  unsigned *out_len)
+{
+	int ret = 0;
+	unsigned char *dmem = __get_cpu_var(kztmem_dstmem);
+	unsigned char *wmem = __get_cpu_var(kztmem_workmem);
+	char *from_va;
+
+	if (unlikely(dmem == NULL || wmem == NULL))
+		goto out;  /* no buffer, so can't compress */
+	from_va = kmap_atomic(from, KM_USER0);
+	mb();
+	ret = lzo1x_1_compress(from_va, PAGE_SIZE, dmem,
+				(size_t *)out_len, wmem);
+	ASSERT(ret == LZO_E_OK);
+	*out_va = dmem;
+	kunmap_atomic(from_va, KM_USER0);
+	ret = 1;
+out:
+	return ret;
+}
+
+
+static int kztmem_cpu_notifier(struct notifier_block *nb,
+				unsigned long action, void *pcpu)
+{
+	int cpu = (long)pcpu;
+
+	switch (action) {
+	case CPU_UP_PREPARE:
+		per_cpu(kztmem_dstmem, cpu) = (void *)__get_free_pages(
+			GFP_KERNEL | __GFP_ZERO | __GFP_REPEAT,
+			LZO_DSTMEM_PAGE_ORDER),
+		per_cpu(kztmem_workmem, cpu) =
+			kzalloc(LZO1X_MEM_COMPRESS,
+				GFP_KERNEL | __GFP_REPEAT);
+		break;
+	case CPU_DEAD:
+	case CPU_UP_CANCELED:
+		free_pages((unsigned long)per_cpu(kztmem_dstmem, cpu),
+				LZO_DSTMEM_PAGE_ORDER);
+		per_cpu(kztmem_dstmem, cpu) = NULL;
+		kfree(per_cpu(kztmem_workmem, cpu));
+		per_cpu(kztmem_workmem, cpu) = NULL;
+		break;
+	default:
+		break;
+	}
+	return NOTIFY_OK;
+}
+
+static struct notifier_block kztmem_cpu_notifier_block = {
+	.notifier_call = kztmem_cpu_notifier
+};
+
+#ifdef CONFIG_SYSFS
+#define KZTMEM_SYSFS_RO(_name) \
+	static ssize_t kztmem_##_name##_show(struct kobject *kobj, \
+				struct kobj_attribute *attr, char *buf) \
+	{ \
+		return sprintf(buf, "%lu\n", kztmem_##_name); \
+	} \
+	static struct kobj_attribute kztmem_##_name##_attr = { \
+		.attr = { .name = __stringify(_name), .mode = 0444 }, \
+		.show = kztmem_##_name##_show, \
+	}
+
+#define KZTMEM_SYSFS_TMEM_STAT_RO(_name) \
+	static ssize_t kztmem_##_name##_show(struct kobject *kobj, \
+				struct kobj_attribute *attr, char *buf) \
+	{ \
+		return sprintf(buf, "%lu\n", \
+				tmem_stat_get(TMEM_STAT_##_name)); \
+	} \
+	static struct kobj_attribute kztmem_##_name##_attr = { \
+		.attr = { .name = __stringify(_name), .mode = 0444 }, \
+		.show = kztmem_##_name##_show, \
+	}
+
+#define KZTMEM_SYSFS_RO_ATOMIC(_name) \
+	static ssize_t kztmem_##_name##_show(struct kobject *kobj, \
+				struct kobj_attribute *attr, char *buf) \
+	{ \
+	    return sprintf(buf, "%d\n", atomic_read(&kztmem_##_name)); \
+	} \
+	static struct kobj_attribute kztmem_##_name##_attr = { \
+		.attr = { .name = __stringify(_name), .mode = 0444 }, \
+		.show = kztmem_##_name##_show, \
+	}
+
+#define KZTMEM_SYSFS_RO_CUSTOM(_name, _func) \
+	static ssize_t kztmem_##_name##_show(struct kobject *kobj, \
+				struct kobj_attribute *attr, char *buf) \
+	{ \
+	    return _func(buf); \
+	} \
+	static struct kobj_attribute kztmem_##_name##_attr = { \
+		.attr = { .name = __stringify(_name), .mode = 0444 }, \
+		.show = kztmem_##_name##_show, \
+	}
+
+KZTMEM_SYSFS_RO_ATOMIC(curr_obj_count);
+KZTMEM_SYSFS_RO(curr_obj_count_max);
+KZTMEM_SYSFS_RO_ATOMIC(curr_objnode_count);
+KZTMEM_SYSFS_RO(curr_objnode_count_max);
+KZTMEM_SYSFS_TMEM_STAT_RO(flush_total);
+KZTMEM_SYSFS_TMEM_STAT_RO(flush_found);
+KZTMEM_SYSFS_TMEM_STAT_RO(flobj_total);
+KZTMEM_SYSFS_TMEM_STAT_RO(flobj_found);
+KZTMEM_SYSFS_RO_ATOMIC(zbud_curr_raw_pages);
+KZTMEM_SYSFS_RO_ATOMIC(zbud_curr_zpages);
+KZTMEM_SYSFS_RO(zbud_curr_zbytes);
+KZTMEM_SYSFS_RO(zbud_cumul_zpages);
+KZTMEM_SYSFS_RO(zbud_cumul_zbytes);
+KZTMEM_SYSFS_RO(zbud_buddied_count);
+KZTMEM_SYSFS_RO(zbpg_unused_list_count);
+KZTMEM_SYSFS_RO(compress_poor);
+KZTMEM_SYSFS_RO_CUSTOM(zbud_unbuddied_list_counts,
+			zbud_show_unbuddied_list_counts);
+KZTMEM_SYSFS_RO_CUSTOM(zbud_cumul_chunk_counts,
+			zbud_show_cumul_chunk_counts);
+
+static struct attribute *kztmem_attrs[] = {
+	&kztmem_curr_obj_count_attr.attr,
+	&kztmem_curr_obj_count_max_attr.attr,
+	&kztmem_curr_objnode_count_attr.attr,
+	&kztmem_curr_objnode_count_max_attr.attr,
+	&kztmem_flush_total_attr.attr,
+	&kztmem_flobj_total_attr.attr,
+	&kztmem_flush_found_attr.attr,
+	&kztmem_flobj_found_attr.attr,
+	&kztmem_compress_poor_attr.attr,
+	&kztmem_zbud_curr_raw_pages_attr.attr,
+	&kztmem_zbud_curr_zpages_attr.attr,
+	&kztmem_zbud_curr_zbytes_attr.attr,
+	&kztmem_zbud_cumul_zpages_attr.attr,
+	&kztmem_zbud_cumul_zbytes_attr.attr,
+	&kztmem_zbud_buddied_count_attr.attr,
+	&kztmem_zbpg_unused_list_count_attr.attr,
+	&kztmem_zbud_unbuddied_list_counts_attr.attr,
+	&kztmem_zbud_cumul_chunk_counts_attr.attr,
+	NULL,
+};
+
+static struct attribute_group kztmem_attr_group = {
+	.attrs = kztmem_attrs,
+	.name = "kztmem",
+};
+
+#endif /* CONFIG_SYSFS */
+
+/*
+ * kztmem shrinker interface (only useful for ephemeral pages, so zbud only)
+ */
+#include <linux/version.h>
+#if LINUX_VERSION_CODE == KERNEL_VERSION(2,6,27)
+static int shrink_kztmem_memory(int nr, gfp_t gfp_mask)
+#else
+static int shrink_kztmem_memory(struct shrinker *shrink, int nr, gfp_t gfp_mask)
+#endif
+{
+	int ret = -1;
+
+	if (nr) {
+		if (!(gfp_mask & __GFP_FS))  /* is this appropriate here?
+						see shrink_icache_memory() */
+			goto out;
+		ASSERT(nr >= 0);
+		if (spin_trylock(&kztmem_direct_reclaim_lock)) {
+			preempt_disable();
+			if (tmem_shrink_trylock()) {
+				shrinking = 1;
+				zbud_evict_pages(nr);
+				shrinking = 0;
+				tmem_shrink_unlock();
+			}
+			preempt_enable_no_resched();
+			spin_unlock(&kztmem_direct_reclaim_lock);
+		}
+	}
+	ret = (int)atomic_read(&kztmem_zbud_curr_raw_pages);
+out:
+	return ret;
+}
+
+static struct shrinker kztmem_shrinker = {
+	.shrink = shrink_kztmem_memory,
+	.seeks = DEFAULT_SEEKS,
+};
+
+/*
+ * kztmem initialization
+ * NOTE FOR NOW kztmem MUST BE PROVIDED AS A KERNEL BOOT PARAMETER OR
+ * NOTHING HAPPENS!
+ */
+
+static int kztmem_enabled;
+
+static int __init enable_kztmem(char *s)
+{
+	kztmem_enabled = 1;
+	return 1;
+}
+__setup("kztmem", enable_kztmem);
+
+static int use_cleancache = 1;
+
+static int __init no_cleancache(char *s)
+{
+	use_cleancache = 0;
+	return 1;
+}
+
+__setup("nocleancache", no_cleancache);
+
+static int use_frontswap = 1;
+
+static int __init no_frontswap(char *s)
+{
+	use_frontswap = 0;
+	return 1;
+}
+
+__setup("nofrontswap", no_frontswap);
+
+static int __init kztmem_init(void)
+{
+#ifdef CONFIG_SYSFS
+	int ret = 0;
+
+	ret = sysfs_create_group(mm_kobj, &kztmem_attr_group);
+	if (ret) {
+		pr_err("kztmem: can't create sysfs\n");
+		goto out;
+	}
+#endif /* CONFIG_SYSFS */
+#if defined(CONFIG_CLEANCACHE) || defined(CONFIG_FRONTSWAP)
+	if (kztmem_enabled) {
+		unsigned int cpu;
+
+		tmem_register_hostops(&kztmem_hostops);
+		tmem_register_pamops(&kztmem_pamops);
+		sadix_tree_init();
+		ret = register_cpu_notifier(&kztmem_cpu_notifier_block);
+		if (ret) {
+			pr_err("kztmem: can't register cpu notifier\n");
+			goto out;
+		}
+		for_each_online_cpu(cpu) {
+			void *pcpu = (void *)(long)cpu;
+			kztmem_cpu_notifier(&kztmem_cpu_notifier_block,
+				CPU_UP_PREPARE, pcpu);
+		}
+	}
+#endif
+#ifdef CONFIG_CLEANCACHE
+	if (kztmem_enabled && use_cleancache) {
+		struct cleancache_ops old_ops;
+
+		zbud_init();
+		register_shrinker(&kztmem_shrinker);
+		old_ops = tmem_cleancache_register_ops();
+		pr_info("kztmem: cleancache enabled using kernel "
+			"transcendent memory and compression buddies\n");
+		if (old_ops.init_fs != NULL)
+			pr_warning("kztmem: cleancache_ops overridden");
+	}
+#endif
+#ifdef CONFIG_FRONTSWAP
+	if (kztmem_enabled && use_frontswap) {
+		struct frontswap_ops old_ops;
+
+		kztmem_client.xvpool = xv_create_pool();
+		if (kztmem_client.xvpool == NULL) {
+			pr_err("kztmem: can't create xvpool\n");
+			goto out;
+		}
+		old_ops = tmem_frontswap_register_ops();
+		pr_info("kztmem: frontswap enabled using kernel "
+			"transcendent memory and xvmalloc\n");
+		if (old_ops.init != NULL)
+			pr_warning("ktmem: frontswap_ops overridden");
+	}
+#endif
+out:
+	return ret;
+}
+
+module_init(kztmem_init)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
