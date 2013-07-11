Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 472C76B0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 07:21:52 -0400 (EDT)
Date: Thu, 11 Jul 2013 13:21:02 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 04/16] mm: numa: Do not migrate or account for hinting
 faults on the zero page
Message-ID: <20130711112102.GF25631@dyad.programming.kicks-ass.net>
References: <1373536020-2799-1-git-send-email-mgorman@suse.de>
 <1373536020-2799-5-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373536020-2799-5-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 11, 2013 at 10:46:48AM +0100, Mel Gorman wrote:
> +++ b/mm/memory.c
> @@ -3560,8 +3560,13 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  	set_pte_at(mm, addr, ptep, pte);
>  	update_mmu_cache(vma, addr, ptep);
>  
> +	/*
> +	 * Do not account for faults against the huge zero page. The read-only

s/huge //

> +	 * data is likely to be read-cached on the local CPUs and it is less
> +	 * useful to know about local versus remote hits on the zero page.
> +	 */
>  	page = vm_normal_page(vma, addr, pte);
> -	if (!page) {
> +	if (!page || is_zero_pfn(page_to_pfn(page))) {
>  		pte_unmap_unlock(ptep, ptl);
>  		return 0;
>  	}
> -- 
> 1.8.1.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
