Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 129216B006E
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 07:24:49 -0400 (EDT)
Date: Fri, 27 Jul 2012 13:24:45 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] mm: hugetlbfs: Close race during teardown of
 hugetlbfs shared page tables
Message-ID: <20120727112445.GF26351@tiehlicka.suse.cz>
References: <1343385965-7738-1-git-send-email-mgorman@suse.de>
 <1343385965-7738-3-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1343385965-7738-3-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Just a nit

On Fri 27-07-12 11:46:05, Mel Gorman wrote:
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index fd1d530..8c6e5a5 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2429,6 +2429,25 @@ again:
>  	tlb_end_vma(tlb, vma);
>  }
>

I would welcome a comment here. Something like:
/*
 * Called when the VMA is on the way out and page tables will be freed
 * by free_pagetables.
 * i_mmap_mutex has to be held when calling this function
 */

> +void __unmap_hugepage_range_final(struct mmu_gather *tlb,
> +			  struct vm_area_struct *vma, unsigned long start,
> +			  unsigned long end, struct page *ref_page)
> +{
> +	__unmap_hugepage_range(tlb, vma, start, end, ref_page);
> +
> +	/*
> +	 * Clear this flag so that x86's huge_pmd_share page_table_shareable
> +	 * test will fail on a vma being torn down, and not grab a page table
> +	 * on its way out.  We're lucky that the flag has such an appropriate
> +	 * name, and can in fact be safely cleared here. We could clear it
> +	 * before the __unmap_hugepage_range above, but all that's necessary
> +	 * is to clear it before releasing the i_mmap_mutex. This works
> +	 * because in the context this is called, the VMA is about to be
> +	 * destroyed and the i_mmap_mutex is held.
> +	 */
> +	vma->vm_flags &= ~VM_MAYSHARE;
> +}
> +

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
