Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id BCF166B004A
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 18:26:57 -0400 (EDT)
Received: by lbbgp10 with SMTP id gp10so297220lbb.14
        for <linux-mm@kvack.org>; Fri, 13 Apr 2012 15:26:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1334355924-7433-1-git-send-email-yinghan@google.com>
References: <1334355924-7433-1-git-send-email-yinghan@google.com>
Date: Fri, 13 Apr 2012 15:26:55 -0700
Message-ID: <CALWz4ix0e7iP=uk8Yb0KrfHPrMNMo7X8POu6-sKE02eh-2CWAQ@mail.gmail.com>
Subject: Re: [PATCH] mm: fix up the vmscan stat in vmstat
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

Sorry for the spam, please ignore... I hit the wrong button.

--Ying

On Fri, Apr 13, 2012 at 3:25 PM, Ying Han <yinghan@google.com> wrote:
> It is always confusing on stat "pgsteal" where it counts both direct
> reclaim as well as background reclaim. However, we have "kswapd_steal"
> which also counts background reclaim value.
>
> This patch fixes it and also makes it match the existng "pgscan_" stats.
>
> Test:
> pgsteal_kswapd_dma32 447623
> pgsteal_kswapd_normal 42272677
> pgsteal_kswapd_movable 0
> pgsteal_direct_dma32 2801
> pgsteal_direct_normal 44353270
> pgsteal_direct_movable 0
>
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
> =A0include/linux/vm_event_item.h | =A0 =A05 +++--
> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 11 ++++++++---
> =A0mm/vmstat.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A04 ++--
> =A03 files changed, 13 insertions(+), 7 deletions(-)
>
> diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.=
h
> index 03b90cdc..06f8e38 100644
> --- a/include/linux/vm_event_item.h
> +++ b/include/linux/vm_event_item.h
> @@ -26,13 +26,14 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT=
,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0PGFREE, PGACTIVATE, PGDEACTIVATE,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0PGFAULT, PGMAJFAULT,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0FOR_ALL_ZONES(PGREFILL),
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 FOR_ALL_ZONES(PGSTEAL),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 FOR_ALL_ZONES(PGSTEAL_KSWAPD),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 FOR_ALL_ZONES(PGSTEAL_DIRECT),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0FOR_ALL_ZONES(PGSCAN_KSWAPD),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0FOR_ALL_ZONES(PGSCAN_DIRECT),
> =A0#ifdef CONFIG_NUMA
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0PGSCAN_ZONE_RECLAIM_FAILED,
> =A0#endif
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 PGINODESTEAL, SLABS_SCANNED, KSWAPD_STEAL, =
KSWAPD_INODESTEAL,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 PGINODESTEAL, SLABS_SCANNED, KSWAPD_INODEST=
EAL,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0KSWAPD_LOW_WMARK_HIT_QUICKLY, KSWAPD_HIGH_=
WMARK_HIT_QUICKLY,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0KSWAPD_SKIP_CONGESTION_WAIT,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0PAGEOUTRUN, ALLOCSTALL, PGROTATED,
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 33c332b..078c9fd 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1568,9 +1568,14 @@ shrink_inactive_list(unsigned long nr_to_scan, str=
uct mem_cgroup_zone *mz,
> =A0 =A0 =A0 =A0reclaim_stat->recent_scanned[0] +=3D nr_anon;
> =A0 =A0 =A0 =A0reclaim_stat->recent_scanned[1] +=3D nr_file;
>
> - =A0 =A0 =A0 if (current_is_kswapd())
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __count_vm_events(KSWAPD_STEAL, nr_reclaime=
d);
> - =A0 =A0 =A0 __count_zone_vm_events(PGSTEAL, zone, nr_reclaimed);
> + =A0 =A0 =A0 if (global_reclaim(sc)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (current_is_kswapd())
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __count_zone_vm_events(PGST=
EAL_KSWAPD, zone,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0nr_reclaimed);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __count_zone_vm_events(PGST=
EAL_DIRECT, zone,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0nr_reclaimed);
> + =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0putback_inactive_pages(mz, &page_list);
>
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index f600557..7db1b9b 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -738,7 +738,8 @@ const char * const vmstat_text[] =3D {
> =A0 =A0 =A0 =A0"pgmajfault",
>
> =A0 =A0 =A0 =A0TEXTS_FOR_ZONES("pgrefill")
> - =A0 =A0 =A0 TEXTS_FOR_ZONES("pgsteal")
> + =A0 =A0 =A0 TEXTS_FOR_ZONES("pgsteal_kswapd")
> + =A0 =A0 =A0 TEXTS_FOR_ZONES("pgsteal_direct")
> =A0 =A0 =A0 =A0TEXTS_FOR_ZONES("pgscan_kswapd")
> =A0 =A0 =A0 =A0TEXTS_FOR_ZONES("pgscan_direct")
>
> @@ -747,7 +748,6 @@ const char * const vmstat_text[] =3D {
> =A0#endif
> =A0 =A0 =A0 =A0"pginodesteal",
> =A0 =A0 =A0 =A0"slabs_scanned",
> - =A0 =A0 =A0 "kswapd_steal",
> =A0 =A0 =A0 =A0"kswapd_inodesteal",
> =A0 =A0 =A0 =A0"kswapd_low_wmark_hit_quickly",
> =A0 =A0 =A0 =A0"kswapd_high_wmark_hit_quickly",
> --
> 1.7.7.3
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
