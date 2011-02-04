Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 178BC8D003B
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 15:39:14 -0500 (EST)
Message-ID: <4D4C63ED.6060104@tilera.com>
Date: Fri, 4 Feb 2011 15:39:09 -0500
From: Chris Metcalf <cmetcalf@tilera.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/25] tile: Fix __pte_free_tlb
References: <20110125173111.720927511@chello.nl> <20110125174907.220115681@chello.nl>
In-Reply-To: <20110125174907.220115681@chello.nl>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>

On 1/25/2011 12:31 PM, Peter Zijlstra wrote:
> Tile's __pte_free_tlb() implementation makes assumptions about the
> generic mmu_gather implementation, cure this ;-)

I assume you will take this patch into your tree?  If so:

Acked-by: Chris Metcalf <cmetcalf@tilera.com>

> [ Chris, from a quick look L2_USER_PGTABLE_PAGES is something like:
>   1 << (24 - 16 + 3), which looks awefully large for an on-stack
>   array. ]

Yes, the pte_pages[] array in this routine is 2KB currently.  Currently we
ship with 64KB pagesize, so the kernel stack has plenty of room.  I do like
that your patch removes this buffer, however, since we're currently looking
into (re-)supporting 4KB pages, which would totally blow the kernel stack
in this routine.

> Cc: Chris Metcalf <cmetcalf@tilera.com>
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
>  arch/tile/mm/pgtable.c |   15 ++-------------
>  1 file changed, 2 insertions(+), 13 deletions(-)
>
> Index: linux-2.6/arch/tile/mm/pgtable.c
> ===================================================================
> --- linux-2.6.orig/arch/tile/mm/pgtable.c
> +++ linux-2.6/arch/tile/mm/pgtable.c
> @@ -252,19 +252,8 @@ void __pte_free_tlb(struct mmu_gather *t
>  	int i;
>  
>  	pgtable_page_dtor(pte);
> -	tlb->need_flush = 1;
> -	if (tlb_fast_mode(tlb)) {
> -		struct page *pte_pages[L2_USER_PGTABLE_PAGES];
> -		for (i = 0; i < L2_USER_PGTABLE_PAGES; ++i)
> -			pte_pages[i] = pte + i;
> -		free_pages_and_swap_cache(pte_pages, L2_USER_PGTABLE_PAGES);
> -		return;
> -	}
> -	for (i = 0; i < L2_USER_PGTABLE_PAGES; ++i) {
> -		tlb->pages[tlb->nr++] = pte + i;
> -		if (tlb->nr >= FREE_PTE_NR)
> -			tlb_flush_mmu(tlb, 0, 0);
> -	}
> +	for (i = 0; i < L2_USER_PGTABLE_PAGES; ++i)
> +		tlb_remove_page(tlb, pte + i);
>  }
>  
>  #ifndef __tilegx__
>
>

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
