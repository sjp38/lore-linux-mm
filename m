Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id F3DAC6B0038
	for <linux-mm@kvack.org>; Wed,  6 May 2015 03:55:40 -0400 (EDT)
Received: by wiun10 with SMTP id n10so12206230wiu.1
        for <linux-mm@kvack.org>; Wed, 06 May 2015 00:55:40 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ha1si863654wib.100.2015.05.06.00.55.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 06 May 2015 00:55:39 -0700 (PDT)
Message-ID: <5549C8FB.7080404@suse.cz>
Date: Wed, 06 May 2015 09:55:39 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v2] CMA: page_isolation: check buddy before access it
References: <1430732477-16977-1-git-send-email-zhuhui@xiaomi.com> <1430796179-1795-1-git-send-email-zhuhui@xiaomi.com> <20150506062801.GA12737@js1304-P5Q-DELUXE>
In-Reply-To: <20150506062801.GA12737@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hui Zhu <zhuhui@xiaomi.com>
Cc: akpm@linux-foundation.org, lauraa@codeaurora.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, teawater@gmail.com

On 6.5.2015 8:28, Joonsoo Kim wrote:
> On Tue, May 05, 2015 at 11:22:59AM +0800, Hui Zhu wrote:
>>
>> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
>> index 755a42c..eb22d1f 100644
>> --- a/mm/page_isolation.c
>> +++ b/mm/page_isolation.c
>> @@ -101,7 +101,8 @@ void unset_migratetype_isolate(struct page *page, unsigned migratetype)
>>  			buddy_idx = __find_buddy_index(page_idx, order);
>>  			buddy = page + (buddy_idx - page_idx);
>>  
>> -			if (!is_migrate_isolate_page(buddy)) {
>> +			if (!pfn_valid_within(page_to_pfn(buddy))
>> +			    || !is_migrate_isolate_page(buddy)) {
>>  				__isolate_free_page(page, order);
>>  				kernel_map_pages(page, (1 << order), 1);
>>  				set_page_refcounted(page);
> 
> Hello,
> 
> This isolation is for merging buddy pages. If buddy is not valid, we
> don't need to isolate page, because we can't merge them.
> I think that correct code would be:
> 
> pfn_valid_within(page_to_pfn(buddy)) &&
>         !is_migrate_isolate_page(buddy)
> 
> But, isolation and free here is safe operation so your code will work
> fine.

Ah damnit, you're right. But now you got me thinking about it more, and
paranoid... I thought I saw more bugs since the buddy might be in different zone
and we are not locking that zone, but then again it's probably fine, just very
tricky. Then I thought it could be simplified but then not again. Guess I'll
just run away fast :)

> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
