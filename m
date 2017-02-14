Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 35C436B03A5
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 11:09:50 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id j90so57193297lfi.3
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 08:09:50 -0800 (PST)
Received: from SELDSEGREL01.sonyericsson.com (seldsegrel01.sonyericsson.com. [37.139.156.29])
        by mx.google.com with ESMTPS id 41si450660lfs.171.2017.02.14.08.09.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 08:09:48 -0800 (PST)
From: <peter.enderborg@sonymobile.com>
Subject: [PATCH 2/3 staging-next] oom: Add notification for oom_score_adj
Date: Tue, 14 Feb 2017 17:09:31 +0100
Message-ID: <20170214160932.4988-2-peter.enderborg@sonymobile.com>
In-Reply-To: <20170214160932.4988-1-peter.enderborg@sonymobile.com>
References: <20170214160932.4988-1-peter.enderborg@sonymobile.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: devel@driverdev.osuosl.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, arve@android.com, riandrews@android.com, torvalds@linux-foundation.org, linux-mm@kvack.org
Cc: Peter Enderborg <peter.enderborg@sonymobile.com>

From: Peter Enderborg <peter.enderborg@sonymobile.com>

This adds subscribtion for changes in oom_score_adj, this
value is important to android systems. For task that uses
oom_score_adj they read the task list. This can be long
and need rcu locks and has a impact on the system. Let
the user track the changes based on oom_score_adj changes
and keep them in their own context so they do their actions
with minimal system impact.

Signed-off-by: Peter Enderborg <peter.enderborg@sonymobile.com>
---
 fs/proc/base.c                     | 13 +++++++
 include/linux/oom_score_notifier.h | 47 ++++++++++++++++++++++++
 kernel/Makefile                    |  1 +
 kernel/fork.c                      |  6 +++
 kernel/oom_score_notifier.c        | 75 ++++++++++++++++++++++++++++++++++++++
 mm/Kconfig                         |  9 +++++
 6 files changed, 151 insertions(+)
 create mode 100644 include/linux/oom_score_notifier.h
 create mode 100644 kernel/oom_score_notifier.c

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 87c9a9a..60c2d9b 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -87,6 +87,7 @@
 #include <linux/slab.h>
 #include <linux/flex_array.h>
 #include <linux/posix-timers.h>
+#include <linux/oom_score_notifier.h>
 #ifdef CONFIG_HARDWALL
 #include <asm/hardwall.h>
 #endif
@@ -1057,6 +1058,7 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
 	static DEFINE_MUTEX(oom_adj_mutex);
 	struct mm_struct *mm = NULL;
 	struct task_struct *task;
+	int old_oom_score_adj;
 	int err = 0;
 
 	task = get_proc_task(file_inode(file));
@@ -1102,9 +1104,20 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
 		}
 	}
 
+	old_oom_score_adj = task->signal->oom_score_adj;
 	task->signal->oom_score_adj = oom_adj;
 	if (!legacy && has_capability_noaudit(current, CAP_SYS_RESOURCE))
 		task->signal->oom_score_adj_min = (short)oom_adj;
+
+#ifdef CONFIG_OOM_SCORE_NOTIFIER
+	err = oom_score_notify_update(task, old_oom_score_adj);
+	if (err) {
+		/* rollback and error handle. */
+		task->signal->oom_score_adj = old_oom_score_adj;
+		goto err_unlock;
+	}
+#endif
+
 	trace_oom_score_adj_update(task);
 
 	if (mm) {
diff --git a/include/linux/oom_score_notifier.h b/include/linux/oom_score_notifier.h
new file mode 100644
index 0000000..c5cea47
--- /dev/null
+++ b/include/linux/oom_score_notifier.h
@@ -0,0 +1,47 @@
+/*
+ *  oom_score_notifier interface
+ *  Copyright (C) 2017 Sony Mobile Communications Inc.
+ *
+ *  Author: Peter Enderborg <peter.enderborg@sonymobile.com>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License version 2 as
+ *  published by the Free Software Foundation.
+ */
+
+#ifndef _LINUX_OOM_SCORE_NOTIFIER_H
+#define _LINUX_OOM_SCORE_NOTIFIER_H
+
+#ifdef CONFIG_OOM_SCORE_NOTIFIER
+
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/spinlock.h>
+
+enum osn_msg_type {
+	OSN_NEW,
+	OSN_FREE,
+	OSN_UPDATE
+};
+
+extern struct atomic_notifier_head oom_score_notifier;
+extern int oom_score_notifier_register(struct notifier_block *n);
+extern int oom_score_notifier_unregister(struct notifier_block *n);
+extern int oom_score_notify_free(struct task_struct *tsk);
+extern int oom_score_notify_new(struct task_struct *tsk);
+extern int oom_score_notify_update(struct task_struct *tsk, int old_score);
+
+struct oom_score_notifier_struct {
+	struct task_struct *tsk;
+	int old_score;
+};
+
+#else
+
+#define oom_score_notify_free(t)  do {} while (0)
+#define oom_score_notify_new(t) false
+#define oom_score_notify_update(t, s) do {} while (0)
+
+#endif /* CONFIG_OOM_SCORE_NOTIFIER */
+
+#endif /* _LINUX_OOM_SCORE_NOTIFIER_H */
diff --git a/kernel/Makefile b/kernel/Makefile
index 12c679f..747c66c 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -91,6 +91,7 @@ obj-$(CONFIG_SYSCTL) += utsname_sysctl.o
 obj-$(CONFIG_TASK_DELAY_ACCT) += delayacct.o
 obj-$(CONFIG_TASKSTATS) += taskstats.o tsacct.o
 obj-$(CONFIG_TRACEPOINTS) += tracepoint.o
+obj-$(CONFIG_OOM_SCORE_NOTIFIER) += oom_score_notifier.o
 obj-$(CONFIG_LATENCYTOP) += latencytop.o
 obj-$(CONFIG_ELFCORE) += elfcore.o
 obj-$(CONFIG_FUNCTION_TRACER) += trace/
diff --git a/kernel/fork.c b/kernel/fork.c
index 11c5c8a..f8a1a89 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -73,6 +73,7 @@
 #include <linux/signalfd.h>
 #include <linux/uprobes.h>
 #include <linux/aio.h>
+#include <linux/oom_score_notifier.h>
 #include <linux/compiler.h>
 #include <linux/sysctl.h>
 #include <linux/kcov.h>
@@ -391,6 +392,7 @@ void __put_task_struct(struct task_struct *tsk)
 	exit_creds(tsk);
 	delayacct_tsk_free(tsk);
 	put_signal_struct(tsk->signal);
+	oom_score_notify_free(tsk);
 
 	if (!profile_handoff_task(tsk))
 		free_task(tsk);
@@ -1790,6 +1792,10 @@ static __latent_entropy struct task_struct *copy_process(
 
 		init_task_pid(p, PIDTYPE_PID, pid);
 		if (thread_group_leader(p)) {
+			retval = oom_score_notify_new(p);
+			if (retval)
+				goto bad_fork_cancel_cgroup;
+
 			init_task_pid(p, PIDTYPE_PGID, task_pgrp(current));
 			init_task_pid(p, PIDTYPE_SID, task_session(current));
 
diff --git a/kernel/oom_score_notifier.c b/kernel/oom_score_notifier.c
new file mode 100644
index 0000000..6dd6d8e
--- /dev/null
+++ b/kernel/oom_score_notifier.c
@@ -0,0 +1,75 @@
+/*
+ *  oom_score_notifier interface
+ *  Copyright (C) 2017 Sony Mobile Communications Inc.
+ *
+ *  Author: Peter Enderborg <peter.enderborg@sonymobile.com>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License version 2 as
+ *  published by the Free Software Foundation.
+ */
+
+
+#include <linux/notifier.h>
+#include <linux/oom_score_notifier.h>
+
+#ifdef CONFIG_OOM_SCORE_NOTIFIER
+ATOMIC_NOTIFIER_HEAD(oom_score_notifier);
+
+int oom_score_notifier_register(struct notifier_block *n)
+{
+	return atomic_notifier_chain_register(&oom_score_notifier, n);
+}
+EXPORT_SYMBOL_GPL(oom_score_notifier_register);
+
+int oom_score_notifier_unregister(struct notifier_block *n)
+{
+	return atomic_notifier_chain_unregister(&oom_score_notifier, n);
+}
+EXPORT_SYMBOL_GPL(oom_score_notifier_unregister);
+
+int oom_score_notify_free(struct task_struct *tsk)
+{
+	struct oom_score_notifier_struct osns;
+
+	osns.tsk = tsk;
+	return notifier_to_errno(atomic_notifier_call_chain(
+		&oom_score_notifier, OSN_FREE, &osns));
+}
+EXPORT_SYMBOL_GPL(oom_score_notify_free);
+
+int oom_score_notify_new(struct task_struct *tsk)
+{
+	struct oom_score_notifier_struct osns;
+
+	osns.tsk = tsk;
+	return notifier_to_errno(atomic_notifier_call_chain(
+		&oom_score_notifier, OSN_NEW, &osns));
+}
+EXPORT_SYMBOL_GPL(oom_score_notify_new);
+
+int oom_score_notify_update(struct task_struct *tsk, int old_score)
+{
+	struct oom_score_notifier_struct osns;
+
+	osns.tsk = tsk;
+	osns.old_score = old_score;
+	return notifier_to_errno(atomic_notifier_call_chain(&oom_score_notifier,
+							    OSN_UPDATE, &osns));
+}
+EXPORT_SYMBOL_GPL(oom_score_notify_update);
+
+#else
+inline int oom_score_notifier_register(struct notifier_block *n) { return 0; };
+inline int oom_score_notifier_unregister(struct notifier_block *n)
+{
+	return 0;
+};
+inline int oom_score_notify_free(struct task_struct *tsk) { return 0; };
+inline int oom_score_notify_new(struct task_struct *tsk) { return 0; };
+inline int oom_score_notify_update(struct task_struct *tsk, int old_score)
+{
+	return 0;
+};
+
+#endif
diff --git a/mm/Kconfig b/mm/Kconfig
index 9b8fccb..fb2a5d2 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -327,6 +327,15 @@ config MMU_NOTIFIER
 	bool
 	select SRCU
 
+config OOM_SCORE_NOTIFIER
+	bool "OOM score notifier"
+	default n
+	help
+	  This create a notifier for process oom_score_adj status.
+	  It create events for new, updated or freed tasks and
+	  are used to build a mirrored task list in
+	  lowmemmorykiller.
+
 config KSM
 	bool "Enable KSM for page merging"
 	depends on MMU
-- 
2.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
