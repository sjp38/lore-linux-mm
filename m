Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2E3E06B01AC
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 03:50:12 -0400 (EDT)
Date: Thu, 1 Jul 2010 17:50:06 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: vmap area cache
Message-ID: <20100701075006.GB22976@laptop>
References: <20100531080757.GE9453@laptop>
 <20100602144905.aa613dec.akpm@linux-foundation.org>
 <20100603135533.GO6822@laptop>
 <1277470817.3158.386.camel@localhost.localdomain>
 <20100626083122.GE29809@laptop>
 <20100630162602.874ebd2a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100630162602.874ebd2a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Steven Whitehouse <swhiteho@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, Avi Kivity <avi@redhat.com>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 30, 2010 at 04:26:02PM -0700, Andrew Morton wrote:
> On Sat, 26 Jun 2010 18:31:22 +1000
> Nick Piggin <npiggin@suse.de> wrote:
> 
> > On Fri, Jun 25, 2010 at 02:00:17PM +0100, Steven Whitehouse wrote:
> > > Hi,
> > > 
> > > Barry Marson has now tested your patch and it seems to work just fine.
> > > Sorry for the delay,
> > > 
> > > Steve.
> > 
> > Hi Steve,
> > 
> > Thanks for that, do you mean that it has solved thee regression?
> 
> Nick, can we please have an updated changelog for this patch?  I didn't
> even know it fixed a regression (what regression?).  Barry's tested-by:
> would be nice too, along with any quantitative results from that.
> 
> Thanks.

Sure. It is a performance regression caused by the lazy vunmap patches
which went in a while back. So it's appropriate for 2.6.36, and then
probably distros will want to backport it, if not -stable.

How's this?
--

mm: vmalloc add a free area cache for vmaps

Provide a free area cache for the vmalloc virtual address allocator,
based on the algorithm used by the user virtual memory allocator.

This reduces the number of rbtree operations and linear traversals over
the vmap extents in order to find a free area, by starting off at the
last point that a free area was found.

The free area cache is reset if areas are freed behind it, or if we are
searching for a smaller area or alignment than last time. So allocation
patterns are not changed (verified by corner-case and random test cases
in userspace testing).

This solves a regression caused by lazy vunmap TLB purging introduced
in db64fe02 (mm: rewrite vmap layer). That patch will leave extents in
the vmap allocator after they are vunmapped, and until a significant
number accumulate that can be flushed in a single batch. So in a
workload that vmalloc/vfree frequently, a chain of extents will build
up from VMALLOC_START address, which have to be iterated over each
time (giving an O(n) type of behaviour).

After this patch, the search will start from where it left off, giving
closer to an amortized O(1).

This is verified to solve regressions reported Steven in GFS2, and Avi
in KVM.

Signed-off-by: Nick Piggin <npiggin@suse.de>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Reported-and-tested-by: Steven Whitehouse <swhiteho@redhat.com>
Reported-and-tested-by: Avi Kivity <avi@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
