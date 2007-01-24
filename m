Message-ID: <45B6CE8C.8010807@yahoo.com.au>
Date: Wed, 24 Jan 2007 14:12:12 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] Page Table cleanup patch
References: <20070124023828.11302.51100.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070124023828.11302.51100.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Davies <pauld@cse.unsw.edu.au>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Paul Davies wrote:
> This patch is a proposed cleanup of the current page table organisation.
> Such a cleanup would be a logical first step towards introducing at least
> a partial clean page table interface, geared towards providing enhanced 
> virtualization oportunities for x86.  It is also a common sense cleanup 
> in its own right.
> 
>  * Creates mlpt.c to hold the page table implementation currently held 
>    in memory.c.
>  * Adjust Makefile 
>  * Move implementation dependent page table code out of 
>    include/linux/mm.h into include/linux/mlpt-mm.h
>  * Move implementation dependent page table code out of 
>    include/asm-generic/pgtable.h to include/asm-generic/pgtable-mlpt.h
> 
> mlpt stands from multi level page table.

Hi Paul,

I'm not sure that I see the point of this patch alone, as there is still
all the mlpt implementation details in all the page table walkers. Or
did you have a scheme to change implementations somehow just using the
p*d_addr_next?

> -#ifndef __PAGETABLE_PUD_FOLDED
> -/*
> - * Allocate page upper directory.
> - * We've already handled the fast-path in-line.
> - */
> -int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
> -{
> -	pud_t *new = pud_alloc_one(mm, address);
> -	if (!new)
> -		return -ENOMEM;
> -
> -	spin_lock(&mm->page_table_lock);
> -	if (pgd_present(*pgd))		/* Another has populated it */
> -		pud_free(new);
> -	else
> -		pgd_populate(mm, pgd, new);
> -	spin_unlock(&mm->page_table_lock);
> -	return 0;
> -}
> -#else
> -/* Workaround for gcc 2.96 */
> -int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
> -{
> -	return 0;
> -}
> -#endif /* __PAGETABLE_PUD_FOLDED */

...

> -/* Workaround for gcc 2.96 */
> -int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
> -{
> -	return 0;
> -}
> -#endif /* __PAGETABLE_PMD_FOLDED */

Hmm, we're gcc-3.2 minimum now -- let's get rid of that crud?

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
