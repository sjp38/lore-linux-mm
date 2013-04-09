Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 0EA036B0005
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 13:05:43 -0400 (EDT)
Date: Tue, 9 Apr 2013 19:05:38 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 1/3] memcg: integrate soft reclaim tighter with zone
 shrinking code
Message-ID: <20130409170538.GN29860@dhcp22.suse.cz>
References: <1365509595-665-1-git-send-email-mhocko@suse.cz>
 <1365509595-665-2-git-send-email-mhocko@suse.cz>
 <5164459F.1010903@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5164459F.1010903@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Ying Han <yinghan@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>

On Wed 10-04-13 01:45:19, KAMEZAWA Hiroyuki wrote:
> (2013/04/09 21:13), Michal Hocko wrote:
[...]
> > @@ -1942,9 +1952,11 @@ static inline bool should_continue_reclaim(struct zone *zone,
> >   	}
> >   }
> >   
> > -static void shrink_zone(struct zone *zone, struct scan_control *sc)
> > +static unsigned
> > +__shrink_zone(struct zone *zone, struct scan_control *sc, bool soft_reclaim)
> >   {
> >   	unsigned long nr_reclaimed, nr_scanned;
> > +	unsigned nr_shrunk = 0;
> 
> What does this number mean ?

number of groups that we called shrink_lruvec for.

> >   	do {
> >   		struct mem_cgroup *root = sc->target_mem_cgroup;
> > @@ -1961,6 +1973,13 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
> >   		do {
> >   			struct lruvec *lruvec;
> >   
> > +			if (soft_reclaim &&
> > +					!mem_cgroup_soft_reclaim_eligible(memcg)) {
> > +				memcg = mem_cgroup_iter(root, memcg, &reclaim);
> > +				continue;
> > +			}
> > +
> > +			nr_shrunk++;
> >   			lruvec = mem_cgroup_zone_lruvec(zone, memcg);
> 
> nr_shrunk will be updated even if the memcg has no pages to be reclaimed...right ?

yes.

> 
> >   
> >   			shrink_lruvec(lruvec, sc);
> > @@ -1984,6 +2003,27 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
> >   		} while (memcg);
> >   	} while (should_continue_reclaim(zone, sc->nr_reclaimed - nr_reclaimed,
> >   					 sc->nr_scanned - nr_scanned, sc));
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
> > +	/*
> > +	 * No group is over the soft limit or those that are do not have
> > +	 * pages in the zone we are reclaiming so we have to reclaim everybody
> > +	 */
> > +	if (do_soft_reclaim && (!nr_shrunk || sc->nr_scanned == nr_scanned)) {
> > +		__shrink_zone(zone, sc, false);
> > +		return;
> > +	}
> 
> Hmm...so...nr_shrunk is working as a bool value. Isn't it better to call
> __shrink_zone(...,false) if above shrink_zone(...,true) couldn't make
> good progress ?

Yes that was an attempt and as Johannes already pointed out nr_shrunk is
superseded by nr_scanned check

> memory-disk ping-pong will happen in bad case.

I am not sure what you mean by this.

> I think....in the 1st run, you can count amount of pages, which are
> candidates to be reclaimed. Then, you can compare the amounts of
> reclaim target and the priority and size of the target (amounts of
> reclaimable memory on the target zonelist), make a decision to fallback to
> full global reclaim or not.

I would like to keep the logic as simple as possible. nr_scanned
progress is a protection from increasing the priority and should be
sufficient for starter. There is still possibility that a small groups
over their soft limit won't have any pages to reclaim because those are
dirty but those pages should be flushed during the global reclaim and we
wait for them during targeted reclaim.

But I agree that maybe we need also a priority check here. Will think
about it.

> 
> Thanks,
> -Kame
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
