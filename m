Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id CD6546B0005
	for <linux-mm@kvack.org>; Thu, 24 May 2018 11:07:03 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id 8-v6so957090oip.22
        for <linux-mm@kvack.org>; Thu, 24 May 2018 08:07:03 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z6-v6si7504408oig.176.2018.05.24.08.07.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 08:07:01 -0700 (PDT)
Date: Thu, 24 May 2018 11:06:59 -0400
From: Brian Foster <bfoster@redhat.com>
Subject: Re: [PATCH 25/34] xfs: remove xfs_reflink_trim_irec_to_next_cow
Message-ID: <20180524150658.GC84959@bfoster.bfoster>
References: <20180523144357.18985-1-hch@lst.de>
 <20180523144357.18985-26-hch@lst.de>
 <20180524145943.GB84959@bfoster.bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180524145943.GB84959@bfoster.bfoster>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, May 24, 2018 at 10:59:43AM -0400, Brian Foster wrote:
> On Wed, May 23, 2018 at 04:43:48PM +0200, Christoph Hellwig wrote:
> > In the only caller we just did a lookup in the COW extent tree for
> > the same offset.  Reuse that result and save a lookup, as well as
> > shortening the ilock hold time.
> > 
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > ---
> >  fs/xfs/xfs_aops.c    | 25 +++++++++++++++++--------
> >  fs/xfs/xfs_reflink.c | 33 ---------------------------------
> >  fs/xfs/xfs_reflink.h |  2 --
> >  3 files changed, 17 insertions(+), 43 deletions(-)
> > 
> > diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> > index a4b4a7037deb..354d26d66c12 100644
> > --- a/fs/xfs/xfs_aops.c
> > +++ b/fs/xfs/xfs_aops.c
> > @@ -383,11 +383,12 @@ xfs_map_blocks(
> >  	struct xfs_inode	*ip = XFS_I(inode);
> >  	struct xfs_mount	*mp = ip->i_mount;
> >  	ssize_t			count = i_blocksize(inode);
> > -	xfs_fileoff_t		offset_fsb, end_fsb;
> > +	xfs_fileoff_t		offset_fsb, end_fsb, cow_fsb = 0;
> 
> cow_fsb should probably be initialized to NULLFSBLOCK rather than 0.
> With that, you also shouldn't need cow_valid. Otherwise looks Ok to me.
> 

Err.. I guess NULLFILEOFF would be more appropriate here, but same
idea..

> Brian
> 
> >  	int			whichfork = XFS_DATA_FORK;
> >  	struct xfs_iext_cursor	icur;
> >  	int			error = 0;
> >  	int			nimaps = 1;
> > +	bool			cow_valid = false;
> >  
> >  	if (XFS_FORCED_SHUTDOWN(mp))
> >  		return -EIO;
> > @@ -407,8 +408,11 @@ xfs_map_blocks(
> >  	 * it directly instead of looking up anything in the data fork.
> >  	 */
> >  	if (xfs_is_reflink_inode(ip) &&
> > -	    xfs_iext_lookup_extent(ip, ip->i_cowfp, offset_fsb, &icur, imap) &&
> > -	    imap->br_startoff <= offset_fsb) {
> > +	    xfs_iext_lookup_extent(ip, ip->i_cowfp, offset_fsb, &icur, imap)) {
> > +		cow_fsb = imap->br_startoff;
> > +		cow_valid = true;
> > +	}
> > +	if (cow_valid && cow_fsb <= offset_fsb) {
> >  		xfs_iunlock(ip, XFS_ILOCK_SHARED);
> >  		/*
> >  		 * Truncate can race with writeback since writeback doesn't
> > @@ -430,6 +434,10 @@ xfs_map_blocks(
> >  
> >  	error = xfs_bmapi_read(ip, offset_fsb, end_fsb - offset_fsb,
> >  				imap, &nimaps, XFS_BMAPI_ENTIRE);
> > +	xfs_iunlock(ip, XFS_ILOCK_SHARED);
> > +	if (error)
> > +		return error;
> > +
> >  	if (!nimaps) {
> >  		/*
> >  		 * Lookup returns no match? Beyond eof? regardless,
> > @@ -451,16 +459,17 @@ xfs_map_blocks(
> >  		 * is a pending CoW reservation before the end of this extent,
> >  		 * so that we pick up the COW extents in the next iteration.
> >  		 */
> > -		xfs_reflink_trim_irec_to_next_cow(ip, offset_fsb, imap);
> > +		if (cow_valid &&
> > +		    cow_fsb < imap->br_startoff + imap->br_blockcount) {
> > +			imap->br_blockcount = cow_fsb - imap->br_startoff;
> > +			trace_xfs_reflink_trim_irec(ip, imap);
> > +		}
> > +
> >  		if (imap->br_state == XFS_EXT_UNWRITTEN)
> >  			*type = XFS_IO_UNWRITTEN;
> >  		else
> >  			*type = XFS_IO_OVERWRITE;
> >  	}
> > -	xfs_iunlock(ip, XFS_ILOCK_SHARED);
> > -	if (error)
> > -		return error;
> > -
> >  done:
> >  	switch (*type) {
> >  	case XFS_IO_HOLE:
> > diff --git a/fs/xfs/xfs_reflink.c b/fs/xfs/xfs_reflink.c
> > index 8e5eb8e70c89..ff76bc56ff3d 100644
> > --- a/fs/xfs/xfs_reflink.c
> > +++ b/fs/xfs/xfs_reflink.c
> > @@ -484,39 +484,6 @@ xfs_reflink_allocate_cow(
> >  	return error;
> >  }
> >  
> > -/*
> > - * Trim an extent to end at the next CoW reservation past offset_fsb.
> > - */
> > -void
> > -xfs_reflink_trim_irec_to_next_cow(
> > -	struct xfs_inode		*ip,
> > -	xfs_fileoff_t			offset_fsb,
> > -	struct xfs_bmbt_irec		*imap)
> > -{
> > -	struct xfs_ifork		*ifp = XFS_IFORK_PTR(ip, XFS_COW_FORK);
> > -	struct xfs_bmbt_irec		got;
> > -	struct xfs_iext_cursor		icur;
> > -
> > -	if (!xfs_is_reflink_inode(ip))
> > -		return;
> > -
> > -	/* Find the extent in the CoW fork. */
> > -	if (!xfs_iext_lookup_extent(ip, ifp, offset_fsb, &icur, &got))
> > -		return;
> > -
> > -	/* This is the extent before; try sliding up one. */
> > -	if (got.br_startoff < offset_fsb) {
> > -		if (!xfs_iext_next_extent(ifp, &icur, &got))
> > -			return;
> > -	}
> > -
> > -	if (got.br_startoff >= imap->br_startoff + imap->br_blockcount)
> > -		return;
> > -
> > -	imap->br_blockcount = got.br_startoff - imap->br_startoff;
> > -	trace_xfs_reflink_trim_irec(ip, imap);
> > -}
> > -
> >  /*
> >   * Cancel CoW reservations for some block range of an inode.
> >   *
> > diff --git a/fs/xfs/xfs_reflink.h b/fs/xfs/xfs_reflink.h
> > index 15a456492667..e8d4d50c629f 100644
> > --- a/fs/xfs/xfs_reflink.h
> > +++ b/fs/xfs/xfs_reflink.h
> > @@ -32,8 +32,6 @@ extern int xfs_reflink_allocate_cow(struct xfs_inode *ip,
> >  		struct xfs_bmbt_irec *imap, bool *shared, uint *lockmode);
> >  extern int xfs_reflink_convert_cow(struct xfs_inode *ip, xfs_off_t offset,
> >  		xfs_off_t count);
> > -extern void xfs_reflink_trim_irec_to_next_cow(struct xfs_inode *ip,
> > -		xfs_fileoff_t offset_fsb, struct xfs_bmbt_irec *imap);
> >  
> >  extern int xfs_reflink_cancel_cow_blocks(struct xfs_inode *ip,
> >  		struct xfs_trans **tpp, xfs_fileoff_t offset_fsb,
> > -- 
> > 2.17.0
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
