Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 57E0C8D0001
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 03:03:05 -0500 (EST)
Date: Fri, 26 Nov 2010 16:48:25 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [stable][BUGFIX] memcg: avoid deadlock between move charge and
 try_charge()
Message-Id: <20101126164825.24e684ca.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20101117092401.61c2117a.nishimura@mxp.nes.nec.co.jp>
References: <20101116191748.d6645376.nishimura@mxp.nes.nec.co.jp>
	<20101116124117.64608b66.akpm@linux-foundation.org>
	<20101117092401.61c2117a.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: stable@kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

> > > Cc: <stable@kernel.org>
> > 
> > The patch doesn't apply well to 2.6.36 so if we do want it backported
> > then please prepare a tested backport for the -stable guys?
> > 
> O.K.
> I'll test a backported patch for 2.6.36.y and send it after this is merged into mainline.
> 
Done.

I've tested this backported patch on 2.6.36 and it works properly.
There is no change in mm/memcontrol.c from v2.6.36 to v2.6.36.1, so
this can be applied to 2.6.36.1 too.

===
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

commit b1dd693e5b9348bd68a80e679e03cf9c0973b01b upstream.

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
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: <stable@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
---
 mm/memcontrol.c |   43 ++++++++++++++++++++++++++-----------------
 1 files changed, 26 insertions(+), 17 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9be3cf8..e6aadd6 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -269,13 +269,14 @@ enum move_type {
 
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
@@ -4445,7 +4446,7 @@ static unsigned long mem_cgroup_count_precharge(struct mm_struct *mm)
 	unsigned long precharge;
 	struct vm_area_struct *vma;
 
-	down_read(&mm->mmap_sem);
+	/* We've already held the mmap_sem */
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		struct mm_walk mem_cgroup_count_precharge_walk = {
 			.pmd_entry = mem_cgroup_count_precharge_pte_range,
@@ -4457,7 +4458,6 @@ static unsigned long mem_cgroup_count_precharge(struct mm_struct *mm)
 		walk_page_range(vma->vm_start, vma->vm_end,
 					&mem_cgroup_count_precharge_walk);
 	}
-	up_read(&mm->mmap_sem);
 
 	precharge = mc.precharge;
 	mc.precharge = 0;
@@ -4508,11 +4508,16 @@ static void mem_cgroup_clear_mc(void)
 
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
 	memcg_oom_recover(from);
 	memcg_oom_recover(to);
 	wake_up_all(&mc.waitq);
@@ -4537,26 +4542,37 @@ static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
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
 			spin_lock(&mc.lock);
 			mc.from = from;
 			mc.to = mem;
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
@@ -4644,7 +4660,7 @@ static void mem_cgroup_move_charge(struct mm_struct *mm)
 	struct vm_area_struct *vma;
 
 	lru_add_drain_all();
-	down_read(&mm->mmap_sem);
+	/* We've already held the mmap_sem */
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		int ret;
 		struct mm_walk mem_cgroup_move_charge_walk = {
@@ -4663,7 +4679,6 @@ static void mem_cgroup_move_charge(struct mm_struct *mm)
 			 */
 			break;
 	}
-	up_read(&mm->mmap_sem);
 }
 
 static void mem_cgroup_move_task(struct cgroup_subsys *ss,
@@ -4672,17 +4687,11 @@ static void mem_cgroup_move_task(struct cgroup_subsys *ss,
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
