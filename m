Date: Thu, 14 Nov 2002 02:09:34 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH][RFC] uClinux slab limits
Message-ID: <20021114020934.A17934@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: manfred@colorfullife.com, akpm@digeo.com
Cc: gerg@snapgear.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Manfred, Andrew,

I'm helping out Greg in getting the core uClinux bits merged
and managed to get most stuff real non-intrusive.  There's one
thing I'd like to have a few comments on, that's the maximum
allowed allocation size in the slab allocator.  uClinux (aka
the mmuless ports, the uClinux get a bit strange now that it's
partially merged) don't support vmalloc naturally and thus need
much large slab size, there's also an option to allow even
large ones.  Are the ifdefs in the below patch okay, or should
we rather have an asm/ header for this?


--- linux-2.5.47/mm/slab.c	Tue Nov 12 11:46:02 2002
+++ linux-2.5.47-uc0/mm/slab.c	Tue Nov 12 11:51:08 2002
@@ -344,8 +344,20 @@
 
 #endif
 
-/* maximum size of an obj (in 2^order pages) */
+/*
+ * Maximum size of an obj (in 2^order pages)
+ * and absolute limit for the gfp order.
+ */
+#ifdef CONFIG_MMU
 #define	MAX_OBJ_ORDER	5	/* 32 pages */
+#define	MAX_GFP_ORDER	5	/* 32 pages */
+#elif defined (CONFIG_LARGE_ALLOCS)
+#define	MAX_OBJ_ORDER	13	/* up to 32Mb */
+#define	MAX_GFP_ORDER	13	/* up to 32Mb */
+#else
+#define	MAX_OBJ_ORDER	8	/* up to 1Mb */
+#define	MAX_GFP_ORDER	8	/* up to 1Mb */
+#endif
 
 /*
  * Do not go above this order unless 0 objects fit into the slab.
@@ -354,12 +366,6 @@
 #define	BREAK_GFP_ORDER_LO	1
 static int slab_break_gfp_order = BREAK_GFP_ORDER_LO;
 
-/*
- * Absolute limit for the gfp order
- */
-#define	MAX_GFP_ORDER	5	/* 32 pages */
-
-
 /* Macros for storing/retrieving the cachep and or slab from the
  * global 'mem_map'. These are used to find the slab an obj belongs to.
  * With kfree(), these are used to find the cache which an obj belongs to.
@@ -399,6 +405,18 @@
 	{ 32768,	NULL, NULL},
 	{ 65536,	NULL, NULL},
 	{131072,	NULL, NULL},
+#ifndef CONFIG_MMU
+	{262144,	NULL, NULL},
+	{524288,	NULL, NULL},
+	{1048576,	NULL, NULL},
+#ifdef CONFIG_LARGE_ALLOCS
+	{2097152,	NULL, NULL},
+	{4194304,	NULL, NULL},
+	{8388608,	NULL, NULL},
+	{16777216,	NULL, NULL},
+	{33554432,	NULL, NULL},
+#endif /* CONFIG_LARGE_ALLOCS */
+#endif /* CONFIG_MMU */
 	{     0,	NULL, NULL}
 };
 /* Must match cache_sizes above. Out of line to keep cache footprint low. */
@@ -427,7 +445,19 @@
 	CN("size-16384"),
 	CN("size-32768"),
 	CN("size-65536"),
-	CN("size-131072")
+	CN("size-131072"),
+#ifndef CONFIG_MMU
+	CN("size-262144"),
+	CN("size-524288"),
+	CN("size-1048576"),
+#ifdef CONFIG_LARGE_ALLOCS
+	CN("size-2097152"),
+	CN("size-4194304"),
+	CN("size-8388608"),
+	CN("size-16777216"),
+	CN("size-33554432"),
+#endif /* CONFIG_LARGE_ALLOCS */
+#endif /* CONFIG_MMU */
 }; 
 #undef CN
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
