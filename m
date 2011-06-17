Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id ACDE06B0012
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 18:04:26 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p5HM4MwP027059
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 15:04:22 -0700
Received: from qyk7 (qyk7.prod.google.com [10.241.83.135])
	by hpaq2.eem.corp.google.com with ESMTP id p5HM41v7009946
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 15:04:21 -0700
Received: by qyk7 with SMTP id 7so1459142qyk.1
        for <linux-mm@kvack.org>; Fri, 17 Jun 2011 15:04:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110616125314.4f78b1e0.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110616124730.d6960b8b.kamezawa.hiroyu@jp.fujitsu.com>
	<20110616125314.4f78b1e0.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 17 Jun 2011 15:04:18 -0700
Message-ID: <BANLkTimYEr9k3Sk5JoaRrrQH4mGoTmL1Wf5gadYVGDuNpxofHw@mail.gmail.com>
Subject: Re: [PATCH 3/7] memcg: add memory.scan_stat
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Andrew Bresticker <abrestic@google.com>

On Wed, Jun 15, 2011 at 8:53 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> From e08990dd9ada13cf236bec1ef44b207436434b8e Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Wed, 15 Jun 2011 14:11:01 +0900
> Subject: [PATCH 3/7] memcg: add memory.scan_stat
>
> commit log of commit 0ae5e89 " memcg: count the soft_limit reclaim in..."
> says it adds scanning stats to memory.stat file. But it doesn't because
> we considered we needed to make a concensus for such new APIs.
>
> This patch is a trial to add memory.scan_stat. This shows
> =A0- the number of scanned pages
> =A0- the number of recleimed pages
> =A0- the number of elaplsed time (including sleep/pause time)
> =A0for both of direct/soft reclaim and shrinking caused by changing limit
> =A0or force_empty.
>
> The biggest difference with oringinal Ying's one is that this file
> can be reset by some write, as
>
> =A0# echo 0 ...../memory.scan_stat
>
> [kamezawa@bluextal ~]$ cat /cgroup/memory/A/memory.scan_stat
> scanned_pages_by_limit 358470
> freed_pages_by_limit 180795
> elapsed_ns_by_limit 21629927
> scanned_pages_by_system 0
> freed_pages_by_system 0
> elapsed_ns_by_system 0
> scanned_pages_by_shrink 76646
> freed_pages_by_shrink 38355
> elappsed_ns_by_shrink 31990670
> total_scanned_pages_by_limit 358470
> total_freed_pages_by_limit 180795
> total_elapsed_ns_by_hierarchical 216299275
> total_scanned_pages_by_system 0
> total_freed_pages_by_system 0
> total_elapsed_ns_by_system 0
> total_scanned_pages_by_shrink 76646
> total_freed_pages_by_shrink 38355
> total_elapsed_ns_by_shrink 31990670
>
> total_xxxx is for hierarchy management.
>
> This will be useful for further memcg developments and need to be
> developped before we do some complicated rework on LRU/softlimit
> management.

Agreed. Actually we are also looking into adding a per-memcg API for
adding visibility of
page reclaim path. It would be helpful for us to settle w/ the API first.

I am not a fan of names, but how about
"/dev/cgroup/memory/memory.reclaim_stat" ?

>
> Now, scan/free/elapsed_by_system is incomplete but future works of
> Johannes at el. will fill remaining information and then, we can
> look into problems of isolation between memcgs.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =A0Documentation/cgroups/memory.txt | =A0 33 +++++++++
> =A0include/linux/memcontrol.h =A0 =A0 =A0 | =A0 16 ++++
> =A0include/linux/swap.h =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A06 -
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0135 ++++++++++=
+++++++++++++++++++++++++++--
> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 27 ++++++=
-
> =A05 files changed, 199 insertions(+), 18 deletions(-)
>
> Index: mmotm-0615/Documentation/cgroups/memory.txt
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-0615.orig/Documentation/cgroups/memory.txt
> +++ mmotm-0615/Documentation/cgroups/memory.txt
> @@ -380,7 +380,7 @@ will be charged as a new owner of it.
>
> =A05.2 stat file
>
> -memory.stat file includes following statistics
> +5.2.1 memory.stat file includes following statistics
>
> =A0# per-memory cgroup local status
> =A0cache =A0 =A0 =A0 =A0 =A0- # of bytes of page cache memory.
> @@ -438,6 +438,37 @@ Note:
> =A0 =A0 =A0 =A0 file_mapped is accounted only when the memory cgroup is o=
wner of page
> =A0 =A0 =A0 =A0 cache.)
>
> +5.2.2 memory.scan_stat
> +
> +memory.scan_stat includes statistics information for memory scanning and
> +freeing, reclaiming. The statistics shows memory scanning information si=
nce
> +memory cgroup creation and can be reset to 0 by writing 0 as
> +
> + #echo 0 > ../memory.scan_stat
> +
> +This file contains following statistics.
> +
> +scanned_pages_by_limit - # of scanned pages at hitting limit.
> +freed_pages_by_limit =A0 - # of freed pages at hitting limit.

How those stats different from Johannes's patch? I feel we should keep
them into this API instead of memory.stat
"pgscan_direct_limit"
"pgreclaim_direct_limit"

> +elapsed_ns_by_limit =A0 =A0- nano sec of elappsed time at LRU scan at
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hitt=
ing limit.(this includes sleep time.)


> +
> +scanned_pages_by_system =A0 =A0 =A0 =A0- # of scanned pages by the kerne=
l.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (Now, this value means =
global memory reclaim
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 caused by system me=
mory shortage with a hint
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0of softlimit. "No so=
ft limit" case will be
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0supported in future.=
)
> +freed_pages_by_system =A0- # of freed pages by the kernel.

The same for the following which I assume the same meaning with:
"pgscan_direct_hierarchy"
"pgreclaim_direct_hierarchy"

> +elapsed_ns_by_system =A0 - nano sec of elappsed time by kernel.
> +
> +scanned_pages_by_shrink =A0 =A0 =A0 =A0- # of scanned pages by shrinking=
.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (i.e. c=
hanges of limit, force_empty, etc.)
> +freed_pages_by_shrink =A0- # of freed pages by shirkining.

So those stats are not included in the ones above?

--Ying

> +elappsed_ns_by_shrink =A0- nano sec of elappsed time at shrinking.
> +
> +total_xxx includes the statistics of children scanning caused by the cgr=
oup.
> +
> +
> =A05.3 swappiness
>
> =A0Similar to /proc/sys/vm/swappiness, but affecting a hierarchy of group=
s only.
> Index: mmotm-0615/include/linux/memcontrol.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-0615.orig/include/linux/memcontrol.h
> +++ mmotm-0615/include/linux/memcontrol.h
> @@ -120,6 +120,22 @@ struct zone_reclaim_stat*
> =A0mem_cgroup_get_reclaim_stat_from_page(struct page *page);
> =A0extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0struct task_struct *p);
> +struct memcg_scanrecord {
> + =A0 =A0 =A0 struct mem_cgroup *mem; /* scanend memory cgroup */
> + =A0 =A0 =A0 struct mem_cgroup *root; /* scan target hierarchy root */
> + =A0 =A0 =A0 int context; =A0 =A0 =A0 =A0 =A0 =A0/* scanning context (se=
e memcontrol.c) */
> + =A0 =A0 =A0 unsigned long nr_scanned; /* the number of scanned pages */
> + =A0 =A0 =A0 unsigned long nr_freed; /* the number of freed pages */
> + =A0 =A0 =A0 unsigned long elappsed; /* nsec of time elapsed while scann=
ing */
> +};
> +
> +extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem=
,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask, bool noswap,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 struct memcg_scanrecord *rec);
> +extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask, bool noswap,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct zone *zone,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct memcg_scanrecord *rec);
>
> =A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> =A0extern int do_swap_account;
> Index: mmotm-0615/include/linux/swap.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-0615.orig/include/linux/swap.h
> +++ mmotm-0615/include/linux/swap.h
> @@ -253,12 +253,6 @@ static inline void lru_cache_add_file(st
> =A0/* linux/mm/vmscan.c */
> =A0extern unsigned long try_to_free_pages(struct zonelist *zonelist, int =
order,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0gfp_t gfp_mask, nodemask_t *mask);
> -extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem=
,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask, bool noswap);
> -extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask, bool noswap,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct zone *zone,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 unsigned long *nr_scanned);
> =A0extern int __isolate_lru_page(struct page *page, int mode, int file);
> =A0extern unsigned long shrink_all_memory(unsigned long nr_pages);
> =A0extern int vm_swappiness;
> Index: mmotm-0615/mm/memcontrol.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-0615.orig/mm/memcontrol.c
> +++ mmotm-0615/mm/memcontrol.c
> @@ -203,6 +203,57 @@ struct mem_cgroup_eventfd_list {
> =A0static void mem_cgroup_threshold(struct mem_cgroup *mem);
> =A0static void mem_cgroup_oom_notify(struct mem_cgroup *mem);
>
> +enum {
> + =A0 =A0 =A0 SCAN_BY_LIMIT,
> + =A0 =A0 =A0 FREED_BY_LIMIT,
> + =A0 =A0 =A0 ELAPSED_BY_LIMIT,
> +
> + =A0 =A0 =A0 SCAN_BY_SYSTEM,
> + =A0 =A0 =A0 FREED_BY_SYSTEM,
> + =A0 =A0 =A0 ELAPSED_BY_SYSTEM,
> +
> + =A0 =A0 =A0 SCAN_BY_SHRINK,
> + =A0 =A0 =A0 FREED_BY_SHRINK,
> + =A0 =A0 =A0 ELAPSED_BY_SHRINK,
> + =A0 =A0 =A0 NR_SCANSTATS,
> +};
> +#define __FREED =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1)
> +#define =A0 =A0 =A0 =A0__ELAPSED =A0 =A0 =A0 (2)
> +
> +struct scanstat {
> + =A0 =A0 =A0 spinlock_t =A0 =A0 =A0lock;
> + =A0 =A0 =A0 unsigned long =A0 stats[NR_SCANSTATS]; =A0 =A0/* local stat=
istics */
> + =A0 =A0 =A0 unsigned long =A0 totalstats[NR_SCANSTATS]; =A0 /* hierarch=
ical */
> +};
> +
> +const char *scanstat_string[NR_SCANSTATS] =3D {
> + =A0 =A0 =A0 "scanned_pages_by_limit",
> + =A0 =A0 =A0 "freed_pages_by_limit",
> + =A0 =A0 =A0 "elapsed_ns_by_limit",
> +
> + =A0 =A0 =A0 "scanned_pages_by_system",
> + =A0 =A0 =A0 "freed_pages_by_system",
> + =A0 =A0 =A0 "elapsed_ns_by_system",
> +
> + =A0 =A0 =A0 "scanned_pages_by_shrink",
> + =A0 =A0 =A0 "freed_pages_by_shrink",
> + =A0 =A0 =A0 "elappsed_ns_by_shrink",
> +};
> +
> +const char *total_scanstat_string[NR_SCANSTATS] =3D {
> + =A0 =A0 =A0 "total_scanned_pages_by_limit",
> + =A0 =A0 =A0 "total_freed_pages_by_limit",
> + =A0 =A0 =A0 "total_elapsed_ns_by_hierarchical",
> +
> + =A0 =A0 =A0 "total_scanned_pages_by_system",
> + =A0 =A0 =A0 "total_freed_pages_by_system",
> + =A0 =A0 =A0 "total_elapsed_ns_by_system",
> +
> + =A0 =A0 =A0 "total_scanned_pages_by_shrink",
> + =A0 =A0 =A0 "total_freed_pages_by_shrink",
> + =A0 =A0 =A0 "total_elapsed_ns_by_shrink",
> +};
> +
> =A0/*
> =A0* The memory controller data structure. The memory controller controls=
 both
> =A0* page cache and RSS per cgroup. We would eventually like to provide
> @@ -264,7 +315,8 @@ struct mem_cgroup {
>
> =A0 =A0 =A0 =A0/* For oom notifier event fd */
> =A0 =A0 =A0 =A0struct list_head oom_notify;
> -
> + =A0 =A0 =A0 /* For recording LRU-scan statistics */
> + =A0 =A0 =A0 struct scanstat scanstat;
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Should we move charges of a task when a task is moved i=
nto this
> =A0 =A0 =A0 =A0 * mem_cgroup ? And what type of charges should we move ?
> @@ -1634,6 +1686,28 @@ int mem_cgroup_select_victim_node(struct
> =A0}
> =A0#endif
>
> +
> +
> +static void mem_cgroup_record_scanstat(struct memcg_scanrecord *rec)
> +{
> + =A0 =A0 =A0 struct mem_cgroup *mem;
> + =A0 =A0 =A0 int context =3D rec->context;
> +
> + =A0 =A0 =A0 mem =3D rec->mem;
> + =A0 =A0 =A0 spin_lock(&mem->scanstat.lock);
> + =A0 =A0 =A0 mem->scanstat.stats[context] +=3D rec->nr_scanned;
> + =A0 =A0 =A0 mem->scanstat.stats[context + __FREED] +=3D rec->nr_freed;
> + =A0 =A0 =A0 mem->scanstat.stats[context + __ELAPSED] +=3D rec->elappsed=
;
> + =A0 =A0 =A0 spin_unlock(&mem->scanstat.lock);
> +
> + =A0 =A0 =A0 mem =3D rec->root;
> + =A0 =A0 =A0 spin_lock(&mem->scanstat.lock);
> + =A0 =A0 =A0 mem->scanstat.totalstats[context] +=3D rec->nr_scanned;
> + =A0 =A0 =A0 mem->scanstat.totalstats[context + __FREED] +=3D rec->nr_fr=
eed;
> + =A0 =A0 =A0 mem->scanstat.totalstats[context + __ELAPSED] +=3D rec->ela=
ppsed;
> + =A0 =A0 =A0 spin_unlock(&mem->scanstat.lock);
> +}
> +
> =A0/*
> =A0* Scan the hierarchy if needed to reclaim memory. We remember the last=
 child
> =A0* we reclaimed from, so that we don't end up penalizing one child exte=
nsively
> @@ -1659,8 +1733,8 @@ static int mem_cgroup_hierarchical_recla
> =A0 =A0 =A0 =A0bool shrink =3D reclaim_options & MEM_CGROUP_RECLAIM_SHRIN=
K;
> =A0 =A0 =A0 =A0bool check_soft =3D reclaim_options & MEM_CGROUP_RECLAIM_S=
OFT;
> =A0 =A0 =A0 =A0unsigned long excess;
> - =A0 =A0 =A0 unsigned long nr_scanned;
> =A0 =A0 =A0 =A0int visit;
> + =A0 =A0 =A0 struct memcg_scanrecord rec;
>
> =A0 =A0 =A0 =A0excess =3D res_counter_soft_limit_excess(&root_mem->res) >=
> PAGE_SHIFT;
>
> @@ -1668,6 +1742,15 @@ static int mem_cgroup_hierarchical_recla
> =A0 =A0 =A0 =A0if (!check_soft && root_mem->memsw_is_minimum)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0noswap =3D true;
>
> + =A0 =A0 =A0 if (shrink)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec.context =3D SCAN_BY_SHRINK;
> + =A0 =A0 =A0 else if (check_soft)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec.context =3D SCAN_BY_SYSTEM;
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec.context =3D SCAN_BY_LIMIT;
> +
> + =A0 =A0 =A0 rec.root =3D root_mem;
> +
> =A0again:
> =A0 =A0 =A0 =A0if (!shrink) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0visit =3D 0;
> @@ -1695,14 +1778,19 @@ again:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0css_put(&victim->css);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec.mem =3D victim;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec.nr_scanned =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec.nr_freed =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec.elappsed =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* we use swappiness of local cgroup */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (check_soft) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D mem_cgroup_shrink_=
node_zone(victim, gfp_mask,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 noswap, zon=
e, &nr_scanned);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *total_scanned +=3D nr_scan=
ned;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 noswap, zon=
e, &rec);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *total_scanned +=3D rec.nr_=
scanned;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D try_to_free_mem_cg=
roup_pages(victim, gfp_mask,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 noswap);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 noswap, &rec);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_record_scanstat(&rec);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0css_put(&victim->css);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0total +=3D ret;
> @@ -3757,7 +3845,8 @@ try_to_free:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D -EINTR;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 progress =3D try_to_free_mem_cgroup_pages(m=
em, GFP_KERNEL, false);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 progress =3D try_to_free_mem_cgroup_pages(m=
em,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 GFP_KERNEL,=
 false, NULL);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!progress) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_retries--;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* maybe some writeback is=
 necessary */
> @@ -4599,6 +4688,34 @@ static int mem_control_numa_stat_open(st
> =A0}
> =A0#endif /* CONFIG_NUMA */
>
> +static int mem_cgroup_scan_stat_read(struct cgroup *cgrp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cfty=
pe *cft,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgro=
up_map_cb *cb)
> +{
> + =A0 =A0 =A0 struct mem_cgroup *mem =3D mem_cgroup_from_cont(cgrp);
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 for (i =3D 0; i < NR_SCANSTATS; i++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cb->fill(cb, scanstat_string[i], mem->scans=
tat.stats[i]);
> + =A0 =A0 =A0 for (i =3D 0; i < NR_SCANSTATS; i++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cb->fill(cb, total_scanstat_string[i],
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem->scanstat.totalstats[i]=
);
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static int mem_cgroup_reset_scan_stat(struct cgroup *cgrp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned in=
t event)
> +{
> + =A0 =A0 =A0 struct mem_cgroup *mem =3D mem_cgroup_from_cont(cgrp);
> +
> + =A0 =A0 =A0 spin_lock(&mem->scanstat.lock);
> + =A0 =A0 =A0 memset(&mem->scanstat.stats, 0, sizeof(mem->scanstat.stats)=
);
> + =A0 =A0 =A0 memset(&mem->scanstat.totalstats, 0, sizeof(mem->scanstat.t=
otalstats));
> + =A0 =A0 =A0 spin_unlock(&mem->scanstat.lock);
> + =A0 =A0 =A0 return 0;
> +}
> +
> +
> =A0static struct cftype mem_cgroup_files[] =3D {
> =A0 =A0 =A0 =A0{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.name =3D "usage_in_bytes",
> @@ -4669,6 +4786,11 @@ static struct cftype mem_cgroup_files[]
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.mode =3D S_IRUGO,
> =A0 =A0 =A0 =A0},
> =A0#endif
> + =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D "scan_stat",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .read_map =3D mem_cgroup_scan_stat_read,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .trigger =3D mem_cgroup_reset_scan_stat,
> + =A0 =A0 =A0 },
> =A0};
>
> =A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> @@ -4932,6 +5054,7 @@ mem_cgroup_create(struct cgroup_subsys *
> =A0 =A0 =A0 =A0atomic_set(&mem->refcnt, 1);
> =A0 =A0 =A0 =A0mem->move_charge_at_immigrate =3D 0;
> =A0 =A0 =A0 =A0mutex_init(&mem->thresholds_lock);
> + =A0 =A0 =A0 spin_lock_init(&mem->scanstat.lock);
> =A0 =A0 =A0 =A0return &mem->css;
> =A0free_out:
> =A0 =A0 =A0 =A0__mem_cgroup_free(mem);
> Index: mmotm-0615/mm/vmscan.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-0615.orig/mm/vmscan.c
> +++ mmotm-0615/mm/vmscan.c
> @@ -2199,9 +2199,9 @@ unsigned long try_to_free_pages(struct z
> =A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR
>
> =A0unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask, bool noswap,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct zone *zone,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 unsigned long *nr_scanned)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 gfp_t gfp_mask, bool noswap,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct zone *zone,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct memcg_scanrecord *rec)
> =A0{
> =A0 =A0 =A0 =A0struct scan_control sc =3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.nr_scanned =3D 0,
> @@ -2213,6 +2213,7 @@ unsigned long mem_cgroup_shrink_node_zon
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.order =3D 0,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.mem_cgroup =3D mem,
> =A0 =A0 =A0 =A0};
> + =A0 =A0 =A0 unsigned long start, end;
>
> =A0 =A0 =A0 =A0sc.gfp_mask =3D (gfp_mask & GFP_RECLAIM_MASK) |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(GFP_HIGHUSER_MOVABLE & ~G=
FP_RECLAIM_MASK);
> @@ -2221,6 +2222,7 @@ unsigned long mem_cgroup_shrink_node_zon
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc.may_writepage,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc.gfp_mask);
>
> + =A0 =A0 =A0 start =3D sched_clock();
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * NOTE: Although we can get the priority field, using it
> =A0 =A0 =A0 =A0 * here is not a good idea, since it limits the pages we c=
an scan.
> @@ -2229,19 +2231,27 @@ unsigned long mem_cgroup_shrink_node_zon
> =A0 =A0 =A0 =A0 * the priority and make it zero.
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0shrink_zone(0, zone, &sc);
> + =A0 =A0 =A0 end =3D sched_clock();
> +
> + =A0 =A0 =A0 if (rec) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec->nr_scanned +=3D sc.nr_scanned;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec->nr_freed +=3D sc.nr_reclaimed;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec->elappsed +=3D end - start;
> + =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaime=
d);
>
> - =A0 =A0 =A0 *nr_scanned =3D sc.nr_scanned;
> =A0 =A0 =A0 =A0return sc.nr_reclaimed;
> =A0}
>
> =A0unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont=
,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 gfp_t gfp_mask,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0bool noswap)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0bool noswap,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0struct memcg_scanrecord *rec)
> =A0{
> =A0 =A0 =A0 =A0struct zonelist *zonelist;
> =A0 =A0 =A0 =A0unsigned long nr_reclaimed;
> + =A0 =A0 =A0 unsigned long start, end;
> =A0 =A0 =A0 =A0int nid;
> =A0 =A0 =A0 =A0struct scan_control sc =3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.may_writepage =3D !laptop_mode,
> @@ -2259,6 +2269,7 @@ unsigned long try_to_free_mem_cgroup_pag
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.gfp_mask =3D sc.gfp_mask,
> =A0 =A0 =A0 =A0};
>
> + =A0 =A0 =A0 start =3D sched_clock();
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Unlike direct reclaim via alloc_pages(), memcg's reclai=
m doesn't
> =A0 =A0 =A0 =A0 * take care of from where we get pages. So the node where=
 we start the
> @@ -2273,6 +2284,12 @@ unsigned long try_to_free_mem_cgroup_pag
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0sc.gfp_mask);
>
> =A0 =A0 =A0 =A0nr_reclaimed =3D do_try_to_free_pages(zonelist, &sc, &shri=
nk);
> + =A0 =A0 =A0 end =3D sched_clock();
> + =A0 =A0 =A0 if (rec) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec->nr_scanned +=3D sc.nr_scanned;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec->nr_freed +=3D sc.nr_reclaimed;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec->elappsed +=3D end - start;
> + =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0trace_mm_vmscan_memcg_reclaim_end(nr_reclaimed);
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
