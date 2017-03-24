Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2FE936B0337
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 16:08:43 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z36so255631wrc.14
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 13:08:43 -0700 (PDT)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id p135si4482556wmb.139.2017.03.24.13.08.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 13:08:41 -0700 (PDT)
Received: by mail-wm0-x230.google.com with SMTP id t189so466708wmt.1
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 13:08:41 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH] fault-inject: support systematic fault injection
Date: Fri, 24 Mar 2017 21:08:37 +0100
Message-Id: <20170324200837.82451-1-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akinobu.mita@gmail.com, akpm@linux-foundation.org
Cc: syzkaller@googlegroups.com, Dmitry Vyukov <dvyukov@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Add /sys/kernel/debug/fail_once file that allows failing 0-th, 1-st, 2-nd
and so on calls systematically. Excerpt from the added documentation:

===
Write to this file of integer N makes N-th call in the current task fail
(N is 0-based). Read from this file returns a single char 'Y' or 'N'
that says if the fault setup with a previous write to this file was
injected or not, and disables the fault if it wasn't yet injected.
Note that this file enables all types of faults (slab, futex, etc).
This setting takes precedence over all other generic settings like
probability, interval, times, etc. But per-capability settings
(e.g. fail_futex/ignore-private) take precedence over it.
This feature is intended for systematic testing of faults in a single
system call. See an example below.
===

Why adding new setting:
1. Existing settings are global rather than per-task.
   So parallel testing is not possible.
2. attr->interval is close but it depends on attr->count
   which is non reset to 0, so interval does not work as expected.
3. Trying to model this with existing settings requires manipulations
   of all of probability, interval, times, space, task-filter and
   unexposed count and per-task make-it-fail files.
4. Existing settings are per-failure-type, and the set of failure
   types is potentially expanding.
5. make-it-fail can't be changed by unprivileged user and aggressive
   stress testing better be done from an unprivileged user.
   Similarly, this would require opening the debugfs files to the
   unprivileged user, as he would need to reopen at least times file
   (not possible to pre-open before dropping privs).

The proposed interface solves all of the above (see the example).

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

---

We want to integrate this into syzkaller fuzzer.
A prototype has found 10 bugs in kernel in first day of usage:
https://groups.google.com/forum/#!searchin/syzkaller/%22FAULT_INJECTION%22%7Csort:relevance
---
 Documentation/fault-injection/fault-injection.txt | 74 +++++++++++++++++++++++
 include/linux/sched.h                             |  1 +
 kernel/fork.c                                     |  4 ++
 lib/fault-inject.c                                | 49 +++++++++++++++
 4 files changed, 128 insertions(+)

diff --git a/Documentation/fault-injection/fault-injection.txt b/Documentation/fault-injection/fault-injection.txt
index 415484f3d59a..593ad33c76c2 100644
--- a/Documentation/fault-injection/fault-injection.txt
+++ b/Documentation/fault-injection/fault-injection.txt
@@ -99,6 +99,20 @@ configuration of fault-injection capabilities.
 	for a caller within [require-start,require-end) OR
 	[reject-start,reject-end).
 
+- /sys/kernel/debug/fail_once:
+
+	Write to this file of integer N makes N-th call in the current task fail
+	(N is 0-based). Read from this file returns a single char 'Y' or 'N'
+	that says if the fault setup with a previous write to this file was
+	injected or not, and disables the fault if it wasn't yet injected.
+	Note that this file enables all types of faults (slab, futex, etc).
+	This setting takes precedence over all other generic settings like
+	probability, interval, times, etc. But per-capability settings
+	(e.g. fail_futex/ignore-private) take precedence over it.
+
+	This feature is intended for systematic testing of faults in a single
+	system call. See an example below.
+
 - /sys/kernel/debug/fail_page_alloc/ignore-gfp-highmem:
 
 	Format: { 'Y' | 'N' }
@@ -278,3 +292,63 @@ allocation failure.
 	# env FAILCMD_TYPE=fail_page_alloc \
 		./tools/testing/fault-injection/failcmd.sh --times=100 \
                 -- make -C tools/testing/selftests/ run_tests
+
+Systematic faults using fail_once
+---------------------------------
+
+The following code systematically faults 0-th, 1-st, 2-nd and so on
+capabilities in the socketpair() system call.
+
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <sys/socket.h>
+#include <fcntl.h>
+#include <unistd.h>
+#include <string.h>
+#include <stdlib.h>
+#include <stdio.h>
+#include <errno.h>
+
+int main()
+{
+	int i, err, res, once, fds[2];
+	char buf[16];
+
+	system("echo N > /sys/kernel/debug/failslab/ignore-gfp-wait");
+	once = open("/sys/kernel/debug/fail_once", O_RDWR);
+	for (i = 0;; i++) {
+		sprintf(buf, "%d", i);
+		write(once, buf, strlen(buf));
+		res = socketpair(AF_LOCAL, SOCK_STREAM, 0, fds);
+		err = errno;
+		read(once, buf, 1);
+		if (res == 0) {
+			close(fds[0]);
+			close(fds[1]);
+		}
+		printf("%d-th fault %c: res=%d/%d\n", i, buf[0], res, err);
+		if (buf[0] != 'Y')
+			break;
+	}
+	return 0;
+}
+
+An example output:
+
+0-th fault Y: res=-1/23
+1-th fault Y: res=-1/23
+2-th fault Y: res=-1/23
+3-th fault Y: res=-1/12
+4-th fault Y: res=-1/12
+5-th fault Y: res=-1/23
+6-th fault Y: res=-1/23
+7-th fault Y: res=-1/23
+8-th fault Y: res=-1/12
+9-th fault Y: res=-1/12
+10-th fault Y: res=-1/12
+11-th fault Y: res=-1/12
+12-th fault Y: res=-1/12
+13-th fault Y: res=-1/12
+14-th fault Y: res=-1/12
+15-th fault Y: res=-1/12
+16-th fault N: res=0/12
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 543e0ea82684..7b50221fea51 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1897,6 +1897,7 @@ struct task_struct {
 #endif
 #ifdef CONFIG_FAULT_INJECTION
 	int make_it_fail;
+	int fail_nth;
 #endif
 	/*
 	 * when (nr_dirtied >= nr_dirtied_pause), it's time to call
diff --git a/kernel/fork.c b/kernel/fork.c
index 61284d8122fa..869c97a0a930 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -545,6 +545,10 @@ static struct task_struct *dup_task_struct(struct task_struct *orig, int node)
 
 	kcov_task_init(tsk);
 
+#ifdef CONFIG_FAULT_INJECTION
+	tsk->fail_nth = 0;
+#endif
+
 	return tsk;
 
 free_stack:
diff --git a/lib/fault-inject.c b/lib/fault-inject.c
index 6a823a53e357..7e94124ed795 100644
--- a/lib/fault-inject.c
+++ b/lib/fault-inject.c
@@ -9,6 +9,7 @@
 #include <linux/interrupt.h>
 #include <linux/stacktrace.h>
 #include <linux/fault-inject.h>
+#include <linux/uaccess.h>
 
 /*
  * setup_fault_attr() is a helper function for various __setup handlers, so it
@@ -107,6 +108,12 @@ static inline bool fail_stacktrace(struct fault_attr *attr)
 
 bool should_fail(struct fault_attr *attr, ssize_t size)
 {
+	if (in_task() && current->fail_nth) {
+		if (--current->fail_nth == 0)
+			goto fail;
+		return false;
+	}
+
 	/* No need to check any other properties if the probability is 0 */
 	if (attr->probability == 0)
 		return false;
@@ -134,6 +141,7 @@ bool should_fail(struct fault_attr *attr, ssize_t size)
 	if (!fail_stacktrace(attr))
 		return false;
 
+fail:
 	fail_dump(attr);
 
 	if (atomic_read(&attr->times) != -1)
@@ -243,4 +251,45 @@ struct dentry *fault_create_debugfs_attr(const char *name,
 }
 EXPORT_SYMBOL_GPL(fault_create_debugfs_attr);
 
+static ssize_t once_write(struct file *file, const char __user *buf, size_t len,
+			  loff_t *offset)
+{
+	int err, n;
+
+	err = kstrtoint_from_user(buf, len, 10, &n);
+	if (err)
+		return err;
+	if (n < 0 || n == INT_MAX)
+		return -EINVAL;
+	current->fail_nth = n + 1;
+	return len;
+}
+
+static ssize_t once_read(struct file *file, char __user *buf, size_t len,
+			 loff_t *offset)
+{
+	int err;
+
+	if (len < 1)
+		return -EINVAL;
+	err = put_user((char)(current->fail_nth ? 'N' : 'Y'), buf);
+	if (err)
+		return err;
+	current->fail_nth = 0;
+	return 1;
+}
+
+static const struct file_operations once_fops = {
+	.write = once_write,
+	.read = once_read,
+};
+
+static int __init init_fault(void)
+{
+	if (!debugfs_create_file("fail_once", 0600, NULL, NULL, &once_fops))
+		return -ENOMEM;
+	return 0;
+}
+late_initcall(init_fault);
+
 #endif /* CONFIG_FAULT_INJECTION_DEBUG_FS */
-- 
2.12.1.578.ge9c3154ca4-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
