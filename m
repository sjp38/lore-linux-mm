Date: Tue, 21 Aug 2007 02:39:22 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC 2/9] Use NOMEMALLOC reclaim to allow reclaim if PF_MEMALLOC is set
Message-ID: <20070821003922.GD8414@wotan.suse.de>
References: <20070814153021.446917377@sgi.com> <20070814153501.305923060@sgi.com> <20070818071035.GA4667@ucw.cz> <Pine.LNX.4.64.0708201158270.28863@schroedinger.engr.sgi.com> <1187641056.5337.32.camel@lappy> <Pine.LNX.4.64.0708201323590.30053@schroedinger.engr.sgi.com> <1187644449.5337.48.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1187644449.5337.48.camel@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Lameter <clameter@sgi.com>, Pavel Machek <pavel@ucw.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 20, 2007 at 11:14:08PM +0200, Peter Zijlstra wrote:
> On Mon, 2007-08-20 at 13:27 -0700, Christoph Lameter wrote:
> > On Mon, 20 Aug 2007, Peter Zijlstra wrote:
> > 
> > > > Plus the same issue can happen today. Writes are usually not completed 
> > > > during reclaim. If the writes are sufficiently deferred then you have the 
> > > > same issue now.
> > > 
> > > Once we have initiated (disk) writeout we do not need more memory to
> > > complete it, all we need to do is wait for the completion interrupt.
> > 
> > We cannot reclaim the page as long as the I/O is not complete. If you 
> > have too many anonymous pages and the rest of memory is dirty then you can 
> > get into OOM scenarios even without this patch.
> 
> As long as the reserve is large enough to completely initialize writeout
> of a single page we can make progress. Once writeout is initialized the
> completion interrupt is guaranteed to happen (assuming working
> hardware).

Although interestingly, we are not guaranteed to have enough memory to
completely initialise writeout of a single page.

The buffer layer doesn't require disk blocks to be allocated at page
dirty-time. Allocating disk blocks can require complex filesystem operations
and readin of buffer cache pages. The buffer_head structures themselves may
not even be present and must be allocated :P

In _practice_, this isn't such a problem because we have dirty limits, and
we're almost guaranteed to have some clean pages to be reclaimed. In this
same way, networked filesystems are not a problem in practice. However
network swap, because there is no dirty limits on swap, can actually see
the deadlock problems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
