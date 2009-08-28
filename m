Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D18876B004D
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 11:04:48 -0400 (EDT)
Received: by gxk12 with SMTP id 12so2650247gxk.4
        for <linux-mm@kvack.org>; Fri, 28 Aug 2009 08:04:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1251449067-3109-3-git-send-email-mel@csn.ul.ie>
References: <1251449067-3109-1-git-send-email-mel@csn.ul.ie>
	 <1251449067-3109-3-git-send-email-mel@csn.ul.ie>
Date: Sat, 29 Aug 2009 00:04:48 +0900
Message-ID: <28c262360908280804r4c40c7baw7bb535dd8c275960@mail.gmail.com>
Subject: Re: [PATCH 2/2] page-allocator: Maintain rolling count of pages to
	free from the PCP
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi, Mel.

On Fri, Aug 28, 2009 at 5:44 PM, Mel Gorman<mel@csn.ul.ie> wrote:
> When round-robin freeing pages from the PCP lists, empty lists may be
> encountered. In the event one of the lists has more pages than another,
> there may be numerous checks for list_empty() which is undesirable. This
> patch maintains a count of pages to free which is incremented when empty
> lists are encountered. The intention is that more pages will then be free=
d
> from fuller lists than the empty ones reducing the number of empty list
> checks in the free path.
>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
> =C2=A0mm/page_alloc.c | =C2=A0 23 ++++++++++++++---------
> =C2=A01 files changed, 14 insertions(+), 9 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 65eedb5..9b86977 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -536,32 +536,37 @@ static void free_pcppages_bulk(struct zone *zone, i=
nt count,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct pe=
r_cpu_pages *pcp)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int migratetype =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 int batch_free =3D 0;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock(&zone->lock);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0zone->pages_scanned =3D 0;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0__mod_zone_page_state(zone, NR_FREE_PAGES, cou=
nt);
> - =C2=A0 =C2=A0 =C2=A0 while (count--) {
> + =C2=A0 =C2=A0 =C2=A0 while (count) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *page;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct list_head *=
list;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Remove pages f=
rom lists in a round-robin fashion. This spinning
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* around potenti=
ally empty lists is bloody awful, alternatives that
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* don't suck are=
 welcome
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Remove pages f=
rom lists in a round-robin fashion. A batch_free
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* count is maint=
ained that is incremented when an empty list is
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* encountered. T=
his is so more pages are freed off fuller lists
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* instead of spi=
nning excessively around empty lists
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0do {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 batch_free++;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (++migratetype =3D=3D MIGRATE_PCPTYPES)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0migratetype =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0list =3D &pcp->lists[migratetype];
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0} while (list_empt=
y(list));

How about increasing the weight by batch_free ?

batch_free =3D 1 << (batch_free - 1);

It's assumed that if batch_free is big, it means
there are contiguous empty lists.
Then it is likely to need more time to refill empty lists than
one list refill. So I think it can decrease spinning empty list
a little more.

>
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page =3D list_entry(li=
st->prev, struct page, lru);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* have to delete it a=
s __free_one_page list manipulates */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 list_del(&page->lru);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 trace_mm_page_pcpu_dra=
in(page, 0, migratetype);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __free_one_page(page, =
zone, 0, migratetype);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 do {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 page =3D list_entry(list->prev, struct page, lru);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 /* must delete as __free_one_page list manipulates */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 list_del(&page->lru);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 __free_one_page(page, zone, 0, migratetype);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 trace_mm_page_pcpu_drain(page, 0, migratetype);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } while (--count && --=
batch_free && !list_empty(list));
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock(&zone->lock);
> =C2=A0}
> --
> 1.6.3.3
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
