Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id A2F6A6B0007
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 09:55:20 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id l13-v6so4275381qth.8
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 06:55:20 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id p16-v6si4096801qvo.24.2018.08.03.06.55.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Aug 2018 06:55:19 -0700 (PDT)
Subject: Re: [PATCH v2 4/9] dmapool: improve scalability of dma_pool_alloc
References: <1dbe6204-17fc-efd9-2381-48186cae2b94@cybernetics.com>
 <CAHp75Vdj_jcv3j2pNf4EnzasN9zCJ1f+2aWwT2f5GKG=yFAm4Q@mail.gmail.com>
From: Tony Battersby <tonyb@cybernetics.com>
Message-ID: <b304d118-8cca-594c-1321-bb65e39700e4@cybernetics.com>
Date: Fri, 3 Aug 2018 09:55:17 -0400
MIME-Version: 1.0
In-Reply-To: <CAHp75Vdj_jcv3j2pNf4EnzasN9zCJ1f+2aWwT2f5GKG=yFAm4Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, linux-scsi <linux-scsi@vger.kernel.org>, MPT-FusionLinux.pdl@broadcom.com

On 08/03/2018 05:02 AM, Andy Shevchenko wrote:
> On Thu, Aug 2, 2018 at 10:58 PM, Tony Battersby <tonyb@cybernetics.com> wrote:
>> dma_pool_alloc() scales poorly when allocating a large number of pages
>> because it does a linear scan of all previously-allocated pages before
>> allocating a new one.  Improve its scalability by maintaining a separate
>> list of pages that have free blocks ready to (re)allocate.  In big O
>> notation, this improves the algorithm from O(n^2) to O(n).
>>  struct dma_pool {              /* the pool */
>> +#define POOL_FULL_IDX   0
>> +#define POOL_AVAIL_IDX  1
>> +#define POOL_N_LISTS    2
>> +       struct list_head page_list[POOL_N_LISTS];
> To be consistent with naming scheme and common practice I would rather
> name the last one as
>
> POOL_MAX_IDX 2
OK.
>
>> +       INIT_LIST_HEAD(&retval->page_list[0]);
>> +       INIT_LIST_HEAD(&retval->page_list[1]);
> You introduced defines and don't use them.
>
Just a matter of style.A  In this context, it only matters that both
index 0 and 1 get initialized, not which index corresponds to which
list.A  But I suppose using the defines would improve keyword search, so
I'll change it.
