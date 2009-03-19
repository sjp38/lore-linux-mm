Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 839C66B0047
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 12:56:54 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B9F1482C7CC
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 13:03:53 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 04w2JcP+Xn1p for <linux-mm@kvack.org>;
	Thu, 19 Mar 2009 13:03:47 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id A275C82C5F0
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 13:03:47 -0400 (EDT)
Date: Thu, 19 Mar 2009 12:53:34 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 24/27] Convert gfp_zone() to use a table of precalculated
 values
In-Reply-To: <alpine.DEB.1.10.0903191105090.8100@qirst.com>
Message-ID: <alpine.DEB.1.10.0903191251310.24152@qirst.com>
References: <1237226020-14057-1-git-send-email-mel@csn.ul.ie> <1237226020-14057-25-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0903161500280.20024@qirst.com> <20090318135222.GA4629@csn.ul.ie> <alpine.DEB.1.10.0903181011210.7901@qirst.com>
 <20090318153508.GA24462@csn.ul.ie> <alpine.DEB.1.10.0903181300540.15570@qirst.com> <20090318181717.GC24462@csn.ul.ie> <alpine.DEB.1.10.0903181507120.10154@qirst.com> <20090318194604.GD24462@csn.ul.ie> <20090319090456.fb11e23c.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.1.10.0903191105090.8100@qirst.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Thu, 19 Mar 2009, Christoph Lameter wrote:

> It would work if we could check for BAD_ZONE with a VM_BUG_ON or a
> BUILD_BUG_ON. If I get some time I will look into this.

Here is such a patch. Boots on my machine and working with that kernel
now. There is a slight gcc problem in that the table is likely repeated
for each compilation unit. Anyone know how to fix that?


Subject: Use a table lookup for gfp_zone and check for errors in flags passed to the page allocator

Use a table to lookup the zone to use given gfp_flags using gfp_zone().

This simplifies the code in gfp_zone() and also keeps the ability of the compiler to
use constant folding to get rid of gfp_zone processing.

One problem with this patch is that we define a static const array in gfp.h. This results
in every compilation unit to reserve its own space for the array. There must be some
trick to get the compiler to allocate this only once. The contents of the array
must be described in the header file otherwise the compiler will not be able to
determine the value of a lookup in the table.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

Index: linux-2.6/include/linux/gfp.h
===================================================================
--- linux-2.6.orig/include/linux/gfp.h	2009-03-19 11:43:32.000000000 -0500
+++ linux-2.6/include/linux/gfp.h	2009-03-19 11:48:38.000000000 -0500
@@ -19,7 +19,8 @@
 #define __GFP_DMA	((__force gfp_t)0x01u)
 #define __GFP_HIGHMEM	((__force gfp_t)0x02u)
 #define __GFP_DMA32	((__force gfp_t)0x04u)
-
+#define __GFP_MOVABLE	((__force gfp_t)0x08u)  /* Page is movable */
+#define GFP_ZONEMASK	((__force gfp_t)0x0fu)
 /*
  * Action modifiers - doesn't change the zoning
  *
@@ -49,7 +50,6 @@
 #define __GFP_HARDWALL   ((__force gfp_t)0x20000u) /* Enforce hardwall cpuset memory allocs */
 #define __GFP_THISNODE	((__force gfp_t)0x40000u)/* No fallback, no policies */
 #define __GFP_RECLAIMABLE ((__force gfp_t)0x80000u) /* Page is reclaimable */
-#define __GFP_MOVABLE	((__force gfp_t)0x100000u)  /* Page is movable */

 #define __GFP_BITS_SHIFT 21	/* Room for 21 __GFP_FOO bits */
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
@@ -111,24 +111,56 @@
 		((gfp_flags & __GFP_RECLAIMABLE) != 0);
 }

-static inline enum zone_type gfp_zone(gfp_t flags)
-{
+#ifdef CONFIG_ZONE_HIGHMEM
+#define OPT_ZONE_HIGHMEM ZONE_HIGHMEM
+#else
+#define OPT_ZONE_HIGHMEM ZONE_NORMAL
+#endif
+
 #ifdef CONFIG_ZONE_DMA
-	if (flags & __GFP_DMA)
-		return ZONE_DMA;
+#define OPT_ZONE_DMA ZONE_DMA
+#else
+#define OPT_ZONE_DMA ZONE_NORMAL
 #endif
+
 #ifdef CONFIG_ZONE_DMA32
-	if (flags & __GFP_DMA32)
-		return ZONE_DMA32;
+#define OPT_ZONE_DMA32 ZONE_DMA32
+#else
+#define OPT_ZONE_DMA32 OPT_ZONE_DMA
 #endif
-	if ((flags & (__GFP_HIGHMEM | __GFP_MOVABLE)) ==
-			(__GFP_HIGHMEM | __GFP_MOVABLE))
-		return ZONE_MOVABLE;
-#ifdef CONFIG_HIGHMEM
-	if (flags & __GFP_HIGHMEM)
-		return ZONE_HIGHMEM;
+
+#define BAD_ZONE MAX_NR_ZONES
+
+static const enum zone_type gfp_zone_table[GFP_ZONEMASK + 1] = {
+	ZONE_NORMAL,		/* 00 No flags set */
+	OPT_ZONE_DMA,		/* 01 GFP_DMA */
+	OPT_ZONE_HIGHMEM,	/* 02 GFP_HIGHMEM */
+	BAD_ZONE,		/* 03 GFP_HIGHMEM GFP_DMA */
+	OPT_ZONE_DMA32,		/* 04 GFP_DMA32 */
+	BAD_ZONE,		/* 05 GFP_DMA32 GFP_DMA */
+	BAD_ZONE,		/* 06 GFP_DMA32 GFP_HIGHMEM */
+	BAD_ZONE,		/* 07 GFP_DMA32 GFP_HIGHMEM GFP_DMA */
+	ZONE_NORMAL,		/* 08 ZONE_MOVABLE */
+	OPT_ZONE_DMA,		/* 09 MOVABLE + DMA */
+	ZONE_MOVABLE,		/* 0A MOVABLE + HIGHMEM */
+	BAD_ZONE,		/* 0B MOVABLE + HIGHMEM + DMA */
+	OPT_ZONE_DMA32,		/* 0C MOVABLE + DMA32 */
+	BAD_ZONE,		/* 0D MOVABLE + DMA32 + DMA */
+	BAD_ZONE,		/* 0E MOVABLE + DMA32 + HIGHMEM */
+	BAD_ZONE		/* 0F MOVABLE + DMA32 + HIGHMEM + DMA */
+};
+
+static inline enum zone_type gfp_zone(gfp_t flags)
+{
+	enum zone_type zone = gfp_zone_table[flags & 0xf];
+
+	if (__builtin_constant_p(zone))
+		BUILD_BUG_ON(zone == BAD_ZONE);
+#ifdef CONFIG_DEBUG_VM
+	else
+		BUG_ON(zone == BAD_ZONE);
 #endif
-	return ZONE_NORMAL;
+	return zone;
 }

 /*
Index: linux-2.6/include/linux/mmzone.h
===================================================================
--- linux-2.6.orig/include/linux/mmzone.h	2009-03-19 11:47:00.000000000 -0500
+++ linux-2.6/include/linux/mmzone.h	2009-03-19 11:47:54.000000000 -0500
@@ -240,7 +240,8 @@
 	ZONE_HIGHMEM,
 #endif
 	ZONE_MOVABLE,
-	__MAX_NR_ZONES
+	__MAX_NR_ZONES,
+	BAD_ZONE
 };

 #ifndef __GENERATING_BOUNDS_H

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
