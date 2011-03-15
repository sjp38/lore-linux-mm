Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8DF148D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 22:03:32 -0400 (EDT)
Received: by iwl42 with SMTP id 42so199446iwl.14
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 19:03:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1300153521.2337.65.camel@sli10-conroe>
References: <1299735018.2337.62.camel@sli10-conroe>
	<20110314143457.GA11699@barrios-desktop>
	<1300153521.2337.65.camel@sli10-conroe>
Date: Tue, 15 Mar 2011 11:03:28 +0900
Message-ID: <AANLkTi=jgJ_S384oqZq4Q2t_TuC=yh9UY-i85300EXFM@mail.gmail.com>
Subject: Re: [PATCH 1/2 v4]mm: simplify code of swap.c
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, mel <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, Mar 15, 2011 at 10:45 AM, Shaohua Li <shaohua.li@intel.com> wrote:
> On Mon, 2011-03-14 at 22:34 +0800, Minchan Kim wrote:
>> Sorry for the late review.
>>
>> On Thu, Mar 10, 2011 at 01:30:18PM +0800, Shaohua Li wrote:
>> > Clean up code and remove duplicate code. Next patch will use
>> > pagevec_lru_move_fn introduced here too.
>> >
>> > Signed-off-by: Shaohua Li <shaohua.li@intel.com>
>> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
>>
>> There is a just nitpick below but I don't care about it if you don't min=
d it.
>> It's up to you or Andrew.
>>
>> >
>> > ---
>> > =C2=A0mm/swap.c | =C2=A0133 +++++++++++++++++++++++++++---------------=
--------------------
>> > =C2=A01 file changed, 58 insertions(+), 75 deletions(-)
>> >
>> > Index: linux/mm/swap.c
>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> > --- linux.orig/mm/swap.c =C2=A0 =C2=A02011-03-09 12:47:09.000000000 +0=
800
>> > +++ linux/mm/swap.c 2011-03-09 13:39:26.000000000 +0800
>> > @@ -179,15 +179,13 @@ void put_pages_list(struct list_head *pa
>> > =C2=A0}
>> > =C2=A0EXPORT_SYMBOL(put_pages_list);
>> >
>> > -/*
>> > - * pagevec_move_tail() must be called with IRQ disabled.
>> > - * Otherwise this may cause nasty races.
>> > - */
>> > -static void pagevec_move_tail(struct pagevec *pvec)
>> > +static void pagevec_lru_move_fn(struct pagevec *pvec,
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 void (*move_fn)(struct page *page, void *arg),
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 void *arg)
>> > =C2=A0{
>> > =C2=A0 =C2=A0 int i;
>> > - =C2=A0 int pgmoved =3D 0;
>> > =C2=A0 =C2=A0 struct zone *zone =3D NULL;
>> > + =C2=A0 unsigned long flags =3D 0;
>> >
>> > =C2=A0 =C2=A0 for (i =3D 0; i < pagevec_count(pvec); i++) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct page *page =3D pvec->=
pages[i];
>> > @@ -195,30 +193,50 @@ static void pagevec_move_tail(struct pag
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (pagezone !=3D zone) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
if (zone)
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock(&zone->lru_lock);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock_irqrestore(&zone->lru_lock, flags);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
zone =3D pagezone;
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_=
lock(&zone->lru_lock);
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (PageLRU(page) && !PageActive(=
page) && !PageUnevictable(page)) {
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 enum =
lru_list lru =3D page_lru_base_type(page);
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 list_=
move_tail(&page->lru, &zone->lru[lru].list);
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_c=
group_rotate_reclaimable_page(page);
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pgmov=
ed++;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_=
lock_irqsave(&zone->lru_lock, flags);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (*move_fn)(page, arg);
>> > =C2=A0 =C2=A0 }
>> > =C2=A0 =C2=A0 if (zone)
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock(&zone->lru_lock);
>> > - =C2=A0 __count_vm_events(PGROTATED, pgmoved);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock_irqrestore(&zone->lru=
_lock, flags);
>> > =C2=A0 =C2=A0 release_pages(pvec->pages, pvec->nr, pvec->cold);
>> > =C2=A0 =C2=A0 pagevec_reinit(pvec);
>> > =C2=A0}
>> >
>> > +static void pagevec_move_tail_fn(struct page *page, void *arg)
>> > +{
>> > + =C2=A0 int *pgmoved =3D arg;
>> > + =C2=A0 struct zone *zone =3D page_zone(page);
>> > +
>> > + =C2=A0 if (PageLRU(page) && !PageActive(page) && !PageUnevictable(pa=
ge)) {
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 enum lru_list lru =3D page_lru_ba=
se_type(page);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 list_move_tail(&page->lru, &zone-=
>lru[lru].list);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_rotate_reclaimable_pag=
e(page);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (*pgmoved)++;
>> > + =C2=A0 }
>> > +}
>> > +
>> > +/*
>> > + * pagevec_move_tail() must be called with IRQ disabled.
>> > + * Otherwise this may cause nasty races.
>> > + */
>> > +static void pagevec_move_tail(struct pagevec *pvec)
>> > +{
>> > + =C2=A0 int pgmoved =3D 0;
>> > +
>> > + =C2=A0 pagevec_lru_move_fn(pvec, pagevec_move_tail_fn, &pgmoved);
>> > + =C2=A0 __count_vm_events(PGROTATED, pgmoved);
>> > +}
>> > +
>>
>> Do we really need 3rd argument of pagevec_lru_move_fn?
>> It seems to be used just only pagevec_move_tail_fn.
>> But let's think about it again.
>> The __count_vm_events(pgmoved) could be done in pagevec_move_tail_fn.
>>
>> I don't like unnecessary argument passing although it's not a big overhe=
ad.
>> I want to make the code simple if we don't have any reason.
> Sure, making code simple is always preferred.
> ___pagevec_lru_add_fn uses the third the parameter too.

Oops. Sorry. I missed that.
I have no objection from right now. :)
Thanks.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
