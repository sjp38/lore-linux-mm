Date: Fri, 2 Mar 2007 07:29:50 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: The performance and behaviour of the anti-fragmentation related patches
Message-ID: <20070302062950.GG15867@wotan.suse.de>
References: <20070302035751.GA15867@wotan.suse.de> <Pine.LNX.4.64.0703012001260.5548@schroedinger.engr.sgi.com> <20070302042149.GB15867@wotan.suse.de> <Pine.LNX.4.64.0703012022320.14299@schroedinger.engr.sgi.com> <20070302050625.GD15867@wotan.suse.de> <Pine.LNX.4.64.0703012137580.1768@schroedinger.engr.sgi.com> <20070302054944.GE15867@wotan.suse.de> <Pine.LNX.4.64.0703012150290.1768@schroedinger.engr.sgi.com> <20070302060831.GF15867@wotan.suse.de> <Pine.LNX.4.64.0703012213130.1917@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703012213130.1917@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@skynet.ie>, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, torvalds@linux-foundation.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 01, 2007 at 10:19:48PM -0800, Christoph Lameter wrote:
> On Fri, 2 Mar 2007, Nick Piggin wrote:
> 
> > > >From the I/O controller and from the application. 
> > 
> > Why doesn't the application need to deal with TLB entries?
> 
> Because it may only operate on a small section of the file and hopefully 
> splice the rest through? But yes support for mmapped I/O would be 
> necessary.

So you're talking about copying a file from one location to another?


> > > This would only be a temporary fix pushing the limits to the double or so?
> > 
> > And using slightly larger page sizes isn't?
> 
> There was no talk about slightly. 1G page size would actually be quite 
> convenient for some applications.

But it is far from convenient for the kernel. So we have hugepages, so
we can stay out of the hair of those applications and they can stay out
of hours.

> > > Amortized? The controller still would have to hunt down the 4kb page 
> > > pieces that we have to feed him right now. Result: Huge scatter gather 
> > > lists that may themselves create issues with higher page order.
> > 
> > What sort of numbers do you have for these controllers that aren't
> > very good at doing sg?
> 
> Writing a terabyte of memory to disk with handling 256 billion page 
> structs? In case of a system with 1 petabyte of memory this may be rather 
> typical and necessary for the application to be able to save its state
> on disk.

But you will have newer IO controllers, faster CPUs...

Is it a problem or isn't it? Waving around the 256 billion number isn't
impressive because it doesn't really say anything.

> > Isn't the issue was something like your IO controllers have only a
> > limited number of sg entries, which is fine with 16K pages, but with
> > 4K pages that doesn't give enough data to cover your RAID stripe?
> > 
> > We're never going to do a variable sized pagecache just because of that.
> 
> No, we need support for larger page sizes than 16k. 16k has not been fine 
> for a couple of years. We only agreed to 16k because that was the common 
> consensus. Best performance was always at 64k 4 years ago (but then we 
> have no numbers for higher page sizes yet). Now we would prefer much 
> larger sizes.

But you are in a tiny minority, so it is not so much a question of what
you prefer, but what you can make do with without being too intrusive.

I understand you have controllers (or maybe it is a block layer limit)
that doesn't work well with 4K pages, but works OK with 16K pages.
This is not something that we would introduce variable sized pagecache
for, surely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
