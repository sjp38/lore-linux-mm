Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4F5B76B0038
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 17:03:00 -0400 (EDT)
Received: by qgbb65 with SMTP id b65so76771464qgb.2
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 14:03:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 76si20722738qgi.45.2015.10.23.14.02.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Oct 2015 14:02:59 -0700 (PDT)
From: Aristeu Rozanski <arozansk@redhat.com>
Subject: [PATCH] oom_kill: add option to disable dump_stack()
Date: Fri, 23 Oct 2015 17:02:30 -0400
Message-Id: <1445634150-27992-1-git-send-email-arozansk@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Aristeu Rozanski <arozansk@redhat.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, cgroups@vger.kernel.org

One of the largest chunks of log messages in a OOM is from dump_stack() and in
some cases it isn't even necessary to figure out what's going on. In
systems with multiple tenants/containers with limited resources each
OOMs can be way more frequent and being able to reduce the amount of log
output for each situation is useful.

This patch adds a sysctl to allow disabling dump_stack() during an OOM while
keeping the default to behave the same way it behaves today.

Cc: Greg Thelen <gthelen@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org
Signed-off-by: Aristeu Rozanski <arozansk@redhat.com>
---
 include/linux/oom.h | 1 +
 kernel/sysctl.c     | 7 +++++++
 mm/oom_kill.c       | 4 +++-
 3 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 03e6257..bdd03e5 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -115,6 +115,7 @@ static inline bool task_will_free_mem(struct task_struct *task)
 
 /* sysctls */
 extern int sysctl_oom_dump_tasks;
+extern int sysctl_oom_dump_stack;
 extern int sysctl_oom_kill_allocating_task;
 extern int sysctl_panic_on_oom;
 #endif /* _INCLUDE_LINUX_OOM_H */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index e69201d..c812523 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1176,6 +1176,13 @@ static struct ctl_table vm_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
+		.procname	= "oom_dump_stack",
+		.data		= &sysctl_oom_dump_stack,
+		.maxlen		= sizeof(sysctl_oom_dump_stack),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
 		.procname	= "overcommit_ratio",
 		.data		= &sysctl_overcommit_ratio,
 		.maxlen		= sizeof(sysctl_overcommit_ratio),
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 1ecc0bc..bdbf83b 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -42,6 +42,7 @@
 int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks = 1;
+int sysctl_oom_dump_stack = 1;
 
 DEFINE_MUTEX(oom_lock);
 
@@ -384,7 +385,8 @@ static void dump_header(struct oom_control *oc, struct task_struct *p,
 		current->signal->oom_score_adj);
 	cpuset_print_task_mems_allowed(current);
 	task_unlock(current);
-	dump_stack();
+	if (sysctl_oom_dump_stack)
+		dump_stack();
 	if (memcg)
 		mem_cgroup_print_oom_info(memcg, p);
 	else
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
