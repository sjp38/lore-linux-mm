Received: by ey-out-1920.google.com with SMTP id 21so53968eyc.44
        for <linux-mm@kvack.org>; Thu, 18 Sep 2008 14:50:25 -0700 (PDT)
Message-ID: <48D2CD1D.9040202@gmail.com>
Date: Thu, 18 Sep 2008 23:50:21 +0200
From: Andrea Righi <righi.andrea@gmail.com>
Reply-To: righi.andrea@gmail.com
MIME-Version: 1.0
Subject: [PATCH -mm] memrlimit: fix task_lock() recursive locking (v2)
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>, containers@lists.linux-foundation.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

cgroup_mm_owner_callbacks() can be called with task_lock() held in
mm_update_next_owner(), and all the .mm_owner_changed callbacks seem to
be *always* called with task_lock() held.

Actually, memrlimit is using task_lock() via get_task_mm() in
memrlimit_cgroup_mm_owner_changed(), raising the following recursive locking
trace:

[ 5346.421365] =============================================
[ 5346.421374] [ INFO: possible recursive locking detected ]
[ 5346.421381] 2.6.27-rc5-mm1 #20
[ 5346.421385] ---------------------------------------------
[ 5346.421391] interbench/10530 is trying to acquire lock:
[ 5346.421396]  (&p->alloc_lock){--..}, at: [<ffffffff8023b034>] get_task_mm+0x24/0x70
[ 5346.421417]
[ 5346.421418] but task is already holding lock:
[ 5346.421423]  (&p->alloc_lock){--..}, at: [<ffffffff8023db98>] mm_update_next_owner+0x148/0x230
[ 5346.421438]
[ 5346.421440] other info that might help us debug this:
[ 5346.421446] 2 locks held by interbench/10530:
[ 5346.421450]  #0:  (&mm->mmap_sem){----}, at: [<ffffffff8023db90>] mm_update_next_owner+0x140/0x230
[ 5346.421467]  #1:  (&p->alloc_lock){--..}, at: [<ffffffff8023db98>] mm_update_next_owner+0x148/0x230
[ 5346.421483]
[ 5346.421485] stack backtrace:
[ 5346.421491] Pid: 10530, comm: interbench Not tainted 2.6.27-rc5-mm1 #20
[ 5346.421496] Call Trace:
[ 5346.421507]  [<ffffffff80263383>] validate_chain+0xb03/0x10d0
[ 5346.421515]  [<ffffffff80263c05>] __lock_acquire+0x2b5/0x9c0
[ 5346.421522]  [<ffffffff80262cc2>] validate_chain+0x442/0x10d0
[ 5346.421530]  [<ffffffff802643aa>] lock_acquire+0x9a/0xe0
[ 5346.421537]  [<ffffffff8023b034>] get_task_mm+0x24/0x70
[ 5346.421546]  [<ffffffff804757c7>] _spin_lock+0x37/0x70
[ 5346.421553]  [<ffffffff8023b034>] get_task_mm+0x24/0x70
[ 5346.421560]  [<ffffffff8023b034>] get_task_mm+0x24/0x70
[ 5346.421569]  [<ffffffff802b91f8>] memrlimit_cgroup_mm_owner_changed+0x18/0x90
[ 5346.421579]  [<ffffffff80278b03>] cgroup_mm_owner_callbacks+0x93/0xc0
[ 5346.421587]  [<ffffffff8023dc36>] mm_update_next_owner+0x1e6/0x230
[ 5346.421595]  [<ffffffff8023dd72>] exit_mm+0xf2/0x120
[ 5346.421602]  [<ffffffff8023f547>] do_exit+0x167/0x930
[ 5346.421610]  [<ffffffff8047604a>] _spin_unlock_irq+0x2a/0x50
[ 5346.421618]  [<ffffffff8023fd46>] do_group_exit+0x36/0xa0
[ 5346.421626]  [<ffffffff8020b7cb>] system_call_fastpath+0x16/0x1b

Since we hold task_lock(), we know that p->mm cannot change and we don't have
to worry about incrementing mm_users. So, just use p->mm directly and
check that we've not picked a kernel thread.

Signed-off-by: Andrea Righi <righi.andrea@gmail.com>
---
 kernel/cgroup.c      |    3 ++-
 mm/memrlimitcgroup.c |   10 ++++------
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 678a680..03cc925 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2757,7 +2757,8 @@ void cgroup_fork_callbacks(struct task_struct *child)
  * invoke this routine, since it assigns the mm->owner the first time
  * and does not change it.
  *
- * The callbacks are invoked with mmap_sem held in read mode.
+ * The callbacks are invoked with task_lock held and mmap_sem held in read
+ * mode.
  */
 void cgroup_mm_owner_callbacks(struct task_struct *old, struct task_struct *new)
 {
diff --git a/mm/memrlimitcgroup.c b/mm/memrlimitcgroup.c
index 8ee74f6..b3d20f5 100644
--- a/mm/memrlimitcgroup.c
+++ b/mm/memrlimitcgroup.c
@@ -238,7 +238,7 @@ out:
 }
 
 /*
- * This callback is called with mmap_sem held
+ * This callback is called with mmap_sem and task_lock held
  */
 static void memrlimit_cgroup_mm_owner_changed(struct cgroup_subsys *ss,
 						struct cgroup *old_cgrp,
@@ -246,9 +246,9 @@ static void memrlimit_cgroup_mm_owner_changed(struct cgroup_subsys *ss,
 						struct task_struct *p)
 {
 	struct memrlimit_cgroup *memrcg, *old_memrcg;
-	struct mm_struct *mm = get_task_mm(p);
+	struct mm_struct *mm = p->mm;
 
-	BUG_ON(!mm);
+	BUG_ON(!mm || (p->flags & PF_KTHREAD));
 
 	/*
 	 * If we don't have a new cgroup, we just uncharge from the old one.
@@ -258,7 +258,7 @@ static void memrlimit_cgroup_mm_owner_changed(struct cgroup_subsys *ss,
 		memrcg = memrlimit_cgroup_from_cgrp(cgrp);
 		if (res_counter_charge(&memrcg->as_res,
 				mm->total_vm << PAGE_SHIFT))
-			goto out;
+			return;
 	}
 
 	if (old_cgrp) {
@@ -266,8 +266,6 @@ static void memrlimit_cgroup_mm_owner_changed(struct cgroup_subsys *ss,
 		res_counter_uncharge(&old_memrcg->as_res,
 				mm->total_vm << PAGE_SHIFT);
 	}
-out:
-	mmput(mm);
 }
 
 struct cgroup_subsys memrlimit_cgroup_subsys = {
-- 
1.5.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
