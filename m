Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 833CA6B0087
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 10:20:30 -0500 (EST)
Date: Thu, 18 Nov 2010 15:19:35 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 33 of 66] madvise(MADV_HUGEPAGE)
Message-ID: <20101118151935.GW8135@csn.ul.ie>
References: <patchbomb.1288798055@v2.random> <7193ff8e62fcf7885199.1288798088@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <7193ff8e62fcf7885199.1288798088@v2.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 03, 2010 at 04:28:08PM +0100, Andrea Arcangeli wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Add madvise MADV_HUGEPAGE to mark regions that are important to be hugepage
> backed. Return -EINVAL if the vma is not of an anonymous type, or the feature
> isn't built into the kernel. Never silently return success.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> ---
> 
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -99,6 +99,7 @@ extern void __split_huge_page_pmd(struct
>  #endif
>  
>  extern unsigned long vma_address(struct page *page, struct vm_area_struct *vma);
> +extern int hugepage_madvise(unsigned long *vm_flags);
>  static inline int PageTransHuge(struct page *page)
>  {
>  	VM_BUG_ON(PageTail(page));
> @@ -121,6 +122,11 @@ static inline int split_huge_page(struct
>  #define wait_split_huge_page(__anon_vma, __pmd)	\
>  	do { } while (0)
>  #define PageTransHuge(page) 0
> +static inline int hugepage_madvise(unsigned long *vm_flags)
> +{
> +	BUG_ON(0);

What's BUG_ON(0) in aid of?

> +	return 0;
> +}
>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>  
>  #endif /* _LINUX_HUGE_MM_H */
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -894,6 +894,22 @@ out:
>  	return ret;
>  }
>  
> +int hugepage_madvise(unsigned long *vm_flags)
> +{
> +	/*
> +	 * Be somewhat over-protective like KSM for now!
> +	 */
> +	if (*vm_flags & (VM_HUGEPAGE | VM_SHARED  | VM_MAYSHARE   |
> +			 VM_PFNMAP   | VM_IO      | VM_DONTEXPAND |
> +			 VM_RESERVED | VM_HUGETLB | VM_INSERTPAGE |
> +			 VM_MIXEDMAP | VM_SAO))
> +		return -EINVAL;
> +
> +	*vm_flags |= VM_HUGEPAGE;
> +
> +	return 0;
> +}
> +
>  void __split_huge_page_pmd(struct mm_struct *mm, pmd_t *pmd)
>  {
>  	struct page *page;
> diff --git a/mm/madvise.c b/mm/madvise.c
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -71,6 +71,11 @@ static long madvise_behavior(struct vm_a
>  		if (error)
>  			goto out;
>  		break;
> +	case MADV_HUGEPAGE:

I should have said it at patch 4 but don't forget that Michael Kerrisk
should be made aware of MADV_HUGEPAGE so it makes it to a manual page
at some point.

> +		error = hugepage_madvise(&new_flags);
> +		if (error)
> +			goto out;
> +		break;
>  	}
>  
>  	if (new_flags == vma->vm_flags) {
> @@ -283,6 +288,9 @@ madvise_behavior_valid(int behavior)
>  	case MADV_MERGEABLE:
>  	case MADV_UNMERGEABLE:
>  #endif
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	case MADV_HUGEPAGE:
> +#endif
>  		return 1;
>  
>  	default:
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
