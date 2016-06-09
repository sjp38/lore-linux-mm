Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 82819828EA
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 14:09:31 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id u74so20912167lff.0
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 11:09:31 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id bn6si9224059wjb.32.2016.06.09.11.09.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Jun 2016 11:09:30 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id EB95798DAB
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 18:09:29 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 27/27] mm: vmstat: Account per-zone stalls and pages skipped during reclaim
Date: Thu,  9 Jun 2016 19:04:43 +0100
Message-Id: <1465495483-11855-28-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
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
index 0512b863a441..e554ca7d095e 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2459,6 +2459,17 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
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
@@ -2495,7 +2506,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	}
 
 	swap = get_mm_counter(mm, MM_SWAPENTS);
-	curr_allocstall = sum_vm_event(ALLOCSTALL);
+	curr_allocstall = sum_alloc_stalls();;
 	down_read(&mm->mmap_sem);
 	result = hugepage_vma_revalidate(mm, address);
 	if (result) {
@@ -2929,7 +2940,7 @@ static void khugepaged_wait_work(void)
 		if (!scan_sleep_jiffies)
 			return;
 
-		allocstall = sum_vm_event(ALLOCSTALL);
+		allocstall = sum_alloc_stalls();
 		khugepaged_sleep_expire = jiffies + scan_sleep_jiffies;
 		wait_event_freezable_timeout(khugepaged_wait,
 					     khugepaged_should_wakeup(),
@@ -2938,7 +2949,7 @@ static void khugepaged_wait_work(void)
 	}
 
 	if (khugepaged_enabled()) {
-		allocstall = sum_vm_event(ALLOCSTALL);
+		allocstall = sum_alloc_stalls();
 		wait_event_freezable(khugepaged_wait, khugepaged_wait_event());
 	}
 }
@@ -2949,7 +2960,7 @@ static int khugepaged(void *none)
 
 	set_freezable();
 	set_user_nice(current, MAX_NICE);
-	allocstall = sum_vm_event(ALLOCSTALL);
+	allocstall = sum_alloc_stalls();
 
 	while (!kthread_should_stop()) {
 		khugepaged_do_scan();
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9e12f5d75c06..ce7f4e54ae26 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1372,6 +1372,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	struct list_head *src = &lruvec->lists[lru];
 	unsigned long nr_taken = 0;
 	unsigned long scan;
+	unsigned long nr_skipped[MAX_NR_ZONES] = { 0, };
 	LIST_HEAD(pages_skipped);
 
 	for (scan = 0; scan < nr_to_scan && nr_taken < nr_to_scan &&
@@ -1385,6 +1386,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
 		if (page_zonenum(page) > sc->reclaim_idx) {
 			list_move(&page->lru, &pages_skipped);
+			nr_skipped[page_zonenum(page)]++;
 			continue;
 		}
 
@@ -1411,8 +1413,17 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
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
@@ -2655,7 +2666,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	delayacct_freepages_start();
 
 	if (global_reclaim(sc))
-		count_vm_event(ALLOCSTALL);
+		__count_zid_vm_events(PGSTALL, classzone_idx, 1);
 
 	do {
 		vmpressure_prio(sc->gfp_mask, sc->target_mem_cgroup,
diff --git a/mm/vmstat.c b/mm/vmstat.c
index dd60fa3ca66b..2de51e9d7e73 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -977,6 +977,8 @@ const char * const vmstat_text[] = {
 	"pswpout",
 
 	TEXTS_FOR_ZONES("pgalloc")
+	TEXTS_FOR_ZONES("pgstall")
+	TEXTS_FOR_ZONES("pgskip")
 
 	"pgfree",
 	"pgactivate",
@@ -1002,7 +1004,6 @@ const char * const vmstat_text[] = {
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
