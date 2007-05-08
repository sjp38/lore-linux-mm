Subject: Re: 2.6.22 -mm merge plans -- vm bugfixes
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <463AFB8C.2000909@yahoo.com.au>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
	 <4636FDD7.9080401@yahoo.com.au>
	 <Pine.LNX.4.64.0705011931520.16502@blonde.wat.veritas.com>
	 <4638009E.3070408@yahoo.com.au>
	 <Pine.LNX.4.64.0705021418030.16517@blonde.wat.veritas.com>
	 <46393BA7.6030106@yahoo.com.au> <20070503103756.GA19958@infradead.org>
	 <4639DBEC.2020401@yahoo.com.au>  <463AFB8C.2000909@yahoo.com.au>
Content-Type: text/plain
Date: Tue, 08 May 2007 13:03:28 +1000
Message-Id: <1178593408.14928.58.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <andrea@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-05-04 at 19:23 +1000, Nick Piggin wrote:

> These ops could also be put to use in bit spinlocks, buffer lock, and
> probably a few other places too.

Ok, the performance hit seems to be under control (especially with the
bigger benchmark showing actual improvements).

There's a little bogon with the PG_waiters bit that you already know
about but appart from that it should be ok.

I must say I absolutely _LOVE_ the bitops with explicit _lock/_unlock
semantics. That should allow us to remove a whole bunch of dodgy
barriers and smp_mb__before_whatever_magic_crap() things we have all
over the place by providing precisely the expected semantics for bit
locks.

There are quite a few people who've been trying to do bit locks and I've
always been very worried by how easy it is to get the barriers wrong (or
too much barriers in the fast path) with these.

There are a couple of things we might want to think about regarding the
actual API to bit locks... the API you propose is simple, but it might
not fit some of the most exotic usage requirements, which typically are
related to manipulating other bits along with the lock bit.

We might just ignore them though. In the case of the page lock, it's
only hitting the slow path, and I would expect other usage scenarii to
be similar.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
