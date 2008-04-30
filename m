Date: Wed, 30 Apr 2008 12:14:51 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [rfc] data race in page table setup/walking?
In-Reply-To: <20080430060340.GE27652@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0804301140490.4651@blonde.site>
References: <20080429050054.GC21795@wotan.suse.de> <Pine.LNX.4.64.0804291333540.22025@blonde.site>
 <20080430060340.GE27652@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-arch@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Wed, 30 Apr 2008, Nick Piggin wrote:
> 
> Actually, aside, all those smp_wmb() things in pgtable-3level.h can
> probably go away if we cared: because we could be sneaky and leverage
> the assumption that top and bottom will always be in the same cacheline
> and thus should be shielded from memory consistency problems :)

I've sometimes wondered along those lines.  But it would need
interrupts disabled, wouldn't it?  And could SMM mess it up?
And what about another CPU taking the cacheline to modify it
in between our two accesses?

I don't think we do care in that x86 PAE case, but as a general
principal, if it can be safely assumed on all architectures (or
more messily, just on some) under certain conditions, then shouldn't
we be looking to use that technique (relying on a consistent view of
separate variables clustered into the same cacheline) in critical
places, rather than regarding it as sneaky?

But I suspect this is a chimaera, that there's actually no
safe use to be made of it.  I'd be glad to be shown wrong.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
