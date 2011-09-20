Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 32EBE9000BD
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 05:32:55 -0400 (EDT)
Date: Tue, 20 Sep 2011 11:10:32 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch 04/11] mm: memcg: per-priority per-zone hierarchy scan
 generations
Message-ID: <20110920091032.GD11489@redhat.com>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
 <1315825048-3437-5-git-send-email-jweiner@redhat.com>
 <20110920084531.GB27675@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110920084531.GB27675@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Sep 20, 2011 at 10:45:32AM +0200, Michal Hocko wrote:
> On Mon 12-09-11 12:57:21, Johannes Weiner wrote:
> > Memory cgroup limit reclaim currently picks one memory cgroup out of
> > the target hierarchy, remembers it as the last scanned child, and
> > reclaims all zones in it with decreasing priority levels.
> > 
> > The new hierarchy reclaim code will pick memory cgroups from the same
> > hierarchy concurrently from different zones and priority levels, it
> > becomes necessary that hierarchy roots not only remember the last
> > scanned child, but do so for each zone and priority level.
> > 
> > Furthermore, detecting full hierarchy round-trips reliably will become
> > crucial, so instead of counting on one iterator site seeing a certain
> > memory cgroup twice, use a generation counter that is increased every
> > time the child with the highest ID has been visited.
> 
> In principle I think the patch is good. I have some concerns about
> locking and I would really appreciate some more description (like you
> provided in the other email in this thread).

Okay, I'll incorporate that description into the changelog.

> > @@ -131,6 +136,8 @@ struct mem_cgroup_per_zone {
> >  	struct list_head	lists[NR_LRU_LISTS];
> >  	unsigned long		count[NR_LRU_LISTS];
> >  
> > +	struct mem_cgroup_iter_state iter_state[DEF_PRIORITY + 1];
> > +
> >  	struct zone_reclaim_stat reclaim_stat;
> >  	struct rb_node		tree_node;	/* RB tree node */
> >  	unsigned long long	usage_in_excess;/* Set to the value by which */
> [...]
> > @@ -781,9 +783,15 @@ struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
> >  	return memcg;
> >  }
> >  
> > +struct mem_cgroup_iter {
> 
> Wouldn't be mem_cgroup_zone_iter_state a better name. It is true it is
> rather long but I find mem_cgroup_iter very confusing because the actual
> position is stored in the zone's state. The other thing is that it looks
> like we have two iterators in mem_cgroup_iter function now but in fact
> the iter parameter is just a state when we start iteration.

Agreed, the naming is unfortunate.  How about
mem_cgroup_reclaim_cookie or something comparable?  It's limited to
reclaim anyway, hierarchy walkers that do not age the LRU lists should
not advance the shared iterator state, so might as well encode it in
the name.

> > +	struct zone *zone;
> > +	int priority;
> > +	unsigned int generation;
> > +};
> > +
> >  static struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
> >  					  struct mem_cgroup *prev,
> > -					  bool remember)
> > +					  struct mem_cgroup_iter *iter)
> 
> I would rather see a different name for the last parameter
> (iter_state?).

I'm with you on this.  Will think something up.

> > @@ -804,10 +812,20 @@ static struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
> >  	}
> >  
> >  	while (!mem) {
> > +		struct mem_cgroup_iter_state *uninitialized_var(is);
> >  		struct cgroup_subsys_state *css;
> >  
> > -		if (remember)
> > -			id = root->last_scanned_child;
> > +		if (iter) {
> > +			int nid = zone_to_nid(iter->zone);
> > +			int zid = zone_idx(iter->zone);
> > +			struct mem_cgroup_per_zone *mz;
> > +
> > +			mz = mem_cgroup_zoneinfo(root, nid, zid);
> > +			is = &mz->iter_state[iter->priority];
> > +			if (prev && iter->generation != is->generation)
> > +				return NULL;
> > +			id = is->position;
> 
> Do we need any kind of locking here (spin_lock(&is->lock))?
> If two parallel reclaimers start on the same zone and priority they will
> see the same position and so bang on the same cgroup.

Note that last_scanned_child wasn't lock-protected before this series,
so there is no actual difference.

I can say, though, that during development I had a lock in there for
some time and it didn't make any difference for 32 concurrent
reclaimers on a quadcore.  Feel free to evaluate with higher
concurrency :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
