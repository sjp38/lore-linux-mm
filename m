Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9AD308D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 18:23:26 -0500 (EST)
Received: by iwc10 with SMTP id 10so687109iwc.14
        for <linux-mm@kvack.org>; Wed, 09 Feb 2011 15:23:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110209134754.d28f018c.akpm@linux-foundation.org>
References: <1297257677-12287-1-git-send-email-namhyung@gmail.com>
	<20110209123803.4bb6291c.akpm@linux-foundation.org>
	<20110209213338.GK27110@cmpxchg.org>
	<20110209134754.d28f018c.akpm@linux-foundation.org>
Date: Thu, 10 Feb 2011 08:23:08 +0900
Message-ID: <AANLkTimG5Qnz39dj_D3C0-Ty1CanpnaWHQbKzT4miMSa@mail.gmail.com>
Subject: Re: [PATCH] mm: batch-free pcp list if possible
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Namhyung Kim <namhyung@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>

On Thu, Feb 10, 2011 at 6:47 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 9 Feb 2011 22:33:38 +0100
> Johannes Weiner <hannes@cmpxchg.org> wrote:
>
>> On Wed, Feb 09, 2011 at 12:38:03PM -0800, Andrew Morton wrote:
>> > On Wed, =C2=A09 Feb 2011 22:21:17 +0900
>> > Namhyung Kim <namhyung@gmail.com> wrote:
>> >
>> > > free_pcppages_bulk() frees pages from pcp lists in a round-robin
>> > > fashion by keeping batch_free counter. But it doesn't need to spin
>> > > if there is only one non-empty list. This can be checked by
>> > > batch_free =3D=3D MIGRATE_PCPTYPES.
>> > >
>> > > Signed-off-by: Namhyung Kim <namhyung@gmail.com>
>> > > ---
>> > > =C2=A0mm/page_alloc.c | =C2=A0 =C2=A04 ++++
>> > > =C2=A01 files changed, 4 insertions(+), 0 deletions(-)
>> > >
>> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> > > index a873e61e312e..470fb42e303c 100644
>> > > --- a/mm/page_alloc.c
>> > > +++ b/mm/page_alloc.c
>> > > @@ -614,6 +614,10 @@ static void free_pcppages_bulk(struct zone *zon=
e, int count,
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 list =
=3D &pcp->lists[migratetype];
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } while (list_empty(list));
>> > >
>> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* This is an only non-empty list. Fre=
e them all. */
>> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (batch_free =3D=3D MIGRATE_PCPTYPES=
)
>> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 batch_free=
 =3D to_free;
>> > > +
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 do {
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page =
=3D list_entry(list->prev, struct page, lru);
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* mu=
st delete as __free_one_page list manipulates */
>> >
>> > free_pcppages_bulk() hurts my brain.
>>
>> Thanks for saying that ;-)
>
> My brain has a lot of scar tissue.
>
>> > What is it actually trying to do, and why? =C2=A0It counts up the numb=
er of
>> > contiguous empty lists and then frees that number of pages from the
>> > first-encountered non-empty list and then advances onto the next list?
>> >
>> > What's the point in that? =C2=A0What relationship does the number of
>> > contiguous empty lists have with the number of pages to free from one
>> > list?
>>
>> It at least recovers some of the otherwise wasted effort of looking at
>> an empty list, by flushing more pages once it encounters a non-empty
>> list. =C2=A0After all, freeing to_free pages is the goal.
>>
>> That breaks the round-robin fashion, though. =C2=A0If list-1 has pages,
>> list-2 is empty and list-3 has pages, it will repeatedly free one page
>> from list-1 and two pages from list-3.
>>
>> My initial response to Namhyung's patch was to write up a version that
>> used a bitmap for all lists. =C2=A0It starts with all lists set and clea=
rs
>> their respective bit once the list is empty, so it would never
>> consider them again. =C2=A0But it looked a bit over-engineered for 3 lis=
ts
>> and the resulting object code was bigger than what we have now.
>> Though, it would be more readable. =C2=A0Attached for reference (unteste=
d
>> and all).
>>
>> =C2=A0 =C2=A0 =C2=A0 Hannes
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 60e58b0..c77ab28 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -590,8 +590,7 @@ static inline int free_pages_check(struct page *page=
)
>> =C2=A0static void free_pcppages_bulk(struct zone *zone, int count,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct per_c=
pu_pages *pcp)
>> =C2=A0{
>> - =C2=A0 =C2=A0 int migratetype =3D 0;
>> - =C2=A0 =C2=A0 int batch_free =3D 0;
>> + =C2=A0 =C2=A0 unsigned long listmap =3D (1 << MIGRATE_PCPTYPES) - 1;
>> =C2=A0 =C2=A0 =C2=A0 int to_free =3D count;
>>
>> =C2=A0 =C2=A0 =C2=A0 spin_lock(&zone->lock);
>> @@ -599,31 +598,29 @@ static void free_pcppages_bulk(struct zone *zone, =
int count,
>> =C2=A0 =C2=A0 =C2=A0 zone->pages_scanned =3D 0;
>>
>> =C2=A0 =C2=A0 =C2=A0 while (to_free) {
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct page *page;
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct list_head *list;
>> -
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int migratetype;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Remove pages from li=
sts in a round-robin fashion. A
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* batch_free count is =
maintained that is incremented when an
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* empty list is encoun=
tered. =C2=A0This is so more pages are freed
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* off fuller lists ins=
tead of spinning excessively around empty
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* lists
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Remove pages from li=
sts in a round-robin fashion.
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Empty lists are excl=
uded from subsequent rounds.
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 do {
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
batch_free++;
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
if (++migratetype =3D=3D MIGRATE_PCPTYPES)
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 migratetype =3D 0;
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
list =3D &pcp->lists[migratetype];
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } while (list_empty(list));
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 for_each_set_bit (migratetyp=
e, &listmap, MIGRATE_PCPTYPES) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
struct list_head *list;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
struct page *page;
>>
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 do {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
list =3D &pcp->lists[migratetype];
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
if (list_empty(list)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 listmap &=3D ~(1 << migratetype);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 continue;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
}
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
if (!to_free--)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 page =3D list_entry(list->prev, struct page, lru);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 /* must delete as __free_one_page list manipulates */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 list_del(&page->lru);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 /* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 __free_one_page(page, zone, 0, page_private(page));
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 trace_mm_page_pcpu_drain(page, 0, page_private(page));
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } while (--to_free && --batc=
h_free && !list_empty(list));
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 __mod_zone_page_state(zone, NR_FREE_PAGES, count);
>> =C2=A0 =C2=A0 =C2=A0 spin_unlock(&zone->lock);
>
> Well, it replaces one linear search with another one. =C2=A0If you really
> want to avoid repeated walking over empty lists then create a local
> array `list_head *lists[MIGRATE_PCPTYPES]' (or MIGRATE_PCPTYPES+1 for
> null-termination), populate it on entry and compact it as lists fall
> empty. =C2=A0Then the code can simply walk around the lists until to_free=
 is
> satisfied or list_empty(lists[0]). =C2=A0It's not obviously worth the eff=
ort
> though - the empty list_heads will be cache-hot and all the cost will
> be in hitting cache-cold pageframes.

Hannes's patch solves round-robin fairness as well as avoidance of
empty list although it makes rather bloated code.
I think it's enough to solve the fairness regardless of whether it's
Hannes's approach or your idea.

>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =C2=A0http://www.tux.org/lkml/
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
