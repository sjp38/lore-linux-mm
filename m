Date: Mon, 22 Aug 2005 15:29:03 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [RFT][PATCH 0/2] pagefault scalability alternative
In-Reply-To: <Pine.LNX.4.61.0508222221280.22924@goblin.wat.veritas.com>
Message-ID: <Pine.LNX.4.62.0508221448480.8933@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.61.0508222221280.22924@goblin.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 22 Aug 2005, Hugh Dickins wrote:

> Here's my alternative to Christoph's pagefault scalability patches:
> no pte xchging, just narrowing the scope of the page_table_lock and
> (if CONFIG_SPLIT_PTLOCK=y when SMP) splitting it up per page table.

The basic idea is to have a spinlock per page table entry it seems. I 
think that is a good idea since it avoids atomic operations and I hope it 
will bring the same performance as my patches (seems that the 
page_table_lock can now be cached on the node that the fault is 
happening). However, these are very extensive changes to the vm.

The vm code in various places expects the page table lock to lock the 
complete page table. How do the page based ptl's and the real ptl 
interact?

There are these various hackish things in there that will hopefully be 
taken care of. F.e. there really should be a spinlock_t ptl in the struct 
page. Spinlock_t is often much bigger than an unsigned long.

The patch generally drops the first acquisition of the page 
table lock from handle_mm_fault that is used to protect the read 
operations on the page table. I doubt that this works with i386 PAE since 
the page table read operations are not protected by the ptl. These are 64 
bit which cannot be reliably retrieved in an 32 bit operation on i386 as 
you pointed out last fall. There may be concurrent writes so that one 
gets two pieces that do not fit. PAE mode either needs to fall back to 
take the page_table_lock for reads or use some tricks to guarantee 64bit 
atomicity.

I have various bad feelings about some elements but I like the general 
direction.

> Certainly not to be considered for merging into -mm yet: contains
> various tangential mods (e.g. mremap move speedup) which should be
> split off into separate patches for description, review and merge.

Could you modularize these patches? Its difficult to review as one. Maybe 
separate the narrowing and the splitting and the miscellaneous things?

> Presented as a Request For Testing - any chance, Christoph, that you
> could get someone to run it up on SGI's ia64 512-ways, to compare
> against the vanilla 2.6.13-rc6-mm1 including your patches?  Thanks!

Compiles and boots fine on ia64. Survives my benchmark on a smaller box. 
Numbers and more details will follow later. It takes some time to get a bigger iron. 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
