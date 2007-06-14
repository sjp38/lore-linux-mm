Received: from mail.bzzt.net (vhe-520116.sshn.net [195.169.225.32])
 by hermes.uci.kun.nl (PMDF V6.2-X17 #30689)
 with ESMTP id <0JJN0093SA50MH@hermes.uci.kun.nl> for linux-mm@kvack.org; Thu,
 14 Jun 2007 23:24:36 +0200 (MEST)
Received: from localhost ([127.0.0.1] ident=arnouten)
	by mail.bzzt.net with esmtp (Exim 3.36 #1 (Debian))
	id 1Hywmo-0001Bl-00	for <linux-mm@kvack.org>; Thu, 14 Jun 2007 23:23:23 +0200
Date: Thu, 14 Jun 2007 23:23:22 +0200
From: Arnout Engelen <arnouten@bzzt.net>
Subject: [PATCH] More informative logging for OOM-killer
Message-id: <4671B1CA.8070908@bzzt.net>
MIME-version: 1.0
Content-type: multipart/mixed; boundary=------------030304040009050502070704
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------030304040009050502070704
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

On a number of occasions I encountered machines which suffered from
occasional OOM's, but tracking down what caused them was tricky because
the OOM-killer only reported the process name of the process it killed,
and this would be something non-conclusive like 'java' or 'python'.

I figured it'd be useful to report not only the process name, but also
the parameters/commandline it had been started with.

The (text/plain) attached patch is a first shot at this. I'm not much of
a kernel hacker, so this is probably not quite commit-worthy material
yet - but I'm prepared to make changes if you guys can point me into the
right direction here, and I won't feel insulted if someone else takes
this over.


Let me know,

Arnout


--------------030304040009050502070704
Content-Type: text/x-patch;
 name="informative_oom_logging.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="informative_oom_logging.patch"

diff -aur linux-vanilla/Documentation/sysctl/vm.txt linux-hacked/Documentation/sysctl/vm.txt
--- linux-vanilla/Documentation/sysctl/vm.txt	2007-06-12 21:59:54.000000000 +0200
+++ linux-hacked/Documentation/sysctl/vm.txt	2007-05-08 18:14:09.000000000 +0200
@@ -31,6 +31,7 @@
 - min_unmapped_ratio
 - min_slab_ratio
 - panic_on_oom
+- informative_oom
 
 ==============================================================
 
@@ -205,3 +206,12 @@
 
 The default value is 0.
 
+=============================================================
+
+informative_oom
+
+This enables printing the commandline of processes killed by oom_killer. This
+will do an allocation at a point where the system is already low on memory, 
+but for most systems the improved diagnostics will be worth it.
+
+The default value is 1.
diff -aur linux-vanilla/include/linux/sysctl.h linux-hacked/include/linux/sysctl.h
--- linux-vanilla/include/linux/sysctl.h	2007-06-12 21:55:28.000000000 +0200
+++ linux-hacked/include/linux/sysctl.h	2007-05-08 18:23:22.000000000 +0200
@@ -202,6 +202,7 @@
 	VM_PANIC_ON_OOM=33,	/* panic at out-of-memory */
 	VM_VDSO_ENABLED=34,	/* map VDSO into new processes? */
 	VM_MIN_SLAB=35,		 /* Percent pages ignored by zone reclaim */
+	VM_INFORMATIVE_OOM=36,	/* show commandline of oom_killed process */
 };
 
 
diff -aur linux-vanilla/kernel/sysctl.c linux-hacked/kernel/sysctl.c
--- linux-vanilla/kernel/sysctl.c	2007-06-12 21:54:44.000000000 +0200
+++ linux-hacked/kernel/sysctl.c	2007-05-08 18:15:40.000000000 +0200
@@ -64,6 +64,7 @@
 extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
 extern int sysctl_panic_on_oom;
+extern int sysctl_informative_oom;
 extern int max_threads;
 extern int core_uses_pid;
 extern int suid_dumpable;
@@ -808,6 +809,14 @@
 		.proc_handler	= &proc_dointvec,
 	},
 	{
+		.ctl_name	= VM_INFORMATIVE_OOM,
+		.procname	= "informative_oom",
+		.data		= &sysctl_informative_oom,
+		.maxlen		= sizeof(sysctl_informative_oom),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+	{
 		.ctl_name	= VM_OVERCOMMIT_RATIO,
 		.procname	= "overcommit_ratio",
 		.data		= &sysctl_overcommit_ratio,
diff -aur linux-vanilla/mm/oom_kill.c linux-hacked/mm/oom_kill.c
--- linux-vanilla/mm/oom_kill.c	2007-05-05 01:05:49.000000000 +0200
+++ linux-hacked/mm/oom_kill.c	2007-06-12 22:25:03.000000000 +0200
@@ -26,6 +26,7 @@
 #include <linux/notifier.h>
 
 int sysctl_panic_on_oom;
+int sysctl_informative_oom = 1;
 /* #define DEBUG */
 
 /**
@@ -266,6 +267,49 @@
 	return chosen;
 }
 
+/*
+ * Get the commandline with which this process was invoked
+ *
+ * TODO: what assumptions can we make about buffer?
+ */
+int mm_pid_cmdline(struct task_struct *task, char * buffer)
+{
+	int res = 0;
+	unsigned int len;
+	struct mm_struct *mm = get_task_mm(task);
+	if (!mm)
+		goto out;
+	if (!mm->arg_end)
+		goto out_mm;	/* Shh! No looking before we're done */
+
+ 	len = mm->arg_end - mm->arg_start;
+ 
+	if (len > PAGE_SIZE)
+		len = PAGE_SIZE;
+ 
+	res = access_process_vm(task, mm->arg_start, buffer, len, 0);
+
+	// If the nul at the end of args has been overwritten, then
+	// assume application is using setproctitle(3).
+	if (res > 0 && buffer[res-1] != '\0' && len < PAGE_SIZE) {
+		len = strnlen(buffer, res);
+		if (len < res) {
+		    res = len;
+		} else {
+			len = mm->env_end - mm->env_start;
+			if (len > PAGE_SIZE - res)
+				len = PAGE_SIZE - res;
+			res += access_process_vm(task, mm->env_start, buffer+res, len, 0);
+			res = strnlen(buffer, res);
+		}
+	}
+out_mm:
+	mmput(mm);
+out:
+	return res;
+}
+
+
 /**
  * Send SIGKILL to the selected  process irrespective of  CAP_SYS_RAW_IO
  * flag though it's unlikely that  we select a process with CAP_SYS_RAW_IO
@@ -286,7 +330,17 @@
 	}
 
 	if (verbose)
+	{
 		printk(KERN_ERR "Killed process %d (%s)\n", p->pid, p->comm);
+		if (sysctl_informative_oom)
+		{
+			// TODO is this a proper upper bound for the
+			// length of a commandline?
+			char buffer[PAGE_SIZE / sizeof(char)];
+			mm_pid_cmdline(p, buffer);
+			printk(KERN_ERR "Invoked as: %s\n", buffer);
+		}
+	}
 
 	/*
 	 * We give our sacrificial lamb high priority and access to


--------------030304040009050502070704--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
