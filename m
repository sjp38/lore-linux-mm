Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5EB356B0092
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 17:50:26 -0500 (EST)
Received: by fxm12 with SMTP id 12so1413765fxm.14
        for <linux-mm@kvack.org>; Wed, 19 Jan 2011 14:50:22 -0800 (PST)
Date: Thu, 20 Jan 2011 00:49:50 +0200
From: Ilya Dryomov <idryomov@gmail.com>
Subject: Re: [BUG] BUG: unable to handle kernel paging request at fffba000
Message-ID: <20110119224950.GA3429@kwango.lan.net>
References: <20110119124047.GA30274@kwango.lan.net> <20110119221909.GO9506@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110119221909.GO9506@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, idryomov@gmail.com
List-ID: <linux-mm.kvack.org>

On Wed, Jan 19, 2011 at 11:19:09PM +0100, Andrea Arcangeli wrote:
> Hello Ilya,
> 
> thanks for sending me the gdb info too.
> 
> can you test this fix? Thanks a lot! (it only affected x86 32bit
> builds with highpte enabled)
> 
> ====
> Subject: fix pte_unmap in khugepaged for highpte x86_32
> 
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> __collapse_huge_page_copy is still dereferencing the pte passed as parameter so
> we must pte_unmap after __collapse_huge_page_copy returns, not before.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

It fixes the above problem for me.  Thanks a lot Andrea.

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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
