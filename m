From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 0/6] [RFC] writeback: try to write older pages first
Date: Thu, 22 Jul 2010 13:09:28 +0800
Message-ID: <20100722050928.653312535@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1Obp8G-0003hg-0U
	for glkm-linux-mm-2@m.gmane.org; Thu, 22 Jul 2010 08:19:48 +0200
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 45C506006B6
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 02:19:33 -0400 (EDT)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Andrew,

The basic way of avoiding pageout() is to make the flusher sync inodes in the
right order. Oldest dirty inodes contains oldest pages. The smaller inode it
is, the more correlation between inode dirty time and its pages' dirty time.
So for small dirty inodes, syncing in the order of inode dirty time is able to
avoid pageout(). If pageout() is still triggered frequently in this case, the
30s dirty expire time may be too long and could be shrinked adaptively; or it
may be a stressed memcg list whose dirty inodes/pages are more hard to track.

For a large dirty inode, it may flush lots of newly dirtied pages _after_
syncing the expired pages. This is the normal case for a single-stream
sequential dirtier, where older pages are in lower offsets.  In this case we
shall not insist on syncing the whole large dirty inode before considering the
other small dirty inodes. This risks wasting time syncing 1GB freshly dirtied
pages before syncing the other N*1MB expired dirty pages who are approaching
the end of the LRU list and hence pageout().

For a large dirty inode, it may also flush lots of newly dirtied pages _before_
hitting the desired old ones, in which case it helps for pageout() to do some
clustered writeback, and/or set mapping->writeback_index to help the flusher
focus on old pages.

For a large dirty inode, it may also have intermixed old and new dirty pages.
In this case we need to make sure the inode is queued for IO before some of
its pages hit pageout(). Adaptive dirty expire time helps here.

OK, end of the vapour ideas. As for this patchset, it fixes the current
kupdate/background writeback priority:

- the kupdate/background writeback shall include newly expired inodes at each
  queue_io() time, as the large inodes left over from previous writeback rounds
  are likely to have less density of old pages.

- the background writeback shall consider expired inodes first, just like the
  kupdate writeback

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
