Received: from wli by holomorphy with local (Exim 3.34 #1 (Debian))
	id 17uRQ1-0002jn-00
	for <linux-mm@kvack.org>; Wed, 25 Sep 2002 22:42:33 -0700
Date: Wed, 25 Sep 2002 22:42:33 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: [3/13] add __GFP_NOKILL to SLAB_KERNEL
Message-ID: <20020926054233.GJ22942@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Slab allocations are failable, hence any SLAB_KERNEL allocation should
be failed when not serviceable instead of killing innocent tasks. In
particular, vm_area_structs, temporary filename buffers (getname),
dentries, inodes, filp's, task_structs, and some others were all seen to
trigger the OOM killer. It seemed best to consolidate it in SLAB_KERNEL.


diff -urN linux-2.5.33/include/linux/slab.h linux-2.5.33-mm5/include/linux/slab.h
--- linux-2.5.33/include/linux/slab.h	2002-09-04 04:02:00.000000000 -0700
+++ linux-2.5.33-mm5/include/linux/slab.h	2002-09-08 20:55:27.000000000 -0700
@@ -20,10 +20,10 @@
 #define SLAB_NOHIGHIO		GFP_NOHIGHIO
 #define	SLAB_ATOMIC		GFP_ATOMIC
 #define	SLAB_USER		GFP_USER
-#define	SLAB_KERNEL		GFP_KERNEL
+#define	SLAB_KERNEL		(GFP_KERNEL | __GFP_NOKILL)
 #define	SLAB_DMA		GFP_DMA
 
-#define SLAB_LEVEL_MASK		(__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_HIGHIO|__GFP_FS)
+#define SLAB_LEVEL_MASK		(__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_HIGHIO|__GFP_FS|__GFP_NOKILL)
 #define	SLAB_NO_GROW		0x00001000UL	/* don't grow a cache */
 
 /* flags to pass to kmem_cache_create().
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
