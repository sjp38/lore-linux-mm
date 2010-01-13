Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 92BAC6B0071
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 05:31:54 -0500 (EST)
Received: by pzk27 with SMTP id 27so2744177pzk.12
        for <linux-mm@kvack.org>; Wed, 13 Jan 2010 02:31:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100113171953.B3E5.A69D9226@jp.fujitsu.com>
References: <20100113171734.B3E2.A69D9226@jp.fujitsu.com>
	 <20100113171953.B3E5.A69D9226@jp.fujitsu.com>
Date: Wed, 13 Jan 2010 19:31:52 +0900
Message-ID: <28c262361001130231k29b933der4022f4d1da80b084@mail.gmail.com>
Subject: Re: [PATCH 2/3][v2] vmstat: add anon_scan_ratio field to zoneinfo
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi, Kosaki.

On Wed, Jan 13, 2010 at 5:21 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Changelog
> =C2=A0from v1
> =C2=A0- get_anon_scan_ratio don't tak zone->lru_lock anymore
> =C2=A0 because zoneinfo_show_print takes zone->lock.

When I saw this changelog first, I got confused.
That's because there is no relation between lru_lock and lock in zone.
You mean zoneinfo is allowed to have a stale data?
Tend to agree with it.

>
>
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> Vmscan folks was asked "why does my system makes so much swap-out?"
> in lkml at several times.
> At that time, I made the debug patch to show recent_anon_{scanned/rorated=
}
> parameter at least three times.
>
> Thus, its parameter should be showed on /proc/zoneinfo. It help
> vmscan folks debugging.

I support this suggestion.

>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =C2=A0include/linux/swap.h | =C2=A0 =C2=A02 ++
> =C2=A0mm/vmscan.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 50 +++++++++=
+++++++++++++++++++++++++++--------------
> =C2=A0mm/vmstat.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A07 ++++=
+--
> =C2=A03 files changed, 43 insertions(+), 16 deletions(-)
>
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index a2602a8..e95d7ed 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -280,6 +280,8 @@ extern void scan_unevictable_unregister_node(struct n=
ode *node);
> =C2=A0extern int kswapd_run(int nid);
> =C2=A0extern void kswapd_stop(int nid);
>
> +unsigned long get_anon_scan_ratio(struct zone *zone, struct mem_cgroup *=
memcg, int swappiness);

Today Andrew said  to me. :)
"The vmscan.c code makes an effort to look nice in an 80-col display."

> +
> =C2=A0#ifdef CONFIG_MMU
> =C2=A0/* linux/mm/shmem.c */
> =C2=A0extern int shmem_unuse(swp_entry_t entry, struct page *page);
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 640486b..0900931 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1493,8 +1493,8 @@ static unsigned long shrink_list(enum lru_list lru,=
 unsigned long nr_to_scan,
> =C2=A0* percent[0] specifies how much pressure to put on ram/swap backed
> =C2=A0* memory, while percent[1] determines pressure on the file LRUs.
> =C2=A0*/
> -static void get_scan_ratio(struct zone *zone, struct scan_control *sc,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned lon=
g *percent)
> +static void __get_scan_ratio(struct zone *zone, struct scan_control *sc,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0int need_update, unsigned long *percent)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long anon, file, free;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long anon_prio, file_prio;
> @@ -1535,18 +1535,19 @@ static void get_scan_ratio(struct zone *zone, str=
uct scan_control *sc,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 *
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * anon in [0], file in [1]
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> - =C2=A0 =C2=A0 =C2=A0 if (unlikely(reclaim_stat->recent_scanned[0] > ano=
n / 4)) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_lock_irq(&zone->l=
ru_lock);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 reclaim_stat->recent_s=
canned[0] /=3D 2;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 reclaim_stat->recent_r=
otated[0] /=3D 2;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock_irq(&zone-=
>lru_lock);
> - =C2=A0 =C2=A0 =C2=A0 }
> -
> - =C2=A0 =C2=A0 =C2=A0 if (unlikely(reclaim_stat->recent_scanned[1] > fil=
e / 4)) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_lock_irq(&zone->l=
ru_lock);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 reclaim_stat->recent_s=
canned[1] /=3D 2;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 reclaim_stat->recent_r=
otated[1] /=3D 2;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock_irq(&zone-=
>lru_lock);

Why do you add new parameter 'need_update'?
Do you see any lru_lock heavy contention? (reclaim VS cat /proc/zoneinfo)
I think maybe not.
I am not sure no locking version is needed.

> + =C2=A0 =C2=A0 =C2=A0 if (need_update) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (unlikely(reclaim_s=
tat->recent_scanned[0] > anon / 4)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 spin_lock_irq(&zone->lru_lock);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 reclaim_stat->recent_scanned[0] /=3D 2;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 reclaim_stat->recent_rotated[0] /=3D 2;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 spin_unlock_irq(&zone->lru_lock);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (unlikely(reclaim_s=
tat->recent_scanned[1] > file / 4)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 spin_lock_irq(&zone->lru_lock);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 reclaim_stat->recent_scanned[1] /=3D 2;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 reclaim_stat->recent_rotated[1] /=3D 2;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 spin_unlock_irq(&zone->lru_lock);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> @@ -1572,6 +1573,27 @@ static void get_scan_ratio(struct zone *zone, stru=
ct scan_control *sc,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0percent[1] =3D 100 - percent[0];
> =C2=A0}
>
> +static void get_scan_ratio(struct zone *zone, struct scan_control *sc,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0unsigned long *percent)
> +{
> + =C2=A0 =C2=A0 =C2=A0 __get_scan_ratio(zone, sc, 1, percent);
> +}
> +

If we really need this version and your changelog is right,
Let's add 'note'.  ;-)

/* Caller have to hold zone->lock */
> +unsigned long get_anon_scan_ratio(struct zone *zone, struct mem_cgroup *=
memcg, int swappiness)
> +{
> + =C2=A0 =C2=A0 =C2=A0 unsigned long percent[2];
> + =C2=A0 =C2=A0 =C2=A0 struct scan_control sc =3D {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .may_swap =3D 1,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .swappiness =3D swappi=
ness,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .mem_cgroup =3D memcg,
> + =C2=A0 =C2=A0 =C2=A0 };
> +
> + =C2=A0 =C2=A0 =C2=A0 __get_scan_ratio(zone, &sc, 0, percent);
> +
> + =C2=A0 =C2=A0 =C2=A0 return percent[0];
> +}
> +
> +
> =C2=A0/*
> =C2=A0* Smallish @nr_to_scan's are deposited in @nr_saved_scan,
> =C2=A0* until we collected @swap_cluster_max pages to scan.
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 6051fba..f690117 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -15,6 +15,7 @@
> =C2=A0#include <linux/cpu.h>
> =C2=A0#include <linux/vmstat.h>
> =C2=A0#include <linux/sched.h>
> +#include <linux/swap.h>
>
> =C2=A0#ifdef CONFIG_VM_EVENT_COUNTERS
> =C2=A0DEFINE_PER_CPU(struct vm_event_state, vm_event_states) =3D {{0}};
> @@ -760,11 +761,13 @@ static void zoneinfo_show_print(struct seq_file *m,=
 pg_data_t *pgdat,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 "\n =C2=A0=
all_unreclaimable: %u"
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 "\n =C2=A0=
prev_priority: =C2=A0 =C2=A0 %i"
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 "\n =C2=A0=
start_pfn: =C2=A0 =C2=A0 =C2=A0 =C2=A0 %lu"
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0"\n =C2=
=A0inactive_ratio: =C2=A0 =C2=A0%u",
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0"\n =C2=
=A0inactive_ratio: =C2=A0 =C2=A0%u"
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0"\n =C2=
=A0anon_scan_ratio: =C2=A0 %lu",
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 zone_is_all_unreclaimable(zone),
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zone->prev=
_priority,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zone->zone=
_start_pfn,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zone->ina=
ctive_ratio);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zone->ina=
ctive_ratio,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0get_anon_=
scan_ratio(zone, NULL, vm_swappiness));
> =C2=A0 =C2=A0 =C2=A0 =C2=A0seq_putc(m, '\n');
> =C2=A0}
>
> --
> 1.6.5.2
>
>
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
