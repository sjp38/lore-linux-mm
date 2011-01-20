Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BAECA6B00E7
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 15:13:10 -0500 (EST)
Date: Thu, 20 Jan 2011 15:13:06 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: 2.6.38-rc1 problems with khugepaged
Message-ID: <20110120201306.GA2025@home.goodmis.org>
References: <web-442414153@zbackend1.aha.ru>
 <20110119155954.GA2272@kryptos.osrc.amd.com>
 <20110119222150.GP9506@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110119222150.GP9506@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Borislav Petkov <bp@amd64.org>, werner <w.landgraf@ru.ru>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 19, 2011 at 11:21:50PM +0100, Andrea Arcangeli wrote:
> Hello Werner,
> 
> this should fix your oops, it's untested still so let me know if you
> test it.

I tested this with ktest.pl on the config that was breaking for me. I
ran the test 20 times and it succeeded for all 20 tests.

Tested-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve


> 
> It's a noop for x86_64 and it only affected x86 32bit with highpte enabled.
> 
> ====
> Subject: khugepaged: fix pte_unmap for highpte x86_32
> 
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> __collapse_huge_page_copy is still dereferencing the pte passed as parameter so
> we must pte_unmap after __collapse_huge_page_copy returns, not before.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 004c9c2..c4f634b 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1837,9 +1837,9 @@ static void collapse_huge_page(struct mm_struct *mm,
>  	spin_lock(ptl);
>  	isolated = __collapse_huge_page_isolate(vma, address, pte);
>  	spin_unlock(ptl);
> -	pte_unmap(pte);
>  
>  	if (unlikely(!isolated)) {
> +		pte_unmap(pte);
>  		spin_lock(&mm->page_table_lock);
>  		BUG_ON(!pmd_none(*pmd));
>  		set_pmd_at(mm, address, pmd, _pmd);
> @@ -1856,6 +1856,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>  	anon_vma_unlock(vma->anon_vma);
>  
>  	__collapse_huge_page_copy(pte, new_page, vma, address, ptl);
> +	pte_unmap(pte);
>  	__SetPageUptodate(new_page);
>  	pgtable = pmd_pgtable(_pmd);
>  	VM_BUG_ON(page_count(pgtable) != 1);
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
