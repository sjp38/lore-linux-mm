Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 87EBE6B0006
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 03:14:51 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id k4-v6so9819410pls.15
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 00:14:51 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t10si6309356pgc.18.2018.03.13.00.14.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 13 Mar 2018 00:14:47 -0700 (PDT)
Date: Tue, 13 Mar 2018 00:14:40 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: fallocate on XFS for swap
Message-ID: <20180313071440.GA23797@infradead.org>
References: <8C28C1CB-47F1-48D1-85C9-5373D29EA13E@amazon.com>
 <20180309234422.GA4860@magnolia>
 <20180310005850.GW18129@dastard>
 <20180310093844.GA23306@infradead.org>
 <20180312214626.GZ18129@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180312214626.GZ18129@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@infradead.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, "Besogonov, Aleksei" <cyberax@amazon.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, xfs <linux-xfs@vger.kernel.org>

On Tue, Mar 13, 2018 at 08:46:26AM +1100, Dave Chinner wrote:
> > So maybe we want a layout based swap code instead of reinventing it,
> > with the slight twist to the layout break code to never try a lease
> > break and just return an error for the IS_SWAPFILE case.
> 
> Hmmm - won't that change user visible behaviour on swapfiles? Not
> that it would be a bad thing to reject read/write from root on swap
> files, but it would make XFS different to everything else.

We already can't writew to active swap files, thank god:

root@testvm:~# dd if=/dev/zero of=swapfile bs=1M count=64
64+0 records in
64+0 records out
67108864 bytes (67 MB, 64 MiB) copied, 0.0458446 s, 1.5 GB/s
mkswap swapfile
mkswap: swapfile: insecure permissions 0644, 0600 suggested.
Setting up swapspace version 1, size = 64 MiB (67104768 bytes)
no label, UUID=bb42b883-f224-4627-8580-c1ba9f4569ab
root@testvm:~# swapon swapfile
swapon: /root/swapfile: insecure permissions 0644, 0600 suggested.
[   54.165439] Adding 65532k swap on /root/swapfile.  Priority:-2 extents:1 across:65532k
root@testvm:~# dd if=/dev/zero of=swapfile bs=1M count=64
dd: failed to open 'swapfile': Text file busy

> 
> Speaking of which - we probably need to spend some time at LSFMM in
> the fs track talking about the iomap infrastructure and long term
> plans to migrate the major filesystems to it....

I won't be there, as I'll be busy working the local election ballot.
