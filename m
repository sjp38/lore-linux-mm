Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CAD1C6B005A
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 00:22:02 -0500 (EST)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1O5M0BF004127
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 24 Feb 2009 14:22:00 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D0C0345DE52
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 14:21:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A6DF345DE4F
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 14:21:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C7001DB8041
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 14:21:59 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F4691DB8037
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 14:21:56 +0900 (JST)
Date: Tue, 24 Feb 2009 14:20:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 04/20] Convert gfp_zone() to use a table of
 precalculated value
Message-Id: <20090224142040.5db39fbd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <200902241459.35435.nickpiggin@yahoo.com.au>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie>
	<20090223164047.GO6740@csn.ul.ie>
	<20090224103226.e9e2766f.kamezawa.hiroyu@jp.fujitsu.com>
	<200902241459.35435.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Feb 2009 14:59:34 +1100
Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> On Tuesday 24 February 2009 12:32:26 KAMEZAWA Hiroyuki wrote:
> > On Mon, 23 Feb 2009 16:40:47 +0000
> >
> > Mel Gorman <mel@csn.ul.ie> wrote:
> > > On Mon, Feb 23, 2009 at 10:43:20AM -0500, Christoph Lameter wrote:
> > > > On Tue, 24 Feb 2009, Nick Piggin wrote:
> > > > > > Are you sure that this is a benefit? Jumps are forward and pretty
> > > > > > short and the compiler is optimizing a branch away in the current
> > > > > > code.
> > > > >
> > > > > Pretty easy to mispredict there, though, especially as you can tend
> > > > > to get allocations interleaved between kernel and movable (or simply
> > > > > if the branch predictor is cold there are a lot of branches on
> > > > > x86-64).
> > > > >
> > > > > I would be interested to know if there is a measured improvement.
> > >
> > > Not in kernbench at least, but that is no surprise. It's a small
> > > percentage of the overall cost. It'll appear in the noise for anything
> > > other than micro-benchmarks.
> > >
> > > > > It
> > > > > adds an extra dcache line to the footprint, but OTOH the instructions
> > > > > you quote is more than one icache line, and presumably Mel's code
> > > > > will be a lot shorter.
> > >
> > > Yes, it's an index lookup of a shared read-only cache line versus a lot
> > > of code with branches to mispredict. I wasn't happy with the cache line
> > > consumption but it was the first obvious alternative.
> > >
> > > > Maybe we can come up with a version of gfp_zone that has no branches
> > > > and no lookup?
> > >
> > > Ideally, yes, but I didn't spot any obvious way of figuring it out at
> > > compile time then or now. Suggestions?
> >
> > Assume
> >   ZONE_DMA=0
> >   ZONE_DMA32=1
> >   ZONE_NORMAL=2
> >   ZONE_HIGHMEM=3
> >   ZONE_MOVABLE=4
> >
> > #define __GFP_DMA       ((__force gfp_t)0x01u)
> > #define __GFP_DMA32     ((__force gfp_t)0x02u)
> > #define __GFP_HIGHMEM   ((__force gfp_t)0x04u)
> > #define __GFP_MOVABLE   ((__force gfp_t)0x08u)
> >
> > #define GFP_MAGIC (0400030102) ) #depends on config.
> >
> > gfp_zone(mask) = ((GFP_MAGIC >> ((mask & 0xf)*3) & 0x7)
> 
> Clever!
> 
> But I wonder if it is even valid to perform bitwise operations on
> the zone bits of the gfp mask? Hmm, I see a few places doing it,
> but if we stamped that out, we could just have a simple zone mask
> that takes the zone idx out of the gfp, which would be slightly
> simpler again and more extendible.
> 
IIRC, __GFP_MOVALE works as flag.

And, one troube is that there is no __GFP_NORMAL flag.

I wrote follwoing in old days(before ZONE_MOVABLE). Assume ZONE_NORMAL=2.

//trasnslate gfp_mask to zone_idx.
#define __GFP_DMA	(2)
#define __GFP_DMA32	(3)
#define __GFP_HIGHMEM	(1)
#define __GFP_MOVABLE	(6)

gfp_zone(mask)	= (mask & 0x7) ^ 0x2 //ZONE_NORMAL=2)

But, this doesn't work. ZONE_NORMAL can be 0,1,2. 
(and ppc doesn't have ZONE_NORMAL)


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
