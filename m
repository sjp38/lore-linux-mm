Date: Thu, 31 Jul 2003 12:47:45 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Understanding page faults code in mm/memory.c
In-Reply-To: <20030731111502.GA1591@eugeneteo.net>
Message-ID: <Pine.LNX.4.53.0307311242370.10913@skynet>
References: <20030731111502.GA1591@eugeneteo.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eugene Teo <eugene.teo@eugeneteo.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jul 2003, Eugene Teo wrote:

> [1] I was looking at mm/memory.c. I noticed that there is a
> difference between minor, and major faults. My guess is that
> when a major fault occurs, the mm performs a page-in from the
> swap to the memory, whilst a minor fault doesn't?
>

Close enough. A major fault requires disk IO of some sort, it could be
either to a file or to swap.

> [2] <snip>
>     - what causes page-outs,
>     - where in the kernel can i look for them?
>

vmscan.c:shrink_cache() is a decent place to start.

> [3] in mm/memory.c, in do_wp_page, I am not sure what the
> portion of code is about:
>
> // If old_page bit is not set, set it, and test.
> if (!TryLockPage(old_page) {
>
>     // [QN:] I don't understand what can_share_swap_page() do
>     // I tried tracing, but i still don't quite get it.
>     int reuse = can_share_swap_page(old_page);

Basically it'll determine if you are the only user of that swap page. If
it returns true, it means that you are the last process to break COW on
that page so just use it. Otherwise it'll fall through and a new page will
be allocated.

>         // creates a new mapping with entry in the page table
>         // [QN:] What is pte_mkyoung?

Sets the accessed bit in the PTE to show it has been recently used

>         // [QN:] why didn't the mm->rss increased since it is
>         // a minor fault? hmm, i am not sure what minor
>         // fault is though.

Because you are using the same page that was there before. No new page is
being used by the process so no need to rss++

-- 
Mel Gorman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
