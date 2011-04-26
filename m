Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 143BD9000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 14:38:08 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id p3QIbx8O007050
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 11:37:59 -0700
Received: from qyk32 (qyk32.prod.google.com [10.241.83.160])
	by hpaq3.eem.corp.google.com with ESMTP id p3QIbBxC006893
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 11:37:58 -0700
Received: by qyk32 with SMTP id 32so1512999qyk.8
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 11:37:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110425183629.144d3f19.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
	<20110425183629.144d3f19.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 26 Apr 2011 11:37:57 -0700
Message-ID: <BANLkTim593sNWDisok+f2DOMqniCF3tDAg@mail.gmail.com>
Subject: Re: [PATCH 5/7] memcg bgreclaim core.
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=002354470aa877c14d04a1d69f92
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>

--002354470aa877c14d04a1d69f92
Content-Type: text/plain; charset=ISO-8859-1

On Mon, Apr 25, 2011 at 2:36 AM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Following patch will chagnge the logic. This is a core.
> ==
> This is the main loop of per-memcg background reclaim which is implemented
> in
> function balance_mem_cgroup_pgdat().
>
> The function performs a priority loop similar to global reclaim. During
> each
> iteration it frees memory from a selected victim node.
> After reclaiming enough pages or scanning enough pages, it returns and find
> next work with round-robin.
>
> changelog v8b..v7
> 1. reworked for using work_queue rather than threads.
> 2. changed shrink_mem_cgroup algorithm to fit workqueue. In short, avoid
>   long running and allow quick round-robin and unnecessary write page.
>   When a thread make pages dirty continuously, write back them by flusher
>   is far faster than writeback by background reclaim. This detail will
>   be fixed when dirty_ratio implemented. The logic around this will be
>   revisited in following patche.
>
> Signed-off-by: Ying Han <yinghan@google.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/memcontrol.h |   11 ++++
>  mm/memcontrol.c            |   44 ++++++++++++++---
>  mm/vmscan.c                |  115
> +++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 162 insertions(+), 8 deletions(-)
>
> Index: memcg/include/linux/memcontrol.h
> ===================================================================
> --- memcg.orig/include/linux/memcontrol.h
> +++ memcg/include/linux/memcontrol.h
> @@ -89,6 +89,8 @@ extern int mem_cgroup_last_scanned_node(
>  extern int mem_cgroup_select_victim_node(struct mem_cgroup *mem,
>                                        const nodemask_t *nodes);
>
> +unsigned long shrink_mem_cgroup(struct mem_cgroup *mem);
> +
>  static inline
>  int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup
> *cgroup)
>  {
> @@ -112,6 +114,9 @@ extern void mem_cgroup_end_migration(str
>  */
>  int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
>  int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
> +unsigned int mem_cgroup_swappiness(struct mem_cgroup *memcg);
> +unsigned long mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg,
> +                               int nid, int zone_idx);
>  unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
>                                       struct zone *zone,
>                                       enum lru_list lru);
> @@ -310,6 +315,12 @@ mem_cgroup_inactive_file_is_low(struct m
>  }
>
>  static inline unsigned long
> +mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg, int nid, int
> zone_idx)
> +{
> +       return 0;
> +}
> +
> +static inline unsigned long
>  mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg, struct zone *zone,
>                         enum lru_list lru)
>  {
> Index: memcg/mm/memcontrol.c
> ===================================================================
> --- memcg.orig/mm/memcontrol.c
> +++ memcg/mm/memcontrol.c
> @@ -1166,6 +1166,23 @@ int mem_cgroup_inactive_file_is_low(stru
>        return (active > inactive);
>  }
>
> +unsigned long mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg,
> +                                               int nid, int zone_idx)
> +{
> +       int nr;
> +       struct mem_cgroup_per_zone *mz =
> +               mem_cgroup_zoneinfo(memcg, nid, zone_idx);
> +
> +       nr = MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_FILE) +
> +            MEM_CGROUP_ZSTAT(mz, NR_INACTIVE_FILE);
> +
> +       if (nr_swap_pages > 0)
> +               nr += MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_ANON) +
> +                     MEM_CGROUP_ZSTAT(mz, NR_INACTIVE_ANON);
> +
> +       return nr;
> +}
> +
>  unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
>                                       struct zone *zone,
>                                       enum lru_list lru)
> @@ -1286,7 +1303,7 @@ static unsigned long mem_cgroup_margin(s
>        return margin >> PAGE_SHIFT;
>  }
>
> -static unsigned int get_swappiness(struct mem_cgroup *memcg)
> +unsigned int mem_cgroup_swappiness(struct mem_cgroup *memcg)
>  {
>        struct cgroup *cgrp = memcg->css.cgroup;
>
> @@ -1595,14 +1612,15 @@ static int mem_cgroup_hierarchical_recla
>                /* we use swappiness of local cgroup */
>                if (check_soft) {
>                        ret = mem_cgroup_shrink_node_zone(victim, gfp_mask,
> -                               noswap, get_swappiness(victim), zone,
> +                               noswap, mem_cgroup_swappiness(victim),
> zone,
>                                &nr_scanned);
>                        *total_scanned += nr_scanned;
>                        mem_cgroup_soft_steal(victim, ret);
>                        mem_cgroup_soft_scan(victim, nr_scanned);
>                } else
>                        ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
> -                                               noswap,
> get_swappiness(victim));
> +                                               noswap,
> +
> mem_cgroup_swappiness(victim));
>                css_put(&victim->css);
>                /*
>                 * At shrinking usage, we can't check we should stop here or
> @@ -1628,15 +1646,25 @@ static int mem_cgroup_hierarchical_recla
>  int
>  mem_cgroup_select_victim_node(struct mem_cgroup *mem, const nodemask_t
> *nodes)
>  {
> -       int next_nid;
> +       int next_nid, i;
>        int last_scanned;
>
>        last_scanned = mem->last_scanned_node;
> -       next_nid = next_node(last_scanned, *nodes);
> +       next_nid = last_scanned;
> +rescan:
> +       next_nid = next_node(next_nid, *nodes);
>
>        if (next_nid == MAX_NUMNODES)
>                next_nid = first_node(*nodes);
>
> +       /* If no page on this node, skip */
> +       for (i = 0; i < MAX_NR_ZONES; i++)
> +               if (mem_cgroup_zone_reclaimable_pages(mem, next_nid, i))
> +                       break;
> +
> +       if (next_nid != last_scanned && (i == MAX_NR_ZONES))
> +               goto rescan;
> +
>        mem->last_scanned_node = next_nid;
>
>        return next_nid;
> @@ -3649,7 +3677,7 @@ try_to_free:
>                        goto out;
>                }
>                progress = try_to_free_mem_cgroup_pages(mem, GFP_KERNEL,
> -                                               false,
> get_swappiness(mem));
> +                                       false, mem_cgroup_swappiness(mem));
>                if (!progress) {
>                        nr_retries--;
>                        /* maybe some writeback is necessary */
> @@ -4073,7 +4101,7 @@ static u64 mem_cgroup_swappiness_read(st
>  {
>        struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
>
> -       return get_swappiness(memcg);
> +       return mem_cgroup_swappiness(memcg);
>  }
>
>  static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype
> *cft,
> @@ -4849,7 +4877,7 @@ mem_cgroup_create(struct cgroup_subsys *
>        INIT_LIST_HEAD(&mem->oom_notify);
>
>        if (parent)
> -               mem->swappiness = get_swappiness(parent);
> +               mem->swappiness = mem_cgroup_swappiness(parent);
>        atomic_set(&mem->refcnt, 1);
>        mem->move_charge_at_immigrate = 0;
>        mutex_init(&mem->thresholds_lock);
> Index: memcg/mm/vmscan.c
> ===================================================================
> --- memcg.orig/mm/vmscan.c
> +++ memcg/mm/vmscan.c
> @@ -42,6 +42,7 @@
>  #include <linux/delayacct.h>
>  #include <linux/sysctl.h>
>  #include <linux/oom.h>
> +#include <linux/res_counter.h>
>
>  #include <asm/tlbflush.h>
>  #include <asm/div64.h>
> @@ -2308,6 +2309,120 @@ static bool sleeping_prematurely(pg_data
>                return !all_zones_ok;
>  }
>
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +/*
> + * The function is used for per-memcg LRU. It scanns all the zones of the
> + * node and returns the nr_scanned and nr_reclaimed.
> + */
> +/*
> + * Limit of scanning per iteration. For round-robin.
> + */
> +#define MEMCG_BGSCAN_LIMIT     (2048)
> +
> +static void
> +shrink_memcg_node(int nid, int priority, struct scan_control *sc)
> +{
> +       unsigned long total_scanned = 0;
> +       struct mem_cgroup *mem_cont = sc->mem_cgroup;
> +       int i;
> +
> +       /*
> +        * This dma->highmem order is consistant with global reclaim.
> +        * We do this because the page allocator works in the opposite
> +        * direction although memcg user pages are mostly allocated at
> +        * highmem.
> +        */
> +       for (i = 0;
> +            (i < NODE_DATA(nid)->nr_zones) &&
> +            (total_scanned < MEMCG_BGSCAN_LIMIT);
> +            i++) {
> +               struct zone *zone = NODE_DATA(nid)->node_zones + i;
> +               struct zone_reclaim_stat *zrs;
> +               unsigned long scan, rotate;
> +
> +               if (!populated_zone(zone))
> +                       continue;
> +               scan = mem_cgroup_zone_reclaimable_pages(mem_cont, nid, i);
> +               if (!scan)
> +                       continue;
> +               /* If recent memory reclaim on this zone doesn't get good
> */
> +               zrs = get_reclaim_stat(zone, sc);
> +               scan = zrs->recent_scanned[0] + zrs->recent_scanned[1];
> +               rotate = zrs->recent_rotated[0] + zrs->recent_rotated[1];
> +
> +               if (rotate > scan/2)
> +                       sc->may_writepage = 1;
> +
> +               sc->nr_scanned = 0;
> +               shrink_zone(priority, zone, sc);
> +               total_scanned += sc->nr_scanned;
> +               sc->may_writepage = 0;
> +       }
> +       sc->nr_scanned = total_scanned;
> +}
> +
> +/*
> + * Per cgroup background reclaim.
> + */
> +unsigned long shrink_mem_cgroup(struct mem_cgroup *mem)
> +{
> +       int nid, priority, next_prio;
> +       nodemask_t nodes;
> +       unsigned long total_scanned;
> +       struct scan_control sc = {
> +               .gfp_mask = GFP_HIGHUSER_MOVABLE,
>

I noticed this is changed from GFP_KERNEL from previous patch, and also
seems memcg reclaim uses this flag as well on other reclaim path. So it
should be a ok change.

+               .may_unmap = 1,
> +               .may_swap = 1,
> +               .nr_to_reclaim = SWAP_CLUSTER_MAX,
> +               .order = 0,
> +               .mem_cgroup = mem,
> +       };
> +
> +       sc.may_writepage = 0;
> +       sc.nr_reclaimed = 0;
> +       total_scanned = 0;
> +       nodes = node_states[N_HIGH_MEMORY];
> +       sc.swappiness = mem_cgroup_swappiness(mem);
> +
> +       current->flags |= PF_SWAPWRITE;
>
why we set the flags here instead of in the main kswapd function
memcg_bgreclaim()
?

+       /*
> +        * Unlike kswapd, we need to traverse cgroups one by one. So, we
> don't
> +        * use full priority. Just scan small number of pages and visit
> next.
> +        * Now, we scan MEMCG_BGRECLAIM_SCAN_LIMIT pages per scan.
> +        * We use static priority 0.
> +        */
>
this comment here is a bit confusing since we are doing reclaim for one
memcg in this funcion.

+       next_prio = min(SWAP_CLUSTER_MAX * num_node_state(N_HIGH_MEMORY),
> +                       MEMCG_BGSCAN_LIMIT/8);
> +       priority = DEF_PRIORITY;
> +       while ((total_scanned < MEMCG_BGSCAN_LIMIT) &&
> +              !nodes_empty(nodes) &&
> +              (sc.nr_to_reclaim > sc.nr_reclaimed)) {
> +
> +               nid = mem_cgroup_select_victim_node(mem, &nodes);
> +               shrink_memcg_node(nid, priority, &sc);
> +               /*
> +                * the node seems to have no pages.
> +                * skip this for a while
> +                */
> +               if (!sc.nr_scanned)
> +                       node_clear(nid, nodes);
> +               total_scanned += sc.nr_scanned;
> +               if (mem_cgroup_watermark_ok(mem, CHARGE_WMARK_HIGH))
> +                       break;
> +               /* emulate priority */
> +               if (total_scanned > next_prio) {
> +                       priority--;
> +                       next_prio <<= 1;
> +               }
> +               if (sc.nr_scanned &&
> +                   total_scanned > sc.nr_reclaimed * 2)
> +                       congestion_wait(WRITE, HZ/10);
> +       }
> +       current->flags &= ~PF_SWAPWRITE;
>

hmm, the same question above. why we need to set this flag each time?

--Ying

+       return sc.nr_reclaimed;
> +}
> +#endif
> +
>  /*
>  * For kswapd, balance_pgdat() will work across all this node's zones until
>  * they are all at high_wmark_pages(zone).
>
>

--002354470aa877c14d04a1d69f92
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Mon, Apr 25, 2011 at 2:36 AM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
Following patch will chagnge the logic. This is a core.<br>
=3D=3D<br>
This is the main loop of per-memcg background reclaim which is implemented =
in<br>
function balance_mem_cgroup_pgdat().<br>
<br>
The function performs a priority loop similar to global reclaim. During eac=
h<br>
iteration it frees memory from a selected victim node.<br>
After reclaiming enough pages or scanning enough pages, it returns and find=
<br>
next work with round-robin.<br>
<br>
changelog v8b..v7<br>
1. reworked for using work_queue rather than threads.<br>
2. changed shrink_mem_cgroup algorithm to fit workqueue. In short, avoid<br=
>
 =A0 long running and allow quick round-robin and unnecessary write page.<b=
r>
 =A0 When a thread make pages dirty continuously, write back them by flushe=
r<br>
 =A0 is far faster than writeback by background reclaim. This detail will<b=
r>
 =A0 be fixed when dirty_ratio implemented. The logic around this will be<b=
r>
 =A0 revisited in following patche.<br>
<br>
Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@g=
oogle.com</a>&gt;<br>
Signed-off-by: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu@jp.f=
ujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<br>
---<br>
=A0include/linux/memcontrol.h | =A0 11 ++++<br>
=A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 44 ++++++++++++++---<br>
=A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0115 ++++++++++++++++++++=
+++++++++++++++++++++++++<br>
=A03 files changed, 162 insertions(+), 8 deletions(-)<br>
<br>
Index: memcg/include/linux/memcontrol.h<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- memcg.orig/include/linux/memcontrol.h<br>
+++ memcg/include/linux/memcontrol.h<br>
@@ -89,6 +89,8 @@ extern int mem_cgroup_last_scanned_node(<br>
=A0extern int mem_cgroup_select_victim_node(struct mem_cgroup *mem,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0const nodemask_t *nodes);<br>
<br>
+unsigned long shrink_mem_cgroup(struct mem_cgroup *mem);<br>
+<br>
=A0static inline<br>
=A0int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup =
*cgroup)<br>
=A0{<br>
@@ -112,6 +114,9 @@ extern void mem_cgroup_end_migration(str<br>
 =A0*/<br>
=A0int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);<br>
=A0int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);<br>
+unsigned int mem_cgroup_swappiness(struct mem_cgroup *memcg);<br>
+unsigned long mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg,<=
br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int nid, int =
zone_idx);<br>
=A0unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct zone *zone,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 enum lru_list lru);<br>
@@ -310,6 +315,12 @@ mem_cgroup_inactive_file_is_low(struct m<br>
=A0}<br>
<br>
=A0static inline unsigned long<br>
+mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg, int nid, int z=
one_idx)<br>
+{<br>
+ =A0 =A0 =A0 return 0;<br>
+}<br>
+<br>
+static inline unsigned long<br>
=A0mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg, struct zone *zone,<br=
>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum lru_list lru)<br>
=A0{<br>
Index: memcg/mm/memcontrol.c<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- memcg.orig/mm/memcontrol.c<br>
+++ memcg/mm/memcontrol.c<br>
@@ -1166,6 +1166,23 @@ int mem_cgroup_inactive_file_is_low(stru<br>
 =A0 =A0 =A0 =A0return (active &gt; inactive);<br>
=A0}<br>
<br>
+unsigned long mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg,<=
br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 int nid, int zone_idx)<br>
+{<br>
+ =A0 =A0 =A0 int nr;<br>
+ =A0 =A0 =A0 struct mem_cgroup_per_zone *mz =3D<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_zoneinfo(memcg, nid, zone_idx);<br=
>
+<br>
+ =A0 =A0 =A0 nr =3D MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_FILE) +<br>
+ =A0 =A0 =A0 =A0 =A0 =A0MEM_CGROUP_ZSTAT(mz, NR_INACTIVE_FILE);<br>
+<br>
+ =A0 =A0 =A0 if (nr_swap_pages &gt; 0)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr +=3D MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_ANON) =
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MEM_CGROUP_ZSTAT(mz, NR_INACTIVE_=
ANON);<br>
+<br>
+ =A0 =A0 =A0 return nr;<br>
+}<br>
+<br>
=A0unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct zone *zone,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 enum lru_list lru)<br>
@@ -1286,7 +1303,7 @@ static unsigned long mem_cgroup_margin(s<br>
 =A0 =A0 =A0 =A0return margin &gt;&gt; PAGE_SHIFT;<br>
=A0}<br>
<br>
-static unsigned int get_swappiness(struct mem_cgroup *memcg)<br>
+unsigned int mem_cgroup_swappiness(struct mem_cgroup *memcg)<br>
=A0{<br>
 =A0 =A0 =A0 =A0struct cgroup *cgrp =3D memcg-&gt;css.cgroup;<br>
<br>
@@ -1595,14 +1612,15 @@ static int mem_cgroup_hierarchical_recla<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* we use swappiness of local cgroup */<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (check_soft) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D mem_cgroup_shrink_n=
ode_zone(victim, gfp_mask,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 noswap, get_s=
wappiness(victim), zone,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 noswap, mem_c=
group_swappiness(victim), zone,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&amp;nr_sca=
nned);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*total_scanned +=3D nr_scan=
ned;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_soft_steal(victi=
m, ret);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_soft_scan(victim=
, nr_scanned);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D try_to_free_mem_cgr=
oup_pages(victim, gfp_mask,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 noswap, get_swappiness(victim));<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 noswap,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 mem_cgroup_swappiness(victim));<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0css_put(&amp;victim-&gt;css);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * At shrinking usage, we can&#39;t check w=
e should stop here or<br>
@@ -1628,15 +1646,25 @@ static int mem_cgroup_hierarchical_recla<br>
=A0int<br>
=A0mem_cgroup_select_victim_node(struct mem_cgroup *mem, const nodemask_t *=
nodes)<br>
=A0{<br>
- =A0 =A0 =A0 int next_nid;<br>
+ =A0 =A0 =A0 int next_nid, i;<br>
 =A0 =A0 =A0 =A0int last_scanned;<br>
<br>
 =A0 =A0 =A0 =A0last_scanned =3D mem-&gt;last_scanned_node;<br>
- =A0 =A0 =A0 next_nid =3D next_node(last_scanned, *nodes);<br>
+ =A0 =A0 =A0 next_nid =3D last_scanned;<br>
+rescan:<br>
+ =A0 =A0 =A0 next_nid =3D next_node(next_nid, *nodes);<br>
<br>
 =A0 =A0 =A0 =A0if (next_nid =3D=3D MAX_NUMNODES)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0next_nid =3D first_node(*nodes);<br>
<br>
+ =A0 =A0 =A0 /* If no page on this node, skip */<br>
+ =A0 =A0 =A0 for (i =3D 0; i &lt; MAX_NR_ZONES; i++)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_zone_reclaimable_pages(mem, ne=
xt_nid, i))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
+<br>
+ =A0 =A0 =A0 if (next_nid !=3D last_scanned &amp;&amp; (i =3D=3D MAX_NR_ZO=
NES))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto rescan;<br>
+<br>
 =A0 =A0 =A0 =A0mem-&gt;last_scanned_node =3D next_nid;<br>
<br>
 =A0 =A0 =A0 =A0return next_nid;<br>
@@ -3649,7 +3677,7 @@ try_to_free:<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0progress =3D try_to_free_mem_cgroup_pages(m=
em, GFP_KERNEL,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 false, get_swappiness(mem));<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 false, mem_cgroup_swappiness(mem));<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!progress) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_retries--;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* maybe some writeback is =
necessary */<br>
@@ -4073,7 +4101,7 @@ static u64 mem_cgroup_swappiness_read(st<br>
=A0{<br>
 =A0 =A0 =A0 =A0struct mem_cgroup *memcg =3D mem_cgroup_from_cont(cgrp);<br=
>
<br>
- =A0 =A0 =A0 return get_swappiness(memcg);<br>
+ =A0 =A0 =A0 return mem_cgroup_swappiness(memcg);<br>
=A0}<br>
<br>
=A0static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftyp=
e *cft,<br>
@@ -4849,7 +4877,7 @@ mem_cgroup_create(struct cgroup_subsys *<br>
 =A0 =A0 =A0 =A0INIT_LIST_HEAD(&amp;mem-&gt;oom_notify);<br>
<br>
 =A0 =A0 =A0 =A0if (parent)<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem-&gt;swappiness =3D get_swappiness(parent)=
;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem-&gt;swappiness =3D mem_cgroup_swappiness(=
parent);<br>
 =A0 =A0 =A0 =A0atomic_set(&amp;mem-&gt;refcnt, 1);<br>
 =A0 =A0 =A0 =A0mem-&gt;move_charge_at_immigrate =3D 0;<br>
 =A0 =A0 =A0 =A0mutex_init(&amp;mem-&gt;thresholds_lock);<br>
Index: memcg/mm/vmscan.c<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- memcg.orig/mm/vmscan.c<br>
+++ memcg/mm/vmscan.c<br>
@@ -42,6 +42,7 @@<br>
=A0#include &lt;linux/delayacct.h&gt;<br>
=A0#include &lt;linux/sysctl.h&gt;<br>
=A0#include &lt;linux/oom.h&gt;<br>
+#include &lt;linux/res_counter.h&gt;<br>
<br>
=A0#include &lt;asm/tlbflush.h&gt;<br>
=A0#include &lt;asm/div64.h&gt;<br>
@@ -2308,6 +2309,120 @@ static bool sleeping_prematurely(pg_data<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return !all_zones_ok;<br>
=A0}<br>
<br>
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR<br>
+/*<br>
+ * The function is used for per-memcg LRU. It scanns all the zones of the<=
br>
+ * node and returns the nr_scanned and nr_reclaimed.<br>
+ */<br>
+/*<br>
+ * Limit of scanning per iteration. For round-robin.<br>
+ */<br>
+#define MEMCG_BGSCAN_LIMIT =A0 =A0 (2048)<br>
+<br>
+static void<br>
+shrink_memcg_node(int nid, int priority, struct scan_control *sc)<br>
+{<br>
+ =A0 =A0 =A0 unsigned long total_scanned =3D 0;<br>
+ =A0 =A0 =A0 struct mem_cgroup *mem_cont =3D sc-&gt;mem_cgroup;<br>
+ =A0 =A0 =A0 int i;<br>
+<br>
+ =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0* This dma-&gt;highmem order is consistant with global rec=
laim.<br>
+ =A0 =A0 =A0 =A0* We do this because the page allocator works in the oppos=
ite<br>
+ =A0 =A0 =A0 =A0* direction although memcg user pages are mostly allocated=
 at<br>
+ =A0 =A0 =A0 =A0* highmem.<br>
+ =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 for (i =3D 0;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0(i &lt; NODE_DATA(nid)-&gt;nr_zones) &amp;&amp;<br=
>
+ =A0 =A0 =A0 =A0 =A0 =A0(total_scanned &lt; MEMCG_BGSCAN_LIMIT);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0i++) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone =3D NODE_DATA(nid)-&gt;node=
_zones + i;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zone_reclaim_stat *zrs;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long scan, rotate;<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!populated_zone(zone))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 scan =3D mem_cgroup_zone_reclaimable_pages(me=
m_cont, nid, i);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!scan)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* If recent memory reclaim on this zone does=
n&#39;t get good */<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 zrs =3D get_reclaim_stat(zone, sc);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 scan =3D zrs-&gt;recent_scanned[0] + zrs-&gt;=
recent_scanned[1];<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 rotate =3D zrs-&gt;recent_rotated[0] + zrs-&g=
t;recent_rotated[1];<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (rotate &gt; scan/2)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;may_writepage =3D 1;<b=
r>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;nr_scanned =3D 0;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_zone(priority, zone, sc);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned +=3D sc-&gt;nr_scanned;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;may_writepage =3D 0;<br>
+ =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 sc-&gt;nr_scanned =3D total_scanned;<br>
+}<br>
+<br>
+/*<br>
+ * Per cgroup background reclaim.<br>
+ */<br>
+unsigned long shrink_mem_cgroup(struct mem_cgroup *mem)<br>
+{<br>
+ =A0 =A0 =A0 int nid, priority, next_prio;<br>
+ =A0 =A0 =A0 nodemask_t nodes;<br>
+ =A0 =A0 =A0 unsigned long total_scanned;<br>
+ =A0 =A0 =A0 struct scan_control sc =3D {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .gfp_mask =3D GFP_HIGHUSER_MOVABLE,<br></bloc=
kquote><div><br></div><div>I noticed this is changed from GFP_KERNEL from p=
revious patch, and also seems memcg reclaim uses this flag as well on other=
 reclaim path. So it should be a ok change.</div>
<div><br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex=
;border-left:1px #ccc solid;padding-left:1ex;">
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .may_unmap =3D 1,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .may_swap =3D 1,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .nr_to_reclaim =3D SWAP_CLUSTER_MAX,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .order =3D 0,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mem_cgroup =3D mem,<br>
+ =A0 =A0 =A0 };<br>
+<br>
+ =A0 =A0 =A0 sc.may_writepage =3D 0;<br>
+ =A0 =A0 =A0 sc.nr_reclaimed =3D 0;<br>
+ =A0 =A0 =A0 total_scanned =3D 0;<br>
+ =A0 =A0 =A0 nodes =3D node_states[N_HIGH_MEMORY];<br>
+ =A0 =A0 =A0 sc.swappiness =3D mem_cgroup_swappiness(mem);<br>
+<br>
+ =A0 =A0 =A0 current-&gt;flags |=3D PF_SWAPWRITE;<br></blockquote><div>why=
 we set the flags here instead of in the main kswapd function=A0<span class=
=3D"Apple-style-span" style=3D"border-collapse: collapse; font-family: aria=
l, sans-serif; font-size: 13px; ">memcg_bgreclaim() ?</span></div>
<meta http-equiv=3D"content-type" content=3D"text/html; charset=3Dutf-8"><d=
iv><br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;b=
order-left:1px #ccc solid;padding-left:1ex;">
+ =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0* Unlike kswapd, we need to traverse cgroups one by one. S=
o, we don&#39;t<br>
+ =A0 =A0 =A0 =A0* use full priority. Just scan small number of pages and v=
isit next.<br>
+ =A0 =A0 =A0 =A0* Now, we scan MEMCG_BGRECLAIM_SCAN_LIMIT pages per scan.<=
br>
+ =A0 =A0 =A0 =A0* We use static priority 0.<br>
+ =A0 =A0 =A0 =A0*/<br></blockquote><div>this comment here is a bit confusi=
ng since we are doing reclaim for one memcg in this funcion.=A0</div><div><=
br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;borde=
r-left:1px #ccc solid;padding-left:1ex;">

+ =A0 =A0 =A0 next_prio =3D min(SWAP_CLUSTER_MAX * num_node_state(N_HIGH_ME=
MORY),<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MEMCG_BGSCAN_LIMIT/8);<br>
+ =A0 =A0 =A0 priority =3D DEF_PRIORITY;<br>
+ =A0 =A0 =A0 while ((total_scanned &lt; MEMCG_BGSCAN_LIMIT) &amp;&amp;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0!nodes_empty(nodes) &amp;&amp;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0(sc.nr_to_reclaim &gt; sc.nr_reclaimed)) {<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 nid =3D mem_cgroup_select_victim_node(mem, &a=
mp;nodes);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_memcg_node(nid, priority, &amp;sc);<br=
>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* the node seems to have no pages.<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* skip this for a while<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!sc.nr_scanned)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 node_clear(nid, nodes);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned +=3D sc.nr_scanned;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_watermark_ok(mem, CHARGE_WMARK=
_HIGH))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* emulate priority */<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (total_scanned &gt; next_prio) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 priority--;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 next_prio &lt;&lt;=3D 1;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sc.nr_scanned &amp;&amp;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned &gt; sc.nr_reclaimed * =
2)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 congestion_wait(WRITE, HZ/10)=
;<br>
+ =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 current-&gt;flags &amp;=3D ~PF_SWAPWRITE;<br></blockquote><di=
v>=A0</div><div>hmm, the same question above. why we need to set this flag =
each time?=A0</div><div><br></div><div>--Ying</div><div><br></div><blockquo=
te class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc so=
lid;padding-left:1ex;">

+ =A0 =A0 =A0 return sc.nr_reclaimed;<br>
+}<br>
+#endif<br>
+<br>
=A0/*<br>
 =A0* For kswapd, balance_pgdat() will work across all this node&#39;s zone=
s until<br>
 =A0* they are all at high_wmark_pages(zone).<br>
<br>
</blockquote></div><br>

--002354470aa877c14d04a1d69f92--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
