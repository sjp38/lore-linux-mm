Date: Mon, 20 Dec 2004 10:40:07 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [RFC][PATCH 0/10] alternate 4-level page tables patches
In-Reply-To: <20041220180435.GG4316@wotan.suse.de>
Message-ID: <Pine.LNX.4.58.0412201016260.4112@ppc970.osdl.org>
References: <41C3D453.4040208@yahoo.com.au>
 <Pine.LNX.4.44.0412182338040.13356-100000@localhost.localdomain>
 <20041220180435.GG4316@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>


On Mon, 20 Dec 2004, Andi Kleen wrote:
> 
> But I'm not strongly opposed to it. If everybody else thinks "pud_t" 
> is the greatest thing since sliced bread and much a much better name
> than "pml4_t" then I guess we could eat the delay and disruption
> that another round of these disruptive patches takes.

To me, it's not the name, but the _placement_.

"pml4_t" is at the _top_, and replaces "pgd_t" in that position. While 
"pud_t" is in the _middle_, and extends upon the existing practice of 
folding the mid directory.

I had a reason why I put "pmd_t" in between the old pgd_t and pte_t when I
expanded from two to three levels: it ends up adding the levels at the
point where they are conceptually the least intrusive.

By "conceptually least intrusive", think about this: one of the most core
header files in the kernel, <linux/sched.h> mentions "pgd_t", but it does
_not_ mention "pmd_t". Why?

Basically, by doing the new folded table in the middle, it _only_ affects 
code that actually walks the page tables. Basically, what I wanted in the 
original 2->3 leval expansion was that people who don't use the new level 
should be able to conceptually totally ignore it. I think that is even 
more true in the 3->4 level expansion.

I haven't done any side-by-side comparisons on your original patches, and
on Nick's version of your patches, but I'm pretty certain that Nick's
patches are more "directed", with less noise. Not because of any name
issues, but because I think the right place to do the folding is in the
middle.

Quite frankly, I don't love Nick's patches either. I'd prefer to see the
infrastructure happen first - have the patch sequence first make _every_
single architecture use the "generic pud_t folding", and basically be in 
the position where the first <n> patches just do the syntactic part that 
makes it possible for then patches <n+1>, <n+2> to actually convert 
individual architectures that want it.

But Nick's patches seem to come fairly close to that.

So no, naming isn't the big difference. The conceptual difference is
bigger. It's just that once you conceptually do it in the middle, a
numbered name like "pml4_t" just doesn't make any sense (I don't think it
makes much sense at the top either, since there is no 1..2..3 to match it,
but that's a separate issue ;)

			Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
