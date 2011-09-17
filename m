Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 51BD4940068
	for <linux-mm@kvack.org>; Fri, 16 Sep 2011 23:39:50 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p8H3dlSu013340
	for <linux-mm@kvack.org>; Fri, 16 Sep 2011 20:39:47 -0700
Received: from pzk6 (pzk6.prod.google.com [10.243.19.134])
	by hpaq11.eem.corp.google.com with ESMTP id p8H3cANM018587
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 16 Sep 2011 20:39:45 -0700
Received: by pzk6 with SMTP id 6so3555641pzk.7
        for <linux-mm@kvack.org>; Fri, 16 Sep 2011 20:39:45 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 8/8] kstaled: add incrementally updating stale page count
Date: Fri, 16 Sep 2011 20:39:13 -0700
Message-Id: <1316230753-8693-9-git-send-email-walken@google.com>
In-Reply-To: <1316230753-8693-1-git-send-email-walken@google.com>
References: <1316230753-8693-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Michael Wolf <mjwolf@us.ibm.com>

Add an incrementally updating stale page count. A new per-cgroup
memory.stale_page_age file is introduced. After a non-zero number of scan
cycles is written there, pages that have been idle for at least that number
of cycles and are currently clean are reported in memory.idle_page_stats
as being stale. Contrary to the idle_*_clean statistic, this stale page
count is continually updated - hooks have been added to notice pages being
accessed or rendered unevictable, at which point the stale page count for
that cgroup is instantly decremented. The point is to allow userspace to
quickly respond to increased memory pressure.


Signed-off-by: Michel Lespinasse <walken@google.com>
---
 include/linux/page-flags.h |   15 ++++++++
 include/linux/pagemap.h    |   11 ++++--
 mm/internal.h              |    1 +
 mm/memcontrol.c            |   82 ++++++++++++++++++++++++++++++++++++++++++--
 mm/mlock.c                 |    1 +
 mm/vmscan.c                |    2 +-
 6 files changed, 104 insertions(+), 8 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index e964d98..22dbe90 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -58,6 +58,8 @@
  *
  * PG_idle indicates that the page has not been referenced since the last time
  * kstaled scanned it.
+ *
+ * PG_stale indicates that the page is currently counted as stale.
  */
 
 /*
@@ -117,6 +119,7 @@ enum pageflags {
 #ifdef CONFIG_KSTALED
 	PG_young,		/* kstaled cleared pte_young */
 	PG_idle,		/* idle since start of kstaled interval */
+	PG_stale,		/* page is counted as stale */
 #endif
 	__NR_PAGEFLAGS,
 
@@ -293,21 +296,33 @@ PAGEFLAG_FALSE(HWPoison)
 
 PAGEFLAG(Young, young)
 PAGEFLAG(Idle, idle)
+PAGEFLAG(Stale, stale) TESTSCFLAG(Stale, stale)
+
+void __set_page_nonstale(struct page *page);
+
+static inline void set_page_nonstale(struct page *page)
+{
+	if (PageStale(page))
+		__set_page_nonstale(page);
+}
 
 static inline void set_page_young(struct page *page)
 {
+	set_page_nonstale(page);
 	if (!PageYoung(page))
 		SetPageYoung(page);
 }
 
 static inline void clear_page_idle(struct page *page)
 {
+	set_page_nonstale(page);
 	if (PageIdle(page))
 		ClearPageIdle(page);
 }
 
 #else /* !CONFIG_KSTALED */
 
+static inline void set_page_nonstale(struct page *page) {}
 static inline void set_page_young(struct page *page) {}
 static inline void clear_page_idle(struct page *page) {}
 
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 716875e..693dd20 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -46,11 +46,14 @@ static inline void mapping_clear_unevictable(struct address_space *mapping)
 	clear_bit(AS_UNEVICTABLE, &mapping->flags);
 }
 
-static inline int mapping_unevictable(struct address_space *mapping)
+static inline int mapping_unevictable(struct address_space *mapping,
+				      struct page *page)
 {
-	if (mapping)
-		return test_bit(AS_UNEVICTABLE, &mapping->flags);
-	return !!mapping;
+	if (mapping && test_bit(AS_UNEVICTABLE, &mapping->flags)) {
+		set_page_nonstale(page);
+		return 1;
+	}
+	return 0;
 }
 
 static inline gfp_t mapping_gfp_mask(struct address_space * mapping)
diff --git a/mm/internal.h b/mm/internal.h
index d071d38..d1cb0d6 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -93,6 +93,7 @@ static inline int is_mlocked_vma(struct vm_area_struct *vma, struct page *page)
 		return 0;
 
 	if (!TestSetPageMlocked(page)) {
+		set_page_nonstale(page);
 		inc_zone_page_state(page, NR_MLOCK);
 		count_vm_event(UNEVICTABLE_PGMLOCKED);
 	}
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ef406a1..da21830 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -292,6 +292,8 @@ struct mem_cgroup {
 	spinlock_t pcp_counter_lock;
 
 #ifdef CONFIG_KSTALED
+	int stale_page_age;
+
 	seqcount_t idle_page_stats_lock;
 	struct idle_page_stats {
 		unsigned long idle_clean;
@@ -299,6 +301,7 @@ struct mem_cgroup {
 		unsigned long idle_dirty_swap;
 	} idle_page_stats[NUM_KSTALED_BUCKETS],
 	  idle_scan_stats[NUM_KSTALED_BUCKETS];
+	atomic_long_t stale_pages;
 	unsigned long idle_page_scans;
 #endif
 };
@@ -2639,6 +2642,13 @@ static int mem_cgroup_move_account(struct page *page,
 		preempt_enable();
 	}
 	mem_cgroup_charge_statistics(from, PageCgroupCache(pc), -nr_pages);
+
+#ifdef CONFIG_KSTALED
+	/* Count page as non-stale */
+	if (PageStale(page) && TestClearPageStale(page))
+		atomic_long_dec(&from->stale_pages);
+#endif
+
 	if (uncharge)
 		/* This is not "cancel", but cancel_charge does all we need. */
 		__mem_cgroup_cancel_charge(from, nr_pages);
@@ -3067,6 +3077,12 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 
 	mem_cgroup_charge_statistics(mem, PageCgroupCache(pc), -nr_pages);
 
+#ifdef CONFIG_KSTALED
+	/* Count page as non-stale */
+	if (PageStale(page) && TestClearPageStale(page))
+		atomic_long_dec(&mem->stale_pages);
+#endif
+
 	ClearPageCgroupUsed(pc);
 	/*
 	 * pc->mem_cgroup is not cleared here. It will be accessed when it's
@@ -4716,6 +4732,29 @@ static int mem_cgroup_idle_page_stats_read(struct cgroup *cgrp,
 		cb->fill(cb, name, stats[bucket].idle_dirty_swap * PAGE_SIZE);
 	}
 	cb->fill(cb, "scans", scans);
+	cb->fill(cb, "stale",
+		 max(atomic_long_read(&mem->stale_pages), 0L) * PAGE_SIZE);
+
+	return 0;
+}
+
+static u64 mem_cgroup_stale_page_age_read(struct cgroup *cgrp,
+					  struct cftype *cft)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
+
+	return mem->stale_page_age;
+}
+
+static int mem_cgroup_stale_page_age_write(struct cgroup *cgrp,
+					   struct cftype *cft, u64 val)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
+
+	if (val > 255)
+		return -EINVAL;
+
+	mem->stale_page_age = val;
 
 	return 0;
 }
@@ -4796,6 +4835,11 @@ static struct cftype mem_cgroup_files[] = {
 		.name = "idle_page_stats",
 		.read_map = mem_cgroup_idle_page_stats_read,
 	},
+	{
+		.name = "stale_page_age",
+		.read_u64 = mem_cgroup_stale_page_age_read,
+		.write_u64 = mem_cgroup_stale_page_age_write,
+	},
 #endif
 };
 
@@ -5716,7 +5760,7 @@ static inline void kstaled_scan_page(struct page *page, u8 *idle_page_age)
 		 */
 		if (!mapping && !PageSwapCache(page))
 			goto out;
-		else if (mapping_unevictable(mapping))
+		else if (mapping_unevictable(mapping, page))
 			goto out;
 		else if (PageSwapCache(page) ||
 			 mapping_cap_swap_backed(mapping))
@@ -5751,13 +5795,23 @@ static inline void kstaled_scan_page(struct page *page, u8 *idle_page_age)
 
 	/* Finally increment the correct statistic for this page. */
 	if (!(info.pr_flags & PR_DIRTY) &&
-	    !PageDirty(page) && !PageWriteback(page))
+	    !PageDirty(page) && !PageWriteback(page)) {
 		stats->idle_clean++;
-	else if (is_file)
+
+		if (mem->stale_page_age && age >= mem->stale_page_age) {
+			if (!PageStale(page) && !TestSetPageStale(page))
+				atomic_long_inc(&mem->stale_pages);
+			goto unlock_page_cgroup_out;
+		}
+	} else if (is_file)
 		stats->idle_dirty_file++;
 	else
 		stats->idle_dirty_swap++;
 
+	/* Count page as non-stale */
+	if (PageStale(page) && TestClearPageStale(page))
+		atomic_long_dec(&mem->stale_pages);
+
  unlock_page_cgroup_out:
 	unlock_page_cgroup(pc);
 
@@ -5767,6 +5821,28 @@ static inline void kstaled_scan_page(struct page *page, u8 *idle_page_age)
 	put_page(page);
 }
 
+void __set_page_nonstale(struct page *page)
+{
+	struct page_cgroup *pc;
+	struct mem_cgroup *mem;
+
+	/* Locate kstaled stats for the page's cgroup. */
+	pc = lookup_page_cgroup(page);
+	if (!pc)
+		return;
+	lock_page_cgroup(pc);
+	mem = pc->mem_cgroup;
+	if (!PageCgroupUsed(pc))
+		goto out;
+
+	/* Count page as non-stale */
+	if (TestClearPageStale(page))
+		atomic_long_dec(&mem->stale_pages);
+
+out:
+	unlock_page_cgroup(pc);
+}
+
 static bool kstaled_scan_node(pg_data_t *pgdat, int scan_seconds, bool reset)
 {
 	unsigned long flags;
diff --git a/mm/mlock.c b/mm/mlock.c
index 048260c..eac4c32 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -81,6 +81,7 @@ void mlock_vma_page(struct page *page)
 	BUG_ON(!PageLocked(page));
 
 	if (!TestSetPageMlocked(page)) {
+		set_page_nonstale(page);
 		inc_zone_page_state(page, NR_MLOCK);
 		count_vm_event(UNEVICTABLE_PGMLOCKED);
 		if (!isolate_lru_page(page))
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7bd9868..752fd21 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3203,7 +3203,7 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 int page_evictable(struct page *page, struct vm_area_struct *vma)
 {
 
-	if (mapping_unevictable(page_mapping(page)))
+	if (mapping_unevictable(page_mapping(page), page))
 		return 0;
 
 	if (PageMlocked(page) || (vma && is_mlocked_vma(vma, page)))
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
