Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4B64C900001
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 00:59:14 -0400 (EDT)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id p3Q4x96c008572
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 21:59:09 -0700
Received: from qwe5 (qwe5.prod.google.com [10.241.194.5])
	by kpbe13.cbf.corp.google.com with ESMTP id p3Q4wSDc022426
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 21:59:07 -0700
Received: by qwe5 with SMTP id 5so143536qwe.23
        for <linux-mm@kvack.org>; Mon, 25 Apr 2011 21:59:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110425183629.144d3f19.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
	<20110425183629.144d3f19.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 25 Apr 2011 21:59:06 -0700
Message-ID: <BANLkTinn5Cs8F5beX6od41xhH4qQuRR5Rw@mail.gmail.com>
Subject: Re: [PATCH 5/7] memcg bgreclaim core.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>

On Mon, Apr 25, 2011 at 2:36 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Following patch will chagnge the logic. This is a core.
> =3D=3D
> This is the main loop of per-memcg background reclaim which is implemente=
d in
> function balance_mem_cgroup_pgdat().
>
> The function performs a priority loop similar to global reclaim. During e=
ach
> iteration it frees memory from a selected victim node.
> After reclaiming enough pages or scanning enough pages, it returns and fi=
nd
> next work with round-robin.
>
> changelog v8b..v7
> 1. reworked for using work_queue rather than threads.
> 2. changed shrink_mem_cgroup algorithm to fit workqueue. In short, avoid
> =A0 long running and allow quick round-robin and unnecessary write page.
> =A0 When a thread make pages dirty continuously, write back them by flush=
er
> =A0 is far faster than writeback by background reclaim. This detail will
> =A0 be fixed when dirty_ratio implemented. The logic around this will be
> =A0 revisited in following patche.
>
> Signed-off-by: Ying Han <yinghan@google.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =A0include/linux/memcontrol.h | =A0 11 ++++
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 44 ++++++++++++++---
> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0115 ++++++++++++++++++=
+++++++++++++++++++++++++++
> =A03 files changed, 162 insertions(+), 8 deletions(-)
>
> Index: memcg/include/linux/memcontrol.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- memcg.orig/include/linux/memcontrol.h
> +++ memcg/include/linux/memcontrol.h
> @@ -89,6 +89,8 @@ extern int mem_cgroup_last_scanned_node(
> =A0extern int mem_cgroup_select_victim_node(struct mem_cgroup *mem,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0const nodemask_t *nodes);
>
> +unsigned long shrink_mem_cgroup(struct mem_cgroup *mem);
> +
> =A0static inline
> =A0int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgrou=
p *cgroup)
> =A0{
> @@ -112,6 +114,9 @@ extern void mem_cgroup_end_migration(str
> =A0*/
> =A0int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
> =A0int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
> +unsigned int mem_cgroup_swappiness(struct mem_cgroup *memcg);
> +unsigned long mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg=
,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int nid, in=
t zone_idx);
> =A0unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct zone *zone,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 enum lru_list lru);
> @@ -310,6 +315,12 @@ mem_cgroup_inactive_file_is_low(struct m
> =A0}
>
> =A0static inline unsigned long
> +mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg, int nid, int=
 zone_idx)
> +{
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static inline unsigned long
> =A0mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg, struct zone *zone,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum lru_list lru)
> =A0{
> Index: memcg/mm/memcontrol.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- memcg.orig/mm/memcontrol.c
> +++ memcg/mm/memcontrol.c
> @@ -1166,6 +1166,23 @@ int mem_cgroup_inactive_file_is_low(stru
> =A0 =A0 =A0 =A0return (active > inactive);
> =A0}
>
> +unsigned long mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg=
,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 int nid, int zone_idx)
> +{
> + =A0 =A0 =A0 int nr;
> + =A0 =A0 =A0 struct mem_cgroup_per_zone *mz =3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_zoneinfo(memcg, nid, zone_idx);
> +
> + =A0 =A0 =A0 nr =3D MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_FILE) +
> + =A0 =A0 =A0 =A0 =A0 =A0MEM_CGROUP_ZSTAT(mz, NR_INACTIVE_FILE);
> +
> + =A0 =A0 =A0 if (nr_swap_pages > 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr +=3D MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_ANON=
) +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MEM_CGROUP_ZSTAT(mz, NR_INACTIV=
E_ANON);
> +
> + =A0 =A0 =A0 return nr;
> +}
> +
> =A0unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct zone *zone,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 enum lru_list lru)
> @@ -1286,7 +1303,7 @@ static unsigned long mem_cgroup_margin(s
> =A0 =A0 =A0 =A0return margin >> PAGE_SHIFT;
> =A0}
>
> -static unsigned int get_swappiness(struct mem_cgroup *memcg)
> +unsigned int mem_cgroup_swappiness(struct mem_cgroup *memcg)
> =A0{
> =A0 =A0 =A0 =A0struct cgroup *cgrp =3D memcg->css.cgroup;
>
> @@ -1595,14 +1612,15 @@ static int mem_cgroup_hierarchical_recla
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* we use swappiness of local cgroup */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (check_soft) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D mem_cgroup_shrink_=
node_zone(victim, gfp_mask,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 noswap, get=
_swappiness(victim), zone,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 noswap, mem=
_cgroup_swappiness(victim), zone,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&nr_scanne=
d);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*total_scanned +=3D nr_sca=
nned;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_soft_steal(vict=
im, ret);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_soft_scan(victi=
m, nr_scanned);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D try_to_free_mem_cg=
roup_pages(victim, gfp_mask,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 noswap, get_swappiness(victim));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 noswap,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 mem_cgroup_swappiness(victim));
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0css_put(&victim->css);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * At shrinking usage, we can't check we s=
hould stop here or
> @@ -1628,15 +1646,25 @@ static int mem_cgroup_hierarchical_recla
> =A0int
> =A0mem_cgroup_select_victim_node(struct mem_cgroup *mem, const nodemask_t=
 *nodes)
> =A0{
> - =A0 =A0 =A0 int next_nid;
> + =A0 =A0 =A0 int next_nid, i;
> =A0 =A0 =A0 =A0int last_scanned;
>
> =A0 =A0 =A0 =A0last_scanned =3D mem->last_scanned_node;
> - =A0 =A0 =A0 next_nid =3D next_node(last_scanned, *nodes);
> + =A0 =A0 =A0 next_nid =3D last_scanned;
> +rescan:
> + =A0 =A0 =A0 next_nid =3D next_node(next_nid, *nodes);
>
> =A0 =A0 =A0 =A0if (next_nid =3D=3D MAX_NUMNODES)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0next_nid =3D first_node(*nodes);
>
> + =A0 =A0 =A0 /* If no page on this node, skip */
> + =A0 =A0 =A0 for (i =3D 0; i < MAX_NR_ZONES; i++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_zone_reclaimable_pages(mem, =
next_nid, i))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +
> + =A0 =A0 =A0 if (next_nid !=3D last_scanned && (i =3D=3D MAX_NR_ZONES))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto rescan;
> +
> =A0 =A0 =A0 =A0mem->last_scanned_node =3D next_nid;
>
> =A0 =A0 =A0 =A0return next_nid;
> @@ -3649,7 +3677,7 @@ try_to_free:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0progress =3D try_to_free_mem_cgroup_pages(=
mem, GFP_KERNEL,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 false, get_swappiness(mem));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 false, mem_cgroup_swappiness(mem));
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!progress) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_retries--;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* maybe some writeback is=
 necessary */
> @@ -4073,7 +4101,7 @@ static u64 mem_cgroup_swappiness_read(st
> =A0{
> =A0 =A0 =A0 =A0struct mem_cgroup *memcg =3D mem_cgroup_from_cont(cgrp);
>
> - =A0 =A0 =A0 return get_swappiness(memcg);
> + =A0 =A0 =A0 return mem_cgroup_swappiness(memcg);
> =A0}
>
> =A0static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cft=
ype *cft,
> @@ -4849,7 +4877,7 @@ mem_cgroup_create(struct cgroup_subsys *
> =A0 =A0 =A0 =A0INIT_LIST_HEAD(&mem->oom_notify);
>
> =A0 =A0 =A0 =A0if (parent)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem->swappiness =3D get_swappiness(parent);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem->swappiness =3D mem_cgroup_swappiness(p=
arent);
> =A0 =A0 =A0 =A0atomic_set(&mem->refcnt, 1);
> =A0 =A0 =A0 =A0mem->move_charge_at_immigrate =3D 0;
> =A0 =A0 =A0 =A0mutex_init(&mem->thresholds_lock);
> Index: memcg/mm/vmscan.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- memcg.orig/mm/vmscan.c
> +++ memcg/mm/vmscan.c
> @@ -42,6 +42,7 @@
> =A0#include <linux/delayacct.h>
> =A0#include <linux/sysctl.h>
> =A0#include <linux/oom.h>
> +#include <linux/res_counter.h>
>
> =A0#include <asm/tlbflush.h>
> =A0#include <asm/div64.h>
> @@ -2308,6 +2309,120 @@ static bool sleeping_prematurely(pg_data
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return !all_zones_ok;
> =A0}
>
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +/*
> + * The function is used for per-memcg LRU. It scanns all the zones of th=
e
> + * node and returns the nr_scanned and nr_reclaimed.
> + */
> +/*
> + * Limit of scanning per iteration. For round-robin.
> + */
> +#define MEMCG_BGSCAN_LIMIT =A0 =A0 (2048)
> +
> +static void
> +shrink_memcg_node(int nid, int priority, struct scan_control *sc)
> +{
> + =A0 =A0 =A0 unsigned long total_scanned =3D 0;
> + =A0 =A0 =A0 struct mem_cgroup *mem_cont =3D sc->mem_cgroup;
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* This dma->highmem order is consistant with global recl=
aim.
> + =A0 =A0 =A0 =A0* We do this because the page allocator works in the opp=
osite
> + =A0 =A0 =A0 =A0* direction although memcg user pages are mostly allocat=
ed at
> + =A0 =A0 =A0 =A0* highmem.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 for (i =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0(i < NODE_DATA(nid)->nr_zones) &&
> + =A0 =A0 =A0 =A0 =A0 =A0(total_scanned < MEMCG_BGSCAN_LIMIT);
> + =A0 =A0 =A0 =A0 =A0 =A0i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone =3D NODE_DATA(nid)->node_=
zones + i;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zone_reclaim_stat *zrs;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long scan, rotate;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!populated_zone(zone))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 scan =3D mem_cgroup_zone_reclaimable_pages(=
mem_cont, nid, i);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!scan)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* If recent memory reclaim on this zone do=
esn't get good */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 zrs =3D get_reclaim_stat(zone, sc);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 scan =3D zrs->recent_scanned[0] + zrs->rece=
nt_scanned[1];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rotate =3D zrs->recent_rotated[0] + zrs->re=
cent_rotated[1];
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (rotate > scan/2)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->may_writepage =3D 1;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->nr_scanned =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_zone(priority, zone, sc);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned +=3D sc->nr_scanned;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->may_writepage =3D 0;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 sc->nr_scanned =3D total_scanned;
> +}

I see the MEMCG_BGSCAN_LIMIT is a newly defined macro from previous
post. So, now the number of pages to scan is capped on 2k for each
memcg, and does it make difference on big vs small cgroup?

--Ying

> +/*
> + * Per cgroup background reclaim.
> + */
> +unsigned long shrink_mem_cgroup(struct mem_cgroup *mem)
> +{
> + =A0 =A0 =A0 int nid, priority, next_prio;
> + =A0 =A0 =A0 nodemask_t nodes;
> + =A0 =A0 =A0 unsigned long total_scanned;
> + =A0 =A0 =A0 struct scan_control sc =3D {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .gfp_mask =3D GFP_HIGHUSER_MOVABLE,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .may_unmap =3D 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .may_swap =3D 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .nr_to_reclaim =3D SWAP_CLUSTER_MAX,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .order =3D 0,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mem_cgroup =3D mem,
> + =A0 =A0 =A0 };
> +
> + =A0 =A0 =A0 sc.may_writepage =3D 0;
> + =A0 =A0 =A0 sc.nr_reclaimed =3D 0;
> + =A0 =A0 =A0 total_scanned =3D 0;
> + =A0 =A0 =A0 nodes =3D node_states[N_HIGH_MEMORY];
> + =A0 =A0 =A0 sc.swappiness =3D mem_cgroup_swappiness(mem);
> +
> + =A0 =A0 =A0 current->flags |=3D PF_SWAPWRITE;
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Unlike kswapd, we need to traverse cgroups one by one.=
 So, we don't
> + =A0 =A0 =A0 =A0* use full priority. Just scan small number of pages and=
 visit next.
> + =A0 =A0 =A0 =A0* Now, we scan MEMCG_BGRECLAIM_SCAN_LIMIT pages per scan=
.
> + =A0 =A0 =A0 =A0* We use static priority 0.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 next_prio =3D min(SWAP_CLUSTER_MAX * num_node_state(N_HIGH_=
MEMORY),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MEMCG_BGSCAN_LIMIT/8);
> + =A0 =A0 =A0 priority =3D DEF_PRIORITY;
> + =A0 =A0 =A0 while ((total_scanned < MEMCG_BGSCAN_LIMIT) &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0!nodes_empty(nodes) &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0(sc.nr_to_reclaim > sc.nr_reclaimed)) {
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nid =3D mem_cgroup_select_victim_node(mem, =
&nodes);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_memcg_node(nid, priority, &sc);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* the node seems to have no pages.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* skip this for a while
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!sc.nr_scanned)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 node_clear(nid, nodes);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned +=3D sc.nr_scanned;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_watermark_ok(mem, CHARGE_WMA=
RK_HIGH))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* emulate priority */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (total_scanned > next_prio) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 priority--;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 next_prio <<=3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sc.nr_scanned &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned > sc.nr_reclaimed * 2=
)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 congestion_wait(WRITE, HZ/1=
0);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 current->flags &=3D ~PF_SWAPWRITE;
> + =A0 =A0 =A0 return sc.nr_reclaimed;
> +}
> +#endif
> +
> =A0/*
> =A0* For kswapd, balance_pgdat() will work across all this node's zones u=
ntil
> =A0* they are all at high_wmark_pages(zone).
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
