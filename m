Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id DFE3E6B02A7
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 05:53:37 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6T9rY9Q023339
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 29 Jul 2010 18:53:35 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D984B45DE6E
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 18:53:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A11DA45DE58
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 18:53:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 11A35E18002
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 18:53:27 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 271FF1DB804A
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 18:53:24 +0900 (JST)
Date: Thu, 29 Jul 2010 18:48:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 4/5] memcg : generic file stat accounting
Message-Id: <20100729184831.05bac45b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100729184250.acdff587.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100729184250.acdff587.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, vgoyal@redhat.com, m-ikeda@ds.jp.nec.com, gthelen@google.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Preparing for adding new status arounf file caches.(dirty, writeback,etc..)
Using a unified macro and more generic names.
All counters will have the same rule for updating.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h  |    4 ++++
 include/linux/page_cgroup.h |   21 +++++++++++++++------
 mm/memcontrol.c             |   35 +++++++++++++++++++++++------------
 3 files changed, 42 insertions(+), 18 deletions(-)

Index: mmotm-0727/include/linux/memcontrol.h
===================================================================
--- mmotm-0727.orig/include/linux/memcontrol.h
+++ mmotm-0727/include/linux/memcontrol.h
@@ -121,6 +121,10 @@ static inline bool mem_cgroup_disabled(v
 	return false;
 }
 
+enum {
+	__MEMCG_FILE_MAPPED,
+	NR_MEMCG_FILE_STAT
+};
 void mem_cgroup_update_file_mapped(struct page *page, int val);
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						gfp_t gfp_mask, int nid,
Index: mmotm-0727/mm/memcontrol.c
===================================================================
--- mmotm-0727.orig/mm/memcontrol.c
+++ mmotm-0727/mm/memcontrol.c
@@ -83,16 +83,20 @@ enum mem_cgroup_stat_index {
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
@@ -334,7 +338,6 @@ enum charge_type {
 /* only for here (for easy reading.) */
 #define PCGF_CACHE	(1UL << PCG_CACHE)
 #define PCGF_USED	(1UL << PCG_USED)
-#define PCGF_LOCK	(1UL << PCG_LOCK)
 /* Not used, but added here for completeness */
 #define PCGF_ACCT	(1UL << PCG_ACCT)
 
@@ -1513,7 +1516,7 @@ bool mem_cgroup_handle_oom(struct mem_cg
  * Currently used to update mapped file statistics, but the routine can be
  * generalized to update other statistics as well.
  */
-void mem_cgroup_update_file_mapped(struct page *page, int val)
+static void mem_cgroup_update_file_stat(struct page *page, int idx, int val)
 {
 	struct mem_cgroup *mem;
 	struct page_cgroup *pc;
@@ -1536,11 +1539,11 @@ void mem_cgroup_update_file_mapped(struc
 		goto done;
 
 	if (val > 0) {
-		this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
-		SetPageCgroupFileMapped(pc);
+		this_cpu_inc(mem->stat->count[MEM_CGROUP_FSTAT_BASE + idx]);
+		SetPCGFileFlag(pc, idx);
 	} else {
-		this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
-		ClearPageCgroupFileMapped(pc);
+		this_cpu_dec(mem->stat->count[MEM_CGROUP_FSTAT_BASE + idx]);
+		ClearPCGFileFlag(pc, idx);
 	}
 
 done:
@@ -1549,6 +1552,11 @@ done:
 	rcu_read_unlock();
 }
 
+void mem_cgroup_update_file_mapped(struct page *page, int val)
+{
+	return mem_cgroup_update_file_stat(page, __MEMCG_FILE_MAPPED, val);
+}
+
 /*
  * size of first charge trial. "32" comes from vmscan.c's magic value.
  * TODO: maybe necessary to use big numbers in big irons.
@@ -2008,17 +2016,20 @@ static void __mem_cgroup_commit_charge(s
 static void __mem_cgroup_move_account(struct page_cgroup *pc,
 	struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge)
 {
+	int i;
 	VM_BUG_ON(from == to);
 	VM_BUG_ON(PageLRU(pc->page));
-	VM_BUG_ON(!PageCgroupLocked(pc));
+	VM_BUG_ON(!page_cgroup_locked(pc));
 	VM_BUG_ON(!PageCgroupUsed(pc));
 	VM_BUG_ON(id_to_memcg(pc->mem_cgroup) != from);
 
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
Index: mmotm-0727/include/linux/page_cgroup.h
===================================================================
--- mmotm-0727.orig/include/linux/page_cgroup.h
+++ mmotm-0727/include/linux/page_cgroup.h
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
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
