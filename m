Subject: Re: [RFC][patch 0/2] mm: remove PageReserved
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <42F7F5AE.6070403@yahoo.com.au>
References: <42F57FCA.9040805@yahoo.com.au>
	 <200508090710.00637.phillips@arcor.de>  <42F7F5AE.6070403@yahoo.com.au>
Content-Type: text/plain
Date: Tue, 09 Aug 2005 10:51:48 +0200
Message-Id: <1123577509.30257.173.camel@gaston>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Daniel Phillips <phillips@arcor.de>, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>
List-ID: <linux-mm.kvack.org>


> Basically, it was doing a whole lot of vaguely related things. It
> was set for ZERO_PAGE pages. It was (and still is) set for struct
> pages that don't point to valid ram. Drivers set it, hoping it will
> do something magical for them.
> 
> And yes, the VM_RESERVED flag is able to replace most usages.
> Checking (pte_page(pte) == ZERO_PAGE(addr)) picks up others.
> 
> What we don't have is something to indicate the page does not point
> to valid ram.

I have no problem keeping PG_reserved for that, and _ONLY_ for that.
(though i'd rather see it renamed then). I'm just afraid by doing so,
some drivers will jump in the gap and abuse it again... Also, we should
make sure we kill the "trick" of refcounting only in one direction.
Either we refcount both (but do nothing, or maybe just BUG_ON if the
page is "reserved" -> not valid RAM), or we don't refcount at all.

For things like Cell, We'll really end up needing struct page covering
the SPUs for example. That is not valid RAM, shouldn't be refcounted,
but we need to be able to have nopage() returning these etc...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
