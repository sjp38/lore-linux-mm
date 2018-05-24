Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 86C0F6B0005
	for <linux-mm@kvack.org>; Thu, 24 May 2018 13:04:57 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id m1-v6so1984172wrn.14
        for <linux-mm@kvack.org>; Thu, 24 May 2018 10:04:57 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id x1-v6si3479609wmh.186.2018.05.24.10.04.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 10:04:56 -0700 (PDT)
Date: Thu, 24 May 2018 19:10:29 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 25/34] xfs: remove xfs_reflink_trim_irec_to_next_cow
Message-ID: <20180524171029.GA23145@lst.de>
References: <20180523144357.18985-1-hch@lst.de> <20180523144357.18985-26-hch@lst.de> <20180524145943.GB84959@bfoster.bfoster> <20180524150658.GC84959@bfoster.bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180524150658.GC84959@bfoster.bfoster>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Foster <bfoster@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, May 24, 2018 at 11:06:59AM -0400, Brian Foster wrote:
> On Thu, May 24, 2018 at 10:59:43AM -0400, Brian Foster wrote:
> > On Wed, May 23, 2018 at 04:43:48PM +0200, Christoph Hellwig wrote:
> > > In the only caller we just did a lookup in the COW extent tree for
> > > the same offset.  Reuse that result and save a lookup, as well as
> > > shortening the ilock hold time.
> > > 
> > > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > > ---
> > >  fs/xfs/xfs_aops.c    | 25 +++++++++++++++++--------
> > >  fs/xfs/xfs_reflink.c | 33 ---------------------------------
> > >  fs/xfs/xfs_reflink.h |  2 --
> > >  3 files changed, 17 insertions(+), 43 deletions(-)
> > > 
> > > diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> > > index a4b4a7037deb..354d26d66c12 100644
> > > --- a/fs/xfs/xfs_aops.c
> > > +++ b/fs/xfs/xfs_aops.c
> > > @@ -383,11 +383,12 @@ xfs_map_blocks(
> > >  	struct xfs_inode	*ip = XFS_I(inode);
> > >  	struct xfs_mount	*mp = ip->i_mount;
> > >  	ssize_t			count = i_blocksize(inode);
> > > -	xfs_fileoff_t		offset_fsb, end_fsb;
> > > +	xfs_fileoff_t		offset_fsb, end_fsb, cow_fsb = 0;
> > 
> > cow_fsb should probably be initialized to NULLFSBLOCK rather than 0.
> > With that, you also shouldn't need cow_valid. Otherwise looks Ok to me.
> > 
> 
> Err.. I guess NULLFILEOFF would be more appropriate here, but same
> idea..

Yes, I'll start using it.
