Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 5A11E6B0256
	for <linux-mm@kvack.org>; Sun,  6 Mar 2016 23:39:56 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id 129so28230671pfw.1
        for <linux-mm@kvack.org>; Sun, 06 Mar 2016 20:39:56 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id q75si26012099pfq.207.2016.03.06.20.39.54
        for <linux-mm@kvack.org>;
        Sun, 06 Mar 2016 20:39:55 -0800 (PST)
Date: Mon, 7 Mar 2016 13:40:31 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: Suspicious error for CMA stress test
Message-ID: <20160307044031.GC24602@js1304-P5Q-DELUXE>
References: <56D6F008.1050600@huawei.com>
 <56D79284.3030009@redhat.com>
 <CAAmzW4PUwoVF+F-BpOZUHhH6YHp_Z8VkiUjdBq85vK6AWVkyPg@mail.gmail.com>
 <56D832BD.5080305@huawei.com>
 <20160304020232.GA12036@js1304-P5Q-DELUXE>
 <56D9325B.9060709@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <56D9325B.9060709@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hanjun Guo <guohanjun@huawei.com>
Cc: Laura Abbott <labbott@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <lauraa@codeaurora.org>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, "thunder.leizhen@huawei.com" <thunder.leizhen@huawei.com>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Mar 04, 2016 at 02:59:39PM +0800, Hanjun Guo wrote:
> On 2016/3/4 10:02, Joonsoo Kim wrote:
> > On Thu, Mar 03, 2016 at 08:49:01PM +0800, Hanjun Guo wrote:
> >> On 2016/3/3 15:42, Joonsoo Kim wrote:
> >>> 2016-03-03 10:25 GMT+09:00 Laura Abbott <labbott@redhat.com>:
> >>>> (cc -mm and Joonsoo Kim)
> >>>>
> >>>>
> >>>> On 03/02/2016 05:52 AM, Hanjun Guo wrote:
> >>>>> Hi,
> >>>>>
> >>>>> I came across a suspicious error for CMA stress test:
> >>>>>
> >>>>> Before the test, I got:
> >>>>> -bash-4.3# cat /proc/meminfo | grep Cma
> >>>>> CmaTotal:         204800 kB
> >>>>> CmaFree:          195044 kB
> >>>>>
> >>>>>
> >>>>> After running the test:
> >>>>> -bash-4.3# cat /proc/meminfo | grep Cma
> >>>>> CmaTotal:         204800 kB
> >>>>> CmaFree:         6602584 kB
> >>>>>
> >>>>> So the freed CMA memory is more than total..
> >>>>>
> >>>>> Also the the MemFree is more than mem total:
> >>>>>
> >>>>> -bash-4.3# cat /proc/meminfo
> >>>>> MemTotal:       16342016 kB
> >>>>> MemFree:        22367268 kB
> >>>>> MemAvailable:   22370528 kB
> >> [...]
> >>>> I played with this a bit and can see the same problem. The sanity
> >>>> check of CmaFree < CmaTotal generally triggers in
> >>>> __move_zone_freepage_state in unset_migratetype_isolate.
> >>>> This also seems to be present as far back as v4.0 which was the
> >>>> first version to have the updated accounting from Joonsoo.
> >>>> Were there known limitations with the new freepage accounting,
> >>>> Joonsoo?
> >>> I don't know. I also played with this and looks like there is
> >>> accounting problem, however, for my case, number of free page is slightly less
> >>> than total. I will take a look.
> >>>
> >>> Hanjun, could you tell me your malloc_size? I tested with 1 and it doesn't
> >>> look like your case.
> >> I tested with malloc_size with 2M, and it grows much bigger than 1M, also I
> >> did some other test:
> > Thanks! Now, I can re-generate erronous situation you mentioned.
> >
> >>  - run with single thread with 100000 times, everything is fine.
> >>
> >>  - I hack the cam_alloc() and free as below [1] to see if it's lock issue, with
> >>    the same test with 100 multi-thread, then I got:
> > [1] would not be sufficient to close this race.
> >
> > Try following things [A]. And, for more accurate test, I changed code a bit more
> > to prevent kernel page allocation from cma area [B]. This will prevent kernel
> > page allocation from cma area completely so we can focus cma_alloc/release race.
> >
> > Although, this is not correct fix, it could help that we can guess
> > where the problem is.
> >
> > Thanks.
> >
> > [A]
> > diff --git a/mm/cma.c b/mm/cma.c
> > index c003274..43ed02d 100644
> > --- a/mm/cma.c
> > +++ b/mm/cma.c
> > @@ -496,7 +496,9 @@ bool cma_release(struct cma *cma, const struct page *pages, unsigned int count)
> >  
> >         VM_BUG_ON(pfn + count > cma->base_pfn + cma->count);
> >  
> > +       mutex_lock(&cma_mutex);
> >         free_contig_range(pfn, count);
> > +       mutex_unlock(&cma_mutex);
> >         cma_clear_bitmap(cma, pfn, count);
> >         trace_cma_release(pfn, pages, count);
> >  
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index c6c38ed..1ce8a59 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2192,7 +2192,8 @@ void free_hot_cold_page(struct page *page, bool cold)
> >          * excessively into the page allocator
> >          */
> >         if (migratetype >= MIGRATE_PCPTYPES) {
> > -               if (unlikely(is_migrate_isolate(migratetype))) {
> > +               if (is_migrate_cma(migratetype) ||
> > +                       unlikely(is_migrate_isolate(migratetype))) {
> >                         free_one_page(zone, page, pfn, 0, migratetype);
> >                         goto out;
> >                 }
> 
> As I replied in previous email, the solution will fix the problem, the Cma freed memory and
> system freed memory is in sane state after apply above patch.
> 
> I also tested this situation which only apply the code below:
> 
>         if (migratetype >= MIGRATE_PCPTYPES) {
> -               if (unlikely(is_migrate_isolate(migratetype))) {
> +               if (is_migrate_cma(migratetype) ||
> +                       unlikely(is_migrate_isolate(migratetype))) {
>                         free_one_page(zone, page, pfn, 0, migratetype);
>                         goto out;
>                 }
> 
> 
> This will not fix the problem, but will reduce the errorous freed number of memory,
> hope this helps.
> 
> >
> >
> > [B]
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index f2dccf9..c6c38ed 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1493,6 +1493,7 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
> >                                                                 int alloc_flags)
> >  {
> >         int i;
> > +       bool cma = false;
> >  
> >         for (i = 0; i < (1 << order); i++) {
> >                 struct page *p = page + i;
> > @@ -1500,6 +1501,9 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
> >                         return 1;
> >         }
> >  
> > +       if (is_migrate_cma(get_pcppage_migratetype(page)))
> > +               cma = true;
> > +
> >         set_page_private(page, 0);
> >         set_page_refcounted(page);
> >  
> > @@ -1528,6 +1532,12 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
> >         else
> >                 clear_page_pfmemalloc(page);
> >  
> > +       if (cma) {
> > +               page_ref_dec(page);
> 
> mm/page_alloc.c: In function a??prep_new_pagea??:
> mm/page_alloc.c:1407:3: error: implicit declaration of function a??page_ref_deca?? [-Werror=implicit-function-declaration]
>    page_ref_dec(page);
>    ^

I tested with linux-next and there is new mechanism to manipulate page
reference count and this is that. You can have same effect with
atomic_dec(&page->_count) in mainline kernel.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
