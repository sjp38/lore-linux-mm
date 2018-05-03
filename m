Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9F88D6B000A
	for <linux-mm@kvack.org>; Thu,  3 May 2018 17:25:13 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id b63-v6so2059800ybg.1
        for <linux-mm@kvack.org>; Thu, 03 May 2018 14:25:13 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id 144-v6si3917152ybd.111.2018.05.03.14.25.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 May 2018 14:25:12 -0700 (PDT)
Date: Thu, 3 May 2018 14:24:47 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH v3 1/2] iomap: add a swapfile activation function
Message-ID: <20180503212447.GG4141@magnolia>
References: <20180503174659.GD4127@magnolia>
 <20180503205803.GA26037@vader>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180503205803.GA26037@vader>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Omar Sandoval <osandov@osandov.com>
Cc: xfs <linux-xfs@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, hch@infradead.org, cyberax@amazon.com, jack@suse.cz, Eryu Guan <guaneryu@gmail.com>

On Thu, May 03, 2018 at 01:58:03PM -0700, Omar Sandoval wrote:
> On Thu, May 03, 2018 at 10:46:59AM -0700, Darrick J. Wong wrote:
> > From: Darrick J. Wong <darrick.wong@oracle.com>
> > 
> > Add a new iomap_swapfile_activate function so that filesystems can
> > activate swap files without having to use the obsolete and slow bmap
> > function.  This enables XFS to support fallocate'd swap files and
> > swap files on realtime devices.
> > 
> 
> Shouldn't we also prevent the extents of an active swapfile from
> becoming shared? If I swapon(a) and reflink(a, b), swapout to a now has
> to break the reflink or corrupt b! In my old Btrfs swapfile series [1] I
> just forbid all reflink operations on active swapfiles. 

xfs already does this in its reflink handler: it takes the inode lock &
bails out if IS_SWAPFILE().  swapon calls claim_swapfile to take the
inode lock and sets S_SWAPFILE (if successful) so the two are
effectively locked out from each other...

> One thing to note is that then this will need a matching
> ->swap_deactivate(), which currently isn't called if ->swap_activate()
> returned > 0.

...so there shouldn't be any state to undo if the
iomap_swapfile_activate fails.

--D

> 
> 1: https://github.com/osandov/linux/tree/btrfs-swap
> 
> > Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> > ---
> > v3: catch null iomap addr, fix too-short extent detection
> > v2: document the swap file layout requirements, combine adjacent
> >     real/unwritten extents, align reported swap extents to physical page
> >     size boundaries, fix compiler errors when swap disabled
