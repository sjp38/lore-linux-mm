Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D476B6B0047
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 03:58:38 -0500 (EST)
Received: by wyb42 with SMTP id 42so1088682wyb.14
        for <linux-mm@kvack.org>; Mon, 01 Mar 2010 00:58:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1267224751-6382-2-git-send-email-arighi@develer.com>
References: <1267224751-6382-1-git-send-email-arighi@develer.com>
	 <1267224751-6382-2-git-send-email-arighi@develer.com>
Date: Mon, 1 Mar 2010 10:58:35 +0200
Message-ID: <cc557aab1003010058i3a824f98l4cec173fac05911f@mail.gmail.com>
Subject: Re: [PATCH -mmotm 1/2] memcg: dirty pages accounting and limiting
	infrastructure
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrea Righi <arighi@develer.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Suleiman Souhlal <suleiman@google.com>, Vivek Goyal <vgoyal@redhat.com>, Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Feb 27, 2010 at 12:52 AM, Andrea Righi <arighi@develer.com> wrote:
> Infrastructure to account dirty pages per cgroup and add dirty limit
> interfaces in the cgroupfs:
>
> =C2=A0- Active write-out: memory.dirty_ratio, memory.dirty_bytes
> =C2=A0- Background write-out: memory.dirty_background_ratio, memory.dirty=
_background_bytes
>
> Signed-off-by: Andrea Righi <arighi@develer.com>
> ---
> =C2=A0include/linux/memcontrol.h | =C2=A0 74 +++++++++-
> =C2=A0mm/memcontrol.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A035=
4 ++++++++++++++++++++++++++++++++++++++++----
> =C2=A02 files changed, 399 insertions(+), 29 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 1f9b119..e6af95c 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -25,6 +25,41 @@ struct page_cgroup;
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
> @@ -117,6 +152,13 @@ extern void mem_cgroup_print_oom_info(struct mem_cgr=
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
> @@ -125,7 +167,8 @@ static inline bool mem_cgroup_disabled(void)
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
> @@ -300,8 +343,8 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, s=
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
> @@ -312,6 +355,31 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct z=
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
> +}
> +
> =C2=A0#endif /* CONFIG_CGROUP_MEM_CONT */
>
> =C2=A0#endif /* _LINUX_MEMCONTROL_H */
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index a443c30..56f3204 100644
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
> @@ -205,6 +190,14 @@ struct mem_cgroup {
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int =C2=A0 =C2=A0swappiness;
>
> + =C2=A0 =C2=A0 =C2=A0 /* control memory cgroup dirty pages */
> + =C2=A0 =C2=A0 =C2=A0 long dirty_ratio;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long dirty_bytes;
> +
> + =C2=A0 =C2=A0 =C2=A0 /* control background writeback (via writeback thr=
eads) */
> + =C2=A0 =C2=A0 =C2=A0 long dirty_background_ratio;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long dirty_background_bytes;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* set when res.limit =3D=3D memsw.limit */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0bool =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
memsw_is_minimum;
>
> @@ -1021,6 +1014,169 @@ static unsigned int get_swappiness(struct mem_cgr=
oup *memcg)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return swappiness;
> =C2=A0}
>
> +enum mem_cgroup_dirty_param {
> + =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_DIRTY_RATIO,
> + =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_DIRTY_BYTES,
> + =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_DIRTY_BACKGROUND_RATIO,
> + =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_DIRTY_BACKGROUND_BYTES,
> +};
> +
> +static unsigned long get_dirty_param(struct mem_cgroup *memcg,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 enum mem_cgroup_dirty_param idx)
> +{
> + =C2=A0 =C2=A0 =C2=A0 unsigned long ret;
> +
> + =C2=A0 =C2=A0 =C2=A0 spin_lock(&memcg->reclaim_param_lock);
> + =C2=A0 =C2=A0 =C2=A0 switch (idx) {
> + =C2=A0 =C2=A0 =C2=A0 case MEM_CGROUP_DIRTY_RATIO:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D memcg->dirty_r=
atio;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 case MEM_CGROUP_DIRTY_BYTES:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D memcg->dirty_b=
ytes;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 case MEM_CGROUP_DIRTY_BACKGROUND_RATIO:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D memcg->dirty_b=
ackground_ratio;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 case MEM_CGROUP_DIRTY_BACKGROUND_BYTES:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D memcg->dirty_b=
ackground_bytes;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 default:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 VM_BUG_ON(1);
> + =C2=A0 =C2=A0 =C2=A0 }
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
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
> + =C2=A0 =C2=A0 =C2=A0 rcu_read_lock();
> + =C2=A0 =C2=A0 =C2=A0 memcg =3D mem_cgroup_from_task(current);
> + =C2=A0 =C2=A0 =C2=A0 if (likely(memcg))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D get_dirty_para=
m(memcg, MEM_CGROUP_DIRTY_RATIO);
> + =C2=A0 =C2=A0 =C2=A0 rcu_read_unlock();
> +out:
> + =C2=A0 =C2=A0 =C2=A0 return ret;
> +}
> +
> +unsigned long mem_cgroup_dirty_bytes(void)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *memcg;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long ret =3D vm_dirty_bytes;
> +
> + =C2=A0 =C2=A0 =C2=A0 if (mem_cgroup_disabled())
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
> + =C2=A0 =C2=A0 =C2=A0 rcu_read_lock();
> + =C2=A0 =C2=A0 =C2=A0 memcg =3D mem_cgroup_from_task(current);
> + =C2=A0 =C2=A0 =C2=A0 if (likely(memcg))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D get_dirty_para=
m(memcg, MEM_CGROUP_DIRTY_BYTES);
> + =C2=A0 =C2=A0 =C2=A0 rcu_read_unlock();
> +out:
> + =C2=A0 =C2=A0 =C2=A0 return ret;
> +}
> +
> +long mem_cgroup_dirty_background_ratio(void)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *memcg;
> + =C2=A0 =C2=A0 =C2=A0 long ret =3D dirty_background_ratio;
> +
> + =C2=A0 =C2=A0 =C2=A0 if (mem_cgroup_disabled())
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
> + =C2=A0 =C2=A0 =C2=A0 rcu_read_lock();
> + =C2=A0 =C2=A0 =C2=A0 memcg =3D mem_cgroup_from_task(current);
> + =C2=A0 =C2=A0 =C2=A0 if (likely(memcg))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D get_dirty_para=
m(memcg, MEM_CGROUP_DIRTY_BACKGROUND_RATIO);
> + =C2=A0 =C2=A0 =C2=A0 rcu_read_unlock();
> +out:
> + =C2=A0 =C2=A0 =C2=A0 return ret;
> +}
> +
> +unsigned long mem_cgroup_dirty_background_bytes(void)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *memcg;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long ret =3D dirty_background_bytes;
> +
> + =C2=A0 =C2=A0 =C2=A0 if (mem_cgroup_disabled())
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
> + =C2=A0 =C2=A0 =C2=A0 rcu_read_lock();
> + =C2=A0 =C2=A0 =C2=A0 memcg =3D mem_cgroup_from_task(current);
> + =C2=A0 =C2=A0 =C2=A0 if (likely(memcg))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D get_dirty_para=
m(memcg, MEM_CGROUP_DIRTY_BACKGROUND_BYTES);
> + =C2=A0 =C2=A0 =C2=A0 rcu_read_unlock();
> +out:
> + =C2=A0 =C2=A0 =C2=A0 return ret;
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
ad_stat(memcg, LRU_ACTIVE_ANON) +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 mem_cgroup_read_stat(memcg, LRU_ACTIVE_FILE) +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 mem_cgroup_read_stat(memcg, LRU_INACTIVE_ANON) +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 mem_cgroup_read_stat(memcg, LRU_INACTIVE_FILE);
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
> + =C2=A0 =C2=A0 =C2=A0 rcu_read_unlock();
> +
> + =C2=A0 =C2=A0 =C2=A0 return stat.value;
> +}
> +
> =C2=A0static int mem_cgroup_count_children_cb(struct mem_cgroup *mem, voi=
d *data)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int *val =3D data;
> @@ -1263,10 +1419,10 @@ static void record_last_oom(struct mem_cgroup *me=
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
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgroup *mem;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page_cgroup *pc;
> @@ -1286,7 +1442,8 @@ void mem_cgroup_update_file_mapped(struct page *pag=
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
> @@ -3033,6 +3190,10 @@ enum {
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
> @@ -3055,6 +3216,10 @@ struct {
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
> @@ -3083,6 +3248,14 @@ static int mem_cgroup_get_local_stat(struct mem_cg=
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
> @@ -3467,6 +3640,100 @@ unlock:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
> =C2=A0}
>
> +static u64 mem_cgroup_dirty_ratio_read(struct cgroup *cgrp, struct cftyp=
e *cft)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *memcg =3D mem_cgroup_from_cont(=
cgrp);
> +
> + =C2=A0 =C2=A0 =C2=A0 return get_dirty_param(memcg, MEM_CGROUP_DIRTY_RAT=
IO);
> +}
> +
> +static int
> +mem_cgroup_dirty_ratio_write(struct cgroup *cgrp, struct cftype *cft, u6=
4 val)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *memcg =3D mem_cgroup_from_cont(=
cgrp);
> +
> + =C2=A0 =C2=A0 =C2=A0 if ((cgrp->parent =3D=3D NULL) || (val > 100))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EINVAL;
> +
> + =C2=A0 =C2=A0 =C2=A0 spin_lock(&memcg->reclaim_param_lock);
> + =C2=A0 =C2=A0 =C2=A0 memcg->dirty_ratio =3D val;
> + =C2=A0 =C2=A0 =C2=A0 memcg->dirty_bytes =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 spin_unlock(&memcg->reclaim_param_lock);
> +
> + =C2=A0 =C2=A0 =C2=A0 return 0;
> +}
> +
> +static u64 mem_cgroup_dirty_bytes_read(struct cgroup *cgrp, struct cftyp=
e *cft)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *memcg =3D mem_cgroup_from_cont(=
cgrp);
> +
> + =C2=A0 =C2=A0 =C2=A0 return get_dirty_param(memcg, MEM_CGROUP_DIRTY_BYT=
ES);
> +}
> +
> +static int
> +mem_cgroup_dirty_bytes_write(struct cgroup *cgrp, struct cftype *cft, u6=
4 val)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *memcg =3D mem_cgroup_from_cont(=
cgrp);
> +
> + =C2=A0 =C2=A0 =C2=A0 if (cgrp->parent =3D=3D NULL)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EINVAL;
> +
> + =C2=A0 =C2=A0 =C2=A0 spin_lock(&memcg->reclaim_param_lock);
> + =C2=A0 =C2=A0 =C2=A0 memcg->dirty_ratio =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 memcg->dirty_bytes =3D val;
> + =C2=A0 =C2=A0 =C2=A0 spin_unlock(&memcg->reclaim_param_lock);
> +
> + =C2=A0 =C2=A0 =C2=A0 return 0;
> +}
> +
> +static u64
> +mem_cgroup_dirty_background_ratio_read(struct cgroup *cgrp, struct cftyp=
e *cft)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *memcg =3D mem_cgroup_from_cont(=
cgrp);
> +
> + =C2=A0 =C2=A0 =C2=A0 return get_dirty_param(memcg, MEM_CGROUP_DIRTY_BAC=
KGROUND_RATIO);
> +}
> +
> +static int mem_cgroup_dirty_background_ratio_write(struct cgroup *cgrp,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct cftype *cft, u64 val)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *memcg =3D mem_cgroup_from_cont(=
cgrp);
> +
> + =C2=A0 =C2=A0 =C2=A0 if ((cgrp->parent =3D=3D NULL) || (val > 100))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EINVAL;
> +
> + =C2=A0 =C2=A0 =C2=A0 spin_lock(&memcg->reclaim_param_lock);
> + =C2=A0 =C2=A0 =C2=A0 memcg->dirty_background_ratio =3D val;
> + =C2=A0 =C2=A0 =C2=A0 memcg->dirty_background_bytes =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 spin_unlock(&memcg->reclaim_param_lock);
> +
> + =C2=A0 =C2=A0 =C2=A0 return 0;
> +}
> +
> +static u64
> +mem_cgroup_dirty_background_bytes_read(struct cgroup *cgrp, struct cftyp=
e *cft)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *memcg =3D mem_cgroup_from_cont(=
cgrp);
> +
> + =C2=A0 =C2=A0 =C2=A0 return get_dirty_param(memcg, MEM_CGROUP_DIRTY_BAC=
KGROUND_BYTES);
> +}
> +
> +static int mem_cgroup_dirty_background_bytes_write(struct cgroup *cgrp,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct cftype *cft, u64 val)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *memcg =3D mem_cgroup_from_cont(=
cgrp);
> +
> + =C2=A0 =C2=A0 =C2=A0 if (cgrp->parent =3D=3D NULL)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EINVAL;
> +
> + =C2=A0 =C2=A0 =C2=A0 spin_lock(&memcg->reclaim_param_lock);
> + =C2=A0 =C2=A0 =C2=A0 memcg->dirty_background_ratio =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 memcg->dirty_background_bytes =3D val;
> + =C2=A0 =C2=A0 =C2=A0 spin_unlock(&memcg->reclaim_param_lock);
> +
> + =C2=A0 =C2=A0 =C2=A0 return 0;
> +}
> +
> =C2=A0static struct cftype mem_cgroup_files[] =3D {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.name =3D "usage_i=
n_bytes",
> @@ -3518,6 +3785,26 @@ static struct cftype mem_cgroup_files[] =3D {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.write_u64 =3D mem=
_cgroup_swappiness_write,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0},
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .name =3D "dirty_ratio=
",
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .read_u64 =3D mem_cgro=
up_dirty_ratio_read,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .write_u64 =3D mem_cgr=
oup_dirty_ratio_write,
> + =C2=A0 =C2=A0 =C2=A0 },
> + =C2=A0 =C2=A0 =C2=A0 {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .name =3D "dirty_bytes=
",
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .read_u64 =3D mem_cgro=
up_dirty_bytes_read,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .write_u64 =3D mem_cgr=
oup_dirty_bytes_write,
> + =C2=A0 =C2=A0 =C2=A0 },
> + =C2=A0 =C2=A0 =C2=A0 {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .name =3D "dirty_backg=
round_ratio",
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .read_u64 =3D mem_cgro=
up_dirty_background_ratio_read,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .write_u64 =3D mem_cgr=
oup_dirty_background_ratio_write,
> + =C2=A0 =C2=A0 =C2=A0 },
> + =C2=A0 =C2=A0 =C2=A0 {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .name =3D "dirty_backg=
round_bytes",
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .read_u64 =3D mem_cgro=
up_dirty_background_bytes_read,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .write_u64 =3D mem_cgr=
oup_dirty_background_bytes_write,
> + =C2=A0 =C2=A0 =C2=A0 },
> + =C2=A0 =C2=A0 =C2=A0 {

mem_cgroup_dirty_background_* functions are too similar to
mem_cgroup_dirty_bytes_*. I think they should be combined
like mem_cgroup_read() and mem_cgroup_write(). It will be
cleaner.

> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.name =3D "move_ch=
arge_at_immigrate",
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.read_u64 =3D mem_=
cgroup_move_charge_read,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.write_u64 =3D mem=
_cgroup_move_charge_write,
> @@ -3776,8 +4063,23 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct=
 cgroup *cont)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mem->last_scanned_child =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_init(&mem->reclaim_param_lock);
>
> - =C2=A0 =C2=A0 =C2=A0 if (parent)
> + =C2=A0 =C2=A0 =C2=A0 if (parent) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mem->swappiness =
=3D get_swappiness(parent);
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem->dirty_ratio =3D g=
et_dirty_param(parent,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_D=
IRTY_RATIO);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem->dirty_bytes =3D g=
et_dirty_param(parent,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_D=
IRTY_BYTES);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem->dirty_background_=
ratio =3D get_dirty_param(parent,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_D=
IRTY_BACKGROUND_RATIO);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem->dirty_background_=
bytes =3D get_dirty_param(parent,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_D=
IRTY_BACKGROUND_BYTES);
> + =C2=A0 =C2=A0 =C2=A0 } else {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem->dirty_ratio =3D v=
m_dirty_ratio;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem->dirty_bytes =3D v=
m_dirty_bytes;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem->dirty_background_=
ratio =3D vm_dirty_ratio;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem->dirty_background_=
bytes =3D vm_dirty_bytes;
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
