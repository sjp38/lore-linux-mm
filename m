Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 491656B006E
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 19:18:47 -0400 (EDT)
Received: by dakp5 with SMTP id p5so1898318dak.14
        for <linux-mm@kvack.org>; Thu, 07 Jun 2012 16:18:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1338260214-21919-1-git-send-email-gaofeng@cn.fujitsu.com>
References: <1338260214-21919-1-git-send-email-gaofeng@cn.fujitsu.com>
From: Zhu Yanhai <zhu.yanhai@gmail.com>
Date: Fri, 8 Jun 2012 07:18:25 +0800
Message-ID: <CAC8teKU1SCnO7Wx7pw3DRZMzaVtsqRBmNdZvvzSa-s=kWfg_Pw@mail.gmail.com>
Subject: Re: [PATCH] meminfo: show /proc/meminfo base on container's memcg
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gao feng <gaofeng@cn.fujitsu.com>
Cc: hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, bsingharora@gmail.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org

2012/5/29 Gao feng <gaofeng@cn.fujitsu.com>:
> cgroup and namespaces are used for creating containers but some of
> information is not isolated/virtualized. This patch is for isolating /pro=
c/meminfo
> information per container, which uses memory cgroup. By this, top,free
> and other tools under container can work as expected(show container's
> usage) without changes.
>
> This patch is a trial to show memcg's info in /proc/meminfo if 'current'
> is under a memcg other than root.
>
> we show /proc/meminfo base on container's memory cgroup.
> because there are lots of info can't be provide by memcg, and
> the cmds such as top, free just use some entries of /proc/meminfo,
> we replace those entries by memory cgroup.
>
> if container has no memcg, we will show host's /proc/meminfo
> as before.
>
> there is no idea how to deal with Buffers,I just set it zero,
> It's strange if Buffers bigger than MemTotal.
>
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> ---
> =C2=A0fs/proc/meminfo.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 11 +++=
++---
> =C2=A0include/linux/memcontrol.h | =C2=A0 15 +++++++++++
> =C2=A0mm/memcontrol.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 5=
6 ++++++++++++++++++++++++++++++++++++++++++++
> =C2=A03 files changed, 78 insertions(+), 4 deletions(-)
>
> diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
> index 80e4645..29a1fcd 100644
> --- a/fs/proc/meminfo.c
> +++ b/fs/proc/meminfo.c
> @@ -13,6 +13,7 @@
> =C2=A0#include <linux/atomic.h>
> =C2=A0#include <asm/page.h>
> =C2=A0#include <asm/pgtable.h>
> +#include <linux/memcontrol.h>
> =C2=A0#include "internal.h"
>
> =C2=A0void __attribute__((weak)) arch_report_meminfo(struct seq_file *m)
> @@ -27,7 +28,6 @@ static int meminfo_proc_show(struct seq_file *m, void *=
v)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct vmalloc_info vmi;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0long cached;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long pages[NR_LRU_LISTS];
> - =C2=A0 =C2=A0 =C2=A0 int lru;
>
> =C2=A0/*
> =C2=A0* display in kilobytes.
> @@ -39,16 +39,19 @@ static int meminfo_proc_show(struct seq_file *m, void=
 *v)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0allowed =3D ((totalram_pages - hugetlb_total_p=
ages())
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* sysctl_overcommi=
t_ratio / 100) + total_swap_pages;
>
> + =C2=A0 =C2=A0 =C2=A0 memcg_meminfo(&i);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0cached =3D global_page_state(NR_FILE_PAGES) -
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0total_swapcache_pages - i.bufferram;
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* If 'current' is in root memory cgroup, ret=
urns global status.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* If not, returns the status of memcg under =
which current runs.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 sys_page_state(pages, &cached);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (cached < 0)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0cached =3D 0;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0get_vmalloc_info(&vmi);
>
> - =C2=A0 =C2=A0 =C2=A0 for (lru =3D LRU_BASE; lru < NR_LRU_LISTS; lru++)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pages[lru] =3D global_=
page_state(NR_LRU_BASE + lru);
> -
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Tagged format, for easy grepping and expans=
ion.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 0316197..6220764 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -21,6 +21,7 @@
> =C2=A0#define _LINUX_MEMCONTROL_H
> =C2=A0#include <linux/cgroup.h>
> =C2=A0#include <linux/vm_event_item.h>
> +#include <linux/mm.h>
>
> =C2=A0struct mem_cgroup;
> =C2=A0struct page_cgroup;
> @@ -116,6 +117,9 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup =
*,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup_reclaim_coo=
kie *);
> =C2=A0void mem_cgroup_iter_break(struct mem_cgroup *, struct mem_cgroup *=
);
>
> +extern void memcg_meminfo(struct sysinfo *si);
> +extern void sys_page_state(unsigned long *page, long *cached);
> +
> =C2=A0/*
> =C2=A0* For memory reclaim.
> =C2=A0*/
> @@ -323,6 +327,17 @@ static inline void mem_cgroup_iter_break(struct mem_=
cgroup *root,
> =C2=A0{
> =C2=A0}
>
> +static inline void memcg_meminfo(struct sysinfo *si)
> +{
> +}
> +
> +static inline void sys_page_state(unsigned long *pages, long *cached)
> +{
> + =C2=A0 =C2=A0 =C2=A0 int lru;
> + =C2=A0 =C2=A0 =C2=A0 for (lru =3D LRU_BASE; lru < NR_LRU_LISTS; lru++)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pages[lru] =3D global_=
page_state(NR_LRU_BASE + lru);
> +}
> +
> =C2=A0static inline bool mem_cgroup_disabled(void)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return true;
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index f142ea9..c25e160 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -52,6 +52,7 @@
> =C2=A0#include "internal.h"
> =C2=A0#include <net/sock.h>
> =C2=A0#include <net/tcp_memcontrol.h>
> +#include <linux/pid_namespace.h>
>
> =C2=A0#include <asm/uaccess.h>
>
> @@ -4345,6 +4346,61 @@ mem_cgroup_get_total_stat(struct mem_cgroup *memcg=
, struct mcs_total_stat *s)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mem_cgroup_get_loc=
al_stat(iter, s);
> =C2=A0}
>
> +void memcg_meminfo(struct sysinfo *val)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *memcg =3D mem_cgroup_from_task(=
current);
> + =C2=A0 =C2=A0 =C2=A0 __kernel_ulong_t totalram, totalswap;
> + =C2=A0 =C2=A0 =C2=A0 if (current->nsproxy->pid_ns =3D=3D &init_pid_ns |=
|
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcg =3D=3D NULL || mem_cgroup_is_r=
oot(memcg))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
This is somehow not exactly the same with your description "if 'current'
> is under a memcg other than root." since you are checking both namespace =
and cgroup constraint.
> +
> + =C2=A0 =C2=A0 =C2=A0 totalram =3D res_counter_read_u64(&memcg->res,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 RES_LIMIT) >=
> PAGE_SHIFT;
> + =C2=A0 =C2=A0 =C2=A0 if (totalram < val->totalram) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __kernel_ulong_t usage=
ram;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 usageram =3D res_count=
er_read_u64(&memcg->res,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 RES_USAGE) >> PAGE_SHIFT;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 val->totalram =3D tota=
lram;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 val->freeram =3D total=
ram - usageram;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 val->bufferram =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 val->totalhigh =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 val->freehigh =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 } else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
You don't want to show the local swap usage and limit (below code) if
mem.hard_limit_in_bytes is larger than the physical memory capacity?
Why?
> +
> + =C2=A0 =C2=A0 =C2=A0 totalswap =3D res_counter_read_u64(&memcg->memsw,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0RES_LI=
MIT) >> PAGE_SHIFT;
> + =C2=A0 =C2=A0 =C2=A0 if (totalswap < val->totalswap) {
here, do you need also to check memcg->memsw_is_minimum? Local
swapping is disabled if memsw_is_minium is true.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __kernel_ulong_t usage=
swap;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 usageswap =3D res_coun=
ter_read_u64(&memcg->memsw,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0RES_USAGE) >> PAGE_SHIFT;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 val->totalswap =3D tot=
alswap - val->totalram;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 val->freeswap =3D tota=
lswap - usageswap - val->freeram;
This is seriously broken, memsw.limit_in_bytes means the max swap
space you can get, and under global memory pressure all physical
memory belongs to a memcg might get dump into disk, until it reaches
the limit set by memsw.limit_in_bytes. So you should not subtract the
physical memory usage.
> + =C2=A0 =C2=A0 =C2=A0 }
And you need a 'else' statement here, although memsw.limit_in_bytes
might be larger than val->totalswap, it's still wrong to show the user
a global swap usage other than your local one, right?

> +}
> +
> +void sys_page_state(unsigned long *pages, long *cached)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *memcg =3D mem_cgroup_from_task(=
current);
> +
> + =C2=A0 =C2=A0 =C2=A0 if (current->nsproxy->pid_ns =3D=3D &init_pid_ns |=
|
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcg =3D=3D NULL || mem_cgroup_is_r=
oot(memcg)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int lru;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 for (lru =3D LRU_BASE;=
 lru < NR_LRU_LISTS; lru++)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 pages[lru] =3D global_page_state(NR_LRU_BASE + lru);
> + =C2=A0 =C2=A0 =C2=A0 } else {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct mcs_total_stat =
s;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memset(&s, 0, sizeof(s=
));
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_get_total_s=
tat(memcg, &s);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 *cached =3D s.stat[MCS=
_CACHE] >> PAGE_SHIFT;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pages[LRU_ACTIVE_ANON]=
 =3D s.stat[MCS_ACTIVE_ANON] >> PAGE_SHIFT;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pages[LRU_ACTIVE_FILE]=
 =3D s.stat[MCS_ACTIVE_FILE] >> PAGE_SHIFT;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pages[LRU_INACTIVE_ANO=
N] =3D s.stat[MCS_INACTIVE_ANON] >> PAGE_SHIFT;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pages[LRU_INACTIVE_FIL=
E] =3D s.stat[MCS_INACTIVE_FILE] >> PAGE_SHIFT;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pages[LRU_UNEVICTABLE]=
 =3D s.stat[MCS_UNEVICTABLE] >> PAGE_SHIFT;
> + =C2=A0 =C2=A0 =C2=A0 }
> +}
> +
> =C2=A0#ifdef CONFIG_NUMA
> =C2=A0static int mem_control_numa_stat_show(struct seq_file *m, void *arg=
)
> =C2=A0{
> --
> 1.7.7.6
>
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.html

We have a highly similar patch with yours here on a large production
system, AFAICS it's absolutely unaccepted to require correcting the
userland tools to read the stat file exported by the various cgroups,
which have different formats and locations and names with the legacy
ones i.e. /proc/stat, /proc/meminfo and /proc/loadavg. There are tons
of the tools and it's impossible to do so (just think about,
top/sar/vmstat/mpstat/free/who, and various userland library read the
number directly from above files, setup their thread pool or memory
pool according to the available resource).

--
Thanks,
Zhu Yanhai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
