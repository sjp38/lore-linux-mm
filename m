Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 485B36B0032
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 10:13:48 -0400 (EDT)
Date: Tue, 20 Aug 2013 10:13:39 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v5] Soft limit rework
Message-ID: <20130820141339.GA31419@cmpxchg.org>
References: <1371557387-22434-1-git-send-email-mhocko@suse.cz>
 <20130819163512.GB712@cmpxchg.org>
 <20130820091414.GC31552@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130820091414.GC31552@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Glauber Costa <glommer@gmail.com>

On Tue, Aug 20, 2013 at 11:14:14AM +0200, Michal Hocko wrote:
> On Mon 19-08-13 12:35:12, Johannes Weiner wrote:
> > On Tue, Jun 18, 2013 at 02:09:39PM +0200, Michal Hocko wrote:
> > > Hi,
> > > 
> > > This is the fifth version of the patchset.
> > > 
> > > Summary of versions:
> > > The first version has been posted here: http://permalink.gmane.org/gmane.linux.kernel.mm/97973
> > > (lkml wasn't CCed at the time so I cannot find it in lwn.net
> > > archives). There were no major objections. 
> > 
> > Except there are.
> 
> Good to know that late... It would have been much more helpful to have
> such a principal feedback few months ago (this work is here since early
> Jun).

I NAKed this "integrate into reclaim but still make soft reclaim an
extra pass" idea the first time Ying submitted it.

And no, the soft limit discussions have been going on since I first
submitted a rewrite as part of the reclaim integration series in
mid-2011.

We have been going back and forth on whether soft limits should behave
as guarantees and *protect* from reclaim.  But I thought we had since
agreed that implementing guarantees should be a separate effort and as
far as I'm concerned there is no justification for all this added code
just to prevent reclaiming non-excess when there is excess around.

> > > My primary test case was a parallel kernel build with 2 groups (make
> > > is running with -j4 with a distribution .config in a separate cgroup
> > > without any hard limit) on a 8 CPU machine booted with 1GB memory.  I
> > > was mostly interested in 2 setups. Default - no soft limit set and - and
> > > 0 soft limit set to both groups.
> > > The first one should tell us whether the rework regresses the default
> > > behavior while the second one should show us improvements in an extreme
> > > case where both workloads are always over the soft limit.
> > 
> > Two kernel builds with 1G of memory means that reclaim is purely
> > trimming the cache every once in a while.  Changes in memory pressure
> > are not measurable up to a certain point, because whether you trim old
> > cache or not does not affect the build jobs.
> > 
> > Also you tested the no-softlimit case and an extreme soft limit case.
> > Where are the common soft limit cases?
> 
> v5.1 had some more tests. I have added soft limitted stream IO resp. kbuild vs
> unlimitted mem_eater loads. Have you checked those?

Another 0-limit test?  If you declare every single page a cgroup has
as being in excess of what it should have, how does reclaiming them
aggressively constitute bad behavior?

> [...]
> > > So to wrap this up. The series is still doing good and improves the soft
> > > limit.
> > 
> > The soft limit tree is a bunch of isolated code that's completely
> > straight-forward.  This is replaced by convoluted memcg iterators,
> > convoluted lruvec shrinkers, spreading even more memcg callbacks with
> > questionable semantics into already complicated generic reclaim code.
> 
> I was trying to keep the convolution into vmscan as small as possible.
> Maybe it can get reduced even more. I will think about it.
> 
> Predicate for memcg iterator has been added to address your concern
> about a potential regression with too many groups. And that looked like
> the least convoluting solution.

I suggested improving the 1st pass by propagating soft limit excess
through the res counters.  They are the hierarchical book keepers.  I
even send you patches to do this.  I don't understand why you
propagate soft limit excess in struct mem_cgroup and use this
ridiculous check_events thing to update them.  We already have the
per-cpu charge caches (stock) and uncharge caches to batch res_counter
updates.

Anyway, this would be a replacement for the current tree structure to
quickly find memcgs in excess.  It has nothing to do with integrating
it into vmscan.c.

> > This series considerably worsens readability and maintainability of
> > both the generic reclaim code as well as the memcg counterpart of it.
> 
> I am really surprised that you are coming with this concerns that late.
> This code has been posted quite some ago, hasn't it? We have even had
> that "calm" discussion with Tejun about predicates and you were silent
> at the time.

I apologize that I was not more responsive in previous submissions,
this is mainly because it was hard to context switch while I was
focussed on the allocator fairness / thrash detection patches.

But you are surprised that I still object to something that I have
been objecting to from day one?  What exactly has changed?

> > The point of naturalizing the memcg code is to reduce data structures
> > and redundancy and to break open opaque interfaces like "do soft
> > reclaim and report back".  But you didn't actually reduce complexity,
> > you added even more opaque callbacks (should_soft_reclaim?
> > soft_reclaim_eligible?).  You didn't integrate soft limit into generic
> > reclaim code, you just made the soft limit API more complicated.
> 
> I can certainly think about simplifications. But it would be nicer if
> you were more specific on the "more complicated" part. The soft reclaim
> is a natural part of the reclaim now. Which I find as an improvement.
> "Do some memcg magic and get back was" a bad idea IMO.

It depends.  Doing memcg reclaim in generic code made sense because
the global data structure went and the generic code absolutely had to
know about memcg iteration.

Soft limit reclaim is something else.  If it were just a modifier of
the existing memcg reclaim loop, I would still put it in vmscan.c for
simplicity reasons.

But your separate soft limit reclaim pass adds quite some complication
to the generic code and there is no good reason for it.

The naming does not help to make it very natural to vmscan.c, either.
__shrink_zone() should be shrink_lruvecs(),
mem_cgroup_soft_reclaim_eligible() should be
mem_cgroup_soft_limit_exceeded() or something like that.  SKIP_TREE
should not be a kernel-wide name for anything.  Also note that we have
since moved on to make lruvec the shared structure and try to steer
away from using memcgs outside of memcontrol.c, so I'm not really fond
of tying more generic code to struct mem_cgroup.

> Hiding the soft limit decisions into the iterators as a searching
> criteria doesn't sound as a totally bad idea to me. Soft limit is an
> additional criteria who to reclaim, isn't it?

Arguably it's a criteria of /how/ to reclaim any given memcg.  Making
it about pre-selecting memcgs is a totally different beast.

> Well, I could have open coded it but that would mean a more code into
> vmscan or getting back to "call some memcg magic and get back to me".

Either way sounds preferrable to having vmscan.c do a lot of things it
does not understand.

> > And, as I mentioned repeatedly in previous submissions, your benchmark
> > numbers don't actually say anything useful about this change.
> 
> I would really welcome suggestions for improvements. I have tried "The
> most interesting test case would be how it behaves if some groups are
> over the soft limits while others are not." with v5.1 where I had
> memeater unlimited and kbuild resp. stream IO being limited.

The workload seems better but the limit configuration is still very
dubious.

I just don't understand what your benchmarks are trying to express.
If you set a soft limit of 0 you declare all memory is optional but
then you go ahead and complain that the workload in there is
thrashing.  WTF?

Kernelbuilds are not really good candidates for soft limit usage in
the first place, because they have a small set of heavily used pages
and a lot of used-once cache.  The core workingset is anything but
optional and you could just set the hard limit to clip all that
needless cache because it does not change performance whether it's
available or not.  Same exact thing goes for IO streamers and their
subset of dirty/writeback pages.

> > I'm against merging this upstream at this point.
> 
> Can we at least find some middle ground here? The way how the current
> soft limit is done is a disaster. Ditching the whole series sounds like
> a step back to me.

I'm worried about memcg madness spreading.  Memcg code is nowhere near
kernel core code standards and I'm really reluctant to have it spread
into something as delicate as vmscan.c for no good reason at all.

If you claim the soft limit implementation is a disaster, I would have
expected a real life workload to back this up but all I've seen are
synthetic tests with no apparent significance to reality.

So, no, I don't buy the "let's just do SOMETHING here" argument.

Let's figure out what the hell is wrong, back it up, find a solution
and verify it against the test case.

Memcg/cgroup code is full of overengineered solutions to problems that
don't exist.  It's insane and it has to stop.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
