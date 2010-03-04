Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6F3A96B0047
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 06:54:55 -0500 (EST)
Received: by wwg30 with SMTP id 30so746042wwg.14
        for <linux-mm@kvack.org>; Thu, 04 Mar 2010 03:54:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1267699215-4101-4-git-send-email-arighi@develer.com>
References: <1267699215-4101-1-git-send-email-arighi@develer.com>
	 <1267699215-4101-4-git-send-email-arighi@develer.com>
Date: Thu, 4 Mar 2010 13:54:51 +0200
Message-ID: <cc557aab1003040354t34e57836r4bd1f9162005c653@mail.gmail.com>
Subject: Re: [PATCH -mmotm 3/4] memcg: dirty pages accounting and limiting
	infrastructure
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrea Righi <arighi@develer.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 4, 2010 at 12:40 PM, Andrea Righi <arighi@develer.com> wrote:
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
> =C2=A0include/linux/memcontrol.h | =C2=A0 80 ++++++++-
> =C2=A0mm/memcontrol.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A042=
0 +++++++++++++++++++++++++++++++++++++++-----
> =C2=A02 files changed, 450 insertions(+), 50 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 1f9b119..cc3421b 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -19,12 +19,66 @@
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
> +/* Dirty memory parameters */
> +struct dirty_param {
> + =C2=A0 =C2=A0 =C2=A0 int dirty_ratio;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long dirty_bytes;
> + =C2=A0 =C2=A0 =C2=A0 int dirty_background_ratio;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long dirty_background_bytes;
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
> + =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped ou=
t */
> + =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_EVENTS, =C2=A0 =C2=A0 =C2=A0/* incremen=
ted at every =C2=A0pagein/pageout */
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
> +/*
> + * TODO: provide a validation check routine. And retry if validation
> + * fails.
> + */
> +static inline void get_global_dirty_param(struct dirty_param *param)
> +{
> + =C2=A0 =C2=A0 =C2=A0 param->dirty_ratio =3D vm_dirty_ratio;
> + =C2=A0 =C2=A0 =C2=A0 param->dirty_bytes =3D vm_dirty_bytes;
> + =C2=A0 =C2=A0 =C2=A0 param->dirty_background_ratio =3D dirty_background=
_ratio;
> + =C2=A0 =C2=A0 =C2=A0 param->dirty_background_bytes =3D dirty_background=
_bytes;
> +}
> +
> =C2=A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> =C2=A0/*
> =C2=A0* All "charge" functions with gfp_mask should use GFP_KERNEL or
> @@ -117,6 +171,10 @@ extern void mem_cgroup_print_oom_info(struct mem_cgr=
oup *memcg,
> =C2=A0extern int do_swap_account;
> =C2=A0#endif
>
> +extern bool mem_cgroup_has_dirty_limit(void);
> +extern void get_dirty_param(struct dirty_param *param);
> +extern s64 mem_cgroup_page_stat(enum mem_cgroup_page_stat_item item);
> +
> =C2=A0static inline bool mem_cgroup_disabled(void)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (mem_cgroup_subsys.disabled)
> @@ -125,7 +183,8 @@ static inline bool mem_cgroup_disabled(void)
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
> @@ -300,8 +359,8 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, s=
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
> @@ -312,6 +371,21 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct z=
one *zone, int order,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> =C2=A0}
>
> +static inline bool mem_cgroup_has_dirty_limit(void)
> +{
> + =C2=A0 =C2=A0 =C2=A0 return false;
> +}
> +
> +static inline void get_dirty_param(struct dirty_param *param)
> +{
> + =C2=A0 =C2=A0 =C2=A0 get_global_dirty_param(param);
> +}
> +
> +static inline s64 mem_cgroup_page_stat(enum mem_cgroup_page_stat_item it=
em)
> +{
> + =C2=A0 =C2=A0 =C2=A0 return -ENOSYS;
> +}
> +
> =C2=A0#endif /* CONFIG_CGROUP_MEM_CONT */
>
> =C2=A0#endif /* _LINUX_MEMCONTROL_H */
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 497b6f7..9842e7b 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -73,28 +73,23 @@ static int really_do_swap_account __initdata =3D 1; /=
* for remember boot option*/
> =C2=A0#define THRESHOLDS_EVENTS_THRESH (7) /* once in 128 */
> =C2=A0#define SOFTLIMIT_EVENTS_THRESH (10) /* once in 1024 */
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
> - =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_EVENTS, =C2=A0 =C2=A0 =C2=A0/* incremen=
ted at every =C2=A0pagein/pageout */
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
> +enum {
> + =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_DIRTY_RATIO,
> + =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_DIRTY_BYTES,
> + =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_DIRTY_BACKGROUND_RATIO,
> + =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_DIRTY_BACKGROUND_BYTES,
> +};
> +
> =C2=A0/*
> =C2=A0* per-zone information in memory controller.
> =C2=A0*/
> @@ -208,6 +203,9 @@ struct mem_cgroup {
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int =C2=A0 =C2=A0swappiness;
>
> + =C2=A0 =C2=A0 =C2=A0 /* control memory cgroup dirty pages */
> + =C2=A0 =C2=A0 =C2=A0 struct dirty_param dirty_param;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* set when res.limit =3D=3D memsw.limit */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0bool =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
memsw_is_minimum;
>
> @@ -1033,6 +1031,156 @@ static unsigned int get_swappiness(struct mem_cgr=
oup *memcg)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return swappiness;
> =C2=A0}
>
> +static bool dirty_param_is_valid(struct dirty_param *param)
> +{
> + =C2=A0 =C2=A0 =C2=A0 if (param->dirty_ratio && param->dirty_bytes)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return false;
> + =C2=A0 =C2=A0 =C2=A0 if (param->dirty_background_ratio && param->dirty_=
background_bytes)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return false;
> + =C2=A0 =C2=A0 =C2=A0 return true;
> +}
> +
> +static void
> +__mem_cgroup_get_dirty_param(struct dirty_param *param, struct mem_cgrou=
p *mem)
> +{
> + =C2=A0 =C2=A0 =C2=A0 param->dirty_ratio =3D mem->dirty_param.dirty_rati=
o;
> + =C2=A0 =C2=A0 =C2=A0 param->dirty_bytes =3D mem->dirty_param.dirty_byte=
s;
> + =C2=A0 =C2=A0 =C2=A0 param->dirty_background_ratio =3D mem->dirty_param=
.dirty_background_ratio;
> + =C2=A0 =C2=A0 =C2=A0 param->dirty_background_bytes =3D mem->dirty_param=
.dirty_background_bytes;
> +}
> +
> +/*
> + * get_dirty_param() - get dirty memory parameters of the current memcg
> + * @param: =C2=A0 =C2=A0 a structure is filled with the dirty memory set=
tings
> + *
> + * The function fills @param with the current memcg dirty memory setting=
s. If
> + * memory cgroup is disabled or in case of error the structure is filled=
 with
> + * the global dirty memory settings.
> + */
> +void get_dirty_param(struct dirty_param *param)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *memcg;
> +
> + =C2=A0 =C2=A0 =C2=A0 if (mem_cgroup_disabled()) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 get_global_dirty_param=
(param);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
> + =C2=A0 =C2=A0 =C2=A0 }
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
> + =C2=A0 =C2=A0 =C2=A0 while (1) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rcu_read_lock();
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcg =3D mem_cgroup_f=
rom_task(current);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (likely(memcg))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 __mem_cgroup_get_dirty_param(param, memcg);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 get_global_dirty_param(param);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rcu_read_unlock();
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Since global a=
nd memcg dirty_param are not protected we try
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* to speculative=
ly read them and retry if we get inconsistent
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* values.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (likely(dirty_param=
_is_valid(param)))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 }
> +}
> +
> +static inline bool mem_cgroup_can_swap(struct mem_cgroup *memcg)
> +{
> + =C2=A0 =C2=A0 =C2=A0 if (!do_swap_account)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return nr_swap_pages >=
 0;
> + =C2=A0 =C2=A0 =C2=A0 return !memcg->memsw_is_minimum &&
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (res_counter_read_u64(=
&memcg->memsw, RES_LIMIT) > 0);
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
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG_ON(1);

Just BUG()?
Andd add 'break;', please.

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
> +/*
> + * mem_cgroup_has_dirty_limit() - check if current memcg has local dirty=
 limits
> + *
> + * Return true if the current memory cgroup has local dirty memory setti=
ngs,
> + * false otherwise.
> + */
> +bool mem_cgroup_has_dirty_limit(void)
> +{
> + =C2=A0 =C2=A0 =C2=A0 if (mem_cgroup_disabled())
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return false;
> + =C2=A0 =C2=A0 =C2=A0 return mem_cgroup_from_task(current) !=3D NULL;
> +}
> +
> +/*
> + * mem_cgroup_page_stat() - get memory cgroup file cache statistics
> + * @item: =C2=A0 =C2=A0 =C2=A0memory statistic item exported to the kern=
el
> + *
> + * Return the accounted statistic value, or a negative value in case of =
error.
> + */
> +s64 mem_cgroup_page_stat(enum mem_cgroup_page_stat_item item)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup_page_stat stat =3D {};
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *memcg;
> +
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
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 stat.value =3D -EINVAL=
;
> + =C2=A0 =C2=A0 =C2=A0 rcu_read_unlock();
> +
> + =C2=A0 =C2=A0 =C2=A0 return stat.value;
> +}
> +
> =C2=A0static int mem_cgroup_count_children_cb(struct mem_cgroup *mem, voi=
d *data)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int *val =3D data;
> @@ -1275,34 +1423,70 @@ static void record_last_oom(struct mem_cgroup *me=
m)
> =C2=A0}
>
> =C2=A0/*
> - * Currently used to update mapped file statistics, but the routine can =
be
> - * generalized to update other statistics as well.
> + * Generalized routine to update file cache's status for memcg.
> + *
> + * Before calling this, mapping->tree_lock should be held and preemption=
 is
> + * disabled. =C2=A0Then, it's guarnteed that the page is not uncharged w=
hile we
> + * access page_cgroup. We can make use of that.
> =C2=A0*/
> -void mem_cgroup_update_file_mapped(struct page *page, int val)
> +void mem_cgroup_update_stat(struct page *page,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 enum mem_cgroup_stat_index idx, int val)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgroup *mem;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page_cgroup *pc;
>
> + =C2=A0 =C2=A0 =C2=A0 if (mem_cgroup_disabled())
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pc =3D lookup_page_cgroup(page);
> - =C2=A0 =C2=A0 =C2=A0 if (unlikely(!pc))
> + =C2=A0 =C2=A0 =C2=A0 if (unlikely(!pc) || !PageCgroupUsed(pc))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;
>
> - =C2=A0 =C2=A0 =C2=A0 lock_page_cgroup(pc);
> - =C2=A0 =C2=A0 =C2=A0 mem =3D pc->mem_cgroup;
> - =C2=A0 =C2=A0 =C2=A0 if (!mem)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto done;
> -
> - =C2=A0 =C2=A0 =C2=A0 if (!PageCgroupUsed(pc))
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto done;
> -
> + =C2=A0 =C2=A0 =C2=A0 lock_page_cgroup_migrate(pc);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* Preemption is already disabled. We can use=
 __this_cpu_xxx
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> - =C2=A0 =C2=A0 =C2=A0 __this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_FI=
LE_MAPPED], val);
> -
> -done:
> - =C2=A0 =C2=A0 =C2=A0 unlock_page_cgroup(pc);
> + =C2=A0 =C2=A0 =C2=A0 * It's guarnteed that this page is never uncharged=
.
> + =C2=A0 =C2=A0 =C2=A0 * The only racy problem is moving account among me=
mcgs.
> + =C2=A0 =C2=A0 =C2=A0 */
> + =C2=A0 =C2=A0 =C2=A0 switch (idx) {
> + =C2=A0 =C2=A0 =C2=A0 case MEM_CGROUP_STAT_FILE_MAPPED:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (val > 0)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 SetPageCgroupFileMapped(pc);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 ClearPageCgroupFileMapped(pc);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 case MEM_CGROUP_STAT_FILE_DIRTY:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (val > 0)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 SetPageCgroupDirty(pc);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 ClearPageCgroupDirty(pc);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 case MEM_CGROUP_STAT_WRITEBACK:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (val > 0)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 SetPageCgroupWriteback(pc);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 ClearPageCgroupWriteback(pc);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 case MEM_CGROUP_STAT_WRITEBACK_TEMP:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (val > 0)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 SetPageCgroupWritebackTemp(pc);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 ClearPageCgroupWritebackTemp(pc);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 case MEM_CGROUP_STAT_UNSTABLE_NFS:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (val > 0)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 SetPageCgroupUnstableNFS(pc);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 ClearPageCgroupUnstableNFS(pc);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 default:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG();
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 mem =3D pc->mem_cgroup;
> + =C2=A0 =C2=A0 =C2=A0 if (likely(mem))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __this_cpu_add(mem->st=
at->count[idx], val);
> + =C2=A0 =C2=A0 =C2=A0 unlock_page_cgroup_migrate(pc);
> =C2=A0}
> +EXPORT_SYMBOL_GPL(mem_cgroup_update_stat);
>
> =C2=A0/*
> =C2=A0* size of first charge trial. "32" comes from vmscan.c's magic valu=
e.
> @@ -1701,6 +1885,45 @@ static void __mem_cgroup_commit_charge(struct mem_=
cgroup *mem,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0memcg_check_events(mem, pc->page);
> =C2=A0}
>
> +/*
> + * Update file cache accounted statistics on task migration.
> + *
> + * TODO: We don't move charges of file (including shmem/tmpfs) pages for=
 now.
> + * So, at the moment this function simply returns without updating accou=
nted
> + * statistics, because we deal only with anonymous pages here.
> + */
> +static void __mem_cgroup_update_file_stat(struct page_cgroup *pc,
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *from, struct mem_cgroup *to)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct page *page =3D pc->page;
> +
> + =C2=A0 =C2=A0 =C2=A0 if (!page_mapped(page) || PageAnon(page))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
> +
> + =C2=A0 =C2=A0 =C2=A0 if (PageCgroupFileMapped(pc)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __this_cpu_dec(from->s=
tat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __this_cpu_inc(to->sta=
t->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 if (PageCgroupDirty(pc)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __this_cpu_dec(from->s=
tat->count[MEM_CGROUP_STAT_FILE_DIRTY]);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __this_cpu_inc(to->sta=
t->count[MEM_CGROUP_STAT_FILE_DIRTY]);
> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 if (PageCgroupWriteback(pc)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __this_cpu_dec(from->s=
tat->count[MEM_CGROUP_STAT_WRITEBACK]);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __this_cpu_inc(to->sta=
t->count[MEM_CGROUP_STAT_WRITEBACK]);
> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 if (PageCgroupWritebackTemp(pc)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __this_cpu_dec(
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 from->stat->count[MEM_CGROUP_STAT_WRITEBACK_TEMP]);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __this_cpu_inc(to->sta=
t->count[MEM_CGROUP_STAT_WRITEBACK_TEMP]);
> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 if (PageCgroupUnstableNFS(pc)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __this_cpu_dec(
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 from->stat->count[MEM_CGROUP_STAT_UNSTABLE_NFS]);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __this_cpu_inc(to->sta=
t->count[MEM_CGROUP_STAT_UNSTABLE_NFS]);
> + =C2=A0 =C2=A0 =C2=A0 }
> +}
> +
> =C2=A0/**
> =C2=A0* __mem_cgroup_move_account - move account of the page
> =C2=A0* @pc: =C2=A0 =C2=A0 =C2=A0 =C2=A0page_cgroup of the page.
> @@ -1721,22 +1944,16 @@ static void __mem_cgroup_commit_charge(struct mem=
_cgroup *mem,
> =C2=A0static void __mem_cgroup_move_account(struct page_cgroup *pc,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgroup *from, struct mem_cgroup *to=
, bool uncharge)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 struct page *page;
> -
> =C2=A0 =C2=A0 =C2=A0 =C2=A0VM_BUG_ON(from =3D=3D to);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0VM_BUG_ON(PageLRU(pc->page));
> =C2=A0 =C2=A0 =C2=A0 =C2=A0VM_BUG_ON(!PageCgroupLocked(pc));
> =C2=A0 =C2=A0 =C2=A0 =C2=A0VM_BUG_ON(!PageCgroupUsed(pc));
> =C2=A0 =C2=A0 =C2=A0 =C2=A0VM_BUG_ON(pc->mem_cgroup !=3D from);
>
> - =C2=A0 =C2=A0 =C2=A0 page =3D pc->page;
> - =C2=A0 =C2=A0 =C2=A0 if (page_mapped(page) && !PageAnon(page)) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Update mapped_file =
data for mem_cgroup */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 preempt_disable();
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __this_cpu_dec(from->s=
tat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __this_cpu_inc(to->sta=
t->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 preempt_enable();
> - =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 preempt_disable();
> + =C2=A0 =C2=A0 =C2=A0 lock_page_cgroup_migrate(pc);
> + =C2=A0 =C2=A0 =C2=A0 __mem_cgroup_update_file_stat(pc, from, to);
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mem_cgroup_charge_statistics(from, pc, false);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (uncharge)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* This is not "ca=
ncel", but cancel_charge does all we need. */
> @@ -1745,6 +1962,8 @@ static void __mem_cgroup_move_account(struct page_c=
group *pc,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* caller should have done css_get */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pc->mem_cgroup =3D to;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mem_cgroup_charge_statistics(to, pc, true);
> + =C2=A0 =C2=A0 =C2=A0 unlock_page_cgroup_migrate(pc);
> + =C2=A0 =C2=A0 =C2=A0 preempt_enable();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * We charges against "to" which may not have =
any tasks. Then, "to"
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * can be under rmdir(). But in current implem=
entation, caller of
> @@ -3042,6 +3261,10 @@ enum {
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
> @@ -3064,6 +3287,10 @@ struct {
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
> @@ -3092,6 +3319,14 @@ static int mem_cgroup_get_local_stat(struct mem_cg=
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
> @@ -3453,6 +3688,60 @@ unlock:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
> =C2=A0}
>
> +static u64 mem_cgroup_dirty_read(struct cgroup *cgrp, struct cftype *cft=
)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *memcg =3D mem_cgroup_from_cont(=
cgrp);
> +
> + =C2=A0 =C2=A0 =C2=A0 switch (cft->private) {
> + =C2=A0 =C2=A0 =C2=A0 case MEM_CGROUP_DIRTY_RATIO:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return memcg->dirty_pa=
ram.dirty_ratio;
> + =C2=A0 =C2=A0 =C2=A0 case MEM_CGROUP_DIRTY_BYTES:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return memcg->dirty_pa=
ram.dirty_bytes;
> + =C2=A0 =C2=A0 =C2=A0 case MEM_CGROUP_DIRTY_BACKGROUND_RATIO:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return memcg->dirty_pa=
ram.dirty_background_ratio;
> + =C2=A0 =C2=A0 =C2=A0 case MEM_CGROUP_DIRTY_BACKGROUND_BYTES:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return memcg->dirty_pa=
ram.dirty_background_bytes;
> + =C2=A0 =C2=A0 =C2=A0 default:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG();
> + =C2=A0 =C2=A0 =C2=A0 }
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
> + =C2=A0 =C2=A0 =C2=A0 if ((type =3D=3D MEM_CGROUP_DIRTY_RATIO ||
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 type =3D=3D MEM_CGROUP=
_DIRTY_BACKGROUND_RATIO) && val > 100)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EINVAL;
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* TODO: provide a validation check routine. =
And retry if validation
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* fails.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 switch (type) {
> + =C2=A0 =C2=A0 =C2=A0 case MEM_CGROUP_DIRTY_RATIO:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcg->dirty_param.dir=
ty_ratio =3D val;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcg->dirty_param.dir=
ty_bytes =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 case MEM_CGROUP_DIRTY_BYTES:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcg->dirty_param.dir=
ty_ratio =C2=A0=3D 0;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcg->dirty_param.dir=
ty_bytes =3D val;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 case MEM_CGROUP_DIRTY_BACKGROUND_RATIO:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcg->dirty_param.dir=
ty_background_ratio =3D val;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcg->dirty_param.dir=
ty_background_bytes =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 case MEM_CGROUP_DIRTY_BACKGROUND_BYTES:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcg->dirty_param.dir=
ty_background_ratio =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcg->dirty_param.dir=
ty_background_bytes =3D val;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;

default:
        BUG();
        break;

> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 return 0;
> +}
> +
> =C2=A0static struct cftype mem_cgroup_files[] =3D {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.name =3D "usage_i=
n_bytes",
> @@ -3504,6 +3793,30 @@ static struct cftype mem_cgroup_files[] =3D {
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
> @@ -3762,8 +4075,21 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct=
 cgroup *cont)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mem->last_scanned_child =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_init(&mem->reclaim_param_lock);
>
> - =C2=A0 =C2=A0 =C2=A0 if (parent)
> + =C2=A0 =C2=A0 =C2=A0 if (parent) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mem->swappiness =
=3D get_swappiness(parent);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem->dirty_param =3D p=
arent->dirty_param;
> + =C2=A0 =C2=A0 =C2=A0 } else {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 while (1) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 get_global_dirty_param(&mem->dirty_param);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* Since global dirty parameters are not protected we
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* try to speculatively read them and retry if we get
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* inconsistent values.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 if (likely(dirty_param_is_valid(&mem->dirty_param)))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 }
> =C2=A0 =C2=A0 =C2=A0 =C2=A0atomic_set(&mem->refcnt, 1);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mem->move_charge_at_immigrate =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mutex_init(&mem->thresholds_lock);
> --
> 1.6.3.3
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
