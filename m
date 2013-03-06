Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id DA4406B0006
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 06:10:34 -0500 (EST)
Received: by mail-oa0-f50.google.com with SMTP id l20so12343201oag.37
        for <linux-mm@kvack.org>; Wed, 06 Mar 2013 03:10:33 -0800 (PST)
Message-ID: <51372423.3060709@gmail.com>
Date: Wed, 06 Mar 2013 19:10:27 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: Re: Should a swapped out page be deleted from swap cache?
References: <CAFNq8R4UYvygk8+X+NZgyGjgU5vBsEv1UM6MiUxah6iW8=0HrQ@mail.gmail.com> <alpine.LNX.2.00.1302180939200.2246@eggly.anvils> <512338A6.1030602@gmail.com> <alpine.LNX.2.00.1302191050330.2248@eggly.anvils> <51241B66.7080004@gmail.com> <CAFNq8R5ni4jKRsHJLyGiNPcj4epz8q5zva_0XEJrL1-uVZHb9w@mail.gmail.com> <513722AA.2030001@gmail.com>
In-Reply-To: <513722AA.2030001@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Haifeng <omycle@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/06/2013 07:04 PM, Ric Mason wrote:
> On 03/06/2013 01:34 PM, Li Haifeng wrote:
>> 2013/2/20 Ric Mason <ric.masonn@gmail.com>:
>>> Hi Hugh,
>>>
>>>
>>> On 02/20/2013 02:56 AM, Hugh Dickins wrote:
>>>> On Tue, 19 Feb 2013, Ric Mason wrote:
>>>>> There is a call of try_to_free_swap in function swap_writepage, if
>>>>> swap_writepage is call from shrink_page_list path, 
>>>>> PageSwapCache(page) ==
>>>>> trure, PageWriteback(page) maybe false, page_swapcount(page) == 0, 
>>>>> then
>>>>> will
>>>>> delete the page from swap cache and free swap slot, where I miss?
>>>> That's correct.  PageWriteback is sure to be false there. 
>>>> page_swapcount
>>>> usually won't be 0 there, but sometimes it will be, and in that 
>>>> case we
>>>> do want to delete from swap cache and free the swap slot.
>>>
>>> 1) If PageSwapCache(page)  == true, PageWriteback(page) == false,
>>> page_swapcount(page) == 0  in swap_writepage(shrink_page_list path), 
>>> then
>>> will delete the page from swap cache and free swap slot, in function
>>> swap_writepage:
>>>
>>> if (try_to_free_swap(page)) {
>>>      unlock_page(page);
>>>      goto out;
>>> }
>>> writeback will not execute, that's wrong. Where I miss?
>> when the page is deleted from swap cache and corresponding swap slot
>> is free, the page is set dirty. The dirty page won't be reclaimed. It
>> is not wrong.
>
> I don't think so. For dirty pages, there are two steps: 1)writeback 
> 2)reclaim. Since PageSwapCache(page) == true && PageWriteback(page) == 
> false && page_swapcount(page) == 0 in swap_writeback(), 
> try_to_free_swap() will return true and writeback will be skip. Then 
> how can step one be executed?

s/swap_writeback()/swap_writepage()

Btw, Hi Hugh, could you explain more to us? :-)

>
>>
>> corresponding path lists as below.
>> when swap_writepage() is called by pageout() in shrink_page_list().
>> pageout() will return PAGE_SUCCESS. For PAGE_SUCCESS, when
>> PageDirty(page) is true, this reclaiming page will be keeped in the
>> inactive LRU list.
>> shrink_page_list()
>> {
>> ...
>>   904                         switch (pageout(page, mapping, sc)) {
>>   905                         case PAGE_KEEP:
>>   906                                 nr_congested++;
>>   907                                 goto keep_locked;
>>   908                         case PAGE_ACTIVATE:
>>   909                                 goto activate_locked;
>>   910                         case PAGE_SUCCESS:
>>   911                                 if (PageWriteback(page))
>>   912                                         goto keep_lumpy;
>>   913                                 if (PageDirty(page))
>>   914                                         goto keep;
>> ...}
>>
>>> 2) In the function pageout, page will be set PG_Reclaim flag, since 
>>> this
>>> flag is set, end_swap_bio_write->end_page_writeback:
>>> if (TestClearPageReclaim(page))
>>>       rotate_reclaimable_page(page);
>>> it means that page will be add to the tail of lru list, page is clean
>>> anonymous page this time and will be reclaim to buddy system soon, 
>>> correct?
>> correct
>>> If is correct, what is the meaning of rotate here?
>> Rotating here is to add the page to the tail of inactive LRU list. So
>> this page will be reclaimed ASAP while reclaiming.
>>
>>>> Hugh
>>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
