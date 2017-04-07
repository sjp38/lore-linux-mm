Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3A8326B0038
	for <linux-mm@kvack.org>; Fri,  7 Apr 2017 08:10:49 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id x203so51161599oig.2
        for <linux-mm@kvack.org>; Fri, 07 Apr 2017 05:10:49 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0135.outbound.protection.outlook.com. [104.47.2.135])
        by mx.google.com with ESMTPS id b132si967662oia.148.2017.04.07.05.10.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 07 Apr 2017 05:10:47 -0700 (PDT)
Subject: Re: [PATCHv2 8/8] x86/mm: Allow to have userspace mappings above
 47-bits
References: <20170406232137.uk7y2knbkcsru4pi@black.fi.intel.com>
 <20170406232442.9822-1-kirill.shutemov@linux.intel.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <4c8cd9a9-2013-2a74-6bea-d7dc7207abb1@virtuozzo.com>
Date: Fri, 7 Apr 2017 14:32:31 +0300
MIME-Version: 1.0
In-Reply-To: <20170406232442.9822-1-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 04/07/2017 02:24 AM, Kirill A. Shutemov wrote:
> On x86, 5-level paging enables 56-bit userspace virtual address space.
> Not all user space is ready to handle wide addresses. It's known that
> at least some JIT compilers use higher bits in pointers to encode their
> information. It collides with valid pointers with 5-level paging and
> leads to crashes.
>
> To mitigate this, we are not going to allocate virtual address space
> above 47-bit by default.
>
> But userspace can ask for allocation from full address space by
> specifying hint address (with or without MAP_FIXED) above 47-bits.
>
> If hint address set above 47-bit, but MAP_FIXED is not specified, we try
> to look for unmapped area by specified address. If it's already
> occupied, we look for unmapped area in *full* address space, rather than
> from 47-bit window.
>
> This approach helps to easily make application's memory allocator aware
> about large address space without manually tracking allocated virtual
> address space.
>
> One important case we need to handle here is interaction with MPX.
> MPX (without MAWA( extension cannot handle addresses above 47-bit, so we
> need to make sure that MPX cannot be enabled we already have VMA above
> the boundary and forbid creating such VMAs once MPX is enabled.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Dmitry Safonov <dsafonov@virtuozzo.com>
> ---
>  arch/x86/include/asm/elf.h       |  2 +-
>  arch/x86/include/asm/mpx.h       |  9 +++++++++
>  arch/x86/include/asm/processor.h | 10 +++++++---
>  arch/x86/kernel/sys_x86_64.c     | 28 +++++++++++++++++++++++++++-
>  arch/x86/mm/hugetlbpage.c        | 27 ++++++++++++++++++++++++---
>  arch/x86/mm/mmap.c               |  2 +-
>  arch/x86/mm/mpx.c                | 33 ++++++++++++++++++++++++++++++++-
>  7 files changed, 101 insertions(+), 10 deletions(-)
>
> diff --git a/arch/x86/include/asm/elf.h b/arch/x86/include/asm/elf.h
> index d4d3ed456cb7..67260dbe1688 100644
> --- a/arch/x86/include/asm/elf.h
> +++ b/arch/x86/include/asm/elf.h
> @@ -250,7 +250,7 @@ extern int force_personality32;
>     the loader.  We need to make sure that it is out of the way of the program
>     that it will "exec", and that there is sufficient room for the brk.  */
>
> -#define ELF_ET_DYN_BASE		(TASK_SIZE / 3 * 2)
> +#define ELF_ET_DYN_BASE		(DEFAULT_MAP_WINDOW / 3 * 2)
>
>  /* This yields a mask that user programs can use to figure out what
>     instruction set this CPU supports.  This could be done in user space,
> diff --git a/arch/x86/include/asm/mpx.h b/arch/x86/include/asm/mpx.h
> index a0d662be4c5b..7d7404756bb4 100644
> --- a/arch/x86/include/asm/mpx.h
> +++ b/arch/x86/include/asm/mpx.h
> @@ -73,6 +73,9 @@ static inline void mpx_mm_init(struct mm_struct *mm)
>  }
>  void mpx_notify_unmap(struct mm_struct *mm, struct vm_area_struct *vma,
>  		      unsigned long start, unsigned long end);
> +
> +unsigned long mpx_unmapped_area_check(unsigned long addr, unsigned long len,
> +		unsigned long flags);
>  #else
>  static inline siginfo_t *mpx_generate_siginfo(struct pt_regs *regs)
>  {
> @@ -94,6 +97,12 @@ static inline void mpx_notify_unmap(struct mm_struct *mm,
>  				    unsigned long start, unsigned long end)
>  {
>  }
> +
> +static inline unsigned long mpx_unmapped_area_check(unsigned long addr,
> +		unsigned long len, unsigned long flags)
> +{
> +	return addr;
> +}
>  #endif /* CONFIG_X86_INTEL_MPX */
>
>  #endif /* _ASM_X86_MPX_H */
> diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
> index 3cada998a402..a98395e89ac6 100644
> --- a/arch/x86/include/asm/processor.h
> +++ b/arch/x86/include/asm/processor.h
> @@ -795,6 +795,7 @@ static inline void spin_lock_prefetch(const void *x)
>  #define IA32_PAGE_OFFSET	PAGE_OFFSET
>  #define TASK_SIZE		PAGE_OFFSET
>  #define TASK_SIZE_MAX		TASK_SIZE
> +#define DEFAULT_MAP_WINDOW	TASK_SIZE
>  #define STACK_TOP		TASK_SIZE
>  #define STACK_TOP_MAX		STACK_TOP
>
> @@ -834,7 +835,10 @@ static inline void spin_lock_prefetch(const void *x)
>   * particular problem by preventing anything from being mapped
>   * at the maximum canonical address.
>   */
> -#define TASK_SIZE_MAX	((1UL << 47) - PAGE_SIZE)
> +#define TASK_SIZE_MAX	((1UL << __VIRTUAL_MASK_SHIFT) - PAGE_SIZE)
> +
> +#define DEFAULT_MAP_WINDOW	(test_thread_flag(TIF_ADDR32) ? \
> +				IA32_PAGE_OFFSET : ((1UL << 47) - PAGE_SIZE))

That fixes 32-bit, but we need to adjust some places, AFAICS, I'll
point them below.

>
>  /* This decides where the kernel will search for a free chunk of vm
>   * space during mmap's.
> @@ -847,7 +851,7 @@ static inline void spin_lock_prefetch(const void *x)
>  #define TASK_SIZE_OF(child)	((test_tsk_thread_flag(child, TIF_ADDR32)) ? \
>  					IA32_PAGE_OFFSET : TASK_SIZE_MAX)
>
> -#define STACK_TOP		TASK_SIZE
> +#define STACK_TOP		DEFAULT_MAP_WINDOW
>  #define STACK_TOP_MAX		TASK_SIZE_MAX
>
>  #define INIT_THREAD  {						\
> @@ -870,7 +874,7 @@ extern void start_thread(struct pt_regs *regs, unsigned long new_ip,
>   * space during mmap's.
>   */
>  #define __TASK_UNMAPPED_BASE(task_size)	(PAGE_ALIGN(task_size / 3))
> -#define TASK_UNMAPPED_BASE		__TASK_UNMAPPED_BASE(TASK_SIZE)
> +#define TASK_UNMAPPED_BASE		__TASK_UNMAPPED_BASE(DEFAULT_MAP_WINDOW)
>
>  #define KSTK_EIP(task)		(task_pt_regs(task)->ip)
>
> diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
> index 207b8f2582c7..593a31e93812 100644
> --- a/arch/x86/kernel/sys_x86_64.c
> +++ b/arch/x86/kernel/sys_x86_64.c
> @@ -21,6 +21,7 @@
>  #include <asm/compat.h>
>  #include <asm/ia32.h>
>  #include <asm/syscalls.h>
> +#include <asm/mpx.h>
>
>  /*
>   * Align a virtual address to avoid aliasing in the I$ on AMD F15h.
> @@ -132,6 +133,10 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
>  	struct vm_unmapped_area_info info;
>  	unsigned long begin, end;
>
> +	addr = mpx_unmapped_area_check(addr, len, flags);
> +	if (IS_ERR_VALUE(addr))
> +		return addr;
> +
>  	if (flags & MAP_FIXED)
>  		return addr;
>
> @@ -151,7 +156,16 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
>  	info.flags = 0;
>  	info.length = len;
>  	info.low_limit = begin;
> -	info.high_limit = end;
> +
> +	/*
> +	 * If hint address is above DEFAULT_MAP_WINDOW, look for unmapped area
> +	 * in the full address space.
> +	 */
> +	if (addr > DEFAULT_MAP_WINDOW)
> +		info.high_limit = min(end, TASK_SIZE);
> +	else
> +		info.high_limit = min(end, DEFAULT_MAP_WINDOW);

That looks not working.
`end' is choosed between tasksize_32bit() and tasksize_64bit().
Which is ~4Gb or 47-bit. So, info.high_limit will never go
above DEFAULT_MAP_WINDOW with this min().

Can we move this logic into find_start_end()?

May it be something like:
if (in_compat_syscall())
   *end = tasksize_32bit();
else if (addr > task_size_64bit())
   *end = TASK_SIZE_MAX;
else
   *end = tasksize_64bit();

In my point of view, it could be even simpler if we add a parameter
to task_size_64bit():

#define TASK_SIZE_47BIT ((1UL << 47) - PAGE_SIZE))

unsigned long task_size_64bit(int full_addr_space)
{
    return (full_addr_space) ? TASK_SIZE_MAX : TASK_SIZE_47BIT;
}

> +
>  	info.align_mask = 0;
>  	info.align_offset = pgoff << PAGE_SHIFT;
>  	if (filp) {
> @@ -171,6 +185,10 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
>  	unsigned long addr = addr0;
>  	struct vm_unmapped_area_info info;
>
> +	addr = mpx_unmapped_area_check(addr, len, flags);
> +	if (IS_ERR_VALUE(addr))
> +		return addr;
> +
>  	/* requested length too big for entire address space */
>  	if (len > TASK_SIZE)
>  		return -ENOMEM;
> @@ -195,6 +213,14 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
>  	info.length = len;
>  	info.low_limit = PAGE_SIZE;
>  	info.high_limit = get_mmap_base(0);
> +
> +	/*
> +	 * If hint address is above DEFAULT_MAP_WINDOW, look for unmapped area
> +	 * in the full address space.
> +	 */
> +	if (addr > DEFAULT_MAP_WINDOW && !in_compat_syscall())
> +		info.high_limit += TASK_SIZE - DEFAULT_MAP_WINDOW;

Hmm, looks like we do need in_compat_syscall() as you did
because x32 mmap() syscall has 8 byte parameter.
Maybe worth a comment.

Anyway, maybe something like that:
if (addr > tasksize_64bit() && !in_compat_syscall())
    info.high_limit += TASK_SIZE_MAX - tasksize_64bit();

This way it's more readable and clear because we don't
need to keep in mind that TIF_ADDR32 flag, while reading.


> +
>  	info.align_mask = 0;
>  	info.align_offset = pgoff << PAGE_SHIFT;
>  	if (filp) {
> diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
> index 302f43fd9c28..9a0b89252c52 100644
> --- a/arch/x86/mm/hugetlbpage.c
> +++ b/arch/x86/mm/hugetlbpage.c
> @@ -18,6 +18,7 @@
>  #include <asm/tlbflush.h>
>  #include <asm/pgalloc.h>
>  #include <asm/elf.h>
> +#include <asm/mpx.h>
>
>  #if 0	/* This is just for testing */
>  struct page *
> @@ -87,23 +88,38 @@ static unsigned long hugetlb_get_unmapped_area_bottomup(struct file *file,
>  	info.low_limit = get_mmap_base(1);
>  	info.high_limit = in_compat_syscall() ?
>  		tasksize_32bit() : tasksize_64bit();
> +
> +	/*
> +	 * If hint address is above DEFAULT_MAP_WINDOW, look for unmapped area
> +	 * in the full address space.
> +	 */
> +	if (addr > DEFAULT_MAP_WINDOW)
> +		info.high_limit = TASK_SIZE;
> +
>  	info.align_mask = PAGE_MASK & ~huge_page_mask(h);
>  	info.align_offset = 0;
>  	return vm_unmapped_area(&info);
>  }
>
>  static unsigned long hugetlb_get_unmapped_area_topdown(struct file *file,
> -		unsigned long addr0, unsigned long len,
> +		unsigned long addr, unsigned long len,
>  		unsigned long pgoff, unsigned long flags)
>  {
>  	struct hstate *h = hstate_file(file);
>  	struct vm_unmapped_area_info info;
> -	unsigned long addr;
>
>  	info.flags = VM_UNMAPPED_AREA_TOPDOWN;
>  	info.length = len;
>  	info.low_limit = PAGE_SIZE;
>  	info.high_limit = get_mmap_base(0);
> +
> +	/*
> +	 * If hint address is above DEFAULT_MAP_WINDOW, look for unmapped area
> +	 * in the full address space.
> +	 */
> +	if (addr > DEFAULT_MAP_WINDOW && !in_compat_syscall())
> +		info.high_limit += TASK_SIZE - DEFAULT_MAP_WINDOW;
> +
>  	info.align_mask = PAGE_MASK & ~huge_page_mask(h);
>  	info.align_offset = 0;
>  	addr = vm_unmapped_area(&info);
> @@ -118,7 +134,7 @@ static unsigned long hugetlb_get_unmapped_area_topdown(struct file *file,
>  		VM_BUG_ON(addr != -ENOMEM);
>  		info.flags = 0;
>  		info.low_limit = TASK_UNMAPPED_BASE;
> -		info.high_limit = TASK_SIZE;
> +		info.high_limit = DEFAULT_MAP_WINDOW;
>  		addr = vm_unmapped_area(&info);
>  	}
>
> @@ -135,6 +151,11 @@ hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
>
>  	if (len & ~huge_page_mask(h))
>  		return -EINVAL;
> +
> +	addr = mpx_unmapped_area_check(addr, len, flags);
> +	if (IS_ERR_VALUE(addr))
> +		return addr;
> +
>  	if (len > TASK_SIZE)
>  		return -ENOMEM;
>
> diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
> index 19ad095b41df..d63232a31945 100644
> --- a/arch/x86/mm/mmap.c
> +++ b/arch/x86/mm/mmap.c
> @@ -44,7 +44,7 @@ unsigned long tasksize_32bit(void)
>
>  unsigned long tasksize_64bit(void)
>  {
> -	return TASK_SIZE_MAX;
> +	return DEFAULT_MAP_WINDOW;

My suggestion about new parameter is above, but at least
we need to omit depending on TIF_ADDR32 here and return
64-bit size independent of flag value:

#define TASK_SIZE_47BIT ((1UL << 47) - PAGE_SIZE))
unsigned long task_size_64bit(void)
{
    return TASK_SIZE_47BIT;
}

Because for 32-bit ELFs it would be always 4Gb in your
case, while 32-bit ELFs can do 64-bit syscalls.

>  }
>
>  static unsigned long stack_maxrandom_size(unsigned long task_size)
> diff --git a/arch/x86/mm/mpx.c b/arch/x86/mm/mpx.c
> index cd44ae727df7..a26a1b373fd0 100644
> --- a/arch/x86/mm/mpx.c
> +++ b/arch/x86/mm/mpx.c
> @@ -355,10 +355,19 @@ int mpx_enable_management(void)
>  	 */
>  	bd_base = mpx_get_bounds_dir();
>  	down_write(&mm->mmap_sem);
> +
> +	/* MPX doesn't support addresses above 47-bits yet. */
> +	if (find_vma(mm, DEFAULT_MAP_WINDOW)) {
> +		pr_warn_once("%s (%d): MPX cannot handle addresses "
> +				"above 47-bits. Disabling.",
> +				current->comm, current->pid);
> +		ret = -ENXIO;
> +		goto out;
> +	}
>  	mm->context.bd_addr = bd_base;
>  	if (mm->context.bd_addr == MPX_INVALID_BOUNDS_DIR)
>  		ret = -ENXIO;
> -
> +out:
>  	up_write(&mm->mmap_sem);
>  	return ret;
>  }
> @@ -1038,3 +1047,25 @@ void mpx_notify_unmap(struct mm_struct *mm, struct vm_area_struct *vma,
>  	if (ret)
>  		force_sig(SIGSEGV, current);
>  }
> +
> +/* MPX cannot handle addresses above 47-bits yet. */
> +unsigned long mpx_unmapped_area_check(unsigned long addr, unsigned long len,
> +		unsigned long flags)
> +{
> +	if (!kernel_managing_mpx_tables(current->mm))
> +		return addr;
> +	if (addr + len <= DEFAULT_MAP_WINDOW)
> +		return addr;
> +	if (flags & MAP_FIXED)
> +		return -ENOMEM;
> +
> +	/*
> +	 * Requested len is larger than whole area we're allowed to map in.
> +	 * Resetting hinting address wouldn't do much good -- fail early.
> +	 */
> +	if (len > DEFAULT_MAP_WINDOW)
> +		return -ENOMEM;
> +
> +	/* Look for unmap area within DEFAULT_MAP_WINDOW */
> +	return 0;
> +}
>


-- 
              Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
