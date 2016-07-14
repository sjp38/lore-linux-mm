Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 299206B025E
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 19:20:01 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e189so183029686pfa.2
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 16:20:01 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id h190si196025pfb.251.2016.07.14.16.19.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jul 2016 16:19:59 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id y134so1198657pfg.3
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 16:19:58 -0700 (PDT)
Date: Fri, 15 Jul 2016 09:20:19 +1000
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [PATCH v2 02/11] mm: Hardened usercopy
Message-ID: <20160714232019.GA28254@350D>
Reply-To: bsingharora@gmail.com
References: <1468446964-22213-1-git-send-email-keescook@chromium.org>
 <1468446964-22213-3-git-send-email-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1468446964-22213-3-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

On Wed, Jul 13, 2016 at 02:55:55PM -0700, Kees Cook wrote:
> This is the start of porting PAX_USERCOPY into the mainline kernel. This
> is the first set of features, controlled by CONFIG_HARDENED_USERCOPY. The
> work is based on code by PaX Team and Brad Spengler, and an earlier port
> from Casey Schaufler. Additional non-slab page tests are from Rik van Riel.
> 
> This patch contains the logic for validating several conditions when
> performing copy_to_user() and copy_from_user() on the kernel object
> being copied to/from:
> - address range doesn't wrap around
> - address range isn't NULL or zero-allocated (with a non-zero copy size)
> - if on the slab allocator:
>   - object size must be less than or equal to copy size (when check is
>     implemented in the allocator, which appear in subsequent patches)
> - otherwise, object must not span page allocations
> - if on the stack
>   - object must not extend before/after the current process task
>   - object must be contained by the current stack frame (when there is
>     arch/build support for identifying stack frames)
> - object must not overlap with kernel text
> 
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
>  arch/Kconfig                |   7 ++
>  include/linux/slab.h        |  12 +++
>  include/linux/thread_info.h |  15 +++
>  mm/Makefile                 |   4 +
>  mm/usercopy.c               | 219 ++++++++++++++++++++++++++++++++++++++++++++
>  security/Kconfig            |  27 ++++++
>  6 files changed, 284 insertions(+)
>  create mode 100644 mm/usercopy.c
> 
> diff --git a/arch/Kconfig b/arch/Kconfig
> index 5e2776562035..195ee4cc939a 100644
> --- a/arch/Kconfig
> +++ b/arch/Kconfig
> @@ -433,6 +433,13 @@ config HAVE_ARCH_WITHIN_STACK_FRAMES
>  	  and similar) by implementing an inline arch_within_stack_frames(),
>  	  which is used by CONFIG_HARDENED_USERCOPY.
>  
> +config HAVE_ARCH_LINEAR_KERNEL_MAPPING
> +	bool
> +	help
> +	  An architecture should select this if it has a secondary linear
> +	  mapping of the kernel text. This is used to verify that kernel
> +	  text exposures are not visible under CONFIG_HARDENED_USERCOPY.
> +
>  config HAVE_CONTEXT_TRACKING
>  	bool
>  	help
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index aeb3e6d00a66..96a16a3fb7cb 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -155,6 +155,18 @@ void kfree(const void *);
>  void kzfree(const void *);
>  size_t ksize(const void *);
>  
> +#ifdef CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR
> +const char *__check_heap_object(const void *ptr, unsigned long n,
> +				struct page *page);
> +#else
> +static inline const char *__check_heap_object(const void *ptr,
> +					      unsigned long n,
> +					      struct page *page)
> +{
> +	return NULL;
> +}
> +#endif
> +
>  /*
>   * Some archs want to perform DMA into kmalloc caches and need a guaranteed
>   * alignment larger than the alignment of a 64-bit integer.
> diff --git a/include/linux/thread_info.h b/include/linux/thread_info.h
> index 3d5c80b4391d..f24b99eac969 100644
> --- a/include/linux/thread_info.h
> +++ b/include/linux/thread_info.h
> @@ -155,6 +155,21 @@ static inline int arch_within_stack_frames(const void * const stack,
>  }
>  #endif
>  
> +#ifdef CONFIG_HARDENED_USERCOPY
> +extern void __check_object_size(const void *ptr, unsigned long n,
> +					bool to_user);
> +
> +static inline void check_object_size(const void *ptr, unsigned long n,
> +				     bool to_user)
> +{
> +	__check_object_size(ptr, n, to_user);
> +}
> +#else
> +static inline void check_object_size(const void *ptr, unsigned long n,
> +				     bool to_user)
> +{ }
> +#endif /* CONFIG_HARDENED_USERCOPY */
> +
>  #endif	/* __KERNEL__ */
>  
>  #endif /* _LINUX_THREAD_INFO_H */
> diff --git a/mm/Makefile b/mm/Makefile
> index 78c6f7dedb83..32d37247c7e5 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -21,6 +21,9 @@ KCOV_INSTRUMENT_memcontrol.o := n
>  KCOV_INSTRUMENT_mmzone.o := n
>  KCOV_INSTRUMENT_vmstat.o := n
>  
> +# Since __builtin_frame_address does work as used, disable the warning.
> +CFLAGS_usercopy.o += $(call cc-disable-warning, frame-address)
> +
>  mmu-y			:= nommu.o
>  mmu-$(CONFIG_MMU)	:= gup.o highmem.o memory.o mincore.o \
>  			   mlock.o mmap.o mprotect.o mremap.o msync.o rmap.o \
> @@ -99,3 +102,4 @@ obj-$(CONFIG_USERFAULTFD) += userfaultfd.o
>  obj-$(CONFIG_IDLE_PAGE_TRACKING) += page_idle.o
>  obj-$(CONFIG_FRAME_VECTOR) += frame_vector.o
>  obj-$(CONFIG_DEBUG_PAGE_REF) += debug_page_ref.o
> +obj-$(CONFIG_HARDENED_USERCOPY) += usercopy.o
> diff --git a/mm/usercopy.c b/mm/usercopy.c
> new file mode 100644
> index 000000000000..4161a1fb1909
> --- /dev/null
> +++ b/mm/usercopy.c
> @@ -0,0 +1,219 @@
> +/*
> + * This implements the various checks for CONFIG_HARDENED_USERCOPY*,
> + * which are designed to protect kernel memory from needless exposure
> + * and overwrite under many unintended conditions. This code is based
> + * on PAX_USERCOPY, which is:
> + *
> + * Copyright (C) 2001-2016 PaX Team, Bradley Spengler, Open Source
> + * Security Inc.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 as
> + * published by the Free Software Foundation.
> + *
> + */
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
> +#include <linux/mm.h>
> +#include <linux/slab.h>
> +#include <asm/sections.h>
> +
> +/*
> + * Checks if a given pointer and length is contained by the current
> + * stack frame (if possible).
> + *
> + *	0: not at all on the stack
> + *	1: fully within a valid stack frame
> + *	2: fully on the stack (when can't do frame-checking)
> + *	-1: error condition (invalid stack position or bad stack frame)

Can we use enums? Makes it easier to read/debug

> + */
> +static noinline int check_stack_object(const void *obj, unsigned long len)
> +{
> +	const void * const stack = task_stack_page(current);
> +	const void * const stackend = stack + THREAD_SIZE;
> +	int ret;
> +
> +	/* Object is not on the stack at all. */
> +	if (obj + len <= stack || stackend <= obj)
> +		return 0;
> +
> +	/*
> +	 * Reject: object partially overlaps the stack (passing the
> +	 * the check above means at least one end is within the stack,
> +	 * so if this check fails, the other end is outside the stack).
> +	 */
> +	if (obj < stack || stackend < obj + len)
> +		return -1;
> +
> +	/* Check if object is safely within a valid frame. */
> +	ret = arch_within_stack_frames(stack, stackend, obj, len);
> +	if (ret)
> +		return ret;
> +
> +	return 2;
> +}
> +
> +static void report_usercopy(const void *ptr, unsigned long len,
> +			    bool to_user, const char *type)
> +{
> +	pr_emerg("kernel memory %s attempt detected %s %p (%s) (%lu bytes)\n",
> +		to_user ? "exposure" : "overwrite",
> +		to_user ? "from" : "to", ptr, type ? : "unknown", len);
> +	dump_stack();
> +	do_group_exit(SIGKILL);

SIGKILL -- SIGBUS?

> +}
> +
> +/* Returns true if any portion of [ptr,ptr+n) over laps with [low,high). */
> +static bool overlaps(const void *ptr, unsigned long n, unsigned long low,
> +		     unsigned long high)
> +{
> +	unsigned long check_low = (uintptr_t)ptr;
> +	unsigned long check_high = check_low + n;
> +
> +	/* Does not overlap if entirely above or entirely below. */
> +	if (check_low >= high || check_high < low)
> +		return false;
> +
> +	return true;
> +}
> +
> +/* Is this address range in the kernel text area? */
> +static inline const char *check_kernel_text_object(const void *ptr,
> +						   unsigned long n)
> +{
> +	unsigned long textlow = (unsigned long)_stext;
> +	unsigned long texthigh = (unsigned long)_etext;
> +
> +	if (overlaps(ptr, n, textlow, texthigh))
> +		return "<kernel text>";
> +
> +#ifdef HAVE_ARCH_LINEAR_KERNEL_MAPPING
> +	/* Check against linear mapping as well. */
> +	if (overlaps(ptr, n, (unsigned long)__va(__pa(textlow)),
> +		     (unsigned long)__va(__pa(texthigh))))
> +		return "<linear kernel text>";
> +#endif
> +
> +	return NULL;
> +}
> +
> +static inline const char *check_bogus_address(const void *ptr, unsigned long n)
> +{
> +	/* Reject if object wraps past end of memory. */
> +	if (ptr + n < ptr)
> +		return "<wrapped address>";
> +
> +	/* Reject if NULL or ZERO-allocation. */
> +	if (ZERO_OR_NULL_PTR(ptr))
> +		return "<null>";
> +
> +	return NULL;
> +}
> +
> +static inline const char *check_heap_object(const void *ptr, unsigned long n,
> +					    bool to_user)
> +{
> +	struct page *page, *endpage;
> +	const void *end = ptr + n - 1;
> +
> +	if (!virt_addr_valid(ptr))
> +		return NULL;
> +
> +	page = virt_to_head_page(ptr);
> +
> +	/* Check slab allocator for flags and size. */
> +	if (PageSlab(page))
> +		return __check_heap_object(ptr, n, page);
> +
> +	/*
> +	 * Sometimes the kernel data regions are not marked Reserved (see
> +	 * check below). And sometimes [_sdata,_edata) does not cover
> +	 * rodata and/or bss, so check each range explicitly.
> +	 */
> +
> +	/* Allow reads of kernel rodata region (if not marked as Reserved). */
> +	if (ptr >= (const void *)__start_rodata &&
> +	    end <= (const void *)__end_rodata) {
> +		if (!to_user)
> +			return "<rodata>";
> +		return NULL;
> +	}
> +
> +	/* Allow kernel data region (if not marked as Reserved). */
> +	if (ptr >= (const void *)_sdata && end <= (const void *)_edata)
> +		return NULL;
> +
> +	/* Allow kernel bss region (if not marked as Reserved). */
> +	if (ptr >= (const void *)__bss_start &&
> +	    end <= (const void *)__bss_stop)
> +		return NULL;
> +
> +	/* Is the object wholly within one base page? */
> +	if (likely(((unsigned long)ptr & (unsigned long)PAGE_MASK) ==
> +		   ((unsigned long)end & (unsigned long)PAGE_MASK)))
> +		return NULL;
> +
> +	/* Allow if start and end are inside the same compound page. */
> +	endpage = virt_to_head_page(end);
> +	if (likely(endpage == page))
> +		return NULL;
> +
> +	/* Allow special areas, device memory, and sometimes kernel data. */
> +	if (PageReserved(page) && PageReserved(endpage))
> +		return NULL;a

If we came here, it's likely that endpage > page, do we need to check
that only the first and last pages are reserved? What about the ones in
the middle?


> +
> +	/* Uh oh. The "object" spans several independently allocated pages. */
> +	return "<spans multiple pages>";
> +}
> +
> +/*
> + * Validates that the given object is one of:
> + * - known safe heap object
> + * - known safe stack object
> + * - not in kernel text
> + */
> +void __check_object_size(const void *ptr, unsigned long n, bool to_user)
> +{
> +	const char *err;
> +
> +	/* Skip all tests if size is zero. */
> +	if (!n)
> +		return;
> +
> +	/* Check for invalid addresses. */
> +	err = check_bogus_address(ptr, n);
> +	if (err)
> +		goto report;
> +
> +	/* Check for bad heap object. */
> +	err = check_heap_object(ptr, n, to_user);
> +	if (err)
> +		goto report;
> +
> +	/* Check for bad stack object. */
> +	switch (check_stack_object(ptr, n)) {
> +	case 0:
> +		/* Object is not touching the current process stack. */
> +		break;
> +	case 1:
> +	case 2:
> +		/*
> +		 * Object is either in the correct frame (when it
> +		 * is possible to check) or just generally on the
> +		 * process stack (when frame checking not available).
> +		 */
> +		return;
> +	default:
> +		err = "<process stack>";
> +		goto report;
> +	}
> +
> +	/* Check for object in kernel to avoid text exposure. */
> +	err = check_kernel_text_object(ptr, n);
> +	if (!err)
> +		return;
> +
> +report:
> +	report_usercopy(ptr, n, to_user, err);
> +}

Looks good otherwise

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
