Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 91FB26B004A
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 17:53:53 -0500 (EST)
Received: by iwn9 with SMTP id 9so8094067iwn.14
        for <linux-mm@kvack.org>; Tue, 09 Nov 2010 14:53:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1289294671-6865-2-git-send-email-gthelen@google.com>
References: <1289294671-6865-1-git-send-email-gthelen@google.com>
	<1289294671-6865-2-git-send-email-gthelen@google.com>
Date: Wed, 10 Nov 2010 07:53:46 +0900
Message-ID: <AANLkTi=LtVcLVj+U-RGRrc2J=JGSvfbQD3Y-Y6yKu5NS@mail.gmail.com>
Subject: Re: [PATCH 1/6] memcg: add mem_cgroup parameter to mem_cgroup_page_stat()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 9, 2010 at 6:24 PM, Greg Thelen <gthelen@google.com> wrote:
> This new parameter can be used to query dirty memory usage
> from a given memcg rather than the current task's memcg.
>
> Signed-off-by: Greg Thelen <gthelen@google.com>
> ---
> =A0include/linux/memcontrol.h | =A0 =A06 ++++--
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 37 +++++++++++++++++++++-=
---------------
> =A0mm/page-writeback.c =A0 =A0 =A0 =A0| =A0 =A02 +-
> =A03 files changed, 26 insertions(+), 19 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 7a3d915..89a9278 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -157,7 +157,8 @@ static inline void mem_cgroup_dec_page_stat(struct pa=
ge *page,
> =A0bool mem_cgroup_has_dirty_limit(void);
> =A0bool mem_cgroup_dirty_info(unsigned long sys_available_mem,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct dirty_info *in=
fo);
> -long mem_cgroup_page_stat(enum mem_cgroup_nr_pages_item item);
> +long mem_cgroup_page_stat(struct mem_cgroup *mem,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum mem_cgroup_nr_page=
s_item item);
>
> =A0unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int ord=
er,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0gfp_t gfp_mask);
> @@ -351,7 +352,8 @@ static inline bool mem_cgroup_dirty_info(unsigned lon=
g sys_available_mem,
> =A0 =A0 =A0 =A0return false;
> =A0}
>
> -static inline long mem_cgroup_page_stat(enum mem_cgroup_nr_pages_item it=
em)
> +static inline long mem_cgroup_page_stat(struct mem_cgroup *mem,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 enum mem_cgroup_nr_pages_item item)
> =A0{
> =A0 =A0 =A0 =A0return -ENOSYS;
> =A0}
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index d8a06d6..1bff7cf 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1245,22 +1245,20 @@ bool mem_cgroup_dirty_info(unsigned long sys_avai=
lable_mem,
> =A0 =A0 =A0 =A0unsigned long available_mem;
> =A0 =A0 =A0 =A0struct mem_cgroup *memcg;
> =A0 =A0 =A0 =A0long value;
> + =A0 =A0 =A0 bool valid =3D false;
>
> =A0 =A0 =A0 =A0if (mem_cgroup_disabled())
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return false;
>
> =A0 =A0 =A0 =A0rcu_read_lock();
> =A0 =A0 =A0 =A0memcg =3D mem_cgroup_from_task(current);
> - =A0 =A0 =A0 if (!__mem_cgroup_has_dirty_limit(memcg)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
> - =A0 =A0 =A0 }
> + =A0 =A0 =A0 if (!__mem_cgroup_has_dirty_limit(memcg))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto done;
> =A0 =A0 =A0 =A0__mem_cgroup_dirty_param(&dirty_param, memcg);
> - =A0 =A0 =A0 rcu_read_unlock();
>
> - =A0 =A0 =A0 value =3D mem_cgroup_page_stat(MEMCG_NR_DIRTYABLE_PAGES);
> + =A0 =A0 =A0 value =3D mem_cgroup_page_stat(memcg, MEMCG_NR_DIRTYABLE_PA=
GES);
> =A0 =A0 =A0 =A0if (value < 0)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto done;
>
> =A0 =A0 =A0 =A0available_mem =3D min((unsigned long)value, sys_available_=
mem);
>
> @@ -1280,17 +1278,21 @@ bool mem_cgroup_dirty_info(unsigned long sys_avai=
lable_mem,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(dirty_param.dirty_backgro=
und_ratio *
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 available_mem=
) / 100;
>
> - =A0 =A0 =A0 value =3D mem_cgroup_page_stat(MEMCG_NR_RECLAIM_PAGES);
> + =A0 =A0 =A0 value =3D mem_cgroup_page_stat(memcg, MEMCG_NR_RECLAIM_PAGE=
S);
> =A0 =A0 =A0 =A0if (value < 0)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto done;
> =A0 =A0 =A0 =A0info->nr_reclaimable =3D value;
>
> - =A0 =A0 =A0 value =3D mem_cgroup_page_stat(MEMCG_NR_WRITEBACK);
> + =A0 =A0 =A0 value =3D mem_cgroup_page_stat(memcg, MEMCG_NR_WRITEBACK);
> =A0 =A0 =A0 =A0if (value < 0)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto done;
> =A0 =A0 =A0 =A0info->nr_writeback =3D value;
>
> - =A0 =A0 =A0 return true;
> + =A0 =A0 =A0 valid =3D true;
> +
> +done:
> + =A0 =A0 =A0 rcu_read_unlock();
> + =A0 =A0 =A0 return valid;
> =A0}
>
> =A0static inline bool mem_cgroup_can_swap(struct mem_cgroup *memcg)
> @@ -1361,20 +1363,23 @@ memcg_hierarchical_free_pages(struct mem_cgroup *=
mem)
>
> =A0/*
> =A0* mem_cgroup_page_stat() - get memory cgroup file cache statistics
> - * @item: =A0 =A0 =A0memory statistic item exported to the kernel
> + * @mem: =A0 =A0 =A0 optional memory cgroup to query. =A0If NULL, use cu=
rrent task's
> + * =A0 =A0 =A0 =A0 =A0 =A0 cgroup.
> + * @item: =A0 =A0 =A0memory statistic item exported to the kernel
> =A0*
> =A0* Return the accounted statistic value or negative value if current ta=
sk is
> =A0* root cgroup.
> =A0*/
> -long mem_cgroup_page_stat(enum mem_cgroup_nr_pages_item item)
> +long mem_cgroup_page_stat(struct mem_cgroup *mem,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum mem_cgroup_nr_page=
s_item item)
> =A0{
> =A0 =A0 =A0 =A0struct mem_cgroup *iter;
> - =A0 =A0 =A0 struct mem_cgroup *mem;
> =A0 =A0 =A0 =A0long value;
>
> =A0 =A0 =A0 =A0get_online_cpus();
> =A0 =A0 =A0 =A0rcu_read_lock();
> - =A0 =A0 =A0 mem =3D mem_cgroup_from_task(current);
> + =A0 =A0 =A0 if (!mem)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem =3D mem_cgroup_from_task(current);
> =A0 =A0 =A0 =A0if (__mem_cgroup_has_dirty_limit(mem)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * If we're looking for dirtyable pages we=
 need to evaluate
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index a477f59..dc3dbe3 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -135,7 +135,7 @@ static unsigned long dirty_writeback_pages(void)
> =A0{
> =A0 =A0 =A0 =A0unsigned long ret;
>
> - =A0 =A0 =A0 ret =3D mem_cgroup_page_stat(MEMCG_NR_DIRTY_WRITEBACK_PAGES=
);
> + =A0 =A0 =A0 ret =3D mem_cgroup_page_stat(NULL, MEMCG_NR_DIRTY_WRITEBACK=
_PAGES);
> =A0 =A0 =A0 =A0if ((long)ret < 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D global_page_state(NR_UNSTABLE_NFS)=
 +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0global_page_state(NR_WRITE=
BACK);
> --
> 1.7.3.1
>

I didn't look at further patches so It might be changed.

Now all of caller of mem_cgroup_page_stat except only
dirty_writeback_pages hold rcu_read_lock.
And mem_cgroup_page_stat itself hold rcu_read_lock again.
Couldn't we remove duplicated rcu lock by adding rcu_read_lock in
dirty_writeback_pages for the consistency?


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
