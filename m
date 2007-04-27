Date: Fri, 27 Apr 2007 10:15:41 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 09/10] SLUB: Exploit page mobility to increase allocation
 order
In-Reply-To: <20070427111431.GF3645@skynet.ie>
Message-ID: <Pine.LNX.4.64.0704271008390.1873@schroedinger.engr.sgi.com>
References: <20070427042655.019305162@sgi.com> <20070427042909.415420974@sgi.com>
 <20070427111431.GF3645@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Apr 2007, Mel Gorman wrote:

> On (26/04/07 21:27), clameter@sgi.com didst pronounce:
> > If there is page mobility then we can defragment memory. So its possible to
> > use higher order of pages for slab allocations.
> > 
> > If the defaults were not overridden set the max order to 4 and guarantee 16
> > objects per slab. This will put some stress on Mel's antifrag approaches.
> > If these defaults are too large then they should be later reduced.
> > 
> 
> I see this went through mm-commits. When the next -mm kernel comes out,
> I'll grind them through the external fragmentation tests and see how it
> works out. Not all slabs are reclaimable so it might have side-effects
> if there are large amounts of slab allocations that are not allocated
> __GFP_RECLAIMABLE. Testing will tell.

Well you have not seen the whole story then. I have a draft here of a 
patch to implement slab callbacks to free objects. I think the first 
victim will be the dentry cache. I will use that functionality first to
defrag the slab cache by

1. Sort the slabs on the partial list by the number of objects inuse
   (already in mm).

2. Start from the back of the list with the smallest number of objects
   and use the callback to either free or reallocate the object. That
   will allocate new objects from the slabs with the most objects.
   Meaning the partial list will shrink on both head and tail.

3. With that I could provide you with a function to attempt to free
   up a slab page which could be used in some form for defragmentation
   from the page allocator.
   Would be great if we could work out a protocol on how to do this.
   This will initially be done with the dentry cache.

This advanced SLUB reclaim material is not suitable for 2.6.22 and I will 
keep it out of mm for awhile.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
