Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id F12476B0031
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 07:55:50 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so11024821pab.16
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 04:55:50 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id og1si48313632pbc.150.2014.07.10.04.55.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 10 Jul 2014 04:55:49 -0700 (PDT)
Message-ID: <53BE7F29.20304@oracle.com>
Date: Thu, 10 Jul 2014 07:55:21 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH RESEND -next 01/21] Add kernel address sanitizer infrastructure.
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com> <1404905415-9046-2-git-send-email-a.ryabinin@samsung.com>
In-Reply-To: <1404905415-9046-2-git-send-email-a.ryabinin@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

On 07/09/2014 07:29 AM, Andrey Ryabinin wrote:
> Address sanitizer for kernel (kasan) is a dynamic memory error detector.
> 
> The main features of kasan is:
>  - is based on compiler instrumentation (fast),
>  - detects out of bounds for both writes and reads,
>  - provides use after free detection,
> 
> This patch only adds infrastructure for kernel address sanitizer. It's not
> available for use yet. The idea and some code was borrowed from [1].
> 
> This feature requires pretty fresh GCC (revision r211699 from 2014-06-16 or
> latter).
> 
> Implementation details:
> The main idea of KASAN is to use shadow memory to record whether each byte of memory
> is safe to access or not, and use compiler's instrumentation to check the shadow memory
> on each memory access.
> 
> Address sanitizer dedicates 1/8 of the low memory to the shadow memory and uses direct
> mapping with a scale and offset to translate a memory address to its corresponding
> shadow address.
> 
> Here is function to translate address to corresponding shadow address:
> 
>      unsigned long kasan_mem_to_shadow(unsigned long addr)
>      {
>                 return ((addr - PAGE_OFFSET) >> KASAN_SHADOW_SCALE_SHIFT)
>                              + kasan_shadow_start;
>      }
> 
> where KASAN_SHADOW_SCALE_SHIFT = 3.
> 
> So for every 8 bytes of lowmemory there is one corresponding byte of shadow memory.
> The following encoding used for each shadow byte: 0 means that all 8 bytes of the
> corresponding memory region are valid for access; k (1 <= k <= 7) means that
> the first k bytes are valid for access, and other (8 - k) bytes are not;
> Any negative value indicates that the entire 8-bytes are unaccessible.
> Different negative values used to distinguish between different kinds of
> unaccessible memory (redzones, freed memory) (see mm/kasan/kasan.h).
> 
> To be able to detect accesses to bad memory we need a special compiler.
> Such compiler inserts a specific function calls (__asan_load*(addr), __asan_store*(addr))
> before each memory access of size 1, 2, 4, 8 or 16.
> 
> These functions check whether memory region is valid to access or not by checking
> corresponding shadow memory. If access is not valid an error printed.
> 
> [1] https://code.google.com/p/address-sanitizer/wiki/AddressSanitizerForKernel
> 
> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>

I gave it a spin, and it seems that it fails for what you might call a "regular"
memory size these days, in my case it was 18G:

[    0.000000] Kernel panic - not syncing: ERROR: Failed to allocate 0xe0c00000 bytes below 0x0.
[    0.000000]
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 3.16.0-rc4-next-20140710-sasha-00044-gb7b0579-dirty #784
[    0.000000]  ffffffffb9c2d3c8 cd9ce91adea4379a 0000000000000000 ffffffffb9c2d3c8
[    0.000000]  ffffffffb9c2d330 ffffffffb7fe89b7 ffffffffb93c8c28 ffffffffb9c2d3b8
[    0.000000]  ffffffffb7fcff1d 0000000000000018 ffffffffb9c2d3c8 ffffffffb9c2d360
[    0.000000] Call Trace:
[    0.000000] <UNK> dump_stack (lib/dump_stack.c:52)
[    0.000000] panic (kernel/panic.c:119)
[    0.000000] memblock_alloc_base (mm/memblock.c:1092)
[    0.000000] memblock_alloc (mm/memblock.c:1097)
[    0.000000] kasan_alloc_shadow (mm/kasan/kasan.c:151)
[    0.000000] zone_sizes_init (arch/x86/mm/init.c:684)
[    0.000000] paging_init (arch/x86/mm/init_64.c:677)
[    0.000000] setup_arch (arch/x86/kernel/setup.c:1168)
[    0.000000] ? printk (kernel/printk/printk.c:1839)
[    0.000000] start_kernel (include/linux/mm_types.h:462 init/main.c:533)
[    0.000000] ? early_idt_handlers (arch/x86/kernel/head_64.S:344)
[    0.000000] x86_64_start_reservations (arch/x86/kernel/head64.c:194)
[    0.000000] x86_64_start_kernel (arch/x86/kernel/head64.c:183)

It got better when I reduced memory to 1GB, but then my system just failed to boot
at all because that's not enough to bring everything up.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
