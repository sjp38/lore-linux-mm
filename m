Date: Thu, 13 Jan 2005 10:16:58 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: page table lock patch V15 [0/7]: overview
In-Reply-To: <20050113180205.GA17600@muc.de>
Message-ID: <Pine.LNX.4.58.0501131005280.19097@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0501120833060.10380@schroedinger.engr.sgi.com>
 <20050112104326.69b99298.akpm@osdl.org> <41E5AFE6.6000509@yahoo.com.au>
 <20050112153033.6e2e4c6e.akpm@osdl.org> <41E5B7AD.40304@yahoo.com.au>
 <Pine.LNX.4.58.0501121552170.12669@schroedinger.engr.sgi.com>
 <41E5BC60.3090309@yahoo.com.au> <Pine.LNX.4.58.0501121611590.12872@schroedinger.engr.sgi.com>
 <20050113031807.GA97340@muc.de> <Pine.LNX.4.58.0501130907050.18742@schroedinger.engr.sgi.com>
 <20050113180205.GA17600@muc.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@osdl.org>, torvalds@osdl.org, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org
List-ID: <linux-mm.kvack.org>

On Thu, 13 Jan 2005, Andi Kleen wrote:

> The rule in i386/x86-64 is that you cannot set the PTE in a non atomic way
> when its present bit is set (because the hardware could asynchronously
> change bits in the PTE that would get lost). Atomic way means clearing
> first and then replacing in an atomic operation.

Hmm. I replaced that portion in the swapper with an xchg operation
and inspect the result later. Clearing a pte and then setting it to
something would open a window for the page fault handler to set up a new
pte there since it does not take the page_table_lock. That xchg must be
atomic for PAE mode to work then.

> This helps you because you shouldn't be looking at the pte anyways
> when pte_present is false. When it is not false it is always updated
> atomically.

so pmd_present, pud_none and pgd_none could be considered atomic even if
the pm/u/gd_t is a multi-word entity? In that case the current approach
would work for higher level entities and in particular S/390 would be in
the clear.

But then the issues of replacing multi-word ptes on i386 PAE remain. If no
write lock is held on mmap_sem then all writes to pte's must be atomic in
order for the get_pte_atomic operation to work reliably.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
