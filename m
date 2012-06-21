Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id E0BA36B00C5
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 08:37:47 -0400 (EDT)
Date: Thu, 21 Jun 2012 14:37:43 +0200
From: Borislav Petkov <bp@amd64.org>
Subject: Re: [PATCH -mm 4/7] mm: make page colouring code generic
Message-ID: <20120621123743.GA7121@aftab.osrc.amd.com>
References: <1340057126-31143-1-git-send-email-riel@redhat.com>
 <1340057126-31143-5-git-send-email-riel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340057126-31143-5-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Rik van Riel <riel@surriel.com>

On Mon, Jun 18, 2012 at 06:05:23PM -0400, Rik van Riel wrote:
> From: Rik van Riel <riel@surriel.com>
> 
> Fix the x86-64 page colouring code to take pgoff into account.
> Use the x86 and MIPS page colouring code as the basis for a generic
> page colouring function.
> 
> Teach the generic arch_get_unmapped_area(_topdown) code to call the
> page colouring code.
> 
> Make sure that ALIGN_DOWN always aligns down, and ends up at the
> right page colour.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>
> ---
>  arch/mips/include/asm/page.h      |    2 -
>  arch/mips/include/asm/pgtable.h   |    1 +
>  arch/x86/include/asm/elf.h        |    3 -
>  arch/x86/include/asm/pgtable_64.h |    1 +
>  arch/x86/kernel/sys_x86_64.c      |   35 +++++++++-----
>  arch/x86/vdso/vma.c               |    2 +-
>  include/linux/sched.h             |    8 +++-
>  mm/mmap.c                         |   91 ++++++++++++++++++++++++++++++++-----
>  8 files changed, 111 insertions(+), 32 deletions(-)
> 
> diff --git a/arch/mips/include/asm/page.h b/arch/mips/include/asm/page.h
> index da9bd7d..459cc25 100644
> --- a/arch/mips/include/asm/page.h
> +++ b/arch/mips/include/asm/page.h
> @@ -63,8 +63,6 @@ extern void build_copy_page(void);
>  extern void clear_page(void * page);
>  extern void copy_page(void * to, void * from);
>  
> -extern unsigned long shm_align_mask;
> -
>  static inline unsigned long pages_do_alias(unsigned long addr1,
>  	unsigned long addr2)
>  {
> diff --git a/arch/mips/include/asm/pgtable.h b/arch/mips/include/asm/pgtable.h
> index b2202a6..f133a4c 100644
> --- a/arch/mips/include/asm/pgtable.h
> +++ b/arch/mips/include/asm/pgtable.h
> @@ -415,6 +415,7 @@ int phys_mem_access_prot_allowed(struct file *file, unsigned long pfn,
>   */
>  #define HAVE_ARCH_UNMAPPED_AREA
>  #define HAVE_ARCH_UNMAPPED_AREA_TOPDOWN
> +#define HAVE_ARCH_ALIGN_ADDR
>  
>  /*
>   * No page table caches to initialise
> diff --git a/arch/x86/include/asm/elf.h b/arch/x86/include/asm/elf.h
> index 5939f44..dc2d0bf 100644
> --- a/arch/x86/include/asm/elf.h
> +++ b/arch/x86/include/asm/elf.h
> @@ -358,8 +358,6 @@ static inline int mmap_is_ia32(void)
>  enum align_flags {
>  	ALIGN_VA_32	= BIT(0),
>  	ALIGN_VA_64	= BIT(1),
> -	ALIGN_VDSO	= BIT(2),
> -	ALIGN_TOPDOWN	= BIT(3),
>  };
>  
>  struct va_alignment {
> @@ -368,5 +366,4 @@ struct va_alignment {
>  } ____cacheline_aligned;
>  
>  extern struct va_alignment va_align;
> -extern unsigned long align_addr(unsigned long, struct file *, enum align_flags);
>  #endif /* _ASM_X86_ELF_H */
> diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
> index 8af36f6..8408ccd 100644
> --- a/arch/x86/include/asm/pgtable_64.h
> +++ b/arch/x86/include/asm/pgtable_64.h
> @@ -170,6 +170,7 @@ extern void cleanup_highmap(void);
>  #define HAVE_ARCH_UNMAPPED_AREA
>  #define HAVE_ARCH_UNMAPPED_AREA_TOPDOWN
>  #define HAVE_ARCH_GET_ADDRESS_RANGE
> +#define HAVE_ARCH_ALIGN_ADDR
>  
>  #define pgtable_cache_init()   do { } while (0)
>  #define check_pgt_cache()      do { } while (0)
> diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
> index 2595a5e..ac0afb8 100644
> --- a/arch/x86/kernel/sys_x86_64.c
> +++ b/arch/x86/kernel/sys_x86_64.c
> @@ -25,31 +25,40 @@
>   * @flags denotes the allocation direction - bottomup or topdown -
>   * or vDSO; see call sites below.
>   */
> -unsigned long align_addr(unsigned long addr, struct file *filp,
> -			 enum align_flags flags)
> +unsigned long arch_align_addr(unsigned long addr, struct file *filp,
> +			unsigned long pgoff, unsigned long flags,
> +			enum mmap_allocation_direction direction)

Arguments vertical alignment too, not only addr alignment :-)

>  {
> -	unsigned long tmp_addr;
> +	unsigned long tmp_addr = PAGE_ALIGN(addr);

I'm guessing addr coming from arch_get_unmapped_area(_topdown) might not
be page-aligned in all cases?

>  
>  	/* handle 32- and 64-bit case with a single conditional */
>  	if (va_align.flags < 0 || !(va_align.flags & (2 - mmap_is_ia32())))
> -		return addr;
> +		return tmp_addr;
>  
> -	if (!(current->flags & PF_RANDOMIZE))
> -		return addr;
> +	/* Always allow MAP_FIXED. Colouring is a performance thing only. */
> +	if (flags & MAP_FIXED)
> +		return tmp_addr;

Why here? Maybe we should push this MAP_FIXED check up in the
arch_get_unmapped_area(_topdown) and not call arch_align_addr() for
MAP_FIXED requests?

Or do you want to save some code duplication?

> -	if (!((flags & ALIGN_VDSO) || filp))
> -		return addr;
> +	if (!(current->flags & PF_RANDOMIZE))
> +		return tmp_addr;
>  
> -	tmp_addr = addr;
> +	if (!(filp || direction == ALLOC_VDSO))
> +		return tmp_addr;
>  
>  	/*
>  	 * We need an address which is <= than the original
>  	 * one only when in topdown direction.
>  	 */
> -	if (!(flags & ALIGN_TOPDOWN))
> +	if (direction == ALLOC_UP)
>  		tmp_addr += va_align.mask;
>  
>  	tmp_addr &= ~va_align.mask;
> +	tmp_addr += ((pgoff << PAGE_SHIFT) & va_align.mask);
> +
> +	if (direction == ALLOC_DOWN && tmp_addr > addr) {
> +		tmp_addr -= va_align.mask;
> +		tmp_addr &= ~va_align.mask;
> +	}
>  
>  	return tmp_addr;
>  }
> @@ -159,7 +168,7 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
>  
>  full_search:
>  
> -	addr = align_addr(addr, filp, 0);
> +	addr = arch_align_addr(addr, filp, pgoff, flags, ALLOC_UP);
>  
>  	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
>  		/* At this point:  (!vma || addr < vma->vm_end). */
> @@ -186,7 +195,7 @@ full_search:
>  			mm->cached_hole_size = vma->vm_start - addr;
>  
>  		addr = vma->vm_end;
> -		addr = align_addr(addr, filp, 0);
> +		addr = arch_align_addr(addr, filp, pgoff, flags, ALLOC_UP);
>  	}
>  }
>  
> @@ -235,7 +244,7 @@ try_again:
>  
>  	addr -= len;
>  	do {
> -		addr = align_addr(addr, filp, ALIGN_TOPDOWN);
> +		addr = arch_align_addr(addr, filp, pgoff, flags, ALLOC_DOWN);
>  
>  		/*
>  		 * Lookup failure means no vma is above this address,
> diff --git a/arch/x86/vdso/vma.c b/arch/x86/vdso/vma.c
> index 00aaf04..83e0355 100644
> --- a/arch/x86/vdso/vma.c
> +++ b/arch/x86/vdso/vma.c
> @@ -141,7 +141,7 @@ static unsigned long vdso_addr(unsigned long start, unsigned len)
>  	 * unaligned here as a result of stack start randomization.
>  	 */
>  	addr = PAGE_ALIGN(addr);
> -	addr = align_addr(addr, NULL, ALIGN_VDSO);
> +	addr = arch_align_addr(addr, NULL, 0, 0, ALLOC_VDSO);
>  
>  	return addr;
>  }
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index fc76318..18f9326 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -390,12 +390,18 @@ extern int sysctl_max_map_count;
>  #ifdef CONFIG_MMU
>  enum mmap_allocation_direction {
>  	ALLOC_UP,
> -	ALLOC_DOWN
> +	ALLOC_DOWN,
> +	ALLOC_VDSO,
>  };
>  extern void arch_pick_mmap_layout(struct mm_struct *mm);
>  extern void
>  arch_get_address_range(unsigned long flags, unsigned long *begin,
>  		unsigned long *end, enum mmap_allocation_direction direction);
> +extern unsigned long shm_align_mask;
> +extern unsigned long
> +arch_align_addr(unsigned long addr, struct file *filp,
> +		unsigned long pgoff, unsigned long flags,
> +		enum mmap_allocation_direction direction);
>  extern unsigned long
>  arch_get_unmapped_area(struct file *, unsigned long, unsigned long,
>  		       unsigned long, unsigned long);
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 92cf0bf..0314cb1 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1465,6 +1465,51 @@ unacct_error:
>  	return error;
>  }
>  
> +#ifndef HAVE_ARCH_ALIGN_ADDR
> +/* Each architecture is responsible for setting this to the required value. */
> +unsigned long shm_align_mask = PAGE_SIZE - 1;
> +EXPORT_SYMBOL(shm_align_mask);
> +
> +unsigned long arch_align_addr(unsigned long addr, struct file *filp,
> +			unsigned long pgoff, unsigned long flags,
> +			enum mmap_allocation_direction direction)

Ditto on arguments alignment as above.

> +{
> +	unsigned long tmp_addr = PAGE_ALIGN(addr);
> +
> +	if (shm_align_mask <= PAGE_SIZE)
> +		return tmp_addr;
> +
> +	/* Allow MAP_FIXED without MAP_SHARED at any address. */
> +	if ((flags & (MAP_FIXED|MAP_SHARED)) == MAP_FIXED)
> +		return tmp_addr;
> +
> +	/* Enforce page colouring for any file or MAP_SHARED mapping. */
> +	if (!(filp || (flags & MAP_SHARED)))
> +		return tmp_addr;
> +
> +	/*
> +	 * We need an address which is <= than the original
> +	 * one only when in topdown direction.
> +	 */
> +	if (direction == ALLOC_UP)
> +		tmp_addr += shm_align_mask;
> +
> +	tmp_addr &= ~shm_align_mask;
> +	tmp_addr += ((pgoff << PAGE_SHIFT) & shm_align_mask);
> +
> +	/*
> +	 * When aligning down, make sure we did not accidentally go up.
> +	 * The caller will check for underflow.
> +	 */

Can we add this comment to the x86-64 version of arch_align_addr too pls?

> +	if (direction == ALLOC_DOWN && tmp_addr > addr) {
> +		tmp_addr -= shm_align_mask;
> +		tmp_addr &= ~shm_align_mask;
> +	}
> +
> +	return tmp_addr;
> +}
> +#endif
> +
>  #ifndef HAVE_ARCH_GET_ADDRESS_RANGE
>  void arch_get_address_range(unsigned long flags, unsigned long *begin,
>  		unsigned long *end, enum mmap_allocation_direction direction)
> @@ -1513,18 +1558,22 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
>  	struct mm_struct *mm = current->mm;
>  	struct vm_area_struct *vma = NULL;
>  	struct rb_node *rb_node;
> -	unsigned long lower_limit, upper_limit;
> +	unsigned long lower_limit, upper_limit, tmp_addr;
>  
>  	arch_get_address_range(flags, &lower_limit, &upper_limit, ALLOC_UP);
>  
>  	if (len > TASK_SIZE)
>  		return -ENOMEM;
>  
> -	if (flags & MAP_FIXED)
> +	if (flags & MAP_FIXED) {
> +		tmp_addr = arch_align_addr(addr, filp, pgoff, flags, ALLOC_UP);
> +		if (tmp_addr != PAGE_ALIGN(addr))
> +			return -EINVAL;
>  		return addr;
> +	}
>  
>  	if (addr) {
> -		addr = PAGE_ALIGN(addr);
> +		addr = arch_align_addr(addr, filp, pgoff, flags, ALLOC_UP);
>  		vma = find_vma(mm, addr);
>  		if (TASK_SIZE - len >= addr &&
>  		    (!vma || addr + len <= vma->vm_start))
> @@ -1533,7 +1582,7 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
>  
>  	/* Find the left-most free area of sufficient size. */
>  	for (addr = 0, rb_node = mm->mm_rb.rb_node; rb_node; ) {
> -		unsigned long vma_start;
> +		unsigned long vma_start, tmp_addr;
>  		int found_here = 0;
>  
>  		vma = rb_to_vma(rb_node);
> @@ -1541,13 +1590,17 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
>  		if (vma->vm_start > len) {
>  			if (!vma->vm_prev) {
>  				/* This is the left-most VMA. */
> -				if (vma->vm_start - len >= lower_limit) {
> -					addr = lower_limit;
> +				tmp_addr = arch_align_addr(lower_limit, filp,
> +						pgoff, flags, ALLOC_UP);
> +				if (vma->vm_start - len >= tmp_addr) {
> +					addr = tmp_addr;
>  					goto found_addr;
>  				}
>  			} else {
>  				/* Is this hole large enough? Remember it. */
>  				vma_start = max(vma->vm_prev->vm_end, lower_limit);
> +				vma_start = arch_align_addr(vma_start, filp,
> +						pgoff, flags, ALLOC_UP);
>  				if (vma->vm_start - len >= vma_start) {
>  					addr = vma_start;
>  					found_here = 1;
> @@ -1599,6 +1652,8 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
>  	if (addr < lower_limit)
>  		addr = lower_limit;
>  
> +	addr = arch_align_addr(addr, filp, pgoff, flags, ALLOC_UP);
> +
>   found_addr:
>  	if (TASK_SIZE - len < addr)
>  		return -ENOMEM;
> @@ -1656,12 +1711,17 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
>  	if (len > TASK_SIZE)
>  		return -ENOMEM;
>  
> -	if (flags & MAP_FIXED)
> +	if (flags & MAP_FIXED) {
> +		unsigned long tmp_addr;
> +		tmp_addr = arch_align_addr(addr, filp, pgoff, flags, ALLOC_DOWN);
> +		if (tmp_addr != PAGE_ALIGN(addr))
> +			return -EINVAL;
>  		return addr;
> +	}
>  
>  	/* requesting a specific address */
>  	if (addr) {
> -		addr = PAGE_ALIGN(addr);
> +		addr = arch_align_addr(addr, filp, pgoff, flags, ALLOC_DOWN);
>  		vma = find_vma(mm, addr);
>  		if (TASK_SIZE - len >= addr &&
>  				(!vma || addr + len <= vma->vm_start))
> @@ -1678,7 +1738,9 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
>  	 */
>  	if (upper_limit - len > mm->highest_vma) {
>  		addr = upper_limit - len;
> -		goto found_addr;
> +		addr = arch_align_addr(addr, filp, pgoff, flags, ALLOC_DOWN);
> +		if (addr > mm->highest_vma);
> +			goto found_addr;
>  	}
>  
>  	/* Find the right-most free area of sufficient size. */
> @@ -1691,9 +1753,14 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
>  		/* Is this hole large enough? Remember it. */
>  		vma_start = min(vma->vm_start, upper_limit);
>  		if (vma_start > len) {
> -			if (!vma->vm_prev ||
> -			    (vma_start - len >= vma->vm_prev->vm_end)) {
> -				addr = vma_start - len;
> +			unsigned long tmp_addr = vma_start - len;
> +			tmp_addr = arch_align_addr(tmp_addr, filp,
> +						   pgoff, flags, ALLOC_DOWN);
> +			/* No underflow? Does it still fit the hole? */
> +			if (tmp_addr && tmp_addr <= vma_start - len &&
> +					(!vma->vm_prev ||
> +					 tmp_addr >= vma->vm_prev->vm_end)) {
> +				addr = tmp_addr;
>  				found_here = 1;
>  			}
>  		}
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Regards/Gruss,
Boris.

Advanced Micro Devices GmbH
Einsteinring 24, 85609 Dornach
GM: Alberto Bozzo
Reg: Dornach, Landkreis Muenchen
HRB Nr. 43632 WEEE Registernr: 129 19551

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
