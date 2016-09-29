Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id D99796B0038
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 13:39:21 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id p135so79796262itb.2
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 10:39:21 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id b133si11866009iti.117.2016.09.29.10.38.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 29 Sep 2016 10:38:48 -0700 (PDT)
Subject: Re: [RFC PATCH 1/1] mm/percpu.c: fix potential memory leakage for
 pcpu_embed_first_chunk()
References: <d6742bae-1b32-10d8-1857-9993a2d06117@zoho.com>
 <20160929164422.GA3773@mtj.duckdns.org>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <b88da9b0-0964-8b42-7054-81605fe7eb85@zoho.com>
Date: Fri, 30 Sep 2016 01:38:35 +0800
MIME-Version: 1.0
In-Reply-To: <20160929164422.GA3773@mtj.duckdns.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: zijun_hu@htc.com, Andrew Morton <akpm@linux-foundation.org>, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2016/9/30 0:44, Tejun Heo wrote:
> Hello,
> 
> On Fri, Sep 30, 2016 at 12:03:20AM +0800, zijun_hu wrote:
>> From: zijun_hu <zijun_hu@htc.com>
>>
>> it will cause memory leakage for pcpu_embed_first_chunk() to go to
>> label @out_free if the chunk spans over 3/4 VMALLOC area. all memory
>> are allocated and recorded into array @areas for each CPU group, but
>> the memory allocated aren't be freed before returning after going to
>> label @out_free
>>
>> in order to fix this bug, we check chunk spanned area immediately
>> after completing memory allocation for all CPU group, we go to label
>> @out_free_areas other than @out_free to free all memory allocated if
>> the checking is failed.
>>
>> Signed-off-by: zijun_hu <zijun_hu@htc.com>
> ...
>> @@ -2000,6 +2001,21 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
>>  		areas[group] = ptr;
>>  
>>  		base = min(ptr, base);
>> +		if (ptr > areas[j])
>> +			j = group;
>> +	}
>> +	max_distance = areas[j] - base;
>> +	max_distance += ai->unit_size * ai->groups[j].nr_units;
>> +
>> +	/* warn if maximum distance is further than 75% of vmalloc space */
>> +	if (max_distance > VMALLOC_TOTAL * 3 / 4) {
>> +		pr_warn("max_distance=0x%lx too large for vmalloc space 0x%lx\n",
>> +				max_distance, VMALLOC_TOTAL);
>> +#ifdef CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK
>> +		/* and fail if we have fallback */
>> +		rc = -EINVAL;
>> +		goto out_free_areas;
>> +#endif
> 
> Isn't it way simpler to make the error path jump to out_free_areas?
> There's another similar case after pcpu_setup_first_chunk() failure
> too.  Also, can you please explain how you tested the changes?
> 
> Thanks.
> 
1) the simpler way don't work because it maybe free many memory block twice

let us take a CPU group as a example, after we allocate All memory
needed by a CPU group, we maybe free a unit memory block which
don't map to a available CPU, we maybe free a part of unit memory which 
we don't used too, you can refer to following code segments for detailed
info.
for (group = 0; group < ai->nr_groups; group++) {
	struct pcpu_group_info *gi = &ai->groups[group];
	void *ptr = areas[group];

	for (i = 0; i < gi->nr_units; i++, ptr += ai->unit_size) {
	if (gi->cpu_map[i] == NR_CPUS) {
				/* unused unit, free whole */
				free_fn(ptr, ai->unit_size);
				continue;
	}
	/* copy and return the unused part */
	memcpy(ptr, __per_cpu_load, ai->static_size);
	free_fn(ptr + size_sum, ai->unit_size - size_sum);
	}
}

2) as we seen, pcpu_setup_first_chunk() doesn't cause a failure, it  return 0
   always or panic by BUG_ON(), even if it fails, we can conclude the allocated
   memory based on information recorded by it, such as pcpu_base_addr and many of
   static variable, we can complete the free operations; but we can't if we
   fail in the case pointed by this patch

3) my test way is simple, i force "if (max_distance > VMALLOC_TOTAL * 3 / 4)"
   to if (1) and print which memory i allocate before the jumping, then print which memory
   i free after the jumping and before returning, then check whether i free the memory i 
   allocate in this function, the result is okay

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
