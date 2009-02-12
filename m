Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 897CB6B003D
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 04:31:51 -0500 (EST)
Received: by rn-out-0910.google.com with SMTP id 56so698028rnw.4
        for <linux-mm@kvack.org>; Thu, 12 Feb 2009 01:31:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090212163310.b204e80a.minchan.kim@barrios-desktop>
References: <20090212163310.b204e80a.minchan.kim@barrios-desktop>
Date: Thu, 12 Feb 2009 18:31:50 +0900
Message-ID: <28c262360902120131o10cbed53g697311ff27ec20b8@mail.gmail.com>
Subject: Re: [PATCH v2] shrink_all_memory() use sc.nr_reclaimed
From: MinChan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, Feb 12, 2009 at 4:33 PM, MinChan Kim <minchan.kim@gmail.com> wrote:
>
> Impact: cleanup
>
> Commit a79311c14eae4bb946a97af25f3e1b17d625985d "vmscan: bail out of
> direct reclaim after swap_cluster_max pages" moved the nr_reclaimed
> counter into the scan control to accumulate the number of all
> reclaimed pages in a reclaim invocation.
>
> The shrink_all_memory() can use the same mechanism. it increases code
> consistency and readability.
>
> It's based on mmtom 2009-02-11-17-15.

Andrew, Sorry for confusing.
It's wrong. It's based on 2009-02-11-18-32

> Signed-off-by: MinChan Kim <minchan.kim@gmail.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
> Cc: Rik van Riel <riel@redhat.com>
>
>
> ---
>  mm/vmscan.c |   51 ++++++++++++++++++++++++++++++---------------------
>  1 files changed, 30 insertions(+), 21 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index ae4202b..caa2de5 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2055,16 +2055,15 @@ unsigned long global_lru_pages(void)
>  #ifdef CONFIG_PM
>  /*
>  * Helper function for shrink_all_memory().  Tries to reclaim 'nr_pages' pages
> - * from LRU lists system-wide, for given pass and priority, and returns the
> - * number of reclaimed pages
> + * from LRU lists system-wide, for given pass and priority.
>  *
>  * For pass > 3 we also try to shrink the LRU lists that contain a few pages
>  */
> -static unsigned long shrink_all_zones(unsigned long nr_pages, int prio,
> +static void shrink_all_zones(unsigned long nr_pages, int prio,
>                                      int pass, struct scan_control *sc)
>  {
>        struct zone *zone;
> -       unsigned long ret = 0;
> +       unsigned long nr_reclaimed = 0;
>
>        for_each_populated_zone(zone) {
>                enum lru_list l;
> @@ -2087,14 +2086,16 @@ static unsigned long shrink_all_zones(unsigned long nr_pages, int prio,
>
>                                zone->lru[l].nr_scan = 0;
>                                nr_to_scan = min(nr_pages, lru_pages);
> -                               ret += shrink_list(l, nr_to_scan, zone,
> +                               nr_reclaimed += shrink_list(l, nr_to_scan, zone,
>                                                                sc, prio);
> -                               if (ret >= nr_pages)
> -                                       return ret;
> +                               if (nr_reclaimed >= nr_pages) {
> +                                       sc->nr_reclaimed = nr_reclaimed;
> +                                       return;
> +                               }
>                        }
>                }
>        }
> -       return ret;
> +       sc->nr_reclaimed = nr_reclaimed;
>  }
>
>  /*
> @@ -2126,13 +2127,15 @@ unsigned long shrink_all_memory(unsigned long nr_pages)
>        /* If slab caches are huge, it's better to hit them first */
>        while (nr_slab >= lru_pages) {
>                reclaim_state.reclaimed_slab = 0;
> -               shrink_slab(nr_pages, sc.gfp_mask, lru_pages);
> +               shrink_slab(sc.swap_cluster_max, sc.gfp_mask, lru_pages);
>                if (!reclaim_state.reclaimed_slab)
>                        break;
>
> -               ret += reclaim_state.reclaimed_slab;
> -               if (ret >= nr_pages)
> +               sc.nr_reclaimed += reclaim_state.reclaimed_slab;
> +               if (sc.nr_reclaimed >= sc.swap_cluster_max) {
> +                       ret = sc.nr_reclaimed;
>                        goto out;
> +               }
>
>                nr_slab -= reclaim_state.reclaimed_slab;
>        }
> @@ -2153,19 +2156,23 @@ unsigned long shrink_all_memory(unsigned long nr_pages)
>                        sc.may_unmap = 1;
>
>                for (prio = DEF_PRIORITY; prio >= 0; prio--) {
> -                       unsigned long nr_to_scan = nr_pages - ret;
> +                       unsigned long nr_to_scan = sc.swap_cluster_max - sc.nr_reclaimed;
>
>                        sc.nr_scanned = 0;
> -                       ret += shrink_all_zones(nr_to_scan, prio, pass, &sc);
> -                       if (ret >= nr_pages)
> +                       shrink_all_zones(nr_to_scan, prio, pass, &sc);
> +                       if (sc.nr_reclaimed >= sc.swap_cluster_max) {
> +                               ret = sc.nr_reclaimed;
>                                goto out;
> +                       }
>
>                        reclaim_state.reclaimed_slab = 0;
>                        shrink_slab(sc.nr_scanned, sc.gfp_mask,
>                                        global_lru_pages());
> -                       ret += reclaim_state.reclaimed_slab;
> -                       if (ret >= nr_pages)
> +                       sc.nr_reclaimed += reclaim_state.reclaimed_slab;
> +                       if (sc.nr_reclaimed >= sc.swap_cluster_max) {
> +                               ret = sc.nr_reclaimed;
>                                goto out;
> +                       }
>
>                        if (sc.nr_scanned && prio < DEF_PRIORITY - 2)
>                                congestion_wait(WRITE, HZ / 10);
> @@ -2173,17 +2180,19 @@ unsigned long shrink_all_memory(unsigned long nr_pages)
>        }
>
>        /*
> -        * If ret = 0, we could not shrink LRUs, but there may be something
> +        * If sc.nr_reclaimed = 0, we could not shrink LRUs, but there may be something
>         * in slab caches
>         */
> -       if (!ret) {
> +       if (!sc.nr_reclaimed) {
>                do {
>                        reclaim_state.reclaimed_slab = 0;
> -                       shrink_slab(nr_pages, sc.gfp_mask, global_lru_pages());
> -                       ret += reclaim_state.reclaimed_slab;
> -               } while (ret < nr_pages && reclaim_state.reclaimed_slab > 0);
> +                       shrink_slab(sc.swap_cluster_max, sc.gfp_mask, global_lru_pages());
> +                       sc.nr_reclaimed += reclaim_state.reclaimed_slab;
> +               } while (sc.nr_reclaimed < sc.swap_cluster_max && reclaim_state.reclaimed_slab > 0);
>        }
>
> +       ret = sc.nr_reclaimed;
> +
>  out:
>        current->reclaim_state = NULL;
>
> --
> 1.5.4.3
>
>
>
> --
> Kinds Regards
> MinChan Kim
>



-- 
Kinds regards,
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
