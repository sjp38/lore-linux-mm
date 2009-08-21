Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8A1C66B00A0
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 11:41:21 -0400 (EDT)
Received: by ywh41 with SMTP id 41so1073761ywh.23
        for <linux-mm@kvack.org>; Fri, 21 Aug 2009 08:41:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090820031723.GA25673@localhost>
References: <20090820024929.GA19793@localhost>
	 <20090820025209.GA24387@localhost> <20090820031723.GA25673@localhost>
Date: Fri, 21 Aug 2009 20:09:17 +0900
Message-ID: <2f11576a0908210409p3f1551a4i194887abbad94e9b@mail.gmail.com>
Subject: Re: [RFC][PATCH] mm: remove unnecessary loop inside
	shrink_inactive_list()
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

2009/8/20 Wu Fengguang <fengguang.wu@intel.com>:
> shrink_inactive_list() won't be called to scan too much pages
> (unless in hibernation code which is fine) or too few pages (ie.
> batching is taken care of by the callers). =A0So we can just remove the
> big loop and isolate the exact number of pages requested.
>
> Just a RFC, and a scratch patch to show the basic idea.
> Please kindly NAK quick if you don't like it ;)

Hm, I think this patch taks only cleanups. right?
if so, I don't find any objection reason.




> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
> =A0mm/vmscan.c | =A0 32 ++++++++++++++++----------------
> =A01 file changed, 16 insertions(+), 16 deletions(-)
>
> --- linux.orig/mm/vmscan.c =A0 =A0 =A02009-08-20 10:16:18.000000000 +0800
> +++ linux/mm/vmscan.c =A0 2009-08-20 10:24:34.000000000 +0800
> @@ -1032,16 +1032,22 @@ int isolate_lru_page(struct page *page)
> =A0* shrink_inactive_list() is a helper for shrink_zone(). =A0It returns =
the number
> =A0* of reclaimed pages
> =A0*/
> -static unsigned long shrink_inactive_list(unsigned long max_scan,
> +static unsigned long shrink_inactive_list(unsigned long nr_to_scan,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct zone *zone, struct =
scan_control *sc,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int priority, int file)
> =A0{
> =A0 =A0 =A0 =A0LIST_HEAD(page_list);
> =A0 =A0 =A0 =A0struct pagevec pvec;
> - =A0 =A0 =A0 unsigned long nr_scanned =3D 0;
> - =A0 =A0 =A0 unsigned long nr_reclaimed =3D 0;
> + =A0 =A0 =A0 unsigned long nr_reclaimed;
> =A0 =A0 =A0 =A0struct zone_reclaim_stat *reclaim_stat =3D get_reclaim_sta=
t(zone, sc);
> - =A0 =A0 =A0 int lumpy_reclaim =3D 0;
> + =A0 =A0 =A0 int lumpy_reclaim;
> + =A0 =A0 =A0 struct page *page;
> + =A0 =A0 =A0 unsigned long nr_taken;
> + =A0 =A0 =A0 unsigned long nr_scan;
> + =A0 =A0 =A0 unsigned long nr_freed;
> + =A0 =A0 =A0 unsigned long nr_active;
> + =A0 =A0 =A0 unsigned int count[NR_LRU_LISTS] =3D { 0, };
> + =A0 =A0 =A0 int mode;
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * If we need a large contiguous chunk of memory, or have
> @@ -1054,21 +1060,17 @@ static unsigned long shrink_inactive_lis
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lumpy_reclaim =3D 1;
> =A0 =A0 =A0 =A0else if (sc->order && priority < DEF_PRIORITY - 2)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lumpy_reclaim =3D 1;
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lumpy_reclaim =3D 0;
> +
> + =A0 =A0 =A0 mode =3D lumpy_reclaim ? ISOLATE_BOTH : ISOLATE_INACTIVE;
>
> =A0 =A0 =A0 =A0pagevec_init(&pvec, 1);
>
> =A0 =A0 =A0 =A0lru_add_drain();
> =A0 =A0 =A0 =A0spin_lock_irq(&zone->lru_lock);
> - =A0 =A0 =A0 do {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page *page;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_taken;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_scan;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_freed;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_active;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned int count[NR_LRU_LISTS] =3D { 0, }=
;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 int mode =3D lumpy_reclaim ? ISOLATE_BOTH :=
 ISOLATE_INACTIVE;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_taken =3D sc->isolate_pages(sc->swap_clu=
ster_max,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_taken =3D sc->isolate_pages(nr_to_scan,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &page_list, &nr_s=
can, sc->order, mode,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone, sc->=
mem_cgroup, 0, file);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_active =3D clear_active_flags(&page_lis=
t, count);
> @@ -1093,7 +1095,6 @@ static unsigned long shrink_inactive_lis
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock_irq(&zone->lru_lock);
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_scanned +=3D nr_scan;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_freed =3D shrink_page_list(&page_list, =
sc, PAGEOUT_IO_ASYNC);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> @@ -1117,7 +1118,7 @@ static unsigned long shrink_inactive_lis
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0PAGEOUT_IO_SYNC);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_reclaimed +=3D nr_freed;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_reclaimed =3D nr_freed;

maybe, nr_freed can be removed perfectly. it have the same meaning as
nr_reclaimed.



> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0local_irq_disable();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (current_is_kswapd()) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__count_zone_vm_events(PGS=
CAN_KSWAPD, zone, nr_scan);
> @@ -1158,7 +1159,6 @@ static unsigned long shrink_inactive_lis
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock_=
irq(&zone->lru_lock);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 } while (nr_scanned < max_scan);
> =A0 =A0 =A0 =A0spin_unlock(&zone->lru_lock);
> =A0done:
> =A0 =A0 =A0 =A0local_irq_enable();
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
