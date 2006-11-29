Date: Tue, 28 Nov 2006 16:30:31 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Re: [RFC] Extract kmalloc.h and slob.h from slab.h
In-Reply-To: <84144f020611281132p5f3f042dq36728c78521efb57@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0611281629250.11531@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0611272229290.6012@schroedinger.engr.sgi.com>
 <84144f020611280000w26d74321i2804b3d04b87762@mail.gmail.com>
 <Pine.LNX.4.64.0611281003190.8764@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611282104170.32289@sbz-30.cs.Helsinki.FI>
 <Pine.LNX.4.64.0611281109150.9370@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611282118140.1597@sbz-30.cs.Helsinki.FI>
 <Pine.LNX.4.64.0611281123400.9465@schroedinger.engr.sgi.com>
 <84144f020611281132p5f3f042dq36728c78521efb57@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: akpm@osdl.org, linux-mm@kvack.org, mpm@selenic.com, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

Patch on top of the other to remove the #ifdefs. Also add some annotation
on the other ifdefs.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc6-mm1/include/linux/kmalloc.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/linux/kmalloc.h	2006-11-28 15:28:50.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/linux/kmalloc.h	2006-11-28 15:31:26.000000000 -0800
@@ -5,8 +5,6 @@
 #include <asm/page.h>		/* kmalloc_sizes.h needs PAGE_SIZE */
 #include <asm/cache.h>		/* kmalloc_sizes.h needs L1_CACHE_BYTES */
 
-#ifdef __KERNEL__
-
 /* Size description struct for general caches. */
 struct cache_sizes {
 	size_t		 cs_size;
@@ -201,8 +199,8 @@
 #define kmalloc_node_track_caller(size, flags, node) \
 	__kmalloc_node_track_caller(size, flags, node, \
 				__builtin_return_address(0))
-#endif
-#else
+#endif /* CONFIG_DEBUG_SLAB */
+#else /* CONFIG_NUMA */
 static inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 {
 	return kmalloc(size, flags);
@@ -210,12 +208,10 @@
 
 #define kmalloc_node_track_caller(size, flags, node) \
 	kmalloc_track_caller(size, flags)
-#endif
+#endif /* CONFIG_NUMA */
 
 extern void __init kmem_cache_init(void);
 extern int slab_is_available(void);
 extern int kmem_cache_reap(int);
 
-#endif	/* __KERNEL__ */
-
 #endif	/* _LINUX_KMALLOC_H */
Index: linux-2.6.19-rc6-mm1/include/linux/slob.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/linux/slob.h	2006-11-28 15:28:50.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/linux/slob.h	2006-11-28 15:31:26.000000000 -0800
@@ -1,8 +1,6 @@
 #ifndef _LINUX_SLOB_H
 #define	_LINUX_SLOB_H
 
-#if	defined(__KERNEL__)
-
 #include <linux/slab.h>
 
 /* SLOB allocator routines */
@@ -42,6 +40,4 @@
 static inline void kmem_set_shrinker(kmem_cache_t *cachep,
 				struct shrinker *shrinker) {}
 
-#endif	/* __KERNEL__ */
-
 #endif	/* _LINUX_SLOB_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
