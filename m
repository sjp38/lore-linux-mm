Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 139CF90010D
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 19:15:11 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p3QNF6tD005327
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 16:15:06 -0700
Received: from qyg14 (qyg14.prod.google.com [10.241.82.142])
	by hpaq1.eem.corp.google.com with ESMTP id p3QNDwU7030564
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 16:15:05 -0700
Received: by qyg14 with SMTP id 14so583770qyg.19
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 16:15:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110426140815.8847062b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
	<20110425183629.144d3f19.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTinn5Cs8F5beX6od41xhH4qQuRR5Rw@mail.gmail.com>
	<20110426140815.8847062b.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 26 Apr 2011 16:15:04 -0700
Message-ID: <BANLkTinnuPnG9+caKaSb5UN9tQ+Hp+Jh3g@mail.gmail.com>
Subject: Re: [PATCH 5/7] memcg bgreclaim core.
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016e64aefda8b335c04a1da7ef1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>

--0016e64aefda8b335c04a1da7ef1
Content-Type: text/plain; charset=ISO-8859-1

On Mon, Apr 25, 2011 at 10:08 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Mon, 25 Apr 2011 21:59:06 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > On Mon, Apr 25, 2011 at 2:36 AM, KAMEZAWA Hiroyuki
> > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > Following patch will chagnge the logic. This is a core.
> > > ==
> > > This is the main loop of per-memcg background reclaim which is
> implemented in
> > > function balance_mem_cgroup_pgdat().
> > >
> > > The function performs a priority loop similar to global reclaim. During
> each
> > > iteration it frees memory from a selected victim node.
> > > After reclaiming enough pages or scanning enough pages, it returns and
> find
> > > next work with round-robin.
> > >
> > > changelog v8b..v7
> > > 1. reworked for using work_queue rather than threads.
> > > 2. changed shrink_mem_cgroup algorithm to fit workqueue. In short,
> avoid
> > >   long running and allow quick round-robin and unnecessary write page.
> > >   When a thread make pages dirty continuously, write back them by
> flusher
> > >   is far faster than writeback by background reclaim. This detail will
> > >   be fixed when dirty_ratio implemented. The logic around this will be
> > >   revisited in following patche.
> > >
> > > Signed-off-by: Ying Han <yinghan@google.com>
> > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > ---
> > >  include/linux/memcontrol.h |   11 ++++
> > >  mm/memcontrol.c            |   44 ++++++++++++++---
> > >  mm/vmscan.c                |  115
> +++++++++++++++++++++++++++++++++++++++++++++
> > >  3 files changed, 162 insertions(+), 8 deletions(-)
> > >
> > > Index: memcg/include/linux/memcontrol.h
> > > ===================================================================
> > > --- memcg.orig/include/linux/memcontrol.h
> > > +++ memcg/include/linux/memcontrol.h
> > > @@ -89,6 +89,8 @@ extern int mem_cgroup_last_scanned_node(
> > >  extern int mem_cgroup_select_victim_node(struct mem_cgroup *mem,
> > >                                        const nodemask_t *nodes);
> > >
> > > +unsigned long shrink_mem_cgroup(struct mem_cgroup *mem);
> > > +
> > >  static inline
> > >  int mm_match_cgroup(const struct mm_struct *mm, const struct
> mem_cgroup *cgroup)
> > >  {
> > > @@ -112,6 +114,9 @@ extern void mem_cgroup_end_migration(str
> > >  */
> > >  int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
> > >  int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
> > > +unsigned int mem_cgroup_swappiness(struct mem_cgroup *memcg);
> > > +unsigned long mem_cgroup_zone_reclaimable_pages(struct mem_cgroup
> *memcg,
> > > +                               int nid, int zone_idx);
> > >  unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
> > >                                       struct zone *zone,
> > >                                       enum lru_list lru);
> > > @@ -310,6 +315,12 @@ mem_cgroup_inactive_file_is_low(struct m
> > >  }
> > >
> > >  static inline unsigned long
> > > +mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg, int nid,
> int zone_idx)
> > > +{
> > > +       return 0;
> > > +}
> > > +
> > > +static inline unsigned long
> > >  mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg, struct zone *zone,
> > >                         enum lru_list lru)
> > >  {
> > > Index: memcg/mm/memcontrol.c
> > > ===================================================================
> > > --- memcg.orig/mm/memcontrol.c
> > > +++ memcg/mm/memcontrol.c
> > > @@ -1166,6 +1166,23 @@ int mem_cgroup_inactive_file_is_low(stru
> > >        return (active > inactive);
> > >  }
> > >
> > > +unsigned long mem_cgroup_zone_reclaimable_pages(struct mem_cgroup
> *memcg,
> > > +                                               int nid, int zone_idx)
> > > +{
> > > +       int nr;
> > > +       struct mem_cgroup_per_zone *mz =
> > > +               mem_cgroup_zoneinfo(memcg, nid, zone_idx);
> > > +
> > > +       nr = MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_FILE) +
> > > +            MEM_CGROUP_ZSTAT(mz, NR_INACTIVE_FILE);
> > > +
> > > +       if (nr_swap_pages > 0)
> > > +               nr += MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_ANON) +
> > > +                     MEM_CGROUP_ZSTAT(mz, NR_INACTIVE_ANON);
> > > +
> > > +       return nr;
> > > +}
> > > +
> > >  unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
> > >                                       struct zone *zone,
> > >                                       enum lru_list lru)
> > > @@ -1286,7 +1303,7 @@ static unsigned long mem_cgroup_margin(s
> > >        return margin >> PAGE_SHIFT;
> > >  }
> > >
> > > -static unsigned int get_swappiness(struct mem_cgroup *memcg)
> > > +unsigned int mem_cgroup_swappiness(struct mem_cgroup *memcg)
> > >  {
> > >        struct cgroup *cgrp = memcg->css.cgroup;
> > >
> > > @@ -1595,14 +1612,15 @@ static int mem_cgroup_hierarchical_recla
> > >                /* we use swappiness of local cgroup */
> > >                if (check_soft) {
> > >                        ret = mem_cgroup_shrink_node_zone(victim,
> gfp_mask,
> > > -                               noswap, get_swappiness(victim), zone,
> > > +                               noswap, mem_cgroup_swappiness(victim),
> zone,
> > >                                &nr_scanned);
> > >                        *total_scanned += nr_scanned;
> > >                        mem_cgroup_soft_steal(victim, ret);
> > >                        mem_cgroup_soft_scan(victim, nr_scanned);
> > >                } else
> > >                        ret = try_to_free_mem_cgroup_pages(victim,
> gfp_mask,
> > > -                                               noswap,
> get_swappiness(victim));
> > > +                                               noswap,
> > > +
> mem_cgroup_swappiness(victim));
> > >                css_put(&victim->css);
> > >                /*
> > >                 * At shrinking usage, we can't check we should stop
> here or
> > > @@ -1628,15 +1646,25 @@ static int mem_cgroup_hierarchical_recla
> > >  int
> > >  mem_cgroup_select_victim_node(struct mem_cgroup *mem, const nodemask_t
> *nodes)
> > >  {
> > > -       int next_nid;
> > > +       int next_nid, i;
> > >        int last_scanned;
> > >
> > >        last_scanned = mem->last_scanned_node;
> > > -       next_nid = next_node(last_scanned, *nodes);
> > > +       next_nid = last_scanned;
> > > +rescan:
> > > +       next_nid = next_node(next_nid, *nodes);
> > >
> > >        if (next_nid == MAX_NUMNODES)
> > >                next_nid = first_node(*nodes);
> > >
> > > +       /* If no page on this node, skip */
> > > +       for (i = 0; i < MAX_NR_ZONES; i++)
> > > +               if (mem_cgroup_zone_reclaimable_pages(mem, next_nid,
> i))
> > > +                       break;
> > > +
> > > +       if (next_nid != last_scanned && (i == MAX_NR_ZONES))
> > > +               goto rescan;
> > > +
> > >        mem->last_scanned_node = next_nid;
> > >
> > >        return next_nid;
> > > @@ -3649,7 +3677,7 @@ try_to_free:
> > >                        goto out;
> > >                }
> > >                progress = try_to_free_mem_cgroup_pages(mem, GFP_KERNEL,
> > > -                                               false,
> get_swappiness(mem));
> > > +                                       false,
> mem_cgroup_swappiness(mem));
> > >                if (!progress) {
> > >                        nr_retries--;
> > >                        /* maybe some writeback is necessary */
> > > @@ -4073,7 +4101,7 @@ static u64 mem_cgroup_swappiness_read(st
> > >  {
> > >        struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > >
> > > -       return get_swappiness(memcg);
> > > +       return mem_cgroup_swappiness(memcg);
> > >  }
> > >
> > >  static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct
> cftype *cft,
> > > @@ -4849,7 +4877,7 @@ mem_cgroup_create(struct cgroup_subsys *
> > >        INIT_LIST_HEAD(&mem->oom_notify);
> > >
> > >        if (parent)
> > > -               mem->swappiness = get_swappiness(parent);
> > > +               mem->swappiness = mem_cgroup_swappiness(parent);
> > >        atomic_set(&mem->refcnt, 1);
> > >        mem->move_charge_at_immigrate = 0;
> > >        mutex_init(&mem->thresholds_lock);
> > > Index: memcg/mm/vmscan.c
> > > ===================================================================
> > > --- memcg.orig/mm/vmscan.c
> > > +++ memcg/mm/vmscan.c
> > > @@ -42,6 +42,7 @@
> > >  #include <linux/delayacct.h>
> > >  #include <linux/sysctl.h>
> > >  #include <linux/oom.h>
> > > +#include <linux/res_counter.h>
> > >
> > >  #include <asm/tlbflush.h>
> > >  #include <asm/div64.h>
> > > @@ -2308,6 +2309,120 @@ static bool sleeping_prematurely(pg_data
> > >                return !all_zones_ok;
> > >  }
> > >
> > > +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> > > +/*
> > > + * The function is used for per-memcg LRU. It scanns all the zones of
> the
> > > + * node and returns the nr_scanned and nr_reclaimed.
> > > + */
> > > +/*
> > > + * Limit of scanning per iteration. For round-robin.
> > > + */
> > > +#define MEMCG_BGSCAN_LIMIT     (2048)
> > > +
> > > +static void
> > > +shrink_memcg_node(int nid, int priority, struct scan_control *sc)
> > > +{
> > > +       unsigned long total_scanned = 0;
> > > +       struct mem_cgroup *mem_cont = sc->mem_cgroup;
> > > +       int i;
> > > +
> > > +       /*
> > > +        * This dma->highmem order is consistant with global reclaim.
> > > +        * We do this because the page allocator works in the opposite
> > > +        * direction although memcg user pages are mostly allocated at
> > > +        * highmem.
> > > +        */
> > > +       for (i = 0;
> > > +            (i < NODE_DATA(nid)->nr_zones) &&
> > > +            (total_scanned < MEMCG_BGSCAN_LIMIT);
> > > +            i++) {
> > > +               struct zone *zone = NODE_DATA(nid)->node_zones + i;
> > > +               struct zone_reclaim_stat *zrs;
> > > +               unsigned long scan, rotate;
> > > +
> > > +               if (!populated_zone(zone))
> > > +                       continue;
> > > +               scan = mem_cgroup_zone_reclaimable_pages(mem_cont, nid,
> i);
> > > +               if (!scan)
> > > +                       continue;
> > > +               /* If recent memory reclaim on this zone doesn't get
> good */
> > > +               zrs = get_reclaim_stat(zone, sc);
> > > +               scan = zrs->recent_scanned[0] + zrs->recent_scanned[1];
> > > +               rotate = zrs->recent_rotated[0] +
> zrs->recent_rotated[1];
> > > +
> > > +               if (rotate > scan/2)
> > > +                       sc->may_writepage = 1;
> > > +
> > > +               sc->nr_scanned = 0;
> > > +               shrink_zone(priority, zone, sc);
> > > +               total_scanned += sc->nr_scanned;
> > > +               sc->may_writepage = 0;
> > > +       }
> > > +       sc->nr_scanned = total_scanned;
> > > +}
> >
> > I see the MEMCG_BGSCAN_LIMIT is a newly defined macro from previous
> > post. So, now the number of pages to scan is capped on 2k for each
> > memcg, and does it make difference on big vs small cgroup?
> >
>
> Now, no difference. One reason is because low_watermark - high_watermark is
> limited to 4MB, at most. It should be static 4MB in many cases and 2048
> pages
> is for scanning 8MB, twice of low_wmark - high_wmark. Another reason is
> that I didn't have enough time for considering to tune this.
> By MEMCG_BGSCAN_LIMIT, round-robin can be simply fair and I think it's a
> good start point.
>

I can see a problem here to be "fair" to each memcg. Each container has
different sizes and running with
different workloads. Some of them are more sensitive with latency than the
other, so they are willing to pay
more cpu cycles to do background reclaim.

So, here we fix the amount of work per-memcg, and the performance for those
jobs will be hurt. If i understand
correctly, we only have one workitem on the workqueue per memcg. So which
means we can only reclaim those amount of pages for each iteration. And if
the queue is big, those jobs(heavy memory allocating, and willing to pay cpu
to do bg reclaim) will hit direct reclaim more than necessary.

--Ying

>
> If memory eater enough slow (because the threads needs to do some
> work on allocated memory), this shrink_mem_cgroup() works fine and
> helps to avoid hitting limit. Here, the amount of dirty pages is
> troublesome.
>
> The penaly for cpu eating (hard-to-reclaim) cgroup is given by 'delay'.
> (see patch 7.) This patch's congestion_wait is too bad and will be replaced
> in patch 7 as 'delay'. In short, if memcg scanning seems to be not
> successful,
> it gets HZ/10 delay until the next work.
>
> If we have dirty_ratio + I/O less dirty throttling, I think we'll see much
> better fairness on this watermark reclaim round robin.
>
>
> Thanks,
> -Kame
>
>
>
>

--0016e64aefda8b335c04a1da7ef1
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Mon, Apr 25, 2011 at 10:08 PM, KAMEZA=
WA Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fuji=
tsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquot=
e class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc sol=
id;padding-left:1ex;">
<div><div></div><div class=3D"h5">On Mon, 25 Apr 2011 21:59:06 -0700<br>
Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google.com</a>&g=
t; wrote:<br>
<br>
&gt; On Mon, Apr 25, 2011 at 2:36 AM, KAMEZAWA Hiroyuki<br>
&gt; &lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com">kamezawa.hiroyu@=
jp.fujitsu.com</a>&gt; wrote:<br>
&gt; &gt; Following patch will chagnge the logic. This is a core.<br>
&gt; &gt; =3D=3D<br>
&gt; &gt; This is the main loop of per-memcg background reclaim which is im=
plemented in<br>
&gt; &gt; function balance_mem_cgroup_pgdat().<br>
&gt; &gt;<br>
&gt; &gt; The function performs a priority loop similar to global reclaim. =
During each<br>
&gt; &gt; iteration it frees memory from a selected victim node.<br>
&gt; &gt; After reclaiming enough pages or scanning enough pages, it return=
s and find<br>
&gt; &gt; next work with round-robin.<br>
&gt; &gt;<br>
&gt; &gt; changelog v8b..v7<br>
&gt; &gt; 1. reworked for using work_queue rather than threads.<br>
&gt; &gt; 2. changed shrink_mem_cgroup algorithm to fit workqueue. In short=
, avoid<br>
&gt; &gt; =A0 long running and allow quick round-robin and unnecessary writ=
e page.<br>
&gt; &gt; =A0 When a thread make pages dirty continuously, write back them =
by flusher<br>
&gt; &gt; =A0 is far faster than writeback by background reclaim. This deta=
il will<br>
&gt; &gt; =A0 be fixed when dirty_ratio implemented. The logic around this =
will be<br>
&gt; &gt; =A0 revisited in following patche.<br>
&gt; &gt;<br>
&gt; &gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com"=
>yinghan@google.com</a>&gt;<br>
&gt; &gt; Signed-off-by: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.h=
iroyu@jp.fujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<br>
&gt; &gt; ---<br>
&gt; &gt; =A0include/linux/memcontrol.h | =A0 11 ++++<br>
&gt; &gt; =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 44 ++++++++++++++=
---<br>
&gt; &gt; =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0115 ++++++++++=
+++++++++++++++++++++++++++++++++++<br>
&gt; &gt; =A03 files changed, 162 insertions(+), 8 deletions(-)<br>
&gt; &gt;<br>
&gt; &gt; Index: memcg/include/linux/memcontrol.h<br>
&gt; &gt; =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
&gt; &gt; --- memcg.orig/include/linux/memcontrol.h<br>
&gt; &gt; +++ memcg/include/linux/memcontrol.h<br>
&gt; &gt; @@ -89,6 +89,8 @@ extern int mem_cgroup_last_scanned_node(<br>
&gt; &gt; =A0extern int mem_cgroup_select_victim_node(struct mem_cgroup *me=
m,<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0const nodemask_t *nodes);<br>
&gt; &gt;<br>
&gt; &gt; +unsigned long shrink_mem_cgroup(struct mem_cgroup *mem);<br>
&gt; &gt; +<br>
&gt; &gt; =A0static inline<br>
&gt; &gt; =A0int mm_match_cgroup(const struct mm_struct *mm, const struct m=
em_cgroup *cgroup)<br>
&gt; &gt; =A0{<br>
&gt; &gt; @@ -112,6 +114,9 @@ extern void mem_cgroup_end_migration(str<br>
&gt; &gt; =A0*/<br>
&gt; &gt; =A0int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);=
<br>
&gt; &gt; =A0int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);=
<br>
&gt; &gt; +unsigned int mem_cgroup_swappiness(struct mem_cgroup *memcg);<br=
>
&gt; &gt; +unsigned long mem_cgroup_zone_reclaimable_pages(struct mem_cgrou=
p *memcg,<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int=
 nid, int zone_idx);<br>
&gt; &gt; =A0unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memc=
g,<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 struct zone *zone,<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 enum lru_list lru);<br>
&gt; &gt; @@ -310,6 +315,12 @@ mem_cgroup_inactive_file_is_low(struct m<br>
&gt; &gt; =A0}<br>
&gt; &gt;<br>
&gt; &gt; =A0static inline unsigned long<br>
&gt; &gt; +mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg, int =
nid, int zone_idx)<br>
&gt; &gt; +{<br>
&gt; &gt; + =A0 =A0 =A0 return 0;<br>
&gt; &gt; +}<br>
&gt; &gt; +<br>
&gt; &gt; +static inline unsigned long<br>
&gt; &gt; =A0mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg, struct zone=
 *zone,<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum lru_list lru=
)<br>
&gt; &gt; =A0{<br>
&gt; &gt; Index: memcg/mm/memcontrol.c<br>
&gt; &gt; =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
&gt; &gt; --- memcg.orig/mm/memcontrol.c<br>
&gt; &gt; +++ memcg/mm/memcontrol.c<br>
&gt; &gt; @@ -1166,6 +1166,23 @@ int mem_cgroup_inactive_file_is_low(stru<b=
r>
&gt; &gt; =A0 =A0 =A0 =A0return (active &gt; inactive);<br>
&gt; &gt; =A0}<br>
&gt; &gt;<br>
&gt; &gt; +unsigned long mem_cgroup_zone_reclaimable_pages(struct mem_cgrou=
p *memcg,<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int nid, int zone_idx)<br>
&gt; &gt; +{<br>
&gt; &gt; + =A0 =A0 =A0 int nr;<br>
&gt; &gt; + =A0 =A0 =A0 struct mem_cgroup_per_zone *mz =3D<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_zoneinfo(memcg, nid, zon=
e_idx);<br>
&gt; &gt; +<br>
&gt; &gt; + =A0 =A0 =A0 nr =3D MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_FILE) +<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0MEM_CGROUP_ZSTAT(mz, NR_INACTIVE_FILE);<=
br>
&gt; &gt; +<br>
&gt; &gt; + =A0 =A0 =A0 if (nr_swap_pages &gt; 0)<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr +=3D MEM_CGROUP_ZSTAT(mz, NR_ACT=
IVE_ANON) +<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MEM_CGROUP_ZSTAT(mz, NR=
_INACTIVE_ANON);<br>
&gt; &gt; +<br>
&gt; &gt; + =A0 =A0 =A0 return nr;<br>
&gt; &gt; +}<br>
&gt; &gt; +<br>
&gt; &gt; =A0unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memc=
g,<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 struct zone *zone,<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 enum lru_list lru)<br>
&gt; &gt; @@ -1286,7 +1303,7 @@ static unsigned long mem_cgroup_margin(s<br=
>
&gt; &gt; =A0 =A0 =A0 =A0return margin &gt;&gt; PAGE_SHIFT;<br>
&gt; &gt; =A0}<br>
&gt; &gt;<br>
&gt; &gt; -static unsigned int get_swappiness(struct mem_cgroup *memcg)<br>
&gt; &gt; +unsigned int mem_cgroup_swappiness(struct mem_cgroup *memcg)<br>
&gt; &gt; =A0{<br>
&gt; &gt; =A0 =A0 =A0 =A0struct cgroup *cgrp =3D memcg-&gt;css.cgroup;<br>
&gt; &gt;<br>
&gt; &gt; @@ -1595,14 +1612,15 @@ static int mem_cgroup_hierarchical_recla<=
br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* we use swappiness of local cgro=
up */<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (check_soft) {<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D mem_cgroup=
_shrink_node_zone(victim, gfp_mask,<br>
&gt; &gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nos=
wap, get_swappiness(victim), zone,<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nos=
wap, mem_cgroup_swappiness(victim), zone,<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&a=
mp;nr_scanned);<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*total_scanned +=
=3D nr_scanned;<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_soft_st=
eal(victim, ret);<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_soft_sc=
an(victim, nr_scanned);<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D try_to_fre=
e_mem_cgroup_pages(victim, gfp_mask,<br>
&gt; &gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 noswap, get_swappiness(victim));<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 noswap,<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_swappiness(victim));<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0css_put(&amp;victim-&gt;css);<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * At shrinking usage, we can&#39;=
t check we should stop here or<br>
&gt; &gt; @@ -1628,15 +1646,25 @@ static int mem_cgroup_hierarchical_recla<=
br>
&gt; &gt; =A0int<br>
&gt; &gt; =A0mem_cgroup_select_victim_node(struct mem_cgroup *mem, const no=
demask_t *nodes)<br>
&gt; &gt; =A0{<br>
&gt; &gt; - =A0 =A0 =A0 int next_nid;<br>
&gt; &gt; + =A0 =A0 =A0 int next_nid, i;<br>
&gt; &gt; =A0 =A0 =A0 =A0int last_scanned;<br>
&gt; &gt;<br>
&gt; &gt; =A0 =A0 =A0 =A0last_scanned =3D mem-&gt;last_scanned_node;<br>
&gt; &gt; - =A0 =A0 =A0 next_nid =3D next_node(last_scanned, *nodes);<br>
&gt; &gt; + =A0 =A0 =A0 next_nid =3D last_scanned;<br>
&gt; &gt; +rescan:<br>
&gt; &gt; + =A0 =A0 =A0 next_nid =3D next_node(next_nid, *nodes);<br>
&gt; &gt;<br>
&gt; &gt; =A0 =A0 =A0 =A0if (next_nid =3D=3D MAX_NUMNODES)<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0next_nid =3D first_node(*nodes);<b=
r>
&gt; &gt;<br>
&gt; &gt; + =A0 =A0 =A0 /* If no page on this node, skip */<br>
&gt; &gt; + =A0 =A0 =A0 for (i =3D 0; i &lt; MAX_NR_ZONES; i++)<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_zone_reclaimable_pag=
es(mem, next_nid, i))<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
&gt; &gt; +<br>
&gt; &gt; + =A0 =A0 =A0 if (next_nid !=3D last_scanned &amp;&amp; (i =3D=3D=
 MAX_NR_ZONES))<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto rescan;<br>
&gt; &gt; +<br>
&gt; &gt; =A0 =A0 =A0 =A0mem-&gt;last_scanned_node =3D next_nid;<br>
&gt; &gt;<br>
&gt; &gt; =A0 =A0 =A0 =A0return next_nid;<br>
&gt; &gt; @@ -3649,7 +3677,7 @@ try_to_free:<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0progress =3D try_to_free_mem_cgrou=
p_pages(mem, GFP_KERNEL,<br>
&gt; &gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 false, get_swappiness(mem));<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 false, mem_cgroup_swappiness(mem));<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!progress) {<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_retries--;<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* maybe some writ=
eback is necessary */<br>
&gt; &gt; @@ -4073,7 +4101,7 @@ static u64 mem_cgroup_swappiness_read(st<br=
>
&gt; &gt; =A0{<br>
&gt; &gt; =A0 =A0 =A0 =A0struct mem_cgroup *memcg =3D mem_cgroup_from_cont(=
cgrp);<br>
&gt; &gt;<br>
&gt; &gt; - =A0 =A0 =A0 return get_swappiness(memcg);<br>
&gt; &gt; + =A0 =A0 =A0 return mem_cgroup_swappiness(memcg);<br>
&gt; &gt; =A0}<br>
&gt; &gt;<br>
&gt; &gt; =A0static int mem_cgroup_swappiness_write(struct cgroup *cgrp, st=
ruct cftype *cft,<br>
&gt; &gt; @@ -4849,7 +4877,7 @@ mem_cgroup_create(struct cgroup_subsys *<br=
>
&gt; &gt; =A0 =A0 =A0 =A0INIT_LIST_HEAD(&amp;mem-&gt;oom_notify);<br>
&gt; &gt;<br>
&gt; &gt; =A0 =A0 =A0 =A0if (parent)<br>
&gt; &gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem-&gt;swappiness =3D get_swappine=
ss(parent);<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem-&gt;swappiness =3D mem_cgroup_s=
wappiness(parent);<br>
&gt; &gt; =A0 =A0 =A0 =A0atomic_set(&amp;mem-&gt;refcnt, 1);<br>
&gt; &gt; =A0 =A0 =A0 =A0mem-&gt;move_charge_at_immigrate =3D 0;<br>
&gt; &gt; =A0 =A0 =A0 =A0mutex_init(&amp;mem-&gt;thresholds_lock);<br>
&gt; &gt; Index: memcg/mm/vmscan.c<br>
&gt; &gt; =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
&gt; &gt; --- memcg.orig/mm/vmscan.c<br>
&gt; &gt; +++ memcg/mm/vmscan.c<br>
&gt; &gt; @@ -42,6 +42,7 @@<br>
&gt; &gt; =A0#include &lt;linux/delayacct.h&gt;<br>
&gt; &gt; =A0#include &lt;linux/sysctl.h&gt;<br>
&gt; &gt; =A0#include &lt;linux/oom.h&gt;<br>
&gt; &gt; +#include &lt;linux/res_counter.h&gt;<br>
&gt; &gt;<br>
&gt; &gt; =A0#include &lt;asm/tlbflush.h&gt;<br>
&gt; &gt; =A0#include &lt;asm/div64.h&gt;<br>
&gt; &gt; @@ -2308,6 +2309,120 @@ static bool sleeping_prematurely(pg_data<=
br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return !all_zones_ok;<br>
&gt; &gt; =A0}<br>
&gt; &gt;<br>
&gt; &gt; +#ifdef CONFIG_CGROUP_MEM_RES_CTLR<br>
&gt; &gt; +/*<br>
&gt; &gt; + * The function is used for per-memcg LRU. It scanns all the zon=
es of the<br>
&gt; &gt; + * node and returns the nr_scanned and nr_reclaimed.<br>
&gt; &gt; + */<br>
&gt; &gt; +/*<br>
&gt; &gt; + * Limit of scanning per iteration. For round-robin.<br>
&gt; &gt; + */<br>
&gt; &gt; +#define MEMCG_BGSCAN_LIMIT =A0 =A0 (2048)<br>
&gt; &gt; +<br>
&gt; &gt; +static void<br>
&gt; &gt; +shrink_memcg_node(int nid, int priority, struct scan_control *sc=
)<br>
&gt; &gt; +{<br>
&gt; &gt; + =A0 =A0 =A0 unsigned long total_scanned =3D 0;<br>
&gt; &gt; + =A0 =A0 =A0 struct mem_cgroup *mem_cont =3D sc-&gt;mem_cgroup;<=
br>
&gt; &gt; + =A0 =A0 =A0 int i;<br>
&gt; &gt; +<br>
&gt; &gt; + =A0 =A0 =A0 /*<br>
&gt; &gt; + =A0 =A0 =A0 =A0* This dma-&gt;highmem order is consistant with =
global reclaim.<br>
&gt; &gt; + =A0 =A0 =A0 =A0* We do this because the page allocator works in=
 the opposite<br>
&gt; &gt; + =A0 =A0 =A0 =A0* direction although memcg user pages are mostly=
 allocated at<br>
&gt; &gt; + =A0 =A0 =A0 =A0* highmem.<br>
&gt; &gt; + =A0 =A0 =A0 =A0*/<br>
&gt; &gt; + =A0 =A0 =A0 for (i =3D 0;<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0(i &lt; NODE_DATA(nid)-&gt;nr_zones) &am=
p;&amp;<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0(total_scanned &lt; MEMCG_BGSCAN_LIMIT);=
<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0i++) {<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone =3D NODE_DATA(nid=
)-&gt;node_zones + i;<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zone_reclaim_stat *zrs;<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long scan, rotate;<br>
&gt; &gt; +<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!populated_zone(zone))<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 scan =3D mem_cgroup_zone_reclaimabl=
e_pages(mem_cont, nid, i);<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!scan)<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* If recent memory reclaim on this=
 zone doesn&#39;t get good */<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 zrs =3D get_reclaim_stat(zone, sc);=
<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 scan =3D zrs-&gt;recent_scanned[0] =
+ zrs-&gt;recent_scanned[1];<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rotate =3D zrs-&gt;recent_rotated[0=
] + zrs-&gt;recent_rotated[1];<br>
&gt; &gt; +<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (rotate &gt; scan/2)<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;may_writepag=
e =3D 1;<br>
&gt; &gt; +<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;nr_scanned =3D 0;<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_zone(priority, zone, sc);<br=
>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned +=3D sc-&gt;nr_scanne=
d;<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;may_writepage =3D 0;<br>
&gt; &gt; + =A0 =A0 =A0 }<br>
&gt; &gt; + =A0 =A0 =A0 sc-&gt;nr_scanned =3D total_scanned;<br>
&gt; &gt; +}<br>
&gt;<br>
&gt; I see the MEMCG_BGSCAN_LIMIT is a newly defined macro from previous<br=
>
&gt; post. So, now the number of pages to scan is capped on 2k for each<br>
&gt; memcg, and does it make difference on big vs small cgroup?<br>
&gt;<br>
<br>
</div></div>Now, no difference. One reason is because low_watermark - high_=
watermark is<br>
limited to 4MB, at most. It should be static 4MB in many cases and 2048 pag=
es<br>
is for scanning 8MB, twice of low_wmark - high_wmark. Another reason is<br>
that I didn&#39;t have enough time for considering to tune this.<br>
By MEMCG_BGSCAN_LIMIT, round-robin can be simply fair and I think it&#39;s =
a<br>
good start point.<br></blockquote><div><br></div><div>I can see a problem h=
ere to be &quot;fair&quot; to each memcg. Each container has different size=
s and running with</div><div>different workloads. Some of them are more sen=
sitive with latency than the other, so they are willing to pay</div>
<div>more cpu cycles to do background reclaim.=A0</div><div><br></div><div>=
So, here we fix the amount of work per-memcg, and the=A0performance for tho=
se jobs will be hurt. If i understand</div><div>correctly, we only have one=
 workitem on the workqueue per memcg. So which means we can only reclaim th=
ose amount of pages for each iteration. And if the queue is big, those jobs=
(heavy memory allocating, and willing to pay cpu to do bg reclaim) will hit=
 direct reclaim more than necessary.</div>
<div><br></div><div>--Ying</div><blockquote class=3D"gmail_quote" style=3D"=
margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<br>
If memory eater enough slow (because the threads needs to do some<br>
work on allocated memory), this shrink_mem_cgroup() works fine and<br>
helps to avoid hitting limit. Here, the amount of dirty pages is troublesom=
e.<br>
<br>
The penaly for cpu eating (hard-to-reclaim) cgroup is given by &#39;delay&#=
39;.<br>
(see patch 7.) This patch&#39;s congestion_wait is too bad and will be repl=
aced<br>
in patch 7 as &#39;delay&#39;. In short, if memcg scanning seems to be not =
successful,<br>
it gets HZ/10 delay until the next work.<br>
<br>
If we have dirty_ratio + I/O less dirty throttling, I think we&#39;ll see m=
uch<br>
better fairness on this watermark reclaim round robin.<br>
<br>
<br>
Thanks,<br>
-Kame<br>
<br>
<br>
<br>
</blockquote></div><br>

--0016e64aefda8b335c04a1da7ef1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
