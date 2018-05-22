Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 64AE06B0003
	for <linux-mm@kvack.org>; Tue, 22 May 2018 04:19:41 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id a7-v6so7334947wrq.13
        for <linux-mm@kvack.org>; Tue, 22 May 2018 01:19:41 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id y34-v6si13780498wry.85.2018.05.22.01.19.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 01:19:40 -0700 (PDT)
Date: Tue, 22 May 2018 10:24:54 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 16/34] iomap: add initial support for writes without
	buffer heads
Message-ID: <20180522082454.GB9801@lst.de>
References: <20180518164830.1552-1-hch@lst.de> <20180518164830.1552-17-hch@lst.de> <20180521232700.GB14384@magnolia> <20180522000745.GU23861@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180522000745.GU23861@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Tue, May 22, 2018 at 10:07:45AM +1000, Dave Chinner wrote:
> > Something doesn't smell right here.  The only pages we need to read in
> > are the first and last pages in the write_begin range, and only if they
> > aren't page aligned and the underlying extent is IOMAP_MAPPED, right?
> 
> And not beyond EOF, too.
> 
> The bufferhead code handles this via the buffer_new() flag - it
> triggers the skipping of read IO and the states in which it is
> set are clearly indicated in iomap_to_bh(). That same logic needs to
> apply here.

The buffer_new logic itself isn't really something to copy directly
as it has all kinds of warts..

> > I also noticed that speculative preallocation kicks in by the second 80M
> > write() call and writeback for the second call can successfully allocate
> > the entire preallocation, which means that the third (or nth) write call
> > can have a real extent already mapped in, and then we end up reading it.
> 
> Yeah, that's because there's no check against EOF here. These writes
> are all beyond EOF, so there shouldn't be any read at all...

The EOF case is already handled in iomap_block_needs_zeroing.  We just
need to skip the read for ranges entirely covered by the write.
