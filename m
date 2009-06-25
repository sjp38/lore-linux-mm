Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 804B76B005C
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 10:14:20 -0400 (EDT)
Received: by yxe3 with SMTP id 3so110940yxe.12
        for <linux-mm@kvack.org>; Thu, 25 Jun 2009 07:14:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090625183616.23b55b24.minchan.kim@barrios-desktop>
References: <20090625183616.23b55b24.minchan.kim@barrios-desktop>
Date: Thu, 25 Jun 2009 23:14:45 +0900
Message-ID: <2f11576a0906250714o5d77db11wd32c1c7139753cb5@mail.gmail.com>
Subject: Re: [PATCH] prevent to reclaim anon page of lumpy reclaim for no swap
	space
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> This patch prevent to reclaim anon page in case of no swap space.
> VM already prevent to reclaim anon page in various place.
> But it doesnt't prevent it for lumpy reclaim.
>
> It shuffles lru list unnecessary so that it is pointless.

NAK.

1. if system have no swap, add_to_swap() never get swap entry.
   eary check don't improve performance so much.
2. __isolate_lru_page() is not only called lumpy reclaim case, but
also be called
    normal reclaim.
3. if system have no swap, anon pages shuffuling doesn't cause any matter.

Then, I don't think this patch's benefit is bigger than side effect.



> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
> =A0mm/vmscan.c | =A0 =A06 ++++++
> =A01 files changed, 6 insertions(+), 0 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 026f452..fb401fe 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -830,7 +830,13 @@ int __isolate_lru_page(struct page *page, int mode, =
int file)
> =A0 =A0 =A0 =A0 * When this function is being called for lumpy reclaim, w=
e
> =A0 =A0 =A0 =A0 * initially look into all LRU pages, active, inactive and
> =A0 =A0 =A0 =A0 * unevictable; only give shrink_page_list evictable pages=
.
> +
> + =A0 =A0 =A0 =A0* If we don't have enough swap space, reclaiming of anon=
 page
> + =A0 =A0 =A0 =A0* is pointless.
> =A0 =A0 =A0 =A0 */
> + =A0 =A0 =A0 if (nr_swap_pages <=3D 0 && PageAnon(page))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
> +
> =A0 =A0 =A0 =A0if (PageUnevictable(page))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ret;
>
> --
> 1.5.4.3
>
>
>
>
> --
> Kinds Regards
> Minchan Kim
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
