Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E00666B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 13:26:32 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p4NHQQDx020478
	for <linux-mm@kvack.org>; Mon, 23 May 2011 10:26:28 -0700
Received: from qwj8 (qwj8.prod.google.com [10.241.195.72])
	by wpaz29.hot.corp.google.com with ESMTP id p4NHPGrH013452
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 23 May 2011 10:26:24 -0700
Received: by qwj8 with SMTP id 8so3809218qwj.32
        for <linux-mm@kvack.org>; Mon, 23 May 2011 10:26:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110520124312.5928aa92.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110520123749.d54b32fa.kamezawa.hiroyu@jp.fujitsu.com>
	<20110520124312.5928aa92.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 23 May 2011 10:26:22 -0700
Message-ID: <BANLkTi=7-xgUetav9s5fvZ8e+U986Y4Z7w@mail.gmail.com>
Subject: Re: [PATCH 0/8] memcg: clean up, export swapiness
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, hannes@cmpxchg.org, Michal Hocko <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

Hi Kame:

Is this patch part of the "memcg async reclaim v2" patchset? I am
trying to do some tests on top of that, but having hard time finding
the [PATCH 3/8] and [PATCH 5/8].

--Ying

On Thu, May 19, 2011 at 8:43 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> From: Ying Han <yinghan@google.com>
> change mem_cgroup's swappiness interface.
>
> Now, memcg's swappiness interface is defined as 'static' and
> the value is passed as an argument to try_to_free_xxxx...
>
> This patch adds an function mem_cgroup_swappiness() and export it,
> reduce arguments. This interface will be used in async reclaim, later.
>
> I think an function is better than passing arguments because it's
> clearer where the swappiness comes from to scan_control.
>
> Signed-off-by: Ying Han <yinghan@google.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =A0include/linux/memcontrol.h | =A0 =A01 +
> =A0include/linux/swap.h =A0 =A0 =A0 | =A0 =A04 +---
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 14 ++++++--------
> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A09 ++++-----
> =A04 files changed, 12 insertions(+), 16 deletions(-)
>
> Index: mmotm-May11/include/linux/memcontrol.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-May11.orig/include/linux/memcontrol.h
> +++ mmotm-May11/include/linux/memcontrol.h
> @@ -112,6 +112,7 @@ unsigned long
> =A0mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg, int nid, i=
nt zid);
> =A0bool mem_cgroup_test_reclaimable(struct mem_cgroup *memcg);
> =A0int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
> +unsigned int mem_cgroup_swappiness(struct mem_cgroup *memcg);
> =A0unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct zone *zone,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 enum lru_list lru);
> Index: mmotm-May11/mm/memcontrol.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-May11.orig/mm/memcontrol.c
> +++ mmotm-May11/mm/memcontrol.c
> @@ -1285,7 +1285,7 @@ static unsigned long mem_cgroup_margin(s
> =A0 =A0 =A0 =A0return margin >> PAGE_SHIFT;
> =A0}
>
> -static unsigned int get_swappiness(struct mem_cgroup *memcg)
> +unsigned int mem_cgroup_swappiness(struct mem_cgroup *memcg)
> =A0{
> =A0 =A0 =A0 =A0struct cgroup *cgrp =3D memcg->css.cgroup;
>
> @@ -1687,14 +1687,13 @@ static int mem_cgroup_hierarchical_recla
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* we use swappiness of local cgroup */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (check_soft) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D mem_cgroup_shrink_=
node_zone(victim, gfp_mask,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 noswap, get=
_swappiness(victim), zone,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &nr_scanned=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 noswap, zon=
e, &nr_scanned);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*total_scanned +=3D nr_sca=
nned;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_soft_steal(vict=
im, is_kswapd, ret);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_soft_scan(victi=
m, is_kswapd, nr_scanned);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D try_to_free_mem_cg=
roup_pages(victim, gfp_mask,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 noswap, get_swappiness(victim));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 noswap);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0css_put(&victim->css);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * At shrinking usage, we can't check we s=
hould stop here or
> @@ -3717,8 +3716,7 @@ try_to_free:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D -EINTR;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 progress =3D try_to_free_mem_cgroup_pages(m=
em, GFP_KERNEL,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 false, get_swappiness(mem));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 progress =3D try_to_free_mem_cgroup_pages(m=
em, GFP_KERNEL, false);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!progress) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_retries--;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* maybe some writeback is=
 necessary */
> @@ -4150,7 +4148,7 @@ static u64 mem_cgroup_swappiness_read(st
> =A0{
> =A0 =A0 =A0 =A0struct mem_cgroup *memcg =3D mem_cgroup_from_cont(cgrp);
>
> - =A0 =A0 =A0 return get_swappiness(memcg);
> + =A0 =A0 =A0 return mem_cgroup_swappiness(memcg);
> =A0}
>
> =A0static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cft=
ype *cft,
> @@ -4836,7 +4834,7 @@ mem_cgroup_create(struct cgroup_subsys *
> =A0 =A0 =A0 =A0INIT_LIST_HEAD(&mem->oom_notify);
>
> =A0 =A0 =A0 =A0if (parent)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem->swappiness =3D get_swappiness(parent);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem->swappiness =3D mem_cgroup_swappiness(p=
arent);
> =A0 =A0 =A0 =A0atomic_set(&mem->refcnt, 1);
> =A0 =A0 =A0 =A0mem->move_charge_at_immigrate =3D 0;
> =A0 =A0 =A0 =A0mutex_init(&mem->thresholds_lock);
> Index: mmotm-May11/include/linux/swap.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-May11.orig/include/linux/swap.h
> +++ mmotm-May11/include/linux/swap.h
> @@ -252,11 +252,9 @@ static inline void lru_cache_add_file(st
> =A0extern unsigned long try_to_free_pages(struct zonelist *zonelist, int =
order,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0gfp_t gfp_mask, nodemask_t *mask);
> =A0extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *m=
em,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask, bool noswap,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 unsigned int swappiness);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask, bool noswap);
> =A0extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *me=
m,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0gfp_t gfp_mask, bool noswap,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 unsigned int swappiness,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0struct zone *zone,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0unsigned long *nr_scanned);
> =A0extern int __isolate_lru_page(struct page *page, int mode, int file);
> Index: mmotm-May11/mm/vmscan.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-May11.orig/mm/vmscan.c
> +++ mmotm-May11/mm/vmscan.c
> @@ -2178,7 +2178,6 @@ unsigned long try_to_free_pages(struct z
>
> =A0unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0gfp_t gfp_mask, bool noswap,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 unsigned int swappiness,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0struct zone *zone,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0unsigned long *nr_scanned)
> =A0{
> @@ -2188,7 +2187,6 @@ unsigned long mem_cgroup_shrink_node_zon
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.may_writepage =3D !laptop_mode,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.may_unmap =3D 1,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.may_swap =3D !noswap,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .swappiness =3D swappiness,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.order =3D 0,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.mem_cgroup =3D mem,
> =A0 =A0 =A0 =A0};
> @@ -2196,6 +2194,8 @@ unsigned long mem_cgroup_shrink_node_zon
> =A0 =A0 =A0 =A0sc.gfp_mask =3D (gfp_mask & GFP_RECLAIM_MASK) |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(GFP_HIGHUSER_MOVABLE & ~G=
FP_RECLAIM_MASK);
>
> + =A0 =A0 =A0 sc.swappiness =3D mem_cgroup_swappiness(mem);
> +
> =A0 =A0 =A0 =A0trace_mm_vmscan_memcg_softlimit_reclaim_begin(0,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc.may_writepage,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc.gfp_mask);
> @@ -2217,8 +2217,7 @@ unsigned long mem_cgroup_shrink_node_zon
>
> =A0unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont=
,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 gfp_t gfp_mask,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0bool noswap,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0unsigned int swappiness)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0bool noswap)
> =A0{
> =A0 =A0 =A0 =A0struct zonelist *zonelist;
> =A0 =A0 =A0 =A0unsigned long nr_reclaimed;
> @@ -2228,7 +2227,6 @@ unsigned long try_to_free_mem_cgroup_pag
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.may_unmap =3D 1,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.may_swap =3D !noswap,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.nr_to_reclaim =3D SWAP_CLUSTER_MAX,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .swappiness =3D swappiness,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.order =3D 0,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.mem_cgroup =3D mem_cont,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.nodemask =3D NULL, /* we don't care the p=
lacement */
> @@ -2245,6 +2243,7 @@ unsigned long try_to_free_mem_cgroup_pag
> =A0 =A0 =A0 =A0 * scan does not need to be the current node.
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0nid =3D mem_cgroup_select_victim_node(mem_cont);
> + =A0 =A0 =A0 sc.swappiness =3D mem_cgroup_swappiness(mem_cont);
>
> =A0 =A0 =A0 =A0zonelist =3D NODE_DATA(nid)->node_zonelists;
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
