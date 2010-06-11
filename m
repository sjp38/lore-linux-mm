Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 227EE6B0071
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 02:11:14 -0400 (EDT)
Date: Thu, 10 Jun 2010 23:10:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/6] vmscan: Write out ranges of pages contiguous to the
 inode where possible
Message-Id: <20100610231045.7fcd6f9d.akpm@linux-foundation.org>
In-Reply-To: <1275987745-21708-6-git-send-email-mel@csn.ul.ie>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
	<1275987745-21708-6-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue,  8 Jun 2010 10:02:24 +0100 Mel Gorman <mel@csn.ul.ie> wrote:

> Page reclaim cleans individual pages using a_ops->writepage() because from
> the VM perspective, it is known that pages in a particular zone must be freed
> soon, it considers the target page to be the oldest and it does not want
> to wait while background flushers cleans other pages. From a filesystem
> perspective this is extremely inefficient as it generates a very seeky
> IO pattern leading to the perverse situation where it can take longer to
> clean all dirty pages than it would have otherwise.
> 
> This patch recognises that there are cases where a number of pages
> belonging to the same inode are being written out. When this happens and
> writepages() is implemented, the range of pages will be written out with
> a_ops->writepages. The inode is pinned and the page lock released before
> submitting the range to the filesystem. While this potentially means that
> more pages are cleaned than strictly necessary, the expectation is that the
> filesystem will be able to writeout the pages more efficiently and improve
> overall performance.
> 
> ...
>
> +			/* Write single page */
> +			switch (write_reclaim_page(cursor, mapping, PAGEOUT_IO_ASYNC)) {
> +			case PAGE_KEEP:
> +			case PAGE_ACTIVATE:
> +			case PAGE_CLEAN:
> +				unlock_page(cursor);
> +				break;
> +			case PAGE_SUCCESS:
> +				break;
> +			}
> +		} else {
> +			/* Grab inode under page lock before writing range */
> +			struct inode *inode = igrab(mapping->host);
> +			unlock_page(cursor);
> +			if (inode) {
> +				do_writepages(mapping, &wbc);
> +				iput(inode);

Buggy.


I did this, umm ~8 years ago and ended up reverting it because it was
complex and didn't seem to buy us anything.  Of course, that was before
we broke the VM and started writing out lots of LRU pages.  That code
was better than your code - it grabbed the address_space and did
writearound around the target page.

The reason this code is buggy is that under extreme memory pressure
(<oldfart>the sort of testing nobody does any more</oldfart>) it can be
the case that this iput() is the final iput() on this inode.

Now go take a look at iput_final(), which I bet has never been executed
on this path in your testing.  It takes a large number of high-level
VFS locks.  Locks which cannot be taken from deep within page reclaim
without causing various deadlocks.

I did solve that problem before reverting it all but I forget how.  By
holding a page lock to pin the address_space rather than igrab(),
perhaps.  Go take a look - it was somewhere between 2.5.1 and 2.5.10 if
I vaguely recall correctly.

Or don't take a look - we shouldn't need to do any of this anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
