Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D54C26B004D
	for <linux-mm@kvack.org>; Tue, 21 Jul 2009 21:52:16 -0400 (EDT)
Received: by gxk3 with SMTP id 3so5710502gxk.14
        for <linux-mm@kvack.org>; Tue, 21 Jul 2009 18:52:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1248166594-8859-2-git-send-email-hannes@cmpxchg.org>
References: <1248166594-8859-1-git-send-email-hannes@cmpxchg.org>
	 <1248166594-8859-2-git-send-email-hannes@cmpxchg.org>
Date: Wed, 22 Jul 2009 10:52:21 +0900
Message-ID: <28c262360907211852m7aa0fd6eic69e4ce29f09e5b8@mail.gmail.com>
Subject: Re: [patch 2/4] mm: introduce page_lru_type()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi.

On Tue, Jul 21, 2009 at 5:56 PM, Johannes Weiner<hannes@cmpxchg.org> wrote:
> Instead of abusing page_is_file_cache() for LRU list index arithmetic,
> add another helper with a more appropriate name and convert the
> non-boolean users of page_is_file_cache() accordingly.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
> =C2=A0include/linux/mm_inline.h | =C2=A0 19 +++++++++++++++++--
> =C2=A0mm/swap.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=
 =C2=A0 =C2=A04 ++--
> =C2=A0mm/vmscan.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=
=A0 =C2=A06 +++---
> =C2=A03 files changed, 22 insertions(+), 7 deletions(-)
>
> diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
> index 7fbb972..ec975f2 100644
> --- a/include/linux/mm_inline.h
> +++ b/include/linux/mm_inline.h
> @@ -60,6 +60,21 @@ del_page_from_lru(struct zone *zone, struct page *page=
)
> =C2=A0}
>
> =C2=A0/**
> + * page_lru_type - which LRU list type should a page be on?
> + * @page: the page to test
> + *
> + * Used for LRU list index arithmetic.
> + *
> + * Returns the base LRU type - file or anon - @page should be on.
> + */
> +static enum lru_list page_lru_type(struct page *page)
> +{
> + =C2=A0 =C2=A0 =C2=A0 if (page_is_file_cache(page))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return LRU_INACTIVE_FI=
LE;
> + =C2=A0 =C2=A0 =C2=A0 return LRU_INACTIVE_ANON;
> +}

page_lru_type function's semantics is general but this function only
considers INACTIVE case.
So we always have to check PageActive to know exact lru type.

Why do we need double check(ex, page_lru_type and PageActive) to know
exact lru type ?

It wouldn't be better to check it all at once ?


> +
> +/**
> =C2=A0* page_lru - which LRU list should a page be on?
> =C2=A0* @page: the page to test
> =C2=A0*
> @@ -68,14 +83,14 @@ del_page_from_lru(struct zone *zone, struct page *pag=
e)
> =C2=A0*/
> =C2=A0static inline enum lru_list page_lru(struct page *page)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 enum lru_list lru =3D LRU_BASE;
> + =C2=A0 =C2=A0 =C2=A0 enum lru_list lru;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (PageUnevictable(page))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0lru =3D LRU_UNEVIC=
TABLE;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0else {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 lru =3D page_lru_type(=
page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (PageActive(pag=
e))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0lru +=3D LRU_ACTIVE;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 lru +=3D page_is_file_=
cache(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return lru;
> diff --git a/mm/swap.c b/mm/swap.c
> index cb29ae5..8f84638 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -118,7 +118,7 @@ static void pagevec_move_tail(struct pagevec *pvec)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0spin_lock(&zone->lru_lock);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (PageLRU(page) =
&& !PageActive(page) && !PageUnevictable(page)) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 int lru =3D page_is_file_cache(page);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 int lru =3D page_lru_type(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0list_move_tail(&page->lru, &zone->lru[lru].list);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0pgmoved++;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> @@ -181,7 +181,7 @@ void activate_page(struct page *page)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_irq(&zone->lru_lock);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (PageLRU(page) && !PageActive(page) && !Pag=
eUnevictable(page)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int file =3D page_=
is_file_cache(page);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int lru =3D LRU_BASE +=
 file;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int lru =3D page_lru_t=
ype(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0del_page_from_lru_=
list(zone, page, lru);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0SetPageActive(page=
);
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 46ec6a5..758f628 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -531,7 +531,7 @@ redo:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * unevictable pag=
e on [in]active list.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * We know how to =
handle that.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 lru =3D active + page_=
is_file_cache(page);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 lru =3D active + page_=
lru_type(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0lru_cache_add_lru(=
page, lru);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0} else {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> @@ -981,7 +981,7 @@ static unsigned long clear_active_flags(struct list_h=
ead *page_list,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *page;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0list_for_each_entry(page, page_list, lru) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 lru =3D page_is_file_c=
ache(page);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 lru =3D page_lru_type(=
page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (PageActive(pag=
e)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0lru +=3D LRU_ACTIVE;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0ClearPageActive(page);
> @@ -2645,7 +2645,7 @@ static void check_move_unevictable_page(struct page=
 *page, struct zone *zone)
> =C2=A0retry:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ClearPageUnevictable(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (page_evictable(page, NULL)) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 enum lru_list l =3D LR=
U_INACTIVE_ANON + page_is_file_cache(page);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 enum lru_list l =3D pa=
ge_lru_type(page);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__dec_zone_state(z=
one, NR_UNEVICTABLE);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0list_move(&page->l=
ru, &zone->lru[l].list);
> --
> 1.6.3
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
