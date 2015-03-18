Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 83ED86B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 12:12:52 -0400 (EDT)
Received: by wibg7 with SMTP id g7so94513979wib.1
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 09:12:52 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id vu5si29695208wjc.94.2015.03.18.09.12.50
        for <linux-mm@kvack.org>;
        Wed, 18 Mar 2015 09:12:51 -0700 (PDT)
Date: Wed, 18 Mar 2015 18:12:46 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: don't count preallocated pmds
Message-ID: <20150318161246.GA5822@node.dhcp.inet.fi>
References: <alpine.LRH.2.02.1503181057340.14516@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1503181057340.14516@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-parisc@vger.kernel.org, jejb@parisc-linux.org, dave.anglin@bell.net

On Wed, Mar 18, 2015 at 11:16:42AM -0400, Mikulas Patocka wrote:
> Hi
> 
> Here I'm sending a patch that fixes numerous "BUG: non-zero nr_pmds on 
> freeing mm: -1" errors on 64-bit PA-RISC kernel.
> 
> I think the patch posted here 
> http://www.spinics.net/lists/linux-parisc/msg05981.html is incorrect, it 
> wouldn't work if the affected address range is freed and allocated 
> multiple times.
> 	- 1. alloc pgd with built-in pmd, the count of pmds is 1
> 	- 2. free the range covered by the built-in pmd, the count of pmds 
> 		is 0, but the built-in pmd is still present

Hm. Okay. I didn't realize you have special case in pmd_clear() for these
pmds.

What about adding mm_inc_nr_pmds() in pmd_clear() for PxD_FLAG_ATTACHED
to compensate mm_dec_nr_pmds() in free_pmd_range()?

I don't like pmd_preallocated() in generic code. It's too specific to
parisc.

> 	- 3. alloc some memory in the range affected by the built-in pmd, 
> 		the count of pmds is still 0
> 	- 4. free the range covered by the built-in pmd, the counter 
> 		underflows to -1
> 
> Mikulas
> 
> 
> From: Mikulas Patocka <mpatocka@redhat.com>
> 
> The patch dc6c9a35b66b520cf67e05d8ca60ebecad3b0479 that counts pmds 
> allocated for a process introduced a bug on 64-bit PA-RISC kernels. There 
> are many "BUG: non-zero nr_pmds on freeing mm: -1" messages.
> 
> The PA-RISC architecture preallocates one pmd with each pgd. This
> preallocated pmd can never be freed - pmd_free does nothing when it is
> called with this pmd. When the kernel attempts to free this preallocated
> pmd, it decreases the count of allocated pmds. The result is that the
> counter underflows and this error is reported.
> 
> This patch fixes the bug by introducing a macro pmd_preallocated and
> making sure that the counter is not decremented when this preallocated pmd
> is freed.
> 
> Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
> 
> ---
>  arch/parisc/include/asm/pgalloc.h |    2 ++
>  mm/memory.c                       |    5 ++++-
>  2 files changed, 6 insertions(+), 1 deletion(-)
> 
> Index: linux-4.0-rc4/arch/parisc/include/asm/pgalloc.h
> ===================================================================
> --- linux-4.0-rc4.orig/arch/parisc/include/asm/pgalloc.h	2015-03-18 15:31:10.000000000 +0100
> +++ linux-4.0-rc4/arch/parisc/include/asm/pgalloc.h	2015-03-18 15:33:20.000000000 +0100
> @@ -81,6 +81,8 @@ static inline void pmd_free(struct mm_st
>  	free_pages((unsigned long)pmd, PMD_ORDER);
>  }
>  
> +#define pmd_preallocated(pmd)	(pmd_flag(*(pmd)) & PxD_FLAG_ATTACHED)
> +
>  #else
>  
>  /* Two Level Page Table Support for pmd's */
> Index: linux-4.0-rc4/mm/memory.c
> ===================================================================
> --- linux-4.0-rc4.orig/mm/memory.c	2015-03-18 15:30:42.000000000 +0100
> +++ linux-4.0-rc4/mm/memory.c	2015-03-18 15:32:33.000000000 +0100
> @@ -427,8 +427,11 @@ static inline void free_pmd_range(struct
>  
>  	pmd = pmd_offset(pud, start);
>  	pud_clear(pud);
> +#ifdef pmd_preallocated
> +	if (!pmd_preallocated(pmd))
> +#endif
> +		mm_dec_nr_pmds(tlb->mm);
>  	pmd_free_tlb(tlb, pmd, start);
> -	mm_dec_nr_pmds(tlb->mm);
>  }
>  
>  static inline void free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
