Subject: Re: [rfc] optimise unlock_page
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <Pine.LNX.4.64.0705091950080.2909@blonde.wat.veritas.com>
References: <20070508113709.GA19294@wotan.suse.de>
	 <20070508114003.GB19294@wotan.suse.de>
	 <1178659827.14928.85.camel@localhost.localdomain>
	 <20070508224124.GD20174@wotan.suse.de>
	 <20070508225012.GF20174@wotan.suse.de>
	 <Pine.LNX.4.64.0705091950080.2909@blonde.wat.veritas.com>
Content-Type: text/plain
Date: Thu, 10 May 2007 07:21:30 +1000
Message-Id: <1178745690.14928.167.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-arch@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Not good enough, I'm afraid.  It looks like Ben's right and you need
> a count - and counts in the page struct are a lot harder to add than
> page flags.
> 
> I've now played around with the hangs on my three 4CPU machines
> (all of them in io_schedule below __lock_page, waiting on pages
> which were neither PG_locked nor PG_waiters when I looked).
> 
> Seeing Ben's mail, I thought the answer would be just to remove
> the "_exclusive" from your three prepare_to_wait_exclusive()s.
> That helped, but it didn't eliminate the hangs.

There might be a way ... by having the flags manipulation always
atomically deal with PG_locked and PG_waiters together. This is possible
but we would need even more weirdo bitops abstractions from the arch I'm
afraid... unless we start using atomic_* rather that bitops in order to
manipulate multiple bits at a time.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
