Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 1544F6B0038
	for <linux-mm@kvack.org>; Fri, 25 Jul 2014 10:48:49 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so5630393pdb.41
        for <linux-mm@kvack.org>; Fri, 25 Jul 2014 07:48:48 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id ol2si3835518pbb.61.2014.07.25.07.48.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Jul 2014 07:48:48 -0700 (PDT)
From: Chintan Pandya <cpandya@codeaurora.org>
Subject: [PATCH v2 1/2] timer: provide an api for deferrable timeout
Date: Fri, 25 Jul 2014 20:18:17 +0530
Message-Id: <1406299698-6357-1-git-send-email-cpandya@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, john.stultz@linaro.org, peterz@infradead.org, mingo@redhat.com, hughd@google.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chintan Pandya <cpandya@codeaurora.org>

schedule_timeout wakes up the CPU from IDLE state. For some
use cases it is not desirable, hence introduce a convenient
API (schedule_timeout_deferrable_interruptible) on similar
pattern which uses a deferrable timer.

Signed-off-by: Chintan Pandya <cpandya@codeaurora.org>
---

 This patch has been newly introduced in patch v2

 include/linux/sched.h |  2 ++
 kernel/time/timer.c   | 27 ++++++++++++++++++++++++---
 2 files changed, 26 insertions(+), 3 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 89f531e..10b154e 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -377,6 +377,8 @@ extern int in_sched_functions(unsigned long addr);
 #define	MAX_SCHEDULE_TIMEOUT	LONG_MAX
 extern signed long schedule_timeout(signed long timeout);
 extern signed long schedule_timeout_interruptible(signed long timeout);
+extern signed long
+schedule_timeout_deferrable_interruptible(signed long timeout);
 extern signed long schedule_timeout_killable(signed long timeout);
 extern signed long schedule_timeout_uninterruptible(signed long timeout);
 asmlinkage void schedule(void);
diff --git a/kernel/time/timer.c b/kernel/time/timer.c
index aca5dfe..e81a301 100644
--- a/kernel/time/timer.c
+++ b/kernel/time/timer.c
@@ -1432,7 +1432,7 @@ static void process_timeout(unsigned long __data)
 }
 
 /**
- * schedule_timeout - sleep until timeout
+ * __schedule_timeout - sleep until timeout
  * @timeout: timeout value in jiffies
  *
  * Make the current task sleep until @timeout jiffies have
@@ -1457,7 +1457,8 @@ static void process_timeout(unsigned long __data)
  *
  * In all cases the return value is guaranteed to be non-negative.
  */
-signed long __sched schedule_timeout(signed long timeout)
+static signed long
+__sched __schedule_timeout(signed long timeout, unsigned long flag)
 {
 	struct timer_list timer;
 	unsigned long expire;
@@ -1493,7 +1494,13 @@ signed long __sched schedule_timeout(signed long timeout)
 
 	expire = timeout + jiffies;
 
-	setup_timer_on_stack(&timer, process_timeout, (unsigned long)current);
+	if (flag & TIMER_DEFERRABLE)
+		setup_deferrable_timer_on_stack(&timer, process_timeout,
+						(unsigned long)current);
+	else
+		setup_timer_on_stack(&timer, process_timeout,
+				     (unsigned long)current);
+
 	__mod_timer(&timer, expire, false, TIMER_NOT_PINNED);
 	schedule();
 	del_singleshot_timer_sync(&timer);
@@ -1506,12 +1513,26 @@ signed long __sched schedule_timeout(signed long timeout)
  out:
 	return timeout < 0 ? 0 : timeout;
 }
+
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
