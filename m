From: "George Spelvin" <linux@horizon.com>
Subject: Re: [PATCH v2 03/10] slab: move up code to get kmem_cache_node in free_block()
Date: 8 May 2014 15:24:05 -0400
Message-ID: <20140508192405.30677.qmail@ns.horizon.com>
References: <alpine.DEB.2.10.1405080850420.22626@gentwo.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.10.1405080850420.22626@gentwo.org>
Sender: linux-kernel-owner@vger.kernel.org
To: cl@linux.com, rientjes@google.com
Cc: iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@horizon.com
List-Id: linux-mm.kvack.org

>>> @@ -3362,17 +3359,12 @@ static void free_block(struct kmem_cache *cachep, void **objpp, int nr_objects,
>>>  		       int node)
>>>  {
>>>  	int i;
>>> -	struct kmem_cache_node *n;
>>> +	struct kmem_cache_node *n = cachep->node[node];
>>>
>>>  	for (i = 0; i < nr_objects; i++) {
>>> -		void *objp;
>>> -		struct page *page;
>>> -
>>> -		clear_obj_pfmemalloc(&objpp[i]);
>>> -		objp = objpp[i];
>>> +		void *objp = clear_obj_pfmemalloc(&objpp[i]);
>>> +		struct page *page = virt_to_head_page(objp);
>>>
>>> -		page = virt_to_head_page(objp);
>>> -		n = cachep->node[node];
>>>  		list_del(&page->lru);
>>>  		check_spinlock_acquired_node(cachep, node);
>>>  		slab_put_obj(cachep, page, objp, node);
>>
>> I think this unnecessarily obfuscates the code.

> It takes the lookup out of the loop. What does the obfuscation?

Taking the lookup of n out was the original cleanup patch; that part is
not my doing.

I changed clear_obj_pfmemalloc to return the modified pointer.
(As well as storing it back in version 1 which you quoted, instead of
storing it back in version 2.)
