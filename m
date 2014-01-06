Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id 4AFBF6B0037
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 10:30:52 -0500 (EST)
Received: by mail-qc0-f179.google.com with SMTP id i8so18007164qcq.10
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 07:30:52 -0800 (PST)
Received: from mail-qe0-x232.google.com (mail-qe0-x232.google.com [2607:f8b0:400d:c02::232])
        by mx.google.com with ESMTPS id c7si55011171qan.153.2014.01.06.07.30.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 06 Jan 2014 07:30:51 -0800 (PST)
Received: by mail-qe0-f50.google.com with SMTP id 1so18701162qec.9
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 07:30:51 -0800 (PST)
From: William Roberts <bill.c.roberts@gmail.com>
Subject: [RFC][PATCH 3/3] audit: Audit proc cmdline value
Date: Mon,  6 Jan 2014 07:30:30 -0800
Message-Id: <1389022230-24664-3-git-send-email-wroberts@tresys.com>
In-Reply-To: <1389022230-24664-1-git-send-email-wroberts@tresys.com>
References: <1389022230-24664-1-git-send-email-wroberts@tresys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-audit@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rgb@redhat.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, sds@tycho.nsa.gov
Cc: William Roberts <wroberts@tresys.com>

During an audit event, cache and print the value of the process's
cmdline value (proc/<pid>/cmdline). This is useful in situations
where processes are started via fork'd virtual machines where the
comm field is incorrect. Often times, setting the comm field still
is insufficient as the comm width is not very wide and most
virtual machine "package names" do not fit. Also, during execution,
many threads have their comm field set as well. By tying it back to
the global cmdline value for the process, audit records will be more
complete in systems with these properties. An example of where this
is useful and applicable is in the realm of Android. With Android,
their is no fork/exec for VM instances. The bare, preloaded Dalvik
VM listens for a fork and specialize request. When this request comes
in, the VM forks, and the loads the specific application (specializing).
This was done to take advantage of COW and to not require a load of
basic packages by the VM on very app spawn. When this spawn occurs,
the package name is set via setproctitle() and shows up in procfs.
Many of these package names are longer then 16 bytes, the historical
width of task->comm. Having the cmdline in the audit records will
couple the application back to the record directly. Also, on my
Debian development box, some audit records were more useful then
what was printed under comm.

The cached cmdline is tied to the life-cycle of the audit_context
structure and is built on demand.

Example denial prior to patch (Ubuntu):
CALL msg=audit(1387828084.070:361): arch=c000003e syscall=82 success=yes exit=0 a0=4184bf a1=418547 a2=0 a3=0 items=0 ppid=1 pid=1329 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 ses=4294967295 tty=(none) comm="console-kit-dae" exe="/usr/sbin/console-kit-daemon" subj=system_u:system_r:consolekit_t:s0-s0:c0.c255 key=(null)

After Patches (Ubuntu):
type=SYSCALL msg=audit(1387828084.070:361): arch=c000003e syscall=82 success=yes exit=0 a0=4184bf a1=418547 a2=0 a3=0 items=0 ppid=1 pid=1329 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 ses=4294967295 tty=(none) comm="console-kit-dae" exe="/usr/sbin/console-kit-daemon" subj=system_u:system_r:consolekit_t:s0-s0:c0.c255 cmdline="/usr/lib/dbus-1.0/dbus-daemon-launch-helper" key=(null)

Example denial prior to patch (Android):
type=1300 msg=audit(248323.940:247): arch=40000028 syscall=54 per=840000 success=yes exit=0 a0=39 a1=540b a2=2 a3=750eecec items=0 ppid=224 pid=1858 auid=4294967295 uid=1002 gid=1002 euid=1002 suid=1002 fsuid=1002 egid=1002 sgid=1002 fsgid=1002 tty=(none) ses=4294967295 comm="bt_hc_worker" exe="/system/bin/app_process" subj=u:r:bluetooth:s0 key=(null)

After Patches (Android):
type=1300 msg=audit(248323.940:247): arch=40000028 syscall=54 per=840000 success=yes exit=0 a0=39 a1=540b a2=2 a3=750eecec items=0 ppid=224 pid=1858 auid=4294967295 uid=1002 gid=1002 euid=1002 suid=1002 fsuid=1002 egid=1002 sgid=1002 fsgid=1002 tty=(none) ses=4294967295 comm="bt_hc_worker" exe="/system/bin/app_process" cmdline="com.android.bluetooth" subj=u:r:bluetooth:s0 key=(null)

Signed-off-by: William Roberts <wroberts@tresys.com>
---
 kernel/audit.h   |    1 +
 kernel/auditsc.c |   32 ++++++++++++++++++++++++++++++++
 2 files changed, 33 insertions(+)

diff --git a/kernel/audit.h b/kernel/audit.h
index b779642..bd6211f 100644
--- a/kernel/audit.h
+++ b/kernel/audit.h
@@ -202,6 +202,7 @@ struct audit_context {
 		} execve;
 	};
 	int fds[2];
+	char *cmdline;
 
 #if AUDIT_DEBUG
 	int		    put_count;
diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index 90594c9..a4c2003 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -842,6 +842,12 @@ static inline struct audit_context *audit_get_context(struct task_struct *tsk,
 	return context;
 }
 
+static inline void audit_cmdline_free(struct audit_context *context)
+{
+	kfree(context->cmdline);
+	context->cmdline = NULL;
+}
+
 static inline void audit_free_names(struct audit_context *context)
 {
 	struct audit_names *n, *next;
@@ -955,6 +961,7 @@ static inline void audit_free_context(struct audit_context *context)
 	audit_free_aux(context);
 	kfree(context->filterkey);
 	kfree(context->sockaddr);
+	audit_cmdline_free(context);
 	kfree(context);
 }
 
@@ -1271,6 +1278,30 @@ static void show_special(struct audit_context *context, int *call_panic)
 	audit_log_end(ab);
 }
 
+static void audit_log_cmdline(struct audit_buffer *ab, struct task_struct *tsk,
+			 struct audit_context *context)
+{
+	int res;
+	char *buf;
+	char *msg = "(null)";
+	audit_log_format(ab, " cmdline=");
+
+	/* Not  cached */
+	if (!context->cmdline) {
+		buf = kmalloc(PATH_MAX, GFP_KERNEL);
+		if (!buf)
+			goto out;
+		res = get_cmdline(tsk, buf, PATH_MAX);
+		/* Ensure NULL terminated */
+		if (buf[res-1] != '\0')
+			buf[res-1] = '\0';
+		context->cmdline = buf;
+	}
+	msg = context->cmdline;
+out:
+	audit_log_untrustedstring(ab, msg);
+}
+
 static void audit_log_exit(struct audit_context *context, struct task_struct *tsk)
 {
 	int i, call_panic = 0;
@@ -1302,6 +1333,7 @@ static void audit_log_exit(struct audit_context *context, struct task_struct *ts
 			 context->name_count);
 
 	audit_log_task_info(ab, tsk);
+	audit_log_cmdline(ab, tsk, context);
 	audit_log_key(ab, context->filterkey);
 	audit_log_end(ab);
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
