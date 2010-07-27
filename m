Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id DF263600365
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 04:05:33 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6R85j5e029512
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 27 Jul 2010 17:05:46 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D08B45DE6D
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 17:05:45 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5CF5545DE55
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 17:05:45 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 118651DB8040
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 17:05:45 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F6C61DB803F
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 17:05:44 +0900 (JST)
Date: Tue, 27 Jul 2010 17:00:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 6/7][memcg] generic file status update
Message-Id: <20100727170059.ca06af88.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This patch itself is not important. I just feel we need this kind of
clean up in future.

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Preparing for adding new status arounf file caches.(dirty, writeback,etc..)
Using a unified macro and more generic names.
All counters will have the same rule for updating.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h  |   10 +++++++---
 include/linux/page_cgroup.h |   21 +++++++++++++++------
 mm/memcontrol.c             |   27 +++++++++++++++++----------
 mm/rmap.c                   |    4 ++--
 4 files changed, 41 insertions(+), 21 deletions(-)

Index: mmotm-0719/include/linux/memcontrol.h
===================================================================
--- mmotm-0719.orig/include/linux/memcontrol.h
+++ mmotm-0719/include/linux/memcontrol.h
@@ -121,7 +121,11 @@ static inline bool mem_cgroup_disabled(v
 	return false;
 }
 
-void mem_cgroup_update_file_mapped(struct page *page, int val);
+enum {
+	__MEMCG_FILE_MAPPED,
+	NR_MEMCG_FILE_STAT
+};
+void mem_cgroup_update_file_stat(struct page *page, int stat, int val);
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						gfp_t gfp_mask, int nid,
 						int zid);
@@ -292,8 +296,8 @@ mem_cgroup_print_oom_info(struct mem_cgr
 {
 }
 
-static inline void mem_cgroup_update_file_mapped(struct page *page,
-							int val)
+static inline void
+mem_cgroup_update_file_stat(struct page *page, int stat, int val);
 {
 }
 
Index: mmotm-0719/mm/memcontrol.c
===================================================================
--- mmotm-0719.orig/mm/memcontrol.c
+++ mmotm-0719/mm/memcontrol.c
@@ -84,16 +84,20 @@ enum mem_cgroup_stat_index {
 	 */
 	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
 	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
-	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
 	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
 	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
 	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
 	MEM_CGROUP_EVENTS,	/* incremented at every  pagein/pageout */
 	MEM_CGROUP_ON_MOVE,   /* A check for locking move account/status */
-
+	MEM_CGROUP_FSTAT_BASE,
+	MEM_CGROUP_FSTAT_END
+		= MEM_CGROUP_FSTAT_BASE + NR_MEMCG_FILE_STAT,
 	MEM_CGROUP_STAT_NSTATS,
 };
 
+#define MEM_CGROUP_STAT_FILE_MAPPED\
+	(MEM_CGROUP_FSTAT_BASE + __MEMCG_FILE_MAPPED)
+
 struct mem_cgroup_stat_cpu {
 	s64 count[MEM_CGROUP_STAT_NSTATS];
 };
@@ -1508,7 +1512,7 @@ bool mem_cgroup_handle_oom(struct mem_cg
  * Currently used to update mapped file statistics, but the routine can be
  * generalized to update other statistics as well.
  */
-void mem_cgroup_update_file_mapped(struct page *page, int val)
+void mem_cgroup_update_file_stat(struct page *page, int idx, int val)
 {
 	struct mem_cgroup *mem;
 	struct page_cgroup *pc;
@@ -1534,11 +1538,11 @@ void mem_cgroup_update_file_mapped(struc
 	 * Preemption is already disabled. We can use __this_cpu_xxx
 	 */
 	if (val > 0) {
-		__this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
-		SetPageCgroupFileMapped(pc);
+		__this_cpu_inc(mem->stat->count[MEM_CGROUP_FSTAT_BASE + idx]);
+		SetPCGFileFlag(pc, idx);
 	} else {
-		__this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
-		ClearPageCgroupFileMapped(pc);
+		__this_cpu_dec(mem->stat->count[MEM_CGROUP_FSTAT_BASE + idx]);
+		ClearPCGFileFlag(pc, idx);
 	}
 
 done:
@@ -1999,17 +2003,20 @@ static void __mem_cgroup_commit_charge(s
 static void __mem_cgroup_move_account(struct page_cgroup *pc,
 	struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge)
 {
+	int i;
 	VM_BUG_ON(from == to);
 	VM_BUG_ON(PageLRU(pc->page));
 	VM_BUG_ON(!PageCgroupLocked(pc));
 	VM_BUG_ON(!PageCgroupUsed(pc));
 	VM_BUG_ON(id_to_mem(pc->mem_cgroup) != from);
 
-	if (PageCgroupFileMapped(pc)) {
+	for (i = 0; i < NR_MEMCG_FILE_STAT; ++i) {
+		if (!TestPCGFileFlag(pc, i))
+			continue;
 		/* Update mapped_file data for mem_cgroup */
 		preempt_disable();
-		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
-		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
+		__this_cpu_dec(from->stat->count[MEM_CGROUP_FSTAT_BASE + i]);
+		__this_cpu_inc(to->stat->count[MEM_CGROUP_FSTAT_BASE + i]);
 		preempt_enable();
 	}
 	mem_cgroup_charge_statistics(from, pc, false);
Index: mmotm-0719/include/linux/page_cgroup.h
===================================================================
--- mmotm-0719.orig/include/linux/page_cgroup.h
+++ mmotm-0719/include/linux/page_cgroup.h
@@ -40,8 +40,8 @@ enum {
 	PCG_CACHE, /* charged as cache */
 	PCG_USED, /* this object is in use. */
 	PCG_ACCT_LRU, /* page has been accounted for */
-	PCG_FILE_MAPPED, /* page is accounted as "mapped" */
 	PCG_MIGRATION, /* under page migration */
+	PCG_FILE_FLAGS, /* see memcontrol.h */
 };
 
 #define TESTPCGFLAG(uname, lname)			\
@@ -76,11 +76,6 @@ CLEARPCGFLAG(AcctLRU, ACCT_LRU)
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
@@ -105,6 +100,20 @@ static inline void unlock_page_cgroup(st
 	bit_spin_unlock(PCG_LOCK, &pc->flags);
 }
 
+static inline void SetPCGFileFlag(struct page_cgroup *pc, int idx)
+{
+	set_bit(PCG_FILE_FLAGS + idx, &pc->flags);
+}
+
+static inline void ClearPCGFileFlag(struct page_cgroup *pc, int idx)
+{
+	clear_bit(PCG_FILE_FLAGS + idx, &pc->flags);
+}
+static inline bool TestPCGFileFlag(struct page_cgroup *pc, int idx)
+{
+	return test_bit(PCG_FILE_FLAGS + idx, &pc->flags);
+}
+
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct page_cgroup;
 
Index: mmotm-0719/mm/rmap.c
===================================================================
--- mmotm-0719.orig/mm/rmap.c
+++ mmotm-0719/mm/rmap.c
@@ -891,7 +891,7 @@ void page_add_file_rmap(struct page *pag
 {
 	if (atomic_inc_and_test(&page->_mapcount)) {
 		__inc_zone_page_state(page, NR_FILE_MAPPED);
-		mem_cgroup_update_file_mapped(page, 1);
+		mem_cgroup_update_file_stat(page, __MEMCG_FILE_MAPPED, 1);
 	}
 }
 
@@ -929,7 +929,7 @@ void page_remove_rmap(struct page *page)
 		__dec_zone_page_state(page, NR_ANON_PAGES);
 	} else {
 		__dec_zone_page_state(page, NR_FILE_MAPPED);
-		mem_cgroup_update_file_mapped(page, -1);
+		mem_cgroup_update_file_stat(page, __MEMCG_FILE_MAPPED, -1);
 	}
 	/*
 	 * It would be tidy to reset the PageAnon mapping here,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
