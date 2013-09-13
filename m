Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 6F4486B0033
	for <linux-mm@kvack.org>; Fri, 13 Sep 2013 10:49:57 -0400 (EDT)
Date: Fri, 13 Sep 2013 16:49:53 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v5] Soft limit rework
Message-ID: <20130913144953.GA23857@dhcp22.suse.cz>
References: <1371557387-22434-1-git-send-email-mhocko@suse.cz>
 <20130819163512.GB712@cmpxchg.org>
 <20130820091414.GC31552@dhcp22.suse.cz>
 <20130820141339.GA31419@cmpxchg.org>
 <20130822105856.GA21529@dhcp22.suse.cz>
 <20130903161550.GA856@cmpxchg.org>
 <20130904163823.GA30851@dhcp22.suse.cz>
 <20130906192311.GE856@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130906192311.GE856@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Glauber Costa <glommer@gmail.com>

On Fri 06-09-13 15:23:11, Johannes Weiner wrote:
> On Wed, Sep 04, 2013 at 06:38:23PM +0200, Michal Hocko wrote:
[...]
> > To handle overcommit situations more gracefully. As the documentation
> > states:
> > "
> > 7. Soft limits
> > 
> > Soft limits allow for greater sharing of memory. The idea behind soft limits
> > is to allow control groups to use as much of the memory as needed, provided
> > 
> > a. There is no memory contention
> > b. They do not exceed their hard limit
> > 
> > When the system detects memory contention or low memory, control groups
> > are pushed back to their soft limits. If the soft limit of each control
> > group is very high, they are pushed back as much as possible to make
> > sure that one control group does not starve the others of memory.
> > 
> > Please note that soft limits is a best-effort feature; it comes with
> > no guarantees, but it does its best to make sure that when memory is
> > heavily contended for, memory is allocated based on the soft limit
> > hints/setup. Currently soft limit based reclaim is set up such that
> > it gets invoked from balance_pgdat (kswapd).
> > "
> > 
> > Except for the last sentence the same holds for the integrated
> > implementation as well. With the patchset we are doing the soft reclaim
> > also for the targeted reclaim which was simply not possible previously
> > because of the data structures limitations. And doing soft reclaim from
> > target reclaim makes a lot of sense to me because whether we have a
> > global or hierarchical memory pressure doesn't make any difference that
> > some groups are set up to sacrifice their memory to help to release the
> > pressure.
> 
> The issue I have with this is that the semantics of the soft limit are
> so backwards that we should strive to get this stuff right
> conceptually before integrating this better into the VM.
> 
> We have a big user that asks for guarantees, which are comparable but
> the invert opposite of this.  Instead of specifying what is optional
> in one group, you specify what is essential in the other group.  And
> the default is to guarantee nothing instead of everything like soft
> limits are currently defined.
> 
> We even tried to invert the default soft limit setting in the past,
> which went nowhere because we can't do these subtle semantic changes
> on an existing interface.
> 
> I would really like to deprecate soft limits and introduce something
> new that has the proper semantics we want from the get-go.  Its
> implementation could very much look like your code, so we can easily
> reuse that.  But the interface and its semantics should come first.

I am open to discussin such a change I just do not see any reason to
have a crippled soft reclaim implementation for the mean time.
Especially when it doesn't look like such a new interface is easy to
agree on.

[...]
> > > You have not shown that prio-0 scans are a problem. 
> > 
> > OK, I thought this was self evident but let me be more specific.
> > 
> > The scan the world is almost always a problem. We are no longer doing
> > proportional anon/file reclaim (swappiness is ignored). This is wrong
> > from at least two points of view. Firstly it makes the reclaim decisions
> > different a lot for groups that are under the soft limit and those
> > that are over. Secondly, and more importantly, this might lead to a
> > pre-mature swapping, especially when there is a lot of IO going on.
> > 
> > The global reclaim suffers from the very same problem and that is why
> > we try to prevent from prio-0 reclaim as much as possible and use it
> > only as a last resort.
> 
> I know that and I can see that this should probably be fixed, but
> there is no quantification for this.  We have no per-memcg reclaim
> statistics

Not having statistic is a separate issue. It makes the situation worse
but that is not a new thing. The old implementation is even worse
because the soft reclaim activity is basically hidden from global
reclaim counters. So a lot of pages might get scanned and we will have
no way to find out. That part is inherently fixed by the series because
of the integration.

> and your test cases were not useful in determining what's going on
> reclaim-wise.

I will instrument the kernel for the next round of tests which would be
hopefully more descriptive.

[...]
> > That simple call from kswapd is not that simple at all in fact. It hides
> > a lot of memcg specific code which is far from being trivial. Even worse
> > that memcg specific code gets back to the reclaim code with different
> > reclaim parameters than those used from the context it has been called
> > from.
> 
> It does not matter to understanding generic reclaim code, though, and
> acts more like the shrinkers.  We send it off to get memory and it
> comes back with results.

Shrinker interface is just too bad. It might work for dentries and
inodes but it failed in many other subsystems where it ended up in
do-something mode. Soft reclaim is yet another example where we are
doing an artificial scan-the-world reclaim to hammer somebody. Fairness
is basically impossible to guarantee and there are corner cases which
are just waiting to explode.

[...]
> Soft limit is about balancing reclaim pressure and I already pointed
> out that your control group has so much limit slack that you can't
> tell if the main group is performing better because of reclaim
> aggressiveness (good) or because the memory is just taken from your
> control group (bad).
> 
> Please either say why I'm wrong or stop asserting points that have
> been refuted.

I will work on improving my testing setup. I will come back with results
early next week hopefully.

[...] 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
