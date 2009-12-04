Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1066660021B
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 01:50:31 -0500 (EST)
Date: Fri, 4 Dec 2009 14:49:39 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH -mmotm 3/7] memcg: move charges of anonymous page
Message-Id: <20091204144939.fb5f4567.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091204144609.b61cc8c4.nishimura@mxp.nes.nec.co.jp>
References: <20091204144609.b61cc8c4.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This patch is the core part of this move-charge-at-task-migration feature.
It implements functions to move charges of anonymous pages mapped only by
the target task.

Implementation:
- define struct move_charge_struct and a valuable of it(mc) to remember the
  count of pre-charges and other information.
- At can_attach(), get anon_rss of the target mm, call __mem_cgroup_try_charge()
  repeatedly and count up mc.precharge.
- At attach(), parse the page table, find a target page to be move, and call
  mem_cgroup_move_account() about the page.
- Cancel all precharges if mc.precharge > 0 on failure or at the end of
  task move.

Changelog: 2009/12/04
- change the term "recharge" to "move_charge".
- handle a signal in can_attach() phase.
- parse the page table in can_attach() phase again(go back to the old behavior),
  because it doesn't add so big overheads, so it would be better to calculate
  the precharge count more accurately.
Changelog: 2009/11/19
- in can_attach(), instead of parsing the page table, make use of per process
  mm_counter(anon_rss).
- loosen the valid check in is_target_pte_for_recharge().
Changelog: 2009/11/06
- drop support for file cache, shmem/tmpfs and shared(used by multiple processes)
  pages(revisit in future).
Changelog: 2009/10/13
- change the term "migrate" to "recharge".
Changelog: 2009/09/24
- in can_attach(), parse the page table of the task and count only the number
  of target ptes and call try_charge() repeatedly. No isolation at this phase.
- in attach(), parse the page table of the task again, and isolate the target
  page and call move_account() one by one.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |  295 +++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 285 insertions(+), 10 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2624d23..e38f211 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -21,6 +21,7 @@
 #include <linux/memcontrol.h>
 #include <linux/cgroup.h>
 #include <linux/mm.h>
+#include <linux/hugetlb.h>
 #include <linux/pagemap.h>
 #include <linux/smp.h>
 #include <linux/page-flags.h>
@@ -243,8 +244,17 @@ struct mem_cgroup {
  * left-shifted bitmap of these types.
  */
 enum move_type {
+	MOVE_CHARGE_TYPE_ANON,	/* private anonymous page and swap of it */
 	NR_MOVE_TYPE,
 };
+/* "mc" and its members are protected by cgroup_mutex */
+struct move_charge_struct {
+	struct mem_cgroup *from;
+	struct mem_cgroup *to;
+	unsigned long precharge;
+};
+static struct move_charge_struct mc;
+
 
 /*
  * Maximum loops in mem_cgroup_hierarchical_reclaim(), used for soft
@@ -1508,7 +1518,7 @@ charged:
 	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
 	 * if they exceeds softlimit.
 	 */
-	if (mem_cgroup_soft_limit_check(mem))
+	if (page && mem_cgroup_soft_limit_check(mem))
 		mem_cgroup_update_tree(mem, page);
 done:
 	return 0;
@@ -1688,8 +1698,9 @@ static void __mem_cgroup_move_account(struct page_cgroup *pc,
 	/*
 	 * We charges against "to" which may not have any tasks. Then, "to"
 	 * can be under rmdir(). But in current implementation, caller of
-	 * this function is just force_empty() and it's garanteed that
-	 * "to" is never removed. So, we don't check rmdir status here.
+	 * this function is just force_empty() and move charge, so it's
+	 * garanteed that "to" is never removed. So, we don't check rmdir
+	 * status here.
 	 */
 }
 
@@ -3430,11 +3441,171 @@ static int mem_cgroup_populate(struct cgroup_subsys *ss,
 }
 
 /* Handlers for move charge at task migration. */
-static int mem_cgroup_can_move_charge(void)
+static int mem_cgroup_do_precharge(void)
+{
+	int ret = -ENOMEM;
+	struct mem_cgroup *mem = mc.to;
+
+	ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false, NULL);
+	if (ret || !mem)
+		return -ENOMEM;
+
+	mc.precharge++;
+	return ret;
+}
+
+/**
+ * is_target_pte_for_mc - check a pte whether it is valid for move charge
+ * @vma: the vma the pte to be checked belongs
+ * @addr: the address corresponding to the pte to be checked
+ * @ptent: the pte to be checked
+ * @target: the pointer the target page will be stored(can be NULL)
+ *
+ * Returns
+ *   0(MC_TARGET_NONE): if the pte is not a target for move charge.
+ *   1(MC_TARGET_PAGE): if the page corresponding to this pte is a target for
+ *     move charge. if @target is not NULL, the page is stored in target->page
+ *     with extra refcnt got(Callers should handle it).
+ *
+ * Called with pte lock held.
+ */
+/* We add a new member later. */
+union mc_target {
+	struct page	*page;
+};
+
+/* We add a new type later. */
+enum mc_target_type {
+	MC_TARGET_NONE,	/* not used */
+	MC_TARGET_PAGE,
+};
+
+static int is_target_pte_for_mc(struct vm_area_struct *vma,
+		unsigned long addr, pte_t ptent, union mc_target *target)
+{
+	struct page *page;
+	struct page_cgroup *pc;
+	int ret = 0;
+	bool move_anon = test_bit(MOVE_CHARGE_TYPE_ANON,
+					&mc.to->move_charge_at_immigrate);
+
+	if (!pte_present(ptent))
+		return 0;
+
+	page = vm_normal_page(vma, addr, ptent);
+	if (!page || !page_mapped(page))
+		return 0;
+	/*
+	 * TODO: We don't move charges of file(including shmem/tmpfs) pages for
+	 * now.
+	 */
+	if (!move_anon || !PageAnon(page))
+		return 0;
+	/*
+	 * TODO: We don't move charges of shared(used by multiple processes)
+	 * pages for now.
+	 */
+	if (page_mapcount(page) > 1)
+		return 0;
+	if (!get_page_unless_zero(page))
+		return 0;
+
+	pc = lookup_page_cgroup(page);
+	/*
+	 * Do only loose check w/o page_cgroup lock. mem_cgroup_move_account()
+	 * checks the pc is valid or not under the lock.
+	 */
+	if (PageCgroupUsed(pc) && pc->mem_cgroup == mc.from) {
+		ret = MC_TARGET_PAGE;
+		if (target)
+			target->page = page;
+	}
+
+	if (!ret || !target)
+		put_page(page);
+
+	return ret;
+}
+
+static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
+					unsigned long addr, unsigned long end,
+					struct mm_walk *walk)
 {
+	struct vm_area_struct *vma = walk->private;
+	pte_t *pte;
+	spinlock_t *ptl;
+
+	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
+	for (; addr != end; pte++, addr += PAGE_SIZE)
+		if (is_target_pte_for_mc(vma, addr, *pte, NULL))
+			mc.precharge++;	/* increment precharge temporarily */
+	pte_unmap_unlock(pte - 1, ptl);
+	cond_resched();
+
 	return 0;
 }
 
+static unsigned long mem_cgroup_count_precharge(struct mm_struct *mm)
+{
+	unsigned long precharge;
+	struct vm_area_struct *vma;
+
+	down_read(&mm->mmap_sem);
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		struct mm_walk mem_cgroup_count_precharge_walk = {
+			.pmd_entry = mem_cgroup_count_precharge_pte_range,
+			.mm = mm,
+			.private = vma,
+		};
+		if (is_vm_hugetlb_page(vma))
+			continue;
+		/* TODO: We don't move charges of shmem/tmpfs pages for now. */
+		if (vma->vm_flags & VM_SHARED)
+			continue;
+		walk_page_range(vma->vm_start, vma->vm_end,
+					&mem_cgroup_count_precharge_walk);
+	}
+	up_read(&mm->mmap_sem);
+
+	precharge = mc.precharge;
+	mc.precharge = 0;
+
+	return precharge;
+}
+
+#define PRECHARGE_AT_ONCE	256
+static int mem_cgroup_precharge_mc(struct mm_struct *mm)
+{
+	int ret = 0;
+	int count = PRECHARGE_AT_ONCE;
+	unsigned long precharge = mem_cgroup_count_precharge(mm);
+
+	while (!ret && precharge--) {
+		if (signal_pending(current)) {
+			ret = -EINTR;
+			break;
+		}
+		if (!count--) {
+			count = PRECHARGE_AT_ONCE;
+			cond_resched();
+		}
+		ret = mem_cgroup_do_precharge();
+	}
+
+	return ret;
+}
+
+static void mem_cgroup_clear_mc(void)
+{
+	/* we must uncharge all the leftover precharges from mc.to */
+	while (mc.precharge) {
+		mem_cgroup_cancel_charge(mc.to);
+		mc.precharge--;
+	}
+	mc.from = NULL;
+	mc.to = NULL;
+}
+
 static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
 				struct cgroup *cgroup,
 				struct task_struct *p,
@@ -3452,11 +3623,19 @@ static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
 		mm = get_task_mm(p);
 		if (!mm)
 			return 0;
-
 		/* We move charges only when we move a owner of the mm */
-		if (mm->owner == p)
-			ret = mem_cgroup_can_move_charge();
-
+		if (mm->owner == p) {
+			VM_BUG_ON(mc.from);
+			VM_BUG_ON(mc.to);
+			VM_BUG_ON(mc.precharge);
+			mc.from = from;
+			mc.to = mem;
+			mc.precharge = 0;
+
+			ret = mem_cgroup_precharge_mc(mm);
+			if (ret)
+				mem_cgroup_clear_mc();
+		}
 		mmput(mm);
 	}
 	return ret;
@@ -3467,10 +3646,95 @@ static void mem_cgroup_cancel_attach(struct cgroup_subsys *ss,
 				struct task_struct *p,
 				bool threadgroup)
 {
+	mem_cgroup_clear_mc();
 }
 
-static void mem_cgroup_move_charge(void)
+static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
+				unsigned long addr, unsigned long end,
+				struct mm_walk *walk)
 {
+	int ret = 0;
+	struct vm_area_struct *vma = walk->private;
+	pte_t *pte;
+	spinlock_t *ptl;
+
+retry:
+	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
+	for (; addr != end; addr += PAGE_SIZE) {
+		pte_t ptent = *(pte++);
+		union mc_target target;
+		int type;
+		struct page *page;
+		struct page_cgroup *pc;
+
+		if (!mc.precharge)
+			break;
+
+		type = is_target_pte_for_mc(vma, addr, ptent, &target);
+		switch (type) {
+		case MC_TARGET_PAGE:
+			page = target.page;
+			if (isolate_lru_page(page))
+				goto put;
+			pc = lookup_page_cgroup(page);
+			if (!mem_cgroup_move_account(pc, mc.from, mc.to)) {
+				css_put(&mc.to->css);
+				mc.precharge--;
+			}
+			putback_lru_page(page);
+put:			/* is_target_pte_for_mc() gets the page */
+			put_page(page);
+			break;
+		default:
+			break;
+		}
+	}
+	pte_unmap_unlock(pte - 1, ptl);
+	cond_resched();
+
+	if (addr != end) {
+		/*
+		 * We have consumed all precharges we got in can_attach().
+		 * We try charge one by one, but don't do any additional
+		 * charges to mc.to if we have failed in charge once in attach()
+		 * phase.
+		 */
+		ret = mem_cgroup_do_precharge();
+		if (!ret)
+			goto retry;
+	}
+
+	return ret;
+}
+
+static void mem_cgroup_move_charge(struct mm_struct *mm)
+{
+	struct vm_area_struct *vma;
+
+	lru_add_drain_all();
+	down_read(&mm->mmap_sem);
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		int ret;
+		struct mm_walk mem_cgroup_move_charge_walk = {
+			.pmd_entry = mem_cgroup_move_charge_pte_range,
+			.mm = mm,
+			.private = vma,
+		};
+		if (is_vm_hugetlb_page(vma))
+			continue;
+		/* TODO: We don't move charges of shmem/tmpfs pages for now. */
+		if (vma->vm_flags & VM_SHARED)
+			continue;
+		ret = walk_page_range(vma->vm_start, vma->vm_end,
+						&mem_cgroup_move_charge_walk);
+		if (ret)
+			/*
+			 * means we have consumed all precharges and failed in
+			 * doing additional charge. Just abandon here.
+			 */
+			break;
+	}
+	up_read(&mm->mmap_sem);
 }
 
 static void mem_cgroup_move_task(struct cgroup_subsys *ss,
@@ -3479,7 +3743,18 @@ static void mem_cgroup_move_task(struct cgroup_subsys *ss,
 				struct task_struct *p,
 				bool threadgroup)
 {
-	mem_cgroup_move_charge();
+	struct mm_struct *mm;
+
+	if (!mc.to)
+		/* no need to move charge */
+		return;
+
+	mm = get_task_mm(p);
+	if (mm) {
+		mem_cgroup_move_charge(mm);
+		mmput(mm);
+	}
+	mem_cgroup_clear_mc();
 }
 
 struct cgroup_subsys mem_cgroup_subsys = {
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
