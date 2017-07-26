Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D274A6B02C3
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 09:28:05 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id a186so89502291pge.7
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 06:28:05 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id y35si10098358plh.898.2017.07.26.06.28.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 06:28:04 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [v4 1/4] mm, oom: refactor the TIF_MEMDIE usage
Date: Wed, 26 Jul 2017 14:27:15 +0100
Message-ID: <20170726132718.14806-2-guro@fb.com>
In-Reply-To: <20170726132718.14806-1-guro@fb.com>
References: <20170726132718.14806-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

First, separate tsk_is_oom_victim() and TIF_MEMDIE flag checks:
let the first one indicate that a task is killed by the OOM killer,
and the second one indicate that a task has an access to the memory
reserves (with a hope to eliminate it later).

Second, set TIF_MEMDIE to all threads of an OOM victim process.

Third, to limit the number of processes which have an access to memory
reserves, let's keep an atomic pointer to a task, which grabbed it.

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: David Rientjes <rientjes@google.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: kernel-team@fb.com
Cc: cgroups@vger.kernel.org
Cc: linux-doc@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
---
 kernel/exit.c   |  2 +-
 mm/memcontrol.c |  2 +-
 mm/oom_kill.c   | 30 +++++++++++++++++++++++++-----
 3 files changed, 27 insertions(+), 7 deletions(-)

diff --git a/kernel/exit.c b/kernel/exit.c
index 8f40bee5ba9d..d5f372a2a363 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -542,7 +542,7 @@ static void exit_mm(void)
 	task_unlock(current);
 	mm_update_next_owner(mm);
 	mmput(mm);
-	if (test_thread_flag(TIF_MEMDIE))
+	if (tsk_is_oom_victim(current))
 		exit_oom_victim();
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d61133e6af99..9085e55eb69f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1896,7 +1896,7 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 * bypass the last charges so that they can exit quickly and
 	 * free their memory.
 	 */
-	if (unlikely(test_thread_flag(TIF_MEMDIE) ||
+	if (unlikely(tsk_is_oom_victim(current) ||
 		     fatal_signal_pending(current) ||
 		     current->flags & PF_EXITING))
 		goto force;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 9e8b4f030c1c..72de01be4d33 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -435,6 +435,8 @@ static DECLARE_WAIT_QUEUE_HEAD(oom_victims_wait);
 
 static bool oom_killer_disabled __read_mostly;
 
+static struct task_struct *tif_memdie_owner;
+
 #define K(x) ((x) << (PAGE_SHIFT-10))
 
 /*
@@ -656,13 +658,24 @@ static void mark_oom_victim(struct task_struct *tsk)
 	struct mm_struct *mm = tsk->mm;
 
 	WARN_ON(oom_killer_disabled);
-	/* OOM killer might race with memcg OOM */
-	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
+
+	if (!cmpxchg(&tif_memdie_owner, NULL, current)) {
+		struct task_struct *t;
+
+		rcu_read_lock();
+		for_each_thread(current, t)
+			set_tsk_thread_flag(t, TIF_MEMDIE);
+		rcu_read_unlock();
+	}
+
+	/*
+	 * OOM killer might race with memcg OOM.
+	 * oom_mm is bound to the signal struct life time.
+	 */
+	if (cmpxchg(&tsk->signal->oom_mm, NULL, mm))
 		return;
 
-	/* oom_mm is bound to the signal struct life time. */
-	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm))
-		mmgrab(tsk->signal->oom_mm);
+	mmgrab(tsk->signal->oom_mm);
 
 	/*
 	 * Make sure that the task is woken up from uninterruptible sleep
@@ -682,6 +695,13 @@ void exit_oom_victim(void)
 {
 	clear_thread_flag(TIF_MEMDIE);
 
+	/*
+	 * If current tasks if a thread, which initially
+	 * received TIF_MEMDIE, clear tif_memdie_owner to
+	 * give a next process a chance to capture it.
+	 */
+	cmpxchg(&tif_memdie_owner, current, NULL);
+
 	if (!atomic_dec_return(&oom_victims))
 		wake_up_all(&oom_victims_wait);
 }
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
