Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 164CF8D0080
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 05:20:20 -0500 (EST)
Date: Tue, 16 Nov 2010 19:17:48 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [BUGFIX] memcg: avoid deadlock between move charge and try_charge()
Message-Id: <20101116191748.d6645376.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

__mem_cgroup_try_charge() can be called under down_write(&mmap_sem)(e.g.
mlock does it). This means it can cause deadlock if it races with move charge:

Ex.1)
                move charge             |        try charge
  --------------------------------------+------------------------------
    mem_cgroup_can_attach()             |  down_write(&mmap_sem)
      mc.moving_task = current          |    ..
      mem_cgroup_precharge_mc()         |  __mem_cgroup_try_charge()
        mem_cgroup_count_precharge()    |    prepare_to_wait()
          down_read(&mmap_sem)          |    if (mc.moving_task)
          -> cannot aquire the lock     |    -> true
                                        |      schedule()

Ex.2)
                move charge             |        try charge
  --------------------------------------+------------------------------
    mem_cgroup_can_attach()             |
      mc.moving_task = current          |
      mem_cgroup_precharge_mc()         |
        mem_cgroup_count_precharge()    |
          down_read(&mmap_sem)          |
          ..                            |
          up_read(&mmap_sem)            |
                                        |  down_write(&mmap_sem)
    mem_cgroup_move_task()              |    ..
      mem_cgroup_move_charge()          |  __mem_cgroup_try_charge()
        down_read(&mmap_sem)            |    prepare_to_wait()
        -> cannot aquire the lock       |    if (mc.moving_task)
                                        |    -> true
                                        |      schedule()

To avoid this deadlock, we do all the move charge works (both can_attach() and
attach()) under one mmap_sem section.
And after this patch, we set/clear mc.moving_task outside mc.lock, because we
use the lock only to check mc.from/to.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: <stable@kernel.org>
---
 mm/memcontrol.c |   43 ++++++++++++++++++++++++++-----------------
 1 files changed, 26 insertions(+), 17 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2efa8ea..0255505 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -278,13 +278,14 @@ enum move_type {
 
 /* "mc" and its members are protected by cgroup_mutex */
 static struct move_charge_struct {
-	spinlock_t	  lock; /* for from, to, moving_task */
+	spinlock_t	  lock; /* for from, to */
 	struct mem_cgroup *from;
 	struct mem_cgroup *to;
 	unsigned long precharge;
 	unsigned long moved_charge;
 	unsigned long moved_swap;
 	struct task_struct *moving_task;	/* a task moving charges */
+	struct mm_struct *mm;
 	wait_queue_head_t waitq;		/* a waitq for other context */
 } mc = {
 	.lock = __SPIN_LOCK_UNLOCKED(mc.lock),
@@ -4631,7 +4632,7 @@ static unsigned long mem_cgroup_count_precharge(struct mm_struct *mm)
 	unsigned long precharge;
 	struct vm_area_struct *vma;
 
-	down_read(&mm->mmap_sem);
+	/* We've already held the mmap_sem */
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		struct mm_walk mem_cgroup_count_precharge_walk = {
 			.pmd_entry = mem_cgroup_count_precharge_pte_range,
@@ -4643,7 +4644,6 @@ static unsigned long mem_cgroup_count_precharge(struct mm_struct *mm)
 		walk_page_range(vma->vm_start, vma->vm_end,
 					&mem_cgroup_count_precharge_walk);
 	}
-	up_read(&mm->mmap_sem);
 
 	precharge = mc.precharge;
 	mc.precharge = 0;
@@ -4694,11 +4694,16 @@ static void mem_cgroup_clear_mc(void)
 
 		mc.moved_swap = 0;
 	}
+	if (mc.mm) {
+		up_read(&mc.mm->mmap_sem);
+		mmput(mc.mm);
+	}
 	spin_lock(&mc.lock);
 	mc.from = NULL;
 	mc.to = NULL;
-	mc.moving_task = NULL;
 	spin_unlock(&mc.lock);
+	mc.moving_task = NULL;
+	mc.mm = NULL;
 	mem_cgroup_end_move(from);
 	memcg_oom_recover(from);
 	memcg_oom_recover(to);
@@ -4724,12 +4729,21 @@ static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
 			return 0;
 		/* We move charges only when we move a owner of the mm */
 		if (mm->owner == p) {
+			/*
+			 * We do all the move charge works under one mmap_sem to
+			 * avoid deadlock with down_write(&mmap_sem)
+			 * -> try_charge() -> if (mc.moving_task) -> sleep.
+			 */
+			down_read(&mm->mmap_sem);
+
 			VM_BUG_ON(mc.from);
 			VM_BUG_ON(mc.to);
 			VM_BUG_ON(mc.precharge);
 			VM_BUG_ON(mc.moved_charge);
 			VM_BUG_ON(mc.moved_swap);
 			VM_BUG_ON(mc.moving_task);
+			VM_BUG_ON(mc.mm);
+
 			mem_cgroup_start_move(from);
 			spin_lock(&mc.lock);
 			mc.from = from;
@@ -4737,14 +4751,16 @@ static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
 			mc.precharge = 0;
 			mc.moved_charge = 0;
 			mc.moved_swap = 0;
-			mc.moving_task = current;
 			spin_unlock(&mc.lock);
+			mc.moving_task = current;
+			mc.mm = mm;
 
 			ret = mem_cgroup_precharge_mc(mm);
 			if (ret)
 				mem_cgroup_clear_mc();
-		}
-		mmput(mm);
+			/* We call up_read() and mmput() in clear_mc(). */
+		} else
+			mmput(mm);
 	}
 	return ret;
 }
@@ -4832,7 +4848,7 @@ static void mem_cgroup_move_charge(struct mm_struct *mm)
 	struct vm_area_struct *vma;
 
 	lru_add_drain_all();
-	down_read(&mm->mmap_sem);
+	/* We've already held the mmap_sem */
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		int ret;
 		struct mm_walk mem_cgroup_move_charge_walk = {
@@ -4851,7 +4867,6 @@ static void mem_cgroup_move_charge(struct mm_struct *mm)
 			 */
 			break;
 	}
-	up_read(&mm->mmap_sem);
 }
 
 static void mem_cgroup_move_task(struct cgroup_subsys *ss,
@@ -4860,17 +4875,11 @@ static void mem_cgroup_move_task(struct cgroup_subsys *ss,
 				struct task_struct *p,
 				bool threadgroup)
 {
-	struct mm_struct *mm;
-
-	if (!mc.to)
+	if (!mc.mm)
 		/* no need to move charge */
 		return;
 
-	mm = get_task_mm(p);
-	if (mm) {
-		mem_cgroup_move_charge(mm);
-		mmput(mm);
-	}
+	mem_cgroup_move_charge(mc.mm);
 	mem_cgroup_clear_mc();
 }
 #else	/* !CONFIG_MMU */
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
