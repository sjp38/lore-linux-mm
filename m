Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id C1B9F6B0009
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 04:41:08 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id g62so162953486wme.1
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 01:41:08 -0800 (PST)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id v125si19680908wme.79.2016.02.22.01.41.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Feb 2016 01:41:07 -0800 (PST)
Received: by mail-wm0-f51.google.com with SMTP id g62so154717286wme.0
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 01:41:07 -0800 (PST)
Date: Mon, 22 Feb 2016 10:41:05 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 6/5] oom, oom_reaper: disable oom_reaper for
 oom_kill_allocating_task
Message-ID: <20160222094105.GD17938@dhcp22.suse.cz>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
 <1454505240-23446-6-git-send-email-mhocko@kernel.org>
 <20160217094855.GC29196@dhcp22.suse.cz>
 <20160219183419.GA30059@dhcp22.suse.cz>
 <201602201132.EFG90182.FOVtSOJHFOLFQM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602201132.EFG90182.FOVtSOJHFOLFQM@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 20-02-16 11:32:07, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 17-02-16 10:48:55, Michal Hocko wrote:
> > > Hi Andrew,
> > > although this can be folded into patch 5
> > > (mm-oom_reaper-implement-oom-victims-queuing.patch) I think it would be
> > > better to have it separate and revert after we sort out the proper
> > > oom_kill_allocating_task behavior or handle exclusion at oom_reaper
> > > level.
> > 
> > An alternative would be something like the following. It is definitely
> > less hackish but it steals one bit in mm->flags. We do not seem to be
> > in shortage there now but who knows. Does this sound better? Later
> > changes might even consider the flag for the victim selection and ignore
> > those which already have the flag set. But I didn't think about it more
> > to form a patch yet.
> 
> This sounds better than "can_oom_reap = !sysctl_oom_kill_allocating_task;".
> 
> > @@ -740,6 +740,10 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
> >  	/* Get a reference to safely compare mm after task_unlock(victim) */
> >  	mm = victim->mm;
> >  	atomic_inc(&mm->mm_count);
> > +
> > +	/* Make sure we do not try to oom reap the mm multiple times */
> > +	can_oom_reap = !test_and_set_bit(MMF_OOM_KILLED, &mm->flags);
> > +
> >  	/*
> >  	 * We should send SIGKILL before setting TIF_MEMDIE in order to prevent
> >  	 * the OOM victim from depleting the memory reserves from the user
> 
> But as of this line we don't know whether this mm is reapable.

Which is not really important. We know that it is eligible only if the
mm wasn't a part of the OOM kill before. Later checks are, of course,
allowed to veto the default and disable the oom reaper.

> Shouldn't this be done like
> 
>   static void wake_oom_reaper(struct task_struct *tsk)
>   {
>           /* Make sure we do not try to oom reap the mm multiple times */
>           if (!oom_reaper_th || !test_and_set_bit(MMF_OOM_KILLED, &mm->flags))
>                   return;

We do not have the mm here. We have a task and would need the task_lock.
I find it much easier to evaluate mm while we still have it and we know
the task holding this mm will receive SIGKILL and TIF_MEMDIE.
 
>           get_task_struct(tsk);
> 
>           spin_lock(&oom_reaper_lock);
>           list_add(&tsk->oom_reaper_list, &oom_reaper_list);
>           spin_unlock(&oom_reaper_lock);
>           wake_up(&oom_reaper_wait);
>   }
> 
> ?
> 
> Moreover, why don't you do like
> 
>   struct mm_struct {
>   	(...snipped...)
>   	struct list_head oom_reaper_list;
>   	(...snipped...)
>   }

Because we would need to search all tasks sharing the same mm in order
to exit_oom_victim.

> than
> 
>   struct task_struct {
>   	(...snipped...)
>   	struct list_head oom_reaper_list;
>   	(...snipped...)
>   }
> 
> so that we can update all ->oom_score_adj using this mm_struct for handling
> crazy combo ( http://lkml.kernel.org/r/20160204163113.GF14425@dhcp22.suse.cz ) ?

I find it much easier to to simply skip over tasks with MMF_OOM_KILLED
when already selecting a victim. We won't need oom_score_adj games at
all. This needs a deeper evaluation though. I didn't get to it yet,
but the point of having MMF flag which is not oom_reaper specific
was to have it reusable in other contexts as well.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
