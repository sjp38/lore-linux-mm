Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 93D076B0047
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 02:46:20 -0500 (EST)
Received: by ey-out-1920.google.com with SMTP id 4so123285eyg.18
        for <linux-mm@kvack.org>; Thu, 11 Feb 2010 23:46:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100212154857.f9d8f28e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100212154422.58bfdc4d.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100212154857.f9d8f28e.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 12 Feb 2010 09:46:17 +0200
Message-ID: <cc557aab1002112346tc9a40a6x53ff9c8a8a8c6dc4@mail.gmail.com>
Subject: Re: [PATCH 2/2] memcg: share event counter rather than duplicate
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Feb 12, 2010 at 8:48 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Memcg has 2 eventcountes which counts "the same" event. Just usages are
> different from each other. This patch tries to reduce event counter.
>
> This patch's logic uses "only increment, no reset" new_counter and masks =
for each
> checks. Softlimit chesk was done per 1000 events. So, the similar check
> can be done by !(new_counter & 0x3ff). Threshold check was done per 100
> events. So, the similar check can be done by (!new_counter & 0x7f)
>
> Cc: Kirill A. Shutemov <kirill@shutemov.name>
> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =C2=A0mm/memcontrol.c | =C2=A0 36 ++++++++++++------------------------
> =C2=A01 file changed, 12 insertions(+), 24 deletions(-)
>
> Index: mmotm-2.6.33-Feb10/mm/memcontrol.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.33-Feb10.orig/mm/memcontrol.c
> +++ mmotm-2.6.33-Feb10/mm/memcontrol.c
> @@ -63,8 +63,8 @@ static int really_do_swap_account __init
> =C2=A0#define do_swap_account =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0(0)
> =C2=A0#endif
>
> -#define SOFTLIMIT_EVENTS_THRESH (1000)
> -#define THRESHOLDS_EVENTS_THRESH (100)
> +#define SOFTLIMIT_EVENTS_THRESH (0x3ff) /* once in 1024 */
> +#define THRESHOLDS_EVENTS_THRESH (0x7f) /* once in 128 */

Probably, better to define it as power of two here. Like

#define SOFTLIMIT_EVENTS_THRESH (10) /* once in 1024 */
#define THRESHOLDS_EVENTS_THRESH (7) /* once in 128 */

And change logic of checks accordingly. What do you think?

> =C2=A0/*
> =C2=A0* Statistics for memory cgroup.
> @@ -79,10 +79,7 @@ enum mem_cgroup_stat_index {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0MEM_CGROUP_STAT_PGPGIN_COUNT, =C2=A0 /* # of p=
ages paged in */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0MEM_CGROUP_STAT_PGPGOUT_COUNT, =C2=A0/* # of p=
ages paged out */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swappe=
d out */
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
> + =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_EVENTS, =C2=A0 =C2=A0 =C2=A0/* incremen=
ted by 1 at pagein/pageout */
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0MEM_CGROUP_STAT_NSTATS,
> =C2=A0};
> @@ -394,16 +391,12 @@ mem_cgroup_remove_exceeded(struct mem_cg
>
> =C2=A0static bool mem_cgroup_soft_limit_check(struct mem_cgroup *mem)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 bool ret =3D false;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0s64 val;
>
> - =C2=A0 =C2=A0 =C2=A0 val =3D this_cpu_read(mem->stat->count[MEM_CGROUP_=
STAT_SOFTLIMIT]);
> - =C2=A0 =C2=A0 =C2=A0 if (unlikely(val < 0)) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 this_cpu_write(mem->st=
at->count[MEM_CGROUP_STAT_SOFTLIMIT],
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 SOFTLIMIT_EVENTS_THRESH);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D true;
> - =C2=A0 =C2=A0 =C2=A0 }
> - =C2=A0 =C2=A0 =C2=A0 return ret;
> + =C2=A0 =C2=A0 =C2=A0 val =3D this_cpu_read(mem->stat->count[MEM_CGROUP_=
EVENTS]);
> + =C2=A0 =C2=A0 =C2=A0 if (unlikely(!(val & SOFTLIMIT_EVENTS_THRESH)))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return true;
> + =C2=A0 =C2=A0 =C2=A0 return false;
> =C2=A0}
>
> =C2=A0static void mem_cgroup_update_tree(struct mem_cgroup *mem, struct p=
age *page)
> @@ -542,8 +535,7 @@ static void mem_cgroup_charge_statistics
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__this_cpu_inc(mem=
->stat->count[MEM_CGROUP_STAT_PGPGIN_COUNT]);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0else
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__this_cpu_inc(mem=
->stat->count[MEM_CGROUP_STAT_PGPGOUT_COUNT]);
> - =C2=A0 =C2=A0 =C2=A0 __this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_SO=
FTLIMIT]);
> - =C2=A0 =C2=A0 =C2=A0 __this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_TH=
RESHOLDS]);
> + =C2=A0 =C2=A0 =C2=A0 __this_cpu_dec(mem->stat->count[MEM_CGROUP_EVENTS]=
);

Decrement??

> =C2=A0 =C2=A0 =C2=A0 =C2=A0preempt_enable();
> =C2=A0}
> @@ -3211,16 +3203,12 @@ static int mem_cgroup_swappiness_write(s
>
> =C2=A0static bool mem_cgroup_threshold_check(struct mem_cgroup *mem)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 bool ret =3D false;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0s64 val;
>
> - =C2=A0 =C2=A0 =C2=A0 val =3D this_cpu_read(mem->stat->count[MEM_CGROUP_=
STAT_THRESHOLDS]);
> - =C2=A0 =C2=A0 =C2=A0 if (unlikely(val < 0)) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 this_cpu_write(mem->st=
at->count[MEM_CGROUP_STAT_THRESHOLDS],
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 THRESHOLDS_EVENTS_THRESH);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D true;
> - =C2=A0 =C2=A0 =C2=A0 }
> - =C2=A0 =C2=A0 =C2=A0 return ret;
> + =C2=A0 =C2=A0 =C2=A0 val =3D this_cpu_read(mem->stat->count[MEM_CGROUP_=
EVENTS]);
> + =C2=A0 =C2=A0 =C2=A0 if (unlikely(!(val & THRESHOLDS_EVENTS_THRESH)))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return true;
> + =C2=A0 =C2=A0 =C2=A0 return false;
> =C2=A0}
>
> =C2=A0static void __mem_cgroup_threshold(struct mem_cgroup *memcg, bool s=
wap)
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
