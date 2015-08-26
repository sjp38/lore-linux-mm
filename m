Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id 235B56B0253
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 08:20:17 -0400 (EDT)
Received: by ykdt205 with SMTP id t205so185360877ykd.1
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 05:20:16 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id r19si38300555qha.4.2015.08.26.05.20.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 26 Aug 2015 05:20:15 -0700 (PDT)
Subject: [PATCH 2/2] android, lmk: Reverse the order of setting TIF_MEMDIE and sending SIGKILL.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201508262117.FAH43726.tOFMVJSLQOFHFO@I-love.SAKURA.ne.jp>
In-Reply-To: <201508262117.FAH43726.tOFMVJSLQOFHFO@I-love.SAKURA.ne.jp>
Message-Id: <201508262119.IHA93770.JOOtFHMSFLOQVF@I-love.SAKURA.ne.jp>
Date: Wed, 26 Aug 2015 21:19:48 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, arve@android.com, riandrews@android.com
Cc: devel@driverdev.osuosl.org, linux-mm@kvack.org, mhocko@kernel.org, rientjes@google.com, hannes@cmpxchg.org

Hello.

Should selected_tasksize be added to rem even when TIF_MEMDIE was not set?

Please see a thread from http://www.spinics.net/lists/linux-mm/msg93246.html
if you want to know why to reverse the order.
----------------------------------------
>From 2d4cc11d8128e4c1397631b91fea78da3eaefb47 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 26 Aug 2015 20:52:39 +0900
Subject: [PATCH 2/2] android, lmk: Reverse the order of setting TIF_MEMDIE and sending SIGKILL.

If we set TIF_MEMDIE before sending SIGKILL, memory reserves could be
spent for allocations which are not needed for terminating the victim.
Reverse the order as with oom_kill_process() does.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 drivers/staging/android/lowmemorykiller.c | 24 +++++++++++-------------
 1 file changed, 11 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/android/lowmemorykiller.c b/drivers/staging/android/lowmemorykiller.c
index d5d25e4..c39b6a2 100644
--- a/drivers/staging/android/lowmemorykiller.c
+++ b/drivers/staging/android/lowmemorykiller.c
@@ -156,26 +156,24 @@ next:
 	}
 	if (selected) {
 		task_lock(selected);
-		if (!selected->mm) {
-			/* Already exited, cannot do mark_tsk_oom_victim() */
-			task_unlock(selected);
-			goto out;
-		}
+		lowmem_print(1, "send sigkill to %d (%s), adj %hd, size %d\n",
+			     selected->pid, selected->comm,
+			     selected_oom_score_adj, selected_tasksize);
+		task_unlock(selected);
+		send_sig(SIGKILL, selected, 0);
 		/*
 		 * FIXME: lowmemorykiller shouldn't abuse global OOM killer
 		 * infrastructure. There is no real reason why the selected
 		 * task should have access to the memory reserves.
 		 */
-		mark_oom_victim(selected);
-		lowmem_print(1, "send sigkill to %d (%s), adj %hd, size %d\n",
-			     selected->pid, selected->comm,
-			     selected_oom_score_adj, selected_tasksize);
+		task_lock(selected);
+		if (selected->mm) {
+			mark_oom_victim(selected);
+			lowmem_deathpending_timeout = jiffies + HZ;
+			rem += selected_tasksize;
+		}
 		task_unlock(selected);
-		lowmem_deathpending_timeout = jiffies + HZ;
-		send_sig(SIGKILL, selected, 0);
-		rem += selected_tasksize;
 	}
-out:
 	lowmem_print(4, "lowmem_scan %lu, %x, return %lu\n",
 		     sc->nr_to_scan, sc->gfp_mask, rem);
 	rcu_read_unlock();
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
