Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E557E8D0047
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 09:16:18 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from spt2.w1.samsung.com ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LIX006AHBIYFT50@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 31 Mar 2011 14:16:12 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LIX00AJCBIYHW@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 31 Mar 2011 14:16:11 +0100 (BST)
Date: Thu, 31 Mar 2011 15:16:06 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 10/12] mm: cma: add CMA 'regions style' API (for testing)
In-reply-to: <1301577368-16095-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1301577368-16095-11-git-send-email-m.szyprowski@samsung.com>
References: <1301577368-16095-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-samsung-soc@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, Mel Gorman <mel@csn.ul.ie>, Pawel Osciak <pawel@osciak.com>

This patch adds CMA 'regions style' API (almost compatible with CMA v1).
It is intended mainly for testing the real contigous memory allocator
and page migration with devices that use older CMA api.

Based on previous works by Michal Nazarewicz.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
CC: Michal Nazarewicz <mina86@mina86.com>
---
 include/linux/cma-regions.h |  340 +++++++++++++++++++
 include/linux/cma.h         |    3 +
 mm/Makefile                 |    2 +-
 mm/cma-regions.c            |  759 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 1103 insertions(+), 1 deletions(-)
 create mode 100644 include/linux/cma-regions.h
 create mode 100644 mm/cma-regions.c

diff --git a/include/linux/cma-regions.h b/include/linux/cma-regions.h
new file mode 100644
index 0000000..f3a2f4d
--- /dev/null
+++ b/include/linux/cma-regions.h
@@ -0,0 +1,340 @@
+#ifndef __LINUX_CMA_REGIONS_H
+#define __LINUX_CMA_REGIONS_H
+
+/*
+ * Contiguous Memory Allocator framework - memory region management
+ * Copyright (c) 2010-2011 by Samsung Electronics.
+ * Written by Michal Nazarewicz (m.nazarewicz@samsung.com)
+ * Updated by Marek Szyprowski (m.szyprowski@samsung.com)
+ */
+
+/*
+ * See Documentation/contiguous-memory.txt for details.
+ */
+
+#include <linux/ioctl.h>
+#include <linux/types.h>
+#include <linux/err.h>
+#include <linux/init.h>
+
+/***************************** Kernel level API *****************************/
+
+#include <linux/rbtree.h>
+#include <linux/list.h>
+
+
+struct device;
+struct cma_info;
+struct cm;
+
+/*
+ * Don't call it directly, use cma_alloc(), cma_alloc_from() or
+ * cma_alloc_from_region().
+ */
+struct cm * __must_check
+__cma_alloc(const struct device *dev, const char *type,
+	    size_t size, dma_addr_t alignment);
+
+/* Don't call it directly, use cma_info() or cma_info_about(). */
+int
+__cma_info(struct cma_info *info, const struct device *dev, const char *type);
+
+
+/**
+ * cma_alloc - allocates contiguous chunk of memory.
+ * @dev:	The device to perform allocation for.
+ * @type:	A type of memory to allocate.  Platform may define
+ *		several different types of memory and device drivers
+ *		can then request chunks of different types.  Usually it's
+ *		safe to pass NULL here which is the same as passing
+ *		"common".
+ * @size:	Size of the memory to allocate in bytes.
+ * @alignment:	Desired alignment in bytes.  Must be a power of two or
+ *		zero.  If alignment is less then a page size it will be
+ *		set to page size. If unsure, pass zero here.
+ *
+ * On error returns a negative error cast to dma_addr_t.  Use
+ * IS_ERR_VALUE() to check if returned value is indeed an error.
+ * Otherwise bus address of the chunk is returned.
+ */
+static inline struct cm * __must_check
+cma_alloc(const struct device *dev, const char *type,
+	  size_t size, dma_addr_t alignment)
+{
+	return dev ? __cma_alloc(dev, type, size, alignment) : ERR_PTR(-EINVAL);
+}
+
+
+/**
+ * struct cma_info - information about regions returned by cma_info().
+ * @lower_bound:	The smallest address that is possible to be
+ *			allocated for given (dev, type) pair.
+ * @upper_bound:	The one byte after the biggest address that is
+ *			possible to be allocated for given (dev, type)
+ *			pair.
+ * @total_size:	Total size of regions mapped to (dev, type) pair.
+ * @free_size:	Total free size in all of the regions mapped to (dev, type)
+ *		pair.  Because of possible race conditions, it is not
+ *		guaranteed that the value will be correct -- it gives only
+ *		an approximation.
+ * @count:	Number of regions mapped to (dev, type) pair.
+ */
+struct cma_info {
+	dma_addr_t lower_bound, upper_bound;
+	size_t total_size, free_size;
+	unsigned count;
+};
+
+/**
+ * cma_info - queries information about regions.
+ * @info:	Pointer to a structure where to save the information.
+ * @dev:	The device to query information for.
+ * @type:	A type of memory to query information for.
+ *		If unsure, pass NULL here which is equal to passing
+ *		"common".
+ *
+ * On error returns a negative error, zero otherwise.
+ */
+static inline int
+cma_info(struct cma_info *info, const struct device *dev, const char *type)
+{
+	return dev ? __cma_info(info, dev, type) : -EINVAL;
+}
+
+
+/**
+ * cma_free - frees a chunk of memory.
+ * @addr:	Beginning of the chunk.
+ *
+ * Returns -ENOENT if there is no chunk at given location; otherwise
+ * zero.  In the former case issues a warning.
+ */
+int cma_free(struct cm *addr);
+
+
+
+/****************************** Lower lever API *****************************/
+
+/**
+ * cma_alloc_from - allocates contiguous chunk of memory from named regions.
+ * @regions:	Comma separated list of region names.  Terminated by NUL
+ *		byte or a semicolon.
+ * @size:	Size of the memory to allocate in bytes.
+ * @alignment:	Desired alignment in bytes.  Must be a power of two or
+ *		zero.  If alignment is less then a page size it will be
+ *		set to page size. If unsure, pass zero here.
+ *
+ * On error returns a negative error cast to dma_addr_t.  Use
+ * IS_ERR_VALUE() to check if returned value is indeed an error.
+ * Otherwise bus address of the chunk is returned.
+ */
+static inline struct cm * __must_check
+cma_alloc_from(const char *regions, size_t size, dma_addr_t alignment)
+{
+	return __cma_alloc(NULL, regions, size, alignment);
+}
+
+/**
+ * cma_info_about - queries information about named regions.
+ * @info:	Pointer to a structure where to save the information.
+ * @regions:	Comma separated list of region names.  Terminated by NUL
+ *		byte or a semicolon.
+ *
+ * On error returns a negative error, zero otherwise.
+ */
+static inline int
+cma_info_about(struct cma_info *info, const const char *regions)
+{
+	return __cma_info(info, NULL, regions);
+}
+
+
+/**
+ * struct cma_region - a region reserved for CMA allocations.
+ * @name:	Unique name of the region.  Read only.
+ * @start:	Bus address of the region in bytes.  Always aligned at
+ *		least to a full page.  Read only.
+ * @size:	Size of the region in bytes.  Multiply of a page size.
+ *		Read only.
+ * @alignment:	Desired alignment of the region in bytes.  A power of two,
+ *		always at least page size.  Early.
+ * @cma:	Low level memory are registered to kernel mm subsystem.
+ *		Private.
+ * @list:	Entry in list of regions.  Private.
+ * @used:	Whether region was already used, ie. there was at least
+ *		one allocation request for.  Private.
+ * @registered:	Whether this region has been registered.  Read only.
+ * @reserved:	Whether this region has been reserved.  Early.  Read only.
+ * @copy_name:	Whether @name needs to be copied when this region is
+ *		converted from early to normal.  Early.  Private.
+ *
+ * Regions come in two types: an early region and normal region.  The
+ * former can be reserved or not-reserved.  Fields marked as "early"
+ * are only meaningful in early regions.
+ *
+ * Early regions are important only during initialisation.  The list
+ * of early regions is built from the "cma" command line argument or
+ * platform defaults.  Platform initialisation code is responsible for
+ * reserving space for unreserved regions that are placed on
+ * cma_early_regions list.
+ *
+ * Later, during CMA initialisation all reserved regions from the
+ * cma_early_regions list are registered as normal regions and can be
+ * used using standard mechanisms.
+ */
+struct cma_region {
+	const char *name;
+	dma_addr_t start;
+	size_t size;
+	dma_addr_t alignment;	/* Early region */
+
+	struct cma *cma;
+	struct list_head list;
+
+	unsigned used:1;
+	unsigned registered:1;
+	unsigned reserved:1;
+	unsigned copy_name:1;
+};
+
+
+/**
+ * cma_region_register() - registers a region.
+ * @reg:	Region to region.
+ *
+ * Region's start and size must be set.
+ *
+ * If name is set the region will be accessible using normal mechanism
+ * like mapping or cma_alloc_from() function otherwise it will be
+ * a private region and accessible only using the
+ * cma_alloc_from_region() function.
+ *
+ * If alloc is set function will try to initialise given allocator
+ * (and will return error if it failes).  Otherwise alloc_name may
+ * point to a name of an allocator to use (if not set, the default
+ * will be used).
+ *
+ * All other fields are ignored and/or overwritten.
+ *
+ * Returns zero or negative error.  In particular, -EADDRINUSE if
+ * region overlap with already existing region.
+ */
+int __must_check cma_region_register(struct cma_region *reg);
+
+/**
+ * cma_region_unregister() - unregisters a region.
+ * @reg:	Region to unregister.
+ *
+ * Region is unregistered only if there are no chunks allocated for
+ * it.  Otherwise, function returns -EBUSY.
+ *
+ * On success returs zero.
+ */
+int __must_check cma_region_unregister(struct cma_region *reg);
+
+
+/**
+ * cma_alloc_from_region() - allocates contiguous chunk of memory from region.
+ * @reg:	Region to allocate chunk from.
+ * @size:	Size of the memory to allocate in bytes.
+ * @alignment:	Desired alignment in bytes.  Must be a power of two or
+ *		zero.  If alignment is less then a page size it will be
+ *		set to page size. If unsure, pass zero here.
+ *
+ * On error returns a negative error cast to dma_addr_t.  Use
+ * IS_ERR_VALUE() to check if returned value is indeed an error.
+ * Otherwise bus address of the chunk is returned.
+ */
+struct cm * __must_check
+cma_alloc_from_region(struct cma_region *reg,
+		      size_t size, dma_addr_t alignment);
+
+
+/**************************** Initialisation API ****************************/
+
+/**
+ * cma_set_defaults() - specifies default command line parameters.
+ * @regions:	A zero-sized entry terminated list of early regions.
+ *		This array must not be placed in __initdata section.
+ * @map:	Map attribute.
+ *
+ * This function should be called prior to cma_early_regions_reserve()
+ * and after early parameters have been parsed.
+ *
+ * Returns zero or negative error.
+ */
+int __init cma_set_defaults(struct cma_region *regions, const char *map);
+
+
+/**
+ * cma_early_regions - a list of early regions.
+ *
+ * Platform needs to allocate space for each of the region before
+ * initcalls are executed.  If space is reserved, the reserved flag
+ * must be set.  Platform initialisation code may choose to use
+ * cma_early_regions_allocate().
+ *
+ * Later, during CMA initialisation all reserved regions from the
+ * cma_early_regions list are registered as normal regions and can be
+ * used using standard mechanisms.
+ */
+extern struct list_head cma_early_regions __initdata;
+
+
+/**
+ * cma_early_region_register() - registers an early region.
+ * @reg:	Region to add.
+ *
+ * Region's size, start and alignment must be set (however the last
+ * two can be zero).  If name is set the region will be accessible
+ * using normal mechanism like mapping or cma_alloc_from() function
+ * otherwise it will be a private region accessible only using the
+ * cma_alloc_from_region().
+ *
+ * During platform initialisation, space is reserved for early
+ * regions.  Later, when CMA initialises, the early regions are
+ * "converted" into normal regions.  If cma_region::alloc is set, CMA
+ * will then try to setup given allocator on the region.  Failure to
+ * do so will result in the region not being registered even though
+ * the space for it will still be reserved.  If cma_region::alloc is
+ * not set, allocator will be attached to the region on first use and
+ * the value of cma_region::alloc_name will be taken into account if
+ * set.
+ *
+ * All other fields are ignored and/or overwritten.
+ *
+ * Returns zero or negative error.  No checking if regions overlap is
+ * performed.
+ */
+int __init __must_check cma_early_region_register(struct cma_region *reg);
+
+
+/**
+ * cma_early_region_reserve() - reserves a physically contiguous memory region.
+ * @reg:	Early region to reserve memory for.
+ *
+ * If platform supports bootmem this is the first allocator this
+ * function tries to use.  If that failes (or bootmem is not
+ * supported) function tries to use memblec if it is available.
+ *
+ * On success sets reg->reserved flag.
+ *
+ * Returns zero or negative error.
+ */
+int __init cma_early_region_reserve(struct cma_region *reg);
+
+/**
+ * cma_early_regions_reserve() - helper function for reserving early regions.
+ * @reserve:	Callbac function used to reserve space for region.  Needs
+ *		to return non-negative if allocation succeeded, negative
+ *		error otherwise.  NULL means cma_early_region_alloc() will
+ *		be used.
+ *
+ * This function traverses the %cma_early_regions list and tries to
+ * reserve memory for each early region.  It uses the @reserve
+ * callback function for that purpose.  The reserved flag of each
+ * region is updated accordingly.
+ */
+void __init cma_early_regions_reserve(int (*reserve)(struct cma_region *reg));
+
+#endif
diff --git a/include/linux/cma.h b/include/linux/cma.h
index 8952531..755f22e 100644
--- a/include/linux/cma.h
+++ b/include/linux/cma.h
@@ -1,3 +1,4 @@
+
 #ifndef __LINUX_CMA_H
 #define __LINUX_CMA_H
 
@@ -258,4 +259,6 @@ void cm_vunmap(struct cm *cm);
 
 #endif
 
+#include <linux/cma-regions.h>
+
 #endif
diff --git a/mm/Makefile b/mm/Makefile
index 01c3b20..33de730 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -49,4 +49,4 @@ obj-$(CONFIG_MEMORY_FAILURE) += memory-failure.o
 obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
 obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
 obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
-obj-$(CONFIG_CMA) += cma.o
+obj-$(CONFIG_CMA) += cma.o cma-regions.o
diff --git a/mm/cma-regions.c b/mm/cma-regions.c
new file mode 100644
index 0000000..f37f58b
--- /dev/null
+++ b/mm/cma-regions.c
@@ -0,0 +1,759 @@
+/*
+ * Contiguous Memory Allocator framework - memory region management
+ * Copyright (c) 2010-2011 by Samsung Electronics.
+ * Written by Michal Nazarewicz (m.nazarewicz@samsung.com)
+ * Updated by Marek Szyprowski (m.szyprowski@samsung.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of the
+ * License or (at your optional) any later version of the license.
+ */
+
+/*
+ * See Documentation/contiguous-memory.txt for details.
+ */
+
+#define pr_fmt(fmt) "cma: " fmt
+
+#ifdef CONFIG_CMA_DEBUG
+#  define DEBUG
+#endif
+
+#include <linux/device.h>      /* struct device, dev_name() */
+#include <linux/errno.h>       /* Error numbers */
+#include <linux/err.h>         /* IS_ERR, PTR_ERR, etc. */
+#include <linux/mm.h>          /* PAGE_ALIGN() */
+#include <linux/module.h>      /* EXPORT_SYMBOL_GPL() */
+#include <linux/mutex.h>       /* mutex */
+#include <linux/slab.h>        /* kmalloc() */
+#include <linux/string.h>      /* str*() */
+
+#include <linux/cma.h>
+
+/*
+ * Protects cma_regions, cma_map, cma_map_length.
+ */
+static DEFINE_MUTEX(cma_mutex);
+
+
+/************************* Map attribute *************************/
+
+static const char *cma_map;
+static size_t cma_map_length;
+
+/*
+ * map-attr      ::= [ rules [ ';' ] ]
+ * rules         ::= rule [ ';' rules ]
+ * rule          ::= patterns '=' regions
+ * patterns      ::= pattern [ ',' patterns ]
+ * regions       ::= REG-NAME [ ',' regions ]
+ * pattern       ::= dev-pattern [ '/' TYPE-NAME ] | '/' TYPE-NAME
+ *
+ * See Documentation/contiguous-memory.txt for details.
+ */
+static ssize_t cma_map_validate(const char *param)
+{
+	const char *ch = param;
+
+	if (*ch == '\0' || *ch == '\n')
+		return 0;
+
+	for (;;) {
+		const char *start = ch;
+
+		while (*ch && *ch != '\n' && *ch != ';' && *ch != '=')
+			++ch;
+
+		if (*ch != '=' || start == ch) {
+			pr_err("map: expecting \"<patterns>=<regions>\" near %s\n",
+			       start);
+			return -EINVAL;
+		}
+
+		while (*++ch != ';')
+			if (*ch == '\0' || *ch == '\n')
+				return ch - param;
+		if (ch[1] == '\0' || ch[1] == '\n')
+			return ch - param;
+		++ch;
+	}
+}
+
+static int __init cma_map_param(char *param)
+{
+	ssize_t len;
+
+	pr_debug("param: map: %s\n", param);
+
+	len = cma_map_validate(param);
+	if (len < 0)
+		return len;
+
+	cma_map = param;
+	cma_map_length = len;
+	return 0;
+}
+
+#if defined CONFIG_CMA_CMDLINE
+
+early_param("cma.map", cma_map_param);
+
+#endif
+
+
+
+/************************* Early regions *************************/
+
+struct list_head cma_early_regions __initdata =
+	LIST_HEAD_INIT(cma_early_regions);
+
+#ifdef CONFIG_CMA_CMDLINE
+
+/*
+ * regions-attr ::= [ regions [ ';' ] ]
+ * regions      ::= region [ ';' regions ]
+ *
+ * region       ::= [ '-' ] reg-name
+ *                    '=' size
+ *                  [ '@' start ]
+ *                  [ '/' alignment ]
+ *
+ * See Documentation/contiguous-memory.txt for details.
+ *
+ * Example:
+ * cma=reg1=64M;reg2=32M@0x100000;reg3=64M/1M
+ *
+ */
+
+#define NUMPARSE(cond_ch, type, cond) ({				\
+		unsigned long long v = 0;				\
+		if (*param == (cond_ch)) {				\
+			const char *const msg = param + 1;		\
+			v = memparse(msg, &param);			\
+			if (!v || v > ~(type)0 || !(cond)) {		\
+				pr_err("param: invalid value near %s\n", msg); \
+				ret = -EINVAL;				\
+				break;					\
+			}						\
+		}							\
+		v;							\
+	})
+
+static int __init cma_param_parse(char *param)
+{
+	static struct cma_region regions[16];
+
+	size_t left = ARRAY_SIZE(regions);
+	struct cma_region *reg = regions;
+	int ret = 0;
+
+	pr_debug("param: %s\n", param);
+
+	for (; *param; ++reg) {
+		dma_addr_t start, alignment;
+		size_t size;
+
+		if (unlikely(!--left)) {
+			pr_err("param: too many early regions\n");
+			return -ENOSPC;
+		}
+
+		/* Parse name */
+		reg->name = param;
+		param = strchr(param, '=');
+		if (!param || param == reg->name) {
+			pr_err("param: expected \"<name>=\" near %s\n",
+			       reg->name);
+			ret = -EINVAL;
+			break;
+		}
+		*param = '\0';
+
+		/* Parse numbers */
+		size      = NUMPARSE('\0', size_t, true);
+		start     = NUMPARSE('@', dma_addr_t, true);
+		alignment = NUMPARSE('/', dma_addr_t, (v & (v - 1)) == 0);
+
+		alignment = max(alignment, (dma_addr_t)PAGE_SIZE);
+		start     = ALIGN(start, alignment);
+		size      = PAGE_ALIGN(size);
+		if (start + size < start) {
+			pr_err("param: invalid start, size combination\n");
+			ret = -EINVAL;
+			break;
+		}
+
+		/* Go to next */
+		if (*param == ';') {
+			*param = '\0';
+			++param;
+		} else if (*param) {
+			pr_err("param: expecting ';' or end of parameter near %s\n",
+			       param);
+			ret = -EINVAL;
+			break;
+		}
+
+		/* Add */
+		reg->size      = size;
+		reg->start     = start;
+		reg->alignment = alignment;
+		reg->copy_name = 1;
+
+		list_add_tail(&reg->list, &cma_early_regions);
+
+		pr_debug("param: registering early region %s (%p@%p/%p)\n",
+			 reg->name, (void *)reg->size, (void *)reg->start,
+			 (void *)reg->alignment);
+	}
+
+	return ret;
+}
+early_param("cma", cma_param_parse);
+
+#undef NUMPARSE
+
+#endif
+
+
+int __init __must_check cma_early_region_register(struct cma_region *reg)
+{
+	dma_addr_t start, alignment;
+	size_t size;
+
+	if (reg->alignment & (reg->alignment - 1))
+		return -EINVAL;
+
+	alignment = max(reg->alignment, (dma_addr_t)PAGE_SIZE);
+	start     = ALIGN(reg->start, alignment);
+	size      = PAGE_ALIGN(reg->size);
+
+	if (start + size < start)
+		return -EINVAL;
+
+	reg->size      = size;
+	reg->start     = start;
+	reg->alignment = alignment;
+
+	list_add_tail(&reg->list, &cma_early_regions);
+
+	pr_debug("param: registering early region %s (%p@%p/%p)\n",
+		 reg->name, (void *)reg->size, (void *)reg->start,
+		 (void *)reg->alignment);
+
+	return 0;
+}
+
+
+
+/************************* Regions  ******************************/
+
+/* List of all regions.  Named regions are kept before unnamed. */
+static LIST_HEAD(cma_regions);
+
+#define cma_foreach_region(reg) \
+	list_for_each_entry(reg, &cma_regions, list)
+
+int __must_check cma_region_register(struct cma_region *reg)
+{
+	const char *name;
+	struct cma_region *r;
+	char *ch = NULL;
+	int ret = 0;
+
+	if (!reg->size || reg->start + reg->size < reg->start)
+		return -EINVAL;
+
+	reg->used = 0;
+	reg->registered = 0;
+
+	/* Copy name */
+	name = reg->name;
+	if (reg->copy_name && (reg->name)) {
+		size_t name_size;
+
+		name_size  = reg->name       ? strlen(reg->name) + 1       : 0;
+
+		ch = kmalloc(name_size, GFP_KERNEL);
+		if (!ch) {
+			pr_err("%s: not enough memory to allocate name\n",
+			       reg->name ?: "(private)");
+			return -ENOMEM;
+		}
+
+		if (name_size) {
+			memcpy(ch, reg->name, name_size);
+			name = ch;
+			ch += name_size;
+		}
+	}
+
+	mutex_lock(&cma_mutex);
+
+	/* Don't let regions overlap */
+	cma_foreach_region(r)
+		if (r->start + r->size > reg->start &&
+		    r->start < reg->start + reg->size) {
+			ret = -EADDRINUSE;
+			goto done;
+		}
+
+	reg->name = name;
+	reg->registered = 1;
+	reg->cma = cma_create(reg->start, reg->size, reg->alignment, false);
+
+	if (IS_ERR(reg->cma)) {
+		pr_err("error, cma create failed: %d\n", -(int)reg->cma);
+		ret = PTR_ERR(reg->cma);
+		goto done;
+	}
+	pr_info("created cma %p\n", reg->cma);
+	ch = NULL;
+
+	/*
+	 * Keep named at the beginning and unnamed (private) at the
+	 * end.  This helps in traversal when named region is looked
+	 * for.
+	 */
+	if (name)
+		list_add(&reg->list, &cma_regions);
+	else
+		list_add_tail(&reg->list, &cma_regions);
+
+done:
+	mutex_unlock(&cma_mutex);
+
+	pr_debug("%s: region %sregistered\n",
+		 reg->name ?: "(private)", ret ? "not " : "");
+	kfree(ch);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(cma_region_register);
+
+static struct cma_region *__must_check
+__cma_region_find(const char **namep)
+{
+	struct cma_region *reg;
+	const char *ch, *name;
+	size_t n;
+
+	ch = *namep;
+	while (*ch && *ch != ',' && *ch != ';')
+		++ch;
+	name = *namep;
+	*namep = *ch == ',' ? ch + 1 : ch;
+	n = ch - name;
+
+	/*
+	 * Named regions are kept in front of unnamed so if we
+	 * encounter unnamed region we can stop.
+	 */
+	cma_foreach_region(reg)
+		if (!reg->name)
+			break;
+		else if (!strncmp(name, reg->name, n) && !reg->name[n])
+			return reg;
+
+	return NULL;
+}
+
+/************************* Initialise CMA *************************/
+
+int __init cma_set_defaults(struct cma_region *regions, const char *map)
+{
+	if (map) {
+		int ret = cma_map_param((char *)map);
+		if (unlikely(ret < 0))
+			return ret;
+	}
+
+	if (!regions)
+		return 0;
+
+	for (; regions->size; ++regions) {
+		int ret = cma_early_region_register(regions);
+		if (unlikely(ret < 0))
+			return ret;
+	}
+
+	return 0;
+}
+
+
+int __init cma_early_region_reserve(struct cma_region *reg)
+{
+	int ret;
+
+	if (!reg->size || (reg->alignment & (reg->alignment - 1)) ||
+	    reg->reserved)
+		return -EINVAL;
+
+	ret = cma_reserve(reg->start, reg->size, reg->alignment, true);
+
+	if (ret >= 0)
+		reg->start = ret;
+
+	return ret;
+}
+
+void __init cma_early_regions_reserve(int (*reserve)(struct cma_region *reg))
+{
+	struct cma_region *reg;
+
+	pr_debug("init: reserving early regions\n");
+
+	if (!reserve)
+		reserve = cma_early_region_reserve;
+
+	list_for_each_entry(reg, &cma_early_regions, list) {
+		if (reg->reserved) {
+			/* nothing */
+		} else if (reserve(reg) >= 0) {
+			pr_debug("init: %s: reserved %p@%p\n",
+				 reg->name ?: "(private)",
+				 (void *)reg->size, (void *)reg->start);
+			reg->reserved = 1;
+		} else {
+			pr_warn("init: %s: unable to reserve %p@%p/%p\n",
+				reg->name ?: "(private)",
+				(void *)reg->size, (void *)reg->start,
+				(void *)reg->alignment);
+		}
+	}
+}
+
+
+static int __init cma_init(void)
+{
+	struct cma_region *reg, *n;
+
+	pr_debug("init: initialising\n");
+
+	if (cma_map) {
+		char *val = kmemdup(cma_map, cma_map_length + 1, GFP_KERNEL);
+		cma_map = val;
+		if (!val)
+			return -ENOMEM;
+		val[cma_map_length] = '\0';
+	}
+
+	list_for_each_entry_safe(reg, n, &cma_early_regions, list) {
+		INIT_LIST_HEAD(&reg->list);
+		/*
+		 * We don't care if there was an error.  It's a pity
+		 * but there's not much we can do about it any way.
+		 * If the error is on a region that was parsed from
+		 * command line then it will stay and waste a bit of
+		 * space; if it was registered using
+		 * cma_early_region_register() it's caller's
+		 * responsibility to do something about it.
+		 */
+		if (reg->reserved && cma_region_register(reg) < 0)
+			/* ignore error */;
+	}
+
+	INIT_LIST_HEAD(&cma_early_regions);
+
+	return 0;
+}
+/*
+ * We want to be initialised earlier than module_init/__initcall so
+ * that drivers that want to grab memory at boot time will get CMA
+ * ready.  subsys_initcall() seems early enough and not too early at
+ * the same time.
+ */
+subsys_initcall(cma_init);
+
+/************************* The Device API *************************/
+
+static const char *__must_check
+__cma_where_from(const struct device *dev, const char *type);
+
+
+/* Allocate. */
+
+static struct cm * __must_check
+__cma_alloc_from_region(struct cma_region *reg,
+			size_t size, dma_addr_t alignment)
+{
+	struct cm *cm;
+
+	pr_debug("allocate %p/%p from %s\n",
+		 (void *)size, (void *)alignment,
+		 reg ? reg->name ?: "(private)" : "(null)");
+
+	if (!reg)
+		return ERR_PTR(-ENOMEM);
+
+	cm = cm_alloc(reg->cma, size, alignment);
+	if (IS_ERR(cm)) {
+		pr_err("failed to allocate\n");
+		return ERR_PTR(-ENOMEM);
+	}
+	return cm;
+}
+
+struct cm * __must_check
+cma_alloc_from_region(struct cma_region *reg,
+		      size_t size, dma_addr_t alignment)
+{
+	struct cm *cm;
+
+	pr_debug("allocate %p/%p from %s\n",
+		 (void *)size, (void *)alignment,
+		 reg ? reg->name ?: "(private)" : "(null)");
+
+	if (!size || alignment & (alignment - 1) || !reg)
+		return ERR_PTR(-EINVAL);
+
+	mutex_lock(&cma_mutex);
+
+	cm = reg->registered ?
+		__cma_alloc_from_region(reg, PAGE_ALIGN(size),
+					max(alignment, (dma_addr_t)PAGE_SIZE)) :
+		ERR_PTR(-EINVAL);
+
+	mutex_unlock(&cma_mutex);
+
+	return cm;
+}
+EXPORT_SYMBOL_GPL(cma_alloc_from_region);
+
+struct cm * __must_check
+__cma_alloc(const struct device *dev, const char *type,
+	    dma_addr_t size, dma_addr_t alignment)
+{
+	struct cma_region *reg;
+	const char *from;
+	struct cm *cm;
+
+	if (dev)
+		pr_debug("allocate %p/%p for %s/%s\n",
+			 (void *)size, (void *)alignment,
+			 dev_name(dev), type ?: "");
+
+	if (!size || alignment & (alignment - 1))
+		return ERR_PTR(-EINVAL);
+
+	size = PAGE_ALIGN(size);
+	if (alignment < PAGE_SIZE)
+		alignment = PAGE_SIZE;
+
+	mutex_lock(&cma_mutex);
+
+	from = __cma_where_from(dev, type);
+	if (unlikely(IS_ERR(from))) {
+		cm = ERR_PTR(PTR_ERR(from));
+		goto done;
+	}
+
+	pr_debug("allocate %p/%p from one of %s\n",
+		 (void *)size, (void *)alignment, from);
+
+	while (*from && *from != ';') {
+		reg = __cma_region_find(&from);
+		cm = __cma_alloc_from_region(reg, size, alignment);
+		if (!IS_ERR(cm))
+			goto done;
+	}
+
+	pr_debug("not enough memory\n");
+	cm = ERR_PTR(-ENOMEM);
+
+done:
+	mutex_unlock(&cma_mutex);
+
+	return cm;
+}
+EXPORT_SYMBOL_GPL(__cma_alloc);
+
+
+/* Query information about regions. */
+static void __cma_info_add(struct cma_info *infop, struct cma_region *reg)
+{
+	infop->total_size += reg->size;
+	if (infop->lower_bound > reg->start)
+		infop->lower_bound = reg->start;
+	if (infop->upper_bound < reg->start + reg->size)
+		infop->upper_bound = reg->start + reg->size;
+	++infop->count;
+}
+
+int
+__cma_info(struct cma_info *infop, const struct device *dev, const char *type)
+{
+	struct cma_info info = { ~(dma_addr_t)0, 0, 0, 0, 0 };
+	struct cma_region *reg;
+	const char *from;
+	int ret;
+
+	if (unlikely(!infop))
+		return -EINVAL;
+
+	mutex_lock(&cma_mutex);
+
+	from = __cma_where_from(dev, type);
+	if (IS_ERR(from)) {
+		ret = PTR_ERR(from);
+		info.lower_bound = 0;
+		goto done;
+	}
+
+	while (*from && *from != ';') {
+		reg = __cma_region_find(&from);
+		if (reg)
+			__cma_info_add(&info, reg);
+	}
+
+	ret = 0;
+done:
+	mutex_unlock(&cma_mutex);
+
+	memcpy(infop, &info, sizeof info);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(__cma_info);
+
+
+/* Freeing. */
+int cma_free(struct cm *cm)
+{
+	mutex_lock(&cma_mutex);
+
+	if (cm)
+		pr_debug("free(%p): freed\n", (void *)cm);
+
+	cm_free(cm);
+	mutex_unlock(&cma_mutex);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(cma_free);
+
+
+/************************* Miscellaneous *************************/
+
+/*
+ * s            ::= rules
+ * rules        ::= rule [ ';' rules ]
+ * rule         ::= patterns '=' regions
+ * patterns     ::= pattern [ ',' patterns ]
+ * regions      ::= REG-NAME [ ',' regions ]
+ * pattern      ::= dev-pattern [ '/' TYPE-NAME ] | '/' TYPE-NAME
+ */
+static const char *__must_check
+__cma_where_from(const struct device *dev, const char *type)
+{
+	/*
+	 * This function matches the pattern from the map attribute
+	 * agains given device name and type.  Type may be of course
+	 * NULL or an emtpy string.
+	 */
+
+	const char *s, *name;
+	int name_matched = 0;
+
+	/*
+	 * If dev is NULL we were called in alternative form where
+	 * type is the from string.  All we have to do is return it.
+	 */
+	if (!dev)
+		return type ?: ERR_PTR(-EINVAL);
+
+	if (!cma_map)
+		return ERR_PTR(-ENOENT);
+
+	name = dev_name(dev);
+	if (WARN_ON(!name || !*name))
+		return ERR_PTR(-EINVAL);
+
+	if (!type)
+		type = "common";
+
+	/*
+	 * Now we go throught the cma_map attribute.
+	 */
+	for (s = cma_map; *s; ++s) {
+		const char *c;
+
+		/*
+		 * If the pattern starts with a slash, the device part of the
+		 * pattern matches if it matched previously.
+		 */
+		if (*s == '/') {
+			if (!name_matched)
+				goto look_for_next;
+			goto match_type;
+		}
+
+		/*
+		 * We are now trying to match the device name.  This also
+		 * updates the name_matched variable.  If, while reading the
+		 * spec, we ecnounter comma it means that the pattern does not
+		 * match and we need to start over with another pattern (the
+		 * one afther the comma).  If we encounter equal sign we need
+		 * to start over with another rule.  If there is a character
+		 * that does not match, we neet to look for a comma (to get
+		 * another pattern) or semicolon (to get another rule) and try
+		 * again if there is one somewhere.
+		 */
+
+		name_matched = 0;
+
+		for (c = name; *s != '*' && *c; ++c, ++s)
+			if (*s == '=')
+				goto next_rule;
+			else if (*s == ',')
+				goto next_pattern;
+			else if (*s != '?' && *c != *s)
+				goto look_for_next;
+		if (*s == '*')
+			++s;
+
+		name_matched = 1;
+
+		/*
+		 * Now we need to match the type part of the pattern.  If the
+		 * pattern is missing it we match only if type points to an
+		 * empty string.  Otherwise wy try to match it just like name.
+		 */
+		if (*s == '/') {
+match_type:		/* s points to '/' */
+			++s;
+
+			for (c = type; *s && *c; ++c, ++s)
+				if (*s == '=')
+					goto next_rule;
+				else if (*s == ',')
+					goto next_pattern;
+				else if (*c != *s)
+					goto look_for_next;
+		}
+
+		/* Return the string behind the '=' sign of the rule. */
+		if (*s == '=')
+			return s + 1;
+		else if (*s == ',')
+			return strchr(s, '=') + 1;
+
+		/* Pattern did not match */
+
+look_for_next:
+		do {
+			++s;
+		} while (*s != ',' && *s != '=');
+		if (*s == ',')
+			continue;
+
+next_rule:	/* s points to '=' */
+		s = strchr(s, ';');
+		if (!s)
+			break;
+
+next_pattern:
+		continue;
+	}
+
+	return ERR_PTR(-ENOENT);
+}
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
