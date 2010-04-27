Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C9DF46B01F3
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 18:59:02 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [10.3.21.3])
	by smtp-out.google.com with ESMTP id o3RMwvhC014533
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 15:58:57 -0700
Received: from pzk1 (pzk1.prod.google.com [10.243.19.129])
	by hpaq3.eem.corp.google.com with ESMTP id o3RMwrFq005121
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 15:58:56 -0700
Received: by pzk1 with SMTP id 1so4333289pzk.8
        for <linux-mm@kvack.org>; Tue, 27 Apr 2010 15:58:53 -0700 (PDT)
Date: Tue, 27 Apr 2010 15:58:41 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] oom: reintroduce and deprecate
 oom_kill_allocating_task
In-Reply-To: <alpine.DEB.2.00.1004211502430.25558@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1004271557590.19364@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1004061426420.28700@chino.kir.corp.google.com> <20100407092050.48c8fc3d.kamezawa.hiroyu@jp.fujitsu.com> <20100407205418.FB90.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1004081036520.25592@chino.kir.corp.google.com>
 <20100421121758.af52f6e0.akpm@linux-foundation.org> <alpine.DEB.2.00.1004211502430.25558@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, anfei <anfei.zhou@gmail.com>, nishimura@mxp.nes.nec.co.jp, Balbir Singh <balbir@linux.vnet.ibm.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

There's a concern that removing /proc/sys/vm/oom_kill_allocating_task
will unnecessarily break the userspace API as the result of the oom
killer rewrite.

This patch reintroduces the sysctl and deprecates it by adding an entry
to Documentation/feature-removal-schedule.txt with a suggested removal
date of December 2011 and emitting a warning the first time it is written
including the writing task's name and pid.

/proc/sys/vm/oom_kill_allocating task mirrors the value of
/proc/sys/vm/oom_kill_quick.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/feature-removal-schedule.txt |   19 +++++++++++++++++++
 include/linux/oom.h                        |    2 ++
 kernel/sysctl.c                            |    7 +++++++
 mm/oom_kill.c                              |   14 ++++++++++++++
 4 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -204,6 +204,25 @@ Who:	David Rientjes <rientjes@google.com>
 
 ---------------------------
 
+What:	/proc/sys/vm/oom_kill_allocating_task
+When:	December 2011
+Why:	/proc/sys/vm/oom_kill_allocating_task is equivalent to
+	/proc/sys/vm/oom_kill_quick.  The two sysctls will mirror each other's
+	value when set.
+
+	Existing users of /proc/sys/vm/oom_kill_allocating_task should simply
+	write a non-zero value to /proc/sys/vm/oom_kill_quick.  This will also
+	suppress a costly tasklist scan when dumping VM information for all
+	oom kill candidates.
+
+	A warning will be emitted to the kernel log if an application uses this
+	deprecated interface.  After it is printed once, future warning will be
+	suppressed until the kernel is rebooted.
+
+Who:	David Rientjes <rientjes@google.com>
+
+---------------------------
+
 What:	remove EXPORT_SYMBOL(kernel_thread)
 When:	August 2006
 Files:	arch/*/kernel/*_ksyms.c
diff --git a/include/linux/oom.h b/include/linux/oom.h
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -67,5 +67,7 @@ extern int sysctl_panic_on_oom;
 extern int sysctl_oom_forkbomb_thres;
 extern int sysctl_oom_kill_quick;
 
+extern int oom_kill_allocating_task_handler(struct ctl_table *table, int write,
+			void __user *buffer, size_t *lenp, loff_t *ppos);
 #endif /* __KERNEL__*/
 #endif /* _INCLUDE_LINUX_OOM_H */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -983,6 +983,13 @@ static struct ctl_table vm_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
+		.procname	= "oom_kill_allocating_task",
+		.data		= &sysctl_oom_kill_quick,
+		.maxlen		= sizeof(sysctl_oom_kill_quick),
+		.mode		= 0644,
+		.proc_handler	= oom_kill_allocating_task_handler,
+	},
+	{
 		.procname	= "oom_forkbomb_thres",
 		.data		= &sysctl_oom_forkbomb_thres,
 		.maxlen		= sizeof(sysctl_oom_forkbomb_thres),
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -37,6 +37,20 @@ int sysctl_oom_forkbomb_thres = DEFAULT_OOM_FORKBOMB_THRES;
 int sysctl_oom_kill_quick;
 static DEFINE_SPINLOCK(zone_scan_lock);
 
+int oom_kill_allocating_task_handler(struct ctl_table *table, int write,
+			void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	int ret;
+
+	ret = proc_dointvec(table, write, buffer, lenp, ppos);
+	if (!ret && write)
+		printk_once(KERN_WARNING "%s (%d): "
+			"/proc/sys/vm/oom_kill_allocating_task is deprecated, "
+			"please use /proc/sys/vm/oom_kill_quick instead.\n",
+			current->comm, task_pid_nr(current));
+	return ret;
+}
+
 /*
  * Do all threads of the target process overlap our allowed nodes?
  * @tsk: task struct of which task to consider

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
