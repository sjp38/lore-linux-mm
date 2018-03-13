Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8CB3B6B026A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 14:24:27 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id i204so689704ywb.14
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 11:24:27 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id x64-v6si156174ybb.187.2018.03.13.11.24.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 11:24:26 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v6 1/2] mm: disable interrupts while initializing deferred pages
Date: Tue, 13 Mar 2018 14:23:54 -0400
Message-Id: <20180313182355.17669-2-pasha.tatashin@oracle.com>
In-Reply-To: <20180313182355.17669-1-pasha.tatashin@oracle.com>
References: <20180313182355.17669-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, pasha.tatashin@oracle.com, m.mizuma@jp.fujitsu.com, akpm@linux-foundation.org, mhocko@suse.com, catalin.marinas@arm.com, takahiro.akashi@linaro.org, gi-oh.kim@profitbricks.com, heiko.carstens@de.ibm.com, baiyaowei@cmss.chinamobile.com, richard.weiyang@gmail.com, paul.burton@mips.com, miles.chen@mediatek.com, vbabka@suse.cz, mgorman@suse.de, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Vlastimil Babka reported about a window issue during which when deferred
pages are initialized, and the current version of on-demand initialization
is finished, allocations may fail.  While this is highly unlikely scenario,
since this kind of allocation request must be large, and must come from
interrupt handler, we still want to cover it.

We solve this by initializing deferred pages with interrupts disabled, and
holding node_size_lock spin lock while pages in the node are being
initialized. The on-demand deferred page initialization that comes later
will use the same lock, and thus synchronize with deferred_init_memmap().

It is unlikely for threads that initialize deferred pages to be
interrupted.  They run soon after smp_init(), but before modules are
initialized, and long before user space programs. This is why there is no
adverse effect of having these threads running with interrupts disabled.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 include/linux/memory_hotplug.h | 53 ++++++++++++++++++++++--------------------
 include/linux/mmzone.h         |  5 ++--
 mm/page_alloc.c                | 19 ++++++++-------
 3 files changed, 42 insertions(+), 35 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index aba5f86eb038..2b0265265c28 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -51,24 +51,6 @@ enum {
 	MMOP_ONLINE_MOVABLE,
 };
 
-/*
- * pgdat resizing functions
- */
-static inline
-void pgdat_resize_lock(struct pglist_data *pgdat, unsigned long *flags)
-{
-	spin_lock_irqsave(&pgdat->node_size_lock, *flags);
-}
-static inline
-void pgdat_resize_unlock(struct pglist_data *pgdat, unsigned long *flags)
-{
-	spin_unlock_irqrestore(&pgdat->node_size_lock, *flags);
-}
-static inline
-void pgdat_resize_init(struct pglist_data *pgdat)
-{
-	spin_lock_init(&pgdat->node_size_lock);
-}
 /*
  * Zone resizing functions
  *
@@ -246,13 +228,6 @@ extern void clear_zone_contiguous(struct zone *zone);
 	___page;				\
  })
 
-/*
- * Stub functions for when hotplug is off
- */
-static inline void pgdat_resize_lock(struct pglist_data *p, unsigned long *f) {}
-static inline void pgdat_resize_unlock(struct pglist_data *p, unsigned long *f) {}
-static inline void pgdat_resize_init(struct pglist_data *pgdat) {}
-
 static inline unsigned zone_span_seqbegin(struct zone *zone)
 {
 	return 0;
@@ -293,6 +268,34 @@ static inline bool movable_node_is_enabled(void)
 }
 #endif /* ! CONFIG_MEMORY_HOTPLUG */
 
+#if defined(CONFIG_MEMORY_HOTPLUG) || defined(CONFIG_DEFERRED_STRUCT_PAGE_INIT)
+/*
+ * pgdat resizing functions
+ */
+static inline
+void pgdat_resize_lock(struct pglist_data *pgdat, unsigned long *flags)
+{
+	spin_lock_irqsave(&pgdat->node_size_lock, *flags);
+}
+static inline
+void pgdat_resize_unlock(struct pglist_data *pgdat, unsigned long *flags)
+{
+	spin_unlock_irqrestore(&pgdat->node_size_lock, *flags);
+}
+static inline
+void pgdat_resize_init(struct pglist_data *pgdat)
+{
+	spin_lock_init(&pgdat->node_size_lock);
+}
+#else /* !(CONFIG_MEMORY_HOTPLUG || CONFIG_DEFERRED_STRUCT_PAGE_INIT) */
+/*
+ * Stub functions for when hotplug is off
+ */
+static inline void pgdat_resize_lock(struct pglist_data *p, unsigned long *f) {}
+static inline void pgdat_resize_unlock(struct pglist_data *p, unsigned long *f) {}
+static inline void pgdat_resize_init(struct pglist_data *pgdat) {}
+#endif /* !(CONFIG_MEMORY_HOTPLUG || CONFIG_DEFERRED_STRUCT_PAGE_INIT) */
+
 #ifdef CONFIG_MEMORY_HOTREMOVE
 
 extern bool is_mem_section_removable(unsigned long pfn, unsigned long nr_pages);
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 7522a6987595..d14168da66a7 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -633,14 +633,15 @@ typedef struct pglist_data {
 #ifndef CONFIG_NO_BOOTMEM
 	struct bootmem_data *bdata;
 #endif
-#ifdef CONFIG_MEMORY_HOTPLUG
+#if defined(CONFIG_MEMORY_HOTPLUG) || defined(CONFIG_DEFERRED_STRUCT_PAGE_INIT)
 	/*
 	 * Must be held any time you expect node_start_pfn, node_present_pages
 	 * or node_spanned_pages stay constant.  Holding this will also
 	 * guarantee that any pfn_valid() stays that way.
 	 *
 	 * pgdat_resize_lock() and pgdat_resize_unlock() are provided to
-	 * manipulate node_size_lock without checking for CONFIG_MEMORY_HOTPLUG.
+	 * manipulate node_size_lock without checking for CONFIG_MEMORY_HOTPLUG
+	 * or CONFIG_DEFERRED_STRUCT_PAGE_INIT.
 	 *
 	 * Nests above zone->lock and zone->span_seqlock
 	 */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3d974cb2a1a1..cada509e2176 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1506,7 +1506,7 @@ static void __init deferred_free_pages(int nid, int zid, unsigned long pfn,
 		} else if (!(pfn & nr_pgmask)) {
 			deferred_free_range(pfn - nr_free, nr_free);
 			nr_free = 1;
-			cond_resched();
+			touch_nmi_watchdog();
 		} else {
 			nr_free++;
 		}
@@ -1535,7 +1535,7 @@ static unsigned long  __init deferred_init_pages(int nid, int zid,
 			continue;
 		} else if (!page || !(pfn & nr_pgmask)) {
 			page = pfn_to_page(pfn);
-			cond_resched();
+			touch_nmi_watchdog();
 		} else {
 			page++;
 		}
@@ -1552,23 +1552,25 @@ static int __init deferred_init_memmap(void *data)
 	int nid = pgdat->node_id;
 	unsigned long start = jiffies;
 	unsigned long nr_pages = 0;
-	unsigned long spfn, epfn;
+	unsigned long spfn, epfn, first_init_pfn, flags;
 	phys_addr_t spa, epa;
 	int zid;
 	struct zone *zone;
-	unsigned long first_init_pfn = pgdat->first_deferred_pfn;
 	const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
 	u64 i;
 
+	/* Bind memory initialisation thread to a local node if possible */
+	if (!cpumask_empty(cpumask))
+		set_cpus_allowed_ptr(current, cpumask);
+
+	pgdat_resize_lock(pgdat, &flags);
+	first_init_pfn = pgdat->first_deferred_pfn;
 	if (first_init_pfn == ULONG_MAX) {
+		pgdat_resize_unlock(pgdat, &flags);
 		pgdat_init_report_one_done();
 		return 0;
 	}
 
-	/* Bind memory initialisation thread to a local node if possible */
-	if (!cpumask_empty(cpumask))
-		set_cpus_allowed_ptr(current, cpumask);
-
 	/* Sanity check boundaries */
 	BUG_ON(pgdat->first_deferred_pfn < pgdat->node_start_pfn);
 	BUG_ON(pgdat->first_deferred_pfn > pgdat_end_pfn(pgdat));
@@ -1598,6 +1600,7 @@ static int __init deferred_init_memmap(void *data)
 		epfn = min_t(unsigned long, zone_end_pfn(zone), PFN_DOWN(epa));
 		deferred_free_pages(nid, zid, spfn, epfn);
 	}
+	pgdat_resize_unlock(pgdat, &flags);
 
 	/* Sanity check that the next zone really is unpopulated */
 	WARN_ON(++zid < MAX_NR_ZONES && populated_zone(++zone));
-- 
2.16.2
