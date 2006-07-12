From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:40:27 +0200
Message-Id: <20060712144027.16998.83825.sendpatchset@lappy>
In-Reply-To: <20060712143659.16998.6444.sendpatchset@lappy>
References: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 18/39] mm: pgrep: initialisation hooks
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Move initialization of the replacement policy's variables into the
implementation.

API:

initialize the policy:

	void pgrep_init(void);

initialize the policies per zone data:

	void pgrep_init_zone(struct zone *);

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

 include/linux/mm_page_replace.h |    2 ++
 init/main.c                     |    2 ++
 mm/page_alloc.c                 |    8 ++------
 mm/useonce.c                    |   15 +++++++++++++++
 4 files changed, 21 insertions(+), 6 deletions(-)

Index: linux-2.6/include/linux/mm_page_replace.h
===================================================================
--- linux-2.6.orig/include/linux/mm_page_replace.h	2006-07-12 16:09:18.000000000 +0200
+++ linux-2.6/include/linux/mm_page_replace.h	2006-07-12 16:11:40.000000000 +0200
@@ -58,6 +58,8 @@ struct scan_control {
 #define prefetchw_prev_lru_page(_page, _base, _field) do { } while (0)
 #endif
 
+extern void pgrep_init(void);
+extern void pgrep_init_zone(struct zone *);
 /* void pgrep_hint_active(struct page *); */
 /* void pgrep_hint_use_once(struct page *); */
 extern void fastcall pgrep_add(struct page *);
Index: linux-2.6/mm/useonce.c
===================================================================
--- linux-2.6.orig/mm/useonce.c	2006-07-12 16:09:18.000000000 +0200
+++ linux-2.6/mm/useonce.c	2006-07-12 16:11:40.000000000 +0200
@@ -6,6 +6,21 @@
 #include <linux/buffer_head.h> /* for try_to_release_page(),
                                        buffer_heads_over_limit */
 
+void __init pgrep_init(void)
+{
+	/* empty hook */
+}
+
+void __init pgrep_init_zone(struct zone *zone)
+{
+	INIT_LIST_HEAD(&zone->active_list);
+	INIT_LIST_HEAD(&zone->inactive_list);
+	zone->nr_scan_active = 0;
+	zone->nr_scan_inactive = 0;
+	zone->nr_active = 0;
+	zone->nr_inactive = 0;
+}
+
 /**
  * lru_cache_add: add a page to the page lists
  * @page: the page to add
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2006-07-12 16:07:32.000000000 +0200
+++ linux-2.6/mm/page_alloc.c	2006-07-12 16:11:40.000000000 +0200
@@ -37,6 +37,7 @@
 #include <linux/nodemask.h>
 #include <linux/vmalloc.h>
 #include <linux/mempolicy.h>
+#include <linux/mm_page_replace.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -2100,12 +2101,7 @@ static void __init free_area_init_core(s
 		zone->temp_priority = zone->prev_priority = DEF_PRIORITY;
 
 		zone_pcp_init(zone);
-		INIT_LIST_HEAD(&zone->active_list);
-		INIT_LIST_HEAD(&zone->inactive_list);
-		zone->nr_scan_active = 0;
-		zone->nr_scan_inactive = 0;
-		zone->nr_active = 0;
-		zone->nr_inactive = 0;
+		pgrep_init_zone(zone);
 		atomic_set(&zone->reclaim_in_progress, 0);
 		if (!size)
 			continue;
Index: linux-2.6/init/main.c
===================================================================
--- linux-2.6.orig/init/main.c	2006-07-12 16:07:31.000000000 +0200
+++ linux-2.6/init/main.c	2006-07-12 16:09:18.000000000 +0200
@@ -47,6 +47,7 @@
 #include <linux/rmap.h>
 #include <linux/mempolicy.h>
 #include <linux/key.h>
+#include <linux/mm_page_replace.h>
 
 #include <asm/io.h>
 #include <asm/bugs.h>
@@ -511,6 +512,7 @@ asmlinkage void __init start_kernel(void
 #endif
 	vfs_caches_init_early();
 	cpuset_init_early();
+	pgrep_init();
 	mem_init();
 	kmem_cache_init();
 	setup_per_cpu_pageset();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
