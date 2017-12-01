Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3FFC86B0038
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 11:52:45 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id p144so2474154itc.9
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 08:52:45 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 16si5157363iob.23.2017.12.01.08.52.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Dec 2017 08:52:43 -0800 (PST)
Subject: Re: [PATCH 1/3] mm,oom: Move last second allocation to inside the OOM killer.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20171201143317.GC8097@cmpxchg.org>
	<20171201144634.sc4cn6hyyt6zawms@dhcp22.suse.cz>
	<20171201145638.GA10280@cmpxchg.org>
	<20171201151715.yiep5wkmxmp77nxn@dhcp22.suse.cz>
	<20171201155711.GA11057@cmpxchg.org>
In-Reply-To: <20171201155711.GA11057@cmpxchg.org>
Message-Id: <201712020152.GCI81290.QtLHOFJMFFSOVO@I-love.SAKURA.ne.jp>
Date: Sat, 2 Dec 2017 01:52:30 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@suse.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, aarcange@redhat.com

Johannes Weiner wrote:
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

"[PATCH 3/3] mm,oom: Remove oom_lock serialization from the OOM reaper." says
that doing last second allocation attempt after select_bad_process() should
help the OOM reaper to free memory compared to doing last second allocation
before select_bad_process().

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

Sleeping with oom_lock held is bad. Even schedule_timeout_killable(1) at
out_of_memory() can allow the owner of oom_lock sleep effectively forever
when many threads are hitting mutex_trylock(&oom_lock) at
__alloc_pages_may_oom(). Let alone adding sleep(5) before sending SIGKILL
and waking up the OOM reaper.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
