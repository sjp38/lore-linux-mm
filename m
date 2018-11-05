Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 85E076B0286
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 17:14:12 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id 69-v6so3151380ljs.4
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 14:14:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p10-v6sor5622286ljh.6.2018.11.05.14.14.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Nov 2018 14:14:10 -0800 (PST)
Subject: Re: [PATCH] slab.h: Avoid using & for logical and of booleans
References: <20181105204000.129023-1-bvanassche@acm.org>
 <20181105131305.574d85469f08a4b76592feb6@linux-foundation.org>
 <1541454489.196084.157.camel@acm.org>
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Message-ID: <ce6faf63-1661-abe5-16a6-8c19cc9f6689@rasmusvillemoes.dk>
Date: Mon, 5 Nov 2018 23:14:06 +0100
MIME-Version: 1.0
In-Reply-To: <1541454489.196084.157.camel@acm.org>
Content-Type: text/plain; charset=UTF-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <bvanassche@acm.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Christoph Lameter <cl@linux.com>, Roman Gushchin <guro@fb.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org

On 2018-11-05 22:48, Bart Van Assche wrote:
> On Mon, 2018-11-05 at 13:13 -0800, Andrew Morton wrote:
>> On Mon,  5 Nov 2018 12:40:00 -0800 Bart Van Assche <bvanassche@acm.org> wrote:
>>
>>> This patch suppresses the following sparse warning:
>>>
>>> ./include/linux/slab.h:332:43: warning: dubious: x & !y
>>>
>>> ...
>>>
>>> --- a/include/linux/slab.h
>>> +++ b/include/linux/slab.h
>>> @@ -329,7 +329,7 @@ static __always_inline enum kmalloc_cache_type kmalloc_type(gfp_t flags)
>>>  	 * If an allocation is both __GFP_DMA and __GFP_RECLAIMABLE, return
>>>  	 * KMALLOC_DMA and effectively ignore __GFP_RECLAIMABLE
>>>  	 */
>>> -	return type_dma + (is_reclaimable & !is_dma) * KMALLOC_RECLAIM;
>>> +	return type_dma + is_reclaimable * !is_dma * KMALLOC_RECLAIM;
>>>  }
>>>  
>>>  /*
>>
>> I suppose so.
>>
>> That function seems too clever for its own good :(.  I wonder if these
>> branch-avoiding tricks are really worthwhile.
> 
> From what I have seen in gcc disassembly it seems to me like gcc uses the
> cmov instruction to implement e.g. the ternary operator (?:). So I think none
> of the cleverness in kmalloc_type() is really necessary to avoid conditional
> branches. I think this function would become much more readable when using a
> switch statement or when rewriting it as follows (untested):
> 
>  static __always_inline enum kmalloc_cache_type kmalloc_type(gfp_t flags)
>  {
> -	int is_dma = 0;
> -	int type_dma = 0;
> -	int is_reclaimable;
> -
> -#ifdef CONFIG_ZONE_DMA
> -	is_dma = !!(flags & __GFP_DMA);
> -	type_dma = is_dma * KMALLOC_DMA;
> -#endif
> -
> -	is_reclaimable = !!(flags & __GFP_RECLAIMABLE);
> -
>  	/*
>  	 * If an allocation is both __GFP_DMA and __GFP_RECLAIMABLE, return
>  	 * KMALLOC_DMA and effectively ignore __GFP_RECLAIMABLE
>  	 */
> -	return type_dma + (is_reclaimable & !is_dma) * KMALLOC_RECLAIM;
> +	static const enum kmalloc_cache_type flags_to_type[2][2] = {
> +		{ 0,		KMALLOC_RECLAIM },
> +		{ KMALLOC_DMA,	KMALLOC_DMA },
> +	};
> +#ifdef CONFIG_ZONE_DMA
> +	bool is_dma = !!(flags & __GFP_DMA);
> +#endif
> +	bool is_reclaimable = !!(flags & __GFP_RECLAIMABLE);
> +
> +	return flags_to_type[is_dma][is_reclaimable];
>  }
> 

Won't that pessimize the cases where gfp is a constant to actually do
the table lookup, and add 16 bytes to every translation unit?

Another option is to add a fake KMALLOC_DMA_RECLAIM so the
kmalloc_caches[] array has size 4, then assign the same dma
kmalloc_cache pointer to [2][i] and [3][i] (so that costs perhaps a
dozen pointers in .data), and then just compute kmalloc_type() as

((flags & __GFP_RECLAIMABLE) >> someshift) | ((flags & __GFP_DMA) >>
someothershift).

Perhaps one could even shuffle the GFP flags so the two shifts are the same.

Rasmus
