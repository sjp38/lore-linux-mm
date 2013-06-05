Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id BFA886B0033
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 10:40:05 -0400 (EDT)
Date: Wed, 5 Jun 2013 10:39:49 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/3] memcg: simplify mem_cgroup_reclaim_iter
Message-ID: <20130605143949.GQ15576@cmpxchg.org>
References: <1370306679-13129-1-git-send-email-tj@kernel.org>
 <1370306679-13129-4-git-send-email-tj@kernel.org>
 <20130604131843.GF31242@dhcp22.suse.cz>
 <20130604205025.GG14916@htj.dyndns.org>
 <20130604212808.GB13231@dhcp22.suse.cz>
 <20130604215535.GM14916@htj.dyndns.org>
 <20130605073023.GB15997@dhcp22.suse.cz>
 <20130605082023.GG7303@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130605082023.GG7303@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, bsingharora@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

On Wed, Jun 05, 2013 at 01:20:23AM -0700, Tejun Heo wrote:
> Hello, Michal.
> 
> On Wed, Jun 05, 2013 at 09:30:23AM +0200, Michal Hocko wrote:
> > > I don't really get that.  As long as the amount is bound and the
> > > overhead negligible / acceptable, why does it matter how long the
> > > pinning persists? 
> > 
> > Because the amount is not bound either. Just create a hierarchy and
> > trigger the hard limit and if you are careful enough you can always keep
> > some of the children in the cached pointer (with css reference, if you
> > will) and then release the hierarchy. You can do that repeatedly and
> > leak considerable amount of memory.
> 
> It's still bound, no?  Each live memcg can only keep limited number of
> cgroups cached, right?

It is bounded by the number of memcgs.  Each one can have 12
(DEF_PRIORITY) references.

> > > We aren't talking about something gigantic or can
> > 
> > mem_cgroup is 888B now (depending on configuration). So I wouldn't call
> > it negligible.
> 
> Do you think that the number can actually grow harmful?  Would you be
> kind enough to share some calculations with me?

5k cgroups * say 10 priority levels * 1k struct mem_cgroup may pin 51M
of dead struct mem_cgroup, plus whatever else the css pins.

> > > In the off chance that this is a real problem, which I strongly doubt,
> > > as I wrote to Johannes, we can implement extremely dumb cleanup
> > > routine rather than this weak reference beast.
> > 
> > That was my first version (https://lkml.org/lkml/2013/1/3/298) and
> > Johannes didn't like. To be honest I do not care _much_ which way we go
> > but we definitely cannot pin those objects for ever.
> 
> I'll get to the barrier thread but really complex barrier dancing like
> that is only justifiable in extremely hot paths a lot of people pay
> attention to.  It doesn't belong inside memcg proper.  If the cached
> amount is an actual concern, let's please implement a simple clean up
> thing.  All we need is a single delayed_work which scans the tree
> periodically.
> 
> Johannes, what do you think?

While I see your concerns about complexity (and this certainly is not
the most straight-forward code), I really can't get too excited about
asynchroneous garbage collection, even worse when it's time-based. It
would probably start out with less code but two releases later we
would have added all this stuff that's required to get the interaction
right and fix unpredictable reclaim disruption that hits when the
reaper coincides just right with heavy reclaim once a week etc.  I
just don't think that asynchroneous models are simpler than state
machines.  Harder to reason about, harder to debug.

Now, there are separate things that add complexity to our current
code: the weak pointers, the lockless iterator, and the fact that all
of it is jam-packed into one monolithic iterator function.  I can see
why you are not happy.  But that does not mean we have to get rid of
everything wholesale.

You hate the barriers, so let's add a lock to access the iterator.
That path is not too hot in most cases.

On the other hand, the weak pointer is not too esoteric of a pattern
and we can neatly abstract it into two functions: one that takes an
iterator and returns a verified css reference or NULL, and one to
invalidate pointers when called from the memcg destruction code.

These two things should greatly simplify mem_cgroup_iter() while not
completely abandoning all our optimizations.

What do you think?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
