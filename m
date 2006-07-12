From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:38:44 +0200
Message-Id: <20060712143844.16998.45206.sendpatchset@lappy>
In-Reply-To: <20060712143659.16998.6444.sendpatchset@lappy>
References: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 9/39] mm: pgrep: move struct scan_control around
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Move struct scan_control to the general pgrep header so that all
policies can make use of it.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

 include/linux/mm_page_replace.h |   23 +++++++++++++++++++++++
 mm/vmscan.c                     |   23 -----------------------
 2 files changed, 23 insertions(+), 23 deletions(-)

Index: linux-2.6/include/linux/mm_page_replace.h
===================================================================
--- linux-2.6.orig/include/linux/mm_page_replace.h	2006-07-12 16:08:18.000000000 +0200
+++ linux-2.6/include/linux/mm_page_replace.h	2006-07-12 16:11:51.000000000 +0200
@@ -8,6 +8,29 @@
 #include <linux/pagevec.h>
 #include <linux/mm_inline.h>
 
+struct scan_control {
+	/* Incremented by the number of inactive pages that were scanned */
+	unsigned long nr_scanned;
+
+	unsigned long nr_mapped;	/* From page_state */
+
+	/* This context's GFP mask */
+	gfp_t gfp_mask;
+
+	int may_writepage;
+
+	/* Can pages be swapped as part of reclaim? */
+	int may_swap;
+
+	/* This context's SWAP_CLUSTER_MAX. If freeing memory for
+	 * suspend, we effectively ignore SWAP_CLUSTER_MAX.
+	 * In this context, it doesn't matter that we scan the
+	 * whole list at once. */
+	int swap_cluster_max;
+
+	unsigned long nr_writeout;      /* page against which writeout was started */
+};
+
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
 
 #ifdef ARCH_HAS_PREFETCH
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2006-07-12 16:08:18.000000000 +0200
+++ linux-2.6/mm/vmscan.c	2006-07-12 16:11:51.000000000 +0200
@@ -43,29 +43,6 @@
 
 #include "internal.h"
 
-struct scan_control {
-	/* Incremented by the number of inactive pages that were scanned */
-	unsigned long nr_scanned;
-
-	unsigned long nr_mapped;	/* From page_state */
-
-	/* This context's GFP mask */
-	gfp_t gfp_mask;
-
-	int may_writepage;
-
-	/* Can pages be swapped as part of reclaim? */
-	int may_swap;
-
-	/* This context's SWAP_CLUSTER_MAX. If freeing memory for
-	 * suspend, we effectively ignore SWAP_CLUSTER_MAX.
-	 * In this context, it doesn't matter that we scan the
-	 * whole list at once. */
-	int swap_cluster_max;
-
-	unsigned long nr_writeout;	/* page against which writeout was started */
-};
-
 /*
  * The list of shrinker callbacks used by to apply pressure to
  * ageable caches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
