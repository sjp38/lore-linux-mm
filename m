Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id DFF586B0070
	for <linux-mm@kvack.org>; Thu,  7 May 2015 03:25:23 -0400 (EDT)
Received: by wief7 with SMTP id f7so6806795wie.0
        for <linux-mm@kvack.org>; Thu, 07 May 2015 00:25:23 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o3si6072494wic.109.2015.05.07.00.25.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 07 May 2015 00:25:22 -0700 (PDT)
Date: Thu, 7 May 2015 08:25:18 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: meminit: Finish initialisation of struct pages before
 basic setup
Message-ID: <20150507072518.GL2462@suse.de>
References: <1430231830-7702-1-git-send-email-mgorman@suse.de>
 <554030D1.8080509@hp.com>
 <5543F802.9090504@hp.com>
 <554415B1.2050702@hp.com>
 <20150504143046.9404c572486caf71bdef0676@linux-foundation.org>
 <20150505104514.GC2462@suse.de>
 <20150505130255.49ff76bbf0a3b32d884ab2ce@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150505130255.49ff76bbf0a3b32d884ab2ce@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Waiman Long <waiman.long@hp.com>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Waiman Long reported that 24TB machines hit OOM during basic setup when
struct page initialisation was deferred. One approach is to initialise memory
on demand but it interferes with page allocator paths. This patch creates
dedicated threads to initialise memory before basic setup. It then blocks
on a rw_semaphore until completion as a wait_queue and counter is overkill.
This may be slower to boot but it's simplier overall and also gets rid of a
section mangling which existed so kswapd could do the initialisation.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/gfp.h |  8 ++++++++
 init/main.c         |  2 ++
 mm/internal.h       | 24 ------------------------
 mm/page_alloc.c     | 46 +++++++++++++++++++++++++++++++++++++---------
 mm/vmscan.c         |  6 ++----
 5 files changed, 49 insertions(+), 37 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 51bd1e72a917..28a3128d9e59 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -385,6 +385,14 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp);
 void drain_all_pages(struct zone *zone);
 void drain_local_pages(struct zone *zone);
 
+#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
+void page_alloc_init_late(void);
+#else
+static inline void page_alloc_init_late(void)
+{
+}
+#endif
+
 /*
  * gfp_allowed_mask is set to GFP_BOOT_MASK during early boot to restrict what
  * GFP flags are used before interrupts are enabled. Once interrupts are
diff --git a/init/main.c b/init/main.c
index 6f0f1c5ff8cc..9bef5f0c9864 100644
--- a/init/main.c
+++ b/init/main.c
@@ -995,6 +995,8 @@ static noinline void __init kernel_init_freeable(void)
 	smp_init();
 	sched_init_smp();
 
+	page_alloc_init_late();
+
 	do_basic_setup();
 
 	/* Open the /dev/console on the rootfs, this should never fail */
diff --git a/mm/internal.h b/mm/internal.h
index 5c221ad41a29..5a7c7a531720 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -377,30 +377,6 @@ static inline void mminit_verify_zonelist(void)
 }
 #endif /* CONFIG_DEBUG_MEMORY_INIT */
 
-/*
- * Deferred struct page initialisation requires init functions that are freed
- * before kswapd is available. Reuse the memory hotplug section annotation
- * to mark the required code.
- *
- * __defermem_init is code that always exists but is annotated __meminit to
- * 	avoid section warnings.
- * __defer_init code gets marked __meminit when deferring struct page
- *	initialistion but is otherwise in the init section.
- */
-#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
-#define __defermem_init __meminit
-#define __defer_init    __meminit
-
-void deferred_init_memmap(int nid);
-#else
-#define __defermem_init
-#define __defer_init __init
-
-static inline void deferred_init_memmap(int nid)
-{
-}
-#endif
-
 /* mminit_validate_memmodel_limits is independent of CONFIG_DEBUG_MEMORY_INIT */
 #if defined(CONFIG_SPARSEMEM)
 extern void mminit_validate_memmodel_limits(unsigned long *start_pfn,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 598f78d6544c..7c257e37f2ce 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -61,6 +61,7 @@
 #include <linux/hugetlb.h>
 #include <linux/sched/rt.h>
 #include <linux/page_owner.h>
+#include <linux/kthread.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -242,7 +243,7 @@ static inline void reset_deferred_meminit(pg_data_t *pgdat)
 }
 
 /* Returns true if the struct page for the pfn is uninitialised */
-static inline bool __defermem_init early_page_uninitialised(unsigned long pfn)
+static inline bool __meminit early_page_uninitialised(unsigned long pfn)
 {
 	int nid = early_pfn_to_nid(pfn);
 
@@ -972,7 +973,7 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	local_irq_restore(flags);
 }
 
-static void __defer_init __free_pages_boot_core(struct page *page,
+static void __init __free_pages_boot_core(struct page *page,
 					unsigned long pfn, unsigned int order)
 {
 	unsigned int nr_pages = 1 << order;
@@ -1039,7 +1040,7 @@ static inline bool __meminit early_pfn_in_nid(unsigned long pfn, int node)
 }
 #endif
 
-void __defer_init __free_pages_bootmem(struct page *page, unsigned long pfn,
+void __init __free_pages_bootmem(struct page *page, unsigned long pfn,
 							unsigned int order)
 {
 	if (early_page_uninitialised(pfn))
@@ -1048,7 +1049,7 @@ void __defer_init __free_pages_bootmem(struct page *page, unsigned long pfn,
 }
 
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
-static void __defermem_init deferred_free_range(struct page *page,
+static void __init deferred_free_range(struct page *page,
 					unsigned long pfn, int nr_pages)
 {
 	int i;
@@ -1068,20 +1069,30 @@ static void __defermem_init deferred_free_range(struct page *page,
 		__free_pages_boot_core(page, pfn, 0);
 }
 
+static struct rw_semaphore __initdata pgdat_init_rwsem;
+
 /* Initialise remaining memory on a node */
-void __defermem_init deferred_init_memmap(int nid)
+static int __init deferred_init_memmap(void *data)
 {
+	pg_data_t *pgdat = (pg_data_t *)data;
+	int nid = pgdat->node_id;
 	struct mminit_pfnnid_cache nid_init_state = { };
 	unsigned long start = jiffies;
 	unsigned long nr_pages = 0;
 	unsigned long walk_start, walk_end;
 	int i, zid;
 	struct zone *zone;
-	pg_data_t *pgdat = NODE_DATA(nid);
 	unsigned long first_init_pfn = pgdat->first_deferred_pfn;
+	const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
 
-	if (first_init_pfn == ULONG_MAX)
-		return;
+	if (first_init_pfn == ULONG_MAX) {
+		up_read(&pgdat_init_rwsem);
+		return 0;
+	}
+
+	/* Bound memory initialisation to a local node if possible */
+	if (!cpumask_empty(cpumask))
+		set_cpus_allowed_ptr(current, cpumask);
 
 	/* Sanity check boundaries */
 	BUG_ON(pgdat->first_deferred_pfn < pgdat->node_start_pfn);
@@ -1173,8 +1184,25 @@ free_range:
 	/* Sanity check that the next zone really is unpopulated */
 	WARN_ON(++zid < MAX_NR_ZONES && populated_zone(++zone));
 
-	pr_info("kswapd %d initialised %lu pages in %ums\n", nid, nr_pages,
+	pr_info("node %d initialised, %lu pages in %ums\n", nid, nr_pages,
 					jiffies_to_msecs(jiffies - start));
+	up_read(&pgdat_init_rwsem);
+	return 0;
+}
+
+void __init page_alloc_init_late(void)
+{
+	int nid;
+
+	init_rwsem(&pgdat_init_rwsem);
+	for_each_node_state(nid, N_MEMORY) {
+		down_read(&pgdat_init_rwsem);
+		kthread_run(deferred_init_memmap, NODE_DATA(nid), "pgdatinit%d", nid);
+	}
+
+	/* Block until all are initialised */
+	down_write(&pgdat_init_rwsem);
+	up_write(&pgdat_init_rwsem);
 }
 #endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c4895d26d036..5e8eadd71bac 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3348,7 +3348,7 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
  * If there are applications that are active memory-allocators
  * (most normal use), this basically shouldn't matter.
  */
-static int __defermem_init kswapd(void *p)
+static int kswapd(void *p)
 {
 	unsigned long order, new_order;
 	unsigned balanced_order;
@@ -3383,8 +3383,6 @@ static int __defermem_init kswapd(void *p)
 	tsk->flags |= PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD;
 	set_freezable();
 
-	deferred_init_memmap(pgdat->node_id);
-
 	order = new_order = 0;
 	balanced_order = 0;
 	classzone_idx = new_classzone_idx = pgdat->nr_zones - 1;
@@ -3540,7 +3538,7 @@ static int cpu_callback(struct notifier_block *nfb, unsigned long action,
  * This kswapd start function will be called by init and node-hot-add.
  * On node-hot-add, kswapd will moved to proper cpus if cpus are hot-added.
  */
-int __defermem_init kswapd_run(int nid)
+int kswapd_run(int nid)
 {
 	pg_data_t *pgdat = NODE_DATA(nid);
 	int ret = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
