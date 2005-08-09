Message-ID: <42F87C24.4080000@yahoo.com.au>
Date: Tue, 09 Aug 2005 19:49:24 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][patch 0/2] mm: remove PageReserved
References: <42F57FCA.9040805@yahoo.com.au>	 <200508090710.00637.phillips@arcor.de>  <42F7F5AE.6070403@yahoo.com.au> <1123577509.30257.173.camel@gaston>
In-Reply-To: <1123577509.30257.173.camel@gaston>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Daniel Phillips <phillips@arcor.de>, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>
List-ID: <linux-mm.kvack.org>

Benjamin Herrenschmidt wrote:

> 
> I have no problem keeping PG_reserved for that, and _ONLY_ for that.
> (though i'd rather see it renamed then). I'm just afraid by doing so,
> some drivers will jump in the gap and abuse it again...

Sure it would be renamed (better yet may be a slower page_is_valid()
that doesn't need to use a flag).

There is always the possibility for driver abuse, I guess... however
as it is now, the tree is basically past the critical mass of self
perpetuation (ie. cut-n-paste). So getting rid of that should certianly
help get things cleaner.

> Also, we should
> make sure we kill the "trick" of refcounting only in one direction.
> Either we refcount both (but do nothing, or maybe just BUG_ON if the
> page is "reserved" -> not valid RAM), or we don't refcount at all.
> 

Yep, that's done. Actually having a BUG_ON PageReserved in the refcount
functions isn't a bad idea for the initial merge, and should help allay
my fears that I might have introduced refcount leaks on PageReserved
pages.

> For things like Cell, We'll really end up needing struct page covering
> the SPUs for example. That is not valid RAM, shouldn't be refcounted,
> but we need to be able to have nopage() returning these etc...
>

In that case, remap_pfn_range should take care of it for you by
setting the VM_RESERVED flag on the vma.

Swsusp is the main "is valid ram" user I have in mind here. It
wants to know whether or not it should save and restore the
memory of a given `struct page`.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
