Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id F34D86B0071
	for <linux-mm@kvack.org>; Fri, 29 May 2015 10:49:25 -0400 (EDT)
Received: by wizo1 with SMTP id o1so26902943wiz.1
        for <linux-mm@kvack.org>; Fri, 29 May 2015 07:49:25 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id km4si9964915wjc.108.2015.05.29.07.49.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 29 May 2015 07:49:23 -0700 (PDT)
Date: Fri, 29 May 2015 16:49:22 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm/oom: Suppress unnecessary "sharing same
 memory"message.
Message-ID: <20150529144922.GE22728@dhcp22.suse.cz>
References: <20150526170213.GB14955@dhcp22.suse.cz>
 <201505270639.JCF57366.OFVOQSFFHtJOML@I-love.SAKURA.ne.jp>
 <20150527164505.GD27348@dhcp22.suse.cz>
 <201505280659.HBE69765.SOtQMJLVFHFFOO@I-love.SAKURA.ne.jp>
 <20150528180524.GB2321@dhcp22.suse.cz>
 <201505292140.JHE18273.SFFMJFHOtQLOVO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201505292140.JHE18273.SFFMJFHOtQLOVO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Fri 29-05-15 21:40:47, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Thu 28-05-15 06:59:32, Tetsuo Handa wrote:
> > > I just imagined a case where p is blocked at down_read() in acct_collect() from
> > > do_exit() when p is sharing mm with other processes, and other process is doing
> > > blocking operation with mm->mmap_sem held for writing. Is such case impossible?
> > 
> > It is very much possible and I have missed this case when proposing
> > my alternative. The other process could be doing an address space
> > operation e.g. mmap which requires an allocation.
> 
> Are there locations that do memory allocations with mm->mmap_sem held for
> writing?

Yes, I've written that in my previous email.

> Is it possible that thread1 is doing memory allocation between
> down_write(&current->mm->mmap_sem) and up_write(&current->mm->mmap_sem),
> thread2 sharing the same mm is waiting at down_read(&current->mm->mmap_sem),
> and the OOM killer invoked by thread3 chooses thread2 as the OOM victim and
> sets TIF_MEMDIE to thread2?

Your usage of thread is confusing. Threads are of no concerns because
those get killed when the group leader is killed. If you refer to
processes then this is exactly what is handled by:
        for_each_process(p)
                if (p->mm == mm && !same_thread_group(p, victim) &&
                    !(p->flags & PF_KTHREAD)) {
                        if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
                                continue;

                        task_lock(p);   /* Protect ->comm from prctl() */
                        pr_err("Kill process %d (%s) sharing same memory\n",
                                task_pid_nr(p), p->comm);
                        task_unlock(p);
                        do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
                }
[...]
> Maybe we can use "struct mm_struct"->"bool chosen_by_oom_killer" and checking
> for (current->mm && current->mm->chosen_by_oom_killer) than
> test_thread_flag(TIF_MEMDIE) inside the memory allocator?

Bool is not sufficient because killing some of the processes might be
sufficient to resolve the OOM condition and the rest can survive. This
is quite unlikely, all right, but not impossible. And then you would
have a dangling chosen_by_oom_killer. So this should be a counter.

So I think, but I have to think more about this, a proper way to handle
this would be something like the following. The patch is obviously
incomplete because memcg OOM killer would need the same treatment which
calls for a common helper etc...

But this is a real corner case. It would have to be current to trigger
OOM killer and the userspace would have to be able to send the signal
at the right moment... So I am even not sure this needs fixing. Are you
able to trigger it?
---
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5cfda39b3268..14128575fe86 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -428,6 +428,8 @@ void mark_oom_victim(struct task_struct *tsk)
 	 */
 	__thaw_task(tsk);
 	atomic_inc(&oom_victims);
+
+	atomic_inc(tsk->mm->under_oom);
 }
 
 /**
@@ -436,6 +438,7 @@ void mark_oom_victim(struct task_struct *tsk)
 void exit_oom_victim(void)
 {
 	clear_thread_flag(TIF_MEMDIE);
+	atomic_dec(current->active_mm->under_oom)
 
 	if (!atomic_dec_return(&oom_victims))
 		wake_up_all(&oom_victims_wait);
@@ -681,6 +684,16 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	}
 
 	/*
+	 * Processes which are sharing mm should die together. If one of them
+	 * was OOM killed already we should shoot others as well.
+	 */
+	if (current->mm && atomic_read(current->mm->under_oom)) {
+		mark_oom_victim(current);
+		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, current, true);
+		goto out;
+	}
+
+	/*
 	 * Check if there were limitations on the allocation (only relevant for
 	 * NUMA) that may require different handling.
 	 */
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
