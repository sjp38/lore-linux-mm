Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 5DD8C6B0031
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 07:35:43 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id l18so1682355wgh.28
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 04:35:42 -0700 (PDT)
Received: from mail-we0-x233.google.com (mail-we0-x233.google.com [2a00:1450:400c:c03::233])
        by mx.google.com with ESMTPS id du7si4348361wib.108.2014.04.03.04.35.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 03 Apr 2014 04:35:41 -0700 (PDT)
Received: by mail-we0-f179.google.com with SMTP id x48so1667550wes.38
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 04:35:40 -0700 (PDT)
Date: Thu, 3 Apr 2014 13:35:37 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [patch] x86: clearing access bit don't flush tlb
Message-ID: <20140403113537.GA543@gmail.com>
References: <20140403004250.GA14597@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140403004250.GA14597@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, riel@redhat.com, hughd@google.com, mgorman@suse.de, torvalds@linux-foundation.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>


* Shaohua Li <shli@kernel.org> wrote:

> Add a few acks and resend this patch.
> 
> We use access bit to age a page at page reclaim. When clearing pte access bit,
> we could skip tlb flush in X86. The side effect is if the pte is in tlb and pte
> access bit is unset in page table, when cpu access the page again, cpu will not
> set page table pte's access bit. Next time page reclaim will think this hot
> page is yong and reclaim it wrongly, but this doesn't corrupt data.
> 
> And according to intel manual, tlb has less than 1k entries, which covers < 4M
> memory. In today's system, several giga byte memory is normal. After page
> reclaim clears pte access bit and before cpu access the page again, it's quite
> unlikely this page's pte is still in TLB. And context swich will flush tlb too.
> The chance skiping tlb flush to impact page reclaim should be very rare.
> 
> Originally (in 2.5 kernel maybe), we didn't do tlb flush after clear access bit.
> Hugh added it to fix some ARM and sparc issues. Since I only change this for
> x86, there should be no risk.
> 
> And in some workloads, TLB flush overhead is very heavy. In my simple
> multithread app with a lot of swap to several pcie SSD, removing the tlb flush
> gives about 20% ~ 30% swapout speedup.
> 
> Signed-off-by: Shaohua Li <shli@fusionio.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> Acked-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Hugh Dickins <hughd@google.com>
> ---
>  arch/x86/mm/pgtable.c |   13 ++++++-------
>  1 file changed, 6 insertions(+), 7 deletions(-)
> 
> Index: linux/arch/x86/mm/pgtable.c
> ===================================================================
> --- linux.orig/arch/x86/mm/pgtable.c	2014-03-27 05:22:08.572100549 +0800
> +++ linux/arch/x86/mm/pgtable.c	2014-03-27 05:46:12.456131121 +0800
> @@ -399,13 +399,12 @@ int pmdp_test_and_clear_young(struct vm_
>  int ptep_clear_flush_young(struct vm_area_struct *vma,
>  			   unsigned long address, pte_t *ptep)
>  {
> -	int young;
> -
> -	young = ptep_test_and_clear_young(vma, address, ptep);
> -	if (young)
> -		flush_tlb_page(vma, address);
> -
> -	return young;
> +	/*
> +	 * In X86, clearing access bit without TLB flush doesn't cause data
> +	 * corruption. Doing this could cause wrong page aging and so hot pages
> +	 * are reclaimed, but the chance should be very rare.

So, beyond the spelling mistakes, I guess this explanation should also 
be a bit more explanatory - how about something like:

	/*
	 * On x86 CPUs, clearing the accessed bit without a TLB flush 
	 * doesn't cause data corruption. [ It could cause incorrect
	 * page aging and the (mistaken) reclaim of hot pages, but the
	 * chance of that should be relatively low. ]
	 *
	 * So as a performance optimization don't flush the TLB when 
	 * clearing the accessed bit, it will eventually be flushed by 
	 * a context switch or a VM operation anyway. [ In the rare 
	 * event of it not getting flushed for a long time the delay 
	 * shouldn't really matter because there's no real memory 
	 * pressure for swapout to react to. ]
	 */

Agreed?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
