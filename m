Date: Mon, 27 Dec 1999 17:06:55 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC] [RFT] [PATCH] memory zone balancing
In-Reply-To: <199912151950.LAA59879@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.9912271701220.335-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Dec 1999, Kanoj Sarcar wrote:

>-	if ((gfp_mask & __GFP_DMA) && !PageDMA(page_map))
>-		goto check_table;
>-	if (!(gfp_mask & __GFP_HIGHMEM) && PageHighMem(page_map))
>+	if (zone && (page_map->zone != zone))
> 		goto check_table;
> 	swap_attempts++;

> 		/* don't account passes over not DMA pages */
>-		if ((gfp_mask & __GFP_DMA) && !PageDMA(page))
>-			goto dispose_continue;
>-		if (!(gfp_mask & __GFP_HIGHMEM) && PageHighMem(page))
>+		if (zone && (page->zone != zone))
> 			goto dispose_continue;

> 	if (PageReserved(page)
> 	    || PageLocked(page)
>-	    || ((gfp_mask & __GFP_DMA) && !PageDMA(page))
>-	    || (!(gfp_mask & __GFP_HIGHMEM) && PageHighMem(page)))
>+	    || (zone && (page->zone != zone)))
> 		goto out_failed;


The above changes you proposed will cause you to go oom even if you still
have 16mbyte of pure (ISA-DMA) RAM free in a no-bigmem kernel. With a
bigmem kernel you'll go OOM even if you still have 1giga of memory free.

As I just told you privately in previous email the checks should be a kind
of ">" (or a more complex operation implemented in a function) and not a
"!=".

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
