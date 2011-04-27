Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 93DCC9000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 23:52:53 -0400 (EDT)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id p3R3qfZo018542
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 20:52:41 -0700
Received: from gya6 (gya6.prod.google.com [10.243.49.6])
	by kpbe12.cbf.corp.google.com with ESMTP id p3R3qdwQ026256
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 20:52:40 -0700
Received: by gya6 with SMTP id 6so652146gya.7
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 20:52:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110427115718.ab6c55ae.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110427115718.ab6c55ae.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 26 Apr 2011 20:52:39 -0700
Message-ID: <BANLkTikTONt-shfi3cVudkbVhqpsP=HQvg@mail.gmail.com>
Subject: Re: [PATCH] memcg: reclaim memory from nodes in round robin
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishmura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>

On Tue, Apr 26, 2011 at 7:57 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Now, memory cgroup's direct reclaim frees memory from the current node.
> But this has some troubles. In usual, when a set of threads works in
> cooperative way, they are tend to on the same node. So, if they hit
> limits under memcg, it will reclaim memory from themselves, it may be
> active working set.
>
> For example, assume 2 node system which has Node 0 and Node 1
> and a memcg which has 1G limit. After some work, file cacne remains and
> and usages are
> =A0 Node 0: =A01M
> =A0 Node 1: =A0998M.
>
> and run an application on Node 0, it will eats its foot before freeing
> unnecessary file caches.
>
> This patch adds round-robin for NUMA and adds equal pressure to each
> node. When using cpuset's spread memory feature, this will work very well=
.
>
> But yes, better algorithm is appreciated.
>
> From: Ying Han <yinghan@google.com>
> Signed-off-by: Ying Han <yinghan@google.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =A0include/linux/memcontrol.h | =A0 =A01 +
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 25 ++++++++++++++++++++++=
+++
> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A09 ++++++++-
> =A03 files changed, 34 insertions(+), 1 deletion(-)
>
> Index: memcg/include/linux/memcontrol.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- memcg.orig/include/linux/memcontrol.h
> +++ memcg/include/linux/memcontrol.h
> @@ -108,6 +108,7 @@ extern void mem_cgroup_end_migration(str
> =A0*/
> =A0int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
> =A0int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
> +int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
> =A0unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct zone *zone,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 enum lru_list lru);
> Index: memcg/mm/memcontrol.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- memcg.orig/mm/memcontrol.c
> +++ memcg/mm/memcontrol.c
> @@ -237,6 +237,7 @@ struct mem_cgroup {
> =A0 =A0 =A0 =A0 * reclaimed from.
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0int last_scanned_child;
> + =A0 =A0 =A0 int last_scanned_node;
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Should the accounting and control be hierarchical, per =
subtree?
> =A0 =A0 =A0 =A0 */
> @@ -1472,6 +1473,29 @@ mem_cgroup_select_victim(struct mem_cgro
> =A0}
>
> =A0/*
> + * Selecting a node where we start reclaim from. Because what we need is=
 just
> + * reducing usage counter, start from anywhere is O,K. When considering
> + * memory reclaim from current node, there are pros. and cons.
> + * Freeing memory from current node means freeing memory from a node whi=
ch
> + * we'll use or we've used. So, it may make LRU bad. And if several thre=
ads
> + * hit limits, it will see a contention on a node. But freeing from remo=
te
> + * node mean more costs for memory reclaim because of memory latency.
> + *
> + * Now, we use round-robin. Better algorithm is welcomed.
> + */
> +int mem_cgroup_select_victim_node(struct mem_cgroup *mem)
> +{
> + =A0 =A0 =A0 int node;
> +
> + =A0 =A0 =A0 node =3D next_node(mem->last_scanned_node, node_states[N_HI=
GH_MEMORY]);
> + =A0 =A0 =A0 if (node =3D=3D MAX_NUMNODES)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 node =3D first_node(node_states[N_HIGH_MEMO=
RY]);
> +
> + =A0 =A0 =A0 mem->last_scanned_node =3D node;
> + =A0 =A0 =A0 return node;
> +}
> +
> +/*
> =A0* Scan the hierarchy if needed to reclaim memory. We remember the last=
 child
> =A0* we reclaimed from, so that we don't end up penalizing one child exte=
nsively
> =A0* based on its position in the children list.
> @@ -4678,6 +4702,7 @@ mem_cgroup_create(struct cgroup_subsys *
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0res_counter_init(&mem->memsw, NULL);
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0mem->last_scanned_child =3D 0;
> + =A0 =A0 =A0 mem->last_scanned_node =3D MAX_NUMNODES;
> =A0 =A0 =A0 =A0INIT_LIST_HEAD(&mem->oom_notify);
>
> =A0 =A0 =A0 =A0if (parent)
> Index: memcg/mm/vmscan.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- memcg.orig/mm/vmscan.c
> +++ memcg/mm/vmscan.c
> @@ -2198,6 +2198,7 @@ unsigned long try_to_free_mem_cgroup_pag
> =A0{
> =A0 =A0 =A0 =A0struct zonelist *zonelist;
> =A0 =A0 =A0 =A0unsigned long nr_reclaimed;
> + =A0 =A0 =A0 int nid;
> =A0 =A0 =A0 =A0struct scan_control sc =3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.may_writepage =3D !laptop_mode,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.may_unmap =3D 1,
> @@ -2208,10 +2209,16 @@ unsigned long try_to_free_mem_cgroup_pag
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.mem_cgroup =3D mem_cont,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.nodemask =3D NULL, /* we don't care the p=
lacement */
> =A0 =A0 =A0 =A0};
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Unlike direct reclaim via allo_pages(), memcg's reclai=
m
> + =A0 =A0 =A0 =A0* don't take care from where we get free resouce. So, th=
e node where
> + =A0 =A0 =A0 =A0* we need to start scan is not need to be current node.
> + =A0 =A0 =A0 =A0*/
Sorry, some typos. alloc_pages() instead of alloc_pages(). And "free resour=
ce".

--Ying
> + =A0 =A0 =A0 nid =3D mem_cgroup_select_victim_node(mem_cont);
>
> =A0 =A0 =A0 =A0sc.gfp_mask =3D (gfp_mask & GFP_RECLAIM_MASK) |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(GFP_HIGHUSER_MOVABLE & ~G=
FP_RECLAIM_MASK);
> - =A0 =A0 =A0 zonelist =3D NODE_DATA(numa_node_id())->node_zonelists;
> + =A0 =A0 =A0 zonelist =3D NODE_DATA(nid)->node_zonelists;
>
> =A0 =A0 =A0 =A0trace_mm_vmscan_memcg_reclaim_begin(0,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0sc.may_writepage,
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
