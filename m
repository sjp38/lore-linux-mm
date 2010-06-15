Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 738F8620089
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 12:14:51 -0400 (EDT)
Date: Tue, 15 Jun 2010 18:14:19 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC PATCH 0/6] Do not call ->writepage[s] from direct reclaim
 and use a_ops->writepages() where possible
Message-ID: <20100615161419.GH28052@random.random>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
 <20100615140011.GD28052@random.random>
 <20100615141122.GA27893@infradead.org>
 <20100615142219.GE28052@random.random>
 <20100615144342.GA3339@infradead.org>
 <20100615150850.GF28052@random.random>
 <20100615153838.GO26788@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100615153838.GO26788@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 15, 2010 at 04:38:38PM +0100, Mel Gorman wrote:
> That is pretty much what Dave is claiming here at
> http://lkml.org/lkml/2010/4/13/121 where if mempool_alloc_slab() needed

This stack trace shows writepage called by shrink_page_list... that
contradict Christoph's claim that xfs already won't writepage if
invoked by direct reclaim.

> to allocate a page and writepage was entered, there would have been a
> a problem.

There can't be a problem if a page wasn't available in mempool because
we can't nest two writepage on top of the other or it'd deadlock on fs
locks and this is the reason of GFP_NOFS, like noticed in the email.

Surely this shows the writepage going very close to the stack
size... probably not enough to trigger the stack detector but close
enough to worry! Agreed.

I think we just need to switch stack on do_try_to_free_pages to solve
it, and not just writepage or the filesystems.

> Broken or not, it's what some of them are doing to avoid stack
> overflows. Worst, they are ignoring both kswapd and direct reclaim when they
> only really needed to ignore kswapd. With this series at least, the
> check for PF_MEMALLOC in ->writepage can be removed

I don't get how we end up in xfs_buf_ioapply above though if xfs
writepage is a noop on PF_MEMALLOC. Definitely PF_MEMALLOC is set
before try_to_free_pages but in the above trace writepage still runs
and submit the I/O.

> This series would at least allow kswapd to turn dirty pages into clean
> ones so it's an improvement.

Not saying it's not an improvement, but still it's not necessarily the
right direction.

> Other than a lack of code to do it :/

;)

> If you really feel strongly about this, you could follow on the series
> by extending clean_page_list() to switch stack if !kswapd.
>
> This has actually been the case for a while. I vaguely recall FS people

Again not what looks like from the stack trace. Also grepping for
PF_MEMALLOC in fs/xfs shows nothing. In fact it's ext4_write_inode
that skips the write if PF_MEMALLOC is set, not writepage apparently
(only did a quick grep so I might be wrong). I suspect
ext4_write_inode is the case I just mentioned about slab shrink, not
->writepage ;).

inodes are small, it's no big deal to keep an inode pinned and not
slab-reclaimable because dirty, while skipping real writepage in
memory pressure could really open a regression in oom false positives!
One pagecache much bigger than one inode and there can be plenty more
dirty pagecache than inodes.

> i.e. when direct reclaim encounters N dirty pages, unconditionally ask the
> flusher threads to clean that number of pages, throttle by waiting for them
> to be cleaned, reclaim them if they get cleaned or otherwise scan more pages
> on the LRU.

Not bad at all... throttling is what makes it safe too. Problem is all
the rest that isn't solved by this and could be solved with a stack
switch, that's my main reason for considering this a ->writepage only
hack not complete enough to provide a generic solution for reclaim
issues ending up in fs->dm->iscsi/bio. I also suspect xfs is more hog
than others (might not be a coicidence the 7k happens with xfs
writepage) and could be lightened up a bit by looking into it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
