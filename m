Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 80F656B0047
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 03:25:12 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o238P6K4026606
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 3 Mar 2010 17:25:07 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AF57845DE5D
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 17:25:06 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B1F845DE4E
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 17:25:06 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 378861DB803C
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 17:25:06 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B21FE3800A
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 17:25:05 +0900 (JST)
Date: Wed, 3 Mar 2010 17:21:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 3/3] memcg: dirty pages instrumentation
Message-Id: <20100303172132.fc6d9387.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100303151549.5d3d686a.kamezawa.hiroyu@jp.fujitsu.com>
References: <1267478620-5276-1-git-send-email-arighi@develer.com>
	<1267478620-5276-4-git-send-email-arighi@develer.com>
	<20100303111238.7133f8af.nishimura@mxp.nes.nec.co.jp>
	<20100303122906.9c613ab2.kamezawa.hiroyu@jp.fujitsu.com>
	<20100303150137.f56d7084.nishimura@mxp.nes.nec.co.jp>
	<20100303151549.5d3d686a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrea Righi <arighi@develer.com>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Greg@smtp1.linux-foundation.org, Suleiman Souhlal <suleiman@google.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 3 Mar 2010 15:15:49 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Agreed.
> Let's try how we can write a code in clean way. (we have time ;)
> For now, to me, IRQ disabling while lock_page_cgroup() seems to be a little
> over killing. What I really want is lockless code...but it seems impossible
> under current implementation.
> 
> I wonder the fact "the page is never unchareged under us" can give us some chances
> ...Hmm.
> 

How about this ? Basically, I don't like duplicating information...so,
# of new pcg_flags may be able to be reduced.

I'm glad this can be a hint for Andrea-san.

==
---
 include/linux/page_cgroup.h |   44 ++++++++++++++++++++-
 mm/memcontrol.c             |   91 +++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 132 insertions(+), 3 deletions(-)

Index: mmotm-2.6.33-Mar2/include/linux/page_cgroup.h
===================================================================
--- mmotm-2.6.33-Mar2.orig/include/linux/page_cgroup.h
+++ mmotm-2.6.33-Mar2/include/linux/page_cgroup.h
@@ -39,6 +39,11 @@ enum {
 	PCG_CACHE, /* charged as cache */
 	PCG_USED, /* this object is in use. */
 	PCG_ACCT_LRU, /* page has been accounted for */
+	PCG_MIGRATE_LOCK, /* used for mutual execution of account migration */
+	PCG_ACCT_DIRTY,
+	PCG_ACCT_WB,
+	PCG_ACCT_WB_TEMP,
+	PCG_ACCT_UNSTABLE,
 };
 
 #define TESTPCGFLAG(uname, lname)			\
@@ -73,6 +78,23 @@ CLEARPCGFLAG(AcctLRU, ACCT_LRU)
 TESTPCGFLAG(AcctLRU, ACCT_LRU)
 TESTCLEARPCGFLAG(AcctLRU, ACCT_LRU)
 
+SETPCGFLAG(AcctDirty, ACCT_DIRTY);
+CLEARPCGFLAG(AcctDirty, ACCT_DIRTY);
+TESTPCGFLAG(AcctDirty, ACCT_DIRTY);
+
+SETPCGFLAG(AcctWB, ACCT_WB);
+CLEARPCGFLAG(AcctWB, ACCT_WB);
+TESTPCGFLAG(AcctWB, ACCT_WB);
+
+SETPCGFLAG(AcctWBTemp, ACCT_WB_TEMP);
+CLEARPCGFLAG(AcctWBTemp, ACCT_WB_TEMP);
+TESTPCGFLAG(AcctWBTemp, ACCT_WB_TEMP);
+
+SETPCGFLAG(AcctUnstableNFS, ACCT_UNSTABLE);
+CLEARPCGFLAG(AcctUnstableNFS, ACCT_UNSTABLE);
+TESTPCGFLAG(AcctUnstableNFS, ACCT_UNSTABLE);
+
+
 static inline int page_cgroup_nid(struct page_cgroup *pc)
 {
 	return page_to_nid(pc->page);
@@ -82,7 +104,9 @@ static inline enum zone_type page_cgroup
 {
 	return page_zonenum(pc->page);
 }
-
+/*
+ * lock_page_cgroup() should not be held under mapping->tree_lock
+ */
 static inline void lock_page_cgroup(struct page_cgroup *pc)
 {
 	bit_spin_lock(PCG_LOCK, &pc->flags);
@@ -93,6 +117,24 @@ static inline void unlock_page_cgroup(st
 	bit_spin_unlock(PCG_LOCK, &pc->flags);
 }
 
+/*
+ * Lock order is
+ * 	lock_page_cgroup()
+ * 		lock_page_cgroup_migrate()
+ * This lock is not be lock for charge/uncharge but for account moving.
+ * i.e. overwrite pc->mem_cgroup. The lock owner should guarantee by itself
+ * the page is uncharged while we hold this.
+ */
+static inline void lock_page_cgroup_migrate(struct page_cgroup *pc)
+{
+	bit_spin_lock(PCG_MIGRATE_LOCK, &pc->flags);
+}
+
+static inline void unlock_page_cgroup_migrate(struct page_cgroup *pc)
+{
+	bit_spin_unlock(PCG_MIGRATE_LOCK, &pc->flags);
+}
+
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct page_cgroup;
 
Index: mmotm-2.6.33-Mar2/mm/memcontrol.c
===================================================================
--- mmotm-2.6.33-Mar2.orig/mm/memcontrol.c
+++ mmotm-2.6.33-Mar2/mm/memcontrol.c
@@ -87,6 +87,10 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
 	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
 	MEM_CGROUP_EVENTS,	/* incremented at every  pagein/pageout */
+	MEM_CGROUP_STAT_DIRTY,
+	MEM_CGROUP_STAT_WBACK,
+	MEM_CGROUP_STAT_WBACK_TEMP,
+	MEM_CGROUP_STAT_UNSTABLE_NFS,
 
 	MEM_CGROUP_STAT_NSTATS,
 };
@@ -1360,6 +1364,86 @@ done:
 }
 
 /*
+ * Update file cache's status for memcg. Before calling this,
+ * mapping->tree_lock should be held and preemption is disabled.
+ * Then, it's guarnteed that the page is not uncharged while we
+ * access page_cgroup. We can make use of that.
+ */
+void mem_cgroup_update_stat_locked(struct page *page, int idx, bool set)
+{
+	struct page_cgroup *pc;
+	struct mem_cgroup *mem;
+
+	pc = lookup_page_cgroup(page);
+	/* Not accounted ? */
+	if (!PageCgroupUsed(pc))
+		return;
+	lock_page_cgroup_migrate(pc);
+	/*
+	 * It's guarnteed that this page is never uncharged.
+	 * The only racy problem is moving account among memcgs.
+	 */
+	switch (idx) {
+	case MEM_CGROUP_STAT_DIRTY:
+		if (set)
+			SetPageCgroupAcctDirty(pc);
+		else
+			ClearPageCgroupAcctDirty(pc);
+		break;
+	case MEM_CGROUP_STAT_WBACK:
+		if (set)
+			SetPageCgroupAcctWB(pc);
+		else
+			ClearPageCgroupAcctWB(pc);
+		break;
+	case MEM_CGROUP_STAT_WBACK_TEMP:
+		if (set)
+			SetPageCgroupAcctWBTemp(pc);
+		else
+			ClearPageCgroupAcctWBTemp(pc);
+		break;
+	case MEM_CGROUP_STAT_UNSTABLE_NFS:
+		if (set)
+			SetPageCgroupAcctUnstableNFS(pc);
+		else
+			ClearPageCgroupAcctUnstableNFS(pc);
+		break;
+	default:
+		BUG();
+		break;
+	}
+	mem = pc->mem_cgroup;
+	if (set)
+		__this_cpu_inc(mem->stat->count[idx]);
+	else
+		__this_cpu_dec(mem->stat->count[idx]);
+	unlock_page_cgroup_migrate(pc);
+}
+
+static void move_acct_information(struct mem_cgroup *from,
+				struct mem_cgroup *to,
+				struct page_cgroup *pc)
+{
+	/* preemption is disabled, migration_lock is held. */
+	if (PageCgroupAcctDirty(pc)) {
+		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_DIRTY]);
+		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_DIRTY]);
+	}
+	if (PageCgroupAcctWB(pc)) {
+		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_WBACK]);
+		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_WBACK]);
+	}
+	if (PageCgroupAcctWBTemp(pc)) {
+		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_WBACK_TEMP]);
+		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_WBACK_TEMP]);
+	}
+	if (PageCgroupAcctUnstableNFS(pc)) {
+		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_UNSTABLE_NFS]);
+		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_UNSTABLE_NFS]);
+	}
+}
+
+/*
  * size of first charge trial. "32" comes from vmscan.c's magic value.
  * TODO: maybe necessary to use big numbers in big irons.
  */
@@ -1794,15 +1878,16 @@ static void __mem_cgroup_move_account(st
 	VM_BUG_ON(!PageCgroupUsed(pc));
 	VM_BUG_ON(pc->mem_cgroup != from);
 
+	preempt_disable();
+	lock_page_cgroup_migrate(pc);
 	page = pc->page;
 	if (page_mapped(page) && !PageAnon(page)) {
 		/* Update mapped_file data for mem_cgroup */
-		preempt_disable();
 		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
 		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
-		preempt_enable();
 	}
 	mem_cgroup_charge_statistics(from, pc, false);
+	move_acct_information(from, to, pc);
 	if (uncharge)
 		/* This is not "cancel", but cancel_charge does all we need. */
 		mem_cgroup_cancel_charge(from);
@@ -1810,6 +1895,8 @@ static void __mem_cgroup_move_account(st
 	/* caller should have done css_get */
 	pc->mem_cgroup = to;
 	mem_cgroup_charge_statistics(to, pc, true);
+	unlock_page_cgroup_migrate(pc);
+	preempt_enable();
 	/*
 	 * We charges against "to" which may not have any tasks. Then, "to"
 	 * can be under rmdir(). But in current implementation, caller of

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
