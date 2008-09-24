Date: Wed, 24 Sep 2008 16:41:21 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2] Report the pagesize backing a VMA in /proc/pid/smaps
Message-ID: <20080924154120.GA10837@csn.ul.ie>
References: <20080923211140.DC16.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080923194655.GA25542@csn.ul.ie> <20080924210309.8C3B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080924210309.8C3B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On (24/09/08 21:32), KOSAKI Motohiro didst pronounce:
> > > Dave, please let me know getpagesize() function return to 4k or 64k on ppc64.
> > > I think the PageSize line of the /proc/pid/smap and getpagesize() result should be matched.
> > > 
> > > otherwise, enduser may be confused.
> > > 
> > 
> > To distinguish between the two, I now report the kernel pagesize and the
> > mmu pagesize like so
> > 
> > KernelPageSize:       64 kB
> > MMUPageSize:           4 kB
> > 
> > This is running a kernel with a 64K base pagesize on a PPC970MP which
> > does not support 64K hardware pagesizes.
> > 
> > Does this make sense?
> 
> Hmmm, Who want to this infomation?
> 

Someone doing performance analysis on POWER may want it. If they switched to
a large base page size without using hugetlbfs at all and saw the same number
of TLB misses, it could be explained by the lower MMU pagesize. Admittedly,
they should have known the hardware didn't support that pagesize.

> I agreed with
>   - An administrator want to know these page are normal or huge.
>   - An administrator want to know hugepage size.
>     (e.g. x86_64 has two hugepage size (2M and 1G))
> 
> but above ppc64 case seems deeply implementation depended infomation and
> nobody want to know it.
> 

I admit it's ppc64-specific. In the latest patch series, I made this a
separate patch so that it could be readily dropped again for this reason.
Maybe an alternative would be to display MMUPageSize *only* where it differs
from KernelPageSize. Would that be better or similarly confusing?

> it seems a bottleneck of future enhancement.
> 

I'm not sure what you mean by it being a bottleneck

> then I disagreed with
>   - show both KernelPageSize and MMUPageSize in normal page.
> 
> 
> I like following two choice
> 
> 
> 1) in normal page, show PAZE_SIZE
> 
> because, any userland application woks as pagesize==PAZE_SIZE 
> on current powerpc architecture.
> 
> because
> 
> fs/binfmt_elf.c
> ------------------------------
> static int
> create_elf_tables(struct linux_binprm *bprm, struct elfhdr *exec,
>                 unsigned long load_addr, unsigned long interp_load_addr)
> {
> (snip)
>         NEW_AUX_ENT(AT_HWCAP, ELF_HWCAP);
>         NEW_AUX_ENT(AT_PAGESZ, ELF_EXEC_PAGESIZE); /* pass ELF_EXEC_PAGESIZE to libc */
> 
> include/asm-powerpc/elf.h
> -----------------------------
> #define ELF_EXEC_PAGESIZE       PAGE_SIZE 
> 

I'm ok with this option and dropping the MMUPageSize patch as the user
should already be able to identify that the hardware does not support 64K
base pagesizes. I will leave the name as KernelPageSize so that it is still
difficult to confuse it with MMU page size.

> 
> 2) in normal page, no display any page size.
>    only hugepage case, display page size.
> 
> because, An administrator want to hugepage size only. (AFAICS)
> 

I prefer option 1 as it's easier to parse the presense of information
than infer from the absense of it.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
