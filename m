Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 55CD3828E6
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 08:14:18 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id l66so163069642wml.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 05:14:18 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id f15si9922333wjs.71.2016.02.03.05.14.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 05:14:11 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id p63so7364277wmp.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 05:14:11 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 5/5] mm, oom_reaper: implement OOM victims queuing
Date: Wed,  3 Feb 2016 14:14:00 +0100
Message-Id: <1454505240-23446-6-git-send-email-mhocko@kernel.org>
In-Reply-To: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

wake_oom_reaper has allowed only 1 oom victim to be queued. The main
reason for that was the simplicity as other solutions would require
some way of queuing. The current approach is racy and that was deemed
sufficient as the oom_reaper is considered a best effort approach
to help with oom handling when the OOM victim cannot terminate in a
reasonable time. The race could lead to missing an oom victim which can
get stuck

out_of_memory
  wake_oom_reaper
    cmpxchg // OK
    			oom_reaper
			  oom_reap_task
			    __oom_reap_task
oom_victim terminates
			      atomic_inc_not_zero // fail
out_of_memory
  wake_oom_reaper
    cmpxchg // fails
			  task_to_reap = NULL

This race requires 2 OOM invocations in a short time period which is not
very likely but certainly not impossible. E.g. the original victim might
have not released a lot of memory for some reason.

The situation would improve considerably if wake_oom_reaper used a more
robust queuing. This is what this patch implements. This means adding
oom_reaper_list list_head into task_struct (eat a hole before embeded
thread_struct for that purpose) and a oom_reaper_lock spinlock for
queuing synchronization. wake_oom_reaper will then add the task on the
queue and oom_reaper will dequeue it.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/sched.h |  3 +++
 mm/oom_kill.c         | 36 +++++++++++++++++++-----------------
 2 files changed, 22 insertions(+), 17 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index a9cdd032b988..c25996c336de 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1814,6 +1814,9 @@ struct task_struct {
 	unsigned long	task_state_change;
 #endif
 	int pagefault_disabled;
+#ifdef CONFIG_MMU
+	struct list_head oom_reaper_list;
+#endif
 /* CPU-specific state of this task */
 	struct thread_struct thread;
 /*
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index b87acdca2a41..87d644c97ac9 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -417,8 +417,10 @@ bool oom_killer_disabled __read_mostly;
  * victim (if that is possible) to help the OOM killer to move on.
  */
 static struct task_struct *oom_reaper_th;
-static struct task_struct *task_to_reap;
 static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
+static LIST_HEAD(oom_reaper_list);
+static DEFINE_SPINLOCK(oom_reaper_lock);
+
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
 static bool __oom_reap_task(struct task_struct *tsk)
@@ -520,12 +522,20 @@ static void oom_reap_task(struct task_struct *tsk)
 static int oom_reaper(void *unused)
 {
 	while (true) {
-		struct task_struct *tsk;
+		struct task_struct *tsk = NULL;
 
 		wait_event_freezable(oom_reaper_wait,
-				     (tsk = READ_ONCE(task_to_reap)));
-		oom_reap_task(tsk);
-		WRITE_ONCE(task_to_reap, NULL);
+				     (!list_empty(&oom_reaper_list)));
+		spin_lock(&oom_reaper_lock);
+		if (!list_empty(&oom_reaper_list)) {
+			tsk = list_first_entry(&oom_reaper_list,
+					struct task_struct, oom_reaper_list);
+			list_del(&tsk->oom_reaper_list);
+		}
+		spin_unlock(&oom_reaper_lock);
+
+		if (tsk)
+			oom_reap_task(tsk);
 	}
 
 	return 0;
@@ -533,23 +543,15 @@ static int oom_reaper(void *unused)
 
 static void wake_oom_reaper(struct task_struct *tsk)
 {
-	struct task_struct *old_tsk;
-
 	if (!oom_reaper_th)
 		return;
 
 	get_task_struct(tsk);
 
-	/*
-	 * Make sure that only a single mm is ever queued for the reaper
-	 * because multiple are not necessary and the operation might be
-	 * disruptive so better reduce it to the bare minimum.
-	 */
-	old_tsk = cmpxchg(&task_to_reap, NULL, tsk);
-	if (!old_tsk)
-		wake_up(&oom_reaper_wait);
-	else
-		put_task_struct(tsk);
+	spin_lock(&oom_reaper_lock);
+	list_add(&tsk->oom_reaper_list, &oom_reaper_list);
+	spin_unlock(&oom_reaper_lock);
+	wake_up(&oom_reaper_wait);
 }
 
 static int __init oom_init(void)
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
