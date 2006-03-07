Date: Mon, 6 Mar 2006 17:52:29 -0800
From: Benjamin LaHaise <bcrl@linux.intel.com>
Subject: Re: [PATCH] avoid atomic op on page free
Message-ID: <20060307015229.GJ32565@linux.intel.com>
References: <20060307001015.GG32565@linux.intel.com> <20060306165039.1c3b66d8.akpm@osdl.org> <20060307011107.GI32565@linux.intel.com> <20060306173941.4b5e0fc7.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060306173941.4b5e0fc7.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 06, 2006 at 05:39:41PM -0800, Andrew Morton wrote:
> > It's just a simple send() and recv() pair of processes.  Networking uses 
> > pages for the buffer on user transmits.
> 
> You mean non-zero-copy transmits?  If they were zero-copy then those pages
> would still be on the LRU.

Correct.

> >  Those pages tend to be freed 
> > in irq context on transmit or in the receiver if the traffic is local.
> 
> If it was a non-zero-copy Tx then networking owns that page and can just do
> free_hot_page() on it and avoid all that stuff in put_page().

At least currently, networking has no way of knowing that is the case since 
pages may have their reference count increased when an skb() is cloned, and 
in fact do when TCP sends them off.

> Thing is, that case would represent about 1000000th of the number of
> put_pages()s which get done in the world.  IOW: a net loss.

Those 1-2 cycles are free if you look at how things get scheduled with the 
execution of the surrounding code. I bet $20 that you can't find a modern 
CPU where the cost is measurable (meaning something like a P4, Athlon).  
If this level of cost for the common case is a concern, it's probably worth 
making atomic_dec_and_test() inline for page_cache_release().  The overhead 
of the function call and the PageCompound() test is probably more than what 
we're talking about as you're increasing the cache footprint and actually 
performing a write to memory.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
