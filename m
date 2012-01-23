Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 29E856B004D
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 17:02:50 -0500 (EST)
Received: by qcsg1 with SMTP id g1so852086qcs.14
        for <linux-mm@kvack.org>; Mon, 23 Jan 2012 14:02:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120113174019.8dff3fc1.kamezawa.hiroyu@jp.fujitsu.com>
References: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
	<20120113174019.8dff3fc1.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 23 Jan 2012 14:02:48 -0800
Message-ID: <CALWz4izasaECifCYoRXL45x1YXYzACC=kUHQivnGZKRH+ySjuw@mail.gmail.com>
Subject: Re: [RFC] [PATCH 3/7 v2] memcg: remove PCG_MOVE_LOCK flag from pc->flags
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, "bsingharora@gmail.com" <bsingharora@gmail.com>

On Fri, Jan 13, 2012 at 12:40 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> From 1008e84d94245b1e7c4d237802ff68ff00757736 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Thu, 12 Jan 2012 15:53:24 +0900
> Subject: [PATCH 3/7] memcg: remove PCG_MOVE_LOCK flag from pc->flags.
>
> PCG_MOVE_LOCK bit is used for bit spinlock for avoiding race between
> memcg's account moving and page state statistics updates.
>
> Considering page-statistics update, very hot path, this lock is
> taken only when someone is moving account (or PageTransHuge())
> And, now, all moving-account between memcgroups (by task-move)
> are serialized.

This might be a side question, can you clarify the serialization here?
Does it mean that we only allow one task-move at a time system-wide?

Thanks

--Ying
>
> So, it seems too costly to have 1bit per page for this purpose.
>
> This patch removes PCG_MOVE_LOCK and add hashed rwlock array
> instead of it. This works well enough. Even when we need to
> take the lock, we don't need to disable IRQ in hot path because
> of using rwlock.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =A0include/linux/page_cgroup.h | =A0 19 -----------
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 72 +++++++++++++++++++++=
+++++++++++++++++----
> =A02 files changed, 65 insertions(+), 26 deletions(-)
>
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index a2d1177..5dba799 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -8,7 +8,6 @@ enum {
> =A0 =A0 =A0 =A0PCG_USED, /* this object is in use. */
> =A0 =A0 =A0 =A0PCG_MIGRATION, /* under page migration */
> =A0 =A0 =A0 =A0/* flags for mem_cgroup and file and I/O status */
> - =A0 =A0 =A0 PCG_MOVE_LOCK, /* For race between move_account v.s. follow=
ing bits */
> =A0 =A0 =A0 =A0PCG_FILE_MAPPED, /* page is accounted as "mapped" */
> =A0 =A0 =A0 =A0__NR_PCG_FLAGS,
> =A0};
> @@ -95,24 +94,6 @@ static inline void unlock_page_cgroup(struct page_cgro=
up *pc)
> =A0 =A0 =A0 =A0bit_spin_unlock(PCG_LOCK, &pc->flags);
> =A0}
>
> -static inline void move_lock_page_cgroup(struct page_cgroup *pc,
> - =A0 =A0 =A0 unsigned long *flags)
> -{
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* We know updates to pc->flags of page cache's stats are=
 from both of
> - =A0 =A0 =A0 =A0* usual context or IRQ context. Disable IRQ to avoid dea=
dlock.
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 local_irq_save(*flags);
> - =A0 =A0 =A0 bit_spin_lock(PCG_MOVE_LOCK, &pc->flags);
> -}
> -
> -static inline void move_unlock_page_cgroup(struct page_cgroup *pc,
> - =A0 =A0 =A0 unsigned long *flags)
> -{
> - =A0 =A0 =A0 bit_spin_unlock(PCG_MOVE_LOCK, &pc->flags);
> - =A0 =A0 =A0 local_irq_restore(*flags);
> -}
> -
> =A0#else /* CONFIG_CGROUP_MEM_RES_CTLR */
> =A0struct page_cgroup;
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 9019069..61e276f 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1338,6 +1338,65 @@ static bool mem_cgroup_wait_acct_move(struct mem_c=
group *memcg)
> =A0 =A0 =A0 =A0return false;
> =A0}
>
> +/*
> + * At moving acccounting information between cgroups, we'll have race wi=
th
> + * page satus accounting. To avoid that, we need some locks. In general,
> + * ading atomic ops to hot path is very bad. We're using 2 level logic.
> + *
> + * When a thread starts moving account information, per-cpu MEM_CGROUP_O=
N_MOVE
> + * value is set. If MEM_CGROUP_ON_MOVE=3D=3D0, there are no race and pag=
e status
> + * update can be done withou any locks. If MEM_CGROUP_ON_MOVE>0, we use
> + * following hashed rwlocks.
> + * - At updating information, we hold rlock.
> + * - When a page is picked up and being moved, wlock is held.
> + *
> + * This logic works well enough because moving account is not an usual e=
vent.
> + */
> +
> +/*
> + * This rwlock is accessed only when MEM_CGROUP_ON_MOVE > 0.
> + */
> +#define NR_MOVE_ACCOUNT_LOCKS =A0(NR_CPUS)
> +#define move_account_hash(page) ((page_to_pfn(page) % NR_MOVE_ACCOUNT_LO=
CKS))
> +static rwlock_t move_account_locks[NR_MOVE_ACCOUNT_LOCKS];
> +
> +static rwlock_t *__mem_cgroup_account_move_lock(struct page *page)
> +{
> + =A0 =A0 =A0 int hnum =3D move_account_hash(page);
> +
> + =A0 =A0 =A0 return &move_account_locks[hnum];
> +}
> +
> +static void mem_cgroup_account_move_rlock(struct page *page)
> +{
> + =A0 =A0 =A0 read_lock(__mem_cgroup_account_move_lock(page));
> +}
> +
> +static void mem_cgroup_account_move_runlock(struct page *page)
> +{
> + =A0 =A0 =A0 read_unlock(__mem_cgroup_account_move_lock(page));
> +}
> +
> +static void mem_cgroup_account_move_wlock(struct page *page,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long *flags)
> +{
> + =A0 =A0 =A0 write_lock_irqsave(__mem_cgroup_account_move_lock(page), *f=
lags);
> +}
> +
> +static void mem_cgroup_account_move_wunlock(struct page *page,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long flags)
> +{
> + =A0 =A0 =A0 write_unlock_irqrestore(__mem_cgroup_account_move_lock(page=
), flags);
> +}
> +
> +static =A0void mem_cgroup_account_move_lock_init(void)
> +{
> + =A0 =A0 =A0 int num;
> +
> + =A0 =A0 =A0 for (num =3D 0; num < NR_MOVE_ACCOUNT_LOCKS; num++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rwlock_init(&move_account_locks[num]);
> +}
> +
> =A0/**
> =A0* mem_cgroup_print_oom_info: Called from OOM with tasklist_lock held i=
n read mode.
> =A0* @memcg: The memory cgroup that went over limit
> @@ -1859,7 +1918,6 @@ void mem_cgroup_update_page_stat(struct page *page,
> =A0 =A0 =A0 =A0struct mem_cgroup *memcg;
> =A0 =A0 =A0 =A0struct page_cgroup *pc =3D lookup_page_cgroup(page);
> =A0 =A0 =A0 =A0bool need_unlock =3D false;
> - =A0 =A0 =A0 unsigned long uninitialized_var(flags);
>
> =A0 =A0 =A0 =A0if (mem_cgroup_disabled())
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> @@ -1871,7 +1929,7 @@ void mem_cgroup_update_page_stat(struct page *page,
> =A0 =A0 =A0 =A0/* pc->mem_cgroup is unstable ? */
> =A0 =A0 =A0 =A0if (unlikely(mem_cgroup_stealed(memcg))) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* take a lock against to access pc->mem_c=
group */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 move_lock_page_cgroup(pc, &flags);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_account_move_rlock(page);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0need_unlock =3D true;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memcg =3D pc->mem_cgroup;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!memcg || !PageCgroupUsed(pc))
> @@ -1894,7 +1952,7 @@ void mem_cgroup_update_page_stat(struct page *page,
>
> =A0out:
> =A0 =A0 =A0 =A0if (unlikely(need_unlock))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 move_unlock_page_cgroup(pc, &flags);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_account_move_runlock(page);
> =A0 =A0 =A0 =A0rcu_read_unlock();
> =A0 =A0 =A0 =A0return;
> =A0}
> @@ -2457,8 +2515,7 @@ static void __mem_cgroup_commit_charge(struct mem_c=
group *memcg,
>
> =A0#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>
> -#define PCGF_NOCOPY_AT_SPLIT ((1 << PCG_LOCK) | (1 << PCG_MOVE_LOCK) |\
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1 << PCG_MIGRATION))
> +#define PCGF_NOCOPY_AT_SPLIT ((1 << PCG_LOCK) | =A0(1 << PCG_MIGRATION))
> =A0/*
> =A0* Because tail pages are not marked as "used", set it. We're under
> =A0* zone->lru_lock, 'splitting on pmd' and compound_lock.
> @@ -2537,7 +2594,7 @@ static int mem_cgroup_move_account(struct page *pag=
e,
> =A0 =A0 =A0 =A0if (!PageCgroupUsed(pc) || pc->mem_cgroup !=3D from)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto unlock;
>
> - =A0 =A0 =A0 move_lock_page_cgroup(pc, &flags);
> + =A0 =A0 =A0 mem_cgroup_account_move_wlock(page, &flags);
>
> =A0 =A0 =A0 =A0if (PageCgroupFileMapped(pc)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Update mapped_file data for mem_cgroup =
*/
> @@ -2561,7 +2618,7 @@ static int mem_cgroup_move_account(struct page *pag=
e,
> =A0 =A0 =A0 =A0 * guaranteed that "to" is never removed. So, we don't che=
ck rmdir
> =A0 =A0 =A0 =A0 * status here.
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 move_unlock_page_cgroup(pc, &flags);
> + =A0 =A0 =A0 mem_cgroup_account_move_wunlock(page, flags);
> =A0 =A0 =A0 =A0ret =3D 0;
> =A0unlock:
> =A0 =A0 =A0 =A0unlock_page_cgroup(pc);
> @@ -4938,6 +4995,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct =
cgroup *cont)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0INIT_WORK(&stock->work, dr=
ain_local_stock);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hotcpu_notifier(memcg_cpu_hotplug_callback=
, 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_account_move_lock_init();
> =A0 =A0 =A0 =A0} else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0parent =3D mem_cgroup_from_cont(cont->pare=
nt);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memcg->use_hierarchy =3D parent->use_hiera=
rchy;
> --
> 1.7.4.1
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
