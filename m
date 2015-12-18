Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id B015D4402ED
	for <linux-mm@kvack.org>; Thu, 17 Dec 2015 19:15:23 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id q3so30318511pav.3
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 16:15:23 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q7si4000734pfq.8.2015.12.17.16.15.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Dec 2015 16:15:22 -0800 (PST)
Date: Thu, 17 Dec 2015 16:15:21 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm, oom: introduce oom reaper
Message-Id: <20151217161521.57fb536085aca377cb93fe1e@linux-foundation.org>
In-Reply-To: <1450204575-13052-1-git-send-email-mhocko@kernel.org>
References: <1450204575-13052-1-git-send-email-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, 15 Dec 2015 19:36:15 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> This patch reduces the probability of such a lockup by introducing a
> specialized kernel thread (oom_reaper) 

CONFIG_MMU=n:

slub.c:(.text+0x4184): undefined reference to `tlb_gather_mmu'
slub.c:(.text+0x41bc): undefined reference to `unmap_page_range'
slub.c:(.text+0x41d8): undefined reference to `tlb_finish_mmu'

I did the below so I can get an mmotm out the door, but hopefully
there's a cleaner way.

--- a/mm/oom_kill.c~mm-oom-introduce-oom-reaper-fix-3
+++ a/mm/oom_kill.c
@@ -415,6 +415,7 @@ static DECLARE_WAIT_QUEUE_HEAD(oom_victi
 
 bool oom_killer_disabled __read_mostly;
 
+#ifdef CONFIG_MMU
 /*
  * OOM Reaper kernel thread which tries to reap the memory used by the OOM
  * victim (if that is possible) to help the OOM killer to move on.
@@ -517,6 +518,27 @@ static void wake_oom_reaper(struct mm_st
 		mmdrop(mm);
 }
 
+static int __init oom_init(void)
+{
+	oom_reaper_th = kthread_run(oom_reaper, NULL, "oom_reaper");
+	if (IS_ERR(oom_reaper_th)) {
+		pr_err("Unable to start OOM reaper %ld. Continuing regardless\n",
+				PTR_ERR(oom_reaper_th));
+		oom_reaper_th = NULL;
+	} else {
+		struct sched_param param = { .sched_priority = MAX_RT_PRIO-1 };
+
+		/*
+		 * Make sure our oom reaper thread will get scheduled when
+		 * ASAP and that it won't get preempted by malicious userspace.
+		 */
+		sched_setscheduler(oom_reaper_th, SCHED_FIFO, &param);
+	}
+	return 0;
+}
+module_init(oom_init)
+#endif
+
 /**
  * mark_oom_victim - mark the given task as OOM victim
  * @tsk: task to mark
@@ -626,7 +648,9 @@ void oom_kill_process(struct oom_control
 	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
+#ifdef CONFIG_MMU
 	bool can_oom_reap = true;
+#endif
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
@@ -719,6 +743,7 @@ void oom_kill_process(struct oom_control
 			continue;
 		if (is_global_init(p))
 			continue;
+#ifdef CONFIG_MMU
 		if (unlikely(p->flags & PF_KTHREAD) ||
 		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
 			/*
@@ -729,13 +754,16 @@ void oom_kill_process(struct oom_control
 			can_oom_reap = false;
 			continue;
 		}
-
+#endif
 		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
 	}
 	rcu_read_unlock();
 
+#ifdef CONFIG_MMU
 	if (can_oom_reap)
 		wake_oom_reaper(mm);
+#endif
+
 	mmdrop(mm);
 	put_task_struct(victim);
 }
@@ -887,23 +915,3 @@ void pagefault_out_of_memory(void)
 
 	mutex_unlock(&oom_lock);
 }
-
-static int __init oom_init(void)
-{
-	oom_reaper_th = kthread_run(oom_reaper, NULL, "oom_reaper");
-	if (IS_ERR(oom_reaper_th)) {
-		pr_err("Unable to start OOM reaper %ld. Continuing regardless\n",
-				PTR_ERR(oom_reaper_th));
-		oom_reaper_th = NULL;
-	} else {
-		struct sched_param param = { .sched_priority = MAX_RT_PRIO-1 };
-
-		/*
-		 * Make sure our oom reaper thread will get scheduled when
-		 * ASAP and that it won't get preempted by malicious userspace.
-		 */
-		sched_setscheduler(oom_reaper_th, SCHED_FIFO, &param);
-	}
-	return 0;
-}
-module_init(oom_init)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
