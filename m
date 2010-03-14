Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 39C576B0182
	for <linux-mm@kvack.org>; Sun, 14 Mar 2010 19:26:52 -0400 (EDT)
From: Andrea Righi <arighi@develer.com>
Subject: [PATCH -mmotm 1/5] memcg: disable irq at page cgroup lock
Date: Mon, 15 Mar 2010 00:26:38 +0100
Message-Id: <1268609202-15581-2-git-send-email-arighi@develer.com>
In-Reply-To: <1268609202-15581-1-git-send-email-arighi@develer.com>
References: <1268609202-15581-1-git-send-email-arighi@develer.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, file-mapped is maintaiend. But more generic update function
will be needed for dirty page accounting.

For accountig page status, we have to guarantee lock_page_cgroup()
will be never called under tree_lock held.
To guarantee that, we use trylock at updating status.
By this, we do fuzzy accounting, but in almost all case, it's correct.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h  |    7 +++-
 include/linux/page_cgroup.h |   15 +++++++
 mm/memcontrol.c             |   94 +++++++++++++++++++++++++++++++++----------
 mm/rmap.c                   |    4 +-
 4 files changed, 95 insertions(+), 25 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 44301c6..88d3f9e 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -124,7 +124,12 @@ static inline bool mem_cgroup_disabled(void)
 	return false;
 }
 
-void mem_cgroup_update_file_mapped(struct page *page, int val);
+enum mem_cgroup_page_stat_item {
+	MEMCG_NR_FILE_MAPPED,
+	MEMCG_NR_FILE_NSTAT,
+};
+
+void mem_cgroup_update_stat(struct page *page, int idx, bool charge);
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						gfp_t gfp_mask, int nid,
 						int zid);
diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 30b0813..bf9a913 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -39,6 +39,8 @@ enum {
 	PCG_CACHE, /* charged as cache */
 	PCG_USED, /* this object is in use. */
 	PCG_ACCT_LRU, /* page has been accounted for */
+	/* for cache-status accounting */
+	PCG_FILE_MAPPED,
 };
 
 #define TESTPCGFLAG(uname, lname)			\
@@ -57,6 +59,10 @@ static inline void ClearPageCgroup##uname(struct page_cgroup *pc)	\
 static inline int TestClearPageCgroup##uname(struct page_cgroup *pc)	\
 	{ return test_and_clear_bit(PCG_##lname, &pc->flags);  }
 
+/* Page/File stat flag mask */
+#define PCG_PageStatMask	((1 << PCG_FILE_MAPPED))
+
+
 TESTPCGFLAG(Locked, LOCK)
 
 /* Cache flag is set only once (at allocation) */
@@ -73,6 +79,10 @@ CLEARPCGFLAG(AcctLRU, ACCT_LRU)
 TESTPCGFLAG(AcctLRU, ACCT_LRU)
 TESTCLEARPCGFLAG(AcctLRU, ACCT_LRU)
 
+TESTPCGFLAG(FileMapped, FILE_MAPPED)
+SETPCGFLAG(FileMapped, FILE_MAPPED)
+CLEARPCGFLAG(FileMapped, FILE_MAPPED)
+
 static inline int page_cgroup_nid(struct page_cgroup *pc)
 {
 	return page_to_nid(pc->page);
@@ -93,6 +103,11 @@ static inline void unlock_page_cgroup(struct page_cgroup *pc)
 	bit_spin_unlock(PCG_LOCK, &pc->flags);
 }
 
+static inline int trylock_page_cgroup(struct page_cgroup *pc)
+{
+	return bit_spin_trylock(PCG_LOCK, &pc->flags);
+}
+
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct page_cgroup;
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7fab84e..b7c23ea 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1348,30 +1348,83 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
  * Currently used to update mapped file statistics, but the routine can be
  * generalized to update other statistics as well.
  */
-void mem_cgroup_update_file_mapped(struct page *page, int val)
+void __mem_cgroup_update_stat(struct page_cgroup *pc, int idx, bool charge)
 {
 	struct mem_cgroup *mem;
-	struct page_cgroup *pc;
+	int val;
 
-	pc = lookup_page_cgroup(page);
-	if (unlikely(!pc))
-		return;
-
-	lock_page_cgroup(pc);
 	mem = pc->mem_cgroup;
-	if (!mem)
-		goto done;
+	if (!mem || !PageCgroupUsed(pc))
+		return;
 
-	if (!PageCgroupUsed(pc))
-		goto done;
+	if (charge)
+		val = 1;
+	else
+		val = -1;
 
+	switch (idx) {
+	case MEMCG_NR_FILE_MAPPED:
+		if (charge) {
+			if (!PageCgroupFileMapped(pc))
+				SetPageCgroupFileMapped(pc);
+			else
+				val = 0;
+		} else {
+			if (PageCgroupFileMapped(pc))
+				ClearPageCgroupFileMapped(pc);
+			else
+				val = 0;
+		}
+		idx = MEM_CGROUP_STAT_FILE_MAPPED;
+		break;
+	default:
+		BUG();
+		break;
+	}
 	/*
 	 * Preemption is already disabled. We can use __this_cpu_xxx
 	 */
-	__this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED], val);
+	__this_cpu_add(mem->stat->count[idx], val);
+}
 
-done:
-	unlock_page_cgroup(pc);
+void mem_cgroup_update_stat(struct page *page, int idx, bool charge)
+{
+	struct page_cgroup *pc;
+
+	pc = lookup_page_cgroup(page);
+	if (!pc || mem_cgroup_is_root(pc->mem_cgroup))
+		return;
+
+	if (trylock_page_cgroup(pc)) {
+		__mem_cgroup_update_stat(pc, idx, charge);
+		unlock_page_cgroup(pc);
+	}
+	return;
+}
+
+static void mem_cgroup_migrate_stat(struct page_cgroup *pc,
+	struct mem_cgroup *from, struct mem_cgroup *to)
+{
+	if (PageCgroupFileMapped(pc)) {
+		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
+		if (!mem_cgroup_is_root(to)) {
+			__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
+		} else {
+			ClearPageCgroupFileMapped(pc);
+		}
+	}
+}
+
+static void
+__mem_cgroup_stat_fixup(struct page_cgroup *pc, struct mem_cgroup *mem)
+{
+	if (mem_cgroup_is_root(mem))
+		return;
+	/* We'are in uncharge() and lock_page_cgroup */
+	if (PageCgroupFileMapped(pc)) {
+		__this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
+		ClearPageCgroupFileMapped(pc);
+	}
 }
 
 /*
@@ -1810,13 +1863,7 @@ static void __mem_cgroup_move_account(struct page_cgroup *pc,
 	VM_BUG_ON(pc->mem_cgroup != from);
 
 	page = pc->page;
-	if (page_mapped(page) && !PageAnon(page)) {
-		/* Update mapped_file data for mem_cgroup */
-		preempt_disable();
-		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
-		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
-		preempt_enable();
-	}
+	mem_cgroup_migrate_stat(pc, from, to);
 	mem_cgroup_charge_statistics(from, pc, false);
 	if (uncharge)
 		/* This is not "cancel", but cancel_charge does all we need. */
@@ -2208,6 +2255,9 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 		__do_uncharge(mem, ctype);
 	if (ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
 		mem_cgroup_swap_statistics(mem, true);
+	if (unlikely(PCG_PageStatMask & pc->flags))
+		__mem_cgroup_stat_fixup(pc, mem);
+
 	mem_cgroup_charge_statistics(mem, pc, false);
 
 	ClearPageCgroupUsed(pc);
diff --git a/mm/rmap.c b/mm/rmap.c
index fcd593c..b5b2daf 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -829,7 +829,7 @@ void page_add_file_rmap(struct page *page)
 {
 	if (atomic_inc_and_test(&page->_mapcount)) {
 		__inc_zone_page_state(page, NR_FILE_MAPPED);
-		mem_cgroup_update_file_mapped(page, 1);
+		mem_cgroup_update_stat(page, MEMCG_NR_FILE_MAPPED, true);
 	}
 }
 
@@ -861,7 +861,7 @@ void page_remove_rmap(struct page *page)
 		__dec_zone_page_state(page, NR_ANON_PAGES);
 	} else {
 		__dec_zone_page_state(page, NR_FILE_MAPPED);
-		mem_cgroup_update_file_mapped(page, -1);
+		mem_cgroup_update_stat(page, MEMCG_NR_FILE_MAPPED, false);
 	}
 	/*
 	 * It would be tidy to reset the PageAnon mapping here,
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
