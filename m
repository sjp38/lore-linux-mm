Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id CC9BB6B03C7
	for <linux-mm@kvack.org>; Mon,  8 May 2017 09:22:10 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id d127so5117384wmf.15
        for <linux-mm@kvack.org>; Mon, 08 May 2017 06:22:10 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id z71si15213088wrb.48.2017.05.08.06.22.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 May 2017 06:22:09 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [PATCH 1/1] mm: Rework slab bitmasks
Date: Mon, 8 May 2017 16:20:22 +0300
Message-ID: <20170508132022.15488-2-igor.stoppa@huawei.com>
In-Reply-To: <20170508132022.15488-1-igor.stoppa@huawei.com>
References: <20170508132022.15488-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, Igor Stoppa <igor.stoppa@huawei.com>

The bitmasks defined in the slab header can be made more readable by
using the BIT() macro.

Furthermore, several conditional definitions can be collapsed, by
expressing their value as a function of the configuration paramter that
controles them, using the macro IS_ENABLED().

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
---
 include/linux/slab.h | 71 +++++++++++++++++++++++-----------------------------
 1 file changed, 31 insertions(+), 40 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 3c37a8c..f7e55f0 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -15,18 +15,24 @@
 #include <linux/types.h>
 #include <linux/workqueue.h>
 
+#define __BIT_VAL(val, shift) (((unsigned long)(val != 0)) << (shift))
+#define BIT_VAL(val, shift) __BIT_VAL(val, shift)
+#define BIT_CFG(cfg, shift) __BIT_VAL(IS_ENABLED(CONFIG_##cfg), shift)
+#define BIT_DBG(dbg, shift) BIT_CFG(DEBUG_##dbg, shift)
+#define BIT_DBG_SLAB(shift)  BIT_DBG(SLAB, shift)
 
 /*
  * Flags to pass to kmem_cache_create().
  * The ones marked DEBUG are only valid if CONFIG_DEBUG_SLAB is set.
  */
-#define SLAB_CONSISTENCY_CHECKS	0x00000100UL	/* DEBUG: Perform (expensive) checks on alloc/free */
-#define SLAB_RED_ZONE		0x00000400UL	/* DEBUG: Red zone objs in a cache */
-#define SLAB_POISON		0x00000800UL	/* DEBUG: Poison objects */
-#define SLAB_HWCACHE_ALIGN	0x00002000UL	/* Align objs on cache lines */
-#define SLAB_CACHE_DMA		0x00004000UL	/* Use GFP_DMA memory */
-#define SLAB_STORE_USER		0x00010000UL	/* DEBUG: Store the last owner for bug hunting */
-#define SLAB_PANIC		0x00040000UL	/* Panic if kmem_cache_create() fails */
+
+#define SLAB_CONSISTENCY_CHECKS	BIT_DBG_SLAB(8)   /* Perform (expensive) checks on alloc/free */
+#define SLAB_RED_ZONE		BIT_DBG_SLAB(10)  /* Red zone objs in a cache */
+#define SLAB_POISON		BIT_DBG_SLAB(11)  /* Poison objects */
+#define SLAB_HWCACHE_ALIGN	BIT(13)           /* Align objs on cache lines */
+#define SLAB_CACHE_DMA		BIT(14)           /* Use GFP_DMA memory */
+#define SLAB_STORE_USER		BIT_DBG_SLAB(16)  /* Store the last owner for bug hunting */
+#define SLAB_PANIC		BIT(18)           /* Panic if kmem_cache_create() fails */
 /*
  * SLAB_DESTROY_BY_RCU - **WARNING** READ THIS!
  *
@@ -62,44 +68,29 @@
  * rcu_read_lock before reading the address, then rcu_read_unlock after
  * taking the spinlock within the structure expected at that address.
  */
-#define SLAB_DESTROY_BY_RCU	0x00080000UL	/* Defer freeing slabs to RCU */
-#define SLAB_MEM_SPREAD		0x00100000UL	/* Spread some memory over cpuset */
-#define SLAB_TRACE		0x00200000UL	/* Trace allocations and frees */
+#define SLAB_DESTROY_BY_RCU	BIT(19)         /* Defer freeing slabs to RCU */
+#define SLAB_MEM_SPREAD		BIT(20)         /* Spread some memory over cpuset */
+#define SLAB_TRACE		BIT(21)         /* Trace allocations and frees */
 
 /* Flag to prevent checks on free */
-#ifdef CONFIG_DEBUG_OBJECTS
-# define SLAB_DEBUG_OBJECTS	0x00400000UL
-#else
-# define SLAB_DEBUG_OBJECTS	0x00000000UL
-#endif
+# define SLAB_DEBUG_OBJECTS	BIT_DBG(OBJECTS, 22)
 
-#define SLAB_NOLEAKTRACE	0x00800000UL	/* Avoid kmemleak tracing */
+#define SLAB_NOLEAKTRACE	BIT(23)         /* Avoid kmemleak tracing */
 
 /* Don't track use of uninitialized memory */
-#ifdef CONFIG_KMEMCHECK
-# define SLAB_NOTRACK		0x01000000UL
-#else
-# define SLAB_NOTRACK		0x00000000UL
-#endif
-#ifdef CONFIG_FAILSLAB
-# define SLAB_FAILSLAB		0x02000000UL	/* Fault injection mark */
-#else
-# define SLAB_FAILSLAB		0x00000000UL
-#endif
-#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
-# define SLAB_ACCOUNT		0x04000000UL	/* Account to memcg */
-#else
-# define SLAB_ACCOUNT		0x00000000UL
-#endif
+# define SLAB_NOTRACK		BIT_CFG(KMEMCHECK, 24)
 
-#ifdef CONFIG_KASAN
-#define SLAB_KASAN		0x08000000UL
-#else
-#define SLAB_KASAN		0x00000000UL
-#endif
+/* Fault injection mark */
+# define SLAB_FAILSLAB		BIT_CFG(FAILSLAB, 25)
+
+/* Account to memcg */
+# define SLAB_ACCOUNT		BIT_VAL(IS_ENABLED(CONFIG_MEMCG) && \
+				        !IS_ENABLED(CONFIG_SLOB), 26)
+
+#define SLAB_KASAN		BIT_CFG(KASAN, 27)
 
 /* The following flags affect the page allocator grouping pages by mobility */
-#define SLAB_RECLAIM_ACCOUNT	0x00020000UL		/* Objects are reclaimable */
+#define SLAB_RECLAIM_ACCOUNT	BIT(17)                 /* Objects are reclaimable */
 #define SLAB_TEMPORARY		SLAB_RECLAIM_ACCOUNT	/* Objects are short-lived */
 /*
  * ZERO_SIZE_PTR will be returned for zero sized kmalloc requests.
@@ -246,9 +237,9 @@ static inline const char *__check_heap_object(const void *ptr,
 #endif
 
 /* Maximum allocatable size */
-#define KMALLOC_MAX_SIZE	(1UL << KMALLOC_SHIFT_MAX)
+#define KMALLOC_MAX_SIZE	BIT(KMALLOC_SHIFT_MAX)
 /* Maximum size for which we actually use a slab cache */
-#define KMALLOC_MAX_CACHE_SIZE	(1UL << KMALLOC_SHIFT_HIGH)
+#define KMALLOC_MAX_CACHE_SIZE	BIT(KMALLOC_SHIFT_HIGH)
 /* Maximum order allocatable via the slab allocagtor */
 #define KMALLOC_MAX_ORDER	(KMALLOC_SHIFT_MAX - PAGE_SHIFT)
 
@@ -256,7 +247,7 @@ static inline const char *__check_heap_object(const void *ptr,
  * Kmalloc subsystem.
  */
 #ifndef KMALLOC_MIN_SIZE
-#define KMALLOC_MIN_SIZE (1 << KMALLOC_SHIFT_LOW)
+#define KMALLOC_MIN_SIZE        BIT(KMALLOC_SHIFT_LOW)
 #endif
 
 /*
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
