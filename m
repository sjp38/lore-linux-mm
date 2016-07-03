Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5A4486B025E
	for <linux-mm@kvack.org>; Sat,  2 Jul 2016 22:38:01 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g62so320839387pfb.3
        for <linux-mm@kvack.org>; Sat, 02 Jul 2016 19:38:01 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id wx10si2417893pab.263.2016.07.02.19.38.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 02 Jul 2016 19:38:00 -0700 (PDT)
Subject: [PATCH 1/8] mm,oom_reaper: Remove pointless kthread_run() failure check.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp>
In-Reply-To: <201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp>
Message-Id: <201607031136.GGI52642.OMLFFOHQtFVJOS@I-love.SAKURA.ne.jp>
Date: Sun, 3 Jul 2016 11:36:47 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com, mhocko@suse.com, mhocko@kernel.org

>From c8b596f22c4fcc9424149681c568e1ab90e545a1 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 2 Jul 2016 22:53:03 +0900
Subject: [PATCH 1/8] mm,oom_reaper: Remove pointless kthread_run() failure check.

Since oom_init() is called before OOM-killable userspace processes are
started, the system will panic if out_of_memory() is called before
oom_init() returns. Therefore, oom_reaper_th == NULL check in
wake_oom_reaper() is pointless.

If kthread_run() in oom_init() fails due to reasons other than OOM
(e.g. no free pid is available), userspace processes won't be able to
start as well. Therefore, trying to continue with error message is
also pointless.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 11 +----------
 1 file changed, 1 insertion(+), 10 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 7d0a275..16340f2 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -447,7 +447,6 @@ bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
  * OOM Reaper kernel thread which tries to reap the memory used by the OOM
  * victim (if that is possible) to help the OOM killer to move on.
  */
-static struct task_struct *oom_reaper_th;
 static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
 static struct task_struct *oom_reaper_list;
 static DEFINE_SPINLOCK(oom_reaper_lock);
@@ -629,9 +628,6 @@ static int oom_reaper(void *unused)
 
 void wake_oom_reaper(struct task_struct *tsk)
 {
-	if (!oom_reaper_th)
-		return;
-
 	/* tsk is already queued? */
 	if (tsk == oom_reaper_list || tsk->oom_reaper_list)
 		return;
@@ -647,12 +643,7 @@ void wake_oom_reaper(struct task_struct *tsk)
 
 static int __init oom_init(void)
 {
-	oom_reaper_th = kthread_run(oom_reaper, NULL, "oom_reaper");
-	if (IS_ERR(oom_reaper_th)) {
-		pr_err("Unable to start OOM reaper %ld. Continuing regardless\n",
-				PTR_ERR(oom_reaper_th));
-		oom_reaper_th = NULL;
-	}
+	kthread_run(oom_reaper, NULL, "oom_reaper");
 	return 0;
 }
 subsys_initcall(oom_init)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
