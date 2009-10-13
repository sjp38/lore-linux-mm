Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A23D46B00AD
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 01:01:02 -0400 (EDT)
Date: Tue, 13 Oct 2009 13:55:04 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [RFC][PATCH 5/8] memcg: recharge charges of mapped page
Message-Id: <20091013135504.22b7fade.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091013134903.66c9682a.nishimura@mxp.nes.nec.co.jp>
References: <20091013134903.66c9682a.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This patch is the core part of this recharge-at-task-move feature.
It implements functions to recharge charges of pages(including anonymous, shmem,
and file caches) mapped by the task.

Implementation:
- define struct recharge_struct and a valuable of it(recharge) to remember
  the count of pre-charges and other information.
- At can_attach(), parse the page table of the task and count the number of
  mapped pages which are charged to the source mem_cgroup, and call
  __mem_cgroup_try_charge() repeatedly and count up recharge.precharge.
- At attach(), parse the page table again, find a target page as we did in
  can_attach(), and call mem_cgroup_move_account() about the page.
- Cancel all charges if recharge.precharge > 0 on failure or at the end of
  task move.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |  266 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 263 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 66206cc..85fee0c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -21,6 +21,8 @@
 #include <linux/memcontrol.h>
 #include <linux/cgroup.h>
 #include <linux/mm.h>
+#include <linux/migrate.h>
+#include <linux/hugetlb.h>
 #include <linux/pagemap.h>
 #include <linux/smp.h>
 #include <linux/page-flags.h>
@@ -197,6 +199,18 @@ struct mem_cgroup {
 };
 
 /*
+ * A data structure and a valiable for recharging charges at task move.
+ * "recharge" and its members are protected by cgroup_lock
+ */
+struct recharge_struct {
+	struct mem_cgroup *from;
+	struct mem_cgroup *to;
+	struct task_struct *target;	/* the target task being moved */
+	unsigned long precharge;
+};
+static struct recharge_struct recharge;
+
+/*
  * Maximum loops in mem_cgroup_hierarchical_reclaim(), used for soft
  * limit reclaim to prevent infinite loops, if they ever occur.
  */
@@ -1529,7 +1543,7 @@ charged:
 	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
 	 * if they exceeds softlimit.
 	 */
-	if (mem_cgroup_soft_limit_check(mem))
+	if (page && mem_cgroup_soft_limit_check(mem))
 		mem_cgroup_update_tree(mem, page);
 done:
 	return 0;
@@ -3432,10 +3446,161 @@ static int mem_cgroup_populate(struct cgroup_subsys *ss,
 }
 
 /* Handlers for recharge at task move. */
+/**
+ * is_target_pte_for_recharge - check a pte whether it is target for recharge
+ * @vma: the vma the pte to be checked belongs
+ * @addr: the address corresponding to the pte to be checked
+ * @ptent: the pte to be checked
+ * @target: the pointer the target page will be stored(can be NULL)
+ *
+ * Returns
+ *   0(RECHARGE_TARGET_NONE): if the pte is not a target for charge recharge.
+ *   1(RECHARGE_TARGET_PAGE): if the page corresponding to this pte is a target
+ *     for recharge. if @target is not NULL, the page is stored in target->page
+ *     with extra refcnt got(Callers should handle it).
+ *
+ * Called with pte lock held.
+ */
+/* We add a new member later. */
+union recharge_target {
+	struct page	*page;
+};
+
+/* We add a new type later. */
+enum recharge_target_type {
+	RECHARGE_TARGET_NONE,	/* not used */
+	RECHARGE_TARGET_PAGE,
+};
+
+static int is_target_pte_for_recharge(struct vm_area_struct *vma,
+		unsigned long addr, pte_t ptent, union recharge_target *target)
+{
+	struct page *page;
+	struct page_cgroup *pc;
+	int ret = 0;
+
+	if (!pte_present(ptent))
+		return 0;
+
+	page = vm_normal_page(vma, addr, ptent);
+	if (!page || !page_mapped(page))
+		return 0;
+	if (!get_page_unless_zero(page))
+		return 0;
+
+	pc = lookup_page_cgroup(page);
+	lock_page_cgroup(pc);
+	if (PageCgroupUsed(pc) && pc->mem_cgroup == recharge.from) {
+		ret = RECHARGE_TARGET_PAGE;
+		if (target)
+			target->page = page;
+	}
+	unlock_page_cgroup(pc);
+
+	if (!ret || !target)
+		put_page(page);
+
+	return ret;
+}
+
+static int mem_cgroup_recharge_do_precharge(void)
+{
+	int ret = -ENOMEM;
+	struct mem_cgroup *mem = recharge.to;
+
+	ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false, NULL);
+	if (ret || !mem)
+		return -ENOMEM;
+
+	recharge.precharge++;
+	return ret;
+}
+
+static int mem_cgroup_recharge_prepare_pte_range(pmd_t *pmd,
+					unsigned long addr, unsigned long end,
+					struct mm_walk *walk)
+{
+	int ret = 0;
+	unsigned long count = 0;
+	struct vm_area_struct *vma = walk->private;
+	pte_t *pte;
+	spinlock_t *ptl;
+
+	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
+	for (; addr != end; pte++, addr += PAGE_SIZE)
+		if (is_target_pte_for_recharge(vma, addr, *pte, NULL))
+			count++;
+	pte_unmap_unlock(pte - 1, ptl);
+
+	while (count-- && !ret)
+		ret = mem_cgroup_recharge_do_precharge();
+
+	return ret;
+}
+
+static int mem_cgroup_recharge_prepare(void)
+{
+	int ret = 0;
+	struct mm_struct *mm;
+	struct vm_area_struct *vma;
+
+	mm = get_task_mm(recharge.target);
+	if (!mm)
+		return 0;
+
+	down_read(&mm->mmap_sem);
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		struct mm_walk mem_cgroup_recharge_prepare_walk = {
+			.pmd_entry = mem_cgroup_recharge_prepare_pte_range,
+			.mm = mm,
+			.private = vma,
+		};
+		if (signal_pending(current)) {
+			ret = -EINTR;
+			break;
+		}
+		if (is_vm_hugetlb_page(vma))
+			continue;
+		ret = walk_page_range(vma->vm_start, vma->vm_end,
+					&mem_cgroup_recharge_prepare_walk);
+		if (ret)
+			break;
+		cond_resched();
+	}
+	up_read(&mm->mmap_sem);
+
+	mmput(mm);
+	return ret;
+}
+
+static void mem_cgroup_clear_recharge(void)
+{
+	while (recharge.precharge--)
+		mem_cgroup_cancel_charge(recharge.to);
+	recharge.from = NULL;
+	recharge.to = NULL;
+	recharge.target = NULL;
+}
+
 static int mem_cgroup_can_recharge(struct mem_cgroup *mem,
 					struct task_struct *p)
 {
-	return 0;
+	int ret;
+	struct mem_cgroup *from = mem_cgroup_from_task(p);
+
+	if (from == mem)
+		return 0;
+
+	recharge.from = from;
+	recharge.to = mem;
+	recharge.target = p;
+	recharge.precharge = 0;
+
+	ret = mem_cgroup_recharge_prepare();
+
+	if (ret)
+		mem_cgroup_clear_recharge();
+	return ret;
 }
 
 static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
@@ -3458,11 +3623,104 @@ static void mem_cgroup_cancel_attach(struct cgroup_subsys *ss,
 				struct task_struct *p,
 				bool threadgroup)
 {
+	struct mem_cgroup *mem = mem_cgroup_from_cgroup(cgroup);
+
 	mutex_unlock(&memcg_tasklist);
+	if (mem->recharge_at_immigrate && thread_group_leader(p))
+		mem_cgroup_clear_recharge();
+}
+
+static int mem_cgroup_recharge_pte_range(pmd_t *pmd,
+				unsigned long addr, unsigned long end,
+				struct mm_walk *walk)
+{
+	int ret = 0;
+	struct vm_area_struct *vma = walk->private;
+	pte_t *pte;
+	spinlock_t *ptl;
+
+retry:
+	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
+	for (; addr != end; addr += PAGE_SIZE) {
+		pte_t ptent = *(pte++);
+		union recharge_target target;
+		int type;
+		struct page *page;
+		struct page_cgroup *pc;
+
+		if (!recharge.precharge)
+			break;
+
+		type = is_target_pte_for_recharge(vma, addr, ptent, &target);
+		switch (type) {
+		case RECHARGE_TARGET_PAGE:
+			page = target.page;
+			if (isolate_lru_page(page))
+				goto put;
+			pc = lookup_page_cgroup(page);
+			if (!mem_cgroup_move_account(pc,
+						recharge.from, recharge.to)) {
+				css_put(&recharge.to->css);
+				recharge.precharge--;
+			}
+			putback_lru_page(page);
+put:			/* is_target_pte_for_recharge() gets the page */
+			put_page(page);
+			break;
+		default:
+			continue;
+		}
+	}
+	pte_unmap_unlock(pte - 1, ptl);
+
+	if (addr != end) {
+		/*
+		 * We have consumed all precharges we got in can_attach().
+		 * We try precharge one by one, but don't do any additional
+		 * precharges nor recharges to recharge.to if we have failed in
+		 * precharge once in attach() phase.
+		 */
+		ret = mem_cgroup_recharge_do_precharge();
+		if (!ret)
+			goto retry;
+	}
+
+	return ret;
 }
 
 static void mem_cgroup_recharge(void)
 {
+	struct mm_struct *mm;
+	struct vm_area_struct *vma;
+
+	mm = get_task_mm(recharge.target);
+	if (!mm)
+		return;
+
+	lru_add_drain_all();
+	down_read(&mm->mmap_sem);
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		int ret;
+		struct mm_walk mem_cgroup_recharge_walk = {
+			.pmd_entry = mem_cgroup_recharge_pte_range,
+			.mm = mm,
+			.private = vma,
+		};
+		if (is_vm_hugetlb_page(vma))
+			continue;
+		ret = walk_page_range(vma->vm_start, vma->vm_end,
+						&mem_cgroup_recharge_walk);
+		if (ret)
+			/*
+			 * means we have consumed all precharges and failed in
+			 * doing additional precharge. Just abandon here.
+			 */
+			break;
+		cond_resched();
+	}
+	up_read(&mm->mmap_sem);
+
+	mmput(mm);
 }
 
 static void mem_cgroup_move_task(struct cgroup_subsys *ss,
@@ -3474,8 +3732,10 @@ static void mem_cgroup_move_task(struct cgroup_subsys *ss,
 	struct mem_cgroup *mem = mem_cgroup_from_cgroup(cgroup);
 
 	mutex_unlock(&memcg_tasklist);
-	if (mem->recharge_at_immigrate && thread_group_leader(p))
+	if (mem->recharge_at_immigrate && thread_group_leader(p)) {
 		mem_cgroup_recharge();
+		mem_cgroup_clear_recharge();
+	}
 }
 
 struct cgroup_subsys mem_cgroup_subsys = {
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
