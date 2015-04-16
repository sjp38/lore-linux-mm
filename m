Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id B4C4A6B0038
	for <linux-mm@kvack.org>; Thu, 16 Apr 2015 15:21:34 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so102150246pdb.0
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 12:21:34 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id nr10si13384852pdb.201.2015.04.16.12.21.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Apr 2015 12:21:33 -0700 (PDT)
Received: by paboj16 with SMTP id oj16so99697404pab.0
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 12:21:33 -0700 (PDT)
Date: Thu, 16 Apr 2015 12:21:31 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/4] mm: Send a single IPI to TLB flush multiple pages
 when unmapping
In-Reply-To: <1429179766-26711-3-git-send-email-mgorman@suse.de>
Message-ID: <alpine.LSU.2.11.1504161157390.17733@eggly.anvils>
References: <1429179766-26711-1-git-send-email-mgorman@suse.de> <1429179766-26711-3-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 16 Apr 2015, Mel Gorman wrote:
>  
>  	/* Move the dirty bit to the physical page now the pte is gone. */
> -	if (pte_dirty(pteval))
> +	if (pte_dirty(pteval)) {
> +		/*
> +		 * If the PTE was dirty then the TLB must be flushed before
> +		 * the page is unlocked as IO can start in parallel. Without
> +		 * the flush, writes could still happen and data would be
> +		 * potentially lost.
> +		 */
> +		if (deferred)
> +			flush_tlb_page(vma, address);

Okay, yes, that should deal with it; and you're probably right that the
safe pte_dirty !pte_write case is too uncommon to be worth another test.

But it would be better to batch even in the pte_dirty case: noting that
it has occurred in the tlb_ubc, then if so, doing try_to_unmap_flush()
before leaving try_to_unmap().

Particularly as you have already set_tlb_ubc_flush_pending() above,
so shrink_lruvec() may then follow with an unnecessary flush; though
I guess a little rearrangement here could stop that.

> +
>  		set_page_dirty(page);
> +	}
>  
>  	/* Update high watermark before we lower rss */
>  	update_hiwater_rss(mm);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
