Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E6E446B0047
	for <linux-mm@kvack.org>; Mon, 20 Sep 2010 06:47:39 -0400 (EDT)
Date: Mon, 20 Sep 2010 11:47:23 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 01/10] hugetlb: fix metadata corruption in
	hugetlb_fault()
Message-ID: <20100920104723.GG1998@csn.ul.ie>
References: <1283908781-13810-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1283908781-13810-2-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1283908781-13810-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 08, 2010 at 10:19:32AM +0900, Naoya Horiguchi wrote:
> Since the PageHWPoison() check is for avoiding hwpoisoned page remained
> in pagecache mapping to the process, it should be done in "found in pagecache"
> branch, not in the common path.
> Otherwise, metadata corruption occurs if memory failure happens between
> alloc_huge_page() and lock_page() because page fault fails with metadata
> changes remained (such as refcount, mapcount, etc.)
> 
> This patch moves the check to "found in pagecache" branch and fix the problem.
> 
> ChangeLog since v2:
> - remove retry check in "new allocation" path.
> - make description more detailed
> - change patch name from "HWPOISON, hugetlb: move PG_HWPoison bit check"
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
> Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>

Seems reasonable.

Acked-by: Mel Gorman <mel@csn.ul.ie>

> ---
>  mm/hugetlb.c |   21 +++++++++------------
>  1 files changed, 9 insertions(+), 12 deletions(-)
> 
> diff --git v2.6.36-rc2/mm/hugetlb.c v2.6.36-rc2/mm/hugetlb.c
> index cc5be78..6871b41 100644
> --- v2.6.36-rc2/mm/hugetlb.c
> +++ v2.6.36-rc2/mm/hugetlb.c
> @@ -2518,22 +2518,19 @@ retry:
>  			hugepage_add_new_anon_rmap(page, vma, address);
>  		}
>  	} else {
> +		/*
> +		 * If memory error occurs between mmap() and fault, some process
> +		 * don't have hwpoisoned swap entry for errored virtual address.
> +		 * So we need to block hugepage fault by PG_hwpoison bit check.
> +		 */
> +		if (unlikely(PageHWPoison(page))) {
> +			ret = VM_FAULT_HWPOISON;
> +			goto backout_unlocked;
> +		}
>  		page_dup_rmap(page);
>  	}
>  
>  	/*
> -	 * Since memory error handler replaces pte into hwpoison swap entry
> -	 * at the time of error handling, a process which reserved but not have
> -	 * the mapping to the error hugepage does not have hwpoison swap entry.
> -	 * So we need to block accesses from such a process by checking
> -	 * PG_hwpoison bit here.
> -	 */
> -	if (unlikely(PageHWPoison(page))) {
> -		ret = VM_FAULT_HWPOISON;
> -		goto backout_unlocked;
> -	}
> -
> -	/*
>  	 * If we are going to COW a private mapping later, we examine the
>  	 * pending reservations for this page now. This will ensure that
>  	 * any allocations necessary to record that reservation occur outside
> -- 
> 1.7.2.2
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
