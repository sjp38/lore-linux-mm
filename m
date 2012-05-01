Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 0FCD26B004D
	for <linux-mm@kvack.org>; Tue,  1 May 2012 16:24:53 -0400 (EDT)
Date: Tue, 1 May 2012 13:24:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/5] mm + fs: prepare for non-page entries in page cache
Message-Id: <20120501132449.30485966.akpm@linux-foundation.org>
In-Reply-To: <20120501201504.GB2112@cmpxchg.org>
References: <1335861713-4573-1-git-send-email-hannes@cmpxchg.org>
	<1335861713-4573-3-git-send-email-hannes@cmpxchg.org>
	<20120501120246.83d2ce28.akpm@linux-foundation.org>
	<20120501201504.GB2112@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 1 May 2012 22:15:04 +0200
Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Tue, May 01, 2012 at 12:02:46PM -0700, Andrew Morton wrote:
> > On Tue,  1 May 2012 10:41:50 +0200
> > Johannes Weiner <hannes@cmpxchg.org> wrote:
> > 
> > > --- a/fs/inode.c
> > > +++ b/fs/inode.c
> > > @@ -544,8 +544,7 @@ static void evict(struct inode *inode)
> > >  	if (op->evict_inode) {
> > >  		op->evict_inode(inode);
> > >  	} else {
> > > -		if (inode->i_data.nrpages)
> > > -			truncate_inode_pages(&inode->i_data, 0);
> > > +		truncate_inode_pages(&inode->i_data, 0);
> > 
> > Why did we lose this optimisation?
> 
> For inodes with only shadow pages remaining in the tree, because there
> is no separate counter for them.  Otherwise, we'd leak the tree nodes.
> 
> I had mapping->nrshadows at first to keep truncation conditional, but
> thought that using an extra word per cached inode would be worse than
> removing this optimization.  There is not too much being done when the
> tree is empty.
> 
> Another solution would be to include the shadows count in ->nrpages,
> but filesystems use this counter for various other purposes.
> 
> Do you think it's worth reconsidering?

It doesn't sound like it's worth adding ->nrshadows for only that
reason.

That's a pretty significant alteration in the meaning of ->nrpages. 
Did this not have any other effects?

What does truncate do?  I assume it invalidates shadow page entries in
the radix tree?  And frees the radix-tree nodes?

The patchset will make lookups slower in some (probably obscure)
circumstances, due to the additional radix-tree nodes.

I assume that if a pagecache lookup encounters a radix-tree node which
contains no real pages, the search will terminate at that point?  We
don't pointlessly go all the way down to the leaf nodes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
