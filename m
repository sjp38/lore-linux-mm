Date: Mon, 20 Dec 2004 16:43:35 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [RFC][PATCH 0/10] alternate 4-level page tables patches
In-Reply-To: <20041221002201.GA21986@wotan.suse.de>
Message-ID: <Pine.LNX.4.58.0412201626340.4112@ppc970.osdl.org>
References: <41C3D453.4040208@yahoo.com.au>
 <Pine.LNX.4.44.0412182338040.13356-100000@localhost.localdomain>
 <20041220180435.GG4316@wotan.suse.de> <Pine.LNX.4.58.0412201016260.4112@ppc970.osdl.org>
 <20041220185308.GA24493@wotan.suse.de> <Pine.LNX.4.58.0412201600400.4112@ppc970.osdl.org>
 <20041221002201.GA21986@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>


On Tue, 21 Dec 2004, Andi Kleen wrote:
> 
> I repeat again: the differences on what code needs
> to be changed between my patchkit and Nick's are quite minor.

Oh, I believe that. But you don't seem to see what my argument was:

> The main difference is just the naming.

No. There's a more conceptual issue, as I mentioned.

Yes, the code ends up being the same, you'll always have

		pgd = pgd_offset(mm, address);
		if (!pgd_present(*pgd))
			goto out;
		pmd = pmd_offset(pgd, address);
		if (!pmd_present(*pmd))
			goto out;
		pte = pte_offset_map(pmd, address);
		if (!pte_present(*pte))
			goto out_unmap;
		...

	out_unmap:
		pte_unmap(pte);
	out:

and regardless of where you add the new thing, it's going to be the same. 
In one case you have a pml4_offset() _before_ the pgd_offset, in the other 
case you have a pud_offset() _after_ the pgd_offset. 

But that doesn't change the fact that you conceptually add it to two 
totally different locations. That you say "it's only naming" means that 
you don't see what I tried to argue. IT IS NOT ONLY NAMING.

I told you why I think the second location is the right one. You ignored 
it. Fine.

> > The thing is, I doubt the x86-64 architecture manuals use "pgd", "pmd" and 
> > "pte", do they? So regardless, there's no consitent naming.
> 
> There is consistent naming for the highest level at least. 
> 
> They use pte, pde, pdpe, pml4e (for the entries, the levels are
> called pte, pde, pdp, pml4) 

My point is that using pml4 is clearly not consistent in _LINUX_, since
AMD doesn't use the names Linux uses for the other levels. So the naming 
_really_ doesn't matter. The only thing that matters is the location of 
the new level.

And I _guarantee_ that your patches touch more files than Nick's patches 
do. Exactly because you change the meaning (and name) of the top-level 
directory, which is referenced in places that don't otherwise care about 
the internals.

I already pointed you at <linux/sched.h> as an example of something that 
cares about the top level, but not the middle ones. Same goes for 
kernel/fork.c, for all the same reasons. 

Not a lot of code, I agree. I think it's an "how do you approach it" 
issue - the end result is largely the same, the _approach_ is different. 

And your approach means you change files that you have absolutely no 
reason to change. Like kernel/fork.c. 

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
