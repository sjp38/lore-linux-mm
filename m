Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3E1E06B0253
	for <linux-mm@kvack.org>; Sat, 21 Oct 2017 06:06:40 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id s9so7012974wrc.16
        for <linux-mm@kvack.org>; Sat, 21 Oct 2017 03:06:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j18sor1161782wrd.31.2017.10.21.03.06.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 21 Oct 2017 03:06:38 -0700 (PDT)
Date: Sat, 21 Oct 2017 13:06:35 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 2/2] slab, slub, slob: convert slab_flags_t to 32-bit
Message-ID: <20171021100635.GA8287@avx2>
References: <20171021100225.GA22428@avx2>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171021100225.GA22428@avx2>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, ecryptfs@vger.kernel.org, linux-xfs@vger.kernel.org, kasan-dev@googlegroups.com, netdev@vger.kernel.org

struct kmem_cache::flags is "unsigned long" which is unnecessary on
64-bit as no flags are defined in the higher bits.

Switch the field to 32-bit and save some space on x86_64 until such
flags appear:

	add/remove: 0/0 grow/shrink: 0/107 up/down: 0/-657 (-657)
	function                                     old     new   delta
	sysfs_slab_add                               720     719      -1
				...
	check_object                                 699     676     -23

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/linux/slab.h  |   44 ++++++++++++++++++++++----------------------
 include/linux/types.h |    2 +-
 mm/slab.c             |    4 ++--
 mm/slub.c             |    4 ++--
 4 files changed, 27 insertions(+), 27 deletions(-)

--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -21,19 +21,19 @@
  * The ones marked DEBUG are only valid if CONFIG_DEBUG_SLAB is set.
  */
 /* DEBUG: Perform (expensive) checks on alloc/free */
-#define SLAB_CONSISTENCY_CHECKS	((slab_flags_t __force)0x00000100UL)
+#define SLAB_CONSISTENCY_CHECKS	((slab_flags_t __force)0x00000100U)
 /* DEBUG: Red zone objs in a cache */
-#define SLAB_RED_ZONE		((slab_flags_t __force)0x00000400UL)
+#define SLAB_RED_ZONE		((slab_flags_t __force)0x00000400U)
 /* DEBUG: Poison objects */
-#define SLAB_POISON		((slab_flags_t __force)0x00000800UL)
+#define SLAB_POISON		((slab_flags_t __force)0x00000800U)
 /* Align objs on cache lines */
-#define SLAB_HWCACHE_ALIGN	((slab_flags_t __force)0x00002000UL)
+#define SLAB_HWCACHE_ALIGN	((slab_flags_t __force)0x00002000U)
 /* Use GFP_DMA memory */
-#define SLAB_CACHE_DMA		((slab_flags_t __force)0x00004000UL)
+#define SLAB_CACHE_DMA		((slab_flags_t __force)0x00004000U)
 /* DEBUG: Store the last owner for bug hunting */
-#define SLAB_STORE_USER		((slab_flags_t __force)0x00010000UL)
+#define SLAB_STORE_USER		((slab_flags_t __force)0x00010000U)
 /* Panic if kmem_cache_create() fails */
-#define SLAB_PANIC		((slab_flags_t __force)0x00040000UL)
+#define SLAB_PANIC		((slab_flags_t __force)0x00040000U)
 /*
  * SLAB_TYPESAFE_BY_RCU - **WARNING** READ THIS!
  *
@@ -72,50 +72,50 @@
  * Note that SLAB_TYPESAFE_BY_RCU was originally named SLAB_DESTROY_BY_RCU.
  */
 /* Defer freeing slabs to RCU */
-#define SLAB_TYPESAFE_BY_RCU	((slab_flags_t __force)0x00080000UL)
+#define SLAB_TYPESAFE_BY_RCU	((slab_flags_t __force)0x00080000U)
 /* Spread some memory over cpuset */
-#define SLAB_MEM_SPREAD		((slab_flags_t __force)0x00100000UL)
+#define SLAB_MEM_SPREAD		((slab_flags_t __force)0x00100000U)
 /* Trace allocations and frees */
-#define SLAB_TRACE		((slab_flags_t __force)0x00200000UL)
+#define SLAB_TRACE		((slab_flags_t __force)0x00200000U)
 
 /* Flag to prevent checks on free */
 #ifdef CONFIG_DEBUG_OBJECTS
-# define SLAB_DEBUG_OBJECTS	((slab_flags_t __force)0x00400000UL)
+# define SLAB_DEBUG_OBJECTS	((slab_flags_t __force)0x00400000U)
 #else
-# define SLAB_DEBUG_OBJECTS	((slab_flags_t __force)0x00000000UL)
+# define SLAB_DEBUG_OBJECTS	0
 #endif
 
 /* Avoid kmemleak tracing */
-#define SLAB_NOLEAKTRACE	((slab_flags_t __force)0x00800000UL)
+#define SLAB_NOLEAKTRACE	((slab_flags_t __force)0x00800000U)
 
 /* Don't track use of uninitialized memory */
 #ifdef CONFIG_KMEMCHECK
-# define SLAB_NOTRACK		((slab_flags_t __force)0x01000000UL)
+# define SLAB_NOTRACK		((slab_flags_t __force)0x01000000U)
 #else
-# define SLAB_NOTRACK		((slab_flags_t __force)0x00000000UL)
+# define SLAB_NOTRACK		0
 #endif
 /* Fault injection mark */
 #ifdef CONFIG_FAILSLAB
-# define SLAB_FAILSLAB		((slab_flags_t __force)0x02000000UL)
+# define SLAB_FAILSLAB		((slab_flags_t __force)0x02000000U)
 #else
-# define SLAB_FAILSLAB		((slab_flags_t __force)0x00000000UL)
+# define SLAB_FAILSLAB		0
 #endif
 /* Account to memcg */
 #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
-# define SLAB_ACCOUNT		((slab_flags_t __force)0x04000000UL)
+# define SLAB_ACCOUNT		((slab_flags_t __force)0x04000000U)
 #else
-# define SLAB_ACCOUNT		((slab_flags_t __force)0x00000000UL)
+# define SLAB_ACCOUNT		0
 #endif
 
 #ifdef CONFIG_KASAN
-#define SLAB_KASAN		((slab_flags_t __force)0x08000000UL)
+#define SLAB_KASAN		((slab_flags_t __force)0x08000000U)
 #else
-#define SLAB_KASAN		((slab_flags_t __force)0x00000000UL)
+#define SLAB_KASAN		0
 #endif
 
 /* The following flags affect the page allocator grouping pages by mobility */
 /* Objects are reclaimable */
-#define SLAB_RECLAIM_ACCOUNT	((slab_flags_t __force)0x00020000UL)
+#define SLAB_RECLAIM_ACCOUNT	((slab_flags_t __force)0x00020000U)
 #define SLAB_TEMPORARY		SLAB_RECLAIM_ACCOUNT	/* Objects are short-lived */
 /*
  * ZERO_SIZE_PTR will be returned for zero sized kmalloc requests.
--- a/include/linux/types.h
+++ b/include/linux/types.h
@@ -155,7 +155,7 @@ typedef u32 dma_addr_t;
 #endif
 
 typedef unsigned __bitwise gfp_t;
-typedef unsigned long __bitwise slab_flags_t;
+typedef unsigned __bitwise slab_flags_t;
 typedef unsigned __bitwise fmode_t;
 
 #ifdef CONFIG_PHYS_ADDR_T_64BIT
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -251,8 +251,8 @@ static void kmem_cache_node_init(struct kmem_cache_node *parent)
 	MAKE_LIST((cachep), (&(ptr)->slabs_free), slabs_free, nodeid);	\
 	} while (0)
 
-#define CFLGS_OBJFREELIST_SLAB	((slab_flags_t __force)0x40000000UL)
-#define CFLGS_OFF_SLAB		((slab_flags_t __force)0x80000000UL)
+#define CFLGS_OBJFREELIST_SLAB	((slab_flags_t __force)0x40000000U)
+#define CFLGS_OFF_SLAB		((slab_flags_t __force)0x80000000U)
 #define	OBJFREELIST_SLAB(x)	((x)->flags & CFLGS_OBJFREELIST_SLAB)
 #define	OFF_SLAB(x)	((x)->flags & CFLGS_OFF_SLAB)
 
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -193,9 +193,9 @@ static inline bool kmem_cache_has_cpu_partial(struct kmem_cache *s)
 
 /* Internal SLUB flags */
 /* Poison object */
-#define __OBJECT_POISON		((slab_flags_t __force)0x80000000UL)
+#define __OBJECT_POISON		((slab_flags_t __force)0x80000000U)
 /* Use cmpxchg_double */
-#define __CMPXCHG_DOUBLE	((slab_flags_t __force)0x40000000UL)
+#define __CMPXCHG_DOUBLE	((slab_flags_t __force)0x40000000U)
 
 /*
  * Tracking user of a slab.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
