Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4695F8D003B
	for <linux-mm@kvack.org>; Sat, 23 Apr 2011 23:03:29 -0400 (EDT)
Received: by wwi36 with SMTP id 36so1309460wwi.26
        for <linux-mm@kvack.org>; Sat, 23 Apr 2011 20:03:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1303604751-4980-1-git-send-email-minchan.kim@gmail.com>
References: <1303604751-4980-1-git-send-email-minchan.kim@gmail.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Sun, 24 Apr 2011 12:02:57 +0900
Message-ID: <BANLkTimzg184ZWraBomJ8ex1-B4Ypj6D9Q@mail.gmail.com>
Subject: Re: [PATCH] Check PageActive when evictable page and unevicetable
 page race happen
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>

2011/4/24 Minchan Kim <minchan.kim@gmail.com>:
> In putback_lru_page, unevictable page can be changed into evictable
> 's one while we move it among lru. So we have checked it again and
> rescued it. But we don't check PageActive, again. It could add
> active page into inactive list so we can see the BUG in isolate_lru_pages=
.
> (But I didn't see any report because I think it's very subtle)
>
> It could happen in race that zap_pte_range's mark_page_accessed and
> putback_lru_page. It's subtle but could be possible.
>
> Note:
> While I review the code, I found it. So it's not real report.
>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
> =A0mm/vmscan.c | =A0 =A04 +++-
> =A01 files changed, 3 insertions(+), 1 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index b3a569f..c0cd1aa 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -562,7 +562,7 @@ int remove_mapping(struct address_space *mapping, str=
uct page *page)
> =A0void putback_lru_page(struct page *page)
> =A0{
> =A0 =A0 =A0 =A0int lru;
> - =A0 =A0 =A0 int active =3D !!TestClearPageActive(page);
> + =A0 =A0 =A0 int active;
> =A0 =A0 =A0 =A0int was_unevictable =3D PageUnevictable(page);
>
> =A0 =A0 =A0 =A0VM_BUG_ON(PageLRU(page));
> @@ -571,6 +571,7 @@ redo:
> =A0 =A0 =A0 =A0ClearPageUnevictable(page);
>
> =A0 =A0 =A0 =A0if (page_evictable(page, NULL)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 active =3D !!TestClearPageActive(page);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * For evictable pages, we can use the cac=
he.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * In event of a race, worst case is we en=
d up with an
> @@ -584,6 +585,7 @@ redo:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Put unevictable pages directly on zone'=
s unevictable
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * list.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ClearPageActive(page);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lru =3D LRU_UNEVICTABLE;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0add_page_to_unevictable_list(page);

I think we forgot 'goto redo' case. following patch is better?

------------------------------------------------
        if (page_evictable(page, NULL)) {
                /*
                 * For evictable pages, we can use the cache.
                 * In event of a race, worst case is we end up with an
                 * unevictable page on [in]active list.
                 * We know how to handle that.
                 */
                lru =3D active + page_lru_base_type(page);
+              if (active)
+                   SetPageActive(page);
                lru_cache_add_lru(page, lru);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
