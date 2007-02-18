Date: Sun, 18 Feb 2007 15:59:16 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: dirty balancing deadlock
Message-Id: <20070218155916.0d3c73a9.akpm@linux-foundation.org>
In-Reply-To: <E1HIvMB-0005Fd-00@dorka.pomaz.szeredi.hu>
References: <E1HIqlm-0004iZ-00@dorka.pomaz.szeredi.hu>
	<20070218125307.4103c04a.akpm@linux-foundation.org>
	<E1HIurG-0005Bw-00@dorka.pomaz.szeredi.hu>
	<20070218145929.547c21c7.akpm@linux-foundation.org>
	<E1HIvMB-0005Fd-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 19 Feb 2007 00:22:11 +0100 Miklos Szeredi <miklos@szeredi.hu> wrote:

> > If so, writes to B will decrease the dirty memory threshold.
> 
> Yes, but not by enough.  Say A dirties a 1100 pages, limit is 1000.
> Some pages queued for writeback (doesn't matter how much).  B writes
> back 1, 1099 dirty remain in A, zero in B.  balance_dirty_pages() for
> B doesn't know that there's nothing more to write back for B, it's
> just waiting there for those 1099, which'll never get written.

hm, OK, arguable.  I guess something like this..

--- a/fs/fs-writeback.c~a
+++ a/fs/fs-writeback.c
@@ -356,7 +356,7 @@ int generic_sync_sb_inodes(struct super_
 			continue;		/* Skip a congested blockdev */
 		}
 
-		if (wbc->bdi && bdi != wbc->bdi) {
+		if (wbc->bdi && bdi != wbc->bdi && bdi_write_congested(bdi)) {
 			if (!sb_is_blkdev_sb(sb))
 				break;		/* fs has the wrong queue */
 			list_move(&inode->i_list, &sb->s_dirty);
_

but where's pdflush?  It should be busily transferring dirtiness from A to
B.

> > The writeout code _should_ just sit there transferring dirtyiness from A to
> > B and cleaning pages via B, looping around, alternating between both.
> > 
> > What does sysrq-t say?
> 
> This is the fuse daemon thread that got stuck.

Where's pdflsuh?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
