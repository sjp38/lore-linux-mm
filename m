Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4AC436B020D
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 20:50:16 -0400 (EDT)
Date: Thu, 19 Aug 2010 20:53:32 -0400
From: Jeff Layton <jlayton@redhat.com>
Subject: Re: why are WB_SYNC_NONE COMMITs being done with FLUSH_SYNC set ?
Message-ID: <20100819205332.5ea929ee@corrin.poochiereds.net>
In-Reply-To: <20100820003308.GA30548@localhost>
References: <20100819101525.076831ad@barsoom.rdu.redhat.com>
	<20100819143710.GA4752@infradead.org>
	<1282229905.6199.19.camel@heimdal.trondhjem.org>
	<20100819151618.5f769dc9@tlielax.poochiereds.net>
	<20100820003308.GA30548@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@gmail.com>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 20 Aug 2010 08:33:08 +0800
Wu Fengguang <fengguang.wu@gmail.com> wrote:

> > Here's a lightly tested patch that turns the check for the two flags
> > into a check for WB_SYNC_NONE. It seems to do the right thing, but I
> > don't have a clear testcase for it. Does this look reasonable?
>  
> Yes, I don't see any problems.
> 
> > ------------------[snip]------------------------
> > 
> > NFS: don't use FLUSH_SYNC on WB_SYNC_NONE COMMIT calls
> > 
> > WB_SYNC_NONE is supposed to mean "don't wait on anything". That should
> > also include not waiting for COMMIT calls to complete.
> > 
> > WB_SYNC_NONE is also implied when wbc->nonblocking or
> > wbc->for_background are set, so we can replace those checks in
> > nfs_commit_unstable_pages with a check for WB_SYNC_NONE.
> >
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/nfs/write.c |   10 +++++-----
> >  1 files changed, 5 insertions(+), 5 deletions(-)
> > 
> > diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> > index 874972d..35bd7d0 100644
> > --- a/fs/nfs/write.c
> > +++ b/fs/nfs/write.c
> > @@ -1436,12 +1436,12 @@ static int nfs_commit_unstable_pages(struct inode *inode, struct writeback_contr
> >  	/* Don't commit yet if this is a non-blocking flush and there are
> >  	 * lots of outstanding writes for this mapping.
> >  	 */
> > -	if (wbc->sync_mode == WB_SYNC_NONE &&
> > -	    nfsi->ncommit <= (nfsi->npages >> 1))
> > -		goto out_mark_dirty;
> > -
> > -	if (wbc->nonblocking || wbc->for_background)
> > +	if (wbc->sync_mode == WB_SYNC_NONE) {
> > +		if (nfsi->ncommit <= (nfsi->npages >> 1))
> > +			goto out_mark_dirty;
> >  		flags = 0;
> > +	}
> > +
> 
> nitpick: I'd slightly prefer an one-line change
> 
> -       if (wbc->nonblocking || wbc->for_background)
> +       if (wbc->sync_mode == WB_SYNC_NONE)
>                 flags = 0;
> 
> That way the patch will look more obvious and "git blame" friendly,
> and the original "Don't commit.." comment will best match its code.
> 
> Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
> 
> Thanks,
> Fengguang

Either way. I figured it would be slightly more efficient to just check
WB_SYNC_NONE once in that function. I suppose we could just fix up the
comments instead. Let me know if I should respin the patch with updated
comments...

Thanks for the review...
-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
