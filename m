Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 3D06C6B00E9
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 03:43:03 -0500 (EST)
Message-ID: <4F547C90.4040007@lge.com>
Date: Mon, 05 Mar 2012 17:42:56 +0900
From: Namhyung Kim <namhyung.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [PATCH -next] slub: set PG_slab on all of slab pages
References: <1330505674-31610-1-git-send-email-namhyung.kim@lge.com> <20120304103446.GA9267@barrios>
In-Reply-To: <20120304103446.GA9267@barrios>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Namhyung Kim <namhyung@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

2012-03-04 7:34 PM, Minchan Kim wrote:
> Hi Namhyung,
>

Hi Minchan,
glad to see you here again :)


> On Wed, Feb 29, 2012 at 05:54:34PM +0900, Namhyung Kim wrote:
>> Unlike SLAB, SLUB doesn't set PG_slab on tail pages, so if a user would
>> call free_pages() incorrectly on a object in a tail page, she will get
>> i confused with the undefined result. Setting the flag would help her by
>> emitting a warning on bad_page() in such a case.
>>
>> Reported-by: Sangseok Lee <sangseok.lee@lge.com>
>> Signed-off-by: Namhyung Kim <namhyung.kim@lge.com>
>
> I read this thread and I feel the we don't reach right point.
> I think it's not a compound page problem.
> We can face above problem where we allocates big order page without __GFP_COMP
> and free middle page of it.
>
> Fortunately, We can catch such a problem by put_page_testzero in __free_pages
> if you enable CONFIG_DEBUG_VM.
>
> Did you tried that with CONFIG_DEBUG_VM?
>

To be honest, I don't have a real test environment which brings this issue in 
the first place. On my simple test environment, enabling CONFIG_DEBUG_VM emits 
a bug when I tried to free middle of the slab pages. Thanks for pointing it out.

However I guess there was a chance to bypass that test anyhow since it did 
reach to __free_pages_ok(). If the page count was 0 already, free_pages() will 
prevent it from getting to the function even though CONFIG_DEBUG_VM was 
disabled. But I don't think it's a kernel bug - it seems entirely our fault :( 
I'll recheck and talk about it with my colleagues.

Thanks,
Namhyung


>> ---
>>   mm/slub.c |   12 ++++++++++--
>>   1 files changed, 10 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/slub.c b/mm/slub.c
>> index 33bab2aca882..575baacbec9b 100644
>> --- a/mm/slub.c
>> +++ b/mm/slub.c
>> @@ -1287,6 +1287,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
>>   	struct page *page;
>>   	struct kmem_cache_order_objects oo = s->oo;
>>   	gfp_t alloc_gfp;
>> +	int i;
>>
>>   	flags&= gfp_allowed_mask;
>>
>> @@ -1320,6 +1321,9 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
>>   	if (!page)
>>   		return NULL;
>>
>> +	for (i = 0; i<  1<<  oo_order(oo); i++)
>> +		__SetPageSlab(page + i);
>> +
>>   	if (kmemcheck_enabled
>>   		&&  !(s->flags&  (SLAB_NOTRACK | DEBUG_DEFAULT_FLAGS))) {
>>   		int pages = 1<<  oo_order(oo);
>> @@ -1369,7 +1373,6 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
>>
>>   	inc_slabs_node(s, page_to_nid(page), page->objects);
>>   	page->slab = s;
>> -	page->flags |= 1<<  PG_slab;
>>
>>   	start = page_address(page);
>>
>> @@ -1396,6 +1399,7 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
>>   {
>>   	int order = compound_order(page);
>>   	int pages = 1<<  order;
>> +	int i;
>>
>>   	if (kmem_cache_debug(s)) {
>>   		void *p;
>> @@ -1413,7 +1417,11 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
>>   		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
>>   		-pages);
>>
>> -	__ClearPageSlab(page);
>> +	for (i = 0; i<  pages; i++) {
>> +		BUG_ON(!PageSlab(page + i));
>> +		__ClearPageSlab(page + i);
>> +	}
>> +
>>   	reset_page_mapcount(page);
>>   	if (current->reclaim_state)
>>   		current->reclaim_state->reclaimed_slab += pages;
>> --
>> 1.7.9
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
>> Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
