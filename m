Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1E5AF6B0044
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 00:31:51 -0500 (EST)
Date: Fri, 6 Nov 2009 14:13:01 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH -mmotm 4/8] memcg: cleanup mem_cgroup_move_parent()
Message-Id: <20091106141301.497f2cef.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
References: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

mem_cgroup_move_parent() calls try_charge first and cancel_charge on failure.
IMHO, charge/uncharge(especially charge) is high cost operation, so we should
avoid it as far as possible.

This patch tries to delay try_charge in mem_cgroup_move_parent() by re-ordering
checks it does.

And this patch renames mem_cgroup_move_account() to __mem_cgroup_move_account(),
changes the return value of __mem_cgroup_move_account() from int to void,
and adds a new wrapper(mem_cgroup_move_account()), which checks whether a @pc
is valid for moving account and calls __mem_cgroup_move_account().

This patch removes the last caller of trylock_page_cgroup(), so removes its
definition too.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 include/linux/page_cgroup.h |    7 +---
 mm/memcontrol.c             |   84 ++++++++++++++++++-------------------------
 2 files changed, 37 insertions(+), 54 deletions(-)

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 4b938d4..b0e4eb1 100644
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
@@ -86,11 +88,6 @@ static inline void lock_page_cgroup(struct page_cgroup *pc)
 	bit_spin_lock(PCG_LOCK, &pc->flags);
 }
 
-static inline int trylock_page_cgroup(struct page_cgroup *pc)
-{
-	return bit_spin_trylock(PCG_LOCK, &pc->flags);
-}
-
 static inline void unlock_page_cgroup(struct page_cgroup *pc)
 {
 	bit_spin_unlock(PCG_LOCK, &pc->flags);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 05e837c..1ad3248 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1613,27 +1613,22 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
 }
 
 /**
- * mem_cgroup_move_account - move account of the page
+ * __mem_cgroup_move_account - move account of the page
  * @pc:	page_cgroup of the page.
  * @from: mem_cgroup which the page is moved from.
  * @to:	mem_cgroup which the page is moved to. @from != @to.
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
+static void __mem_cgroup_move_account(struct page_cgroup *pc,
 	struct mem_cgroup *from, struct mem_cgroup *to)
 {
-	struct mem_cgroup_per_zone *from_mz, *to_mz;
-	int nid, zid;
-	int ret = -EBUSY;
 	struct page *page;
 	int cpu;
 	struct mem_cgroup_stat *stat;
@@ -1641,20 +1636,9 @@ static int mem_cgroup_move_account(struct page_cgroup *pc,
 
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
 		res_counter_uncharge(&from->res, PAGE_SIZE);
@@ -1683,15 +1667,28 @@ static int mem_cgroup_move_account(struct page_cgroup *pc,
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
+}
+
+/*
+ * check whether the @pc is valid for moving account and call
+ * __mem_cgroup_move_account()
+ */
+static int mem_cgroup_move_account(struct page_cgroup *pc,
+				struct mem_cgroup *from, struct mem_cgroup *to)
+{
+	int ret = -EINVAL;
+	lock_page_cgroup(pc);
+	if (PageCgroupUsed(pc) && pc->mem_cgroup == from) {
+		__mem_cgroup_move_account(pc, from, to);
+		ret = 0;
+	}
+	unlock_page_cgroup(pc);
 	return ret;
 }
 
@@ -1713,38 +1710,27 @@ static int mem_cgroup_move_parent(struct page_cgroup *pc,
 	if (!pcg)
 		return -EINVAL;
 
+	ret = -EBUSY;
+	if (!get_page_unless_zero(page))
+		goto out;
+	if (isolate_lru_page(page))
+		goto put;
 
 	parent = mem_cgroup_from_cont(pcg);
-
-
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
 
 	ret = mem_cgroup_move_account(pc, child, parent);
-
+	if (!ret)
+		css_put(&parent->css);	/* drop extra refcnt by try_charge() */
+	else
+		mem_cgroup_cancel_charge(parent);	/* does css_put */
+put_back:
 	putback_lru_page(page);
-	if (!ret) {
-		put_page(page);
-		/* drop extra refcnt by try_charge() */
-		css_put(&parent->css);
-		return 0;
-	}
-
-cancel:
+put:
 	put_page(page);
-uncharge:
-	mem_cgroup_cancel_charge(parent);
+out:
 	return ret;
 }
 
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
