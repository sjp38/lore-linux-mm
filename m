Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D85FE6B0253
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 05:17:10 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id o88so1220507wrb.18
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 02:17:10 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 64si4888571ede.469.2017.11.03.02.17.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Nov 2017 02:17:09 -0700 (PDT)
Date: Fri, 3 Nov 2017 10:17:08 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] s390/mm: fix pud table accounting
Message-ID: <20171103091708.eh4qgoxp3bc5vvkb@dhcp22.suse.cz>
References: <20171103090551.18231-1-heiko.carstens@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171103090551.18231-1-heiko.carstens@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-next@vger.kernel.org, linux-s390@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Fri 03-11-17 10:05:51, Heiko Carstens wrote:
> With "mm: account pud page tables" and "mm: consolidate page table
> accounting" pud page table accounting was introduced which now results
> in tons of warnings like this one on s390:
> 
> BUG: non-zero pgtables_bytes on freeing mm: -16384
> 
> Reason for this are our run-time folded page tables: by default new
> processes start with three page table levels where the allocated pgd
> is the same as the first pud. In this case there won't ever be a pud
> allocated and therefore mm_inc_nr_puds() will also never be called.
> 
> However when freeing the address space free_pud_range() will call
> exactly once mm_dec_nr_puds() which leads to misaccounting.
> 
> Therefore call mm_inc_nr_puds() within init_new_context() to fix
> this. This is the same like we have it already for processes that run
> with two page table levels (aka compat processes).
> 
> While at it also adjust the comment, since there is no "mm->nr_pmds"
> anymore.

Subtle...

Thanks for the fix, I didn't have any idea about this when reviewing.

> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> ---
>  arch/s390/include/asm/mmu_context.h | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/s390/include/asm/mmu_context.h b/arch/s390/include/asm/mmu_context.h
> index 3c9abedc323c..4f943d58cbac 100644
> --- a/arch/s390/include/asm/mmu_context.h
> +++ b/arch/s390/include/asm/mmu_context.h
> @@ -43,6 +43,8 @@ static inline int init_new_context(struct task_struct *tsk,
>  		mm->context.asce_limit = STACK_TOP_MAX;
>  		mm->context.asce = __pa(mm->pgd) | _ASCE_TABLE_LENGTH |
>  				   _ASCE_USER_BITS | _ASCE_TYPE_REGION3;
> +		/* pgd_alloc() did not account this pud */
> +		mm_inc_nr_puds(mm);
>  		break;
>  	case -PAGE_SIZE:
>  		/* forked 5-level task, set new asce with new_mm->pgd */
> @@ -58,7 +60,7 @@ static inline int init_new_context(struct task_struct *tsk,
>  		/* forked 2-level compat task, set new asce with new mm->pgd */
>  		mm->context.asce = __pa(mm->pgd) | _ASCE_TABLE_LENGTH |
>  				   _ASCE_USER_BITS | _ASCE_TYPE_SEGMENT;
> -		/* pgd_alloc() did not increase mm->nr_pmds */
> +		/* pgd_alloc() did not account this pmd */
>  		mm_inc_nr_pmds(mm);
>  	}
>  	crst_table_init((unsigned long *) mm->pgd, pgd_entry_type(mm));
> -- 
> 2.13.5
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
