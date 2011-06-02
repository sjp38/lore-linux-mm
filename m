Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id AA04E6B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 11:01:51 -0400 (EDT)
Date: Thu, 2 Jun 2011 17:01:23 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/8] mm: memcg-aware global reclaim
Message-ID: <20110602150123.GE28684@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
 <1306909519-7286-3-git-send-email-hannes@cmpxchg.org>
 <BANLkTikKHq=NBAPOXJVDM7ZEc9CkW+HdmQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTikKHq=NBAPOXJVDM7ZEc9CkW+HdmQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jun 02, 2011 at 10:59:01PM +0900, Hiroyuki Kamezawa wrote:
> 2011/6/1 Johannes Weiner <hannes@cmpxchg.org>:
> > @@ -1381,6 +1373,97 @@ u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
> >        return min(limit, memsw);
> >  }
> >
> > +/**
> > + * mem_cgroup_hierarchy_walk - iterate over a memcg hierarchy
> > + * @root: starting point of the hierarchy
> > + * @prev: previous position or NULL
> > + *
> > + * Caller must hold a reference to @root.  While this function will
> > + * return @root as part of the walk, it will never increase its
> > + * reference count.
> > + *
> > + * Caller must clean up with mem_cgroup_stop_hierarchy_walk() when it
> > + * stops the walk potentially before the full round trip.
> > + */
> > +struct mem_cgroup *mem_cgroup_hierarchy_walk(struct mem_cgroup *root,
> > +                                            struct mem_cgroup *prev)
> > +{
> > +       struct mem_cgroup *mem;
> > +
> > +       if (mem_cgroup_disabled())
> > +               return NULL;
> > +
> > +       if (!root)
> > +               root = root_mem_cgroup;
> > +       /*
> > +        * Even without hierarchy explicitely enabled in the root
> > +        * memcg, it is the ultimate parent of all memcgs.
> > +        */
> > +       if (!(root == root_mem_cgroup || root->use_hierarchy))
> > +               return root;
> 
> Hmm, because ROOT cgroup has no limit and control, if root=root_mem_cgroup,
> we do full hierarchy scan always. Right ?

What it essentially means is that all existing memcgs in the system
contribute to the usage of root_mem_cgroup.

If there is global memory pressure, we need to consider reclaiming
from every single memcg in the system.

> > +static unsigned long mem_cgroup_reclaim(struct mem_cgroup *mem,
> > +                                       gfp_t gfp_mask,
> > +                                       unsigned long flags)
> > +{
> > +       unsigned long total = 0;
> > +       bool noswap = false;
> > +       int loop;
> > +
> > +       if ((flags & MEM_CGROUP_RECLAIM_NOSWAP) || mem->memsw_is_minimum)
> > +               noswap = true;
> > +       for (loop = 0; loop < MEM_CGROUP_MAX_RECLAIM_LOOPS; loop++) {
> > +               drain_all_stock_async();
> 
> In recent patch, I removed this call here because this wakes up
> kworker too much.
> I will post that patch as a bugfix. So, please adjust this call
> somewhere which is
> not called frequently.

Okay, please CC me when you send out the bugfix.

> > @@ -1927,8 +1980,7 @@ static int mem_cgroup_do_charge(struct mem_cgroup *mem, gfp_t gfp_mask,
> >        if (!(gfp_mask & __GFP_WAIT))
> >                return CHARGE_WOULDBLOCK;
> >
> > -       ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
> > -                                             gfp_mask, flags);
> > +       ret = mem_cgroup_reclaim(mem_over_limit, gfp_mask, flags);
> >        if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
> >                return CHARGE_RETRY;
> >        /*
> 
> It seems this clean-up around hierarchy and softlimit can be in an
> independent patch, no ?

Hm, why do you think it's a cleanup?  The hierarchical target reclaim
code is moved to vmscan.c and as a result the entry points for hard
limit and soft limit reclaim differ.  This is why the original
function, mem_cgroup_hierarchical_reclaim() has to be split into two
parts.

> > @@ -1943,6 +1976,31 @@ restart:
> >        throttle_vm_writeout(sc->gfp_mask);
> >  }
> >
> > +static void shrink_zone(int priority, struct zone *zone,
> > +                       struct scan_control *sc)
> > +{
> > +       unsigned long nr_reclaimed_before = sc->nr_reclaimed;
> > +       struct mem_cgroup *root = sc->target_mem_cgroup;
> > +       struct mem_cgroup *first, *mem = NULL;
> > +
> > +       first = mem = mem_cgroup_hierarchy_walk(root, mem);
> 
> Hmm, I think we should add some scheduling here, later.
> (as select a group over softlimit or select a group which has
>  easily reclaimable pages on this zone.)
> 
> This name as hierarchy_walk() sounds like "full scan in round-robin, always".
> Could you find better name ?

Okay, I'll try.

> > +       for (;;) {
> > +               unsigned long nr_reclaimed;
> > +
> > +               sc->mem_cgroup = mem;
> > +               do_shrink_zone(priority, zone, sc);
> > +
> > +               nr_reclaimed = sc->nr_reclaimed - nr_reclaimed_before;
> > +               if (nr_reclaimed >= sc->nr_to_reclaim)
> > +                       break;
> 
> what this calculation means ?  Shouldn't we do this quit based on the
> number of "scan"
> rather than "reclaimed" ?

It aborts the loop once sc->nr_to_reclaim pages have been reclaimed
from that zone during that hierarchy walk, to prevent overreclaim.

If you have unbalanced sizes of memcgs in the system, it is not
desirable to have every reclaimer scan all memcgs, but let those quit
early that have made some progress on the bigger memcgs.

It's essentially a forward progagation of the same check in
do_shrink_zone().  It trades absolute fairness for average reclaim
latency.

Note that kswapd sets the reclaim target to infinity, so this
optimization applies only to direct reclaimers.

> > +               mem = mem_cgroup_hierarchy_walk(root, mem);
> > +               if (mem == first)
> > +                       break;
> 
> Why we quit loop  ?

get_scan_count() for traditional global reclaim returns the scan
target for the zone.

With this per-memcg reclaimer, get_scan_count() will return scan
targets for the respective per-memcg zone subsizes.

So once we have gone through all memcgs, we should have scanned the
amount of pages that global reclaim would have deemed sensible for
that zone at that priority level.

As such, this is the exit condition based on scan count you referred
to above.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
