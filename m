Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 753806B0036
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 09:44:48 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kq14so11144731pab.34
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 06:44:48 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id g4si8600348pde.327.2014.07.10.06.44.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 10 Jul 2014 06:44:47 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N8I00ISZ0U3BO50@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 10 Jul 2014 14:44:27 +0100 (BST)
Message-id: <53BE9786.4060700@samsung.com>
Date: Thu, 10 Jul 2014 17:39:18 +0400
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC/PATCH RESEND -next 01/21] Add kernel address sanitizer
 infrastructure.
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1404905415-9046-2-git-send-email-a.ryabinin@samsung.com>
 <53BE7F29.20304@oracle.com> <53BE8EA5.2030402@samsung.com>
 <53BE959A.4010206@oracle.com>
In-reply-to: <53BE959A.4010206@oracle.com>
Content-type: text/plain; charset=ISO-8859-1
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>

On 07/10/14 17:31, Sasha Levin wrote:
> On 07/10/2014 09:01 AM, Andrey Ryabinin wrote:
>> On 07/10/14 15:55, Sasha Levin wrote:
>>>> On 07/09/2014 07:29 AM, Andrey Ryabinin wrote:
>>>>>> Address sanitizer for kernel (kasan) is a dynamic memory error detector.
>>>>>>
>>>>>> The main features of kasan is:
>>>>>>  - is based on compiler instrumentation (fast),
>>>>>>  - detects out of bounds for both writes and reads,
>>>>>>  - provides use after free detection,
>>>>>>
>>>>>> This patch only adds infrastructure for kernel address sanitizer. It's not
>>>>>> available for use yet. The idea and some code was borrowed from [1].
>>>>>>
>>>>>> This feature requires pretty fresh GCC (revision r211699 from 2014-06-16 or
>>>>>> latter).
>>>>>>
>>>>>> Implementation details:
>>>>>> The main idea of KASAN is to use shadow memory to record whether each byte of memory
>>>>>> is safe to access or not, and use compiler's instrumentation to check the shadow memory
>>>>>> on each memory access.
>>>>>>
>>>>>> Address sanitizer dedicates 1/8 of the low memory to the shadow memory and uses direct
>>>>>> mapping with a scale and offset to translate a memory address to its corresponding
>>>>>> shadow address.
>>>>>>
>>>>>> Here is function to translate address to corresponding shadow address:
>>>>>>
>>>>>>      unsigned long kasan_mem_to_shadow(unsigned long addr)
>>>>>>      {
>>>>>>                 return ((addr - PAGE_OFFSET) >> KASAN_SHADOW_SCALE_SHIFT)
>>>>>>                              + kasan_shadow_start;
>>>>>>      }
>>>>>>
>>>>>> where KASAN_SHADOW_SCALE_SHIFT = 3.
>>>>>>
>>>>>> So for every 8 bytes of lowmemory there is one corresponding byte of shadow memory.
>>>>>> The following encoding used for each shadow byte: 0 means that all 8 bytes of the
>>>>>> corresponding memory region are valid for access; k (1 <= k <= 7) means that
>>>>>> the first k bytes are valid for access, and other (8 - k) bytes are not;
>>>>>> Any negative value indicates that the entire 8-bytes are unaccessible.
>>>>>> Different negative values used to distinguish between different kinds of
>>>>>> unaccessible memory (redzones, freed memory) (see mm/kasan/kasan.h).
>>>>>>
>>>>>> To be able to detect accesses to bad memory we need a special compiler.
>>>>>> Such compiler inserts a specific function calls (__asan_load*(addr), __asan_store*(addr))
>>>>>> before each memory access of size 1, 2, 4, 8 or 16.
>>>>>>
>>>>>> These functions check whether memory region is valid to access or not by checking
>>>>>> corresponding shadow memory. If access is not valid an error printed.
>>>>>>
>>>>>> [1] https://code.google.com/p/address-sanitizer/wiki/AddressSanitizerForKernel
>>>>>>
>>>>>> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
>>>>
>>>> I gave it a spin, and it seems that it fails for what you might call a "regular"
>>>> memory size these days, in my case it was 18G:
>>>>
>>>> [    0.000000] Kernel panic - not syncing: ERROR: Failed to allocate 0xe0c00000 bytes below 0x0.
>>>> [    0.000000]
>>>> [    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 3.16.0-rc4-next-20140710-sasha-00044-gb7b0579-dirty #784
>>>> [    0.000000]  ffffffffb9c2d3c8 cd9ce91adea4379a 0000000000000000 ffffffffb9c2d3c8
>>>> [    0.000000]  ffffffffb9c2d330 ffffffffb7fe89b7 ffffffffb93c8c28 ffffffffb9c2d3b8
>>>> [    0.000000]  ffffffffb7fcff1d 0000000000000018 ffffffffb9c2d3c8 ffffffffb9c2d360
>>>> [    0.000000] Call Trace:
>>>> [    0.000000] <UNK> dump_stack (lib/dump_stack.c:52)
>>>> [    0.000000] panic (kernel/panic.c:119)
>>>> [    0.000000] memblock_alloc_base (mm/memblock.c:1092)
>>>> [    0.000000] memblock_alloc (mm/memblock.c:1097)
>>>> [    0.000000] kasan_alloc_shadow (mm/kasan/kasan.c:151)
>>>> [    0.000000] zone_sizes_init (arch/x86/mm/init.c:684)
>>>> [    0.000000] paging_init (arch/x86/mm/init_64.c:677)
>>>> [    0.000000] setup_arch (arch/x86/kernel/setup.c:1168)
>>>> [    0.000000] ? printk (kernel/printk/printk.c:1839)
>>>> [    0.000000] start_kernel (include/linux/mm_types.h:462 init/main.c:533)
>>>> [    0.000000] ? early_idt_handlers (arch/x86/kernel/head_64.S:344)
>>>> [    0.000000] x86_64_start_reservations (arch/x86/kernel/head64.c:194)
>>>> [    0.000000] x86_64_start_kernel (arch/x86/kernel/head64.c:183)
>>>>
>>>> It got better when I reduced memory to 1GB, but then my system just failed to boot
>>>> at all because that's not enough to bring everything up.
>>>>
>> Thanks.
>> I think memory size is not a problem here. I tested on my desktop with 16G.
>> Seems it's a problem with memory holes cited by Dave.
>> kasan tries to allocate ~3.5G. It means that lowmemsize is 28G in your case.
> 
> That's correct (I've mistyped and got 18 instead of 28 above).
> 
> However, I'm a bit confused here, I thought highmem/lowmem split was a 32bit
> thing, so I'm not sure how it applies here.
> 
Right. By lowmemsize here I mean size of direct
mapping of all phys. memory (which usually called as lowmem on 32bit systems).



> Anyways, the machine won't boot with more than 1GB of RAM, is there a solution to
> get KASAN running on my machine?
> 
Could you share you .config? I'll try to boot it by myself. It could be that some options conflicting with kasan.
Also boot cmdline might help.

> 
> Thanks,
> Sasha
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
