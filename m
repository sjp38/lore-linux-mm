Date: Sun, 23 Dec 2007 09:22:17 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch] mm: fix PageUptodate memory ordering bug
In-Reply-To: <20071223071529.GC29288@wotan.suse.de>
Message-ID: <alpine.LFD.0.9999.0712230900310.21557@woody.linux-foundation.org>
References: <20071218012632.GA23110@wotan.suse.de> <20071222005737.2675c33b.akpm@linux-foundation.org> <20071223055730.GA29288@wotan.suse.de> <20071222223234.7f0fbd8a.akpm@linux-foundation.org> <20071223071529.GC29288@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>


On Sun, 23 Dec 2007, Nick Piggin wrote:
> 
> It's not actually increasing size by that much here... hmm, do you have
> CONFIG_X86_PPRO_FENCE defined, by any chance?
> 
> It looks like this gets defined by default for i386, and also probably for
> distro configs. Linus? This is a fairly heavy hammer for such an unlikely bug on
> such a small number of systems (that admittedly doesn't even fix the bug in all
> cases anyway). It's not only heavy for my proposed patch, but it also halves the
> speed of spinlocks. Can we have some special config option for this instead? 

A special config option isn't great, since vendors would probably then 
enable it for those old P6's.

But maybe an "alternative()" thing that depends on a CPU capability?

Of course, it definitely *is* true that the number of CPU's that have that 
bug _and_ are actually used in SMP environments is probably vanishingly 
small. So maybe even vendors don't really care any more, and we could make 
the PPRO_FENCE thing a thing of the past.

There's actually a few different PPro errata. There's #51, which is an IO 
ordering thing, and can happen on UP too. There's #66, which breaks CPU 
ordering, and is SMP-only (and which is probably at least *mostly* fixed 
by PPRO_FENCE), and there is #92 which can cause cache incoherency and 
where PPRO_FENCE *may* indirectly help.

We could decide to just ignore all of them, or perhaps ignore all but #51. 
I think Alan still has an old four-way PPro hidden away somewhere, but 
he's probably one of the few people who could even *test* this thing.

Or we could make PPRO_FENCE just be something that you have to enable by 
hand, rather than enabling it automatically for a set of CPU's. That way 
Alan can add it to his config, and everybody else can clear it if they 
decide that they don't have one of the old 200MHz PPro's any more..

				Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
