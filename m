Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D8EC76B02C3
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 23:59:27 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 123so26306255pga.5
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 20:59:27 -0700 (PDT)
Received: from ipmail01.adl6.internode.on.net (ipmail01.adl6.internode.on.net. [150.101.137.136])
        by mx.google.com with ESMTP id x4si2164199pfi.681.2017.08.10.20.59.25
        for <linux-mm@kvack.org>;
        Thu, 10 Aug 2017 20:59:26 -0700 (PDT)
Date: Fri, 11 Aug 2017 13:59:22 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: How can we share page cache pages for reflinked files?
Message-ID: <20170811035922.GR21024@dastard>
References: <20170810042849.GK21024@dastard>
 <20170810055737.v6yexikxa5zxvntv@node.shutemov.name>
 <20170810090133.GL21024@dastard>
 <20170810133118.va2ziyzcwxmtkbi2@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170810133118.va2ziyzcwxmtkbi2@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>

On Thu, Aug 10, 2017 at 04:31:18PM +0300, Kirill A. Shutemov wrote:
> On Thu, Aug 10, 2017 at 07:01:33PM +1000, Dave Chinner wrote:
> > On Thu, Aug 10, 2017 at 08:57:37AM +0300, Kirill A. Shutemov wrote:
> > > On Thu, Aug 10, 2017 at 02:28:49PM +1000, Dave Chinner wrote:
> > > > Hi folks,
> > > > 
> > > > I've recently been looking into what is involved in sharing page
> > > > cache pages for shared extents in a filesystem. That is, create a
> > > > file, reflink it so there's two files but only one copy of the data
> > > > on disk, then read both files.  Right now, we get two copies of the
> > > > data in the page cache - one in each inode mapping tree.
> > > > 
> > > > If we scale this up to a container host which is using reflink trees
> > > > it's shared root images, there might be hundreds of copies of the
> > > > same data held in cache (i.e. one page per container). Given that
> > > > the filesystem knows that the underlying data extent is shared when
> > > > we go to read it, it's relatively easy to add mechanisms to the
> > > > filesystem to return the same page for all attempts to read the
> > > > from a shared extent from all inodes that share it.
> > > > 
> > > > However, the problem I'm getting stuck on is that the page cache
> > > > itself can't handle inserting a single page into multiple page cache
> > > > mapping trees. i.e. The page has a single pointer to the mapping
> > > > address space, and the mapping has a single pointer back to the
> > > > owner inode. As such, a cached page has a 1:1 mapping to it's host
> > > > inode and this structure seems to be assumed rather widely through
> > > > the code.
> > > 
> > > I think to solve the problem with page->mapping we need something similar
> > > to what we have for anon rmap[1]. In this case we would be able to keep
> > > the same page in page cache for multiple inodes.
> > 
> > Being unfamiliar with the anon rmap code, I'm struggling to see the
> > need for that much complexity here. The AVC abstraction solves a
> > scalability problem that, to me, doesn't exist for tracking multiple
> > mapping tree pointers for a page. i.e. I don't see where a list
> > traversal is necessary in the shared page -> mapping tree resolution
> > for page cache sharing.
> 
> [ Cc: Rik ]
> 
> The reflink interface has potential to construct a tree of dependencies
> between reflinked files similar in complexity to tree of forks (and CoWed
> anon mappings) that lead to current anon rmap design.

I'm too stupid to see the operation that would create the tree of
dependencies you are talking about. Can you outline how we get to
that situation?

AFAICT, the dependencies just don't exist because the reflink
operations don't duplicate the page cache into the new file. And
when we are doing a cache lookup, we are looking for a page with a matching *block address*,
not a specific mapping or index in the cache. The cached page could
be anywhere in the filesystem, it could even be on a different
block device and filesystem. Nothing we have in the page cache
indexes physical block addresses, so these lookups cannot be done
via the page cache.

Physical block index lookups, of course, is what buffer caches are
for.  So essentially the process of sharing the pages cached on a
shared extent is this:

Cold cache:

	1. lookup extent map
	2. find IOMAP_SHARED is set on the extent
	3. Look up iomap->blkno in buffer cache
		a. Search for cached block
		b. not found, instantiate, attach page to buffer
		c. take ref to page, return struct page
	4. insert struct page into page cache
	5. do read IO into page.

Hot cache: Only step 3 changes:

	3. Look up iomap->blkno in buffer cache
		a. Search for cached block
		b. Found, take ref to page,
		c. return struct page

IOWs, we use a buffer cache to provide an inclusive global L2 cache
for pages cached over shared blocks within a filesystem LBA space.
This means there is no "needle in a haystack" search for matching
shared cached pages, nor is there complex dependency graph between
shared pages and mappings.

The only thing that makes this not work right now is that a
struct page can't be shared across mutliple mappings....

> But it's harder to get there accidentally. :)
> 
> > I've been thinking of something simpler along the lines of a dynamic
> > struct page objects w/ special page flags as an object that allows
> > us to keep different mapping tree entries for the same physical
> > page. Seems like this would work for read-only sharing, but perhaps
> > I'm just blind and I'm missing something I shouldn't be?
> 
> Naive approach would be just to put all connected through reflink mappings
> on the same linked list. page->mapping can point to any of them in this
> case. To check that the page actually belong to the mapping we would need
> to look into radix-tree.

There is so much code that assumes page->mapping points to the
mapping (and hence mapping tree) the page has been inserted into.
Indeed, this is how we check for racing with page
invalidation/reclaim after a lookup. i.e. once we've locked a page,
if page->mapping is different to the current mapping we have, then
the page is considered invalid and we shouldn't touch it. This
mechanism is the only thing that makes truncate work correctly in
many filesystems, so changing this is pretty much a non-starter.

Put simply, I'm trying to find a solution that doesn't start with
"break all the filesystems".... :/

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
