Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 1FD676B0033
	for <linux-mm@kvack.org>; Fri, 13 Sep 2013 12:17:26 -0400 (EDT)
Date: Fri, 13 Sep 2013 12:17:09 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v5] Soft limit rework
Message-ID: <20130913161709.GV856@cmpxchg.org>
References: <1371557387-22434-1-git-send-email-mhocko@suse.cz>
 <20130819163512.GB712@cmpxchg.org>
 <20130820091414.GC31552@dhcp22.suse.cz>
 <20130820141339.GA31419@cmpxchg.org>
 <20130822105856.GA21529@dhcp22.suse.cz>
 <20130903161550.GA856@cmpxchg.org>
 <20130904163823.GA30851@dhcp22.suse.cz>
 <20130906192311.GE856@cmpxchg.org>
 <20130913144953.GA23857@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130913144953.GA23857@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Glauber Costa <glommer@gmail.com>

On Fri, Sep 13, 2013 at 04:49:53PM +0200, Michal Hocko wrote:
> On Fri 06-09-13 15:23:11, Johannes Weiner wrote:
> > On Wed, Sep 04, 2013 at 06:38:23PM +0200, Michal Hocko wrote:
> [...]
> > > To handle overcommit situations more gracefully. As the documentation
> > > states:
> > > "
> > > 7. Soft limits
> > > 
> > > Soft limits allow for greater sharing of memory. The idea behind soft limits
> > > is to allow control groups to use as much of the memory as needed, provided
> > > 
> > > a. There is no memory contention
> > > b. They do not exceed their hard limit
> > > 
> > > When the system detects memory contention or low memory, control groups
> > > are pushed back to their soft limits. If the soft limit of each control
> > > group is very high, they are pushed back as much as possible to make
> > > sure that one control group does not starve the others of memory.
> > > 
> > > Please note that soft limits is a best-effort feature; it comes with
> > > no guarantees, but it does its best to make sure that when memory is
> > > heavily contended for, memory is allocated based on the soft limit
> > > hints/setup. Currently soft limit based reclaim is set up such that
> > > it gets invoked from balance_pgdat (kswapd).
> > > "
> > > 
> > > Except for the last sentence the same holds for the integrated
> > > implementation as well. With the patchset we are doing the soft reclaim
> > > also for the targeted reclaim which was simply not possible previously
> > > because of the data structures limitations. And doing soft reclaim from
> > > target reclaim makes a lot of sense to me because whether we have a
> > > global or hierarchical memory pressure doesn't make any difference that
> > > some groups are set up to sacrifice their memory to help to release the
> > > pressure.
> > 
> > The issue I have with this is that the semantics of the soft limit are
> > so backwards that we should strive to get this stuff right
> > conceptually before integrating this better into the VM.
> > 
> > We have a big user that asks for guarantees, which are comparable but
> > the invert opposite of this.  Instead of specifying what is optional
> > in one group, you specify what is essential in the other group.  And
> > the default is to guarantee nothing instead of everything like soft
> > limits are currently defined.
> > 
> > We even tried to invert the default soft limit setting in the past,
> > which went nowhere because we can't do these subtle semantic changes
> > on an existing interface.
> > 
> > I would really like to deprecate soft limits and introduce something
> > new that has the proper semantics we want from the get-go.  Its
> > implementation could very much look like your code, so we can easily
> > reuse that.  But the interface and its semantics should come first.
> 
> I am open to discussin such a change I just do not see any reason to
> have a crippled soft reclaim implementation for the mean time.
> Especially when it doesn't look like such a new interface is easy to
> agree on.

We had a crippled soft limit implementation from the time it was
merged, it never worked better than now.

You seem to think that this is an argument *for* finally fixing it.  I
disagree.  We should absolutely *avoid* steering people toward it now,
when the long term plan is already to get rid of it.

There is a concensus that cgroups and the controllers were merged
before they were ready and we are now struggling heavily to iron out
the design mistakes with the minimum amount of disruption we can get
away with.

We are also at this time coordinating with all the other controllers
and the cgroup core to do exactly that, where Tejun is providing us
with tools to revamp the problematic interfaces.

And we agree that soft limits were such a design mistake that should
be ironed out.

So for the love of everything we hold dear, why would you think that
NOW is a good time to fix the implemantion and get people to use it?

> > > > You have not shown that prio-0 scans are a problem. 
> > > 
> > > OK, I thought this was self evident but let me be more specific.
> > > 
> > > The scan the world is almost always a problem. We are no longer doing
> > > proportional anon/file reclaim (swappiness is ignored). This is wrong
> > > from at least two points of view. Firstly it makes the reclaim decisions
> > > different a lot for groups that are under the soft limit and those
> > > that are over. Secondly, and more importantly, this might lead to a
> > > pre-mature swapping, especially when there is a lot of IO going on.
> > > 
> > > The global reclaim suffers from the very same problem and that is why
> > > we try to prevent from prio-0 reclaim as much as possible and use it
> > > only as a last resort.
> > 
> > I know that and I can see that this should probably be fixed, but
> > there is no quantification for this.  We have no per-memcg reclaim
> > statistics
> 
> Not having statistic is a separate issue. It makes the situation worse
> but that is not a new thing. The old implementation is even worse
> because the soft reclaim activity is basically hidden from global
> reclaim counters. So a lot of pages might get scanned and we will have
> no way to find out. That part is inherently fixed by the series because
> of the integration.

Because it's in the *global* reclaim counters?  That's great but it
does not address the problem at all.  This is about pressure balance
between groups and you don't have any numbers for that.

All I'm saying is that before changing how the pressure is balanced we
need to know per-memcg statistics to quantify it and get an insight
into what we are actually doing.  You respond with a wall of text but
you don't address the problem at all.

And before doing all that, we should get the user-visible interface
right, which we all agreed is broken.

> > > That simple call from kswapd is not that simple at all in fact. It hides
> > > a lot of memcg specific code which is far from being trivial. Even worse
> > > that memcg specific code gets back to the reclaim code with different
> > > reclaim parameters than those used from the context it has been called
> > > from.
> > 
> > It does not matter to understanding generic reclaim code, though, and
> > acts more like the shrinkers.  We send it off to get memory and it
> > comes back with results.
> 
> Shrinker interface is just too bad. It might work for dentries and
> inodes but it failed in many other subsystems where it ended up in
> do-something mode. Soft reclaim is yet another example where we are
> doing an artificial scan-the-world reclaim to hammer somebody. Fairness
> is basically impossible to guarantee and there are corner cases which
> are just waiting to explode.

Every time you reply you are just attacking bits of my argument in a
way that is completely irrelevant to the discussion.  What is the
overall objective that you are trying to defend?

I said that you are making the interface more complex because the
current interface is leaving the complexity encapsulated in memcg
code.  It does not matter one bit that some shrinkers are set up
incorrectly, that entirely misses the point.

Michal, it's completely unobvious what your longterm goals are for
soft limits and guarantees.  And without that it's hard to comprehend
how and if the patches you are sending push into the right direction.
Every time I try to discuss the bigger picture you derail it with
details about how the implementation is broken.  It's frustrating.

This series is a grab bag of fixes that drag a lot of complexity from
memcg code into generic reclaim, to repair the age old implementation
of a user-visible interface that we already agree sucks balls and
should be deprecated.  The fact that you did not even demonstrate that
the repair itself was successful is a secondary issue at this point,
but it certainly didn't help your case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
