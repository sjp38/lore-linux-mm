Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id AF9906B02C3
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 11:37:50 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id g75so113668716ywb.0
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 08:37:50 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id z124si948371ywd.143.2017.08.17.08.37.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 08:37:49 -0700 (PDT)
Subject: Re: [v6 01/15] x86/mm: reserve only exiting low pages
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-2-git-send-email-pasha.tatashin@oracle.com>
 <20170814135525.GN19063@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <5c39369d-c8a4-ceab-1845-6b36eabe7fca@oracle.com>
Date: Thu, 17 Aug 2017 11:37:11 -0400
MIME-Version: 1.0
In-Reply-To: <20170814135525.GN19063@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, "H. Peter Anvin" <hpa@zytor.com>

Hi Michal,

While working on a bug that was reported to me by "kernel test robot".

  unable to handle kernel NULL pointer dereference at           (null)

The issue was that page_to_pfn() on that configuration was looking for a 
section inside flags fields in "struct page". So, reserved but 
unavailable memory should have its "struct page" zeroed.

Therefore, I am going to remove this patch from my series, but instead 
have a new patch that iterates through:

reserved && !memory memblocks, and zeroes struct pages for them. Since 
for that memory struct pages will never go through __init_single_page(), 
yet some fields might still be accessed.

Pasha

On 08/14/2017 09:55 AM, Michal Hocko wrote:
> Let's CC Hpa on this one. I am still not sure it is correct. The full
> series is here
> http://lkml.kernel.org/r/1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com
> 
> On Mon 07-08-17 16:38:35, Pavel Tatashin wrote:
>> Struct pages are initialized by going through __init_single_page(). Since
>> the existing physical memory in memblock is represented in memblock.memory
>> list, struct page for every page from this list goes through
>> __init_single_page().
>>
>> The second memblock list: memblock.reserved, manages the allocated memory.
>> The memory that won't be available to kernel allocator. So, every page from
>> this list goes through reserve_bootmem_region(), where certain struct page
>> fields are set, the assumption being that the struct pages have been
>> initialized beforehand.
>>
>> In trim_low_memory_range() we unconditionally reserve memoryfrom PFN 0, but
>> memblock.memory might start at a later PFN. For example, in QEMU,
>> e820__memblock_setup() can use PFN 1 as the first PFN in memblock.memory,
>> so PFN 0 is not on memblock.memory (and hence isn't initialized via
>> __init_single_page) but is on memblock.reserved (and hence we set fields in
>> the uninitialized struct page).
>>
>> Currently, the struct page memory is always zeroed during allocation,
>> which prevents this problem from being detected. But, if some asserts
>> provided by CONFIG_DEBUG_VM_PGFLAGS are tighten, this problem may become
>> visible in existing kernels.
>>
>> In this patchset we will stop zeroing struct page memory during allocation.
>> Therefore, this bug must be fixed in order to avoid random assert failures
>> caused by CONFIG_DEBUG_VM_PGFLAGS triggers.
>>
>> The fix is to reserve memory from the first existing PFN.
>>
>> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
>> Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
>> Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
>> Reviewed-by: Bob Picco <bob.picco@oracle.com>
>> ---
>>   arch/x86/kernel/setup.c | 5 ++++-
>>   1 file changed, 4 insertions(+), 1 deletion(-)
>>
>> diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
>> index 3486d0498800..489cdc141bcb 100644
>> --- a/arch/x86/kernel/setup.c
>> +++ b/arch/x86/kernel/setup.c
>> @@ -790,7 +790,10 @@ early_param("reservelow", parse_reservelow);
>>   
>>   static void __init trim_low_memory_range(void)
>>   {
>> -	memblock_reserve(0, ALIGN(reserve_low, PAGE_SIZE));
>> +	unsigned long min_pfn = find_min_pfn_with_active_regions();
>> +	phys_addr_t base = min_pfn << PAGE_SHIFT;
>> +
>> +	memblock_reserve(base, ALIGN(reserve_low, PAGE_SIZE));
>>   }
>>   	
>>   /*
>> -- 
>> 2.14.0
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
