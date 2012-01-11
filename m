Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 17BE36B005A
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 17:41:12 -0500 (EST)
Received: by wgbed3 with SMTP id ed3so43373wgb.2
        for <linux-mm@kvack.org>; Wed, 11 Jan 2012 14:41:10 -0800 (PST)
From: Ying Han <yinghan@google.com>
Subject: memcg: add mlock statistic in memory.stat
Date: Wed, 11 Jan 2012 14:41:08 -0800
Message-Id: <1326321668-5422-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>
Cc: linux-mm@kvack.org

We have the nr_mlock stat both in meminfo as well as vmstat system wide, this
patch adds the mlock field into per-memcg memory stat. The stat itself enhances
the metrics exported by memcg, especially is used together with "uneivctable"
lru stat.

Tested:
$ cat /dev/cgroup/memory/memory.use_hierarchy
1

$ mkdir /dev/cgroup/memory/A
$ mkdir /dev/cgroup/memory/A/B
$ echo 1g >/dev/cgroup/memory/A/memory.limit_in_bytes
$ echo 1g >/dev/cgroup/memory/B/memory.limit_in_bytes

1. Run memtoy in B and mlock 512m file pages:
$ memtoy>file /export/hda3/file_512m
$ memtoy>map file_512m 0 512m shared
$ memtoy>lock file_512m
//meantime add some memory pressure.

$ cat /dev/cgroup/memory/A/B/memory.stat
...
mlock 536870912
unevictable 536870912
...
total_mlock 536870912
total_unevictable 536870912

$ cat /dev/cgroup/memory/A/memory.stat
...
mlock 0
unevictable 0
...
total_mlock 536870912
total_unevictable 536870912

2. unlock the file pages
$ memtoy>unlock file_512m
$ cat /dev/cgroup/memory/A/B/memory.stat
...
mlock 0
unevictable 0
...
total_mlock 0
total_unevictable 0

3. after step 1, move memtoy to A and force_empty B

$ cat /dev/cgroup/memory/A/B/memory.stat
...
mlock 0
unevictable 0
...
total_mlock 0
total_unevictable 0

$ cat /dev/cgroup/memory/A/memory.stat
...
mlock 536870912
unevictable 536870912
...
total_mlock 536870912
total_unevictable 536870912

Signed-off-by: Ying Han <yinghan@google.com>
---
 Documentation/cgroups/memory.txt |    2 ++
 include/linux/memcontrol.h       |    1 +
 include/linux/page_cgroup.h      |   11 +++++++++++
 mm/internal.h                    |    4 ++++
 mm/memcontrol.c                  |   27 ++++++++++++++++++++++++++-
 mm/mlock.c                       |    3 +++
 mm/page_alloc.c                  |    1 +
 7 files changed, 48 insertions(+), 1 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 09a9472..070c016 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -386,6 +386,7 @@ memory.stat file includes following statistics
 cache		- # of bytes of page cache memory.
 rss		- # of bytes of anonymous and swap cache memory.
 mapped_file	- # of bytes of mapped file (includes tmpfs/shmem)
+mlock		- # of bytes of mlocked memory.
 pgpgin		- # of charging events to the memory cgroup. The charging
 		event happens each time a page is accounted as either mapped
 		anon page(RSS) or cache page(Page Cache) to the cgroup.
@@ -410,6 +411,7 @@ hierarchical_memsw_limit - # of bytes of memory+swap limit with regard to
 total_cache		- sum of all children's "cache"
 total_rss		- sum of all children's "rss"
 total_mapped_file	- sum of all children's "cache"
+total_mlock		- sum of all children's "mlock"
 total_pgpgin		- sum of all children's "pgpgin"
 total_pgpgout		- sum of all children's "pgpgout"
 total_swap		- sum of all children's "swap"
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 4afc144..18f675b 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -30,6 +30,7 @@ struct mm_struct;
 /* Stats that can be updated by kernel. */
 enum mem_cgroup_page_stat_item {
 	MEMCG_NR_FILE_MAPPED, /* # of pages charged as file rss */
+	MEMCG_NR_MLOCK, /* # of pages charged as mlock */
 };
 
 struct mem_cgroup_reclaim_cookie {
diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index aaa60da..ec8e7c0 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -10,6 +10,7 @@ enum {
 	/* flags for mem_cgroup and file and I/O status */
 	PCG_MOVE_LOCK, /* For race between move_account v.s. following bits */
 	PCG_FILE_MAPPED, /* page is accounted as "mapped" */
+	PCG_MLOCK, /* page is accounted as "mlock" */
 	/* No lock in page_cgroup */
 	PCG_ACCT_LRU, /* page has been accounted for (under lru_lock) */
 	__NR_PCG_FLAGS,
@@ -62,6 +63,10 @@ static inline void SetPageCgroup##uname(struct page_cgroup *pc)\
 static inline void ClearPageCgroup##uname(struct page_cgroup *pc)	\
 	{ clear_bit(PCG_##lname, &pc->flags);  }
 
+#define TESTSETPCGFLAG(uname, lname)			\
+static inline int TestSetPageCgroup##uname(struct page_cgroup *pc)	\
+	{ return test_and_set_bit(PCG_##lname, &pc->flags); }
+
 #define TESTCLEARPCGFLAG(uname, lname)			\
 static inline int TestClearPageCgroup##uname(struct page_cgroup *pc)	\
 	{ return test_and_clear_bit(PCG_##lname, &pc->flags);  }
@@ -85,6 +90,12 @@ SETPCGFLAG(FileMapped, FILE_MAPPED)
 CLEARPCGFLAG(FileMapped, FILE_MAPPED)
 TESTPCGFLAG(FileMapped, FILE_MAPPED)
 
+SETPCGFLAG(Mlock, MLOCK)
+CLEARPCGFLAG(Mlock, MLOCK)
+TESTPCGFLAG(Mlock, MLOCK)
+TESTSETPCGFLAG(Mlock, MLOCK)
+TESTCLEARPCGFLAG(Mlock, MLOCK)
+
 SETPCGFLAG(Migration, MIGRATION)
 CLEARPCGFLAG(Migration, MIGRATION)
 TESTPCGFLAG(Migration, MIGRATION)
diff --git a/mm/internal.h b/mm/internal.h
index 2189af4..1366a21 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -12,6 +12,7 @@
 #define __MM_INTERNAL_H
 
 #include <linux/mm.h>
+#include <linux/memcontrol.h>
 
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
@@ -139,6 +140,7 @@ static inline int is_mlocked_vma(struct vm_area_struct *vma, struct page *page)
 		return 0;
 
 	if (!TestSetPageMlocked(page)) {
+		mem_cgroup_inc_page_stat(page, MEMCG_NR_MLOCK);
 		inc_zone_page_state(page, NR_MLOCK);
 		count_vm_event(UNEVICTABLE_PGMLOCKED);
 	}
@@ -177,8 +179,10 @@ static inline void mlock_migrate_page(struct page *newpage, struct page *page)
 		unsigned long flags;
 
 		local_irq_save(flags);
+		mem_cgroup_dec_page_stat(page, MEMCG_NR_MLOCK);
 		__dec_zone_page_state(page, NR_MLOCK);
 		SetPageMlocked(newpage);
+		mem_cgroup_inc_page_stat(newpage, MEMCG_NR_MLOCK);
 		__inc_zone_page_state(newpage, NR_MLOCK);
 		local_irq_restore(flags);
 	}
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 33f083a..4f540a7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -84,6 +84,7 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
 	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
 	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
+	MEM_CGROUP_STAT_MLOCK, /* # of pages charged as mlock()ed */
 	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
 	MEM_CGROUP_STAT_DATA, /* end of data requires synchronization */
 	MEM_CGROUP_ON_MOVE,	/* someone is moving account between groups */
@@ -1758,11 +1759,22 @@ void mem_cgroup_update_page_stat(struct page *page,
 			ClearPageCgroupFileMapped(pc);
 		idx = MEM_CGROUP_STAT_FILE_MAPPED;
 		break;
+	case MEMCG_NR_MLOCK:
+		if (val > 0) {
+			if (TestSetPageCgroupMlock(pc))
+				val = 0;
+		} else {
+			if (!TestClearPageCgroupMlock(pc))
+				val = 0;
+		}
+		idx = MEM_CGROUP_STAT_MLOCK;
+		break;
 	default:
 		BUG();
 	}
 
-	this_cpu_add(memcg->stat->count[idx], val);
+	if (val)
+		this_cpu_add(memcg->stat->count[idx], val);
 
 out:
 	if (unlikely(need_unlock))
@@ -2402,6 +2414,15 @@ static int mem_cgroup_move_account(struct page *page,
 		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
 		preempt_enable();
 	}
+
+	if (PageCgroupMlock(pc)) {
+		/* Update mlocked data for mem_cgroup */
+		preempt_disable();
+		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_MLOCK]);
+		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_MLOCK]);
+		preempt_enable();
+	}
+
 	mem_cgroup_charge_statistics(from, PageCgroupCache(pc), -nr_pages);
 	if (uncharge)
 		/* This is not "cancel", but cancel_charge does all we need. */
@@ -3728,6 +3749,7 @@ enum {
 	MCS_CACHE,
 	MCS_RSS,
 	MCS_FILE_MAPPED,
+	MCS_MLOCK,
 	MCS_PGPGIN,
 	MCS_PGPGOUT,
 	MCS_SWAP,
@@ -3754,6 +3776,7 @@ struct mem_cgroup_stat_name memcg_stat_strings[NR_MCS_STAT] = {
 	{"cache", "total_cache"},
 	{"rss", "total_rss"},
 	{"mapped_file", "total_mapped_file"},
+	{"mlock", "total_mlock"},
 	{"pgpgin", "total_pgpgin"},
 	{"pgpgout", "total_pgpgout"},
 	{"swap", "total_swap"},
@@ -3779,6 +3802,8 @@ mem_cgroup_get_local_stat(struct mem_cgroup *memcg, struct mcs_total_stat *s)
 	s->stat[MCS_RSS] += val * PAGE_SIZE;
 	val = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_FILE_MAPPED);
 	s->stat[MCS_FILE_MAPPED] += val * PAGE_SIZE;
+	val = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_MLOCK);
+	s->stat[MCS_MLOCK] += val * PAGE_SIZE;
 	val = mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_PGPGIN);
 	s->stat[MCS_PGPGIN] += val;
 	val = mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_PGPGOUT);
diff --git a/mm/mlock.c b/mm/mlock.c
index 4f4f53b..ad165ca 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -59,6 +59,7 @@ void __clear_page_mlock(struct page *page)
 		return;
 	}
 
+	mem_cgroup_dec_page_stat(page, MEMCG_NR_MLOCK);
 	dec_zone_page_state(page, NR_MLOCK);
 	count_vm_event(UNEVICTABLE_PGCLEARED);
 	if (!isolate_lru_page(page)) {
@@ -81,6 +82,7 @@ void mlock_vma_page(struct page *page)
 	BUG_ON(!PageLocked(page));
 
 	if (!TestSetPageMlocked(page)) {
+		mem_cgroup_inc_page_stat(page, MEMCG_NR_MLOCK);
 		inc_zone_page_state(page, NR_MLOCK);
 		count_vm_event(UNEVICTABLE_PGMLOCKED);
 		if (!isolate_lru_page(page))
@@ -108,6 +110,7 @@ void munlock_vma_page(struct page *page)
 	BUG_ON(!PageLocked(page));
 
 	if (TestClearPageMlocked(page)) {
+		mem_cgroup_dec_page_stat(page, MEMCG_NR_MLOCK);
 		dec_zone_page_state(page, NR_MLOCK);
 		if (!isolate_lru_page(page)) {
 			int ret = SWAP_AGAIN;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5c4922e..849426e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -634,6 +634,7 @@ out:
  */
 static inline void free_page_mlock(struct page *page)
 {
+	mem_cgroup_dec_page_stat(page, MEMCG_NR_MLOCK);
 	__dec_zone_page_state(page, NR_MLOCK);
 	__count_vm_event(UNEVICTABLE_MLOCKFREED);
 }
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
