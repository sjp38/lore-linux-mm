Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m7BAAR6f022842
	for <linux-mm@kvack.org>; Mon, 11 Aug 2008 06:10:27 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7BA7itX210920
	for <linux-mm@kvack.org>; Mon, 11 Aug 2008 06:07:44 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7BA7i3q030631
	for <linux-mm@kvack.org>; Mon, 11 Aug 2008 06:07:44 -0400
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Mon, 11 Aug 2008 15:37:43 +0530
Message-Id: <20080811100743.26336.6497.sendpatchset@balbir-laptop>
In-Reply-To: <20080811100719.26336.98302.sendpatchset@balbir-laptop>
References: <20080811100719.26336.98302.sendpatchset@balbir-laptop>
Subject: [-mm][PATCH 2/2] Memory rlimit enhance mm_owner_changed callback to deal with exited owner
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, nishimura@mxp.nes.nec.co.jp, Pavel Emelianov <xemul@openvz.org>, hugh@veritas.com, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


mm_owner_changed callback can also be called with new task set to NULL.
(race between try_to_unuse() and mm->owner exiting). Surprisingly the order
of cgroup arguments being passed was incorrect (proves that we did not
run into mm_owner_changed callback at all).

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 mm/memrlimitcgroup.c |   15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff -puN mm/memrlimitcgroup.c~memrlimit-handle-mm-owner-notification-with-task-null mm/memrlimitcgroup.c
--- linux-2.6.27-rc1/mm/memrlimitcgroup.c~memrlimit-handle-mm-owner-notification-with-task-null	2008-08-05 10:56:56.000000000 +0530
+++ linux-2.6.27-rc1-balbir/mm/memrlimitcgroup.c	2008-08-05 11:24:04.000000000 +0530
@@ -73,6 +73,12 @@ void memrlimit_cgroup_uncharge_as(struct
 {
 	struct memrlimit_cgroup *memrcg;
 
+	/*
+	 * Uncharge happened as a part of the mm_owner_changed callback
+	 */
+	if (!mm->owner)
+		return;
+
 	memrcg = memrlimit_cgroup_from_task(mm->owner);
 	res_counter_uncharge(&memrcg->as_res, (nr_pages << PAGE_SHIFT));
 }
@@ -235,8 +241,8 @@ out:
  * This callback is called with mmap_sem held
  */
 static void memrlimit_cgroup_mm_owner_changed(struct cgroup_subsys *ss,
-						struct cgroup *cgrp,
 						struct cgroup *old_cgrp,
+						struct cgroup *cgrp,
 						struct task_struct *p)
 {
 	struct memrlimit_cgroup *memrcg, *old_memrcg;
@@ -246,7 +252,12 @@ static void memrlimit_cgroup_mm_owner_ch
 	memrcg = memrlimit_cgroup_from_cgrp(cgrp);
 	old_memrcg = memrlimit_cgroup_from_cgrp(old_cgrp);
 
-	if (res_counter_charge(&memrcg->as_res, (mm->total_vm << PAGE_SHIFT)))
+	/*
+	 * If we don't have a new cgroup, we just uncharge from the old one.
+	 * It means that the task is going away
+	 */
+	if (memrcg &&
+	    res_counter_charge(&memrcg->as_res, (mm->total_vm << PAGE_SHIFT)))
 		goto out;
 	res_counter_uncharge(&old_memrcg->as_res, (mm->total_vm << PAGE_SHIFT));
 out:
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
