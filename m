Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id BDF2D6B0035
	for <linux-mm@kvack.org>; Wed, 20 Aug 2014 08:11:01 -0400 (EDT)
Received: by mail-ig0-f170.google.com with SMTP id h3so11046066igd.5
        for <linux-mm@kvack.org>; Wed, 20 Aug 2014 05:11:01 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id m4si2207024igx.47.2014.08.20.05.11.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Aug 2014 05:11:00 -0700 (PDT)
From: Chintan Pandya <cpandya@codeaurora.org>
Subject: [PATCH v4 1/2] timer: provide an api for deferrable timeout
Date: Wed, 20 Aug 2014 17:40:27 +0530
Message-Id: <1408536628-29379-1-git-send-email-cpandya@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, Chintan Pandya <cpandya@codeaurora.org>, Thomas Gleixner <tglx@linutronix.de>, John Stultz <john.stultz@linaro.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Hugh Dickins <hughd@google.com>

schedule_timeout wakes up the CPU from IDLE state. For some use cases it
is not desirable, hence introduce a convenient API
(schedule_timeout_deferrable_interruptible) on similar pattern which uses
a deferrable timer.

Signed-off-by: Chintan Pandya <cpandya@codeaurora.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: John Stultz <john.stultz@linaro.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Hugh Dickins <hughd@google.com>
---
Changes:

V3-->V4:
	- No change

V2-->V3:
	- Big comment moved from static function to exported function
	- Using __setup_timer_on_stack for better readability

V2:
	- this patch has been newly introduced in patch v2


 include/linux/sched.h |  2 ++
 kernel/time/timer.c   | 73 +++++++++++++++++++++++++++++++--------------------
 2 files changed, 47 insertions(+), 28 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 5c2c885..13fe361 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -376,6 +376,8 @@ extern int in_sched_functions(unsigned long addr);
 #define	MAX_SCHEDULE_TIMEOUT	LONG_MAX
 extern signed long schedule_timeout(signed long timeout);
 extern signed long schedule_timeout_interruptible(signed long timeout);
+extern signed long
+schedule_timeout_deferrable_interruptible(signed long timeout);
 extern signed long schedule_timeout_killable(signed long timeout);
 extern signed long schedule_timeout_uninterruptible(signed long timeout);
 asmlinkage void schedule(void);
diff --git a/kernel/time/timer.c b/kernel/time/timer.c
index aca5dfe..f4c4082 100644
--- a/kernel/time/timer.c
+++ b/kernel/time/timer.c
@@ -1431,33 +1431,8 @@ static void process_timeout(unsigned long __data)
 	wake_up_process((struct task_struct *)__data);
 }
 
-/**
- * schedule_timeout - sleep until timeout
- * @timeout: timeout value in jiffies
- *
- * Make the current task sleep until @timeout jiffies have
- * elapsed. The routine will return immediately unless
- * the current task state has been set (see set_current_state()).
- *
- * You can set the task state as follows -
- *
- * %TASK_UNINTERRUPTIBLE - at least @timeout jiffies are guaranteed to
- * pass before the routine returns. The routine will return 0
- *
- * %TASK_INTERRUPTIBLE - the routine may return early if a signal is
- * delivered to the current task. In this case the remaining time
- * in jiffies will be returned, or 0 if the timer expired in time
- *
- * The current task state is guaranteed to be TASK_RUNNING when this
- * routine returns.
- *
- * Specifying a @timeout value of %MAX_SCHEDULE_TIMEOUT will schedule
- * the CPU away without a bound on the timeout. In this case the return
- * value will be %MAX_SCHEDULE_TIMEOUT.
- *
- * In all cases the return value is guaranteed to be non-negative.
- */
-signed long __sched schedule_timeout(signed long timeout)
+static signed long
+__sched __schedule_timeout(signed long timeout, unsigned long flag)
 {
 	struct timer_list timer;
 	unsigned long expire;
@@ -1493,7 +1468,9 @@ signed long __sched schedule_timeout(signed long timeout)
 
 	expire = timeout + jiffies;
 
-	setup_timer_on_stack(&timer, process_timeout, (unsigned long)current);
+	__setup_timer_on_stack(&timer, process_timeout, (unsigned long)current,
+				flag);
+
 	__mod_timer(&timer, expire, false, TIMER_NOT_PINNED);
 	schedule();
 	del_singleshot_timer_sync(&timer);
@@ -1506,12 +1483,52 @@ signed long __sched schedule_timeout(signed long timeout)
  out:
 	return timeout < 0 ? 0 : timeout;
 }
+
+/**
+ * schedule_timeout - sleep until timeout
+ * @timeout: timeout value in jiffies
+ *
+ * Make the current task sleep until @timeout jiffies have
+ * elapsed. The routine will return immediately unless
+ * the current task state has been set (see set_current_state()).
+ *
+ * You can set the task state as follows -
+ *
+ * %TASK_UNINTERRUPTIBLE - at least @timeout jiffies are guaranteed to
+ * pass before the routine returns. The routine will return 0
+ *
+ * %TASK_INTERRUPTIBLE - the routine may return early if a signal is
+ * delivered to the current task. In this case the remaining time
+ * in jiffies will be returned, or 0 if the timer expired in time
+ *
+ * The current task state is guaranteed to be TASK_RUNNING when this
+ * routine returns.
+ *
+ * Specifying a @timeout value of %MAX_SCHEDULE_TIMEOUT will schedule
+ * the CPU away without a bound on the timeout. In this case the return
+ * value will be %MAX_SCHEDULE_TIMEOUT.
+ *
+ * In all cases the return value is guaranteed to be non-negative.
+ */
+signed long __sched schedule_timeout(signed long timeout)
+{
+	return __schedule_timeout(timeout, 0);
+}
 EXPORT_SYMBOL(schedule_timeout);
 
 /*
  * We can use __set_current_state() here because schedule_timeout() calls
  * schedule() unconditionally.
  */
+
+signed long
+__sched schedule_timeout_deferrable_interruptible(signed long timeout)
+{
+	__set_current_state(TASK_INTERRUPTIBLE);
+	return __schedule_timeout(timeout, TIMER_DEFERRABLE);
+}
+EXPORT_SYMBOL(schedule_timeout_deferrable_interruptible);
+
 signed long __sched schedule_timeout_interruptible(signed long timeout)
 {
 	__set_current_state(TASK_INTERRUPTIBLE);
-- 
Chintan Pandya

QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
