Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id 75D876B0036
	for <linux-mm@kvack.org>; Fri,  2 May 2014 11:04:51 -0400 (EDT)
Received: by mail-ee0-f50.google.com with SMTP id c13so3181246eek.37
        for <linux-mm@kvack.org>; Fri, 02 May 2014 08:04:50 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id v2si1888768eel.226.2014.05.02.08.04.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 02 May 2014 08:04:49 -0700 (PDT)
Date: Fri, 2 May 2014 11:04:34 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/4] memcg, mm: introduce lowlimit reclaim
Message-ID: <20140502150434.GM23420@cmpxchg.org>
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
 <1398688005-26207-2-git-send-email-mhocko@suse.cz>
 <20140430225550.GD26041@cmpxchg.org>
 <20140502093628.GC3446@dhcp22.suse.cz>
 <20140502120715.GI3446@dhcp22.suse.cz>
 <20140502130118.GK23420@cmpxchg.org>
 <20140502141515.GJ3446@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140502141515.GJ3446@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri, May 02, 2014 at 04:15:15PM +0200, Michal Hocko wrote:
> On Fri 02-05-14 09:01:18, Johannes Weiner wrote:
> > On Fri, May 02, 2014 at 02:07:15PM +0200, Michal Hocko wrote:
> > > On Fri 02-05-14 11:36:28, Michal Hocko wrote:
> > > > On Wed 30-04-14 18:55:50, Johannes Weiner wrote:
> > > > > On Mon, Apr 28, 2014 at 02:26:42PM +0200, Michal Hocko wrote:
> > > > > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > > > > index 19d620b3d69c..40e517630138 100644
> > > > > > --- a/mm/memcontrol.c
> > > > > > +++ b/mm/memcontrol.c
> > > > > > @@ -2808,6 +2808,29 @@ static struct mem_cgroup *mem_cgroup_lookup(unsigned short id)
> > > > > >  	return mem_cgroup_from_id(id);
> > > > > >  }
> > > > > >  
> > > > > > +/**
> > > > > > + * mem_cgroup_reclaim_eligible - checks whether given memcg is eligible for the
> > > > > > + * reclaim
> > > > > > + * @memcg: target memcg for the reclaim
> > > > > > + * @root: root of the reclaim hierarchy (null for the global reclaim)
> > > > > > + *
> > > > > > + * The given group is reclaimable if it is above its low limit and the same
> > > > > > + * applies for all parents up the hierarchy until root (including).
> > > > > > + */
> > > > > > +bool mem_cgroup_reclaim_eligible(struct mem_cgroup *memcg,
> > > > > > +		struct mem_cgroup *root)
> > > > > 
> > > > > Could you please rename this to something that is more descriptive in
> > > > > the reclaim callsite?  How about mem_cgroup_within_low_limit()?
> > > > 
> > > > I have intentionally used somethig that is not low_limit specific. The
> > > > generic reclaim code does't have to care about the reason why a memcg is
> > > > not reclaimable. I agree that having follow_low_limit paramter explicit
> > > > and mem_cgroup_reclaim_eligible not is messy. So something should be
> > > > renamed. I would probably go with s@follow_low_limit@check_reclaim_eligible@
> > > > but I do not have a strong preference.
> > > 
> > > What about this?
> > 
> > I really don't like it.
> > 
> > Yes, we should be hiding implementation details, but we should stop
> > treating memcg like an alien in this code.  The VM code obviously
> > doesn't have to know HOW the guarantees are exactly implemented, but
> > it's a perfectly fine *concept* that can be known outside of memcg:
> > 
> > shrink_zone:
> > for each memcg in system:
> >   if mem_cgroup_within_guarantee(memcg):
> >     continue
> >   reclaim(memcg-zone)
> > 
> > is perfectly understandable and makes it easier to reason about the
> > behavior of the reclaim code.  If I just see !mem_cgroup_eligible(), I
> > don't know if this affects the scenario I'm thinking about at all.
> > 
> > It's obscuring useful information for absolutely no benefit.  If you
> > burden the reclaim code with a callback, you better explain what you
> > are doing.  You owe it to the reader.
> 
> OK fair enough, what about the following?

Thanks, that's much better IMO.

> @@ -2215,8 +2215,18 @@ static inline bool should_continue_reclaim(struct zone *zone,
>  	}
>  }
>  
> +/**
> + * __shrink_zone - shrinks a given zone
> + *
> + * @zone: zone to shrink
> + * @sc: scan control with additional reclaim parameters
> + * @force_memcg_guarantee: do not reclaim memcgs which are within their memory
> + * guarantee
> + *
> + * Returns the number of reclaimed memcgs.
> + */
>  static unsigned __shrink_zone(struct zone *zone, struct scan_control *sc,
> -		bool follow_low_limit)
> +		bool force_memcg_guarantee)
>  {
>  	unsigned long nr_reclaimed, nr_scanned;
>  	unsigned nr_scanned_groups = 0;
> @@ -2236,12 +2246,9 @@ static unsigned __shrink_zone(struct zone *zone, struct scan_control *sc,
>  		do {
>  			struct lruvec *lruvec;
>  
> -			/*
> -			 * Memcg might be under its low limit so we have to
> -			 * skip it during the first reclaim round
> -			 */
> -			if (follow_low_limit &&
> -					!mem_cgroup_reclaim_eligible(memcg, root)) {
> +			/* Memcg might be protected from the reclaim */
> +			if (force_memcg_guarantee &&

respect_?  consider_?

force sounds like something the second round would do -- force reclaim
despite guarantees...  But then again, I'm still for removing that 2nd
force cycle, so I don't care too strongly about that name (yet) :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
