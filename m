Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 533CD6B0253
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 07:00:58 -0400 (EDT)
Received: by mail-wm0-f44.google.com with SMTP id p65so157747927wmp.0
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 04:00:58 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id y67si19731880wmg.88.2016.03.22.04.00.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Mar 2016 04:00:57 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id r129so16728461wmr.2
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 04:00:57 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/9] sched: add schedule_timeout_idle()
Date: Tue, 22 Mar 2016 12:00:18 +0100
Message-Id: <1458644426-22973-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1458644426-22973-1-git-send-email-mhocko@kernel.org>
References: <1458644426-22973-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>

From: Andrew Morton <akpm@linux-foundation.org>

This will be needed in the patch "mm, oom: introduce oom reaper".

Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/sched.h |  1 +
 kernel/time/timer.c   | 11 +++++++++++
 2 files changed, 12 insertions(+)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 084ed9fba620..9cf5731472fe 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -425,6 +425,7 @@ extern signed long schedule_timeout(signed long timeout);
 extern signed long schedule_timeout_interruptible(signed long timeout);
 extern signed long schedule_timeout_killable(signed long timeout);
 extern signed long schedule_timeout_uninterruptible(signed long timeout);
+extern signed long schedule_timeout_idle(signed long timeout);
 asmlinkage void schedule(void);
 extern void schedule_preempt_disabled(void);
 
diff --git a/kernel/time/timer.c b/kernel/time/timer.c
index d1798fa0c743..73164c3aa56b 100644
--- a/kernel/time/timer.c
+++ b/kernel/time/timer.c
@@ -1566,6 +1566,17 @@ signed long __sched schedule_timeout_uninterruptible(signed long timeout)
 }
 EXPORT_SYMBOL(schedule_timeout_uninterruptible);
 
+/*
+ * Like schedule_timeout_uninterruptible(), except this task will not contribute
+ * to load average.
+ */
+signed long __sched schedule_timeout_idle(signed long timeout)
+{
+	__set_current_state(TASK_IDLE);
+	return schedule_timeout(timeout);
+}
+EXPORT_SYMBOL(schedule_timeout_idle);
+
 #ifdef CONFIG_HOTPLUG_CPU
 static void migrate_timer_list(struct tvec_base *new_base, struct hlist_head *head)
 {
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
