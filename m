Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 28E536B0006
	for <linux-mm@kvack.org>; Thu,  3 May 2018 16:58:07 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p189so16034170pfp.1
        for <linux-mm@kvack.org>; Thu, 03 May 2018 13:58:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 37-v6sor5984055plq.9.2018.05.03.13.58.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 May 2018 13:58:05 -0700 (PDT)
Date: Thu, 3 May 2018 13:58:03 -0700
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH v3 1/2] iomap: add a swapfile activation function
Message-ID: <20180503205803.GA26037@vader>
References: <20180503174659.GD4127@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180503174659.GD4127@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: xfs <linux-xfs@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, hch@infradead.org, cyberax@amazon.com, jack@suse.cz, Eryu Guan <guaneryu@gmail.com>

On Thu, May 03, 2018 at 10:46:59AM -0700, Darrick J. Wong wrote:
> From: Darrick J. Wong <darrick.wong@oracle.com>
> 
> Add a new iomap_swapfile_activate function so that filesystems can
> activate swap files without having to use the obsolete and slow bmap
> function.  This enables XFS to support fallocate'd swap files and
> swap files on realtime devices.
> 

Shouldn't we also prevent the extents of an active swapfile from
becoming shared? If I swapon(a) and reflink(a, b), swapout to a now has
to break the reflink or corrupt b! In my old Btrfs swapfile series [1] I
just forbid all reflink operations on active swapfiles. 

One thing to note is that then this will need a matching
->swap_deactivate(), which currently isn't called if ->swap_activate()
returned > 0.

1: https://github.com/osandov/linux/tree/btrfs-swap

> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> ---
> v3: catch null iomap addr, fix too-short extent detection
> v2: document the swap file layout requirements, combine adjacent
>     real/unwritten extents, align reported swap extents to physical page
>     size boundaries, fix compiler errors when swap disabled
