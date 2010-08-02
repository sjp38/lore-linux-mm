Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 565A2600429
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 06:22:11 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o72AM83O006002
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 2 Aug 2010 19:22:08 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C9AE45DE52
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 19:22:08 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7AF2F45DE51
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 19:22:08 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 63E7C1DB803C
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 19:22:08 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1095B1DB8043
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 19:22:05 +0900 (JST)
Date: Mon, 2 Aug 2010 19:17:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH -mm 4/5] memcg generic file stat accounting interface.
Message-Id: <20100802191715.63ce81ed.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100802191113.05c982e4.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100802191113.05c982e4.kamezawa.hiroyu@jp.fujitsu.com>
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
 - clean up and moved mem_cgroup_stat_index to header file.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h  |   23 ++++++++++++++++++++++
 include/linux/page_cgroup.h |   12 +++++------
 mm/memcontrol.c             |   46 ++++++++++++++++++--------------------------
 3 files changed, 48 insertions(+), 33 deletions(-)

Index: mmotm-0727/include/linux/memcontrol.h
===================================================================
--- mmotm-0727.orig/include/linux/memcontrol.h
+++ mmotm-0727/include/linux/memcontrol.h
@@ -25,6 +25,29 @@ struct page_cgroup;
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
+	/* About file-stat please see memcontrol.h */
+	MEM_CGROUP_FSTAT_BASE,
+	MEM_CGROUP_FSTAT_FILE_MAPPED = MEM_CGROUP_FSTAT_BASE,
+	MEM_CGROUP_FSTAT_END,
+	MEM_CGROUP_STAT_NSTATS = MEM_CGROUP_FSTAT_END,
+};
+
+#define MEMCG_FSTAT_IDX(idx)	((idx) - MEM_CGROUP_FSTAT_BASE)
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
@@ -1512,7 +1494,8 @@ bool mem_cgroup_handle_oom(struct mem_cg
  * Currently used to update mapped file statistics, but the routine can be
  * generalized to update other statistics as well.
  */
-void mem_cgroup_update_file_mapped(struct page *page, int val)
+static void
+mem_cgroup_update_file_stat(struct page *page, unsigned int idx, int val)
 {
 	struct mem_cgroup *mem;
 	struct page_cgroup *pc;
@@ -1536,11 +1519,11 @@ void mem_cgroup_update_file_mapped(struc
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
@@ -1548,6 +1531,12 @@ done:
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
@@ -2007,17 +1996,20 @@ static void __mem_cgroup_commit_charge(s
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
@@ -3447,7 +3439,7 @@ static int mem_cgroup_get_local_stat(str
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
@@ -40,9 +40,14 @@ enum {
 	PCG_CACHE, /* charged as cache */
 	PCG_USED, /* this object is in use. */
 	PCG_ACCT_LRU, /* page has been accounted for */
-	PCG_FILE_MAPPED, /* page is accounted as "mapped" */
 	PCG_MIGRATION, /* under page migration */
+	PCG_FILE_FLAGS, /* see memcontrol.h */
 };
+/*
+ * file-stat flags are defined regarding to memcg's stat information.
+ * Here, just defines a macro for indexing
+ */
+#define fflag_idx(idx)	((idx) + PCG_FILE_FLAGS)
 
 #define TESTPCGFLAG(uname, lname)			\
 static inline int PageCgroup##uname(struct page_cgroup *pc)	\
@@ -76,11 +81,6 @@ CLEARPCGFLAG(AcctLRU, ACCT_LRU)
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
