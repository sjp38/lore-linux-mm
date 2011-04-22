Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6B5798D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 03:54:33 -0400 (EDT)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id p3M7sR4c024389
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 00:54:28 -0700
Received: from qwf7 (qwf7.prod.google.com [10.241.194.71])
	by kpbe16.cbf.corp.google.com with ESMTP id p3M7sLuM004846
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 00:54:26 -0700
Received: by qwf7 with SMTP id 7so248786qwf.24
        for <linux-mm@kvack.org>; Fri, 22 Apr 2011 00:54:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110422150050.FA6E.A69D9226@jp.fujitsu.com>
References: <1303446260-21333-1-git-send-email-yinghan@google.com>
	<1303446260-21333-8-git-send-email-yinghan@google.com>
	<20110422150050.FA6E.A69D9226@jp.fujitsu.com>
Date: Fri, 22 Apr 2011 00:54:21 -0700
Message-ID: <BANLkTi=BewF6TtSAsqY+bYQB6UUR_yt9yQ@mail.gmail.com>
Subject: Re: [PATCH V7 7/9] Per-memcg background reclaim.
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0ce008bc67ffdb04a17d2aa8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--000e0ce008bc67ffdb04a17d2aa8
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Apr 21, 2011 at 11:00 PM, KOSAKI Motohiro <
kosaki.motohiro@jp.fujitsu.com> wrote:

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
> > changelog v7..v6:
> > 1. change based on KAMAZAWA's patchset. Each memcg reclaims now reclaims
> > SWAP_CLUSTER_MAX of pages and putback the memcg to the tail of list.
> > memcg-kswapd will visit memcgs in round-robin manner and reduce usages.
> >
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
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  include/linux/memcontrol.h |    9 +++
> >  mm/memcontrol.c            |   18 +++++++
> >  mm/vmscan.c                |  118
> ++++++++++++++++++++++++++++++++++++++++++++
> >  3 files changed, 145 insertions(+), 0 deletions(-)
> >
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index 7444738..39eade6 100644
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
> > index 4696fd8..41eaa62 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1105,6 +1105,24 @@ int mem_cgroup_inactive_file_is_low(struct
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
> > index 63c557e..ba03a10 100644
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
>
> Bah!
> If you need sc.priority, you have to make cleanup patch at first. and
> all current reclaim path have to use sc.priority. Please don't increase
> unnecessary mess.
>
> hmm. so then I would change it by passing the priority
> as separate parameter.
>


>
> >
> >  #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
> > @@ -2620,10 +2624,124 @@ static void kswapd_try_to_sleep(struct kswapd
> *kswapd_p, int order,
> >       finish_wait(wait_h, &wait);
> >  }
> >
> > +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> > +/*
> > + * The function is used for per-memcg LRU. It scanns all the zones of
> the
> > + * node and returns the nr_scanned and nr_reclaimed.
> > + */
> > +static void shrink_memcg_node(pg_data_t *pgdat, int order,
> > +                             struct scan_control *sc)
> > +{
> > +     int i;
> > +     unsigned long total_scanned = 0;
> > +     struct mem_cgroup *mem_cont = sc->mem_cgroup;
> > +     int priority = sc->priority;
>
> unnecessary local variables. we can keep smaller stack.
>
> ok.

>
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
>
> please make helper function for may_writepage. iow, don't cut-n-paste.
>
> hmm, can you help to clarify that?
>


> > +/*
> > + * Per cgroup background reclaim.
> > + * TODO: Take off the order since memcg always do order 0
> > + */
> > +static unsigned long shrink_mem_cgroup(struct mem_cgroup *mem_cont, int
> order)
> > +{
> > +     int i, nid, priority, loop;
> > +     pg_data_t *pgdat;
> > +     nodemask_t do_nodes;
> > +     unsigned long total_scanned;
> > +     struct scan_control sc = {
> > +             .gfp_mask = GFP_KERNEL,
> > +             .may_unmap = 1,
> > +             .may_swap = 1,
> > +             .nr_to_reclaim = SWAP_CLUSTER_MAX,
> > +             .swappiness = vm_swappiness,
>
> No. memcg has per-memcg swappiness. Please don't use global swappiness
> value.
>
> sounds reasonable, i will take a look at it.

>
> > +             .order = order,
> > +             .mem_cgroup = mem_cont,
> > +     };
> > +
> > +     do_nodes = NODE_MASK_NONE;
> > +     sc.may_writepage = !laptop_mode;
> > +     sc.nr_reclaimed = 0;
>
> this initialization move into sc static initializer. balance pgdat has
> loop_again label and this doesn't.
>

will change.


>
> > +     total_scanned = 0;
> > +
> > +     do_nodes = node_states[N_ONLINE];
>
> Why do we need care memoryless node? N_HIGH_MEMORY is wrong?
>
hmm, let me look into that.

>
> > +
> > +     for (priority = DEF_PRIORITY;
> > +             (priority >= 0) && (sc.nr_to_reclaim > sc.nr_reclaimed);
> > +             priority--) {
>
> bah. bad coding style...
>

ok. will change.

>
> > +
> > +             sc.priority = priority;
> > +             /* The swap token gets in the way of swapout... */
> > +             if (!priority)
> > +                     disable_swap_token();
>
> Why?
>
> disable swap token mean "Please devest swap preventation privilege from
> owner task. Instead we endure swap storm and performance hit".
> However I doublt memcg memory shortage is good situation to make swap
> storm.
>

I am not sure about that either way. we probably can leave as it is and make
corresponding change if real problem is observed?

>
>
> > +
> > +             for (loop = num_online_nodes();
> > +                     (loop > 0) && !nodes_empty(do_nodes);
> > +                     loop--) {
>
> Why don't you use for_each_online_node()?
> Maybe for_each_node_state(n, N_HIGH_MEMORY) is best option?
>
> At least, find_next_bit() is efficient than bare loop?
>



> > +
> > +                     nid = mem_cgroup_select_victim_node(mem_cont,
> > +                                                     &do_nodes);
> > +
> > +                     pgdat = NODE_DATA(nid);
> > +                     shrink_memcg_node(pgdat, order, &sc);
> > +                     total_scanned += sc.nr_scanned;
> > +
> > +                     for (i = pgdat->nr_zones - 1; i >= 0; i--) {
> > +                             struct zone *zone = pgdat->node_zones + i;
> > +
> > +                             if (populated_zone(zone))
> > +                                     break;
> > +                     }
>
> memory less node check is here. but we can check it before.
>

Not sure I understand this, can you help to clarify?

thank you for reviewing

--Ying

>
> > +                     if (i < 0)
> > +                             node_clear(nid, do_nodes);
> > +
> > +                     if (mem_cgroup_watermark_ok(mem_cont,
> > +                                             CHARGE_WMARK_HIGH))
> > +                             goto out;
> > +             }
> > +
> > +             if (total_scanned && priority < DEF_PRIORITY - 2)
> > +                     congestion_wait(WRITE, HZ/10);
> > +     }
> > +out:
> > +     return sc.nr_reclaimed;
> > +}
> > +#else
> >  static unsigned long shrink_mem_cgroup(struct mem_cgroup *mem_cont, int
> order)
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
>
>
>
>

--000e0ce008bc67ffdb04a17d2aa8
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, Apr 21, 2011 at 11:00 PM, KOSAKI=
 Motohiro <span dir=3D"ltr">&lt;<a href=3D"mailto:kosaki.motohiro@jp.fujits=
u.com">kosaki.motohiro@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote =
class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid=
;padding-left:1ex;">
<div><div></div><div class=3D"h5">&gt; This is the main loop of per-memcg b=
ackground reclaim which is implemented in<br>
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
&gt; changelog v7..v6:<br>
&gt; 1. change based on KAMAZAWA&#39;s patchset. Each memcg reclaims now re=
claims<br>
&gt; SWAP_CLUSTER_MAX of pages and putback the memcg to the tail of list.<b=
r>
&gt; memcg-kswapd will visit memcgs in round-robin manner and reduce usages=
.<br>
&gt;<br>
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
&gt; Signed-off-by: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu=
@jp.fujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<br>
&gt; ---<br>
&gt; =A0include/linux/memcontrol.h | =A0 =A09 +++<br>
&gt; =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 18 +++++++<br>
&gt; =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0118 +++++++++++++++=
+++++++++++++++++++++++++++++<br>
&gt; =A03 files changed, 145 insertions(+), 0 deletions(-)<br>
&gt;<br>
&gt; diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h<b=
r>
&gt; index 7444738..39eade6 100644<br>
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
&gt; index 4696fd8..41eaa62 100644<br>
&gt; --- a/mm/memcontrol.c<br>
&gt; +++ b/mm/memcontrol.c<br>
&gt; @@ -1105,6 +1105,24 @@ int mem_cgroup_inactive_file_is_low(struct mem_=
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
&gt; index 63c557e..ba03a10 100644<br>
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
<br>
</div></div>Bah!<br>
If you need sc.priority, you have to make cleanup patch at first. and<br>
all current reclaim path have to use sc.priority. Please don&#39;t increase=
<br>
unnecessary mess.<br>
<div class=3D"im"><br>
hmm. so then I would change it by passing the priority as=A0separate=A0para=
meter.</div></blockquote><div>=A0</div><blockquote class=3D"gmail_quote" st=
yle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;"><div=
 class=3D"im">
=A0<br>
&gt;<br>
&gt; =A0#define lru_to_page(_head) (list_entry((_head)-&gt;prev, struct pag=
e, lru))<br>
&gt; @@ -2620,10 +2624,124 @@ static void kswapd_try_to_sleep(struct kswapd=
 *kswapd_p, int order,<br>
&gt; =A0 =A0 =A0 finish_wait(wait_h, &amp;wait);<br>
&gt; =A0}<br>
&gt;<br>
&gt; +#ifdef CONFIG_CGROUP_MEM_RES_CTLR<br>
&gt; +/*<br>
&gt; + * The function is used for per-memcg LRU. It scanns all the zones of=
 the<br>
&gt; + * node and returns the nr_scanned and nr_reclaimed.<br>
&gt; + */<br>
&gt; +static void shrink_memcg_node(pg_data_t *pgdat, int order,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct scan_=
control *sc)<br>
&gt; +{<br>
&gt; + =A0 =A0 int i;<br>
&gt; + =A0 =A0 unsigned long total_scanned =3D 0;<br>
&gt; + =A0 =A0 struct mem_cgroup *mem_cont =3D sc-&gt;mem_cgroup;<br>
&gt; + =A0 =A0 int priority =3D sc-&gt;priority;<br>
<br>
</div>unnecessary local variables. we can keep smaller stack.<br>
<div class=3D"im"><br></div></blockquote><div>ok.=A0</div><blockquote class=
=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padd=
ing-left:1ex;"><div class=3D"im">
<br>
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
<br>
</div>please make helper function for may_writepage. iow, don&#39;t cut-n-p=
aste.<br>
<div class=3D"im"><br>
hmm, can you help to clarify that?=A0<br></div></blockquote><div>=A0</div><=
blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px=
 #ccc solid;padding-left:1ex;"><div class=3D"im">
&gt; +/*<br>
&gt; + * Per cgroup background reclaim.<br>
&gt; + * TODO: Take off the order since memcg always do order 0<br>
&gt; + */<br>
&gt; +static unsigned long shrink_mem_cgroup(struct mem_cgroup *mem_cont, i=
nt order)<br>
&gt; +{<br>
&gt; + =A0 =A0 int i, nid, priority, loop;<br>
&gt; + =A0 =A0 pg_data_t *pgdat;<br>
&gt; + =A0 =A0 nodemask_t do_nodes;<br>
&gt; + =A0 =A0 unsigned long total_scanned;<br>
&gt; + =A0 =A0 struct scan_control sc =3D {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .gfp_mask =3D GFP_KERNEL,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .may_unmap =3D 1,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .may_swap =3D 1,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .nr_to_reclaim =3D SWAP_CLUSTER_MAX,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .swappiness =3D vm_swappiness,<br>
<br>
</div>No. memcg has per-memcg swappiness. Please don&#39;t use global swapp=
iness value.<br>
<div class=3D"im"><br></div></blockquote><div>sounds reasonable, i will tak=
e a look at it.=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0=
 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;"><div class=3D"im">
<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .order =3D order,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .mem_cgroup =3D mem_cont,<br>
&gt; + =A0 =A0 };<br>
&gt; +<br>
&gt; + =A0 =A0 do_nodes =3D NODE_MASK_NONE;<br>
&gt; + =A0 =A0 sc.may_writepage =3D !laptop_mode;<br>
&gt; + =A0 =A0 sc.nr_reclaimed =3D 0;<br>
<br>
</div>this initialization move into sc static initializer. balance pgdat ha=
s<br>
loop_again label and this doesn&#39;t.<br></blockquote><div><br></div><div>=
will change.=A0</div><div>=A0</div><blockquote class=3D"gmail_quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im"><br>
&gt; + =A0 =A0 total_scanned =3D 0;<br>
&gt; +<br>
&gt; + =A0 =A0 do_nodes =3D node_states[N_ONLINE];<br>
<br>
</div>Why do we need care memoryless node? N_HIGH_MEMORY is wrong?<br></blo=
ckquote><div>hmm, let me look into that.=A0</div><blockquote class=3D"gmail=
_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:=
1ex;">

<div class=3D"im"><br>
&gt; +<br>
&gt; + =A0 =A0 for (priority =3D DEF_PRIORITY;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 (priority &gt;=3D 0) &amp;&amp; (sc.nr_to_re=
claim &gt; sc.nr_reclaimed);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 priority--) {<br>
<br>
</div>bah. bad coding style...<br></blockquote><div><br></div><div>ok. will=
 change.=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8=
ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im"><br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 sc.priority =3D priority;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 /* The swap token gets in the way of swapout=
... */<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (!priority)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 disable_swap_token();<br>
<br>
</div>Why?<br>
<br>
disable swap token mean &quot;Please devest swap preventation privilege fro=
m<br>
owner task. Instead we endure swap storm and performance hit&quot;.<br>
However I doublt memcg memory shortage is good situation to make swap storm=
.<br></blockquote><div><br></div><div>I am not sure about that either way. =
we probably can leave as it is and make corresponding change if real proble=
m is observed?=A0</div>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;">
<div class=3D"im"><br>
<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 for (loop =3D num_online_nodes();<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (loop &gt; 0) &amp;&amp; !no=
des_empty(do_nodes);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 loop--) {<br>
<br>
</div>Why don&#39;t you use for_each_online_node()?<br>
Maybe for_each_node_state(n, N_HIGH_MEMORY) is best option?<br>
<br>
At least, find_next_bit() is efficient than bare loop?<br></blockquote><div=
>=A0</div><div><br></div><blockquote class=3D"gmail_quote" style=3D"margin:=
0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im"><br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nid =3D mem_cgroup_select_vi=
ctim_node(mem_cont,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &amp;do_nodes);<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat =3D NODE_DATA(nid);<br=
>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_memcg_node(pgdat, ord=
er, &amp;sc);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned +=3D sc.nr_sca=
nned;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D pgdat-&gt;nr_zone=
s - 1; i &gt;=3D 0; i--) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zone =
*zone =3D pgdat-&gt;node_zones + i;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (populate=
d_zone(zone))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 break;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
<br>
</div>memory less node check is here. but we can check it before.<br></bloc=
kquote><div><br></div><div>Not sure I understand this, can you help to clar=
ify?</div><div><br></div><div>thank you for reviewing</div><div><br></div>
<div>--Ying=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0=
 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div><div></div><div class=3D"h5"><br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (i &lt; 0)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 node_clear(n=
id, do_nodes);<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_watermark_ok(=
mem_cont,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 CHARGE_WMARK_HIGH))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;<br=
>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (total_scanned &amp;&amp; priority &lt; D=
EF_PRIORITY - 2)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 congestion_wait(WRITE, HZ/10=
);<br>
&gt; + =A0 =A0 }<br>
&gt; +out:<br>
&gt; + =A0 =A0 return sc.nr_reclaimed;<br>
&gt; +}<br>
&gt; +#else<br>
&gt; =A0static unsigned long shrink_mem_cgroup(struct mem_cgroup *mem_cont,=
 int order)<br>
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
<br>
<br>
<br>
</div></div></blockquote></div><br>

--000e0ce008bc67ffdb04a17d2aa8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
