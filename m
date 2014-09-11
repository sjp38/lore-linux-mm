Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f174.google.com (mail-vc0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0B48D6B0096
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 08:50:28 -0400 (EDT)
Received: by mail-vc0-f174.google.com with SMTP id hy10so5717231vcb.19
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 05:50:27 -0700 (PDT)
Received: from mail-vc0-f177.google.com (mail-vc0-f177.google.com [209.85.220.177])
        by mx.google.com with ESMTPS id si3si270736vcb.92.2014.09.11.05.50.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 11 Sep 2014 05:50:26 -0700 (PDT)
Received: by mail-vc0-f177.google.com with SMTP id la4so3553547vcb.36
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 05:50:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140911123632.GA8296@cmpxchg.org>
References: <20140909131540.GA10568@cmpxchg.org> <CALq1K=LFd_MWYUMGhZxu4yb-u5WcDqb=DvY4N3P+wV0WO3Zq_g@mail.gmail.com>
 <20140911123632.GA8296@cmpxchg.org>
From: Leon Romanovsky <leon@leon.nu>
Date: Thu, 11 Sep 2014 15:50:06 +0300
Message-ID: <CALq1K=KYYXgtK5mRvBO_+Kdxt8nHmq-cquo1Qqj=UdB+TDrueA@mail.gmail.com>
Subject: Re: [patch resend] mm: page_alloc: fix zone allocation fairness on UP
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Sep 11, 2014 at 3:36 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Wed, Sep 10, 2014 at 07:32:20AM +0300, Leon Romanovsky wrote:
>> Hi Johaness,
>>
>>
>> On Tue, Sep 9, 2014 at 4:15 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
>>
>> > The zone allocation batches can easily underflow due to higher-order
>> > allocations or spills to remote nodes.  On SMP that's fine, because
>> > underflows are expected from concurrency and dealt with by returning
>> > 0.  But on UP, zone_page_state will just return a wrapped unsigned
>> > long, which will get past the <= 0 check and then consider the zone
>> > eligible until its watermarks are hit.
>> >
>> > 3a025760fc15 ("mm: page_alloc: spill to remote nodes before waking
>> > kswapd") already made the counter-resetting use atomic_long_read() to
>> > accomodate underflows from remote spills, but it didn't go all the way
>> > with it.  Make it clear that these batches are expected to go negative
>> > regardless of concurrency, and use atomic_long_read() everywhere.
>> >
>> > Fixes: 81c0a2bb515f ("mm: page_alloc: fair zone allocator policy")
>> > Reported-by: Vlastimil Babka <vbabka@suse.cz>
>> > Reported-by: Leon Romanovsky <leon@leon.nu>
>> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
>> > Acked-by: Mel Gorman <mgorman@suse.de>
>> > Cc: "3.12+" <stable@kernel.org>
>> > ---
>> >  mm/page_alloc.c | 7 +++----
>> >  1 file changed, 3 insertions(+), 4 deletions(-)
>> >
>> > Sorry I forgot to CC you, Leon.  Resend with updated Tags.
>> >
>> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> > index 18cee0d4c8a2..eee961958021 100644
>> > --- a/mm/page_alloc.c
>> > +++ b/mm/page_alloc.c
>> > @@ -1612,7 +1612,7 @@ again:
>> >         }
>> >
>> >         __mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
>> > -       if (zone_page_state(zone, NR_ALLOC_BATCH) == 0 &&
>> > +       if (atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]) <= 0 &&
>> >             !zone_is_fair_depleted(zone))
>> >                 zone_set_flag(zone, ZONE_FAIR_DEPLETED);
>> >
>> > @@ -5701,9 +5701,8 @@ static void __setup_per_zone_wmarks(void)
>> >                 zone->watermark[WMARK_HIGH] = min_wmark_pages(zone) + (tmp
>> > >> 1);
>> >
>> >                 __mod_zone_page_state(zone, NR_ALLOC_BATCH,
>> > -                                     high_wmark_pages(zone) -
>> > -                                     low_wmark_pages(zone) -
>> > -                                     zone_page_state(zone,
>> > NR_ALLOC_BATCH));
>> > +                       high_wmark_pages(zone) - low_wmark_pages(zone) -
>> > +                       atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]));
>> >
>> >                 setup_zone_migrate_reserve(zone);
>> >                 spin_unlock_irqrestore(&zone->lock, flags);
>> >
>>
>> I think the better way will be to apply Mel's patch
>> https://lkml.org/lkml/2014/9/8/214 which fix zone_page_state shadow casting
>> issue and convert all atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH])) to
>> zone_page__state(zone, NR_ALLOC_BATCH). This move will unify access to
>> vm_stat.
>
> It's not as simple.  The counter can go way negative and we need that
> negative number, not 0, to calculate the reset delta.  As I said in
> response to Mel's patch, we could make the vmstat API signed but I'm
> not convinced that is reasonable, given the 99% majority of usecases.
You are right, I missed that NR_ALLOC_BATCH is in use as a part of calculations
+                       high_wmark_pages(zone) - low_wmark_pages(zone) -
+                       atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]));
Sorry


-- 
Leon Romanovsky | Independent Linux Consultant
        www.leon.nu | leon@leon.nu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
