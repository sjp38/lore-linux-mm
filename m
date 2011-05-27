Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 520D66B0022
	for <linux-mm@kvack.org>; Thu, 26 May 2011 21:22:24 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id p4R1MJZU000473
	for <linux-mm@kvack.org>; Thu, 26 May 2011 18:22:19 -0700
Received: from qyk2 (qyk2.prod.google.com [10.241.83.130])
	by kpbe11.cbf.corp.google.com with ESMTP id p4R1LxaP013349
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 26 May 2011 18:22:18 -0700
Received: by qyk2 with SMTP id 2so932537qyk.2
        for <linux-mm@kvack.org>; Thu, 26 May 2011 18:22:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110527101446.73f2499a.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110526141047.dc828124.kamezawa.hiroyu@jp.fujitsu.com>
	<20110526143631.adc2c911.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTim+hj4Y5wUhB+BHoSOsXdaMYeKqbA@mail.gmail.com>
	<20110527101446.73f2499a.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 26 May 2011 18:22:17 -0700
Message-ID: <BANLkTintv-B1GRkUdXiA4jDYGNVG3rvx7A@mail.gmail.com>
Subject: Re: [RFC][PATCH v3 10/10] memcg : reclaim statistics
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>

On Thu, May 26, 2011 at 6:14 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 26 May 2011 18:17:04 -0700
> Ying Han <yinghan@google.com> wrote:
>
>> Hi Kame:
>>
>> I applied the patch on top of mmotm-2011-05-12-15-52. After boot up, i
>> keep getting the following crash by reading the
>> /dev/cgroup/memory/memory.reclaim_stat
>>
>> [ =A0200.776366] Kernel panic - not syncing: Fatal exception
>> [ =A0200.781591] Pid: 7535, comm: cat Tainted: G =A0 =A0 =A0D W =A0 2.6.=
39-mcg-DEV #130
>> [ =A0200.788463] Call Trace:
>> [ =A0200.790916] =A0[<ffffffff81405a75>] panic+0x91/0x194
>> [ =A0200.797096] =A0[<ffffffff81408ac8>] oops_end+0xae/0xbe
>> [ =A0200.803450] =A0[<ffffffff810398d3>] die+0x5a/0x63
>> [ =A0200.809366] =A0[<ffffffff81408561>] do_trap+0x121/0x130
>> [ =A0200.814427] =A0[<ffffffff81037fe6>] do_divide_error+0x90/0x99
>> [#1] SMP
>> [ =A0200.821395] =A0[<ffffffff81112bcb>] ? mem_cgroup_reclaim_stat_read+=
0x28/0xf0
>> [ =A0200.829624] =A0[<ffffffff81104509>] ? page_add_new_anon_rmap+0x7e/0=
x90
>> [ =A0200.837372] =A0[<ffffffff810fb7f8>] ? handle_pte_fault+0x28a/0x775
>> [ =A0200.844773] =A0[<ffffffff8140f0f5>] divide_error+0x15/0x20
>> [ =A0200.851471] =A0[<ffffffff81112bcb>] ? mem_cgroup_reclaim_stat_read+=
0x28/0xf0
>> [ =A0200.859729] =A0[<ffffffff810a4a01>] cgroup_seqfile_show+0x38/0x46
>> [ =A0200.867036] =A0[<ffffffff810a4d72>] ? cgroup_lock+0x17/0x17
>> [ =A0200.872444] =A0[<ffffffff81133f2c>] seq_read+0x182/0x361
>> [ =A0200.878984] =A0[<ffffffff8111a0c4>] vfs_read+0xab/0x107
>> [ =A0200.885403] =A0[<ffffffff8111a1e0>] sys_read+0x4a/0x6e
>> [ =A0200.891764] =A0[<ffffffff8140f469>] sysenter_dispatch+0x7/0x27
>>
>> I will debug it, but like to post here in case i missed some patches in =
between.
>>
>
> It must be mem->scanned is 0 and
> =A0 =A0 mem->reclaimed * 100 /mem->scanned cause error.
>
> It must be mem->reclaimed * 100 / (mem->scanned +1).
>
> I'll fix. thank you for reporting.

That is what I thought :) I will apply the change for now

--Ying
>
> Thanks,
> -Kame
>
>
>> --Ying
>>
>> On Wed, May 25, 2011 at 10:36 PM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> >
>> > This patch adds a file memory.reclaim_stat.
>> >
>> > This file shows following.
>> > =3D=3D
>> > recent_scan_success_ratio =A012 # recent reclaim/scan ratio.
>> > limit_scan_pages 671 =A0 =A0 =A0 =A0 =A0# scan caused by hitting limit=
.
>> > limit_freed_pages 538 =A0 =A0 =A0 =A0 # freed pages by limit_scan
>> > limit_elapsed_ns 518555076 =A0 =A0# elapsed time in LRU scanning by li=
mit.
>> > soft_scan_pages 0 =A0 =A0 =A0 =A0 =A0 =A0 # scan caused by softlimit.
>> > soft_freed_pages 0 =A0 =A0 =A0 =A0 =A0 =A0# freed pages by soft_scan.
>> > soft_elapsed_ns 0 =A0 =A0 =A0 =A0 =A0 =A0 # elapsed time in LRU scanni=
ng by softlimit.
>> > margin_scan_pages 16744221 =A0 =A0# scan caused by auto-keep-margin
>> > margin_freed_pages 565943 =A0 =A0 # freed pages by auto-keep-margin.
>> > margin_elapsed_ns 5545388791 =A0# elapsed time in LRU scanning by auto=
-keep-margin
>> >
>> > This patch adds a new file rather than adding more stats to memory.sta=
t. By it,
>> > this support "reset" accounting by
>> >
>> > =A0# echo 0 > .../memory.reclaim_stat
>> >
>> > This is good for debug and tuning.
>> >
>> > TODO:
>> > =A0- add Documentaion.
>> >
>> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> > ---
>> > =A0mm/memcontrol.c | =A0 87 ++++++++++++++++++++++++++++++++++++++++++=
++++++++------
>> > =A01 file changed, 79 insertions(+), 8 deletions(-)
>> >
>> > Index: memcg_async/mm/memcontrol.c
>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> > --- memcg_async.orig/mm/memcontrol.c
>> > +++ memcg_async/mm/memcontrol.c
>> > @@ -216,6 +216,13 @@ static void mem_cgroup_update_margin_to_
>> > =A0static void mem_cgroup_may_async_reclaim(struct mem_cgroup *mem);
>> > =A0static void mem_cgroup_reflesh_scan_ratio(struct mem_cgroup *mem);
>> >
>> > +enum scan_type {
>> > + =A0 =A0 =A0 LIMIT_SCAN, =A0 =A0 /* scan memory because memcg hits li=
mit */
>> > + =A0 =A0 =A0 SOFT_SCAN, =A0 =A0 =A0/* scan memory because of soft lim=
it */
>> > + =A0 =A0 =A0 MARGIN_SCAN, =A0 =A0/* scan memory for making margin to =
limit */
>> > + =A0 =A0 =A0 NR_SCAN_TYPES,
>> > +};
>> > +
>> > =A0/*
>> > =A0* The memory controller data structure. The memory controller contr=
ols both
>> > =A0* page cache and RSS per cgroup. We would eventually like to provid=
e
>> > @@ -300,6 +307,13 @@ struct mem_cgroup {
>> > =A0 =A0 =A0 =A0unsigned long =A0 scanned;
>> > =A0 =A0 =A0 =A0unsigned long =A0 reclaimed;
>> > =A0 =A0 =A0 =A0unsigned long =A0 next_scanratio_update;
>> > + =A0 =A0 =A0 /* For statistics */
>> > + =A0 =A0 =A0 struct {
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_scanned_pages;
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_reclaimed_pages;
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long elapsed_ns;
>> > + =A0 =A0 =A0 } scan_stat[NR_SCAN_TYPES];
>> > +
>> > =A0 =A0 =A0 =A0/*
>> > =A0 =A0 =A0 =A0 * percpu counter.
>> > =A0 =A0 =A0 =A0 */
>> > @@ -1426,7 +1440,9 @@ unsigned int mem_cgroup_swappiness(struc
>> >
>> > =A0static void __mem_cgroup_update_scan_ratio(struct mem_cgroup *mem,
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigne=
d long scanned,
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned=
 long reclaimed)
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned=
 long reclaimed,
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned=
 long elapsed,
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum sca=
n_type type)
>> > =A0{
>> > =A0 =A0 =A0 =A0unsigned long limit;
>> >
>> > @@ -1439,6 +1455,9 @@ static void __mem_cgroup_update_scan_rat
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem->scanned /=3D 2;
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem->reclaimed /=3D 2;
>> > =A0 =A0 =A0 =A0}
>> > + =A0 =A0 =A0 mem->scan_stat[type].nr_scanned_pages +=3D scanned;
>> > + =A0 =A0 =A0 mem->scan_stat[type].nr_reclaimed_pages +=3D reclaimed;
>> > + =A0 =A0 =A0 mem->scan_stat[type].elapsed_ns +=3D elapsed;
>> > =A0 =A0 =A0 =A0spin_unlock(&mem->scan_stat_lock);
>> > =A0}
>> >
>> > @@ -1448,6 +1467,8 @@ static void __mem_cgroup_update_scan_rat
>> > =A0* @root : root memcg of hierarchy walk.
>> > =A0* @scanned : scanned pages
>> > =A0* @reclaimed: reclaimed pages.
>> > + * @elapsed: used time for memory reclaim
>> > + * @type : scan type as LIMIT_SCAN, SOFT_SCAN, MARGIN_SCAN.
>> > =A0*
>> > =A0* record scan/reclaim ratio to the memcg both to a child and it's r=
oot
>> > =A0* mem cgroup, which is a reclaim target. This value is used for
>> > @@ -1457,11 +1478,14 @@ static void __mem_cgroup_update_scan_rat
>> > =A0static void mem_cgroup_update_scan_ratio(struct mem_cgroup *mem,
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0str=
uct mem_cgroup *root,
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigne=
d long scanned,
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned=
 long reclaimed)
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned=
 long reclaimed,
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned=
 long elapsed,
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int type=
)
>> > =A0{
>> > - =A0 =A0 =A0 __mem_cgroup_update_scan_ratio(mem, scanned, reclaimed);
>> > + =A0 =A0 =A0 __mem_cgroup_update_scan_ratio(mem, scanned, reclaimed, =
elapsed, type);
>> > =A0 =A0 =A0 =A0if (mem !=3D root)
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mem_cgroup_update_scan_ratio(root, sca=
nned, reclaimed);
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mem_cgroup_update_scan_ratio(root, sca=
nned, reclaimed,
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 elapsed, type);
>> >
>> > =A0}
>> >
>> > @@ -1906,6 +1930,7 @@ static int mem_cgroup_hierarchical_recla
>> > =A0 =A0 =A0 =A0bool is_kswapd =3D false;
>> > =A0 =A0 =A0 =A0unsigned long excess;
>> > =A0 =A0 =A0 =A0unsigned long nr_scanned;
>> > + =A0 =A0 =A0 unsigned long start, end, elapsed;
>> >
>> > =A0 =A0 =A0 =A0excess =3D res_counter_soft_limit_excess(&root_mem->res=
) >> PAGE_SHIFT;
>> >
>> > @@ -1947,18 +1972,24 @@ static int mem_cgroup_hierarchical_recla
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* we use swappiness of local cgroup */
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (check_soft) {
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 start =3D sched_clock();
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D mem_cgroup_shri=
nk_node_zone(victim, gfp_mask,
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0noswap,=
 zone, &nr_scanned);
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 end =3D sched_clock();
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 elapsed =3D end - start;
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*total_scanned +=3D nr_=
scanned;
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_soft_steal(v=
ictim, is_kswapd, ret);
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_soft_scan(vi=
ctim, is_kswapd, nr_scanned);
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_update_scan_=
ratio(victim,
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 root_mem, nr_scanned, ret);
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 root_mem=
, nr_scanned, ret, elapsed, SOFT_SCAN);
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else {
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 start =3D sched_clock();
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D try_to_free_mem=
_cgroup_pages(victim, gfp_mask,
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0noswap, &nr_scanned);
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 end =3D sched_clock();
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 elapsed =3D end - start;
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_update_scan_=
ratio(victim,
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 root_mem, nr_scanned, ret);
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 root_mem=
, nr_scanned, ret, elapsed, LIMIT_SCAN);
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0css_put(&victim->css);
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
>> > @@ -4003,7 +4034,7 @@ static void mem_cgroup_async_shrink_work
>> > =A0 =A0 =A0 =A0struct delayed_work *dw =3D to_delayed_work(work);
>> > =A0 =A0 =A0 =A0struct mem_cgroup *mem, *victim;
>> > =A0 =A0 =A0 =A0long nr_to_reclaim;
>> > - =A0 =A0 =A0 unsigned long nr_scanned, nr_reclaimed;
>> > + =A0 =A0 =A0 unsigned long nr_scanned, nr_reclaimed, start, end;
>> > =A0 =A0 =A0 =A0int delay =3D 0;
>> >
>> > =A0 =A0 =A0 =A0mem =3D container_of(dw, struct mem_cgroup, async_work)=
;
>> > @@ -4022,9 +4053,12 @@ static void mem_cgroup_async_shrink_work
>> > =A0 =A0 =A0 =A0if (!victim)
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto finish_scan;
>> >
>> > + =A0 =A0 =A0 start =3D sched_clock();
>> > =A0 =A0 =A0 =A0nr_reclaimed =3D mem_cgroup_shrink_rate_limited(victim,=
 nr_to_reclaim,
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0&nr_scanned);
>> > - =A0 =A0 =A0 mem_cgroup_update_scan_ratio(victim, mem, nr_scanned, nr=
_reclaimed);
>> > + =A0 =A0 =A0 end =3D sched_clock();
>> > + =A0 =A0 =A0 mem_cgroup_update_scan_ratio(victim, mem, nr_scanned, nr=
_reclaimed,
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 end - start, MARGIN_SCAN=
);
>> > =A0 =A0 =A0 =A0css_put(&victim->css);
>> >
>> > =A0 =A0 =A0 =A0/* If margin is enough big, stop */
>> > @@ -4680,6 +4714,38 @@ static int mem_control_stat_show(struct
>> > =A0 =A0 =A0 =A0return 0;
>> > =A0}
>> >
>> > +static int mem_cgroup_reclaim_stat_read(struct cgroup *cont, struct c=
ftype *cft,
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struc=
t cgroup_map_cb *cb)
>> > +{
>> > + =A0 =A0 =A0 struct mem_cgroup *mem =3D mem_cgroup_from_cont(cont);
>> > + =A0 =A0 =A0 u64 val;
>> > + =A0 =A0 =A0 int i; /* for indexing scan_stat[] */
>> > +
>> > + =A0 =A0 =A0 val =3D mem->reclaimed * 100 / mem->scanned;
>> > + =A0 =A0 =A0 cb->fill(cb, "recent_scan_success_ratio", val);
>> > + =A0 =A0 =A0 i =A0=3D LIMIT_SCAN;
>> > + =A0 =A0 =A0 cb->fill(cb, "limit_scan_pages", mem->scan_stat[i].nr_sc=
anned_pages);
>> > + =A0 =A0 =A0 cb->fill(cb, "limit_freed_pages", mem->scan_stat[i].nr_r=
eclaimed_pages);
>> > + =A0 =A0 =A0 cb->fill(cb, "limit_elapsed_ns", mem->scan_stat[i].elaps=
ed_ns);
>> > + =A0 =A0 =A0 i =3D SOFT_SCAN;
>> > + =A0 =A0 =A0 cb->fill(cb, "soft_scan_pages", mem->scan_stat[i].nr_sca=
nned_pages);
>> > + =A0 =A0 =A0 cb->fill(cb, "soft_freed_pages", mem->scan_stat[i].nr_re=
claimed_pages);
>> > + =A0 =A0 =A0 cb->fill(cb, "soft_elapsed_ns", mem->scan_stat[i].elapse=
d_ns);
>> > + =A0 =A0 =A0 i =3D MARGIN_SCAN;
>> > + =A0 =A0 =A0 cb->fill(cb, "margin_scan_pages", mem->scan_stat[i].nr_s=
canned_pages);
>> > + =A0 =A0 =A0 cb->fill(cb, "margin_freed_pages", mem->scan_stat[i].nr_=
reclaimed_pages);
>> > + =A0 =A0 =A0 cb->fill(cb, "margin_elapsed_ns", mem->scan_stat[i].elap=
sed_ns);
>> > + =A0 =A0 =A0 return 0;
>> > +}
>> > +
>> > +static int mem_cgroup_reclaim_stat_reset(struct cgroup *cgrp, unsigne=
d int event)
>> > +{
>> > + =A0 =A0 =A0 struct mem_cgroup *mem =3D mem_cgroup_from_cont(cgrp);
>> > + =A0 =A0 =A0 memset(mem->scan_stat, 0, sizeof(mem->scan_stat));
>> > + =A0 =A0 =A0 return 0;
>> > +}
>> > +
>> > +
>> > =A0/*
>> > =A0* User flags for async_control is a subset of mem->async_flags. But
>> > =A0* this needs to be defined independently to hide implemation detail=
s.
>> > @@ -5163,6 +5229,11 @@ static struct cftype mem_cgroup_files[]
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.open =3D mem_control_numa_stat_open,
>> > =A0 =A0 =A0 =A0},
>> > =A0#endif
>> > + =A0 =A0 =A0 {
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D "reclaim_stat",
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .read_map =3D mem_cgroup_reclaim_stat_re=
ad,
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .trigger =3D mem_cgroup_reclaim_stat_res=
et,
>> > + =A0 =A0 =A0 }
>> > =A0};
>> >
>> > =A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
>> >
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" =
in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at =A0http://www.tux.org/lkml/
>>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
