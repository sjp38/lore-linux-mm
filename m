Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 222BA6B00FD
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 16:27:35 -0400 (EDT)
Message-ID: <4FE3830E.7050402@parallels.com>
Date: Fri, 22 Jun 2012 00:24:46 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] don't do __ClearPageSlab before freeing slab page.
References: <1340225959-1966-1-git-send-email-glommer@parallels.com> <1340225959-1966-5-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1206210103350.31077@chino.kir.corp.google.com> <4FE2D7B2.8060204@parallels.com> <4FE2FFDA.6000009@jp.fujitsu.com>
In-Reply-To: <4FE2FFDA.6000009@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, Cristoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Suleiman Souhlal <suleiman@google.com>

On 06/21/2012 03:04 PM, Kamezawa Hiroyuki wrote:
> (2012/06/21 17:13), Glauber Costa wrote:
>> On 06/21/2012 12:04 PM, David Rientjes wrote:
>>> On Thu, 21 Jun 2012, Glauber Costa wrote:
>>>
>>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>>> index 6092f33..fdec73e 100644
>>>> --- a/mm/page_alloc.c
>>>> +++ b/mm/page_alloc.c
>>>> @@ -698,8 +698,10 @@ static bool free_pages_prepare(struct page
>>>> *page, unsigned int order)
>>>>
>>>> if (PageAnon(page))
>>>> page->mapping = NULL;
>>>> - for (i = 0; i < (1 << order); i++)
>>>> + for (i = 0; i < (1 << order); i++) {
>>>> + __ClearPageSlab(page + i);
>>>> bad += free_pages_check(page + i);
>>>> + }
>>>> if (bad)
>>>> return false;
>>>>
>>>> @@ -2561,6 +2563,7 @@ EXPORT_SYMBOL(get_zeroed_page);
>>>> void __free_pages(struct page *page, unsigned int order)
>>>> {
>>>> if (put_page_testzero(page)) {
>>>> + __ClearPageSlab(page);
>>>> if (order == 0)
>>>> free_hot_cold_page(page, 0);
>>>> else
>>>
>>> These are called from a number of different places that has nothing
>>> to do
>>> with slab so it's certainly out of place here. Is there really no
>>> alternative way of doing this?
>>
>> Well, if the requirement is that we must handle this from the page
>> allocator, how else should I know if I must call the corresponding
>> free functions ?
>>
>> Also note that other bits are tested inside the page allocator as
>> well, such as MLock.
>>
>> I saw no other way, but if you have suggestions, I'd be open to try
>> them, of course.
>>
>
> I'm sorry I don't understand the logic enough well.
>
> Why check in __free_pages() is better than check in callers of
> slab.c/slub.c ?
>
> Thanks,
> -Kame
>

How would the slab people feel, specially Christoph, about a simple 
change in the caches, replacing free_pages and alloc_pages by common 
functions that calls the memcg correspondents when needed ?

It could even be done in a header file, and the change in the slab goes 
only as far as changing names in the call sites. (And maybe 
standardizing, because we have a mixture of free_pages and __free_pages 
around)

This would possibly render the __GFP_SLABMEMC not needed, since we'd 
have stable call sites for memcg to derive its context from.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
