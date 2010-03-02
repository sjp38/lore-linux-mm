Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1755F6B0047
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 05:04:56 -0500 (EST)
Received: by wyb29 with SMTP id 29so32150wyb.14
        for <linux-mm@kvack.org>; Tue, 02 Mar 2010 02:04:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1267478620-5276-3-git-send-email-arighi@develer.com>
References: <1267478620-5276-1-git-send-email-arighi@develer.com>
	 <1267478620-5276-3-git-send-email-arighi@develer.com>
Date: Tue, 2 Mar 2010 12:04:53 +0200
Message-ID: <cc557aab1003020204k16038838ta537357aeeb67b11@mail.gmail.com>
Subject: Re: [PATCH -mmotm 2/3] memcg: dirty pages accounting and limiting
	infrastructure
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrea Righi <arighi@develer.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 1, 2010 at 11:23 PM, Andrea Righi <arighi@develer.com> wrote:
> Infrastructure to account dirty pages per cgroup and add dirty limit
> interfaces in the cgroupfs:
>
> =C2=A0- Direct write-out: memory.dirty_ratio, memory.dirty_bytes
>
> =C2=A0- Background write-out: memory.dirty_background_ratio, memory.dirty=
_background_bytes
>
> Signed-off-by: Andrea Righi <arighi@develer.com>
> ---
> =C2=A0include/linux/memcontrol.h | =C2=A0 77 ++++++++++-
> =C2=A0mm/memcontrol.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A033=
6 ++++++++++++++++++++++++++++++++++++++++----
> =C2=A02 files changed, 384 insertions(+), 29 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 1f9b119..cc88b2e 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -19,12 +19,50 @@
>
> =C2=A0#ifndef _LINUX_MEMCONTROL_H
> =C2=A0#define _LINUX_MEMCONTROL_H
> +
> +#include <linux/writeback.h>
> =C2=A0#include <linux/cgroup.h>
> +
> =C2=A0struct mem_cgroup;
> =C2=A0struct page_cgroup;
> =C2=A0struct page;
> =C2=A0struct mm_struct;
>
> +/* Cgroup memory statistics items exported to the kernel */
> +enum mem_cgroup_page_stat_item {
> + =C2=A0 =C2=A0 =C2=A0 MEMCG_NR_DIRTYABLE_PAGES,
> + =C2=A0 =C2=A0 =C2=A0 MEMCG_NR_RECLAIM_PAGES,
> + =C2=A0 =C2=A0 =C2=A0 MEMCG_NR_WRITEBACK,
> + =C2=A0 =C2=A0 =C2=A0 MEMCG_NR_DIRTY_WRITEBACK_PAGES,
> +};
> +
> +/*
> + * Statistics for memory cgroup.
> + */
> +enum mem_cgroup_stat_index {
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* For MEM_CONTAINER_TYPE_ALL, usage =3D page=
cache + rss.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_STAT_CACHE, =C2=A0 =C2=A0 /* # of pages=
 charged as cache */
> + =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_STAT_RSS, =C2=A0 =C2=A0 =C2=A0 /* # of =
pages charged as anon rss */
> + =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_STAT_FILE_MAPPED, =C2=A0/* # of pages c=
harged as file rss */
> + =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_STAT_PGPGIN_COUNT, =C2=A0 /* # of pages=
 paged in */
> + =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_STAT_PGPGOUT_COUNT, =C2=A0/* # of pages=
 paged out */
> + =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_STAT_EVENTS, /* sum of pagein + pageout=
 for internal use */
> + =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped ou=
t */
> + =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_STAT_SOFTLIMIT, /* decrements on each p=
age in/out.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 used by soft=
 limit implementation */
> + =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_STAT_THRESHOLDS, /* decrements on each =
page in/out.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 used by thre=
shold implementation */
> + =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_STAT_FILE_DIRTY, =C2=A0 /* # of dirty p=
ages in page cache */
> + =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_STAT_WRITEBACK, =C2=A0 /* # of pages un=
der writeback */
> + =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_STAT_WRITEBACK_TEMP, =C2=A0 /* # of pag=
es under writeback using
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 temporary buffers */
> + =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_STAT_UNSTABLE_NFS, =C2=A0 /* # of NFS u=
nstable pages */
> +
> + =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_STAT_NSTATS,
> +};
> +
> =C2=A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> =C2=A0/*
> =C2=A0* All "charge" functions with gfp_mask should use GFP_KERNEL or
> @@ -117,6 +155,13 @@ extern void mem_cgroup_print_oom_info(struct mem_cgr=
oup *memcg,
> =C2=A0extern int do_swap_account;
> =C2=A0#endif
>
> +extern long mem_cgroup_dirty_ratio(void);
> +extern unsigned long mem_cgroup_dirty_bytes(void);
> +extern long mem_cgroup_dirty_background_ratio(void);
> +extern unsigned long mem_cgroup_dirty_background_bytes(void);
> +
> +extern s64 mem_cgroup_page_stat(enum mem_cgroup_page_stat_item item);
> +
> =C2=A0static inline bool mem_cgroup_disabled(void)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (mem_cgroup_subsys.disabled)
> @@ -125,7 +170,8 @@ static inline bool mem_cgroup_disabled(void)
> =C2=A0}
>
> =C2=A0extern bool mem_cgroup_oom_called(struct task_struct *task);
> -void mem_cgroup_update_file_mapped(struct page *page, int val);
> +void mem_cgroup_update_stat(struct page *page,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 enum mem_cgroup_stat_index idx, int val);
> =C2=A0unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int =
order,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0gfp_t gfp_mask, int nid,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0int zid);
> @@ -300,8 +346,8 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, s=
truct task_struct *p)
> =C2=A0{
> =C2=A0}
>
> -static inline void mem_cgroup_update_file_mapped(struct page *page,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int val)
> +static inline void mem_cgroup_update_stat(struct page *page,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 enum mem_cgroup_stat_index idx, int val)
> =C2=A0{
> =C2=A0}
>
> @@ -312,6 +358,31 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct z=
one *zone, int order,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> =C2=A0}
>
> +static inline long mem_cgroup_dirty_ratio(void)
> +{
> + =C2=A0 =C2=A0 =C2=A0 return vm_dirty_ratio;
> +}
> +
> +static inline unsigned long mem_cgroup_dirty_bytes(void)
> +{
> + =C2=A0 =C2=A0 =C2=A0 return vm_dirty_bytes;
> +}
> +
> +static inline long mem_cgroup_dirty_background_ratio(void)
> +{
> + =C2=A0 =C2=A0 =C2=A0 return dirty_background_ratio;
> +}
> +
> +static inline unsigned long mem_cgroup_dirty_background_bytes(void)
> +{
> + =C2=A0 =C2=A0 =C2=A0 return dirty_background_bytes;
> +}
> +
> +static inline s64 mem_cgroup_page_stat(enum mem_cgroup_page_stat_item it=
em)
> +{
> + =C2=A0 =C2=A0 =C2=A0 return -ENOMEM;

Why ENOMEM? Probably, EINVAL or ENOSYS?

> +}
> +
> =C2=A0#endif /* CONFIG_CGROUP_MEM_CONT */
>
> =C2=A0#endif /* _LINUX_MEMCONTROL_H */
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index a443c30..e74cf66 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -66,31 +66,16 @@ static int really_do_swap_account __initdata =3D 1; /=
* for remember boot option*/
> =C2=A0#define SOFTLIMIT_EVENTS_THRESH (1000)
> =C2=A0#define THRESHOLDS_EVENTS_THRESH (100)
>
> -/*
> - * Statistics for memory cgroup.
> - */
> -enum mem_cgroup_stat_index {
> - =C2=A0 =C2=A0 =C2=A0 /*
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* For MEM_CONTAINER_TYPE_ALL, usage =3D page=
cache + rss.
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> - =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_STAT_CACHE, =C2=A0 =C2=A0 /* # of pages=
 charged as cache */
> - =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_STAT_RSS, =C2=A0 =C2=A0 =C2=A0 /* # of =
pages charged as anon rss */
> - =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_STAT_FILE_MAPPED, =C2=A0/* # of pages c=
harged as file rss */
> - =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_STAT_PGPGIN_COUNT, =C2=A0 /* # of pages=
 paged in */
> - =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_STAT_PGPGOUT_COUNT, =C2=A0/* # of pages=
 paged out */
> - =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped ou=
t */
> - =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_STAT_SOFTLIMIT, /* decrements on each p=
age in/out.
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 used by soft=
 limit implementation */
> - =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_STAT_THRESHOLDS, /* decrements on each =
page in/out.
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 used by thre=
shold implementation */
> -
> - =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_STAT_NSTATS,
> -};
> -
> =C2=A0struct mem_cgroup_stat_cpu {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0s64 count[MEM_CGROUP_STAT_NSTATS];
> =C2=A0};
>
> +/* Per cgroup page statistics */
> +struct mem_cgroup_page_stat {
> + =C2=A0 =C2=A0 =C2=A0 enum mem_cgroup_page_stat_item item;
> + =C2=A0 =C2=A0 =C2=A0 s64 value;
> +};
> +
> =C2=A0/*
> =C2=A0* per-zone information in memory controller.
> =C2=A0*/
> @@ -157,6 +142,15 @@ struct mem_cgroup_threshold_ary {
> =C2=A0static bool mem_cgroup_threshold_check(struct mem_cgroup *mem);
> =C2=A0static void mem_cgroup_threshold(struct mem_cgroup *mem);
>
> +enum mem_cgroup_dirty_param {
> + =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_DIRTY_RATIO,
> + =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_DIRTY_BYTES,
> + =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_DIRTY_BACKGROUND_RATIO,
> + =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_DIRTY_BACKGROUND_BYTES,
> +
> + =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_DIRTY_NPARAMS,
> +};
> +
> =C2=A0/*
> =C2=A0* The memory controller data structure. The memory controller contr=
ols both
> =C2=A0* page cache and RSS per cgroup. We would eventually like to provid=
e
> @@ -205,6 +199,9 @@ struct mem_cgroup {
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int =C2=A0 =C2=A0swappiness;
>
> + =C2=A0 =C2=A0 =C2=A0 /* control memory cgroup dirty pages */
> + =C2=A0 =C2=A0 =C2=A0 unsigned long dirty_param[MEM_CGROUP_DIRTY_NPARAMS=
];
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* set when res.limit =3D=3D memsw.limit */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0bool =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
memsw_is_minimum;
>
> @@ -1021,6 +1018,164 @@ static unsigned int get_swappiness(struct mem_cgr=
oup *memcg)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return swappiness;
> =C2=A0}
>
> +static unsigned long get_dirty_param(struct mem_cgroup *memcg,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 enum mem_cgroup_dirty_param idx)
> +{
> + =C2=A0 =C2=A0 =C2=A0 unsigned long ret;
> +
> + =C2=A0 =C2=A0 =C2=A0 VM_BUG_ON(idx >=3D MEM_CGROUP_DIRTY_NPARAMS);
> + =C2=A0 =C2=A0 =C2=A0 spin_lock(&memcg->reclaim_param_lock);
> + =C2=A0 =C2=A0 =C2=A0 ret =3D memcg->dirty_param[idx];
> + =C2=A0 =C2=A0 =C2=A0 spin_unlock(&memcg->reclaim_param_lock);
> +
> + =C2=A0 =C2=A0 =C2=A0 return ret;
> +}
> +
> +long mem_cgroup_dirty_ratio(void)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *memcg;
> + =C2=A0 =C2=A0 =C2=A0 long ret =3D vm_dirty_ratio;
> +
> + =C2=A0 =C2=A0 =C2=A0 if (mem_cgroup_disabled())
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* It's possible that "current" may be moved =
to other cgroup while we
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* access cgroup. But precise check is meanin=
gless because the task can
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* be moved after our access and writeback te=
nds to take long time.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* At least, "memcg" will not be freed under =
rcu_read_lock().
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 rcu_read_lock();
> + =C2=A0 =C2=A0 =C2=A0 memcg =3D mem_cgroup_from_task(current);
> + =C2=A0 =C2=A0 =C2=A0 if (likely(memcg))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D get_dirty_para=
m(memcg, MEM_CGROUP_DIRTY_RATIO);
> + =C2=A0 =C2=A0 =C2=A0 rcu_read_unlock();
> +
> + =C2=A0 =C2=A0 =C2=A0 return ret;
> +}
> +
> +unsigned long mem_cgroup_dirty_bytes(void)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *memcg;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long ret =3D vm_dirty_bytes;
> +
> + =C2=A0 =C2=A0 =C2=A0 if (mem_cgroup_disabled())
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;
> + =C2=A0 =C2=A0 =C2=A0 rcu_read_lock();
> + =C2=A0 =C2=A0 =C2=A0 memcg =3D mem_cgroup_from_task(current);
> + =C2=A0 =C2=A0 =C2=A0 if (likely(memcg))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D get_dirty_para=
m(memcg, MEM_CGROUP_DIRTY_BYTES);
> + =C2=A0 =C2=A0 =C2=A0 rcu_read_unlock();
> +
> + =C2=A0 =C2=A0 =C2=A0 return ret;
> +}
> +
> +long mem_cgroup_dirty_background_ratio(void)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *memcg;
> + =C2=A0 =C2=A0 =C2=A0 long ret =3D dirty_background_ratio;
> +
> + =C2=A0 =C2=A0 =C2=A0 if (mem_cgroup_disabled())
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;
> + =C2=A0 =C2=A0 =C2=A0 rcu_read_lock();
> + =C2=A0 =C2=A0 =C2=A0 memcg =3D mem_cgroup_from_task(current);
> + =C2=A0 =C2=A0 =C2=A0 if (likely(memcg))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D get_dirty_para=
m(memcg, MEM_CGROUP_DIRTY_BACKGROUND_RATIO);
> + =C2=A0 =C2=A0 =C2=A0 rcu_read_unlock();
> +
> + =C2=A0 =C2=A0 =C2=A0 return ret;
> +}
> +
> +unsigned long mem_cgroup_dirty_background_bytes(void)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *memcg;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long ret =3D dirty_background_bytes;
> +
> + =C2=A0 =C2=A0 =C2=A0 if (mem_cgroup_disabled())
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;
> + =C2=A0 =C2=A0 =C2=A0 rcu_read_lock();
> + =C2=A0 =C2=A0 =C2=A0 memcg =3D mem_cgroup_from_task(current);
> + =C2=A0 =C2=A0 =C2=A0 if (likely(memcg))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D get_dirty_para=
m(memcg, MEM_CGROUP_DIRTY_BACKGROUND_BYTES);
> + =C2=A0 =C2=A0 =C2=A0 rcu_read_unlock();
> +
> + =C2=A0 =C2=A0 =C2=A0 return ret;
> +}
> +
> +static inline bool mem_cgroup_can_swap(struct mem_cgroup *memcg)
> +{
> + =C2=A0 =C2=A0 =C2=A0 return do_swap_account ?
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 res_counter_read_u64(&memcg->memsw, RES_LIMIT) :
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 nr_swap_pages > 0;
> +}
> +
> +static s64 mem_cgroup_get_local_page_stat(struct mem_cgroup *memcg,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 enum mem_cgroup_page_stat_item item)
> +{
> + =C2=A0 =C2=A0 =C2=A0 s64 ret;
> +
> + =C2=A0 =C2=A0 =C2=A0 switch (item) {
> + =C2=A0 =C2=A0 =C2=A0 case MEMCG_NR_DIRTYABLE_PAGES:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D res_counter_re=
ad_u64(&memcg->res, RES_LIMIT) -
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 res_counter_read_u64(&memcg->res, RES_USAGE);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Translate free memo=
ry in pages */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret >>=3D PAGE_SHIFT;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret +=3D mem_cgroup_re=
ad_stat(memcg, LRU_ACTIVE_FILE) +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 mem_cgroup_read_stat(memcg, LRU_INACTIVE_FILE);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (mem_cgroup_can_swa=
p(memcg))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 ret +=3D mem_cgroup_read_stat(memcg, LRU_ACTIVE_ANON) +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_read_stat(memcg, LRU_INACTIVE=
_ANON);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 case MEMCG_NR_RECLAIM_PAGES:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D mem_cgroup_rea=
d_stat(memcg, MEM_CGROUP_STAT_FILE_DIRTY) +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 mem_cgroup_read_stat(memcg,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_S=
TAT_UNSTABLE_NFS);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 case MEMCG_NR_WRITEBACK:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D mem_cgroup_rea=
d_stat(memcg, MEM_CGROUP_STAT_WRITEBACK);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 case MEMCG_NR_DIRTY_WRITEBACK_PAGES:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D mem_cgroup_rea=
d_stat(memcg, MEM_CGROUP_STAT_WRITEBACK) +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 mem_cgroup_read_stat(memcg,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_STAT_UNSTABLE_NFS);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 default:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 WARN_ON_ONCE(1);

I think it's a bug, not warning.

> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 return ret;
> +}
> +
> +static int mem_cgroup_page_stat_cb(struct mem_cgroup *mem, void *data)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup_page_stat *stat =3D (struct mem_=
cgroup_page_stat *)data;
> +
> + =C2=A0 =C2=A0 =C2=A0 stat->value +=3D mem_cgroup_get_local_page_stat(me=
m, stat->item);
> + =C2=A0 =C2=A0 =C2=A0 return 0;
> +}
> +
> +s64 mem_cgroup_page_stat(enum mem_cgroup_page_stat_item item)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup_page_stat stat =3D {};
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *memcg;
> +
> + =C2=A0 =C2=A0 =C2=A0 if (mem_cgroup_disabled())
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -ENOMEM;

EINVAL/ENOSYS?

> + =C2=A0 =C2=A0 =C2=A0 rcu_read_lock();
> + =C2=A0 =C2=A0 =C2=A0 memcg =3D mem_cgroup_from_task(current);
> + =C2=A0 =C2=A0 =C2=A0 if (memcg) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Recursively ev=
aulate page statistics against all cgroup
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* under hierarch=
y tree
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 stat.item =3D item;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_walk_tree(m=
emcg, &stat, mem_cgroup_page_stat_cb);
> + =C2=A0 =C2=A0 =C2=A0 } else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 stat.value =3D -ENOMEM=
;

ditto.

> + =C2=A0 =C2=A0 =C2=A0 rcu_read_unlock();
> +
> + =C2=A0 =C2=A0 =C2=A0 return stat.value;
> +}
> +
> =C2=A0static int mem_cgroup_count_children_cb(struct mem_cgroup *mem, voi=
d *data)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int *val =3D data;
> @@ -1263,14 +1418,16 @@ static void record_last_oom(struct mem_cgroup *me=
m)
> =C2=A0}
>
> =C2=A0/*
> - * Currently used to update mapped file statistics, but the routine can =
be
> - * generalized to update other statistics as well.
> + * Generalized routine to update memory cgroup statistics.
> =C2=A0*/
> -void mem_cgroup_update_file_mapped(struct page *page, int val)
> +void mem_cgroup_update_stat(struct page *page,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 enum mem_cgroup_stat_index idx, int val)

EXPORT_SYMBOL_GPL(mem_cgroup_update_stat) is needed, since
it uses by filesystems.

> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgroup *mem;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page_cgroup *pc;
>
> + =C2=A0 =C2=A0 =C2=A0 if (mem_cgroup_disabled())
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pc =3D lookup_page_cgroup(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (unlikely(!pc))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;
> @@ -1286,7 +1443,8 @@ void mem_cgroup_update_file_mapped(struct page *pag=
e, int val)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Preemption is already disabled. We can use =
__this_cpu_xxx
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> - =C2=A0 =C2=A0 =C2=A0 __this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_FI=
LE_MAPPED], val);
> + =C2=A0 =C2=A0 =C2=A0 VM_BUG_ON(idx >=3D MEM_CGROUP_STAT_NSTATS);
> + =C2=A0 =C2=A0 =C2=A0 __this_cpu_add(mem->stat->count[idx], val);
>
> =C2=A0done:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unlock_page_cgroup(pc);
> @@ -3033,6 +3191,10 @@ enum {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0MCS_PGPGIN,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0MCS_PGPGOUT,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0MCS_SWAP,
> + =C2=A0 =C2=A0 =C2=A0 MCS_FILE_DIRTY,
> + =C2=A0 =C2=A0 =C2=A0 MCS_WRITEBACK,
> + =C2=A0 =C2=A0 =C2=A0 MCS_WRITEBACK_TEMP,
> + =C2=A0 =C2=A0 =C2=A0 MCS_UNSTABLE_NFS,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0MCS_INACTIVE_ANON,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0MCS_ACTIVE_ANON,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0MCS_INACTIVE_FILE,
> @@ -3055,6 +3217,10 @@ struct {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{"pgpgin", "total_pgpgin"},
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{"pgpgout", "total_pgpgout"},
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{"swap", "total_swap"},
> + =C2=A0 =C2=A0 =C2=A0 {"filedirty", "dirty_pages"},
> + =C2=A0 =C2=A0 =C2=A0 {"writeback", "writeback_pages"},
> + =C2=A0 =C2=A0 =C2=A0 {"writeback_tmp", "writeback_temp_pages"},
> + =C2=A0 =C2=A0 =C2=A0 {"nfs", "nfs_unstable"},
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{"inactive_anon", "total_inactive_anon"},
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{"active_anon", "total_active_anon"},
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{"inactive_file", "total_inactive_file"},
> @@ -3083,6 +3249,14 @@ static int mem_cgroup_get_local_stat(struct mem_cg=
roup *mem, void *data)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0val =3D mem_cgroup=
_read_stat(mem, MEM_CGROUP_STAT_SWAPOUT);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0s->stat[MCS_SWAP] =
+=3D val * PAGE_SIZE;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> + =C2=A0 =C2=A0 =C2=A0 val =3D mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_=
FILE_DIRTY);
> + =C2=A0 =C2=A0 =C2=A0 s->stat[MCS_FILE_DIRTY] +=3D val;
> + =C2=A0 =C2=A0 =C2=A0 val =3D mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_=
WRITEBACK);
> + =C2=A0 =C2=A0 =C2=A0 s->stat[MCS_WRITEBACK] +=3D val;
> + =C2=A0 =C2=A0 =C2=A0 val =3D mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_=
WRITEBACK_TEMP);
> + =C2=A0 =C2=A0 =C2=A0 s->stat[MCS_WRITEBACK_TEMP] +=3D val;
> + =C2=A0 =C2=A0 =C2=A0 val =3D mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_=
UNSTABLE_NFS);
> + =C2=A0 =C2=A0 =C2=A0 s->stat[MCS_UNSTABLE_NFS] +=3D val;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* per zone stat */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0val =3D mem_cgroup_get_local_zonestat(mem, LRU=
_INACTIVE_ANON);
> @@ -3467,6 +3641,50 @@ unlock:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
> =C2=A0}
>
> +static u64 mem_cgroup_dirty_read(struct cgroup *cgrp, struct cftype *cft=
)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *memcg =3D mem_cgroup_from_cont(=
cgrp);
> + =C2=A0 =C2=A0 =C2=A0 int type =3D cft->private;
> +
> + =C2=A0 =C2=A0 =C2=A0 return get_dirty_param(memcg, type);
> +}
> +
> +static int
> +mem_cgroup_dirty_write(struct cgroup *cgrp, struct cftype *cft, u64 val)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *memcg =3D mem_cgroup_from_cont(=
cgrp);
> + =C2=A0 =C2=A0 =C2=A0 int type =3D cft->private;
> +
> + =C2=A0 =C2=A0 =C2=A0 if (cgrp->parent =3D=3D NULL)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EINVAL;
> + =C2=A0 =C2=A0 =C2=A0 if (((type =3D=3D MEM_CGROUP_DIRTY_RATIO) ||
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (type =3D=3D MEM_CGROU=
P_DIRTY_BACKGROUND_RATIO)) && (val > 100))

Too many unnecessary brackets

       if ((type =3D=3D MEM_CGROUP_DIRTY_RATIO ||
               type =3D=3D MEM_CGROUP_DIRTY_BACKGROUND_RATIO) && val > 100)

> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EINVAL;
> +
> + =C2=A0 =C2=A0 =C2=A0 spin_lock(&memcg->reclaim_param_lock);
> + =C2=A0 =C2=A0 =C2=A0 switch (type) {
> + =C2=A0 =C2=A0 =C2=A0 case MEM_CGROUP_DIRTY_RATIO:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcg->dirty_param[MEM=
_CGROUP_DIRTY_RATIO] =3D val;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcg->dirty_param[MEM=
_CGROUP_DIRTY_BYTES] =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 case MEM_CGROUP_DIRTY_BYTES:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcg->dirty_param[MEM=
_CGROUP_DIRTY_RATIO] =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcg->dirty_param[MEM=
_CGROUP_DIRTY_BYTES] =3D val;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 case MEM_CGROUP_DIRTY_BACKGROUND_RATIO:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcg->dirty_param[MEM=
_CGROUP_DIRTY_BACKGROUND_RATIO] =3D val;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcg->dirty_param[MEM=
_CGROUP_DIRTY_BACKGROUND_BYTES] =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 case MEM_CGROUP_DIRTY_BACKGROUND_BYTES:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcg->dirty_param[MEM=
_CGROUP_DIRTY_BACKGROUND_RATIO] =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcg->dirty_param[MEM=
_CGROUP_DIRTY_BACKGROUND_BYTES] =3D val;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 spin_unlock(&memcg->reclaim_param_lock);
> +
> + =C2=A0 =C2=A0 =C2=A0 return 0;
> +}
> +
> =C2=A0static struct cftype mem_cgroup_files[] =3D {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.name =3D "usage_i=
n_bytes",
> @@ -3518,6 +3736,30 @@ static struct cftype mem_cgroup_files[] =3D {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.write_u64 =3D mem=
_cgroup_swappiness_write,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0},
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .name =3D "dirty_ratio=
",
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .read_u64 =3D mem_cgro=
up_dirty_read,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .write_u64 =3D mem_cgr=
oup_dirty_write,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .private =3D MEM_CGROU=
P_DIRTY_RATIO,
> + =C2=A0 =C2=A0 =C2=A0 },
> + =C2=A0 =C2=A0 =C2=A0 {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .name =3D "dirty_bytes=
",
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .read_u64 =3D mem_cgro=
up_dirty_read,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .write_u64 =3D mem_cgr=
oup_dirty_write,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .private =3D MEM_CGROU=
P_DIRTY_BYTES,
> + =C2=A0 =C2=A0 =C2=A0 },
> + =C2=A0 =C2=A0 =C2=A0 {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .name =3D "dirty_backg=
round_ratio",
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .read_u64 =3D mem_cgro=
up_dirty_read,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .write_u64 =3D mem_cgr=
oup_dirty_write,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .private =3D MEM_CGROU=
P_DIRTY_BACKGROUND_RATIO,
> + =C2=A0 =C2=A0 =C2=A0 },
> + =C2=A0 =C2=A0 =C2=A0 {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .name =3D "dirty_backg=
round_bytes",
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .read_u64 =3D mem_cgro=
up_dirty_read,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .write_u64 =3D mem_cgr=
oup_dirty_write,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .private =3D MEM_CGROU=
P_DIRTY_BACKGROUND_BYTES,
> + =C2=A0 =C2=A0 =C2=A0 },
> + =C2=A0 =C2=A0 =C2=A0 {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.name =3D "move_ch=
arge_at_immigrate",
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.read_u64 =3D mem_=
cgroup_move_charge_read,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.write_u64 =3D mem=
_cgroup_move_charge_write,
> @@ -3725,6 +3967,19 @@ static int mem_cgroup_soft_limit_tree_init(void)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> =C2=A0}
>
> +/*
> + * NOTE: called only with &src->reclaim_param_lock held from
> + * mem_cgroup_create().
> + */
> +static inline void
> +copy_dirty_params(struct mem_cgroup *dst, struct mem_cgroup *src)
> +{
> + =C2=A0 =C2=A0 =C2=A0 int i;
> +
> + =C2=A0 =C2=A0 =C2=A0 for (i =3D 0; i < MEM_CGROUP_DIRTY_NPARAMS; i++)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dst->dirty_param[i] =
=3D src->dirty_param[i];
> +}
> +
> =C2=A0static struct cgroup_subsys_state * __ref
> =C2=A0mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
> =C2=A0{
> @@ -3776,8 +4031,37 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct=
 cgroup *cont)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mem->last_scanned_child =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_init(&mem->reclaim_param_lock);
>
> - =C2=A0 =C2=A0 =C2=A0 if (parent)
> + =C2=A0 =C2=A0 =C2=A0 if (parent) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mem->swappiness =
=3D get_swappiness(parent);
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_lock(&parent->rec=
laim_param_lock);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 copy_dirty_params(mem,=
 parent);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock(&parent->r=
eclaim_param_lock);
> + =C2=A0 =C2=A0 =C2=A0 } else {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* XXX: should we=
 need a lock here? we could switch from
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* vm_dirty_ratio=
 to vm_dirty_bytes or vice versa but we're not
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* reading them a=
tomically. The same for dirty_background_ratio
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* and dirty_back=
ground_bytes.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* For now, try t=
o read them speculatively and retry if a
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* "conflict" is =
detected.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 do {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 mem->dirty_param[MEM_CGROUP_DIRTY_RATIO] =3D
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 vm_dirty_ratio;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 mem->dirty_param[MEM_CGROUP_DIRTY_BYTES] =3D
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 vm_dirty_bytes;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } while (mem->dirty_pa=
ram[MEM_CGROUP_DIRTY_RATIO] &&
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0mem->dirty_param[MEM_CGROUP_DIRTY_BYTES]);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 do {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 mem->dirty_param[MEM_CGROUP_DIRTY_BACKGROUND_RATIO] =3D
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 dirty_background_ratio;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 mem->dirty_param[MEM_CGROUP_DIRTY_BACKGROUND_BYTES] =3D
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 dirty_background_bytes;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } while (mem->dirty_pa=
ram[MEM_CGROUP_DIRTY_BACKGROUND_RATIO] &&
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 mem->dirty_param[MEM_CGROUP_DIRTY_BACKGROUND_BYTES]);
> + =C2=A0 =C2=A0 =C2=A0 }
> =C2=A0 =C2=A0 =C2=A0 =C2=A0atomic_set(&mem->refcnt, 1);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mem->move_charge_at_immigrate =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mutex_init(&mem->thresholds_lock);
> --
> 1.6.3.3
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
