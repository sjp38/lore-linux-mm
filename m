Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6022E6B02AA
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 06:07:39 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o75A8NLv021648
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 5 Aug 2010 19:08:23 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E65BA45DE51
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 19:08:22 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C7BF645DE50
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 19:08:22 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AF8261DB803E
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 19:08:22 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5BE7F1DB8038
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 19:08:22 +0900 (JST)
Date: Thu, 5 Aug 2010 19:03:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 4/4 -mm][memcg] generic file-stat accounting interface for
 memcg
Message-Id: <20100805190329.e9c4a12b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100805184434.3a29c0f9.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100805184434.3a29c0f9.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, vgoyal@redhat.com, m-ikeda@ds.jp.nec.com, gthelen@google.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Preparing for adding new status arounf file caches.(dirty, writeback,etc..)
Using a unified macro and more generic names.
All counters will have the same rule for updating.

Changelog:
 - resrructured for clean up.
 - added VM_BUG_ON().

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h  |   24 ++++++++++++++++++++++
 include/linux/page_cgroup.h |   19 ++++++++++++------
 mm/memcontrol.c             |   46 ++++++++++++++++++--------------------------
 3 files changed, 56 insertions(+), 33 deletions(-)

Index: mmotm-0727/include/linux/memcontrol.h
===================================================================
--- mmotm-0727.orig/include/linux/memcontrol.h
+++ mmotm-0727/include/linux/memcontrol.h
@@ -25,6 +25,30 @@ struct page_cgroup;
 struct page;
 struct mm_struct;
 
+/*
+ * Per-cpu Statistics for memory cgroup.
+ */
+enum mem_cgroup_stat_index {
+	/*
+	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
+	 */
+	MEM_CGROUP_STAT_CACHE,		/* # of pages charged as cache */
+	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
+	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
+	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
+	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
+	MEM_CGROUP_EVENTS,	/* incremented at every  pagein/pageout */
+	MEM_CGROUP_ON_MOVE,   /* A check for locking move account/status */
+	/* When you add new member for file-stat, please update page_cgroup.h */
+	MEM_CGROUP_FSTAT_BASE,
+	MEM_CGROUP_FSTAT_FILE_MAPPED = MEM_CGROUP_FSTAT_BASE,
+	MEM_CGROUP_FSTAT_END,
+	MEM_CGROUP_STAT_NSTATS = MEM_CGROUP_FSTAT_END,
+};
+
+#define MEMCG_FSTAT_IDX(idx)	((idx) - MEM_CGROUP_FSTAT_BASE)
+#define NR_FILE_FLAGS_MEMCG ((MEM_CGROUP_FSTAT_END - MEM_CGROUP_FSTAT_BASE))
+
 extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 					struct list_head *dst,
 					unsigned long *scanned, int order,
Index: mmotm-0727/mm/memcontrol.c
===================================================================
--- mmotm-0727.orig/mm/memcontrol.c
+++ mmotm-0727/mm/memcontrol.c
@@ -74,24 +74,6 @@ static int really_do_swap_account __init
 #define THRESHOLDS_EVENTS_THRESH (7) /* once in 128 */
 #define SOFTLIMIT_EVENTS_THRESH (10) /* once in 1024 */
 
-/*
- * Statistics for memory cgroup.
- */
-enum mem_cgroup_stat_index {
-	/*
-	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
-	 */
-	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
-	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
-	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
-	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
-	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
-	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
-	MEM_CGROUP_EVENTS,	/* incremented at every  pagein/pageout */
-	MEM_CGROUP_ON_MOVE,   /* A check for locking move account/status */
-
-	MEM_CGROUP_STAT_NSTATS,
-};
 
 struct mem_cgroup_stat_cpu {
 	s64 count[MEM_CGROUP_STAT_NSTATS];
@@ -1513,7 +1495,8 @@ bool mem_cgroup_handle_oom(struct mem_cg
  * Currently used to update mapped file statistics, but the routine can be
  * generalized to update other statistics as well.
  */
-void mem_cgroup_update_file_mapped(struct page *page, int val)
+static void
+mem_cgroup_update_file_stat(struct page *page, unsigned int idx, int val)
 {
 	struct mem_cgroup *mem;
 	struct page_cgroup *pc;
@@ -1537,11 +1520,11 @@ void mem_cgroup_update_file_mapped(struc
 	if (unlikely(!PageCgroupUsed(pc)))
 		goto done;
 	if (val > 0) {
-		this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
-		SetPageCgroupFileMapped(pc);
+		this_cpu_inc(mem->stat->count[idx]);
+		set_bit(fflag_idx(MEMCG_FSTAT_IDX(idx)), &pc->flags);
 	} else {
-		this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
-		ClearPageCgroupFileMapped(pc);
+		this_cpu_dec(mem->stat->count[idx]);
+		clear_bit(fflag_idx(MEMCG_FSTAT_IDX(idx)), &pc->flags);
 	}
 done:
 	if (need_lock)
@@ -1549,6 +1532,12 @@ done:
 	rcu_read_unlock();
 }
 
+void mem_cgroup_update_file_mapped(struct page *page, int val)
+{
+	return mem_cgroup_update_file_stat(page,
+		MEM_CGROUP_FSTAT_FILE_MAPPED, val);
+}
+
 /*
  * size of first charge trial. "32" comes from vmscan.c's magic value.
  * TODO: maybe necessary to use big numbers in big irons.
@@ -2008,17 +1997,20 @@ static void __mem_cgroup_commit_charge(s
 static void __mem_cgroup_move_account(struct page_cgroup *pc,
 	struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge)
 {
+	int i;
 	VM_BUG_ON(from == to);
 	VM_BUG_ON(PageLRU(pc->page));
 	VM_BUG_ON(!PageCgroupLocked(pc));
 	VM_BUG_ON(!PageCgroupUsed(pc));
 	VM_BUG_ON(id_to_memcg(pc->mem_cgroup) != from);
 
-	if (PageCgroupFileMapped(pc)) {
+	for (i = MEM_CGROUP_FSTAT_BASE; i < MEM_CGROUP_FSTAT_END; ++i) {
+		if (!test_bit(fflag_idx(MEMCG_FSTAT_IDX(i)), &pc->flags))
+			continue;
 		/* Update mapped_file data for mem_cgroup */
 		preempt_disable();
-		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
-		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
+		__this_cpu_dec(from->stat->count[i]);
+		__this_cpu_inc(to->stat->count[i]);
 		preempt_enable();
 	}
 	mem_cgroup_charge_statistics(from, pc, false);
@@ -3448,7 +3440,7 @@ static int mem_cgroup_get_local_stat(str
 	s->stat[MCS_CACHE] += val * PAGE_SIZE;
 	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_RSS);
 	s->stat[MCS_RSS] += val * PAGE_SIZE;
-	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_FILE_MAPPED);
+	val = mem_cgroup_read_stat(mem, MEM_CGROUP_FSTAT_FILE_MAPPED);
 	s->stat[MCS_FILE_MAPPED] += val * PAGE_SIZE;
 	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_PGPGIN_COUNT);
 	s->stat[MCS_PGPGIN] += val;
Index: mmotm-0727/include/linux/page_cgroup.h
===================================================================
--- mmotm-0727.orig/include/linux/page_cgroup.h
+++ mmotm-0727/include/linux/page_cgroup.h
@@ -3,6 +3,7 @@
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 #include <linux/bit_spinlock.h>
+#include <linux/memcontrol.h> /* for flags */
 /*
  * Page Cgroup can be considered as an extended mem_map.
  * A page_cgroup page is associated with every page descriptor. The
@@ -43,10 +44,21 @@ enum {
 	PCG_CACHE, /* charged as cache */
 	PCG_USED, /* this object is in use. */
 	PCG_ACCT_LRU, /* page has been accounted for */
-	PCG_FILE_MAPPED, /* page is accounted as "mapped" */
 	PCG_MIGRATION, /* under page migration */
+	PCG_FILE_FLAGS_MEMCG, /* see memcontrol.h */
+	PCG_FILE_FLAGS_MEMCG_END
+		= PCG_FILE_FLAGS_MEMCG + NR_FILE_FLAGS_MEMCG - 1,
 };
 
+/*
+ * file-stat flags are defined regarding to memcg's stat information.
+ * Here, just defines a macro for indexing
+ */
+static inline int fflag_idx (int idx) {
+	VM_BUG_ON((idx)>=NR_FILE_FLAGS_MEMCG);
+	return ((idx) + PCG_FILE_FLAGS_MEMCG);
+}
+
 #define TESTPCGFLAG(uname, lname)			\
 static inline int PageCgroup##uname(struct page_cgroup *pc)	\
 	{ return test_bit(PCG_##lname, &pc->flags); }
@@ -79,11 +91,6 @@ CLEARPCGFLAG(AcctLRU, ACCT_LRU)
 TESTPCGFLAG(AcctLRU, ACCT_LRU)
 TESTCLEARPCGFLAG(AcctLRU, ACCT_LRU)
 
-
-SETPCGFLAG(FileMapped, FILE_MAPPED)
-CLEARPCGFLAG(FileMapped, FILE_MAPPED)
-TESTPCGFLAG(FileMapped, FILE_MAPPED)
-
 SETPCGFLAG(Migration, MIGRATION)
 CLEARPCGFLAG(Migration, MIGRATION)
 TESTPCGFLAG(Migration, MIGRATION)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
