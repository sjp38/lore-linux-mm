Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f50.google.com (mail-qa0-f50.google.com [209.85.216.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6F5ED6B0039
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 12:59:19 -0500 (EST)
Received: by mail-qa0-f50.google.com with SMTP id cm18so926652qab.23
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 09:59:19 -0800 (PST)
Received: from mail-qa0-x22d.google.com (mail-qa0-x22d.google.com [2607:f8b0:400d:c00::22d])
        by mx.google.com with ESMTPS id fy9si3698546qab.69.2014.01.28.09.59.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jan 2014 09:59:18 -0800 (PST)
Received: by mail-qa0-f45.google.com with SMTP id ii20so933583qab.18
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 09:59:18 -0800 (PST)
From: William Roberts <bill.c.roberts@gmail.com>
Subject: [PATCH v6 3/3] audit: Audit proc cmdline value
Date: Tue, 28 Jan 2014 09:59:14 -0800
Message-Id: <1390931954-7874-3-git-send-email-wroberts@tresys.com>
In-Reply-To: <1390931954-7874-1-git-send-email-wroberts@tresys.com>
References: <1390931954-7874-1-git-send-email-wroberts@tresys.com>
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
type=SYSCALL msg=audit(1387828084.070:361): arch=c000003e syscall=82 success=yes exit=0 a0=4184bf a1=418547 a2=0 a3=0 items=0 ppid=1 pid=1329 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 ses=4294967295 tty=(none) comm="console-kit-dae" exe="/usr/sbin/console-kit-daemon" subj=system_u:system_r:consolekit_t:s0-s0:c0.c255 key=(null) cmdline="/usr/lib/dbus-1.0/dbus-daemon-launch-helper"

Example denial prior to patch (Android):
type=1300 msg=audit(248323.940:247): arch=40000028 syscall=54 per=840000 success=yes exit=0 a0=39 a1=540b a2=2 a3=750eecec items=0 ppid=224 pid=1858 auid=4294967295 uid=1002 gid=1002 euid=1002 suid=1002 fsuid=1002 egid=1002 sgid=1002 fsgid=1002 tty=(none) ses=4294967295 comm="bt_hc_worker" exe="/system/bin/app_process" subj=u:r:bluetooth:s0 key=(null)

After Patches (Android):
type=1300 msg=audit(248323.940:247): arch=40000028 syscall=54 per=840000 success=yes exit=0 a0=39 a1=540b a2=2 a3=750eecec items=0 ppid=224 pid=1858 auid=4294967295 uid=1002 gid=1002 euid=1002 suid=1002 fsuid=1002 egid=1002 sgid=1002 fsgid=1002 tty=(none) ses=4294967295 comm="bt_hc_worker" exe="/system/bin/app_process" subj=u:r:bluetooth:s0 key=(null) cmdline="com.android.bluetooth"

Signed-off-by: William Roberts <wroberts@tresys.com>
---
 kernel/audit.h   |    6 ++++++
 kernel/auditsc.c |   41 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 47 insertions(+)

diff --git a/kernel/audit.h b/kernel/audit.h
index 57cc64d..aae1b21 100644
--- a/kernel/audit.h
+++ b/kernel/audit.h
@@ -106,6 +106,11 @@ struct audit_names {
 	bool			should_free;
 };
 
+struct audit_cmdline {
+	int	len;	/* length of the cmdline field. */
+	char	*value;	/* the cmdline field */
+};
+
 /* The per-task audit context. */
 struct audit_context {
 	int		    dummy;	/* must be the first element */
@@ -202,6 +207,7 @@ struct audit_context {
 		} execve;
 	};
 	int fds[2];
+	struct audit_cmdline cmdline;
 
 #if AUDIT_DEBUG
 	int		    put_count;
diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index 10176cd..dc62c01 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -79,6 +79,9 @@
 /* no execve audit message should be longer than this (userspace limits) */
 #define MAX_EXECVE_AUDIT_LEN 7500
 
+/* max length to print of cmdline value during audit */
+#define MAX_CMDLINE_AUDIT_LEN 128
+
 /* number of audit rules */
 int audit_n_rules;
 
@@ -842,6 +845,13 @@ static inline struct audit_context *audit_get_context(struct task_struct *tsk,
 	return context;
 }
 
+static inline void audit_cmdline_free(struct audit_context *context)
+{
+	kfree(context->cmdline.value);
+	context->cmdline.value = NULL;
+	context->cmdline.len = 0;
+}
+
 static inline void audit_free_names(struct audit_context *context)
 {
 	struct audit_names *n, *next;
@@ -955,6 +965,7 @@ static inline void audit_free_context(struct audit_context *context)
 	audit_free_aux(context);
 	kfree(context->filterkey);
 	kfree(context->sockaddr);
+	audit_cmdline_free(context);
 	kfree(context);
 }
 
@@ -1271,6 +1282,35 @@ static void show_special(struct audit_context *context, int *call_panic)
 	audit_log_end(ab);
 }
 
+static void audit_log_cmdline(struct audit_buffer *ab, struct task_struct *tsk,
+			 struct audit_context *context)
+{
+	int res;
+	char *buf;
+	char *msg = "(null)";
+	int len = strlen(msg);
+
+	audit_log_format(ab, " cmdline=");
+
+	/* Not  cached */
+	if (!context->cmdline.value) {
+		buf = kmalloc(MAX_CMDLINE_AUDIT_LEN, GFP_KERNEL);
+		if (!buf)
+			goto out;
+		res = get_cmdline(tsk, buf, MAX_CMDLINE_AUDIT_LEN);
+		if (res == 0) {
+			kfree(buf);
+			goto out;
+		}
+		context->cmdline.value = buf;
+		context->cmdline.len = res;
+	}
+	msg = context->cmdline.value;
+	len = context->cmdline.len;
+out:
+	audit_log_n_untrustedstring(ab, msg, len);
+}
+
 static void audit_log_exit(struct audit_context *context, struct task_struct *tsk)
 {
 	int i, call_panic = 0;
@@ -1303,6 +1343,7 @@ static void audit_log_exit(struct audit_context *context, struct task_struct *ts
 
 	audit_log_task_info(ab, tsk);
 	audit_log_key(ab, context->filterkey);
+	audit_log_cmdline(ab, tsk, context);
 	audit_log_end(ab);
 
 	for (aux = context->aux; aux; aux = aux->next) {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
