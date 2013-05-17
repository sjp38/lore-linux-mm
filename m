Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 6380E6B0032
	for <linux-mm@kvack.org>; Fri, 17 May 2013 03:34:15 -0400 (EDT)
Date: Fri, 17 May 2013 09:34:13 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v3 -mm 3/3] vmscan, memcg: Do softlimit reclaim also for
 targeted reclaim
Message-ID: <20130517073413.GE25158@dhcp22.suse.cz>
References: <1368431172-6844-1-git-send-email-mhocko@suse.cz>
 <1368431172-6844-4-git-send-email-mhocko@suse.cz>
 <20130516231238.GA15025@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130516231238.GA15025@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Balbir Singh <bsingharora@gmail.com>

On Thu 16-05-13 16:12:38, Tejun Heo wrote:
> On Mon, May 13, 2013 at 09:46:12AM +0200, Michal Hocko wrote:
> > Soft reclaim has been done only for the global reclaim (both background
> > and direct). Since "memcg: integrate soft reclaim tighter with zone
> > shrinking code" there is no reason for this limitation anymore as the
> > soft limit reclaim doesn't use any special code paths and it is a
> > part of the zone shrinking code which is used by both global and
> > targeted reclaims.
> ...
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
>  Reviewed-by: Tejun Heo <tj@kernel.org>

Thanks

> 
> Some nitpicks follow.
> 
> >  /*
> > - * A group is eligible for the soft limit reclaim if it is
> > - * 	a) is over its soft limit
> > + * A group is eligible for the soft limit reclaim under the given root
> > + * hierarchy if
> > + * 	a) it is over its soft limit
> >   * 	b) any parent up the hierarchy is over its soft limit
> 
> This was added before but in general I think the use of parent for
> ancestor is a bit confusing.  Not a big deal but no reason to continue
> it.

$ git grep ancestor mm/memcontrol.c | wc -l
4
$ git grep
parent mm/memcontrol.c | wc -l
80

Yeah, we are used to use parent much more. Maybe it is worth a clean up
on its own but I will stick with the majority in this patch

> >  	/*
> > -	 * If any parent up the hierarchy is over its soft limit then we
> > -	 * have to obey and reclaim from this group as well.
> > +	 * If any parent up to the root in the hierarchy is over its soft limit
> > +	 * then we have to obey and reclaim from this group as well.
> 
> Prolly using terms ancestors and subtree would make the explanation
> clearer?

As I said earlier we should be explicit about hierarchy as
ancestor/parent (what ever we call it) might or might not be part of the
hierarchy. Yeah, we have that use_hierarchy thingy which we love so
much.

> >  static bool mem_cgroup_should_soft_reclaim(struct scan_control *sc)
> >  {
> > -	return global_reclaim(sc);
> > +	return true;
> 
> Kinda silly after this change, maybe just modify shrink_zone() like
> the following?
> 
>         if (IS_ENABLED(CONFIG_MEMCG)) {
> 		__shrink_zone(zone, sc, true);
> 		if (sc->nr_scanned == nr_scanned)
> 			__shrink_zone(zone, sc, false);
> 	} else {
> 		__shrink_zone(zone, sc, false);
>         }

I plan to build on top of this where mem_cgroup_should_soft_reclaim
would do more than just return true. So I will keep it this way if you
do not mind.

> > @@ -1974,7 +1974,7 @@ __shrink_zone(struct zone *zone, struct scan_control *sc, bool soft_reclaim)
> >  			struct lruvec *lruvec;
> >  
> >  			if (soft_reclaim &&
> > -					!mem_cgroup_soft_reclaim_eligible(memcg)) {
> > +					!mem_cgroup_soft_reclaim_eligible(memcg, root)) {
> 
> Weird indentation which breaks line and goes over 80 col, why not do
> the following?
> 
> 		if (soft_reclaim &&
> 		    !mem_cgroup_soft_reclaim_eligible(memcg, root)) {
> 			memcg = mem_cgroup_iter(root, memcg, &reclaim);
> 			continue;
> 		}

Hmm, I rely on vim doing the_right_thing usually. I definitely do not
mind to change the formatting. I have fixed this in the first patch
where the code has been introduced and refreshed this patch on top of
that.

I will repost the whole series with reviewed-bys and other acks later

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
