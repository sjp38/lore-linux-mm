Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id F01A36B00E7
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 10:01:44 -0400 (EDT)
Date: Thu, 9 Jun 2011 16:01:40 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 2/8] mm: memcg-aware global reclaim
Message-ID: <20110609140140.GC3994@tiehlicka.suse.cz>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
 <1306909519-7286-3-git-send-email-hannes@cmpxchg.org>
 <BANLkTikKHq=NBAPOXJVDM7ZEc9CkW+HdmQ@mail.gmail.com>
 <20110602150123.GE28684@cmpxchg.org>
 <BANLkTinWGEJHf1MhzDS4JB0-V9iynoFoHA@mail.gmail.com>
 <20110602172905.GF28684@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20110602172905.GF28684@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 02-06-11 19:29:05, Johannes Weiner wrote:
> On Fri, Jun 03, 2011 at 01:14:12AM +0900, Hiroyuki Kamezawa wrote:
> > 2011/6/3 Johannes Weiner <hannes@cmpxchg.org>:
> > > On Thu, Jun 02, 2011 at 10:59:01PM +0900, Hiroyuki Kamezawa wrote:
> > >> 2011/6/1 Johannes Weiner <hannes@cmpxchg.org>:
> > 
> > >> > @@ -1927,8 +1980,7 @@ static int mem_cgroup_do_charge(struct mem_cgroup *mem, gfp_t gfp_mask,
> > >> >        if (!(gfp_mask & __GFP_WAIT))
> > >> >                return CHARGE_WOULDBLOCK;
> > >> >
> > >> > -       ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
> > >> > -                                             gfp_mask, flags);
> > >> > +       ret = mem_cgroup_reclaim(mem_over_limit, gfp_mask, flags);
> > >> >        if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
> > >> >                return CHARGE_RETRY;
> > >> >        /*
> > >>
> > >> It seems this clean-up around hierarchy and softlimit can be in an
> > >> independent patch, no ?
> > >
> > > Hm, why do you think it's a cleanup?  The hierarchical target reclaim
> > > code is moved to vmscan.c and as a result the entry points for hard
> > > limit and soft limit reclaim differ.  This is why the original
> > > function, mem_cgroup_hierarchical_reclaim() has to be split into two
> > > parts.
> > >
> > If functionality is unchanged, I think it's clean up.
> > I agree to move hierarchy walk to vmscan.c. but it can be done as
> > a clean up patch for current code.
> > (Make current try_to_free_mem_cgroup_pages() to use this code.)
> >  and then, you can write a patch which only includes a core
> > logic/purpose of this patch
> > "use root cgroup's LRU for global and make global reclaim as full-scan
> > of memcgroup."
> > 
> > In short, I felt this patch is long....and maybe watchers of -mm are
> > not interested in rewritie of hierarchy walk but are intetested in the
> > chages in shrink_zone() itself very much.
> 
> But the split up is, unfortunately, a change in functionality.  The
> current code selects one memcg and reclaims all zones on all priority
> levels on behalf of that memcg.  My code changes that such that it
> reclaims a bunch of memcgs from the hierarchy for each zone and
> priority level instead.  From memcgs -> priorities -> zones to
> priorities -> zones -> memcgs.

I think you should mention this in the change log it nicely describes
the core of the change.

> 
> I don't want to pass that off as a cleanup.
> 
> But it is long, I agree with you.  I'll split up the 'move
> hierarchical target reclaim to generic code' from 'make global reclaim
> hierarchical' and see if this makes the changes more straight-forward.
> 
> Because I suspect the perceived unwieldiness does not stem from the
> amount of lines changed, but from the number of different logical
> changes.

Agreed.

> 
> > >> > +       for (;;) {
> > >> > +               unsigned long nr_reclaimed;
> > >> > +
> > >> > +               sc->mem_cgroup = mem;
> > >> > +               do_shrink_zone(priority, zone, sc);
> > >> > +
> > >> > +               nr_reclaimed = sc->nr_reclaimed - nr_reclaimed_before;
> > >> > +               if (nr_reclaimed >= sc->nr_to_reclaim)
> > >> > +                       break;
> > >>
> > >> what this calculation means ?  Shouldn't we do this quit based on the
> > >> number of "scan"
> > >> rather than "reclaimed" ?
> > >
> > > It aborts the loop once sc->nr_to_reclaim pages have been reclaimed
> > > from that zone during that hierarchy walk, to prevent overreclaim.
> > >
> > > If you have unbalanced sizes of memcgs in the system, it is not
> > > desirable to have every reclaimer scan all memcgs, but let those quit
> > > early that have made some progress on the bigger memcgs.
> > >
> > Hmm, why not if (sc->nr_reclaimed >= sc->nr_to_reclaim) ?
> > 
> > I'm sorry if I miss something..
> 
> It's a bit awkward and undocumented, I'm afraid.  The loop is like
> this:
> 
> 	for each zone:
> 	  for each memcg:
> 	    shrink
> 	    if sc->nr_reclaimed >= sc->nr_to_reclaim:
> 	      break
> 
> sc->nr_reclaimed is never reset, so once you reclaimed enough pages
> from one zone, you will only try the first memcg in all the other
> zones, which might well be empty, so no pressure at all on subsequent
> zones.
> 
> That's why I use the per-zone delta like this:
> 
>        for each zone:
>          before = sc->nr_reclaimed
> 	 for each memcg:
> 	   shrink
> 	   if sc->nr_reclaimed - before >= sc->nr_to_reclaim
> 
> which still ensures on one hand that we don't keep hammering a zone if
> we reclaimed the overall reclaim target already, but on the other hand
> that we apply some pressure to the other zones as well.
> 
> It's the same concept as in do_shrink_zone().  It breaks the loop when
> 
> 	nr_reclaimed >= sc->nr_to_reclaim

Maybe you could make do_shrink_zone return the number of reclaimed
pages. It's true that it would require yet another nr_reclaimed variable
in the that function but it would be more straightforward IMO.
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
