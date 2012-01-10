Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 57E086B005C
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 18:54:06 -0500 (EST)
Received: by qcsd17 with SMTP id d17so85012qcs.14
        for <linux-mm@kvack.org>; Tue, 10 Jan 2012 15:54:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1326207772-16762-2-git-send-email-hannes@cmpxchg.org>
References: <1326207772-16762-1-git-send-email-hannes@cmpxchg.org>
	<1326207772-16762-2-git-send-email-hannes@cmpxchg.org>
Date: Tue, 10 Jan 2012 15:54:05 -0800
Message-ID: <CALWz4izbTw4+7zbfiED9Lx=6RwiqxE11g5-fNRHTh=mcP=vQ2Q@mail.gmail.com>
Subject: Re: [patch 1/2] mm: memcg: per-memcg reclaim statistics
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Thank you for the patch and the stats looks reasonable to me, few
questions as below:

On Tue, Jan 10, 2012 at 7:02 AM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> With the single per-zone LRU gone and global reclaim scanning
> individual memcgs, it's straight-forward to collect meaningful and
> accurate per-memcg reclaim statistics.
>
> This adds the following items to memory.stat:

Some of the previous discussions including patches have similar stats
in memory.vmscan_stat API, which collects all the per-memcg vmscan
stats. I would like to understand more why we add into memory.stat
instead, and do we have plan to keep extending memory.stat for those
vmstat like stats?

>
> pgreclaim

Not sure if we want to keep this more consistent to /proc/vmstat, then
it will be "pgsteal"?

> pgscan
>
> =A0Number of pages reclaimed/scanned from that memcg due to its own
> =A0hard limit (or physical limit in case of the root memcg) by the
> =A0allocating task.
>
> kswapd_pgreclaim
> kswapd_pgscan

we have "pgscan_kswapd_*" in vmstat, so maybe ?
"pgsteal_kswapd"
"pgscan_kswapd"

>
> =A0Reclaim activity from kswapd due to the memcg's own limit. =A0Only
> =A0applicable to the root memcg for now since kswapd is only triggered
> =A0by physical limits, but kswapd-style reclaim based on memcg hard
> =A0limits is being developped.
>
> hierarchy_pgreclaim
> hierarchy_pgscan
> hierarchy_kswapd_pgreclaim
> hierarchy_kswapd_pgscan

"pgsteal_hierarchy"
"pgsteal_kswapd_hierarchy"
..

No strong option on the naming, but try to make it more consistent to
existing API.


>
> =A0Reclaim activity due to limitations in one of the memcg's parents.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
> =A0Documentation/cgroups/memory.txt | =A0 =A04 ++
> =A0include/linux/memcontrol.h =A0 =A0 =A0 | =A0 10 +++++
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 84 ++++++++++=
+++++++++++++++++++++++++++-
> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A07 +++
> =A04 files changed, 103 insertions(+), 2 deletions(-)
>
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/mem=
ory.txt
> index cc0ebc5..eb9e982 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -389,6 +389,10 @@ mapped_file =A0 =A0 =A0 =A0- # of bytes of mapped fi=
le (includes tmpfs/shmem)
> =A0pgpgin =A0 =A0 =A0 =A0 - # of pages paged in (equivalent to # of charg=
ing events).
> =A0pgpgout =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0- # of pages paged out (equival=
ent to # of uncharging events).
> =A0swap =A0 =A0 =A0 =A0 =A0 - # of bytes of swap usage
> +pgreclaim =A0 =A0 =A0- # of pages reclaimed due to this memcg's limit
> +pgscan =A0 =A0 =A0 =A0 - # of pages scanned due to this memcg's limit
> +kswapd_* =A0 =A0 =A0 - # reclaim activity by background daemon due to th=
is memcg's limit
> +hierarchy_* =A0 =A0- # reclaim activity due to pressure from parental me=
mcg
> =A0inactive_anon =A0- # of bytes of anonymous memory and swap cache memor=
y on
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0LRU list.
> =A0active_anon =A0 =A0- # of bytes of anonymous and swap cache memory on =
active
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index bd3b102..6c1d69e 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -121,6 +121,8 @@ struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat=
(struct mem_cgroup *memcg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct zone *zone);
> =A0struct zone_reclaim_stat*
> =A0mem_cgroup_get_reclaim_stat_from_page(struct page *page);
> +void mem_cgroup_account_reclaim(struct mem_cgroup *, struct mem_cgroup *=
,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned lo=
ng, unsigned long, bool);
> =A0extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0struct task_struct *p);
> =A0extern void mem_cgroup_replace_page_cache(struct page *oldpage,
> @@ -347,6 +349,14 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *p=
age)
> =A0 =A0 =A0 =A0return NULL;
> =A0}
>
> +static inline void mem_cgroup_account_reclaim(struct mem_cgroup *root,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 struct mem_cgroup *memcg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 unsigned long nr_reclaimed,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 unsigned long nr_scanned,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 bool kswapd)
> +{
> +}
> +
> =A0static inline void
> =A0mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct=
 *p)
> =A0{
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 8e2a80d..170dff4 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -91,12 +91,23 @@ enum mem_cgroup_stat_index {
> =A0 =A0 =A0 =A0MEM_CGROUP_STAT_NSTATS,
> =A0};
>
> +#define MEM_CGROUP_EVENTS_KSWAPD 2
> +#define MEM_CGROUP_EVENTS_HIERARCHY 4
> +
> =A0enum mem_cgroup_events_index {
> =A0 =A0 =A0 =A0MEM_CGROUP_EVENTS_PGPGIN, =A0 =A0 =A0 /* # of pages paged =
in */
> =A0 =A0 =A0 =A0MEM_CGROUP_EVENTS_PGPGOUT, =A0 =A0 =A0/* # of pages paged =
out */
> =A0 =A0 =A0 =A0MEM_CGROUP_EVENTS_COUNT, =A0 =A0 =A0 =A0/* # of pages page=
d in/out */
> =A0 =A0 =A0 =A0MEM_CGROUP_EVENTS_PGFAULT, =A0 =A0 =A0/* # of page-faults =
*/
> =A0 =A0 =A0 =A0MEM_CGROUP_EVENTS_PGMAJFAULT, =A0 /* # of major page-fault=
s */
> + =A0 =A0 =A0 MEM_CGROUP_EVENTS_PGRECLAIM,
> + =A0 =A0 =A0 MEM_CGROUP_EVENTS_PGSCAN,
> + =A0 =A0 =A0 MEM_CGROUP_EVENTS_KSWAPD_PGRECLAIM,
> + =A0 =A0 =A0 MEM_CGROUP_EVENTS_KSWAPD_PGSCAN,
> + =A0 =A0 =A0 MEM_CGROUP_EVENTS_HIERARCHY_PGRECLAIM,
> + =A0 =A0 =A0 MEM_CGROUP_EVENTS_HIERARCHY_PGSCAN,
> + =A0 =A0 =A0 MEM_CGROUP_EVENTS_HIERARCHY_KSWAPD_PGRECLAIM,
> + =A0 =A0 =A0 MEM_CGROUP_EVENTS_HIERARCHY_KSWAPD_PGSCAN,

missing comment here?
> =A0 =A0 =A0 =A0MEM_CGROUP_EVENTS_NSTATS,
> =A0};
> =A0/*
> @@ -889,6 +900,38 @@ static inline bool mem_cgroup_is_root(struct mem_cgr=
oup *memcg)
> =A0 =A0 =A0 =A0return (memcg =3D=3D root_mem_cgroup);
> =A0}
>
> +/**
> + * mem_cgroup_account_reclaim - update per-memcg reclaim statistics
> + * @root: memcg that triggered reclaim
> + * @memcg: memcg that is actually being scanned
> + * @nr_reclaimed: number of pages reclaimed from @memcg
> + * @nr_scanned: number of pages scanned from @memcg
> + * @kswapd: whether reclaiming task is kswapd or allocator itself
> + */
> +void mem_cgroup_account_reclaim(struct mem_cgroup *root,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct mem_=
cgroup *memcg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned lo=
ng nr_reclaimed,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned lo=
ng nr_scanned,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool kswapd=
)
> +{
> + =A0 =A0 =A0 unsigned int offset =3D 0;
> +
> + =A0 =A0 =A0 if (!root)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 root =3D root_mem_cgroup;
> +
> + =A0 =A0 =A0 if (kswapd)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 offset +=3D MEM_CGROUP_EVENTS_KSWAPD;
> + =A0 =A0 =A0 if (root !=3D memcg)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 offset +=3D MEM_CGROUP_EVENTS_HIERARCHY;

Just to be clear, here root cgroup has hierarchy_* stats always 0 ?
Also, we might want to consider renaming the root here, something like
target? The root is confusing with root_mem_cgroup.

--Ying

> +
> + =A0 =A0 =A0 preempt_disable();
> + =A0 =A0 =A0 __this_cpu_add(memcg->stat->events[MEM_CGROUP_EVENTS_PGRECL=
AIM + offset],
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_reclaimed);
> + =A0 =A0 =A0 __this_cpu_add(memcg->stat->events[MEM_CGROUP_EVENTS_PGSCAN=
 + offset],
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_scanned);
> + =A0 =A0 =A0 preempt_enable();
> +}
> +
> =A0void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_ite=
m idx)
> =A0{
> =A0 =A0 =A0 =A0struct mem_cgroup *memcg;
> @@ -1662,6 +1705,8 @@ static int mem_cgroup_soft_reclaim(struct mem_cgrou=
p *root_memcg,
> =A0 =A0 =A0 =A0excess =3D res_counter_soft_limit_excess(&root_memcg->res)=
 >> PAGE_SHIFT;
>
> =A0 =A0 =A0 =A0while (1) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_reclaimed;
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0victim =3D mem_cgroup_iter(root_memcg, vic=
tim, &reclaim);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!victim) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0loop++;
> @@ -1687,8 +1732,11 @@ static int mem_cgroup_soft_reclaim(struct mem_cgro=
up *root_memcg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!mem_cgroup_reclaimable(victim, false)=
)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 total +=3D mem_cgroup_shrink_node_zone(vict=
im, gfp_mask, false,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone, &nr_scanned);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_reclaimed =3D mem_cgroup_shrink_node_zon=
e(victim, gfp_mask, false,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone, &nr_scanned);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_account_reclaim(root_mem_cgroup,=
 victim, nr_reclaimed,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0nr_scanned, current_is_kswapd());
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 total +=3D nr_reclaimed;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*total_scanned +=3D nr_scanned;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!res_counter_soft_limit_excess(&root_m=
emcg->res))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> @@ -4023,6 +4071,14 @@ enum {
> =A0 =A0 =A0 =A0MCS_SWAP,
> =A0 =A0 =A0 =A0MCS_PGFAULT,
> =A0 =A0 =A0 =A0MCS_PGMAJFAULT,
> + =A0 =A0 =A0 MCS_PGRECLAIM,
> + =A0 =A0 =A0 MCS_PGSCAN,
> + =A0 =A0 =A0 MCS_KSWAPD_PGRECLAIM,
> + =A0 =A0 =A0 MCS_KSWAPD_PGSCAN,
> + =A0 =A0 =A0 MCS_HIERARCHY_PGRECLAIM,
> + =A0 =A0 =A0 MCS_HIERARCHY_PGSCAN,
> + =A0 =A0 =A0 MCS_HIERARCHY_KSWAPD_PGRECLAIM,
> + =A0 =A0 =A0 MCS_HIERARCHY_KSWAPD_PGSCAN,
> =A0 =A0 =A0 =A0MCS_INACTIVE_ANON,
> =A0 =A0 =A0 =A0MCS_ACTIVE_ANON,
> =A0 =A0 =A0 =A0MCS_INACTIVE_FILE,
> @@ -4047,6 +4103,14 @@ struct {
> =A0 =A0 =A0 =A0{"swap", "total_swap"},
> =A0 =A0 =A0 =A0{"pgfault", "total_pgfault"},
> =A0 =A0 =A0 =A0{"pgmajfault", "total_pgmajfault"},
> + =A0 =A0 =A0 {"pgreclaim", "total_pgreclaim"},
> + =A0 =A0 =A0 {"pgscan", "total_pgscan"},
> + =A0 =A0 =A0 {"kswapd_pgreclaim", "total_kswapd_pgreclaim"},
> + =A0 =A0 =A0 {"kswapd_pgscan", "total_kswapd_pgscan"},
> + =A0 =A0 =A0 {"hierarchy_pgreclaim", "total_hierarchy_pgreclaim"},
> + =A0 =A0 =A0 {"hierarchy_pgscan", "total_hierarchy_pgscan"},
> + =A0 =A0 =A0 {"hierarchy_kswapd_pgreclaim", "total_hierarchy_kswapd_pgre=
claim"},
> + =A0 =A0 =A0 {"hierarchy_kswapd_pgscan", "total_hierarchy_kswapd_pgscan"=
},
> =A0 =A0 =A0 =A0{"inactive_anon", "total_inactive_anon"},
> =A0 =A0 =A0 =A0{"active_anon", "total_active_anon"},
> =A0 =A0 =A0 =A0{"inactive_file", "total_inactive_file"},
> @@ -4079,6 +4143,22 @@ mem_cgroup_get_local_stat(struct mem_cgroup *memcg=
, struct mcs_total_stat *s)
> =A0 =A0 =A0 =A0s->stat[MCS_PGFAULT] +=3D val;
> =A0 =A0 =A0 =A0val =3D mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_PG=
MAJFAULT);
> =A0 =A0 =A0 =A0s->stat[MCS_PGMAJFAULT] +=3D val;
> + =A0 =A0 =A0 val =3D mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_PGR=
ECLAIM);
> + =A0 =A0 =A0 s->stat[MCS_PGRECLAIM] +=3D val;
> + =A0 =A0 =A0 val =3D mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_PGS=
CAN);
> + =A0 =A0 =A0 s->stat[MCS_PGSCAN] +=3D val;
> + =A0 =A0 =A0 val =3D mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_KSW=
APD_PGRECLAIM);
> + =A0 =A0 =A0 s->stat[MCS_KSWAPD_PGRECLAIM] +=3D val;
> + =A0 =A0 =A0 val =3D mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_KSW=
APD_PGSCAN);
> + =A0 =A0 =A0 s->stat[MCS_KSWAPD_PGSCAN] +=3D val;
> + =A0 =A0 =A0 val =3D mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_HIE=
RARCHY_PGRECLAIM);
> + =A0 =A0 =A0 s->stat[MCS_HIERARCHY_PGRECLAIM] +=3D val;
> + =A0 =A0 =A0 val =3D mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_HIE=
RARCHY_PGSCAN);
> + =A0 =A0 =A0 s->stat[MCS_HIERARCHY_PGSCAN] +=3D val;
> + =A0 =A0 =A0 val =3D mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_HIE=
RARCHY_KSWAPD_PGRECLAIM);
> + =A0 =A0 =A0 s->stat[MCS_HIERARCHY_KSWAPD_PGRECLAIM] +=3D val;
> + =A0 =A0 =A0 val =3D mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_HIE=
RARCHY_KSWAPD_PGSCAN);
> + =A0 =A0 =A0 s->stat[MCS_HIERARCHY_KSWAPD_PGSCAN] +=3D val;
>
> =A0 =A0 =A0 =A0/* per zone stat */
> =A0 =A0 =A0 =A0val =3D mem_cgroup_nr_lru_pages(memcg, BIT(LRU_INACTIVE_AN=
ON));
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c631234..e3fd8a7 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2115,12 +2115,19 @@ static void shrink_zone(int priority, struct zone=
 *zone,
>
> =A0 =A0 =A0 =A0memcg =3D mem_cgroup_iter(root, NULL, &reclaim);
> =A0 =A0 =A0 =A0do {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_reclaimed =3D sc->nr_recla=
imed;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_scanned =3D sc->nr_scanned=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct mem_cgroup_zone mz =3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.mem_cgroup =3D memcg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.zone =3D zone,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0};
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0shrink_mem_cgroup_zone(priority, &mz, sc);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_account_reclaim(root, memcg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0sc->nr_reclaimed - nr_reclaimed,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0sc->nr_scanned - nr_scanned,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0current_is_kswapd());
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Limit reclaim has historically picked o=
ne memcg and
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * scanned it with decreasing priority lev=
els until
> --
> 1.7.7.5
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
