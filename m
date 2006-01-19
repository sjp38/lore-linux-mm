Date: Thu, 19 Jan 2006 15:50:08 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 3/3] mm: PageActive no testset
Message-ID: <20060119145008.GA20126@wotan.suse.de>
References: <20060118024106.10241.69438.sendpatchset@linux.site> <20060118024139.10241.73020.sendpatchset@linux.site> <20060118141346.GB7048@dmt.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060118141346.GB7048@dmt.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>, Linus Torvalds <torvalds@osdl.org>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Hi Marcelo,

On Wed, Jan 18, 2006 at 12:13:46PM -0200, Marcelo Tosatti wrote:
> Hi Nick,
> 
> On Wed, Jan 18, 2006 at 11:40:58AM +0100, Nick Piggin wrote:
> > PG_active is protected by zone->lru_lock, it does not need TestSet/TestClear
> > operations.
> 
> page->flags bits (including PG_active and PG_lru bits) are touched by
> several codepaths which do not hold zone->lru_lock. 
> 
> AFAICT zone->lru_lock guards access to the LRU list, and no more than
> that.
> 

Yep.

> Moreover, what about consistency of the rest of page->flags bits?
> 

That's OK, set_bit and clear_bit are atomic as well, they just don't
imply memory barriers and can be implemented a bit more simply.

The test-set / test-clear operations also kind of imply that it is
being used for locking or without other synchronisation (usually).

> PPC for example implements test_and_set_bit() with:
> 
> 	lwarx	reg, addr   (load and create reservation for 32-bit addr)
> 	or 	reg, BITOP_MASK(nr)	
> 	stwcx	reg, addr  (store word upon reservation validation, otherwise loop)
> 

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
