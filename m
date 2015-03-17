Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id D3E686B006C
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 06:25:12 -0400 (EDT)
Received: by wetk59 with SMTP id k59so3959734wet.3
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 03:25:12 -0700 (PDT)
Received: from mail-wi0-x232.google.com (mail-wi0-x232.google.com. [2a00:1450:400c:c05::232])
        by mx.google.com with ESMTPS id h6si22727769wjf.31.2015.03.17.03.25.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Mar 2015 03:25:11 -0700 (PDT)
Received: by wibg7 with SMTP id g7so59215386wib.1
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 03:25:10 -0700 (PDT)
Date: Tue, 17 Mar 2015 11:25:08 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2 v2] mm: Allow small allocations to fail
Message-ID: <20150317102508.GG28112@dhcp22.suse.cz>
References: <1426107294-21551-1-git-send-email-mhocko@suse.cz>
 <1426107294-21551-2-git-send-email-mhocko@suse.cz>
 <201503151443.CFE04129.MVFOOStLFHFOQJ@I-love.SAKURA.ne.jp>
 <20150315121317.GA30685@dhcp22.suse.cz>
 <201503152206.AGJ22930.HOStFFFQLVMOOJ@I-love.SAKURA.ne.jp>
 <20150316074607.GA24885@dhcp22.suse.cz>
 <20150316211146.GA15456@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150316211146.GA15456@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, david@fromorbit.com, mgorman@suse.de, riel@redhat.com, fengguang.wu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 16-03-15 17:11:46, Johannes Weiner wrote:
> On Mon, Mar 16, 2015 at 08:46:07AM +0100, Michal Hocko wrote:
> > @@ -707,6 +708,29 @@ sysctl, it will revert to this default behavior.
> >  
> >  ==============================================================
> >  
> > +retry_allocation_attempts
> > +
> > +Page allocator tries hard to not fail small allocations requests.
> > +Currently it retries indefinitely for small allocations requests (<= 32kB).
> > +This works mostly fine but under an extreme low memory conditions system
> > +might end up in deadlock situations because the looping allocation
> > +request might block further progress for OOM killer victims.
> > +
> > +Even though this hasn't turned out to be a huge problem for many years the
> > +long term plan is to move away from this default behavior but as this is
> > +a long established behavior we cannot change it immediately.
> > +
> > +This knob should help in the transition. It tells how many times should
> > +allocator retry when the system is OOM before the allocation fails.
> > +The default value (ULONG_MAX) preserves the old behavior. This is a safe
> > +default for production systems which cannot afford any unexpected
> > +downtimes. More experimental systems might set it to a small number
> > +(>=1), the higher the value the less probable would be allocation
> > +failures when OOM is transient and could be resolved without the
> > +particular allocation to fail.
> 
> This is a negotiation between the page allocator and the various
> requirements of its in-kernel users.  If *we* can't make an educated
> guess with the entire codebase available, how the heck can we expect
> userspace to?
> 
> And just assuming for a second that they actually do a better job than
> us, are they going to send us a report of their workload and machine
> specs and the value that worked for them?  Of course not, why would
> you think they'd suddenly send anything but regression reports?
>
> And we wouldn't get regression reports without changing the default,
> because really, what is the incentive to mess with that knob?  Making
> a lockup you probably never encountered less likely to trigger, while
> adding failures of unknown quantity or quality into the system?
> 
> This is truly insane.  You're taking one magic factor out of a complex
> kernel mechanism and dump it on userspace, which has neither reason
> nor context to meaningfully change the default.  We'd never leave that
> state of transition.  Only when machines do lock up in the wild, at
> least we can tell them they should have set this knob to "like, 50?"
> 
> If we want to address this problem, we are the ones that have to make
> the call.  Pick a value based on a reasonable model, make it the
> default, then deal with the fallout and update our assumptions.
> 
> Once that is done, whether we want to provide a boolean failsafe to
> revert this in the field is another question.

I have no problem having the behavior enabled/disabled rather than a
number if people think this is a better idea. This is the primary point
I've posted this to linux-api mailing list as well. I definitely do not
want to get stuck in the pick your number discussion.

> A sysctl certainly doesn't sound appropriate to me because this is not
> a tunable that we expect people to set according to their usecase.  We
> expect our model to work for *everybody*.  A boot flag would be
> marginally better but it still reeks too much of tunable.

I am OK with a boot option as well if the sysctl is considered
inappropriate. It is less flexible though. Consider a regression testing
where the same load is run 2 times once with failing allocations and
once without it. Why should we force the tester to do a reboot cycle?
 
> Maybe CONFIG_FAILABLE_SMALL_ALLOCS.  Maybe something more euphemistic.
> But I honestly can't think of anything that wouldn't scream "horrible
> leak of implementation details."  The user just shouldn't ever care.

Any config option basically means that distribution users will not get
to test this until distributions change the default and this won't
happen until the testing coverage and period was sufficient. See the
chicken and egg problem? This is basically undermining the whole idea
about the voluntary testing. So no, I really do not like this.
 
> Given that there are usually several stages of various testing between
> when a commit gets merged upstream and when it finally makes it into a
> critical production system, maybe we don't need to provide userspace
> control over this at all?

I can still see conservative users not changing this behavior _ever_.
Even after the rest of the world trusts the new default. They should
have a way to disable it. Many of those are running distribution kernels
so they really need a way to control the behavior. Be it a boot time
option or sysctl. Historically we were using sysctl for backward
compatibility and I do not see any reason to be different here as well.

> So what value do we choose?
> 
> Once we kick the OOM killer we should give the victim some time to
> exit and then try the allocation again.  Looping just ONCE after that
> means we scan all the LRU pages in the system a second time and invoke
> the shrinkers another twelve times, with ratios approaching 1.  If the
> OOM killer doesn't yield an allocatable page after this, I see very
> little point in going on.  After all, we expect all our callers to
> handle errors.

I am OK with the single retry. As shown with the tests the same load
might end up with less allocation failures with the higher values but
that is a detail. Users of !GFP_NOFAIL should be prepared for failures
and the if the failures are too excessive I agree this should be
addressed in the page allocator.
 
> So why not just pass an "oomed" bool to should_alloc_retry() and bail
> on small allocations at that point?  Put it upstream and deal with the
> fallout long before this hits critical infrastructure?  By presumably
> fixing up caller error handling and GFP flags?

This is way too risky IMO. We cannot change a long established behavior
that quickly. I do agree we should allow failing in linux-next and
development trees. So that it is us kernel developers to start testing
first. Then we have zero day testing projects and Fenguang has shown an
interest in this as well. I would also expect/hoped for some testing
internal within major distributions. We are no way close to have this
default behavior in the Linus tree, though.

That is why I've proposed 3 steps 1) voluntary testers, 2) distributions
default 3) upstream default. Why don't you think this is a proper
approach?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
