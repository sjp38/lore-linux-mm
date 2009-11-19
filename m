Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A9A3C6B004D
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 23:46:02 -0500 (EST)
Date: Thu, 19 Nov 2009 13:29:49 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH -mmotm 3/5] memcg: recharge charges of anonymous page
Message-Id: <20091119132949.9dd85afc.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091119132734.1757fc42.nishimura@mxp.nes.nec.co.jp>
References: <20091119132734.1757fc42.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This patch is the core part of this recharge-at-task-move feature.
It implements functions to recharge charges of anonymous pages mapped only by
the target task.

Implementation:
- define struct recharge_struct and a valuable of it(recharge) to remember
  the count of pre-charges and other information.
- At can_attach(), get anon_rss of the target mm, call __mem_cgroup_try_charge()
  repeatedly and count up recharge.precharge.
- At attach(), parse the page table, find a target page to be recharged, and
  call mem_cgroup_move_account() about the page.
- Cancel all charges if recharge.precharge > 0 on failure or at the end of
  task move.

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
 mm/memcontrol.c |  241 +++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 234 insertions(+), 7 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 13fe93d..df363da 100644
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
@@ -240,8 +241,17 @@ struct mem_cgroup {
 /* Stuffs for recharge at task move. */
 /* Types of charges to be recharged */
 enum recharge_type {
+	RECHARGE_TYPE_ANON,	/* private anonymous page and swap of it */
 	NR_RECHARGE_TYPE,
 };
+/* "recharge" and its members are protected by cgroup_lock */
+struct recharge_struct {
+	struct mem_cgroup *from;
+	struct mem_cgroup *to;
+	unsigned long precharge;
+};
+static struct recharge_struct recharge;
+
 
 /*
  * Maximum loops in mem_cgroup_hierarchical_reclaim(), used for soft
@@ -1499,7 +1509,7 @@ charged:
 	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
 	 * if they exceeds softlimit.
 	 */
-	if (mem_cgroup_soft_limit_check(mem))
+	if (page && mem_cgroup_soft_limit_check(mem))
 		mem_cgroup_update_tree(mem, page);
 done:
 	return 0;
@@ -3420,9 +3430,50 @@ static int mem_cgroup_populate(struct cgroup_subsys *ss,
 }
 
 /* Handlers for recharge at task move. */
-static int mem_cgroup_can_recharge(void)
+static int mem_cgroup_do_precharge(void)
 {
-	return 0;
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
+#define PRECHARGE_AT_ONCE	256
+static int mem_cgroup_prepare_recharge(struct mm_struct *mm)
+{
+	int ret = 0;
+	int count = PRECHARGE_AT_ONCE;
+	unsigned long prepare = 0;
+	bool recharge_anon = test_bit(RECHARGE_TYPE_ANON,
+					&recharge.to->recharge_at_immigrate);
+
+	if (recharge_anon)
+		prepare += get_mm_counter(mm, anon_rss);
+
+	while (!ret && prepare--) {
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
+static void mem_cgroup_clear_recharge(void)
+{
+	while (recharge.precharge) {
+		mem_cgroup_cancel_charge(recharge.to);
+		recharge.precharge--;
+	}
+	recharge.from = NULL;
+	recharge.to = NULL;
 }
 
 static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
@@ -3443,8 +3494,18 @@ static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
 		if (!mm)
 			return 0;
 
-		if (mm->owner == p)
-			ret = mem_cgroup_can_recharge();
+		if (mm->owner == p) {
+			VM_BUG_ON(recharge.from);
+			VM_BUG_ON(recharge.to);
+			VM_BUG_ON(recharge.precharge);
+			recharge.from = from;
+			recharge.to = mem;
+			recharge.precharge = 0;
+
+			ret = mem_cgroup_prepare_recharge(mm);
+			if (ret)
+				mem_cgroup_clear_recharge();
+		}
 
 		mmput(mm);
 	}
@@ -3456,10 +3517,165 @@ static void mem_cgroup_cancel_attach(struct cgroup_subsys *ss,
 				struct task_struct *p,
 				bool threadgroup)
 {
+	mem_cgroup_clear_recharge();
 }
 
-static void mem_cgroup_recharge(void)
+/**
+ * is_target_pte_for_recharge - check a pte whether it is valid for recharge
+ * @vma: the vma the pte to be checked belongs
+ * @addr: the address corresponding to the pte to be checked
+ * @ptent: the pte to be checked
+ * @target: the pointer the target page will be stored
+ *
+ * Returns
+ *   0(RECHARGE_TARGET_NONE): if the pte is not a target for recharge.
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
 {
+	struct page *page;
+	struct page_cgroup *pc;
+	int ret = 0;
+	bool recharge_anon = test_bit(RECHARGE_TYPE_ANON,
+					&recharge.to->recharge_at_immigrate);
+
+	if (!pte_present(ptent))
+		return 0;
+
+	page = vm_normal_page(vma, addr, ptent);
+	if (!page || !page_mapped(page))
+		return 0;
+	/* TODO: We don't recharge file(including shmem/tmpfs) pages for now. */
+	if (!recharge_anon || !PageAnon(page))
+		return 0;
+	/*
+	 * TODO: We don't recharge shared(used by multiple processes) pages
+	 * for now.
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
+	if (PageCgroupUsed(pc)) {
+		ret = RECHARGE_TARGET_PAGE;
+		target->page = page;
+	}
+
+	if (!ret)
+		put_page(page);
+
+	return ret;
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
+			break;
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
+		ret = mem_cgroup_do_precharge();
+		if (!ret)
+			goto retry;
+	}
+
+	return ret;
+}
+
+static void mem_cgroup_recharge(struct mm_struct *mm)
+{
+	struct vm_area_struct *vma;
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
+		/* TODO: We don't recharge shmem/tmpfs pages for now. */
+		if (vma->vm_flags & VM_SHARED)
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
 }
 
 static void mem_cgroup_move_task(struct cgroup_subsys *ss,
@@ -3468,7 +3684,18 @@ static void mem_cgroup_move_task(struct cgroup_subsys *ss,
 				struct task_struct *p,
 				bool threadgroup)
 {
-	mem_cgroup_recharge();
+	struct mm_struct *mm;
+
+	if (!recharge.to)
+		/* no need to recharge */
+		return;
+
+	mm = get_task_mm(p);
+	if (mm) {
+		mem_cgroup_recharge(mm);
+		mmput(mm);
+	}
+	mem_cgroup_clear_recharge();
 }
 
 struct cgroup_subsys mem_cgroup_subsys = {
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
