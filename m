Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 032326B005A
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 23:09:17 -0400 (EDT)
Date: Thu, 17 Sep 2009 11:24:42 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH 2/8] memcg: cleanup mem_cgroup_move_parent()
Message-Id: <20090917112442.b520a7a2.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
References: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

mem_cgroup_move_parent() calls try_charge first and cancel_charge on failure.
IMHO, charge/uncharge(especially charge) is high cost operation, so we should
avoid it as far as possible.

This patch tries to delay try_charge in mem_cgroup_move_parent() by re-ordering
checks it does.
And this patch changes the return value of mem_cgroup_move_account() from int
to void. Callers should confirm all of conditions needed to move account.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 include/linux/page_cgroup.h |    2 +
 mm/memcontrol.c             |   77 ++++++++++++++++--------------------------
 2 files changed, 31 insertions(+), 48 deletions(-)

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 7a3627e..321f037 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -57,6 +57,8 @@ static inline void ClearPageCgroup##uname(struct page_cgroup *pc)	\
 static inline int TestClearPageCgroup##uname(struct page_cgroup *pc)	\
 	{ return test_and_clear_bit(PCG_##lname, &pc->flags);  }
 
+TESTPCGFLAG(Locked, LOCK)
+
 /* Cache flag is set only once (at allocation) */
 TESTPCGFLAG(Cache, CACHE)
 CLEARPCGFLAG(Cache, CACHE)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 00f3f97..8b2bbbb 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1487,20 +1487,15 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
  *
  * The caller must confirm following.
  * - page is not on LRU (isolate_page() is useful.)
- *
- * returns 0 at success,
- * returns -EBUSY when lock is busy or "pc" is unstable.
+ * - the pc is locked, used, and ->mem_cgroup points to @from.
  *
  * This function does "uncharge" from old cgroup but doesn't do "charge" to
  * new cgroup. It should be done by a caller.
  */
 
-static int mem_cgroup_move_account(struct page_cgroup *pc,
+static void mem_cgroup_move_account(struct page_cgroup *pc,
 	struct mem_cgroup *from, struct mem_cgroup *to)
 {
-	struct mem_cgroup_per_zone *from_mz, *to_mz;
-	int nid, zid;
-	int ret = -EBUSY;
 	struct page *page;
 	int cpu;
 	struct mem_cgroup_stat *stat;
@@ -1508,20 +1503,9 @@ static int mem_cgroup_move_account(struct page_cgroup *pc,
 
 	VM_BUG_ON(from == to);
 	VM_BUG_ON(PageLRU(pc->page));
-
-	nid = page_cgroup_nid(pc);
-	zid = page_cgroup_zid(pc);
-	from_mz =  mem_cgroup_zoneinfo(from, nid, zid);
-	to_mz =  mem_cgroup_zoneinfo(to, nid, zid);
-
-	if (!trylock_page_cgroup(pc))
-		return ret;
-
-	if (!PageCgroupUsed(pc))
-		goto out;
-
-	if (pc->mem_cgroup != from)
-		goto out;
+	VM_BUG_ON(!PageCgroupLocked(pc));
+	VM_BUG_ON(!PageCgroupUsed(pc));
+	VM_BUG_ON(pc->mem_cgroup != from);
 
 	if (!mem_cgroup_is_root(from))
 		res_counter_uncharge(&from->res, PAGE_SIZE, NULL);
@@ -1550,16 +1534,12 @@ static int mem_cgroup_move_account(struct page_cgroup *pc,
 	css_get(&to->css);
 	pc->mem_cgroup = to;
 	mem_cgroup_charge_statistics(to, pc, true);
-	ret = 0;
-out:
-	unlock_page_cgroup(pc);
 	/*
 	 * We charges against "to" which may not have any tasks. Then, "to"
 	 * can be under rmdir(). But in current implementation, caller of
 	 * this function is just force_empty() and it's garanteed that
 	 * "to" is never removed. So, we don't check rmdir status here.
 	 */
-	return ret;
 }
 
 /*
@@ -1580,38 +1560,39 @@ static int mem_cgroup_move_parent(struct page_cgroup *pc,
 	if (!pcg)
 		return -EINVAL;
 
+	ret = -EBUSY;
+	if (!get_page_unless_zero(page))
+		goto out;
+	if (isolate_lru_page(page))
+		goto put;
 
-	parent = mem_cgroup_from_cont(pcg);
-
+	ret = -EINVAL;
+	lock_page_cgroup(pc);
+	if (!PageCgroupUsed(pc) || pc->mem_cgroup != child) /* early check */
+		goto unlock;
+	unlock_page_cgroup(pc);
 
+	parent = mem_cgroup_from_cont(pcg);
 	ret = __mem_cgroup_try_charge(NULL, gfp_mask, &parent, false, page);
 	if (ret || !parent)
-		return ret;
-
-	if (!get_page_unless_zero(page)) {
-		ret = -EBUSY;
-		goto uncharge;
-	}
-
-	ret = isolate_lru_page(page);
-
-	if (ret)
-		goto cancel;
+		goto put_back;
 
-	ret = mem_cgroup_move_account(pc, child, parent);
-
-	putback_lru_page(page);
-	if (!ret) {
-		put_page(page);
+	lock_page_cgroup(pc);
+	if (likely(PageCgroupUsed(pc) && pc->mem_cgroup == child)) {
+		mem_cgroup_move_account(pc, child, parent);
 		/* drop extra refcnt by try_charge() */
 		css_put(&parent->css);
-		return 0;
+	} else {
+		ret = -EINVAL;
+		mem_cgroup_cancel_charge(parent);	/* does css_put */
 	}
-
-cancel:
+unlock:
+	unlock_page_cgroup(pc);
+put_back:
+	putback_lru_page(page);
+put:
 	put_page(page);
-uncharge:
-	mem_cgroup_cancel_charge(parent);
+out:
 	return ret;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
