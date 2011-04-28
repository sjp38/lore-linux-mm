Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A96116B0011
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 23:44:04 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id p3S3i0vu027655
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 20:44:00 -0700
Received: from qwb8 (qwb8.prod.google.com [10.241.193.72])
	by wpaz13.hot.corp.google.com with ESMTP id p3S3hfWT013217
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 20:43:59 -0700
Received: by qwb8 with SMTP id 8so1544037qwb.11
        for <linux-mm@kvack.org>; Wed, 27 Apr 2011 20:43:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110428121643.b3cbf420.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110428121643.b3cbf420.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 27 Apr 2011 20:43:58 -0700
Message-ID: <BANLkTimywCF06gfKWFcbAsWtFUbs73rZrQ@mail.gmail.com>
Subject: Re: Fw: [PATCH] memcg: add reclaim statistics accounting
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Apr 27, 2011 at 8:16 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> sorry, I had wrong TO:...
>
> Begin forwarded message:
>
> Date: Thu, 28 Apr 2011 12:02:34 +0900
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> To: linux-mm@vger.kernel.org
> Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishi=
mura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.i=
bm.com" <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, "akpm@l=
inux-foundation.org" <akpm@linux-foundation.org>
> Subject: [PATCH] memcg: add reclaim statistics accounting
>
>
>
> Now, memory cgroup provides poor reclaim statistics per memcg. This
> patch adds statistics for direct/soft reclaim as the number of
> pages scans, the number of page freed by reclaim, the nanoseconds of
> latency at reclaim.
>
> It's good to add statistics before we modify memcg/global reclaim, largel=
y.
> This patch refactors current soft limit status and add an unified update =
logic.
>
> For example, After #cat 195Mfile > /dev/null under 100M limit.
> =A0 =A0 =A0 =A0# cat /cgroup/memory/A/memory.stat
> =A0 =A0 =A0 =A0....
> =A0 =A0 =A0 =A0limit_freed 24592

why not "limit_steal" ?

> =A0 =A0 =A0 =A0soft_steal 0
> =A0 =A0 =A0 =A0limit_scan 43974
> =A0 =A0 =A0 =A0soft_scan 0
> =A0 =A0 =A0 =A0limit_latency 133837417
>
> nearly 96M caches are freed. scanned twice. used 133ms.

Does it make sense to split up the soft_steal/scan for bg reclaim and
direct reclaim? The same for the limit_steal/scan. I am now testing
the patch to add the soft_limit reclaim on global ttfp, and i already
have the patch to add the following:

kswapd_soft_steal 0
kswapd_soft_scan 0
direct_soft_steal 0
direct_soft_scan 0
kswapd_steal 0
pg_pgsteal 0
kswapd_pgscan 0
pg_scan 0

It is more clear to me to have finer granularity of the stats. Let me
know if that works or not. I probably can post it this week.

--Ying
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamaezawa.hiroyu@jp.fujitsu.com>
> ---
> =A0Documentation/cgroups/memory.txt | =A0 13 ++++++--
> =A0include/linux/memcontrol.h =A0 =A0 =A0 | =A0 =A01
> =A0include/linux/swap.h =A0 =A0 =A0 =A0 =A0 =A0 | =A0 10 ++----
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 63 ++++++++++=
++++++++++++++---------------
> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 25 ++++++=
+++++++--
> =A05 files changed, 77 insertions(+), 35 deletions(-)
>
> Index: memcg/include/linux/memcontrol.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- memcg.orig/include/linux/memcontrol.h
> +++ memcg/include/linux/memcontrol.h
> @@ -106,6 +106,7 @@ extern void mem_cgroup_end_migration(str
> =A0/*
> =A0* For memory reclaim.
> =A0*/
> +enum { RECLAIM_SCAN, RECLAIM_FREE, RECLAIM_LATENCY, NR_RECLAIM_INFO};
> =A0int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
> =A0int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
> =A0int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
> Index: memcg/mm/memcontrol.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- memcg.orig/mm/memcontrol.c
> +++ memcg/mm/memcontrol.c
> @@ -96,10 +96,6 @@ enum mem_cgroup_events_index {
> =A0 =A0 =A0 =A0MEM_CGROUP_EVENTS_COUNT, =A0 =A0 =A0 =A0/* # of pages page=
d in/out */
> =A0 =A0 =A0 =A0MEM_CGROUP_EVENTS_PGFAULT, =A0 =A0 =A0/* # of page-faults =
*/
> =A0 =A0 =A0 =A0MEM_CGROUP_EVENTS_PGMAJFAULT, =A0 /* # of major page-fault=
s */
> - =A0 =A0 =A0 MEM_CGROUP_EVENTS_SOFT_STEAL, =A0 /* # of pages reclaimed f=
rom */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 /* soft reclaim =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 MEM_CGROUP_EVENTS_SOFT_SCAN, =A0 =A0/* # of pages scanned f=
rom */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 /* soft reclaim =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0MEM_CGROUP_EVENTS_NSTATS,
> =A0};
> =A0/*
> @@ -206,6 +202,9 @@ struct mem_cgroup_eventfd_list {
> =A0static void mem_cgroup_threshold(struct mem_cgroup *mem);
> =A0static void mem_cgroup_oom_notify(struct mem_cgroup *mem);
>
> +/* memory reclaim contexts */
> +enum { MEM_LIMIT, MEM_SOFT, NR_MEM_CONTEXTS};
> +
> =A0/*
> =A0* The memory controller data structure. The memory controller controls=
 both
> =A0* page cache and RSS per cgroup. We would eventually like to provide
> @@ -242,6 +241,7 @@ struct mem_cgroup {
> =A0 =A0 =A0 =A0nodemask_t =A0 =A0 =A0scan_nodes;
> =A0 =A0 =A0 =A0unsigned long =A0 next_scan_node_update;
> =A0#endif
> + =A0 =A0 =A0 atomic_long_t =A0 reclaim_info[NR_MEM_CONTEXTS][NR_RECLAIM_=
INFO];
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Should the accounting and control be hierarchical, per =
subtree?
> =A0 =A0 =A0 =A0 */
> @@ -645,16 +645,6 @@ static void mem_cgroup_charge_statistics
> =A0 =A0 =A0 =A0preempt_enable();
> =A0}
>
> -static void mem_cgroup_soft_steal(struct mem_cgroup *mem, int val)
> -{
> - =A0 =A0 =A0 this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_SOFT_STEAL=
], val);
> -}
> -
> -static void mem_cgroup_soft_scan(struct mem_cgroup *mem, int val)
> -{
> - =A0 =A0 =A0 this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_SOFT_SCAN]=
, val);
> -}
> -
> =A0static unsigned long
> =A0mem_cgroup_get_zonestat_node(struct mem_cgroup *mem, int nid, enum lru=
_list idx)
> =A0{
> @@ -679,6 +669,15 @@ static unsigned long mem_cgroup_get_loca
> =A0 =A0 =A0 =A0return total;
> =A0}
>
> +void mem_cgroup_update_reclaim_info(struct mem_cgroup *mem, int context,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned lo=
ng *stats)
> +{
> + =A0 =A0 =A0 int i;
> + =A0 =A0 =A0 for (i =3D 0; i < NR_RECLAIM_INFO; i++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 atomic_long_add(stats[i], &mem->reclaim_inf=
o[context][i]);
> +}
> +
> +
> =A0static bool __memcg_event_check(struct mem_cgroup *mem, int target)
> =A0{
> =A0 =A0 =A0 =A0unsigned long val, next;
> @@ -1560,6 +1559,8 @@ int mem_cgroup_select_victim_node(struct
> =A0}
> =A0#endif
>
> +
> +
> =A0/*
> =A0* Scan the hierarchy if needed to reclaim memory. We remember the last=
 child
> =A0* we reclaimed from, so that we don't end up penalizing one child exte=
nsively
> @@ -1585,7 +1586,8 @@ static int mem_cgroup_hierarchical_recla
> =A0 =A0 =A0 =A0bool shrink =3D reclaim_options & MEM_CGROUP_RECLAIM_SHRIN=
K;
> =A0 =A0 =A0 =A0bool check_soft =3D reclaim_options & MEM_CGROUP_RECLAIM_S=
OFT;
> =A0 =A0 =A0 =A0unsigned long excess;
> - =A0 =A0 =A0 unsigned long nr_scanned;
> + =A0 =A0 =A0 unsigned long stats[NR_RECLAIM_INFO];
> + =A0 =A0 =A0 int context =3D (check_soft)? MEM_SOFT : MEM_LIMIT;
>
> =A0 =A0 =A0 =A0excess =3D res_counter_soft_limit_excess(&root_mem->res) >=
> PAGE_SHIFT;
>
> @@ -1631,13 +1633,12 @@ static int mem_cgroup_hierarchical_recla
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (check_soft) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D mem_cgroup_shrink_=
node_zone(victim, gfp_mask,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0noswap, ge=
t_swappiness(victim), zone,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &nr_scanned=
);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *total_scanned +=3D nr_scan=
ned;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_soft_steal(victi=
m, ret);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_soft_scan(victim=
, nr_scanned);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 stats);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *total_scanned +=3D stats[R=
ECLAIM_SCAN];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D try_to_free_mem_cg=
roup_pages(victim, gfp_mask,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 noswap, get_swappiness(victim));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 noswap, get_swappiness(victim),stats);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_update_reclaim_info(victim, cont=
ext, stats);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0css_put(&victim->css);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * At shrinking usage, we can't check we s=
hould stop here or
> @@ -3661,7 +3662,7 @@ try_to_free:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0progress =3D try_to_free_mem_cgroup_pages(=
mem, GFP_KERNEL,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 false, get_swappiness(mem));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 false, get_swappiness(mem), NULL);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!progress) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_retries--;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* maybe some writeback is=
 necessary */
> @@ -3929,8 +3930,12 @@ enum {
> =A0 =A0 =A0 =A0MCS_SWAP,
> =A0 =A0 =A0 =A0MCS_PGFAULT,
> =A0 =A0 =A0 =A0MCS_PGMAJFAULT,
> + =A0 =A0 =A0 MCS_LIMIT_FREED,
> =A0 =A0 =A0 =A0MCS_SOFT_STEAL,
> + =A0 =A0 =A0 MCS_LIMIT_SCAN,
> =A0 =A0 =A0 =A0MCS_SOFT_SCAN,
> + =A0 =A0 =A0 MCS_LIMIT_LATENCY,
> + =A0 =A0 =A0 MCS_SOFT_LATENCY,
> =A0 =A0 =A0 =A0MCS_INACTIVE_ANON,
> =A0 =A0 =A0 =A0MCS_ACTIVE_ANON,
> =A0 =A0 =A0 =A0MCS_INACTIVE_FILE,
> @@ -3955,8 +3960,12 @@ struct {
> =A0 =A0 =A0 =A0{"swap", "total_swap"},
> =A0 =A0 =A0 =A0{"pgfault", "total_pgfault"},
> =A0 =A0 =A0 =A0{"pgmajfault", "total_pgmajfault"},
> + =A0 =A0 =A0 {"limit_freed", "total_limit_freed"},
> =A0 =A0 =A0 =A0{"soft_steal", "total_soft_steal"},
> + =A0 =A0 =A0 {"limit_scan", "total_limit_scan"},
> =A0 =A0 =A0 =A0{"soft_scan", "total_soft_scan"},
> + =A0 =A0 =A0 {"limit_latency", "total_limit_latency"},
> + =A0 =A0 =A0 {"soft_latency", "total_soft_latency"},
> =A0 =A0 =A0 =A0{"inactive_anon", "total_inactive_anon"},
> =A0 =A0 =A0 =A0{"active_anon", "total_active_anon"},
> =A0 =A0 =A0 =A0{"inactive_file", "total_inactive_file"},
> @@ -3985,10 +3994,18 @@ mem_cgroup_get_local_stat(struct mem_cgr
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0val =3D mem_cgroup_read_stat(mem, MEM_CGRO=
UP_STAT_SWAPOUT);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0s->stat[MCS_SWAP] +=3D val * PAGE_SIZE;
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 val =3D mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_SOFT_=
STEAL);
> + =A0 =A0 =A0 val =3D atomic_long_read(&mem->reclaim_info[MEM_LIMIT][RECL=
AIM_FREE]);
> + =A0 =A0 =A0 s->stat[MCS_LIMIT_FREED] +=3D val;
> + =A0 =A0 =A0 val =3D atomic_long_read(&mem->reclaim_info[MEM_SOFT][RECLA=
IM_FREE]);
> =A0 =A0 =A0 =A0s->stat[MCS_SOFT_STEAL] +=3D val;
> - =A0 =A0 =A0 val =3D mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_SOFT_=
SCAN);
> + =A0 =A0 =A0 val =3D atomic_long_read(&mem->reclaim_info[MEM_LIMIT][RECL=
AIM_SCAN]);
> + =A0 =A0 =A0 s->stat[MCS_LIMIT_SCAN] +=3D val;
> + =A0 =A0 =A0 val =3D atomic_long_read(&mem->reclaim_info[MEM_SOFT][RECLA=
IM_SCAN]);
> =A0 =A0 =A0 =A0s->stat[MCS_SOFT_SCAN] +=3D val;
> + =A0 =A0 =A0 val =3D atomic_long_read(&mem->reclaim_info[MEM_LIMIT][RECL=
AIM_LATENCY]);
> + =A0 =A0 =A0 s->stat[MCS_LIMIT_LATENCY] +=3D val;
> + =A0 =A0 =A0 val =3D atomic_long_read(&mem->reclaim_info[MEM_SOFT][RECLA=
IM_LATENCY]);
> + =A0 =A0 =A0 s->stat[MCS_SOFT_LATENCY] +=3D val;
> =A0 =A0 =A0 =A0val =3D mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_PGFA=
ULT);
> =A0 =A0 =A0 =A0s->stat[MCS_PGFAULT] +=3D val;
> =A0 =A0 =A0 =A0val =3D mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_PGMA=
JFAULT);
> Index: memcg/mm/vmscan.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- memcg.orig/mm/vmscan.c
> +++ memcg/mm/vmscan.c
> @@ -2156,7 +2156,7 @@ unsigned long mem_cgroup_shrink_node_zon
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0gfp_t gfp_mask, bool noswap,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0unsigned int swappiness,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0struct zone *zone,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 unsigned long *nr_scanned)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 unsigned long *stats)
> =A0{
> =A0 =A0 =A0 =A0struct scan_control sc =3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.nr_scanned =3D 0,
> @@ -2168,6 +2168,9 @@ unsigned long mem_cgroup_shrink_node_zon
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.order =3D 0,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.mem_cgroup =3D mem,
> =A0 =A0 =A0 =A0};
> + =A0 =A0 =A0 u64 start, end;
> +
> + =A0 =A0 =A0 start =3D sched_clock();
>
> =A0 =A0 =A0 =A0sc.gfp_mask =3D (gfp_mask & GFP_RECLAIM_MASK) |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(GFP_HIGHUSER_MOVABLE & ~G=
FP_RECLAIM_MASK);
> @@ -2175,7 +2178,6 @@ unsigned long mem_cgroup_shrink_node_zon
> =A0 =A0 =A0 =A0trace_mm_vmscan_memcg_softlimit_reclaim_begin(0,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc.may_writepage,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc.gfp_mask);
> -
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * NOTE: Although we can get the priority field, using it
> =A0 =A0 =A0 =A0 * here is not a good idea, since it limits the pages we c=
an scan.
> @@ -2185,20 +2187,26 @@ unsigned long mem_cgroup_shrink_node_zon
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0shrink_zone(0, zone, &sc);
>
> + =A0 =A0 =A0 stats[RECLAIM_SCAN] =3D sc.nr_scanned;
> + =A0 =A0 =A0 stats[RECLAIM_FREE] =3D sc.nr_reclaimed;
> + =A0 =A0 =A0 end =3D sched_clock();
> + =A0 =A0 =A0 stats[RECLAIM_LATENCY] =3D end - start;
> +
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
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 bool noswap,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0unsigned int swappiness)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0unsigned int swappiness,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0unsigned long *stats)
> =A0{
> =A0 =A0 =A0 =A0struct zonelist *zonelist;
> =A0 =A0 =A0 =A0unsigned long nr_reclaimed;
> =A0 =A0 =A0 =A0int nid;
> + =A0 =A0 =A0 u64 end, start;
> =A0 =A0 =A0 =A0struct scan_control sc =3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.may_writepage =3D !laptop_mode,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.may_unmap =3D 1,
> @@ -2209,6 +2217,8 @@ unsigned long try_to_free_mem_cgroup_pag
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.mem_cgroup =3D mem_cont,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.nodemask =3D NULL, /* we don't care the p=
lacement */
> =A0 =A0 =A0 =A0};
> +
> + =A0 =A0 =A0 start =3D sched_clock();
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Unlike direct reclaim via alloc_pages(), memcg's reclai=
m
> =A0 =A0 =A0 =A0 * don't take care of from where we get pages . So, the no=
de where
> @@ -2226,6 +2236,13 @@ unsigned long try_to_free_mem_cgroup_pag
>
> =A0 =A0 =A0 =A0nr_reclaimed =3D do_try_to_free_pages(zonelist, &sc);
>
> + =A0 =A0 =A0 if (stats) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 stats[RECLAIM_SCAN] =3D sc.nr_scanned;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 stats[RECLAIM_FREE] =3D sc.nr_reclaimed;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 end =3D sched_clock();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 stats[RECLAIM_LATENCY] =3D end - start;
> + =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0trace_mm_vmscan_memcg_reclaim_end(nr_reclaimed);
>
> =A0 =A0 =A0 =A0return nr_reclaimed;
> Index: memcg/Documentation/cgroups/memory.txt
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- memcg.orig/Documentation/cgroups/memory.txt
> +++ memcg/Documentation/cgroups/memory.txt
> @@ -387,8 +387,13 @@ pgpgout =A0 =A0 =A0 =A0 =A0 =A0- # of pages paged ou=
t (equival
> =A0swap =A0 =A0 =A0 =A0 =A0 - # of bytes of swap usage
> =A0pgfault =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0- # of page faults.
> =A0pgmajfault =A0 =A0 - # of major page faults.
> -soft_steal =A0 =A0 - # of pages reclaimed from global hierarchical recla=
im
> -soft_scan =A0 =A0 =A0- # of pages scanned from global hierarchical recla=
im
> +limit_freed =A0 =A0- # of pages reclaimed by hitting limit.
> +soft_steal =A0 =A0 - # of pages reclaimed by kernel with hints of soft l=
imit
> +limit_scan =A0 =A0 - # of pages scanned by hitting limit.
> +soft_scan =A0 =A0 =A0- # of pages scanned by kernel with hints of soft l=
imit
> +limit_latency =A0- # of nanosecs epalsed at reclaiming by hitting limit
> +soft_latency =A0 - # of nanosecs epalsed at reclaiming by kernel with hi=
ts of
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 soft limit.
> =A0inactive_anon =A0- # of bytes of anonymous memory and swap cache memor=
y on
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0LRU list.
> =A0active_anon =A0 =A0- # of bytes of anonymous and swap cache memory on =
active
> @@ -412,8 +417,12 @@ total_pgpgout =A0 =A0 =A0 =A0 =A0 =A0 =A0- sum of al=
l children's "
> =A0total_swap =A0 =A0 =A0 =A0 =A0 =A0 - sum of all children's "swap"
> =A0total_pgfault =A0 =A0 =A0 =A0 =A0- sum of all children's "pgfault"
> =A0total_pgmajfault =A0 =A0 =A0 - sum of all children's "pgmajfault"
> +total_limit_freed =A0 =A0 =A0- sum of all children's "limit_freed"
> =A0total_soft_steal =A0 =A0 =A0 - sum of all children's "soft_steal"
> +total_limit_scan =A0 =A0 =A0 - sum of all children's "limit_scan"
> =A0total_soft_scan =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0- sum of all children's=
 "soft_scan"
> +total_limit_latency =A0 =A0- sum of all children's "limit_latency"
> +total_soft_latency =A0 =A0 - sum of all children's "soft_latency"
> =A0total_inactive_anon =A0 =A0- sum of all children's "inactive_anon"
> =A0total_active_anon =A0 =A0 =A0- sum of all children's "active_anon"
> =A0total_inactive_file =A0 =A0- sum of all children's "inactive_file"
> Index: memcg/include/linux/swap.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- memcg.orig/include/linux/swap.h
> +++ memcg/include/linux/swap.h
> @@ -252,13 +252,11 @@ static inline void lru_cache_add_file(st
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
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask, bool noswap, unsigned int s=
wappiness,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long *stats);
> =A0extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *me=
m,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask, bool noswap,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 unsigned int swappiness,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct zone *zone,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 unsigned long *nr_scanned);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask, bool noswap, unsigned int s=
wappiness,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone, unsigned long *stats);
> =A0extern int __isolate_lru_page(struct page *page, int mode, int file);
> =A0extern unsigned long shrink_all_memory(unsigned long nr_pages);
> =A0extern int vm_swappiness;
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
