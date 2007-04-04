Date: Wed, 4 Apr 2007 10:02:36 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [rfc] no ZERO_PAGE?
In-Reply-To: <20070404183220.2455465b.dada1@cosmosbay.com>
Message-ID: <Pine.LNX.4.64.0704040950570.6730@woody.linux-foundation.org>
References: <20070329075805.GA6852@wotan.suse.de>
 <Pine.LNX.4.64.0703291324090.21577@blonde.wat.veritas.com>
 <20070330024048.GG19407@wotan.suse.de> <20070404033726.GE18507@wotan.suse.de>
 <Pine.LNX.4.64.0704040830500.6730@woody.linux-foundation.org>
 <20070404183220.2455465b.dada1@cosmosbay.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, tee@sgi.com, holt@sgi.com, Andrea Arcangeli <andrea@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


On Wed, 4 Apr 2007, Eric Dumazet wrote:
> 
> But results on an Intel Pentium-M are interesting, in particular 2) & 3)
> 
> If a page is first allocated as page_zero then cow to a full rw page, this is more expensive.
> (2660 cycles instead of 2300)

Yes, you have an extra TLB flush there at a minimum (if the page didn't 
exist at all before, you don't have to flush).

That said, the big cost tends to be the clearing of the page. Which is why 
the "bring in zero page" is so much faster than anything else - it's the 
only case that doesn't need to clear the page.

So you should basically think of your numbers like this:
 - roughly 900 cycles is the cost of the page fault and all the 
   "basic software" side in the kernel
 - roughly 1400 cycles to actually do the "memset" to clear the page (and 
   no, that's *not* the cost of memory accesses per se - it's very likely 
   already in the L2 cache or similar, we just need to clear it and if 
   it wasn't marked exclusive need to do a bus cycle to invalidate it on 
   any other CPU's).

with small variation depending on what the state was before of the cache 
in particular (for example, the TLB flush cost, but also: when you do

> 4) memset 4096 bytes to 0x55:
> Poke_full (addr=0x804f000, len=4096): 2719 cycles

This only adds ~600 cycles to memset the same 4kB that cost ~1400 cycles 
before, but that's *probably* largely because it was now already dirty in 
the L2 and possibly the L1, so it's quite possible that this is really 
just a cache effect, because now it's entirely exclusive in the caches so 
you don't need to do any probing on the bus at all).

Also note: in the end, page faults are usually fairly unusual. You do them 
once, and then use the page a lot after that. That's not *always* true, of 
course. Some malloc()/free() patterns of big areas that are not used for 
long will easily cause constant mmap/munmap, and a lot of page faults.

The worst effect of page faults tends to be for short-lived stuff. Notably 
things like "system()" that executes a shell just to execute something 
else. Almost *everything* in that path is basically "use once, then throw 
away", and page fault latency is interesting.

So this is one case where it might be interesting to look at what lmbench 
reports for the "fork/exit", "fork/exec" and "shell exec" numbers before 
and after. 

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
