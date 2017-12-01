Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 782F26B0038
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 11:38:36 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id w22so6757529pge.10
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 08:38:36 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b70si5489950pfk.47.2017.12.01.08.38.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Dec 2017 08:38:35 -0800 (PST)
Date: Fri, 1 Dec 2017 17:38:30 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 1/3] mm,oom: Move last second allocation to inside the
 OOM killer.
Message-ID: <20171201163830.on5mykdtet2wa5is@dhcp22.suse.cz>
References: <1511607169-5084-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171201143317.GC8097@cmpxchg.org>
 <20171201144634.sc4cn6hyyt6zawms@dhcp22.suse.cz>
 <20171201145638.GA10280@cmpxchg.org>
 <20171201151715.yiep5wkmxmp77nxn@dhcp22.suse.cz>
 <20171201155711.GA11057@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171201155711.GA11057@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>

On Fri 01-12-17 15:57:11, Johannes Weiner wrote:
> On Fri, Dec 01, 2017 at 04:17:15PM +0100, Michal Hocko wrote:
> > On Fri 01-12-17 14:56:38, Johannes Weiner wrote:
> > > On Fri, Dec 01, 2017 at 03:46:34PM +0100, Michal Hocko wrote:
> > > > On Fri 01-12-17 14:33:17, Johannes Weiner wrote:
> > > > > On Sat, Nov 25, 2017 at 07:52:47PM +0900, Tetsuo Handa wrote:
> > > > > > @@ -1068,6 +1071,17 @@ bool out_of_memory(struct oom_control *oc)
> > > > > >  	}
> > > > > >  
> > > > > >  	select_bad_process(oc);
> > > > > > +	/*
> > > > > > +	 * Try really last second allocation attempt after we selected an OOM
> > > > > > +	 * victim, for somebody might have managed to free memory while we were
> > > > > > +	 * selecting an OOM victim which can take quite some time.
> > > > > 
> > > > > Somebody might free some memory right after this attempt fails. OOM
> > > > > can always be a temporary state that resolves on its own.
> > > > > 
> > > > > What keeps us from declaring OOM prematurely is the fact that we
> > > > > already scanned the entire LRU list without success, not last second
> > > > > or last-last second, or REALLY last-last-last-second allocations.
> > > > 
> > > > You are right that this is inherently racy. The point here is, however,
> > > > that the race window between the last check and the kill can be _huge_!
> > > 
> > > My point is that it's irrelevant. We already sampled the entire LRU
> > > list; compared to that, the delay before the kill is immaterial.
> > 
> > Well, I would disagree. I have seen OOM reports with a free memory.
> > Closer debugging shown that an existing process was on the way out and
> > the oom victim selection took way too long and fired after a large
> > process manage. There were different hacks^Wheuristics to cover those
> > cases but they turned out to just cause different corner cases. Moving
> > the existing last moment allocation after a potentially very time
> > consuming action is relatively cheap and safe measure to cover those
> > cases without any negative side effects I can think of.
> 
> An existing process can exit right after you pull the trigger. How big
> is *that* race window? By this logic you could add a sleep(5) before
> the last-second allocation because it would increase the likelihood of
> somebody else exiting voluntarily.

Please read what I wrote above again. I am not saying this is _closing_
the any race. It however reduces the race window which I find generally
a good thing. Especially when there are no other negative side effects.
 
> This patch is making the time it takes to select a victim an integral
> part of OOM semantics. Think about it: if somebody later speeds up the
> OOM selection process, they shrink the window in which somebody could
> volunteer memory for the last-second allocation. By optimizing that
> code, you're probabilistically increasing the rate of OOM kills.
>
> A guaranteed 5 second window would in fact be better behavior.
> 
> This is bananas. I'm sticking with my nak.

So are you saying that the existing last allocation attempt is more
reasonable? I've tried to remove it [1] and you were against that.

All I'am trying to tell is that _if_ we want to have something like
the last moment allocation after reclaim gave up then it should happen
closer to the killing the actual disruptive operation. The current
attempt in __alloc_pages_may_oom makes only very little sense to me.

[1] http://lkml.kernel.org/r/1454013603-3682-1-git-send-email-mhocko@kernel.org
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
