Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 77C2B6B006C
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 18:46:17 -0500 (EST)
Date: Tue, 20 Nov 2012 08:46:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 4/5] mm, highmem: makes flush_all_zero_pkmaps() return
 index of first flushed entry
Message-ID: <20121119234619.GB447@bbox>
References: <1351702597-10795-1-git-send-email-js1304@gmail.com>
 <1351702597-10795-5-git-send-email-js1304@gmail.com>
 <20121101050347.GD24883@bbox>
 <CAAmzW4P=YdFt9KFmHcQh=tJheuZuvZVojYGNTqfO4YDy+C8_1g@mail.gmail.com>
 <20121102224236.GB2070@barrios>
 <CAAmzW4MoXExAMxxJTGehBEY76nUjkSsJ66L0C+sZsnAQANA+Lw@mail.gmail.com>
 <20121113124937.GA4360@barrios>
 <CAAmzW4Oz6pAsF7cA6Q5Hvr3Md8dsZtaaX8k_HaJcP+9=iBb3nQ@mail.gmail.com>
 <20121113150159.GA5296@barrios>
 <CAAmzW4MxZYXCV3UqmPpCfzunLS5ufcqNOjeTSHABEyfTASTn=w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAmzW4MxZYXCV3UqmPpCfzunLS5ufcqNOjeTSHABEyfTASTn=w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Peter Zijlstra <a.p.zijlstra@chello.nl>

Hi Joonsoo,
Sorry for the delay.

On Thu, Nov 15, 2012 at 02:09:04AM +0900, JoonSoo Kim wrote:
> Hi, Minchan.
> 
> 2012/11/14 Minchan Kim <minchan@kernel.org>:
> > On Tue, Nov 13, 2012 at 11:12:28PM +0900, JoonSoo Kim wrote:
> >> 2012/11/13 Minchan Kim <minchan@kernel.org>:
> >> > On Tue, Nov 13, 2012 at 09:30:57AM +0900, JoonSoo Kim wrote:
> >> >> 2012/11/3 Minchan Kim <minchan@kernel.org>:
> >> >> > Hi Joonsoo,
> >> >> >
> >> >> > On Sat, Nov 03, 2012 at 04:07:25AM +0900, JoonSoo Kim wrote:
> >> >> >> Hello, Minchan.
> >> >> >>
> >> >> >> 2012/11/1 Minchan Kim <minchan@kernel.org>:
> >> >> >> > On Thu, Nov 01, 2012 at 01:56:36AM +0900, Joonsoo Kim wrote:
> >> >> >> >> In current code, after flush_all_zero_pkmaps() is invoked,
> >> >> >> >> then re-iterate all pkmaps. It can be optimized if flush_all_zero_pkmaps()
> >> >> >> >> return index of first flushed entry. With this index,
> >> >> >> >> we can immediately map highmem page to virtual address represented by index.
> >> >> >> >> So change return type of flush_all_zero_pkmaps()
> >> >> >> >> and return index of first flushed entry.
> >> >> >> >>
> >> >> >> >> Additionally, update last_pkmap_nr to this index.
> >> >> >> >> It is certain that entry which is below this index is occupied by other mapping,
> >> >> >> >> therefore updating last_pkmap_nr to this index is reasonable optimization.
> >> >> >> >>
> >> >> >> >> Cc: Mel Gorman <mel@csn.ul.ie>
> >> >> >> >> Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
> >> >> >> >> Cc: Minchan Kim <minchan@kernel.org>
> >> >> >> >> Signed-off-by: Joonsoo Kim <js1304@gmail.com>
> >> >> >> >>
> >> >> >> >> diff --git a/include/linux/highmem.h b/include/linux/highmem.h
> >> >> >> >> index ef788b5..97ad208 100644
> >> >> >> >> --- a/include/linux/highmem.h
> >> >> >> >> +++ b/include/linux/highmem.h
> >> >> >> >> @@ -32,6 +32,7 @@ static inline void invalidate_kernel_vmap_range(void *vaddr, int size)
> >> >> >> >>
> >> >> >> >>  #ifdef CONFIG_HIGHMEM
> >> >> >> >>  #include <asm/highmem.h>
> >> >> >> >> +#define PKMAP_INVALID_INDEX (LAST_PKMAP)
> >> >> >> >>
> >> >> >> >>  /* declarations for linux/mm/highmem.c */
> >> >> >> >>  unsigned int nr_free_highpages(void);
> >> >> >> >> diff --git a/mm/highmem.c b/mm/highmem.c
> >> >> >> >> index d98b0a9..b365f7b 100644
> >> >> >> >> --- a/mm/highmem.c
> >> >> >> >> +++ b/mm/highmem.c
> >> >> >> >> @@ -106,10 +106,10 @@ struct page *kmap_to_page(void *vaddr)
> >> >> >> >>       return virt_to_page(addr);
> >> >> >> >>  }
> >> >> >> >>
> >> >> >> >> -static void flush_all_zero_pkmaps(void)
> >> >> >> >> +static unsigned int flush_all_zero_pkmaps(void)
> >> >> >> >>  {
> >> >> >> >>       int i;
> >> >> >> >> -     int need_flush = 0;
> >> >> >> >> +     unsigned int index = PKMAP_INVALID_INDEX;
> >> >> >> >>
> >> >> >> >>       flush_cache_kmaps();
> >> >> >> >>
> >> >> >> >> @@ -141,10 +141,13 @@ static void flush_all_zero_pkmaps(void)
> >> >> >> >>                         &pkmap_page_table[i]);
> >> >> >> >>
> >> >> >> >>               set_page_address(page, NULL);
> >> >> >> >> -             need_flush = 1;
> >> >> >> >> +             if (index == PKMAP_INVALID_INDEX)
> >> >> >> >> +                     index = i;
> >> >> >> >>       }
> >> >> >> >> -     if (need_flush)
> >> >> >> >> +     if (index != PKMAP_INVALID_INDEX)
> >> >> >> >>               flush_tlb_kernel_range(PKMAP_ADDR(0), PKMAP_ADDR(LAST_PKMAP));
> >> >> >> >> +
> >> >> >> >> +     return index;
> >> >> >> >>  }
> >> >> >> >>
> >> >> >> >>  /**
> >> >> >> >> @@ -152,14 +155,19 @@ static void flush_all_zero_pkmaps(void)
> >> >> >> >>   */
> >> >> >> >>  void kmap_flush_unused(void)
> >> >> >> >>  {
> >> >> >> >> +     unsigned int index;
> >> >> >> >> +
> >> >> >> >>       lock_kmap();
> >> >> >> >> -     flush_all_zero_pkmaps();
> >> >> >> >> +     index = flush_all_zero_pkmaps();
> >> >> >> >> +     if (index != PKMAP_INVALID_INDEX && (index < last_pkmap_nr))
> >> >> >> >> +             last_pkmap_nr = index;
> >> >> >> >
> >> >> >> > I don't know how kmap_flush_unused is really fast path so how my nitpick
> >> >> >> > is effective. Anyway,
> >> >> >> > What problem happens if we do following as?
> >> >> >> >
> >> >> >> > lock()
> >> >> >> > index = flush_all_zero_pkmaps();
> >> >> >> > if (index != PKMAP_INVALID_INDEX)
> >> >> >> >         last_pkmap_nr = index;
> >> >> >> > unlock();
> >> >> >> >
> >> >> >> > Normally, last_pkmap_nr is increased with searching empty slot in
> >> >> >> > map_new_virtual. So I expect return value of flush_all_zero_pkmaps
> >> >> >> > in kmap_flush_unused normally become either less than last_pkmap_nr
> >> >> >> > or last_pkmap_nr + 1.
> >> >> >>
> >> >> >> There is a case that return value of kmap_flush_unused() is larger
> >> >> >> than last_pkmap_nr.
> >> >> >
> >> >> > I see but why it's problem? kmap_flush_unused returns larger value than
> >> >> > last_pkmap_nr means that there is no free slot at below the value.
> >> >> > So unconditional last_pkmap_nr update is vaild.
> >> >>
> >> >> I think that this is not true.
> >> >> Look at the slightly different example.
> >> >>
> >> >> Assume last_pkmap = 20 and index 1-9, 12-19 is kmapped. 10, 11 is kunmapped.
> >> >>
> >> >> do kmap_flush_unused() => flush index 10,11 => last_pkmap = 10;
> >> >> do kunmap() with index 17
> >> >> do kmap_flush_unused() => flush index 17 => last_pkmap = 17?
> >> >>
> >> >> In this case, unconditional last_pkmap_nr update skip one kunmapped index.
> >> >> So, conditional update is needed.
> >> >
> >> > Thanks for pouinting out, Joonsoo.
> >> > You're right. I misunderstood your flush_all_zero_pkmaps change.
> >> > As your change, flush_all_zero_pkmaps returns first *flushed* free slot index.
> >> > What's the benefit returning flushed flushed free slot index rather than free slot index?
> >>
> >> If flush_all_zero_pkmaps() return free slot index rather than first
> >> flushed free slot,
> >> we need another comparison like as 'if pkmap_count[i] == 0' and
> >> need another local variable for determining whether flush is occurred or not.
> >> I want to minimize these overhead and churning of the code, although
> >> they are negligible.
> >>
> >> > I think flush_all_zero_pkmaps should return first free slot because customer of
> >> > flush_all_zero_pkmaps doesn't care whether it's just flushed or not.
> >> > What he want is just free or not. In such case, we can remove above check and it makes
> >> > flusha_all_zero_pkmaps more intuitive.
> >>
> >> Yes, it is more intuitive, but as I mentioned above, it need another comparison,
> >> so with that, a benefit which prevent to re-iterate when there is no
> >> free slot, may be disappeared.
> >
> > If you're very keen on the performance, why do you have such code?
> > You can remove below branch if you were keen on the performance.
> >
> > diff --git a/mm/highmem.c b/mm/highmem.c
> > index c8be376..44a88dd 100644
> > --- a/mm/highmem.c
> > +++ b/mm/highmem.c
> > @@ -114,7 +114,7 @@ static unsigned int flush_all_zero_pkmaps(void)
> >
> >         flush_cache_kmaps();
> >
> > -       for (i = 0; i < LAST_PKMAP; i++) {
> > +       for (i = LAST_PKMAP - 1; i >= 0; i--) {
> >                 struct page *page;
> >
> >                 /*
> > @@ -141,8 +141,7 @@ static unsigned int flush_all_zero_pkmaps(void)
> >                 pte_clear(&init_mm, PKMAP_ADDR(i), &pkmap_page_table[i]);
> >
> >                 set_page_address(page, NULL);
> > -               if (index == PKMAP_INVALID_INDEX)
> > -                       index = i;
> > +               index = i;
> >         }
> >         if (index != PKMAP_INVALID_INDEX)
> >                 flush_tlb_kernel_range(PKMAP_ADDR(0), PKMAP_ADDR(LAST_PKMAP));
> >
> >
> > Anyway, if you have the concern of performance, Okay let's give up making code clear
> > although I didn't see any report about kmap perfomance. Instead, please consider above
> > optimization because you have already broken what you mentioned.
> > If we can't make function clear, another method for it is to add function comment. Please.
> 
> Yes, I also didn't see any report about kmap performance.
> By your reviewing comment, I eventually reach that this patch will not
> give any benefit.
> So how about to drop it?

Personally, I prefer to proceed but if you don't have a confidence about gain,
No problem to drop it.
Thanks.

> 
> Thanks for review.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
