Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6518B6B0253
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 04:20:30 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p87so4371469pfj.21
        for <linux-mm@kvack.org>; Fri, 27 Oct 2017 01:20:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l87si4956821pfj.597.2017.10.27.01.20.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 27 Oct 2017 01:20:29 -0700 (PDT)
Date: Fri, 27 Oct 2017 10:20:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
Message-ID: <20171027082025.r3cauztayjlmc4lj@dhcp22.suse.cz>
References: <20171025131151.GA8210@cmpxchg.org>
 <20171025141221.xm4cqp2z6nunr6vy@dhcp22.suse.cz>
 <20171025164402.GA11582@cmpxchg.org>
 <20171025172924.i7du5wnkeihx2fgl@dhcp22.suse.cz>
 <20171025181106.GA14967@cmpxchg.org>
 <20171025190057.mqmnprhce7kvsfz7@dhcp22.suse.cz>
 <20171025211359.GA17899@cmpxchg.org>
 <xr931slqdery.fsf@gthelen.svl.corp.google.com>
 <20171026143140.GB21147@cmpxchg.org>
 <xr93y3nxbs3j.fsf@gthelen.svl.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <xr93y3nxbs3j.fsf@gthelen.svl.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Shakeel Butt <shakeelb@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Thu 26-10-17 12:56:48, Greg Thelen wrote:
> Michal Hocko wrote:
> > Greg Thelen wrote:
> > > So a force charge fallback might be a needed even with oom killer successful
> > > invocations.  Or we'll need to teach out_of_memory() to return three values
> > > (e.g. NO_VICTIM, NEW_VICTIM, PENDING_VICTIM) and try_charge() can loop on
> > > NEW_VICTIM.
> > 
> > No we, really want to wait for the oom victim to do its job. The only thing we
> > should be worried about is when out_of_memory doesn't invoke the reaper. There
> > is only one case like that AFAIK - GFP_NOFS request. I have to think about
> > this case some more. We currently fail in that case the request.
> 
> Nod, but I think only wait a short time (more below).  The
> schedule_timeout_killable(1) in out_of_memory() seems ok to me.  I don't
> think there's a problem overcharging a little bit to expedite oom
> killing.

This is not about time. This is about the feedback mechanism oom_reaper
provides. We should do any actions until we get that feedback.

> Johannes Weiner wrote:
> > True. I was assuming we'd retry MEM_CGROUP_RECLAIM_RETRIES times at a maximum,
> > even if the OOM killer indicates a kill has been issued. What you propose
> > makes sense too.
> 
> Sounds good.
> 
> It looks like the oom reaper will wait 1 second
> (MAX_OOM_REAP_RETRIES*HZ/10) before giving up and setting MMF_OOM_SKIP,
> which enables the oom killer to select another victim.  Repeated
> try_charge() => out_of_memory() calls will return true while there's a
> pending victim.  After the first call, out_of_memory() doesn't appear to
> sleep.  So I assume try_charge() would quickly burn through
> MEM_CGROUP_RECLAIM_RETRIES (5) attempts before resorting to
> overcharging.  IMO, this is fine because:
> 1) it's possible the victim wants locks held by try_charge caller.  So
>    waiting for the oom reaper to timeout and out_of_memory to select
>    additional victims would kill more than required.
> 2) waiting 1 sec to detect a livelock between try_charge() and pending
>    oom victim seems unfortunate.

I am not yet sure whether overcharging or ENOMEM is the right way to go
(have to think through that much more) but one thing is clear I guess.
The charge path shouldn't do any decision as long as it gets a possitive
feedback from the oom killer path. And that pretty much depend on what
oom reaper is able to do. Implementation details about how much the
reaper waits if it is not able reclaim any memory is not all that
important.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
