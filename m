Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id AC4E7828EB
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 15:09:33 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id n128so49665425pfn.3
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 12:09:33 -0800 (PST)
Received: from mail-pf0-x230.google.com (mail-pf0-x230.google.com. [2607:f8b0:400e:c00::230])
        by mx.google.com with ESMTPS id tl10si19104683pac.177.2016.01.11.12.09.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 12:09:32 -0800 (PST)
Received: by mail-pf0-x230.google.com with SMTP id e65so49841484pfe.0
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 12:09:32 -0800 (PST)
Date: Mon, 11 Jan 2016 12:09:24 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH V2] mm/powerpc: Fix _PAGE_PTE breaking swapoff
In-Reply-To: <1452527374-4886-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Message-ID: <alpine.LSU.2.11.1601111130480.3993@eggly.anvils>
References: <1452527374-4886-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Mon, 11 Jan 2016, Aneesh Kumar K.V wrote:

> Core kernel expect swp_entry_t to be consisting of
> only swap type and swap offset. We should not leak pte bits to
> swp_entry_t. This breaks swapoff which use the swap type and offset
> to build a swp_entry_t and later compare that to the swp_entry_t
> obtained from linux page table pte. Leaking pte bits to swp_entry_t
> breaks that comparison and results in us looping in try_to_unuse.
> 
> The stack trace can be anywhere below try_to_unuse() in mm/swapfile.c,
> since swapoff is circling around and around that function, reading from
> each used swap block into a page, then trying to find where that page
> belongs, looking at every non-file pte of every mm that ever swapped.
> 
> Reported-by: Hugh Dickins <hughd@google.com>
> Suggested-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

I think we've seen enough of my name above, but if it helps further
Acked-by: Hugh Dickins <hughd@google.com>

Though I don't find the code comment below on swp_entry_t enlightening -
your commit description above is much more helpful.  If I were writing it,
I might say... hmm, it's too hard: given all the convolutions, I gave up.

> ---
> Changes from V1:
> * improve change log and code comment
> 
>  arch/powerpc/include/asm/book3s/64/pgtable.h | 11 ++++++++---
>  1 file changed, 8 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
> index 03c1a5a21c0c..cecb971674a8 100644
> --- a/arch/powerpc/include/asm/book3s/64/pgtable.h
> +++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
> @@ -158,9 +158,14 @@ static inline void pgd_set(pgd_t *pgdp, unsigned long val)
>  #define __swp_entry(type, offset)	((swp_entry_t) { \
>  					((type) << _PAGE_BIT_SWAP_TYPE) \
>  					| ((offset) << PTE_RPN_SHIFT) })
> -
> -#define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val((pte)) })
> -#define __swp_entry_to_pte(x)		__pte((x).val)
> +/*
> + * swp_entry_t should be independent of pte bits. We build a swp_entry_t from
> + * swap type and offset we get from swap and convert that to pte to
> + * find a matching pte in linux page table.
> + * Clear bits not found in swap entries here
> + */
> +#define __pte_to_swp_entry(pte)	((swp_entry_t) { pte_val((pte)) & ~_PAGE_PTE })
> +#define __swp_entry_to_pte(x)	__pte((x).val | _PAGE_PTE)
>  
>  #ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
>  #define _PAGE_SWP_SOFT_DIRTY   (1UL << (SWP_TYPE_BITS + _PAGE_BIT_SWAP_TYPE))
> -- 
> 2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
