Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id EF6A26B004F
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 10:50:10 -0500 (EST)
Date: Fri, 13 Jan 2012 16:50:01 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/2] mm: memcg: hierarchical soft limit reclaim
Message-ID: <20120113155001.GB1653@cmpxchg.org>
References: <1326207772-16762-1-git-send-email-hannes@cmpxchg.org>
 <1326207772-16762-3-git-send-email-hannes@cmpxchg.org>
 <20120113120406.GC17060@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120113120406.GC17060@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 13, 2012 at 01:04:06PM +0100, Michal Hocko wrote:
> On Tue 10-01-12 16:02:52, Johannes Weiner wrote:
> > Right now, memcg soft limits are implemented by having a sorted tree
> > of memcgs that are in excess of their limits.  Under global memory
> > pressure, kswapd first reclaims from the biggest excessor and then
> > proceeds to do regular global reclaim.  The result of this is that
> > pages are reclaimed from all memcgs, but more scanning happens against
> > those above their soft limit.
> > 
> > With global reclaim doing memcg-aware hierarchical reclaim by default,
> > this is a lot easier to implement: everytime a memcg is reclaimed
> > from, scan more aggressively (per tradition with a priority of 0) if
> > it's above its soft limit.  With the same end result of scanning
> > everybody, but soft limit excessors a bit more.
> > 
> > Advantages:
> > 
> >   o smoother reclaim: soft limit reclaim is a separate stage before
> >     global reclaim, whose result is not communicated down the line and
> >     so overreclaim of the groups in excess is very likely.  After this
> >     patch, soft limit reclaim is fully integrated into regular reclaim
> >     and each memcg is considered exactly once per cycle.
> > 
> >   o true hierarchy support: soft limits are only considered when
> >     kswapd does global reclaim, but after this patch, targetted
> >     reclaim of a memcg will mind the soft limit settings of its child
> >     groups.
> 
> Yes it makes sense. At first I was thinking that soft limit should be
> considered only under global mem. pressure (at least documentation says
> so) but now it makes sense.
> We can push on over-soft limit groups more because they told us they
> could sacrifice something...  Anyway documentation needs an update as
> well.

You are right, I'll look into it.

> But we have to be little bit careful here. I am still quite confuses how
> we should handle hierarchies vs. subtrees. See bellow.

> > @@ -1318,6 +1123,36 @@ static unsigned long mem_cgroup_margin(struct mem_cgroup *memcg)
> >  	return margin >> PAGE_SHIFT;
> >  }
> >  
> > +/**
> > + * mem_cgroup_over_softlimit
> > + * @root: hierarchy root
> > + * @memcg: child of @root to test
> > + *
> > + * Returns %true if @memcg exceeds its own soft limit or contributes
> > + * to the soft limit excess of one of its parents up to and including
> > + * @root.
> > + */
> > +bool mem_cgroup_over_softlimit(struct mem_cgroup *root,
> > +			       struct mem_cgroup *memcg)
> > +{
> > +	if (mem_cgroup_disabled())
> > +		return false;
> > +
> > +	if (!root)
> > +		root = root_mem_cgroup;
> > +
> > +	for (; memcg; memcg = parent_mem_cgroup(memcg)) {
> > +		/* root_mem_cgroup does not have a soft limit */
> > +		if (memcg == root_mem_cgroup)
> > +			break;
> > +		if (res_counter_soft_limit_excess(&memcg->res))
> > +			return true;
> > +		if (memcg == root)
> > +			break;
> > +	}
> > +	return false;
> > +}
> 
> Well, this might be little bit tricky. We do not check whether memcg and
> root are in a hierarchy (in terms of use_hierarchy) relation. 
> 
> If we are under global reclaim then we iterate over all memcgs and so
> there is no guarantee that there is a hierarchical relation between the
> given memcg and its parent. While, on the other hand, if we are doing
> memcg reclaim then we have this guarantee.
> 
> Why should we punish a group (subtree) which is perfectly under its soft
> limit just because some other subtree contributes to the common parent's
> usage and makes it over its limit?
> Should we check memcg->use_hierarchy here?

We do, actually.  parent_mem_cgroup() checks the res_counter parent,
which is only set when ->use_hierarchy is also set.  The loop should
never walk upwards outside of a hierarchy.

And yes, if you have this:

        A
       / \
      B   C

and configured a soft limit for A, you asked for both B and C to be
responsible when this limit is exceeded, that's not new behaviour.

> Does it even makes sense to setup soft limit on a parent group without
> hierarchies?
> Well I have to admit that hierarchies makes me headache.

There is no parent without a hierarchy.  It is insofar pretty
confusing that you can actually create a directory hierarchy that does
not reflect a memcg hierarchy:

	# pwd
	/sys/fs/cgroup/memory/foo/bar
	# cat memory.usage_in_bytes 
	450560
	# cat ../memory.usage_in_bytes 
	0

there is no accounting/limiting/whatever parent-child relationship
between foo and bar.

> > @@ -2121,8 +2121,16 @@ static void shrink_zone(int priority, struct zone *zone,
> >  			.mem_cgroup = memcg,
> >  			.zone = zone,
> >  		};
> > +		int epriority = priority;
> > +		/*
> > +		 * Put more pressure on hierarchies that exceed their
> > +		 * soft limit, to push them back harder than their
> > +		 * well-behaving siblings.
> > +		 */
> > +		if (mem_cgroup_over_softlimit(root, memcg))
> > +			epriority = 0;
> 
> This sounds too aggressive to me. Shouldn't we just double the pressure
> or something like that?

That's the historical value.  When I tried priority - 1, it was not
aggressive enough.

> Previously we always had nr_to_reclaim == SWAP_CLUSTER_MAX when we did
> memcg reclaim but this is not the case now. For the kswapd we have
> nr_to_reclaim == ULONG_MAX so we will not break out of the reclaim early
> and we have to scan a lot.
> Direct reclaim (shrink or hard limit) shouldn't be affected here.

It took me a while: we had SWAP_CLUSTER_MAX in _soft limit reclaim_,
which means that even with priority 0 we would bail after reclaiming
SWAP_CLUSTER_MAX from each lru of a zone.  But it's now happening with
kswapd's own scan_control, so the overreclaim protection is gone.

That is indeed a change in behaviour I haven't noticed, good catch!

I will look into it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
