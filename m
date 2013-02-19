Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id C80E06B0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 03:32:47 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id rr4so2110814pbb.13
        for <linux-mm@kvack.org>; Tue, 19 Feb 2013 00:32:46 -0800 (PST)
Message-ID: <512338A6.1030602@gmail.com>
Date: Tue, 19 Feb 2013 16:32:38 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: Re: Should a swapped out page be deleted from swap cache?
References: <CAFNq8R4UYvygk8+X+NZgyGjgU5vBsEv1UM6MiUxah6iW8=0HrQ@mail.gmail.com> <alpine.LNX.2.00.1302180939200.2246@eggly.anvils>
In-Reply-To: <alpine.LNX.2.00.1302180939200.2246@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Li Haifeng <omycle@gmail.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/19/2013 02:06 AM, Hugh Dickins wrote:
> On Mon, 18 Feb 2013, Li Haifeng wrote:
>
>> For explain my question, the two points should be displayed as below.
>>
>> 1.  If an anonymous page is swapped out, this page will be deleted
>> from swap cache and be put back into buddy system.
> Yes, unless the page is referenced again before it comes to be
> deleted from swap cache.
>
>> 2. When a page is swapped out, the sharing count of swap slot must not
>> be zero. That is, page_swapcount(page) will not return zero.
> I would not say "must not": we just prefer not to waste time on swapping
> a page out if its use count has already gone to 0.  And its use count
> might go down to 0 an instant after swap_writepage() makes that check.
>
>> Are both of them above right?
>>
>> According the two points above, I was confused to the line 655 below.
>> When a page is swapped out, the return value of page_swapcount(page)
>> will not be zero. So, the page couldn't be deleted from swap cache.
> Yes, we cannot free the swap as long as its data might be needed again.
>
> But a swap cache page may linger in memory for an indefinite time,
> in between being queued for write out, and actually being freed from
> the end of the lru by memory pressure.
>
> At various points where we hold the page lock on a swap cache page,
> it's worth checking whether it is still actually needed, or could
> now be freed from swap cache, and the corresponding swap slot freed:
> that's what try_to_free_swap() does.

Hi Hugh,

There is a call of try_to_free_swap in function swap_writepage, if 
swap_writepage is call from shrink_page_list path, PageSwapCache(page) 
== trure, PageWriteback(page) maybe false, page_swapcount(page) == 0, 
then will delete the page from swap cache and free swap slot, where I miss?

>
> Hugh
>
>>   644  * If swap is getting full, or if there are no more mappings of this page,
>>   645  * then try_to_free_swap is called to free its swap space.
>>   646  */
>>   647 int try_to_free_swap(struct page *page)
>>   648 {
>>   649         VM_BUG_ON(!PageLocked(page));
>>   650
>>   651         if (!PageSwapCache(page))
>>   652                 return 0;
>>   653         if (PageWriteback(page))
>>   654                 return 0;
>>   655         if (page_swapcount(page))//Has referenced by other swap out page.
>>   656                 return 0;
>>   657
>>   658         /*
>>   659          * Once hibernation has begun to create its image of memory,
>>   660          * there's a danger that one of the calls to try_to_free_swap()
>>   661          * - most probably a call from __try_to_reclaim_swap() while
>>   662          * hibernation is allocating its own swap pages for the image,
>>   663          * but conceivably even a call from memory reclaim - will free
>>   664          * the swap from a page which has already been recorded in the
>>   665          * image as a clean swapcache page, and then reuse its swap for
>>   666          * another page of the image.  On waking from hibernation, the
>>   667          * original page might be freed under memory pressure, then
>>   668          * later read back in from swap, now with the wrong data.
>>   669          *
>>   670          * Hibration suspends storage while it is writing the image
>>   671          * to disk so check that here.
>>   672          */
>>   673         if (pm_suspended_storage())
>>   674                 return 0;
>>   675
>>   676         delete_from_swap_cache(page);
>>   677         SetPageDirty(page);
>>   678         return 1;
>>   679 }
>>
>> Thanks.
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
