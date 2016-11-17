Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id AFF616B0338
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 13:01:48 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id w132so131941712ita.1
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 10:01:48 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 66si3136127iox.230.2016.11.17.10.01.42
        for <linux-mm@kvack.org>;
        Thu, 17 Nov 2016 10:01:42 -0800 (PST)
Message-ID: <582DF05A.9050601@arm.com>
Date: Thu, 17 Nov 2016 18:00:58 +0000
From: James Morse <james.morse@arm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v27 1/9] memblock: add memblock_cap_memory_range()
References: <20161102044959.11954-1-takahiro.akashi@linaro.org> <20161102045153.12008-1-takahiro.akashi@linaro.org> <20161110172720.GB17134@arm.com> <20161111025049.GG381@linaro.org> <20161111031903.GB15997@arm.com> <20161114055515.GH381@linaro.org> <20161116163015.GM7928@arm.com> <20161117022023.GA5704@linaro.org> <20161117111917.GA22855@arm.com>
In-Reply-To: <20161117111917.GA22855@arm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>
Cc: Dennis Chen <dennis.chen@arm.com>, catalin.marinas@arm.com, akpm@linux-foundation.org, geoff@infradead.org, bauerman@linux.vnet.ibm.com, dyoung@redhat.com, mark.rutland@arm.com, kexec@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.orgnd@arm.com

Hi Will, Akashi,

On 17/11/16 11:19, Will Deacon wrote:
> It looks much better, thanks! Just one question below.
> 

> On Thu, Nov 17, 2016 at 02:34:24PM +0900, AKASHI Takahiro wrote:
>> diff --git a/mm/memblock.c b/mm/memblock.c
>> index 7608bc3..fea1688 100644
>> --- a/mm/memblock.c
>> +++ b/mm/memblock.c
>> @@ -1514,11 +1514,37 @@ void __init memblock_enforce_memory_limit(phys_addr_t limit)
>>  			      (phys_addr_t)ULLONG_MAX);
>>  }
>>  
>> +void __init memblock_cap_memory_range(phys_addr_t base, phys_addr_t size)
>> +{
>> +	int start_rgn, end_rgn;
>> +	int i, ret;
>> +
>> +	if (!size)
>> +		return;
>> +
>> +	ret = memblock_isolate_range(&memblock.memory, base, size,
>> +						&start_rgn, &end_rgn);
>> +	if (ret)
>> +		return;
>> +
>> +	/* remove all the MAP regions */
>> +	for (i = memblock.memory.cnt - 1; i >= end_rgn; i--)
>> +		if (!memblock_is_nomap(&memblock.memory.regions[i]))
>> +			memblock_remove_region(&memblock.memory, i);
> 
> In the case that we have only one, giant memblock that covers base all
> of base + size, can't we end up with start_rgn = end_rgn = 0? In which

Can this happen? If we only have one memblock that exactly spans
base:(base+size), memblock_isolate_range() will hit the '@rgn is fully
contained, record it' code and set start_rgn=0,end_rgn=1. (rbase==base,
rend==end). We only go round the loop once.

If we only have one memblock that is bigger than base:(base+size) we end up with
three regions, start_rgn=1,end_rgn=2. The trickery here is the '@rgn intersects
from above' code decreases the loop counter so we process the same entry twice,
hitting '@rgn is fully contained, record it' the second time round... so we go
round the loop four times.

I can't see how we hit the:
> 	if (rbase >= end)
> 		break;
> 	if (rend <= base)
> 		continue;

code in either case...



Thanks,

James


> case, we'd end up accidentally removing the map regions here.
> 
> The existing code:
> 
>> -	/* remove all the MAP regions above the limit */
>> -	for (i = end_rgn - 1; i >= start_rgn; i--) {
>> -		if (!memblock_is_nomap(&type->regions[i]))
>> -			memblock_remove_region(type, i);
>> -	}
> 
> seems to handle this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
