Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id AE1B76B000A
	for <linux-mm@kvack.org>; Fri, 10 Aug 2018 07:16:06 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id h26-v6so3184563eds.14
        for <linux-mm@kvack.org>; Fri, 10 Aug 2018 04:16:06 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a16-v6si741025edc.228.2018.08.10.04.16.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Aug 2018 04:16:05 -0700 (PDT)
Date: Fri, 10 Aug 2018 13:16:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/4] mm, oom: Fix unnecessary killing of additional
 processes.
Message-ID: <20180810111604.GA1644@dhcp22.suse.cz>
References: <1533389386-3501-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1533389386-3501-4-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180806134550.GO19540@dhcp22.suse.cz>
 <alpine.DEB.2.21.1808061315220.43071@chino.kir.corp.google.com>
 <20180806205121.GM10003@dhcp22.suse.cz>
 <alpine.DEB.2.21.1808091311030.244858@chino.kir.corp.google.com>
 <20180810090735.GY1644@dhcp22.suse.cz>
 <be42a7c0-015e-2992-a40d-20af21e8c0fc@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <be42a7c0-015e-2992-a40d-20af21e8c0fc@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Roman Gushchin <guro@fb.com>

On Fri 10-08-18 19:54:39, Tetsuo Handa wrote:
> On 2018/08/10 18:07, Michal Hocko wrote:
> >> Yes, of course, it would be easy to rely on exit_mmap() to set 
> >> MMF_OOM_SKIP itself and have the oom reaper drop the task from its list 
> >> when we are assured of forward progress.  What polling are you proposing 
> >> other than a timeout based mechanism to do this?
> > 
> > I was thinking about doing something like the following
> > - oom_reaper checks the amount of victim's memory after it is done with
> >   reaping (e.g. by calling oom_badness before and after). 
> 
> OK. We can apply
> 
> +static inline unsigned long oom_victim_mm_score(struct mm_struct *mm)
> +{
> +	return get_mm_rss(mm) + get_mm_counter(mm, MM_SWAPENTS) +
> +		mm_pgtables_bytes(mm) / PAGE_SIZE;
> +}
> 
> and
> 
> -	points = get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS) +
> -		mm_pgtables_bytes(p->mm) / PAGE_SIZE;
> +	points = oom_victim_mm_score(p->mm);
> 
> part, can't we?
> 
> >                                                           If it wasn't able to
> >   reclaim much then return false and keep retrying with the existing
> >   mechanism
> 
> How do you decide whether oom_reaper() was not able to reclaim much?

Just a rule of thumb. If it freed at least few kBs then we should be good
to MMF_OOM_SKIP.
 
> > - once a flag (e.g. MMF_OOM_MMAP) is set it bails out and won't set the
> >   MMF_OOM_SKIP flag.
> 
> Unless oom_victim_mm_score() becomes close to 0, setting MMF_OOM_SKIP is
> considered premature. oom_reaper() will have to keep retrying....

there absolutely have to be a cap for retrying. Otherwise you have
lockup scenarios back when the memory is mostly consumed by page tables.

> >> We could set a MMF_EXIT_MMAP in exit_mmap() to specify that it will 
> >> complete free_pgtables() for that mm.  The problem is the same: when does 
> >> the oom reaper decide to set MMF_OOM_SKIP because MMF_EXIT_MMAP has not 
> >> been set in a timely manner?
> > 
> > reuse the current retry policy which is the number of attempts rather
> > than any timeout.
> 
> And this is really I can't understand. The number of attempts multiplied
> by retry interval _is_ nothing but timeout.

Yes it is a timeout but it is not the time that matters. It is that we
have tried sufficient times. Looks at it this way. You can retry 5 times
in 10s or just once. Depending on what is going on in the system. I
would really prefer the behavior to be deterministic.

> We are already using timeout based decision, with some attempt to reclaim
> memory if conditions are met.

Timeout based decision is when you, well, make a decision after a
certain time passes. And we do not do that.
 
> >> If this is an argument that the oom reaper should loop checking for 
> >> MMF_EXIT_MMAP and doing schedule_timeout(1) a set number of times rather 
> >> than just setting the jiffies in the mm itself, that's just implementing 
> >> the same thing and doing so in a way where the oom reaper stalls operating 
> >> on a single mm rather than round-robin iterating over mm's in my patch.
> > 
> > I've said earlier that I do not mind doing round robin in the oom repaer
> > but this is certainly more complex than what we do now and I haven't
> > seen any actual example where it would matter. OOM reaper is a safely
> > measure. Nothing should fall apart if it is slow. 
> 
> The OOM reaper can fail if allocating threads have high priority. You seem to
> assume that realtime threads won't trigger OOM path. But since !PF_WQ_WORKER
> threads do only cond_resched() due to your "the cargo cult programming" refusal,
> and like Andrew Morton commented
> 
>   cond_resched() is a no-op in the presence of realtime policy threads
>   and using to attempt to yield to a different thread it in this fashion
>   is broken.
> 
> at "mm: disable preemption before swapcache_free" thread, we can't guarantee
> that allocating threads shall give the OOM reaper enough CPU resource for
> making forward progress. And my direct OOM reaping proposal was also refused
> by you. I really dislike counting OOM reaper as a safety measure.

Well, yeah, you can screw up your system with real time priority tasks
all you want. I really fail to see why you are bringing that up now
though. Yet another offtopic?

-- 
Michal Hocko
SUSE Labs
