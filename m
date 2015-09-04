Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8495D6B0038
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 14:07:17 -0400 (EDT)
Received: by pacwi10 with SMTP id wi10so30968278pac.3
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 11:07:17 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id st10si5406441pab.215.2015.09.04.11.07.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Fri, 04 Sep 2015 11:07:16 -0700 (PDT)
Subject: Re: [PATCH 2/2] android, lmk: Reverse the order of setting TIF_MEMDIE and sending SIGKILL.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201508262117.FAH43726.tOFMVJSLQOFHFO@I-love.SAKURA.ne.jp>
	<201508262119.IHA93770.JOOtFHMSFLOQVF@I-love.SAKURA.ne.jp>
	<20150903010620.GC31349@kroah.com>
	<20150904140559.GD8220@dhcp22.suse.cz>
	<20150904171519.GA5537@kroah.com>
In-Reply-To: <20150904171519.GA5537@kroah.com>
Message-Id: <201509050306.CDJ43754.LtFHVOMJFFOSQO@I-love.SAKURA.ne.jp>
Date: Sat, 5 Sep 2015 03:06:46 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, mhocko@kernel.org
Cc: arve@android.com, riandrews@android.com, devel@driverdev.osuosl.org, linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org

Greg KH wrote:
> On Fri, Sep 04, 2015 at 04:05:59PM +0200, Michal Hocko wrote:
> > On Wed 02-09-15 18:06:20, Greg KH wrote:
> > [...]
> > > And if we aren't taking patch 1/2, I guess this one isn't needed either?
> > 
> > Unlike the patch1 which was pretty much cosmetic this fixes a real
> > issue.
> 
> Ok, then it would be great to get this in a format that I can apply it
> in :)

I see. Here is a minimal patch.
(Acked-by: from http://lkml.kernel.org/r/20150827084443.GE14367@dhcp22.suse.cz )
----------------------------------------
>From 118609fa25700af11791b1b7e8349f8973a9e7e4 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 5 Sep 2015 02:58:12 +0900
Subject: [PATCH] android, lmk: Send SIGKILL before setting TIF_MEMDIE.

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
