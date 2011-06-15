Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id D33326B0012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 01:30:20 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p5F5UH6d030645
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 22:30:18 -0700
Received: from qyk29 (qyk29.prod.google.com [10.241.83.157])
	by hpaq2.eem.corp.google.com with ESMTP id p5F5UFZt008470
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 22:30:16 -0700
Received: by qyk29 with SMTP id 29so1863053qyk.3
        for <linux-mm@kvack.org>; Tue, 14 Jun 2011 22:30:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110615104935.ccefc6b5.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110613120054.3336e997.kamezawa.hiroyu@jp.fujitsu.com>
	<20110613121648.3d28afcd.kamezawa.hiroyu@jp.fujitsu.com>
	<20110615104935.ccefc6b5.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 14 Jun 2011 22:30:15 -0700
Message-ID: <BANLkTi=FBROyRiM1tZbJGMY2Esmtc=-BSQ@mail.gmail.com>
Subject: Re: [BUGFIX][PATCH v6] memcg: fix percpu cached charge draining frequency
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

On Tue, Jun 14, 2011 at 6:49 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> This is a repleacement for
> memcg-fix-percpu-cached-charge-draining-frequency.patch
> +
> memcg-fix-percpu-cached-charge-draining-frequency-fix.patch
>
>
> Changelog:
> =A0- removed unnecessary rcu_read_lock()
> =A0- removed a fix for softlimit case (move to another independent patch)
> =A0- make mutex static.
> =A0- applied comment updates from Andrew Morton.
>
> A patch for softlimit will follow this.
>
> =3D=3D
> From f3f41b827d70142858ba8b370510a82d608870d0 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Wed, 15 Jun 2011 10:39:57 +0900
> Subject: [PATCH 5/6] memcg: fix behavior of per cpu charge cache draining=
.
>
> =A0For performance, memory cgroup caches some "charge" from res_counter
> =A0into per cpu cache. This works well but because it's cache,
> =A0it needs to be flushed in some cases. Typical cases are
> =A0 =A0 =A0 =A0 1. when someone hit limit.
> =A0 =A0 =A0 =A0 2. when rmdir() is called and need to charges to be 0.
>
> But "1" has problem.
>
> Recently, with large SMP machines, we see many kworker runs because
> of flushing memcg's cache. Bad things in implementation are
> that even if a cpu contains a cache for memcg not related to
> a memcg which hits limit, drain code is called.
>
> This patch does
> =A0 =A0 =A0 =A0A) check percpu cache contains a useful data or not.
> =A0 =A0 =A0 =A0B) check other asynchronous percpu draining doesn't run.
> =A0 =A0 =A0 =A0C) don't call local cpu callback.
>
> (*)This patch avoid changing the calling condition with hard-limit.
>
> When I run "cat 1Gfile > /dev/null" under 300M limit memcg,
>
> [Before]
> 13767 kamezawa =A020 =A0 0 98.6m =A0424 =A0416 D 10.0 =A00.0 =A0 0:00.61 =
cat
> =A0 58 root =A0 =A0 =A020 =A0 0 =A0 =A0 0 =A0 =A00 =A0 =A00 S =A00.6 =A00=
.0 =A0 0:00.09 kworker/2:1
> =A0 60 root =A0 =A0 =A020 =A0 0 =A0 =A0 0 =A0 =A00 =A0 =A00 S =A00.6 =A00=
.0 =A0 0:00.08 kworker/4:1
> =A0 =A04 root =A0 =A0 =A020 =A0 0 =A0 =A0 0 =A0 =A00 =A0 =A00 S =A00.3 =
=A00.0 =A0 0:00.02 kworker/0:0
> =A0 57 root =A0 =A0 =A020 =A0 0 =A0 =A0 0 =A0 =A00 =A0 =A00 S =A00.3 =A00=
.0 =A0 0:00.05 kworker/1:1
> =A0 61 root =A0 =A0 =A020 =A0 0 =A0 =A0 0 =A0 =A00 =A0 =A00 S =A00.3 =A00=
.0 =A0 0:00.05 kworker/5:1
> =A0 62 root =A0 =A0 =A020 =A0 0 =A0 =A0 0 =A0 =A00 =A0 =A00 S =A00.3 =A00=
.0 =A0 0:00.05 kworker/6:1
> =A0 63 root =A0 =A0 =A020 =A0 0 =A0 =A0 0 =A0 =A00 =A0 =A00 S =A00.3 =A00=
.0 =A0 0:00.05 kworker/7:1
>
> [After]
> =A02676 root =A0 =A0 =A020 =A0 0 98.6m =A0416 =A0416 D =A09.3 =A00.0 =A0 =
0:00.87 cat
> =A02626 kamezawa =A020 =A0 0 15192 1312 =A0920 R =A00.3 =A00.0 =A0 0:00.2=
8 top
> =A0 =A01 root =A0 =A0 =A020 =A0 0 19384 1496 1204 S =A00.0 =A00.0 =A0 0:0=
0.66 init
> =A0 =A02 root =A0 =A0 =A020 =A0 0 =A0 =A0 0 =A0 =A00 =A0 =A00 S =A00.0 =
=A00.0 =A0 0:00.00 kthreadd
> =A0 =A03 root =A0 =A0 =A020 =A0 0 =A0 =A0 0 =A0 =A00 =A0 =A00 S =A00.0 =
=A00.0 =A0 0:00.00 ksoftirqd/0
> =A0 =A04 root =A0 =A0 =A020 =A0 0 =A0 =A0 0 =A0 =A00 =A0 =A00 S =A00.0 =
=A00.0 =A0 0:00.00 kworker/0:0
>
> Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Reviewed-by: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> Changelog:
> =A0- removed unnecessary rcu_read_lock()
> =A0- removed a fix for softlimit case (move to another independent patch)
> =A0- make mutex static.
> =A0- applied comment updates from Andrew Morton.
> ---
> =A0mm/memcontrol.c | =A0 54 ++++++++++++++++++++++++++++++++++++++-------=
---------
> =A01 files changed, 38 insertions(+), 16 deletions(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 915c3f3..8fb29de 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -359,7 +359,7 @@ enum charge_type {
> =A0static void mem_cgroup_get(struct mem_cgroup *mem);
> =A0static void mem_cgroup_put(struct mem_cgroup *mem);
> =A0static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
> -static void drain_all_stock_async(void);
> +static void drain_all_stock_async(struct mem_cgroup *mem);
>
> =A0static struct mem_cgroup_per_zone *
> =A0mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
> @@ -1671,7 +1671,7 @@ static int mem_cgroup_hierarchical_reclaim(struct m=
em_cgroup *root_mem,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (victim =3D=3D root_mem) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0loop++;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (loop >=3D 1)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 drain_all_s=
tock_async();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 drain_all_s=
tock_async(root_mem);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (loop >=3D 2) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * If we h=
ave not been able to reclaim
> @@ -1934,9 +1934,11 @@ struct memcg_stock_pcp {
> =A0 =A0 =A0 =A0struct mem_cgroup *cached; /* this never be root cgroup */
> =A0 =A0 =A0 =A0unsigned int nr_pages;
> =A0 =A0 =A0 =A0struct work_struct work;
> + =A0 =A0 =A0 unsigned long flags;
> +#define FLUSHING_CACHED_CHARGE (0)
> =A0};
> =A0static DEFINE_PER_CPU(struct memcg_stock_pcp, memcg_stock);
> -static atomic_t memcg_drain_count;
> +static DEFINE_MUTEX(percpu_charge_mutex);
>
> =A0/*
> =A0* Try to consume stocked charge on this cpu. If success, one page is c=
onsumed
> @@ -1984,6 +1986,7 @@ static void drain_local_stock(struct work_struct *d=
ummy)
> =A0{
> =A0 =A0 =A0 =A0struct memcg_stock_pcp *stock =3D &__get_cpu_var(memcg_sto=
ck);
> =A0 =A0 =A0 =A0drain_stock(stock);
> + =A0 =A0 =A0 clear_bit(FLUSHING_CACHED_CHARGE, &stock->flags);
> =A0}
>
> =A0/*
> @@ -2008,26 +2011,45 @@ static void refill_stock(struct mem_cgroup *mem, =
unsigned int nr_pages)
> =A0* expects some charges will be back to res_counter later but cannot wa=
it for
> =A0* it.
> =A0*/
> -static void drain_all_stock_async(void)
> +static void drain_all_stock_async(struct mem_cgroup *root_mem)
> =A0{
> - =A0 =A0 =A0 int cpu;
> - =A0 =A0 =A0 /* This function is for scheduling "drain" in asynchronous =
way.
> - =A0 =A0 =A0 =A0* The result of "drain" is not directly handled by calle=
rs. Then,
> - =A0 =A0 =A0 =A0* if someone is calling drain, we don't have to call dra=
in more.
> - =A0 =A0 =A0 =A0* Anyway, WORK_STRUCT_PENDING check in queue_work_on() w=
ill catch if
> - =A0 =A0 =A0 =A0* there is a race. We just do loose check here.
> + =A0 =A0 =A0 int cpu, curcpu;
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* If someone calls draining, avoid adding more kworker r=
uns.
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 if (atomic_read(&memcg_drain_count))
> + =A0 =A0 =A0 if (!mutex_trylock(&percpu_charge_mutex))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> =A0 =A0 =A0 =A0/* Notify other cpus that system-wide "drain" is running *=
/
> - =A0 =A0 =A0 atomic_inc(&memcg_drain_count);
> =A0 =A0 =A0 =A0get_online_cpus();
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Get a hint for avoiding draining charges on the curren=
t cpu,
> + =A0 =A0 =A0 =A0* which must be exhausted by our charging. =A0It is not =
required that
> + =A0 =A0 =A0 =A0* this be a precise check, so we use raw_smp_processor_i=
d() instead of
> + =A0 =A0 =A0 =A0* getcpu()/putcpu().
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 curcpu =3D raw_smp_processor_id();
> =A0 =A0 =A0 =A0for_each_online_cpu(cpu) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct memcg_stock_pcp *stock =3D &per_cpu=
(memcg_stock, cpu);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule_work_on(cpu, &stock->work);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct mem_cgroup *mem;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cpu =3D=3D curcpu)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem =3D stock->cached;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!mem)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem !=3D root_mem) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!root_mem->use_hierarch=
y)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* check whether "mem" is u=
nder tree of "root_mem" */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!css_is_ancestor(&mem->=
css, &root_mem->css))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!test_and_set_bit(FLUSHING_CACHED_CHARG=
E, &stock->flags))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule_work_on(cpu, &stoc=
k->work);
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0put_online_cpus();
> - =A0 =A0 =A0 atomic_dec(&memcg_drain_count);
> + =A0 =A0 =A0 mutex_unlock(&percpu_charge_mutex);
> =A0 =A0 =A0 =A0/* We don't wait for flush_work */
> =A0}
>
> @@ -2035,9 +2057,9 @@ static void drain_all_stock_async(void)
> =A0static void drain_all_stock_sync(void)
> =A0{
> =A0 =A0 =A0 =A0/* called when force_empty is called */
> - =A0 =A0 =A0 atomic_inc(&memcg_drain_count);
> + =A0 =A0 =A0 mutex_lock(&percpu_charge_mutex);
> =A0 =A0 =A0 =A0schedule_on_each_cpu(drain_local_stock);
> - =A0 =A0 =A0 atomic_dec(&memcg_drain_count);
> + =A0 =A0 =A0 mutex_unlock(&percpu_charge_mutex);
> =A0}
>
> =A0/*
> --
> 1.7.4.1
>
>
>

Tested-by: Ying Han <yinghan@google.com>


--Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
