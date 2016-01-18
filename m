Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 486116B0253
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 05:23:00 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id uo6so417873081pac.1
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 02:23:00 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id l73si38904935pfi.58.2016.01.18.02.22.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Jan 2016 02:22:59 -0800 (PST)
Subject: Re: [PATCH 3/2] oom: clear TIF_MEMDIE after oom_reaper managed to unmap the address space
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1452094975-551-1-git-send-email-mhocko@kernel.org>
	<1452516120-5535-1-git-send-email-mhocko@kernel.org>
	<201601181335.JJD69226.JHVQSMFOFOFtOL@I-love.SAKURA.ne.jp>
In-Reply-To: <201601181335.JJD69226.JHVQSMFOFOFtOL@I-love.SAKURA.ne.jp>
Message-Id: <201601181922.GFI87538.LFOJStFOHOVQMF@I-love.SAKURA.ne.jp>
Date: Mon, 18 Jan 2016 19:22:45 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com

> Date: Mon, 18 Jan 2016 13:22:51 +0900
> Subject: [PATCH 4/2] oom: change OOM reaper to walk the process list
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  include/linux/sched.h |   4 +
>  mm/memcontrol.c       |   8 +-
>  mm/oom_kill.c         | 250 ++++++++++++++++++++++++++++++++++----------------
>  3 files changed, 183 insertions(+), 79 deletions(-)
> 
Oops. I meant to move mark_oom_victim() to after sending SIGKILL to other
processes sharing the same memory, but I can't move mark_oom_victim() to
after task_unlock().

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index d3a7cd8..51cb936 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -832,6 +832,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	 * space under its control.
 	 */
 	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
+	mark_oom_victim(victim);
 	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
 		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
 		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
@@ -864,7 +865,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	rcu_read_unlock();
 
 	mmdrop(mm);
-	mark_oom_victim(victim);
 	put_task_struct(victim);
 }
 #undef K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
