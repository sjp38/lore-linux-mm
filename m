Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 410DF6B00B6
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 14:50:36 -0500 (EST)
Date: Tue, 26 Jan 2010 19:50:22 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 16 of 31] bail out gup_fast on splitting pmd
Message-ID: <20100126195022.GT16468@csn.ul.ie>
References: <patchbomb.1264513915@v2.random> <cc86f09d614465026c0f.1264513931@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <cc86f09d614465026c0f.1264513931@v2.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 26, 2010 at 02:52:11PM +0100, Andrea Arcangeli wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Force gup_fast to take the slow path and block if the pmd is splitting, not
> only if it's none.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Mel Gorman <mel@csn.ul.ie>

> ---
> 
> diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
> --- a/arch/x86/mm/gup.c
> +++ b/arch/x86/mm/gup.c
> @@ -156,7 +156,18 @@ static int gup_pmd_range(pud_t pud, unsi
>  		pmd_t pmd = *pmdp;
>  
>  		next = pmd_addr_end(addr, end);
> -		if (pmd_none(pmd))
> +		/*
> +		 * The pmd_trans_splitting() check below explains why
> +		 * pmdp_splitting_flush has to flush the tlb, to stop
> +		 * this gup-fast code from running while we set the
> +		 * splitting bit in the pmd. Returning zero will take
> +		 * the slow path that will call wait_split_huge_page()
> +		 * if the pmd is still in splitting state. gup-fast
> +		 * can't because it has irq disabled and
> +		 * wait_split_huge_page() would never return as the
> +		 * tlb flush IPI wouldn't run.
> +		 */
> +		if (pmd_none(pmd) || pmd_trans_splitting(pmd))
>  			return 0;
>  		if (unlikely(pmd_large(pmd))) {
>  			if (!gup_huge_pmd(pmd, addr, next, write, pages, nr))
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
