Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 42B306B0031
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 12:16:01 -0400 (EDT)
Date: Tue, 3 Sep 2013 12:15:50 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v5] Soft limit rework
Message-ID: <20130903161550.GA856@cmpxchg.org>
References: <1371557387-22434-1-git-send-email-mhocko@suse.cz>
 <20130819163512.GB712@cmpxchg.org>
 <20130820091414.GC31552@dhcp22.suse.cz>
 <20130820141339.GA31419@cmpxchg.org>
 <20130822105856.GA21529@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130822105856.GA21529@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Glauber Costa <glommer@gmail.com>

Hi Michal,

On Thu, Aug 22, 2013 at 12:58:56PM +0200, Michal Hocko wrote:
> [I am mostly offline for the whole week with very limitted internet
> access so it will get longer for me to respond to emails. Sorry about
> that]

Same deal for me, just got back.  Sorry for the delays.

> On Tue 20-08-13 10:13:39, Johannes Weiner wrote:
> > On Tue, Aug 20, 2013 at 11:14:14AM +0200, Michal Hocko wrote:
> > > On Mon 19-08-13 12:35:12, Johannes Weiner wrote:
> > > > On Tue, Jun 18, 2013 at 02:09:39PM +0200, Michal Hocko wrote:
> > > > > Hi,
> > > > > 
> > > > > This is the fifth version of the patchset.
> > > > > 
> > > > > Summary of versions:
> > > > > The first version has been posted here: http://permalink.gmane.org/gmane.linux.kernel.mm/97973
> > > > > (lkml wasn't CCed at the time so I cannot find it in lwn.net
> > > > > archives). There were no major objections. 
> > > > 
> > > > Except there are.
> > > 
> > > Good to know that late... It would have been much more helpful to have
> > > such a principal feedback few months ago (this work is here since early
> > > Jun).
> > 
> > I NAKed this "integrate into reclaim but still make soft reclaim an
> > extra pass" idea the first time Ying submitted it.
> 
> There was a general agreement about this approach at LSF AFAIR. So it is
> really surprising hearing that from you _now_
> 
> I do not remember the details of your previous NAK but I do remember you
> liked the series I posted before the conference. I am willing to change
> details (e.g. move big vmscan part into memcg) but I do insist on having
> soft reclaim integrated to the regular reclaim.

I was okay with the series back at LSF.

But this was under the assumption that we are moving towards turning
softlimits into guarantees.  It was only after LSF that we agreed that
conflating these two things is not a good idea and that we are better
off implementing guarantees separately.

On the contrary, I am surprised that you are still pushing this series
in light of the discussions after LSF.

Google was a big pusher of the soft limit changes, but their
requirements were always hard guarantees.  We have since agreed that
this should be done separately.

What is the use case for soft limits at this point?

> > And no, the soft limit discussions have been going on since I first
> > submitted a rewrite as part of the reclaim integration series in
> > mid-2011.
> 
> Which makes the whole story even more sad :/
> 
> > We have been going back and forth on whether soft limits should behave
> > as guarantees and *protect* from reclaim.  But I thought we had since
> > agreed that implementing guarantees should be a separate effort and as
> > far as I'm concerned there is no justification for all this added code
> > just to prevent reclaiming non-excess when there is excess around.
> 
> The patchset is absolutely not about guarantees anymore. It is more
> about making the current soft limit reclaim more natural. E.g. not doing
> prio-0 scans.

With guarantees out of the window there is absolutely no justification
for this added level of complexity.  The tree code is verbose but dead
simple.  And it's contained.

You have not shown that prio-0 scans are a problem.  Or even argued
why you need new memcg iteration code to fix the priority level.

> The side effect that the isolation works better in the result is just a
> bonus. And I have to admit I like that bonus.

What isolation?

> > > > > My primary test case was a parallel kernel build with 2 groups (make
> > > > > is running with -j4 with a distribution .config in a separate cgroup
> > > > > without any hard limit) on a 8 CPU machine booted with 1GB memory.  I
> > > > > was mostly interested in 2 setups. Default - no soft limit set and - and
> > > > > 0 soft limit set to both groups.
> > > > > The first one should tell us whether the rework regresses the default
> > > > > behavior while the second one should show us improvements in an extreme
> > > > > case where both workloads are always over the soft limit.
> > > > 
> > > > Two kernel builds with 1G of memory means that reclaim is purely
> > > > trimming the cache every once in a while.  Changes in memory pressure
> > > > are not measurable up to a certain point, because whether you trim old
> > > > cache or not does not affect the build jobs.
> > > > 
> > > > Also you tested the no-softlimit case and an extreme soft limit case.
> > > > Where are the common soft limit cases?
> > > 
> > > v5.1 had some more tests. I have added soft limitted stream IO resp. kbuild vs
> > > unlimitted mem_eater loads. Have you checked those?
> > 
> > Another 0-limit test?  If you declare every single page a cgroup has
> > as being in excess of what it should have, how does reclaiming them
> > aggressively constitute bad behavior?
> 
> My testing simply tries to compare the behavior before and after the
> patchset. And points out that the current soft reclaim is really
> aggressive and it doesn't have to act like that.

How can you get a meaningful result out of a meaningless setup?

You can't tell if it's apropriately aggressive, not aggressive enough,
or too aggressive if your test case does not mean anything.  There are
no sane expectations that can be met.

> > > > > So to wrap this up. The series is still doing good and improves the soft
> > > > > limit.
> > > > 
> > > > The soft limit tree is a bunch of isolated code that's completely
> > > > straight-forward.  This is replaced by convoluted memcg iterators,
> > > > convoluted lruvec shrinkers, spreading even more memcg callbacks with
> > > > questionable semantics into already complicated generic reclaim code.
> > > 
> > > I was trying to keep the convolution into vmscan as small as possible.
> > > Maybe it can get reduced even more. I will think about it.
> > > 
> > > Predicate for memcg iterator has been added to address your concern
> > > about a potential regression with too many groups. And that looked like
> > > the least convoluting solution.
> > 
> > I suggested improving the 1st pass by propagating soft limit excess
> > through the res counters.  They are the hierarchical book keepers.  I
> > even send you patches to do this.  I don't understand why you
> > propagate soft limit excess in struct mem_cgroup and use this
> > ridiculous check_events thing to update them.  We already have the
> > per-cpu charge caches (stock) and uncharge caches to batch res_counter
> > updates.
> > 
> > Anyway, this would be a replacement for the current tree structure to
> > quickly find memcgs in excess. 
> 
> Yes and I do not insist on having this per-memcg counter. I took this
> way to keep this memcg specific thing withing memcg code and do not
> pollute generic cgroup code which doesn't care about this property at
> all.

res_counters hierarchically track usage, limit, and soft limit.
Sounds like the perfect fit to track hierarchical soft limit excess to
me.

> > > > This series considerably worsens readability and maintainability of
> > > > both the generic reclaim code as well as the memcg counterpart of it.
> > > 
> > > I am really surprised that you are coming with this concerns that late.
> > > This code has been posted quite some ago, hasn't it? We have even had
> > > that "calm" discussion with Tejun about predicates and you were silent
> > > at the time.
> > 
> > I apologize that I was not more responsive in previous submissions,
> > this is mainly because it was hard to context switch while I was
> > focussed on the allocator fairness / thrash detection patches.
> 
> Come on, Johannes! We were sitting in the same room at LSF when there
> was a general agreement about the patchset because "It is a general
> improvement and further changes might happen on top of it". You didn't
> say a word you didn't like it and consider the integration as a bad
> idea.

It was a step towards turning soft limits into guarantees.  What other
use case was there?

Then it might have been a good first step.  I don't think it is a
general improvement of the code and I don't remember saying that.

> > > > The point of naturalizing the memcg code is to reduce data structures
> > > > and redundancy and to break open opaque interfaces like "do soft
> > > > reclaim and report back".  But you didn't actually reduce complexity,
> > > > you added even more opaque callbacks (should_soft_reclaim?
> > > > soft_reclaim_eligible?).  You didn't integrate soft limit into generic
> > > > reclaim code, you just made the soft limit API more complicated.
> > > 
> > > I can certainly think about simplifications. But it would be nicer if
> > > you were more specific on the "more complicated" part. The soft reclaim
> > > is a natural part of the reclaim now. Which I find as an improvement.
> > > "Do some memcg magic and get back was" a bad idea IMO.
> > 
> > It depends.  Doing memcg reclaim in generic code made sense because
> > the global data structure went and the generic code absolutely had to
> > know about memcg iteration.
> > 
> > Soft limit reclaim is something else.  If it were just a modifier of
> > the existing memcg reclaim loop, I would still put it in vmscan.c for
> > simplicity reasons.
> > 
> > But your separate soft limit reclaim pass adds quite some complication
> > to the generic code and there is no good reason for it.
> 
> Does it? The whole decision is hidden within the predicate so the main
> loop doesn't have to care at all. If we ever go with another limit for
> the guarantee it would simply use a different predicate to select the
> right group.

This is just handwaving.  You replaced a simple function call in
kswapd with an extra lruvec pass and an enhanced looping construct.
It's all extra protocol that vmscan.c has to follow without actually
improving the understandability of the code.  You still have to dig
into all those predicates to know what's going on.

And at the risk of repeating myself, you haven't proven that it's
worth the trouble.

> > > > And, as I mentioned repeatedly in previous submissions, your benchmark
> > > > numbers don't actually say anything useful about this change.
> > > 
> > > I would really welcome suggestions for improvements. I have tried "The
> > > most interesting test case would be how it behaves if some groups are
> > > over the soft limits while others are not." with v5.1 where I had
> > > memeater unlimited and kbuild resp. stream IO being limited.
> > 
> > The workload seems better but the limit configuration is still very
> > dubious.
> > 
> > I just don't understand what your benchmarks are trying to express.
> > If you set a soft limit of 0 you declare all memory is optional but
> > then you go ahead and complain that the workload in there is
> > thrashing.  WTF?
> 
> As I've already said the primary motivation was to check before and
> after state and as you can see we can do better... Although you might
> find soft_limit=0 setting artificial this setting is the easiest way to
> tell that such a group is the number one candidate for reclaim.

That would test for correctness, but then you draw conclusions about
performance.

Correctness-wise, the unpatched kernel seems to prefer reclaiming the
0-limit group as expected.

You can't draw reasonable conclusions on performance and
aggressiveness from such an unrealistic setup.

> We have users who would like to do backups or some temporary actions to
> not disturb the main workload. So stream-io resp. kbuild vs. mem_eater
> is simulating such a use case.

It's not obvious why you are not using hard limits instead.  Again,
streamers and kbuild don't really benefit from the extra cache, so
there is no reason to let it expand into available memory and retract
on pressure.

These tests are just wildly inappropriate for soft limits, it's
ridiculous that you insist that their outcome says anything at all.

> > Kernelbuilds are not really good candidates for soft limit usage in
> > the first place, because they have a small set of heavily used pages
> > and a lot of used-once cache.
> 
> It still produces the sufficient memory pressure to disturb other
> groups.

See "hard limit" above.

> > The core workingset is anything but
> > optional and you could just set the hard limit to clip all that
> > needless cache because it does not change performance whether it's
> > available or not.  Same exact thing goes for IO streamers and their
> > subset of dirty/writeback pages.
> > 
> > > > I'm against merging this upstream at this point.
> > > 
> > > Can we at least find some middle ground here? The way how the current
> > > soft limit is done is a disaster. Ditching the whole series sounds like
> > > a step back to me.
> > 
> > I'm worried about memcg madness spreading.  Memcg code is nowhere near
> > kernel core code standards and I'm really reluctant to have it spread
> > into something as delicate as vmscan.c for no good reason at all.
> > 
> > If you claim the soft limit implementation is a disaster, I would have
> > expected a real life workload to back this up but all I've seen are
> > synthetic tests with no apparent significance to reality.
> > 
> > So, no, I don't buy the "let's just do SOMETHING here" argument.
> > 
> > Let's figure out what the hell is wrong, back it up, find a solution
> > and verify it against the test case.
> 
> It is basically prio-0 thing that is the disaster. And I was quite
> explicit about that. 

And I keep telling you that you have proven neither the problem nor
the solution.

Your choice of tests suggests that you either don't understand what
you are testing or that you don't understand what soft limits mean.

There is no apparent point to this series and it adds complexity to
vmscan.c.  It has no business getting merged.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
