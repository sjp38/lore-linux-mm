In-reply-to: <200808011122.51792.nickpiggin@yahoo.com.au> (message from Nick
	Piggin on Fri, 1 Aug 2008 11:22:51 +1000)
Subject: Re: [patch v3] splice: fix race with page invalidation
References: <E1KO8DV-0004E4-6H@pomaz-ex.szeredi.hu> <alpine.LFD.1.10.0807310957200.3277@nehalem.linux-foundation.org> <E1KOceD-0000nD-JA@pomaz-ex.szeredi.hu> <200808011122.51792.nickpiggin@yahoo.com.au>
Message-Id: <E1KOzMt-0003fa-Ah@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Fri, 01 Aug 2008 20:28:47 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: nickpiggin@yahoo.com.au
Cc: miklos@szeredi.hu, torvalds@linux-foundation.org, jens.axboe@oracle.com, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 1 Aug 2008, Nick Piggin wrote:
> Well, a) it probably makes sense in that case to provide another mode
> of operation which fills the data synchronously from the sender and
> copys it to the pipe (although the sender might just use read/write)
> And b) we could *also* look at clearing PG_uptodate as an optimisation
> iff that is found to help.

IMO it's not worth it to complicate the API just for the sake of
correctness in the so-very-rare read error case.  Users of the splice
API will simply ignore this requirement, because things will work fine
on ext3 and friends, and will break only rarely on NFS and FUSE.

So I think it's much better to make the API simple: invalid pages are
OK, and for I/O errors we return -EIO on the pipe.  It's not 100%
correct, but all in all it will result in less buggy programs.

Thanks,
Miklos
----

Subject: mm: dont clear PG_uptodate on truncate/invalidate

From: Miklos Szeredi <mszeredi@suse.cz>

Brian Wang reported that a FUSE filesystem exported through NFS could return
I/O errors on read.  This was traced to splice_direct_to_actor() returning a
short or zero count when racing with page invalidation.

However this is not FUSE or NFSD specific, other filesystems (notably NFS)
also call invalidate_inode_pages2() to purge stale data from the cache.

If this happens while such pages are sitting in a pipe buffer, then splice(2)
from the pipe can return zero, and read(2) from the pipe can return ENODATA.

The zero return is especially bad, since it implies end-of-file or
disconnected pipe/socket, and is documented as such for splice.  But returning
an error for read() is also nasty, when in fact there was no error (data
becoming stale is not an error).

The same problems can be triggered by "hole punching" with
madvise(MADV_REMOVE).

Fix this by not clearing the PG_uptodate flag on truncation and
invalidation.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---
 mm/truncate.c |    2 --
 1 file changed, 2 deletions(-)

Index: linux-2.6/mm/truncate.c
===================================================================
--- linux-2.6.orig/mm/truncate.c	2008-07-28 17:45:02.000000000 +0200
+++ linux-2.6/mm/truncate.c	2008-08-01 20:18:51.000000000 +0200
@@ -104,7 +104,6 @@ truncate_complete_page(struct address_sp
 	cancel_dirty_page(page, PAGE_CACHE_SIZE);
 
 	remove_from_page_cache(page);
-	ClearPageUptodate(page);
 	ClearPageMappedToDisk(page);
 	page_cache_release(page);	/* pagecache ref */
 }
@@ -356,7 +355,6 @@ invalidate_complete_page2(struct address
 	BUG_ON(PagePrivate(page));
 	__remove_from_page_cache(page);
 	spin_unlock_irq(&mapping->tree_lock);
-	ClearPageUptodate(page);
 	page_cache_release(page);	/* pagecache ref */
 	return 1;
 failed:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
