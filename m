Date: Mon, 20 Dec 2004 19:59:19 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 10/10] alternate 4-level page tables patches
Message-ID: <20041220185919.GB24493@wotan.suse.de>
References: <41C3D548.6080209@yahoo.com.au> <41C3D57C.5020005@yahoo.com.au> <41C3D594.4020108@yahoo.com.au> <41C3D5B1.3040200@yahoo.com.au> <20041218073100.GA338@wotan.suse.de> <Pine.LNX.4.58.0412181102070.22750@ppc970.osdl.org> <20041220174357.GB4316@wotan.suse.de> <Pine.LNX.4.58.0412201000340.4112@ppc970.osdl.org> <20041220181930.GH4316@wotan.suse.de> <Pine.LNX.4.58.0412201041000.4112@ppc970.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0412201041000.4112@ppc970.osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andi Kleen <ak@suse.de>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Mon, Dec 20, 2004 at 10:47:05AM -0800, Linus Torvalds wrote:
> 
> 
> On Mon, 20 Dec 2004, Andi Kleen wrote:
> > 
> > I remember there was one, but they took a brute-force sledgehammer fix.
> > The right fix would have been to add the noinlines, not penalize
> > everybody.
> 
> No. 
> 
> Adding work-arounds to source code for broken compilers is just not 
> acceptable. If some compiler feature works badly, it is _disabled_.


> 
> Look at "-fno-strict-aliasing". Exactly the same issue. Sure, we could 
> have tried to find every place where it was an issue, but very 
> fundamentally that's HARD. The issues aren't obvious from the source code, 
> and the "fixes" are not obvious either and do not improve readability. 
> Even though arguably the aliasing logic _could_ have helped other places

IMHO that's totally different. Yes aliasing problems are happening
everywhere because they cause problems with very common coding idioms.
But the big stack frame thing is pretty rare if it happens at all  
(I'm still sceptical) 

> 
> So if a compiler does something we don't want to handle, we disable that
> feature. It's just not _possible_ to audit the source code for these kinds
> of compiler features unless you write a tool that does most of it
> automatically (or at least points out where the things need to be done).

./scripts/checkstack.pl

> 
> Once you start doing "noinline" and depend on those being right, you end
> up having to support that forever - with new code inevitably causing
> subtle breakage because of some strange compiler rule that in no way is
> obvious (ie adding/removing a "static" just because you ended up exporting
> it to somebody else suddenly has very non-local issues - that's BAD).

You're far exaggerating the problem. It happens pretty seldom.

I think even Arjan only found one case or two in million lines
of code.

And as I said the stack frame sizes need to be regularly checked
anyways, since there seems to be a fraction of the driver people
who are just not aware of it (totally independent of unit-at-a-time) 

> 
> > It helps when you add the noinlines. I can do that later - search
> > for Arjan's old report (I think he reported it), check what compiler
> > version he used, compile everything with it and unit-at-a-time
> > and eyeball all the big stack frames and add noinline
> > if it should be really needed.
> 
> If you do that _first_, then sure. And have some automated checker tool
> that we can run occasionally to verify that we don't break this magic rule
> later by mistake.

scripts/checkstack.pl

There is probably a makefile target for it too, but I cannot find it 
right now. Probably should be in make buildcheck.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
