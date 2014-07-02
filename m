Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id A7C366B0037
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 17:46:04 -0400 (EDT)
Received: by mail-ig0-f177.google.com with SMTP id c1so780772igq.10
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 14:46:04 -0700 (PDT)
Received: from mail-ie0-x235.google.com (mail-ie0-x235.google.com [2607:f8b0:4001:c03::235])
        by mx.google.com with ESMTPS id cz19si3355800igc.31.2014.07.02.14.46.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 02 Jul 2014 14:46:03 -0700 (PDT)
Received: by mail-ie0-f181.google.com with SMTP id y20so1960123ier.12
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 14:46:03 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCHv5 2/4] mm/zpool: implement common zpool api to zbud/zsmalloc
Date: Wed,  2 Jul 2014 17:45:34 -0400
Message-Id: <1404337536-11037-3-git-send-email-ddstreet@ieee.org>
In-Reply-To: <1404337536-11037-1-git-send-email-ddstreet@ieee.org>
References: <1401747586-11861-1-git-send-email-ddstreet@ieee.org>
 <1404337536-11037-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>, Nitin Gupta <ngupta@vflare.org>
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

Add zpool api.

zpool provides an interface for memory storage, typically of compressed
memory.  Users can select what backend to use; currently the only
implementations are zbud, a low density implementation with up to
two compressed pages per storage page, and zsmalloc, a higher density
implementation with multiple compressed pages per storage page.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
Cc: Seth Jennings <sjennings@variantweb.net>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>
Cc: Weijie Yang <weijie.yang@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---

Changes since v4 : https://lkml.org/lkml/2014/6/2/707
  -move function doc from zpool.h to zpool.c
  -add doc clarifying concurrency use
  -move module usage refcounting into this patch from later patch
  -add atomic_t refcounting
  -change driver unregister function to return failure if driver in use
  -update to pass gfp to create and malloc functions

Changes since v3 : https://lkml.org/lkml/2014/5/24/135
  -change zpool_shrink() to use # pages instead of # bytes
  -change zpool_shrink() to update *reclaimed param with
   number of pages actually reclaimed

Changes since v2 : https://lkml.org/lkml/2014/5/7/733
  -Remove hardcoded zbud/zsmalloc implementations
  -Add driver (un)register functions

Changes since v1 https://lkml.org/lkml/2014/4/19/101
 -add some pr_info() during creation and pr_err() on errors
 -remove zpool code to call zs_shrink(), since zsmalloc shrinking
  was removed from this patchset
 -remove fallback; only specified pool type will be tried
 -pr_fmt() is defined in zpool to prefix zpool: in any pr_XXX() calls


 include/linux/zpool.h | 106 +++++++++++++++
 mm/Kconfig            |  41 +++---
 mm/Makefile           |   1 +
 mm/zpool.c            | 364 ++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/zsmalloc.c         |   1 -
 5 files changed, 495 insertions(+), 18 deletions(-)
 create mode 100644 include/linux/zpool.h
 create mode 100644 mm/zpool.c

diff --git a/include/linux/zpool.h b/include/linux/zpool.h
new file mode 100644
index 0000000..f14bd75
--- /dev/null
+++ b/include/linux/zpool.h
@@ -0,0 +1,106 @@
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
+struct zpool *zpool_create_pool(char *type, gfp_t gfp, struct zpool_ops *ops);
+
+char *zpool_get_type(struct zpool *pool);
+
+void zpool_destroy_pool(struct zpool *pool);
+
+int zpool_malloc(struct zpool *pool, size_t size, gfp_t gfp,
+			unsigned long *handle);
+
+void zpool_free(struct zpool *pool, unsigned long handle);
+
+int zpool_shrink(struct zpool *pool, unsigned int pages,
+			unsigned int *reclaimed);
+
+void *zpool_map_handle(struct zpool *pool, unsigned long handle,
+			enum zpool_mapmode mm);
+
+void zpool_unmap_handle(struct zpool *pool, unsigned long handle);
+
+u64 zpool_get_total_size(struct zpool *pool);
+
+
+/**
+ * struct zpool_driver - driver implementation for zpool
+ * @type:	name of the driver.
+ * @list:	entry in the list of zpool drivers.
+ * @create:	create a new pool.
+ * @destroy:	destroy a pool.
+ * @malloc:	allocate mem from a pool.
+ * @free:	free mem from a pool.
+ * @shrink:	shrink the pool.
+ * @map:	map a handle.
+ * @unmap:	unmap a handle.
+ * @total_size:	get total size of a pool.
+ *
+ * This is created by a zpool implementation and registered
+ * with zpool.
+ */
+struct zpool_driver {
+	char *type;
+	struct module *owner;
+	atomic_t refcount;
+	struct list_head list;
+
+	void *(*create)(gfp_t gfp, struct zpool_ops *ops);
+	void (*destroy)(void *pool);
+
+	int (*malloc)(void *pool, size_t size, gfp_t gfp,
+				unsigned long *handle);
+	void (*free)(void *pool, unsigned long handle);
+
+	int (*shrink)(void *pool, unsigned int pages,
+				unsigned int *reclaimed);
+
+	void *(*map)(void *pool, unsigned long handle,
+				enum zpool_mapmode mm);
+	void (*unmap)(void *pool, unsigned long handle);
+
+	u64 (*total_size)(void *pool);
+};
+
+void zpool_register_driver(struct zpool_driver *driver);
+
+int zpool_unregister_driver(struct zpool_driver *driver);
+
+int zpool_evict(void *pool, unsigned long handle);
+
+#endif
diff --git a/mm/Kconfig b/mm/Kconfig
index 3e9977a..865f91c 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -508,15 +508,17 @@ config CMA_DEBUG
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
@@ -538,17 +540,22 @@ config ZSWAP
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
 	tristate "Memory allocator for compressed pages"
diff --git a/mm/Makefile b/mm/Makefile
index 4064f3e..2f6eeb6 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -59,6 +59,7 @@ obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
 obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
 obj-$(CONFIG_CLEANCACHE) += cleancache.o
 obj-$(CONFIG_MEMORY_ISOLATION) += page_isolation.o
+obj-$(CONFIG_ZPOOL)	+= zpool.o
 obj-$(CONFIG_ZBUD)	+= zbud.o
 obj-$(CONFIG_ZSMALLOC)	+= zsmalloc.o
 obj-$(CONFIG_GENERIC_EARLY_IOREMAP) += early_ioremap.o
diff --git a/mm/zpool.c b/mm/zpool.c
new file mode 100644
index 0000000..e40612a
--- /dev/null
+++ b/mm/zpool.c
@@ -0,0 +1,364 @@
+/*
+ * zpool memory storage api
+ *
+ * Copyright (C) 2014 Dan Streetman
+ *
+ * This is a common frontend for memory storage pool implementations.
+ * Typically, this is used to store compressed memory.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/list.h>
+#include <linux/types.h>
+#include <linux/mm.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/module.h>
+#include <linux/zpool.h>
+
+struct zpool {
+	char *type;
+
+	struct zpool_driver *driver;
+	void *pool;
+	struct zpool_ops *ops;
+
+	struct list_head list;
+};
+
+static LIST_HEAD(drivers_head);
+static DEFINE_SPINLOCK(drivers_lock);
+
+static LIST_HEAD(pools_head);
+static DEFINE_SPINLOCK(pools_lock);
+
+/**
+ * zpool_register_driver() - register a zpool implementation.
+ * @driver:	driver to register
+ */
+void zpool_register_driver(struct zpool_driver *driver)
+{
+	spin_lock(&drivers_lock);
+	atomic_set(&driver->refcount, 0);
+	list_add(&driver->list, &drivers_head);
+	spin_unlock(&drivers_lock);
+}
+EXPORT_SYMBOL(zpool_register_driver);
+
+/**
+ * zpool_unregister_driver() - unregister a zpool implementation.
+ * @driver:	driver to unregister.
+ *
+ * Module usage counting is used to prevent using a driver
+ * while/after unloading, so if this is called from module
+ * exit function, this should never fail; if called from
+ * other than the module exit function, and this returns
+ * failure, the driver is in use and must remain available.
+ */
+int zpool_unregister_driver(struct zpool_driver *driver)
+{
+	int ret = 0, refcount;
+
+	spin_lock(&drivers_lock);
+	refcount = atomic_read(&driver->refcount);
+	WARN_ON(refcount < 0);
+	if (refcount > 0)
+		ret = -EBUSY;
+	else
+		list_del(&driver->list);
+	spin_unlock(&drivers_lock);
+
+	return ret;
+}
+EXPORT_SYMBOL(zpool_unregister_driver);
+
+/**
+ * zpool_evict() - evict callback from a zpool implementation.
+ * @pool:	pool to evict from.
+ * @handle:	handle to evict.
+ *
+ * This can be used by zpool implementations to call the
+ * user's evict zpool_ops struct evict callback.
+ */
+int zpool_evict(void *pool, unsigned long handle)
+{
+	struct zpool *zpool;
+
+	spin_lock(&pools_lock);
+	list_for_each_entry(zpool, &pools_head, list) {
+		if (zpool->pool == pool) {
+			spin_unlock(&pools_lock);
+			if (!zpool->ops || !zpool->ops->evict)
+				return -EINVAL;
+			return zpool->ops->evict(zpool, handle);
+		}
+	}
+	spin_unlock(&pools_lock);
+
+	return -ENOENT;
+}
+EXPORT_SYMBOL(zpool_evict);
+
+static struct zpool_driver *zpool_get_driver(char *type)
+{
+	struct zpool_driver *driver;
+
+	spin_lock(&drivers_lock);
+	list_for_each_entry(driver, &drivers_head, list) {
+		if (!strcmp(driver->type, type)) {
+			bool got = try_module_get(driver->owner);
+
+			if (got)
+				atomic_inc(&driver->refcount);
+			spin_unlock(&drivers_lock);
+			return got ? driver : NULL;
+		}
+	}
+
+	spin_unlock(&drivers_lock);
+	return NULL;
+}
+
+static void zpool_put_driver(struct zpool_driver *driver)
+{
+	atomic_dec(&driver->refcount);
+	module_put(driver->owner);
+}
+
+/**
+ * zpool_create_pool() - Create a new zpool
+ * @type	The type of the zpool to create (e.g. zbud, zsmalloc)
+ * @gfp		The GFP flags to use when allocating the pool.
+ * @ops		The optional ops callback.
+ *
+ * This creates a new zpool of the specified type.  The gfp flags will be
+ * used when allocating memory, if the implementation supports it.  If the
+ * ops param is NULL, then the created zpool will not be shrinkable.
+ *
+ * Implementations must guarantee this to be thread-safe.
+ *
+ * Returns: New zpool on success, NULL on failure.
+ */
+struct zpool *zpool_create_pool(char *type, gfp_t gfp, struct zpool_ops *ops)
+{
+	struct zpool_driver *driver;
+	struct zpool *zpool;
+
+	pr_info("creating pool type %s\n", type);
+
+	driver = zpool_get_driver(type);
+
+	if (!driver) {
+		request_module(type);
+		driver = zpool_get_driver(type);
+	}
+
+	if (!driver) {
+		pr_err("no driver for type %s\n", type);
+		return NULL;
+	}
+
+	zpool = kmalloc(sizeof(*zpool), gfp);
+	if (!zpool) {
+		pr_err("couldn't create zpool - out of memory\n");
+		zpool_put_driver(driver);
+		return NULL;
+	}
+
+	zpool->type = driver->type;
+	zpool->driver = driver;
+	zpool->pool = driver->create(gfp, ops);
+	zpool->ops = ops;
+
+	if (!zpool->pool) {
+		pr_err("couldn't create %s pool\n", type);
+		zpool_put_driver(driver);
+		kfree(zpool);
+		return NULL;
+	}
+
+	pr_info("created %s pool\n", type);
+
+	spin_lock(&pools_lock);
+	list_add(&zpool->list, &pools_head);
+	spin_unlock(&pools_lock);
+
+	return zpool;
+}
+
+/**
+ * zpool_destroy_pool() - Destroy a zpool
+ * @pool	The zpool to destroy.
+ *
+ * Implementations must guarantee this to be thread-safe,
+ * however only when destroying different pools.  The same
+ * pool should only be destroyed once, and should not be used
+ * after it is destroyed.
+ *
+ * This destroys an existing zpool.  The zpool should not be in use.
+ */
+void zpool_destroy_pool(struct zpool *zpool)
+{
+	pr_info("destroying pool type %s\n", zpool->type);
+
+	spin_lock(&pools_lock);
+	list_del(&zpool->list);
+	spin_unlock(&pools_lock);
+	zpool->driver->destroy(zpool->pool);
+	zpool_put_driver(zpool->driver);
+	kfree(zpool);
+}
+
+/**
+ * zpool_get_type() - Get the type of the zpool
+ * @pool	The zpool to check
+ *
+ * This returns the type of the pool.
+ *
+ * Implementations must guarantee this to be thread-safe.
+ *
+ * Returns: The type of zpool.
+ */
+char *zpool_get_type(struct zpool *zpool)
+{
+	return zpool->type;
+}
+
+/**
+ * zpool_malloc() - Allocate memory
+ * @pool	The zpool to allocate from.
+ * @size	The amount of memory to allocate.
+ * @gfp		The GFP flags to use when allocating memory.
+ * @handle	Pointer to the handle to set
+ *
+ * This allocates the requested amount of memory from the pool.
+ * The gfp flags will be used when allocating memory, if the
+ * implementation supports it.  The provided @handle will be
+ * set to the allocated object handle.
+ *
+ * Implementations must guarantee this to be thread-safe.
+ *
+ * Returns: 0 on success, negative value on error.
+ */
+int zpool_malloc(struct zpool *zpool, size_t size, gfp_t gfp,
+			unsigned long *handle)
+{
+	return zpool->driver->malloc(zpool->pool, size, gfp, handle);
+}
+
+/**
+ * zpool_free() - Free previously allocated memory
+ * @pool	The zpool that allocated the memory.
+ * @handle	The handle to the memory to free.
+ *
+ * This frees previously allocated memory.  This does not guarantee
+ * that the pool will actually free memory, only that the memory
+ * in the pool will become available for use by the pool.
+ *
+ * Implementations must guarantee this to be thread-safe,
+ * however only when freeing different handles.  The same
+ * handle should only be freed once, and should not be used
+ * after freeing.
+ */
+void zpool_free(struct zpool *zpool, unsigned long handle)
+{
+	zpool->driver->free(zpool->pool, handle);
+}
+
+/**
+ * zpool_shrink() - Shrink the pool size
+ * @pool	The zpool to shrink.
+ * @pages	The number of pages to shrink the pool.
+ * @reclaimed	The number of pages successfully evicted.
+ *
+ * This attempts to shrink the actual memory size of the pool
+ * by evicting currently used handle(s).  If the pool was
+ * created with no zpool_ops, or the evict call fails for any
+ * of the handles, this will fail.  If non-NULL, the @reclaimed
+ * parameter will be set to the number of pages reclaimed,
+ * which may be more than the number of pages requested.
+ *
+ * Implementations must guarantee this to be thread-safe.
+ *
+ * Returns: 0 on success, negative value on error/failure.
+ */
+int zpool_shrink(struct zpool *zpool, unsigned int pages,
+			unsigned int *reclaimed)
+{
+	return zpool->driver->shrink(zpool->pool, pages, reclaimed);
+}
+
+/**
+ * zpool_map_handle() - Map a previously allocated handle into memory
+ * @pool	The zpool that the handle was allocated from
+ * @handle	The handle to map
+ * @mm		How the memory should be mapped
+ *
+ * This maps a previously allocated handle into memory.  The @mm
+ * param indicates to the implementation how the memory will be
+ * used, i.e. read-only, write-only, read-write.  If the
+ * implementation does not support it, the memory will be treated
+ * as read-write.
+ *
+ * This may hold locks, disable interrupts, and/or preemption,
+ * and the zpool_unmap_handle() must be called to undo those
+ * actions.  The code that uses the mapped handle should complete
+ * its operatons on the mapped handle memory quickly and unmap
+ * as soon as possible.  As the implementation may use per-cpu
+ * data, multiple handles should not be mapped concurrently on
+ * any cpu.
+ *
+ * Returns: A pointer to the handle's mapped memory area.
+ */
+void *zpool_map_handle(struct zpool *zpool, unsigned long handle,
+			enum zpool_mapmode mapmode)
+{
+	return zpool->driver->map(zpool->pool, handle, mapmode);
+}
+
+/**
+ * zpool_unmap_handle() - Unmap a previously mapped handle
+ * @pool	The zpool that the handle was allocated from
+ * @handle	The handle to unmap
+ *
+ * This unmaps a previously mapped handle.  Any locks or other
+ * actions that the implementation took in zpool_map_handle()
+ * will be undone here.  The memory area returned from
+ * zpool_map_handle() should no longer be used after this.
+ */
+void zpool_unmap_handle(struct zpool *zpool, unsigned long handle)
+{
+	zpool->driver->unmap(zpool->pool, handle);
+}
+
+/**
+ * zpool_get_total_size() - The total size of the pool
+ * @pool	The zpool to check
+ *
+ * This returns the total size in bytes of the pool.
+ *
+ * Returns: Total size of the zpool in bytes.
+ */
+u64 zpool_get_total_size(struct zpool *zpool)
+{
+	return zpool->driver->total_size(zpool->pool);
+}
+
+static int __init init_zpool(void)
+{
+	pr_info("loaded\n");
+	return 0;
+}
+
+static void __exit exit_zpool(void)
+{
+	pr_info("unloaded\n");
+}
+
+module_init(init_zpool);
+module_exit(exit_zpool);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Dan Streetman <ddstreet@ieee.org>");
+MODULE_DESCRIPTION("Common API for compressed memory storage");
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index fe78189..4cd5479 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -240,7 +240,6 @@ struct mapping_area {
 	enum zs_mapmode vm_mm; /* mapping mode */
 };
 
-
 /* per-cpu VM mapping areas for zspage accesses that cross page boundaries */
 static DEFINE_PER_CPU(struct mapping_area, zs_map_area);
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
