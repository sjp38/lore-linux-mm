Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2CAEB6B02F3
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 17:20:01 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p4so169815527pfk.15
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 14:20:01 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id m21si14869327pli.508.2017.06.21.14.20.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 14:20:00 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [v3 5/6] mm, oom: don't mark all oom victims tasks with TIF_MEMDIE
Date: Wed, 21 Jun 2017 22:19:15 +0100
Message-ID: <1498079956-24467-6-git-send-email-guro@fb.com>
In-Reply-To: <1498079956-24467-1-git-send-email-guro@fb.com>
References: <1498079956-24467-1-git-send-email-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

We want to limit the number of tasks which are having an access
to the memory reserves. To ensure the progress it's enough
to have one such process at the time.

If we need to kill the whole cgroup, let's give an access to the
memory reserves only to the first process in the list, which is
(usually) the biggest process.
This will give us good chances that all other processes will be able
to quit without an access to the memory reserves.

Otherwise, to keep going forward, let's grant the access to the memory
reserves for tasks, which can't be reaped by the oom_reaper.
As it will be done from the oom reaper thread, which handles the
oom reaper queue consequently, there is no high risk to have too many
such processes at the same time.

To implement this solution, we need to stop using TIF_MEMDIE flag
as an universal marker for oom victims tasks. It's not a big issue,
as we have oom_mm pointer/tsk_is_oom_victim(), which are just better.

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: kernel-team@fb.com
Cc: cgroups@vger.kernel.org
Cc: linux-doc@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
---
 kernel/exit.c |  2 +-
 mm/oom_kill.c | 31 ++++++++++++++++++++++---------
 2 files changed, 23 insertions(+), 10 deletions(-)

diff --git a/kernel/exit.c b/kernel/exit.c
index d211425..5b95d74 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -554,7 +554,7 @@ static void exit_mm(void)
 	task_unlock(current);
 	mm_update_next_owner(mm);
 	mmput(mm);
-	if (test_thread_flag(TIF_MEMDIE))
+	if (tsk_is_oom_victim(current))
 		exit_oom_victim();
 }
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 489ab69..b55bd18 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -556,8 +556,18 @@ static void oom_reap_task(struct task_struct *tsk)
 	struct mm_struct *mm = tsk->signal->oom_mm;
 
 	/* Retry the down_read_trylock(mmap_sem) a few times */
-	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task_mm(tsk, mm))
+	while (attempts++ < MAX_OOM_REAP_RETRIES &&
+	       !__oom_reap_task_mm(tsk, mm)) {
+
+		/*
+		 * If the task has no access to the memory reserves,
+		 * grant it to help the task to exit.
+		 */
+		if (!test_tsk_thread_flag(tsk, TIF_MEMDIE))
+			set_tsk_thread_flag(tsk, TIF_MEMDIE);
+
 		schedule_timeout_idle(HZ/10);
+	}
 
 	if (attempts <= MAX_OOM_REAP_RETRIES)
 		goto done;
@@ -647,16 +657,13 @@ static inline void wake_oom_reaper(struct task_struct *tsk)
  */
 static void mark_oom_victim(struct task_struct *tsk)
 {
-	struct mm_struct *mm = tsk->mm;
-
 	WARN_ON(oom_killer_disabled);
-	/* OOM killer might race with memcg OOM */
-	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
-		return;
 
 	/* oom_mm is bound to the signal struct life time. */
-	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm))
-		mmgrab(tsk->signal->oom_mm);
+	if (cmpxchg(&tsk->signal->oom_mm, NULL, tsk->mm) != NULL)
+		return;
+
+	mmgrab(tsk->signal->oom_mm);
 
 	/*
 	 * Make sure that the task is woken up from uninterruptible sleep
@@ -665,7 +672,13 @@ static void mark_oom_victim(struct task_struct *tsk)
 	 * that TIF_MEMDIE tasks should be ignored.
 	 */
 	__thaw_task(tsk);
-	atomic_inc(&oom_victims);
+
+	/*
+	 * If there are no oom victims in flight,
+	 * give the task an access to the memory reserves.
+	 */
+	if (atomic_inc_return(&oom_victims) == 1)
+		set_tsk_thread_flag(tsk, TIF_MEMDIE);
 }
 
 /**
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
