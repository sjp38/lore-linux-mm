Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CA6076B0276
	for <linux-mm@kvack.org>; Tue, 22 May 2018 18:38:10 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id z1-v6so12032574pfh.3
        for <linux-mm@kvack.org>; Tue, 22 May 2018 15:38:10 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id u19-v6si17247986pfn.241.2018.05.22.15.38.08
        for <linux-mm@kvack.org>;
        Tue, 22 May 2018 15:38:09 -0700 (PDT)
Date: Wed, 23 May 2018 08:38:06 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 16/34] iomap: add initial support for writes without
 buffer heads
Message-ID: <20180522223806.GX23861@dastard>
References: <20180518164830.1552-1-hch@lst.de>
 <20180518164830.1552-17-hch@lst.de>
 <20180521232700.GB14384@magnolia>
 <20180522000745.GU23861@dastard>
 <20180522082454.GB9801@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180522082454.GB9801@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Tue, May 22, 2018 at 10:24:54AM +0200, Christoph Hellwig wrote:
> On Tue, May 22, 2018 at 10:07:45AM +1000, Dave Chinner wrote:
> > > Something doesn't smell right here.  The only pages we need to read in
> > > are the first and last pages in the write_begin range, and only if they
> > > aren't page aligned and the underlying extent is IOMAP_MAPPED, right?
> > 
> > And not beyond EOF, too.
> > 
> > The bufferhead code handles this via the buffer_new() flag - it
> > triggers the skipping of read IO and the states in which it is
> > set are clearly indicated in iomap_to_bh(). That same logic needs to
> > apply here.
> 
> The buffer_new logic itself isn't really something to copy directly
> as it has all kinds of warts..

Sure, my point was that it documents all the cases where we can
avoid reading from disk, not that we should copy the logic.

> > > I also noticed that speculative preallocation kicks in by the second 80M
> > > write() call and writeback for the second call can successfully allocate
> > > the entire preallocation, which means that the third (or nth) write call
> > > can have a real extent already mapped in, and then we end up reading it.
> > 
> > Yeah, that's because there's no check against EOF here. These writes
> > are all beyond EOF, so there shouldn't be any read at all...
> 
> The EOF case is already handled in iomap_block_needs_zeroing.

Ok, I missed that detail as it's in a different patch. It looks like
if (pos > EOF) it will zeroed. But in this case I think that pos ==
EOF and so it was reading instead. That smells like off-by-one bug
to me.

> We just
> need to skip the read for ranges entirely covered by the write.

Yup.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
