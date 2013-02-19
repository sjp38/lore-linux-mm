Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id F01916B0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 08:28:02 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id un1so2237005pbc.40
        for <linux-mm@kvack.org>; Tue, 19 Feb 2013 05:28:02 -0800 (PST)
Message-ID: <51237DDB.2050305@gmail.com>
Date: Tue, 19 Feb 2013 21:27:55 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: cma: fix accounting of CMA pages placed in high memory
References: <1359973626-3900-1-git-send-email-m.szyprowski@samsung.com> <20130204233430.GA2610@blaptop> <5110B05B.5070109@samsung.com>
In-Reply-To: <5110B05B.5070109@samsung.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, kyungmin.park@samsung.com

On 02/05/2013 03:10 PM, Marek Szyprowski wrote:
> Hello,
>
> On 2/5/2013 12:34 AM, Minchan Kim wrote:
>> On Mon, Feb 04, 2013 at 11:27:05AM +0100, Marek Szyprowski wrote:
>> > The total number of low memory pages is determined as
>> > totalram_pages - totalhigh_pages, so without this patch all CMA
>> > pageblocks placed in highmem were accounted to low memory.
>>
>> So what's the end user effect? With the effect, we have to decide
>> routing it on stable.
>>
>> >
>> > Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
>> > ---
>> >  mm/page_alloc.c |    4 ++++
>> >  1 file changed, 4 insertions(+)
>> >
>> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> > index f5bab0a..6415d93 100644
>> > --- a/mm/page_alloc.c
>> > +++ b/mm/page_alloc.c
>> > @@ -773,6 +773,10 @@ void __init init_cma_reserved_pageblock(struct 
>> page *page)
>> >      set_pageblock_migratetype(page, MIGRATE_CMA);
>> >      __free_pages(page, pageblock_order);
>> >      totalram_pages += pageblock_nr_pages;
>> > +#ifdef CONFIG_HIGHMEM
>>
>> We don't need #ifdef/#endif.
>
> #ifdef is required to let this code compile when highmem is not enabled,
> becuase totalhigh_pages is defined as 0, see include/linux/highmem.h
>

Hi Marek,

1) Why can support CMA regions placed in highmem? CMA is for dma buffer, 
correct? Then how can old dma device access highmem?
2) Why there is no totalhigh_pages variable define in the case of config 
highmem?

>> > +    if (PageHighMem(page))
>> > +        totalhigh_pages += pageblock_nr_pages;
>> > +#endif
>> >  }
>> >  #endif
>> >
>
> Best regards

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
