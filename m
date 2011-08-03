Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6FBBE6B016A
	for <linux-mm@kvack.org>; Wed,  3 Aug 2011 09:45:13 -0400 (EDT)
Date: Wed, 3 Aug 2011 14:45:07 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/8] btrfs: Warn if direct reclaim tries to writeback
 pages
Message-ID: <20110803134507.GI19099@suse.de>
References: <1311265730-5324-1-git-send-email-mgorman@suse.de>
 <1311265730-5324-5-git-send-email-mgorman@suse.de>
 <20110803111031.GC27199@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110803111031.GC27199@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Wed, Aug 03, 2011 at 01:10:31PM +0200, Johannes Weiner wrote:
> On Thu, Jul 21, 2011 at 05:28:46PM +0100, Mel Gorman wrote:
> > Direct reclaim should never writeback pages. Warn if an attempt is
> > made. By rights, btrfs should be allowing writepage from kswapd if
> > it is failing to reclaim pages by any other means but it's outside
> > the scope of this patch.
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > ---
> >  fs/btrfs/disk-io.c |    2 ++
> >  fs/btrfs/inode.c   |    2 ++
> >  2 files changed, 4 insertions(+), 0 deletions(-)
> > 
> > diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
> > index 1ac8db5d..cc9c9cf 100644
> > --- a/fs/btrfs/disk-io.c
> > +++ b/fs/btrfs/disk-io.c
> > @@ -829,6 +829,8 @@ static int btree_writepage(struct page *page, struct writeback_control *wbc)
> >  
> >  	tree = &BTRFS_I(page->mapping->host)->io_tree;
> >  	if (!(current->flags & PF_MEMALLOC)) {
> > +		WARN_ON_ONCE((current->flags & (PF_MEMALLOC|PF_KSWAPD)) ==
> > +								PF_MEMALLOC);
> 
> Since it is branch for PF_MEMALLOC being set, why not just
> WARN_ON_ONCE(!(current->flags & PF_KSWAPD)) instead?
> 
> Minor nitpick, though, and I can understand if you just want to have
> the conditionals be the same in every fs.
> 

It was just copying the conditionals for the other FS although I admit
your version would look nicer.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
