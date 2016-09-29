Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7B0B06B029E
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 07:29:30 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id p53so93857010qtp.0
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 04:29:30 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id e2si8515880qkc.69.2016.09.29.04.29.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 29 Sep 2016 04:29:29 -0700 (PDT)
Subject: Re: [RESEND PATCH 1/1] mm/percpu.c: correct max_distance calculation
 for pcpu_embed_first_chunk()
References: <7180d3c9-45d3-ffd2-cf8c-0d925f888a4d@zoho.com>
 <0310bf92-c8da-459f-58e3-40b8bfbb7223@zoho.com>
 <20160929103507.GA25170@mtj.duckdns.org>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <d17c5531-7a3b-7463-ba38-3a0eb8de0b84@zoho.com>
Date: Thu, 29 Sep 2016 19:29:12 +0800
MIME-Version: 1.0
In-Reply-To: <20160929103507.GA25170@mtj.duckdns.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: zijun_hu@htc.com, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, cl@linux.com

On 2016/9/29 18:35, Tejun Heo wrote:
> Hello,
> 
> On Sat, Sep 24, 2016 at 07:20:49AM +0800, zijun_hu wrote:
>> it is error to represent the max range max_distance spanned by all the
>> group areas as the offset of the highest group area plus unit size in
>> pcpu_embed_first_chunk(), it should equal to the offset plus the size
>> of the highest group area
>>
>> in order to fix this issue,let us find the highest group area who has the
>> biggest base address among all the ones, then max_distance is formed by
>> add it's offset and size value
> 
>  [PATCH] percpu: fix max_distance calculation in pcpu_embed_first_chunk()
> 
>  pcpu_embed_first_chunk() calculates the range a percpu chunk spans
>  into max_distance and uses it to ensure that a chunk is not too big
>  compared to the total vmalloc area.  However, during calculation, it
>  used incorrect top address by adding a unit size to the higest
>  group's base address.
> 
>  This can make the calculated max_distance slightly smaller than the
>  actual distance although given the scale of values involved the error
>  is very unlikely to have an actual impact.
> 
>  Fix this issue by adding the group's size instead of a unit size.
> 
>> the type of variant max_distance is changed from size_t to unsigned long
>> to prevent potential overflow
> 
> This doesn't make any sense.  All the values involved are valid
> addresses (or +1 of it), they can't overflow and size_t is the same
> size as ulong.
> 
>> @@ -2025,17 +2026,18 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
>>  	}
>>  
>>  	/* base address is now known, determine group base offsets */
>> -	max_distance = 0;
>> +	i = 0;
>>  	for (group = 0; group < ai->nr_groups; group++) {
>>  		ai->groups[group].base_offset = areas[group] - base;
>> -		max_distance = max_t(size_t, max_distance,
>> -				     ai->groups[group].base_offset);
>> +		if (areas[group] > areas[i])
>> +			i = group;
>>  	}
>> -	max_distance += ai->unit_size;
>> +	max_distance = ai->groups[i].base_offset +
>> +		(unsigned long)ai->unit_size * ai->groups[i].nr_units;
> 
> I don't think you need ulong cast here.
> 
> Thanks.
> 
okay, thanks for your reply
i will correct this in another patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
