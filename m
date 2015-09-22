Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4EFA36B0038
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 23:39:17 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so137646912pac.2
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 20:39:17 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id ir5si10743621pbb.212.2015.09.21.20.39.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Mon, 21 Sep 2015 20:39:16 -0700 (PDT)
Subject: Re: [PATCH 1/3] mm,oom: Reverse the order of setting TIF_MEMDIE and sending SIGKILL.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1442714685-14002-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20150921145958.434bdb12c91e5300c27576f5@linux-foundation.org>
In-Reply-To: <20150921145958.434bdb12c91e5300c27576f5@linux-foundation.org>
Message-Id: <201509221239.EGD05714.JFSOOOtVLFHFQM@I-love.SAKURA.ne.jp>
Date: Tue, 22 Sep 2015 12:39:08 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, stable@vger.kernel.org

Andrew Morton wrote:
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -554,6 +554,8 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
> >  
> >  	/* mm cannot safely be dereferenced after task_unlock(victim) */
> >  	mm = victim->mm;
> > +	/* Send SIGKILL before setting TIF_MEMDIE. */
> > +	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
> 
> The patch looks good, but the comment is poor.  It says what the code
> does (which is obvious anyway) but fails to describe *why* the code is
> this way, which is what the reader wants to understand.
> 
> In fact the comment seems rather misleading, because we could retain
> the current ordering:
> 
> 	mark_oom_victim(...);
> 	do_send_sig_info(...);
> 
> and still achieve this patch's objectives?
> 

If

  mark_oom_victim(...);
  task_unlock(...);
  do_send_sig_info(...);

then preemption can jump in. I confirmed that preemption can still
deplete the memory reserves under rare conditions.

If

  mark_oom_victim(...);
  do_send_sig_info(...);
  task_unlock(...);

then only interrupts can jump in. In case the interrupts takes long time
(e.g. SysRq-t), send SIGKILL before setting TIF_MEMDIE for safety.
------------------------------------------------------------
>From 472f4c9dc6e6a2641dcf26d92eb75de41ee79709 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Tue, 22 Sep 2015 12:13:12 +0900
Subject: [PATCH] mm,oom: Reverse the order of setting TIF_MEMDIE and sending SIGKILL.

It was confirmed that a local unprivileged user can consume all memory
reserves and hang up that system using time lag between the OOM killer
sets TIF_MEMDIE on an OOM victim and sends SIGKILL to that victim, for
printk() inside for_each_process() loop at oom_kill_process() can consume
many seconds when there are many thread groups sharing the same memory.

Before starting oom-depleter process:

    Node 0 DMA: 3*4kB (UM) 6*8kB (U) 4*16kB (UEM) 0*32kB 0*64kB 1*128kB (M) 2*256kB (EM) 2*512kB (UE) 2*1024kB (EM) 1*2048kB (E) 1*4096kB (M) = 9980kB
    Node 0 DMA32: 31*4kB (UEM) 27*8kB (UE) 32*16kB (UE) 13*32kB (UE) 14*64kB (UM) 7*128kB (UM) 8*256kB (UM) 8*512kB (UM) 3*1024kB (U) 4*2048kB (UM) 362*4096kB (UM) = 1503220kB

As of invoking the OOM killer:

    Node 0 DMA: 11*4kB (UE) 8*8kB (UEM) 6*16kB (UE) 2*32kB (EM) 0*64kB 1*128kB (U) 3*256kB (UEM) 2*512kB (UE) 3*1024kB (UEM) 1*2048kB (U) 0*4096kB = 7308kB
    Node 0 DMA32: 1049*4kB (UEM) 507*8kB (UE) 151*16kB (UE) 53*32kB (UEM) 83*64kB (UEM) 52*128kB (EM) 25*256kB (UEM) 11*512kB (M) 6*1024kB (UM) 1*2048kB (M) 0*4096kB = 44556kB

Between the thread group leader got TIF_MEMDIE and receives SIGKILL:

    Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
    Node 0 DMA32: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB

The oom-depleter's thread group leader which got TIF_MEMDIE started
memset() in user space after the OOM killer set TIF_MEMDIE, and it was
free to abuse ALLOC_NO_WATERMARKS by TIF_MEMDIE for memset() in user space
until SIGKILL is delivered.  If SIGKILL is delivered before TIF_MEMDIE is
set, the oom-depleter can terminate without touching memory reserves.

Although the possibility of hitting this time lag is very small for 3.19
and earlier kernels because TIF_MEMDIE is set immediately before sending
SIGKILL, preemption or long interrupts (an extreme example is SysRq-t) can
step between and allow memory allocations which are not needed for
terminating the OOM victim.

Fixes: 83363b917a29 ("oom: make sure that TIF_MEMDIE is set under task_lock")
Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: David Rientjes <rientjes@google.com>
Cc: <stable@vger.kernel.org>	[4.0+]
---
 mm/oom_kill.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 7b6228e..97c376c 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -563,6 +563,12 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 
 	/* mm cannot safely be dereferenced after task_unlock(victim) */
 	mm = victim->mm;
+	/*
+	 * We should send SIGKILL before setting TIF_MEMDIE in order to prevent
+	 * the OOM victim from depleting the memory reserves from the user
+	 * space under its control.
+	 */
+	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
 	mark_oom_victim(victim);
 	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
 		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
@@ -594,7 +600,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 		}
 	rcu_read_unlock();
 
-	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
 	put_task_struct(victim);
 }
 #undef K
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
