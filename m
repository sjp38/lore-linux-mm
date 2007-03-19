Message-ID: <45FE3092.3030202@yahoo.com.au>
Date: Mon, 19 Mar 2007 17:41:22 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: ZERO_PAGE refcounting causes cache line bouncing
References: <Pine.LNX.4.64.0703161514170.7846@schroedinger.engr.sgi.com> <20070317043545.GH8915@holomorphy.com> <45FE261F.3030903@yahoo.com.au> <45FE2CA0.3080204@yahoo.com.au>
In-Reply-To: <45FE2CA0.3080204@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: William Lee Irwin III <wli@holomorphy.com>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:

> Something like this roughly should get rid of ZERO_PAGE _count and 
> _mapcount
> manipulation for anonymous pages. (others still exist, XIP and 
> /dev/zero, but
> they should not be a large concern AFAIKS).
> 
> I haven't booted this, but it is a quick forward port + some fixes and
> simplifications.
> 
> 
> ------------------------------------------------------------------------
> 
> Index: linux-2.6/mm/memory.c
> ===================================================================
> --- linux-2.6.orig/mm/memory.c
> +++ linux-2.6/mm/memory.c
> @@ -665,7 +665,8 @@ static unsigned long zap_pte_range(struc
>  			ptent = ptep_get_and_clear_full(mm, addr, pte,
>  							tlb->fullmm);
>  			tlb_remove_tlb_entry(tlb, pte, addr);
> -			if (unlikely(!page))
> +			if (unlikely(!page ||
> +				(!vma->vm_file && page == ZERO_PAGE(addr))))
>  				continue;

Hmm, well I suppose it would be cleaner if this check used the one in
handle_pte_fault instead of !vma->vm_file ie. (!vma->vm_ops ||
!vma->vm_ops->nopage)


>  			if (unlikely(details) && details->nonlinear_vma
>  			    && linear_page_index(details->nonlinear_vma,
> @@ -2152,15 +2153,12 @@ static int do_anonymous_page(struct mm_s
>  	} else {
>  		/* Map the ZERO_PAGE - vm_page_prot is readonly */
>  		page = ZERO_PAGE(address);
> -		page_cache_get(page);
>  		entry = mk_pte(page, vma->vm_page_prot);
>  
>  		ptl = pte_lockptr(mm, pmd);
>  		spin_lock(ptl);
>  		if (!pte_none(*page_table))
> -			goto release;
> -		inc_mm_counter(mm, file_rss);
> -		page_add_file_rmap(page);
> +			goto unlock;
>  	}
>  
>  	set_pte_at(mm, address, page_table, entry);


-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
