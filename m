From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 0/5]  [RFC] transfer ASYNC vmscan writeback IO to the flusher threads
Date: Thu, 29 Jul 2010 19:51:42 +0800
Message-ID: <20100729115142.102255590@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1OeS9I-0006WK-94
	for glkm-linux-mm-2@m.gmane.org; Thu, 29 Jul 2010 14:23:44 +0200
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2688C6B02A9
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 08:23:27 -0400 (EDT)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>
List-Id: linux-mm.kvack.org

Andrew,

It's possible to transfer ASYNC vmscan writeback IOs to the flusher threads.
This simple patchset shows the basic idea. Since it's a big behavior change,
there are inevitably lots of details to sort out. I don't know where it will
go after tests and discussions, so the patches are intentionally kept simple.

sync livelock avoidance (need more to be complete, but this is minimal required for the last two patches)
	[PATCH 1/5] writeback: introduce wbc.for_sync to cover the two sync stages
	[PATCH 2/5] writeback: stop periodic/background work on seeing sync works
	[PATCH 3/5] writeback: prevent sync livelock with the sync_after timestamp

let the flusher threads do ASYNC writeback for pageout()
	[PATCH 4/5] writeback: introduce bdi_start_inode_writeback()
	[PATCH 5/5] vmscan: transfer async file writeback to the flusher

The last two patches are the meats, they depend on the first three patches to
kick the background writeback work, so that the for_reclaim writeback can be
serviced timely.

Comments are welcome!

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
