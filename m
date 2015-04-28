Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 6EE3C6B0080
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 10:37:35 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so153883798wgy.2
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 07:37:35 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bn4si18310123wib.52.2015.04.28.07.37.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Apr 2015 07:37:20 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 08/13] mm: meminit: Initialise remaining struct pages in parallel with kswapd
Date: Tue, 28 Apr 2015 15:37:05 +0100
Message-Id: <1430231830-7702-9-git-send-email-mgorman@suse.de>
In-Reply-To: <1430231830-7702-1-git-send-email-mgorman@suse.de>
References: <1430231830-7702-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Only a subset of struct pages are initialised at the moment. When this patch
is applied kswapd initialise the remaining struct pages in parallel. This
should boot faster by spreading the work to multiple CPUs and initialising
data that is local to the CPU.  The user-visible effect on large machines
is that free memory will appear to rapidly increase early in the lifetime
of the system until kswapd reports that all memory is initialised in the
kernel log.  Once initialised there should be no other user-visibile effects.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/internal.h   |   6 +++
 mm/mm_init.c    |   1 +
 mm/page_alloc.c | 123 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 mm/vmscan.c     |   6 ++-
 4 files changed, 130 insertions(+), 6 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 24314b671db1..bed751a7ac42 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -394,9 +394,15 @@ static inline void mminit_verify_zonelist(void)
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
 #define __defermem_init __meminit
 #define __defer_init    __meminit
+
+void deferred_init_memmap(int nid);
 #else
 #define __defermem_init
 #define __defer_init __init
+
+static inline void deferred_init_memmap(int nid)
+{
+}
 #endif
 
 /* mminit_validate_memmodel_limits is independent of CONFIG_DEBUG_MEMORY_INIT */
diff --git a/mm/mm_init.c b/mm/mm_init.c
index 5f420f7fafa1..28fbf87b20aa 100644
--- a/mm/mm_init.c
+++ b/mm/mm_init.c
@@ -11,6 +11,7 @@
 #include <linux/export.h>
 #include <linux/memory.h>
 #include <linux/notifier.h>
+#include <linux/sched.h>
 #include "internal.h"
 
 #ifdef CONFIG_DEBUG_MEMORY_INIT
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8ec493a24b9c..96f2c2dc8ca6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -252,6 +252,14 @@ static inline bool __defermem_init early_page_uninitialised(unsigned long pfn)
 	return false;
 }
 
+static inline bool early_page_nid_uninitialised(unsigned long pfn, int nid)
+{
+	if (pfn >= NODE_DATA(nid)->first_deferred_pfn)
+		return true;
+
+	return false;
+}
+
 /*
  * Returns false when the remaining initialisation should be deferred until
  * later in the boot cycle when it can be parallelised.
@@ -284,6 +292,11 @@ static inline bool early_page_uninitialised(unsigned long pfn)
 	return false;
 }
 
+static inline bool early_page_nid_uninitialised(unsigned long pfn, int nid)
+{
+	return false;
+}
+
 static inline bool update_defer_init(pg_data_t *pgdat,
 				unsigned long pfn, unsigned long zone_end,
 				unsigned long *nr_initialised)
@@ -880,20 +893,51 @@ static void __meminit __init_single_pfn(unsigned long pfn, unsigned long zone,
 	return __init_single_page(pfn_to_page(pfn), pfn, zone, nid);
 }
 
+#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
+static void init_reserved_page(unsigned long pfn)
+{
+	pg_data_t *pgdat;
+	int nid, zid;
+
+	if (!early_page_uninitialised(pfn))
+		return;
+
+	nid = early_pfn_to_nid(pfn);
+	pgdat = NODE_DATA(nid);
+
+	for (zid = 0; zid < MAX_NR_ZONES; zid++) {
+		struct zone *zone = &pgdat->node_zones[zid];
+
+		if (pfn >= zone->zone_start_pfn && pfn < zone_end_pfn(zone))
+			break;
+	}
+	__init_single_pfn(pfn, zid, nid);
+}
+#else
+static inline void init_reserved_page(unsigned long pfn)
+{
+}
+#endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
+
 /*
  * Initialised pages do not have PageReserved set. This function is
  * called for each range allocated by the bootmem allocator and
  * marks the pages PageReserved. The remaining valid pages are later
  * sent to the buddy page allocator.
  */
-void reserve_bootmem_region(unsigned long start, unsigned long end)
+void __meminit reserve_bootmem_region(unsigned long start, unsigned long end)
 {
 	unsigned long start_pfn = PFN_DOWN(start);
 	unsigned long end_pfn = PFN_UP(end);
 
-	for (; start_pfn < end_pfn; start_pfn++)
-		if (pfn_valid(start_pfn))
-			SetPageReserved(pfn_to_page(start_pfn));
+	for (; start_pfn < end_pfn; start_pfn++) {
+		if (pfn_valid(start_pfn)) {
+			struct page *page = pfn_to_page(start_pfn);
+
+			init_reserved_page(start_pfn);
+			SetPageReserved(page);
+		}
+	}
 }
 
 static bool free_pages_prepare(struct page *page, unsigned int order)
@@ -1018,6 +1062,74 @@ void __defer_init __free_pages_bootmem(struct page *page, unsigned long pfn,
 	return __free_pages_boot_core(page, pfn, order);
 }
 
+#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
+/* Initialise remaining memory on a node */
+void __defermem_init deferred_init_memmap(int nid)
+{
+	struct mminit_pfnnid_cache nid_init_state = { };
+	unsigned long start = jiffies;
+	unsigned long nr_pages = 0;
+	unsigned long walk_start, walk_end;
+	int i, zid;
+	struct zone *zone;
+	pg_data_t *pgdat = NODE_DATA(nid);
+	unsigned long first_init_pfn = pgdat->first_deferred_pfn;
+
+	if (first_init_pfn == ULONG_MAX)
+		return;
+
+	/* Sanity check boundaries */
+	BUG_ON(pgdat->first_deferred_pfn < pgdat->node_start_pfn);
+	BUG_ON(pgdat->first_deferred_pfn > pgdat_end_pfn(pgdat));
+	pgdat->first_deferred_pfn = ULONG_MAX;
+
+	/* Only the highest zone is deferred so find it */
+	for (zid = 0; zid < MAX_NR_ZONES; zid++) {
+		zone = pgdat->node_zones + zid;
+		if (first_init_pfn < zone_end_pfn(zone))
+			break;
+	}
+
+	for_each_mem_pfn_range(i, nid, &walk_start, &walk_end, NULL) {
+		unsigned long pfn, end_pfn;
+
+		end_pfn = min(walk_end, zone_end_pfn(zone));
+		pfn = first_init_pfn;
+		if (pfn < walk_start)
+			pfn = walk_start;
+		if (pfn < zone->zone_start_pfn)
+			pfn = zone->zone_start_pfn;
+
+		for (; pfn < end_pfn; pfn++) {
+			struct page *page;
+
+			if (!pfn_valid(pfn))
+				continue;
+
+			if (!meminit_pfn_in_nid(pfn, nid, &nid_init_state))
+				continue;
+
+			if (page->flags) {
+				VM_BUG_ON(page_zone(page) != zone);
+				continue;
+			}
+
+			__init_single_page(page, pfn, zid, nid);
+			__free_pages_boot_core(page, pfn, 0);
+			nr_pages++;
+			cond_resched();
+		}
+		first_init_pfn = max(end_pfn, first_init_pfn);
+	}
+
+	/* Sanity check that the next zone really is unpopulated */
+	WARN_ON(++zid < MAX_NR_ZONES && populated_zone(++zone));
+
+	pr_info("kswapd %d initialised %lu pages in %ums\n", nid, nr_pages,
+					jiffies_to_msecs(jiffies - start));
+}
+#endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
+
 #ifdef CONFIG_CMA
 /* Free whole pageblock and set its migration type to MIGRATE_CMA. */
 void __init init_cma_reserved_pageblock(struct page *page)
@@ -4228,6 +4340,9 @@ static void setup_zone_migrate_reserve(struct zone *zone)
 	zone->nr_migrate_reserve_block = reserve;
 
 	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
+		if (!early_page_nid_uninitialised(pfn, zone_to_nid(zone)))
+			return;
+
 		if (!pfn_valid(pfn))
 			continue;
 		page = pfn_to_page(pfn);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5e8eadd71bac..c4895d26d036 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3348,7 +3348,7 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
  * If there are applications that are active memory-allocators
  * (most normal use), this basically shouldn't matter.
  */
-static int kswapd(void *p)
+static int __defermem_init kswapd(void *p)
 {
 	unsigned long order, new_order;
 	unsigned balanced_order;
@@ -3383,6 +3383,8 @@ static int kswapd(void *p)
 	tsk->flags |= PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD;
 	set_freezable();
 
+	deferred_init_memmap(pgdat->node_id);
+
 	order = new_order = 0;
 	balanced_order = 0;
 	classzone_idx = new_classzone_idx = pgdat->nr_zones - 1;
@@ -3538,7 +3540,7 @@ static int cpu_callback(struct notifier_block *nfb, unsigned long action,
  * This kswapd start function will be called by init and node-hot-add.
  * On node-hot-add, kswapd will moved to proper cpus if cpus are hot-added.
  */
-int kswapd_run(int nid)
+int __defermem_init kswapd_run(int nid)
 {
 	pg_data_t *pgdat = NODE_DATA(nid);
 	int ret = 0;
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
