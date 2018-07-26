Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3A7E86B026D
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 15:37:17 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id d134-v6so1070565vkf.5
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 12:37:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j203-v6sor849175vke.129.2018.07.26.12.37.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 26 Jul 2018 12:37:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <15ff502d-d840-1003-6c45-bc17f0d81262@cybernetics.com>
References: <15ff502d-d840-1003-6c45-bc17f0d81262@cybernetics.com>
From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Thu, 26 Jul 2018 22:37:15 +0300
Message-ID: <CAHp75VcXVgAtUWY5yRBFg85C5NPN2BAFyAfAkPLkKq5+SsNHpg@mail.gmail.com>
Subject: Re: [PATCH 1/3] dmapool: improve scalability of dma_pool_alloc
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Matthew Wilcox <willy@infradead.org>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, linux-scsi <linux-scsi@vger.kernel.org>, MPT-FusionLinux.pdl@broadcom.com

On Thu, Jul 26, 2018 at 9:54 PM, Tony Battersby <tonyb@cybernetics.com> wrote:
> dma_pool_alloc() scales poorly when allocating a large number of pages
> because it does a linear scan of all previously-allocated pages before
> allocating a new one.  Improve its scalability by maintaining a separate
> list of pages that have free blocks ready to (re)allocate.  In big O
> notation, this improves the algorithm from O(n^2) to O(n).



>         spin_lock_irqsave(&pool->lock, flags);
> -       list_for_each_entry(page, &pool->page_list, page_list) {
> -               if (page->offset < pool->allocation)
> -                       goto ready;

> +       if (!list_empty(&pool->avail_page_list)) {
> +               page = list_first_entry(&pool->avail_page_list,
> +                                       struct dma_page,
> +                                       avail_page_link);
> +               goto ready;
>         }

It looks like

page = list_first_entry_or_null();
if (page)
 goto ready;

Though I don't know which one produces better code in the result.

>From reader prospective of view I would go with my variant.


> +       /* This test checks if the page is already in avail_page_list. */
> +       if (list_empty(&page->avail_page_link))
> +               list_add(&page->avail_page_link, &pool->avail_page_list);

How can you be sure that the page you are testing for is the first one?

It seems you are relying on the fact that in the list should be either
0 or 1 page. In that case what's the point to have a list?

-- 
With Best Regards,
Andy Shevchenko
