Date: Tue, 25 May 2004 12:44:37 +0100
From: Matthew Wilcox <willy@debian.org>
Subject: Re: [PATCH] ppc64: Fix possible race with set_pte on a present PTE
Message-ID: <20040525114437.GC29154@parcelfarce.linux.theplanet.co.uk>
References: <1085369393.15315.28.camel@gaston> <Pine.LNX.4.58.0405232046210.25502@ppc970.osdl.org> <1085371988.15281.38.camel@gaston> <Pine.LNX.4.58.0405232134480.25502@ppc970.osdl.org> <1085373839.14969.42.camel@gaston> <Pine.LNX.4.58.0405232149380.25502@ppc970.osdl.org> <20040525034326.GT29378@dualathlon.random> <Pine.LNX.4.58.0405242051460.32189@ppc970.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0405242051460.32189@ppc970.osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrew Morton <akpm@osdl.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Ben LaHaise <bcrl@kvack.org>, linux-mm@kvack.org, Architectures Group <linux-arch@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, May 24, 2004 at 09:00:02PM -0700, Linus Torvalds wrote:
> I suspect we should just make a "ptep_set_bits()" inline function that 
> _atomically_ does "set the dirty/accessed bits". On x86, it would be a 
> simple
> 
> 		asm("lock ; orl %1,%0"
> 			:"m" (*ptep)
> 			:"r" (entry));
> 
> and similarly on most other architectures it should be quite easy to do 
> the equivalent. You can always do it with a simple compare-and-exchange 
> loop, something any SMP-capable architecture should have.

... but PA doesn't.  Just load-and-clear-word (and its 64-bit equivalent
in 64-bit mode).  And that word has to be 16-byte aligned.  What race
are we protecting against?  If it's like xchg() and we only need to
protect against a racing xchg() and not a reader, we can just reuse the
global array of hashed spinlocks we have for that.

> Of course, arguably we can actually optimize this by "knowing" that it is
> safe to set the dirty bit, so then we don't even need an atomic operation,
> we just need one atomic write.  So we only actually need the atomic op for 
> the accessed bit case, and if we make the write-case be totally separate..

Ah, atomic writes we can do.  That's easy.  I think all Linux architectures
support atomic writes to naturally aligned addresses, don't they?

> Anybody willing to write up a patch for a few architectures? Is there any 
> architecture out there that would have a problem with this?
> 
> 		Linus

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
