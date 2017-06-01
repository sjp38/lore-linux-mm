Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4B0936B033C
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 12:57:42 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id t133so52093211oif.9
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 09:57:42 -0700 (PDT)
Received: from mail-oi0-x22d.google.com (mail-oi0-x22d.google.com. [2607:f8b0:4003:c06::22d])
        by mx.google.com with ESMTPS id s34si8605781ots.33.2017.06.01.09.57.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 09:57:41 -0700 (PDT)
Received: by mail-oi0-x22d.google.com with SMTP id h4so61544658oib.3
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 09:57:41 -0700 (PDT)
Date: Thu, 1 Jun 2017 09:57:30 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: 4.12-rc ppc64 4k-page needs costly allocations
In-Reply-To: <87wp8wpcg9.fsf@skywalker.in.ibm.com>
Message-ID: <alpine.LSU.2.11.1706010952100.3014@eggly.anvils>
References: <alpine.LSU.2.11.1705301151090.2133@eggly.anvils> <87wp8wpcg9.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Hugh Dickins <hughd@google.com>, Michael Ellerman <mpe@ellerman.id.au>, Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Thu, 1 Jun 2017, Aneesh Kumar K.V wrote:
> Hugh Dickins <hughd@google.com> writes:
> 
> > Since f6eedbba7a26 ("powerpc/mm/hash: Increase VA range to 128TB")
> > I find that swapping loads on ppc64 on G5 with 4k pages are failing:
> >
> > SLUB: Unable to allocate memory on node -1, gfp=0x14000c0(GFP_KERNEL)
> >   cache: pgtable-2^12, object size: 32768, buffer size: 65536, default order: 4, min order: 4
> >   pgtable-2^12 debugging increased min order, use slub_debug=O to disable.
> >   node 0: slabs: 209, objs: 209, free: 8
> > gcc: page allocation failure: order:4, mode:0x16040c0(GFP_KERNEL|__GFP_COMP|__GFP_NOTRACK), nodemask=(null)
> > CPU: 1 PID: 6225 Comm: gcc Not tainted 4.12.0-rc2 #1
> > Call Trace:
> > [c00000000090b5c0] [c0000000004f8478] .dump_stack+0xa0/0xcc (unreliable)
> > [c00000000090b650] [c0000000000eb194] .warn_alloc+0xf0/0x178
> > [c00000000090b710] [c0000000000ebc9c] .__alloc_pages_nodemask+0xa04/0xb00
> > [c00000000090b8b0] [c00000000013921c] .new_slab+0x234/0x608
> > [c00000000090b980] [c00000000013b59c] .___slab_alloc.constprop.64+0x3dc/0x564
> > [c00000000090bad0] [c0000000004f5a84] .__slab_alloc.isra.61.constprop.63+0x54/0x70
> > [c00000000090bb70] [c00000000013b864] .kmem_cache_alloc+0x140/0x288
> > [c00000000090bc30] [c00000000004d934] .mm_init.isra.65+0x128/0x1c0
> > [c00000000090bcc0] [c000000000157810] .do_execveat_common.isra.39+0x294/0x690
> > [c00000000090bdb0] [c000000000157e70] .SyS_execve+0x28/0x38
> > [c00000000090be30] [c00000000000a118] system_call+0x38/0xfc
> >
> > I did try booting with slub_debug=O as the message suggested, but that
> > made no difference: it still hoped for but failed on order:4 allocations.
> >
> > I wanted to try removing CONFIG_SLUB_DEBUG, but didn't succeed in that:
> > it seemed to be a hard requirement for something, but I didn't find what.
> >
> > I did try CONFIG_SLAB=y instead of SLUB: that lowers these allocations to
> > the expected order:3, which then results in OOM-killing rather than direct
> > allocation failure, because of the PAGE_ALLOC_COSTLY_ORDER 3 cutoff.  But
> > makes no real difference to the outcome: swapping loads still abort early.
> >
> > Relying on order:3 or order:4 allocations is just too optimistic: ppc64
> > with 4k pages would do better not to expect to support a 128TB userspace.
> >
> > I tried the obvious partial revert below, but it's not good enough:
> > the system did not boot beyond
> >
> > Starting init: /sbin/init exists but couldn't execute it (error -7)
> > Starting init: /bin/sh exists but couldn't execute it (error -7)
> > Kernel panic - not syncing: No working init found. ...
> >
> 
> Can you try this patch.

Thanks!  By the time I got to try it, you'd sent another later in the
day.  Fractionally different, and I didn't spend any time working out
whether the difference was significant or cosmetic, I just tried that
second one instead.  No problems with it so far, hasn't been running
long, but long enough to say that it definitely fixes the problems
I was getting - thank you.

Hugh

> 
> commit fc55c0dc8b23446f937c1315aa61e74673de5ee6
> Author: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Date:   Thu Jun 1 08:06:40 2017 +0530
> 
>     powerpc/mm/4k: Limit 4k page size to 64TB
>     
>     Supporting 512TB requires us to do a order 3 allocation for level 1 page
>     table(pgd). Limit 4k to 64TB for now.
>     
>     Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> 
> diff --git a/arch/powerpc/include/asm/book3s/64/hash-4k.h b/arch/powerpc/include/asm/book3s/64/hash-4k.h
> index b4b5e6b671ca..0c4e470571ca 100644
> --- a/arch/powerpc/include/asm/book3s/64/hash-4k.h
> +++ b/arch/powerpc/include/asm/book3s/64/hash-4k.h
> @@ -8,7 +8,7 @@
>  #define H_PTE_INDEX_SIZE  9
>  #define H_PMD_INDEX_SIZE  7
>  #define H_PUD_INDEX_SIZE  9
> -#define H_PGD_INDEX_SIZE  12
> +#define H_PGD_INDEX_SIZE  9
>  
>  #ifndef __ASSEMBLY__
>  #define H_PTE_TABLE_SIZE	(sizeof(pte_t) << H_PTE_INDEX_SIZE)
> diff --git a/arch/powerpc/include/asm/processor.h b/arch/powerpc/include/asm/processor.h
> index a2123f291ab0..5de3271026f1 100644
> --- a/arch/powerpc/include/asm/processor.h
> +++ b/arch/powerpc/include/asm/processor.h
> @@ -110,13 +110,15 @@ void release_thread(struct task_struct *);
>  #define TASK_SIZE_128TB (0x0000800000000000UL)
>  #define TASK_SIZE_512TB (0x0002000000000000UL)
>  
> -#ifdef CONFIG_PPC_BOOK3S_64
> +#if defined(CONFIG_PPC_BOOK3S_64) && defined(CONFIG_PPC_64K_PAGES)
>  /*
>   * Max value currently used:
>   */
> -#define TASK_SIZE_USER64	TASK_SIZE_512TB
> +#define TASK_SIZE_USER64		TASK_SIZE_512TB
> +#define DEFAULT_MAP_WINDOW_USER64	TASK_SIZE_128TB
>  #else
> -#define TASK_SIZE_USER64	TASK_SIZE_64TB
> +#define TASK_SIZE_USER64		TASK_SIZE_64TB
> +#define DEFAULT_MAP_WINDOW_USER64	TASK_SIZE_64TB
>  #endif
>  
>  /*
> @@ -132,7 +134,7 @@ void release_thread(struct task_struct *);
>   * space during mmap's.
>   */
>  #define TASK_UNMAPPED_BASE_USER32 (PAGE_ALIGN(TASK_SIZE_USER32 / 4))
> -#define TASK_UNMAPPED_BASE_USER64 (PAGE_ALIGN(TASK_SIZE_128TB / 4))
> +#define TASK_UNMAPPED_BASE_USER64 (PAGE_ALIGN(DEFAULT_MAP_WINDOW_USER64 / 4))
>  
>  #define TASK_UNMAPPED_BASE ((is_32bit_task()) ? \
>  		TASK_UNMAPPED_BASE_USER32 : TASK_UNMAPPED_BASE_USER64 )
> @@ -143,8 +145,8 @@ void release_thread(struct task_struct *);
>   * with 128TB and conditionally enable upto 512TB
>   */
>  #ifdef CONFIG_PPC_BOOK3S_64
> -#define DEFAULT_MAP_WINDOW	((is_32bit_task()) ? \
> -				 TASK_SIZE_USER32 : TASK_SIZE_128TB)
> +#define DEFAULT_MAP_WINDOW	((is_32bit_task()) ?			\
> +				 TASK_SIZE_USER32 : DEFAULT_MAP_WINDOW_USER64)
>  #else
>  #define DEFAULT_MAP_WINDOW	TASK_SIZE
>  #endif
> @@ -153,7 +155,7 @@ void release_thread(struct task_struct *);
>  
>  #ifdef CONFIG_PPC_BOOK3S_64
>  /* Limit stack to 128TB */
> -#define STACK_TOP_USER64 TASK_SIZE_128TB
> +#define STACK_TOP_USER64 DEFAULT_MAP_WINDOW_USER64
>  #else
>  #define STACK_TOP_USER64 TASK_SIZE_USER64
>  #endif
> diff --git a/arch/powerpc/kernel/setup-common.c b/arch/powerpc/kernel/setup-common.c
> index 8389ff5ac002..77062461c469 100644
> --- a/arch/powerpc/kernel/setup-common.c
> +++ b/arch/powerpc/kernel/setup-common.c
> @@ -921,7 +921,7 @@ void __init setup_arch(char **cmdline_p)
>  
>  #ifdef CONFIG_PPC_MM_SLICES
>  #ifdef CONFIG_PPC64
> -	init_mm.context.addr_limit = TASK_SIZE_128TB;
> +	init_mm.context.addr_limit = DEFAULT_MAP_WINDOW_USER64;
>  #else
>  #error	"context.addr_limit not initialized."
>  #endif
> diff --git a/arch/powerpc/mm/mmu_context_book3s64.c b/arch/powerpc/mm/mmu_context_book3s64.c
> index c6dca2ae78ef..a3edf813d455 100644
> --- a/arch/powerpc/mm/mmu_context_book3s64.c
> +++ b/arch/powerpc/mm/mmu_context_book3s64.c
> @@ -99,7 +99,7 @@ static int hash__init_new_context(struct mm_struct *mm)
>  	 * mm->context.addr_limit. Default to max task size so that we copy the
>  	 * default values to paca which will help us to handle slb miss early.
>  	 */
> -	mm->context.addr_limit = TASK_SIZE_128TB;
> +	mm->context.addr_limit = DEFAULT_MAP_WINDOW_USER64;
>  
>  	/*
>  	 * The old code would re-promote on fork, we don't do that when using
>  
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
