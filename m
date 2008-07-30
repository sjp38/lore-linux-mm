Received: by yw-out-1718.google.com with SMTP id 5so119491ywm.26
        for <linux-mm@kvack.org>; Wed, 30 Jul 2008 13:37:40 -0700 (PDT)
Message-ID: <2f11576a0807301337i58422d07if590b0181749f8f2@mail.gmail.com>
Date: Thu, 31 Jul 2008 05:37:40 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/7] unevictable lru: add event counts to list scan
In-Reply-To: <20080730200643.24272.16893.sendpatchset@lts-notebook>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080730200618.24272.31756.sendpatchset@lts-notebook>
	 <20080730200643.24272.16893.sendpatchset@lts-notebook>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Rik van Riel <riel@surriel.com>, Eric.Whitney@hp.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

>  mm/vmscan.c |    5 +++++
>  1 file changed, 5 insertions(+)
>
> Index: linux-2.6.27-rc1-mmotm-30jul/mm/vmscan.c
> ===================================================================
> --- linux-2.6.27-rc1-mmotm-30jul.orig/mm/vmscan.c       2008-07-30 13:26:46.000000000 -0400
> +++ linux-2.6.27-rc1-mmotm-30jul/mm/vmscan.c    2008-07-30 13:34:58.000000000 -0400
> @@ -2407,6 +2407,7 @@ retry:
>                __dec_zone_state(zone, NR_UNEVICTABLE);
>                list_move(&page->lru, &zone->lru[l].list);
>                __inc_zone_state(zone, NR_INACTIVE_ANON + l);
> +               __count_vm_event(UNEVICTABLE_PGRESCUED);
>        } else {
>                /*
>                 * rotate unevictable list
> @@ -2440,6 +2441,7 @@ void scan_mapping_unevictable_pages(stru
>        while (next < end &&
>                pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
>                int i;
> +               int pg_scanned = 0;
>
>                zone = NULL;
>
> @@ -2448,6 +2450,7 @@ void scan_mapping_unevictable_pages(stru
>                        pgoff_t page_index = page->index;
>                        struct zone *pagezone = page_zone(page);
>
> +                       pg_scanned++;
>                        if (page_index > next)
>                                next = page_index;
>                        next++;
> @@ -2465,6 +2468,8 @@ void scan_mapping_unevictable_pages(stru
>                if (zone)
>                        spin_unlock_irq(&zone->lru_lock);
>                pagevec_release(&pvec);
> +
> +               count_vm_events(UNEVICTABLE_PGSCANNED, pg_scanned);

yup, ok.

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
