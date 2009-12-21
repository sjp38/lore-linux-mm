Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 133BB6B0047
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 00:47:51 -0500 (EST)
Date: Mon, 21 Dec 2009 14:36:20 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH -mmotm 5/8] memcg: improve performance in moving charge
Message-Id: <20091221143620.4830a54c.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091221143106.6ff3ca15.nishimura@mxp.nes.nec.co.jp>
References: <20091221143106.6ff3ca15.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This patch tries to reduce overheads in moving charge by:

- Instead of calling res_counter_uncharge() against the old cgroup in
  __mem_cgroup_move_account() everytime, call res_counter_uncharge() at the end
  of task migration once.
- removed css_get(&to->css) from __mem_cgroup_move_account() because callers
  should have already called css_get(). And removed css_put(&to->css) too,
  which was called by callers of move_account on success of move_account.
- Instead of calling __mem_cgroup_try_charge(), i.e. res_counter_charge(),
  repeatedly, call res_counter_charge(PAGE_SIZE * count) in can_attach() if
  possible.
- Instead of calling css_get()/css_put() repeatedly, make use of coalesce
  __css_get()/__css_put() if possible.

These changes reduces the overhead from 1.7sec to 0.6sec to move charges of 1G
anonymous memory in my test environment.

Changelog: 2009/12/14
- move cgroup part to another patch.
- fix some bugs.

Changelog: 2009/12/04
- new patch

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |  152 +++++++++++++++++++++++++++++++++++-------------------
 1 files changed, 98 insertions(+), 54 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c363170..86e3202 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -252,6 +252,7 @@ struct move_charge_struct {
 	struct mem_cgroup *from;
 	struct mem_cgroup *to;
 	unsigned long precharge;
+	unsigned long moved_charge;
 };
 static struct move_charge_struct mc;
 
@@ -1537,14 +1538,23 @@ nomem:
  * This function is for that and do uncharge, put css's refcnt.
  * gotten by try_charge().
  */
-static void mem_cgroup_cancel_charge(struct mem_cgroup *mem)
+static void __mem_cgroup_cancel_charge(struct mem_cgroup *mem,
+							unsigned long count)
 {
 	if (!mem_cgroup_is_root(mem)) {
-		res_counter_uncharge(&mem->res, PAGE_SIZE);
+		res_counter_uncharge(&mem->res, PAGE_SIZE * count);
 		if (do_swap_account)
-			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
+			res_counter_uncharge(&mem->memsw, PAGE_SIZE * count);
+		VM_BUG_ON(test_bit(CSS_ROOT, &mem->css.flags));
+		WARN_ON_ONCE(count > INT_MAX);
+		__css_put(&mem->css, (int)count);
 	}
-	css_put(&mem->css);
+	/* we don't need css_put for root */
+}
+
+static void mem_cgroup_cancel_charge(struct mem_cgroup *mem)
+{
+	__mem_cgroup_cancel_charge(mem, 1);
 }
 
 /*
@@ -1647,17 +1657,20 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
  * @pc:	page_cgroup of the page.
  * @from: mem_cgroup which the page is moved from.
  * @to:	mem_cgroup which the page is moved to. @from != @to.
+ * @uncharge: whether we should call uncharge and css_put against @from.
  *
  * The caller must confirm following.
  * - page is not on LRU (isolate_page() is useful.)
  * - the pc is locked, used, and ->mem_cgroup points to @from.
  *
- * This function does "uncharge" from old cgroup but doesn't do "charge" to
- * new cgroup. It should be done by a caller.
+ * This function doesn't do "charge" nor css_get to new cgroup. It should be
+ * done by a caller(__mem_cgroup_try_charge would be usefull). If @uncharge is
+ * true, this function does "uncharge" from old cgroup, but it doesn't if
+ * @uncharge is false, so a caller should do "uncharge".
  */
 
 static void __mem_cgroup_move_account(struct page_cgroup *pc,
-	struct mem_cgroup *from, struct mem_cgroup *to)
+	struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge)
 {
 	struct page *page;
 	int cpu;
@@ -1670,10 +1683,6 @@ static void __mem_cgroup_move_account(struct page_cgroup *pc,
 	VM_BUG_ON(!PageCgroupUsed(pc));
 	VM_BUG_ON(pc->mem_cgroup != from);
 
-	if (!mem_cgroup_is_root(from))
-		res_counter_uncharge(&from->res, PAGE_SIZE);
-	mem_cgroup_charge_statistics(from, pc, false);
-
 	page = pc->page;
 	if (page_mapped(page) && !PageAnon(page)) {
 		cpu = smp_processor_id();
@@ -1689,12 +1698,12 @@ static void __mem_cgroup_move_account(struct page_cgroup *pc,
 		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_FILE_MAPPED,
 						1);
 	}
+	mem_cgroup_charge_statistics(from, pc, false);
+	if (uncharge)
+		/* This is not "cancel", but cancel_charge does all we need. */
+		mem_cgroup_cancel_charge(from);
 
-	if (do_swap_account && !mem_cgroup_is_root(from))
-		res_counter_uncharge(&from->memsw, PAGE_SIZE);
-	css_put(&from->css);
-
-	css_get(&to->css);
+	/* caller should have done css_get */
 	pc->mem_cgroup = to;
 	mem_cgroup_charge_statistics(to, pc, true);
 	/*
@@ -1711,12 +1720,12 @@ static void __mem_cgroup_move_account(struct page_cgroup *pc,
  * __mem_cgroup_move_account()
  */
 static int mem_cgroup_move_account(struct page_cgroup *pc,
-				struct mem_cgroup *from, struct mem_cgroup *to)
+		struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge)
 {
 	int ret = -EINVAL;
 	lock_page_cgroup(pc);
 	if (PageCgroupUsed(pc) && pc->mem_cgroup == from) {
-		__mem_cgroup_move_account(pc, from, to);
+		__mem_cgroup_move_account(pc, from, to, uncharge);
 		ret = 0;
 	}
 	unlock_page_cgroup(pc);
@@ -1752,11 +1761,9 @@ static int mem_cgroup_move_parent(struct page_cgroup *pc,
 	if (ret || !parent)
 		goto put_back;
 
-	ret = mem_cgroup_move_account(pc, child, parent);
-	if (!ret)
-		css_put(&parent->css);	/* drop extra refcnt by try_charge() */
-	else
-		mem_cgroup_cancel_charge(parent);	/* does css_put */
+	ret = mem_cgroup_move_account(pc, child, parent, true);
+	if (ret)
+		mem_cgroup_cancel_charge(parent);
 put_back:
 	putback_lru_page(page);
 put:
@@ -3442,16 +3449,58 @@ static int mem_cgroup_populate(struct cgroup_subsys *ss,
 }
 
 /* Handlers for move charge at task migration. */
-static int mem_cgroup_do_precharge(void)
+#define PRECHARGE_COUNT_AT_ONCE	256
+static int mem_cgroup_do_precharge(unsigned long count)
 {
-	int ret = -ENOMEM;
+	int ret = 0;
+	int batch_count = PRECHARGE_COUNT_AT_ONCE;
 	struct mem_cgroup *mem = mc.to;
 
-	ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false, NULL);
-	if (ret || !mem)
-		return -ENOMEM;
-
-	mc.precharge++;
+	if (mem_cgroup_is_root(mem)) {
+		mc.precharge += count;
+		/* we don't need css_get for root */
+		return ret;
+	}
+	/* try to charge at once */
+	if (count > 1) {
+		struct res_counter *dummy;
+		/*
+		 * "mem" cannot be under rmdir() because we've already checked
+		 * by cgroup_lock_live_cgroup() that it is not removed and we
+		 * are still under the same cgroup_mutex. So we can postpone
+		 * css_get().
+		 */
+		if (res_counter_charge(&mem->res, PAGE_SIZE * count, &dummy))
+			goto one_by_one;
+		if (do_swap_account && res_counter_charge(&mem->memsw,
+						PAGE_SIZE * count, &dummy)) {
+			res_counter_uncharge(&mem->res, PAGE_SIZE * count);
+			goto one_by_one;
+		}
+		mc.precharge += count;
+		VM_BUG_ON(test_bit(CSS_ROOT, &mem->css.flags));
+		WARN_ON_ONCE(count > INT_MAX);
+		__css_get(&mem->css, (int)count);
+		return ret;
+	}
+one_by_one:
+	/* fall back to one by one charge */
+	while (count--) {
+		if (signal_pending(current)) {
+			ret = -EINTR;
+			break;
+		}
+		if (!batch_count--) {
+			batch_count = PRECHARGE_COUNT_AT_ONCE;
+			cond_resched();
+		}
+		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem,
+								false, NULL);
+		if (ret || !mem)
+			/* mem_cgroup_clear_mc() will do uncharge later */
+			return -ENOMEM;
+		mc.precharge++;
+	}
 	return ret;
 }
 
@@ -3574,34 +3623,25 @@ static unsigned long mem_cgroup_count_precharge(struct mm_struct *mm)
 	return precharge;
 }
 
-#define PRECHARGE_AT_ONCE	256
 static int mem_cgroup_precharge_mc(struct mm_struct *mm)
 {
-	int ret = 0;
-	int count = PRECHARGE_AT_ONCE;
-	unsigned long precharge = mem_cgroup_count_precharge(mm);
-
-	while (!ret && precharge--) {
-		if (signal_pending(current)) {
-			ret = -EINTR;
-			break;
-		}
-		if (!count--) {
-			count = PRECHARGE_AT_ONCE;
-			cond_resched();
-		}
-		ret = mem_cgroup_do_precharge();
-	}
-
-	return ret;
+	return mem_cgroup_do_precharge(mem_cgroup_count_precharge(mm));
 }
 
 static void mem_cgroup_clear_mc(void)
 {
 	/* we must uncharge all the leftover precharges from mc.to */
-	while (mc.precharge) {
-		mem_cgroup_cancel_charge(mc.to);
-		mc.precharge--;
+	if (mc.precharge) {
+		__mem_cgroup_cancel_charge(mc.to, mc.precharge);
+		mc.precharge = 0;
+	}
+	/*
+	 * we didn't uncharge from mc.from at mem_cgroup_move_account(), so
+	 * we must uncharge here.
+	 */
+	if (mc.moved_charge) {
+		__mem_cgroup_cancel_charge(mc.from, mc.moved_charge);
+		mc.moved_charge = 0;
 	}
 	mc.from = NULL;
 	mc.to = NULL;
@@ -3629,9 +3669,11 @@ static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
 			VM_BUG_ON(mc.from);
 			VM_BUG_ON(mc.to);
 			VM_BUG_ON(mc.precharge);
+			VM_BUG_ON(mc.moved_charge);
 			mc.from = from;
 			mc.to = mem;
 			mc.precharge = 0;
+			mc.moved_charge = 0;
 
 			ret = mem_cgroup_precharge_mc(mm);
 			if (ret)
@@ -3678,9 +3720,11 @@ retry:
 			if (isolate_lru_page(page))
 				goto put;
 			pc = lookup_page_cgroup(page);
-			if (!mem_cgroup_move_account(pc, mc.from, mc.to)) {
-				css_put(&mc.to->css);
+			if (!mem_cgroup_move_account(pc,
+						mc.from, mc.to, false)) {
 				mc.precharge--;
+				/* we uncharge from mc.from later. */
+				mc.moved_charge++;
 			}
 			putback_lru_page(page);
 put:			/* is_target_pte_for_mc() gets the page */
@@ -3700,7 +3744,7 @@ put:			/* is_target_pte_for_mc() gets the page */
 		 * charges to mc.to if we have failed in charge once in attach()
 		 * phase.
 		 */
-		ret = mem_cgroup_do_precharge();
+		ret = mem_cgroup_do_precharge(1);
 		if (!ret)
 			goto retry;
 	}
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
