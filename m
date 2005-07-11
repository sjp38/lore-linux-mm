Date: Sun, 10 Jul 2005 18:58:48 -0700 (PDT)
From: Paul Jackson <pj@sgi.com>
Message-Id: <20050711015848.23183.13682.sendpatchset@tomahawk.engr.sgi.com>
In-Reply-To: <20050711015835.23183.40213.sendpatchset@tomahawk.engr.sgi.com>
References: <20050711015835.23183.40213.sendpatchset@tomahawk.engr.sgi.com>
Subject: [PATCH 2/4] cpusets new __GFP_HARDWALL flag
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dinakar Guniguntala <dino@in.ibm.com>, Erich Focht <efocht@hpce.nec.com>, Simon Derr <Simon.Derr@bull.net>
Cc: linux-mm@kvack.org, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>

Add another GFP flag: __GFP_HARDWALL.

A subsequent "cpuset_zone_allowed" patch will use this flag to mark
GFP_USER allocations, and distinguish them from GFP_KERNEL allocations.

Allocations (such as GFP_USER) marked GFP_HARDWALL are constrainted to
the current tasks cpuset.  Other allocations (such as GFP_KERNEL) can
steal from the possibly larger nearest mem_exclusive cpuset ancestor,
if memory is tight on every node in the current cpuset.

This patch collides with Mel Gorman's patch to reduce fragmentation
in the standard buddy allocator, which adds two GFP flags.  At first
glance, it seems that his added __GFP_USERRCLM flag could be used in
place of the following __GFP_HARDWALL, as they both seem to be set
the same way - for GFP_USER and GFP_HIGHUSER.  Perhaps we should call
this flag __GFP_USER, rather than some name dependent on its use(s).

Signed-off-by: Paul Jackson <pj@sgi.com>

Index: linux-2.6-mem_exclusive/include/linux/gfp.h
===================================================================
--- linux-2.6-mem_exclusive.orig/include/linux/gfp.h	2005-07-02 17:42:02.000000000 -0700
+++ linux-2.6-mem_exclusive/include/linux/gfp.h	2005-07-02 17:43:00.000000000 -0700
@@ -40,6 +40,7 @@ struct vm_area_struct;
 #define __GFP_ZERO	0x8000u	/* Return zeroed page on success */
 #define __GFP_NOMEMALLOC 0x10000u /* Don't use emergency reserves */
 #define __GFP_NORECLAIM  0x20000u /* No zone reclaim during page_cache_alloc */
+#define __GFP_HARDWALL   0x40000u /* Enforce hardwall cpuset memory allocs */
 
 #define __GFP_BITS_SHIFT 20	/* Room for 20 __GFP_FOO bits */
 #define __GFP_BITS_MASK ((1 << __GFP_BITS_SHIFT) - 1)
@@ -48,14 +49,15 @@ struct vm_area_struct;
 #define GFP_LEVEL_MASK (__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_FS| \
 			__GFP_COLD|__GFP_NOWARN|__GFP_REPEAT| \
 			__GFP_NOFAIL|__GFP_NORETRY|__GFP_NO_GROW|__GFP_COMP| \
-			__GFP_NOMEMALLOC|__GFP_NORECLAIM)
+			__GFP_NOMEMALLOC|__GFP_NORECLAIM|__GFP_HARDWALL)
 
 #define GFP_ATOMIC	(__GFP_HIGH)
 #define GFP_NOIO	(__GFP_WAIT)
 #define GFP_NOFS	(__GFP_WAIT | __GFP_IO)
 #define GFP_KERNEL	(__GFP_WAIT | __GFP_IO | __GFP_FS)
-#define GFP_USER	(__GFP_WAIT | __GFP_IO | __GFP_FS)
-#define GFP_HIGHUSER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HIGHMEM)
+#define GFP_USER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL)
+#define GFP_HIGHUSER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL | \
+			 __GFP_HIGHMEM)
 
 /* Flag - indicates that the buffer will be suitable for DMA.  Ignored on some
    platforms, used as appropriate on others */

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
