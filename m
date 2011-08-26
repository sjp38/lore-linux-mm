Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 739CF6B016A
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 12:14:25 -0400 (EDT)
Date: Fri, 26 Aug 2011 12:14:22 -0400
From: Dave Jones <davej@redhat.com>
Subject: VM: add would_have_oomkilled sysctl
Message-ID: <20110826161422.GB30573@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org

At various times in the past, we've had reports where users have been
convinced that the oomkiller was too heavy handed. I added this sysctl
mostly as a knob for them to see that the kernel really doesn't do much better
without killing something.

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 5e3aa83..79a27b4 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -72,5 +72,6 @@ extern struct task_struct *find_lock_task_mm(struct task_struct *p);
 extern int sysctl_oom_dump_tasks;
 extern int sysctl_oom_kill_allocating_task;
 extern int sysctl_panic_on_oom;
+extern int sysctl_would_have_oomkilled;
 #endif /* __KERNEL__*/
 #endif /* _INCLUDE_LINUX_OOM_H */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 5abfa15..a0fed6d 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1000,6 +1000,13 @@ static struct ctl_table vm_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
+		.procname	= "would_have_oomkilled",
+		.data		= &sysctl_would_have_oomkilled,
+		.maxlen		= sizeof(sysctl_would_have_oomkilled),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
 		.procname	= "overcommit_ratio",
 		.data		= &sysctl_overcommit_ratio,
 		.maxlen		= sizeof(sysctl_overcommit_ratio),
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 7dcca55..281ac39 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -35,6 +35,7 @@
 int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks = 1;
+int sysctl_would_have_oomkilled;
 static DEFINE_SPINLOCK(zone_scan_lock);
 
 #ifdef CONFIG_NUMA
@@ -477,6 +478,13 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	}
 
 	task_lock(p);
+	if (sysctl_would_have_oomkilled) {
+		printk(KERN_ERR "%s: would have killed process %d (%s), but continuing instead...\n",
+			__func__, task_pid_nr(p), p->comm);
+		task_unlock(p);
+		return 0;
+	}
+
 	pr_err("%s: Kill process %d (%s) score %d or sacrifice child\n",
 		message, task_pid_nr(p), p->comm, points);
 	task_unlock(p);
-- 
1.7.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
