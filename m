Date: Mon, 24 May 2004 21:00:02 -0700 (PDT)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH] ppc64: Fix possible race with set_pte on a present PTE
In-Reply-To: <20040525034326.GT29378@dualathlon.random>
Message-ID: <Pine.LNX.4.58.0405242051460.32189@ppc970.osdl.org>
References: <1085369393.15315.28.camel@gaston> <Pine.LNX.4.58.0405232046210.25502@ppc970.osdl.org>
 <1085371988.15281.38.camel@gaston> <Pine.LNX.4.58.0405232134480.25502@ppc970.osdl.org>
 <1085373839.14969.42.camel@gaston> <Pine.LNX.4.58.0405232149380.25502@ppc970.osdl.org>
 <20040525034326.GT29378@dualathlon.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrew Morton <akpm@osdl.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Ben LaHaise <bcrl@kvack.org>, linux-mm@kvack.org, Architectures Group <linux-arch@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


On Tue, 25 May 2004, Andrea Arcangeli wrote:
> 
> The below patch should fix it, the only problem is that it can screwup
> some arch that might use page-faults to keep track of the accessed bit,

Indeed. At least alpha does this - that's where this code came from. SO 
this will cause infinite page faults on alpha and any other "accessed bit 
in software" architectures.

Not good.

I suspect we should just make a "ptep_set_bits()" inline function that 
_atomically_ does "set the dirty/accessed bits". On x86, it would be a 
simple

		asm("lock ; orl %1,%0"
			:"m" (*ptep)
			:"r" (entry));

and similarly on most other architectures it should be quite easy to do 
the equivalent. You can always do it with a simple compare-and-exchange 
loop, something any SMP-capable architecture should have.

Of course, arguably we can actually optimize this by "knowing" that it is
safe to set the dirty bit, so then we don't even need an atomic operation,
we just need one atomic write.  So we only actually need the atomic op for 
the accessed bit case, and if we make the write-case be totally separate..

Anybody willing to write up a patch for a few architectures? Is there any 
architecture out there that would have a problem with this?

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
