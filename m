Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 002636B0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2013 07:16:52 -0500 (EST)
Received: by mail-pb0-f66.google.com with SMTP id um15so2883344pbc.5
        for <linux-mm@kvack.org>; Wed, 20 Feb 2013 04:16:52 -0800 (PST)
Message-ID: <5124BEAE.6060801@gmail.com>
Date: Wed, 20 Feb 2013 20:16:46 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: Re: [patch] mm: shmem: use new radix tree iterator
References: <1359699238-7327-1-git-send-email-hannes@cmpxchg.org> <alpine.LNX.2.00.1302031759240.4120@eggly.anvils>
In-Reply-To: <alpine.LNX.2.00.1302031759240.4120@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Hugh,
On 02/04/2013 10:01 AM, Hugh Dickins wrote:
> On Fri, 1 Feb 2013, Johannes Weiner wrote:
>
>> In shmem_find_get_pages_and_swap, use the faster radix tree iterator
>> construct from 78c1d78 "radix-tree: introduce bit-optimized iterator".
>>
>> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Yes, that looks fine, and is testing out fine, thanks.
> Acked-by: Hugh Dickins <hughd@google.com>

Could you share your testcase with me? It seems that you always can test 
shmem patches.

>
>> ---
>>   mm/shmem.c | 25 ++++++++++++-------------
>>   1 file changed, 12 insertions(+), 13 deletions(-)
>>
>> diff --git a/mm/shmem.c b/mm/shmem.c
>> index a368a1c..c5dc8ae 100644
>> --- a/mm/shmem.c
>> +++ b/mm/shmem.c
>> @@ -336,19 +336,19 @@ static unsigned shmem_find_get_pages_and_swap(struct address_space *mapping,
>>   					pgoff_t start, unsigned int nr_pages,
>>   					struct page **pages, pgoff_t *indices)
>>   {
>> -	unsigned int i;
>> -	unsigned int ret;
>> -	unsigned int nr_found;
>> +	void **slot;
>> +	unsigned int ret = 0;
>> +	struct radix_tree_iter iter;
>> +
>> +	if (!nr_pages)
>> +		return 0;
>>   
>>   	rcu_read_lock();
>>   restart:
>> -	nr_found = radix_tree_gang_lookup_slot(&mapping->page_tree,
>> -				(void ***)pages, indices, start, nr_pages);
>> -	ret = 0;
>> -	for (i = 0; i < nr_found; i++) {
>> +	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
>>   		struct page *page;
>>   repeat:
>> -		page = radix_tree_deref_slot((void **)pages[i]);
>> +		page = radix_tree_deref_slot(slot);
>>   		if (unlikely(!page))
>>   			continue;
>>   		if (radix_tree_exception(page)) {
>> @@ -365,17 +365,16 @@ static unsigned shmem_find_get_pages_and_swap(struct address_space *mapping,
>>   			goto repeat;
>>   
>>   		/* Has the page moved? */
>> -		if (unlikely(page != *((void **)pages[i]))) {
>> +		if (unlikely(page != *slot)) {
>>   			page_cache_release(page);
>>   			goto repeat;
>>   		}
>>   export:
>> -		indices[ret] = indices[i];
>> +		indices[ret] = iter.index;
>>   		pages[ret] = page;
>> -		ret++;
>> +		if (++ret == nr_pages)
>> +			break;
>>   	}
>> -	if (unlikely(!ret && nr_found))
>> -		goto restart;
>>   	rcu_read_unlock();
>>   	return ret;
>>   }
>> -- 
>> 1.7.11.7
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
