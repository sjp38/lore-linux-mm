Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D6DCC6B006E
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 03:48:01 -0400 (EDT)
Message-ID: <4EAFA429.9060103@openvz.org>
Date: Tue, 01 Nov 2011 11:47:53 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add free_hot_cold_page_list helper
References: <20110729075837.12274.58405.stgit@localhost6>	<CAEwNFnBFNzrPoen-oM7DdB1QA5-cmUqAFABO7WxzZpiQacA7Fg@mail.gmail.com> <20111031131448.c6d6d458.akpm@linux-foundation.org>
In-Reply-To: <20111031131448.c6d6d458.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Andrew Morton wrote:
> On Mon, 29 Aug 2011 16:48:46 +0900
> Minchan Kim<minchan.kim@gmail.com>  wrote:
>
>> On Fri, Jul 29, 2011 at 4:58 PM, Konstantin Khlebnikov
>> <khlebnikov@openvz.org>  wrote:
>>> This patch adds helper free_hot_cold_page_list() to free list of 0-order pages.
>>> It frees pages directly from list without temporary page-vector.
>>> It also calls trace_mm_pagevec_free() to simulate pagevec_free() behaviour.
>>>
>>> bloat-o-meter:
>>>
>>> add/remove: 1/1 grow/shrink: 1/3 up/down: 267/-295 (-28)
>>> function                                     old     new   delta
>>> free_hot_cold_page_list                        -     264    +264
>>> get_page_from_freelist                      2129    2132      +3
>>>   pagevec_free                               243     239      -4
>>> split_free_page                              380     373      -7
>>> release_pages                                606     510     -96
>>> free_page_list                               188       -    -188
>>>
>>> Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
>>> ---
>>>   include/linux/gfp.h |    1 +
>>>   mm/page_alloc.c     |   12 ++++++++++++
>>>   mm/swap.c           |   14 +++-----------
>>>   mm/vmscan.c         |   20 +-------------------
>>>   4 files changed, 17 insertions(+), 30 deletions(-)
>>>
>>> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
>>> index cb40892..dd7b9cc 100644
>>> --- a/include/linux/gfp.h
>>> +++ b/include/linux/gfp.h
>>> @@ -358,6 +358,7 @@ void *alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask);
>>>   extern void  free_pages(struct page *page, unsigned int order);
>>>   extern void free_pages(unsigned long addr, unsigned int order);
>>>   extern void free_hot_cold_page(struct page *page, int cold);
>>> +extern void free_hot_cold_page_list(struct list_head *list, int cold);
>>>
>>>   #define  free_page(page)  free_pages((page), 0)
>>>   #define free_page(addr) free_pages((addr), 0)
>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>> index 1dbcf88..af486e4 100644
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -1209,6 +1209,18 @@ out:
>>>         local_irq_restore(flags);
>>>   }
>>>
>>> +void free_hot_cold_page_list(struct list_head *list, int cold)
>>> +{
>>> +       struct page *page, *next;
>>> +
>>> +       list_for_each_entry_safe(page, next, list, lru) {
>>> +               trace_mm_pagevec_free(page, cold);
>>
>>
>> I understand you want to minimize changes without breaking current ABI
>> with trace tools.
>> But apparently, It's not a pagvec_free. It just hurts readability.
>> As I take a look at the code, mm_pagevec_free isn't related to pagevec
>> but I guess it can represent 0-order pages free because 0-order pages
>> are freed only by pagevec until now.
>> So, how about renaming it with mm_page_free or mm_page_free_zero_order?
>> If you do, you need to do s/MM_PAGEVEC_FREE/MM_FREE_FREE/g in
>> trace-pagealloc-postprocess.pl.
>>
>>
>>> +               free_hot_cold_page(page, cold);
>>> +       }
>>> +
>>> +       INIT_LIST_HEAD(list);
>>
>> Why do we need it?
>
> My email has been horrid for a couple of months (fixed now), so I might
> have missed any reply to Minchin's review comments?
>

Sorry, I forget about this patch. v2 sended.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
