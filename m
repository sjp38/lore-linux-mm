Message-ID: <41C3F2D6.6060107@yahoo.com.au>
Date: Sat, 18 Dec 2004 20:05:26 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 4/10] alternate 4-level page tables patches
References: <41C3D453.4040208@yahoo.com.au> <41C3D479.40708@yahoo.com.au> <41C3D48F.8080006@yahoo.com.au> <41C3D4AE.7010502@yahoo.com.au> <41C3D4C8.1000508@yahoo.com.au>
In-Reply-To: <41C3D4C8.1000508@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: Andi Kleen <ak@suse.de>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> 4/10
> 
> 
> ------------------------------------------------------------------------
> 
> 
> 
> Rename clear_page_tables to clear_page_range. clear_page_range takes byte
> ranges, and aggressively frees page table pages. Maybe useful to control
> page table memory consumption on 4-level architectures (and even 3 level
> ones).
> 

I maybe didn't do this patch justice by hiding it away in this series.
It may be worthy of its own thread - surely there must be some significant
downsides if nobody had implemented it in the past (or maybe just a fact
of "that doesn't happen much").

Anyway, if we show off its best-case: start 100 processes that each allocate
1GB of memory, touch all pages, then free it (but don't exit). Do that on
i386 with PAE (but most any 3+ level setup will be more or less vulnerable
to the same problem).

npiggin@intel:~/tests/pte$ grep PageTables meminfo.100*
meminfo.100:PageTables:     181228 kB
meminfo.100.optimized:PageTables:       2476 kB

You see, the 1GB we've allocated isn't perfectly PGDIR aligned, so none of
the page tables can get freed. So it is a potentially significant saving
in some cases.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
