Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 451CA6B0062
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 04:47:13 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 1/3] zsmalloc: promote to lib/
Date: Wed, 26 Sep 2012 17:50:17 +0900
Message-Id: <1348649419-16494-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1348649419-16494-1-git-send-email-minchan@kernel.org>
References: <1348649419-16494-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>

This patch promotes the slab-based zsmalloc memory allocator
from the staging tree to lib/

zcache/zram depends on this allocator for storing compressed RAM pages
in an efficient way under system wide memory pressure where
high-order (greater than 0) page allocation are very likely to
fail.

For more information on zsmalloc and its internals, read the
documentation at the top of the zsmalloc.c file.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/staging/Kconfig                  |    2 -
 drivers/staging/Makefile                 |    1 -
 drivers/staging/zcache/zcache-main.c     |    4 +-
 drivers/staging/zram/zram_drv.h          |    3 +-
 drivers/staging/zsmalloc/Kconfig         |   10 -
 drivers/staging/zsmalloc/Makefile        |    3 -
 drivers/staging/zsmalloc/zsmalloc-main.c | 1064 ------------------------------
 drivers/staging/zsmalloc/zsmalloc.h      |   43 --
 include/linux/zsmalloc.h                 |   43 ++
 lib/Kconfig                              |    2 +
 lib/Makefile                             |    1 +
 lib/zsmalloc/Kconfig                     |   18 +
 lib/zsmalloc/Makefile                    |    1 +
 lib/zsmalloc/zsmalloc.c                  | 1064 ++++++++++++++++++++++++++++++
 14 files changed, 1132 insertions(+), 1127 deletions(-)
 delete mode 100644 drivers/staging/zsmalloc/Kconfig
 delete mode 100644 drivers/staging/zsmalloc/Makefile
 delete mode 100644 drivers/staging/zsmalloc/zsmalloc-main.c
 delete mode 100644 drivers/staging/zsmalloc/zsmalloc.h
 create mode 100644 include/linux/zsmalloc.h
 create mode 100644 lib/zsmalloc/Kconfig
 create mode 100644 lib/zsmalloc/Makefile
 create mode 100644 lib/zsmalloc/zsmalloc.c

diff --git a/drivers/staging/Kconfig b/drivers/staging/Kconfig
index 449f04a..4316ef5 100644
--- a/drivers/staging/Kconfig
+++ b/drivers/staging/Kconfig
@@ -78,8 +78,6 @@ source "drivers/staging/zram/Kconfig"
 
 source "drivers/staging/zcache/Kconfig"
 
-source "drivers/staging/zsmalloc/Kconfig"
-
 source "drivers/staging/wlags49_h2/Kconfig"
 
 source "drivers/staging/wlags49_h25/Kconfig"
diff --git a/drivers/staging/Makefile b/drivers/staging/Makefile
index a19abe5..db18726 100644
--- a/drivers/staging/Makefile
+++ b/drivers/staging/Makefile
@@ -34,7 +34,6 @@ obj-$(CONFIG_DX_SEP)            += sep/
 obj-$(CONFIG_IIO)		+= iio/
 obj-$(CONFIG_ZRAM)		+= zram/
 obj-$(CONFIG_ZCACHE)		+= zcache/
-obj-$(CONFIG_ZSMALLOC)		+= zsmalloc/
 obj-$(CONFIG_WLAGS49_H2)	+= wlags49_h2/
 obj-$(CONFIG_WLAGS49_H25)	+= wlags49_h25/
 obj-$(CONFIG_FB_SM7XX)		+= sm7xxfb/
diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index 52b43b7..34b2c5c 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -32,9 +32,9 @@
 #include <linux/crypto.h>
 #include <linux/string.h>
 #include <linux/idr.h>
-#include "tmem.h"
+#include <linux/zsmalloc.h>
 
-#include "../zsmalloc/zsmalloc.h"
+#include "tmem.h"
 
 #ifdef CONFIG_CLEANCACHE
 #include <linux/cleancache.h>
diff --git a/drivers/staging/zram/zram_drv.h b/drivers/staging/zram/zram_drv.h
index 572c0b1..f6d0925 100644
--- a/drivers/staging/zram/zram_drv.h
+++ b/drivers/staging/zram/zram_drv.h
@@ -17,8 +17,7 @@
 
 #include <linux/spinlock.h>
 #include <linux/mutex.h>
-
-#include "../zsmalloc/zsmalloc.h"
+#include <linux/zsmalloc.h>
 
 /*
  * Some arbitrary value. This is just to catch
diff --git a/drivers/staging/zsmalloc/Kconfig b/drivers/staging/zsmalloc/Kconfig
deleted file mode 100644
index 9084565..0000000
--- a/drivers/staging/zsmalloc/Kconfig
+++ /dev/null
@@ -1,10 +0,0 @@
-config ZSMALLOC
-	tristate "Memory allocator for compressed pages"
-	default n
-	help
-	  zsmalloc is a slab-based memory allocator designed to store
-	  compressed RAM pages.  zsmalloc uses virtual memory mapping
-	  in order to reduce fragmentation.  However, this results in a
-	  non-standard allocator interface where a handle, not a pointer, is
-	  returned by an alloc().  This handle must be mapped in order to
-	  access the allocated space.
diff --git a/drivers/staging/zsmalloc/Makefile b/drivers/staging/zsmalloc/Makefile
deleted file mode 100644
index b134848..0000000
--- a/drivers/staging/zsmalloc/Makefile
+++ /dev/null
@@ -1,3 +0,0 @@
-zsmalloc-y 		:= zsmalloc-main.o
-
-obj-$(CONFIG_ZSMALLOC)	+= zsmalloc.o
diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
deleted file mode 100644
index 09a9d35..0000000
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ /dev/null
@@ -1,1064 +0,0 @@
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
-
-/*
- * This allocator is designed for use with zcache and zram. Thus, the
- * allocator is supposed to work well under low memory conditions. In
- * particular, it never attempts higher order page allocation which is
- * very likely to fail under memory pressure. On the other hand, if we
- * just use single (0-order) pages, it would suffer from very high
- * fragmentation -- any object of size PAGE_SIZE/2 or larger would occupy
- * an entire page. This was one of the major issues with its predecessor
- * (xvmalloc).
- *
- * To overcome these issues, zsmalloc allocates a bunch of 0-order pages
- * and links them together using various 'struct page' fields. These linked
- * pages act as a single higher-order page i.e. an object can span 0-order
- * page boundaries. The code refers to these linked pages as a single entity
- * called zspage.
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
-
-#include "zsmalloc.h"
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
- * as single (void *) handle value.
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
-#define ZS_SIZE_CLASS_DELTA	16
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
-	const char *name;
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
-/*
- * By default, zsmalloc uses a copy-based object mapping method to access
- * allocations that span two pages. However, if a particular architecture
- * 1) Implements local_flush_tlb_kernel_range() and 2) Performs VM mapping
- * faster than copying, then it should be added here so that
- * USE_PGTABLE_MAPPING is defined. This causes zsmalloc to use page table
- * mapping rather than copying
- * for object mapping.
-*/
-#if defined(CONFIG_ARM)
-#define USE_PGTABLE_MAPPING
-#endif
-
-struct mapping_area {
-#ifdef USE_PGTABLE_MAPPING
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
-		next = (struct page *)page->private;
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
-	reset_page_mapcount(page);
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
-			first_page->private = (unsigned long)page;
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
-#ifdef USE_PGTABLE_MAPPING
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
-	unsigned long end = addr + (PAGE_SIZE * 2);
-
-	flush_cache_vunmap(addr, end);
-	unmap_kernel_range_noflush(addr, PAGE_SIZE * 2);
-	local_flush_tlb_kernel_range(addr, end);
-}
-
-#else /* USE_PGTABLE_MAPPING */
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
-#endif /* USE_PGTABLE_MAPPING */
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
-static void zs_exit(void)
-{
-	int cpu;
-
-	for_each_online_cpu(cpu)
-		zs_cpu_notifier(NULL, CPU_DEAD, (void *)(long)cpu);
-	unregister_cpu_notifier(&zs_cpu_nb);
-}
-
-static int zs_init(void)
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
-struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
-{
-	int i, ovhd_size;
-	struct zs_pool *pool;
-
-	if (!name)
-		return NULL;
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
-	pool->name = name;
-
-	return pool;
-}
-EXPORT_SYMBOL_GPL(zs_create_pool);
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
-				pr_info("Freeing non-empty class with size "
-					"%db, fullness group %d\n",
-					class->size, fg);
-			}
-		}
-	}
-	kfree(pool);
-}
-EXPORT_SYMBOL_GPL(zs_destroy_pool);
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
-EXPORT_SYMBOL_GPL(zs_malloc);
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
-EXPORT_SYMBOL_GPL(zs_free);
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
-*/
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
-EXPORT_SYMBOL_GPL(zs_map_object);
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
-EXPORT_SYMBOL_GPL(zs_unmap_object);
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
-EXPORT_SYMBOL_GPL(zs_get_total_size_bytes);
-
-module_init(zs_init);
-module_exit(zs_exit);
-
-MODULE_LICENSE("Dual BSD/GPL");
-MODULE_AUTHOR("Nitin Gupta <ngupta@vflare.org>");
diff --git a/drivers/staging/zsmalloc/zsmalloc.h b/drivers/staging/zsmalloc/zsmalloc.h
deleted file mode 100644
index de2e8bf..0000000
--- a/drivers/staging/zsmalloc/zsmalloc.h
+++ /dev/null
@@ -1,43 +0,0 @@
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
-#ifndef _ZS_MALLOC_H_
-#define _ZS_MALLOC_H_
-
-#include <linux/types.h>
-
-/*
- * zsmalloc mapping modes
- *
- * NOTE: These only make a difference when a mapped object spans pages
-*/
-enum zs_mapmode {
-	ZS_MM_RW, /* normal read-write mapping */
-	ZS_MM_RO, /* read-only (no copy-out at unmap time) */
-	ZS_MM_WO /* write-only (no copy-in at map time) */
-};
-
-struct zs_pool;
-
-struct zs_pool *zs_create_pool(const char *name, gfp_t flags);
-void zs_destroy_pool(struct zs_pool *pool);
-
-unsigned long zs_malloc(struct zs_pool *pool, size_t size);
-void zs_free(struct zs_pool *pool, unsigned long obj);
-
-void *zs_map_object(struct zs_pool *pool, unsigned long handle,
-			enum zs_mapmode mm);
-void zs_unmap_object(struct zs_pool *pool, unsigned long handle);
-
-u64 zs_get_total_size_bytes(struct zs_pool *pool);
-
-#endif
diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h
new file mode 100644
index 0000000..de2e8bf
--- /dev/null
+++ b/include/linux/zsmalloc.h
@@ -0,0 +1,43 @@
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
+#ifndef _ZS_MALLOC_H_
+#define _ZS_MALLOC_H_
+
+#include <linux/types.h>
+
+/*
+ * zsmalloc mapping modes
+ *
+ * NOTE: These only make a difference when a mapped object spans pages
+*/
+enum zs_mapmode {
+	ZS_MM_RW, /* normal read-write mapping */
+	ZS_MM_RO, /* read-only (no copy-out at unmap time) */
+	ZS_MM_WO /* write-only (no copy-in at map time) */
+};
+
+struct zs_pool;
+
+struct zs_pool *zs_create_pool(const char *name, gfp_t flags);
+void zs_destroy_pool(struct zs_pool *pool);
+
+unsigned long zs_malloc(struct zs_pool *pool, size_t size);
+void zs_free(struct zs_pool *pool, unsigned long obj);
+
+void *zs_map_object(struct zs_pool *pool, unsigned long handle,
+			enum zs_mapmode mm);
+void zs_unmap_object(struct zs_pool *pool, unsigned long handle);
+
+u64 zs_get_total_size_bytes(struct zs_pool *pool);
+
+#endif
diff --git a/lib/Kconfig b/lib/Kconfig
index bb94c1b..d95da41 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -216,6 +216,8 @@ config DECOMPRESS_LZO
 config GENERIC_ALLOCATOR
 	boolean
 
+source "lib/zsmalloc/Kconfig"
+
 #
 # reed solomon support is select'ed if needed
 #
diff --git a/lib/Makefile b/lib/Makefile
index 3128e35..dd26077 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -64,6 +64,7 @@ obj-$(CONFIG_CRC7)	+= crc7.o
 obj-$(CONFIG_LIBCRC32C)	+= libcrc32c.o
 obj-$(CONFIG_CRC8)	+= crc8.o
 obj-$(CONFIG_GENERIC_ALLOCATOR) += genalloc.o
+obj-$(CONFIG_ZSMALLOC) += zsmalloc/
 
 obj-$(CONFIG_ZLIB_INFLATE) += zlib_inflate/
 obj-$(CONFIG_ZLIB_DEFLATE) += zlib_deflate/
diff --git a/lib/zsmalloc/Kconfig b/lib/zsmalloc/Kconfig
new file mode 100644
index 0000000..b6abd31
--- /dev/null
+++ b/lib/zsmalloc/Kconfig
@@ -0,0 +1,18 @@
+config ZSMALLOC
+       tristate "Memory allocator for compressed pages"
+       default n
+       help
+         zsmalloc is a slab-based memory allocator designed to store
+         compressed RAM pages.  zsmalloc uses a memory pool that combines
+         single pages into higher order pages by linking them together
+         using the fields of the struct page. Allocations are then
+         mapped through copy buffers or VM mapping, in order to reduce
+         memory pool fragmentation and increase allocation success rate under
+         memory pressure.
+
+         This results in a non-standard allocator interface where
+         a handle, not a pointer, is returned by the allocation function.
+         This handle must be mapped in order to access the allocated space.
+
+         If unsure, say N.
+
diff --git a/lib/zsmalloc/Makefile b/lib/zsmalloc/Makefile
new file mode 100644
index 0000000..d02d3a5
--- /dev/null
+++ b/lib/zsmalloc/Makefile
@@ -0,0 +1 @@
+obj-$(CONFIG_ZSMALLOC) += zsmalloc.o
diff --git a/lib/zsmalloc/zsmalloc.c b/lib/zsmalloc/zsmalloc.c
new file mode 100644
index 0000000..2cde21e
--- /dev/null
+++ b/lib/zsmalloc/zsmalloc.c
@@ -0,0 +1,1064 @@
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
+
+/*
+ * This allocator is designed for use with zcache and zram. Thus, the
+ * allocator is supposed to work well under low memory conditions. In
+ * particular, it never attempts higher order page allocation which is
+ * very likely to fail under memory pressure. On the other hand, if we
+ * just use single (0-order) pages, it would suffer from very high
+ * fragmentation -- any object of size PAGE_SIZE/2 or larger would occupy
+ * an entire page. This was one of the major issues with its predecessor
+ * (xvmalloc).
+ *
+ * To overcome these issues, zsmalloc allocates a bunch of 0-order pages
+ * and links them together using various 'struct page' fields. These linked
+ * pages act as a single higher-order page i.e. an object can span 0-order
+ * page boundaries. The code refers to these linked pages as a single entity
+ * called zspage.
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
+
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
+ * as single (void *) handle value.
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
+#define ZS_SIZE_CLASS_DELTA	16
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
+	const char *name;
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
+/*
+ * By default, zsmalloc uses a copy-based object mapping method to access
+ * allocations that span two pages. However, if a particular architecture
+ * 1) Implements local_flush_tlb_kernel_range() and 2) Performs VM mapping
+ * faster than copying, then it should be added here so that
+ * USE_PGTABLE_MAPPING is defined. This causes zsmalloc to use page table
+ * mapping rather than copying
+ * for object mapping.
+*/
+#if defined(CONFIG_ARM)
+#define USE_PGTABLE_MAPPING
+#endif
+
+struct mapping_area {
+#ifdef USE_PGTABLE_MAPPING
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
+		next = (struct page *)page->private;
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
+	reset_page_mapcount(page);
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
+			first_page->private = (unsigned long)page;
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
+#ifdef USE_PGTABLE_MAPPING
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
+	unsigned long end = addr + (PAGE_SIZE * 2);
+
+	flush_cache_vunmap(addr, end);
+	unmap_kernel_range_noflush(addr, PAGE_SIZE * 2);
+	local_flush_tlb_kernel_range(addr, end);
+}
+
+#else /* USE_PGTABLE_MAPPING */
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
+#endif /* USE_PGTABLE_MAPPING */
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
+static void zs_exit(void)
+{
+	int cpu;
+
+	for_each_online_cpu(cpu)
+		zs_cpu_notifier(NULL, CPU_DEAD, (void *)(long)cpu);
+	unregister_cpu_notifier(&zs_cpu_nb);
+}
+
+static int zs_init(void)
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
+struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
+{
+	int i, ovhd_size;
+	struct zs_pool *pool;
+
+	if (!name)
+		return NULL;
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
+	pool->name = name;
+
+	return pool;
+}
+EXPORT_SYMBOL_GPL(zs_create_pool);
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
+				pr_info("Freeing non-empty class with size "
+					"%db, fullness group %d\n",
+					class->size, fg);
+			}
+		}
+	}
+	kfree(pool);
+}
+EXPORT_SYMBOL_GPL(zs_destroy_pool);
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
+EXPORT_SYMBOL_GPL(zs_malloc);
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
+EXPORT_SYMBOL_GPL(zs_free);
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
+*/
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
+EXPORT_SYMBOL_GPL(zs_map_object);
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
+EXPORT_SYMBOL_GPL(zs_unmap_object);
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
+EXPORT_SYMBOL_GPL(zs_get_total_size_bytes);
+
+module_init(zs_init);
+module_exit(zs_exit);
+
+MODULE_LICENSE("Dual BSD/GPL");
+MODULE_AUTHOR("Nitin Gupta <ngupta@vflare.org>");
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
