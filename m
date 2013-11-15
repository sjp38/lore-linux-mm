Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 19F476B0037
	for <linux-mm@kvack.org>; Fri, 15 Nov 2013 00:34:19 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id q10so3036067pdj.1
        for <linux-mm@kvack.org>; Thu, 14 Nov 2013 21:34:18 -0800 (PST)
Received: from psmtp.com ([74.125.245.142])
        by mx.google.com with SMTP id ai2si896021pad.204.2013.11.14.21.34.16
        for <linux-mm@kvack.org>;
        Thu, 14 Nov 2013 21:34:17 -0800 (PST)
Message-ID: <5285B256.6050403@codeaurora.org>
Date: Thu, 14 Nov 2013 21:34:14 -0800
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 4/4] mm/vmalloc.c: Treat the entire kernel virtual
 space as vmalloc
References: <1384212412-21236-1-git-send-email-lauraa@codeaurora.org> <1384212412-21236-5-git-send-email-lauraa@codeaurora.org> <528507BA.9010101@intel.com>
In-Reply-To: <528507BA.9010101@intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org
Cc: Neeti Desai <neetid@codeaurora.org>

On 11/14/2013 9:26 AM, Dave Hansen wrote:
> On 11/11/2013 03:26 PM, Laura Abbott wrote:
>> With CONFIG_ENABLE_VMALLOC_SAVINGS, all lowmem is tracked in
>> vmalloc. This means that all the kernel virtual address space
>> can be treated as part of the vmalloc region. Allow vm areas
>> to be allocated from the full kernel address range.
>>
>> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
>> Signed-off-by: Neeti Desai <neetid@codeaurora.org>
>> ---
>>   mm/vmalloc.c |   11 +++++++++++
>>   1 files changed, 11 insertions(+), 0 deletions(-)
>>
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index c7b138b..181247d 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -1385,16 +1385,27 @@ struct vm_struct *__get_vm_area_caller(unsigned long size, unsigned long flags,
>>    */
>>   struct vm_struct *get_vm_area(unsigned long size, unsigned long flags)
>>   {
>> +#ifdef CONFIG_ENABLE_VMALLOC_SAVING
>> +	return __get_vm_area_node(size, 1, flags, PAGE_OFFSET, VMALLOC_END,
>> +				  NUMA_NO_NODE, GFP_KERNEL,
>> +				  __builtin_return_address(0));
>> +#else
>>   	return __get_vm_area_node(size, 1, flags, VMALLOC_START, VMALLOC_END,
>>   				  NUMA_NO_NODE, GFP_KERNEL,
>>   				  __builtin_return_address(0));
>> +#endif
>>   }
>>
>>   struct vm_struct *get_vm_area_caller(unsigned long size, unsigned long flags,
>>   				const void *caller)
>>   {
>> +#ifdef CONFIG_ENABLE_VMALLOC_SAVING
>> +	return __get_vm_area_node(size, 1, flags, PAGE_OFFSET, VMALLOC_END,
>> +				  NUMA_NO_NODE, GFP_KERNEL, caller);
>> +#else
>>   	return __get_vm_area_node(size, 1, flags, VMALLOC_START, VMALLOC_END,
>>   				  NUMA_NO_NODE, GFP_KERNEL, caller);
>> +#endif
>>   }
>
> Couple of nits: first of all, there's no reason to copy, paste, and
> #ifdef this much code.  This just invites one of the copies to bitrot.
> I'd much rather see this:
>
> #ifdef CONFIG_ENABLE_VMALLOC_SAVING
> #define LOWEST_VMALLOC_VADDR PAGE_OFFSET
> #else
> #define LOWEST_VMALLOC_VADDR VMALLOC_START
> #endif
>
> Then just replace the PAGE_OFFSET in the function arguments with
> LOWEST_VMALLOC_VADDR.
>

Good point.

> Have you done any audits to make sure that the rest of the code that
> deals with vmalloc addresses in the kernel is using is_vmalloc_addr()?
> I'd be a bit worried that we might have picked up an assumption or two
> that *all* vmalloc addresses are _above_ VMALLOC_START.
>
> The percpu.c code looks like it might do this, and maybe the kcore code.
>   The vmalloc.c code itself has this in get_vmalloc_info():
>
>>                  /*
>>                   * Some archs keep another range for modules in vmalloc space
>>                   */
>>                  if (addr < VMALLOC_START)
>>                          continue;
>
> Seems like that would break as well.
>
> With this patch, VMALLOC_START loses enough of its meaning that I wonder
> if we should even keep it around.  It's the start of the _dedicated_
> vmalloc space, but it's mostly useless and obscure enough that maybe we
> should get rid of its use in common code.
>

Yes, there are plenty of clients who are using VMALLOC_START. There 
might still be a use for VMALLOC_START as marking 'no more direct mapped 
memory above this address' . To start making some if the cleanup easier, 
it would help to have an already calculated total amount of vmalloc for 
the clients who are trying to work off a vmalloc percentage.

Thanks,
Laura

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
