Date: Sun, 18 Apr 2004 20:55:13 +0100
From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: PTE aging, ptep_test_and_clear_young() and TLB
Message-ID: <20040418205513.A27725@flint.arm.linux.org.uk>
References: <20040418122344.A11293@flint.arm.linux.org.uk> <Pine.LNX.4.44.0404181331240.20000-100000@localhost.localdomain> <20040418134228.B12222@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040418134228.B12222@flint.arm.linux.org.uk>; from rmk@arm.linux.org.uk on Sun, Apr 18, 2004 at 01:42:28PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Apr 18, 2004 at 01:42:28PM +0100, Russell King wrote:
> Basically, to be able to use either ptep_to_mm() or ptep_to_address()
> in asm/pgtable.h, you need to:
> 
> 1. remove linux/mm.h from asm-generic/rmap.h
> 2. somehow work around linux/highmem.h which includes linux/mm.h so
>    asm-generic/rmap.h can have a definition of kmap_atomic_to_page()
> 3. remove asm/pgtable.h from linux/mm.h and linux/page-flags.h
> 
> I've managed to get so far with that, but the real killer seems to
> be (2).

Ok, I've found a solution.

There are three things which keep linux/mm.h requires from asm/pgtable.h:
- pte_addr_t
- pgd_none (in pmd_alloc)
- pmd_offset (in pmd_alloc)

However, there are some hidden dependencies between asm/pgalloc.h and
asm/pgtable.h which have a nasty sting in the tail - and eliminating
asm/pgtable.h from linux/mm.h is enough to trigger it.

Essentially, the plan to solve this sanely boils down to:

1. move pte_addr_t from asm-*/pgtable.h into asm-*/page.h

   This should be safe to do because pte_addr_t is used by linux/mm.h
   and all files which use pte_addr_t include linux/mm.h.  Secondly,
   linux/mm.h includes both these files, asm-*/page.h before
   asm-*/pgtable.h

   pte_addr_t also appears to sit more naturally in asm-*/page.h -
   it's where pte_t is defined, and most of the architectures
   derive its definition from pte_t.

2. Eliminate asm/pgalloc.h from most files.

   Many files appear not to use anything from this header file, but
   include it anyway.  Grepping around for uses of the definitions
   in asm/pgalloc.h reveals 52 files using or providing pgalloc.h
   definitions (including pgalloc.h files).  However, a wapping
   557 files include pgalloc.h.

   The only files which need pgalloc.h include are:

	 ./arch/alpha/mm/init.c
	 ./arch/arm/mm/mm-armv.c
	 ./arch/arm26/mm/mm-memc.c
	 ./arch/i386/mm/pgtable.c
	+./arch/ia64/kernel/process.c
	+./arch/ia64/mm/init.c
	+./arch/parisc/kernel/process.c
	+./arch/parisc/mm/init.c
	 ./arch/ppc/mm/pgtable.c
	+./arch/ppc64/mm/tlb.c
	 ./arch/s390/mm/init.c
	 ./arch/sparc/kernel/process.c
	 ./arch/sparc/mm/init.c
	 ./arch/sparc/mm/srmmu.c
	 ./arch/sparc/mm/sun4c.c
	 ./arch/sparc64/kernel/process.c
	 ./arch/sparc64/mm/init.c
	 ./arch/um/kernel/mem.c
	+./include/asm-alpha/tlb.h
	+./include/asm-arm/tlb.h
	+./include/asm-arm26/tlb.h
	+./include/asm-generic/tlb.h
	+./include/asm-ia64/tlb.h
	+./include/asm-m68k/pgtable.h
	+./include/asm-parisc/tlb.h
	+./include/asm-ppc64/tlb.h
	+./include/asm-sparc64/pgtable.h
	+./include/asm-sparc64/tlb.h
	+./include/asm-x86_64/pgtable.h
	 ./kernel/fork.c
	 ./mm/memory.c

   Files prefixed with '+' use pgalloc.h definitions but do not
   directly include it.  I'm intending cleaning ARM up as far as
   this header goes.  It may be worth others gradually (over time)
   submitting tested patches to remove the gross needless include
   of asm/pgalloc.h

   Why is this such an issue... When we come to (3), all the files
   which incorrectly include asm/pgalloc.h suddenly break.

3. Move asm/pgtable.h include, along with xxx_alloc prototypes
   into linux/pgtable.h, add linux/mm.h, and update files to use
   linux/pgtable.h instead of linux/mm.h if they manipulate
   pgd/pmd/ptes.  Eliminate asm/pgtable.h includes from all files
   except linux/pgtable.h

   This is the most difficult part (no kidding) because its going
   to cause problems all over the place.  I suspect it may be
   possible to grep around to find everywhere which needs to be
   updated like in (2).

Once (3) is done, we no longer have the restriction that pgtable.h
is included without having struct page, struct mm_struct,
struct vma_struct etc defined, and, we can also get at things like
the mm_struct and the userspace address from a pte.

Now, given all that, I'm going to expect a "whoa, that's too much
especially in a stable kernel series" so I think this is something
I'll keep for 2.7.  However, I think (1) and (2) should at least
get sorted out for sanity sake.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
