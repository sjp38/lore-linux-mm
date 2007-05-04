Message-Id: <20070504103156.284261312@chello.nl>
References: <20070504102651.923946304@chello.nl>
Date: Fri, 04 May 2007 12:26:55 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 04/40] mm: serialize access to min_free_kbytes
Content-Disposition: inline; filename=mm-setup_per_zone_pages_min.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@SteelEye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

There is a small race between the procfs caller and the memory hotplug caller
of setup_per_zone_pages_min(). Not a big deal, but the next patch will add yet
another caller. Time to close the gap.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/page_alloc.c |   16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

Index: linux-2.6-git/mm/page_alloc.c
===================================================================
--- linux-2.6-git.orig/mm/page_alloc.c	2007-01-15 09:58:49.000000000 +0100
+++ linux-2.6-git/mm/page_alloc.c	2007-01-15 09:58:51.000000000 +0100
@@ -95,6 +95,7 @@ static char * const zone_names[MAX_NR_ZO
 #endif
 };
 
+static DEFINE_SPINLOCK(min_free_lock);
 int min_free_kbytes = 1024;
 
 unsigned long __meminitdata nr_kernel_pages;
@@ -3074,12 +3075,12 @@ static void setup_per_zone_lowmem_reserv
 }
 
 /**
- * setup_per_zone_pages_min - called when min_free_kbytes changes.
+ * __setup_per_zone_pages_min - called when min_free_kbytes changes.
  *
  * Ensures that the pages_{min,low,high} values for each zone are set correctly
  * with respect to min_free_kbytes.
  */
-void setup_per_zone_pages_min(void)
+static void __setup_per_zone_pages_min(void)
 {
 	unsigned long pages_min = min_free_kbytes >> (PAGE_SHIFT - 10);
 	unsigned long lowmem_pages = 0;
@@ -3133,6 +3134,15 @@ void setup_per_zone_pages_min(void)
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
@@ -3168,7 +3178,7 @@ static int __init init_per_zone_pages_mi
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
