Date: Mon, 20 Dec 2004 10:47:05 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH 10/10] alternate 4-level page tables patches
In-Reply-To: <20041220181930.GH4316@wotan.suse.de>
Message-ID: <Pine.LNX.4.58.0412201041000.4112@ppc970.osdl.org>
References: <41C3D4F9.9040803@yahoo.com.au> <41C3D516.9060306@yahoo.com.au>
 <41C3D548.6080209@yahoo.com.au> <41C3D57C.5020005@yahoo.com.au>
 <41C3D594.4020108@yahoo.com.au> <41C3D5B1.3040200@yahoo.com.au>
 <20041218073100.GA338@wotan.suse.de> <Pine.LNX.4.58.0412181102070.22750@ppc970.osdl.org>
 <20041220174357.GB4316@wotan.suse.de> <Pine.LNX.4.58.0412201000340.4112@ppc970.osdl.org>
 <20041220181930.GH4316@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>


On Mon, 20 Dec 2004, Andi Kleen wrote:
> 
> I remember there was one, but they took a brute-force sledgehammer fix.
> The right fix would have been to add the noinlines, not penalize
> everybody.

No. 

Adding work-arounds to source code for broken compilers is just not 
acceptable. If some compiler feature works badly, it is _disabled_.

Look at "-fno-strict-aliasing". Exactly the same issue. Sure, we could 
have tried to find every place where it was an issue, but very 
fundamentally that's HARD. The issues aren't obvious from the source code, 
and the "fixes" are not obvious either and do not improve readability. 
Even though arguably the aliasing logic _could_ have helped other places

So if a compiler does something we don't want to handle, we disable that
feature. It's just not _possible_ to audit the source code for these kinds
of compiler features unless you write a tool that does most of it
automatically (or at least points out where the things need to be done).

Once you start doing "noinline" and depend on those being right, you end
up having to support that forever - with new code inevitably causing
subtle breakage because of some strange compiler rule that in no way is
obvious (ie adding/removing a "static" just because you ended up exporting
it to somebody else suddenly has very non-local issues - that's BAD).

> It helps when you add the noinlines. I can do that later - search
> for Arjan's old report (I think he reported it), check what compiler
> version he used, compile everything with it and unit-at-a-time
> and eyeball all the big stack frames and add noinline
> if it should be really needed.

If you do that _first_, then sure. And have some automated checker tool
that we can run occasionally to verify that we don't break this magic rule
later by mistake.

			Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
