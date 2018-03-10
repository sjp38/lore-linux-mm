Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id A620C6B0005
	for <linux-mm@kvack.org>; Sat, 10 Mar 2018 04:38:49 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id 1-v6so5654829plv.6
        for <linux-mm@kvack.org>; Sat, 10 Mar 2018 01:38:49 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x1si2115372pgp.89.2018.03.10.01.38.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 10 Mar 2018 01:38:48 -0800 (PST)
Date: Sat, 10 Mar 2018 01:38:44 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: fallocate on XFS for swap
Message-ID: <20180310093844.GA23306@infradead.org>
References: <8C28C1CB-47F1-48D1-85C9-5373D29EA13E@amazon.com>
 <20180309234422.GA4860@magnolia>
 <20180310005850.GW18129@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180310005850.GW18129@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, "Besogonov, Aleksei" <cyberax@amazon.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, xfs <linux-xfs@vger.kernel.org>

On Sat, Mar 10, 2018 at 11:58:50AM +1100, Dave Chinner wrote:
> > Probably the best idea, but see fs/iomap.c since we're basically leasing
> > a chunk of file space to the kernel.  Leasing space to a user that wants
> > direct access is becoming rather common (rdma, map_sync, etc.)
> 
> thing is, we don't want in-kernel users of fiemap. We've got other
> block mapping interfaces that can be used, such as iomap...

Agreed.  fiemap is in many ways just as bad as bmap - it is an
information at a given point in time interface.  It is more detailed
than bmap and allows better error reporting, but it still is
fundamentally the wrong thing to use for any sort of the I/O path.

> 
> > > 3. Add an XFS-specific implementation of swapfile_activate.
> > 
> > Ugh no.
> 
> What we want is an iomap-based re-implementation of
> generic_swap_activate(). One of the ways to plumb that in is to
> use ->swapfile_activate() like so:

Hmm.  Fundamentally swap is the same problem as the pNFS block layout
or get_user_pages on DAX mappings - we want to get a 'lease' on the
current block mapping, and make sure it stays that way as the external
user (the swap code in this case) uses it.  The twist for the swap code
is mostly that it never wants to break the least but instead disallow
any external operation, but that's not really such a big difference.

So maybe we want a layout based swap code instead of reinventing it,
with the slight twist to the layout break code to never try a lease
break and just return an error for the IS_SWAPFILE case.
