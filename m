Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8BF4A6B01C4
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 05:08:17 -0400 (EDT)
Date: Tue, 8 Jun 2010 05:08:11 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC PATCH 0/6] Do not call ->writepage[s] from direct reclaim
 and use a_ops->writepages() where possible
Message-ID: <20100608090811.GA5949@infradead.org>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 08, 2010 at 10:02:19AM +0100, Mel Gorman wrote:
> seeky patterns.  The second is that direct reclaim calling the filesystem
> splices two potentially deep call paths together and potentially overflows
> the stack on complex storage or filesystems. This series is an early draft
> at tackling both of these problems and is in three stages.

Btw, one more thing came up when I discussed the issue again with Dave
recently:

 - we also need to care about ->releasepage.  At least for XFS it
   can end up in the same deep allocator chain as ->writepage because
   it does all the extent state conversions, even if it doesn't
   start I/O.  I haven't managed yet to decode the ext4/btrfs codepaths
   for ->releasepage yet to figure out how they release a page that
   covers a delayed allocated or unwritten range.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
