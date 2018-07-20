Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 80E316B0006
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 05:34:48 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id p7-v6so4435887eds.19
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 02:34:48 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y34-v6si1592013edy.425.2018.07.20.02.34.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 02:34:47 -0700 (PDT)
Subject: Re: [PATCH v3 2/7] mm, slab/slub: introduce kmalloc-reclaimable
 caches
References: <20180718133620.6205-1-vbabka@suse.cz>
 <20180718133620.6205-3-vbabka@suse.cz>
 <20180719082319.6jkltwinon3pyzyn@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <6981b5a7-470c-ab1d-99dd-23304d81358a@suse.cz>
Date: Fri, 20 Jul 2018 11:32:28 +0200
MIME-Version: 1.0
In-Reply-To: <20180719082319.6jkltwinon3pyzyn@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Matthew Wilcox <willy@infradead.org>

On 07/19/2018 10:23 AM, Mel Gorman wrote:
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
>> +	} else {
>> +		name = kmalloc_info[idx].name;
>> +	}
>> +
>> +	kmalloc_caches[type][idx] = create_kmalloc_cache(name,
>>  					kmalloc_info[idx].size, flags, 0,
>>  					kmalloc_info[idx].size);
>>  }
> 
> I was going to query that BUG_ON but if I'm reading it right, we just
> have to be careful in the future that the "normal" kmalloc cache is always
> initialised before the reclaimable cache or there will be issues.

Yeah, I was just copying how the dma-kmalloc code does it.

>> @@ -1122,22 +1133,25 @@ static void __init new_kmalloc_cache(int idx, slab_flags_t flags)
>>   */
>>  void __init create_kmalloc_caches(slab_flags_t flags)
>>  {
>> -	int i;
>> -	int type = KMALLOC_NORMAL;
>> +	int i, type;
>>  
>> -	for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++) {
>> -		if (!kmalloc_caches[type][i])
>> -			new_kmalloc_cache(i, flags);
>> +	for (type = KMALLOC_NORMAL; type <= KMALLOC_RECLAIM; type++) {
>> +		for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++) {
>> +			if (!kmalloc_caches[type][i])
>> +				new_kmalloc_cache(i, type, flags);
>>  
> 
> I don't see a problem here as such but the values of the KMALLOC_* types
> is important both for this function and the kmalloc_type(). It might be
> worth adding a warning that these functions be examined if updating the
> types but then again, anyone trying and getting it wrong will have a
> broken kernel so;

OK

> Acked-by: Mel Gorman <mgorman@techsingularity.net>

Thanks!
