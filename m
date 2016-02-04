Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id C039C4403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 05:49:45 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id 65so41432317pfd.2
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 02:49:45 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id d1si15969642pas.96.2016.02.04.02.49.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 Feb 2016 02:49:44 -0800 (PST)
Subject: Re: [PATCH 5/5] mm, oom_reaper: implement OOM victims queuing
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
	<1454505240-23446-6-git-send-email-mhocko@kernel.org>
In-Reply-To: <1454505240-23446-6-git-send-email-mhocko@kernel.org>
Message-Id: <201602041949.BIG30715.QVFLFOOOHMtSFJ@I-love.SAKURA.ne.jp>
Date: Thu, 4 Feb 2016 19:49:29 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com

Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> wake_oom_reaper has allowed only 1 oom victim to be queued. The main
> reason for that was the simplicity as other solutions would require
> some way of queuing. The current approach is racy and that was deemed
> sufficient as the oom_reaper is considered a best effort approach
> to help with oom handling when the OOM victim cannot terminate in a
> reasonable time. The race could lead to missing an oom victim which can
> get stuck
> 
> out_of_memory
>   wake_oom_reaper
>     cmpxchg // OK
>     			oom_reaper
> 			  oom_reap_task
> 			    __oom_reap_task
> oom_victim terminates
> 			      atomic_inc_not_zero // fail
> out_of_memory
>   wake_oom_reaper
>     cmpxchg // fails
> 			  task_to_reap = NULL
> 
> This race requires 2 OOM invocations in a short time period which is not
> very likely but certainly not impossible. E.g. the original victim might
> have not released a lot of memory for some reason.
> 
> The situation would improve considerably if wake_oom_reaper used a more
> robust queuing. This is what this patch implements. This means adding
> oom_reaper_list list_head into task_struct (eat a hole before embeded
> thread_struct for that purpose) and a oom_reaper_lock spinlock for
> queuing synchronization. wake_oom_reaper will then add the task on the
> queue and oom_reaper will dequeue it.
> 

I think we want to rewrite this patch's description from a different point
of view.

As of "[PATCH 1/5] mm, oom: introduce oom reaper", we assumed that we try to
manage OOM livelock caused by system-wide OOM events using the OOM reaper.
Therefore, the OOM reaper had high scheduling priority and we considered side
effect of the OOM reaper as a reasonable constraint.

But as the discussion went by, we started to try to manage OOM livelock
caused by non system-wide OOM events (e.g. memcg OOM) using the OOM reaper.
Therefore, the OOM reaper now has normal scheduling priority. For non
system-wide OOM events, side effect of the OOM reaper might not be a
reasonable constraint. Some administrator might expect that the OOM reaper
does not break coredumping unless the system is under system-wide OOM events.

The race described in this patch's description sounds as if 2 OOM invocations
are by system-wide OOM events. If we consider only system-wide OOM events,
there is no need to keep task_to_reap != NULL after the OOM reaper found
a task to reap (shown below) because existing victim will prevent the OOM
killer from calling wake_oom_reaper().

----------------------------------------
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 012dd6f..c919ddb 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1835,9 +1835,6 @@ struct task_struct {
 	unsigned long	task_state_change;
 #endif
 	int pagefault_disabled;
-#ifdef CONFIG_MMU
-	struct list_head oom_reaper_list;
-#endif
 /* CPU-specific state of this task */
 	struct thread_struct thread;
 /*
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index b42c6bc..fa6a302 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -422,10 +422,8 @@ bool oom_killer_disabled __read_mostly;
  * victim (if that is possible) to help the OOM killer to move on.
  */
 static struct task_struct *oom_reaper_th;
+static struct task_struct *task_to_reap;
 static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
-static LIST_HEAD(oom_reaper_list);
-static DEFINE_SPINLOCK(oom_reaper_lock);
-
 
 static bool __oom_reap_task(struct task_struct *tsk)
 {
@@ -526,20 +524,11 @@ static void oom_reap_task(struct task_struct *tsk)
 static int oom_reaper(void *unused)
 {
 	while (true) {
-		struct task_struct *tsk = NULL;
+		struct task_struct *tsk;
 
 		wait_event_freezable(oom_reaper_wait,
-				     (!list_empty(&oom_reaper_list)));
-		spin_lock(&oom_reaper_lock);
-		if (!list_empty(&oom_reaper_list)) {
-			tsk = list_first_entry(&oom_reaper_list,
-					struct task_struct, oom_reaper_list);
-			list_del(&tsk->oom_reaper_list);
-		}
-		spin_unlock(&oom_reaper_lock);
-
-		if (tsk)
-			oom_reap_task(tsk);
+				     (tsk = xchg(&task_to_reap, NULL)));
+		oom_reap_task(tsk);
 	}
 
 	return 0;
@@ -551,11 +540,11 @@ static void wake_oom_reaper(struct task_struct *tsk)
 		return;
 
 	get_task_struct(tsk);
-
-	spin_lock(&oom_reaper_lock);
-	list_add(&tsk->oom_reaper_list, &oom_reaper_list);
-	spin_unlock(&oom_reaper_lock);
-	wake_up(&oom_reaper_wait);
+	tsk = xchg(&task_to_reap, tsk);
+	if (!tsk)
+		wake_up(&oom_reaper_wait);
+	else
+		put_task_struct(tsk);
 }
 
 static int __init oom_init(void)
----------------------------------------

But if we consider non system-wide OOM events, it is not very unlikely to hit
this race. This queue is useful for situations where memcg1 and memcg2 hit
memcg OOM at the same time and victim1 in memcg1 cannot terminate immediately.

I expect parallel reaping (shown below) because there is no need to serialize
victim tasks (e.g. wait for reaping victim1 in memcg1 which can take up to
1 second to complete before start reaping victim2 in memcg2) if we implement
this queue.

----------------------------------------
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index b42c6bc..c2d6472 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -427,7 +427,7 @@ static LIST_HEAD(oom_reaper_list);
 static DEFINE_SPINLOCK(oom_reaper_lock);
 
 
-static bool __oom_reap_task(struct task_struct *tsk)
+static bool oom_reap_task(struct task_struct *tsk)
 {
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
@@ -504,42 +504,42 @@ out:
 	return ret;
 }
 
-#define MAX_OOM_REAP_RETRIES 10
-static void oom_reap_task(struct task_struct *tsk)
-{
-	int attempts = 0;
-
-	/* Retry the down_read_trylock(mmap_sem) a few times */
-	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task(tsk))
-		schedule_timeout_idle(HZ/10);
-
-	if (attempts > MAX_OOM_REAP_RETRIES) {
-		pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
-				task_pid_nr(tsk), tsk->comm);
-		debug_show_all_locks();
-	}
-
-	/* Drop a reference taken by wake_oom_reaper */
-	put_task_struct(tsk);
-}
-
 static int oom_reaper(void *unused)
 {
 	while (true) {
-		struct task_struct *tsk = NULL;
-
+		struct task_struct *tsk;
+		struct task_struct *t;
+		LIST_HEAD(list);
+		int i;
+
 		wait_event_freezable(oom_reaper_wait,
 				     (!list_empty(&oom_reaper_list)));
 		spin_lock(&oom_reaper_lock);
-		if (!list_empty(&oom_reaper_list)) {
-			tsk = list_first_entry(&oom_reaper_list,
-					struct task_struct, oom_reaper_list);
-			list_del(&tsk->oom_reaper_list);
-		}
+		list_splice(&oom_reaper_list, &list);
+		INIT_LIST_HEAD(&oom_reaper_list);
 		spin_unlock(&oom_reaper_lock);
-
-		if (tsk)
-			oom_reap_task(tsk);
+		/* Retry the down_read_trylock(mmap_sem) a few times */
+		for (i = 0; i < 10; i++) {
+			list_for_each_entry_safe(tsk, t, &list,
+						 oom_reaper_list) {
+				if (!oom_reap_task(tsk))
+					continue;
+				list_del(&tsk->oom_reaper_list);
+				/* Drop a reference taken by wake_oom_reaper */
+				put_task_struct(tsk);
+			}
+			if (list_empty(&list))
+				break;
+			schedule_timeout_idle(HZ/10);
+		}
+		if (list_empty(&list))
+			continue;
+		list_for_each_entry(tsk, &list, oom_reaper_list) {
+			pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
+				task_pid_nr(tsk), tsk->comm);
+			put_task_struct(tsk);
+		}
+		debug_show_all_locks();
 	}
 
 	return 0;
----------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
