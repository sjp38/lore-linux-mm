Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A4B22900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 04:21:18 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 1156B3EE0BB
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 17:21:14 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E548B45DE94
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 17:21:13 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C848F45DE77
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 17:21:13 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BCABDE08005
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 17:21:13 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BC75E08001
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 17:21:13 +0900 (JST)
Date: Fri, 15 Apr 2011 17:14:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V4 06/10] Per-memcg background reclaim.
Message-Id: <20110415171437.098392da.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTin0r26b2JgRJkXwLxP4m5HGAaxH=A@mail.gmail.com>
References: <1302821669-29862-1-git-send-email-yinghan@google.com>
	<1302821669-29862-7-git-send-email-yinghan@google.com>
	<20110415101148.80cb6721.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTin0r26b2JgRJkXwLxP4m5HGAaxH=A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Thu, 14 Apr 2011 23:08:40 -0700
Ying Han <yinghan@google.com> wrote:

> On Thu, Apr 14, 2011 at 6:11 PM, KAMEZAWA Hiroyuki <
> kamezawa.hiroyu@jp.fujitsu.com> wrote:

> >
> > As you know, memcg works against user's memory, memory should be in highmem
> > zone.
> > Memcg-kswapd is not for memory-shortage, but for voluntary page dropping by
> > _user_.
> >
> 
> in some sense, yes. but it would also related to memory-shortage on fully
> packed machines.
> 

No. _at this point_, this is just for freeing volutary before hitting limit
to gain performance. Anyway, this understainding is not affecting the patch
itself.

> >
> > If this memcg-kswapd drops pages from lower zones first, ah, ok, it's good
> > for
> > the system because memcg's pages should be on higher zone if we have free
> > memory.
> >
> > So, I think the reason for dma->highmem is different from global kswapd.
> >
> 
> yes. I agree that the logic of dma->highmem ordering is not exactly the same
> from per-memcg kswapd and per-node kswapd. But still the page allocation
> happens on the other side, and this is still good for the system as you
> pointed out.
> 
> >
> >
> >
> >
> > > +     for (i = 0; i < pgdat->nr_zones; i++) {
> > > +             struct zone *zone = pgdat->node_zones + i;
> > > +
> > > +             if (!populated_zone(zone))
> > > +                     continue;
> > > +
> > > +             sc->nr_scanned = 0;
> > > +             shrink_zone(priority, zone, sc);
> > > +             total_scanned += sc->nr_scanned;
> > > +
> > > +             /*
> > > +              * If we've done a decent amount of scanning and
> > > +              * the reclaim ratio is low, start doing writepage
> > > +              * even in laptop mode
> > > +              */
> > > +             if (total_scanned > SWAP_CLUSTER_MAX * 2 &&
> > > +                 total_scanned > sc->nr_reclaimed + sc->nr_reclaimed /
> > 2) {
> > > +                     sc->may_writepage = 1;
> > > +             }
> > > +     }
> > > +
> > > +     sc->nr_scanned = total_scanned;
> > > +     return;
> > > +}
> > > +
> > > +/*
> > > + * Per cgroup background reclaim.
> > > + * TODO: Take off the order since memcg always do order 0
> > > + */
> > > +static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup
> > *mem_cont,
> > > +                                           int order)
> > > +{
> > > +     int i, nid;
> > > +     int start_node;
> > > +     int priority;
> > > +     bool wmark_ok;
> > > +     int loop;
> > > +     pg_data_t *pgdat;
> > > +     nodemask_t do_nodes;
> > > +     unsigned long total_scanned;
> > > +     struct scan_control sc = {
> > > +             .gfp_mask = GFP_KERNEL,
> > > +             .may_unmap = 1,
> > > +             .may_swap = 1,
> > > +             .nr_to_reclaim = ULONG_MAX,
> > > +             .swappiness = vm_swappiness,
> > > +             .order = order,
> > > +             .mem_cgroup = mem_cont,
> > > +     };
> > > +
> > > +loop_again:
> > > +     do_nodes = NODE_MASK_NONE;
> > > +     sc.may_writepage = !laptop_mode;
> >
> > I think may_writepage should start from '0' always. We're not sure
> > the system is in memory shortage...we just want to release memory
> > volunatary. write_page will add huge costs, I guess.
> >
> > For exmaple,
> >        sc.may_writepage = !!loop
> > may be better for memcg.
> >
> > BTW, you set nr_to_reclaim as ULONG_MAX here and doesn't modify it later.
> >
> > I think you should add some logic to fix it to right value.
> >
> > For example, before calling shrink_zone(),
> >
> > sc->nr_to_reclaim = min(SWAP_CLUSETR_MAX, memcg_usage_in_this_zone() /
> > 100);  # 1% in this zone.
> >
> > if we love 'fair pressure for each zone'.
> >
> 
> Hmm. I don't get it. Leaving the nr_to_reclaim to be ULONG_MAX in kswapd
> case which is intended to add equal memory pressure for each zone. 

And it need to reclaim memory from the zone.
memcg can visit other zone/node because it's not work for zone/pgdat.

> So in the shrink_zone, we won't bail out in the following condition:
> 
> 
> >-------while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
> > >------->------->------->------->-------nr[LRU_INACTIVE_FILE]) {
> >
> 
>  >------->-------if (nr_reclaimed >= nr_to_reclaim && priority <
> DEF_PRIORITY)
> >------->------->-------break;
> 
> }

Yes. So, by setting nr_to_reclaim to be proper value for a zone,
we can visit next zone/node sooner. memcg's kswapd is not requrested to
free memory from a node/zone. (But we'll need a hint for bias, later.)

By making nr_reclaimed to be ULONG_MAX, to quit this loop, we need to
loop until all nr[lru] to be 0. When memcg kswapd finds that memcg's usage
is difficult to be reduced under high_wmark, priority goes up dramatically
and we'll see long loop in this zone if zone is busy.

For memcg kswapd, it can visit next zone rather than loop more. Then,
we'll be able to reduce cpu usage and contention by memcg_kswapd.

I think this do-more/skip-and-next logic will be a difficult issue
and need to be maintained with long time research. For now, I bet
ULONG_MAX is not a choice. As usual try_to_free_page() does,
SWAP_CLUSTER_MAX will be enough. As it is, we can visit next node.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
