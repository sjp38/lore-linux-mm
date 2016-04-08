Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 94F0F6B0253
	for <linux-mm@kvack.org>; Fri,  8 Apr 2016 07:34:44 -0400 (EDT)
Received: by mail-wm0-f49.google.com with SMTP id u206so18867275wme.1
        for <linux-mm@kvack.org>; Fri, 08 Apr 2016 04:34:44 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id k71si2559209wmg.79.2016.04.08.04.34.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Apr 2016 04:34:43 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id l6so3637503wml.3
        for <linux-mm@kvack.org>; Fri, 08 Apr 2016 04:34:43 -0700 (PDT)
Date: Fri, 8 Apr 2016 13:34:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/3] oom, oom_reaper: Try to reap tasks which skip
 regular OOM killer path
Message-ID: <20160408113442.GG29820@dhcp22.suse.cz>
References: <1459951996-12875-1-git-send-email-mhocko@kernel.org>
 <1459951996-12875-3-git-send-email-mhocko@kernel.org>
 <201604072038.CHC51027.MSJOFVLHOFFtQO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201604072038.CHC51027.MSJOFVLHOFFtQO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, oleg@redhat.com

On Thu 07-04-16 20:38:43, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > @@ -563,6 +582,53 @@ static void wake_oom_reaper(struct task_struct *tsk)
> >  	wake_up(&oom_reaper_wait);
> >  }
> >  
> > +/* Check if we can reap the given task. This has to be called with stable
> > + * tsk->mm
> > + */
> > +static void try_oom_reaper(struct task_struct *tsk)
> > +{
> > +	struct mm_struct *mm = tsk->mm;
> > +	struct task_struct *p;
> > +
> > +	if (!mm)
> > +		return;
> > +
> > +	/*
> > +	 * There might be other threads/processes which are either not
> > +	 * dying or even not killable.
> > +	 */
> > +	if (atomic_read(&mm->mm_users) > 1) {
> > +		rcu_read_lock();
> > +		for_each_process(p) {
> > +			bool exiting;
> > +
> > +			if (!process_shares_mm(p, mm))
> > +				continue;
> > +			if (same_thread_group(p, tsk))
> > +				continue;
> > +			if (fatal_signal_pending(p))
> > +				continue;
> > +
> > +			/*
> > +			 * If the task is exiting make sure the whole thread group
> > +			 * is exiting and cannot acces mm anymore.
> > +			 */
> > +			spin_lock_irq(&p->sighand->siglock);
> > +			exiting = signal_group_exit(p->signal);
> > +			spin_unlock_irq(&p->sighand->siglock);
> > +			if (exiting)
> > +				continue;
> > +
> > +			/* Give up */
> > +			rcu_read_unlock();
> > +			return;
> > +		}
> > +		rcu_read_unlock();
> > +	}
> > +
> > +	wake_oom_reaper(tsk);
> > +}
> > +
> 
> I think you want to change "try_oom_reaper() without wake_oom_reaper()"
> as mm_is_reapable() and use it from oom_kill_process() in order to skip
> p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN test which needlessly makes
> can_oom_reap false.

Not sure I understand the OOM_SCORE_ADJ_MIN part. We cannot reap the
task if somebody sharing the mm is OOM_SCORE_ADJ_MIN. We have to check
this in oom_kill_process because we are sending SIGKILL but we do not
have to check for this explicitly in try_oom_reaper because we only care
about exiting/killed tasks.

[...]

> > @@ -873,6 +926,7 @@ bool out_of_memory(struct oom_control *oc)
> >  	if (current->mm &&
> >  	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
> >  		mark_oom_victim(current);
> > +		try_oom_reaper(current);
> >  		return true;
> >  	}
> >  
> 
> Why don't you call try_oom_reaper() from the shortcuts in
> mem_cgroup_out_of_memory() as well?

I have focused on the global case and the correctness for now. But I
agree we can safely squash mem_cgroup_out_of_memory part into the patch
as well. Thanks for pointing this out.

> Why don't you embed try_oom_reaper() into mark_oom_victim() like I did at
> http://lkml.kernel.org/r/201602052014.HBG52666.HFMOQVLFOSFJtO@I-love.SAKURA.ne.jp ?

it didn't fit in the current flow of oom_kill_process where we do:
do_send_sig_info(victim)
mark_oom_victim(victim)
kill_sharing_tasks

so in the case of shared mm we wouldn't schedule the task for the reaper
most likely because we have to kill them first.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
