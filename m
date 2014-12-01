Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id AD1526B0069
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 13:18:30 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id bs8so27424662wib.1
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 10:18:30 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dd7si5697204wjb.143.2014.12.01.10.18.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 01 Dec 2014 10:18:29 -0800 (PST)
Date: Mon, 1 Dec 2014 19:18:28 +0100
From: David Sterba <dsterba@suse.cz>
Subject: Re: [PATCH v2 5/5] btrfs: enable swap file support
Message-ID: <20141201181828.GL12140@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <cover.1416563833.git.osandov@osandov.com>
 <afd3c1009172a4a1cfa10e73a64caf35c631a6d4.1416563833.git.osandov@osandov.com>
 <20141121180045.GF8568@twin.jikos.cz>
 <20141122200357.GA15189@mew>
 <20141124220302.GA5785@mew.dhcp4.washington.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141124220302.GA5785@mew.dhcp4.washington.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Omar Sandoval <osandov@osandov.com>
Cc: Filipe David Manana <fdmanana@gmail.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, Trond Myklebust <trond.myklebust@primarydata.com>, Mel Gorman <mgorman@suse.de>

On Mon, Nov 24, 2014 at 02:03:02PM -0800, Omar Sandoval wrote:
> Alright, I took a look at this. My understanding is that a PREALLOC extent
> represents a region on disk that has already been allocated but isn't in use
> yet, but please correct me if I'm wrong. Judging by this comment in
> btrfs_get_blocks_direct, we don't have to worry about PREALLOC extents in
> general:
> 
> /*
>  * We don't allocate a new extent in the following cases
>  *
>  * 1) The inode is marked as NODATACOW.  In this case we'll just use the
>  * existing extent.
>  * 2) The extent is marked as PREALLOC.  We're good to go here and can
>  * just use the extent.
>  *
>  */

Ok, thanks for checking.

> A couple of other considerations that cropped up:
> 
> - btrfs_get_extent does a bunch of extra work if the extent is not cached in
>   the extent map tree that would be nice to avoid when swapping
> - We might still have to do a COW if the swap file is in a snapshot
> 
> We can avoid the btrfs_get_extent by pinning the extents in memory one way or
> another in btrfs_swap_activate.

That's preferrable, the overhead should be small.

> The snapshot issue is a little tricker to resolve. I see a few options:
> 
> 1. Just do the COW and hope for the best

Snapshotting of NODATACOW files work, the extents are COWed on the first
write, the original owner sees no change.

> 2. As part of btrfs_swap_activate, COW any shared extents. If a snapshot
> happens while a swap file is active, we'll fall back to 1.

So we should make sure that any write to the swapfile will not lead to
the first-COW, this would require to scan all the extents and see if
we're the owner and COW eventually.

Doing that automatically is IMO better from the user perspective,
compared to an erroring out and requesting a manual "dd" over the file.

Possibly, the implied COW could create preallocated extents so we do not
have to rewrite the data.

> 3. Clobber any swap file extents which are in a snapshot, i.e., always use the
> existing extent.

Easy to implement but could lead to bad suprises.

More thoughts:

There are some guards in the generic code to prevent unwanted
modifications to the swapfiles (eg. no truncate, no fallocate, no
deletion). Further we should audit btrfs ioctls that may interfere with
swap and forbid any action (notably the cloning and deduplication ones).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
