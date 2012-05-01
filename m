Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 9D10D6B004D
	for <linux-mm@kvack.org>; Tue,  1 May 2012 17:30:09 -0400 (EDT)
Date: Tue, 1 May 2012 23:29:58 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/5] mm + fs: prepare for non-page entries in page cache
Message-ID: <20120501212958.GC2112@cmpxchg.org>
References: <1335861713-4573-1-git-send-email-hannes@cmpxchg.org>
 <1335861713-4573-3-git-send-email-hannes@cmpxchg.org>
 <20120501120246.83d2ce28.akpm@linux-foundation.org>
 <20120501201504.GB2112@cmpxchg.org>
 <20120501132449.30485966.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120501132449.30485966.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, May 01, 2012 at 01:24:49PM -0700, Andrew Morton wrote:
> On Tue, 1 May 2012 22:15:04 +0200
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > On Tue, May 01, 2012 at 12:02:46PM -0700, Andrew Morton wrote:
> > > On Tue,  1 May 2012 10:41:50 +0200
> > > Johannes Weiner <hannes@cmpxchg.org> wrote:
> > > 
> > > > --- a/fs/inode.c
> > > > +++ b/fs/inode.c
> > > > @@ -544,8 +544,7 @@ static void evict(struct inode *inode)
> > > >  	if (op->evict_inode) {
> > > >  		op->evict_inode(inode);
> > > >  	} else {
> > > > -		if (inode->i_data.nrpages)
> > > > -			truncate_inode_pages(&inode->i_data, 0);
> > > > +		truncate_inode_pages(&inode->i_data, 0);
> > > 
> > > Why did we lose this optimisation?
> > 
> > For inodes with only shadow pages remaining in the tree, because there
> > is no separate counter for them.  Otherwise, we'd leak the tree nodes.
> > 
> > I had mapping->nrshadows at first to keep truncation conditional, but
> > thought that using an extra word per cached inode would be worse than
> > removing this optimization.  There is not too much being done when the
> > tree is empty.
> > 
> > Another solution would be to include the shadows count in ->nrpages,
> > but filesystems use this counter for various other purposes.
> > 
> > Do you think it's worth reconsidering?
> 
> It doesn't sound like it's worth adding ->nrshadows for only that
> reason.
> 
> That's a pretty significant alteration in the meaning of ->nrpages. 
> Did this not have any other effects?

It still means "number of page entries in radix tree", just that the
radix tree can be non-empty when this count drops to zero.  AFAICS,
it's used when writing/syncing the inode or when gathering statistics,
like nr_blockdev_pages().  They only care about actual pages.  It's
just the final truncate that has to make sure to remove the non-pages
as well.

> What does truncate do?  I assume it invalidates shadow page entries in
> the radix tree?  And frees the radix-tree nodes?

Yes, it just does a radix_tree_delete() on these shadow page entries,
see clear_exceptional_entry() in mm/truncate.c.  This garbage-collects
empty nodes.

> The patchset will make lookups slower in some (probably obscure)
> circumstances, due to the additional radix-tree nodes.
> 
> I assume that if a pagecache lookup encounters a radix-tree node which
> contains no real pages, the search will terminate at that point?  We
> don't pointlessly go all the way down to the leaf nodes?

When reading/instantiating it's not pointless.  Empty slots or shadow
slots are faults and we have to retrieve the shadow entries to
calculate the refault distance.

When writing: dirtied pages are tagged, and tags are propagated
upwards in the tree, so we don't check any more nodes than before.
For leaf nodes (64 slots) where shadow entries and dirty pages mix,
the cost of skipping shadow entries is a bit bigger than that of empty
slots (see the radix_tree_exception branch in find_get_pages(), which
Hugh added to handle shmem's swap entries).

Then there are filesystems that do page cache lookups for population
analysis/heuristics, they could indeed pointlessly descend to leaf
nodes that only contain non-page entries.  I haven't investigated yet
how hot these paths actuallly are.  If this turns out to be a problem,
we could add another tag and trade tree size for performance.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
