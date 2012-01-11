Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 4D06D6B0062
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 16:42:32 -0500 (EST)
Received: by pbdd2 with SMTP id d2so1020456pbd.14
        for <linux-mm@kvack.org>; Wed, 11 Jan 2012 13:42:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1326207772-16762-3-git-send-email-hannes@cmpxchg.org>
References: <1326207772-16762-1-git-send-email-hannes@cmpxchg.org>
	<1326207772-16762-3-git-send-email-hannes@cmpxchg.org>
Date: Wed, 11 Jan 2012 13:42:31 -0800
Message-ID: <CALWz4izwNBN_qcSsqg-qYw-Esc9vBL3=4cv3Wsg1jf6001_fWQ@mail.gmail.com>
Subject: Re: [patch 2/2] mm: memcg: hierarchical soft limit reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jan 10, 2012 at 7:02 AM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> Right now, memcg soft limits are implemented by having a sorted tree
> of memcgs that are in excess of their limits. =A0Under global memory
> pressure, kswapd first reclaims from the biggest excessor and then
> proceeds to do regular global reclaim. =A0The result of this is that
> pages are reclaimed from all memcgs, but more scanning happens against
> those above their soft limit.
>
> With global reclaim doing memcg-aware hierarchical reclaim by default,
> this is a lot easier to implement: everytime a memcg is reclaimed
> from, scan more aggressively (per tradition with a priority of 0) if
> it's above its soft limit. =A0With the same end result of scanning
> everybody, but soft limit excessors a bit more.
>
> Advantages:
>
> =A0o smoother reclaim: soft limit reclaim is a separate stage before
> =A0 =A0global reclaim, whose result is not communicated down the line and
> =A0 =A0so overreclaim of the groups in excess is very likely. =A0After th=
is
> =A0 =A0patch, soft limit reclaim is fully integrated into regular reclaim
> =A0 =A0and each memcg is considered exactly once per cycle.
>
> =A0o true hierarchy support: soft limits are only considered when
> =A0 =A0kswapd does global reclaim, but after this patch, targetted
> =A0 =A0reclaim of a memcg will mind the soft limit settings of its child
> =A0 =A0groups.

Why we add soft limit reclaim into target reclaim?

Based on the discussions, my understanding is that the soft limit only
take effect while the whole machine is under memory contention. We
don't want to add extra pressure on a cgroup if there is free memory
on the system even the cgroup is above its limit.

>
> =A0o code size: soft limit reclaim requires a lot of code to maintain
> =A0 =A0the per-node per-zone rb-trees to quickly find the biggest
> =A0 =A0offender, dedicated paths for soft limit reclaim etc. while this
> =A0 =A0new implementation gets away without all that.
>
> Test:
>
> The test consists of two concurrent kernel build jobs in separate
> source trees, the master and the slave. =A0The two jobs get along nicely
> on 600MB of available memory, so this is the zero overcommit control
> case. =A0When available memory is decreased, the overcommit is
> compensated by decreasing the soft limit of the slave by the same
> amount, in the hope that the slave takes the hit and the master stays
> unaffected.
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A060=
0M-0M-vanilla =A0 =A0 =A0 =A0 600M-0M-patched
> Master walltime (s) =A0 =A0 =A0 =A0 =A0 =A0 =A0 552.65 ( =A0+0.00%) =A0 =
=A0 =A0 552.38 ( =A0-0.05%)
> Master walltime (stddev) =A0 =A0 =A0 =A0 =A0 =A01.25 ( =A0+0.00%) =A0 =A0=
 =A0 =A0 0.92 ( -14.66%)
> Master major faults =A0 =A0 =A0 =A0 =A0 =A0 =A0 204.38 ( =A0+0.00%) =A0 =
=A0 =A0 205.38 ( =A0+0.49%)
> Master major faults (stddev) =A0 =A0 =A0 27.16 ( =A0+0.00%) =A0 =A0 =A0 =
=A013.80 ( -47.43%)
> Master reclaim =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 31.88 ( =A0+0.00%)=
 =A0 =A0 =A0 =A037.75 ( +17.87%)
> Master reclaim (stddev) =A0 =A0 =A0 =A0 =A0 =A034.01 ( =A0+0.00%) =A0 =A0=
 =A0 =A075.88 (+119.59%)
> Master scan =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A031.88 ( =A0+0.=
00%) =A0 =A0 =A0 =A037.75 ( +17.87%)
> Master scan (stddev) =A0 =A0 =A0 =A0 =A0 =A0 =A0 34.01 ( =A0+0.00%) =A0 =
=A0 =A0 =A075.88 (+119.59%)
> Master kswapd reclaim =A0 =A0 =A0 =A0 =A0 33922.12 ( =A0+0.00%) =A0 =A0 3=
3887.12 ( =A0-0.10%)
> Master kswapd reclaim (stddev) =A0 =A0969.08 ( =A0+0.00%) =A0 =A0 =A0 492=
.22 ( -49.16%)
> Master kswapd scan =A0 =A0 =A0 =A0 =A0 =A0 =A034085.75 ( =A0+0.00%) =A0 =
=A0 33985.75 ( =A0-0.29%)
> Master kswapd scan (stddev) =A0 =A0 =A01101.07 ( =A0+0.00%) =A0 =A0 =A0 5=
63.33 ( -48.79%)
> Slave walltime (s) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0552.68 ( =A0+0.00%) =A0=
 =A0 =A0 552.12 ( =A0-0.10%)
> Slave walltime (stddev) =A0 =A0 =A0 =A0 =A0 =A0 0.79 ( =A0+0.00%) =A0 =A0=
 =A0 =A0 1.05 ( +14.76%)
> Slave major faults =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0212.50 ( =A0+0.00%) =A0=
 =A0 =A0 204.50 ( =A0-3.75%)
> Slave major faults (stddev) =A0 =A0 =A0 =A026.90 ( =A0+0.00%) =A0 =A0 =A0=
 =A013.17 ( -49.20%)
> Slave reclaim =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A026.12 ( =A0+0.00=
%) =A0 =A0 =A0 =A035.00 ( +32.72%)
> Slave reclaim (stddev) =A0 =A0 =A0 =A0 =A0 =A0 29.42 ( =A0+0.00%) =A0 =A0=
 =A0 =A074.91 (+149.55%)
> Slave scan =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 31.38 ( =A0+0.=
00%) =A0 =A0 =A0 =A035.00 ( +11.20%)
> Slave scan (stddev) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A033.31 ( =A0+0.00%) =A0=
 =A0 =A0 =A074.91 (+121.24%)
> Slave kswapd reclaim =A0 =A0 =A0 =A0 =A0 =A034259.00 ( =A0+0.00%) =A0 =A0=
 33469.88 ( =A0-2.30%)
> Slave kswapd reclaim (stddev) =A0 =A0 925.15 ( =A0+0.00%) =A0 =A0 =A0 565=
.07 ( -38.88%)
> Slave kswapd scan =A0 =A0 =A0 =A0 =A0 =A0 =A0 34354.62 ( =A0+0.00%) =A0 =
=A0 33555.75 ( =A0-2.33%)
> Slave kswapd scan (stddev) =A0 =A0 =A0 =A0969.62 ( =A0+0.00%) =A0 =A0 =A0=
 581.70 ( -39.97%)
>
> In the control case, the differences in elapsed time, number of major
> faults taken, and reclaim statistics are within the noise for both the
> master and the slave job.

What's the soft limit setting in the controlled case?

I assume it is the default RESOURCE_MAX. So both Master and Slave get
equal pressure before/after the patch, and no differences on the stats
should be observed.


> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 6=
00M-280M-vanilla =A0 =A0 =A0600M-280M-patched
> Master walltime (s) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0595.13 ( =A0+0.00%=
) =A0 =A0 =A0553.19 ( =A0-7.04%)
> Master walltime (stddev) =A0 =A0 =A0 =A0 =A0 =A0 =A0 8.31 ( =A0+0.00%) =
=A0 =A0 =A0 =A02.57 ( -61.64%)
> Master major faults =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 3729.75 ( =A0+0.00%) =
=A0 =A0 =A0783.25 ( -78.98%)
> Master major faults (stddev) =A0 =A0 =A0 =A0 258.79 ( =A0+0.00%) =A0 =A0 =
=A0226.68 ( -12.36%)
> Master reclaim =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 705.00 ( =A0+0=
.00%) =A0 =A0 =A0 29.50 ( -95.68%)
> Master reclaim (stddev) =A0 =A0 =A0 =A0 =A0 =A0 =A0232.87 ( =A0+0.00%) =
=A0 =A0 =A0 44.72 ( -80.45%)
> Master scan =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0714.88 ( =
=A0+0.00%) =A0 =A0 =A0 30.00 ( -95.67%)
> Master scan (stddev) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 237.44 ( =A0+0.00%) =
=A0 =A0 =A0 45.39 ( -80.54%)
> Master kswapd reclaim =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0114.75 ( =A0+0.00%) =
=A0 =A0 =A0 50.00 ( -55.94%)
> Master kswapd reclaim (stddev) =A0 =A0 =A0 128.51 ( =A0+0.00%) =A0 =A0 =
=A0 =A09.45 ( -91.93%)
> Master kswapd scan =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 115.75 ( =A0+0.00%=
) =A0 =A0 =A0 50.00 ( -56.32%)
> Master kswapd scan (stddev) =A0 =A0 =A0 =A0 =A0130.31 ( =A0+0.00%) =A0 =
=A0 =A0 =A09.45 ( -92.04%)
> Slave walltime (s) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 631.18 ( =A0+0.00%=
) =A0 =A0 =A0577.68 ( =A0-8.46%)
> Slave walltime (stddev) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A09.89 ( =A0+0.00%) =
=A0 =A0 =A0 =A03.63 ( -57.47%)
> Slave major faults =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 28401.75 ( =A0+0.00%) =
=A0 =A014656.75 ( -48.39%)
> Slave major faults (stddev) =A0 =A0 =A0 =A0 2629.97 ( =A0+0.00%) =A0 =A0 =
1911.81 ( -27.30%)
> Slave reclaim =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A065400.62 ( =A0+0=
.00%) =A0 =A0 1479.62 ( -97.74%)
> Slave reclaim (stddev) =A0 =A0 =A0 =A0 =A0 =A0 11623.02 ( =A0+0.00%) =A0 =
=A0 1482.13 ( -87.24%)
> Slave scan =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 9050047.88 ( =A0+0=
.00%) =A0 =A095968.25 ( -98.94%)
> Slave scan (stddev) =A0 =A0 =A0 =A0 =A0 =A0 =A01912786.94 ( =A0+0.00%) =
=A0 =A093390.71 ( -95.12%)
> Slave kswapd reclaim =A0 =A0 =A0 =A0 =A0 =A0 =A0327894.50 ( =A0+0.00%) =
=A0 227099.88 ( -30.74%)
> Slave kswapd reclaim (stddev) =A0 =A0 =A022289.43 ( =A0+0.00%) =A0 =A0161=
13.14 ( -27.71%)
> Slave kswapd scan =A0 =A0 =A0 =A0 =A0 =A0 =A0 34987335.75 ( =A0+0.00%) =
=A01362367.12 ( -96.11%)
> Slave kswapd scan (stddev) =A0 =A0 =A0 2523642.98 ( =A0+0.00%) =A0 156754=
.74 ( -93.79%)
>
> Here, the available memory is limited to 320 MB, the machine is
> overcommitted by 280 MB. =A0The soft limit of the master is 300 MB, that
> of the slave merely 20 MB.
>
> Looking at the slave job first, it is much better off with the patched
> kernel: direct reclaim is almost gone, kswapd reclaim is decreased by
> a third. =A0The result is much fewer major faults taken, which in turn
> lets the job finish quicker.

What's the setting of the hard limit here? Is the direct reclaim
referring to per-memcg directly reclaim or global one.

>
> It would be a zero-sum game if the improvement happened at the cost of
> the master but looking at the numbers, even the master performs better
> with the patched kernel. =A0In fact, the master job is almost unaffected
> on the patched kernel compared to the control case.

It makes sense since the master job get less affected by the patch
than the slave job under the example. Under the control case, if both
master and slave have RESOURCE_MAX soft limit setting, they are under
equal memory pressure(priority =3D DEF_PRIORITY) . On the second
example, only the slave pressure being increased by priority =3D 0, and
the Master got scanned with same priority =3D DEF_PRIORITY pretty much.

So I would expect to see more reclaim activities happens in slave on
the patched kernel compared to the control case. It seems match the
testing result.

>
> This is an odd phenomenon, as the patch does not directly change how
> the master is reclaimed. =A0An explanation for this is that the severe
> overreclaim of the slave in the unpatched kernel results in the master
> growing bigger than in the patched case. =A0Combining the fact that
> memcgs are scanned according to their size with the increased refault
> rate of the overreclaimed slave triggering global reclaim more often
> means that overall pressure on the master job is higher in the
> unpatched kernel.

We can check the Master memory.usage_in_bytes while the job is running.

On the other hand, I don't see why we expect the Master being less
reclaimed in the controlled case? On the unpatched kernel, the Master
is being reclaimed under global pressure each time anyway since we
ignore the return value of softlimit.

>
> At any rate, the patched kernel seems to do a much better job at both
> overall resource allocation under soft limit overcommit as well as the
> requested prioritization of the master job.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
> =A0include/linux/memcontrol.h | =A0 18 +--
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0412 ++++------------------=
----------------------
> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 80 +--------
> =A03 files changed, 48 insertions(+), 462 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 6c1d69e..72368b7 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -121,6 +121,7 @@ struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat=
(struct mem_cgroup *memcg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct zone *zone);
> =A0struct zone_reclaim_stat*
> =A0mem_cgroup_get_reclaim_stat_from_page(struct page *page);
> +bool mem_cgroup_over_softlimit(struct mem_cgroup *, struct mem_cgroup *)=
;

Maybe something like "mem_cgroup_over_soft_limit()" ?

> =A0void mem_cgroup_account_reclaim(struct mem_cgroup *, struct mem_cgroup=
 *,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned l=
ong, unsigned long, bool);
> =A0extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
> @@ -155,9 +156,6 @@ static inline void mem_cgroup_dec_page_stat(struct pa=
ge *page,
> =A0 =A0 =A0 =A0mem_cgroup_update_page_stat(page, idx, -1);
> =A0}
>
> -unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order=
,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 unsigned long *total_scanned);
> =A0u64 mem_cgroup_get_limit(struct mem_cgroup *memcg);
>
> =A0void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_ite=
m idx);
> @@ -362,22 +360,20 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg,=
 struct task_struct *p)
> =A0{
> =A0}
>
> -static inline void mem_cgroup_inc_page_stat(struct page *page,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 enum mem_cgroup_page_stat_item idx)
> +static inline bool
> +mem_cgroup_over_softlimit(struct mem_cgroup *root, struct mem_cgroup *me=
mcg)
> =A0{
> + =A0 =A0 =A0 return false;
> =A0}
>
> -static inline void mem_cgroup_dec_page_stat(struct page *page,
> +static inline void mem_cgroup_inc_page_stat(struct page *page,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0enum mem_cgroup_page_stat_item idx)
> =A0{
> =A0}
>
> -static inline
> -unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order=
,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 gfp_t gfp_mask,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 unsigned long *total_scanned)
> +static inline void mem_cgroup_dec_page_stat(struct page *page,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 enum mem_cgroup_page_stat_item idx)
> =A0{
> - =A0 =A0 =A0 return 0;
> =A0}
>
> =A0static inline
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 170dff4..d4f7ae5 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -35,7 +35,6 @@
> =A0#include <linux/limits.h>
> =A0#include <linux/export.h>
> =A0#include <linux/mutex.h>
> -#include <linux/rbtree.h>
> =A0#include <linux/slab.h>
> =A0#include <linux/swap.h>
> =A0#include <linux/swapops.h>
> @@ -118,12 +117,10 @@ enum mem_cgroup_events_index {
> =A0*/
> =A0enum mem_cgroup_events_target {
> =A0 =A0 =A0 =A0MEM_CGROUP_TARGET_THRESH,
> - =A0 =A0 =A0 MEM_CGROUP_TARGET_SOFTLIMIT,
> =A0 =A0 =A0 =A0MEM_CGROUP_TARGET_NUMAINFO,
> =A0 =A0 =A0 =A0MEM_CGROUP_NTARGETS,
> =A0};
> =A0#define THRESHOLDS_EVENTS_TARGET (128)
> -#define SOFTLIMIT_EVENTS_TARGET (1024)
> =A0#define NUMAINFO_EVENTS_TARGET (1024)
>
> =A0struct mem_cgroup_stat_cpu {
> @@ -149,12 +146,6 @@ struct mem_cgroup_per_zone {
> =A0 =A0 =A0 =A0struct mem_cgroup_reclaim_iter reclaim_iter[DEF_PRIORITY +=
 1];
>
> =A0 =A0 =A0 =A0struct zone_reclaim_stat reclaim_stat;
> - =A0 =A0 =A0 struct rb_node =A0 =A0 =A0 =A0 =A0tree_node; =A0 =A0 =A0/* =
RB tree node */
> - =A0 =A0 =A0 unsigned long long =A0 =A0 =A0usage_in_excess;/* Set to the=
 value by which */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 /* the soft limit is exceeded*/
> - =A0 =A0 =A0 bool =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0on_tree;
> - =A0 =A0 =A0 struct mem_cgroup =A0 =A0 =A0 *mem; =A0 =A0 =A0 =A0 =A0 /* =
Back pointer, we cannot */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 /* use container_of =A0 =A0 =A0 =A0*/
> =A0};
> =A0/* Macro for accessing counter */
> =A0#define MEM_CGROUP_ZSTAT(mz, idx) =A0 =A0 =A0((mz)->count[(idx)])
> @@ -167,26 +158,6 @@ struct mem_cgroup_lru_info {
> =A0 =A0 =A0 =A0struct mem_cgroup_per_node *nodeinfo[MAX_NUMNODES];
> =A0};
>
> -/*
> - * Cgroups above their limits are maintained in a RB-Tree, independent o=
f
> - * their hierarchy representation
> - */
> -
> -struct mem_cgroup_tree_per_zone {
> - =A0 =A0 =A0 struct rb_root rb_root;
> - =A0 =A0 =A0 spinlock_t lock;
> -};
> -
> -struct mem_cgroup_tree_per_node {
> - =A0 =A0 =A0 struct mem_cgroup_tree_per_zone rb_tree_per_zone[MAX_NR_ZON=
ES];
> -};
> -
> -struct mem_cgroup_tree {
> - =A0 =A0 =A0 struct mem_cgroup_tree_per_node *rb_tree_per_node[MAX_NUMNO=
DES];
> -};
> -
> -static struct mem_cgroup_tree soft_limit_tree __read_mostly;
> -
> =A0struct mem_cgroup_threshold {
> =A0 =A0 =A0 =A0struct eventfd_ctx *eventfd;
> =A0 =A0 =A0 =A0u64 threshold;
> @@ -343,7 +314,6 @@ static bool move_file(void)
> =A0* limit reclaim to prevent infinite loops, if they ever occur.
> =A0*/
> =A0#define =A0 =A0 =A0 =A0MEM_CGROUP_MAX_RECLAIM_LOOPS =A0 =A0 =A0 =A0 =
=A0 =A0(100)
> -#define =A0 =A0 =A0 =A0MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS (2)

You might need to remove the comment above as well.
>
> =A0enum charge_type {
> =A0 =A0 =A0 =A0MEM_CGROUP_CHARGE_TYPE_CACHE =3D 0,
> @@ -398,164 +368,6 @@ page_cgroup_zoneinfo(struct mem_cgroup *memcg, stru=
ct page *page)
> =A0 =A0 =A0 =A0return mem_cgroup_zoneinfo(memcg, nid, zid);
> =A0}
>
> -static struct mem_cgroup_tree_per_zone *
> -soft_limit_tree_node_zone(int nid, int zid)
> -{
> - =A0 =A0 =A0 return &soft_limit_tree.rb_tree_per_node[nid]->rb_tree_per_=
zone[zid];
> -}
> -
> -static struct mem_cgroup_tree_per_zone *
> -soft_limit_tree_from_page(struct page *page)
> -{
> - =A0 =A0 =A0 int nid =3D page_to_nid(page);
> - =A0 =A0 =A0 int zid =3D page_zonenum(page);
> -
> - =A0 =A0 =A0 return &soft_limit_tree.rb_tree_per_node[nid]->rb_tree_per_=
zone[zid];
> -}
> -
> -static void
> -__mem_cgroup_insert_exceeded(struct mem_cgroup *memcg,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct mem_=
cgroup_per_zone *mz,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct mem_=
cgroup_tree_per_zone *mctz,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned lo=
ng long new_usage_in_excess)
> -{
> - =A0 =A0 =A0 struct rb_node **p =3D &mctz->rb_root.rb_node;
> - =A0 =A0 =A0 struct rb_node *parent =3D NULL;
> - =A0 =A0 =A0 struct mem_cgroup_per_zone *mz_node;
> -
> - =A0 =A0 =A0 if (mz->on_tree)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> -
> - =A0 =A0 =A0 mz->usage_in_excess =3D new_usage_in_excess;
> - =A0 =A0 =A0 if (!mz->usage_in_excess)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> - =A0 =A0 =A0 while (*p) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 parent =3D *p;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz_node =3D rb_entry(parent, struct mem_cgr=
oup_per_zone,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 tree_node);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mz->usage_in_excess < mz_node->usage_in=
_excess)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p =3D &(*p)->rb_left;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* We can't avoid mem cgroups that are ov=
er their soft
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* limit by the same amount
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 else if (mz->usage_in_excess >=3D mz_node->=
usage_in_excess)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p =3D &(*p)->rb_right;
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 rb_link_node(&mz->tree_node, parent, p);
> - =A0 =A0 =A0 rb_insert_color(&mz->tree_node, &mctz->rb_root);
> - =A0 =A0 =A0 mz->on_tree =3D true;
> -}
> -
> -static void
> -__mem_cgroup_remove_exceeded(struct mem_cgroup *memcg,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct mem_=
cgroup_per_zone *mz,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct mem_=
cgroup_tree_per_zone *mctz)
> -{
> - =A0 =A0 =A0 if (!mz->on_tree)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> - =A0 =A0 =A0 rb_erase(&mz->tree_node, &mctz->rb_root);
> - =A0 =A0 =A0 mz->on_tree =3D false;
> -}
> -
> -static void
> -mem_cgroup_remove_exceeded(struct mem_cgroup *memcg,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct mem_=
cgroup_per_zone *mz,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct mem_=
cgroup_tree_per_zone *mctz)
> -{
> - =A0 =A0 =A0 spin_lock(&mctz->lock);
> - =A0 =A0 =A0 __mem_cgroup_remove_exceeded(memcg, mz, mctz);
> - =A0 =A0 =A0 spin_unlock(&mctz->lock);
> -}
> -
> -
> -static void mem_cgroup_update_tree(struct mem_cgroup *memcg, struct page=
 *page)
> -{
> - =A0 =A0 =A0 unsigned long long excess;
> - =A0 =A0 =A0 struct mem_cgroup_per_zone *mz;
> - =A0 =A0 =A0 struct mem_cgroup_tree_per_zone *mctz;
> - =A0 =A0 =A0 int nid =3D page_to_nid(page);
> - =A0 =A0 =A0 int zid =3D page_zonenum(page);
> - =A0 =A0 =A0 mctz =3D soft_limit_tree_from_page(page);
> -
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* Necessary to update all ancestors when hierarchy is us=
ed.
> - =A0 =A0 =A0 =A0* because their event counter is not touched.
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 for (; memcg; memcg =3D parent_mem_cgroup(memcg)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz =3D mem_cgroup_zoneinfo(memcg, nid, zid)=
;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 excess =3D res_counter_soft_limit_excess(&m=
emcg->res);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* We have to update the tree if mz is on=
 RB-tree or
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* mem is over its softlimit.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (excess || mz->on_tree) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&mctz->lock);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* if on-tree, remove it */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mz->on_tree)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mem_cgrou=
p_remove_exceeded(memcg, mz, mctz);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Insert again. mz->usag=
e_in_excess will be updated.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If excess is 0, no tre=
e ops.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mem_cgroup_insert_exceede=
d(memcg, mz, mctz, excess);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&mctz->lock);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 }
> -}
> -
> -static void mem_cgroup_remove_from_trees(struct mem_cgroup *memcg)
> -{
> - =A0 =A0 =A0 int node, zone;
> - =A0 =A0 =A0 struct mem_cgroup_per_zone *mz;
> - =A0 =A0 =A0 struct mem_cgroup_tree_per_zone *mctz;
> -
> - =A0 =A0 =A0 for_each_node_state(node, N_POSSIBLE) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (zone =3D 0; zone < MAX_NR_ZONES; zone+=
+) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz =3D mem_cgroup_zoneinfo(=
memcg, node, zone);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mctz =3D soft_limit_tree_no=
de_zone(node, zone);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_remove_exceeded(=
memcg, mz, mctz);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 }
> -}
> -
> -static struct mem_cgroup_per_zone *
> -__mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_zone *mc=
tz)
> -{
> - =A0 =A0 =A0 struct rb_node *rightmost =3D NULL;
> - =A0 =A0 =A0 struct mem_cgroup_per_zone *mz;
> -
> -retry:
> - =A0 =A0 =A0 mz =3D NULL;
> - =A0 =A0 =A0 rightmost =3D rb_last(&mctz->rb_root);
> - =A0 =A0 =A0 if (!rightmost)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto done; =A0 =A0 =A0 =A0 =A0 =A0 =A0/* No=
thing to reclaim from */
> -
> - =A0 =A0 =A0 mz =3D rb_entry(rightmost, struct mem_cgroup_per_zone, tree=
_node);
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* Remove the node now but someone else can add it back,
> - =A0 =A0 =A0 =A0* we will to add it back at the end of reclaim to its co=
rrect
> - =A0 =A0 =A0 =A0* position in the tree.
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 __mem_cgroup_remove_exceeded(mz->mem, mz, mctz);
> - =A0 =A0 =A0 if (!res_counter_soft_limit_excess(&mz->mem->res) ||
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 !css_tryget(&mz->mem->css))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto retry;
> -done:
> - =A0 =A0 =A0 return mz;
> -}
> -
> -static struct mem_cgroup_per_zone *
> -mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_zone *mctz=
)
> -{
> - =A0 =A0 =A0 struct mem_cgroup_per_zone *mz;
> -
> - =A0 =A0 =A0 spin_lock(&mctz->lock);
> - =A0 =A0 =A0 mz =3D __mem_cgroup_largest_soft_limit_node(mctz);
> - =A0 =A0 =A0 spin_unlock(&mctz->lock);
> - =A0 =A0 =A0 return mz;
> -}
> -
> =A0/*
> =A0* Implementation Note: reading percpu statistics for memcg.
> =A0*
> @@ -696,9 +508,6 @@ static bool mem_cgroup_event_ratelimit(struct mem_cgr=
oup *memcg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case MEM_CGROUP_TARGET_THRESH:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0next =3D val + THRESHOLDS_=
EVENTS_TARGET;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case MEM_CGROUP_TARGET_SOFTLIMIT:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 next =3D val + SOFTLIMIT_EV=
ENTS_TARGET;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case MEM_CGROUP_TARGET_NUMAINFO:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0next =3D val + NUMAINFO_EV=
ENTS_TARGET;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> @@ -718,13 +527,11 @@ static bool mem_cgroup_event_ratelimit(struct mem_c=
group *memcg,
> =A0static void memcg_check_events(struct mem_cgroup *memcg, struct page *=
page)
> =A0{
> =A0 =A0 =A0 =A0preempt_disable();
> - =A0 =A0 =A0 /* threshold event is triggered in finer grain than soft li=
mit */
> + =A0 =A0 =A0 /* threshold event is triggered in finer grain than numa in=
fo */
> =A0 =A0 =A0 =A0if (unlikely(mem_cgroup_event_ratelimit(memcg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0MEM_CGROUP_TARGET_THRESH))) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool do_softlimit, do_numainfo;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool do_numainfo;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_softlimit =3D mem_cgroup_event_ratelimit=
(memcg,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 MEM_CGROUP_TARGET_SOFTLIMIT);
> =A0#if MAX_NUMNODES > 1
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0do_numainfo =3D mem_cgroup_event_ratelimit=
(memcg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0MEM_CGROUP_TARGET_NUMAINFO);
> @@ -732,8 +539,6 @@ static void memcg_check_events(struct mem_cgroup *mem=
cg, struct page *page)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0preempt_enable();
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_threshold(memcg);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(do_softlimit))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_update_tree(memc=
g, page);
> =A0#if MAX_NUMNODES > 1
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (unlikely(do_numainfo))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0atomic_inc(&memcg->numainf=
o_events);
> @@ -1318,6 +1123,36 @@ static unsigned long mem_cgroup_margin(struct mem_=
cgroup *memcg)
> =A0 =A0 =A0 =A0return margin >> PAGE_SHIFT;
> =A0}
>
> +/**
> + * mem_cgroup_over_softlimit
> + * @root: hierarchy root
> + * @memcg: child of @root to test
> + *
> + * Returns %true if @memcg exceeds its own soft limit or contributes
> + * to the soft limit excess of one of its parents up to and including
> + * @root.
> + */
> +bool mem_cgroup_over_softlimit(struct mem_cgroup *root,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct mem_c=
group *memcg)
> +{
> + =A0 =A0 =A0 if (mem_cgroup_disabled())
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
> +
> + =A0 =A0 =A0 if (!root)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 root =3D root_mem_cgroup;
> +
> + =A0 =A0 =A0 for (; memcg; memcg =3D parent_mem_cgroup(memcg)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* root_mem_cgroup does not have a soft lim=
it */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (memcg =3D=3D root_mem_cgroup)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (res_counter_soft_limit_excess(&memcg->r=
es))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (memcg =3D=3D root)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 }

Here it adds pressure on a cgroup if one of its parents exceeds soft
limit, although the cgroup itself is under soft limit. It does change
my understanding of soft limit, and might introduce regression of our
existing use cases.

Here is an example:

Machine capacity 32G and we over-commit by 8G.

root
  -> A (hard limit 20G, soft limit 15G, usage 16G)
       -> A1 (soft limit 5G, usage 4G)
       -> A2 (soft limit 10G, usage 12G)
  -> B (hard limit 20G, soft limit 10G, usage 16G)

under global reclaim, we don't want to add pressure on A1 although its
parent A exceeds its soft limit. Assume that if we set the soft limit
corresponding to each cgroup's working set size (hot memory), and it
will introduce regression to A1 in that case.

In my existing implementation, i am checking the cgroup's soft limit
standalone w/o looking its ancestors.

> + =A0 =A0 =A0 return false;
> +}
> +
> =A0int mem_cgroup_swappiness(struct mem_cgroup *memcg)
> =A0{
> =A0 =A0 =A0 =A0struct cgroup *cgrp =3D memcg->css.cgroup;
> @@ -1687,64 +1522,6 @@ bool mem_cgroup_reclaimable(struct mem_cgroup *mem=
cg, bool noswap)
> =A0}
> =A0#endif
>
> -static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_memcg,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stru=
ct zone *zone,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0gfp_=
t gfp_mask,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsi=
gned long *total_scanned)
> -{
> - =A0 =A0 =A0 struct mem_cgroup *victim =3D NULL;
> - =A0 =A0 =A0 int total =3D 0;
> - =A0 =A0 =A0 int loop =3D 0;
> - =A0 =A0 =A0 unsigned long excess;
> - =A0 =A0 =A0 unsigned long nr_scanned;
> - =A0 =A0 =A0 struct mem_cgroup_reclaim_cookie reclaim =3D {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .zone =3D zone,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .priority =3D 0,
> - =A0 =A0 =A0 };
> -
> - =A0 =A0 =A0 excess =3D res_counter_soft_limit_excess(&root_memcg->res) =
>> PAGE_SHIFT;
> -
> - =A0 =A0 =A0 while (1) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_reclaimed;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 victim =3D mem_cgroup_iter(root_memcg, vict=
im, &reclaim);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!victim) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 loop++;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (loop >=3D 2) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If we =
have not been able to reclaim
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* anythi=
ng, it might because there are
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* no rec=
laimable pages under this hierarchy
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!total)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* We wan=
t to do more targeted reclaim.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* excess=
 >> 2 is not to excessive so as to
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* reclai=
m too much, nor too less that we keep
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* coming=
 back to reclaim from this cgroup
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (total >=
=3D (excess >> 2) ||
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 (loop > MEM_CGROUP_MAX_RECLAIM_LOOPS))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!mem_cgroup_reclaimable(victim, false))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_reclaimed =3D mem_cgroup_shrink_node_zon=
e(victim, gfp_mask, false,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone, &nr_scanned);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_account_reclaim(root_mem_cgroup,=
 victim, nr_reclaimed,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0nr_scanned, current_is_kswapd());
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 total +=3D nr_reclaimed;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 *total_scanned +=3D nr_scanned;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!res_counter_soft_limit_excess(&root_me=
mcg->res))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 mem_cgroup_iter_break(root_memcg, victim);
> - =A0 =A0 =A0 return total;
> -}
> -
> =A0/*
> =A0* Check OOM-Killer is already running under our hierarchy.
> =A0* If someone is running, return false.
> @@ -2507,8 +2284,6 @@ static void __mem_cgroup_commit_charge(struct mem_c=
group *memcg,
> =A0 =A0 =A0 =A0unlock_page_cgroup(pc);
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * "charge_statistics" updated event counter. Then, check =
it.
> - =A0 =A0 =A0 =A0* Insert ancestor (and ancestor's ancestors), to softlim=
it RB-tree.
> - =A0 =A0 =A0 =A0* if they exceeds softlimit.
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0memcg_check_events(memcg, page);
> =A0}
> @@ -3578,98 +3353,6 @@ static int mem_cgroup_resize_memsw_limit(struct me=
m_cgroup *memcg,
> =A0 =A0 =A0 =A0return ret;
> =A0}
>
> -unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order=
,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 gfp_t gfp_mask,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 unsigned long *total_scanned)
> -{
> - =A0 =A0 =A0 unsigned long nr_reclaimed =3D 0;
> - =A0 =A0 =A0 struct mem_cgroup_per_zone *mz, *next_mz =3D NULL;
> - =A0 =A0 =A0 unsigned long reclaimed;
> - =A0 =A0 =A0 int loop =3D 0;
> - =A0 =A0 =A0 struct mem_cgroup_tree_per_zone *mctz;
> - =A0 =A0 =A0 unsigned long long excess;
> - =A0 =A0 =A0 unsigned long nr_scanned;
> -
> - =A0 =A0 =A0 if (order > 0)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> -
> - =A0 =A0 =A0 mctz =3D soft_limit_tree_node_zone(zone_to_nid(zone), zone_=
idx(zone));
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* This loop can run a while, specially if mem_cgroup's c=
ontinuously
> - =A0 =A0 =A0 =A0* keep exceeding their soft limit and putting the system=
 under
> - =A0 =A0 =A0 =A0* pressure
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 do {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (next_mz)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz =3D next_mz;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz =3D mem_cgroup_largest_s=
oft_limit_node(mctz);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!mz)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_scanned =3D 0;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 reclaimed =3D mem_cgroup_soft_reclaim(mz->m=
em, zone,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 gfp_mask, &nr_scanned);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_reclaimed +=3D reclaimed;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 *total_scanned +=3D nr_scanned;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&mctz->lock);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If we failed to reclaim anything from =
this memory cgroup
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* it is time to move on to the next cgro=
up
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 next_mz =3D NULL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!reclaimed) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 do {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Loop u=
ntil we find yet another one.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* By the=
 time we get the soft_limit lock
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* again,=
 someone might have aded the
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* group =
back on the RB tree. Iterate to
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* make s=
ure we get a different mem.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* mem_cg=
roup_largest_soft_limit_node returns
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* NULL i=
f no other cgroup is present on
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* the tr=
ee
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 next_mz =3D
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mem_cgrou=
p_largest_soft_limit_node(mctz);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (next_mz=
 =3D=3D mz)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 css_put(&next_mz->mem->css);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else /* nex=
t_mz =3D=3D NULL or other memcg */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } while (1);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mem_cgroup_remove_exceeded(mz->mem, mz, m=
ctz);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 excess =3D res_counter_soft_limit_excess(&m=
z->mem->res);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* One school of thought says that we sho=
uld not add
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* back the node to the tree if reclaim r=
eturns 0.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* But our reclaim could return 0, simply=
 because due
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* to priority we are exposing a smaller =
subset of
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* memory to reclaim from. Consider this =
as a longer
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* term TODO.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* If excess =3D=3D 0, no tree ops */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mem_cgroup_insert_exceeded(mz->mem, mz, m=
ctz, excess);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&mctz->lock);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 css_put(&mz->mem->css);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 loop++;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Could not reclaim anything and there a=
re no more
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* mem cgroups to try or we seem to be lo=
oping without
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* reclaiming anything.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!nr_reclaimed &&
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (next_mz =3D=3D NULL ||
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 loop > MEM_CGROUP_MAX_SOFT_=
LIMIT_RECLAIM_LOOPS))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 } while (!nr_reclaimed);
> - =A0 =A0 =A0 if (next_mz)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 css_put(&next_mz->mem->css);
> - =A0 =A0 =A0 return nr_reclaimed;
> -}
> -
> =A0/*
> =A0* This routine traverse page_cgroup in given list and drop them all.
> =A0* *And* this routine doesn't reclaim page itself, just removes page_cg=
roup.
> @@ -4816,9 +4499,6 @@ static int alloc_mem_cgroup_per_zone_info(struct me=
m_cgroup *memcg, int node)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mz =3D &pn->zoneinfo[zone];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for_each_lru(l)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0INIT_LIST_HEAD(&mz->lruvec=
.lists[l]);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz->usage_in_excess =3D 0;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz->on_tree =3D false;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz->mem =3D memcg;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0memcg->info.nodeinfo[node] =3D pn;
> =A0 =A0 =A0 =A0return 0;
> @@ -4872,7 +4552,6 @@ static void __mem_cgroup_free(struct mem_cgroup *me=
mcg)
> =A0{
> =A0 =A0 =A0 =A0int node;
>
> - =A0 =A0 =A0 mem_cgroup_remove_from_trees(memcg);
> =A0 =A0 =A0 =A0free_css_id(&mem_cgroup_subsys, &memcg->css);
>
> =A0 =A0 =A0 =A0for_each_node_state(node, N_POSSIBLE)
> @@ -4927,31 +4606,6 @@ static void __init enable_swap_cgroup(void)
> =A0}
> =A0#endif
>
> -static int mem_cgroup_soft_limit_tree_init(void)
> -{
> - =A0 =A0 =A0 struct mem_cgroup_tree_per_node *rtpn;
> - =A0 =A0 =A0 struct mem_cgroup_tree_per_zone *rtpz;
> - =A0 =A0 =A0 int tmp, node, zone;
> -
> - =A0 =A0 =A0 for_each_node_state(node, N_POSSIBLE) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 tmp =3D node;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!node_state(node, N_NORMAL_MEMORY))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tmp =3D -1;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rtpn =3D kzalloc_node(sizeof(*rtpn), GFP_KE=
RNEL, tmp);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!rtpn)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 soft_limit_tree.rb_tree_per_node[node] =3D =
rtpn;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (zone =3D 0; zone < MAX_NR_ZONES; zone+=
+) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rtpz =3D &rtpn->rb_tree_per=
_zone[zone];
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rtpz->rb_root =3D RB_ROOT;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_init(&rtpz->lock)=
;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 return 0;
> -}
> -
> =A0static struct cgroup_subsys_state * __ref
> =A0mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
> =A0{
> @@ -4973,8 +4627,6 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct =
cgroup *cont)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enable_swap_cgroup();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0parent =3D NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0root_mem_cgroup =3D memcg;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_soft_limit_tree_init())
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto free_out;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for_each_possible_cpu(cpu) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct memcg_stock_pcp *st=
ock =3D
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0&per_cpu(memcg_stock, cpu);
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index e3fd8a7..4279549 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2121,8 +2121,16 @@ static void shrink_zone(int priority, struct zone =
*zone,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.mem_cgroup =3D memcg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.zone =3D zone,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0};
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int epriority =3D priority;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Put more pressure on hierarchies that =
exceed their
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* soft limit, to push them back harder t=
han their
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* well-behaving siblings.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_over_softlimit(root, memcg))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 epriority =3D 0;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_mem_cgroup_zone(priority, &mz, sc);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_mem_cgroup_zone(epriority, &mz, sc);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_account_reclaim(root, memcg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 sc->nr_reclaimed - nr_reclaimed,
> @@ -2171,8 +2179,6 @@ static bool shrink_zones(int priority, struct zonel=
ist *zonelist,
> =A0{
> =A0 =A0 =A0 =A0struct zoneref *z;
> =A0 =A0 =A0 =A0struct zone *zone;
> - =A0 =A0 =A0 unsigned long nr_soft_reclaimed;
> - =A0 =A0 =A0 unsigned long nr_soft_scanned;
> =A0 =A0 =A0 =A0bool should_abort_reclaim =3D false;
>
> =A0 =A0 =A0 =A0for_each_zone_zonelist_nodemask(zone, z, zonelist,
> @@ -2205,19 +2211,6 @@ static bool shrink_zones(int priority, struct zone=
list *zonelist,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* This steals pages from=
 memory cgroups over softlimit
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* and returns the number=
 of reclaimed pages and
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* scanned pages. This wo=
rks for global memory pressure
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* and balancing, not for=
 a memcg's limit.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_soft_scanned =3D 0;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_soft_reclaimed =3D mem_c=
group_soft_limit_reclaim(zone,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 sc->order, sc->gfp_mask,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 &nr_soft_scanned);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->nr_reclaimed +=3D nr_so=
ft_reclaimed;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->nr_scanned +=3D nr_soft=
_scanned;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* need some check for avoi=
d more shrink_zone() */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0shrink_zone(priority, zone, sc);
> @@ -2393,48 +2386,6 @@ unsigned long try_to_free_pages(struct zonelist *z=
onelist, int order,
> =A0}
>
> =A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> -
> -unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask, bool noswap,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct zone *zone,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 unsigned long *nr_scanned)
> -{
> - =A0 =A0 =A0 struct scan_control sc =3D {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .nr_scanned =3D 0,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .nr_to_reclaim =3D SWAP_CLUSTER_MAX,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .may_writepage =3D !laptop_mode,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .may_unmap =3D 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .may_swap =3D !noswap,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .order =3D 0,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .target_mem_cgroup =3D memcg,
> - =A0 =A0 =A0 };
> - =A0 =A0 =A0 struct mem_cgroup_zone mz =3D {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mem_cgroup =3D memcg,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .zone =3D zone,
> - =A0 =A0 =A0 };
> -
> - =A0 =A0 =A0 sc.gfp_mask =3D (gfp_mask & GFP_RECLAIM_MASK) |
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (GFP_HIGHUSER_MOVABLE & ~GF=
P_RECLAIM_MASK);
> -
> - =A0 =A0 =A0 trace_mm_vmscan_memcg_softlimit_reclaim_begin(0,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc.may_writepage,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc.gfp_mask);
> -
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* NOTE: Although we can get the priority field, using it
> - =A0 =A0 =A0 =A0* here is not a good idea, since it limits the pages we =
can scan.
> - =A0 =A0 =A0 =A0* if we don't reclaim here, the shrink_zone from balance=
_pgdat
> - =A0 =A0 =A0 =A0* will pick up pages from other mem cgroup's as well. We=
 hack
> - =A0 =A0 =A0 =A0* the priority and make it zero.
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 shrink_mem_cgroup_zone(0, &mz, &sc);
> -
> - =A0 =A0 =A0 trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed=
);
> -
> - =A0 =A0 =A0 *nr_scanned =3D sc.nr_scanned;
> - =A0 =A0 =A0 return sc.nr_reclaimed;
> -}
> -
> =A0unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 gfp_t gfp_mask,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 bool noswap)
> @@ -2609,8 +2560,6 @@ static unsigned long balance_pgdat(pg_data_t *pgdat=
, int order,
> =A0 =A0 =A0 =A0int end_zone =3D 0; =A0 =A0 =A0 /* Inclusive. =A00 =3D ZON=
E_DMA */
> =A0 =A0 =A0 =A0unsigned long total_scanned;
> =A0 =A0 =A0 =A0struct reclaim_state *reclaim_state =3D current->reclaim_s=
tate;
> - =A0 =A0 =A0 unsigned long nr_soft_reclaimed;
> - =A0 =A0 =A0 unsigned long nr_soft_scanned;
> =A0 =A0 =A0 =A0struct scan_control sc =3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.gfp_mask =3D GFP_KERNEL,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.may_unmap =3D 1,
> @@ -2701,17 +2650,6 @@ loop_again:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc.nr_scanned =3D 0;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_soft_scanned =3D 0;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Call soft limit reclai=
m before calling shrink_zone.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_soft_reclaimed =3D mem_c=
group_soft_limit_reclaim(zone,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order, sc.gfp_mask,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &nr_soft_scanned);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc.nr_reclaimed +=3D nr_sof=
t_reclaimed;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned +=3D nr_soft_=
scanned;
> -
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * We put equal pressure o=
n every zone, unless
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * one zone has way too ma=
ny pages free
> --
> 1.7.7.5
>

--Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
