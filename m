Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5Q9Skr7016342
	for <linux-mm@kvack.org>; Thu, 26 Jun 2008 05:28:46 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5Q9Sk8V202710
	for <linux-mm@kvack.org>; Thu, 26 Jun 2008 05:28:46 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5Q9SkR1010067
	for <linux-mm@kvack.org>; Thu, 26 Jun 2008 05:28:46 -0400
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Thu, 26 Jun 2008 14:58:43 +0530
Message-Id: <20080626092843.16841.59163.sendpatchset@balbir-laptop>
In-Reply-To: <20080626092815.16841.54817.sendpatchset@balbir-laptop>
References: <20080626092815.16841.54817.sendpatchset@balbir-laptop>
Subject: [2/5] memrlimit handle attach_task() failure, add can_attach() callback
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


Changelog v2->v1

1. Rename res_counter_add_check() to res_counter_can_add()

Making the first argument (struct res_counter *) a constant pointer causes
the compiler to spew out warnings in spin_(un)lock_irq* routines, since
we now pass address from a constant pointer to the lock routines.

This patch fixes a task migration problem reported by Kamezawa-San. This
patch should fix all issues with migraiton, except for a rare condition
documented in memrlimit_cgroup_move_task(). To fix that problem, we
would need to add transaction properties to cgroups.

The problem reported was that migrating to a group that did not have
sufficient limits to accept an incoming task caused a kernel warning.

Steps to reproduce

% mkdir /dev/cgroup/memrlimit/group_01
% mkdir /dev/cgroup/memrlimit/group_02
% echo 1G > /dev/cgroup/memrlimit/group_01/memrlimit.limit_in_bytes
% echo 0 >  /dev/cgroup/memrlimit/group_02/memrlimit.limit_in_bytes
% echo $$ > /dev/cgroup/memrlimit/group_01/tasks
% echo $$ > /dev/cgroup/memrlimit/group_02/tasks
% exit

memrlimit does the right thing by not moving the charges to group_02,
but the task is still put into g2 (since we did not use can_attach to
fail migration). Once in g2, when we echo the task to the root cgroup,
it tries to uncharge the cost of the task from g2. g2 does not have
any charge associated with the task, hence we get a warning.

Reported-by: kamezawa.hiroyu@jp.fujitsu.com

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 include/linux/res_counter.h |   18 ++++++++++++++++++
 mm/memrlimitcgroup.c        |   43 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 61 insertions(+)

diff -puN mm/memrlimitcgroup.c~memrlimit-cgroup-fix-attach-task mm/memrlimitcgroup.c
--- linux-2.6.26-rc5/mm/memrlimitcgroup.c~memrlimit-cgroup-fix-attach-task	2008-06-26 14:42:21.000000000 +0530
+++ linux-2.6.26-rc5-balbir/mm/memrlimitcgroup.c	2008-06-26 14:42:21.000000000 +0530
@@ -166,6 +166,38 @@ static int memrlimit_cgroup_populate(str
 				ARRAY_SIZE(memrlimit_cgroup_files));
 }
 
+static int memrlimit_cgroup_can_move_task(struct cgroup_subsys *ss,
+					struct cgroup *cgrp,
+					struct task_struct *p)
+{
+	struct mm_struct *mm;
+	struct memrlimit_cgroup *memrcg;
+	int ret = 0;
+
+	mm = get_task_mm(p);
+	if (mm == NULL)
+		return -EINVAL;
+
+	/*
+	 * Hold mmap_sem, so that total_vm does not change underneath us
+	 */
+	down_read(&mm->mmap_sem);
+
+	rcu_read_lock();
+	if (p != rcu_dereference(mm->owner))
+		goto out;
+
+	memrcg = memrlimit_cgroup_from_cgrp(cgrp);
+
+	if (!res_counter_can_add(&memrcg->as_res, (mm->total_vm << PAGE_SHIFT)))
+		ret = -ENOMEM;
+out:
+	rcu_read_unlock();
+	up_read(&mm->mmap_sem);
+	mmput(mm);
+	return ret;
+}
+
 static void memrlimit_cgroup_move_task(struct cgroup_subsys *ss,
 					struct cgroup *cgrp,
 					struct cgroup *old_cgrp,
@@ -193,6 +225,16 @@ static void memrlimit_cgroup_move_task(s
 	if (memrcg == old_memrcg)
 		goto out;
 
+	/*
+	 * TBD: Even though we do the necessary checks in can_attach(),
+	 * by the time we come here, there is a chance that we still
+	 * fail (the memrlimit cgroup has grown its usage, and the
+	 * addition of total_vm will no longer fit into its limit)
+	 *
+	 * We need transactional support in cgroups to let us know
+	 * if can_attach() has failed and call attach_failed() on
+	 * cgroups for which can_attach() succeeded.
+	 */
 	if (res_counter_charge(&memrcg->as_res, (mm->total_vm << PAGE_SHIFT)))
 		goto out;
 	res_counter_uncharge(&old_memrcg->as_res, (mm->total_vm << PAGE_SHIFT));
@@ -231,6 +273,7 @@ struct cgroup_subsys memrlimit_cgroup_su
 	.destroy = memrlimit_cgroup_destroy,
 	.populate = memrlimit_cgroup_populate,
 	.attach = memrlimit_cgroup_move_task,
+	.can_attach = memrlimit_cgroup_can_move_task,
 	.mm_owner_changed = memrlimit_cgroup_mm_owner_changed,
 	.early_init = 0,
 };
diff -puN kernel/res_counter.c~memrlimit-cgroup-fix-attach-task kernel/res_counter.c
diff -puN include/linux/res_counter.h~memrlimit-cgroup-fix-attach-task include/linux/res_counter.h
--- linux-2.6.26-rc5/include/linux/res_counter.h~memrlimit-cgroup-fix-attach-task	2008-06-26 14:42:21.000000000 +0530
+++ linux-2.6.26-rc5-balbir/include/linux/res_counter.h	2008-06-26 14:44:39.000000000 +0530
@@ -153,4 +153,22 @@ static inline void res_counter_reset_fai
 	cnt->failcnt = 0;
 	spin_unlock_irqrestore(&cnt->lock, flags);
 }
+
+/*
+ * Add the value val to the resource counter and check if we are
+ * still under the limit.
+ */
+static inline bool res_counter_can_add(struct res_counter *cnt,
+						unsigned long val)
+{
+	bool ret = false;
+	unsigned long flags;
+
+	spin_lock_irqsave(&cnt->lock, flags);
+	if (cnt->usage + val <= cnt->limit)
+		ret = true;
+	spin_unlock_irqrestore(&cnt->lock, flags);
+	return ret;
+}
+
 #endif
_

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
