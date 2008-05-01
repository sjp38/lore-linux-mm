Date: Thu, 1 May 2008 02:35:42 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] data race in page table setup/walking?
Message-ID: <20080501003542.GB11312@wotan.suse.de>
References: <20080429050054.GC21795@wotan.suse.de> <Pine.LNX.4.64.0804291333540.22025@blonde.site> <20080430060340.GE27652@wotan.suse.de> <Pine.LNX.4.64.0804301140490.4651@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804301140490.4651@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-arch@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 30, 2008 at 12:14:51PM +0100, Hugh Dickins wrote:
> On Wed, 30 Apr 2008, Nick Piggin wrote:
> > 
> > Actually, aside, all those smp_wmb() things in pgtable-3level.h can
> > probably go away if we cared: because we could be sneaky and leverage
> > the assumption that top and bottom will always be in the same cacheline
> > and thus should be shielded from memory consistency problems :)
> 
> I've sometimes wondered along those lines.  But it would need
> interrupts disabled, wouldn't it?  And could SMM mess it up?
> And what about another CPU taking the cacheline to modify it
> in between our two accesses?

Nothing more than could not already happen with the smp_wmb in there,
AFAIKS.

 
> I don't think we do care in that x86 PAE case, but as a general
> principal, if it can be safely assumed on all architectures (or
> more messily, just on some) under certain conditions, then shouldn't
> we be looking to use that technique (relying on a consistent view of
> separate variables clustered into the same cacheline) in critical
> places, rather than regarding it as sneaky?
> 
> But I suspect this is a chimaera, that there's actually no
> safe use to be made of it.  I'd be glad to be shown wrong.

Well Linus put a dampener on it... but if it actually did work, then
yeah I guess there are some places it could be used. I suspect that
on some implementations, being in the same cacheline would actually
fully order all transactions of a CPU, so if it did make a big
difference anywhere, we could have smp_*mb_cacheline() or something ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
