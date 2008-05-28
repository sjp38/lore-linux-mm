Date: Wed, 28 May 2008 12:39:06 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [patch 2/2] lockless get_user_pages
Message-ID: <20080528113906.GA699@shadowen.org>
References: <20080525144847.GB25747@wotan.suse.de> <20080525145227.GC25747@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080525145227.GC25747@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, shaggy@austin.ibm.com, jens.axboe@oracle.com, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, May 25, 2008 at 04:52:27PM +0200, Nick Piggin wrote:
> 
> Introduce a new "fast_gup" (for want of a better name right now) which
> is basically a get_user_pages with a less general API (but still tends to
> be suited to the common case):
> 
> - task and mm are always current and current->mm
> - force is always 0
> - pages is always non-NULL
> - don't pass back vmas
> 
> This restricted API can be implemented in a much more scalable way when
> the ptes are present, by walking the page tables locklessly.
> 
> Before anybody asks; it is impossible to just "detect" such a situation in the
> existing get_user_pages call, and branch to a fastpath in that case, because
> get_user_pages requres the mmap_sem is held over the call, wheras fast_gup does
> not.
> 
> This patch implements fast_gup on x86, and converts a number of key callsites
> to use it.
> 
> On x86, we do an optimistic lockless pagetable walk, without taking any page
> table locks or even mmap_sem. Page table existence is guaranteed by turning
> interrupts off (combined with the fact that we're always looking up the current
> mm, means we can do the lockless page table walk within the constraints of the
> TLB shootdown design). Basically we can do this lockless pagetable walk in a
> similar manner to the way the CPU's pagetable walker does not have to take any
> locks to find present ptes.
> 
> Many other architectures could do the same thing. Those that don't IPI
> could potentially RCU free the page tables and do speculative references
> on the pages (a la lockless pagecache) to achieve a lockless fast_gup. I
> have actually got an implementation of this for powerpc.
> 
> This patch was found to give about 10% performance improvement on a 2 socket
> 8 core Intel Xeon system running an OLTP workload on DB2 v9.5
> 
>  "To test the effects of the patch, an OLTP workload was run on an IBM
>  x3850 M2 server with 2 processors (quad-core Intel Xeon processors at
>  2.93 GHz) using IBM DB2 v9.5 running Linux 2.6.24rc7 kernel. Comparing
>  runs with and without the patch resulted in an overall performance
>  benefit of ~9.8%. Correspondingly, oprofiles showed that samples from
>  __up_read and __down_read routines that is seen during thread contention
>  for system resources was reduced from 2.8% down to .05%. Monitoring
>  the /proc/vmstat output from the patched run showed that the counter for
>  fast_gup contained a very high number while the fast_gup_slow value was
>  zero."
> 
> (fast_gup_slow is a counter we had for the number of times the slowpath
> was invoked).
> 
> The main reason for the improvement is that DB2 has multiple threads each
> issuing direct-IO. Direct-IO uses get_user_pages, and thus the threads
> contend the mmap_sem cacheline, and can also contend on page table locks.
> 
> I would anticipate larger performance gains on larger systems, however I
> think DB2 uses an adaptive mix of threads and processes, so it could be
> that thread contention remains pretty constant as machine size increases.
> In which case, we stuck with "only" a 10% gain.
> 
> Lots of other code could use this too (eg. grep drivers/).
> 
> The downside of using fast_gup is that if there is not a pte with the
> correct permissions for the access, we end up falling back to get_user_pages
> and so the fast_gup is just extra work. This should not be the common case
> in performance critical code, I'd hope.

>From what I can see of the algorithm, as it stops at the first non-present
page, as long as the optimisation you allude to in the comments was
implemented the overhead would be much less, and basically constant for
the failure case.

See below for my take on that optimisation.

> Signed-off-by: Nick Piggin <npiggin@suse.de>
> 
> ---
>  arch/x86/mm/Makefile      |    2 
>  arch/x86/mm/gup.c         |  193 ++++++++++++++++++++++++++++++++++++++++++++++
>  fs/bio.c                  |    8 -
>  fs/direct-io.c            |   10 --
>  fs/splice.c               |   41 ---------
>  include/asm-x86/uaccess.h |    5 +
>  include/linux/mm.h        |   19 ++++
>  7 files changed, 225 insertions(+), 53 deletions(-)

I do wonder if it would be logical to introduce the generic version and
the x86 implementation as separate patches as there will be further
architecture specific implementations.

> Index: linux-2.6/fs/bio.c
> ===================================================================
> --- linux-2.6.orig/fs/bio.c
> +++ linux-2.6/fs/bio.c
> @@ -713,12 +713,8 @@ static struct bio *__bio_map_user_iov(st
>  		const int local_nr_pages = end - start;
>  		const int page_limit = cur_page + local_nr_pages;
>  		
> -		down_read(&current->mm->mmap_sem);
> -		ret = get_user_pages(current, current->mm, uaddr,
> -				     local_nr_pages,
> -				     write_to_vm, 0, &pages[cur_page], NULL);
> -		up_read(&current->mm->mmap_sem);
> -
> +		ret = fast_gup(uaddr, local_nr_pages,
> +				write_to_vm, &pages[cur_page]);
>  		if (ret < local_nr_pages) {
>  			ret = -EFAULT;
>  			goto out_unmap;
> Index: linux-2.6/fs/direct-io.c
> ===================================================================
> --- linux-2.6.orig/fs/direct-io.c
> +++ linux-2.6/fs/direct-io.c
> @@ -150,17 +150,11 @@ static int dio_refill_pages(struct dio *
>  	int nr_pages;
>  
>  	nr_pages = min(dio->total_pages - dio->curr_page, DIO_PAGES);
> -	down_read(&current->mm->mmap_sem);
> -	ret = get_user_pages(
> -		current,			/* Task for fault acounting */
> -		current->mm,			/* whose pages? */
> +	ret = fast_gup(
>  		dio->curr_user_address,		/* Where from? */
>  		nr_pages,			/* How many pages? */
>  		dio->rw == READ,		/* Write to memory? */
> -		0,				/* force (?) */
> -		&dio->pages[0],
> -		NULL);				/* vmas */
> -	up_read(&current->mm->mmap_sem);
> +		&dio->pages[0]);		/* Put results here */
>  
>  	if (ret < 0 && dio->blocks_available && (dio->rw & WRITE)) {
>  		struct page *page = ZERO_PAGE(0);
> Index: linux-2.6/fs/splice.c
> ===================================================================
> --- linux-2.6.orig/fs/splice.c
> +++ linux-2.6/fs/splice.c
> @@ -1147,36 +1147,6 @@ static long do_splice(struct file *in, l
>  }
>  
>  /*
> - * Do a copy-from-user while holding the mmap_semaphore for reading, in a
> - * manner safe from deadlocking with simultaneous mmap() (grabbing mmap_sem
> - * for writing) and page faulting on the user memory pointed to by src.
> - * This assumes that we will very rarely hit the partial != 0 path, or this
> - * will not be a win.
> - */
> -static int copy_from_user_mmap_sem(void *dst, const void __user *src, size_t n)
> -{
> -	int partial;
> -
> -	if (!access_ok(VERIFY_READ, src, n))
> -		return -EFAULT;
> -
> -	pagefault_disable();
> -	partial = __copy_from_user_inatomic(dst, src, n);
> -	pagefault_enable();
> -
> -	/*
> -	 * Didn't copy everything, drop the mmap_sem and do a faulting copy
> -	 */
> -	if (unlikely(partial)) {
> -		up_read(&current->mm->mmap_sem);
> -		partial = copy_from_user(dst, src, n);
> -		down_read(&current->mm->mmap_sem);
> -	}
> -
> -	return partial;
> -}
> -
> -/*
>   * Map an iov into an array of pages and offset/length tupples. With the
>   * partial_page structure, we can map several non-contiguous ranges into
>   * our ones pages[] map instead of splitting that operation into pieces.
> @@ -1189,8 +1159,6 @@ static int get_iovec_page_array(const st
>  {
>  	int buffers = 0, error = 0;
>  
> -	down_read(&current->mm->mmap_sem);
> -
>  	while (nr_vecs) {
>  		unsigned long off, npages;
>  		struct iovec entry;
> @@ -1199,7 +1167,7 @@ static int get_iovec_page_array(const st
>  		int i;
>  
>  		error = -EFAULT;
> -		if (copy_from_user_mmap_sem(&entry, iov, sizeof(entry)))
> +		if (copy_from_user(&entry, iov, sizeof(entry)))
>  			break;
>  
>  		base = entry.iov_base;
> @@ -1233,9 +1201,8 @@ static int get_iovec_page_array(const st
>  		if (npages > PIPE_BUFFERS - buffers)
>  			npages = PIPE_BUFFERS - buffers;
>  
> -		error = get_user_pages(current, current->mm,
> -				       (unsigned long) base, npages, 0, 0,
> -				       &pages[buffers], NULL);
> +		error = fast_gup((unsigned long)base, npages,
> +					0, &pages[buffers]);
>  
>  		if (unlikely(error <= 0))
>  			break;
> @@ -1274,8 +1241,6 @@ static int get_iovec_page_array(const st
>  		iov++;
>  	}
>  
> -	up_read(&current->mm->mmap_sem);
> -
>  	if (buffers)
>  		return buffers;
>  
> Index: linux-2.6/include/linux/mm.h
> ===================================================================
> --- linux-2.6.orig/include/linux/mm.h
> +++ linux-2.6/include/linux/mm.h
> @@ -12,6 +12,7 @@
>  #include <linux/prio_tree.h>
>  #include <linux/debug_locks.h>
>  #include <linux/mm_types.h>
> +#include <linux/uaccess.h> /* for __HAVE_ARCH_FAST_GUP */
>  
>  struct mempolicy;
>  struct anon_vma;
> @@ -830,6 +831,24 @@ extern int mprotect_fixup(struct vm_area
>  			  struct vm_area_struct **pprev, unsigned long start,
>  			  unsigned long end, unsigned long newflags);
>  
> +#ifndef __HAVE_ARCH_FAST_GUP
> +/* Should be moved to asm-generic, and architectures can include it if they
> + * don't implement their own fast_gup.
> + */
> +#define fast_gup(start, nr_pages, write, pages)			\
> +({								\
> +	struct mm_struct *mm = current->mm;			\
> +	int ret;						\
> +								\
> +	down_read(&mm->mmap_sem);				\
> +	ret = get_user_pages(current, mm, start, nr_pages,	\
> +					write, 0, pages, NULL);	\
> +	up_read(&mm->mmap_sem);					\
> +								\
> +	ret;							\
> +})
> +#endif
> +

Could this not be inserted into linux/uaccess.h?  That feels like a more
natural fit given the location of the __HAVE_* flag as well.  Feels like
that would pull something out of mm.h and as call sites convert they
would necessarily get fixed should they need the additional header.

I had a quick try and it cirtainly seems like moving it there compiles
on x86 at least (with the optimised version removed).

>  /*
>   * A callback you can register to apply pressure to ageable caches.
>   *
> Index: linux-2.6/arch/x86/mm/Makefile
> ===================================================================
> --- linux-2.6.orig/arch/x86/mm/Makefile
> +++ linux-2.6/arch/x86/mm/Makefile
> @@ -1,5 +1,5 @@
>  obj-y	:=  init_$(BITS).o fault.o ioremap.o extable.o pageattr.o mmap.o \
> -	    pat.o pgtable.o
> +	    pat.o pgtable.o gup.o
>  
>  obj-$(CONFIG_X86_32)		+= pgtable_32.o
>  
> Index: linux-2.6/arch/x86/mm/gup.c
> ===================================================================
> --- /dev/null
> +++ linux-2.6/arch/x86/mm/gup.c
> @@ -0,0 +1,244 @@
> +/*
> + * Lockless fast_gup for x86
> + *
> + * Copyright (C) 2008 Nick Piggin
> + * Copyright (C) 2008 Novell Inc.
> + */
> +#include <linux/sched.h>
> +#include <linux/mm.h>
> +#include <linux/vmstat.h>
> +#include <asm/pgtable.h>
> +
> +static inline pte_t gup_get_pte(pte_t *ptep)
> +{
> +#ifndef CONFIG_X86_PAE
> +	return *ptep;
> +#else
> +	/*
> +	 * With fast_gup, we walk down the pagetables without taking any locks.
> +	 * For this we would like to load the pointers atoimcally, but that is
> +	 * not possible (without expensive cmpxchg8b) on PAE.  What we do have
> +	 * is the guarantee that a pte will only either go from not present to
> +	 * present, or present to not present or both -- it will not switch to
> +	 * a completely different present page without a TLB flush in between;
> +	 * something that we are blocking by holding interrupts off.
> +	 *
> +	 * Setting ptes from not present to present goes:
> +	 * ptep->pte_high = h;
> +	 * smp_wmb();
> +	 * ptep->pte_low = l;
> +	 *
> +	 * And present to not present goes:
> +	 * ptep->pte_low = 0;
> +	 * smp_wmb();
> +	 * ptep->pte_high = 0;
> +	 *
> +	 * We must ensure here that the load of pte_low sees l iff
> +	 * pte_high sees h. We load pte_high *after* loading pte_low,
> +	 * which ensures we don't see an older value of pte_high.
> +	 * *Then* we recheck pte_low, which ensures that we haven't
> +	 * picked up a changed pte high. We might have got rubbish values
> +	 * from pte_low and pte_high, but we are guaranteed that pte_low
> +	 * will not have the present bit set *unless* it is 'l'. And
> +	 * fast_gup only operates on present ptes, so we're safe.
> +	 *
> +	 * gup_get_pte should not be used or copied outside gup.c without
> +	 * being very careful -- it does not atomically load the pte or
> +	 * anything that is likely to be useful for you.
> +	 */
> +	pte_t pte;
> +
> +retry:
> +	pte.pte_low = ptep->pte_low;
> +	smp_rmb();
> +	pte.pte_high = ptep->pte_high;
> +	smp_rmb();
> +	if (unlikely(pte.pte_low != ptep->pte_low))
> +		goto retry;
> +
> +	return pte;
> +#endif
> +}
> +
> +/*
> + * The performance critical leaf functions are made noinline otherwise gcc
> + * inlines everything into a single function which results in too much
> + * register pressure.
> + */
> +static noinline int gup_pte_range(pmd_t pmd, unsigned long addr,
> +		unsigned long end, int write, struct page **pages, int *nr)
> +{
> +	unsigned long mask;
> +	pte_t *ptep;
> +
> +	mask = _PAGE_PRESENT|_PAGE_USER;
> +	if (write)
> +		mask |= _PAGE_RW;
> +
> +	ptep = pte_offset_map(&pmd, addr);
> +	do {
> +		pte_t pte = gup_get_pte(ptep);
> +		struct page *page;
> +
> +		if ((pte_val(pte) & (mask | _PAGE_SPECIAL)) != mask)
> +			return 0;

I see the missing unmap was already spotted.

> +		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
> +		page = pte_page(pte);
> +		get_page(page);
> +		pages[*nr] = page;
> +		(*nr)++;
> +
> +	} while (ptep++, addr += PAGE_SIZE, addr != end);
> +	pte_unmap(ptep - 1);
> +
> +	return 1;
> +}
> +
> +static inline void get_head_page_multiple(struct page *page, int nr)
> +{
> +	VM_BUG_ON(page != compound_head(page));
> +	VM_BUG_ON(page_count(page) == 0);
> +	atomic_add(nr, &page->_count);
> +}
> +
> +static noinline int gup_huge_pmd(pmd_t pmd, unsigned long addr,
> +		unsigned long end, int write, struct page **pages, int *nr)
> +{
> +	unsigned long mask;
> +	pte_t pte = *(pte_t *)&pmd;
> +	struct page *head, *page;
> +	int refs;
> +
> +	mask = _PAGE_PRESENT|_PAGE_USER;
> +	if (write)
> +		mask |= _PAGE_RW;
> +	if ((pte_val(pte) & mask) != mask)
> +		return 0;
> +	/* hugepages are never "special" */
> +	VM_BUG_ON(pte_val(pte) & _PAGE_SPECIAL);
> +	VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
> +
> +	refs = 0;
> +	head = pte_page(pte);
> +	page = head + ((addr & ~HPAGE_MASK) >> PAGE_SHIFT);
> +	do {
> +		VM_BUG_ON(compound_head(page) != head);
> +		pages[*nr] = page;
> +		(*nr)++;
> +		page++;
> +		refs++;
> +	} while (addr += PAGE_SIZE, addr != end);
> +	get_head_page_multiple(head, refs);
> +
> +	return 1;
> +}
> +
> +static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
> +		int write, struct page **pages, int *nr)
> +{
> +	unsigned long next;
> +	pmd_t *pmdp;
> +
> +	pmdp = pmd_offset(&pud, addr);
> +	do {
> +		pmd_t pmd = *pmdp;
> +
> +		next = pmd_addr_end(addr, end);
> +		if (pmd_none(pmd))
> +			return 0;
> +		if (unlikely(pmd_large(pmd))) {
> +			if (!gup_huge_pmd(pmd, addr, next, write, pages, nr))
> +				return 0;
> +		} else {
> +			if (!gup_pte_range(pmd, addr, next, write, pages, nr))
> +				return 0;
> +		}
> +	} while (pmdp++, addr = next, addr != end);
> +
> +	return 1;
> +}
> +
> +static int gup_pud_range(pgd_t pgd, unsigned long addr, unsigned long end, int write, struct page **pages, int *nr)
> +{
> +	unsigned long next;
> +	pud_t *pudp;
> +
> +	pudp = pud_offset(&pgd, addr);
> +	do {
> +		pud_t pud = *pudp;
> +
> +		next = pud_addr_end(addr, end);
> +		if (pud_none(pud))
> +			return 0;
> +		if (!gup_pmd_range(pud, addr, next, write, pages, nr))
> +			return 0;
> +	} while (pudp++, addr = next, addr != end);
> +
> +	return 1;
> +}
> +
> +int fast_gup(unsigned long start, int nr_pages, int write, struct page **pages)
> +{
> +	struct mm_struct *mm = current->mm;
> +	unsigned long end = start + (nr_pages << PAGE_SHIFT);
> +	unsigned long addr = start;
> +	unsigned long next;
> +	pgd_t *pgdp;
> +	int nr = 0;
> +
> +	if (unlikely(!access_ok(write ? VERIFY_WRITE : VERIFY_READ,
> +					start, nr_pages*PAGE_SIZE)))
> +		goto slow_irqon;
> +
> +	/*
> +	 * XXX: batch / limit 'nr', to avoid large irq off latency
> +	 * needs some instrumenting to determine the common sizes used by
> +	 * important workloads (eg. DB2), and whether limiting the batch size
> +	 * will decrease performance.
> +	 *
> +	 * It seems like we're in the clear for the moment. Direct-IO is
> +	 * the main guy that batches up lots of get_user_pages, and even
> +	 * they are limited to 64-at-a-time which is not so many.
> +	 */
> +	/*
> +	 * This doesn't prevent pagetable teardown, but does prevent
> +	 * the pagetables and pages from being freed on x86.
> +	 *
> +	 * So long as we atomically load page table pointers versus teardown
> +	 * (which we do on x86, with the above PAE exception), we can follow the
> +	 * address down to the the page and take a ref on it.
> +	 */
> +	local_irq_disable();
> +	pgdp = pgd_offset(mm, addr);
> +	do {
> +		pgd_t pgd = *pgdp;
> +
> +		next = pgd_addr_end(addr, end);
> +		if (pgd_none(pgd))
> +			goto slow;
> +		if (!gup_pud_range(pgd, addr, next, write, pages, &nr))
> +			goto slow;
> +	} while (pgdp++, addr = next, addr != end);
> +	local_irq_enable();
> +
> +	VM_BUG_ON(nr != (end - start) >> PAGE_SHIFT);
> +	return nr;
> +
> +	{
> +		int i, ret;
> +
> +slow:
> +		local_irq_enable();
> +slow_irqon:
> +		/* Could optimise this more by keeping what we've already got */
> +		for (i = 0; i < nr; i++)
> +			put_page(pages[i]);

it feels like optimising this would be pretty simple, is not the
following sufficient:

		start += nr << PAGE_SHIFT;
		pages += nr;
	
> +
> +		down_read(&mm->mmap_sem);
> +		ret = get_user_pages(current, mm, start,
> +			(end - start) >> PAGE_SHIFT, write, 0, pages, NULL);
> +		up_read(&mm->mmap_sem);
> +
> +		return ret;
> +	}
> +}
> Index: linux-2.6/include/asm-x86/uaccess.h
> ===================================================================
> --- linux-2.6.orig/include/asm-x86/uaccess.h
> +++ linux-2.6/include/asm-x86/uaccess.h
> @@ -3,3 +3,8 @@
>  #else
>  # include "uaccess_64.h"
>  #endif
> +
> +#define __HAVE_ARCH_FAST_GUP
> +struct page;
> +int fast_gup(unsigned long start, int nr_pages, int write, struct page **pages);
> +

Reviewed-by: Andy Whitcroft <apw@shadowen.org>

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
