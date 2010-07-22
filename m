Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2BCCB6B02A4
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 08:29:07 -0400 (EDT)
Received: by pvc30 with SMTP id 30so3656641pvc.14
        for <linux-mm@kvack.org>; Thu, 22 Jul 2010 05:29:08 -0700 (PDT)
Date: Thu, 22 Jul 2010 21:28:42 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [RFC]mm: batch activate_page() to reduce lock contention
Message-ID: <20100722122842.GA23183@barrios-desktop>
References: <1279610324.17101.9.camel@sli10-desk.sh.intel.com>
 <20100721160634.GA7976@barrios-desktop>
 <20100722002716.GA7740@sli10-desk.sh.intel.com>
 <AANLkTimDszQHVV8P=C9xjNMY65NDNz16qOm8DUHu=Mz0@mail.gmail.com>
 <20100722051702.GA26829@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20100722051702.GA26829@sli10-desk.sh.intel.com>
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, "Wu, Fengguang" <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 22, 2010 at 01:17:03PM +0800, Shaohua Li wrote:
> On Thu, Jul 22, 2010 at 09:08:43AM +0800, Minchan Kim wrote:
> > On Thu, Jul 22, 2010 at 9:27 AM, Shaohua Li <shaohua.li@intel.com> wrote:
> > >> > But we did see some strange regression. The regression is small (usually < 2%)
> > >> > and most are from multithread test and none heavily use activate_page(). For
> > >> > example, in the same system, we create 64 threads. Each thread creates a private
> > >> > mmap region and does read access. We measure the total time and saw about 2%
> > >> > regression. But in such workload, 99% time is on page fault and activate_page()
> > >> > takes no time. Very strange, we haven't a good explanation for this so far,
> > >> > hopefully somebody can share a hint.
> > >>
> > >> Mabye it might be due to lru_add_drain.
> > >> You are adding cost in lru_add_drain and it is called several place.
> > >> So if we can't get the gain in there, it could make a bit of regression.
> > >> I might be wrong and it's a just my guessing.
> > > The workload with regression doesn't invoke too many activate_page, so
> > > basically activate_page_drain_cpu() is a nop, it should not take too much.
> > 
> > I think it's culprit. little call activate_page, many call lru_drain_all.
> > It would make losing pagevec's benefit.
> > But as your scenario, I think it doesn't call lru_drain_all frequently.
> > That's because it is called when process call things related unmap
> > operation or swapping.
> > Do you have a such workload in test case?
> Yes, I'm testing if activate_page_drain_cpu() causes the regression. This regression
> is small (<2%) for a stress test and sometimes not stable.

Do you mean regression is less 2% even corner case happens?
Then, Okay. it might be marginal number.

> 
> > >> > Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> > >> >
> > >> > diff --git a/mm/swap.c b/mm/swap.c
> > >> > index 3ce7bc3..4a3fd7f 100644
> > >> > --- a/mm/swap.c
> > >> > +++ b/mm/swap.c
> > >> > @@ -39,6 +39,7 @@ int page_cluster;
> > >> >
> > >> >  static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
> > >> >  static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
> > >> > +static DEFINE_PER_CPU(struct pagevec, activate_page_pvecs);
> > >> >
> > >> >  /*
> > >> >   * This path almost never happens for VM activity - pages are normally
> > >> > @@ -175,11 +176,10 @@ static void update_page_reclaim_stat(struct zone *zone, struct page *page,
> > >> >  /*
> > >> >   * FIXME: speed this up?
> > >> >   */
> > >> Couldn't we remove above comment by this patch?
> > > ha, yes.
> > >
> > >> > -void activate_page(struct page *page)
> > >> > +static void __activate_page(struct page *page)
> > >> >  {
> > >> >     struct zone *zone = page_zone(page);
> > >> >
> > >> > -   spin_lock_irq(&zone->lru_lock);
> > >> >     if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
> > >> >             int file = page_is_file_cache(page);
> > >> >             int lru = page_lru_base_type(page);
> > >> > @@ -192,7 +192,46 @@ void activate_page(struct page *page)
> > >> >
> > >> >             update_page_reclaim_stat(zone, page, file, 1);
> > >> >     }
> > >> > -   spin_unlock_irq(&zone->lru_lock);
> > >> > +}
> > >> > +
> > >> > +static void activate_page_drain_cpu(int cpu)
> > >> > +{
> > >> > +   struct pagevec *pvec = &per_cpu(activate_page_pvecs, cpu);
> > >> > +   struct zone *last_zone = NULL, *zone;
> > >> > +   int i, j;
> > >> > +
> > >> > +   for (i = 0; i < pagevec_count(pvec); i++) {
> > >> > +           zone = page_zone(pvec->pages[i]);
> > >> > +           if (zone == last_zone)
> > >> > +                   continue;
> > >> > +
> > >> > +           if (last_zone)
> > >> > +                   spin_unlock_irq(&last_zone->lru_lock);
> > >> > +           last_zone = zone;
> > >> > +           spin_lock_irq(&last_zone->lru_lock);
> > >> > +
> > >> > +           for (j = i; j < pagevec_count(pvec); j++) {
> > >> > +                   struct page *page = pvec->pages[j];
> > >> > +
> > >> > +                   if (last_zone != page_zone(page))
> > >> > +                           continue;
> > >> > +                   __activate_page(page);
> > >> > +           }
> > >> > +   }
> > >> > +   if (last_zone)
> > >> > +           spin_unlock_irq(&last_zone->lru_lock);
> > >> > +   release_pages(pvec->pages, pagevec_count(pvec), pvec->cold);
> > >> > +   pagevec_reinit(pvec);
> > >>
> > >> In worst case(DMA->NORMAL->HIGHMEM->DMA->NORMA->HIGHMEM->......),
> > >> overhead would is big than old. how about following as?
> > >> static DEFINE_PER_CPU(struct pagevec[MAX_NR_ZONES], activate_page_pvecs);
> > >> Is it a overkill?
> > > activate_page_drain_cpu is a two level loop. In you case, the drain order
> > > will be DMA->DMA->NORMAL->NORMAL->HIGHMEM->HIGHMEM. Since pagevec size is
> > > 14, the loop should finish quickly.
> > Yes. so why do we separates lru pagevec with  pagevec[NR_LRU_LISTS]?
> > I think It can remove looping unnecessary looping overhead but of
> > course we have to use more memory.
> Each node has zones, so a pagevec[MAX_NR_ZONES] doesn't work here. And in my

Ahh. Yes. We might need pagevec per node but it seem to be overkill 
as you mentioned.

Feel free to add my reviewed-by sign when you resend.
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

> test wich activate_page heavily used, activate_page_drain_cpu overhead is quite
> small. This isn't worthy IMO.

> 
> Thanks,
> Shaohua

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
