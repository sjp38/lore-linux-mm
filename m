Message-ID: <3D78DD07.E36AE3A9@zip.com.au>
Date: Fri, 06 Sep 2002 09:51:19 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: 2.5.33-mm4 filemap_copy_from_user: Unexpected page fault
References: <1031327285.1984.155.camel@spc9.esa.lanl.gov>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steven Cole <elenstev@mesatop.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Steven Cole wrote:
> 
> With 2.5.33-mm4, I tried running dbench on an ext2 partition and was
> able to run up to dbench 80 successfully.  However, at dbench 96, I got
> four messages like this:
> 
> filemap_copy_from_user: Unexpected page fault

Yep.  This means that the page we faulted in by-hand in generic_file_write()
wasn't resident during the subsequent copy_from_user().

That fault-in by-hand is there to prevent a deadlock.  That printk
meand that it isnt working all the time.   We have (always had) a
problem.

> Shortly after this, the box hung again,
> ...
> >>EIP; c0159bf4 <sync_sb_inodes+84/260>   <=====
> Trace; c0159e1e <writeback_inodes+4e/80>
> Trace; c013b8aa <background_writeout+7a/c0>
> Trace; c013b4cb <__pdflush+12b/1d0>

Hum.  Thanks for that.

I've been dbenching and compiling all night.  And yet, it
seems that the dirty inode search in sync_sb_inodes() can trivially
lock up.

Does this fix?

 fs-writeback.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

--- 2.5.33/fs/fs-writeback.c~scole	Fri Sep  6 09:50:25 2002
+++ 2.5.33-akpm/fs/fs-writeback.c	Fri Sep  6 09:50:47 2002
@@ -242,16 +242,16 @@ sync_sb_inodes(struct super_block *sb, s
 
 		if (wbc->nonblocking && bdi_write_congested(bdi)) {
 			wbc->encountered_congestion = 1;
+			list_move(&inode->i_list, &sb->s_dirty);
 			if (sb != blockdev_superblock)
 				break;		/* Skip the entire fs */
-			list_move(&inode->i_list, &sb->s_dirty);
 			continue;
 		}
 
 		if (wbc->bdi && bdi != wbc->bdi) {
+			list_move(&inode->i_list, &sb->s_dirty);
 			if (sb != blockdev_superblock)
 				break;		/* inappropriate superblock */
-			list_move(&inode->i_list, &sb->s_dirty);
 			continue;		/* not this blockdev */
 		}
 

.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
