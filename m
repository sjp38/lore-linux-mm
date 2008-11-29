From: Nikanth Karthikesan <knikanth@suse.de>
Subject: [PATCH] Unused check for thread group leader in mem_cgroup_move_task
Date: Sat, 29 Nov 2008 12:59:27 +0530
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Message-Id: <200811291259.27681.knikanth@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: containers@lists.linux-foundation.org, xemul@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, nikanth@gmail.com
List-ID: <linux-mm.kvack.org>

Currently we just check for thread group leader in attach() handler but do 
nothing!  Either (1) move it to can_attach handler or (2) remove the test 
itself. I am attaching patches for both below.

Thanks
Nikanth Karthikesan

Move thread group leader check to can_attach handler, but this may prevent non 
thread group leaders to be moved at all! 

Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>

---
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 866dcc7..26bc823 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1136,6 +1136,18 @@ static int mem_cgroup_populate(struct cgroup_subsys 
*ss,
 					ARRAY_SIZE(mem_cgroup_files));
 }
 
+static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
+                          struct cgroup *cgrp, struct task_struct *tsk)
+{
+	/*
+	 * Only thread group leaders are allowed to migrate, the mm_struct is
+	 * in effect owned by the leader
+	 */
+	if (!thread_group_leader(tsk))
+		return -EINVAL;
+	return 0;
+}
+
 static void mem_cgroup_move_task(struct cgroup_subsys *ss,
 				struct cgroup *cont,
 				struct cgroup *old_cont,
@@ -1151,14 +1163,6 @@ static void mem_cgroup_move_task(struct cgroup_subsys 
*ss,
 	mem = mem_cgroup_from_cont(cont);
 	old_mem = mem_cgroup_from_cont(old_cont);
 
-	/*
-	 * Only thread group leaders are allowed to migrate, the mm_struct is
-	 * in effect owned by the leader
-	 */
-	if (!thread_group_leader(p))
-		goto out;
-
-out:
 	mmput(mm);
 }
 
@@ -1169,6 +1173,7 @@ struct cgroup_subsys mem_cgroup_subsys = {
 	.pre_destroy = mem_cgroup_pre_destroy,
 	.destroy = mem_cgroup_destroy,
 	.populate = mem_cgroup_populate,
+	.can_attach = mem_cgroup_can_attach,
 	.attach = mem_cgroup_move_task,
 	.early_init = 0,
 };



The patch to remove unused code follows.

Remove the unused test for thread group leader.

Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>

---
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 866dcc7..8e9287d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1151,14 +1151,6 @@ static void mem_cgroup_move_task(struct cgroup_subsys 
*ss,
 	mem = mem_cgroup_from_cont(cont);
 	old_mem = mem_cgroup_from_cont(old_cont);
 
-	/*
-	 * Only thread group leaders are allowed to migrate, the mm_struct is
-	 * in effect owned by the leader
-	 */
-	if (!thread_group_leader(p))
-		goto out;
-
-out:
 	mmput(mm);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
