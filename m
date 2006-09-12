Message-Id: <20060912144903.094525000@chello.nl>
References: <20060912143049.278065000@chello.nl>
Subject: [PATCH 01/20] mm: serialize access to min_free_kbytes
Content-Disposition: inline; filename=setup_per_zone_pages_min.patch
Date: Tue, 12 Sep 2006 17:25:49 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, David Miller <davem@davemloft.net>, Rik van Riel <riel@redhat.com>, Daniel Phillips <phillips@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

There is a small race between the procfs caller and the memory hotplug caller
of setup_per_zone_pages_min(). Not a big deal, but the next patch will add yet
another caller. Time to close the gap.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/page_alloc.c |   16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -81,6 +81,7 @@ struct zone *zone_table[1 << ZONETABLE_S
 EXPORT_SYMBOL(zone_table);
 
 static char *zone_names[MAX_NR_ZONES] = { "DMA", "DMA32", "Normal", "HighMem" };
+static DEFINE_SPINLOCK(min_free_lock);
 int min_free_kbytes = 1024;
 
 unsigned long __meminitdata nr_kernel_pages;
@@ -2190,11 +2191,11 @@ static void setup_per_zone_lowmem_reserv
 }
 
 /*
- * setup_per_zone_pages_min - called when min_free_kbytes changes.  Ensures 
+ * __setup_per_zone_pages_min - called when min_free_kbytes changes.  Ensures
  *	that the pages_{min,low,high} values for each zone are set correctly 
  *	with respect to min_free_kbytes.
  */
-void setup_per_zone_pages_min(void)
+static void __setup_per_zone_pages_min(void)
 {
 	unsigned long pages_min = min_free_kbytes >> (PAGE_SHIFT - 10);
 	unsigned long lowmem_pages = 0;
@@ -2248,6 +2249,15 @@ void setup_per_zone_pages_min(void)
 	calculate_totalreserve_pages();
 }
 
+void setup_per_zone_pages_min(void)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&min_free_lock, flags);
+	__setup_per_zone_pages_min();
+	spin_unlock_irqrestore(&min_free_lock, flags);
+}
+
 /*
  * Initialise min_free_kbytes.
  *
@@ -2283,7 +2293,7 @@ static int __init init_per_zone_pages_mi
 		min_free_kbytes = 128;
 	if (min_free_kbytes > 65536)
 		min_free_kbytes = 65536;
-	setup_per_zone_pages_min();
+	__setup_per_zone_pages_min();
 	setup_per_zone_lowmem_reserve();
 	return 0;
 }

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
