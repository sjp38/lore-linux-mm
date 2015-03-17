Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1F32F6B0032
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 13:26:47 -0400 (EDT)
Received: by wifj2 with SMTP id j2so17119328wif.1
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 10:26:46 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id s15si4382677wik.39.2015.03.17.10.26.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Mar 2015 10:26:45 -0700 (PDT)
Date: Tue, 17 Mar 2015 13:26:28 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2 v2] mm: Allow small allocations to fail
Message-ID: <20150317172628.GA5109@phnom.home.cmpxchg.org>
References: <1426107294-21551-1-git-send-email-mhocko@suse.cz>
 <1426107294-21551-2-git-send-email-mhocko@suse.cz>
 <201503151443.CFE04129.MVFOOStLFHFOQJ@I-love.SAKURA.ne.jp>
 <20150315121317.GA30685@dhcp22.suse.cz>
 <201503152206.AGJ22930.HOStFFFQLVMOOJ@I-love.SAKURA.ne.jp>
 <20150316074607.GA24885@dhcp22.suse.cz>
 <20150316211146.GA15456@phnom.home.cmpxchg.org>
 <20150317102508.GG28112@dhcp22.suse.cz>
 <20150317132926.GA1824@phnom.home.cmpxchg.org>
 <20150317141729.GI28112@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150317141729.GI28112@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, david@fromorbit.com, mgorman@suse.de, riel@redhat.com, fengguang.wu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 17, 2015 at 03:17:29PM +0100, Michal Hocko wrote:
> On Tue 17-03-15 09:29:26, Johannes Weiner wrote:
> > On Tue, Mar 17, 2015 at 11:25:08AM +0100, Michal Hocko wrote:
> > > On Mon 16-03-15 17:11:46, Johannes Weiner wrote:
> > > > A sysctl certainly doesn't sound appropriate to me because this is not
> > > > a tunable that we expect people to set according to their usecase.  We
> > > > expect our model to work for *everybody*.  A boot flag would be
> > > > marginally better but it still reeks too much of tunable.
> > > 
> > > I am OK with a boot option as well if the sysctl is considered
> > > inappropriate. It is less flexible though. Consider a regression testing
> > > where the same load is run 2 times once with failing allocations and
> > > once without it. Why should we force the tester to do a reboot cycle?
> > 
> > Because we can get rid of the Kconfig more easily once we transitioned.
> 
> How? We might be forced to keep the original behavior _for ever_. I do
> not see any difference between runtime, boottime or compiletime option.
> Except for the flexibility which is different for each one of course. We
> can argue about which one is the most appropriate of course but I feel
> strongly we cannot go and change the semantic right away.

Sure, why not add another slab allocator while you're at it.  How many
times do we have to repeat the same mistakes?  If the old model sucks,
then it needs to be fixed or replaced.  Don't just offer another one
that sucks in different ways and ask the user to pick their poison,
with a promise that we might improve the newer model until it's
suitable to ditch the old one.

This is nothing more than us failing and giving up trying to actually
solve our problems.

> > > > Given that there are usually several stages of various testing between
> > > > when a commit gets merged upstream and when it finally makes it into a
> > > > critical production system, maybe we don't need to provide userspace
> > > > control over this at all?
> > > 
> > > I can still see conservative users not changing this behavior _ever_.
> > > Even after the rest of the world trusts the new default. They should
> > > have a way to disable it. Many of those are running distribution kernels
> > > so they really need a way to control the behavior. Be it a boot time
> > > option or sysctl. Historically we were using sysctl for backward
> > > compatibility and I do not see any reason to be different here as well.
> > 
> > Again, this is an implementation detail that we are trying to fix up.
> 
> This is not an implementation detail! This is about change of the
> _semantic_ of the allocator. I wouldn't call it an implementation
> detail.

We can make the allocator robust through improving reclaim and the OOM
killer.  This "nr of retries" is 100% an implementation detail of this
single stupid function.

On a higher level, allowing the page allocator to return NULL is an
implementation detail of the operating system, userspace doesn't care
how the allocator and the callers communicate as long as the callers
can compensate for the allocator changing.  Involving userspace in
this decision is simply crazy talk.  They have no incentive to
partake.  MM people have to coordinate with other kernel developers to
deal with allocation NULLs without regressing userspace.  Maybe they
can fail the allocations without any problems, maybe they want to wait
for other events that they have more insight into than the allocator.
This is what Dave meant when he said that we should provide mechanism
and leave policy to the callsites.

It's 100% a kernel implementation detail that has NOTHING to do with
userspace.  Zilch.  It's about how the allocator implements the OOM
mechanism and how the allocation sites implement the OOM policy.

> > It has nothing to do with userspace, it's not a heuristic.  It's bad
> > enough that this would be at all selectable from userspace, now you
> > want to make it permanently configurable?
> > 
> > The problem we have to solve here is finding a value that doesn't
> > deadlock the allocator, makes error situations stable and behave
> > predictably, and doesn't regress real workloads out there.
> > Your proposal tries to avoid immediate regressions at the cost of
> > keeping the deadlock potential AND fragmenting the test space, which
> > will make the whole situation even more fragile. 
> 
> While the deadlocks are possible the history shows they are not really
> that common. While unexpected allocation failures are much more risky
> because they would _regress_ previously working kernel. So I see this
> conservative approach appropriate.
> 
> > Why would you want production systems to run code that nobody else is
> > running anymore?
> 
> I do not understand this.

Can you please read the entire email before replying?  What I meant by
this is explained following this question.  You explicitely asked for
permanently segregating the behavior of upstream kernels from that of
critical production systems.

> > We have a functioning testing pipeline to evaluate kernel changes like
> > this: private tree -> subsystem tree -> next -> rc -> release ->
> > stable -> longterm -> vendor.
> 
> This might work for smaller changes not when basically the whole kernel
> is affected and the potential regression space is hard to predict and
> potentially very large.

Hence Andrew's suggestion to partition the callers and do the
transition incrementally.

> > We propagate risky changes to bigger
> > and bigger test coverage domains and back them out once they introduce
> > regressions.
> 
> Great so we end up reverting this in a month or two when the first users
> stumble over a bug and we are back to square one. Excellent plan...

No, we're not.  We now have data on the missing pieces.  We need to
update our initial assumptions, evaluate our caller requirements.
Update the way we perform reclaim, finetune how we determine OOM
situations - maybe we just need some smart waits.  All this would
actually improve the kernel.

That whole "nr of retries" is stupid in the first place.  The amount
of work that is retried is completely implementation dependent and
changes all the time.  We can probably wait for much more sensible
events.  For example, if the things we do in a single loop give up
prematurely, then maybe instead of just adding more loops, we could
add a timeout-wait for the OOM victim to exit.  Change the congestion
throttling.  Whatever.  Anything is better than making the iterations
of a variable loop configurable to userspace.  But what needs to be
done depends on the way real applications actually regress.  Are
allocations failing right before the OOM victim exited and we should
have waited for it instead?  Are there in-flight writebacks we could
have waited for and we need to adjust our throttling in vmscan.c?
Because that throttling has only been tuned to save CPU cycles during
our endless reclaim, not actually to reliably make LRU reclaim trail
dirty page laundering.  There is so much room for optimizations that
would leave us with a better functioning system across the map, than
throwing braindead retrying at the problem.  But we need the data.

Those endless retry loops have masked reliability problems in the
underlying reclaim and OOM code.  We can not address them without
exposure.  And we likely won't be needing this single magic number
once the implementation is better and a single sequence of robust
reclaim and OOM kills is enough to determine that we are thoroughly
out of memory and there is no point in retrying inside the allocator.
Whatever is left in terms of OOM policy should be the responsibility
of the caller.

> > You are trying to bypass this mechanism in an ad-hoc way
> > with no plan of ever re-uniting the configuration space, but by
> > splitting the test base in half (or N in your original proposal) you
> > are setting us up for bugs reported in vendor kernels that didn't get
> > caught through our primary means of maturing kernel changes.
> > 
> > Furthermore, it makes the code's behavior harder to predict and reason
> > about, which makes subsequent development prone to errors and yet more
> > regressions.
> 
> How come? !GFP_NOFAIL allocations _have_ to check for allocation
> failures regardless the underlying allocator implementation.

Can you please think a bit longer about these emails before replying?

If you split the configuration space into kernels that endlessly retry
and those that do not, you can introduce new deadlocks to the nofail
kernels which don't get caught in the canfail kernels.  If you weaken
the code that executes in each loop, you can regress robustness in the
canfail kernels which is not caught in the nofail kernels.  You'll hit
deadlocks in the production environments that were not existent in the
canfail testing setups, and experience from production environments
won't translate to upstream fixes very well.

> > You're trying so hard to be defensive about this that you're actually
> > making everybody worse off.  Prioritizing a single aspect of a change
> > above everything else will never lead to good solutions.  Engineering
> > is about making trade-offs and finding the sweet spots.
> 
> OK, so I am really wondering what you are proposing as an alternative.
> Simply start failing allocations right away is hazardous and
> irresponsible and not going to fly because we would quickly end up
> reverting the change. Which will not help us to change the current
> non-failing semantic which will be more and more PITA over the time
> because it pushes us into the corner, it is deadlock prone and doesn't
> allow callers to define proper fail strategies.

Maybe run a smarter test than an artificial stress for starters, see
if this actually matters for an array of more realistic mmtests and/or
filesystem tests.  And then analyse those failures instead of bumping
the nr_retries knob blindly.

And I agree with Andrew that we could probably be selective INSIDE THE
KERNEL about which callers are taking the plunge.  The only reason to
be careful with this change is the scale, it has nothing to do with
long-standing behavior.  That's just handwaving.  Make it opt-in on a
kernel code level, not on a userspace level, so that we have those
responsible for the callsite code be aware of this change and can
think of the consequences up front.  Let XFS people think about
failing small allocations in their context: which of those are allowed
to propagate to userspace and which aren't?  If we regress userspace
because allocation failures leak by accident, we know the caller needs
to be fixed.  If we regress a workload by failing failable allocations
earlier than before, we know that the page allocator should try
harder/smarter.  This is the advantage of having an actual model: you
can figure out who is violating it and fix the problem where it occurs
instead of papering it over.

Then let ext4 people think about it and ease them into it.  Let them
know what is coming and what they should be prepared for, and then we
can work with them in fixing up any issues.  Once the big ticket items
are done we can flip the rest and deal with that fallout separately.

There is an existing path to make and evaluate such changes and you
haven't made a case why we should deviate from that.  We didn't ask
users to choose between fine-grained locking or the big kernel lock,
either, did we?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
