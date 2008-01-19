Date: Sat, 19 Jan 2008 06:07:55 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 2/6] mm: introduce pte_special pte bit
Message-ID: <20080119050755.GA19722@wotan.suse.de>
References: <20080118045649.334391000@suse.de> <20080118045755.516986000@suse.de> <alpine.LFD.1.00.0801180816120.2957@woody.linux-foundation.org> <20080118224622.GA11563@wotan.suse.de> <alpine.LFD.1.00.0801181448280.2957@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.00.0801181448280.2957@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Jared Hulbert <jaredeh@gmail.com>, Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 18, 2008 at 03:03:03PM -0800, Linus Torvalds wrote:
> 
> 
> On Fri, 18 Jan 2008, Nick Piggin wrote:
> > 
> > I thought in your last mail on the subject, that you had conceded the
> > vma-based scheme should stay, so I might have misunderstood that to mean
> > you would, reluctantly, go with the scheme. I guess I need to try a bit
> > harder ;)
> 
> Yes, I did concede that apparently we cannot just mandate "let's just use 
> a bit in the pte".
> 
> So I do agree that we seem to be forced to have two different 
> implementations: one for architectures where we can make use of a marker 
> on the PTE itself (or perhaps some *other* way to distinguish things 
> automatically), and one for the ones where we need to just be able 
> to distinguish purely based on our own data structures.

Yep, thanks for the clarification.


> I just then didn't like the lack of abstraction.
> 
> > How about taking a different approach. How about also having a pte_normal()
> > function.
> 
> Well, one reason I'd prefer not to, is that I can well imagine an 
> architecture that doesn't actually put the "normal" bit in the PTE itself, 
> but in a separate data structure.
> 
> In particular, let's say that you decide that
> 
>  - the architecture really doesn't have any space in the hw page tables
>  - but for various reasons you *really* don't want to use the tricky 
>    "page->offset" logic etc
>  - ..and you realize that PFNMAP and FIXMAP are actually very rare
> 
> so..
> 
>  - you just associate each PFNMAP/FIXMAP vma with a simple bitmap that 
>    contains the "special" bit.
> 
> It's actually not that hard to do. If you have an architecture-specific 
> interface like
> 
> 	struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr, pte_t pte);
> 
> then it wouldn't be too hard at all to create a hash lookup on the VMA (or 
> perhaps on a "vma, 256-page-aligned(addr)" tuple) to look up a bitmap, and 
> then use the address to see if it was marked special or not.
> 
> But yes, then you'd also need to have that extended
> 
> 	set_special_pte_at(vma, addr, pfn, prot);
> 
> interface to set that bit in that bitmap.
> 
> See? 
> 
> Is it better than what we already have for the generic case? Possibly not. 
> But I like abstractions that aren't tied to *one* particular 
> implementation.

Well that's all true, but I would be a bit worried about architectures
inventing their own ways of doin gthings. I mean, _every_ implementation
needs to be understood by core mm/ developers; and conversely, none of
the architecture maintainers need to care a single bit about any of the
implementations if they provide some basic low level things to us.

So I'd argue that if someone really needed to invent another scheme, then
that should also be somehow folded into mm/ code if possible rather than
let the arch do it...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
