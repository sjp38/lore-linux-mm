Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1D6D76B0005
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 21:32:22 -0500 (EST)
Received: by mail-ig0-f171.google.com with SMTP id hb3so47021407igb.0
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 18:32:22 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id h19si24961568ioh.25.2016.02.19.18.32.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Feb 2016 18:32:21 -0800 (PST)
Subject: Re: [PATCH 6/5] oom, oom_reaper: disable oom_reaper for oom_kill_allocating_task
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
	<1454505240-23446-6-git-send-email-mhocko@kernel.org>
	<20160217094855.GC29196@dhcp22.suse.cz>
	<20160219183419.GA30059@dhcp22.suse.cz>
In-Reply-To: <20160219183419.GA30059@dhcp22.suse.cz>
Message-Id: <201602201132.EFG90182.FOVtSOJHFOLFQM@I-love.SAKURA.ne.jp>
Date: Sat, 20 Feb 2016 11:32:07 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Wed 17-02-16 10:48:55, Michal Hocko wrote:
> > Hi Andrew,
> > although this can be folded into patch 5
> > (mm-oom_reaper-implement-oom-victims-queuing.patch) I think it would be
> > better to have it separate and revert after we sort out the proper
> > oom_kill_allocating_task behavior or handle exclusion at oom_reaper
> > level.
> 
> An alternative would be something like the following. It is definitely
> less hackish but it steals one bit in mm->flags. We do not seem to be
> in shortage there now but who knows. Does this sound better? Later
> changes might even consider the flag for the victim selection and ignore
> those which already have the flag set. But I didn't think about it more
> to form a patch yet.

This sounds better than "can_oom_reap = !sysctl_oom_kill_allocating_task;".

> @@ -740,6 +740,10 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  	/* Get a reference to safely compare mm after task_unlock(victim) */
>  	mm = victim->mm;
>  	atomic_inc(&mm->mm_count);
> +
> +	/* Make sure we do not try to oom reap the mm multiple times */
> +	can_oom_reap = !test_and_set_bit(MMF_OOM_KILLED, &mm->flags);
> +
>  	/*
>  	 * We should send SIGKILL before setting TIF_MEMDIE in order to prevent
>  	 * the OOM victim from depleting the memory reserves from the user

But as of this line we don't know whether this mm is reapable.

Shouldn't this be done like

  static void wake_oom_reaper(struct task_struct *tsk)
  {
          /* Make sure we do not try to oom reap the mm multiple times */
          if (!oom_reaper_th || !test_and_set_bit(MMF_OOM_KILLED, &mm->flags))
                  return;

          get_task_struct(tsk);

          spin_lock(&oom_reaper_lock);
          list_add(&tsk->oom_reaper_list, &oom_reaper_list);
          spin_unlock(&oom_reaper_lock);
          wake_up(&oom_reaper_wait);
  }

?

Moreover, why don't you do like

  struct mm_struct {
  	(...snipped...)
  	struct list_head oom_reaper_list;
  	(...snipped...)
  }

than

  struct task_struct {
  	(...snipped...)
  	struct list_head oom_reaper_list;
  	(...snipped...)
  }

so that we can update all ->oom_score_adj using this mm_struct for handling
crazy combo ( http://lkml.kernel.org/r/20160204163113.GF14425@dhcp22.suse.cz ) ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
