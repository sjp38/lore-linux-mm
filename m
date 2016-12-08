Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7CFCA6B0069
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 13:56:14 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id 81so13528192iog.0
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 10:56:14 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id y7si21570938iod.33.2016.12.08.10.56.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 10:56:13 -0800 (PST)
Subject: Re: [RFC, PATCHv1 17/28] x86/mm: define virtual memory map for
 5-level paging
References: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
 <20161208162150.148763-19-kirill.shutemov@linux.intel.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <24bebd32-2056-dd5a-8b77-d2a9572dc512@infradead.org>
Date: Thu, 8 Dec 2016 10:56:04 -0800
MIME-Version: 1.0
In-Reply-To: <20161208162150.148763-19-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/08/16 08:21, Kirill A. Shutemov wrote:
> The first part of memory map (up to %esp fixup) simply scales existing
> map for 4-level paging by factor of 9 -- number of bits addressed by
> additional page table level.
> 
> The rest of the map is uncahnged.

                         unchanged.

(more fixes below)


> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  Documentation/x86/x86_64/mm.txt         | 23 ++++++++++++++++++++++-
>  arch/x86/Kconfig                        |  1 +
>  arch/x86/include/asm/kasan.h            |  9 ++++++---
>  arch/x86/include/asm/page_64_types.h    | 10 ++++++++++
>  arch/x86/include/asm/pgtable_64_types.h |  6 ++++++
>  arch/x86/include/asm/sparsemem.h        |  9 +++++++--
>  6 files changed, 52 insertions(+), 6 deletions(-)
> 
> diff --git a/Documentation/x86/x86_64/mm.txt b/Documentation/x86/x86_64/mm.txt
> index 8c7dd5957ae1..d33fb0799b3d 100644
> --- a/Documentation/x86/x86_64/mm.txt
> +++ b/Documentation/x86/x86_64/mm.txt
> @@ -12,7 +12,7 @@ ffffc90000000000 - ffffe8ffffffffff (=45 bits) vmalloc/ioremap space
>  ffffe90000000000 - ffffe9ffffffffff (=40 bits) hole
>  ffffea0000000000 - ffffeaffffffffff (=40 bits) virtual memory map (1TB)
>  ... unused hole ...
> -ffffec0000000000 - fffffc0000000000 (=44 bits) kasan shadow memory (16TB)
> +ffffec0000000000 - fffffbffffffffff (=44 bits) kasan shadow memory (16TB)
>  ... unused hole ...
>  ffffff0000000000 - ffffff7fffffffff (=39 bits) %esp fixup stacks
>  ... unused hole ...
> @@ -23,6 +23,27 @@ ffffffffa0000000 - ffffffffff5fffff (=1526 MB) module mapping space
>  ffffffffff600000 - ffffffffffdfffff (=8 MB) vsyscalls
>  ffffffffffe00000 - ffffffffffffffff (=2 MB) unused hole
>  
> +Virtual memory map with 5 level page tables:
> +
> +0000000000000000 - 00ffffffffffffff (=56 bits) user space, different per mm
> +hole caused by [57:63] sign extension

Can you briefly explain the sign extension?
Should that be [56:63]?

> +ff00000000000000 - ff0fffffffffffff (=52 bits) guard hole, reserved for hypervisor
> +ff10000000000000 - ff8fffffffffffff (=55 bits) direct mapping of all phys. memory
> +ff90000000000000 - ff91ffffffffffff (=49 bits) hole
> +ff92000000000000 - ffd1ffffffffffff (=54 bits) vmalloc/ioremap space
> +ffd2000000000000 - ff93ffffffffffff (=49 bits) virtual memory map (512TB)
> +... unused hole ...
> +ff96000000000000 - ffb5ffffffffffff (=53 bits) kasan shadow memory (8PB)
> +... unused hole ...
> +fffe000000000000 - fffeffffffffffff (=49 bits) %esp fixup stacks
> +... unused hole ...
> +ffffffef00000000 - ffffffff00000000 (=64 GB) EFI region mapping space

                    - fffffffeffffffff

> +... unused hole ...
> +ffffffff80000000 - ffffffffa0000000 (=512 MB)  kernel text mapping, from phys 0

                    - ffffffff9fffffff

> +ffffffffa0000000 - ffffffffff5fffff (=1526 MB) module mapping space
> +ffffffffff600000 - ffffffffffdfffff (=8 MB) vsyscalls
> +ffffffffffe00000 - ffffffffffffffff (=2 MB) unused hole
> +
>  The direct mapping covers all memory in the system up to the highest
>  memory address (this means in some cases it can also include PCI memory
>  holes).

> diff --git a/arch/x86/include/asm/kasan.h b/arch/x86/include/asm/kasan.h
> index 1410b567ecde..2587c6bd89be 100644
> --- a/arch/x86/include/asm/kasan.h
> +++ b/arch/x86/include/asm/kasan.h
> @@ -11,9 +11,12 @@
>   * 'kernel address space start' >> KASAN_SHADOW_SCALE_SHIFT
>   */
>  #define KASAN_SHADOW_START      (KASAN_SHADOW_OFFSET + \
> -					(0xffff800000000000ULL >> 3))
> -/* 47 bits for kernel address -> (47 - 3) bits for shadow */
> -#define KASAN_SHADOW_END        (KASAN_SHADOW_START + (1ULL << (47 - 3)))
> +					((-1UL << __VIRTUAL_MASK_SHIFT) >> 3))
> +/*
> + * 47 bits for kernel address -> (47 - 3) bits for shadow
> + * 56 bits for kernel address -> (56 - 3) bits fro shadow

typo: s/fro/for/

> + */
> +#define KASAN_SHADOW_END        (KASAN_SHADOW_START + (1ULL << (__VIRTUAL_MASK_SHIFT - 3)))
>  
>  #ifndef __ASSEMBLY__
>  


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
