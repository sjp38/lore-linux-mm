Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id CDF676B0038
	for <linux-mm@kvack.org>; Sun,  6 Sep 2015 01:26:10 -0400 (EDT)
Received: by obqa2 with SMTP id a2so42982646obq.3
        for <linux-mm@kvack.org>; Sat, 05 Sep 2015 22:26:10 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id r64si5082091oig.117.2015.09.05.22.26.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 05 Sep 2015 22:26:09 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] android, lmk: Send SIGKILL before setting TIF_MEMDIE.
Date: Sun,  6 Sep 2015 14:25:35 +0900
Message-Id: <1441517135-4980-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, mhocko@kernel.org, linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

It was observed that setting TIF_MEMDIE before sending SIGKILL at
oom_kill_process() allows memory reserves to be depleted by allocations
which are not needed for terminating the OOM victim.

This patch reverts commit 6bc2b856bb7c ("staging: android: lowmemorykiller:
set TIF_MEMDIE before send kill sig"), for oom_kill_process() was updated
to send SIGKILL before setting TIF_MEMDIE.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 drivers/staging/android/lowmemorykiller.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/android/lowmemorykiller.c b/drivers/staging/android/lowmemorykiller.c
index 872bd60..569d12c 100644
--- a/drivers/staging/android/lowmemorykiller.c
+++ b/drivers/staging/android/lowmemorykiller.c
@@ -157,26 +157,22 @@ static unsigned long lowmem_scan(struct shrinker *s, struct shrink_control *sc)
 	}
 	if (selected) {
 		task_lock(selected);
-		if (!selected->mm) {
-			/* Already exited, cannot do mark_tsk_oom_victim() */
-			task_unlock(selected);
-			goto out;
-		}
+		send_sig(SIGKILL, selected, 0);
 		/*
 		 * FIXME: lowmemorykiller shouldn't abuse global OOM killer
 		 * infrastructure. There is no real reason why the selected
 		 * task should have access to the memory reserves.
 		 */
-		mark_oom_victim(selected);
+		if (selected->mm)
+			mark_oom_victim(selected);
 		task_unlock(selected);
 		lowmem_print(1, "send sigkill to %d (%s), adj %hd, size %d\n",
 			     selected->pid, selected->comm,
 			     selected_oom_score_adj, selected_tasksize);
 		lowmem_deathpending_timeout = jiffies + HZ;
-		send_sig(SIGKILL, selected, 0);
 		rem += selected_tasksize;
 	}
-out:
+
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
