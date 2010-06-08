Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id AE2696B01D0
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 05:28:34 -0400 (EDT)
Date: Tue, 8 Jun 2010 10:28:14 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 0/6] Do not call ->writepage[s] from direct reclaim
	and use a_ops->writepages() where possible
Message-ID: <20100608092814.GB27717@csn.ul.ie>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie> <20100608090811.GA5949@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100608090811.GA5949@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 08, 2010 at 05:08:11AM -0400, Christoph Hellwig wrote:
> On Tue, Jun 08, 2010 at 10:02:19AM +0100, Mel Gorman wrote:
> > seeky patterns.  The second is that direct reclaim calling the filesystem
> > splices two potentially deep call paths together and potentially overflows
> > the stack on complex storage or filesystems. This series is an early draft
> > at tackling both of these problems and is in three stages.
> 
> Btw, one more thing came up when I discussed the issue again with Dave
> recently:
> 
>  - we also need to care about ->releasepage.  At least for XFS it
>    can end up in the same deep allocator chain as ->writepage because
>    it does all the extent state conversions, even if it doesn't
>    start I/O. 

Dang.

>    I haven't managed yet to decode the ext4/btrfs codepaths
>    for ->releasepage yet to figure out how they release a page that
>    covers a delayed allocated or unwritten range.
> 

If ext4/btrfs are also very deep call-chains and this series is going more
or less the right direction, then avoiding calling ->releasepage from direct
reclaim is one, somewhat unfortunate, option. The second is to avoid it on
a per-filesystem basis for direct reclaim using PF_MEMALLOC to detect
reclaimers and PF_KSWAPD to tell the difference between direct
reclaimers and kswapd.

Either way, these pages could be treated similar to dirty pages on the
dirty_pages list.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
