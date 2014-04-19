Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id 4EBCC6B0035
	for <linux-mm@kvack.org>; Sat, 19 Apr 2014 11:53:29 -0400 (EDT)
Received: by mail-qa0-f52.google.com with SMTP id s7so2451175qap.25
        for <linux-mm@kvack.org>; Sat, 19 Apr 2014 08:53:29 -0700 (PDT)
Received: from mail-qc0-x234.google.com (mail-qc0-x234.google.com [2607:f8b0:400d:c01::234])
        by mx.google.com with ESMTPS id 68si13374831qgn.64.2014.04.19.08.53.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 19 Apr 2014 08:53:28 -0700 (PDT)
Received: by mail-qc0-f180.google.com with SMTP id w7so2627526qcr.25
        for <linux-mm@kvack.org>; Sat, 19 Apr 2014 08:53:28 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH 3/4] mm: zpool: implement common zpool api to zbud/zsmalloc
Date: Sat, 19 Apr 2014 11:52:43 -0400
Message-Id: <1397922764-1512-4-git-send-email-ddstreet@ieee.org>
In-Reply-To: <1397922764-1512-1-git-send-email-ddstreet@ieee.org>
References: <1397922764-1512-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Weijie Yang <weijie.yang@samsung.com>, Johannes Weiner <hannes@cmpxchg.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

Add zpool api.

zpool provides an interface for memory storage, typically of compressed
memory.  Users can select what backend to use; currently the only
implementations are zbud, a low density implementation with exactly
two compressed pages per storage page, and zsmalloc, a higher density
implementation with multiple compressed pages per storage page.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
---
 include/linux/zpool.h | 166 ++++++++++++++++++++++
 mm/Kconfig            |  43 +++---
 mm/Makefile           |   1 +
 mm/zpool.c            | 380 ++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 572 insertions(+), 18 deletions(-)
 create mode 100644 include/linux/zpool.h
 create mode 100644 mm/zpool.c

diff --git a/include/linux/zpool.h b/include/linux/zpool.h
new file mode 100644
index 0000000..82d81c6
--- /dev/null
+++ b/include/linux/zpool.h
@@ -0,0 +1,166 @@
+/*
+ * zpool memory storage api
+ *
+ * Copyright (C) 2014 Dan Streetman
+ *
+ * This is a common frontend for the zbud and zsmalloc memory
+ * storage pool implementations.  Typically, this is used to
+ * store compressed memory.
+ */
+
+#ifndef _ZPOOL_H_
+#define _ZPOOL_H_
+
+struct zpool;
+
+struct zpool_ops {
+	int (*evict)(struct zpool *pool, unsigned long handle);
+};
+
+#define ZPOOL_TYPE_ZSMALLOC "zsmalloc"
+#define ZPOOL_TYPE_ZBUD "zbud"
+
+/*
+ * Control how a handle is mapped.  It will be ignored if the
+ * implementation does not support it.  Its use is optional.
+ * Note that this does not refer to memory protection, it
+ * refers to how the memory will be copied in/out if copying
+ * is necessary during mapping; read-write is the safest as
+ * it copies the existing memory in on map, and copies the
+ * changed memory back out on unmap.  Write-only does not copy
+ * in the memory and should only be used for initialization.
+ * If in doubt, use ZPOOL_MM_DEFAULT which is read-write.
+ */
+enum zpool_mapmode {
+	ZPOOL_MM_RW, /* normal read-write mapping */
+	ZPOOL_MM_RO, /* read-only (no copy-out at unmap time) */
+	ZPOOL_MM_WO, /* write-only (no copy-in at map time) */
+
+	ZPOOL_MM_DEFAULT = ZPOOL_MM_RW
+};
+
+/**
+ * zpool_create_pool() - Create a new zpool
+ * @type	The type of the zpool to create (e.g. zbud, zsmalloc)
+ * @flags	What GFP flags should be used when the zpool allocates memory.
+ * @ops		The optional ops callback.
+ * @fallback	If other implementations should be used
+ *
+ * This creates a new zpool of the specified type.  The zpool will use the
+ * given flags when allocating any memory.  If the ops param is NULL, then
+ * the created zpool will not be shrinkable.
+ *
+ * If creation of the implementation @type fails, and @fallback is true,
+ * then other implementation(s) are tried.  If @fallback is false or no
+ * implementations could be created, then NULL is returned.
+ *
+ * Returns: New zpool on success, NULL on failure.
+ */
+struct zpool *zpool_create_pool(char *type, gfp_t flags,
+			struct zpool_ops *ops, bool fallback);
+
+/**
+ * zpool_get_type() - Get the type of the zpool
+ * @pool	The zpool to check
+ *
+ * This returns the type of the pool, which will match one of the
+ * ZPOOL_TYPE_* defined values.  This can be useful after calling
+ * zpool_create_pool() with @fallback set to true.
+ *
+ * Returns: The type of zpool.
+ */
+char *zpool_get_type(struct zpool *pool);
+
+/**
+ * zpool_destroy_pool() - Destroy a zpool
+ * @pool	The zpool to destroy.
+ *
+ * This destroys an existing zpool.  The zpool should not be in use.
+ */
+void zpool_destroy_pool(struct zpool *pool);
+
+/**
+ * zpool_malloc() - Allocate memory
+ * @pool	The zpool to allocate from.
+ * @size	The amount of memory to allocate.
+ * @handle	Pointer to the handle to set
+ *
+ * This allocates the requested amount of memory from the pool.
+ * The provided @handle will be set to the allocated object handle.
+ *
+ * Returns: 0 on success, negative value on error.
+ */
+int zpool_malloc(struct zpool *pool, size_t size, unsigned long *handle);
+
+/**
+ * zpool_free() - Free previously allocated memory
+ * @pool	The zpool that allocated the memory.
+ * @handle	The handle to the memory to free.
+ *
+ * This frees previously allocated memory.  This does not guarantee
+ * that the pool will actually free memory, only that the memory
+ * in the pool will become available for use by the pool.
+ */
+void zpool_free(struct zpool *pool, unsigned long handle);
+
+/**
+ * zpool_shrink() - Shrink the pool size
+ * @pool	The zpool to shrink.
+ * @size	The minimum amount to shrink the pool.
+ *
+ * This attempts to shrink the actual memory size of the pool
+ * by evicting currently used handle(s).  If the pool was
+ * created with no zpool_ops, or the evict call fails for any
+ * of the handles, this will fail.
+ *
+ * Returns: 0 on success, negative value on error/failure.
+ */
+int zpool_shrink(struct zpool *pool, size_t size);
+
+/**
+ * zpool_map_handle() - Map a previously allocated handle into memory
+ * @pool	The zpool that the handle was allocated from
+ * @handle	The handle to map
+ * @mm	How the memory should be mapped
+ *
+ * This maps a previously allocated handle into memory.  The @mm
+ * param indicates to the implemenation how the memory will be
+ * used, i.e. read-only, write-only, read-write.  If the
+ * implementation does not support it, the memory will be treated
+ * as read-write.
+ *
+ * This may hold locks, disable interrupts, and/or preemption,
+ * and the zpool_unmap_handle() must be called to undo those
+ * actions.  The code that uses the mapped handle should complete
+ * its operatons on the mapped handle memory quickly and unmap
+ * as soon as possible.  Multiple handles should not be mapped
+ * concurrently on a cpu.
+ *
+ * Returns: A pointer to the handle's mapped memory area.
+ */
+void *zpool_map_handle(struct zpool *pool, unsigned long handle,
+			enum zpool_mapmode mm);
+
+/**
+ * zpool_unmap_handle() - Unmap a previously mapped handle
+ * @pool	The zpool that the handle was allocated from
+ * @handle	The handle to unmap
+ *
+ * This unmaps a previously mapped handle.  Any locks or other
+ * actions that the implemenation took in zpool_map_handle()
+ * will be undone here.  The memory area returned from
+ * zpool_map_handle() should no longer be used after this.
+ */
+void zpool_unmap_handle(struct zpool *pool, unsigned long handle);
+
+/**
+ * zpool_get_total_size() - The total size of the pool
+ * @pool	The zpool to check
+ *
+ * This returns the total size in bytes of the pool.
+ *
+ * Returns: Total size of the zpool in bytes.
+ */
+u64 zpool_get_total_size(struct zpool *pool);
+
+#endif
diff --git a/mm/Kconfig b/mm/Kconfig
index ebe5880..ed7715c 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -512,21 +512,23 @@ config CMA_DEBUG
 	  processing calls such as dma_alloc_from_contiguous().
 	  This option does not affect warning and error messages.
 
-config ZBUD
-	tristate
-	default n
+config MEM_SOFT_DIRTY
+	bool "Track memory changes"
+	depends on CHECKPOINT_RESTORE && HAVE_ARCH_SOFT_DIRTY && PROC_FS
+	select PROC_PAGE_MONITOR
 	help
-	  A special purpose allocator for storing compressed pages.
-	  It is designed to store up to two compressed pages per physical
-	  page.  While this design limits storage density, it has simple and
-	  deterministic reclaim properties that make it preferable to a higher
-	  density approach when reclaim will be used.
+	  This option enables memory changes tracking by introducing a
+	  soft-dirty bit on pte-s. This bit it set when someone writes
+	  into a page just as regular dirty bit, but unlike the latter
+	  it can be cleared by hands.
+
+	  See Documentation/vm/soft-dirty.txt for more details.
 
 config ZSWAP
 	bool "Compressed cache for swap pages (EXPERIMENTAL)"
 	depends on FRONTSWAP && CRYPTO=y
 	select CRYPTO_LZO
-	select ZBUD
+	select ZPOOL
 	default n
 	help
 	  A lightweight compressed cache for swap pages.  It takes
@@ -542,17 +544,22 @@ config ZSWAP
 	  they have not be fully explored on the large set of potential
 	  configurations and workloads that exist.
 
-config MEM_SOFT_DIRTY
-	bool "Track memory changes"
-	depends on CHECKPOINT_RESTORE && HAVE_ARCH_SOFT_DIRTY && PROC_FS
-	select PROC_PAGE_MONITOR
+config ZPOOL
+	tristate "Common API for compressed memory storage"
+	default n
 	help
-	  This option enables memory changes tracking by introducing a
-	  soft-dirty bit on pte-s. This bit it set when someone writes
-	  into a page just as regular dirty bit, but unlike the latter
-	  it can be cleared by hands.
+	  Compressed memory storage API.  This allows using either zbud or
+	  zsmalloc.
 
-	  See Documentation/vm/soft-dirty.txt for more details.
+config ZBUD
+	tristate "Low density storage for compressed pages"
+	default n
+	help
+	  A special purpose allocator for storing compressed pages.
+	  It is designed to store up to two compressed pages per physical
+	  page.  While this design limits storage density, it has simple and
+	  deterministic reclaim properties that make it preferable to a higher
+	  density approach when reclaim will be used.
 
 config ZSMALLOC
 	bool "Memory allocator for compressed pages"
diff --git a/mm/Makefile b/mm/Makefile
index 60cacbb..4135f7c 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -60,6 +60,7 @@ obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
 obj-$(CONFIG_CLEANCACHE) += cleancache.o
 obj-$(CONFIG_MEMORY_ISOLATION) += page_isolation.o
 obj-$(CONFIG_PAGE_OWNER) += pageowner.o
+obj-$(CONFIG_ZPOOL)	+= zpool.o
 obj-$(CONFIG_ZBUD)	+= zbud.o
 obj-$(CONFIG_ZSMALLOC)	+= zsmalloc.o
 obj-$(CONFIG_GENERIC_EARLY_IOREMAP) += early_ioremap.o
diff --git a/mm/zpool.c b/mm/zpool.c
new file mode 100644
index 0000000..592cc0d
--- /dev/null
+++ b/mm/zpool.c
@@ -0,0 +1,380 @@
+/*
+ * zpool memory storage api
+ *
+ * Copyright (C) 2014 Dan Streetman
+ *
+ * This is a common frontend for the zbud and zsmalloc memory
+ * storage pool implementations.  Typically, this is used to
+ * store compressed memory.
+ */
+
+#include <linux/list.h>
+#include <linux/types.h>
+#include <linux/mm.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/zpool.h>
+#include <linux/zbud.h>
+#include <linux/zsmalloc.h>
+
+struct zpool_imp {
+	void (*destroy)(struct zpool *pool);
+
+	int (*malloc)(struct zpool *pool, size_t size, unsigned long *handle);
+	void (*free)(struct zpool *pool, unsigned long handle);
+
+	int (*shrink)(struct zpool *pool, size_t size);
+
+	void *(*map)(struct zpool *pool, unsigned long handle,
+				enum zpool_mapmode mm);
+	void (*unmap)(struct zpool *pool, unsigned long handle);
+
+	u64 (*total_size)(struct zpool *pool);
+};
+
+struct zpool {
+	char *type;
+
+	union {
+#ifdef CONFIG_ZSMALLOC
+	struct zs_pool *zsmalloc_pool;
+#endif
+#ifdef CONFIG_ZBUD
+	struct zbud_pool *zbud_pool;
+#endif
+	};
+
+	struct zpool_imp *imp;
+	struct zpool_ops *ops;
+
+	struct list_head list;
+};
+
+static LIST_HEAD(zpools);
+static DEFINE_SPINLOCK(zpools_lock);
+
+static int zpool_noop_evict(struct zpool *pool, unsigned long handle)
+{
+	return -EINVAL;
+}
+static struct zpool_ops zpool_noop_ops = {
+	.evict = zpool_noop_evict
+};
+
+
+/* zsmalloc */
+
+#ifdef CONFIG_ZSMALLOC
+
+static void zpool_zsmalloc_destroy(struct zpool *zpool)
+{
+	spin_lock(&zpools_lock);
+	list_del(&zpool->list);
+	spin_unlock(&zpools_lock);
+
+	zs_destroy_pool(zpool->zsmalloc_pool);
+	kfree(zpool);
+}
+
+static int zpool_zsmalloc_malloc(struct zpool *pool, size_t size,
+			unsigned long *handle)
+{
+	*handle = zs_malloc(pool->zsmalloc_pool, size);
+	return *handle ? 0 : -1;
+}
+
+static void zpool_zsmalloc_free(struct zpool *pool, unsigned long handle)
+{
+	zs_free(pool->zsmalloc_pool, handle);
+}
+
+static int zpool_zsmalloc_shrink(struct zpool *pool, size_t size)
+{
+	return zs_shrink(pool->zsmalloc_pool, size);
+}
+
+static void *zpool_zsmalloc_map(struct zpool *pool, unsigned long handle,
+			enum zpool_mapmode zpool_mapmode)
+{
+	enum zs_mapmode zs_mapmode;
+
+	switch (zpool_mapmode) {
+	case ZPOOL_MM_RO:
+		zs_mapmode = ZS_MM_RO; break;
+	case ZPOOL_MM_WO:
+		zs_mapmode = ZS_MM_WO; break;
+	case ZPOOL_MM_RW: /* fallthrough */
+	default:
+		zs_mapmode = ZS_MM_RW; break;
+	}
+	return zs_map_object(pool->zsmalloc_pool, handle, zs_mapmode);
+}
+
+static void zpool_zsmalloc_unmap(struct zpool *pool, unsigned long handle)
+{
+	zs_unmap_object(pool->zsmalloc_pool, handle);
+}
+
+static u64 zpool_zsmalloc_total_size(struct zpool *pool)
+{
+	return zs_get_total_size_bytes(pool->zsmalloc_pool);
+}
+
+static int zpool_zsmalloc_evict(struct zs_pool *zsmalloc_pool,
+			unsigned long handle)
+{
+	struct zpool *zpool;
+
+	spin_lock(&zpools_lock);
+	list_for_each_entry(zpool, &zpools, list) {
+		if (zpool->zsmalloc_pool == zsmalloc_pool) {
+			spin_unlock(&zpools_lock);
+			return zpool->ops->evict(zpool, handle);
+		}
+	}
+	spin_unlock(&zpools_lock);
+	return -EINVAL;
+}
+
+static struct zpool_imp zpool_zsmalloc_imp = {
+	.destroy = zpool_zsmalloc_destroy,
+	.malloc = zpool_zsmalloc_malloc,
+	.free = zpool_zsmalloc_free,
+	.shrink = zpool_zsmalloc_shrink,
+	.map = zpool_zsmalloc_map,
+	.unmap = zpool_zsmalloc_unmap,
+	.total_size = zpool_zsmalloc_total_size
+};
+
+static struct zs_ops zpool_zsmalloc_ops = {
+	.evict = zpool_zsmalloc_evict
+};
+
+static struct zpool *zpool_zsmalloc_create(gfp_t flags, struct zpool_ops *ops)
+{
+	struct zpool *zpool;
+	struct zs_ops *zs_ops = (ops ? &zpool_zsmalloc_ops : NULL);
+
+	zpool = kmalloc(sizeof(*zpool), GFP_KERNEL);
+	if (!zpool)
+		return NULL;
+
+	zpool->zsmalloc_pool = zs_create_pool(flags, zs_ops);
+	if (!zpool->zsmalloc_pool) {
+		kfree(zpool);
+		return NULL;
+	}
+
+	zpool->type = ZPOOL_TYPE_ZSMALLOC;
+	zpool->imp = &zpool_zsmalloc_imp;
+	zpool->ops = (ops ? ops : &zpool_noop_ops);
+	spin_lock(&zpools_lock);
+	list_add(&zpool->list, &zpools);
+	spin_unlock(&zpools_lock);
+
+	return zpool;
+}
+
+#else
+
+static struct zpool *zpool_zsmalloc_create(gfp_t flags, struct zpool_ops *ops)
+{
+	pr_info("zpool: no zsmalloc in this kernel\n");
+	return NULL;
+}
+
+#endif /* CONFIG_ZSMALLOC */
+
+
+/* zbud */
+
+#ifdef CONFIG_ZBUD
+
+static void zpool_zbud_destroy(struct zpool *zpool)
+{
+	spin_lock(&zpools_lock);
+	list_del(&zpool->list);
+	spin_unlock(&zpools_lock);
+
+	zbud_destroy_pool(zpool->zbud_pool);
+	kfree(zpool);
+}
+
+static int zpool_zbud_malloc(struct zpool *pool, size_t size,
+			unsigned long *handle)
+{
+	return zbud_alloc(pool->zbud_pool, size, handle);
+}
+
+static void zpool_zbud_free(struct zpool *pool, unsigned long handle)
+{
+	zbud_free(pool->zbud_pool, handle);
+}
+
+static int zpool_zbud_shrink(struct zpool *pool, size_t size)
+{
+	return zbud_reclaim_page(pool->zbud_pool, 3);
+}
+
+static void *zpool_zbud_map(struct zpool *pool, unsigned long handle,
+			enum zpool_mapmode zpool_mapmode)
+{
+	return zbud_map(pool->zbud_pool, handle);
+}
+
+static void zpool_zbud_unmap(struct zpool *pool, unsigned long handle)
+{
+	zbud_unmap(pool->zbud_pool, handle);
+}
+
+static u64 zpool_zbud_total_size(struct zpool *pool)
+{
+	return zbud_get_pool_size(pool->zbud_pool) * PAGE_SIZE;
+}
+
+static int zpool_zbud_evict(struct zbud_pool *zbud_pool, unsigned long handle)
+{
+	struct zpool *zpool;
+
+	spin_lock(&zpools_lock);
+	list_for_each_entry(zpool, &zpools, list) {
+		if (zpool->zbud_pool == zbud_pool) {
+			spin_unlock(&zpools_lock);
+			return zpool->ops->evict(zpool, handle);
+		}
+	}
+	spin_unlock(&zpools_lock);
+	return -EINVAL;
+}
+
+static struct zpool_imp zpool_zbud_imp = {
+	.destroy = zpool_zbud_destroy,
+	.malloc = zpool_zbud_malloc,
+	.free = zpool_zbud_free,
+	.shrink = zpool_zbud_shrink,
+	.map = zpool_zbud_map,
+	.unmap = zpool_zbud_unmap,
+	.total_size = zpool_zbud_total_size
+};
+
+static struct zbud_ops zpool_zbud_ops = {
+	.evict = zpool_zbud_evict
+};
+
+static struct zpool *zpool_zbud_create(gfp_t flags, struct zpool_ops *ops)
+{
+	struct zpool *zpool;
+	struct zbud_ops *zbud_ops = (ops ? &zpool_zbud_ops : NULL);
+
+	zpool = kmalloc(sizeof(*zpool), GFP_KERNEL);
+	if (!zpool)
+		return NULL;
+
+	zpool->zbud_pool = zbud_create_pool(flags, zbud_ops);
+	if (!zpool->zbud_pool) {
+		kfree(zpool);
+		return NULL;
+	}
+
+	zpool->type = ZPOOL_TYPE_ZBUD;
+	zpool->imp = &zpool_zbud_imp;
+	zpool->ops = (ops ? ops : &zpool_noop_ops);
+	spin_lock(&zpools_lock);
+	list_add(&zpool->list, &zpools);
+	spin_unlock(&zpools_lock);
+
+	return zpool;
+}
+
+#else
+
+static struct zpool *zpool_zbud_create(gfp_t flags, struct zpool_ops *ops)
+{
+	pr_info("zpool: no zbud in this kernel\n");
+	return NULL;
+}
+
+#endif /* CONFIG_ZBUD */
+
+
+struct zpool *zpool_fallback_create(gfp_t flags, struct zpool_ops *ops)
+{
+	struct zpool *pool = NULL;
+
+#ifdef CONFIG_ZSMALLOC
+	pool = zpool_zsmalloc_create(flags, ops);
+	if (pool)
+		return pool;
+	pr_info("zpool: fallback unable to create zsmalloc pool\n");
+#endif
+
+#ifdef CONFIG_ZBUD
+	pool = zpool_zbud_create(flags, ops);
+	if (!pool)
+		pr_info("zpool: fallback unable to create zbud pool\n");
+#endif
+
+	return pool;
+}
+
+struct zpool *zpool_create_pool(char *type, gfp_t flags,
+			struct zpool_ops *ops, bool fallback)
+{
+	struct zpool *pool = NULL;
+
+	if (!strcmp(type, ZPOOL_TYPE_ZSMALLOC))
+		pool = zpool_zsmalloc_create(flags, ops);
+	else if (!strcmp(type, ZPOOL_TYPE_ZBUD))
+		pool = zpool_zbud_create(flags, ops);
+	else
+		pr_err("zpool: unknown type %s\n", type);
+
+	if (!pool && fallback)
+		pool = zpool_fallback_create(flags, ops);
+
+	if (!pool)
+		pr_err("zpool: couldn't create zpool\n");
+
+	return pool;
+}
+
+char *zpool_get_type(struct zpool *pool)
+{
+	return pool->type;
+}
+
+void zpool_destroy_pool(struct zpool *pool)
+{
+	pool->imp->destroy(pool);
+}
+
+int zpool_malloc(struct zpool *pool, size_t size, unsigned long *handle)
+{
+	return pool->imp->malloc(pool, size, handle);
+}
+
+void zpool_free(struct zpool *pool, unsigned long handle)
+{
+	pool->imp->free(pool, handle);
+}
+
+int zpool_shrink(struct zpool *pool, size_t size)
+{
+	return pool->imp->shrink(pool, size);
+}
+
+void *zpool_map_handle(struct zpool *pool, unsigned long handle,
+			enum zpool_mapmode mapmode)
+{
+	return pool->imp->map(pool, handle, mapmode);
+}
+
+void zpool_unmap_handle(struct zpool *pool, unsigned long handle)
+{
+	pool->imp->unmap(pool, handle);
+}
+
+u64 zpool_get_total_size(struct zpool *pool)
+{
+	return pool->imp->total_size(pool);
+}
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
