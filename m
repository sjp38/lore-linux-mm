From: Daniel Phillips <phillips@phunq.net>
Subject: Re: [PATCH 00/10] foundations for reserve-based allocation
Date: Mon, 6 Aug 2007 12:53:19 -0700
References: <20070806102922.907530000@chello.nl> <200708061231.04982.phillips@phunq.net> <1186429018.11797.100.camel@lappy>
In-Reply-To: <1186429018.11797.100.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200708061253.20149.phillips@phunq.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

On Monday 06 August 2007 12:36, Peter Zijlstra wrote:
> On Mon, 2007-08-06 at 12:31 -0700, Daniel Phillips wrote:
> > On Monday 06 August 2007 11:17, Peter Zijlstra wrote:
> > > And how do we know a page was taken out of the reserves?
> >
> > Why not return that in the low bit of the page address?  This is a
> > little more cache efficient, does not leave that odd footprint in
> > the page union and forces the caller to examine the
> > alloc_pages(...P_MEMALLOC) return, making it harder to overlook the
> > fact that it got a page out of reserve and forget to put one back
> > later.
>
> This would require auditing all page allocation sites to ensure they
> ever happen under PF_MEMALLOC or the like. Because if an allocator
> ever fails to check the low bit and assumes its a valid struct page
> *, stuff will go *bang*.

But is that not exactly what we want?  If somebody sets __GFP_MEMALLOC 
then they had better be prepared to deal with the result.

OK, I see there are cases where the the gfp flags are blindly passed 
down level after level (tending to indicate a design flaw anyway) but 
they usually also get passed back up the chain without examination.  
Yes, an audit would be needed, but since when has that ever stood in 
the way of a miniscule optimization?  And if we miss a case it 
helpfully goes bang on us, no need to play games with new function 
names or the like.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
