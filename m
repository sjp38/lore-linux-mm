Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 91A656B0667
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 03:06:11 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id g71so1051903wmg.13
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 00:06:11 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g53si986529wrg.284.2017.08.03.00.06.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Aug 2017 00:06:09 -0700 (PDT)
Date: Thu, 3 Aug 2017 09:06:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, oom: do not rely on TIF_MEMDIE for memory
 reserves access
Message-ID: <20170803070606.GA12521@dhcp22.suse.cz>
References: <20170727090357.3205-1-mhocko@kernel.org>
 <20170727090357.3205-2-mhocko@kernel.org>
 <201708020030.ACB04683.JLHMFVOSFFOtOQ@I-love.SAKURA.ne.jp>
 <20170801165242.GA15518@dhcp22.suse.cz>
 <201708031039.GDG05288.OQJOHtLVFMSFFO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201708031039.GDG05288.OQJOHtLVFMSFFO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, guro@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 03-08-17 10:39:42, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 02-08-17 00:30:33, Tetsuo Handa wrote:
> > > > @@ -3603,6 +3612,22 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
> > > >  	return alloc_flags;
> > > >  }
> > > >  
> > > > +static bool oom_reserves_allowed(struct task_struct *tsk)
> > > > +{
> > > > +	if (!tsk_is_oom_victim(tsk))
> > > > +		return false;
> > > > +
> > > > +	/*
> > > > +	 * !MMU doesn't have oom reaper so we shouldn't risk the memory reserves
> > > > +	 * depletion and shouldn't give access to memory reserves passed the
> > > > +	 * exit_mm
> > > > +	 */
> > > > +	if (!IS_ENABLED(CONFIG_MMU) && !tsk->mm)
> > > > +		return false;
> > > 
> > > Branching based on CONFIG_MMU is ugly. I suggest timeout based next OOM
> > > victim selection if CONFIG_MMU=n.
> > 
> > I suggest we do not argue about nommu without actually optimizing for or
> > fixing nommu which we are not here. I am even not sure memory reserves
> > can ever be depleted for that config.
> 
> I don't think memory reserves can deplete for CONFIG_MMU=n environment.
> But the reason the OOM reaper was introduced is not limited to handling
> depletion of memory reserves. The OOM reaper was introduced because
> OOM victims might get stuck indirectly waiting for other threads doing
> memory allocation. You said
> 
>   > Yes, exit_aio is the only blocking call I know of currently. But I would
>   > like this to be as robust as possible and so I do not want to rely on
>   > the current implementation. This can change in future and I can
>   > guarantee that nobody will think about the oom path when adding
>   > something to the final __mmput path.
> 
> at http://lkml.kernel.org/r/20170726054533.GA960@dhcp22.suse.cz , but
> how can you guarantee that nobody will think about the oom path
> when adding something to the final __mmput() path without thinking
> about possibility of getting stuck waiting for memory allocation in
> CONFIG_MMU=n environment?

Look, I really appreciate your sentiment for for nommu platform but with
an absolute lack of _any_ oom reports on that platform that I am aware
of nor any reports about lockups during oom I am less than thrilled to
add a code to fix a problem which even might not exist. Nommu is usually
very special with a very specific workload running (e.g. no overcommit)
so I strongly suspect that any OOM theories are highly academic.

All I do care about is to not regress nommu as much as possible. So can
we get back to the proposed patch and updates I have done to address
your review feedback please?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
