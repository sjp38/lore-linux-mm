Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 94ABD6B0031
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 07:47:40 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id r10so8729651pdi.41
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 04:47:40 -0700 (PDT)
Message-ID: <525D2B15.8060503@asianux.com>
Date: Tue, 15 Oct 2013 19:46:29 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: revert mremap pud_free anti-fix
References: <alpine.LNX.2.00.1310150330350.9078@eggly.anvils>
In-Reply-To: <alpine.LNX.2.00.1310150330350.9078@eggly.anvils>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 10/15/2013 06:34 PM, Hugh Dickins wrote:
> Revert 1ecfd533f4c5 ("mm/mremap.c: call pud_free() after fail calling
> pmd_alloc()").  The original code was correct: pud_alloc(), pmd_alloc(),
> pte_alloc_map() ensure that the pud, pmd, pt is already allocated, and
> seldom do they need to allocate; on failure, upper levels are freed if
> appropriate by the subsequent do_munmap().  Whereas 1ecfd533f4c5 did an
> unconditional pud_free() of a most-likely still-in-use pud: saved only
> by the near-impossiblity of pmd_alloc() failing.
> 

What you said above sounds reasonable to me,  but better to provide the
information below:

 - pud_free() for pgd_alloc() in "arch/arm/mm/pgd.c".

 - pud_free() for init_stub_pte() in "arch/um/kernel/skas/mmu.c".

 - more details about do_munmap(), (e.g. do it need mm->page_table_lock)
   or more details about the demo "most-likely still-in-use pud ...".


Hmm... I am not quite sure about the 3 things, and I will/should
continue analysing/learning about them, but better to get your reply. :-)

Thanks.

> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
> 
>  mm/mremap.c |    5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
> 
> --- 3.12-rc5/mm/mremap.c	2013-09-16 17:37:56.841072270 -0700
> +++ linux/mm/mremap.c	2013-10-15 03:07:09.140091599 -0700
> @@ -25,7 +25,6 @@
>  #include <asm/uaccess.h>
>  #include <asm/cacheflush.h>
>  #include <asm/tlbflush.h>
> -#include <asm/pgalloc.h>
>  
>  #include "internal.h"
>  
> @@ -63,10 +62,8 @@ static pmd_t *alloc_new_pmd(struct mm_st
>  		return NULL;
>  
>  	pmd = pmd_alloc(mm, pud, addr);
> -	if (!pmd) {
> -		pud_free(mm, pud);
> +	if (!pmd)
>  		return NULL;
> -	}
>  
>  	VM_BUG_ON(pmd_trans_huge(*pmd));
>  
> 
> 


-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
