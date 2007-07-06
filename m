Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l665j6K3087212
	for <linux-mm@kvack.org>; Fri, 6 Jul 2007 15:45:10 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l665Pgpc190372
	for <linux-mm@kvack.org>; Fri, 6 Jul 2007 15:25:45 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l665M7AL007898
	for <linux-mm@kvack.org>; Fri, 6 Jul 2007 15:22:08 +1000
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Thu, 05 Jul 2007 22:21:55 -0700
Message-Id: <20070706052155.11677.41872.sendpatchset@balbir-laptop>
In-Reply-To: <20070706052029.11677.16964.sendpatchset@balbir-laptop>
References: <20070706052029.11677.16964.sendpatchset@balbir-laptop>
Subject: [-mm PATCH 5/8] Memory controller task migration (v2)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>
Cc: Linux Containers <containers@lists.osdl.org>, Paul Menage <menage@google.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux MM Mailing List <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Eric W Biederman <ebiederm@xmission.com>
List-ID: <linux-mm.kvack.org>

Allow tasks to migrate from one container to the other. We migrate
mm_struct's mem_container only when the thread group id migrates.


Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 mm/memcontrol.c |   35 +++++++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff -puN mm/memcontrol.c~mem-control-task-migration mm/memcontrol.c
--- linux-2.6.22-rc6/mm/memcontrol.c~mem-control-task-migration	2007-07-05 13:45:18.000000000 -0700
+++ linux-2.6.22-rc6-balbir/mm/memcontrol.c	2007-07-05 13:45:18.000000000 -0700
@@ -302,11 +302,46 @@ err:
 	return rc;
 }
 
+static void mem_container_move_task(struct container_subsys *ss,
+				struct container *cont,
+				struct container *old_cont,
+				struct task_struct *p)
+{
+	struct mm_struct *mm;
+	struct mem_container *mem, *old_mem;
+
+	mm = get_task_mm(p);
+	if (mm == NULL)
+		return;
+
+	mem = mem_container_from_cont(cont);
+	old_mem = mem_container_from_cont(old_cont);
+
+	if (mem == old_mem)
+		goto out;
+
+	/*
+	 * Only thread group leaders are allowed to migrate, the mm_struct is
+	 * in effect owned by the leader
+	 */
+	if (p->tgid != p->pid)
+		goto out;
+
+	css_get(&mem->css);
+	rcu_assign_pointer(mm->mem_container, mem);
+	css_put(&old_mem->css);
+
+out:
+	mmput(mm);
+	return;
+}
+
 struct container_subsys mem_container_subsys = {
 	.name = "mem_container",
 	.subsys_id = mem_container_subsys_id,
 	.create = mem_container_create,
 	.destroy = mem_container_destroy,
 	.populate = mem_container_populate,
+	.attach = mem_container_move_task,
 	.early_init = 1,
 };
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
