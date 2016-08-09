Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 05C786B0253
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 10:56:00 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l4so24957680wml.0
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 07:55:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t73si3440803wme.10.2016.08.09.07.55.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 Aug 2016 07:55:58 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v10 01/11] kthread: Rename probe_kthread_data() to kthread_probe_data()
Date: Tue,  9 Aug 2016 16:55:35 +0200
Message-Id: <1470754545-17632-2-git-send-email-pmladek@suse.com>
In-Reply-To: <1470754545-17632-1-git-send-email-pmladek@suse.com>
References: <1470754545-17632-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

A good practice is to prefix the names of functions by the name
of the subsystem.

This patch fixes the name of probe_kthread_data(). The other wrong
functions names are part of the kthread worker API and will be
fixed separately.

Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Petr Mladek <pmladek@suse.com>
Acked-by: Tejun Heo <tj@kernel.org>
---
 include/linux/kthread.h | 2 +-
 kernel/kthread.c        | 4 ++--
 kernel/workqueue.c      | 2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index e691b6a23f72..c792ee1628d0 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -44,7 +44,7 @@ bool kthread_should_stop(void);
 bool kthread_should_park(void);
 bool kthread_freezable_should_stop(bool *was_frozen);
 void *kthread_data(struct task_struct *k);
-void *probe_kthread_data(struct task_struct *k);
+void *kthread_probe_data(struct task_struct *k);
 int kthread_park(struct task_struct *k);
 void kthread_unpark(struct task_struct *k);
 void kthread_parkme(void);
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 9ff173dca1ae..0bec14aa844e 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -138,7 +138,7 @@ void *kthread_data(struct task_struct *task)
 }
 
 /**
- * probe_kthread_data - speculative version of kthread_data()
+ * kthread_probe_data - speculative version of kthread_data()
  * @task: possible kthread task in question
  *
  * @task could be a kthread task.  Return the data value specified when it
@@ -146,7 +146,7 @@ void *kthread_data(struct task_struct *task)
  * inaccessible for any reason, %NULL is returned.  This function requires
  * that @task itself is safe to dereference.
  */
-void *probe_kthread_data(struct task_struct *task)
+void *kthread_probe_data(struct task_struct *task)
 {
 	struct kthread *kthread = to_kthread(task);
 	void *data = NULL;
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index ef071ca73fc3..c9ef3b9c1088 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -4249,7 +4249,7 @@ void print_worker_info(const char *log_lvl, struct task_struct *task)
 	 * This function is called without any synchronization and @task
 	 * could be in any state.  Be careful with dereferences.
 	 */
-	worker = probe_kthread_data(task);
+	worker = kthread_probe_data(task);
 
 	/*
 	 * Carefully copy the associated workqueue's workfn and name.  Keep
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
