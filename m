Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id EE7676B01D8
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 13:37:59 -0400 (EDT)
Date: Tue, 15 Jun 2010 18:37:47 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC PATCH 0/6] Do not call ->writepage[s] from direct reclaim
 and use a_ops->writepages() where possible
Message-ID: <20100615163747.GK28052@random.random>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
 <20100615140011.GD28052@random.random>
 <20100615141122.GA27893@infradead.org>
 <20100615142219.GE28052@random.random>
 <20100615144342.GA3339@infradead.org>
 <20100615150850.GF28052@random.random>
 <20100615153838.GO26788@csn.ul.ie>
 <20100615161419.GH28052@random.random>
 <20100615163044.GR26788@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100615163044.GR26788@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 15, 2010 at 05:30:44PM +0100, Mel Gorman wrote:
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

so it's under xfs/linux-2.6... ;) I guess this dates back from the
xfs/irix xfs/freebsd days, no prob.

> Again, missing the code to do it and am missing data showing that not
> writing pages in direct reclaim is really a bad idea.

Your code is functionally fine, my point is it's not just writepage as
shown by the PF_MEMALLOC check in ext4.

> Other than the whole "lacking the code" thing and it's still not clear that
> writing from direct reclaim is absolutly necessary for VM stability considering
> it's been ignored today by at least two filesystems. I can add the throttling
> logic if it'd make you happied but I know it'd be at least two weeks
>  before I could start from scratch on a
> stack-switch-based-solution and a PITA considering that I'm not convinced
> it's necessary :)

The reason things are working on I think is because of
wait_on_page_writeback. By the time lots of ram is full with dirty
pdflush and stuff will submit I/O, then VM will still wait on I/O to
complete. Waiting is eating no stack, submitting I/O does instead. So
that explains why everything works fine.

It'd be interesting to verify that things don't fall apart with
current xfs if you swapon ./file_on_xfs instead of /dev/something.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
