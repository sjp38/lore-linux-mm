Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A7B286B00D5
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 03:37:21 -0500 (EST)
Date: Mon, 2 Mar 2009 09:37:18 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] mm: hold page lock over page_mkwrite
Message-ID: <20090302083718.GE1257@wotan.suse.de>
References: <20090225093629.GD22785@wotan.suse.de> <20090301081744.GI26138@disturbed> <20090301135057.GA26905@wotan.suse.de> <20090302081953.GK26138@disturbed>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090302081953.GK26138@disturbed>
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 02, 2009 at 07:19:53PM +1100, Dave Chinner wrote:
> On Sun, Mar 01, 2009 at 02:50:57PM +0100, Nick Piggin wrote:
> > On Sun, Mar 01, 2009 at 07:17:44PM +1100, Dave Chinner wrote:
> > > On Wed, Feb 25, 2009 at 10:36:29AM +0100, Nick Piggin wrote:
> > > > I need this in fsblock because I am working to ensure filesystem metadata
> > > > can be correctly allocated and refcounted. This means that page cleaning
> > > > should not require memory allocation (to be really robust).
> > > 
> > > Which, unfortunately, is just a dream for any filesystem that uses
> > > delayed allocation. i.e. they have to walk the free space trees
> > > which may need to be read from disk and therefore require memory
> > > to succeed....
> > 
> > Well it's a dream because probably none of them get it right, but
> > that doesn't mean its impossible.
> > 
> > You don't need complete memory allocation up-front to be robust,
> > but having reserves or degraded modes that simply guarantee
> > forward progress is enough.
> > 
> > For example, if you need to read/write filesystem metadata to find
> > and allocate free space, then you really only need a page to do all
> > the IO.
> 
> For journalling filesystems, dirty metadata is pinned for at least the
> duration of the transaction and in many cases it is pinned for
> multiple transactions (i.e. in memory aggregation of commits like
> XFS does). And then once the transaction is complete, it can't be
> reused until it is written to disk.
> 
> For the worst case usage in XFS, think about a complete btree split
> of both free space trees, plus a complete btree split of the extent
> tree.  That is two buffers per level per btree that are pinned by
> the transaction.
> 
> The free space trees are bound in depth by the AG size so the limit
> is (IIRC) 15 buffers per tree at 1TB AG size. However, the inode
> extent tree can be deeper than that (bound by filesystem size). In
> effect, writing back a single page could require memory allocation
> of 30-40 pages just for metadata that is dirtied by the allocation
> transaction.
> 
> And then the next page written back goes into a different
> AG and splits the trees there. And then the next does the same.

So assuming there is no reasonable way to do out of core algorithms
on the filesystem metadata (and likely you don't want to anyway
because it would be a significant slowdown or diverge of code
paths), you still only need to reserve one set of those 30-40 pages
for the entire kernel.

You only ever need to reserve enough memory for a *single* page
to be processed. In the worst case that there are multiple pages
under writeout but can't allocate memory, only one will be allowed
access to reserves and the others will block until it is finished
and can unpin them all.


> Luckily, this sort of thing doesn't happen very often, but it does
> serve to demonstrate how difficult it is to quantify how much memory
> the writeback path really needs to guarantee forward progress.
> Hence the dream......

Well I'm not saying it is an immediate problem or it would be a
good use of anybody's time to rush out and try to redesign their
fs code to fix it ;) But at least for any new core/generic library
functionality like fsblock, it would be silly not to close the hole
there (not least because the problem is simpler here than in a
complex fs).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
