Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 63BA06B004A
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 20:34:50 -0400 (EDT)
Date: Fri, 10 Jun 2011 02:34:07 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/8] mm: memcg-aware global reclaim
Message-ID: <20110610003407.GA27964@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
 <1306909519-7286-3-git-send-email-hannes@cmpxchg.org>
 <20110609154839.GF4878@barrios-laptop>
 <20110609172347.GB20333@cmpxchg.org>
 <BANLkTimD-pecv82qAZkyxA9nLQWbcDry-w@mail.gmail.com>
 <BANLkTin7uRdUg_mer3ve5nz3WjX9qjP4SQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTin7uRdUg_mer3ve5nz3WjX9qjP4SQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 10, 2011 at 08:47:55AM +0900, Minchan Kim wrote:
> On Fri, Jun 10, 2011 at 8:41 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> > On Fri, Jun 10, 2011 at 2:23 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> >> On Fri, Jun 10, 2011 at 12:48:39AM +0900, Minchan Kim wrote:
> >>> On Wed, Jun 01, 2011 at 08:25:13AM +0200, Johannes Weiner wrote:
> >>> > When a memcg hits its hard limit, hierarchical target reclaim is
> >>> > invoked, which goes through all contributing memcgs in the hierarchy
> >>> > below the offending memcg and reclaims from the respective per-memcg
> >>> > lru lists.  This distributes pressure fairly among all involved
> >>> > memcgs, and pages are aged with respect to their list buddies.
> >>> >
> >>> > When global memory pressure arises, however, all this is dropped
> >>> > overboard.  Pages are reclaimed based on global lru lists that have
> >>> > nothing to do with container-internal age, and some memcgs may be
> >>> > reclaimed from much more than others.
> >>> >
> >>> > This patch makes traditional global reclaim consider container
> >>> > boundaries and no longer scan the global lru lists.  For each zone
> >>> > scanned, the memcg hierarchy is walked and pages are reclaimed from
> >>> > the per-memcg lru lists of the respective zone.  For now, the
> >>> > hierarchy walk is bounded to one full round-trip through the
> >>> > hierarchy, or if the number of reclaimed pages reach the overall
> >>> > reclaim target, whichever comes first.
> >>> >
> >>> > Conceptually, global memory pressure is then treated as if the root
> >>> > memcg had hit its limit.  Since all existing memcgs contribute to the
> >>> > usage of the root memcg, global reclaim is nothing more than target
> >>> > reclaim starting from the root memcg.  The code is mostly the same for
> >>> > both cases, except for a few heuristics and statistics that do not
> >>> > always apply.  They are distinguished by a newly introduced
> >>> > global_reclaim() primitive.
> >>> >
> >>> > One implication of this change is that pages have to be linked to the
> >>> > lru lists of the root memcg again, which could be optimized away with
> >>> > the old scheme.  The costs are not measurable, though, even with
> >>> > worst-case microbenchmarks.
> >>> >
> >>> > As global reclaim no longer relies on global lru lists, this change is
> >>> > also in preparation to remove those completely.
> >>
> >> [cut diff]
> >>
> >>> I didn't look at all, still. You might change the logic later patches.
> >>> If I understand this patch right, it does round-robin reclaim in all memcgs
> >>> when global memory pressure happens.
> >>>
> >>> Let's consider this memcg size unbalance case.
> >>>
> >>> If A-memcg has lots of LRU pages, scanning count for reclaim would be bigger
> >>> so the chance to reclaim the pages would be higher.
> >>> If we reclaim A-memcg, we can reclaim the number of pages we want easily and break.
> >>> Next reclaim will happen at some time and reclaim will start the B-memcg of A-memcg
> >>> we reclaimed successfully before. But unfortunately B-memcg has small lru so
> >>> scanning count would be small and small memcg's LRU aging is higher than bigger memcg.
> >>> It means small memcg's working set can be evicted easily than big memcg.
> >>> my point is that we should not set next memcg easily.
> >>> We have to consider memcg LRU size.
> >>
> >> I may be missing something, but you said yourself that B had a smaller
> >> scan count compared to A, so the aging speed should be proportional to
> >> respective size.
> >>
> >> The number of pages scanned per iteration is essentially
> >>
> >>        number of lru pages in memcg-zone >> priority
> >>
> >> so we scan relatively more pages from B than from A each round.
> >>
> >> It's the exact same logic we have been applying traditionally to
> >> distribute pressure fairly among zones to equalize their aging speed.
> >>
> >> Is that what you meant or are we talking past each other?
> >
> > True if we can reclaim pages easily(ie, default priority) in all memcgs.
> > But let's think about it.
> > Normally direct reclaim path reclaims only SWAP_CLUSTER_MAX size.
> > If we have small memcg, scan window size would be smaller and it is
> > likely to be hard reclaim in the priority compared to bigger memcg. It
> > means it can raise priority easily in small memcg and even it might
> > call lumpy or compaction in case of global memory pressure. It can
> > churn all LRU order. :(
> > Of course, we have bailout routine so we might make such unfair aging
> > effect small but it's not same with old behavior(ie, single LRU list,
> > fair aging POV global according to priority raise)
> 
> To make fair, how about considering turn over different memcg before
> raise up priority?
> It can make aging speed fairly while it can make high contention of
> lru_lock. :(

Actually, the way you describe it is how it used to work for limit
reclaim before my patches.  It would select one memcg, then reclaim
with increasing priority until SWAP_CLUSTER_MAX were reclaimed.

	memcg = select_victim()
	for each prio:
	  for each zone:
	    shrink_zone(prio, zone, sc = { .mem_cgroup = memcg })

What it's supposed to do with my patches is scan all memcgs in the
hierarchy at the same priority.  If it hasn't made progress, it will
increase the priority and iterate again over the hierarchy.

	for each prio:
	  for each zone:
	    for each memcg:
	      do_shrink_zone(prio, zone, sc = { .mem_cgroup = memcg })

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
