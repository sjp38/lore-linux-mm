Message-ID: <3D3B94AF.27A254EA@zip.com.au>
Date: Sun, 21 Jul 2002 22:14:23 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] low-latency zap_page_range
References: <1027196427.1116.753.camel@sinai>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>
Cc: torvalds@transmeta.com, riel@conectiva.com.br, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Robert Love wrote:
> 
> The lock hold time in zap_page_range is horrid.
>

Yes, it is.  And although our mandate is to fix things
like this without grafted-on low latency hacks, zap_page_range()
may be one case where simply popping the lock is the best solution.
Not sure.

> ...
> +       while (size) {
> +               block = (size > ZAP_BLOCK_SIZE) ? ZAP_BLOCK_SIZE : size;
> +               end = address + block;
> +
> +               spin_lock(&mm->page_table_lock);
> +
> +               flush_cache_range(vma, address, end);
> +               tlb = tlb_gather_mmu(mm, 0);
> +               unmap_page_range(tlb, vma, address, end);
> +               tlb_finish_mmu(tlb, address, end);
> +
> +               spin_unlock(&mm->page_table_lock);
> +
> +               address += block;
> +               size -= block;
> +       }

This adds probably-unneeded extra work - we shouldn't go
dropping the lock unless that is actually required.  ie:
poll ->need_resched first.    Possible?

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
