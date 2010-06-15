Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 644B86B01E4
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 12:34:28 -0400 (EDT)
Date: Tue, 15 Jun 2010 17:34:07 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 0/6] Do not call ->writepage[s] from direct reclaim
	and use a_ops->writepages() where possible
Message-ID: <20100615163407.GS26788@csn.ul.ie>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie> <20100615140011.GD28052@random.random> <20100615141122.GA27893@infradead.org> <20100615142219.GE28052@random.random> <20100615144342.GA3339@infradead.org> <20100615150850.GF28052@random.random> <20100615153838.GO26788@csn.ul.ie> <20100615161419.GH28052@random.random> <20100615163044.GR26788@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100615163044.GR26788@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> > > That is pretty much what Dave is claiming here at
> > > http://lkml.org/lkml/2010/4/13/121 where if mempool_alloc_slab() needed
> > 
> > This stack trace shows writepage called by shrink_page_list... that
> > contradict Christoph's claim that xfs already won't writepage if
> > invoked by direct reclaim.
> > 
> 
> See this
> 
> STATIC int
> xfs_vm_writepage(
>         struct page             *page,
>         struct writeback_control *wbc)
> {
>         int                     error;
>         int                     need_trans;
>         int                     delalloc, unmapped, unwritten;
>         struct inode            *inode = page->mapping->host;
> 
>         trace_xfs_writepage(inode, page, 0);
> 
>         /*
>          * Refuse to write the page out if we are called from reclaim
>          * context.
>          *
>          * This is primarily to avoid stack overflows when called from deep
>          * used stacks in random callers for direct reclaim, but disabling
>          * reclaim for kswap is a nice side-effect as kswapd causes rather
>          * suboptimal I/O patters, too.
>          *
>          * This should really be done by the core VM, but until that happens
>          * filesystems like XFS, btrfs and ext4 have to take care of this
>          * by themselves.
>          */
>         if (current->flags & PF_MEMALLOC)
>                 goto out_fail;
> 

My apologies. I didn't realise this was added so recently. I thought for
a while already so....

> > Not bad at all... throttling is what makes it safe too. Problem is all
> > the rest that isn't solved by this and could be solved with a stack
> > switch, that's my main reason for considering this a ->writepage only
> > hack not complete enough to provide a generic solution for reclaim
> > issues ending up in fs->dm->iscsi/bio. I also suspect xfs is more hog
> > than others (might not be a coicidence the 7k happens with xfs
> > writepage) and could be lightened up a bit by looking into it.
> > 
> 
> Other than the whole "lacking the code" thing and it's still not clear that
> writing from direct reclaim is absolutly necessary for VM stability considering
> it's been ignored today by at least two filesystems.

I retract this point as well because in reality, we have little data on
the full consequences of not writing pages from direct reclaim. Early
data based on the tests I've run indicate that the number of pages
direct reclaim writes is so small that it's not a problem but there is a
strong case for adding throttling at least.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
