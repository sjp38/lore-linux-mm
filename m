Message-ID: <41C404ED.7050603@yahoo.com.au>
Date: Sat, 18 Dec 2004 21:22:37 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 4/10] alternate 4-level page tables patches
References: <41C3D453.4040208@yahoo.com.au> <41C3D479.40708@yahoo.com.au> <41C3D48F.8080006@yahoo.com.au> <41C3D4AE.7010502@yahoo.com.au> <41C3D4C8.1000508@yahoo.com.au> <41C3F2D6.6060107@yahoo.com.au> <20041218095050.GC338@wotan.suse.de> <41C40125.3060405@yahoo.com.au>
In-Reply-To: <41C40125.3060405@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Andi Kleen wrote:
> 

>> Another way I thought about was to have a reference count of the used
>> ptes/pmds per page table page in struct page and free the page when it 
>> goes to zero. That would give perfect garbage collection. Drawback is 
>> that
>> it may be a bit intrusive again.
>>
> 
> Yes I thought about that a bit too.
> 
> Note that this (4/10) patch should give perfect garbage collection too
> (modulo bugs). The difference is in where the overheads lie. I suspect
> refcounting may be too much overhead (at least, SMP overhead); especially
> in light of Christoph's results.
> 

Hmm... you could refcount just the pud and pmd directories, and
have clear_page_range just expand to cover the nearest pte page
sized hole....

That way, clear_page_range can drive perfect pmd_page (lowest
level directiry) freeing, and that will drive refcount garbage
collection of the next level directory, which will cascade
up(down?)wards to all levels.

This should have minimal overhead in the fault paths, while also
lowering unmap overhead (maybe even more than it is today).

But there is no point rushing into things... as you said, we can
look into more optimisations after the base is solid.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
