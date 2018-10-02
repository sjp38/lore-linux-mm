Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5BD2B6B0006
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 06:17:10 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id g36-v6so1223161plb.5
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 03:17:10 -0700 (PDT)
Received: from terminus.zytor.com (terminus.zytor.com. [198.137.202.136])
        by mx.google.com with ESMTPS id u3-v6si6507228plz.353.2018.10.02.03.17.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Oct 2018 03:17:08 -0700 (PDT)
Date: Tue, 2 Oct 2018 03:17:02 -0700
From: tip-bot for Mel Gorman <tipbot@zytor.com>
Message-ID: <tip-efaffc5e40aeced0bcb497ed7a0a5b8c14abfcdf@git.kernel.org>
Reply-To: linux-mm@kvack.org, srikar@linux.vnet.ibm.com, tglx@linutronix.de,
        hpa@zytor.com, riel@surriel.com, mgorman@techsingularity.net,
        a.p.zijlstra@chello.nl, mingo@kernel.org, jhladky@redhat.com,
        linux-kernel@vger.kernel.org, torvalds@linux-foundation.org
In-Reply-To: <20181001100525.29789-2-mgorman@techsingularity.net>
References: <20181001100525.29789-2-mgorman@techsingularity.net>
Subject: [tip:sched/urgent] mm, sched/numa: Remove rate-limiting of
 automatic NUMA balancing migration
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, jhladky@redhat.com, mingo@kernel.org, a.p.zijlstra@chello.nl, mgorman@techsingularity.net, riel@surriel.com, tglx@linutronix.de, hpa@zytor.com, srikar@linux.vnet.ibm.com, linux-mm@kvack.org

Commit-ID:  efaffc5e40aeced0bcb497ed7a0a5b8c14abfcdf
Gitweb:     https://git.kernel.org/tip/efaffc5e40aeced0bcb497ed7a0a5b8c14abfcdf
Author:     Mel Gorman <mgorman@techsingularity.net>
AuthorDate: Mon, 1 Oct 2018 11:05:24 +0100
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Tue, 2 Oct 2018 11:31:14 +0200

mm, sched/numa: Remove rate-limiting of automatic NUMA balancing migration

Rate limiting of page migrations due to automatic NUMA balancing was
introduced to mitigate the worst-case scenario of migrating at high
frequency due to false sharing or slowly ping-ponging between nodes.
Since then, a lot of effort was spent on correctly identifying these
pages and avoiding unnecessary migrations and the safety net may no longer
be required.

Jirka Hladky reported a regression in 4.17 due to a scheduler patch that
avoids spreading STREAM tasks wide prematurely. However, once the task
was properly placed, it delayed migrating the memory due to rate limiting.
Increasing the limit fixed the problem for him.

Currently, the limit is hard-coded and does not account for the real
capabilities of the hardware. Even if an estimate was attempted, it would
not properly account for the number of memory controllers and it could
not account for the amount of bandwidth used for normal accesses. Rather
than fudging, this patch simply eliminates the rate limiting.

However, Jirka reports that a STREAM configuration using multiple
processes achieved similar performance to 4.16. In local tests, this patch
improved performance of STREAM relative to the baseline but it is somewhat
machine-dependent. Most workloads show little or not performance difference
implying that there is not a heavily reliance on the throttling mechanism
and it is safe to remove.

STREAM on 2-socket machine
                         4.19.0-rc5             4.19.0-rc5
                         numab-v1r1       noratelimit-v1r1
MB/sec copy     43298.52 (   0.00%)    44673.38 (   3.18%)
MB/sec scale    30115.06 (   0.00%)    31293.06 (   3.91%)
MB/sec add      32825.12 (   0.00%)    34883.62 (   6.27%)
MB/sec triad    32549.52 (   0.00%)    34906.60 (   7.24%

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Reviewed-by: Rik van Riel <riel@surriel.com>
Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Jirka Hladky <jhladky@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Link: http://lkml.kernel.org/r/20181001100525.29789-2-mgorman@techsingularity.net
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/mmzone.h         |  6 ----
 include/trace/events/migrate.h | 27 ------------------
 mm/migrate.c                   | 65 ------------------------------------------
 mm/page_alloc.c                |  2 --
 4 files changed, 100 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 1e22d96734e0..3f4c0b167333 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -671,12 +671,6 @@ typedef struct pglist_data {
 #ifdef CONFIG_NUMA_BALANCING
 	/* Lock serializing the migrate rate limiting window */
 	spinlock_t numabalancing_migrate_lock;
-
-	/* Rate limiting time interval */
-	unsigned long numabalancing_migrate_next_window;
-
-	/* Number of pages migrated during the rate limiting time interval */
-	unsigned long numabalancing_migrate_nr_pages;
 #endif
 	/*
 	 * This is a per-node reserve of pages that are not available
diff --git a/include/trace/events/migrate.h b/include/trace/events/migrate.h
index 711372845945..705b33d1e395 100644
--- a/include/trace/events/migrate.h
+++ b/include/trace/events/migrate.h
@@ -70,33 +70,6 @@ TRACE_EVENT(mm_migrate_pages,
 		__print_symbolic(__entry->mode, MIGRATE_MODE),
 		__print_symbolic(__entry->reason, MIGRATE_REASON))
 );
-
-TRACE_EVENT(mm_numa_migrate_ratelimit,
-
-	TP_PROTO(struct task_struct *p, int dst_nid, unsigned long nr_pages),
-
-	TP_ARGS(p, dst_nid, nr_pages),
-
-	TP_STRUCT__entry(
-		__array(	char,		comm,	TASK_COMM_LEN)
-		__field(	pid_t,		pid)
-		__field(	int,		dst_nid)
-		__field(	unsigned long,	nr_pages)
-	),
-
-	TP_fast_assign(
-		memcpy(__entry->comm, p->comm, TASK_COMM_LEN);
-		__entry->pid		= p->pid;
-		__entry->dst_nid	= dst_nid;
-		__entry->nr_pages	= nr_pages;
-	),
-
-	TP_printk("comm=%s pid=%d dst_nid=%d nr_pages=%lu",
-		__entry->comm,
-		__entry->pid,
-		__entry->dst_nid,
-		__entry->nr_pages)
-);
 #endif /* _TRACE_MIGRATE_H */
 
 /* This part must be outside protection */
diff --git a/mm/migrate.c b/mm/migrate.c
index 4f1d894835b5..5e285c1249a0 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1855,54 +1855,6 @@ static struct page *alloc_misplaced_dst_page(struct page *page,
 	return newpage;
 }
 
-/*
- * page migration rate limiting control.
- * Do not migrate more than @pages_to_migrate in a @migrate_interval_millisecs
- * window of time. Default here says do not migrate more than 1280M per second.
- */
-static unsigned int migrate_interval_millisecs __read_mostly = 100;
-static unsigned int ratelimit_pages __read_mostly = 128 << (20 - PAGE_SHIFT);
-
-/* Returns true if the node is migrate rate-limited after the update */
-static bool numamigrate_update_ratelimit(pg_data_t *pgdat,
-					unsigned long nr_pages)
-{
-	unsigned long next_window, interval;
-
-	next_window = READ_ONCE(pgdat->numabalancing_migrate_next_window);
-	interval = msecs_to_jiffies(migrate_interval_millisecs);
-
-	/*
-	 * Rate-limit the amount of data that is being migrated to a node.
-	 * Optimal placement is no good if the memory bus is saturated and
-	 * all the time is being spent migrating!
-	 */
-	if (time_after(jiffies, next_window) &&
-			spin_trylock(&pgdat->numabalancing_migrate_lock)) {
-		pgdat->numabalancing_migrate_nr_pages = 0;
-		do {
-			next_window += interval;
-		} while (unlikely(time_after(jiffies, next_window)));
-
-		WRITE_ONCE(pgdat->numabalancing_migrate_next_window, next_window);
-		spin_unlock(&pgdat->numabalancing_migrate_lock);
-	}
-	if (pgdat->numabalancing_migrate_nr_pages > ratelimit_pages) {
-		trace_mm_numa_migrate_ratelimit(current, pgdat->node_id,
-								nr_pages);
-		return true;
-	}
-
-	/*
-	 * This is an unlocked non-atomic update so errors are possible.
-	 * The consequences are failing to migrate when we potentiall should
-	 * have which is not severe enough to warrant locking. If it is ever
-	 * a problem, it can be converted to a per-cpu counter.
-	 */
-	pgdat->numabalancing_migrate_nr_pages += nr_pages;
-	return false;
-}
-
 static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
 {
 	int page_lru;
@@ -1975,14 +1927,6 @@ int migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
 	if (page_is_file_cache(page) && PageDirty(page))
 		goto out;
 
-	/*
-	 * Rate-limit the amount of data that is being migrated to a node.
-	 * Optimal placement is no good if the memory bus is saturated and
-	 * all the time is being spent migrating!
-	 */
-	if (numamigrate_update_ratelimit(pgdat, 1))
-		goto out;
-
 	isolated = numamigrate_isolate_page(pgdat, page);
 	if (!isolated)
 		goto out;
@@ -2029,14 +1973,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	unsigned long mmun_start = address & HPAGE_PMD_MASK;
 	unsigned long mmun_end = mmun_start + HPAGE_PMD_SIZE;
 
-	/*
-	 * Rate-limit the amount of data that is being migrated to a node.
-	 * Optimal placement is no good if the memory bus is saturated and
-	 * all the time is being spent migrating!
-	 */
-	if (numamigrate_update_ratelimit(pgdat, HPAGE_PMD_NR))
-		goto out_dropref;
-
 	new_page = alloc_pages_node(node,
 		(GFP_TRANSHUGE_LIGHT | __GFP_THISNODE),
 		HPAGE_PMD_ORDER);
@@ -2133,7 +2069,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 
 out_fail:
 	count_vm_events(PGMIGRATE_FAIL, HPAGE_PMD_NR);
-out_dropref:
 	ptl = pmd_lock(mm, pmd);
 	if (pmd_same(*pmd, entry)) {
 		entry = pmd_modify(entry, vma->vm_page_prot);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 89d2a2ab3fe6..706a738c0aee 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6197,8 +6197,6 @@ static unsigned long __init calc_memmap_size(unsigned long spanned_pages,
 static void pgdat_init_numabalancing(struct pglist_data *pgdat)
 {
 	spin_lock_init(&pgdat->numabalancing_migrate_lock);
-	pgdat->numabalancing_migrate_nr_pages = 0;
-	pgdat->numabalancing_migrate_next_window = jiffies;
 }
 #else
 static void pgdat_init_numabalancing(struct pglist_data *pgdat) {}
