Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 735226B0038
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 09:29:44 -0400 (EDT)
Received: by wgdm6 with SMTP id m6so8511883wgd.2
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 06:29:44 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id gq9si3219754wib.53.2015.03.17.06.29.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Mar 2015 06:29:43 -0700 (PDT)
Date: Tue, 17 Mar 2015 09:29:26 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2 v2] mm: Allow small allocations to fail
Message-ID: <20150317132926.GA1824@phnom.home.cmpxchg.org>
References: <1426107294-21551-1-git-send-email-mhocko@suse.cz>
 <1426107294-21551-2-git-send-email-mhocko@suse.cz>
 <201503151443.CFE04129.MVFOOStLFHFOQJ@I-love.SAKURA.ne.jp>
 <20150315121317.GA30685@dhcp22.suse.cz>
 <201503152206.AGJ22930.HOStFFFQLVMOOJ@I-love.SAKURA.ne.jp>
 <20150316074607.GA24885@dhcp22.suse.cz>
 <20150316211146.GA15456@phnom.home.cmpxchg.org>
 <20150317102508.GG28112@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150317102508.GG28112@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, david@fromorbit.com, mgorman@suse.de, riel@redhat.com, fengguang.wu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 17, 2015 at 11:25:08AM +0100, Michal Hocko wrote:
> On Mon 16-03-15 17:11:46, Johannes Weiner wrote:
> > A sysctl certainly doesn't sound appropriate to me because this is not
> > a tunable that we expect people to set according to their usecase.  We
> > expect our model to work for *everybody*.  A boot flag would be
> > marginally better but it still reeks too much of tunable.
> 
> I am OK with a boot option as well if the sysctl is considered
> inappropriate. It is less flexible though. Consider a regression testing
> where the same load is run 2 times once with failing allocations and
> once without it. Why should we force the tester to do a reboot cycle?

Because we can get rid of the Kconfig more easily once we transitioned.

> > Maybe CONFIG_FAILABLE_SMALL_ALLOCS.  Maybe something more euphemistic.
> > But I honestly can't think of anything that wouldn't scream "horrible
> > leak of implementation details."  The user just shouldn't ever care.
> 
> Any config option basically means that distribution users will not get
> to test this until distributions change the default and this won't
> happen until the testing coverage and period was sufficient. See the
> chicken and egg problem? This is basically undermining the whole idea
> about the voluntary testing. So no, I really do not like this.

Why would anybody volunteer to test this?  What are you giving users
in exchange for potentially destabilizing their kernels?

> > Given that there are usually several stages of various testing between
> > when a commit gets merged upstream and when it finally makes it into a
> > critical production system, maybe we don't need to provide userspace
> > control over this at all?
> 
> I can still see conservative users not changing this behavior _ever_.
> Even after the rest of the world trusts the new default. They should
> have a way to disable it. Many of those are running distribution kernels
> so they really need a way to control the behavior. Be it a boot time
> option or sysctl. Historically we were using sysctl for backward
> compatibility and I do not see any reason to be different here as well.

Again, this is an implementation detail that we are trying to fix up.
It has nothing to do with userspace, it's not a heuristic.  It's bad
enough that this would be at all selectable from userspace, now you
want to make it permanently configurable?

The problem we have to solve here is finding a value that doesn't
deadlock the allocator, makes error situations stable and behave
predictably, and doesn't regress real workloads out there.

Your proposal tries to avoid immediate regressions at the cost of
keeping the deadlock potential AND fragmenting the test space, which
will make the whole situation even more fragile.  Why would you want
production systems to run code that nobody else is running anymore?
We have a functioning testing pipeline to evaluate kernel changes like
this: private tree -> subsystem tree -> next -> rc -> release ->
stable -> longterm -> vendor.  We propagate risky changes to bigger
and bigger test coverage domains and back them out once they introduce
regressions.  You are trying to bypass this mechanism in an ad-hoc way
with no plan of ever re-uniting the configuration space, but by
splitting the test base in half (or N in your original proposal) you
are setting us up for bugs reported in vendor kernels that didn't get
caught through our primary means of maturing kernel changes.

Furthermore, it makes the code's behavior harder to predict and reason
about, which makes subsequent development prone to errors and yet more
regressions.

You're trying so hard to be defensive about this that you're actually
making everybody worse off.  Prioritizing a single aspect of a change
above everything else will never lead to good solutions.  Engineering
is about making trade-offs and finding the sweet spots.

> > So what value do we choose?
> > 
> > Once we kick the OOM killer we should give the victim some time to
> > exit and then try the allocation again.  Looping just ONCE after that
> > means we scan all the LRU pages in the system a second time and invoke
> > the shrinkers another twelve times, with ratios approaching 1.  If the
> > OOM killer doesn't yield an allocatable page after this, I see very
> > little point in going on.  After all, we expect all our callers to
> > handle errors.
> 
> I am OK with the single retry. As shown with the tests the same load
> might end up with less allocation failures with the higher values but
> that is a detail. Users of !GFP_NOFAIL should be prepared for failures
> and the if the failures are too excessive I agree this should be
> addressed in the page allocator.

Well yeah, allocation failures are fully expected to increase with
artificial stress tests.  It doesn't really mean anything.  All we can
do is make an educated guess and start exposing real workloads.

> > So why not just pass an "oomed" bool to should_alloc_retry() and bail
> > on small allocations at that point?  Put it upstream and deal with the
> > fallout long before this hits critical infrastructure?  By presumably
> > fixing up caller error handling and GFP flags?
> 
> This is way too risky IMO. We cannot change a long established behavior
> that quickly. I do agree we should allow failing in linux-next and
> development trees. So that it is us kernel developers to start testing
> first. Then we have zero day testing projects and Fenguang has shown an
> interest in this as well. I would also expect/hoped for some testing
> internal within major distributions. We are no way close to have this
> default behavior in the Linus tree, though.

The age of this behavior has nothing to do with how fast we trigger
bugs and fix them up.

The only problem here is the scale and the unknown impact.  We will
know the impact only by exposure to real workloads, and Andrew made a
suggestion already to keep the scale of the initial change low(er).

> That is why I've proposed 3 steps 1) voluntary testers, 2) distributions
> default 3) upstream default. Why don't you think this is a proper
> approach?

Because nobody will volunteer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
