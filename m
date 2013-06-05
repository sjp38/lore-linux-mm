Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id EFDF66B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 13:22:18 -0400 (EDT)
Received: by mail-qe0-f49.google.com with SMTP id cz11so1226372qeb.36
        for <linux-mm@kvack.org>; Wed, 05 Jun 2013 10:22:18 -0700 (PDT)
Date: Wed, 5 Jun 2013 10:22:12 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/3] memcg: simplify mem_cgroup_reclaim_iter
Message-ID: <20130605172212.GA10693@mtj.dyndns.org>
References: <1370306679-13129-1-git-send-email-tj@kernel.org>
 <1370306679-13129-4-git-send-email-tj@kernel.org>
 <20130604131843.GF31242@dhcp22.suse.cz>
 <20130604205025.GG14916@htj.dyndns.org>
 <20130604212808.GB13231@dhcp22.suse.cz>
 <20130604215535.GM14916@htj.dyndns.org>
 <20130605073023.GB15997@dhcp22.suse.cz>
 <20130605082023.GG7303@mtj.dyndns.org>
 <20130605143949.GQ15576@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130605143949.GQ15576@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, bsingharora@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

Hey, Johannes.

On Wed, Jun 05, 2013 at 10:39:49AM -0400, Johannes Weiner wrote:
> 5k cgroups * say 10 priority levels * 1k struct mem_cgroup may pin 51M
> of dead struct mem_cgroup, plus whatever else the css pins.

Yeah, it seems like it can grow quite a bit.

> > I'll get to the barrier thread but really complex barrier dancing like
> > that is only justifiable in extremely hot paths a lot of people pay
> > attention to.  It doesn't belong inside memcg proper.  If the cached
> > amount is an actual concern, let's please implement a simple clean up
> > thing.  All we need is a single delayed_work which scans the tree
> > periodically.
> > 
> > Johannes, what do you think?
> 
> While I see your concerns about complexity (and this certainly is not
> the most straight-forward code), I really can't get too excited about
> asynchroneous garbage collection, even worse when it's time-based. It
> would probably start out with less code but two releases later we
> would have added all this stuff that's required to get the interaction
> right and fix unpredictable reclaim disruption that hits when the
> reaper coincides just right with heavy reclaim once a week etc.  I
> just don't think that asynchroneous models are simpler than state
> machines.  Harder to reason about, harder to debug.

Agreed, but we can do the cleanup from ->css_offline() as Michal
suggested.  Naively implemented, this will lose the nice property of
keeping the iteration point even when the cursor cgroup is removed,
which can be an issue if we're actually worrying about cases with 5k
cgroups continuously being created and destroyed.  Maybe we can make
it point to the next cgroup to visit rather than the last visited one
and update it from ->css_offline().

> Now, there are separate things that add complexity to our current
> code: the weak pointers, the lockless iterator, and the fact that all
> of it is jam-packed into one monolithic iterator function.  I can see
> why you are not happy.  But that does not mean we have to get rid of
> everything wholesale.
> 
> You hate the barriers, so let's add a lock to access the iterator.
> That path is not too hot in most cases.
> 
> On the other hand, the weak pointer is not too esoteric of a pattern
> and we can neatly abstract it into two functions: one that takes an
> iterator and returns a verified css reference or NULL, and one to
> invalidate pointers when called from the memcg destruction code.
>
> These two things should greatly simplify mem_cgroup_iter() while not
> completely abandoning all our optimizations.
> 
> What do you think?

I really think the weak pointers should go especially as we can
achieve about the same thing with normal RCU dereference.  Also, I'm a
bit confused about what you're suggesting.  If we have invalidation
from offline, why do we need weak pointers?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
