Date: Wed, 14 May 2008 03:18:41 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 2/2] fix SMP data race in pagetable setup vs walking
Message-ID: <20080514011841.GC24516@wotan.suse.de>
References: <20080505112021.GC5018@wotan.suse.de> <20080505121240.GD5018@wotan.suse.de> <alpine.LFD.1.10.0805050828120.32269@woody.linux-foundation.org> <20080506095138.GE10141@wotan.suse.de> <alpine.LFD.1.10.0805060750430.32269@woody.linux-foundation.org> <20080513080143.GB19870@wotan.suse.de> <alpine.LFD.1.10.0805130844000.3019@woody.linux-foundation.org> <20080514003417.GA24516@wotan.suse.de> <alpine.LFD.1.10.0805131753150.3019@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.10.0805131753150.3019@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, linux-arch@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Paul McKenney <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, May 13, 2008 at 05:55:50PM -0700, Linus Torvalds wrote:
> 
> 
> On Wed, 14 May 2008, Nick Piggin wrote:
> > 
> > Uh, I don't follow your logic. The "reference" Linux memory model
> > requires it, so I don't see how you can justify saying it is wrong
> > just because a *specific* architecture doesn't need it.
> 
> You're thinking about it the wrong way.
> 
> NO specific architecture requires it except for alpha, and alpha already 
> has it.
> 
> Nobody else is *ever* likely to want it ever again.

Sure, I understand that. But unless you're hinting about removing
SMP support for those alphas that require it, all generic code
obviously still has to care about it. And not many people would
say they only ever look at x86 code and nothing else. I just think
it is a good exercise to _always_ be thinking about barriers, and
be thinking about them in terms of the Linux memory consistency
standard. Maybe I'm biased because I don't do much arch work...

 
> In other words, it's not a "reference model". It's an "alpha hack". We do 
> not want to copy it in code that doesn't need or want it.
> 
> And that's especially true when it's not needed at all, and adding it just 
> makes a really simple macro much more complex and totally unreadable.
> 
> If it was about adding something to a function that was already a real 
> function, it would be different.
> 
> If you coudl write it as a nice inline function, it would be different.
> 
> But when that alpha hack turns a regular (simple) #define into a thing of 
> horror, the downside is much *much* bigger than any (non-existent) upside.

Oh that's the main thing you're worried about. Then what about the
ACCESS_ONCE that might be required? That would require the same kind
of thing as I did. And actually smp_read_barrier_depends is a pretty
good indicator for (one of the) cases where we need that macro (although
as I said, I prefer gcc to be fixed).

Anyway, what I will do is send a patch which does the core, and the
alpha bits. At least then the actual bugs will be fixed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
