Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8AB416B01CA
	for <linux-mm@kvack.org>; Thu, 14 May 2009 10:26:37 -0400 (EDT)
Received: by gxk20 with SMTP id 20so2502643gxk.14
        for <linux-mm@kvack.org>; Thu, 14 May 2009 07:27:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090514231555.f52c81eb.minchan.kim@gmail.com>
References: <20090514231555.f52c81eb.minchan.kim@gmail.com>
Date: Thu, 14 May 2009 23:27:00 +0900
Message-ID: <2f11576a0905140727j5ba02b07t94826f57dd99839c@mail.gmail.com>
Subject: Re: [PATCH] mmtom: Prevent shrinking of active anon lru list in case
	of no swap space V3
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> =A0mm/vmscan.c | =A0 =A02 +-
> =A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 2f9d555..621708f 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1577,7 +1577,7 @@ static void shrink_zone(int priority, struct zone *=
zone,
> =A0 =A0 =A0 =A0 * Even if we did not try to evict anon pages at all, we w=
ant to
> =A0 =A0 =A0 =A0 * rebalance the anon lru active/inactive ratio.
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 if (inactive_anon_is_low(zone, sc))
> + =A0 =A0 =A0 if (inactive_anon_is_low(zone, sc) && nr_swap_pages > 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0shrink_active_list(SWAP_CLUSTER_MAX, zone,=
 sc, priority, 0);


       if (nr_swap_pages > 0 && inactive_anon_is_low(zone, sc))

is better?
compiler can't swap evaluate order around &&.

then,

    if ( 0 && inactive_anon_is_low(zone, sc))

and

    if (inactive_anon_is_low(zone, sc) && 0)

are different.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
