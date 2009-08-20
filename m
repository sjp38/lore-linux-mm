Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 442266B004F
	for <linux-mm@kvack.org>; Thu, 20 Aug 2009 08:32:23 -0400 (EDT)
Date: Thu, 20 Aug 2009 20:32:06 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH -v2] mm: do batched scans for mem_cgroup
Message-ID: <20090820123206.GA9770@localhost>
References: <20090820024929.GA19793@localhost> <20090820121347.8a886e4b.kamezawa.hiroyu@jp.fujitsu.com> <20090820040533.GA27540@localhost> <28c262360908200401t41c03ad3n114b24e03b61de08@mail.gmail.com> <20090820114933.GB7359@localhost> <28c262360908200513y3fee675do4e1f0204ffb8df63@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <28c262360908200513y3fee675do4e1f0204ffb8df63@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 20, 2009 at 08:13:59PM +0800, Minchan Kim wrote:
> On Thu, Aug 20, 2009 at 8:49 PM, Wu Fengguang<fengguang.wu@intel.com> wrote:
> > On Thu, Aug 20, 2009 at 07:01:21PM +0800, Minchan Kim wrote:
> >> Hi, Wu.
> >>
> >> On Thu, Aug 20, 2009 at 1:05 PM, Wu Fengguang<fengguang.wu@intel.com> wrote:
> >> > On Thu, Aug 20, 2009 at 11:13:47AM +0800, KAMEZAWA Hiroyuki wrote:
> >> >> On Thu, 20 Aug 2009 10:49:29 +0800
> >> >> Wu Fengguang <fengguang.wu@intel.com> wrote:
> >> >>
> >> >> > For mem_cgroup, shrink_zone() may call shrink_list() with nr_to_scan=1,
> >> >> > in which case shrink_list() _still_ calls isolate_pages() with the much
> >> >> > larger SWAP_CLUSTER_MAX. A It effectively scales up the inactive list
> >> >> > scan rate by up to 32 times.
> >> >> >
> >> >> > For example, with 16k inactive pages and DEF_PRIORITY=12, (16k >> 12)=4.
> >> >> > So when shrink_zone() expects to scan 4 pages in the active/inactive
> >> >> > list, it will be scanned SWAP_CLUSTER_MAX=32 pages in effect.
> >> >> >
> >> >> > The accesses to nr_saved_scan are not lock protected and so not 100%
> >> >> > accurate, however we can tolerate small errors and the resulted small
> >> >> > imbalanced scan rates between zones.
> >> >> >
> >> >> > This batching won't blur up the cgroup limits, since it is driven by
> >> >> > "pages reclaimed" rather than "pages scanned". When shrink_zone()
> >> >> > decides to cancel (and save) one smallish scan, it may well be called
> >> >> > again to accumulate up nr_saved_scan.
> >> >> >
> >> >> > It could possibly be a problem for some tiny mem_cgroup (which may be
> >> >> > _full_ scanned too much times in order to accumulate up nr_saved_scan).
> >> >> >
> >> >> > CC: Rik van Riel <riel@redhat.com>
> >> >> > CC: Minchan Kim <minchan.kim@gmail.com>
> >> >> > CC: Balbir Singh <balbir@linux.vnet.ibm.com>
> >> >> > CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> >> >> > CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >> >> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> >> >> > ---
> >> >>
> >> >> Hmm, how about this ?
> >> >> ==
> >> >> Now, nr_saved_scan is tied to zone's LRU.
> >> >> But, considering how vmscan works, it should be tied to reclaim_stat.
> >> >>
> >> >> By this, memcg can make use of nr_saved_scan information seamlessly.
> >> >
> >> > Good idea, full patch updated with your signed-off-by :)
> >> >
> >> > Thanks,
> >> > Fengguang
> >> > ---
> >> > mm: do batched scans for mem_cgroup
> >> >
> >> > For mem_cgroup, shrink_zone() may call shrink_list() with nr_to_scan=1,
> >> > in which case shrink_list() _still_ calls isolate_pages() with the much
> >> > larger SWAP_CLUSTER_MAX. A It effectively scales up the inactive list
> >> > scan rate by up to 32 times.
> >>
> >> Yes. It can scan 32 times pages in only inactive list, not active list.
> >
> > Yes and no ;)
> >
> > inactive anon list over scanned => inactive_anon_is_low() == TRUE
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A => shrink_active_list()
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A => active anon list over scanned
> 
> Why inactive anon list is overscanned in case mem_cgroup ?
> 
> in shrink_zone,
> 1) The vm doesn't accumulate nr[l].
> 2) Below routine store min value to nr_to_scan.
> nr_to_scan = min(nr[l], swap_cluster_max);
> ex) if nr[l] = 4, vm calls shrink_active_list with 4 as nr_to_scan.

It's not over scanned here, but at end of shrink_zone():

        /* 
         * Even if we did not try to evict anon pages at all, we want to
         * rebalance the anon lru active/inactive ratio.
         */
        if (inactive_anon_is_low(zone, sc) && nr_swap_pages > 0)
                shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);

as well as balance_pgdat():

                        /*
                         * Do some background aging of the anon list, to give
                         * pages a chance to be referenced before reclaiming.
                         */
                        if (inactive_anon_is_low(zone, &sc))
                                shrink_active_list(SWAP_CLUSTER_MAX, zone,
                                                        &sc, priority, 0);

So the anon lists are over scanned compared to the active file list.

> So I think overscan doesn't occur in active list.
> 
> > So the end result may be
> >
> > - anon inactive A => over scanned
> > - anon active A  A => over scanned (maybe not as much)
> > - file inactive A => over scanned
> > - file active A  A => under scanned (relatively)
> >
> >> > For example, with 16k inactive pages and DEF_PRIORITY=12, (16k >> 12)=4.
> >> > So when shrink_zone() expects to scan 4 pages in the active/inactive
> >> > list, it will be scanned SWAP_CLUSTER_MAX=32 pages in effect.
> >>
> >> Active list scan would be scanned in 4, A inactive list A is 32.
> >
> > Exactly.
> >
> >> >
> >> > The accesses to nr_saved_scan are not lock protected and so not 100%
> >> > accurate, however we can tolerate small errors and the resulted small
> >> > imbalanced scan rates between zones.
> >>
> >> Yes.
> >>
> >> > This batching won't blur up the cgroup limits, since it is driven by
> >> > "pages reclaimed" rather than "pages scanned". When shrink_zone()
> >> > decides to cancel (and save) one smallish scan, it may well be called
> >> > again to accumulate up nr_saved_scan.
> >>
> >> You mean nr_scan_try_batch logic ?
> >> But that logic works for just global reclaim?
> >> Now am I missing something?
> >>
> >> Could you elaborate more? :)
> >
> > Sorry for the confusion. The above paragraph originates from Balbir's
> > concern:
> >
> > A  A  A  A This might be a concern (although not a big ATM), since we can't
> > A  A  A  A afford to miss limits by much. If a cgroup is near its limit and we
> > A  A  A  A drop scanning it. We'll have to work out what this means for the end
> 
> Why does mem_cgroup drops scanning ?

Right, it has no reason to drop scanning, as long as it has not
reclaimed enough pages.

> It's because nr_scan_try_batch? or something ?

nr_scan_try_batch may only make this invocation of shrink_zone() drop scanning.
But balance_pgdat() etc. will re-call shrink_zone() to make progress.

> Sorry. Still, I can't understand your point. :(

It's _nothing_ wrong with you to not able to understand it :)
Sorry, I was explaining a null issue indeed. I'd better just remove that paragraph..
 
Thanks,
Fengguang

> > A  A  A  A user. May be more fundamental look through is required at the priority
> > A  A  A  A based logic of exposing how much to scan, I don't know.
> >
> > Thanks,
> > Fengguang
> >
> >> > It could possibly be a problem for some tiny mem_cgroup (which may be
> >> > _full_ scanned too much times in order to accumulate up nr_saved_scan).
> >> >
> >> > CC: Rik van Riel <riel@redhat.com>
> >> > CC: Minchan Kim <minchan.kim@gmail.com>
> >> > CC: Balbir Singh <balbir@linux.vnet.ibm.com>
> >> > CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> >> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> >> > ---
> >> > A include/linux/mmzone.h | A  A 6 +++++-
> >> > A mm/page_alloc.c A  A  A  A | A  A 2 +-
> >> > A mm/vmscan.c A  A  A  A  A  A | A  20 +++++++++++---------
> >> > A 3 files changed, 17 insertions(+), 11 deletions(-)
> >> >
> >> > --- linux.orig/include/linux/mmzone.h A  2009-07-30 10:45:15.000000000 +0800
> >> > +++ linux/include/linux/mmzone.h A  A  A  A 2009-08-20 11:51:08.000000000 +0800
> >> > @@ -269,6 +269,11 @@ struct zone_reclaim_stat {
> >> > A  A  A  A  */
> >> > A  A  A  A unsigned long A  A  A  A  A  recent_rotated[2];
> >> > A  A  A  A unsigned long A  A  A  A  A  recent_scanned[2];
> >> > +
> >> > + A  A  A  /*
> >> > + A  A  A  A * accumulated for batching
> >> > + A  A  A  A */
> >> > + A  A  A  unsigned long A  A  A  A  A  nr_saved_scan[NR_LRU_LISTS];
> >> > A };
> >> >
> >> > A struct zone {
> >> > @@ -323,7 +328,6 @@ struct zone {
> >> > A  A  A  A spinlock_t A  A  A  A  A  A  A lru_lock;
> >> > A  A  A  A struct zone_lru {
> >> > A  A  A  A  A  A  A  A struct list_head list;
> >> > - A  A  A  A  A  A  A  unsigned long nr_saved_scan; A  A /* accumulated for batching */
> >> > A  A  A  A } lru[NR_LRU_LISTS];
> >> >
> >> > A  A  A  A struct zone_reclaim_stat reclaim_stat;
> >> > --- linux.orig/mm/vmscan.c A  A  A 2009-08-20 11:48:46.000000000 +0800
> >> > +++ linux/mm/vmscan.c A  2009-08-20 12:00:55.000000000 +0800
> >> > @@ -1521,6 +1521,7 @@ static void shrink_zone(int priority, st
> >> > A  A  A  A enum lru_list l;
> >> > A  A  A  A unsigned long nr_reclaimed = sc->nr_reclaimed;
> >> > A  A  A  A unsigned long swap_cluster_max = sc->swap_cluster_max;
> >> > + A  A  A  struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
> >> > A  A  A  A int noswap = 0;
> >> >
> >> > A  A  A  A /* If we have no swap space, do not bother scanning anon pages. */
> >> > @@ -1540,12 +1541,9 @@ static void shrink_zone(int priority, st
> >> > A  A  A  A  A  A  A  A  A  A  A  A scan >>= priority;
> >> > A  A  A  A  A  A  A  A  A  A  A  A scan = (scan * percent[file]) / 100;
> >> > A  A  A  A  A  A  A  A }
> >> > - A  A  A  A  A  A  A  if (scanning_global_lru(sc))
> >> > - A  A  A  A  A  A  A  A  A  A  A  nr[l] = nr_scan_try_batch(scan,
> >> > - A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  &zone->lru[l].nr_saved_scan,
> >> > - A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  swap_cluster_max);
> >> > - A  A  A  A  A  A  A  else
> >> > - A  A  A  A  A  A  A  A  A  A  A  nr[l] = scan;
> >> > + A  A  A  A  A  A  A  nr[l] = nr_scan_try_batch(scan,
> >> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  &reclaim_stat->nr_saved_scan[l],
> >> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  swap_cluster_max);
> >> > A  A  A  A }
> >> >
> >> > A  A  A  A while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
> >> > @@ -2128,6 +2126,7 @@ static void shrink_all_zones(unsigned lo
> >> > A {
> >> > A  A  A  A struct zone *zone;
> >> > A  A  A  A unsigned long nr_reclaimed = 0;
> >> > + A  A  A  struct zone_reclaim_stat *reclaim_stat;
> >> >
> >> > A  A  A  A for_each_populated_zone(zone) {
> >> > A  A  A  A  A  A  A  A enum lru_list l;
> >> > @@ -2144,11 +2143,14 @@ static void shrink_all_zones(unsigned lo
> >> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A l == LRU_ACTIVE_FILE))
> >> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A continue;
> >> >
> >> > - A  A  A  A  A  A  A  A  A  A  A  zone->lru[l].nr_saved_scan += (lru_pages >> prio) + 1;
> >> > - A  A  A  A  A  A  A  A  A  A  A  if (zone->lru[l].nr_saved_scan >= nr_pages || pass > 3) {
> >> > + A  A  A  A  A  A  A  A  A  A  A  reclaim_stat = get_reclaim_stat(zone, sc);
> >> > + A  A  A  A  A  A  A  A  A  A  A  reclaim_stat->nr_saved_scan[l] +=
> >> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  (lru_pages >> prio) + 1;
> >> > + A  A  A  A  A  A  A  A  A  A  A  if (reclaim_stat->nr_saved_scan[l]
> >> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  >= nr_pages || pass > 3) {
> >> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A unsigned long nr_to_scan;
> >> >
> >> > - A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  zone->lru[l].nr_saved_scan = 0;
> >> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  reclaim_stat->nr_saved_scan[l] = 0;
> >> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A nr_to_scan = min(nr_pages, lru_pages);
> >> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A nr_reclaimed += shrink_list(l, nr_to_scan, zone,
> >> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A sc, prio);
> >> > --- linux.orig/mm/page_alloc.c A 2009-08-20 11:57:54.000000000 +0800
> >> > +++ linux/mm/page_alloc.c A  A  A  2009-08-20 11:58:39.000000000 +0800
> >> > @@ -3716,7 +3716,7 @@ static void __paginginit free_area_init_
> >> > A  A  A  A  A  A  A  A zone_pcp_init(zone);
> >> > A  A  A  A  A  A  A  A for_each_lru(l) {
> >> > A  A  A  A  A  A  A  A  A  A  A  A INIT_LIST_HEAD(&zone->lru[l].list);
> >> > - A  A  A  A  A  A  A  A  A  A  A  zone->lru[l].nr_saved_scan = 0;
> >> > + A  A  A  A  A  A  A  A  A  A  A  zone->reclaim_stat.nr_saved_scan[l] = 0;
> >> > A  A  A  A  A  A  A  A }
> >> > A  A  A  A  A  A  A  A zone->reclaim_stat.recent_rotated[0] = 0;
> >> > A  A  A  A  A  A  A  A zone->reclaim_stat.recent_rotated[1] = 0;
> >> >
> >> > --
> >> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >> > the body to majordomo@kvack.org. A For more info on Linux MM,
> >> > see: http://www.linux-mm.org/ .
> >> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >> >
> >>
> >>
> >>
> >> --
> >> Kind regards,
> >> Minchan Kim
> >
> 
> 
> 
> -- 
> Kind regards,
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
