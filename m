Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id EDCD6828E1
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 11:48:32 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id le9so93740399pab.0
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 08:48:32 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id w198si21007637pfd.144.2016.08.05.08.48.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 05 Aug 2016 08:48:32 -0700 (PDT)
Subject: Re: [PATCH] mm/vmalloc: fix align value calculation error
References: <57A2F6A3.9080908@zoho.com> <57A2FE7B.5070505@zoho.com>
 <20160804142421.576426492d629f0839298f9a@linux-foundation.org>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <fc045ecf-20fa-0722-b3ac-9a6140488fad@zoho.com>
Date: Fri, 5 Aug 2016 23:48:21 +0800
MIME-Version: 1.0
In-Reply-To: <20160804142421.576426492d629f0839298f9a@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: tj@kernel.org, hannes@cmpxchg.org, mhocko@kernel.org, minchan@kernel.org, zijun_hu@htc.com, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 2016/8/5 5:24, Andrew Morton wrote:
>>
>> it causes double align requirement for __get_vm_area_node() if parameter
>> size is power of 2 and VM_IOREMAP is set in parameter flags
>>
>> it is fixed by handling the specail case manually due to lack of
>> get_count_order() for long parameter
>>
>> ...
>>
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -1357,11 +1357,16 @@ static struct vm_struct *__get_vm_area_node(unsigned long size,
>>  {
>>  	struct vmap_area *va;
>>  	struct vm_struct *area;
>> +	int ioremap_size_order;
>>  
>>  	BUG_ON(in_interrupt());
>> -	if (flags & VM_IOREMAP)
>> -		align = 1ul << clamp_t(int, fls_long(size),
>> -				       PAGE_SHIFT, IOREMAP_MAX_ORDER);
>> +	if (flags & VM_IOREMAP) {
>> +		ioremap_size_order = fls_long(size);
>> +		if (is_power_of_2(size) && size != 1)
>> +			ioremap_size_order--;
>> +		align = 1ul << clamp_t(int, ioremap_size_order, PAGE_SHIFT,
>> +				IOREMAP_MAX_ORDER);
>> +	}
>>  
>>  	size = PAGE_ALIGN(size);
>>  	if (unlikely(!size))
> 
> I'm having trouble with this, and a more complete description would
> have helped!
> 
> As far as I can tell, the current code will decide the following:
> 
> size=0x10000: alignment=0x10000
> size=0x0f000: alignment=0x8000
> 

no, the current code doesn't achieve the above results as shown below
size=0x10000 -> fls_long(0x10000)=17 -> alignment=0x20000
size=0x0f000 -> fls_long(0x0f000)=16 -> alignment=0x10000
it is wrong for power of 2 value such as size=0x10000

> And your patch will change it so that
> 
> size=0x10000: alignment=0x8000
> size=0x0f000: alignment=0x8000
> 
> Correct?
>

no, my patch will results in the following calculations
size=0x10000: alignment=0x10000
size=0x0f000: alignment=0x10000

> If so, I'm struggling to see the sense in this.  Shouldn't we be
> changing things so that
> 
> size=0x10000: alignment=0x10000
> size=0x0f000: alignment=0x10000
> 
> ?
okay, it is the aim of my patch as explained above
i provide another solution as shown below
i appreciate it since it is more canonical
please help to review and apply it kindly
