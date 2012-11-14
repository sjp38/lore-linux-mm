Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id E51756B0081
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 13:43:51 -0500 (EST)
Message-ID: <50A3E659.9060804@redhat.com>
Date: Wed, 14 Nov 2012 13:43:37 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] change_protection(): Count the number of pages affected
References: <1352883029-7885-1-git-send-email-mingo@kernel.org> <CA+55aFz_JnoR73O46YWhZn2A4t_CSUkGzMMprCUpvR79TVMCEQ@mail.gmail.com>
In-Reply-To: <CA+55aFz_JnoR73O46YWhZn2A4t_CSUkGzMMprCUpvR79TVMCEQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, Hugh Dickins <hughd@google.com>

On 11/14/2012 01:01 PM, Linus Torvalds wrote:

> But even *more* aggressively, how about looking at
>
>   - not flushing the TLB at all if the bits become  more permissive
> (taking the TLB micro-fault and letting the CPU just update it on its
> own)

This seems like a good idea.

Additionally, we may be able to get away with not modifying
the PTEs if the bits become more permissive. We can just let
handle_pte_fault update the bits to match the VMA permissions.

That way we may be able to save a fair amount of scanning and
pte manipulation for eg. JVMs that manipulate the same range
of memory repeatedly in the garbage collector.

I do not know whether that would be worthwhile, but it sounds
like something that may be worth a try...

>   - even *more* aggressive: if the bits become strictly more
> restrictive, how about not flushing the TLB at all, *and* not even
> changing the page tables, and just teaching the page fault code to do
> it lazily at fault time?

How can we do that in a safe way?

Unless we change the page tables, and flush the TLBs before
returning to userspace, the mprotect may not take effect for
an arbitrarily large period of time.

If we do not change the page tables, we should also not incur
any page faults, so the fault code would never run to "do it
lazily".

Am I misreading what you propose?

> Now, the "change protections lazily" might actually be a huge
> performance problem with the page fault overhead dwarfing any TLB
> flush costs, but we don't really know, do we? It might be worth trying
> out.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
