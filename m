Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id EF5A16B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 09:46:41 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id k62-v6so8409531oiy.1
        for <linux-mm@kvack.org>; Thu, 31 May 2018 06:46:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o23-v6si14303464oto.55.2018.05.31.06.46.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 May 2018 06:46:40 -0700 (PDT)
Date: Thu, 31 May 2018 09:46:38 -0400
From: Brian Foster <bfoster@redhat.com>
Subject: Re: [PATCH 07/18] xfs: remove the now unused XFS_BMAPI_IGSTATE flag
Message-ID: <20180531134637.GA2997@bfoster.bfoster>
References: <20180530100013.31358-1-hch@lst.de>
 <20180530100013.31358-8-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180530100013.31358-8-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 30, 2018 at 12:00:02PM +0200, Christoph Hellwig wrote:
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---

The change looks Ok... It's clearly reasonable to remove a flag that is
no longer used, but why is it no longer used? The previous patch drops
it to "make xfs_writepage_map() extent map centric," but the description
doesn't exactly explain why (and it's not immediately clear to me
amongst all the other code changes).

My understanding of the purpose of IGSTATE here is that if we already
have an iotype == unwritten ioend, it makes sense to combine contiguous
mappings since we'd convert the unwritten portions on I/O completion.
Now that we look up extent first and establish the ioend type from that
rather than set the ioend type based on the buffer state, I suppose it
is possible for IGSTATE to lose the fact that a contiguous unwritten
extent ends up being merged with a normal extent before the ioend type
is established..? Then again, was IGSTATE even effective in this context
with nimaps == 1?

This change may very well be fine in the end, but it's made
unnecessarily difficult to review by the nature of the previous patch.
ISTM that if this is a dependency of the broader change, it should be
split off into a separate patch that drops the usage and the flag
together and explains why.

Brian

>  fs/xfs/libxfs/xfs_bmap.c | 6 ++----
>  fs/xfs/libxfs/xfs_bmap.h | 3 ---
>  2 files changed, 2 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/xfs/libxfs/xfs_bmap.c b/fs/xfs/libxfs/xfs_bmap.c
> index 7b0e2b551e23..4b5e014417d2 100644
> --- a/fs/xfs/libxfs/xfs_bmap.c
> +++ b/fs/xfs/libxfs/xfs_bmap.c
> @@ -3799,8 +3799,7 @@ xfs_bmapi_update_map(
>  		   mval[-1].br_startblock != HOLESTARTBLOCK &&
>  		   mval->br_startblock == mval[-1].br_startblock +
>  					  mval[-1].br_blockcount &&
> -		   ((flags & XFS_BMAPI_IGSTATE) ||
> -			mval[-1].br_state == mval->br_state)) {
> +		   mval[-1].br_state == mval->br_state) {
>  		ASSERT(mval->br_startoff ==
>  		       mval[-1].br_startoff + mval[-1].br_blockcount);
>  		mval[-1].br_blockcount += mval->br_blockcount;
> @@ -3845,7 +3844,7 @@ xfs_bmapi_read(
>  
>  	ASSERT(*nmap >= 1);
>  	ASSERT(!(flags & ~(XFS_BMAPI_ATTRFORK|XFS_BMAPI_ENTIRE|
> -			   XFS_BMAPI_IGSTATE|XFS_BMAPI_COWFORK)));
> +			   XFS_BMAPI_COWFORK)));
>  	ASSERT(xfs_isilocked(ip, XFS_ILOCK_SHARED|XFS_ILOCK_EXCL));
>  
>  	if (unlikely(XFS_TEST_ERROR(
> @@ -4290,7 +4289,6 @@ xfs_bmapi_write(
>  
>  	ASSERT(*nmap >= 1);
>  	ASSERT(*nmap <= XFS_BMAP_MAX_NMAP);
> -	ASSERT(!(flags & XFS_BMAPI_IGSTATE));
>  	ASSERT(tp != NULL ||
>  	       (flags & (XFS_BMAPI_CONVERT | XFS_BMAPI_COWFORK)) ==
>  			(XFS_BMAPI_CONVERT | XFS_BMAPI_COWFORK));
> diff --git a/fs/xfs/libxfs/xfs_bmap.h b/fs/xfs/libxfs/xfs_bmap.h
> index 2c233f9f1a26..a845fe57d1b5 100644
> --- a/fs/xfs/libxfs/xfs_bmap.h
> +++ b/fs/xfs/libxfs/xfs_bmap.h
> @@ -80,8 +80,6 @@ struct xfs_extent_free_item
>  #define XFS_BMAPI_METADATA	0x002	/* mapping metadata not user data */
>  #define XFS_BMAPI_ATTRFORK	0x004	/* use attribute fork not data */
>  #define XFS_BMAPI_PREALLOC	0x008	/* preallocation op: unwritten space */
> -#define XFS_BMAPI_IGSTATE	0x010	/* Ignore state - */
> -					/* combine contig. space */
>  #define XFS_BMAPI_CONTIG	0x020	/* must allocate only one extent */
>  /*
>   * unwritten extent conversion - this needs write cache flushing and no additional
> @@ -128,7 +126,6 @@ struct xfs_extent_free_item
>  	{ XFS_BMAPI_METADATA,	"METADATA" }, \
>  	{ XFS_BMAPI_ATTRFORK,	"ATTRFORK" }, \
>  	{ XFS_BMAPI_PREALLOC,	"PREALLOC" }, \
> -	{ XFS_BMAPI_IGSTATE,	"IGSTATE" }, \
>  	{ XFS_BMAPI_CONTIG,	"CONTIG" }, \
>  	{ XFS_BMAPI_CONVERT,	"CONVERT" }, \
>  	{ XFS_BMAPI_ZERO,	"ZERO" }, \
> -- 
> 2.17.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
