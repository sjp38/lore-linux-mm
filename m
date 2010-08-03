Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id CF4C2620113
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 09:36:47 -0400 (EDT)
Date: Tue, 3 Aug 2010 21:44:31 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/5] writeback: stop periodic/background work on seeing
 sync works
Message-ID: <20100803134431.GA32173@localhost>
References: <20100729115142.102255590@intel.com>
 <20100729121423.332557547@intel.com>
 <20100729162027.GF12690@quack.suse.cz>
 <20100730040306.GA5694@localhost>
 <20100802205152.GL3278@quack.suse.cz>
 <20100803030125.GA12070@localhost>
 <20100803105520.GA3322@quack.suse.cz>
 <20100803123922.GC3322@quack.suse.cz>
 <20100803125924.GA31827@localhost>
 <20100803132216.GA31893@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100803132216.GA31893@localhost>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 03, 2010 at 09:22:16PM +0800, Wu Fengguang wrote:
> > >   Fengguang, how about merging also the attached simple patch together with
> > > my fix? With these two patches, I'm not able to trigger any sync livelock
> > > while without one of them I hit them quite easily...
> > 
> > This looks OK. However note that redirty_tail() can modify
> > dirtied_when unexpectedly. So the more we rely on wb_start, the more
> > possibility an inode is (wrongly) skipped by sync. I have a bunch of
> > patches to remove redirty_tail(). However they may not be good
> > candidates for 2.6.36..
> 
> It looks that setting wb_start at the beginning of
> writeback_inodes_wb() won't be easily affected by redirty_tail().

Except for this redirty_tail(), which may mess up the dirtied_when
ordering in b_dirty and later on break the assumption of
inode_dirtied_after(inode, wbc->wb_start).

It can be replaced by a requeue_io() for now.  Christoph mentioned a
patchset to introduce sb->s_wb, which should be a better solution.

Thanks,
Fengguang

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index a178828..e56e68b 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -457,12 +457,7 @@ int generic_writeback_sb_inodes(struct super_block *sb,
 
 		if (inode->i_sb != sb) {
 			if (only_this_sb) {
-				/*
-				 * We only want to write back data for this
-				 * superblock, move all inodes not belonging
-				 * to it back onto the dirty list.
-				 */
-				redirty_tail(inode);
+				requeue_io(inode);
 				continue;
 			}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
