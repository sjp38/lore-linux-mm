Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E8678600375
	for <linux-mm@kvack.org>; Sat, 24 Apr 2010 22:40:30 -0400 (EDT)
Subject: No one seems to be using AOP_WRITEPAGE_ACTIVATE?
From: "Theodore Ts'o" <tytso@mit.edu>
Message-Id: <E1O5rld-0001AX-Lk@closure.thunk.org>
Date: Sat, 24 Apr 2010 22:40:21 -0400
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org
List-ID: <linux-mm.kvack.org>


I happened to be going through the source code for write_cache_pages(),
and I came across a reference to AOP_WRITEPAGE_ACTIVATE.  I was curious
what the heck that was, so I did search for it, and found this in
Documentation/filesystems/vfs.txt:

      If wbc->sync_mode is WB_SYNC_NONE, ->writepage doesn't have to
      try too hard if there are problems, and may choose to write out
      other pages from the mapping if that is easier (e.g. due to
      internal dependencies).  If it chooses not to start writeout, it
      should return AOP_WRITEPAGE_ACTIVATE so that the VM will not keep
      calling ->writepage on that page.

      See the file "Locking" for more details.

No filesystems are currently returning AOP_WRITEPAGE_ACTIVATE when it
chooses not to writeout page and call redirty_page_for_writeback()
instead.

Is this a change we should make, for example when btrfs refuses a
writepage() when PF_MEMALLOC is set, or when ext4 refuses a writepage()
if the page involved hasn't been allocated an on-disk block yet (i.e.,
delayed allocation)?  The change seems to be that we should call
redirty_page_for_writeback() as before, but then _not_ unlock the page,
and return AOP_WRITEPAGE_ACTIVATE.  Is this a good and useful thing for
us to do?

Right now, the only writepage() function which is returning
AOP_WRITEPAGE_ACTIVATE is shmem_writepage(), and very curiously it's not
using redirty_page_for_writeback().  Should it, out of consistency's
sake if not to keep various zone accounting straight?

There are some longer-term issues, including the fact that ext4 and
btrfs are violating some of the rules laid out in
Documentation/vfs/Locking regarding what writepage() is supposed to do
under direct reclaim -- something which isn't going to be practical for
us to change on the file-system side, at least not without doing some
pretty nasty and serious rework, for both ext4 and I suspect btrfs.  But
if returning AOP_WRITEPAGE_ACTIVATE will help the VM deal more
gracefully with the fact that ext4 and btrfs will be refusing
writepage() calls under certain conditions, maybe we should make this
change?

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
