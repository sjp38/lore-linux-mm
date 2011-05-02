Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id EAC486B0022
	for <linux-mm@kvack.org>; Mon,  2 May 2011 12:52:42 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id p42GqcVB030257
	for <linux-mm@kvack.org>; Mon, 2 May 2011 09:52:38 -0700
Received: from qwa26 (qwa26.prod.google.com [10.241.193.26])
	by kpbe11.cbf.corp.google.com with ESMTP id p42GqaPf007662
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 2 May 2011 09:52:37 -0700
Received: by qwa26 with SMTP id 26so3961388qwa.14
        for <linux-mm@kvack.org>; Mon, 02 May 2011 09:52:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1304355025-1421-3-git-send-email-yinghan@google.com>
References: <1304355025-1421-1-git-send-email-yinghan@google.com>
	<1304355025-1421-3-git-send-email-yinghan@google.com>
Date: Mon, 2 May 2011 09:52:36 -0700
Message-ID: <BANLkTi=V3Pj20u75E9o5HgFD+b4oX=ckXQ@mail.gmail.com>
Subject: Re: [PATCH V2 2/2] Add stats to monitor soft_limit reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>

On Mon, May 2, 2011 at 9:50 AM, Ying Han <yinghan@google.com> wrote:
> This patch extend the soft_limit reclaim stats to both global background
> reclaim and global direct reclaim.
>
> The following stats are renamed and added:
>
> $cat /dev/cgroup/memory/A/memory.stat
> soft_kswapd_steal 1053626
> soft_kswapd_scan 1053693
> soft_direct_steal 1481810
> soft_direct_scan 1481996
>
> changelog v2..v1:
> 1. rename the stats on soft_kswapd/direct_steal/scan.
> 2. fix the documentation to match the stat name.
>
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
> =A0Documentation/cgroups/memory.txt | =A0 16 +++++++--
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 68 ++++++++++=
++++++++++++++++++----------
> =A02 files changed, 62 insertions(+), 22 deletions(-)
>
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/mem=
ory.txt
> index 0c40dab..575cf33 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -387,8 +387,14 @@ pgpgout =A0 =A0 =A0 =A0 =A0 =A0- # of pages paged ou=
t (equivalent to # of uncharging events).
> =A0swap =A0 =A0 =A0 =A0 =A0 - # of bytes of swap usage
> =A0pgfault =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0- # of page faults.
> =A0pgmajfault =A0 =A0 - # of major page faults.
> -soft_steal =A0 =A0 - # of pages reclaimed from global hierarchical recla=
im
> -soft_scan =A0 =A0 =A0- # of pages scanned from global hierarchical recla=
im
> +soft_kswapd_steal- # of pages reclaimed in global hierarchical reclaim f=
rom
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 background reclaim
> +soft_kswapd_scan - # of pages scanned in global hierarchical reclaim fro=
m
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 background reclaim
> +soft_direct_steal- # of pages reclaimed in global hierarchical reclaim f=
rom
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 direct reclaim
> +soft_direct_scan- # of pages scanned in global hierarchical reclaim from
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 direct reclaim
> =A0inactive_anon =A0- # of bytes of anonymous memory and swap cache memor=
y on
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0LRU list.
> =A0active_anon =A0 =A0- # of bytes of anonymous and swap cache memory on =
active
> @@ -412,8 +418,10 @@ total_pgpgout =A0 =A0 =A0 =A0 =A0 =A0 =A0- sum of al=
l children's "pgpgout"
> =A0total_swap =A0 =A0 =A0 =A0 =A0 =A0 - sum of all children's "swap"
> =A0total_pgfault =A0 =A0 =A0 =A0 =A0- sum of all children's "pgfault"
> =A0total_pgmajfault =A0 =A0 =A0 - sum of all children's "pgmajfault"
> -total_soft_steal =A0 =A0 =A0 - sum of all children's "soft_steal"
> -total_soft_scan =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0- sum of all children's "=
soft_scan"
> +total_soft_kswapd_steal =A0 =A0 =A0 =A0- sum of all children's "soft_ksw=
apd_steal"
> +total_soft_kswapd_scan - sum of all children's "soft_kswapd_scan"
> +total_soft_direct_steal =A0 =A0 =A0 =A0- sum of all children's "soft_dir=
ect_steal"
> +total_soft_direct_scan - sum of all children's "soft_direct_scan"
> =A0total_inactive_anon =A0 =A0- sum of all children's "inactive_anon"
> =A0total_active_anon =A0 =A0 =A0- sum of all children's "active_anon"
> =A0total_inactive_file =A0 =A0- sum of all children's "inactive_file"
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index c2776f1..da1fb2b 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -96,10 +96,14 @@ enum mem_cgroup_events_index {
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
> + =A0 =A0 =A0 MEM_CGROUP_EVENTS_SOFT_KSWAPD_STEAL, /* # of pages reclaime=
d from */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 /* soft reclaim in background reclaim */
> + =A0 =A0 =A0 MEM_CGROUP_EVENTS_SOFT_KSWAPD_SCAN, /* # of pages scanned f=
rom */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 /* soft reclaim in background reclaim */
> + =A0 =A0 =A0 MEM_CGROUP_EVENTS_SOFT_DIRECT_STEAL, /* # of pages reclaime=
d from */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 /* soft reclaim in direct reclaim */
> + =A0 =A0 =A0 MEM_CGROUP_EVENTS_SOFT_DIRECT_SCAN, /* # of pages scanned f=
rom */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 /* soft reclaim in direct reclaim */
> =A0 =A0 =A0 =A0MEM_CGROUP_EVENTS_NSTATS,
> =A0};
> =A0/*
> @@ -640,14 +644,30 @@ static void mem_cgroup_charge_statistics(struct mem=
_cgroup *mem,
> =A0 =A0 =A0 =A0preempt_enable();
> =A0}
>
> -static void mem_cgroup_soft_steal(struct mem_cgroup *mem, int val)
> +static void mem_cgroup_soft_steal(struct mem_cgroup *mem, bool is_kswapd=
,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int val=
)
> =A0{
> - =A0 =A0 =A0 this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_SOFT_STEAL=
], val);
> + =A0 =A0 =A0 if (is_kswapd)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 this_cpu_add(
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem->stat->events[MEM_CGROU=
P_EVENTS_SOFT_KSWAPD_STEAL],
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 val);
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 this_cpu_add(
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem->stat->events[MEM_CGROU=
P_EVENTS_SOFT_DIRECT_STEAL],
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 val);
> =A0}
>
> -static void mem_cgroup_soft_scan(struct mem_cgroup *mem, int val)
> +static void mem_cgroup_soft_scan(struct mem_cgroup *mem, bool is_kswapd,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int val)
> =A0{
> - =A0 =A0 =A0 this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_SOFT_SCAN]=
, val);
> + =A0 =A0 =A0 if (is_kswapd)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 this_cpu_add(
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem->stat->events[MEM_CGROU=
P_EVENTS_SOFT_KSWAPD_SCAN],
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 val);
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 this_cpu_add(
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem->stat->events[MEM_CGROU=
P_EVENTS_SOFT_DIRECT_SCAN],
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 val);
> =A0}
>
> =A0static unsigned long mem_cgroup_get_local_zonestat(struct mem_cgroup *=
mem,
> @@ -1495,6 +1515,7 @@ static int mem_cgroup_hierarchical_reclaim(struct m=
em_cgroup *root_mem,
> =A0 =A0 =A0 =A0bool noswap =3D reclaim_options & MEM_CGROUP_RECLAIM_NOSWA=
P;
> =A0 =A0 =A0 =A0bool shrink =3D reclaim_options & MEM_CGROUP_RECLAIM_SHRIN=
K;
> =A0 =A0 =A0 =A0bool check_soft =3D reclaim_options & MEM_CGROUP_RECLAIM_S=
OFT;
> + =A0 =A0 =A0 bool is_kswapd =3D false;
> =A0 =A0 =A0 =A0unsigned long excess;
> =A0 =A0 =A0 =A0unsigned long nr_scanned;
>
> @@ -1504,6 +1525,9 @@ static int mem_cgroup_hierarchical_reclaim(struct m=
em_cgroup *root_mem,
> =A0 =A0 =A0 =A0if (root_mem->memsw_is_minimum)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0noswap =3D true;
>
> + =A0 =A0 =A0 if (current_is_kswapd())
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 is_kswapd =3D true;
> +
> =A0 =A0 =A0 =A0while (1) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0victim =3D mem_cgroup_select_victim(root_m=
em);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (victim =3D=3D root_mem) {
> @@ -1544,8 +1568,8 @@ static int mem_cgroup_hierarchical_reclaim(struct m=
em_cgroup *root_mem,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0noswap, ge=
t_swappiness(victim), zone,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&nr_scanne=
d);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*total_scanned +=3D nr_sca=
nned;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_soft_steal(victi=
m, ret);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_soft_scan(victim=
, nr_scanned);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_soft_steal(victi=
m, is_kswapd, ret);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_soft_scan(victim=
, is_kswapd, nr_scanned);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D try_to_free_mem_cg=
roup_pages(victim, gfp_mask,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0noswap, get_swappiness(victim));
> @@ -3840,8 +3864,10 @@ enum {
> =A0 =A0 =A0 =A0MCS_SWAP,
> =A0 =A0 =A0 =A0MCS_PGFAULT,
> =A0 =A0 =A0 =A0MCS_PGMAJFAULT,
> - =A0 =A0 =A0 MCS_SOFT_STEAL,
> - =A0 =A0 =A0 MCS_SOFT_SCAN,
> + =A0 =A0 =A0 MCS_SOFT_KSWAPD_STEAL,
> + =A0 =A0 =A0 MCS_SOFT_KSWAPD_SCAN,
> + =A0 =A0 =A0 MCS_SOFT_DIRECT_STEAL,
> + =A0 =A0 =A0 MCS_SOFT_DIRECT_SCAN,
> =A0 =A0 =A0 =A0MCS_INACTIVE_ANON,
> =A0 =A0 =A0 =A0MCS_ACTIVE_ANON,
> =A0 =A0 =A0 =A0MCS_INACTIVE_FILE,
> @@ -3866,8 +3892,10 @@ struct {
> =A0 =A0 =A0 =A0{"swap", "total_swap"},
> =A0 =A0 =A0 =A0{"pgfault", "total_pgfault"},
> =A0 =A0 =A0 =A0{"pgmajfault", "total_pgmajfault"},
> - =A0 =A0 =A0 {"soft_steal", "total_soft_steal"},
> - =A0 =A0 =A0 {"soft_scan", "total_soft_scan"},
> + =A0 =A0 =A0 {"soft_kswapd_steal", "total_soft_kswapd_steal"},
> + =A0 =A0 =A0 {"soft_kswapd_scan", "total_soft_kswapd_scan"},
> + =A0 =A0 =A0 {"soft_direct_steal", "total_soft_direct_steal"},
> + =A0 =A0 =A0 {"soft_direct_scan", "total_soft_direct_scan"},
> =A0 =A0 =A0 =A0{"inactive_anon", "total_inactive_anon"},
> =A0 =A0 =A0 =A0{"active_anon", "total_active_anon"},
> =A0 =A0 =A0 =A0{"inactive_file", "total_inactive_file"},
> @@ -3896,10 +3924,14 @@ mem_cgroup_get_local_stat(struct mem_cgroup *mem,=
 struct mcs_total_stat *s)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0val =3D mem_cgroup_read_stat(mem, MEM_CGRO=
UP_STAT_SWAPOUT);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0s->stat[MCS_SWAP] +=3D val * PAGE_SIZE;
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 val =3D mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_SOFT_=
STEAL);
> - =A0 =A0 =A0 s->stat[MCS_SOFT_STEAL] +=3D val;
> - =A0 =A0 =A0 val =3D mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_SOFT_=
SCAN);
> - =A0 =A0 =A0 s->stat[MCS_SOFT_SCAN] +=3D val;
> + =A0 =A0 =A0 val =3D mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_SOFT_=
KSWAPD_STEAL);
> + =A0 =A0 =A0 s->stat[MCS_SOFT_KSWAPD_STEAL] +=3D val;
> + =A0 =A0 =A0 val =3D mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_SOFT_=
KSWAPD_SCAN);
> + =A0 =A0 =A0 s->stat[MCS_SOFT_KSWAPD_SCAN] +=3D val;
> + =A0 =A0 =A0 val =3D mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_SOFT_=
DIRECT_STEAL);
> + =A0 =A0 =A0 s->stat[MCS_SOFT_DIRECT_STEAL] +=3D val;
> + =A0 =A0 =A0 val =3D mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_SOFT_=
DIRECT_SCAN);
> + =A0 =A0 =A0 s->stat[MCS_SOFT_DIRECT_SCAN] +=3D val;
> =A0 =A0 =A0 =A0val =3D mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_PGFA=
ULT);
> =A0 =A0 =A0 =A0s->stat[MCS_PGFAULT] +=3D val;
> =A0 =A0 =A0 =A0val =3D mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_PGMA=
JFAULT);
> --
> 1.7.3.1
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
