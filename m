Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id BB4B76B0096
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 04:16:18 -0400 (EDT)
Message-ID: <4FE2D7B2.8060204@parallels.com>
Date: Thu, 21 Jun 2012 12:13:38 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] don't do __ClearPageSlab before freeing slab page.
References: <1340225959-1966-1-git-send-email-glommer@parallels.com> <1340225959-1966-5-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1206210103350.31077@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1206210103350.31077@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, Cristoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Suleiman Souhlal <suleiman@google.com>

On 06/21/2012 12:04 PM, David Rientjes wrote:
> On Thu, 21 Jun 2012, Glauber Costa wrote:
>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 6092f33..fdec73e 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -698,8 +698,10 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
>>
>>   	if (PageAnon(page))
>>   		page->mapping = NULL;
>> -	for (i = 0; i < (1 << order); i++)
>> +	for (i = 0; i < (1 << order); i++) {
>> +		__ClearPageSlab(page + i);
>>   		bad += free_pages_check(page + i);
>> +	}
>>   	if (bad)
>>   		return false;
>>
>> @@ -2561,6 +2563,7 @@ EXPORT_SYMBOL(get_zeroed_page);
>>   void __free_pages(struct page *page, unsigned int order)
>>   {
>>   	if (put_page_testzero(page)) {
>> +		__ClearPageSlab(page);
>>   		if (order == 0)
>>   			free_hot_cold_page(page, 0);
>>   		else
>
> These are called from a number of different places that has nothing to do
> with slab so it's certainly out of place here.  Is there really no
> alternative way of doing this?

Well, if the requirement is that we must handle this from the page 
allocator, how else should I know if I must call the corresponding free 
functions ?

Also note that other bits are tested inside the page allocator as well, 
such as MLock.

I saw no other way, but if you have suggestions, I'd be open to try 
them, of course.

>> diff --git a/mm/slab.c b/mm/slab.c
>> index cb6da05..3e578fc 100644
>> --- a/mm/slab.c
>> +++ b/mm/slab.c
>> @@ -1821,11 +1821,6 @@ static void kmem_freepages(struct kmem_cache *cachep, void *addr)
>>   	else
>>   		sub_zone_page_state(page_zone(page),
>>   				NR_SLAB_UNRECLAIMABLE, nr_freed);
>> -	while (i--) {
>> -		BUG_ON(!PageSlab(page));
>> -		__ClearPageSlab(page);
>> -		page++;
>> -	}
>>   	if (current->reclaim_state)
>>   		current->reclaim_state->reclaimed_slab += nr_freed;
>>   	free_pages((unsigned long)addr, cachep->gfporder);
>
> And we lose this validation in slab.
>
> I'm hoping there's an alternative.
The validation can stay, if you would prefer. We still expect the page 
to be PageSlab at this point, so we can test for it, and only clear later.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
