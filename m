Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 854648E0018
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 09:36:06 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id r82so6404907oie.14
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 06:36:06 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t38si5318259ote.107.2018.12.10.06.36.04
        for <linux-mm@kvack.org>;
        Mon, 10 Dec 2018 06:36:04 -0800 (PST)
Subject: Re: [PATCH] mm/zsmalloc.c: Fix zsmalloc 32-bit PAE support
References: <20181210142105.6750-1-rafael.tinoco@linaro.org>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <4da655ec-a1ac-c524-1eb4-5cbd18b265ef@arm.com>
Date: Mon, 10 Dec 2018 14:35:55 +0000
MIME-Version: 1.0
In-Reply-To: <20181210142105.6750-1-rafael.tinoco@linaro.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael David Tinoco <rafael.tinoco@linaro.org>, Russell King <linux@armlinux.org.uk>
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-sh@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Ram Pai <linuxram@us.ibm.com>, linux-mips@vger.kernel.org, linux-mm@kvack.org, Khalid Aziz <khalid.aziz@oracle.com>, Paul Mackerras <paulus@samba.org>, "H . Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, linux-s390@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Ingo Molnar <mingo@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, James Hogan <jhogan@kernel.org>, Anthony Yznaga <anthony.yznaga@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Fenghua Yu <fenghua.yu@intel.com>, Joerg Roedel <jroedel@suse.de>, Juergen Gross <jgross@suse.com>, Vasily Gorbik <gor@linux.ibm.com>, Will Deacon <will.deacon@arm.com>, Nicholas Piggin <npiggin@gmail.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, Christophe Leroy <christophe.leroy@c-s.fr>, Tony Luck <tony.luck@intel.com>, Jiri Kosina <jkosina@suse.cz>, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, Minchan Kim <minchan@kernel.org>, Paul Burton <paul.burton@mips.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linuxppc-dev@lists.ozlabs.org, "David S . Miller" <davem@davemloft.net>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On 10/12/2018 14:21, Rafael David Tinoco wrote:
> On 32-bit systems, zsmalloc uses HIGHMEM and, when PAE is enabled, the
> physical frame number might be so big that zsmalloc obj encoding (to
> location) will break, causing:
> 
> BUG: KASAN: null-ptr-deref in zs_map_object+0xa4/0x2bc
> Read of size 4 at addr 00000000 by task mkfs.ext4/623
> CPU: 2 PID: 623 Comm: mkfs.ext4 Not tainted 4.19.0-rc8-00017-g8239bc6d3307-dirty #15
> Hardware name: Generic DT based system
> [<c0418f7c>] (unwind_backtrace) from [<c0410ca4>] (show_stack+0x20/0x24)
> [<c0410ca4>] (show_stack) from [<c16bd540>] (dump_stack+0xbc/0xe8)
> [<c16bd540>] (dump_stack) from [<c06cab74>] (kasan_report+0x248/0x390)
> [<c06cab74>] (kasan_report) from [<c06c94e8>] (__asan_load4+0x78/0xb4)
> [<c06c94e8>] (__asan_load4) from [<c06ddc24>] (zs_map_object+0xa4/0x2bc)
> [<c06ddc24>] (zs_map_object) from [<bf0bbbd8>] (zram_bvec_rw.constprop.2+0x324/0x8e4 [zram])
> [<bf0bbbd8>] (zram_bvec_rw.constprop.2 [zram]) from [<bf0bc3cc>] (zram_make_request+0x234/0x46c [zram])
> [<bf0bc3cc>] (zram_make_request [zram]) from [<c09aff9c>] (generic_make_request+0x304/0x63c)
> [<c09aff9c>] (generic_make_request) from [<c09b0320>] (submit_bio+0x4c/0x1c8)
> [<c09b0320>] (submit_bio) from [<c0743570>] (submit_bh_wbc.constprop.15+0x238/0x26c)
> [<c0743570>] (submit_bh_wbc.constprop.15) from [<c0746cf8>] (__block_write_full_page+0x524/0x76c)
> [<c0746cf8>] (__block_write_full_page) from [<c07472c4>] (block_write_full_page+0x1bc/0x1d4)
> [<c07472c4>] (block_write_full_page) from [<c0748eb4>] (blkdev_writepage+0x24/0x28)
> [<c0748eb4>] (blkdev_writepage) from [<c064a780>] (__writepage+0x44/0x78)
> [<c064a780>] (__writepage) from [<c064b50c>] (write_cache_pages+0x3b8/0x800)
> [<c064b50c>] (write_cache_pages) from [<c064dd78>] (generic_writepages+0x74/0xa0)
> [<c064dd78>] (generic_writepages) from [<c0748e64>] (blkdev_writepages+0x18/0x1c)
> [<c0748e64>] (blkdev_writepages) from [<c064e890>] (do_writepages+0x68/0x134)
> [<c064e890>] (do_writepages) from [<c06368a4>] (__filemap_fdatawrite_range+0xb0/0xf4)
> [<c06368a4>] (__filemap_fdatawrite_range) from [<c0636b68>] (file_write_and_wait_range+0x64/0xd0)
> [<c0636b68>] (file_write_and_wait_range) from [<c0747af8>] (blkdev_fsync+0x54/0x84)
> [<c0747af8>] (blkdev_fsync) from [<c0739dac>] (vfs_fsync_range+0x70/0xd4)
> [<c0739dac>] (vfs_fsync_range) from [<c0739e98>] (do_fsync+0x4c/0x80)
> [<c0739e98>] (do_fsync) from [<c073a26c>] (sys_fsync+0x1c/0x20)
> [<c073a26c>] (sys_fsync) from [<c0401000>] (ret_fast_syscall+0x0/0x2c)
> 
> when trying to decode (the pfn) and map the object.
> 
> That happens because one architecture might not re-define
> MAX_PHYSMEM_BITS, like in this ARM 32-bit w/ LPAE enabled example. For
> 32-bit systems, if not re-defined, MAX_POSSIBLE_PHYSMEM_BITS will
> default to BITS_PER_LONG (32) in most cases, and, with PAE enabled,
> _PFN_BITS might be wrong: which may cause obj variable to overflow if
> frame number is in HIGHMEM and referencing a page above the 4GB
> watermark.
> 
> commit 6e00ec00b1a7 ("staging: zsmalloc: calculate MAX_PHYSMEM_BITS if
> not defined") realized MAX_PHYSMEM_BITS depended on SPARSEMEM headers
> and "fixed" it by calculating it using BITS_PER_LONG if SPARSEMEM wasn't
> used, like in the example given above.
> 
> Systems with potential for PAE exist for a long time and assuming
> BITS_PER_LONG seems inadequate. Defining MAX_PHYSMEM_BITS looks better,
> however it is NOT a constant anymore for x86.
> 
> SO, instead, MAX_POSSIBLE_PHYSMEM_BITS should be defined by every
> architecture using zsmalloc, together with a sanity check for
> MAX_POSSIBLE_PHYSMEM_BITS being too big on 32-bit systems.
> 
> Link: https://bugs.linaro.org/show_bug.cgi?id=3765#c17
> Signed-off-by: Rafael David Tinoco <rafael.tinoco@linaro.org>
> ---
>   arch/arm/include/asm/pgtable-2level-types.h |  2 ++
>   arch/arm/include/asm/pgtable-3level-types.h |  2 ++
>   arch/arm64/include/asm/pgtable-types.h      |  2 ++
>   arch/ia64/include/asm/page.h                |  2 ++
>   arch/mips/include/asm/page.h                |  2 ++
>   arch/powerpc/include/asm/mmu.h              |  2 ++
>   arch/s390/include/asm/page.h                |  2 ++
>   arch/sh/include/asm/page.h                  |  2 ++
>   arch/sparc/include/asm/page_32.h            |  2 ++
>   arch/sparc/include/asm/page_64.h            |  2 ++
>   arch/x86/include/asm/pgtable-2level_types.h |  2 ++
>   arch/x86/include/asm/pgtable-3level_types.h |  3 +-
>   arch/x86/include/asm/pgtable_64_types.h     |  4 +--
>   mm/zsmalloc.c                               | 35 +++++++++++----------
>   14 files changed, 45 insertions(+), 19 deletions(-)
> 
> diff --git a/arch/arm/include/asm/pgtable-2level-types.h b/arch/arm/include/asm/pgtable-2level-types.h
> index 66cb5b0e89c5..552dba411324 100644
> --- a/arch/arm/include/asm/pgtable-2level-types.h
> +++ b/arch/arm/include/asm/pgtable-2level-types.h
> @@ -64,4 +64,6 @@ typedef pteval_t pgprot_t;
>   
>   #endif /* STRICT_MM_TYPECHECKS */
>   
> +#define MAX_POSSIBLE_PHYSMEM_BITS 32
> +
>   #endif	/* _ASM_PGTABLE_2LEVEL_TYPES_H */
> diff --git a/arch/arm/include/asm/pgtable-3level-types.h b/arch/arm/include/asm/pgtable-3level-types.h
> index 921aa30259c4..664c39e6517c 100644
> --- a/arch/arm/include/asm/pgtable-3level-types.h
> +++ b/arch/arm/include/asm/pgtable-3level-types.h
> @@ -67,4 +67,6 @@ typedef pteval_t pgprot_t;
>   
>   #endif	/* STRICT_MM_TYPECHECKS */
>   
> +#define MAX_POSSIBLE_PHYSMEM_BITS 36

Nit: with LPAE, physical addresses go up to 40 bits, not just 36.

Robin.

> +
>   #endif	/* _ASM_PGTABLE_3LEVEL_TYPES_H */
> diff --git a/arch/arm64/include/asm/pgtable-types.h b/arch/arm64/include/asm/pgtable-types.h
> index 345a072b5856..45c3834eb4c8 100644
> --- a/arch/arm64/include/asm/pgtable-types.h
> +++ b/arch/arm64/include/asm/pgtable-types.h
> @@ -64,4 +64,6 @@ typedef struct { pteval_t pgprot; } pgprot_t;
>   #include <asm-generic/5level-fixup.h>
>   #endif
>   
> +#define MAX_POSSIBLE_PHYSMEM_BITS CONFIG_ARM64_PA_BITS
> +
>   #endif	/* __ASM_PGTABLE_TYPES_H */
> diff --git a/arch/ia64/include/asm/page.h b/arch/ia64/include/asm/page.h
> index 5798bd2b462c..a3e055979e46 100644
> --- a/arch/ia64/include/asm/page.h
> +++ b/arch/ia64/include/asm/page.h
> @@ -235,4 +235,6 @@ get_order (unsigned long size)
>   
>   #define __HAVE_ARCH_GATE_AREA	1
>   
> +#define MAX_POSSIBLE_PHYSMEM_BITS 50
> +
>   #endif /* _ASM_IA64_PAGE_H */
> diff --git a/arch/mips/include/asm/page.h b/arch/mips/include/asm/page.h
> index e8cc328fce2d..f6a5dea1a66c 100644
> --- a/arch/mips/include/asm/page.h
> +++ b/arch/mips/include/asm/page.h
> @@ -263,4 +263,6 @@ extern int __virt_addr_valid(const volatile void *kaddr);
>   #include <asm-generic/memory_model.h>
>   #include <asm-generic/getorder.h>
>   
> +#define MAX_POSSIBLE_PHYSMEM_BITS 48
> +
>   #endif /* _ASM_PAGE_H */
> diff --git a/arch/powerpc/include/asm/mmu.h b/arch/powerpc/include/asm/mmu.h
> index eb20eb3b8fb0..2ebc1d2d9a5c 100644
> --- a/arch/powerpc/include/asm/mmu.h
> +++ b/arch/powerpc/include/asm/mmu.h
> @@ -324,6 +324,8 @@ static inline u16 get_mm_addr_key(struct mm_struct *mm, unsigned long address)
>   #define MAX_PHYSMEM_BITS        46
>   #endif
>   
> +#define MAX_POSSIBLE_PHYSMEM_BITS MAX_PHYSMEM_BITS
> +
>   #ifdef CONFIG_PPC_BOOK3S_64
>   #include <asm/book3s/64/mmu.h>
>   #else /* CONFIG_PPC_BOOK3S_64 */
> diff --git a/arch/s390/include/asm/page.h b/arch/s390/include/asm/page.h
> index a4d38092530a..8abec1461bf7 100644
> --- a/arch/s390/include/asm/page.h
> +++ b/arch/s390/include/asm/page.h
> @@ -180,4 +180,6 @@ static inline int devmem_is_allowed(unsigned long pfn)
>   #include <asm-generic/memory_model.h>
>   #include <asm-generic/getorder.h>
>   
> +#define MAX_POSSIBLE_PHYSMEM_BITS CONFIG_MAX_PHYSMEM_BITS
> +
>   #endif /* _S390_PAGE_H */
> diff --git a/arch/sh/include/asm/page.h b/arch/sh/include/asm/page.h
> index 5eef8be3e59f..40c7e12cf09e 100644
> --- a/arch/sh/include/asm/page.h
> +++ b/arch/sh/include/asm/page.h
> @@ -205,4 +205,6 @@ typedef struct page *pgtable_t;
>   #define ARCH_SLAB_MINALIGN	8
>   #endif
>   
> +#define MAX_POSSIBLE_PHYSMEM_BITS 32
> +
>   #endif /* __ASM_SH_PAGE_H */
> diff --git a/arch/sparc/include/asm/page_32.h b/arch/sparc/include/asm/page_32.h
> index b76d59edec8c..14e9ca4659d7 100644
> --- a/arch/sparc/include/asm/page_32.h
> +++ b/arch/sparc/include/asm/page_32.h
> @@ -139,4 +139,6 @@ extern unsigned long pfn_base;
>   #include <asm-generic/memory_model.h>
>   #include <asm-generic/getorder.h>
>   
> +#define MAX_POSSIBLE_PHYSMEM_BITS 32
> +
>   #endif /* _SPARC_PAGE_H */
> diff --git a/arch/sparc/include/asm/page_64.h b/arch/sparc/include/asm/page_64.h
> index e80f2d5bf62f..6d6f3654ead1 100644
> --- a/arch/sparc/include/asm/page_64.h
> +++ b/arch/sparc/include/asm/page_64.h
> @@ -163,4 +163,6 @@ extern unsigned long PAGE_OFFSET;
>   
>   #include <asm-generic/getorder.h>
>   
> +#define MAX_POSSIBLE_PHYSMEM_BITS MAX_PHYS_ADDRESS_BITS
> +
>   #endif /* _SPARC64_PAGE_H */
> diff --git a/arch/x86/include/asm/pgtable-2level_types.h b/arch/x86/include/asm/pgtable-2level_types.h
> index 6deb6cd236e3..c2eae59e6505 100644
> --- a/arch/x86/include/asm/pgtable-2level_types.h
> +++ b/arch/x86/include/asm/pgtable-2level_types.h
> @@ -38,4 +38,6 @@ typedef union {
>   /* This covers all VMSPLIT_* and VMSPLIT_*_OPT variants */
>   #define PGD_KERNEL_START	(CONFIG_PAGE_OFFSET >> PGDIR_SHIFT)
>   
> +#define MAX_POSSIBLE_PHYSMEM_BITS 32
> +
>   #endif /* _ASM_X86_PGTABLE_2LEVEL_DEFS_H */
> diff --git a/arch/x86/include/asm/pgtable-3level_types.h b/arch/x86/include/asm/pgtable-3level_types.h
> index 33845d36897c..5fce514a49a0 100644
> --- a/arch/x86/include/asm/pgtable-3level_types.h
> +++ b/arch/x86/include/asm/pgtable-3level_types.h
> @@ -45,7 +45,8 @@ typedef union {
>    */
>   #define PTRS_PER_PTE	512
>   
> -#define MAX_POSSIBLE_PHYSMEM_BITS	36
>   #define PGD_KERNEL_START	(CONFIG_PAGE_OFFSET >> PGDIR_SHIFT)
>   
> +#define MAX_POSSIBLE_PHYSMEM_BITS 36
> +
>   #endif /* _ASM_X86_PGTABLE_3LEVEL_DEFS_H */
> diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
> index 84bd9bdc1987..d808cfde3d19 100644
> --- a/arch/x86/include/asm/pgtable_64_types.h
> +++ b/arch/x86/include/asm/pgtable_64_types.h
> @@ -64,8 +64,6 @@ extern unsigned int ptrs_per_p4d;
>   #define P4D_SIZE		(_AC(1, UL) << P4D_SHIFT)
>   #define P4D_MASK		(~(P4D_SIZE - 1))
>   
> -#define MAX_POSSIBLE_PHYSMEM_BITS	52
> -
>   #else /* CONFIG_X86_5LEVEL */
>   
>   /*
> @@ -154,4 +152,6 @@ extern unsigned int ptrs_per_p4d;
>   
>   #define PGD_KERNEL_START	((PAGE_SIZE / 2) / sizeof(pgd_t))
>   
> +#define MAX_POSSIBLE_PHYSMEM_BITS (pgtable_l5_enabled() ? 52 : 46)
> +
>   #endif /* _ASM_X86_PGTABLE_64_DEFS_H */
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 0787d33b80d8..132c20b6fd4f 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -80,23 +80,7 @@
>    * as single (unsigned long) handle value.
>    *
>    * Note that object index <obj_idx> starts from 0.
> - *
> - * This is made more complicated by various memory models and PAE.
> - */
> -
> -#ifndef MAX_POSSIBLE_PHYSMEM_BITS
> -#ifdef MAX_PHYSMEM_BITS
> -#define MAX_POSSIBLE_PHYSMEM_BITS MAX_PHYSMEM_BITS
> -#else
> -/*
> - * If this definition of MAX_PHYSMEM_BITS is used, OBJ_INDEX_BITS will just
> - * be PAGE_SHIFT
>    */
> -#define MAX_POSSIBLE_PHYSMEM_BITS BITS_PER_LONG
> -#endif
> -#endif
> -
> -#define _PFN_BITS		(MAX_POSSIBLE_PHYSMEM_BITS - PAGE_SHIFT)
>   
>   /*
>    * Memory for allocating for handle keeps object position by
> @@ -116,6 +100,25 @@
>    */
>   #define OBJ_ALLOCATED_TAG 1
>   #define OBJ_TAG_BITS 1
> +
> +/*
> + * MAX_POSSIBLE_PHYSMEM_BITS should be defined by all archs using zsmalloc:
> + * Trying to guess it from MAX_PHYSMEM_BITS, or considering it BITS_PER_LONG,
> + * proved to be wrong by not considering PAE capabilities, or using SPARSEMEM
> + * only headers, leading to bad object encoding due to object index overflow.
> + */
> +#ifndef MAX_POSSIBLE_PHYSMEM_BITS
> + #define MAX_POSSIBLE_PHYSMEM_BITS BITS_PER_LONG
> + #error "MAX_POSSIBLE_PHYSMEM_BITS HAS to be defined by arch using zsmalloc";
> +#else
> + #ifndef CONFIG_64BIT
> +  #if (MAX_POSSIBLE_PHYSMEM_BITS >= (BITS_PER_LONG + PAGE_SHIFT - OBJ_TAG_BITS))
> +   #error "MAX_POSSIBLE_PHYSMEM_BITS is wrong for this arch";
> +  #endif
> + #endif
> +#endif
> +
> +#define _PFN_BITS (MAX_POSSIBLE_PHYSMEM_BITS - PAGE_SHIFT)
>   #define OBJ_INDEX_BITS	(BITS_PER_LONG - _PFN_BITS - OBJ_TAG_BITS)
>   #define OBJ_INDEX_MASK	((_AC(1, UL) << OBJ_INDEX_BITS) - 1)
>   
> 
