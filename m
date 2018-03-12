Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id A1BB86B0003
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 17:46:30 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id y19so2716645pgv.18
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 14:46:30 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id t11-v6si3331969ply.226.2018.03.12.14.46.28
        for <linux-mm@kvack.org>;
        Mon, 12 Mar 2018 14:46:29 -0700 (PDT)
Date: Tue, 13 Mar 2018 08:46:26 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: fallocate on XFS for swap
Message-ID: <20180312214626.GZ18129@dastard>
References: <8C28C1CB-47F1-48D1-85C9-5373D29EA13E@amazon.com>
 <20180309234422.GA4860@magnolia>
 <20180310005850.GW18129@dastard>
 <20180310093844.GA23306@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180310093844.GA23306@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, "Besogonov, Aleksei" <cyberax@amazon.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, xfs <linux-xfs@vger.kernel.org>

On Sat, Mar 10, 2018 at 01:38:44AM -0800, Christoph Hellwig wrote:
> On Sat, Mar 10, 2018 at 11:58:50AM +1100, Dave Chinner wrote:
> > > > 3. Add an XFS-specific implementation of swapfile_activate.
> > > 
> > > Ugh no.
> > 
> > What we want is an iomap-based re-implementation of
> > generic_swap_activate(). One of the ways to plumb that in is to
> > use ->swapfile_activate() like so:
> 
> Hmm.  Fundamentally swap is the same problem as the pNFS block layout
> or get_user_pages on DAX mappings - we want to get a 'lease' on the
> current block mapping, and make sure it stays that way as the external
> user (the swap code in this case) uses it.  The twist for the swap code
> is mostly that it never wants to break the least but instead disallow
> any external operation, but that's not really such a big difference.

True.

> So maybe we want a layout based swap code instead of reinventing it,
> with the slight twist to the layout break code to never try a lease
> break and just return an error for the IS_SWAPFILE case.

Hmmm - won't that change user visible behaviour on swapfiles? Not
that it would be a bad thing to reject read/write from root on swap
files, but it would make XFS different to everything else.

Speaking of which - we probably need to spend some time at LSFMM in
the fs track talking about the iomap infrastructure and long term
plans to migrate the major filesystems to it....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
