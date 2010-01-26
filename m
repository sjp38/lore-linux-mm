Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 626986B009A
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 14:23:47 -0500 (EST)
Date: Tue, 26 Jan 2010 19:23:29 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 10 of 31] export maybe_mkwrite
Message-ID: <20100126192329.GO16468@csn.ul.ie>
References: <patchbomb.1264513915@v2.random> <1779fe2f7714b38953ec.1264513925@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1779fe2f7714b38953ec.1264513925@v2.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 26, 2010 at 02:52:05PM +0100, Andrea Arcangeli wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> huge_memory.c needs it too when it fallbacks in copying hugepages into regular
> fragmented pages if hugepage allocation fails during COW.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Mel Gorman <mel@csn.ul.ie>

> ---
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -387,6 +387,19 @@ static inline void set_compound_order(st
>  }
>  
>  /*
> + * Do pte_mkwrite, but only if the vma says VM_WRITE.  We do this when
> + * servicing faults for write access.  In the normal case, do always want
> + * pte_mkwrite.  But get_user_pages can cause write faults for mappings
> + * that do not have writing enabled, when used by access_process_vm.
> + */
> +static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
> +{
> +	if (likely(vma->vm_flags & VM_WRITE))
> +		pte = pte_mkwrite(pte);
> +	return pte;
> +}
> +
> +/*
>   * Multiple processes may "see" the same page. E.g. for untouched
>   * mappings of /dev/null, all processes see the same page full of
>   * zeroes, and text pages of executables and shared libraries have
> diff --git a/mm/memory.c b/mm/memory.c
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1943,19 +1943,6 @@ static inline int pte_unmap_same(struct 
>  	return same;
>  }
>  
> -/*
> - * Do pte_mkwrite, but only if the vma says VM_WRITE.  We do this when
> - * servicing faults for write access.  In the normal case, do always want
> - * pte_mkwrite.  But get_user_pages can cause write faults for mappings
> - * that do not have writing enabled, when used by access_process_vm.
> - */
> -static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
> -{
> -	if (likely(vma->vm_flags & VM_WRITE))
> -		pte = pte_mkwrite(pte);
> -	return pte;
> -}
> -
>  static inline void cow_user_page(struct page *dst, struct page *src, unsigned long va, struct vm_area_struct *vma)
>  {
>  	/*
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
