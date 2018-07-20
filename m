Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4AC2D6B000A
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 05:37:24 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g11-v6so4280056edi.8
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 02:37:24 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u18-v6si1627327eda.251.2018.07.20.02.37.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 02:37:23 -0700 (PDT)
Subject: Re: [PATCH v3 2/7] mm, slab/slub: introduce kmalloc-reclaimable
 caches
References: <20180718133620.6205-1-vbabka@suse.cz>
 <20180718133620.6205-3-vbabka@suse.cz>
 <20180719181613.GA26595@castle.DHCP.thefacebook.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <32c05b49-6703-08c2-bacf-ee070082d5ae@suse.cz>
Date: Fri, 20 Jul 2018 11:35:04 +0200
MIME-Version: 1.0
In-Reply-To: <20180719181613.GA26595@castle.DHCP.thefacebook.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>

On 07/19/2018 08:16 PM, Roman Gushchin wrote:
>>  	is_dma = !!(flags & __GFP_DMA);
>>  #endif
>>  
>> -	return is_dma;
>> +	is_reclaimable = !!(flags & __GFP_RECLAIMABLE);
>> +
>> +	/*
>> +	 * If an allocation is botth __GFP_DMA and __GFP_RECLAIMABLE, return
>                                  ^^
> 			       typo
>> +	 * KMALLOC_DMA and effectively ignore __GFP_RECLAIMABLE
>> +	 */
>> +	return (is_dma * 2) + (is_reclaimable & !is_dma);
> 
> Maybe
> is_dma * KMALLOC_DMA + (is_reclaimable && !is_dma) * KMALLOC_RECLAIM
> looks better?

I think I meant to do that but forgot, thanks.

>>  }
>>  
>>  /*
>> diff --git a/mm/slab_common.c b/mm/slab_common.c
>> index 4614248ca381..614fb7ab8312 100644
>> --- a/mm/slab_common.c
>> +++ b/mm/slab_common.c
>> @@ -1107,10 +1107,21 @@ void __init setup_kmalloc_cache_index_table(void)
>>  	}
>>  }
>>  
>> -static void __init new_kmalloc_cache(int idx, slab_flags_t flags)
>> +static void __init
>> +new_kmalloc_cache(int idx, int type, slab_flags_t flags)
>>  {
>> -	kmalloc_caches[KMALLOC_NORMAL][idx] = create_kmalloc_cache(
>> -					kmalloc_info[idx].name,
>> +	const char *name;
>> +
>> +	if (type == KMALLOC_RECLAIM) {
>> +		flags |= SLAB_RECLAIM_ACCOUNT;
>> +		name = kasprintf(GFP_NOWAIT, "kmalloc-rcl-%u",
>> +						kmalloc_info[idx].size);
>> +		BUG_ON(!name);
> 
> I'd replace this with WARN_ON() and falling back to kmalloc_info[idx].name.

It's basically a copy/paste of the dma-kmalloc code. If that triggers,
it means somebody was changing the code and introduced a wrong order (as
Mel said). A system that genuinely has no memory for that printf at this
point, would not get very far anyway...

>> +	} else {
>> +		name = kmalloc_info[idx].name;
>> +	}
>> +
>> +	kmalloc_caches[type][idx] = create_kmalloc_cache(name,
>>  					kmalloc_info[idx].size, flags, 0,
>>  					kmalloc_info[idx].size);
>>  }
