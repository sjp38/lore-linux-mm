Date: Mon, 15 Jan 2001 19:40:00 +0100
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: swapout selection change in pre1
Message-ID: <20010115194000.C18795@pcep-jamie.cern.ch>
References: <20010115102445.B18014@pcep-jamie.cern.ch> <Pine.LNX.4.10.10101151011340.6108-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.10.10101151011340.6108-100000@penguin.transmeta.com>; from torvalds@transmeta.com on Mon, Jan 15, 2001 at 10:24:19AM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Ed Tomlinson <tomlins@cam.org>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> See - when the VM layer frees pages from a virtual mapping, it doesn't
> throw them away. The pages are still there, and there won't be any "spiral
> of death". If the faulter faults them in quickly, a soft-fault will happen
> without any new memory allocation, and you won't see any more vmascanning.
> It doesn't get "worse", if the working set actually fits in memory.

Ok, as long as the agressive scanning is only increased by hard faults.

> So the only case that actually triggers a "meltdown" is when the working
> set does _not_ fit in memory, in which case not only will the pages be
> unmapped, but they'll also get freed aggressively by the page_launder()
> logic. At that point, the big process will actually end up waiting for the
> pages, and will end up penalizing itself, which is exactly what we want.
> 
> So it should never "spiral out of control", simply because of the fact
> that if we fit in memory it has no other impact than initially doing more
> soft page faults when it tries to find the right balancing point. It only
> really kicks in for real when people are continually trying to free
> memory: which is only true when we really have a working set bigger than
> available memory, and which is exactly the case where we _want_ to
> penalize the people who seem to be the worst offenders.
> 
> So I woubt you get any "subtle cases".

Suppose you have two processes with the same size working set.  Process
A is almost entirely paged out and so everything it does triggers a hard
fault.  This causes A to be agressively vmscanned, which ensures that
most of A's working set pages aren't mapped, and therefore can be paged
out.

Process B is almost entirely paged in and doesn't fault very much.  It
is not being aggressively vmscanned.  After it does hard fault, there is
a good chance that the subsequent few pages it wants are still mapped.

So process A is heavily hard faulting, process B is not, and the
aggressive vmscanning of process A conspires to keep it that way.

Like the TCP unfairness problem, where one stream captures the link and
other streams cannot get a fair share.

I am waving my hands a bit but no more than Linus I think :)

Btw, reverse page mapping resolves this and makes it very simple: no
vmscanning (*), so no hand waving heuristic.  I agree that every scheme
except Dave's for reverse mapping has appeared rather too heavy.  I
don't know if anyone remembers the one I suggested a few months ago,
based on Dave's.  I believe it addresses the problems Dave noted with
anonymous pages etc.  Must find the time etc.

(*) You might vmscan for efficiency sake anyway, but it needn't affect
paging decisions.

> Note that this ties in to the thread issue too: if you have a single VM
> and 50 threads that all fault in, that single VM _will_ be penalized. Not
> because it has 50 threads (like the old code did), but because it has a
> very active paging behaviour.
> 
> Which again is exactly what we want: we don't want to penalize threads per
> se, because threads are often used for user interfaces etc and can often
> be largely dormant. What we really want to penalize is bad VM behaviour,
> and that's exactly the information we get from heavy page faulting.

Certainly, it's most desirable to simply treat VMs as just VMs.

What _may_ be a factor is that thread VMs get an unfair share of the
processor.  Probably they should not, but right now they do.  And this
unfair share certainly skews the scanning and paging statistics.  I'm
not sure if any counterbalance is needed.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
