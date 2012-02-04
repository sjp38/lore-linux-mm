Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 10DD96B002C
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 19:56:49 -0500 (EST)
Message-ID: <4F2C824E.8080501@intel.com>
Date: Sat, 04 Feb 2012 08:56:46 +0800
From: Alex Shi <alex.shi@intel.com>
MIME-Version: 1.0
Subject: Re: [rfc PATCH]slub: per cpu partial statistics change
References: <1328256695.12669.24.camel@debian> <alpine.DEB.2.00.1202030920060.2420@router.home>
In-Reply-To: <alpine.DEB.2.00.1202030920060.2420@router.home>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 02/03/2012 11:27 PM, Christoph Lameter wrote:

> On Fri, 3 Feb 2012, Alex,Shi wrote:
> 
>> This patch split the cpu_partial_free into 2 parts: cpu_partial_node, PCP refilling
>> times from node partial; and same name cpu_partial_free, PCP refilling times in
>> slab_free slow path. A new statistic 'release_cpu_partial' is added to get PCP
>> release times. These info are useful when do PCP tunning.
> 
> Releasing? The code where you inserted the new statistics counts the pages
> put on the cpu partial list when refilling from the node partial list.


Ops, are we talking the same base kernel: Linus' tree?  :)
Here the Releasing code only be called in slow free path and the PCP is
full at the same time, not in PCP refilling from node partial.

explanations more below.

> See more below.

>

>>  struct kmem_cache_cpu {
>> diff --git a/mm/slub.c b/mm/slub.c
>> index 4907563..5dd299c 100644
>> --- a/mm/slub.c
>> +++ b/mm/slub.c
>> @@ -1560,6 +1560,7 @@ static void *get_partial_node(struct kmem_cache *s,
>>  		} else {
>>  			page->freelist = t;
>>  			available = put_cpu_partial(s, page, 0);
>> +			stat(s, CPU_PARTIAL_NODE);
> 
> This is refilling the per cpu partial list from the node list.


Yes. and same as my explanation in patch:
-       CPU_PARTIAL_FREE,       /* USed cpu partial on free */
+       CPU_PARTIAL_FREE,       /* Refill cpu partial on free */
+       CPU_PARTIAL_NODE,       /* Refill cpu partial from node partial */

> 
>>  		}
>>  		if (kmem_cache_debug(s) || available > s->cpu_partial / 2)
>>  			break;
>> @@ -1973,6 +1974,7 @@ int put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
>>  				local_irq_restore(flags);
>>  				pobjects = 0;
>>  				pages = 0;
>> +				stat(s, RELEASE_CPU_PARTIAL);
> 
> The callers count the cpu partial operations. Why is there now one in
> put_cpu_partial? It is moving a page to the cpu partial list. Not
> releasing it from the cpu partial list.


All old PCP will drain out on running CPU by unfreeze_partials() even it
is not accurate here. The new one is not lost counting. It still be
counted as CPU_PARTIAL_FREE in the following change as before.

If release is right, maybe named as drain_cpu_partial or
unfreeze_cpu_partial?

> 
>>
>> @@ -2465,9 +2466,10 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
>>  		 * If we just froze the page then put it onto the
>>  		 * per cpu partial list.
>>  		 */
>> -		if (new.frozen && !was_frozen)
>> +		if (new.frozen && !was_frozen) {
>>  			put_cpu_partial(s, page, 1);
>> -
>> +			stat(s, CPU_PARTIAL_FREE);
> 
> cpu partial list filled with a partial page created from a fully allocated
> slab (which therefore was not on any list before).


Yes, but the counting is not new here. It just moved out of
put_cpu_partial().

> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
