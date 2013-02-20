Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 6E76C6B000A
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 21:57:13 -0500 (EST)
Received: by mail-ie0-f171.google.com with SMTP id 10so9459496ied.30
        for <linux-mm@kvack.org>; Tue, 19 Feb 2013 18:57:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <51237DDB.2050305@gmail.com>
References: <1359973626-3900-1-git-send-email-m.szyprowski@samsung.com>
	<20130204233430.GA2610@blaptop>
	<5110B05B.5070109@samsung.com>
	<51237DDB.2050305@gmail.com>
Date: Wed, 20 Feb 2013 11:57:12 +0900
Message-ID: <CAH9JG2V4+qXLMq5nbuN37nb4xrPB11L91q=2NKrVDautyyK2Bw@mail.gmail.com>
Subject: Re: [PATCH] mm: cma: fix accounting of CMA pages placed in high memory
From: Kyungmin Park <kmpark@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de

On Tue, Feb 19, 2013 at 10:27 PM, Simon Jeons <simon.jeons@gmail.com> wrote:
> On 02/05/2013 03:10 PM, Marek Szyprowski wrote:
>>
>> Hello,
>>
>> On 2/5/2013 12:34 AM, Minchan Kim wrote:
>>>
>>> On Mon, Feb 04, 2013 at 11:27:05AM +0100, Marek Szyprowski wrote:
>>> > The total number of low memory pages is determined as
>>> > totalram_pages - totalhigh_pages, so without this patch all CMA
>>> > pageblocks placed in highmem were accounted to low memory.
>>>
>>> So what's the end user effect? With the effect, we have to decide
>>> routing it on stable.
>>>
>>> >
>>> > Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
>>> > ---
>>> >  mm/page_alloc.c |    4 ++++
>>> >  1 file changed, 4 insertions(+)
>>> >
>>> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>> > index f5bab0a..6415d93 100644
>>> > --- a/mm/page_alloc.c
>>> > +++ b/mm/page_alloc.c
>>> > @@ -773,6 +773,10 @@ void __init init_cma_reserved_pageblock(struct
>>> > page *page)
>>> >      set_pageblock_migratetype(page, MIGRATE_CMA);
>>> >      __free_pages(page, pageblock_order);
>>> >      totalram_pages += pageblock_nr_pages;
>>> > +#ifdef CONFIG_HIGHMEM
>>>
>>> We don't need #ifdef/#endif.
>>
>>
>> #ifdef is required to let this code compile when highmem is not enabled,
>> becuase totalhigh_pages is defined as 0, see include/linux/highmem.h
>>
>
> Hi Marek,
>
> 1) Why can support CMA regions placed in highmem?
Some vendors use reserved memory at highmem, and it's hard to modify
to use lowmem, so just CMA can support highmem and no need to adjust
address used at reserved memory.
> CMA is for dma buffer, correct? Then how can old dma device access highmem?
What's the "old dma device"? To support it, we also modify
arch/arm/mm/dma-mapping.c for handling highmem address.

> 2) Why there is no totalhigh_pages variable define in the case of config
> highmem?
I don't know. it's just defined in case of highmem. that's reason to
use #ifdef/endif. we don't know hisotrical reason.

Thank you,
Kyungmin Park
>
>
>>> > +    if (PageHighMem(page))
>>> > +        totalhigh_pages += pageblock_nr_pages;
>>> > +#endif
>>> >  }
>>> >  #endif
>>> >
>>
>>
>> Best regards
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
