Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 154276B007B
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 05:57:33 -0500 (EST)
Received: by ey-out-1920.google.com with SMTP id 3so466967eyh.18
        for <linux-mm@kvack.org>; Mon, 15 Feb 2010 02:57:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100212180952.28b2f6c5.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100212154422.58bfdc4d.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100212180508.eb58a4d1.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100212180952.28b2f6c5.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 15 Feb 2010 12:57:30 +0200
Message-ID: <cc557aab1002150257y65bb3856x4a4c60e5c6218a50@mail.gmail.com>
Subject: Re: [PATCH 2/2] memcg : share event counter rather than duplicate v2
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Feb 12, 2010 at 11:09 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Memcg has 2 eventcountes which counts "the same" event. Just usages are
> different from each other. This patch tries to reduce event counter.
>
> Now logic uses "only increment, no reset" counter and masks for each
> checks. Softlimit chesk was done per 1000 evetns. So, the similar check
> can be done by !(new_counter & 0x3ff). Threshold check was done per 100
> events. So, the similar check can be done by (!new_counter & 0x7f)
>
> ALL event checks are done right after EVENT percpu counter is updated.
>
> Changelog: 2010/02/12
> =C2=A0- fixed to use "inc" rather than "dec"
> =C2=A0- modified to be more unified style of counter handling.
> =C2=A0- taking care of account-move.
>
> Cc: Kirill A. Shutemov <kirill@shutemov.name>
> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =C2=A0mm/memcontrol.c | =C2=A0 86 ++++++++++++++++++++++++++-------------=
-----------------
> =C2=A01 file changed, 41 insertions(+), 45 deletions(-)
>
> Index: mmotm-2.6.33-Feb10/mm/memcontrol.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.33-Feb10.orig/mm/memcontrol.c
> +++ mmotm-2.6.33-Feb10/mm/memcontrol.c
> @@ -63,8 +63,15 @@ static int really_do_swap_account __init
> =C2=A0#define do_swap_account =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0(0)
> =C2=A0#endif
>
> -#define SOFTLIMIT_EVENTS_THRESH (1000)
> -#define THRESHOLDS_EVENTS_THRESH (100)
> +/*
> + * Per memcg event counter is incremented at every pagein/pageout. This =
counter
> + * is used for trigger some periodic events. This is straightforward and=
 better
> + * than using jiffies etc. to handle periodic memcg event.
> + *
> + * These values will be used as !((event) & ((1 <<(thresh)) - 1))
> + */
> +#define THRESHOLDS_EVENTS_THRESH (7) /* once in 128 */
> +#define SOFTLIMIT_EVENTS_THRESH (10) /* once in 1024 */
>
> =C2=A0/*
> =C2=A0* Statistics for memory cgroup.
> @@ -79,10 +86,7 @@ enum mem_cgroup_stat_index {
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
ted at every =C2=A0pagein/pageout */
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0MEM_CGROUP_STAT_NSTATS,
> =C2=A0};
> @@ -154,7 +158,6 @@ struct mem_cgroup_threshold_ary {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgroup_threshold entries[0];
> =C2=A0};
>
> -static bool mem_cgroup_threshold_check(struct mem_cgroup *mem);
> =C2=A0static void mem_cgroup_threshold(struct mem_cgroup *mem);
>
> =C2=A0/*
> @@ -392,19 +395,6 @@ mem_cgroup_remove_exceeded(struct mem_cg
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock(&mctz->lock);
> =C2=A0}
>
> -static bool mem_cgroup_soft_limit_check(struct mem_cgroup *mem)
> -{
> - =C2=A0 =C2=A0 =C2=A0 bool ret =3D false;
> - =C2=A0 =C2=A0 =C2=A0 s64 val;
> -
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
> -}
>
> =C2=A0static void mem_cgroup_update_tree(struct mem_cgroup *mem, struct p=
age *page)
> =C2=A0{
> @@ -542,8 +532,7 @@ static void mem_cgroup_charge_statistics
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__this_cpu_inc(mem=
->stat->count[MEM_CGROUP_STAT_PGPGIN_COUNT]);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0else
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__this_cpu_inc(mem=
->stat->count[MEM_CGROUP_STAT_PGPGOUT_COUNT]);
> - =C2=A0 =C2=A0 =C2=A0 __this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_SO=
FTLIMIT]);
> - =C2=A0 =C2=A0 =C2=A0 __this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_TH=
RESHOLDS]);
> + =C2=A0 =C2=A0 =C2=A0 __this_cpu_inc(mem->stat->count[MEM_CGROUP_EVENTS]=
);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0preempt_enable();
> =C2=A0}
> @@ -563,6 +552,29 @@ static unsigned long mem_cgroup_get_loca
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return total;
> =C2=A0}
>
> +static bool __memcg_event_check(struct mem_cgroup *mem, int event_mask_s=
hift)

inline?

> +{
> + =C2=A0 =C2=A0 =C2=A0 s64 val;
> +
> + =C2=A0 =C2=A0 =C2=A0 val =3D this_cpu_read(mem->stat->count[MEM_CGROUP_=
EVENTS]);
> +
> + =C2=A0 =C2=A0 =C2=A0 return !(val & ((1 << event_mask_shift) - 1));
> +}
> +
> +/*
> + * Check events in order.
> + *
> + */
> +static void memcg_check_events(struct mem_cgroup *mem, struct page *page=
)

Ditto.

> +{
> + =C2=A0 =C2=A0 =C2=A0 /* threshold event is triggered in finer grain tha=
n soft limit */
> + =C2=A0 =C2=A0 =C2=A0 if (unlikely(__memcg_event_check(mem, THRESHOLDS_E=
VENTS_THRESH))) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_threshold(m=
em);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (unlikely(__memcg_e=
vent_check(mem, SOFTLIMIT_EVENTS_THRESH)))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 mem_cgroup_update_tree(mem, page);
> + =C2=A0 =C2=A0 =C2=A0 }
> +}
> +
> =C2=A0static struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return container_of(cgroup_subsys_state(cont,
> @@ -1686,11 +1698,7 @@ static void __mem_cgroup_commit_charge(s
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Insert ancestor (and ancestor's ancestors),=
 to softlimit RB-tree.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * if they exceeds softlimit.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> - =C2=A0 =C2=A0 =C2=A0 if (mem_cgroup_soft_limit_check(mem))
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_update_tree=
(mem, pc->page);
> - =C2=A0 =C2=A0 =C2=A0 if (mem_cgroup_threshold_check(mem))
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_threshold(m=
em);
> -
> + =C2=A0 =C2=A0 =C2=A0 memcg_check_events(mem, pc->page);
> =C2=A0}
>
> =C2=A0/**
> @@ -1760,6 +1768,11 @@ static int mem_cgroup_move_account(struc
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unlock_page_cgroup(pc);
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* check events
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 memcg_check_events(to, pc->page);
> + =C2=A0 =C2=A0 =C2=A0 memcg_check_events(from, pc->page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
> =C2=A0}
>
> @@ -2128,10 +2141,7 @@ __mem_cgroup_uncharge_common(struct page
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mz =3D page_cgroup_zoneinfo(pc);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unlock_page_cgroup(pc);
>
> - =C2=A0 =C2=A0 =C2=A0 if (mem_cgroup_soft_limit_check(mem))
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_update_tree=
(mem, page);
> - =C2=A0 =C2=A0 =C2=A0 if (mem_cgroup_threshold_check(mem))
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_threshold(m=
em);
> + =C2=A0 =C2=A0 =C2=A0 memcg_check_events(mem, page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* at swapout, this memcg will be accessed to =
record to swap */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ctype !=3D MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0css_put(&mem->css)=
;
> @@ -3207,20 +3217,6 @@ static int mem_cgroup_swappiness_write(s
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> =C2=A0}
>
> -static bool mem_cgroup_threshold_check(struct mem_cgroup *mem)
> -{
> - =C2=A0 =C2=A0 =C2=A0 bool ret =3D false;
> - =C2=A0 =C2=A0 =C2=A0 s64 val;
> -
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
> -}
> -
> =C2=A0static void __mem_cgroup_threshold(struct mem_cgroup *memcg, bool s=
wap)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgroup_threshold_ary *t;
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
