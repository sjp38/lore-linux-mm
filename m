Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 450646B0034
	for <linux-mm@kvack.org>; Wed,  4 Sep 2013 12:38:26 -0400 (EDT)
Date: Wed, 4 Sep 2013 18:38:23 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v5] Soft limit rework
Message-ID: <20130904163823.GA30851@dhcp22.suse.cz>
References: <1371557387-22434-1-git-send-email-mhocko@suse.cz>
 <20130819163512.GB712@cmpxchg.org>
 <20130820091414.GC31552@dhcp22.suse.cz>
 <20130820141339.GA31419@cmpxchg.org>
 <20130822105856.GA21529@dhcp22.suse.cz>
 <20130903161550.GA856@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130903161550.GA856@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Glauber Costa <glommer@gmail.com>

On Tue 03-09-13 12:15:50, Johannes Weiner wrote:
> > On Tue 20-08-13 10:13:39, Johannes Weiner wrote:
> > > On Tue, Aug 20, 2013 at 11:14:14AM +0200, Michal Hocko wrote:
> > > > On Mon 19-08-13 12:35:12, Johannes Weiner wrote:
> > > > > On Tue, Jun 18, 2013 at 02:09:39PM +0200, Michal Hocko wrote:
> > > > > > Hi,
> > > > > > 
> > > > > > This is the fifth version of the patchset.
> > > > > > 
> > > > > > Summary of versions:
> > > > > > The first version has been posted here: http://permalink.gmane.org/gmane.linux.kernel.mm/97973
> > > > > > (lkml wasn't CCed at the time so I cannot find it in lwn.net
> > > > > > archives). There were no major objections. 
> > > > > 
> > > > > Except there are.
> > > > 
> > > > Good to know that late... It would have been much more helpful to have
> > > > such a principal feedback few months ago (this work is here since early
> > > > Jun).
> > > 
> > > I NAKed this "integrate into reclaim but still make soft reclaim an
> > > extra pass" idea the first time Ying submitted it.
> > 
> > There was a general agreement about this approach at LSF AFAIR. So it is
> > really surprising hearing that from you _now_
> > 
> > I do not remember the details of your previous NAK but I do remember you
> > liked the series I posted before the conference. I am willing to change
> > details (e.g. move big vmscan part into memcg) but I do insist on having
> > soft reclaim integrated to the regular reclaim.
> 
> I was okay with the series back at LSF.
> 
> But this was under the assumption that we are moving towards turning
> softlimits into guarantees.  It was only after LSF that we agreed that
> conflating these two things is not a good idea and that we are better
> off implementing guarantees separately.
> 
> On the contrary, I am surprised that you are still pushing this series
> in light of the discussions after LSF.
> 
> Google was a big pusher of the soft limit changes, but their
> requirements were always hard guarantees.  We have since agreed that
> this should be done separately.

Yes, and this series is _not_ about guarantees. It is primarily
about fitting the current soft reclaim into the regular reclaim more
naturally. More on that bellow.

> What is the use case for soft limits at this point?

To handle overcommit situations more gracefully. As the documentation
states:
"
7. Soft limits

Soft limits allow for greater sharing of memory. The idea behind soft limits
is to allow control groups to use as much of the memory as needed, provided

a. There is no memory contention
b. They do not exceed their hard limit

When the system detects memory contention or low memory, control groups
are pushed back to their soft limits. If the soft limit of each control
group is very high, they are pushed back as much as possible to make
sure that one control group does not starve the others of memory.

Please note that soft limits is a best-effort feature; it comes with
no guarantees, but it does its best to make sure that when memory is
heavily contended for, memory is allocated based on the soft limit
hints/setup. Currently soft limit based reclaim is set up such that
it gets invoked from balance_pgdat (kswapd).
"

Except for the last sentence the same holds for the integrated
implementation as well. With the patchset we are doing the soft reclaim
also for the targeted reclaim which was simply not possible previously
because of the data structures limitations. And doing soft reclaim from
target reclaim makes a lot of sense to me because whether we have a
global or hierarchical memory pressure doesn't make any difference that
some groups are set up to sacrifice their memory to help to release the
pressure.

> > > And no, the soft limit discussions have been going on since I first
> > > submitted a rewrite as part of the reclaim integration series in
> > > mid-2011.
> > 
> > Which makes the whole story even more sad :/
> > 
> > > We have been going back and forth on whether soft limits should behave
> > > as guarantees and *protect* from reclaim.  But I thought we had since
> > > agreed that implementing guarantees should be a separate effort and as
> > > far as I'm concerned there is no justification for all this added code
> > > just to prevent reclaiming non-excess when there is excess around.
> > 
> > The patchset is absolutely not about guarantees anymore. It is more
> > about making the current soft limit reclaim more natural. E.g. not doing
> > prio-0 scans.
> 
> With guarantees out of the window there is absolutely no justification
> for this added level of complexity.  The tree code is verbose but dead
> simple.  And it's contained.
> 
> You have not shown that prio-0 scans are a problem. 

OK, I thought this was self evident but let me be more specific.

The scan the world is almost always a problem. We are no longer doing
proportional anon/file reclaim (swappiness is ignored). This is wrong
from at least two points of view. Firstly it makes the reclaim decisions
different a lot for groups that are under the soft limit and those
that are over. Secondly, and more importantly, this might lead to a
pre-mature swapping, especially when there is a lot of IO going on.

The global reclaim suffers from the very same problem and that is why
we try to prevent from prio-0 reclaim as much as possible and use it
only as a last resort.

> Or even argued why you need new memcg iteration code to fix the
> priority level.

The new iterator code is there to make the iteration more effective when
selecting interesting groups. Whether the skipping logic should be
inside the iterator or open coded outside is an implementation detail
IMO.
I am considering the callback approach better because it is reusable as
the skipping part is implemented only once at the place with the same
code which has to deal with all other details already. And the caller
only cares to tell which (sub)trees he is interested in.

> > The side effect that the isolation works better in the result is just a
> > bonus. And I have to admit I like that bonus.
> 
> What isolation?

Reclaiming groups over the soft limit might be sufficient to release
the memory pressure and so other groups might be saved from being
reclaimed. Isolation might be a strong word for that as that would
require a certain guarantee but working in a best-effort mode can work
much better than what we have right now.

If we do a fair reclaim on the whole (sub)tree rather than hammer the
biggest offender we might end up reclaiming from other groups less.

I even think that doing the fair soft reclaim is a better approach from
the conceptual point of view because it is less prone to corner cases
when one group is hammered over and over again without actually helping
to relief the memory pressure for which is the soft limit intended in
the first place.

[...]
> > > > > This series considerably worsens readability and maintainability of
> > > > > both the generic reclaim code as well as the memcg counterpart of it.
> > > > 
> > > > I am really surprised that you are coming with this concerns that late.
> > > > This code has been posted quite some ago, hasn't it? We have even had
> > > > that "calm" discussion with Tejun about predicates and you were silent
> > > > at the time.
> > > 
> > > I apologize that I was not more responsive in previous submissions,
> > > this is mainly because it was hard to context switch while I was
> > > focussed on the allocator fairness / thrash detection patches.
> > 
> > Come on, Johannes! We were sitting in the same room at LSF when there
> > was a general agreement about the patchset because "It is a general
> > improvement and further changes might happen on top of it". You didn't
> > say a word you didn't like it and consider the integration as a bad
> > idea.
> 
> It was a step towards turning soft limits into guarantees.  What other
> use case was there?

And it is still a preparatory step for further improvements towards
guarantees. If you look at the series a new (min limit or whatever you
call it) knob is almost trivial to implement.

> Then it might have been a good first step.  I don't think it is a
> general improvement of the code and I don't remember saying that.
> 
> > > > > The point of naturalizing the memcg code is to reduce data structures
> > > > > and redundancy and to break open opaque interfaces like "do soft
> > > > > reclaim and report back".  But you didn't actually reduce complexity,
> > > > > you added even more opaque callbacks (should_soft_reclaim?
> > > > > soft_reclaim_eligible?).  You didn't integrate soft limit into generic
> > > > > reclaim code, you just made the soft limit API more complicated.
> > > > 
> > > > I can certainly think about simplifications. But it would be nicer if
> > > > you were more specific on the "more complicated" part. The soft reclaim
> > > > is a natural part of the reclaim now. Which I find as an improvement.
> > > > "Do some memcg magic and get back was" a bad idea IMO.
> > > 
> > > It depends.  Doing memcg reclaim in generic code made sense because
> > > the global data structure went and the generic code absolutely had to
> > > know about memcg iteration.
> > > 
> > > Soft limit reclaim is something else.  If it were just a modifier of
> > > the existing memcg reclaim loop, I would still put it in vmscan.c for
> > > simplicity reasons.
> > > 
> > > But your separate soft limit reclaim pass adds quite some complication
> > > to the generic code and there is no good reason for it.
> > 
> > Does it? The whole decision is hidden within the predicate so the main
> > loop doesn't have to care at all. If we ever go with another limit for
> > the guarantee it would simply use a different predicate to select the
> > right group.
> 
> This is just handwaving.  You replaced a simple function call in
> kswapd

That simple call from kswapd is not that simple at all in fact. It hides
a lot of memcg specific code which is far from being trivial. Even worse
that memcg specific code gets back to the reclaim code with different
reclaim parameters than those used from the context it has been called
from.

> with an extra lruvec pass and an enhanced looping construct.
> It's all extra protocol that vmscan.c has to follow without actually
> improving the understandability of the code.  You still have to dig
> into all those predicates to know what's going on.

Comparing that to the memcg per-node-zone excess trees, their
maintenance and a code to achieve at least some fairness during reclaim
the above is a) much less code to read/maintain/understand b) it
achieves the same result without corner cases mentioned previously.

I was trying to taint vmscan.c as little as possible. I have a patch
which moves most of the memcg specific parts back to memcontrol.c but I
cannot say I like it because it duplicates some code and has to expose
scan_control and shrink_lruvec outside vmscan.c.

> And at the risk of repeating myself, you haven't proven that it's
> worth the trouble.
>
> > > > > And, as I mentioned repeatedly in previous submissions, your benchmark
> > > > > numbers don't actually say anything useful about this change.
> > > > 
> > > > I would really welcome suggestions for improvements. I have tried "The
> > > > most interesting test case would be how it behaves if some groups are
> > > > over the soft limits while others are not." with v5.1 where I had
> > > > memeater unlimited and kbuild resp. stream IO being limited.
> > > 
> > > The workload seems better but the limit configuration is still very
> > > dubious.
> > > 
> > > I just don't understand what your benchmarks are trying to express.
> > > If you set a soft limit of 0 you declare all memory is optional but
> > > then you go ahead and complain that the workload in there is
> > > thrashing.  WTF?
> > 
> > As I've already said the primary motivation was to check before and
> > after state and as you can see we can do better... Although you might
> > find soft_limit=0 setting artificial this setting is the easiest way to
> > tell that such a group is the number one candidate for reclaim.
> 
> That would test for correctness, but then you draw conclusions about
> performance.

The series is not about performance improvements. I am sorry if the
testing results made a different impression. The primary motivation was
to get rid of a big memcg specific reclaim path which doesn't handle
fairness well and uses hackish prio-0 reclaim which is too disruptive.
 
> Correctness-wise, the unpatched kernel seems to prefer reclaiming the
> 0-limit group as expected.

It does and as even simple configuration shows that the current soft
reclaim is too disturbing and reclaiming much more than necessary.

> You can't draw reasonable conclusions on performance and
> aggressiveness from such an unrealistic setup.
> 
> > We have users who would like to do backups or some temporary actions to
> > not disturb the main workload. So stream-io resp. kbuild vs. mem_eater
> > is simulating such a use case.
> 
> It's not obvious why you are not using hard limits instead. 

Because although the load in the soft limited groups is willing to
sacrifice its memory it would still prefer as much much memory as
possible to finish as soon as possible.
And also setting the hard limit might be really non-trivial, especially
when you have more such loads because you have to be careful so the
cumulative usage doesn't cause the global reclaim.

> Again, streamers and kbuild don't really benefit from the extra cache,
> so there is no reason to let it expand into available memory and
> retract on pressure.
> These tests are just wildly inappropriate for soft limits, it's
> ridiculous that you insist that their outcome says anything at all.

I do realize that my testing load is simplified a lot, but to be honest,
what ever load I come up with, it still might be argued against as too
simplified or artificial. We simply do not have any etalon.

I was merely interested in well known and understood loads and compared
before and after results for a basic overview of the changes. The series
was not aimed as performance improvement in the first place.

And to be honest I wasn't expecting such a big differences, especially
for stream IO which should be easy "drop everything behind" as it
is use-once load. As you can see, though, the previous soft limit
implementation was hammering even on that load too much. You can see
that on this graph quite nicely [1].
Similar with the kbuild test case where the system swapped out much more
pages (by factor 145) and the Major page faults increased as well (by
factor 85).
You can argue that my testing loads are not typical soft limit
configurations and I even might agree but they clearly show that the way
how we do the soft reclaim currently is way too disruptive and that is
the first thing to fix when we want to move on in that area.

---
[1] http://labs.suse.cz/mhocko/soft_limit_rework/stream_io-vs-mem_eater/stream-one-run.png
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
