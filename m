Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2E8546B061B
	for <linux-mm@kvack.org>; Thu, 10 May 2018 11:08:44 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id r7-v6so2337301ith.5
        for <linux-mm@kvack.org>; Thu, 10 May 2018 08:08:44 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id h79-v6si773108ioh.43.2018.05.10.08.08.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 May 2018 08:08:42 -0700 (PDT)
Date: Thu, 10 May 2018 08:08:38 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 10/33] iomap: add an iomap-based bmap implementation
Message-ID: <20180510150838.GE25312@magnolia>
References: <20180509074830.16196-1-hch@lst.de>
 <20180509074830.16196-11-hch@lst.de>
 <20180509164628.GV11261@magnolia>
 <20180510064250.GD11422@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180510064250.GD11422@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Thu, May 10, 2018 at 08:42:50AM +0200, Christoph Hellwig wrote:
> On Wed, May 09, 2018 at 09:46:28AM -0700, Darrick J. Wong wrote:
> > On Wed, May 09, 2018 at 09:48:07AM +0200, Christoph Hellwig wrote:
> > > This adds a simple iomap-based implementation of the legacy ->bmap
> > > interface.  Note that we can't easily add checks for rt or reflink
> > > files, so these will have to remain in the callers.  This interface
> > > just needs to die..
> > 
> > You /can/ check these...
> > 
> > if (iomap->bdev != inode->i_sb->s_bdev)
> > 	return 0;
> > if (iomap->flags & IOMAP_F_SHARED)
> > 	return 0;
> 
> The latter only checks for a shared extent, not a file with possibly
> shared extents.  I'd rather keep the check for a file with possible
> shared extents.

<nod>

> > > +static loff_t
> > > +iomap_bmap_actor(struct inode *inode, loff_t pos, loff_t length,
> > > +		void *data, struct iomap *iomap)
> > > +{
> > > +	sector_t *bno = data;
> > > +
> > > +	if (iomap->type == IOMAP_MAPPED)
> > > +		*bno = (iomap->addr + pos - iomap->offset) >> inode->i_blkbits;
> > 
> > Does this need to be careful w.r.t. overflow on systems where sector_t
> > is a 32-bit unsigned long?
> > 
> > Also, ioctl_fibmap() typecasts the returned sector_t to an int, which
> > also seems broken.  I agree the interface needs to die, but ioctls take
> > a long time to deprecate.
> 
> Not much we can do about the interface.

Yes, the interface is fubar, but if file /foo maps to block 8589934720
then do we return the truncated result 128?

--D
