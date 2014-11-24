Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id AB6EC6B0038
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 17:03:07 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id g10so8287863pdj.23
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 14:03:07 -0800 (PST)
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com. [209.85.192.181])
        by mx.google.com with ESMTPS id xn3si23487473pab.146.2014.11.24.14.03.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Nov 2014 14:03:06 -0800 (PST)
Received: by mail-pd0-f181.google.com with SMTP id z10so10604229pdj.40
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 14:03:05 -0800 (PST)
Date: Mon, 24 Nov 2014 14:03:02 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH v2 5/5] btrfs: enable swap file support
Message-ID: <20141124220302.GA5785@mew.dhcp4.washington.edu>
References: <cover.1416563833.git.osandov@osandov.com>
 <afd3c1009172a4a1cfa10e73a64caf35c631a6d4.1416563833.git.osandov@osandov.com>
 <20141121180045.GF8568@twin.jikos.cz>
 <20141122200357.GA15189@mew>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141122200357.GA15189@mew>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Filipe David Manana <fdmanana@gmail.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, Trond Myklebust <trond.myklebust@primarydata.com>, Mel Gorman <mgorman@suse.de>

On Sat, Nov 22, 2014 at 12:03:57PM -0800, Omar Sandoval wrote:
> On Fri, Nov 21, 2014 at 07:00:45PM +0100, David Sterba wrote:
> > > +			ret = -EINVAL;
> > > +			goto out;
> > > +		}
> > > +		if (test_bit(EXTENT_FLAG_COMPRESSED, &em->flags)) {
> > > +			pr_err("BTRFS: swapfile is compresed");
> > > +			ret = -EINVAL;
> > > +			goto out;
> > > +		}
> > 
> > I think the preallocated extents should be refused as well. This means
> > the filesystem has enough space to hold the data but it would still have
> > to go through the allocation and could in turn stress the memory
> > management code that triggered the swapping activity in the first place.
> > 
> > Though it's probably still possible to reach such corner case even with
> > fully allocated nodatacow file, this should be reviewed anyway.
> > 
> I'll definitely take a closer look at this. In particular,
> btrfs_get_blocks_direct and btrfs_get_extent do allocations in some cases which
> I'll look into.
> 
Alright, I took a look at this. My understanding is that a PREALLOC extent
represents a region on disk that has already been allocated but isn't in use
yet, but please correct me if I'm wrong. Judging by this comment in
btrfs_get_blocks_direct, we don't have to worry about PREALLOC extents in
general:

/*
 * We don't allocate a new extent in the following cases
 *
 * 1) The inode is marked as NODATACOW.  In this case we'll just use the
 * existing extent.
 * 2) The extent is marked as PREALLOC.  We're good to go here and can
 * just use the extent.
 *
 */

A couple of other considerations that cropped up:

- btrfs_get_extent does a bunch of extra work if the extent is not cached in
  the extent map tree that would be nice to avoid when swapping
- We might still have to do a COW if the swap file is in a snapshot

We can avoid the btrfs_get_extent by pinning the extents in memory one way or
another in btrfs_swap_activate.

The snapshot issue is a little tricker to resolve. I see a few options:

1. Just do the COW and hope for the best
2. As part of btrfs_swap_activate, COW any shared extents. If a snapshot
happens while a swap file is active, we'll fall back to 1.
3. Clobber any swap file extents which are in a snapshot, i.e., always use the
existing extent.

I'm partial to 3, as it's the simplest approach, and I don't think it makes
much sense for a swap file to be in a snapshot anyways. I'd appreciate any
comments that anyone might have.

-- 
Omar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
