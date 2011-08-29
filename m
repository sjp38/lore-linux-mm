Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6056E900137
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 15:04:57 -0400 (EDT)
Date: Mon, 29 Aug 2011 21:04:26 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/8] mm: memcg-aware global reclaim
Message-ID: <20110829190426.GC1434@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
 <1306909519-7286-3-git-send-email-hannes@cmpxchg.org>
 <CALWz4iwChnacF061L9vWo7nEA7qaXNJrK=+jsEe9xBtvEBD9MA@mail.gmail.com>
 <20110811210914.GB31229@cmpxchg.org>
 <CALWz4iwJfyWRineMy+W02YBvS0Y=Pv1y8Rb=8i5R=vUCfrO+iQ@mail.gmail.com>
 <CALWz4iwRXBheXFND5zq3ze2PJDkeoxYHD1zOsTyzOe3XqY5apA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALWz4iwRXBheXFND5zq3ze2PJDkeoxYHD1zOsTyzOe3XqY5apA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>

On Mon, Aug 29, 2011 at 12:22:02AM -0700, Ying Han wrote:
> On Mon, Aug 29, 2011 at 12:15 AM, Ying Han <yinghan@google.com> wrote:
> > On Thu, Aug 11, 2011 at 2:09 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> >>
> >> On Thu, Aug 11, 2011 at 01:39:45PM -0700, Ying Han wrote:
> >> > Please consider including the following patch for the next post. It causes
> >> > crash on some of the tests where sc->mem_cgroup is NULL (global kswapd).
> >> >
> >> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> >> > index b72a844..12ab25d 100644
> >> > --- a/mm/vmscan.c
> >> > +++ b/mm/vmscan.c
> >> > @@ -2768,7 +2768,8 @@ loop_again:
> >> >                          * Do some background aging of the anon list, to
> >> > give
> >> >                          * pages a chance to be referenced before
> >> > reclaiming.
> >> >                          */
> >> > -                       if (inactive_anon_is_low(zone, &sc))
> >> > +                       if (scanning_global_lru(&sc) &&
> >> > +                                       inactive_anon_is_low(zone, &sc))
> >> >                                 shrink_active_list(SWAP_CLUSTER_MAX, zone,
> >> >                                                         &sc, priority, 0);
> >>
> >> Thanks!  I completely overlooked this one and only noticed it after
> >> changing the arguments to shrink_active_list().
> >>
> >> On memcg configurations, scanning_global_lru() will essentially never
> >> be true again, so I moved the anon pre-aging to a separate function
> >> that also does a hierarchy loop to preage the per-memcg anon lists.
> >>
> >> I hope to send out the next revision soon.
> >
> > Also, please consider to fold in the following patch as well. It fixes
> > the root cgroup lru accounting and we could easily trigger OOM while
> > doing some swapoff test w/o it.
> >
> > mm:fix the lru accounting for root cgroup.
> >
> > This patch is applied on top of:
> > "
> > mm: memcg-aware global reclaim
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > "
> >
> > This patch fixes the lru accounting for root cgroup.
> >
> > After the "memcg-aware global reclaim" patch, one of the changes is to have
> > lru pages linked back to root. Under the global memory pressure, we start from
> > the root cgroup lru and walk through the memcg hierarchy of the system. For
> > each memcg, we reclaim pages based on the its lru size.
> >
> > However for root cgroup, we used not having a seperate lru and only counting
> > the pages charged to root as part of root lru size. Without this patch, all
> > the pages which are linked to root lru but not charged to root like swapcache
> > readahead are not visible to page reclaim code and we are easily to get OOM.
> >
> > After this patch, all the pages linked under root lru are counted in the lru
> > size, including Used and !Used.
> >
> > Signed-off-by: Hugh Dickins <hughd@google.com>
> > Signed-off-by: Ying Han <yinghan@google.com>
> >
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 5518f54..f6c5f29 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -888,19 +888,21 @@ void mem_cgroup_del_lru_list(struct page *page,
> > enum lru_list lru)
> >  {
> >  >------struct page_cgroup *pc;
> >  >------struct mem_cgroup_per_zone *mz;
> > +>------struct mem_cgroup *mem;
> > .
> >  >------if (mem_cgroup_disabled())
> >  >------>-------return;
> >  >------pc = lookup_page_cgroup(page);
> > ->------/* can happen while we handle swapcache. */
> > ->------if (!TestClearPageCgroupAcctLRU(pc))
> > ->------>-------return;
> > ->------VM_BUG_ON(!pc->mem_cgroup);
> > ->------/*
> > ->------ * We don't check PCG_USED bit. It's cleared when the "page" is finally
> > ->------ * removed from global LRU.
> > ->------ */
> > ->------mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
> > +
> > +>------if (TestClearPageCgroupAcctLRU(pc) || PageCgroupUsed(pc)) {

This PageCgroupUsed part confuses me.  A page that is being isolated
shortly after being charged while on the LRU may reach here, and then
it is unaccounted from pc->mem_cgroup, which it never was accounted
to.

Could you explain why you added it?

I now made it so that PageCgroupAcctLRU on the LRU means accounted to
pc->mem_cgroup, and !PageCgroupAcctLRU on the LRU means accounted to
and babysitted by root_mem_cgroup.  Always.  Which also means that
before_commit now ensures an LRU page is moved to root_mem_cgroup for
babysitting during the charge, so that concurrent isolations/putbacks
are always accounted correctly.  Is this what you had in mind?  Did I
miss something?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
