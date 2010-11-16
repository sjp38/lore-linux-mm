Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D979A8D0080
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 08:08:31 -0500 (EST)
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 4D3B1F4
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 13:08:04 +0000 (GMT)
Received: from relay2.stm.gmessaging.net (unknown [10.230.100.18])
	by zeta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 693AB791
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 13:08:03 +0000 (GMT)
Received: from exdcvycastm004.EQ1STM.local (alteon-source-exch [10.230.100.61])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(Client CN "exdcvycastm004", Issuer "exdcvycastm004" (not verified))
	by relay2.stm.gmessaging.net (Postfix) with ESMTPS id AC6CEA8094
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 14:07:57 +0100 (CET)
From: Johan Mossberg <johan.xx.mossberg@stericsson.com>
Subject: [PATCH 2/3] hwmem: Add hwmem (part 2)
Date: Tue, 16 Nov 2010 14:08:01 +0100
Message-ID: <1289912882-23996-3-git-send-email-johan.xx.mossberg@stericsson.com>
In-Reply-To: <1289912882-23996-2-git-send-email-johan.xx.mossberg@stericsson.com>
References: <1289912882-23996-1-git-send-email-johan.xx.mossberg@stericsson.com>
 <1289912882-23996-2-git-send-email-johan.xx.mossberg@stericsson.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Johan Mossberg <johan.xx.mossberg@stericsson.com>
List-ID: <linux-mm.kvack.org>

Add hardware memory driver, part 2.

The main purpose of hwmem is:

* To allocate buffers suitable for use with hardware. Currently
this means contiguous buffers.
* To synchronize the caches for the allocated buffers. This is
achieved by keeping track of when the CPU uses a buffer and when
other hardware uses the buffer, when we switch from CPU to other
hardware or vice versa the caches are synchronized.
* To handle sharing of allocated buffers between processes i.e.
import, export.

Hwmem is available both through a user space API and through a
kernel API.

Signed-off-by: Johan Mossberg <johan.xx.mossberg@stericsson.com>
Acked-by: Linus Walleij <linus.walleij@stericsson.com>
---
 drivers/misc/hwmem/cache_handler.c       |  494 ++++++++++++++++++++++++++++++
 drivers/misc/hwmem/cache_handler.h       |   60 ++++
 drivers/misc/hwmem/cache_handler_u8500.c |  208 +++++++++++++
 3 files changed, 762 insertions(+), 0 deletions(-)
 create mode 100644 drivers/misc/hwmem/cache_handler.c
 create mode 100644 drivers/misc/hwmem/cache_handler.h
 create mode 100644 drivers/misc/hwmem/cache_handler_u8500.c

diff --git a/drivers/misc/hwmem/cache_handler.c b/drivers/misc/hwmem/cache_handler.c
new file mode 100644
index 0000000..831770d
--- /dev/null
+++ b/drivers/misc/hwmem/cache_handler.c
@@ -0,0 +1,494 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ *
+ * Cache handler
+ *
+ * Author: Johan Mossberg <johan.xx.mossberg@stericsson.com>
+ * for ST-Ericsson.
+ *
+ * License terms: GNU General Public License (GPL), version 2.
+ */
+
+#include <linux/hwmem.h>
+
+#include <asm/pgtable.h>
+
+#include "cache_handler.h"
+
+#define U32_MAX (~(u32)0)
+
+void cachi_set_buf_cache_settings(struct cach_buf *buf,
+					enum hwmem_alloc_flags cache_settings);
+void cachi_set_pgprot_cache_options(struct cach_buf *buf,
+							pgprot_t *pgprot);
+void cachi_drain_cpu_write_buf(void);
+void cachi_invalidate_cpu_cache(u32 virt_start, u32 virt_end, u32 phys_start,
+		u32 phys_end, bool inner_only, bool *flushed_everything);
+void cachi_clean_cpu_cache(u32 virt_start, u32 virt_end, u32 phys_start,
+		u32 phys_end, bool inner_only, bool *cleaned_everything);
+void cachi_flush_cpu_cache(u32 virt_start, u32 virt_end, u32 phys_start,
+		u32 phys_end, bool inner_only, bool *flushed_everything);
+bool cachi_can_keep_track_of_range_in_cpu_cache(void);
+/* Returns 1 if no cache is present */
+u32 cachi_get_cache_granularity(void);
+
+static void sync_buf_pre_cpu(struct cach_buf *buf, enum hwmem_access access,
+						struct hwmem_region *region);
+static void sync_buf_post_cpu(struct cach_buf *buf,
+	enum hwmem_access next_access, struct hwmem_region *next_region);
+
+static void invalidate_cpu_cache(struct cach_buf *buf,
+					struct cach_range *range_2b_used);
+static void clean_cpu_cache(struct cach_buf *buf,
+					struct cach_range *range_2b_used);
+static void flush_cpu_cache(struct cach_buf *buf,
+					struct cach_range *range_2b_used);
+
+static void null_range(struct cach_range *range);
+static void expand_range(struct cach_range *range,
+					struct cach_range *range_2_add);
+/*
+ * Expands range to one of enclosing_range's two edges. The function will
+ * choose which of enclosing_range's edges to expand range to in such a
+ * way that the size of range is minimized. range must be located inside
+ * enclosing_range.
+ */
+static void expand_range_2_edge(struct cach_range *range,
+					struct cach_range *enclosing_range);
+static void shrink_range(struct cach_range *range,
+					struct cach_range *range_2_remove);
+static bool is_non_empty_range(struct cach_range *range);
+static void intersect_range(struct cach_range *range_1,
+		struct cach_range *range_2, struct cach_range *intersection);
+/* Align_up restrictions apply here to */
+static void align_range_up(struct cach_range *range, u32 alignment);
+static void region_2_range(struct hwmem_region *region, u32 buffer_size,
+						struct cach_range *range);
+
+static u32 offset_2_vaddr(struct cach_buf *buf, u32 offset);
+static u32 offset_2_paddr(struct cach_buf *buf, u32 offset);
+
+/* Saturates, might return unaligned values when that happens */
+static u32 align_up(u32 value, u32 alignment);
+static u32 align_down(u32 value, u32 alignment);
+
+static bool is_wb(enum hwmem_alloc_flags cache_settings);
+static bool is_inner_only(enum hwmem_alloc_flags cache_settings);
+
+/*
+ * Exported functions
+ */
+
+void cach_init_buf(struct cach_buf *buf, enum hwmem_alloc_flags cache_settings,
+					u32 vstart, u32 pstart,	u32 size)
+{
+	bool tmp;
+
+	buf->vstart = vstart;
+	buf->pstart = pstart;
+	buf->size = size;
+
+	cachi_set_buf_cache_settings(buf, cache_settings);
+
+	cachi_flush_cpu_cache(offset_2_vaddr(buf, 0),
+		offset_2_vaddr(buf, buf->size), offset_2_paddr(buf, 0),
+				offset_2_paddr(buf, buf->size), false, &tmp);
+	cachi_drain_cpu_write_buf();
+
+	buf->in_cpu_write_buf = false;
+	if (cachi_can_keep_track_of_range_in_cpu_cache())
+		null_range(&buf->range_in_cpu_cache);
+	else {
+		/* Assume worst case, that the entire alloc is in the cache. */
+		buf->range_in_cpu_cache.start = 0;
+		buf->range_in_cpu_cache.end = buf->size;
+		align_range_up(&buf->range_in_cpu_cache,
+						cachi_get_cache_granularity());
+	}
+	null_range(&buf->range_dirty_in_cpu_cache);
+	null_range(&buf->range_invalid_in_cpu_cache);
+}
+
+void cach_set_pgprot_cache_options(struct cach_buf *buf, pgprot_t *pgprot)
+{
+	cachi_set_pgprot_cache_options(buf, pgprot);
+}
+
+void cach_set_domain(struct cach_buf *buf, enum hwmem_access access,
+			enum hwmem_domain domain, struct hwmem_region *region)
+{
+	struct hwmem_region *__region;
+	struct hwmem_region full_region;
+
+	if (region != NULL)
+		__region = region;
+	else {
+		full_region.offset = 0;
+		full_region.count = 1;
+		full_region.start = 0;
+		full_region.end = buf->size;
+		full_region.size = buf->size;
+
+		__region = &full_region;
+	}
+
+	switch (domain) {
+	case HWMEM_DOMAIN_SYNC:
+		sync_buf_post_cpu(buf, access, __region);
+
+		break;
+
+	case HWMEM_DOMAIN_CPU:
+		sync_buf_pre_cpu(buf, access, __region);
+
+		break;
+	}
+}
+
+/*
+ * Local functions
+ */
+
+void __attribute__((weak)) cachi_set_buf_cache_settings(struct cach_buf *buf,
+					enum hwmem_alloc_flags cache_settings)
+{
+	buf->cache_settings = cache_settings & ~HWMEM_ALLOC_CACHE_HINT_MASK;
+
+	if ((cache_settings & HWMEM_ALLOC_CACHED) == HWMEM_ALLOC_CACHED) {
+		/*
+		 * If the alloc is cached we'll use the default setting. We
+		 * don't know what this setting is so we have to assume the
+		 * worst case, ie write back inner and outer.
+		 */
+		buf->cache_settings |= HWMEM_ALLOC_CACHE_HINT_WB;
+	}
+}
+
+void __attribute__((weak)) cachi_set_pgprot_cache_options(struct cach_buf *buf,
+							pgprot_t *pgprot)
+{
+	if ((buf->cache_settings & HWMEM_ALLOC_CACHED) == HWMEM_ALLOC_CACHED)
+		*pgprot = *pgprot; /* To silence compiler and checkpatch */
+	else if (buf->cache_settings & HWMEM_ALLOC_BUFFERED)
+		*pgprot = pgprot_writecombine(*pgprot);
+	else
+		*pgprot = pgprot_noncached(*pgprot);
+}
+
+bool __attribute__((weak)) cachi_can_keep_track_of_range_in_cpu_cache(void)
+{
+	/* We don't know so we go with the safe alternative */
+	return false;
+}
+
+static void sync_buf_pre_cpu(struct cach_buf *buf, enum hwmem_access access,
+						struct hwmem_region *region)
+{
+	bool write = access & HWMEM_ACCESS_WRITE;
+	bool read = access & HWMEM_ACCESS_READ;
+
+	if (!write && !read)
+		return;
+
+	if ((buf->cache_settings & HWMEM_ALLOC_CACHED) == HWMEM_ALLOC_CACHED) {
+		struct cach_range region_range;
+
+		region_2_range(region, buf->size, &region_range);
+
+		if (read || (write && is_wb(buf->cache_settings)))
+			/* Perform defered invalidates */
+			invalidate_cpu_cache(buf, &region_range);
+		if (read)
+			expand_range(&buf->range_in_cpu_cache, &region_range);
+		if (write && is_wb(buf->cache_settings)) {
+			struct cach_range intersection;
+
+			intersect_range(&buf->range_in_cpu_cache,
+						&region_range, &intersection);
+
+			expand_range(&buf->range_dirty_in_cpu_cache,
+								&intersection);
+		}
+	}
+	if (buf->cache_settings & HWMEM_ALLOC_BUFFERED) {
+		if (write)
+			buf->in_cpu_write_buf = true;
+	}
+}
+
+static void sync_buf_post_cpu(struct cach_buf *buf,
+	enum hwmem_access next_access, struct hwmem_region *next_region)
+{
+	bool write = next_access & HWMEM_ACCESS_WRITE;
+	bool read = next_access & HWMEM_ACCESS_READ;
+	struct cach_range region_range;
+
+	if (!write && !read)
+		return;
+
+	region_2_range(next_region, buf->size, &region_range);
+
+	if (write) {
+		if (cachi_can_keep_track_of_range_in_cpu_cache())
+			flush_cpu_cache(buf, &region_range);
+		else { /* Defer invalidate */
+			struct cach_range intersection;
+
+			intersect_range(&buf->range_in_cpu_cache,
+						&region_range, &intersection);
+
+			expand_range(&buf->range_invalid_in_cpu_cache,
+								&intersection);
+
+			clean_cpu_cache(buf, &region_range);
+		}
+	}
+	if (read)
+		clean_cpu_cache(buf, &region_range);
+
+	if (buf->in_cpu_write_buf) {
+		cachi_drain_cpu_write_buf();
+
+		buf->in_cpu_write_buf = false;
+	}
+}
+
+static void invalidate_cpu_cache(struct cach_buf *buf, struct cach_range *range)
+{
+	struct cach_range intersection;
+
+	intersect_range(&buf->range_invalid_in_cpu_cache, range,
+								&intersection);
+	if (is_non_empty_range(&intersection)) {
+		bool flushed_everything;
+
+		expand_range_2_edge(&intersection,
+					&buf->range_invalid_in_cpu_cache);
+
+		cachi_invalidate_cpu_cache(
+				offset_2_vaddr(buf, intersection.start),
+				offset_2_vaddr(buf, intersection.end),
+				offset_2_paddr(buf, intersection.start),
+				offset_2_paddr(buf, intersection.end),
+				is_inner_only(buf->cache_settings),
+							&flushed_everything);
+
+		if (flushed_everything) {
+			null_range(&buf->range_invalid_in_cpu_cache);
+			null_range(&buf->range_dirty_in_cpu_cache);
+		} else
+			/*
+			 * No need to shrink range_in_cpu_cache as invalidate
+			 * is only used when we can't keep track of what's in
+			 * the CPU cache.
+			 */
+			shrink_range(&buf->range_invalid_in_cpu_cache,
+								&intersection);
+	}
+}
+
+static void clean_cpu_cache(struct cach_buf *buf, struct cach_range *range)
+{
+	struct cach_range intersection;
+
+	intersect_range(&buf->range_dirty_in_cpu_cache, range, &intersection);
+	if (is_non_empty_range(&intersection)) {
+		bool cleaned_everything;
+
+		expand_range_2_edge(&intersection,
+					&buf->range_dirty_in_cpu_cache);
+
+		cachi_clean_cpu_cache(
+				offset_2_vaddr(buf, intersection.start),
+				offset_2_vaddr(buf, intersection.end),
+				offset_2_paddr(buf, intersection.start),
+				offset_2_paddr(buf, intersection.end),
+				is_inner_only(buf->cache_settings),
+							&cleaned_everything);
+
+		if (cleaned_everything)
+			null_range(&buf->range_dirty_in_cpu_cache);
+		else
+			shrink_range(&buf->range_dirty_in_cpu_cache,
+								&intersection);
+	}
+}
+
+static void flush_cpu_cache(struct cach_buf *buf, struct cach_range *range)
+{
+	struct cach_range intersection;
+
+	intersect_range(&buf->range_in_cpu_cache, range, &intersection);
+	if (is_non_empty_range(&intersection)) {
+		bool flushed_everything;
+
+		expand_range_2_edge(&intersection, &buf->range_in_cpu_cache);
+
+		cachi_flush_cpu_cache(
+				offset_2_vaddr(buf, intersection.start),
+				offset_2_vaddr(buf, intersection.end),
+				offset_2_paddr(buf, intersection.start),
+				offset_2_paddr(buf, intersection.end),
+				is_inner_only(buf->cache_settings),
+							&flushed_everything);
+
+		if (flushed_everything) {
+			if (cachi_can_keep_track_of_range_in_cpu_cache())
+				null_range(&buf->range_in_cpu_cache);
+			null_range(&buf->range_dirty_in_cpu_cache);
+			null_range(&buf->range_invalid_in_cpu_cache);
+		} else {
+			if (cachi_can_keep_track_of_range_in_cpu_cache())
+				shrink_range(&buf->range_in_cpu_cache,
+							 &intersection);
+			shrink_range(&buf->range_dirty_in_cpu_cache,
+								&intersection);
+			shrink_range(&buf->range_invalid_in_cpu_cache,
+								&intersection);
+		}
+	}
+}
+
+static void null_range(struct cach_range *range)
+{
+	range->start = U32_MAX;
+	range->end = 0;
+}
+
+static void expand_range(struct cach_range *range,
+						struct cach_range *range_2_add)
+{
+	range->start = min(range->start, range_2_add->start);
+	range->end = max(range->end, range_2_add->end);
+}
+
+/*
+ * Expands range to one of enclosing_range's two edges. The function will
+ * choose which of enclosing_range's edges to expand range to in such a
+ * way that the size of range is minimized. range must be located inside
+ * enclosing_range.
+ */
+static void expand_range_2_edge(struct cach_range *range,
+					struct cach_range *enclosing_range)
+{
+	u32 space_on_low_side = range->start - enclosing_range->start;
+	u32 space_on_high_side = enclosing_range->end - range->end;
+
+	if (space_on_low_side < space_on_high_side)
+		range->start = enclosing_range->start;
+	else
+		range->end = enclosing_range->end;
+}
+
+static void shrink_range(struct cach_range *range,
+					struct cach_range *range_2_remove)
+{
+	if (range_2_remove->start > range->start)
+		range->end = min(range->end, range_2_remove->start);
+	else
+		range->start = max(range->start, range_2_remove->end);
+
+	if (range->start >= range->end)
+		null_range(range);
+}
+
+static bool is_non_empty_range(struct cach_range *range)
+{
+	return range->end > range->start;
+}
+
+static void intersect_range(struct cach_range *range_1,
+		struct cach_range *range_2, struct cach_range *intersection)
+{
+	intersection->start = max(range_1->start, range_2->start);
+	intersection->end = min(range_1->end, range_2->end);
+
+	if (intersection->start >= intersection->end)
+		null_range(intersection);
+}
+
+/* Align_up restrictions apply here to */
+static void align_range_up(struct cach_range *range, u32 alignment)
+{
+	if (!is_non_empty_range(range))
+		return;
+
+	range->start = align_down(range->start, alignment);
+	range->end = align_up(range->end, alignment);
+}
+
+static void region_2_range(struct hwmem_region *region, u32 buffer_size,
+						struct cach_range *range)
+{
+	/*
+	 * We don't care about invalid regions, instead we limit the region's
+	 * range to the buffer's range. This should work good enough, worst
+	 * case we synch the entire buffer when we get an invalid region which
+	 * is acceptable.
+	 */
+	range->start = region->offset + region->start;
+	range->end = min(region->offset + (region->count * region->size) -
+				(region->size - region->end), buffer_size);
+	if (range->start >= range->end) {
+		null_range(range);
+		return;
+	}
+
+	align_range_up(range, cachi_get_cache_granularity());
+}
+
+static u32 offset_2_vaddr(struct cach_buf *buf, u32 offset)
+{
+	return buf->vstart + offset;
+}
+
+static u32 offset_2_paddr(struct cach_buf *buf, u32 offset)
+{
+	return buf->pstart + offset;
+}
+
+/* Saturates, might return unaligned values when that happens */
+static u32 align_up(u32 value, u32 alignment)
+{
+	u32 remainder = value % alignment;
+	u32 value_2_add;
+
+	if (remainder == 0)
+		return value;
+
+	value_2_add = alignment - remainder;
+
+	if (value_2_add > U32_MAX - value) /* Will overflow */
+		return U32_MAX;
+
+	return value + value_2_add;
+}
+
+static u32 align_down(u32 value, u32 alignment)
+{
+	u32 remainder = value % alignment;
+	if (remainder == 0)
+		return value;
+
+	return value - remainder;
+}
+
+static bool is_wb(enum hwmem_alloc_flags cache_settings)
+{
+	u32 cache_hints = cache_settings & HWMEM_ALLOC_CACHE_HINT_MASK;
+	if (cache_hints == HWMEM_ALLOC_CACHE_HINT_WB ||
+		cache_hints == HWMEM_ALLOC_CACHE_HINT_WB_INNER)
+		return true;
+	else
+		return false;
+}
+
+static bool is_inner_only(enum hwmem_alloc_flags cache_settings)
+{
+	u32 cache_hints = cache_settings & HWMEM_ALLOC_CACHE_HINT_MASK;
+	if (cache_hints == HWMEM_ALLOC_CACHE_HINT_WT_INNER ||
+		cache_hints == HWMEM_ALLOC_CACHE_HINT_WB_INNER)
+		return true;
+	else
+		return false;
+}
diff --git a/drivers/misc/hwmem/cache_handler.h b/drivers/misc/hwmem/cache_handler.h
new file mode 100644
index 0000000..3c2a71f
--- /dev/null
+++ b/drivers/misc/hwmem/cache_handler.h
@@ -0,0 +1,60 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ *
+ * Cache handler
+ *
+ * Author: Johan Mossberg <johan.xx.mossberg@stericsson.com>
+ * for ST-Ericsson.
+ *
+ * License terms: GNU General Public License (GPL), version 2.
+ */
+
+/*
+ * Cache handler can not handle simultaneous execution! The caller has to
+ * ensure such a situation does not occur.
+ */
+
+#ifndef _CACHE_HANDLER_H_
+#define _CACHE_HANDLER_H_
+
+#include <linux/types.h>
+#include <linux/hwmem.h>
+
+/*
+ * To not have to double all datatypes we've used hwmem datatypes. If someone
+ * want's to use cache handler but not hwmem then we'll have to define our own
+ * datatypes.
+ */
+
+struct cach_range {
+	u32 start; /* Inclusive */
+	u32 end; /* Exclusive */
+};
+
+/*
+ * Internal, do not touch!
+ */
+struct cach_buf {
+	u32 vstart;
+	u32 pstart;
+	u32 size;
+
+	/* Remaining hints are active */
+	enum hwmem_alloc_flags cache_settings;
+
+	bool in_cpu_write_buf;
+	struct cach_range range_in_cpu_cache;
+	struct cach_range range_dirty_in_cpu_cache;
+	struct cach_range range_invalid_in_cpu_cache;
+};
+
+void cach_init_buf(struct cach_buf *buf,
+	enum hwmem_alloc_flags cache_settings, u32 vstart, u32 pstart,
+								u32 size);
+
+void cach_set_pgprot_cache_options(struct cach_buf *buf, pgprot_t *pgprot);
+
+void cach_set_domain(struct cach_buf *buf, enum hwmem_access access,
+			enum hwmem_domain domain, struct hwmem_region *region);
+
+#endif /* _CACHE_HANDLER_H_ */
diff --git a/drivers/misc/hwmem/cache_handler_u8500.c b/drivers/misc/hwmem/cache_handler_u8500.c
new file mode 100644
index 0000000..3c1bc5a
--- /dev/null
+++ b/drivers/misc/hwmem/cache_handler_u8500.c
@@ -0,0 +1,208 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ *
+ * Cache handler
+ *
+ * Author: Johan Mossberg <johan.xx.mossberg@stericsson.com>
+ * for ST-Ericsson.
+ *
+ * License terms: GNU General Public License (GPL), version 2.
+ */
+
+/* TODO: Move all this stuff to mach */
+
+#include <linux/hwmem.h>
+#include <linux/dma-mapping.h>
+
+#include <asm/pgtable.h>
+#include <asm/cacheflush.h>
+#include <asm/outercache.h>
+#include <asm/system.h>
+
+#include "cache_handler.h"
+
+/*
+ * Values are derived from measurements on HREFP_1.1_V32_OM_S10 running
+ * u8500-android-2.2_r1.1_v0.21.
+ *
+ * A lot of time can be spent trying to figure out the perfect breakpoints but
+ * for now I've chosen the following simple way.
+ *
+ * breakpoint = best_case + (worst_case - best_case) * 0.666
+ * The breakpoint is moved slightly towards the worst case because a full
+ * clean/flush affects the entire system so we should be a bit careful.
+ *
+ * BEST CASE:
+ * Best case is that the cache is empty and the system is idling. The case
+ * where the cache contains only targeted data could be better in some cases
+ * but it's hard to do measurements and calculate on that case so I choose the
+ * easier alternative.
+ *
+ * inner_inv_breakpoint = time_2_range_inv_on_empty_cache(
+ *					complete_flush_on_empty_cache_time)
+ * inner_clean_breakpoint = time_2_range_clean_on_empty_cache(
+ *					complete_clean_on_empty_cache_time)
+ *
+ * outer_inv_breakpoint = time_2_range_inv_on_empty_cache(
+ *					complete_flush_on_empty_cache_time)
+ * outer_clean_breakpoint = time_2_range_clean_on_empty_cache(
+ *					complete_clean_on_empty_cache_time)
+ * outer_flush_breakpoint = time_2_range_flush_on_empty_cache(
+ *					complete_flush_on_empty_cache_time)
+ *
+ * WORST CASE:
+ * Worst case is that the cache is filled with dirty non targeted data that
+ * will be used after the synchronization and the system is under heavy load.
+ *
+ * inner_inv_breakpoint = time_2_range_inv_on_empty_cache(
+ *				complete_flush_on_full_cache_time * 1.5 +
+ *					complete_flush_on_full_cache_time / 2)
+ * Times 1.5 because it runs on both cores half the time. Plus
+ * "complete_flush_on_full_cache_time / 2" because all data has to be read
+ * back, here we assume that both cores can fill their cache simultaneously
+ * (seems to be the case as operations on full and empty inner cache takes
+ * roughlythe same amount of time ie the bus to outer is not the bottle neck).
+ * inner_clean_breakpoint = time_2_range_clean_on_empty_cache(
+ *				complete_clean_on_full_cache_time * 1.5)
+ *
+ * outer_inv_breakpoint = time_2_range_inv_on_empty_cache(
+ *					complete_flush_on_full_cache_time * 2 +
+ *					(complete_flush_on_full_cache_time -
+ *				complete_flush_on_empty_cache_time) * 2)
+ * Plus "(complete_flush_on_full_cache_time -
+ * complete_flush_on_empty_cache_time)" because no one else can work when we
+ * hog the bus with our unecessary transfer.
+ * outer_clean_breakpoint = time_2_range_clean_on_empty_cache(
+ *					complete_clean_on_full_cache_time +
+ *					(complete_clean_on_full_cache_time -
+ *					complete_clean_on_empty_cache_time))
+ * outer_flush_breakpoint = time_2_range_flush_on_empty_cache(
+ *					complete_flush_on_full_cache_time * 2 +
+ *					(complete_flush_on_full_cache_time -
+ *				complete_flush_on_empty_cache_time) * 2)
+ *
+ * These values might have to be updated if changes are made to the CPU, L2$,
+ * memory bus or memory.
+ */
+/* 36224 */
+static const u32 inner_inv_breakpoint =	21324 + (43697 - 21324) * 0.666;
+/* 28930 */
+static const u32 inner_clean_breakpoint = 21324 + (32744 - 21324) * 0.666;
+/* 485414 */
+static const u32 outer_inv_breakpoint = 68041 + (694727 - 68041) * 0.666;
+/* 254069 */
+static const u32 outer_clean_breakpoint = 68041 + (347363 - 68041) * 0.666;
+/* 485414 */
+static const u32 outer_flush_breakpoint = 68041 + (694727 - 68041) * 0.666;
+
+static bool is_wt(enum hwmem_alloc_flags cache_settings);
+
+void cachi_set_buf_cache_settings(struct cach_buf *buf,
+					enum hwmem_alloc_flags cache_settings)
+{
+	buf->cache_settings = cache_settings & ~HWMEM_ALLOC_CACHE_HINT_MASK;
+
+	if ((cache_settings & HWMEM_ALLOC_CACHED) == HWMEM_ALLOC_CACHED) {
+		if (is_wt(cache_settings))
+			buf->cache_settings |= HWMEM_ALLOC_CACHE_HINT_WT;
+		else
+			buf->cache_settings |= HWMEM_ALLOC_CACHE_HINT_WB;
+	}
+}
+
+void cachi_set_pgprot_cache_options(struct cach_buf *buf, pgprot_t *pgprot)
+{
+	if ((buf->cache_settings & HWMEM_ALLOC_CACHED) == HWMEM_ALLOC_CACHED) {
+		if (is_wt(buf->cache_settings))
+			*pgprot = __pgprot_modify(*pgprot, L_PTE_MT_MASK,
+							L_PTE_MT_WRITETHROUGH);
+		else
+			*pgprot = __pgprot_modify(*pgprot, L_PTE_MT_MASK,
+							L_PTE_MT_WRITEBACK);
+	} else if (buf->cache_settings & HWMEM_ALLOC_BUFFERED)
+		*pgprot = pgprot_writecombine(*pgprot);
+	else
+		*pgprot = pgprot_noncached(*pgprot);
+}
+
+void cachi_drain_cpu_write_buf(void)
+{
+	dsb();
+	outer_cache.sync();
+}
+
+void cachi_invalidate_cpu_cache(u32 virt_start, u32 virt_end, u32 phys_start,
+		u32 phys_end, bool inner_only, bool *flushed_everything)
+{
+	u32 range_size = virt_end - virt_start;
+
+	*flushed_everything = false;
+
+	if (range_size < outer_inv_breakpoint)
+		outer_cache.inv_range(phys_start, phys_end);
+	else
+		outer_cache.flush_all();
+
+	/* Inner invalidate range */
+	dmac_map_area((void *)virt_start, range_size, DMA_FROM_DEVICE);
+}
+
+void cachi_clean_cpu_cache(u32 virt_start, u32 virt_end, u32 phys_start,
+		u32 phys_end, bool inner_only, bool *cleaned_everything)
+{
+	u32 range_size = virt_end - virt_start;
+
+	*cleaned_everything = false;
+
+	/* Inner clean range */
+	dmac_map_area((void *)virt_start, range_size, DMA_TO_DEVICE);
+
+	/*
+	 * There is currently no outer_cache.clean_all() so we use flush
+	 * instead, which is ok as clean is a subset of flush. Clean range
+	 * and flush range take the same amount of time so we can use
+	 * outer_flush_breakpoint here.
+	 */
+	if (range_size < outer_flush_breakpoint)
+		outer_cache.clean_range(phys_start, phys_end);
+	else
+		outer_cache.flush_all();
+}
+
+void cachi_flush_cpu_cache(u32 virt_start, u32 virt_end, u32 phys_start,
+		u32 phys_end, bool inner_only, bool *flushed_everything)
+{
+	u32 range_size = virt_end - virt_start;
+
+	*flushed_everything = false;
+
+	/* Inner clean range */
+	dmac_map_area((void *)virt_start, range_size, DMA_TO_DEVICE);
+
+	if (range_size < outer_flush_breakpoint)
+		outer_cache.flush_range(phys_start, phys_end);
+	else
+		outer_cache.flush_all();
+
+	/* Inner invalidate range */
+	dmac_map_area((void *)virt_start, range_size, DMA_FROM_DEVICE);
+}
+
+u32 cachi_get_cache_granularity(void)
+{
+	return 32;
+}
+
+/*
+ * Local functions
+ */
+
+static bool is_wt(enum hwmem_alloc_flags cache_settings)
+{
+	u32 cache_hints = cache_settings & HWMEM_ALLOC_CACHE_HINT_MASK;
+	if (cache_hints == HWMEM_ALLOC_CACHE_HINT_WT ||
+		cache_hints == HWMEM_ALLOC_CACHE_HINT_WT_INNER)
+		return true;
+	else
+		return false;
+}
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
