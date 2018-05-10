Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 34F0E6B05BB
	for <linux-mm@kvack.org>; Thu, 10 May 2018 02:39:14 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k16-v6so704644wrh.6
        for <linux-mm@kvack.org>; Wed, 09 May 2018 23:39:14 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id 63-v6si112916wre.270.2018.05.09.23.39.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 May 2018 23:39:13 -0700 (PDT)
Date: Thu, 10 May 2018 08:42:50 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 10/33] iomap: add an iomap-based bmap implementation
Message-ID: <20180510064250.GD11422@lst.de>
References: <20180509074830.16196-1-hch@lst.de> <20180509074830.16196-11-hch@lst.de> <20180509164628.GV11261@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180509164628.GV11261@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Wed, May 09, 2018 at 09:46:28AM -0700, Darrick J. Wong wrote:
> On Wed, May 09, 2018 at 09:48:07AM +0200, Christoph Hellwig wrote:
> > This adds a simple iomap-based implementation of the legacy ->bmap
> > interface.  Note that we can't easily add checks for rt or reflink
> > files, so these will have to remain in the callers.  This interface
> > just needs to die..
> 
> You /can/ check these...
> 
> if (iomap->bdev != inode->i_sb->s_bdev)
> 	return 0;
> if (iomap->flags & IOMAP_F_SHARED)
> 	return 0;

The latter only checks for a shared extent, not a file with possibly
shared extents.  I'd rather keep the check for a file with possible
shared extents.

> > +static loff_t
> > +iomap_bmap_actor(struct inode *inode, loff_t pos, loff_t length,
> > +		void *data, struct iomap *iomap)
> > +{
> > +	sector_t *bno = data;
> > +
> > +	if (iomap->type == IOMAP_MAPPED)
> > +		*bno = (iomap->addr + pos - iomap->offset) >> inode->i_blkbits;
> 
> Does this need to be careful w.r.t. overflow on systems where sector_t
> is a 32-bit unsigned long?
> 
> Also, ioctl_fibmap() typecasts the returned sector_t to an int, which
> also seems broken.  I agree the interface needs to die, but ioctls take
> a long time to deprecate.

Not much we can do about the interface.
