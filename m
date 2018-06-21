Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 63EC96B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 23:47:04 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id m1-v6so669050pgr.3
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 20:47:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e188-v6sor1125017pfg.118.2018.06.20.20.47.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Jun 2018 20:47:03 -0700 (PDT)
Subject: Re: [PATCH] mm: mempool: Fix a possible sleep-in-atomic-context bug
 in mempool_resize()
References: <20180621030714.10368-1-baijiaju1990@gmail.com>
 <20180621033839.GB12608@bombadil.infradead.org>
From: Jia-Ju Bai <baijiaju1990@gmail.com>
Message-ID: <7a900944-5281-2e07-54f9-fc7574d2c538@gmail.com>
Date: Thu, 21 Jun 2018 11:46:33 +0800
MIME-Version: 1.0
In-Reply-To: <20180621033839.GB12608@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: akpm@linux-foundation.org, dvyukov@google.com, gregkh@linuxfoundation.org, jthumshirn@suse.de, pombredanne@nexb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 2018/6/21 11:38, Matthew Wilcox wrote:
> On Thu, Jun 21, 2018 at 11:07:14AM +0800, Jia-Ju Bai wrote:
>> The kernel may sleep with holding a spinlock.
>> The function call path (from bottom to top) in Linux-4.16.7 is:
>>
>> [FUNC] remove_element(GFP_KERNEL)
>> mm/mempool.c, 250: remove_element in mempool_resize
>> mm/mempool.c, 247: _raw_spin_lock_irqsave in mempool_resize
>>
>> To fix this bug, GFP_KERNEL is replaced with GFP_ATOMIC.
>>
>> This bug is found by my static analysis tool (DSAC-2) and checked by
>> my code review.
> But ... we don't use the flags argument.
>
> static void *remove_element(mempool_t *pool, gfp_t flags)
> {
>          void *element = pool->elements[--pool->curr_nr];
>
>          BUG_ON(pool->curr_nr < 0);
>          kasan_unpoison_element(pool, element, flags);
>          check_element(pool, element);
>          return element;
> }
>
> ...
>
> static void kasan_unpoison_element(mempool_t *pool, void *element, gfp_t flags)
> {
>          if (pool->alloc == mempool_alloc_slab || pool->alloc == mempool_kmalloc)
>                  kasan_unpoison_slab(element);
>          if (pool->alloc == mempool_alloc_pages)
>                  kasan_alloc_pages(element, (unsigned long)pool->pool_data);
> }
>
> So the correct patch would just remove this argument to remove_element() and
> kasan_unpoison_element()?

Yes, I also find this.
I can submit a patch that removes the flag in:
Definitions of kasan_unpoison_element() and remove_element()
Three calls to remove_element() and one call to kasan_unpoison_element() 
in mempool.c.

Do you think it is okay?


Best wishes,
Jia-Ju Bai
