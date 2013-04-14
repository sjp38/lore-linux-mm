Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 0889C6B0006
	for <linux-mm@kvack.org>; Sun, 14 Apr 2013 10:34:27 -0400 (EDT)
Date: Sun, 14 Apr 2013 07:34:20 -0700
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 1/3] memcg: integrate soft reclaim tighter with zone
 shrinking code
Message-ID: <20130414143420.GA6478@dhcp22.suse.cz>
References: <1365509595-665-1-git-send-email-mhocko@suse.cz>
 <1365509595-665-2-git-send-email-mhocko@suse.cz>
 <20130414004252.GA1330@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130414004252.GA1330@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, Ying Han <yinghan@google.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>

On Sun 14-04-13 01:42:52, Mel Gorman wrote:
> On Tue, Apr 09, 2013 at 02:13:13PM +0200, Michal Hocko wrote:
> > Memcg soft reclaim has been traditionally triggered from the global
> > reclaim paths before calling shrink_zone. mem_cgroup_soft_limit_reclaim
> > then picked up a group which exceeds the soft limit the most and
> > reclaimed it with 0 priority to reclaim at least SWAP_CLUSTER_MAX pages.
> > 
> 
> I didn't realise it scanned at priority 0 or else I forgot! Priority 0
> scanning means memcg soft reclaim currently scans anon and file equally
> with the full LRU of ecah type considered as scan candidates. Consequently,
> it will reclaim SWAP_CLUSTER_MAX from each evictable LRU before stopping as
> sc->nr_to_reclaim pages have been scanned. It's only partially related to
> your series of course this is very blunt behaviour for memcg reclaim. In an
> ideal world of infinite free time it might be worth checking what happens
> if that thing scans at priority 1 or at least keep an eye on what happens
> priority when/if you replace mem_cgroup_shrink_node_zone

I do not think experimenting with prio 1 would make any difference. We
would still reclaim half of LRUs and bail out if at least
SWAP_CLUSTER_MAX cluster max pagas have been reclaimed after visiting
all reclaimable LRUs. The whole point of the series is to not do
anything special for the soft reclaim priority wise.

[...]
> > Soft reclaim should be applicable also to the targeted reclaim which is
> > awkward right now without additional hacks.
> > Last but not least the whole infrastructure eats a lot of code[1].
> > 
> > After this patch shrink_zone is done in 2. First it tries to do the
> 
> Done in 2 what? Passes I think.

Yes. Fixed.
 
[...]
> > +	if (res_counter_soft_limit_excess(&memcg->res))
> > +		return true;
> > +
> > +	/*
> > +	 * If any parent up the hierarchy is over its soft limit then we
> > +	 * have to obey and reclaim from this group as well.
> > +	 */
> > +	while((parent = parent_mem_cgroup(parent))) {
> > +		if (res_counter_soft_limit_excess(&parent->res))
> > +			return true;
> 
> Remove the initial if with this?
> /*
>  * If the target memcg or any of its parents are over their soft limit
>  * then we have to obey and reclaim from this group as well
>  */
> do {
> 	if (res_counter_soft_limit_excess(&memcg->res))
> 		return true;
> while ((memcg = parent_mem_cgroup(memcg));

The later patch changes this behavior. Where we treat current memcg and
parent slightly different based on whether the limit has been set by
an user or it is the default unlimited value.

[...]
> > -static void shrink_zone(struct zone *zone, struct scan_control *sc)
> > +static unsigned
> > +__shrink_zone(struct zone *zone, struct scan_control *sc, bool soft_reclaim)
> >  {
> >  	unsigned long nr_reclaimed, nr_scanned;
> > +	unsigned nr_shrunk = 0;
> >  
> >  	do {
> >  		struct mem_cgroup *root = sc->target_mem_cgroup;
> > @@ -1961,6 +1973,13 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
> >  		do {
> >  			struct lruvec *lruvec;
> >  
> > +			if (soft_reclaim &&
> > +					!mem_cgroup_soft_reclaim_eligible(memcg)) {
> > +				memcg = mem_cgroup_iter(root, memcg, &reclaim);
> > +				continue;
> > +			}
> > +
> 
> Calling mem_cgroup_soft_reclaim_eligible means we do multiple searches
> of the hierarchy while ascending the hierarchy. It's a stretch but it
> may be a problem for very deep hierarchies.

I think it shouldn't be a problem for hundreds of memcgs and I am quite
sceptical about such configurations for other reasons (e.g. charging
overhead). And we are in the reclaim path so this is hardly a hot path
(unlike the chargin). So while this might turn out to be a real problem
we would need to fix other parts as well with higher priority.

> Would it be worth having mem_cgroup_soft_reclaim_eligible return what
> the highest parent over its soft limit was and stop the iterator when
> the highest parent is reached?  I think this would avoid calling
> mem_cgroup_soft_reclaim_eligible multiple times.

This is basically what the original implementation did and I think it is
not the right way to go. First why should we care who is the most
exceeding group. We should treat them equally if the there is no special
reason to not do so. And I do not see such a special reason. Besides
that keeping a exceed sorted data structure of memcgs turned out quite a
lot of code. Note that the later patch integrate soft reclaim into
targeted reclaim which would mean that we would have to keep such a
list/tree per memcg.

> > +			nr_shrunk++;
> >  			lruvec = mem_cgroup_zone_lruvec(zone, memcg);
> >  
> >  			shrink_lruvec(lruvec, sc);
> > @@ -1984,6 +2003,27 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
> >  		} while (memcg);
> >  	} while (should_continue_reclaim(zone, sc->nr_reclaimed - nr_reclaimed,
> >  					 sc->nr_scanned - nr_scanned, sc));
> > +
> > +	return nr_shrunk;
> > +}
> > +
> > +
> > +static void shrink_zone(struct zone *zone, struct scan_control *sc)
> > +{
> > +	bool do_soft_reclaim = mem_cgroup_should_soft_reclaim(sc);
> > +	unsigned long nr_scanned = sc->nr_scanned;
> > +	unsigned nr_shrunk;
> > +
> > +	nr_shrunk = __shrink_zone(zone, sc, do_soft_reclaim);
> > +
> 
> The two pass thing is explained in the changelog very well but adding
> comments on it here would not hurt.

What about merging the comment that is already there with this?

/*
 * If memcg is enabled we try to reclaim only over-soft limit groups in
 * the first pass and only fallback to all groups reclaim if no group is
 * over the soft limit or those that are do not have pages in the zone
 * we are reclaiming so we have to reclaim everybody.
 * This will guarantee that groups that are below their soft limit are
 * not touched unless the memory pressure cannot be handled otherwise
 * and so the soft limit can be used for the working set preservation.
 */
> 
> Otherwise this patch looks like a great idea and memcg soft reclaim looks
> a lot less like it's stuck on the side.

Thanks for the review Mel!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
