Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 47A1E6B023C
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 10:22:52 -0400 (EDT)
Date: Tue, 15 Jun 2010 16:22:19 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC PATCH 0/6] Do not call ->writepage[s] from direct reclaim
 and use a_ops->writepages() where possible
Message-ID: <20100615142219.GE28052@random.random>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
 <20100615140011.GD28052@random.random>
 <20100615141122.GA27893@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100615141122.GA27893@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 15, 2010 at 10:11:22AM -0400, Christoph Hellwig wrote:
> On Tue, Jun 15, 2010 at 04:00:11PM +0200, Andrea Arcangeli wrote:
> > collecting clean cache doesn't still satisfy the allocation), during
> > allocations in direct reclaim and increase the THREAD_SIZE than doing
> > this purely for stack reasons as the VM will lose reliability if we
> 
> This basically means doubling the stack size, as you can splice together
> two extremtly stack hungry codepathes in the worst case.  Do you really
> want order 2 stack allocations?

If we were forbidden to call ->writepage just because of stack
overflow yes as I don't think it's big deal with memory compaction and
I see this as a too limiting design to allow ->writepage only in
kernel thread. ->writepage is also called by the pagecache layer,
msync etc.. not just by kswapd.

But let's defer this after we have any resemblance of hard numbers of
worst-case stack usage measured during the aforementioned workload, I
didn't read all the details as I'm quite against this design, but I
didn't see any stack usage number or any sign of stack-overflow debug
triggering. I'd suggest to measure the max stack usage first and worry
later.

And if ->writepage is a stack hog in some fs, I'd rather see
->writepage made less stack hungry (with proper warning at runtime
with debug option enabled) than vetoed. The VM itself shouldn't be a
stack hog already. I don't see a particular reason why writepage
should be so stuck hungry compared to the rest of the kernel, it just
have to do I/O, if it requires complex data structure it should
kmalloc those and stay light on stack as everybody else.

And if something I'm worried more about slab shrink than ->writepage
as that enters the vfs layer and then the lowlevel fs to collect the
dentry, inode etc...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
