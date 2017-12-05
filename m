Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id BE4796B0275
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 05:46:13 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id c9so11333313wrb.4
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 02:46:13 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id y102si88529ede.315.2017.12.05.02.46.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 05 Dec 2017 02:46:11 -0800 (PST)
Date: Tue, 5 Dec 2017 10:46:01 +0000
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/3] mm,oom: Move last second allocation to inside the
 OOM killer.
Message-ID: <20171205104601.GA1898@cmpxchg.org>
References: <1511607169-5084-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171201143317.GC8097@cmpxchg.org>
 <20171201144634.sc4cn6hyyt6zawms@dhcp22.suse.cz>
 <20171201145638.GA10280@cmpxchg.org>
 <20171201151715.yiep5wkmxmp77nxn@dhcp22.suse.cz>
 <20171201155711.GA11057@cmpxchg.org>
 <20171201163830.on5mykdtet2wa5is@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171201163830.on5mykdtet2wa5is@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>

On Fri, Dec 01, 2017 at 05:38:30PM +0100, Michal Hocko wrote:
> On Fri 01-12-17 15:57:11, Johannes Weiner wrote:
> > On Fri, Dec 01, 2017 at 04:17:15PM +0100, Michal Hocko wrote:
> > > On Fri 01-12-17 14:56:38, Johannes Weiner wrote:
> > > > On Fri, Dec 01, 2017 at 03:46:34PM +0100, Michal Hocko wrote:
> > > > > On Fri 01-12-17 14:33:17, Johannes Weiner wrote:
> > > > > > On Sat, Nov 25, 2017 at 07:52:47PM +0900, Tetsuo Handa wrote:
> > > > > > > @@ -1068,6 +1071,17 @@ bool out_of_memory(struct oom_control *oc)
> > > > > > >  	}
> > > > > > >  
> > > > > > >  	select_bad_process(oc);
> > > > > > > +	/*
> > > > > > > +	 * Try really last second allocation attempt after we selected an OOM
> > > > > > > +	 * victim, for somebody might have managed to free memory while we were
> > > > > > > +	 * selecting an OOM victim which can take quite some time.
> > > > > > 
> > > > > > Somebody might free some memory right after this attempt fails. OOM
> > > > > > can always be a temporary state that resolves on its own.
> > > > > > 
> > > > > > What keeps us from declaring OOM prematurely is the fact that we
> > > > > > already scanned the entire LRU list without success, not last second
> > > > > > or last-last second, or REALLY last-last-last-second allocations.
> > > > > 
> > > > > You are right that this is inherently racy. The point here is, however,
> > > > > that the race window between the last check and the kill can be _huge_!
> > > > 
> > > > My point is that it's irrelevant. We already sampled the entire LRU
> > > > list; compared to that, the delay before the kill is immaterial.
> > > 
> > > Well, I would disagree. I have seen OOM reports with a free memory.
> > > Closer debugging shown that an existing process was on the way out and
> > > the oom victim selection took way too long and fired after a large
> > > process manage. There were different hacks^Wheuristics to cover those
> > > cases but they turned out to just cause different corner cases. Moving
> > > the existing last moment allocation after a potentially very time
> > > consuming action is relatively cheap and safe measure to cover those
> > > cases without any negative side effects I can think of.
> > 
> > An existing process can exit right after you pull the trigger. How big
> > is *that* race window? By this logic you could add a sleep(5) before
> > the last-second allocation because it would increase the likelihood of
> > somebody else exiting voluntarily.
> 
> Please read what I wrote above again. I am not saying this is _closing_
> the any race. It however reduces the race window which I find generally
> a good thing. Especially when there are no other negative side effects.

Please read what I wrote. OOM conditions are not steady states, so you
are shaving cycles off a race window that is indefinite in size.

> > This patch is making the time it takes to select a victim an integral
> > part of OOM semantics. Think about it: if somebody later speeds up the
> > OOM selection process, they shrink the window in which somebody could
> > volunteer memory for the last-second allocation. By optimizing that
> > code, you're probabilistically increasing the rate of OOM kills.
> >
> > A guaranteed 5 second window would in fact be better behavior.
> > 
> > This is bananas. I'm sticking with my nak.
> 
> So are you saying that the existing last allocation attempt is more
> reasonable? I've tried to remove it [1] and you were against that.
> 
> All I'am trying to tell is that _if_ we want to have something like
> the last moment allocation after reclaim gave up then it should happen
> closer to the killing the actual disruptive operation. The current
> attempt in __alloc_pages_may_oom makes only very little sense to me.

Yes, you claim that, but you're not making a convincing case to me.

That last attempt serializes OOM conditions. It doesn't matter where
it is before the OOM kill as long as it's inside the OOM lock, because
these are the outcomes from the locked section:

	1. It's the first invocation, nothing is on the freelist, no
	task has TIF_MEMDIE set. Choose a victim and kill.

	2. It's the second invocation, the first invocation is still
	active. The trylock fails and we retry.

	3. It's the second invocation, a victim has been dispatched
	but nothing has been freed. TIF_MEMDIE is found, we retry.

	4. It's the second invocation, a victim has died (or been
	reaped) and freed memory. The allocation succeeds.

That's how the OOM state machine works in the presence of multiple
allocating threads, and the code as is makes perfect sense to me.

Your argument for moving the allocation attempt closer to the kill is
because the OOM kill is destructive and we don't want it to happen
when something unrelated happens to free memory during the victim
selection. I do understand that.

My argument against doing that is that the OOM kill is destructive and
we want it tied to memory pressure as determined by reclaim, not
random events we don't have control over, so that users can test the
safety of the memory pressure created by their applications before
putting them into production environments.

We'd give up a certain amount of determinism and reproducibility, and
introduce unexpected implementation-defined semantics (currently the
sampling window for pressure is reclaim time, afterwards it would
include OOM victim selection time), in an attempt to probabilistically
reduce OOM kills under severe memory pressure by an unknown factor.

This might sound intriguing when you only focus on the split second
between the last reclaim attempt and when we issue the kill - "hey,
look, here is one individual instance of a kill I could have avoided
by exploiting a race condition."

But it's bad system behavior. For most users OOM kills are extremely
disruptive. Literally the only way to make them any worse is by making
them unpredictable and less reproducible.

I do understand the upsides you're advocating for - although you
haven't quantified them. They're just not worth the downsides.

Hence the nak.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
