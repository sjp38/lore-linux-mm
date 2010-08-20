Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3DB6C6B0200
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 20:03:16 -0400 (EDT)
Received: by pvc30 with SMTP id 30so1094948pvc.14
        for <linux-mm@kvack.org>; Thu, 19 Aug 2010 17:03:14 -0700 (PDT)
Date: Fri, 20 Aug 2010 08:02:58 +0800
From: Wu Fengguang <fengguang.wu@gmail.com>
Subject: Re: why are WB_SYNC_NONE COMMITs being done with FLUSH_SYNC set ?
Message-ID: <20100820000258.GA30226@localhost>
References: <20100819101525.076831ad@barsoom.rdu.redhat.com>
 <20100819143710.GA4752@infradead.org>
 <20100819235553.GB22747@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="UlVJffcvxoiEqYs2"
Content-Disposition: inline
In-Reply-To: <20100819235553.GB22747@localhost>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Jens Axboe <axboe@kernel.dk>, David Howells <dhowells@redhat.com>, Sage Weil <sage@newdream.net>, Steve French <sfrench@samba.org>
List-ID: <linux-mm.kvack.org>


--UlVJffcvxoiEqYs2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

[add CC to afs/cifs/ceph maintainers]

On Fri, Aug 20, 2010 at 07:55:53AM +0800, Wu Fengguang wrote:
> On Thu, Aug 19, 2010 at 10:37:10AM -0400, Christoph Hellwig wrote:
> > On Thu, Aug 19, 2010 at 10:15:25AM -0400, Jeff Layton wrote:
> > > I'm looking at backporting some upstream changes to earlier kernels,
> > > and ran across something I don't quite understand...
> > > 
> > > In nfs_commit_unstable_pages, we set the flags to FLUSH_SYNC. We then
> > > zero out the flags if wbc->nonblocking or wbc->for_background is set.
> > > 
> > > Shouldn't we also clear it out if wbc->sync_mode == WB_SYNC_NONE ?
> > > WB_SYNC_NONE means "don't wait on anything", so shouldn't that include
> > > not waiting on the COMMIT to complete?
> > 
> > I've been trying to figure out what the nonblocking flag is supposed
> > to mean for a while now.
> > 
> > It basically disappeared in commit 0d99519efef15fd0cf84a849492c7b1deee1e4b7
> > 
> > 	"writeback: remove unused nonblocking and congestion checks"
> > 
> > from Wu.  What's left these days is a couple of places in local copies
> > of write_cache_pages (afs, cifs), and a couple of checks in random
> > writepages instances (afs, block_write_full_page, ceph, nfs, reiserfs, xfs)
> > and the use in nfs_write_inode.
> 
> In principle all nonblocking checks in ->writepages should be removed.
> 
> (My original patch does have chunks for afs/cifs that somehow get
>  dropped in the process, and missed ceph because it's not upstream
>  when I started patch..)
> 
> > It's only actually set for memory
> > migration and pageout, that is VM writeback.
> > 
> > To me it really doesn't make much sense, but maybe someone has a better
> > idea what it is for.
>  
> Since migration and pageout still set nonblocking for ->writepage, we
> may keep them in the near future, until VM does not start IO on itself.
> 
> > > +	if (wbc->nonblocking || wbc->for_background ||
> > > +	    wbc->sync_mode == WB_SYNC_NONE)
> > 
> > You could remove the nonblocking and for_background checks as
> > these impliy WB_SYNC_NONE.
> 
> Agreed.
> 
> Thanks,
> Fengguang

--UlVJffcvxoiEqYs2
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="writeback-remove-congested-checks.patch"

Subject: writeback: remove useless nonblocking checks in ->writepages
From: Wu Fengguang <fengguang.wu@intel.com>
Date: Fri Aug 20 07:04:54 CST 2010

This removes more deadcode that was somehow missed by commit 0d99519efef
(writeback: remove unused nonblocking and congestion checks).

The nonblocking checks in ->writepages are no longer used because the
flusher now prefer to block on get_request_wait() than to skip inodes on
IO congestion. The latter will lead to more seeky IO.

CC: David Howells <dhowells@redhat.com>
CC: Sage Weil <sage@newdream.net>
CC: Steve French <sfrench@samba.org>
CC: Chris Mason <chris.mason@oracle.com>
CC: Jens Axboe <axboe@kernel.dk>
CC: Christoph Hellwig <hch@infradead.org>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/afs/write.c |   16 +---------------
 fs/cifs/file.c |   10 ----------
 2 files changed, 1 insertion(+), 25 deletions(-)

--- linux-next.orig/fs/afs/write.c	2010-06-24 14:32:01.000000000 +0800
+++ linux-next/fs/afs/write.c	2010-08-20 07:03:01.000000000 +0800
@@ -455,8 +455,6 @@ int afs_writepage(struct page *page, str
 	}
 
 	wbc->nr_to_write -= ret;
-	if (wbc->nonblocking && bdi_write_congested(bdi))
-		wbc->encountered_congestion = 1;
 
 	_leave(" = 0");
 	return 0;
@@ -529,11 +527,6 @@ static int afs_writepages_region(struct 
 
 		wbc->nr_to_write -= ret;
 
-		if (wbc->nonblocking && bdi_write_congested(bdi)) {
-			wbc->encountered_congestion = 1;
-			break;
-		}
-
 		cond_resched();
 	} while (index < end && wbc->nr_to_write > 0);
 
@@ -554,18 +547,11 @@ int afs_writepages(struct address_space 
 
 	_enter("");
 
-	if (wbc->nonblocking && bdi_write_congested(bdi)) {
-		wbc->encountered_congestion = 1;
-		_leave(" = 0 [congest]");
-		return 0;
-	}
-
 	if (wbc->range_cyclic) {
 		start = mapping->writeback_index;
 		end = -1;
 		ret = afs_writepages_region(mapping, wbc, start, end, &next);
-		if (start > 0 && wbc->nr_to_write > 0 && ret == 0 &&
-		    !(wbc->nonblocking && wbc->encountered_congestion))
+		if (start > 0 && wbc->nr_to_write > 0 && ret == 0)
 			ret = afs_writepages_region(mapping, wbc, 0, start,
 						    &next);
 		mapping->writeback_index = next;
--- linux-next.orig/fs/cifs/file.c	2010-08-20 06:57:11.000000000 +0800
+++ linux-next/fs/cifs/file.c	2010-08-20 07:03:01.000000000 +0800
@@ -1379,16 +1379,6 @@ static int cifs_writepages(struct addres
 		return generic_writepages(mapping, wbc);
 
 
-	/*
-	 * BB: Is this meaningful for a non-block-device file system?
-	 * If it is, we should test it again after we do I/O
-	 */
-	if (wbc->nonblocking && bdi_write_congested(bdi)) {
-		wbc->encountered_congestion = 1;
-		kfree(iov);
-		return 0;
-	}
-
 	xid = GetXid();
 
 	pagevec_init(&pvec, 0);

--UlVJffcvxoiEqYs2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
