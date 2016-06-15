Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 54AFA6B025E
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 05:52:30 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id wy7so6905375lbb.0
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 02:52:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l141si4187256wmg.20.2016.06.15.02.52.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Jun 2016 02:52:28 -0700 (PDT)
Subject: Re: [PATCH v2] mm/page_alloc: remove unnecessary order check in
 __alloc_pages_direct_compact
References: <1465983258-3726-1-git-send-email-opensource.ganesh@gmail.com>
 <CAKTCnzk1GZ+=ijvOm=Tw1GNGLdefovvS5wsR9XqpLLmrSSx9=g@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <16e37ddf-c28d-23ea-1216-d5a9c8a81b58@suse.cz>
Date: Wed, 15 Jun 2016 11:52:26 +0200
MIME-Version: 1.0
In-Reply-To: <CAKTCnzk1GZ+=ijvOm=Tw1GNGLdefovvS5wsR9XqpLLmrSSx9=g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, mhocko@suse.com, mina86@mina86.com, Minchan Kim <minchan@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

On 06/15/2016 11:40 AM, Balbir Singh wrote:
> On Wed, Jun 15, 2016 at 7:34 PM, Ganesh Mahendran
> <opensource.ganesh@gmail.com> wrote:
>> In the callee try_to_compact_pages(), the (order == 0) is checked,
>> so remove check in __alloc_pages_direct_compact.
>>
>> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
>> ---
>> v2:
>>   remove the check in __alloc_pages_direct_compact - Anshuman Khandual
>> ---
>>  mm/page_alloc.c | 3 ---
>>  1 file changed, 3 deletions(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index b9ea618..2f5a82a 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -3173,9 +3173,6 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>>         struct page *page;
>>         int contended_compaction;
>>
>> -       if (!order)
>> -               return NULL;
>> -
>>         current->flags |= PF_MEMALLOC;
>>         *compact_result = try_to_compact_pages(gfp_mask, order, alloc_flags, ac,
>>                                                 mode, &contended_compaction);
>
> What is the benefit of this. Is an if check more expensive than
> calling the function and returning from it? I don't feel strongly
> about such changes, but its good to audit the overall code for reading
> and performance.

Agree. The majority of calls should be for order == 0 where the check 
avoids us from modifying current->flags and calling into compaction.c 
just to return and modify the flags back. I would argue that we should 
even check order before calling __alloc_pages_direct_compact() to avoid 
another potential call, but the compiler might be doing the right thing 
already.

So v1 was better in this aspect. But it wouldn't gain us any measurable 
performance benefit anyway, so we might as well leave it.

> Balbir Singh
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
