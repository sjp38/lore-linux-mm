Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id AC4396B02C7
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 15:16:12 -0400 (EDT)
Date: Thu, 19 Aug 2010 15:16:18 -0400
From: Jeff Layton <jlayton@redhat.com>
Subject: Re: why are WB_SYNC_NONE COMMITs being done with FLUSH_SYNC set ?
Message-ID: <20100819151618.5f769dc9@tlielax.poochiereds.net>
In-Reply-To: <1282229905.6199.19.camel@heimdal.trondhjem.org>
References: <20100819101525.076831ad@barsoom.rdu.redhat.com>
	<20100819143710.GA4752@infradead.org>
	<1282229905.6199.19.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Christoph Hellwig <hch@infradead.org>, fengguang.wu@gmail.com, linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Aug 2010 10:58:25 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> On Thu, 2010-08-19 at 10:37 -0400, Christoph Hellwig wrote:
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
> > and the use in nfs_write_inode.  It's only actually set for memory
> > migration and pageout, that is VM writeback.
> > 
> > To me it really doesn't make much sense, but maybe someone has a better
> > idea what it is for.
> > 
> > > +	if (wbc->nonblocking || wbc->for_background ||
> > > +	    wbc->sync_mode == WB_SYNC_NONE)
> > 
> > You could remove the nonblocking and for_background checks as
> > these impliy WB_SYNC_NONE.
> 
> To me that sounds fine. I've also been trying to wrap my head around the
> differences between 'nonblocking', 'for_background', 'for_reclaim' and
> 'for_kupdate' and how the filesystem is supposed to treat them.
> 
> Aside from the above, I've used 'for_reclaim', 'for_kupdate' and
> 'for_background' in order to adjust the RPC request's queuing priority
> (high in the case of 'for_reclaim' and low for the other two).
> 

Here's a lightly tested patch that turns the check for the two flags
into a check for WB_SYNC_NONE. It seems to do the right thing, but I
don't have a clear testcase for it. Does this look reasonable?

------------------[snip]------------------------

NFS: don't use FLUSH_SYNC on WB_SYNC_NONE COMMIT calls

WB_SYNC_NONE is supposed to mean "don't wait on anything". That should
also include not waiting for COMMIT calls to complete.

WB_SYNC_NONE is also implied when wbc->nonblocking or
wbc->for_background are set, so we can replace those checks in
nfs_commit_unstable_pages with a check for WB_SYNC_NONE.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/write.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 874972d..35bd7d0 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1436,12 +1436,12 @@ static int nfs_commit_unstable_pages(struct inode *inode, struct writeback_contr
 	/* Don't commit yet if this is a non-blocking flush and there are
 	 * lots of outstanding writes for this mapping.
 	 */
-	if (wbc->sync_mode == WB_SYNC_NONE &&
-	    nfsi->ncommit <= (nfsi->npages >> 1))
-		goto out_mark_dirty;
-
-	if (wbc->nonblocking || wbc->for_background)
+	if (wbc->sync_mode == WB_SYNC_NONE) {
+		if (nfsi->ncommit <= (nfsi->npages >> 1))
+			goto out_mark_dirty;
 		flags = 0;
+	}
+
 	ret = nfs_commit_inode(inode, flags);
 	if (ret >= 0) {
 		if (wbc->sync_mode == WB_SYNC_NONE) {

-- 
1.5.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
