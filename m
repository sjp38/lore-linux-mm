Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CAB876B003D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 08:36:59 -0400 (EDT)
Date: Mon, 16 Mar 2009 13:36:54 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] fix/improve generic page table walker
Message-ID: <20090316123654.GF30802@wotan.suse.de>
References: <20090311144951.58c6ab60@skybase> <1236792263.3205.45.camel@calx> <20090312093335.6dd67251@skybase> <1236867014.3213.16.camel@calx> <20090312154229.3ee463eb@skybase> <1236873494.3213.55.camel@calx> <20090316132717.69f6f4ce@skybase>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090316132717.69f6f4ce@skybase>
Sender: owner-linux-mm@kvack.org
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gerald Schaefer <gerald.schaefer@de.ibm.com>, akpm@linux-foundation.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 16, 2009 at 01:27:17PM +0100, Martin Schwidefsky wrote:
> On Thu, 12 Mar 2009 10:58:14 -0500
> Matt Mackall <mpm@selenic.com> wrote:
> 
> > On Thu, 2009-03-12 at 15:42 +0100, Martin Schwidefsky wrote:
> > > Then what exactly is a pgd_t? For me it is the top level page table
> > > which can have very different meaning for the various architectures.
> > 
> > The important thing is that it's always 3 levels removed from the
> > bottom, whether or not those 3 levels actually have hardware
> > manifestations. From your description, it sounds like that's not how
> > things work in S390 land.
> 
> With the page table folding "3 levels removed from the bottom" doesn't
> tell me much since there is no real representation in hardware AND in
> memory for the missing page table levels. So the only valid meaning of
> a pgd_t is that you have to use pud_offset, pmd_offset and pte_offset
> to get to a pte. If I do the page table folding at runtime or at
> compile time is a minor detail.

I don't know if it would be helpful to you, but I solve a similar
kind of problem in the lockless radix tree by encoding node height
in the node itself. Maybe you could use some bits in the page table
pointers or even in the struct pages for this.


> 
> > > Well, the hardware can do up to 5 levels of page tables for the full
> > > 64 bit address space. With the introduction of pud's we wanted to
> > > extend our address space from 3 levels / 42 bits to 4 levels / 53 bits.
> > > But this comes at a cost: additional page table levels cost memory and
> > > performance. In particular for the compat processes which can only
> > > address a maximum of 2 GB it is a waste to allocate 4 levels. With the
> > > dynamic page tables we allocate as much as required by each process.
> > 
> > X86 uses 1-entry tables at higher levels to maintain consistency with
> > fairly minimal overhead. In some of the sillier addressing modes, we may
> > even use a 4-entry table in some places. I think table size is fixed at
> > compile time, but I don't think that's essential. Very little code in
> > the x86 architecture has any notion of how many hardware levels actually
> > exist.
> 
> Indeed very little code needs to know how many page table levels
> exist. The page table folding works as long as the access to a
> particular page is done with the sequence
> 
> 	pgd = pgd_offset(mm, address);
> 	pud = pud_offset(pgd, address);
> 	pmd = pmd_offset(pud, address);
> 	pte = pte_offset(pmd, address);
> 
> The indivitual pointers pgd/pud/pmd/pte can be incremented as long as
> they stay in the valid address range, e.g. pmd_addr_end checks for the
> next pmd segment boundary and the end address of the walk.
> 
> If the page table folding is static or dynamic is irrelevant. The only
> thing we are arguing is what makes a valid end address for a walk. It
> has to be smaller than TASK_SIZE. With the current definitions the s390
> code has the additional assumption that the address has to be smaller
> than the highest vma as well. The patch below changes TASK_SIZE to
> reflect the size of the address space in use by the process. Then the
> generic page table walker works fine. What doesn't work anymore is the
> automatic upgrade from 3 to 4 levels via mmap. I'm still thinking about
> a clever solution, the best I have so far is a patch that introduces
> TASK_SIZE_MAX which reflects the maximum possible size as opposed to
> TASK_SIZE that gives you the current size. The code in do_mmap_pgoff
> then uses TASK_SIZE_MAX instead of TASK_SIZE.
> 
> -- 
> blue skies,
>    Martin.
> 
> "Reality continues to ruin my life." - Calvin.
> 
> ---
> Subject: [PATCH] make page table walking more robust
> 
> From: Martin Schwidefsky <schwidefsky@de.ibm.com>
> 
> Make page table walking on s390 more robust. The current code requires
> that the pgd/pud/pmd/pte loop is only done for address ranges that are
> below the end address of the last vma of the address space. But this
> is not always true, e.g. the generic page table walker does not
> guarantee this. Change TASK_SIZE/TASK_SIZE_OF to reflect the current
> size of the address space. This makes the generic page table walker
> happy but it breaks the upgrade of a 3 level page table to a 4 level
> page table. To make the upgrade work again another fix is required.
> 
> Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
> ---
> 
>  arch/s390/include/asm/processor.h |    5 ++---
>  arch/s390/mm/mmap.c               |    4 ++--
>  arch/s390/mm/pgtable.c            |    2 ++
>  3 files changed, 6 insertions(+), 5 deletions(-)
> 
> diff -urpN linux-2.6/arch/s390/include/asm/processor.h
> linux-2.6-patched/arch/s390/include/asm/processor.h ---
> linux-2.6/arch/s390/include/asm/processor.h	2009-03-16
> 12:24:26.000000000 +0100 +++
> linux-2.6-patched/arch/s390/include/asm/processor.h	2009-03-16
> 12:24:28.000000000 +0100 @@ -47,7 +47,7 @@ extern void
> print_cpu_info(void); extern int get_cpu_capability(unsigned int *); /*
> - * User space process size: 2GB for 31 bit, 4TB for 64 bit.
> + * User space process size: 2GB for 31 bit, 4TB or 8PT for 64 bit.
>   */
>  #ifndef __s390x__
>  
> @@ -56,8 +56,7 @@ extern int get_cpu_capability(unsigned i
>  
>  #else /* __s390x__ */
>  
> -#define TASK_SIZE_OF(tsk)
> (test_tsk_thread_flag(tsk,TIF_31BIT) ? \
> -					(1UL << 31) : (1UL << 53))
> +#define TASK_SIZE_OF(tsk)	((tsk)->mm->context.asce_limit)
>  #define TASK_UNMAPPED_BASE	(test_thread_flag(TIF_31BIT) ? \
>  					(1UL << 30) : (1UL << 41))
>  #define TASK_SIZE		TASK_SIZE_OF(current)
> diff -urpN linux-2.6/arch/s390/mm/mmap.c
> linux-2.6-patched/arch/s390/mm/mmap.c ---
> linux-2.6/arch/s390/mm/mmap.c	2008-12-25 00:26:37.000000000
> +0100 +++ linux-2.6-patched/arch/s390/mm/mmap.c	2009-03-16
> 12:24:28.000000000 +0100 @@ -35,7 +35,7 @@
>   * Leave an at least ~128 MB hole.
>   */
>  #define MIN_GAP (128*1024*1024)
> -#define MAX_GAP (TASK_SIZE/6*5)
> +#define MAX_GAP (STACK_TOP/6*5)
>  
>  static inline unsigned long mmap_base(void)
>  {
> @@ -46,7 +46,7 @@ static inline unsigned long mmap_base(vo
>  	else if (gap > MAX_GAP)
>  		gap = MAX_GAP;
>  
> -	return TASK_SIZE - (gap & PAGE_MASK);
> +	return STACK_TOP - (gap & PAGE_MASK);
>  }
>  
>  static inline int mmap_is_legacy(void)
> diff -urpN linux-2.6/arch/s390/mm/pgtable.c
> linux-2.6-patched/arch/s390/mm/pgtable.c ---
> linux-2.6/arch/s390/mm/pgtable.c	2009-03-16 12:24:09.000000000
> +0100 +++ linux-2.6-patched/arch/s390/mm/pgtable.c	2009-03-16
> 12:24:28.000000000 +0100 @@ -117,6 +117,7 @@ repeat:
> crst_table_init(table, entry); pgd_populate(mm, (pgd_t *) table, (pud_t
> *) pgd); mm->pgd = (pgd_t *) table;
> +		mm->task_size = mm->context.asce_limit;
>  		table = NULL;
>  	}
>  	spin_unlock(&mm->page_table_lock);
> @@ -154,6 +155,7 @@ void crst_table_downgrade(struct mm_stru
>  			BUG();
>  		}
>  		mm->pgd = (pgd_t *) (pgd_val(*pgd) &
> _REGION_ENTRY_ORIGIN);
> +		mm->task_size = mm->context.asce_limit;
>  		crst_table_free(mm, (unsigned long *) pgd);
>  	}
>  	update_mm(mm, current);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
