Message-ID: <41C40125.3060405@yahoo.com.au>
Date: Sat, 18 Dec 2004 21:06:29 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 4/10] alternate 4-level page tables patches
References: <41C3D453.4040208@yahoo.com.au> <41C3D479.40708@yahoo.com.au> <41C3D48F.8080006@yahoo.com.au> <41C3D4AE.7010502@yahoo.com.au> <41C3D4C8.1000508@yahoo.com.au> <41C3F2D6.6060107@yahoo.com.au> <20041218095050.GC338@wotan.suse.de>
In-Reply-To: <20041218095050.GC338@wotan.suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> On Sat, Dec 18, 2004 at 08:05:26PM +1100, Nick Piggin wrote:
> 
>>Nick Piggin wrote:
>>
>>>4/10
>>>
>>>
>>>------------------------------------------------------------------------
>>>
>>>
>>>
>>>Rename clear_page_tables to clear_page_range. clear_page_range takes byte
>>>ranges, and aggressively frees page table pages. Maybe useful to control
>>>page table memory consumption on 4-level architectures (and even 3 level
>>>ones).
>>>
>>
>>I maybe didn't do this patch justice by hiding it away in this series.
>>It may be worthy of its own thread - surely there must be some significant
>>downsides if nobody had implemented it in the past (or maybe just a fact
>>of "that doesn't happen much").
> 
> 
> Yes, more could be done in this area. When I did 4level I just tried
> to keep the same semantics without optimizing anything.
> 

Sure - and we can look at it further later (we may even include a variant
of this patch in your 4level patches for example).

I just noticed it wasn't too difficult code-wise to implement, and Hugh
thought it might be worthwhile... hence I included it in this patchset.
Maybe a bit rude of me to change behaviour in the middle of a 4level
patchset though ;)

> Another way I thought about was to have a reference count of the used
> ptes/pmds per page table page in struct page and free the page when it goes 
> to zero. That would give perfect garbage collection. Drawback is that
> it may be a bit intrusive again.
> 

Yes I thought about that a bit too.

Note that this (4/10) patch should give perfect garbage collection too
(modulo bugs). The difference is in where the overheads lie. I suspect
refcounting may be too much overhead (at least, SMP overhead); especially
in light of Christoph's results.

Although I think it would enable you to do page table reclaim when
reclaiming mapped, file backed pages quite easily... but I'm not sure if
that is enough to offset the slowdowns.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
