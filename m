Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 313216B00E9
	for <linux-mm@kvack.org>; Mon, 11 Nov 2013 20:23:07 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id ro12so2925098pbb.27
        for <linux-mm@kvack.org>; Mon, 11 Nov 2013 17:23:06 -0800 (PST)
Received: from psmtp.com ([74.125.245.128])
        by mx.google.com with SMTP id bf6si6370012pad.77.2013.11.11.17.23.04
        for <linux-mm@kvack.org>;
        Mon, 11 Nov 2013 17:23:05 -0800 (PST)
Message-ID: <528182F6.4070308@codeaurora.org>
Date: Mon, 11 Nov 2013 17:23:02 -0800
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 3/4] mm/vmalloc.c: Allow lowmem to be tracked in vmalloc
References: <1384212412-21236-1-git-send-email-lauraa@codeaurora.org> <1384212412-21236-4-git-send-email-lauraa@codeaurora.org> <CAH9JG2Uh7PBEqRGPe5H6H+n1cnqwLFrFfB9aUOee8myG27DoiA@mail.gmail.com>
In-Reply-To: <CAH9JG2Uh7PBEqRGPe5H6H+n1cnqwLFrFfB9aUOee8myG27DoiA@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyungmin Park <kmpark@infradead.org>
Cc: linux-mm@kvack.org, Neeti Desai <neetid@codeaurora.org>, linux-arm-kernel@lists.infradead.org

On 11/11/2013 3:37 PM, Kyungmin Park wrote:
> Hi Laura,
>
> On Tue, Nov 12, 2013 at 8:26 AM, Laura Abbott <lauraa@codeaurora.org> wrote:
>> vmalloc is currently assumed to be a completely separate address space
>> from the lowmem region. While this may be true in the general case,
>> there are some instances where lowmem and virtual space intermixing
>> provides gains. One example is needing to steal a large chunk of physical
>> lowmem for another purpose outside the systems usage. Rather than
>> waste the precious lowmem space on a 32-bit system, we can allow the
>> virtual holes created by the physical holes to be used by vmalloc
>> for virtual addressing. Track lowmem allocations in vmalloc to
>> allow mixing of lowmem and vmalloc.
>>
>> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
>> Signed-off-by: Neeti Desai <neetid@codeaurora.org>
>> ---
>>   include/linux/mm.h      |    6 ++++++
>>   include/linux/vmalloc.h |    1 +
>>   mm/Kconfig              |   11 +++++++++++
>>   mm/vmalloc.c            |   26 ++++++++++++++++++++++++++
>>   4 files changed, 44 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index f022460..76df50d 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -308,6 +308,10 @@ unsigned long vmalloc_to_pfn(const void *addr);
>>    * On nommu, vmalloc/vfree wrap through kmalloc/kfree directly, so there
>>    * is no special casing required.
>>    */
>> +
>> +#ifdef CONFIG_VMALLOC_SAVING
> mismatch below Kconfig. CONFIG_ENABLE_VMALLOC_SAVING?

Argh, I folded in a wrong patch when integrating. I'll fix it.

>> +extern int is_vmalloc_addr(const void *x)
>> +#else
>>   static inline int is_vmalloc_addr(const void *x)
>>   {
>>   #ifdef CONFIG_MMU
>> @@ -318,6 +322,8 @@ static inline int is_vmalloc_addr(const void *x)
>>          return 0;
>>   #endif
>>   }
>> +#endif
>> +
>>   #ifdef CONFIG_MMU
>>   extern int is_vmalloc_or_module_addr(const void *x);
>>   #else
>> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
>> index 4b8a891..e0c8c49 100644
>> --- a/include/linux/vmalloc.h
>> +++ b/include/linux/vmalloc.h
>> @@ -16,6 +16,7 @@ struct vm_area_struct;                /* vma defining user mapping in mm_types.h */
>>   #define VM_USERMAP             0x00000008      /* suitable for remap_vmalloc_range */
>>   #define VM_VPAGES              0x00000010      /* buffer for pages was vmalloc'ed */
>>   #define VM_UNINITIALIZED       0x00000020      /* vm_struct is not fully initialized */
>> +#define VM_LOWMEM              0x00000040      /* Tracking of direct mapped lowmem */
>>   /* bits [20..32] reserved for arch specific ioremap internals */
>>
>>   /*
>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index 8028dcc..b3c459d 100644
>> --- a/mm/Kconfig
>> +++ b/mm/Kconfig
>> @@ -519,3 +519,14 @@ config MEM_SOFT_DIRTY
>>            it can be cleared by hands.
>>
>>            See Documentation/vm/soft-dirty.txt for more details.
>> +
>> +config ENABLE_VMALLOC_SAVING
>> +       bool "Intermix lowmem and vmalloc virtual space"
>> +       depends on ARCH_TRACKS_VMALLOC
>> +       help
>> +         Some memory layouts on embedded systems steal large amounts
>> +         of lowmem physical memory for purposes outside of the kernel.
>> +         Rather than waste the physical and virtual space, allow the
>> +         kernel to use the virtual space as vmalloc space.
>> +
>> +         If unsure, say N.
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index 13a5495..c7b138b 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -204,6 +204,29 @@ static int vmap_page_range(unsigned long start, unsigned long end,
>>          return ret;
>>   }
>>
>> +#ifdef ENABLE_VMALLOC_SAVING
> missing "CONFIG_"
>

Yes, this is a mess and needs to be cleaned up.

> Thank you,
> Kyungimn Park

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
