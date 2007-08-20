Subject: Re: [RFC 2/9] Use NOMEMALLOC reclaim to allow reclaim if
	PF_MEMALLOC is set
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0708201323590.30053@schroedinger.engr.sgi.com>
References: <20070814153021.446917377@sgi.com>
	 <20070814153501.305923060@sgi.com> <20070818071035.GA4667@ucw.cz>
	 <Pine.LNX.4.64.0708201158270.28863@schroedinger.engr.sgi.com>
	 <1187641056.5337.32.camel@lappy>
	 <Pine.LNX.4.64.0708201323590.30053@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 20 Aug 2007 23:14:08 +0200
Message-Id: <1187644449.5337.48.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pavel Machek <pavel@ucw.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-08-20 at 13:27 -0700, Christoph Lameter wrote:
> On Mon, 20 Aug 2007, Peter Zijlstra wrote:
> 
> > > Plus the same issue can happen today. Writes are usually not completed 
> > > during reclaim. If the writes are sufficiently deferred then you have the 
> > > same issue now.
> > 
> > Once we have initiated (disk) writeout we do not need more memory to
> > complete it, all we need to do is wait for the completion interrupt.
> 
> We cannot reclaim the page as long as the I/O is not complete. If you 
> have too many anonymous pages and the rest of memory is dirty then you can 
> get into OOM scenarios even without this patch.

As long as the reserve is large enough to completely initialize writeout
of a single page we can make progress. Once writeout is initialized the
completion interrupt is guaranteed to happen (assuming working
hardware).

This makes that I can happily run a 256M anonymous workload on a machine
with only 128M memory.

> > Networking is different here in that an unbounded amount of net traffic
> > needs to be processed in order to find the completion event.
> 
> Its not that different.

Yes it is, disk based completion does not require memory, network based
completion requires unbounded memory.

>  Pages are pinned during writeout from reclaim and 
> it is not clear when the write will complete. 

For disk based writeback you do not know when it comes, but you need
only passively wait for it. 

For networked writeback you need to receive all packets that happen to
be targeted at your machine and inspect them - and toss some away
because you cannot keep everything, memory is limited.

> There are no bounds that I 
> know in reclaim for the writeback of dirty anonymous pages.

throttle_vm_writeout() does sort-of.

> But some throttling function like for dirty pages is likely needed for 
> network traffic.

Yes, Daniel is working on writeout throttling.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
