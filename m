Date: Thu, 19 Jan 2006 14:52:22 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [patch 3/3] mm: PageActive no testset
Message-ID: <20060119165222.GC4418@dmt.cnet>
References: <20060118024106.10241.69438.sendpatchset@linux.site> <20060118024139.10241.73020.sendpatchset@linux.site> <20060118141346.GB7048@dmt.cnet> <20060119145008.GA20126@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060119145008.GA20126@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>, Linus Torvalds <torvalds@osdl.org>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 19, 2006 at 03:50:08PM +0100, Nick Piggin wrote:
> Hi Marcelo,
> 
> On Wed, Jan 18, 2006 at 12:13:46PM -0200, Marcelo Tosatti wrote:
> > Hi Nick,
> > 
> > On Wed, Jan 18, 2006 at 11:40:58AM +0100, Nick Piggin wrote:
> > > PG_active is protected by zone->lru_lock, it does not need TestSet/TestClear
> > > operations.
> > 
> > page->flags bits (including PG_active and PG_lru bits) are touched by
> > several codepaths which do not hold zone->lru_lock. 
> > 
> > AFAICT zone->lru_lock guards access to the LRU list, and no more than
> > that.
> > 
> 
> Yep.
> 
> > Moreover, what about consistency of the rest of page->flags bits?
> > 
> 
> That's OK, set_bit and clear_bit are atomic as well, they just don't
> imply memory barriers and can be implemented a bit more simply.

Indeed!

> The test-set / test-clear operations also kind of imply that it is
> being used for locking or without other synchronisation (usually).

Non-atomic versions such as __ClearPageLRU()/__ClearPageActive() are 
not usable, though.

PPC:

static __inline__ void __clear_bit(unsigned long nr,
                                   volatile unsigned long *addr)
{
        unsigned long mask = BITOP_MASK(nr);
        unsigned long *p = ((unsigned long *)addr) + BITOP_WORD(nr);

        *p &= ~mask;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
