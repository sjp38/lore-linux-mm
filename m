Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 882796B02C3
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 07:50:08 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id m84so14546225qki.5
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 04:50:08 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id u9si987117qte.46.2017.08.08.04.50.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 04:50:07 -0700 (PDT)
Subject: Re: [v6 11/15] arm64/kasan: explicitly zero kasan shadow memory
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-12-git-send-email-pasha.tatashin@oracle.com>
 <20170808090743.GA12887@arm.com>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <f8b2b9ed-abf0-0c16-faa2-98b66dcbed78@oracle.com>
Date: Tue, 8 Aug 2017 07:49:22 -0400
MIME-Version: 1.0
In-Reply-To: <20170808090743.GA12887@arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, catalin.marinas@arm.com, sam@ravnborg.org

Hi Will,

Thank you for looking at this change. What you described was in my 
previous iterations of this project.

See for example here: https://lkml.org/lkml/2017/5/5/369

I was asked to remove that flag, and only zero memory in place when 
needed. Overall the current approach is better everywhere else in the 
kernel, but it adds a little extra code to kasan initialization.

Pasha

On 08/08/2017 05:07 AM, Will Deacon wrote:
> On Mon, Aug 07, 2017 at 04:38:45PM -0400, Pavel Tatashin wrote:
>> To optimize the performance of struct page initialization,
>> vmemmap_populate() will no longer zero memory.
>>
>> We must explicitly zero the memory that is allocated by vmemmap_populate()
>> for kasan, as this memory does not go through struct page initialization
>> path.
>>
>> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
>> Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
>> Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
>> Reviewed-by: Bob Picco <bob.picco@oracle.com>
>> ---
>>   arch/arm64/mm/kasan_init.c | 42 ++++++++++++++++++++++++++++++++++++++++++
>>   1 file changed, 42 insertions(+)
>>
>> diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
>> index 81f03959a4ab..e78a9ecbb687 100644
>> --- a/arch/arm64/mm/kasan_init.c
>> +++ b/arch/arm64/mm/kasan_init.c
>> @@ -135,6 +135,41 @@ static void __init clear_pgds(unsigned long start,
>>   		set_pgd(pgd_offset_k(start), __pgd(0));
>>   }
>>   
>> +/*
>> + * Memory that was allocated by vmemmap_populate is not zeroed, so we must
>> + * zero it here explicitly.
>> + */
>> +static void
>> +zero_vmemmap_populated_memory(void)
>> +{
>> +	struct memblock_region *reg;
>> +	u64 start, end;
>> +
>> +	for_each_memblock(memory, reg) {
>> +		start = __phys_to_virt(reg->base);
>> +		end = __phys_to_virt(reg->base + reg->size);
>> +
>> +		if (start >= end)
>> +			break;
>> +
>> +		start = (u64)kasan_mem_to_shadow((void *)start);
>> +		end = (u64)kasan_mem_to_shadow((void *)end);
>> +
>> +		/* Round to the start end of the mapped pages */
>> +		start = round_down(start, SWAPPER_BLOCK_SIZE);
>> +		end = round_up(end, SWAPPER_BLOCK_SIZE);
>> +		memset((void *)start, 0, end - start);
>> +	}
>> +
>> +	start = (u64)kasan_mem_to_shadow(_text);
>> +	end = (u64)kasan_mem_to_shadow(_end);
>> +
>> +	/* Round to the start end of the mapped pages */
>> +	start = round_down(start, SWAPPER_BLOCK_SIZE);
>> +	end = round_up(end, SWAPPER_BLOCK_SIZE);
>> +	memset((void *)start, 0, end - start);
>> +}
> 
> I can't help but think this would be an awful lot nicer if you made
> vmemmap_alloc_block take extra GFP flags as a parameter. That way, we could
> implement a version of vmemmap_populate that does the zeroing when we need
> it, without having to duplicate a bunch of the code like this. I think it
> would also be less error-prone, because you wouldn't have to do the
> allocation and the zeroing in two separate steps.
> 
> Will
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
