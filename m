Message-ID: <380435A6.93B4B75A@colorfullife.com>
Date: Wed, 13 Oct 1999 09:32:54 +0200
From: Manfred Spraul <manfreds@colorfullife.com>
MIME-Version: 1.0
Subject: Re: locking question: do_mmap(), do_munmap()
References: <199910130125.SAA66579@google.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, viro@math.psu.edu, andrea@suse.de, linux-kernel@vger.rutgers.edu, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Kanoj Sarcar wrote:
> Here's a primitive patch showing the direction I am thinking of. I do not
> have any problem with a spinning lock, but I coded this against 2.2.10,
> where insert_vm_struct could go to sleep, hence I had to use sleeping
> locks to protect the vma chain.

I found a few places where I don't know how to change them.

1) arch/mips/mm/r4xx0.c:
their flush_cache_range() function internally calls find_vma().
flush_cache_range() is called by proc/mem.c, and it seems that this
function cannot get the mmap semaphore.
Currently, every caller of flush_cache_range() either owns the kernel
lock or the mmap_sem.
OTHO, this function contains a race anyway [src_vma can go away if
handle_mm_fault() sleeps, src_vma is used at the end of the function.]

2) arch/sparc/mm/fault.c:
>    /* This conditional is 'interesting'. */
>         if (pgd_val(*pgdp) && !(write && !(pte_val(*ptep) & _SUN4C_PAGE_WRITE))
>             && (pte_val(*ptep) & _SUN4C_PAGE_VALID))
>                 /* Note: It is safe to not grab the MMAP semaphore here because
>                  *       we know that update_mmu_cache() will not sleep for
>                  *       any reason (at least not in the current implementation)
>                  *       and therefore there is no danger of another thread getting
>                  *       on the CPU and doing a shrink_mmap() on this vma.
>                  */
>                 sun4c_update_mmu_cache (find_vma(current->mm, address), address,
>                                         *ptep);
>         else
>                 do_sparc_fault(regs, text_fault, write, address);
> }
could be safe because sun4c is only UP?

3) include/ppc-asm/pgtable.h:
> extern __inline__ pte_t *find_pte(struct mm_struct *mm,unsigned long va)
> {
>         pgd_t *dir;
>         pmd_t *pmd;
>         pte_t *pte;
> 
>         va &= PAGE_MASK;
>         
>         dir = pgd_offset( mm, va );
>         if (dir)
>         {
>                 pmd = pmd_offset(dir, va & PAGE_MASK);
>                 if (pmd && pmd_present(*pmd))
>                 {
>                         pte = pte_offset(pmd, va);
>                         if (pte && pte_present(*pte))
>                         {                       
>                                 pte_uncache(*pte);
>                                 flush_tlb_page(find_vma(mm,va),va);
>                         }
>                 }
>         }
>         return pte;
> }
Could be safe because only called for "init_mm"?

I've not yet looked at swap_out [mm/swapfile.c and
arch/m68k/atari/stram.c] and proc/array.c

--
	Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
