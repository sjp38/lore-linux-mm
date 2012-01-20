Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 578CD6B004D
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 03:40:56 -0500 (EST)
Received: by vbbfa15 with SMTP id fa15so266661vbb.14
        for <linux-mm@kvack.org>; Fri, 20 Jan 2012 00:40:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120113174510.5e0f6131.kamezawa.hiroyu@jp.fujitsu.com>
References: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com> <20120113174510.5e0f6131.kamezawa.hiroyu@jp.fujitsu.com>
From: Greg Thelen <gthelen@google.com>
Date: Fri, 20 Jan 2012 00:40:34 -0800
Message-ID: <CAHH2K0ZzE55Dx=pz+cR1US3UnUbUxuyVjM=N3kf3NN+Rz8GJjQ@mail.gmail.com>
Subject: Re: [RFC] [PATCH 7/7 v2] memcg: make mem_cgroup_begin_update_stat to
 use global pcpu.
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Ying Han <yinghan@google.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, "bsingharora@gmail.com" <bsingharora@gmail.com>

On Fri, Jan 13, 2012 at 12:45 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> From 3df71cef5757ee6547916c4952f04a263c1b8ddb Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Fri, 13 Jan 2012 17:07:35 +0900
> Subject: [PATCH 7/7] memcg: make mem_cgroup_begin_update_stat to use glob=
al pcpu.
>
> Now, a per-cpu flag to show the memcg is under account moving is
> now implemented as per-memcg-per-cpu.
>
> So, when accessing this, we need to access memcg 1st. But this
> function is called even when status update doesn't occur. Then,
> accessing struct memcg is an overhead in such case.
>
> This patch removes per-cpu-per-memcg MEM_CGROUP_ON_MOVE and add
> per-cpu vairable to do the same work. For per-memcg, atomic
> counter is added. By this, mem_cgroup_begin_update_stat() will
> just access percpu variable in usual case and don't need to find & access
> memcg. This reduces overhead.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =A0include/linux/memcontrol.h | =A0 16 +++++++++-
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 67 +++++++++++++++++++++-=
---------------------
> =A02 files changed, 47 insertions(+), 36 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 976b58c..26a4baa 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -151,12 +151,22 @@ static inline bool mem_cgroup_disabled(void)
> =A0* =A0 =A0 mem_cgroup_update_page_stat(page, idx, val)
> =A0* =A0 =A0 mem_cgroup_end_update_page_stat(page, locked);
> =A0*/
> +DECLARE_PER_CPU(int, mem_cgroup_account_moving);
> +static inline bool any_mem_cgroup_stealed(void)
> +{
> + =A0 =A0 =A0 smp_rmb();
> + =A0 =A0 =A0 return this_cpu_read(mem_cgroup_account_moving) > 0;
> +}
> +
> =A0bool __mem_cgroup_begin_update_page_stat(struct page *page);
> =A0static inline bool mem_cgroup_begin_update_page_stat(struct page *page=
)
> =A0{
> =A0 =A0 =A0 =A0if (mem_cgroup_disabled())
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return false;
> - =A0 =A0 =A0 return __mem_cgroup_begin_update_page_stat(page);
> + =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 if (unlikely(any_mem_cgroup_stealed()))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return __mem_cgroup_begin_update_page_stat(=
page);
> + =A0 =A0 =A0 return false;
> =A0}
> =A0void mem_cgroup_update_page_stat(struct page *page,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum mem_=
cgroup_page_stat_item idx,
> @@ -167,7 +177,9 @@ mem_cgroup_end_update_page_stat(struct page *page, bo=
ol locked)
> =A0{
> =A0 =A0 =A0 =A0if (mem_cgroup_disabled())
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> - =A0 =A0 =A0 __mem_cgroup_end_update_page_stat(page, locked);
> + =A0 =A0 =A0 if (locked)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mem_cgroup_end_update_page_stat(page, loc=
ked);
> + =A0 =A0 =A0 rcu_read_unlock();
> =A0}
>
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 8b67ccf..4836e8d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -89,7 +89,6 @@ enum mem_cgroup_stat_index {
> =A0 =A0 =A0 =A0MEM_CGROUP_STAT_FILE_MAPPED, =A0/* # of pages charged as f=
ile rss */
> =A0 =A0 =A0 =A0MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> =A0 =A0 =A0 =A0MEM_CGROUP_STAT_DATA, /* end of data requires synchronizat=
ion */
> - =A0 =A0 =A0 MEM_CGROUP_ON_MOVE, =A0 =A0 /* someone is moving account be=
tween groups */
> =A0 =A0 =A0 =A0MEM_CGROUP_STAT_NSTATS,
> =A0};
>
> @@ -279,6 +278,8 @@ struct mem_cgroup {
> =A0 =A0 =A0 =A0 * mem_cgroup ? And what type of charges should we move ?
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0unsigned long =A0 move_charge_at_immigrate;
> + =A0 =A0 =A0 /* set when a page under this memcg may be moving to other =
memcg */
> + =A0 =A0 =A0 atomic_t =A0 =A0 =A0 =A0account_moving;
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * percpu counter.
> =A0 =A0 =A0 =A0 */
> @@ -1250,20 +1251,27 @@ int mem_cgroup_swappiness(struct mem_cgroup *memc=
g)
> =A0 =A0 =A0 =A0return memcg->swappiness;
> =A0}
>
> +/*
> + * For quick check, for avoiding looking up memcg, system-wide
> + * per-cpu check is provided.
> + */
> +DEFINE_PER_CPU(int, mem_cgroup_account_moving);

Why is this a per-cpu counter?  Can this be an single atomic_t
instead, or does cpu hotplug require per-cpu state?  In the common
case, when there is no move in progress, then the counter would be
zero and clean in all cpu caches that need it.  When moving pages,
mem_cgroup_start_move() would atomic_inc the counter.

> +DEFINE_SPINLOCK(mem_cgroup_stealed_lock);
> +
> =A0static void mem_cgroup_start_move(struct mem_cgroup *memcg)
> =A0{
> =A0 =A0 =A0 =A0int cpu;
>
> =A0 =A0 =A0 =A0get_online_cpus();
> - =A0 =A0 =A0 spin_lock(&memcg->pcp_counter_lock);
> + =A0 =A0 =A0 spin_lock(&mem_cgroup_stealed_lock);
> =A0 =A0 =A0 =A0for_each_online_cpu(cpu) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 per_cpu(memcg->stat->count[MEM_CGROUP_ON_MO=
VE], cpu) +=3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 per_cpu(mem_cgroup_account_moving, cpu) +=
=3D 1;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0smp_wmb();
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 memcg->nocpu_base.count[MEM_CGROUP_ON_MOVE] +=3D 1;
> - =A0 =A0 =A0 spin_unlock(&memcg->pcp_counter_lock);
> + =A0 =A0 =A0 spin_unlock(&mem_cgroup_stealed_lock);
> =A0 =A0 =A0 =A0put_online_cpus();
>
> + =A0 =A0 =A0 atomic_inc(&memcg->account_moving);
> =A0 =A0 =A0 =A0synchronize_rcu();
> =A0}
>
> @@ -1274,11 +1282,12 @@ static void mem_cgroup_end_move(struct mem_cgroup=
 *memcg)
> =A0 =A0 =A0 =A0if (!memcg)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> =A0 =A0 =A0 =A0get_online_cpus();
> - =A0 =A0 =A0 spin_lock(&memcg->pcp_counter_lock);
> - =A0 =A0 =A0 for_each_online_cpu(cpu)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 per_cpu(memcg->stat->count[MEM_CGROUP_ON_MO=
VE], cpu) -=3D 1;
> - =A0 =A0 =A0 memcg->nocpu_base.count[MEM_CGROUP_ON_MOVE] -=3D 1;
> - =A0 =A0 =A0 spin_unlock(&memcg->pcp_counter_lock);
> + =A0 =A0 =A0 spin_lock(&mem_cgroup_stealed_lock);
> + =A0 =A0 =A0 for_each_online_cpu(cpu) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 per_cpu(mem_cgroup_account_moving, cpu) -=
=3D 1;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 spin_unlock(&mem_cgroup_stealed_lock);
> + =A0 =A0 =A0 atomic_dec(&memcg->account_moving);
> =A0 =A0 =A0 =A0put_online_cpus();
> =A0}
> =A0/*
> @@ -1296,8 +1305,7 @@ static void mem_cgroup_end_move(struct mem_cgroup *=
memcg)
> =A0static bool mem_cgroup_stealed(struct mem_cgroup *memcg)
> =A0{
> =A0 =A0 =A0 =A0VM_BUG_ON(!rcu_read_lock_held());
> - =A0 =A0 =A0 smp_rmb();
> - =A0 =A0 =A0 return this_cpu_read(memcg->stat->count[MEM_CGROUP_ON_MOVE]=
) > 0;
> + =A0 =A0 =A0 return atomic_read(&memcg->account_moving) > 0;
> =A0}
>
> =A0static bool mem_cgroup_under_move(struct mem_cgroup *memcg)
> @@ -1343,10 +1351,9 @@ static bool mem_cgroup_wait_acct_move(struct mem_c=
group *memcg)
> =A0* page satus accounting. To avoid that, we need some locks. In general=
,
> =A0* ading atomic ops to hot path is very bad. We're using 2 level logic.
> =A0*
> - * When a thread starts moving account information, per-cpu MEM_CGROUP_O=
N_MOVE
> - * value is set. If MEM_CGROUP_ON_MOVE=3D=3D0, there are no race and pag=
e status
> - * update can be done withou any locks. If MEM_CGROUP_ON_MOVE>0, we use
> - * following hashed rwlocks.
> + * When a thread starts moving account information, memcg->account_movin=
g
> + * value is set. If =3D=3D0, there are no race and page status update ca=
n be done
> + * without any locks. If account_moving >0, we use following hashed rwlo=
cks.
> =A0* - At updating information, we hold rlock.
> =A0* - When a page is picked up and being moved, wlock is held.
> =A0*
> @@ -1354,7 +1361,7 @@ static bool mem_cgroup_wait_acct_move(struct mem_cg=
roup *memcg)
> =A0*/
>
> =A0/*
> - * This rwlock is accessed only when MEM_CGROUP_ON_MOVE > 0.
> + * This rwlock is accessed only when account_moving > 0.
> =A0*/
> =A0#define NR_MOVE_ACCOUNT_LOCKS =A0(NR_CPUS)
> =A0#define move_account_hash(page) ((page_to_pfn(page) % NR_MOVE_ACCOUNT_=
LOCKS))
> @@ -1907,9 +1914,8 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *memcg=
, gfp_t mask)
> =A0* if there are race with "uncharge". Statistics itself is properly han=
dled
> =A0* by flags.
> =A0*
> - * Considering "move", this is an only case we see a race. To make the r=
ace
> - * small, we check MEM_CGROUP_ON_MOVE percpu value and detect there are
> - * possibility of race condition. If there is, we take a lock.
> + * If any_mem_cgroup_stealed() && mem_cgroup_stealed(), there is
> + * a possiblity of race condition and we take a lock.
> =A0*/
>
> =A0bool __mem_cgroup_begin_update_page_stat(struct page *page)
> @@ -1918,7 +1924,6 @@ bool __mem_cgroup_begin_update_page_stat(struct pag=
e *page)
> =A0 =A0 =A0 =A0bool locked =3D false;
> =A0 =A0 =A0 =A0struct mem_cgroup *memcg;
>
> - =A0 =A0 =A0 rcu_read_lock();
> =A0 =A0 =A0 =A0memcg =3D pc->mem_cgroup;
>
> =A0 =A0 =A0 =A0if (!memcg || !PageCgroupUsed(pc))
> @@ -1933,9 +1938,7 @@ out:
>
> =A0void __mem_cgroup_end_update_page_stat(struct page *page, bool locked)
> =A0{
> - =A0 =A0 =A0 if (locked)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_account_move_runlock(page);
> - =A0 =A0 =A0 rcu_read_unlock();
> + =A0 =A0 =A0 mem_cgroup_account_move_runlock(page);
> =A0}
>
> =A0void mem_cgroup_update_page_stat(struct page *page,
> @@ -2133,18 +2136,14 @@ static void mem_cgroup_drain_pcp_counter(struct m=
em_cgroup *memcg, int cpu)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0per_cpu(memcg->stat->events[i], cpu) =3D 0=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memcg->nocpu_base.events[i] +=3D x;
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 /* need to clear ON_MOVE value, works as a kind of lock. */
> - =A0 =A0 =A0 per_cpu(memcg->stat->count[MEM_CGROUP_ON_MOVE], cpu) =3D 0;
> =A0 =A0 =A0 =A0spin_unlock(&memcg->pcp_counter_lock);
> =A0}
>
> -static void synchronize_mem_cgroup_on_move(struct mem_cgroup *memcg, int=
 cpu)
> +static void synchronize_mem_cgroup_on_move(int cpu)
> =A0{
> - =A0 =A0 =A0 int idx =3D MEM_CGROUP_ON_MOVE;
> -
> - =A0 =A0 =A0 spin_lock(&memcg->pcp_counter_lock);
> - =A0 =A0 =A0 per_cpu(memcg->stat->count[idx], cpu) =3D memcg->nocpu_base=
.count[idx];
> - =A0 =A0 =A0 spin_unlock(&memcg->pcp_counter_lock);
> + =A0 =A0 =A0 spin_lock(&mem_cgroup_stealed_lock);
> + =A0 =A0 =A0 per_cpu(mem_cgroup_account_moving, cpu) =3D 0;
> + =A0 =A0 =A0 spin_unlock(&mem_cgroup_stealed_lock);
> =A0}
>
> =A0static int __cpuinit memcg_cpu_hotplug_callback(struct notifier_block =
*nb,
> @@ -2156,8 +2155,7 @@ static int __cpuinit memcg_cpu_hotplug_callback(str=
uct notifier_block *nb,
> =A0 =A0 =A0 =A0struct mem_cgroup *iter;
>
> =A0 =A0 =A0 =A0if ((action =3D=3D CPU_ONLINE)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 for_each_mem_cgroup(iter)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 synchronize_mem_cgroup_on_m=
ove(iter, cpu);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 synchronize_mem_cgroup_on_move(cpu);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NOTIFY_OK;
> =A0 =A0 =A0 =A0}
>
> @@ -2167,6 +2165,7 @@ static int __cpuinit memcg_cpu_hotplug_callback(str=
uct notifier_block *nb,
> =A0 =A0 =A0 =A0for_each_mem_cgroup(iter)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_drain_pcp_counter(iter, cpu);
>
> + =A0 =A0 =A0 per_cpu(mem_cgroup_account_moving, cpu) =3D 0;
> =A0 =A0 =A0 =A0stock =3D &per_cpu(memcg_stock, cpu);
> =A0 =A0 =A0 =A0drain_stock(stock);
> =A0 =A0 =A0 =A0return NOTIFY_OK;
> --
> 1.7.4.1
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
