Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2EA64828E1
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 10:20:55 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id g18so13687498lfg.2
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 07:20:55 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id t10si4119259wme.94.2016.06.21.07.20.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jun 2016 07:20:53 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 4485D1C13FD
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 15:20:53 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 27/27] mm: vmstat: Account per-zone stalls and pages skipped during reclaim
Date: Tue, 21 Jun 2016 15:16:06 +0100
Message-Id: <1466518566-30034-28-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The vmstat allocstall was fairly useful in the general sense but
node-based LRUs change that. It's important to know if a stall was for an
address-limited allocation request as this will require skipping pages from
other zones. This patch adds pgstall_* counters to replace allocstall. The
sum of the counters will equal the old allocstall so it can be trivially
recalculated. A high number of address-limited allocation requests may
result in a lot of useless LRU scanning for suitable pages.

As address-limited allocations require pages to be skipped, it's important
to know how much useless LRU scanning took place so this patch adds
pgskip* counters. This yields the following model

1. The number of address-space limited stalls can be accounted for (pgstall)
2. The amount of useless work required to reclaim the data is accounted (pgskip)
3. The total number of scans is available from pgscan_kswapd and pgscan_direct
   so from that the ratio of useful to useless scans can be calculated.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/vm_event_item.h |  4 +++-
 mm/huge_memory.c              | 19 +++++++++++++++----
 mm/vmscan.c                   | 15 +++++++++++++--
 mm/vmstat.c                   |  3 ++-
 4 files changed, 33 insertions(+), 8 deletions(-)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 8dcb5a813163..0a0503da8c3b 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -23,6 +23,8 @@
 
 enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		FOR_ALL_ZONES(PGALLOC),
+		FOR_ALL_ZONES(PGSTALL),
+		FOR_ALL_ZONES(PGSCAN_SKIP),
 		PGFREE, PGACTIVATE, PGDEACTIVATE,
 		PGFAULT, PGMAJFAULT,
 		PGLAZYFREED,
@@ -37,7 +39,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 #endif
 		PGINODESTEAL, SLABS_SCANNED, KSWAPD_INODESTEAL,
 		KSWAPD_LOW_WMARK_HIT_QUICKLY, KSWAPD_HIGH_WMARK_HIT_QUICKLY,
-		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
+		PAGEOUTRUN, PGROTATED,
 		DROP_PAGECACHE, DROP_SLAB,
 #ifdef CONFIG_NUMA_BALANCING
 		NUMA_PTE_UPDATES,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index d5dd6533de32..e55bc5b6601d 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2452,6 +2452,17 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 	return true;
 }
 
+static unsigned long sum_alloc_stalls(void)
+{
+	int zid;
+	unsigned long allocstall = 0;
+
+	for (zid = 0; zid < MAX_NR_ZONES - 1; zid++)
+		allocstall += sum_vm_event(PGSTALL_NORMAL - ZONE_NORMAL + zid);
+
+	return allocstall;
+}
+
 static void collapse_huge_page(struct mm_struct *mm,
 				   unsigned long address,
 				   struct page **hpage,
@@ -2488,7 +2499,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	}
 
 	swap = get_mm_counter(mm, MM_SWAPENTS);
-	curr_allocstall = sum_vm_event(ALLOCSTALL);
+	curr_allocstall = sum_alloc_stalls();;
 	down_read(&mm->mmap_sem);
 	result = hugepage_vma_revalidate(mm, address);
 	if (result) {
@@ -2934,7 +2945,7 @@ static void khugepaged_wait_work(void)
 		if (!scan_sleep_jiffies)
 			return;
 
-		allocstall = sum_vm_event(ALLOCSTALL);
+		allocstall = sum_alloc_stalls();
 		khugepaged_sleep_expire = jiffies + scan_sleep_jiffies;
 		wait_event_freezable_timeout(khugepaged_wait,
 					     khugepaged_should_wakeup(),
@@ -2943,7 +2954,7 @@ static void khugepaged_wait_work(void)
 	}
 
 	if (khugepaged_enabled()) {
-		allocstall = sum_vm_event(ALLOCSTALL);
+		allocstall = sum_alloc_stalls();
 		wait_event_freezable(khugepaged_wait, khugepaged_wait_event());
 	}
 }
@@ -2954,7 +2965,7 @@ static int khugepaged(void *none)
 
 	set_freezable();
 	set_user_nice(current, MAX_NICE);
-	allocstall = sum_vm_event(ALLOCSTALL);
+	allocstall = sum_alloc_stalls();
 
 	while (!kthread_should_stop()) {
 		khugepaged_do_scan();
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 16ad7b4be1e9..66219c391797 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1388,6 +1388,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	struct list_head *src = &lruvec->lists[lru];
 	unsigned long nr_taken = 0;
 	unsigned long nr_zone_taken[MAX_NR_ZONES] = { 0 };
+	unsigned long nr_skipped[MAX_NR_ZONES] = { 0, };
 	unsigned long scan, nr_pages;
 	LIST_HEAD(pages_skipped);
 
@@ -1402,6 +1403,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
 		if (page_zonenum(page) > sc->reclaim_idx) {
 			list_move(&page->lru, &pages_skipped);
+			nr_skipped[page_zonenum(page)]++;
 			continue;
 		}
 
@@ -1430,8 +1432,17 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	 * scanning would soon rescan the same pages to skip and put the
 	 * system at risk of premature OOM.
 	 */
-	if (!list_empty(&pages_skipped))
+	if (!list_empty(&pages_skipped)) {
+		int zid;
+
 		list_splice(&pages_skipped, src);
+		for (zid = 0; zid < MAX_NR_ZONES; zid++) {
+			if (!nr_skipped[zid])
+				continue;
+
+			__count_zid_vm_events(PGSCAN_SKIP, zid, nr_skipped[zid]);
+		}
+	}
 	*nr_scanned = scan;
 	trace_mm_vmscan_lru_isolate(sc->reclaim_idx, sc->order, nr_to_scan, scan,
 				    nr_taken, mode, is_file_lru(lru));
@@ -2684,7 +2695,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	delayacct_freepages_start();
 
 	if (global_reclaim(sc))
-		count_vm_event(ALLOCSTALL);
+		__count_zid_vm_events(PGSTALL, classzone_idx, 1);
 
 	do {
 		vmpressure_prio(sc->gfp_mask, sc->target_mem_cgroup,
diff --git a/mm/vmstat.c b/mm/vmstat.c
index ec96d20eeb52..f5f20db200c6 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -979,6 +979,8 @@ const char * const vmstat_text[] = {
 	"pswpout",
 
 	TEXTS_FOR_ZONES("pgalloc")
+	TEXTS_FOR_ZONES("pgstall")
+	TEXTS_FOR_ZONES("pgskip")
 
 	"pgfree",
 	"pgactivate",
@@ -1004,7 +1006,6 @@ const char * const vmstat_text[] = {
 	"kswapd_low_wmark_hit_quickly",
 	"kswapd_high_wmark_hit_quickly",
 	"pageoutrun",
-	"allocstall",
 
 	"pgrotated",
 
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
