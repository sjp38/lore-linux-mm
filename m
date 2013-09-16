Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 574276B0070
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 12:44:10 -0400 (EDT)
Date: Mon, 16 Sep 2013 18:44:05 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v5] Soft limit rework
Message-ID: <20130916164405.GG3674@dhcp22.suse.cz>
References: <1371557387-22434-1-git-send-email-mhocko@suse.cz>
 <20130819163512.GB712@cmpxchg.org>
 <20130820091414.GC31552@dhcp22.suse.cz>
 <20130820141339.GA31419@cmpxchg.org>
 <20130822105856.GA21529@dhcp22.suse.cz>
 <20130903161550.GA856@cmpxchg.org>
 <20130904163823.GA30851@dhcp22.suse.cz>
 <20130906192311.GE856@cmpxchg.org>
 <20130913144953.GA23857@dhcp22.suse.cz>
 <20130913161709.GV856@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130913161709.GV856@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Glauber Costa <glommer@gmail.com>

On Fri 13-09-13 12:17:09, Johannes Weiner wrote:
> On Fri, Sep 13, 2013 at 04:49:53PM +0200, Michal Hocko wrote:
> > On Fri 06-09-13 15:23:11, Johannes Weiner wrote:
[...]
> > > I would really like to deprecate soft limits and introduce something
> > > new that has the proper semantics we want from the get-go.  Its
> > > implementation could very much look like your code, so we can easily
> > > reuse that.  But the interface and its semantics should come first.
> > 
> > I am open to discussin such a change I just do not see any reason to
> > have a crippled soft reclaim implementation for the mean time.
> > Especially when it doesn't look like such a new interface is easy to
> > agree on.
> 
> We had a crippled soft limit implementation from the time it was
> merged, it never worked better than now.
> 
> You seem to think that this is an argument *for* finally fixing it.  I
> disagree.  We should absolutely *avoid* steering people toward it now,
> when the long term plan is already to get rid of it.

It is not just about fixing it. It is also about getting rid of the
bloat that the previous implementation depended on. Not only LoC but
also the resulting binary:

$ size mm/built-in.o 
base:
   text    data     bss     dec     hex filename
   534283  233703  163456  931442   e3672 mm/built-in.o
rework:
   text    data     bss     dec     hex filename
   532866  229591  163456  925913   e20d9 mm/built-in.o

I would like to get rid of as much of a special code as possible.
Especially this one which I hate personally because it is a crude hack
that shouldn't have existed.

> There is a concensus that cgroups and the controllers were merged
> before they were ready and we are now struggling heavily to iron out
> the design mistakes with the minimum amount of disruption we can get
> away with.
> 
> We are also at this time coordinating with all the other controllers
> and the cgroup core to do exactly that, where Tejun is providing us
> with tools to revamp the problematic interfaces.
> 
> And we agree that soft limits were such a design mistake that should
> be ironed out.
> 
> So for the love of everything we hold dear, why would you think that
> NOW is a good time to fix the implemantion and get people to use it?

There are users who already use this feature and it will take some (read
a lot of) time to move them to something else. And that something else
still doesn't exist and I suspect it will take some time to push it into
a proper shape (and be sure we do not screw it this time).

So while I agree that we need something more (semantically) reasonable
there is no need to keep this crippled implementation around especially
when it is non-trivial amount of code.

> > > > > You have not shown that prio-0 scans are a problem. 
> > > > 
> > > > OK, I thought this was self evident but let me be more specific.
> > > > 
> > > > The scan the world is almost always a problem. We are no longer doing
> > > > proportional anon/file reclaim (swappiness is ignored). This is wrong
> > > > from at least two points of view. Firstly it makes the reclaim decisions
> > > > different a lot for groups that are under the soft limit and those
> > > > that are over. Secondly, and more importantly, this might lead to a
> > > > pre-mature swapping, especially when there is a lot of IO going on.
> > > > 
> > > > The global reclaim suffers from the very same problem and that is why
> > > > we try to prevent from prio-0 reclaim as much as possible and use it
> > > > only as a last resort.
> > > 
> > > I know that and I can see that this should probably be fixed, but
> > > there is no quantification for this.  We have no per-memcg reclaim
> > > statistics
> > 
> > Not having statistic is a separate issue. It makes the situation worse
> > but that is not a new thing. The old implementation is even worse
> > because the soft reclaim activity is basically hidden from global
> > reclaim counters. So a lot of pages might get scanned and we will have
> > no way to find out. That part is inherently fixed by the series because
> > of the integration.
> 
> Because it's in the *global* reclaim counters?  That's great but it
> does not address the problem at all.  This is about pressure balance
> between groups and you don't have any numbers for that.

yes, but the point was that if somebody uses soft reclaim currently you
would miss a big part of reclaim activity because soft reclaim is not
accounted even in the global counters. So you can see a long stall
during direct reclaim while the counters look all good.

> All I'm saying is that before changing how the pressure is balanced we
> need to know per-memcg statistics to quantify it and get an insight
> into what we are actually doing.

We can still see the indirect effects of the reclaim. E.g. performance
dropdown due to re-faults/swapping. My previous tests cared only about
the restricted group which, I admit, is very superficial. I am working
on a setup where I am measuring both.

> You respond with a wall of text but you don't address the problem at
> all.
> 
> And before doing all that, we should get the user-visible interface
> right, which we all agreed is broken.
>
> > > > That simple call from kswapd is not that simple at all in fact. It hides
> > > > a lot of memcg specific code which is far from being trivial. Even worse
> > > > that memcg specific code gets back to the reclaim code with different
> > > > reclaim parameters than those used from the context it has been called
> > > > from.
> > > 
> > > It does not matter to understanding generic reclaim code, though, and
> > > acts more like the shrinkers.  We send it off to get memory and it
> > > comes back with results.
> > 
> > Shrinker interface is just too bad. It might work for dentries and
> > inodes but it failed in many other subsystems where it ended up in
> > do-something mode. Soft reclaim is yet another example where we are
> > doing an artificial scan-the-world reclaim to hammer somebody. Fairness
> > is basically impossible to guarantee and there are corner cases which
> > are just waiting to explode.
> 
> Every time you reply you are just attacking bits of my argument in a
> way that is completely irrelevant to the discussion.  What is the
> overall objective that you are trying to defend?
> 
> I said that you are making the interface more complex because the
> current interface is leaving the complexity encapsulated in memcg
> code.  It does not matter one bit that some shrinkers are set up
> incorrectly, that entirely misses the point.

My point was that this is another example of those shrinkers that do a
bad job.

> Michal, it's completely unobvious what your longterm goals are for
> soft limits and guarantees. 

I've already said that I am open to discuss a new interface with a
better semantics and providing guarantees. Once we settle with that one
then we can deprecate the soft limit and after a long time we can ditch
it completely.

> And without that it's hard to comprehend how and if the patches you
> are sending push into the right direction.  Every time I try to
> discuss the bigger picture you derail it with details about how the
> implementation is broken.  It's frustrating.

I am sorry to hear that. I thought that highlevel things were clear.
Soft limit sucks and we need something better. That is clear. I am
just arguing that waiting for that something better shouldn't stop us
working on the current interface as it removes the code and I believe
it eventually even helps loads that are currently relying on the soft
limit.

> This series is a grab bag of fixes that drag a lot of complexity from
> memcg code into generic reclaim, to repair the age old implementation
> of a user-visible interface that we already agree sucks balls and
> should be deprecated.  The fact that you did not even demonstrate that
> the repair itself was successful is a secondary issue at this point,
> but it certainly didn't help your case.

I will follow up with the testing results later. I hope I manage to have
them before I leave on vacation.

The question, though, is whether even results supporting my claims about
enhancements would make any difference. To be honest I thought that the
integration would be non-controversial topic even without performance
improvements which could have be expected due to removing prio-0 reclaim
which is a pure evil. Also the natural fairness of the s.r. sounds like
a good thing.

Anyway. Your wording that nothing should be done about the soft reclaim
seems to be quite clear though. If this position is really firm then go
ahead and NACK the series _explicitly_ so that Andrew or you can send a
revert request to Linus. I would really like to not waste a lot of time
on testing right now when it wouldn't lead to anything.

Thanks
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
