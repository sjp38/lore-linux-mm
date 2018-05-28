Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E20726B0008
	for <linux-mm@kvack.org>; Mon, 28 May 2018 12:03:50 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e20-v6so7606306pff.14
        for <linux-mm@kvack.org>; Mon, 28 May 2018 09:03:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h9-v6si8037304pgc.597.2018.05.28.09.03.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 May 2018 09:03:49 -0700 (PDT)
Subject: Re: [RFC PATCH 1/5] mm, slab/slub: introduce kmalloc-reclaimable
 caches
References: <20180524110011.1940-1-vbabka@suse.cz>
 <20180524110011.1940-2-vbabka@suse.cz>
 <0100016397ffdbf2-dc8a305f-efa8-4771-9f2a-3a7568693db4-000000@email.amazonses.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <99bb1e0c-15e2-7f8a-19ea-7cf9f49551b1@suse.cz>
Date: Mon, 28 May 2018 10:03:48 +0200
MIME-Version: 1.0
In-Reply-To: <0100016397ffdbf2-dc8a305f-efa8-4771-9f2a-3a7568693db4-000000@email.amazonses.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Vijayanand Jitta <vjitta@codeaurora.org>

On 05/25/2018 05:51 PM, Christopher Lameter wrote:
> On Thu, 24 May 2018, Vlastimil Babka wrote:
> 
>> diff --git a/include/linux/slab.h b/include/linux/slab.h
>> index 9ebe659bd4a5..5bff0571b360 100644
>> --- a/include/linux/slab.h
>> +++ b/include/linux/slab.h
>> @@ -296,11 +296,16 @@ static inline void __check_heap_object(const void *ptr, unsigned long n,
>>                                 (KMALLOC_MIN_SIZE) : 16)
>>
>>  #ifndef CONFIG_SLOB
>> -extern struct kmem_cache *kmalloc_caches[KMALLOC_SHIFT_HIGH + 1];
>> +extern struct kmem_cache *kmalloc_caches[2][KMALLOC_SHIFT_HIGH + 1];
>>  #ifdef CONFIG_ZONE_DMA
>>  extern struct kmem_cache *kmalloc_dma_caches[KMALLOC_SHIFT_HIGH + 1];
>>  #endif
> 
> In the existing code we used a different array name for the DMA caches.
> This is a similar situation.
> 
> I would suggest to use
> 
> kmalloc_reclaimable_caches[]
> 
> or make it consistent by folding the DMA caches into the array too (but
> then note the issues below).
> 
>> @@ -536,12 +541,13 @@ static __always_inline void *kmalloc(size_t size, gfp_t flags)
>>  #ifndef CONFIG_SLOB
>>  		if (!(flags & GFP_DMA)) {
>>  			unsigned int index = kmalloc_index(size);
>> +			unsigned int recl = kmalloc_reclaimable(flags);
> 
> This is a hotpath reserved for regular allocations. The reclaimable slabs
> need to be handled like the DMA slabs.  So check for GFP_DMA plus the
> reclaimable flags.

Yeah I thought that by doing reclaimable via array index manipulation
and not a branch, there would be no noticeable overhead. And GFP_DMA
should go away eventually. I will see if I can convert GFP_DMA to
another index, and completely remove the branch quoted above.

>> @@ -588,12 +594,13 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
>>  	if (__builtin_constant_p(size) &&
>>  		size <= KMALLOC_MAX_CACHE_SIZE && !(flags & GFP_DMA)) {
>>  		unsigned int i = kmalloc_index(size);
>> +		unsigned int recl = kmalloc_reclaimable(flags);
>>
> 
> 
> Same situation here and additional times below.
> 
