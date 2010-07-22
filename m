Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D95886B024D
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 21:08:47 -0400 (EDT)
Received: by iwn2 with SMTP id 2so8740106iwn.14
        for <linux-mm@kvack.org>; Wed, 21 Jul 2010 18:08:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100722002716.GA7740@sli10-desk.sh.intel.com>
References: <1279610324.17101.9.camel@sli10-desk.sh.intel.com>
	<20100721160634.GA7976@barrios-desktop>
	<20100722002716.GA7740@sli10-desk.sh.intel.com>
Date: Thu, 22 Jul 2010 10:08:43 +0900
Message-ID: <AANLkTimDszQHVV8P=C9xjNMY65NDNz16qOm8DUHu=Mz0@mail.gmail.com>
Subject: Re: [RFC]mm: batch activate_page() to reduce lock contention
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, "Wu, Fengguang" <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 22, 2010 at 9:27 AM, Shaohua Li <shaohua.li@intel.com> wrote:
>> > But we did see some strange regression. The regression is small (usual=
ly < 2%)
>> > and most are from multithread test and none heavily use activate_page(=
). For
>> > example, in the same system, we create 64 threads. Each thread creates=
 a private
>> > mmap region and does read access. We measure the total time and saw ab=
out 2%
>> > regression. But in such workload, 99% time is on page fault and activa=
te_page()
>> > takes no time. Very strange, we haven't a good explanation for this so=
 far,
>> > hopefully somebody can share a hint.
>>
>> Mabye it might be due to lru_add_drain.
>> You are adding cost in lru_add_drain and it is called several place.
>> So if we can't get the gain in there, it could make a bit of regression.
>> I might be wrong and it's a just my guessing.
> The workload with regression doesn't invoke too many activate_page, so
> basically activate_page_drain_cpu() is a nop, it should not take too much=
.

I think it's culprit. little call activate_page, many call lru_drain_all.
It would make losing pagevec's benefit.
But as your scenario, I think it doesn't call lru_drain_all frequently.
That's because it is called when process call things related unmap
operation or swapping.
Do you have a such workload in test case?

>
>> > Signed-off-by: Shaohua Li <shaohua.li@intel.com>
>> >
>> > diff --git a/mm/swap.c b/mm/swap.c
>> > index 3ce7bc3..4a3fd7f 100644
>> > --- a/mm/swap.c
>> > +++ b/mm/swap.c
>> > @@ -39,6 +39,7 @@ int page_cluster;
>> >
>> > =A0static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
>> > =A0static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
>> > +static DEFINE_PER_CPU(struct pagevec, activate_page_pvecs);
>> >
>> > =A0/*
>> > =A0 * This path almost never happens for VM activity - pages are norma=
lly
>> > @@ -175,11 +176,10 @@ static void update_page_reclaim_stat(struct zone=
 *zone, struct page *page,
>> > =A0/*
>> > =A0 * FIXME: speed this up?
>> > =A0 */
>> Couldn't we remove above comment by this patch?
> ha, yes.
>
>> > -void activate_page(struct page *page)
>> > +static void __activate_page(struct page *page)
>> > =A0{
>> > =A0 =A0 struct zone *zone =3D page_zone(page);
>> >
>> > - =A0 spin_lock_irq(&zone->lru_lock);
>> > =A0 =A0 if (PageLRU(page) && !PageActive(page) && !PageUnevictable(pag=
e)) {
>> > =A0 =A0 =A0 =A0 =A0 =A0 int file =3D page_is_file_cache(page);
>> > =A0 =A0 =A0 =A0 =A0 =A0 int lru =3D page_lru_base_type(page);
>> > @@ -192,7 +192,46 @@ void activate_page(struct page *page)
>> >
>> > =A0 =A0 =A0 =A0 =A0 =A0 update_page_reclaim_stat(zone, page, file, 1);
>> > =A0 =A0 }
>> > - =A0 spin_unlock_irq(&zone->lru_lock);
>> > +}
>> > +
>> > +static void activate_page_drain_cpu(int cpu)
>> > +{
>> > + =A0 struct pagevec *pvec =3D &per_cpu(activate_page_pvecs, cpu);
>> > + =A0 struct zone *last_zone =3D NULL, *zone;
>> > + =A0 int i, j;
>> > +
>> > + =A0 for (i =3D 0; i < pagevec_count(pvec); i++) {
>> > + =A0 =A0 =A0 =A0 =A0 zone =3D page_zone(pvec->pages[i]);
>> > + =A0 =A0 =A0 =A0 =A0 if (zone =3D=3D last_zone)
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> > +
>> > + =A0 =A0 =A0 =A0 =A0 if (last_zone)
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irq(&last_zone->lru_=
lock);
>> > + =A0 =A0 =A0 =A0 =A0 last_zone =3D zone;
>> > + =A0 =A0 =A0 =A0 =A0 spin_lock_irq(&last_zone->lru_lock);
>> > +
>> > + =A0 =A0 =A0 =A0 =A0 for (j =3D i; j < pagevec_count(pvec); j++) {
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page *page =3D pvec->page=
s[j];
>> > +
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (last_zone !=3D page_zone(pag=
e))
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __activate_page(page);
>> > + =A0 =A0 =A0 =A0 =A0 }
>> > + =A0 }
>> > + =A0 if (last_zone)
>> > + =A0 =A0 =A0 =A0 =A0 spin_unlock_irq(&last_zone->lru_lock);
>> > + =A0 release_pages(pvec->pages, pagevec_count(pvec), pvec->cold);
>> > + =A0 pagevec_reinit(pvec);
>>
>> In worst case(DMA->NORMAL->HIGHMEM->DMA->NORMA->HIGHMEM->......),
>> overhead would is big than old. how about following as?
>> static DEFINE_PER_CPU(struct pagevec[MAX_NR_ZONES], activate_page_pvecs)=
;
>> Is it a overkill?
> activate_page_drain_cpu is a two level loop. In you case, the drain order
> will be DMA->DMA->NORMAL->NORMAL->HIGHMEM->HIGHMEM. Since pagevec size is
> 14, the loop should finish quickly.
Yes. so why do we separates lru pagevec with  pagevec[NR_LRU_LISTS]?
I think It can remove looping unnecessary looping overhead but of
course we have to use more memory.




--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
