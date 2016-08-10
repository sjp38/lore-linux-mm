Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C9F5E6B0005
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 01:33:17 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id o124so63798336pfg.1
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 22:33:17 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id m18si46631988pfg.123.2016.08.09.22.33.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 09 Aug 2016 22:33:16 -0700 (PDT)
Subject: Re: [PATCH] mm/vmalloc: fix align value calculation error
References: <57A2F6A3.9080908@zoho.com> <57A2FE7B.5070505@zoho.com>
 <20160804142421.576426492d629f0839298f9a@linux-foundation.org>
 <fc045ecf-20fa-0722-b3ac-9a6140488fad@zoho.com>
 <20160809142832.623dfdbf666c08b8fc8772d2@linux-foundation.org>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <57AABC8B.1040409@zoho.com>
Date: Wed, 10 Aug 2016 13:32:59 +0800
MIME-Version: 1.0
In-Reply-To: <20160809142832.623dfdbf666c08b8fc8772d2@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: tj@kernel.org, hannes@cmpxchg.org, mhocko@kernel.org, minchan@kernel.org, zijun_hu@htc.com, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 08/10/2016 05:28 AM, Andrew Morton wrote:
> On Fri, 5 Aug 2016 23:48:21 +0800 zijun_hu <zijun_hu@zoho.com> wrote:
> 
>> From: zijun_hu <zijun_hu@htc.com>
>> Date: Fri, 5 Aug 2016 22:10:07 +0800
>> Subject: [PATCH 1/1] mm/vmalloc: fix align value calculation error
>>
>> it causes double align requirement for __get_vm_area_node() if parameter
>> size is power of 2 and VM_IOREMAP is set in parameter flags
>>
>> get_order_long() is implemented and used instead of fls_long() for
>> fixing the bug
> 
> Makes sense.  I think.
> 
>> --- a/include/linux/bitops.h
>> +++ b/include/linux/bitops.h
>> @@ -192,6 +192,23 @@ static inline unsigned fls_long(unsigned long l)
>>  }
>>  
>>  /**
>> + * get_order_long - get order after rounding @l up to power of 2
>> + * @l: parameter
>> + *
>> + * it is same as get_count_order() but long type parameter
>> + * or 0 is returned if @l == 0UL
>> + */
>> +static inline int get_order_long(unsigned long l)
>> +{
>> +	if (l == 0UL)
>> +		return 0;
>> +	else if (l & (l - 1UL))
>> +		return fls_long(l);
>> +	else
>> +		return fls_long(l) - 1;
>> +}
>> +
>> +/**
>>   * __ffs64 - find first set bit in a 64 bit word
>>   * @word: The 64 bit word
>>   *
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index 91f44e7..7d717f3 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -1360,7 +1360,7 @@ static struct vm_struct *__get_vm_area_node(unsigned long size,
>>  
>>  	BUG_ON(in_interrupt());
>>  	if (flags & VM_IOREMAP)
>> -		align = 1ul << clamp_t(int, fls_long(size),
>> +		align = 1ul << clamp_t(int, get_order_long(size),
>>  				       PAGE_SHIFT, IOREMAP_MAX_ORDER);
>>  
>>  	size = PAGE_ALIGN(size);
> 
> It would be better to call this get_count_order_long(), I think?  To
> match get_count_order()?
> 
yes, i agree with you to correct function name

i provide another patch called v2 based on your suggestion as shown below
it have following correction against original patch v1
1) use name get_count_order_long() instead of get_order_long()
2) return -1 if @l == 0 to consist with get_order_long()
3) cast type to int before returning from get_count_order_long()
4) move up function parameter checking for __get_vm_area_node()
5) more commit message is offered to make issue and approach clear
any comments about new patch is welcome

this new patch called patch v2 is shown below
