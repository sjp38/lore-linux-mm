Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 982616B0044
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 01:30:21 -0500 (EST)
Date: Mon, 14 Dec 2009 15:26:41 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH -mmotm 8/8] memcg: improbe performance in moving swap charge
Message-Id: <20091214152641.cc1b4f1a.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091214151748.bf9c4978.nishimura@mxp.nes.nec.co.jp>
References: <20091214151748.bf9c4978.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This patch tries to reduce overheads in moving charge by:

- Adds a new function(__mem_cgroup_get/put), which takes "count" as a arg and
  increment/decrement mem->refcnt by "count".
- removed res_counter_uncharge, css_put, and mem_cgroup_get/put from the path
  to move swap account, and consolidate all of them into mem_cgroup_clear_mc.

These changes reduces the overhead from **sec to **sec to move charges of 1G
anonymous memory(including 500MB swap) in my test environment.

Changelog: 2009/12/04
- new patch

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |   81 +++++++++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 64 insertions(+), 17 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index af8fbc4..80f25c8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -254,6 +254,7 @@ struct move_charge_struct {
 	struct mem_cgroup *to;
 	unsigned long precharge;
 	unsigned long moved_charge;
+	unsigned long moved_swap;
 	struct task_struct *moving_task;	/* a task moving charges */
 	wait_queue_head_t waitq;		/* a waitq for other context */
 						/* not to cause oom */
@@ -2277,6 +2278,7 @@ void mem_cgroup_uncharge_swap(swp_entry_t ent)
  * @entry: swap entry to be moved
  * @from:  mem_cgroup which the entry is moved from
  * @to:  mem_cgroup which the entry is moved to
+ * @need_fixup: whether we should fixup res_counters and refcounts.
  *
  * It succeeds only when the swap_cgroup's record for this entry is the same
  * as the mem_cgroup's id of @from.
@@ -2287,7 +2289,7 @@ void mem_cgroup_uncharge_swap(swp_entry_t ent)
  * both res and memsw, and called css_get().
  */
 static int mem_cgroup_move_swap_account(swp_entry_t entry,
-				struct mem_cgroup *from, struct mem_cgroup *to)
+		struct mem_cgroup *from, struct mem_cgroup *to, bool need_fixup)
 {
 	unsigned short old_id, new_id;
 
@@ -2295,19 +2297,25 @@ static int mem_cgroup_move_swap_account(swp_entry_t entry,
 	new_id = css_id(&to->css);
 
 	if (swap_cgroup_cmpxchg(entry, old_id, new_id) == old_id) {
-		if (!mem_cgroup_is_root(from))
-			res_counter_uncharge(&from->memsw, PAGE_SIZE);
 		mem_cgroup_swap_statistics(from, false);
-		mem_cgroup_put(from);
+		mem_cgroup_swap_statistics(to, true);
 		/*
-		 * we charged both to->res and to->memsw, so we should uncharge
-		 * to->res.
+		 * This function is only called from task migration context now,
+		 * so we can safely postpone mem_cgroup_get/put and uncharge
+		 * till the end of this context(mem_cgroup_clear_mc).
 		 */
-		if (!mem_cgroup_is_root(to))
-			res_counter_uncharge(&to->res, PAGE_SIZE);
-		mem_cgroup_swap_statistics(to, true);
-		mem_cgroup_get(to);
-
+		if (need_fixup) {
+			if (!mem_cgroup_is_root(from))
+				res_counter_uncharge(&from->memsw, PAGE_SIZE);
+			mem_cgroup_put(from);
+			/*
+			 * we charged both to->res and to->memsw, so we should
+			 * uncharge to->res.
+			 */
+			if (!mem_cgroup_is_root(to))
+				res_counter_uncharge(&to->res, PAGE_SIZE);
+			mem_cgroup_get(to);
+		}
 		return 0;
 	}
 	return -EINVAL;
@@ -3387,14 +3395,19 @@ static void __mem_cgroup_free(struct mem_cgroup *mem)
 		vfree(mem);
 }
 
+static void __mem_cgroup_get(struct mem_cgroup *mem, int count)
+{
+	atomic_add(count, &mem->refcnt);
+}
+
 static void mem_cgroup_get(struct mem_cgroup *mem)
 {
-	atomic_inc(&mem->refcnt);
+	__mem_cgroup_get(mem, 1);
 }
 
-static void mem_cgroup_put(struct mem_cgroup *mem)
+static void __mem_cgroup_put(struct mem_cgroup *mem, int count)
 {
-	if (atomic_dec_and_test(&mem->refcnt)) {
+	if (atomic_sub_and_test(count, &mem->refcnt)) {
 		struct mem_cgroup *parent = parent_mem_cgroup(mem);
 		__mem_cgroup_free(mem);
 		if (parent)
@@ -3402,6 +3415,11 @@ static void mem_cgroup_put(struct mem_cgroup *mem)
 	}
 }
 
+static void mem_cgroup_put(struct mem_cgroup *mem)
+{
+	__mem_cgroup_put(mem, 1);
+}
+
 /*
  * Returns the parent mem_cgroup in memcgroup hierarchy with hierarchy enabled.
  */
@@ -3762,6 +3780,33 @@ static void mem_cgroup_clear_mc(void)
 		__mem_cgroup_cancel_charge(mc.from, mc.moved_charge);
 		mc.moved_charge = 0;
 	}
+	/* we must fixup refcnts and charges */
+	if (mc.moved_swap) {
+		WARN_ON_ONCE(mc.moved_swap > INT_MAX);
+		/* uncharge swap account from the old cgroup */
+		if (!mem_cgroup_is_root(mc.from))
+			res_counter_uncharge(&mc.from->memsw,
+						PAGE_SIZE * mc.moved_swap);
+		__mem_cgroup_put(mc.from, mc.moved_swap);
+
+		if (!mem_cgroup_is_root(mc.to)) {
+			/*
+			 * we charged both to->res and to->memsw, so we should
+			 * uncharge to->res.
+			 */
+			res_counter_uncharge(&mc.to->res,
+						PAGE_SIZE * mc.moved_swap);
+			/*
+			 * we must do css_put to cancel the refcnt got in
+			 * can_attach.
+			 */
+			VM_BUG_ON(test_bit(CSS_ROOT, &mc.to->css.flags));
+			__css_put(&mc.to->css, mc.moved_swap);
+		}
+		__mem_cgroup_get(mc.to, mc.moved_swap);
+
+		mc.moved_swap = 0;
+	}
 	mc.from = NULL;
 	mc.to = NULL;
 	mc.moving_task = NULL;
@@ -3791,10 +3836,11 @@ static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
 			VM_BUG_ON(mc.to);
 			VM_BUG_ON(mc.precharge);
 			VM_BUG_ON(mc.moved_charge);
+			VM_BUG_ON(mc.moved_swap);
 			VM_BUG_ON(mc.moving_task);
 			mc = (struct move_charge_struct) {
 				.from = from, .to = mem, .precharge = 0,
-				.moved_charge = 0,
+				.moved_charge = 0, .moved_swap = 0,
 				.moving_task = current, .waitq = mc.waitq
 			};
 
@@ -3857,9 +3903,10 @@ put:			/* is_target_pte_for_mc() gets the page */
 		case MC_TARGET_SWAP:
 			ent = target.ent;
 			if (!mem_cgroup_move_swap_account(ent,
-						mc.from, mc.to)) {
-				css_put(&mc.to->css);
+						mc.from, mc.to, false)) {
 				mc.precharge--;
+				/* we fixup refcnts and charges later. */
+				mc.moved_swap++;
 			}
 			break;
 		default:
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
