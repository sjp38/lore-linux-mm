Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 40F016B0253
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 08:18:31 -0400 (EDT)
Received: by pacti10 with SMTP id ti10so86836451pac.0
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 05:18:31 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id ad8si38345597pad.109.2015.08.26.05.18.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 26 Aug 2015 05:18:30 -0700 (PDT)
Subject: [PATCH 1/2] android, lmk: Protect task->comm with task_lock.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201508262117.FAH43726.tOFMVJSLQOFHFO@I-love.SAKURA.ne.jp>
Date: Wed, 26 Aug 2015 21:17:54 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, arve@android.com, riandrews@android.com
Cc: devel@driverdev.osuosl.org, linux-mm@kvack.org, mhocko@kernel.org, rientjes@google.com, hannes@cmpxchg.org

Hello.

Next patch is mm-related but this patch is not.
Via which tree should these patches go?
----------------------------------------
>From 48c1b457eb32d7a029e9a078ee0a67974ada9261 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 26 Aug 2015 20:49:17 +0900
Subject: [PATCH 1/2] android, lmk: Protect task->comm with task_lock.

Passing task->comm to printk() wants task_lock() protection in order
to avoid potentially emitting garbage bytes.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 drivers/staging/android/lowmemorykiller.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/android/lowmemorykiller.c b/drivers/staging/android/lowmemorykiller.c
index 872bd60..d5d25e4 100644
--- a/drivers/staging/android/lowmemorykiller.c
+++ b/drivers/staging/android/lowmemorykiller.c
@@ -134,26 +134,25 @@ static unsigned long lowmem_scan(struct shrinker *s, struct shrink_control *sc)
 			return 0;
 		}
 		oom_score_adj = p->signal->oom_score_adj;
-		if (oom_score_adj < min_score_adj) {
-			task_unlock(p);
-			continue;
-		}
+		if (oom_score_adj < min_score_adj)
+			goto next;
 		tasksize = get_mm_rss(p->mm);
-		task_unlock(p);
 		if (tasksize <= 0)
-			continue;
+			goto next;
 		if (selected) {
 			if (oom_score_adj < selected_oom_score_adj)
-				continue;
+				goto next;
 			if (oom_score_adj == selected_oom_score_adj &&
 			    tasksize <= selected_tasksize)
-				continue;
+				goto next;
 		}
 		selected = p;
 		selected_tasksize = tasksize;
 		selected_oom_score_adj = oom_score_adj;
 		lowmem_print(2, "select %d (%s), adj %hd, size %d, to kill\n",
 			     p->pid, p->comm, oom_score_adj, tasksize);
+next:
+		task_unlock(p);
 	}
 	if (selected) {
 		task_lock(selected);
@@ -168,10 +167,10 @@ static unsigned long lowmem_scan(struct shrinker *s, struct shrink_control *sc)
 		 * task should have access to the memory reserves.
 		 */
 		mark_oom_victim(selected);
-		task_unlock(selected);
 		lowmem_print(1, "send sigkill to %d (%s), adj %hd, size %d\n",
 			     selected->pid, selected->comm,
 			     selected_oom_score_adj, selected_tasksize);
+		task_unlock(selected);
 		lowmem_deathpending_timeout = jiffies + HZ;
 		send_sig(SIGKILL, selected, 0);
 		rem += selected_tasksize;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
