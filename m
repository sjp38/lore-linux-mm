Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 3C8AE6B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 17:17:33 -0400 (EDT)
Date: Wed, 5 Jun 2013 17:17:04 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/3] memcg: simplify mem_cgroup_reclaim_iter
Message-ID: <20130605211704.GJ15721@cmpxchg.org>
References: <20130604131843.GF31242@dhcp22.suse.cz>
 <20130604205025.GG14916@htj.dyndns.org>
 <20130604212808.GB13231@dhcp22.suse.cz>
 <20130604215535.GM14916@htj.dyndns.org>
 <20130605073023.GB15997@dhcp22.suse.cz>
 <20130605082023.GG7303@mtj.dyndns.org>
 <20130605143949.GQ15576@cmpxchg.org>
 <20130605172212.GA10693@mtj.dyndns.org>
 <20130605194552.GI15721@cmpxchg.org>
 <20130605200612.GH10693@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130605200612.GH10693@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, bsingharora@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

Hi Tejun,

On Wed, Jun 05, 2013 at 01:06:12PM -0700, Tejun Heo wrote:
> On Wed, Jun 05, 2013 at 03:45:52PM -0400, Johannes Weiner wrote:
> > I'm not sure what you are suggesting.  Synchroneously invalidate every
> > individual iterator upwards the hierarchy every time a cgroup is
> > destroyed?
> 
> Yeap.

> > As I said, the weak pointers are only a few lines of code that can be
> > neatly self-contained (see the invalidate, load, store functions
> > below).  Please convince me that your alternative solution will save
> > complexity to such an extent that either the memory waste of
> > indefinite css pinning, or the computational overhead of non-lazy
> > iterator cleanup, is justifiable.
> 
> The biggest issue I see with the weak pointer is that it's special and
> tricky.  If this is something which is absolutely necessary, it should
> be somewhere more generic.  Also, if we can use the usual RCU deref
> with O(depth) cleanup in the cold path, I don't see how this deviation
> is justifiable.
>
> For people who've been looking at it for long enough, it probably
> isn't that different from using plain RCU but that's just because that
> person has spent the time to build that pattern into his/her brain.
> We now have a lot of people accustomed to plain RCU usages which in
> itself is tricky already and introducing new constructs is actively
> deterimental to maintainability.  We sure can do that when there's no
> alternative but I don't think avoiding synchronous cleanup on cgroup
> destruction path is a good enough reason.  It feels like an
> over-engineering to me.
>
> Another thing is that this matters the most when there are continuous
> creation and destruction of cgroups and the weak pointer
> implementation would keep resetting the iteration to the beginning.
> Depending on timing, it'd be able to live-lock reclaim cursor to the
> beginning of iteration even with fairly low rate of destruction,
> right?  It can be pretty bad high up the tree.  With synchronous
> cleanup, depending on how it's implemented, it can be made to keep the
> iteration position.

That could be an advantage, yes.  But keep in mind that every
destruction has to perform this invalidation operation against the
global root_mem_cgroup's nr_node * nr_zone * nr_priority_levels
iterators, so you can't muck around forever, while possibly holding a
lock at this level.  It's not a hot path, but you don't want to turn
it into one, either.

The upshot for me is this: whether you do long-term pinning or greedy
iterator invalidation, the cost of cgroup destruction increases.
Either in terms of memory usage or in terms of compute time.  I would
have loved to see something as simple as the long-term pinning work
out in practice, because it truly would have been simpler.  But at
this point, I don't really care much because the projected margins of
reduction in complexity and increase of cost from your proposal are
too small for me to feel strongly about one solution or the other, or
go ahead and write the code.  I'll look at your patches, though ;-)

Either way, I'll prepare the patch set that includes the barrier fix
and a small cleanup to make the weak pointer management more
palatable.  I'm still open to code proposals, so don't let it distract
you, but we might as well make it a bit more readable in the meantime.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
