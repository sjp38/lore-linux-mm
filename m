Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 163616B004F
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 23:00:10 -0500 (EST)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 04/20] Convert gfp_zone() to use a table of precalculated value
Date: Tue, 24 Feb 2009 14:59:34 +1100
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie> <20090223164047.GO6740@csn.ul.ie> <20090224103226.e9e2766f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090224103226.e9e2766f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200902241459.35435.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Tuesday 24 February 2009 12:32:26 KAMEZAWA Hiroyuki wrote:
> On Mon, 23 Feb 2009 16:40:47 +0000
>
> Mel Gorman <mel@csn.ul.ie> wrote:
> > On Mon, Feb 23, 2009 at 10:43:20AM -0500, Christoph Lameter wrote:
> > > On Tue, 24 Feb 2009, Nick Piggin wrote:
> > > > > Are you sure that this is a benefit? Jumps are forward and pretty
> > > > > short and the compiler is optimizing a branch away in the current
> > > > > code.
> > > >
> > > > Pretty easy to mispredict there, though, especially as you can tend
> > > > to get allocations interleaved between kernel and movable (or simply
> > > > if the branch predictor is cold there are a lot of branches on
> > > > x86-64).
> > > >
> > > > I would be interested to know if there is a measured improvement.
> >
> > Not in kernbench at least, but that is no surprise. It's a small
> > percentage of the overall cost. It'll appear in the noise for anything
> > other than micro-benchmarks.
> >
> > > > It
> > > > adds an extra dcache line to the footprint, but OTOH the instructions
> > > > you quote is more than one icache line, and presumably Mel's code
> > > > will be a lot shorter.
> >
> > Yes, it's an index lookup of a shared read-only cache line versus a lot
> > of code with branches to mispredict. I wasn't happy with the cache line
> > consumption but it was the first obvious alternative.
> >
> > > Maybe we can come up with a version of gfp_zone that has no branches
> > > and no lookup?
> >
> > Ideally, yes, but I didn't spot any obvious way of figuring it out at
> > compile time then or now. Suggestions?
>
> Assume
>   ZONE_DMA=0
>   ZONE_DMA32=1
>   ZONE_NORMAL=2
>   ZONE_HIGHMEM=3
>   ZONE_MOVABLE=4
>
> #define __GFP_DMA       ((__force gfp_t)0x01u)
> #define __GFP_DMA32     ((__force gfp_t)0x02u)
> #define __GFP_HIGHMEM   ((__force gfp_t)0x04u)
> #define __GFP_MOVABLE   ((__force gfp_t)0x08u)
>
> #define GFP_MAGIC (0400030102) ) #depends on config.
>
> gfp_zone(mask) = ((GFP_MAGIC >> ((mask & 0xf)*3) & 0x7)

Clever!

But I wonder if it is even valid to perform bitwise operations on
the zone bits of the gfp mask? Hmm, I see a few places doing it,
but if we stamped that out, we could just have a simple zone mask
that takes the zone idx out of the gfp, which would be slightly
simpler again and more extendible.

But if it's too hard to avoid the bitwise operations, then your idea
is pretty cool ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
