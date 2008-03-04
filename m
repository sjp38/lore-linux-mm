From: Christoph Lameter <clameter@sgi.com>
Subject: [rfc 09/10] Get rid of __ZONE_COUNT
Date: Mon, 03 Mar 2008 16:05:01 -0800
Message-ID: <20080304000734.153878688@sgi.com>
References: <20080304000452.514878384@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756330AbYCDALA@vger.kernel.org>
Content-Disposition: inline; filename=bounds_nr_max_zones
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, apw@shadowen.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

It was used to compensate because MAX_NR_ZONES was not available
to the #ifdefs. Export MAX_NR_ZONES via the new mechanism
and get rid of __ZONE_COUNT.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/bounds.h |    1 +
 include/linux/mmzone.h |   22 +++++-----------------
 kernel/bounds.c        |    1 +
 3 files changed, 7 insertions(+), 17 deletions(-)

Index: linux-2.6/include/linux/mmzone.h
===================================================================
--- linux-2.6.orig/include/linux/mmzone.h	2008-03-03 15:53:28.329306618 -0800
+++ linux-2.6/include/linux/mmzone.h	2008-03-03 15:54:59.166310018 -0800
@@ -17,6 +17,7 @@
 #include <linux/pageblock-flags.h>
 #include <asm/atomic.h>
 #include <asm/page.h>
+#include <linux/bounds.h>
 
 /* Free memory management - zoned buddy allocator.  */
 #ifndef CONFIG_FORCE_MAX_ZONEORDER
@@ -177,7 +178,7 @@ enum zone_type {
 	ZONE_HIGHMEM,
 #endif
 	ZONE_MOVABLE,
-	MAX_NR_ZONES
+	__MAX_NR_ZONES
 };
 
 /*
@@ -188,28 +189,15 @@ enum zone_type {
  * match the requested limits. See gfp_zone() in include/linux/gfp.h
  */
 
-/*
- * Count the active zones.  Note that the use of defined(X) outside
- * #if and family is not necessarily defined so ensure we cannot use
- * it later.  Use __ZONE_COUNT to work out how many shift bits we need.
- */
-#define __ZONE_COUNT (			\
-	  defined(CONFIG_ZONE_DMA)	\
-	+ defined(CONFIG_ZONE_DMA32)	\
-	+ 1				\
-	+ defined(CONFIG_HIGHMEM)	\
-	+ 1				\
-)
-#if __ZONE_COUNT < 2
+#if MAX_NR_ZONES < 2
 #define ZONES_SHIFT 0
-#elif __ZONE_COUNT <= 2
+#elif MAX_NR_ZONES <= 2
 #define ZONES_SHIFT 1
-#elif __ZONE_COUNT <= 4
+#elif MAX_NR_ZONES <= 4
 #define ZONES_SHIFT 2
 #else
 #error ZONES_SHIFT -- too many zones configured adjust calculation
 #endif
-#undef __ZONE_COUNT
 
 struct zone {
 	/* Fields commonly accessed by the page allocator */
Index: linux-2.6/kernel/bounds.c
===================================================================
--- linux-2.6.orig/kernel/bounds.c	2008-03-03 15:53:28.329306618 -0800
+++ linux-2.6/kernel/bounds.c	2008-03-03 15:54:34.278034457 -0800
@@ -14,4 +14,5 @@
 void foo(void)
 {
 	DEFINE(NR_PAGEFLAGS, __NR_PAGEFLAGS);
+	DEFINE(MAX_NR_ZONES, __MAX_NR_ZONES);
 }
Index: linux-2.6/include/linux/bounds.h
===================================================================
--- linux-2.6.orig/include/linux/bounds.h	2008-03-03 15:53:28.329306618 -0800
+++ linux-2.6/include/linux/bounds.h	2008-03-03 15:54:34.278034457 -0800
@@ -8,5 +8,6 @@
  */
 
 #define NR_PAGEFLAGS 32 /* __NR_PAGEFLAGS	# */
+#define MAX_NR_ZONES 4 /* __MAX_NR_ZONES	# */
 
 #endif

-- 
