Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 86B786B0165
	for <linux-mm@kvack.org>; Thu, 30 May 2013 01:02:24 -0400 (EDT)
Message-ID: <51A6DD52.406@synopsys.com>
Date: Thu, 30 May 2013 10:32:10 +0530
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Fix the TLB range flushed when __tlb_remove_page()
 runs out of slots
References: <1369832173-15088-1-git-send-email-vgupta@synopsys.com>
In-Reply-To: <1369832173-15088-1-git-send-email-vgupta@synopsys.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Shi <alex.shi@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

[+alex.shi@intel.com]

On 05/29/2013 06:26 PM, Vineet Gupta wrote:
> zap_pte_range loops from @addr to @end. In the middle, if it runs out of
> batching slots, TLB entries needs to be flushed for @start to @interim,
> NOT @interim to @end.
> 
> Since ARC port doesn't use page free batching I can't test it myself but
> this seems like the right thing to do.
> Observed this when working on a fix for the issue at thread:
> 	http://www.spinics.net/lists/linux-arch/msg21736.html
> 
> Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: linux-mm@kvack.org
> Cc: linux-arch@vger.kernel.org <linux-arch@vger.kernel.org>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Max Filippov <jcmvbkbc@gmail.com>
> ---
>  mm/memory.c |    9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 6dc1882..d9d5fd9 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1110,6 +1110,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
>  	spinlock_t *ptl;
>  	pte_t *start_pte;
>  	pte_t *pte;
> +	unsigned long range_start = addr;
>  
>  again:
>  	init_rss_vec(rss);
> @@ -1215,12 +1216,14 @@ again:
>  		force_flush = 0;
>  
>  #ifdef HAVE_GENERIC_MMU_GATHER
> -		tlb->start = addr;
> -		tlb->end = end;
> +		tlb->start = range_start;
> +		tlb->end = addr;
>  #endif
>  		tlb_flush_mmu(tlb);
> -		if (addr != end)
> +		if (addr != end) {
> +			range_start = addr;
>  			goto again;
> +		}
>  	}
>  
>  	return addr;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
