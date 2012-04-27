Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 7A3086B00FE
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 15:14:49 -0400 (EDT)
Received: by qcse1 with SMTP id e1so120401qcs.2
        for <linux-mm@kvack.org>; Fri, 27 Apr 2012 12:14:48 -0700 (PDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH 2/2] memcg: add mlock statistic in memory.stat
Date: Fri, 27 Apr 2012 12:14:46 -0700
Message-Id: <1335554086-4294-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

We have the nr_mlock stat both in meminfo as well as vmstat system wide, this
patch adds the mlock field into per-memcg memory stat. The stat itself enhances
the metrics exported by memcg since the unevictable lru includes more than
mlock()'d page like SHM_LOCK'd.

Why we need to count mlock'd pages while they are unevictable and we can not
do much on them anyway?

This is true. The mlock stat I am proposing is more helpful for system admin
and kernel developer to understand the system workload. The same information
should be helpful to add into OOM log as well. Many times in the past that we
need to read the mlock stat from the per-container meminfo for different
reason. Afterall, we do have the ability to read the mlock from meminfo and
this patch fills the info in memcg.

Note:
Here are the places where I didn't add the hook:
1. in the mlock_migrate_page() since the owner of oldpage and newpage is the same.
2. in the freeing path since page shouldn't get to there at the first place.

v3..v2:
1. removes the mlock stat update on the freeing path since memcg could be
destroyed by that time. added comment indicating why it might still be safe
not updating the stat there at all.
2. ran page fault test and included the performance number.

v2..v1:
1. rebase on top of 3.4-rc2 and the code is based on the following commit
went into 3.4-rc1:

Tested:
1 )
$ cat /dev/cgroup/memory/memory.use_hierarchy
1

$ mkdir /dev/cgroup/memory/A
$ mkdir /dev/cgroup/memory/A/B
$ echo 1g >/dev/cgroup/memory/A/memory.limit_in_bytes
$ echo 1g >/dev/cgroup/memory/B/memory.limit_in_bytes

1. Run memtoy in B and mlock 512m file pages:
memtoy>file /export/hda3/file_512m private
memtoy>map file_512m 0 512m
memtoy>lock file_512m
memtoy:  mlock of file_512m [131072 pages] took  5.296secs.

$ cat /dev/cgroup/memory/A/B/memory.stat
mlock 536870912
unevictable 536870912
..
total_mlock 536870912
total_unevictable 536870912

$ cat /dev/cgroup/memory/A/memory.stat
mlock 0
unevictable 0
..
total_mlock 536870912
total_unevictable 536870912

2)Create 20g memcg and run single thread page fault test (pft) w/ 10g mlock memory,
here it measures faults/cpu/second:

x before.txt
+ after.txt
+--------------------------------------------------------------------------+
    N           Min           Max        Median           Avg        Stddev
x  10     346345.92     349113.01     347470.52     347651.93     819.71411
+  10     345934.67     348973.58      347677.9     347495.33     833.58657
No difference proven at 95.0% confidence

Signed-off-by: Ying Han <yinghan@google.com>
---
 Documentation/cgroups/memory.txt |    2 ++
 include/linux/memcontrol.h       |    1 +
 mm/internal.h                    |   18 ++++++++++++++++++
 mm/memcontrol.c                  |   16 ++++++++++++++++
 mm/mlock.c                       |   15 +++++++++++++++
 mm/page_alloc.c                  |   10 ++++++++++
 6 files changed, 62 insertions(+), 0 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 9b1067a..2f53399 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -409,6 +409,7 @@ memory.stat file includes following statistics
 cache		- # of bytes of page cache memory.
 rss		- # of bytes of anonymous and swap cache memory.
 mapped_file	- # of bytes of mapped file (includes tmpfs/shmem)
+mlock		- # of bytes of mlocked memory.
 pgpgin		- # of charging events to the memory cgroup. The charging
 		event happens each time a page is accounted as either mapped
 		anon page(RSS) or cache page(Page Cache) to the cgroup.
@@ -433,6 +434,7 @@ hierarchical_memsw_limit - # of bytes of memory+swap limit with regard to
 total_cache		- sum of all children's "cache"
 total_rss		- sum of all children's "rss"
 total_mapped_file	- sum of all children's "cache"
+total_mlock		- sum of all children's "mlock"
 total_pgpgin		- sum of all children's "pgpgin"
 total_pgpgout		- sum of all children's "pgpgout"
 total_swap		- sum of all children's "swap"
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index f94efd2..112b573 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -30,6 +30,7 @@ struct mm_struct;
 /* Stats that can be updated by kernel. */
 enum mem_cgroup_page_stat_item {
 	MEMCG_NR_FILE_MAPPED, /* # of pages charged as file rss */
+	MEMCG_NR_MLOCK, /* # of pages charged as mlock */
 };
 
 struct mem_cgroup_reclaim_cookie {
diff --git a/mm/internal.h b/mm/internal.h
index 2189af4..96684b5 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -12,6 +12,7 @@
 #define __MM_INTERNAL_H
 
 #include <linux/mm.h>
+#include <linux/memcontrol.h>
 
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
@@ -133,15 +134,22 @@ static inline void munlock_vma_pages_all(struct vm_area_struct *vma)
  */
 static inline int is_mlocked_vma(struct vm_area_struct *vma, struct page *page)
 {
+	bool locked;
+	unsigned long flags;
+
 	VM_BUG_ON(PageLRU(page));
 
 	if (likely((vma->vm_flags & (VM_LOCKED | VM_SPECIAL)) != VM_LOCKED))
 		return 0;
 
+	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
 	if (!TestSetPageMlocked(page)) {
 		inc_zone_page_state(page, NR_MLOCK);
+		mem_cgroup_inc_page_stat(page, MEMCG_NR_MLOCK);
 		count_vm_event(UNEVICTABLE_PGMLOCKED);
 	}
+	mem_cgroup_end_update_page_stat(page, &locked, &flags);
+
 	return 1;
 }
 
@@ -163,8 +171,13 @@ extern void munlock_vma_page(struct page *page);
 extern void __clear_page_mlock(struct page *page);
 static inline void clear_page_mlock(struct page *page)
 {
+	bool locked;
+	unsigned long flags;
+
+	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
 	if (unlikely(TestClearPageMlocked(page)))
 		__clear_page_mlock(page);
+	mem_cgroup_end_update_page_stat(page, &locked, &flags);
 }
 
 /*
@@ -173,6 +186,11 @@ static inline void clear_page_mlock(struct page *page)
  */
 static inline void mlock_migrate_page(struct page *newpage, struct page *page)
 {
+	/*
+	 * Here we are supposed to update the page memcg's mlock stat and the
+	 * newpage memcgs' mlock. Since the page and newpage are always being
+	 * charged to the same memcg, so no need.
+	 */
 	if (TestClearPageMlocked(page)) {
 		unsigned long flags;
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b868def..5810241 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -87,6 +87,7 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
 	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
 	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
+	MEM_CGROUP_STAT_MLOCK, /* # of pages charged as mlock()ed */
 	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
 	MEM_CGROUP_STAT_DATA, /* end of data requires synchronization */
 	MEM_CGROUP_STAT_NSTATS,
@@ -1975,6 +1976,9 @@ void mem_cgroup_update_page_stat(struct page *page,
 	case MEMCG_NR_FILE_MAPPED:
 		idx = MEM_CGROUP_STAT_FILE_MAPPED;
 		break;
+	case MEMCG_NR_MLOCK:
+		idx = MEM_CGROUP_STAT_MLOCK;
+		break;
 	default:
 		BUG();
 	}
@@ -2627,6 +2631,14 @@ static int mem_cgroup_move_account(struct page *page,
 		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
 		preempt_enable();
 	}
+
+	if (PageMlocked(page)) {
+		/* Update mlocked data for mem_cgroup */
+		preempt_disable();
+		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_MLOCK]);
+		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_MLOCK]);
+		preempt_enable();
+	}
 	mem_cgroup_charge_statistics(from, anon, -nr_pages);
 	if (uncharge)
 		/* This is not "cancel", but cancel_charge does all we need. */
@@ -4048,6 +4060,7 @@ enum {
 	MCS_CACHE,
 	MCS_RSS,
 	MCS_FILE_MAPPED,
+	MCS_MLOCK,
 	MCS_PGPGIN,
 	MCS_PGPGOUT,
 	MCS_SWAP,
@@ -4072,6 +4085,7 @@ struct {
 	{"cache", "total_cache"},
 	{"rss", "total_rss"},
 	{"mapped_file", "total_mapped_file"},
+	{"mlock", "total_mlock"},
 	{"pgpgin", "total_pgpgin"},
 	{"pgpgout", "total_pgpgout"},
 	{"swap", "total_swap"},
@@ -4097,6 +4111,8 @@ mem_cgroup_get_local_stat(struct mem_cgroup *memcg, struct mcs_total_stat *s)
 	s->stat[MCS_RSS] += val * PAGE_SIZE;
 	val = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_FILE_MAPPED);
 	s->stat[MCS_FILE_MAPPED] += val * PAGE_SIZE;
+	val = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_MLOCK);
+	s->stat[MCS_MLOCK] += val * PAGE_SIZE;
 	val = mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_PGPGIN);
 	s->stat[MCS_PGPGIN] += val;
 	val = mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_PGPGOUT);
diff --git a/mm/mlock.c b/mm/mlock.c
index ef726e8..cef0201 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -50,6 +50,8 @@ EXPORT_SYMBOL(can_do_mlock);
 
 /*
  *  LRU accounting for clear_page_mlock()
+ *  Make sure the caller calls mem_cgroup_begin[end]_update_page_stat,
+ *  otherwise it will be race between "move" and "page stat accounting".
  */
 void __clear_page_mlock(struct page *page)
 {
@@ -60,6 +62,7 @@ void __clear_page_mlock(struct page *page)
 	}
 
 	dec_zone_page_state(page, NR_MLOCK);
+	mem_cgroup_dec_page_stat(page, MEMCG_NR_MLOCK);
 	count_vm_event(UNEVICTABLE_PGCLEARED);
 	if (!isolate_lru_page(page)) {
 		putback_lru_page(page);
@@ -78,14 +81,20 @@ void __clear_page_mlock(struct page *page)
  */
 void mlock_vma_page(struct page *page)
 {
+	bool locked;
+	unsigned long flags;
+
 	BUG_ON(!PageLocked(page));
 
+	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
 	if (!TestSetPageMlocked(page)) {
 		inc_zone_page_state(page, NR_MLOCK);
+		mem_cgroup_inc_page_stat(page, MEMCG_NR_MLOCK);
 		count_vm_event(UNEVICTABLE_PGMLOCKED);
 		if (!isolate_lru_page(page))
 			putback_lru_page(page);
 	}
+	mem_cgroup_end_update_page_stat(page, &locked, &flags);
 }
 
 /**
@@ -105,10 +114,15 @@ void mlock_vma_page(struct page *page)
  */
 void munlock_vma_page(struct page *page)
 {
+	bool locked;
+	unsigned long flags;
+
 	BUG_ON(!PageLocked(page));
 
+	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
 	if (TestClearPageMlocked(page)) {
 		dec_zone_page_state(page, NR_MLOCK);
+		mem_cgroup_dec_page_stat(page, MEMCG_NR_MLOCK);
 		if (!isolate_lru_page(page)) {
 			int ret = SWAP_AGAIN;
 
@@ -141,6 +155,7 @@ void munlock_vma_page(struct page *page)
 				count_vm_event(UNEVICTABLE_PGMUNLOCKED);
 		}
 	}
+	mem_cgroup_end_update_page_stat(page, &locked, &flags);
 }
 
 /**
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4f905af..ffe5849 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -727,6 +727,11 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 		return;
 
 	local_irq_save(flags);
+	/*
+	 * Note: we didn't update the page memcg's mlock stat since we believe
+	 * the mlocked page shouldn't get to here. However, we could be wrong
+	 * and a warn_once would tell us.
+	 */
 	if (unlikely(wasMlocked))
 		free_page_mlock(page);
 	__count_vm_events(PGFREE, 1 << order);
@@ -1263,6 +1268,11 @@ void free_hot_cold_page(struct page *page, int cold)
 	migratetype = get_pageblock_migratetype(page);
 	set_page_private(page, migratetype);
 	local_irq_save(flags);
+	/*
+	 * Note: we didn't update the page memcg's mlock stat since we believe
+	 * the mlocked page shouldn't get to here. However, we could be wrong
+	 * and a warn_once would tell us.
+	 */
 	if (unlikely(wasMlocked))
 		free_page_mlock(page);
 	__count_vm_event(PGFREE);
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
