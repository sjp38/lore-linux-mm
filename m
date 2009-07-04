Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B9AF66B004F
	for <linux-mm@kvack.org>; Sat,  4 Jul 2009 13:14:18 -0400 (EDT)
Received: by qyk36 with SMTP id 36so1845947qyk.12
        for <linux-mm@kvack.org>; Sat, 04 Jul 2009 10:36:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090704141818.0afa877a.minchan.kim@gmail.com>
References: <20090704141818.0afa877a.minchan.kim@gmail.com>
Date: Sun, 5 Jul 2009 02:36:25 +0900
Message-ID: <2f11576a0907041036i3585206bl475cc9f70176a0db@mail.gmail.com>
Subject: Re: [PATCH][mmotm] don't attempt to reclaim anon page in lumpy
	reclaim when no swap space is available
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

2009/7/4 Minchan Kim <minchan.kim@gmail.com>:
>
> This patch is based on mmotm 2009-07-02-19-57 reverted
> 'vmscan: don't attempt to reclaim anon page in lumpy reclaim when no swap=
 space is available.'
>
> This verssion is better than old one.
> That's because enough swap space check is done in case of only lumpy recl=
aim.
> so it can't degrade performance in normal case.
>
> =3D=3D CUT HERE =3D=3D
>
> VM already avoids attempting to reclaim anon pages in various places, But
> it doesn't avoid it for lumpy reclaim.
>
> It shuffles lru list unnecessary so that it is pointless.
>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =A0mm/vmscan.c | =A0 =A07 +++++++
> =A01 files changed, 7 insertions(+), 0 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 27558aa..977af15 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -930,6 +930,13 @@ static unsigned long isolate_lru_pages(unsigned long=
 nr_to_scan,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Check that we have not =
crossed a zone boundary. */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (unlikely(page_zone_id(=
cursor_page) !=3D zone_id))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If we don't have enoug=
h swap space, reclaiming of anon page
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* which don't already ha=
ve a swap slot is pointless.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nr_swap_pages <=3D 0 &&=
 (PageAnon(cursor_page) &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 !PageSwapCache(cursor_page)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (__isolate_lru_page(cur=
sor_page, mode, file) =3D=3D 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_move(=
&cursor_page->lru, dst);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup=
_del_lru(cursor_page);

okey. this is definitely better. thanks.
    Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
