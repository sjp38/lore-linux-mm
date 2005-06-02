Date: Thu, 2 Jun 2005 14:15:09 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Avoiding external fragmentation with a placement policy Version
 12
In-Reply-To: <423970000.1117668514@flay>
Message-ID: <Pine.LNX.4.58.0506021120120.4112@skynet>
References: <20050531112048.D2511E57A@skynet.csn.ul.ie> <429E20B6.2000907@austin.ibm.com>
 <429E4023.2010308@yahoo.com.au> <423970000.1117668514@flay>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, jschopp@austin.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Wed, 1 Jun 2005, Martin J. Bligh wrote:

> --On Thursday, June 02, 2005 09:09:23 +1000 Nick Piggin <nickpiggin@yahoo.com.au> wrote:
>
> > Joel Schopp wrote:
> >
> >>
> >> Other than the very minor whitespace changes above I have nothing bad to
> >> say about this patch.  I think it is about time to pick in up in -mm for
> >> wider testing.
> >>
> >
> > It adds a lot of complexity to the page allocator and while
> > it might be very good, the only improvement we've been shown
> > yet is allocating lots of MAX_ORDER allocations I think? (ie.
> > not very useful)
>
> I agree that MAX_ORDER allocs aren't interesting, but we can hit
> frag problems easily at way less than max order. CIFS does it, NFS
> does it, jumbo frame gigabit ethernet does it, to name a few. The
> most common failure I see is order 3.
>

I focused on the MAX_ORDER allocations for two reasons. The first is
because they are very difficult to satisfy. If we can service MAX_ORDER
allocations, we can certainly service order 3. The second is that my very
long-term (and currently vapour-ware) aim is to transparently support
large pages which will require 4MiB blocks on the x86 at least.

> Keep a machine up for a while, get it thoroughly fragmented, then
> push it reasonably hard constant pressure, and try allocating anything
> large.
>

That is what bench-stresshighalloc does with order-10 allocations. It
compiles 7 trees at -j4 for a few minutes and then tries to allocate 160
pages. It tends to manage about 50% of them comparised to 1-5% with the
standard allocator (which also kills everything).

> Seems to me we're basically pointing a blunderbuss at memory, and
> blowing away large portions, and *hoping* something falls out the
> bottom that's a big enough chunk?
>

With this allocator, we are still using a blunderbus approach but the
chances of big enough chunks been available are a lot better. I released a
proof-of-concept patch that freed pages by linearly scanning that worked
very well, but it needs a lot of work. Linearly scanning would help
guarantee high-order allocations but the penalty is that LRU-ordering
would be violated.

To test lower-order allocations, I ran a slightly different test where I
tried to allocate 6000 order-5 pages under heavy pressure. The standard
allocator repeatadly went OOM and allocated 5190 pages. The modified one
did not OOM and allocated 5961. The test is not very fair though because
it pins memory and the allocations are type GFP_KERNEL. For the gigabit
ethernet and network filesystem tests, I imagine we are dealing with
GFP_ATOMIC or GFP_NFS?

-- 
Mel Gorman
Part-time Phd Student                          Java Applications Developer
University of Limerick                         IBM Dublin Software Lab
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
