Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 45B116B0005
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 21:32:24 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id x81so2362026pgx.21
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 18:32:24 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id f6si5884956pgn.165.2018.03.12.18.32.22
        for <linux-mm@kvack.org>;
        Mon, 12 Mar 2018 18:32:22 -0700 (PDT)
Date: Tue, 13 Mar 2018 12:31:44 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: fallocate on XFS for swap
Message-ID: <20180313013144.GA18129@dastard>
References: <8C28C1CB-47F1-48D1-85C9-5373D29EA13E@amazon.com>
 <20180309234422.GA4860@magnolia>
 <20180310005850.GW18129@dastard>
 <20180310011707.GA4875@magnolia>
 <20180310013646.GX18129@dastard>
 <A59B9E63-29A2-4C40-960B-E09809DE501F@amazon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <A59B9E63-29A2-4C40-960B-E09809DE501F@amazon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Besogonov, Aleksei" <cyberax@amazon.com>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, xfs <linux-xfs@vger.kernel.org>

[Aleski, can you word wrap your email text at 72 columns? ]

On Mon, Mar 12, 2018 at 10:01:54PM +0000, Besogonov, Aleksei wrote:
> [snip unrelated]
> 
> So I'm looking at the XFS code and it appears that the iomap is
> limited to 1024*PAGE_SIZE blocks at a time,

Take a closer look - that code is not used for reading file extents
and returning them to the caller.

> which is too small for
> most of swap use-cases. I can of course just loop through the file
> in 4Mb increments and, just like the bmap() code does today. But
> this just doesn't look right and it's not atomic. And it looks
> like iomap in ext2 doesn't have this limitation. 
> 
> The stated rationale for the XFS limit is:
> >/*
> > * We cap the maximum length we map here to MAX_WRITEBACK_PAGES pages
> > * to keep the chunks of work done where somewhat symmetric with the
> > * work writeback does. This is a completely arbitrary number pulled
> > * out of thin air as a best guess for initial testing.
> > *
> > * Note that the values needs to be less than 32-bits wide until
> > * the lower level functions are updated.
> > */

Yeah, that's in the IOMAP_WRITE path used for block allocation. swap
file mapping should not be asking for IOMAP_WRITE mappings that
trigger extent allocation, so you should never hit this case.

You should probably be using the IOMAP_REPORT path (i.e. basically
very similar code to iomap_fiemap/iomap_fiemap_apply and rejecting
any file that returns an iomap that is not IOMAP_MAPPED or
IOMAP_UNWRITTEN. Also, you want to reject any file that returns
IOMAP_F_SHARED in iomap->flags, too, because swapfiles can't do COW
to break extent sharing on writes.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
