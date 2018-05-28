Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4A5636B0007
	for <linux-mm@kvack.org>; Mon, 28 May 2018 02:51:49 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id p9-v6so814160wrm.22
        for <linux-mm@kvack.org>; Sun, 27 May 2018 23:51:49 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id m204-v6si5160249wmf.227.2018.05.27.23.51.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 May 2018 23:51:47 -0700 (PDT)
Date: Mon, 28 May 2018 08:57:50 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 2/2] xfs: add support for sub-pagesize writeback
	without buffer_heads
Message-ID: <20180528065750.GA5098@lst.de>
References: <20180523144646.19159-1-hch@lst.de> <20180523144646.19159-3-hch@lst.de> <20180525171714.GB92502@bfoster.bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180525171714.GB92502@bfoster.bfoster>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Foster <bfoster@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Fri, May 25, 2018 at 01:17:15PM -0400, Brian Foster wrote:
> On Wed, May 23, 2018 at 04:46:46PM +0200, Christoph Hellwig wrote:
> > Switch to using the iomap_page structure for checking sub-page uptodate
> > status and track sub-page I/O completion status, and remove large
> > quantities of boilerplate code working around buffer heads.
> > 
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > ---
> >  fs/xfs/xfs_aops.c  | 536 +++++++--------------------------------------
> >  fs/xfs/xfs_buf.h   |   1 -
> >  fs/xfs/xfs_iomap.c |   3 -
> >  fs/xfs/xfs_super.c |   2 +-
> >  fs/xfs/xfs_trace.h |  18 +-
> >  5 files changed, 79 insertions(+), 481 deletions(-)
> > 
> > diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> > index efa2cbb27d67..d279929e53fb 100644
> > --- a/fs/xfs/xfs_aops.c
> > +++ b/fs/xfs/xfs_aops.c
> ...
> > @@ -768,7 +620,7 @@ xfs_aops_discard_page(
> >  	int			error;
> >  
> >  	if (XFS_FORCED_SHUTDOWN(mp))
> > -		goto out_invalidate;
> > +		goto out;
> >  
> >  	xfs_alert(mp,
> >  		"page discard on page "PTR_FMT", inode 0x%llx, offset %llu.",
> > @@ -778,15 +630,15 @@ xfs_aops_discard_page(
> >  			PAGE_SIZE / i_blocksize(inode));
> >  	if (error && !XFS_FORCED_SHUTDOWN(mp))
> >  		xfs_alert(mp, "page discard unable to remove delalloc mapping.");
> > -out_invalidate:
> > -	xfs_vm_invalidatepage(page, 0, PAGE_SIZE);
> > +out:
> > +	iomap_invalidatepage(page, 0, PAGE_SIZE);
> 
> All this does is lose the tracepoint. I don't think this call needs to
> change. The rest looks Ok to me, but I still need to run some tests on
> the whole thing.

Ok.  I actually had it that way, then thought we shouldn't need the
invalidatepage without bufferheads, but it turns out we still do and
added it back this way.  I'll go back to start and won't collect $200..
