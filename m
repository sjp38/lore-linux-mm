Received: from m7.gw.fujitsu.co.jp ([10.0.50.77])
        by fgwmail6.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k3B5RHAH032251 for <linux-mm@kvack.org>; Tue, 11 Apr 2006 14:27:17 +0900
        (envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s11.gw.fujitsu.co.jp by m7.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k3B5RFoI004479 for <linux-mm@kvack.org>; Tue, 11 Apr 2006 14:27:16 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s11.gw.fujitsu.co.jp (s11 [127.0.0.1])
	by s11.gw.fujitsu.co.jp (Postfix) with ESMTP id 43D7DDC0AB
	for <linux-mm@kvack.org>; Tue, 11 Apr 2006 14:27:16 +0900 (JST)
Received: from fjm504.ms.jp.fujitsu.com (fjm504.ms.jp.fujitsu.com [10.56.99.80])
	by s11.gw.fujitsu.co.jp (Postfix) with ESMTP id AD1B2DC089
	for <linux-mm@kvack.org>; Tue, 11 Apr 2006 14:27:15 +0900 (JST)
Received: from fjmscan502.ms.jp.fujitsu.com (fjmscan502.ms.jp.fujitsu.com [10.56.99.142])by fjm504.ms.jp.fujitsu.com with ESMTP id k3B5QpRE027308
	for <linux-mm@kvack.org>; Tue, 11 Apr 2006 14:26:51 +0900
Received: from unknown ([10.124.100.187])
	by fjmscan502.ms.jp.fujitsu.com (8.13.1/8.12.11) with SMTP id k3B5Qn2D031967
	for <linux-mm@kvack.org>; Tue, 11 Apr 2006 14:26:51 +0900
Date: Tue, 11 Apr 2006 14:29:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC] [PATCH] support for oom_die
Message-Id: <20060411142909.1899c4c4.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

This patch adds a feature to panic at OOM, oom_die.

I think 2.6 kernel is very robust against OOM situation but sometimes
it occurs. Yes, oom_kill works enough and exit oom situation, *when*
the system wants to survive.

First, crash-dump is merged (to -mm?). So panic at OOM can be a method to
preserve *all* information at OOM. Current OOM killer kills process by SIGKILL,
this doesn't preserve any information about OOM situation. Just message log tell
something and we have to imagine what happend.

Second, considering clustering system, it has a failover node replacement 
system. Because oom_killer tends to kill system slowly, one by one, to detect 
it and do failover(or not) at OOM is tend to be difficult. (as far as I know)
Panic at OOM is useful in such system because failover system can replace
the node immediately.

I'm sorry if this kind of discussion has been setteled in past.

-Kame
==
This patch adds oom_die sysctl under sys.vm.

When oom_die==1, system panic at out_of_memory istead of kill some
process. In some environment, I think panic is more useful than kill.

for example)
(1) When a host is a node of a clustering system and panics at OOM,
    Failover system can detect panic by out-of-memory easily and immediately.
    It can replace the node with another node in fast way.

(2) When the system equips crash dump, out-of-memory will cause crash
    dump. While oom_killer cannot preserve enough information to detect
    the reason of OOM, crash dump can preserve *all* information.
    We can chase it.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: linux-2.6.17-rc1-mm2/kernel/sysctl.c
===================================================================
--- linux-2.6.17-rc1-mm2.orig/kernel/sysctl.c
+++ linux-2.6.17-rc1-mm2/kernel/sysctl.c
@@ -60,6 +60,7 @@ extern int proc_nr_files(ctl_table *tabl
 extern int C_A_D;
 extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
+extern int sysctl_oom_die;
 extern int max_threads;
 extern int sysrq_enabled;
 extern int core_uses_pid;
@@ -718,6 +719,14 @@ static ctl_table vm_table[] = {
 		.proc_handler	= &proc_dointvec,
 	},
 	{
+		.ctl_name	= VM_OOM_DIE,
+		.procname	= "oom_die",
+		.data		= &sysctl_oom_die,
+		.maxlen		= sizeof(sysctl_oom_die),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+	{
 		.ctl_name	= VM_OVERCOMMIT_RATIO,
 		.procname	= "overcommit_ratio",
 		.data		= &sysctl_overcommit_ratio,
Index: linux-2.6.17-rc1-mm2/mm/oom_kill.c
===================================================================
--- linux-2.6.17-rc1-mm2.orig/mm/oom_kill.c
+++ linux-2.6.17-rc1-mm2/mm/oom_kill.c
@@ -23,7 +23,7 @@
 #include <linux/cpuset.h>
 
 /* #define DEBUG */
-
+int sysctl_oom_die = 0;
 /**
  * oom_badness - calculate a numeric value for how bad this task has been
  * @p: task struct of which task we should calculate
@@ -290,6 +290,12 @@ static struct mm_struct *oom_kill_proces
 	return oom_kill_task(p, message);
 }
 
+
+static void oom_die(void)
+{
+	panic("Panic: out of memory: oom_die is selected.");
+}
+
 /**
  * oom_kill - kill the "best" process when we run out of memory
  *
@@ -331,6 +337,8 @@ void out_of_memory(struct zonelist *zone
 
 	case CONSTRAINT_NONE:
 retry:
+		if (sysctl_oom_die)
+			oom_die();
 		/*
 		 * Rambo mode: Shoot down a process and hope it solves whatever
 		 * issues we may have.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
