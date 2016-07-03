Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id B7C186B0005
	for <linux-mm@kvack.org>; Sat,  2 Jul 2016 22:40:17 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ts6so283133120pac.1
        for <linux-mm@kvack.org>; Sat, 02 Jul 2016 19:40:17 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t15si1421086pfj.37.2016.07.02.19.40.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 02 Jul 2016 19:40:17 -0700 (PDT)
Subject: [PATCH 5/8] mm,oom: Remove unused signal_struct->oom_victims.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp>
In-Reply-To: <201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp>
Message-Id: <201607031140.GAF05212.tMFJFOOSLOQHVF@I-love.SAKURA.ne.jp>
Date: Sun, 3 Jul 2016 11:40:03 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com, mhocko@suse.com, mhocko@kernel.org

>From e2e22cd0c0c486d1aef01232fcc62b00fb01709f Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 2 Jul 2016 23:02:19 +0900
Subject: [PATCH 5/8] mm,oom: Remove unused signal_struct->oom_victims.

Since OOM_SCAN_ABORT case was removed, we no longer need to use
signal_struct->oom_victims useless. Remove it.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/sched.h | 1 -
 mm/oom_kill.c         | 2 --
 2 files changed, 3 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 553af29..f472f27 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -671,7 +671,6 @@ struct signal_struct {
 	atomic_t		sigcnt;
 	atomic_t		live;
 	int			nr_threads;
-	atomic_t oom_victims; /* # of TIF_MEDIE threads in this thread group */
 	struct list_head	thread_head;
 
 	wait_queue_head_t	wait_chldexit;	/* for wait4() */
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 734378a..55e0ffb 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -659,7 +659,6 @@ void mark_oom_victim(struct task_struct *tsk, struct oom_control *oc)
 	/* OOM killer might race with memcg OOM */
 	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
 		return;
-	atomic_inc(&tsk->signal->oom_victims);
 	/*
 	 * Since mark_oom_victim() is called from multiple threads,
 	 * connect this mm to oom_mm_list only if not yet connected.
@@ -693,7 +692,6 @@ void exit_oom_victim(struct task_struct *tsk)
 {
 	if (!test_and_clear_tsk_thread_flag(tsk, TIF_MEMDIE))
 		return;
-	atomic_dec(&tsk->signal->oom_victims);
 
 	if (!atomic_dec_return(&oom_victims))
 		wake_up_all(&oom_victims_wait);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
