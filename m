Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 32E9B6B0009
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 19:34:35 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id 4so44061893pfd.1
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 16:34:35 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ny6si53783466pab.59.2016.03.01.16.34.34
        for <linux-mm@kvack.org>;
        Tue, 01 Mar 2016 16:34:34 -0800 (PST)
Subject: [PATCH v2] mm: exclude ZONE_DEVICE from GFP_ZONE_TABLE
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 01 Mar 2016 16:32:04 -0800
Message-ID: <20160302002829.38211.89593.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Mark <markk@clara.co.uk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Sudip Mukherjee <sudipm.mukherjee@gmail.com>, Vlastimil Babka <vbabka@suse.cz>

ZONE_DEVICE (merged in 4.3) and ZONE_CMA (proposed) are examples of new
mm zones that are bumping up against the current maximum limit of 4
zones, i.e. 2 bits in page->flags for the GFP_ZONE_TABLE.

The GFP_ZONE_TABLE poses an interesting constraint since
include/linux/gfp.h gets included by the 32-bit portion of a 64-bit
build.  We need to be careful to only build the table for zones that
have a corresponding gfp_t flag.  GFP_ZONES_SHIFT is introduced for this
purpose.  This patch does not attempt to solve the problem of adding a
new zone that also has a corresponding GFP_ flag.

Vlastimil points out that ZONE_DEVICE, by depending on x86_64 and
SPARSEMEM_VMEMMAP implies that SECTIONS_WIDTH is zero.  In other words
even though ZONE_DEVICE does not fit in GFP_ZONE_TABLE it is free to
consume another bit in page->flags (expand ZONES_WIDTH) with room to
spare.

Link: https://bugzilla.kernel.org/show_bug.cgi?id=110931
Fixes: 033fbae988fc ("mm: ZONE_DEVICE for "device memory"")
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Reported-by: Mark <markk@clara.co.uk>
Reported-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
Changes since v1 [1]:

1/ Drop NR_ZONES_EXTENDED and its adjustments to NODES_SHIFT, we have
   enough room in page flags given the current config constraints of
   ZONE_DEVICE that imply that SECTIONS_WIDTH is zero. (Vlastimil).

2/ Fold in the 80 column fixes from
   mm-config_nr_zones_extended-fix.patch (Andrew)

[1]: http://marc.info/?l=linux-mm&m=145396199024296&w=2

 include/linux/gfp.h               |   33 ++++++++++++++++++++-------------
 include/linux/page-flags-layout.h |    2 ++
 mm/Kconfig                        |    2 --
 3 files changed, 22 insertions(+), 15 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index af1f2b24bbe4..dddd4767bd2f 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -329,22 +329,29 @@ static inline bool gfpflags_allow_blocking(const gfp_t gfp_flags)
  *       0xe    => BAD (MOVABLE+DMA32+HIGHMEM)
  *       0xf    => BAD (MOVABLE+DMA32+HIGHMEM+DMA)
  *
- * ZONES_SHIFT must be <= 2 on 32 bit platforms.
+ * GFP_ZONES_SHIFT must be <= 2 on 32 bit platforms.
  */
 
-#if 16 * ZONES_SHIFT > BITS_PER_LONG
-#error ZONES_SHIFT too large to create GFP_ZONE_TABLE integer
+#if defined(CONFIG_ZONE_DEVICE) && (MAX_NR_ZONES-1) <= 4
+/* ZONE_DEVICE is not a valid GFP zone specifier */
+#define GFP_ZONES_SHIFT 2
+#else
+#define GFP_ZONES_SHIFT ZONES_SHIFT
+#endif
+
+#if 16 * GFP_ZONES_SHIFT > BITS_PER_LONG
+#error GFP_ZONES_SHIFT too large to create GFP_ZONE_TABLE integer
 #endif
 
 #define GFP_ZONE_TABLE ( \
-	(ZONE_NORMAL << 0 * ZONES_SHIFT)				      \
-	| (OPT_ZONE_DMA << ___GFP_DMA * ZONES_SHIFT)			      \
-	| (OPT_ZONE_HIGHMEM << ___GFP_HIGHMEM * ZONES_SHIFT)		      \
-	| (OPT_ZONE_DMA32 << ___GFP_DMA32 * ZONES_SHIFT)		      \
-	| (ZONE_NORMAL << ___GFP_MOVABLE * ZONES_SHIFT)			      \
-	| (OPT_ZONE_DMA << (___GFP_MOVABLE | ___GFP_DMA) * ZONES_SHIFT)	      \
-	| (ZONE_MOVABLE << (___GFP_MOVABLE | ___GFP_HIGHMEM) * ZONES_SHIFT)   \
-	| (OPT_ZONE_DMA32 << (___GFP_MOVABLE | ___GFP_DMA32) * ZONES_SHIFT)   \
+	(ZONE_NORMAL << 0 * GFP_ZONES_SHIFT)				       \
+	| (OPT_ZONE_DMA << ___GFP_DMA * GFP_ZONES_SHIFT)		       \
+	| (OPT_ZONE_HIGHMEM << ___GFP_HIGHMEM * GFP_ZONES_SHIFT)	       \
+	| (OPT_ZONE_DMA32 << ___GFP_DMA32 * GFP_ZONES_SHIFT)		       \
+	| (ZONE_NORMAL << ___GFP_MOVABLE * GFP_ZONES_SHIFT)		       \
+	| (OPT_ZONE_DMA << (___GFP_MOVABLE | ___GFP_DMA) * GFP_ZONES_SHIFT)    \
+	| (ZONE_MOVABLE << (___GFP_MOVABLE | ___GFP_HIGHMEM) * GFP_ZONES_SHIFT)\
+	| (OPT_ZONE_DMA32 << (___GFP_MOVABLE | ___GFP_DMA32) * GFP_ZONES_SHIFT)\
 )
 
 /*
@@ -369,8 +376,8 @@ static inline enum zone_type gfp_zone(gfp_t flags)
 	enum zone_type z;
 	int bit = (__force int) (flags & GFP_ZONEMASK);
 
-	z = (GFP_ZONE_TABLE >> (bit * ZONES_SHIFT)) &
-					 ((1 << ZONES_SHIFT) - 1);
+	z = (GFP_ZONE_TABLE >> (bit * GFP_ZONES_SHIFT)) &
+					 ((1 << GFP_ZONES_SHIFT) - 1);
 	VM_BUG_ON((GFP_ZONE_BAD >> bit) & 1);
 	return z;
 }
diff --git a/include/linux/page-flags-layout.h b/include/linux/page-flags-layout.h
index da523661500a..77b078c103b2 100644
--- a/include/linux/page-flags-layout.h
+++ b/include/linux/page-flags-layout.h
@@ -17,6 +17,8 @@
 #define ZONES_SHIFT 1
 #elif MAX_NR_ZONES <= 4
 #define ZONES_SHIFT 2
+#elif MAX_NR_ZONES <= 8
+#define ZONES_SHIFT 3
 #else
 #error ZONES_SHIFT -- too many zones configured adjust calculation
 #endif
diff --git a/mm/Kconfig b/mm/Kconfig
index 03cbfa072f42..664fa2416909 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -652,8 +652,6 @@ config IDLE_PAGE_TRACKING
 
 config ZONE_DEVICE
 	bool "Device memory (pmem, etc...) hotplug support" if EXPERT
-	default !ZONE_DMA
-	depends on !ZONE_DMA
 	depends on MEMORY_HOTPLUG
 	depends on MEMORY_HOTREMOVE
 	depends on X86_64 #arch_add_memory() comprehends device memory

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
