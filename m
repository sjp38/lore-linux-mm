Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 317836B0255
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 00:21:41 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so60543719pac.0
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 21:21:40 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id i6si15512973pbq.228.2015.09.23.21.21.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Sep 2015 21:21:40 -0700 (PDT)
Received: by padhy16 with SMTP id hy16so60629854pad.1
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 21:21:40 -0700 (PDT)
Date: Thu, 24 Sep 2015 13:22:26 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [linux-next] khugepaged inconsistent lock state
Message-ID: <20150924042225.GB626@swordfish>
References: <20150921044600.GA863@swordfish>
 <20150921150135.GB30755@node.dhcp.inet.fi>
 <alpine.LSU.2.11.1509211611190.8889@eggly.anvils>
 <20150923132214.GC25020@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150923132214.GC25020@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (09/23/15 16:22), Kirill A. Shutemov wrote:
[..]
> khugepaged does swap in during collapse under anon_vma lock. It causes
> complain from lockdep. The trace below shows following scenario:
> 
>  - khugepaged tries to swap in a page under mmap_sem and anon_vma lock;
>  - do_swap_page() calls swapin_readahead() with GFP_HIGHUSER_MOVABLE;
>  - __read_swap_cache_async() tries to allocate the page for swap in;
>  - lockdep_trace_alloc() in __alloc_pages_nodemask() notices that with
>    given gfp_mask we could end up in direct relaim.
>  - Lockdep already knows that reclaim sometimes (e.g. in case of
>    split_huge_page()) wants to take anon_vma lock on its own.
> 
> Therefore deadlock is possible.
[..]

Gave it some testing on my box. Works fine on my side.

I guess you can add (if needed)
Tested-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
> ---
>  mm/huge_memory.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index dd58ecfcafe6..06c8f6d8fee2 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2725,10 +2725,10 @@ static void collapse_huge_page(struct mm_struct *mm,
>  		goto out;
>  	}
>  
> -	anon_vma_lock_write(vma->anon_vma);
> -
>  	__collapse_huge_page_swapin(mm, vma, address, pmd);
>  
> +	anon_vma_lock_write(vma->anon_vma);
> +
>  	pte = pte_offset_map(pmd, address);
>  	pte_ptl = pte_lockptr(mm, pmd);
>  
> -- 
>  Kirill A. Shutemov
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
