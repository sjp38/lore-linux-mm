Date: Mon, 20 Dec 2004 19:53:08 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC][PATCH 0/10] alternate 4-level page tables patches
Message-ID: <20041220185308.GA24493@wotan.suse.de>
References: <41C3D453.4040208@yahoo.com.au> <Pine.LNX.4.44.0412182338040.13356-100000@localhost.localdomain> <20041220180435.GG4316@wotan.suse.de> <Pine.LNX.4.58.0412201016260.4112@ppc970.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0412201016260.4112@ppc970.osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andi Kleen <ak@suse.de>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

> I haven't done any side-by-side comparisons on your original patches, and
> on Nick's version of your patches, but I'm pretty certain that Nick's
> patches are more "directed", with less noise. Not because of any name

> issues, but because I think the right place to do the folding is in the
> middle.

I don't think it's true. Currently his patches are much smaller,
but only because he didn't convert the architectures yet. I think 
if he does a full conversion it will be about the same size.

[like he originally hoped to not touch the architectures that
much, but it didn't work out] 


> 
> Quite frankly, I don't love Nick's patches either. I'd prefer to see the
> infrastructure happen first - have the patch sequence first make _every_
> single architecture use the "generic pud_t folding", and basically be in 
> the position where the first <n> patches just do the syntactic part that 
> makes it possible for then patches <n+1>, <n+2> to actually convert 
> individual architectures that want it.

I'm not sure what you mean with that. You have to convert the architectures,
otherwise they won't compile. That's true for my patch and true for
Nick's (except that he didn't do all the work of converting the archs yet)

While it may be possible to do some
hacks that allows code to be unconverted I didn't do this intentionally:
the risk of some common code not getting converted and breaking
true 4level page tables is too high.

At least my patchkit was 
infrastructure (basically mm/* and a few related headers), 
compat stuff (nopml4-* emulation layer) and then a single patch
for each architecture.  You'll need to add it pretty much 
all at one, otherwise things won't compile. I don't see how
you could do it less intrusively (Nick's patches definitely require
a similar flag day). 

Currently only x86-64 is truly 4 level. ppc64 plans to be, but they
haven't done it yet. All the others seem to want to stay at 2 or 3 levels
for now.

Ok in theory you could leave out the x86-64 patch at first, but then
you would need a different patch that makes it use nopml4 (or pud_t) 

> So no, naming isn't the big difference. The conceptual difference is
> bigger. It's just that once you conceptually do it in the middle, a
> numbered name like "pml4_t" just doesn't make any sense (I don't think it

Sorry I didn't invent it, just copied it from the x86-64 architecture
manuals because I didn't see any reason to be different.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
