Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id E7BDA6B004A
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 10:20:28 -0400 (EDT)
Date: Wed, 11 Apr 2012 16:20:23 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch v2] thp, memcg: split hugepage for memcg oom on cow
Message-ID: <20120411142023.GB1789@redhat.com>
References: <alpine.DEB.2.00.1204031854530.30629@chino.kir.corp.google.com>
 <4F838385.9070309@jp.fujitsu.com>
 <alpine.DEB.2.00.1204092241180.27689@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1204092242050.27689@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1204092242050.27689@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On Mon, Apr 09, 2012 at 10:42:31PM -0700, David Rientjes wrote:
> On COW, a new hugepage is allocated and charged to the memcg.  If the
> system is oom or the charge to the memcg fails, however, the fault
> handler will return VM_FAULT_OOM which results in an oom kill.
> 
> Instead, it's possible to fallback to splitting the hugepage so that the
> COW results only in an order-0 page being allocated and charged to the
> memcg which has a higher liklihood to succeed.  This is expensive because
> the hugepage must be split in the page fault handler, but it is much
> better than unnecessarily oom killing a process.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/huge_memory.c |    3 +++
>  mm/memory.c      |   18 +++++++++++++++---
>  2 files changed, 18 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -950,6 +950,8 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  		count_vm_event(THP_FAULT_FALLBACK);
>  		ret = do_huge_pmd_wp_page_fallback(mm, vma, address,
>  						   pmd, orig_pmd, page, haddr);
> +		if (ret & VM_FAULT_OOM)
> +			split_huge_page(page);
>  		put_page(page);
>  		goto out;
>  	}
> @@ -957,6 +959,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  
>  	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
>  		put_page(new_page);
> +		split_huge_page(page);
>  		put_page(page);
>  		ret |= VM_FAULT_OOM;
>  		goto out;
> diff --git a/mm/memory.c b/mm/memory.c
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3489,6 +3489,7 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	if (unlikely(is_vm_hugetlb_page(vma)))
>  		return hugetlb_fault(mm, vma, address, flags);
>  
> +retry:
>  	pgd = pgd_offset(mm, address);
>  	pud = pud_alloc(mm, pgd, address);
>  	if (!pud)
> @@ -3502,13 +3503,24 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  							  pmd, flags);
>  	} else {
>  		pmd_t orig_pmd = *pmd;
> +		int ret;
> +
>  		barrier();
>  		if (pmd_trans_huge(orig_pmd)) {
>  			if (flags & FAULT_FLAG_WRITE &&
>  			    !pmd_write(orig_pmd) &&
> -			    !pmd_trans_splitting(orig_pmd))
> -				return do_huge_pmd_wp_page(mm, vma, address,
> -							   pmd, orig_pmd);
> +			    !pmd_trans_splitting(orig_pmd)) {
> +				ret = do_huge_pmd_wp_page(mm, vma, address, pmd,
> +							  orig_pmd);
> +				/*
> +				 * If COW results in an oom, the huge pmd will
> +				 * have been split, so retry the fault on the
> +				 * pte for a smaller charge.
> +				 */
> +				if (unlikely(ret & VM_FAULT_OOM))
> +					goto retry;

Can you instead put a __split_huge_page_pmd(mm, pmd) here?  It has to
redo the get-page-ref-through-pagetable dance, but it's more robust
and obvious than splitting the COW page before returning OOM in the
thp wp handler.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
