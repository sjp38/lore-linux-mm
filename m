Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id DC4376B00A9
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 20:22:54 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fa10so30672pad.13
        for <linux-mm@kvack.org>; Mon, 29 Apr 2013 17:22:54 -0700 (PDT)
Date: Mon, 29 Apr 2013 17:22:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, memcg: add rss_huge stat to memory.stat
In-Reply-To: <alpine.DEB.2.02.1304281432160.5570@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1304291721550.4634@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1304251440190.27228@chino.kir.corp.google.com> <20130426111739.GF31157@dhcp22.suse.cz> <alpine.DEB.2.02.1304281432160.5570@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This exports the amount of anonymous transparent hugepages for each memcg
via the new "rss_huge" stat in memory.stat.  The units are in bytes.

This is helpful to determine the hugepage utilization for individual jobs
on the system in comparison to rss and opportunities where MADV_HUGEPAGE
may be helpful.

The amount of anonymous transparent hugepages is also included in "rss"
for backwards compatibility.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/cgroups/memory.txt |  4 +++-
 mm/memcontrol.c                  | 36 ++++++++++++++++++++++++++----------
 2 files changed, 29 insertions(+), 11 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -478,7 +478,9 @@ memory.stat file includes following statistics
 
 # per-memory cgroup local status
 cache		- # of bytes of page cache memory.
-rss		- # of bytes of anonymous and swap cache memory.
+rss		- # of bytes of anonymous and swap cache memory (includes
+		transparent hugepages).
+rss_huge	- # of bytes of anonymous transparent hugepages.
 mapped_file	- # of bytes of mapped file (includes tmpfs/shmem)
 pgpgin		- # of charging events to the memory cgroup. The charging
 		event happens each time a page is accounted as either mapped
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -91,16 +91,18 @@ enum mem_cgroup_stat_index {
 	/*
 	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
 	 */
-	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
-	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
-	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
-	MEM_CGROUP_STAT_SWAP, /* # of pages, swapped out */
+	MEM_CGROUP_STAT_CACHE,		/* # of pages charged as cache */
+	MEM_CGROUP_STAT_RSS,		/* # of pages charged as anon rss */
+	MEM_CGROUP_STAT_RSS_HUGE,	/* # of pages charged as anon huge */
+	MEM_CGROUP_STAT_FILE_MAPPED,	/* # of pages charged as file rss */
+	MEM_CGROUP_STAT_SWAP,		/* # of pages, swapped out */
 	MEM_CGROUP_STAT_NSTATS,
 };
 
 static const char * const mem_cgroup_stat_names[] = {
 	"cache",
 	"rss",
+	"rss_huge",
 	"mapped_file",
 	"swap",
 };
@@ -888,6 +890,7 @@ static unsigned long mem_cgroup_read_events(struct mem_cgroup *memcg,
 }
 
 static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
+					 struct page *page,
 					 bool anon, int nr_pages)
 {
 	preempt_disable();
@@ -903,6 +906,10 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
 		__this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_CACHE],
 				nr_pages);
 
+	if (PageTransHuge(page))
+		__this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_RSS_HUGE],
+				nr_pages);
+
 	/* pagein of a big page is an event. So, ignore page size */
 	if (nr_pages > 0)
 		__this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_PGPGIN]);
@@ -2813,7 +2820,7 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
 	else
 		anon = false;
 
-	mem_cgroup_charge_statistics(memcg, anon, nr_pages);
+	mem_cgroup_charge_statistics(memcg, page, anon, nr_pages);
 	unlock_page_cgroup(pc);
 
 	/*
@@ -3603,16 +3610,21 @@ void mem_cgroup_split_huge_fixup(struct page *head)
 {
 	struct page_cgroup *head_pc = lookup_page_cgroup(head);
 	struct page_cgroup *pc;
+	struct mem_cgroup *memcg;
 	int i;
 
 	if (mem_cgroup_disabled())
 		return;
+
+	memcg = head_pc->mem_cgroup;
 	for (i = 1; i < HPAGE_PMD_NR; i++) {
 		pc = head_pc + i;
-		pc->mem_cgroup = head_pc->mem_cgroup;
+		pc->mem_cgroup = memcg;
 		smp_wmb();/* see __commit_charge() */
 		pc->flags = head_pc->flags & ~PCGF_NOCOPY_AT_SPLIT;
 	}
+	__this_cpu_sub(memcg->stat->count[MEM_CGROUP_STAT_RSS_HUGE],
+		       HPAGE_PMD_NR);
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
@@ -3668,11 +3680,11 @@ static int mem_cgroup_move_account(struct page *page,
 		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
 		preempt_enable();
 	}
-	mem_cgroup_charge_statistics(from, anon, -nr_pages);
+	mem_cgroup_charge_statistics(from, page, anon, -nr_pages);
 
 	/* caller should have done css_get */
 	pc->mem_cgroup = to;
-	mem_cgroup_charge_statistics(to, anon, nr_pages);
+	mem_cgroup_charge_statistics(to, page, anon, nr_pages);
 	move_unlock_mem_cgroup(from, &flags);
 	ret = 0;
 unlock:
@@ -4047,7 +4059,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype,
 		break;
 	}
 
-	mem_cgroup_charge_statistics(memcg, anon, -nr_pages);
+	mem_cgroup_charge_statistics(memcg, page, anon, -nr_pages);
 
 	ClearPageCgroupUsed(pc);
 	/*
@@ -4397,7 +4409,7 @@ void mem_cgroup_replace_page_cache(struct page *oldpage,
 	lock_page_cgroup(pc);
 	if (PageCgroupUsed(pc)) {
 		memcg = pc->mem_cgroup;
-		mem_cgroup_charge_statistics(memcg, false, -1);
+		mem_cgroup_charge_statistics(memcg, oldpage, false, -1);
 		ClearPageCgroupUsed(pc);
 	}
 	unlock_page_cgroup(pc);
@@ -4925,6 +4937,10 @@ static inline u64 mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
 			return res_counter_read_u64(&memcg->memsw, RES_USAGE);
 	}
 
+	/*
+	 * Transparent hugepages are still accounted for in MEM_CGROUP_STAT_RSS
+	 * as well as in MEM_CGROUP_STAT_RSS_HUGE.
+	 */
 	val = mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_CACHE);
 	val += mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_RSS);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
