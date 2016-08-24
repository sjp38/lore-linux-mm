Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 109C66B0038
	for <linux-mm@kvack.org>; Wed, 24 Aug 2016 00:31:48 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id g62so3959366ith.3
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 21:31:48 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id 80si4930610otg.252.2016.08.23.21.31.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 Aug 2016 21:31:42 -0700 (PDT)
Message-ID: <57BD2156.3070202@huawei.com>
Date: Wed, 24 Aug 2016 12:23:50 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: page should be aligned with max_order
References: <1471961400-1536-1-git-send-email-zhongjiang@huawei.com> <f7690e60-33d4-5fd9-f542-f62a97fef8d2@suse.cz>
In-Reply-To: <f7690e60-33d4-5fd9-f542-f62a97fef8d2@suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org

On 2016/8/24 0:56, Vlastimil Babka wrote:
> On 23.8.2016 16:10, zhongjiang wrote:
>> From: zhong jiang <zhongjiang@huawei.com>
>>
>> At present, page aligned with MAX_ORDER make no sense.
> Is it a bug that manifests... how?
  it is not bug.  Just a little confused.
  According to the commit da2041 (mm/page_alloc: prevent merging between isolated and other pageblocks)
  it prevent the mix between the isolate and other page block.  because it will lead to other blocks
  account increase in the end when mixed block is freed. is it right ?

  In addtion, The changelog points to buddies can be left unmerged can be  fixed by change the max_order to MAX_ORDER.
  how does it work ?  or I miss the point you want to  express. because I do not think that the change can solve the issue.
> Does it make more sense with max_order? why?
  I think we should limit the page_idx to two pageblock size. so it can merge the pageblock.
> I think we could just drop the page_idx masking and use pfn directly.
> __find_buddy_index() only looks at the 1 << order bit. Then there are operations
> such as (buddy_idx & page_idx) and (combined_idx - page_idx),
> none of these should care about the bits higher than MAX_ORDER/max_order as the
> subtraction cancels them out. That's also why the "mistake" you point out
> doesn't result in a bug IMHO.
  yes , I agree. 

  Thanks
   zhongjiang
>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>> ---
>>  mm/page_alloc.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index ff726f94..a178b1d 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -786,7 +786,7 @@ static inline void __free_one_page(struct page *page,
>>  	if (likely(!is_migrate_isolate(migratetype)))
>>  		__mod_zone_freepage_state(zone, 1 << order, migratetype);
>>  
>> -	page_idx = pfn & ((1 << MAX_ORDER) - 1);
>> +	page_idx = pfn & ((1 << max_order) - 1);
>>  
>>  	VM_BUG_ON_PAGE(page_idx & ((1 << order) - 1), page);
>>  	VM_BUG_ON_PAGE(bad_range(zone, page), page);
>>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
