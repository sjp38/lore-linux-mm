Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E00016B01E3
	for <linux-mm@kvack.org>; Sun, 25 Apr 2010 20:32:45 -0400 (EDT)
Subject: Locking between writeback and truncate paths?
From: "Theodore Ts'o" <tytso@mit.edu>
Message-Id: <E1O6CFc-0006Y2-SY@closure.thunk.org>
Date: Sun, 25 Apr 2010 20:32:40 -0400
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: linux-ext4@vger.kernel.org
List-ID: <linux-mm.kvack.org>


Has anyone looked into whether it might make sense to have have a lock
which which blocks vmtruncate() from racing against the writeback code?
Arguments in favor of the status quo is that if the inode happens to be
undergoing writeback, and we know we're about to truncate the sucker,
it's best if we can stop the writeback ASAP and avoid the wasted work.

However, modern file systems have to do multiple pass against the page
cache; first to find out how many dirty pages are present so that the
delayed allocation can be efficiently targetted against the free space
on disk; then the file system has to allocate the necessary extent, and
the finally the buffer heads attached to the pages need to be populated
and the page sent out for writeback.  However what if while this is
happening, on another CPU, some of the pages are truncated and then
(perhaps on a 3rd CPU) the pages are written to again once again subject
to delayed allocation?

Right now, ext4 doesn't protect against this; I'm working on it fixing
it.  But fixing it in the file system, while possible, is nasty, since
it means that we have to constantly recheck against file systems
get_blocks() filesystem against every single page, after locking each
page, just in case the we happen to be racing against a truncate.  I
suppose I could put in a lock to prevent the fs-level truncate from
completing until the inode's writeback is complete, but then it's still
possible that we will have allocated too much space (since the truncate
happened right after we finished counting out the delalloc pages), and
we need to make sure extent is marked uninitalized lest we crash right
after the allocate and before the truncate takes place.  Ugh!

I'm prety sure I can make it work, but it won't necessarily be the
fastest thing in the world, and it will require taking a bunch of extra
locks, some of them for every single page being written.  It would be
simpler to simply add a mutual exclusion between truncate and writeback;
which has a downside, as I've acknowledged --- but which case is more
common and thus worth optimizing for?  The normal writeback case, or
being able to avoid some extra disk writes in the case where the
truncate is issued exactly while the write back code is processing the
inode?

Any thoughts or suggestions would be greatly appreciated.  I've looked
at the xfs and btrfs code for some ideas, but dealing with current
writeback and truncate is nasty, especially if there's a subsequent
delalloc write happening in parallel with the writeback and immediately
after the truncate.  After studying the code quite extensively over the
weekend, I'm still not entirely sure that XFS and btrfs gets this case
right (I know ext4 currently doesn't).  Of course, it's not clear
whether users will trip against this in practice, but it's nevertheless
still a botch, and I'm wondering if it's simpler to avoid the concurrent
vmtruncate/writeback case entirely.

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
