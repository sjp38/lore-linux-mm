Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id CF37D6B0273
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 15:56:16 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id i23-v6so2180242qtf.9
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 12:56:16 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id c56-v6si2194253qtc.342.2018.07.26.12.56.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 12:56:15 -0700 (PDT)
Subject: Re: [PATCH 1/3] dmapool: improve scalability of dma_pool_alloc
References: <15ff502d-d840-1003-6c45-bc17f0d81262@cybernetics.com>
 <CAHp75VcXVgAtUWY5yRBFg85C5NPN2BAFyAfAkPLkKq5+SsNHpg@mail.gmail.com>
From: Tony Battersby <tonyb@cybernetics.com>
Message-ID: <2a04ee8b-478d-39f1-09a0-1b2f8c6ee8c6@cybernetics.com>
Date: Thu, 26 Jul 2018 15:56:12 -0400
MIME-Version: 1.0
In-Reply-To: <CAHp75VcXVgAtUWY5yRBFg85C5NPN2BAFyAfAkPLkKq5+SsNHpg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Matthew Wilcox <willy@infradead.org>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, linux-scsi <linux-scsi@vger.kernel.org>, MPT-FusionLinux.pdl@broadcom.com

On 07/26/2018 03:37 PM, Andy Shevchenko wrote:
> On Thu, Jul 26, 2018 at 9:54 PM, Tony Battersby <tonyb@cybernetics.com> wrote:
>> dma_pool_alloc() scales poorly when allocating a large number of pages
>> because it does a linear scan of all previously-allocated pages before
>> allocating a new one.  Improve its scalability by maintaining a separate
>> list of pages that have free blocks ready to (re)allocate.  In big O
>> notation, this improves the algorithm from O(n^2) to O(n).
>
>
>>         spin_lock_irqsave(&pool->lock, flags);
>> -       list_for_each_entry(page, &pool->page_list, page_list) {
>> -               if (page->offset < pool->allocation)
>> -                       goto ready;
>> +       if (!list_empty(&pool->avail_page_list)) {
>> +               page = list_first_entry(&pool->avail_page_list,
>> +                                       struct dma_page,
>> +                                       avail_page_link);
>> +               goto ready;
>>         }
> It looks like
>
> page = list_first_entry_or_null();
> if (page)
>  goto ready;
>
> Though I don't know which one produces better code in the result.
>
> >From reader prospective of view I would go with my variant.

Thanks, I didn't know about list_first_entry_or_null().

>
>> +       /* This test checks if the page is already in avail_page_list. */
>> +       if (list_empty(&page->avail_page_link))
>> +               list_add(&page->avail_page_link, &pool->avail_page_list);
> How can you be sure that the page you are testing for is the first one?
>
> It seems you are relying on the fact that in the list should be either
> 0 or 1 page. In that case what's the point to have a list?
>
That would be true if the test were "if (list_empty(&pool->avail_page_list))".A  But it is testing the list pointers in the item rather than the list pointers in the pool.A  It may be a bit confusing if you have never seen that usage before, which is why I added a comment.A  Basically, if you use list_del_init() instead of list_del(), then you can use list_empty() on the item itself to test if the item is present in a list or not.A  For example, the comments in list.h warn not to use list_empty() on the entry after just list_del():

/**
 * list_del - deletes entry from list.
 * @entry: the element to delete from the list.
 * Note: list_empty() on entry does not return true after this, the entry is
 * in an undefined state.
 */
