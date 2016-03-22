Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 49E9B6B0261
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 07:01:10 -0400 (EDT)
Received: by mail-wm0-f41.google.com with SMTP id l68so146655611wml.0
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 04:01:10 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id ew3si29076071wjd.140.2016.03.22.04.01.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Mar 2016 04:01:06 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id p65so29046320wmp.1
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 04:01:06 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 5/9] mm, oom_reaper: implement OOM victims queuing
Date: Tue, 22 Mar 2016 12:00:22 +0100
Message-Id: <1458644426-22973-6-git-send-email-mhocko@kernel.org>
In-Reply-To: <1458644426-22973-1-git-send-email-mhocko@kernel.org>
References: <1458644426-22973-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>

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
index 9cf5731472fe..bc5867296f7b 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1838,6 +1838,9 @@ struct task_struct {
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
index e627ce235e38..8e0bd279135f 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -416,8 +416,10 @@ bool oom_killer_disabled __read_mostly;
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
@@ -523,12 +525,20 @@ static void oom_reap_task(struct task_struct *tsk)
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
@@ -536,23 +546,15 @@ static int oom_reaper(void *unused)
 
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
