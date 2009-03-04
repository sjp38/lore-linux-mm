Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 124AC6B009A
	for <linux-mm@kvack.org>; Tue,  3 Mar 2009 23:38:05 -0500 (EST)
Date: Wed, 4 Mar 2009 15:37:39 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [patch][rfc] mm: hold page lock over page_mkwrite
Message-ID: <20090304043739.GM26138@disturbed>
References: <20090225093629.GD22785@wotan.suse.de> <20090301081744.GI26138@disturbed> <20090301135057.GA26905@wotan.suse.de> <20090302081953.GK26138@disturbed> <20090302083718.GE1257@wotan.suse.de> <49ABFA9D.90801@hp.com> <20090303043338.GB3973@wotan.suse.de> <20090303172535.GA16993@shareable.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090303172535.GA16993@shareable.org>
Sender: owner-linux-mm@kvack.org
To: Jamie Lokier <jamie@shareable.org>
Cc: Nick Piggin <npiggin@suse.de>, jim owens <jowens@hp.com>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 03, 2009 at 05:25:36PM +0000, Jamie Lokier wrote:
> > > it so "we can always make forward progress".  But it won't
> > > matter because once a real user drives the system off this
> > > cliff there is no difference between "hung" and "really slow
> > > progress".  They are going to crash it and report a hang.
> > 
> > I don't think that is the case. These are situations that
> > would be *really* rare and transient. It is not like thrashing
> > in that your working set size exceeds physical RAM, but just
> > a combination of conditions that causes an unusual spike in the
> > required memory to clean some dirty pages (eg. Dave's example
> > of several IOs requiring btree splits over several AGs). Could
> > cause a resource deadlock.
> 
> Suppose the systems has two pages to be written.  The first must
> _reserve_ 40 pages of scratch space just in case the operation will
> need them.  If the second page write is initiated concurrently with
> the first, the second must reserve another 40 pages concurrently.
> 
> If 10 page writes are concurrent, that's 400 pages of scratch space
> needed in reserve...

Therein lies the problem. XFS can do this in parallel in every AG at
the same time. i.e. the reserve is per AG. The maximum number of AGs
in XFS is 2^32, and I know of filesystems out there that have
thousands of AGs in them. Hence reserving 40 pages per AG is
definitely unreasonable. ;)

Even if we look at concurrent allocations as the upper bound, I've
seen an 8p machine with several hundred concurrent allocation
transactions in progress. Even that is unreasonable if you consider
machines with 64k pages - it's hundreds of megabytes of RAM that are
mostly going to be unused.

Specifying a pool of pages is not a guaranteed solution, either,
as someone will always exhaust it as we can't guarantee any given
transaction will complete before the pool is exhausted. i.e.
the mempool design as it stands can't be used.

AFAIC, "should never allocate during writeback" is a great goal, but
it is one that we will never be able to reach without throwing
everything away and starting again. Minimising allocation is
something we can do but we can't avoid it entirely. The higher
layers need to understand this, not assert that the lower layers
must conform to an impossible constraint and break if they don't.....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
