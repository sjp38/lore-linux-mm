Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id E90B66B0035
	for <linux-mm@kvack.org>; Wed,  3 Sep 2014 08:28:32 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id eu11so17176474pac.5
        for <linux-mm@kvack.org>; Wed, 03 Sep 2014 05:28:30 -0700 (PDT)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id f4si11029800pdj.69.2014.09.03.05.28.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 03 Sep 2014 05:28:29 -0700 (PDT)
Received: by mail-pd0-f174.google.com with SMTP id ft15so10913380pdb.5
        for <linux-mm@kvack.org>; Wed, 03 Sep 2014 05:28:27 -0700 (PDT)
Message-ID: <54065B77.5030507@gmail.com>
Date: Wed, 03 Sep 2014 08:06:15 +0800
From: Wang Sheng-Hui <shhuiw@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: reposition zbud page in lru list if not freed in
 zbud_free
References: <1409491769-10530-1-git-send-email-shhuiw@gmail.com> <20140902143936.GA11096@cerebellum.variantweb.net>
In-Reply-To: <20140902143936.GA11096@cerebellum.variantweb.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>
Cc: linux-mm@kvack.org



On 2014a1'09ae??02ae?JPY 22:39, Seth Jennings wrote:
> On Sun, Aug 31, 2014 at 09:29:29PM +0800, Wang Sheng-Hui wrote:
>> Reposition zbud page in the lru list of the pool if the zbud page
>> is not freed in zbud_free.
> 
> This doesn't mention what is wrong with the current code.  Afaict, the
> code is doing the right thing by not changing the position of the zpage
> in the LRU.  Why would we want to move a zpage to the front of the LRU
> just because one of the allocations it contains is freed?  The "age" of
> the other allocation is unchanged and its containing zpage should
> maintain its position in the LRU, right?
> 

Seth,

I have one question.

In zbud_reclaim_page, if one page contains handles not freed, then the page
is repositioned, in current code.

540                 } else if (zhdr->first_chunks == 0 ||
541                                 zhdr->last_chunks == 0) {
542                         /* add to unbuddied list */
543                         freechunks = num_free_chunks(zhdr);
544                         list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
545                 } else {
546                         /* add to buddied list */
547                         list_add(&zhdr->buddy, &pool->buddied);
548                 }
549
550                 /* add to beginning of LRU */
551                 list_add(&zhdr->lru, &pool->lru);

I want to why it is different for zbud_free?

Regards,
Sheng-Hui
> Thanks,
> Seth
> 
>>
>> Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
>> ---
>>  mm/zbud.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/zbud.c b/mm/zbud.c
>> index f26e7fc..b1d7777 100644
>> --- a/mm/zbud.c
>> +++ b/mm/zbud.c
>> @@ -432,15 +432,16 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
>>  	/* Remove from existing buddy list */
>>  	list_del(&zhdr->buddy);
>>  
>> +	list_del(&zhdr->lru);
>>  	if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
>>  		/* zbud page is empty, free */
>> -		list_del(&zhdr->lru);
>>  		free_zbud_page(zhdr);
>>  		pool->pages_nr--;
>>  	} else {
>>  		/* Add to unbuddied list */
>>  		freechunks = num_free_chunks(zhdr);
>>  		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
>> +		list_add(&zhdr->lru, &pool->lru);
>>  	}
>>  
>>  	spin_unlock(&pool->lock);
>> -- 
>> 1.8.3.2
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
