Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 46C0A8D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 23:25:58 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p3K3Pq6k029654
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 20:25:54 -0700
Received: from qyk7 (qyk7.prod.google.com [10.241.83.135])
	by wpaz33.hot.corp.google.com with ESMTP id p3K3PLFW020434
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 20:25:51 -0700
Received: by qyk7 with SMTP id 7so200575qyk.3
        for <linux-mm@kvack.org>; Tue, 19 Apr 2011 20:25:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110420100317.e7d43bab.kamezawa.hiroyu@jp.fujitsu.com>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
	<1303185466-2532-7-git-send-email-yinghan@google.com>
	<20110420100317.e7d43bab.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 19 Apr 2011 20:25:50 -0700
Message-ID: <BANLkTi=H6Ms2evXq9FYhqY1oVnQ+Z=s5Wg@mail.gmail.com>
Subject: Re: [PATCH V6 06/10] Per-memcg background reclaim.
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=00248c6a84ca752f0504a1512e7e
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--00248c6a84ca752f0504a1512e7e
Content-Type: text/plain; charset=ISO-8859-1

On Tue, Apr 19, 2011 at 6:03 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Mon, 18 Apr 2011 20:57:42 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > This is the main loop of per-memcg background reclaim which is
> implemented in
> > function balance_mem_cgroup_pgdat().
> >
> > The function performs a priority loop similar to global reclaim. During
> each
> > iteration it invokes balance_pgdat_node() for all nodes on the system,
> which
> > is another new function performs background reclaim per node. After
> reclaiming
> > each node, it checks mem_cgroup_watermark_ok() and breaks the priority
> loop if
> > it returns true.
> >
>
> Seems getting better. But some comments, below.
>

thank you for reviewing.

>
>
> > changelog v6..v5:
> > 1. add mem_cgroup_zone_reclaimable_pages()
> > 2. fix some comment style.
> >
> > changelog v5..v4:
> > 1. remove duplicate check on nodes_empty()
> > 2. add logic to check if the per-memcg lru is empty on the zone.
> >
> > changelog v4..v3:
> > 1. split the select_victim_node and zone_unreclaimable to a seperate
> patches
> > 2. remove the logic tries to do zone balancing.
> >
> > changelog v3..v2:
> > 1. change mz->all_unreclaimable to be boolean.
> > 2. define ZONE_RECLAIMABLE_RATE macro shared by zone and per-memcg
> reclaim.
> > 3. some more clean-up.
> >
> > changelog v2..v1:
> > 1. move the per-memcg per-zone clear_unreclaimable into uncharge stage.
> > 2. shared the kswapd_run/kswapd_stop for per-memcg and global background
> > reclaim.
> > 3. name the per-memcg memcg as "memcg-id" (css->id). And the global
> kswapd
> > keeps the same name.
> > 4. fix a race on kswapd_stop while the per-memcg-per-zone info could be
> accessed
> > after freeing.
> > 5. add the fairness in zonelist where memcg remember the last zone
> reclaimed
> > from.
> >
> > Signed-off-by: Ying Han <yinghan@google.com>
> > ---
> >  include/linux/memcontrol.h |    9 +++
> >  mm/memcontrol.c            |   18 +++++
> >  mm/vmscan.c                |  151
> ++++++++++++++++++++++++++++++++++++++++++++
> >  3 files changed, 178 insertions(+), 0 deletions(-)
> >
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index d4ff7f2..a4747b0 100644
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -115,6 +115,8 @@ extern void mem_cgroup_end_migration(struct
> mem_cgroup *mem,
> >   */
> >  int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
> >  int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
> > +unsigned long mem_cgroup_zone_reclaimable_pages(struct mem_cgroup
> *memcg,
> > +                                               struct zone *zone);
> >  unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
> >                                      struct zone *zone,
> >                                      enum lru_list lru);
> > @@ -311,6 +313,13 @@ mem_cgroup_inactive_file_is_low(struct mem_cgroup
> *memcg)
> >  }
> >
> >  static inline unsigned long
> > +mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg,
> > +                                 struct zone *zone)
> > +{
> > +     return 0;
> > +}
> > +
> > +static inline unsigned long
> >  mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg, struct zone *zone,
> >                        enum lru_list lru)
> >  {
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 06fddd2..7490147 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1097,6 +1097,24 @@ int mem_cgroup_inactive_file_is_low(struct
> mem_cgroup *memcg)
> >       return (active > inactive);
> >  }
> >
> > +unsigned long mem_cgroup_zone_reclaimable_pages(struct mem_cgroup
> *memcg,
> > +                                             struct zone *zone)
> > +{
> > +     int nr;
> > +     int nid = zone_to_nid(zone);
> > +     int zid = zone_idx(zone);
> > +     struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(memcg, nid,
> zid);
> > +
> > +     nr = MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_FILE) +
> > +          MEM_CGROUP_ZSTAT(mz, NR_INACTIVE_FILE);
> > +
> > +     if (nr_swap_pages > 0)
> > +             nr += MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_ANON) +
> > +                   MEM_CGROUP_ZSTAT(mz, NR_INACTIVE_ANON);
> > +
> > +     return nr;
> > +}
> > +
> >  unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
> >                                      struct zone *zone,
> >                                      enum lru_list lru)
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 0060d1e..2a5c734 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -47,6 +47,8 @@
> >
> >  #include <linux/swapops.h>
> >
> > +#include <linux/res_counter.h>
> > +
> >  #include "internal.h"
> >
> >  #define CREATE_TRACE_POINTS
> > @@ -111,6 +113,8 @@ struct scan_control {
> >        * are scanned.
> >        */
> >       nodemask_t      *nodemask;
> > +
> > +     int priority;
> >  };
> >
> >  #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
> > @@ -2625,11 +2629,158 @@ out:
> >       finish_wait(wait_h, &wait);
> >  }
> >
> > +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> > +/*
> > + * The function is used for per-memcg LRU. It scanns all the zones of
> the
> > + * node and returns the nr_scanned and nr_reclaimed.
> > + */
> > +static void balance_pgdat_node(pg_data_t *pgdat, int order,
> > +                                     struct scan_control *sc)
> > +{
>
>
> shrink_memcg_node() instead of balance_pgdat_node() ?
>
> I guess the name is misleading.
>

ok. will make the change

>
> > +     int i;
> > +     unsigned long total_scanned = 0;
> > +     struct mem_cgroup *mem_cont = sc->mem_cgroup;
> > +     int priority = sc->priority;
> > +
> > +     /*
> > +      * This dma->highmem order is consistant with global reclaim.
> > +      * We do this because the page allocator works in the opposite
> > +      * direction although memcg user pages are mostly allocated at
> > +      * highmem.
> > +      */
> > +     for (i = 0; i < pgdat->nr_zones; i++) {
> > +             struct zone *zone = pgdat->node_zones + i;
> > +             unsigned long scan = 0;
> > +
> > +             scan = mem_cgroup_zone_reclaimable_pages(mem_cont, zone);
> > +             if (!scan)
> > +                     continue;
> > +
> > +             sc->nr_scanned = 0;
> > +             shrink_zone(priority, zone, sc);
> > +             total_scanned += sc->nr_scanned;
> > +
> > +             /*
> > +              * If we've done a decent amount of scanning and
> > +              * the reclaim ratio is low, start doing writepage
> > +              * even in laptop mode
> > +              */
> > +             if (total_scanned > SWAP_CLUSTER_MAX * 2 &&
> > +                 total_scanned > sc->nr_reclaimed + sc->nr_reclaimed /
> 2) {
> > +                     sc->may_writepage = 1;
> > +             }
> > +     }
> > +
> > +     sc->nr_scanned = total_scanned;
> > +}
> > +
> > +/*
> > + * Per cgroup background reclaim.
> > + * TODO: Take off the order since memcg always do order 0
> > + */
> > +static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup
> *mem_cont,
> > +                                           int order)
>
> Here, too. shrink_mem_cgroup() may be straightforward.
>

will make the change.

>
>
> > +{
> > +     int i, nid;
> > +     int start_node;
> > +     int priority;
> > +     bool wmark_ok;
> > +     int loop;
> > +     pg_data_t *pgdat;
> > +     nodemask_t do_nodes;
> > +     unsigned long total_scanned;
> > +     struct scan_control sc = {
> > +             .gfp_mask = GFP_KERNEL,
> > +             .may_unmap = 1,
> > +             .may_swap = 1,
> > +             .nr_to_reclaim = SWAP_CLUSTER_MAX,
> > +             .swappiness = vm_swappiness,
> > +             .order = order,
> > +             .mem_cgroup = mem_cont,
> > +     };
> > +
> > +loop_again:
> > +     do_nodes = NODE_MASK_NONE;
> > +     sc.may_writepage = !laptop_mode;
>
> Even with !laptop_mode, "write_page since the 1st scan" should be avoided.
> How about sc.may_writepage = 1 when we do "goto loop_again;" ?
>
> sounds a safe change to make. will add it.
>


> > +     sc.nr_reclaimed = 0;
> > +     total_scanned = 0;
> > +
> > +     for (priority = DEF_PRIORITY; priority >= 0; priority--) {
> > +             sc.priority = priority;
> > +             wmark_ok = false;
> > +             loop = 0;
> > +
> > +             /* The swap token gets in the way of swapout... */
> > +             if (!priority)
> > +                     disable_swap_token();
> > +
> > +             if (priority == DEF_PRIORITY)
> > +                     do_nodes = node_states[N_ONLINE];
>
> This can be moved out from the loop.
>
> ok. changed.

> > +
> > +             while (1) {
> > +                     nid = mem_cgroup_select_victim_node(mem_cont,
> > +                                                     &do_nodes);
> > +
> > +                     /*
> > +                      * Indicate we have cycled the nodelist once
> > +                      * TODO: we might add MAX_RECLAIM_LOOP for
> preventing
> > +                      * kswapd burning cpu cycles.
> > +                      */
> > +                     if (loop == 0) {
> > +                             start_node = nid;
> > +                             loop++;
> > +                     } else if (nid == start_node)
> > +                             break;
> > +
>
> Hmm...let me try a different style.
> ==
>        start_node = mem_cgroup_select_victim_node(mem_cont, &do_nodes);
>        for (nid = start_node;
>             nid != start_node && !node_empty(do_nodes);
>             nid = mem_cgroup_select_victim_node(mem_cont, &do_nodes)) {
>
>                shrink_memcg_node(NODE_DATA(nid), order, &sc);
>                 total_scanned += sc.nr_scanned;
>                 for (i = 0; i < NODE_DATA(nid)->nr_zones; i++) {
>                        if (populated_zone(NODE_DATA(nid)->node_zones + i))
>                                break;
>                }
>                if (i == NODE_DATA(nid)->nr_zones)
>                         node_clear(nid, do_nodes);
>                if (mem_cgroup_watermark_ok(mem_cont, CHARGE_WMARK_HIGH))
>                         break;
>        }
> ==
>
> In short, I like for() loop rather than while(1) because next calculation
> and
> end condition are clear.
>

Ok. I should be able to make that change.

>
>
>
> > +                     pgdat = NODE_DATA(nid);
> > +                     balance_pgdat_node(pgdat, order, &sc);
> > +                     total_scanned += sc.nr_scanned;
> > +
> > +                     for (i = pgdat->nr_zones - 1; i >= 0; i--) {
> > +                             struct zone *zone = pgdat->node_zones + i;
> > +
> > +                             if (!populated_zone(zone))
> > +                                     continue;
> > +                     }
> > +                     if (i < 0)
> > +                             node_clear(nid, do_nodes);
> Isn't this wrong ? I guess
>                if (populated_zone(zone))
>                        break;
> is what you want to do.
>
> hmm. you are right.

--Ying

--Ying

> Thanks,
> -Kame
> > +
> > +                     if (mem_cgroup_watermark_ok(mem_cont,
> > +                                                     CHARGE_WMARK_HIGH))
> {
> > +                             wmark_ok = true;
> > +                             goto out;
> > +                     }
> > +
> > +                     if (nodes_empty(do_nodes)) {
> > +                             wmark_ok = true;
> > +                             goto out;
> > +                     }
> > +             }
> > +
> > +             if (total_scanned && priority < DEF_PRIORITY - 2)
> > +                     congestion_wait(WRITE, HZ/10);
> > +
> > +             if (sc.nr_reclaimed >= SWAP_CLUSTER_MAX)
> > +                     break;
> > +     }
> > +out:
> > +     if (!wmark_ok) {
> > +             cond_resched();
> > +
> > +             try_to_freeze();
> > +
> > +             goto loop_again;
> > +     }
> > +
> > +     return sc.nr_reclaimed;
> > +}
> > +#else
> >  static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup
> *mem_cont,
> >                                                       int order)
> >  {
> >       return 0;
> >  }
> > +#endif
> >
> >  /*
> >   * The background pageout daemon, started as a kernel thread
> > --
> > 1.7.3.1
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Fight unfair telecom internet charges in Canada: sign
> http://stopthemeter.ca/
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >
>
>

--00248c6a84ca752f0504a1512e7e
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Tue, Apr 19, 2011 at 6:03 PM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
<div class=3D"im">On Mon, 18 Apr 2011 20:57:42 -0700<br>
Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google.com</a>&g=
t; wrote:<br>
<br>
&gt; This is the main loop of per-memcg background reclaim which is impleme=
nted in<br>
&gt; function balance_mem_cgroup_pgdat().<br>
&gt;<br>
&gt; The function performs a priority loop similar to global reclaim. Durin=
g each<br>
&gt; iteration it invokes balance_pgdat_node() for all nodes on the system,=
 which<br>
&gt; is another new function performs background reclaim per node. After re=
claiming<br>
&gt; each node, it checks mem_cgroup_watermark_ok() and breaks the priority=
 loop if<br>
&gt; it returns true.<br>
&gt;<br>
<br>
</div>Seems getting better. But some comments, below.<br></blockquote><div>=
<br></div><div>thank you for reviewing.=A0</div><blockquote class=3D"gmail_=
quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1=
ex;">

<div><div></div><div class=3D"h5"><br>
<br>
&gt; changelog v6..v5:<br>
&gt; 1. add mem_cgroup_zone_reclaimable_pages()<br>
&gt; 2. fix some comment style.<br>
&gt;<br>
&gt; changelog v5..v4:<br>
&gt; 1. remove duplicate check on nodes_empty()<br>
&gt; 2. add logic to check if the per-memcg lru is empty on the zone.<br>
&gt;<br>
&gt; changelog v4..v3:<br>
&gt; 1. split the select_victim_node and zone_unreclaimable to a seperate p=
atches<br>
&gt; 2. remove the logic tries to do zone balancing.<br>
&gt;<br>
&gt; changelog v3..v2:<br>
&gt; 1. change mz-&gt;all_unreclaimable to be boolean.<br>
&gt; 2. define ZONE_RECLAIMABLE_RATE macro shared by zone and per-memcg rec=
laim.<br>
&gt; 3. some more clean-up.<br>
&gt;<br>
&gt; changelog v2..v1:<br>
&gt; 1. move the per-memcg per-zone clear_unreclaimable into uncharge stage=
.<br>
&gt; 2. shared the kswapd_run/kswapd_stop for per-memcg and global backgrou=
nd<br>
&gt; reclaim.<br>
&gt; 3. name the per-memcg memcg as &quot;memcg-id&quot; (css-&gt;id). And =
the global kswapd<br>
&gt; keeps the same name.<br>
&gt; 4. fix a race on kswapd_stop while the per-memcg-per-zone info could b=
e accessed<br>
&gt; after freeing.<br>
&gt; 5. add the fairness in zonelist where memcg remember the last zone rec=
laimed<br>
&gt; from.<br>
&gt;<br>
&gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com">ying=
han@google.com</a>&gt;<br>
&gt; ---<br>
&gt; =A0include/linux/memcontrol.h | =A0 =A09 +++<br>
&gt; =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 18 +++++<br>
&gt; =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0151 +++++++++++++++=
+++++++++++++++++++++++++++++<br>
&gt; =A03 files changed, 178 insertions(+), 0 deletions(-)<br>
&gt;<br>
&gt; diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h<b=
r>
&gt; index d4ff7f2..a4747b0 100644<br>
&gt; --- a/include/linux/memcontrol.h<br>
&gt; +++ b/include/linux/memcontrol.h<br>
&gt; @@ -115,6 +115,8 @@ extern void mem_cgroup_end_migration(struct mem_cg=
roup *mem,<br>
&gt; =A0 */<br>
&gt; =A0int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);<br>
&gt; =A0int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);<br>
&gt; +unsigned long mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *me=
mcg,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone);<br>
&gt; =A0unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,<br=
>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0struct zone *zone,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0enum lru_list lru);<br>
&gt; @@ -311,6 +313,13 @@ mem_cgroup_inactive_file_is_low(struct mem_cgroup=
 *memcg)<br>
&gt; =A0}<br>
&gt;<br>
&gt; =A0static inline unsigned long<br>
&gt; +mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 stru=
ct zone *zone)<br>
&gt; +{<br>
&gt; + =A0 =A0 return 0;<br>
&gt; +}<br>
&gt; +<br>
&gt; +static inline unsigned long<br>
&gt; =A0mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg, struct zone *zon=
e,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum lru_list lru)<br>
&gt; =A0{<br>
&gt; diff --git a/mm/memcontrol.c b/mm/memcontrol.c<br>
&gt; index 06fddd2..7490147 100644<br>
&gt; --- a/mm/memcontrol.c<br>
&gt; +++ b/mm/memcontrol.c<br>
&gt; @@ -1097,6 +1097,24 @@ int mem_cgroup_inactive_file_is_low(struct mem_=
cgroup *memcg)<br>
&gt; =A0 =A0 =A0 return (active &gt; inactive);<br>
&gt; =A0}<br>
&gt;<br>
&gt; +unsigned long mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *me=
mcg,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 struct zone *zone)<br>
&gt; +{<br>
&gt; + =A0 =A0 int nr;<br>
&gt; + =A0 =A0 int nid =3D zone_to_nid(zone);<br>
&gt; + =A0 =A0 int zid =3D zone_idx(zone);<br>
&gt; + =A0 =A0 struct mem_cgroup_per_zone *mz =3D mem_cgroup_zoneinfo(memcg=
, nid, zid);<br>
&gt; +<br>
&gt; + =A0 =A0 nr =3D MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_FILE) +<br>
&gt; + =A0 =A0 =A0 =A0 =A0MEM_CGROUP_ZSTAT(mz, NR_INACTIVE_FILE);<br>
&gt; +<br>
&gt; + =A0 =A0 if (nr_swap_pages &gt; 0)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 nr +=3D MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_ANON)=
 +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MEM_CGROUP_ZSTAT(mz, NR_INACTIVE=
_ANON);<br>
&gt; +<br>
&gt; + =A0 =A0 return nr;<br>
&gt; +}<br>
&gt; +<br>
&gt; =A0unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,<br=
>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0struct zone *zone,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0enum lru_list lru)<br>
&gt; diff --git a/mm/vmscan.c b/mm/vmscan.c<br>
&gt; index 0060d1e..2a5c734 100644<br>
&gt; --- a/mm/vmscan.c<br>
&gt; +++ b/mm/vmscan.c<br>
&gt; @@ -47,6 +47,8 @@<br>
&gt;<br>
&gt; =A0#include &lt;linux/swapops.h&gt;<br>
&gt;<br>
&gt; +#include &lt;linux/res_counter.h&gt;<br>
&gt; +<br>
&gt; =A0#include &quot;internal.h&quot;<br>
&gt;<br>
&gt; =A0#define CREATE_TRACE_POINTS<br>
&gt; @@ -111,6 +113,8 @@ struct scan_control {<br>
&gt; =A0 =A0 =A0 =A0* are scanned.<br>
&gt; =A0 =A0 =A0 =A0*/<br>
&gt; =A0 =A0 =A0 nodemask_t =A0 =A0 =A0*nodemask;<br>
&gt; +<br>
&gt; + =A0 =A0 int priority;<br>
&gt; =A0};<br>
&gt;<br>
&gt; =A0#define lru_to_page(_head) (list_entry((_head)-&gt;prev, struct pag=
e, lru))<br>
&gt; @@ -2625,11 +2629,158 @@ out:<br>
&gt; =A0 =A0 =A0 finish_wait(wait_h, &amp;wait);<br>
&gt; =A0}<br>
&gt;<br>
&gt; +#ifdef CONFIG_CGROUP_MEM_RES_CTLR<br>
&gt; +/*<br>
&gt; + * The function is used for per-memcg LRU. It scanns all the zones of=
 the<br>
&gt; + * node and returns the nr_scanned and nr_reclaimed.<br>
&gt; + */<br>
&gt; +static void balance_pgdat_node(pg_data_t *pgdat, int order,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct scan_control *sc)<br>
&gt; +{<br>
<br>
<br>
</div></div>shrink_memcg_node() instead of balance_pgdat_node() ?<br>
<br>
I guess the name is misleading.<br></blockquote><div><br></div><div>ok. wil=
l make the change=A0</div><blockquote class=3D"gmail_quote" style=3D"margin=
:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div><div></div><div class=3D"h5"><br>
&gt; + =A0 =A0 int i;<br>
&gt; + =A0 =A0 unsigned long total_scanned =3D 0;<br>
&gt; + =A0 =A0 struct mem_cgroup *mem_cont =3D sc-&gt;mem_cgroup;<br>
&gt; + =A0 =A0 int priority =3D sc-&gt;priority;<br>
&gt; +<br>
&gt; + =A0 =A0 /*<br>
&gt; + =A0 =A0 =A0* This dma-&gt;highmem order is consistant with global re=
claim.<br>
&gt; + =A0 =A0 =A0* We do this because the page allocator works in the oppo=
site<br>
&gt; + =A0 =A0 =A0* direction although memcg user pages are mostly allocate=
d at<br>
&gt; + =A0 =A0 =A0* highmem.<br>
&gt; + =A0 =A0 =A0*/<br>
&gt; + =A0 =A0 for (i =3D 0; i &lt; pgdat-&gt;nr_zones; i++) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone =3D pgdat-&gt;node_zones +=
 i;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 unsigned long scan =3D 0;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 scan =3D mem_cgroup_zone_reclaimable_pages(m=
em_cont, zone);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (!scan)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;nr_scanned =3D 0;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 shrink_zone(priority, zone, sc);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 total_scanned +=3D sc-&gt;nr_scanned;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0* If we&#39;ve done a decent amount of sc=
anning and<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0* the reclaim ratio is low, start doing w=
ritepage<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0* even in laptop mode<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (total_scanned &gt; SWAP_CLUSTER_MAX * 2 =
&amp;&amp;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned &gt; sc-&gt;nr_reclaim=
ed + sc-&gt;nr_reclaimed / 2) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;may_writepage =3D 1;<=
br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; + =A0 =A0 }<br>
&gt; +<br>
&gt; + =A0 =A0 sc-&gt;nr_scanned =3D total_scanned;<br>
&gt; +}<br>
&gt; +<br>
&gt; +/*<br>
&gt; + * Per cgroup background reclaim.<br>
&gt; + * TODO: Take off the order since memcg always do order 0<br>
&gt; + */<br>
&gt; +static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup *mem_=
cont,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 int order)<br>
<br>
</div></div>Here, too. shrink_mem_cgroup() may be straightforward.<br></blo=
ckquote><div><br></div><div>will make the change.=A0</div><blockquote class=
=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padd=
ing-left:1ex;">

<div class=3D"im"><br>
<br>
&gt; +{<br>
&gt; + =A0 =A0 int i, nid;<br>
&gt; + =A0 =A0 int start_node;<br>
&gt; + =A0 =A0 int priority;<br>
&gt; + =A0 =A0 bool wmark_ok;<br>
&gt; + =A0 =A0 int loop;<br>
&gt; + =A0 =A0 pg_data_t *pgdat;<br>
&gt; + =A0 =A0 nodemask_t do_nodes;<br>
&gt; + =A0 =A0 unsigned long total_scanned;<br>
&gt; + =A0 =A0 struct scan_control sc =3D {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .gfp_mask =3D GFP_KERNEL,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .may_unmap =3D 1,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .may_swap =3D 1,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .nr_to_reclaim =3D SWAP_CLUSTER_MAX,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .swappiness =3D vm_swappiness,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .order =3D order,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .mem_cgroup =3D mem_cont,<br>
&gt; + =A0 =A0 };<br>
&gt; +<br>
&gt; +loop_again:<br>
&gt; + =A0 =A0 do_nodes =3D NODE_MASK_NONE;<br>
&gt; + =A0 =A0 sc.may_writepage =3D !laptop_mode;<br>
<br>
</div>Even with !laptop_mode, &quot;write_page since the 1st scan&quot; sho=
uld be avoided.<br>
How about sc.may_writepage =3D 1 when we do &quot;goto loop_again;&quot; ?<=
br>
<div class=3D"im"><br>
sounds a safe change to make. will add it.<br></div></blockquote><div>=A0</=
div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-lef=
t:1px #ccc solid;padding-left:1ex;"><div class=3D"im">
&gt; + =A0 =A0 sc.nr_reclaimed =3D 0;<br>
&gt; + =A0 =A0 total_scanned =3D 0;<br>
&gt; +<br>
&gt; + =A0 =A0 for (priority =3D DEF_PRIORITY; priority &gt;=3D 0; priority=
--) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 sc.priority =3D priority;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 wmark_ok =3D false;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 loop =3D 0;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 /* The swap token gets in the way of swapout=
... */<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (!priority)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 disable_swap_token();<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (priority =3D=3D DEF_PRIORITY)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_nodes =3D node_states[N_O=
NLINE];<br>
<br>
</div>This can be moved out from the loop.<br>
<div class=3D"im"><br></div></blockquote><div>ok. changed.=A0</div><blockqu=
ote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc s=
olid;padding-left:1ex;"><div class=3D"im">
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 while (1) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nid =3D mem_cgroup_select_vi=
ctim_node(mem_cont,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &amp;do_nodes);<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Indicate we have cycled=
 the nodelist once<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* TODO: we might add MAX_=
RECLAIM_LOOP for preventing<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* kswapd burning cpu cycl=
es.<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (loop =3D=3D 0) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 start_node =
=3D nid;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 loop++;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else if (nid =3D=3D start_=
node)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
&gt; +<br>
<br>
</div>Hmm...let me try a different style.<br>
=3D=3D<br>
 =A0 =A0 =A0 =A0start_node =3D mem_cgroup_select_victim_node(mem_cont, &amp=
;do_nodes);<br>
 =A0 =A0 =A0 =A0for (nid =3D start_node;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 nid !=3D start_node &amp;&amp; !node_empty(do_node=
s);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 nid =3D mem_cgroup_select_victim_node(mem_cont, &a=
mp;do_nodes)) {<br>
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0shrink_memcg_node(NODE_DATA(nid), order, &a=
mp;sc);<br>
<div class=3D"im"> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0total_scanned +=3D sc.nr_=
scanned;<br>
</div> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for (i =3D 0; i &lt; NODE_DATA(nid)-&=
gt;nr_zones; i++) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (populated_zone(NODE_DAT=
A(nid)-&gt;node_zones + i))<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (i =3D=3D NODE_DATA(nid)-&gt;nr_zones)<b=
r>
<div class=3D"im"> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0node_clea=
r(nid, do_nodes);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (mem_cgroup_watermark_ok(mem_cont, CHARG=
E_WMARK_HIGH))<br>
</div> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;<br>
 =A0 =A0 =A0 =A0}<br>
=3D=3D<br>
<br>
In short, I like for() loop rather than while(1) because next calculation a=
nd<br>
end condition are clear.<br></blockquote><div><br></div><div>Ok. I should b=
e able to make that change.=A0</div><blockquote class=3D"gmail_quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im"><br>
<br>
<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat =3D NODE_DATA(nid);<br=
>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 balance_pgdat_node(pgdat, or=
der, &amp;sc);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned +=3D sc.nr_sca=
nned;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D pgdat-&gt;nr_zone=
s - 1; i &gt;=3D 0; i--) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zone =
*zone =3D pgdat-&gt;node_zones + i;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!populat=
ed_zone(zone))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 continue;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (i &lt; 0)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 node_clear(n=
id, do_nodes);<br>
</div>Isn&#39;t this wrong ? I guess<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (populated_zone(zone))<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;<br>
is what you want to do.<br>
<br></blockquote><div>hmm. you are right.=A0</div><div><br></div><div>--Yin=
g</div><div><br></div><div>--Ying=A0</div><blockquote class=3D"gmail_quote"=
 style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
Thanks,<br>
-Kame<br>
<div class=3D"im">&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_watermark_ok(=
mem_cont,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 CHARGE_WMARK_HIGH)) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wmark_ok =3D=
 true;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;<br=
>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nodes_empty(do_nodes)) {=
<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wmark_ok =3D=
 true;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;<br=
>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (total_scanned &amp;&amp; priority &lt; D=
EF_PRIORITY - 2)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 congestion_wait(WRITE, HZ/10=
);<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (sc.nr_reclaimed &gt;=3D SWAP_CLUSTER_MAX=
)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
&gt; + =A0 =A0 }<br>
&gt; +out:<br>
&gt; + =A0 =A0 if (!wmark_ok) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 cond_resched();<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 try_to_freeze();<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 goto loop_again;<br>
&gt; + =A0 =A0 }<br>
&gt; +<br>
&gt; + =A0 =A0 return sc.nr_reclaimed;<br>
&gt; +}<br>
&gt; +#else<br>
&gt; =A0static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup *me=
m_cont,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int order)<br>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 return 0;<br>
&gt; =A0}<br>
&gt; +#endif<br>
&gt;<br>
&gt; =A0/*<br>
&gt; =A0 * The background pageout daemon, started as a kernel thread<br>
&gt; --<br>
&gt; 1.7.3.1<br>
&gt;<br>
</div>&gt; --<br>
&gt; To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<=
br>
&gt; the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org=
</a>. =A0For more info on Linux MM,<br>
&gt; see: <a href=3D"http://www.linux-mm.org/" target=3D"_blank">http://www=
.linux-mm.org/</a> .<br>
&gt; Fight unfair telecom internet charges in Canada: sign <a href=3D"http:=
//stopthemeter.ca/" target=3D"_blank">http://stopthemeter.ca/</a><br>
&gt; Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvac=
k.org">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">emai=
l@kvack.org</a> &lt;/a&gt;<br>
&gt;<br>
<br>
</blockquote></div><br>

--00248c6a84ca752f0504a1512e7e--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
