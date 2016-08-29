Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8B1FE83090
	for <linux-mm@kvack.org>; Sun, 28 Aug 2016 20:43:13 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id o124so273345364pfg.1
        for <linux-mm@kvack.org>; Sun, 28 Aug 2016 17:43:13 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id tu5si35914882pab.149.2016.08.28.17.43.11
        for <linux-mm@kvack.org>;
        Sun, 28 Aug 2016 17:43:12 -0700 (PDT)
Date: Mon, 29 Aug 2016 10:42:34 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 2/9] ext2: tell DAX the size of allocation holes
Message-ID: <20160829004234.GS22388@dastard>
References: <20160823220419.11717-1-ross.zwisler@linux.intel.com>
 <20160823220419.11717-3-ross.zwisler@linux.intel.com>
 <20160825075728.GA11235@infradead.org>
 <20160826212934.GA11265@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160826212934.GA11265@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, linux-nvdimm@ml01.01.org, Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, Andreas Dilger <adilger.kernel@dilger.ca>, Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.com>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org

On Fri, Aug 26, 2016 at 03:29:34PM -0600, Ross Zwisler wrote:
> On Thu, Aug 25, 2016 at 12:57:28AM -0700, Christoph Hellwig wrote:
> > Hi Ross,
> > 
> > can you take at my (fully working, but not fully cleaned up) version
> > of the iomap based DAX code here:
> > 
> > http://git.infradead.org/users/hch/vfs.git/shortlog/refs/heads/iomap-dax
> > 
> > By using iomap we don't even have the size hole problem and totally
> > get out of the reverse-engineer what buffer_heads are trying to tell
> > us business.  It also gets rid of the other warts of the DAX path
> > due to pretending to be like direct I/O, so this might be a better
> > way forward also for ext2/4.
> 
> In general I agree that the usage of struct iomap seems more straightforward
> than the old way of using struct buffer_head + get_block_t.  I really don't
> think we want to have two competing DAX I/O and fault paths, though, which I
> assume everyone else agrees with as well.

We'll be moving XFS this way, regardless of whether the generic DAX
code goes that way or not. iomap is a much cleaner, more efficient
interface than get_blocks via bufferheads. We are slowly removing
bufferheads from XFS so anything that uses them or depends on them
that Xfs requires is going to have an iomap-based variant written
for it.

Christoph is doing the hard yards to make iomap a VFS level
interface because that's a) the most efficient way to implement it,
and b) it's the right place for IO path extent mapping abstractions.
So there will be a iomap path for DAX, just like there will be a
iomap path for direct IO, regardless of what other filesystems
implement. i.e. other filesystems can move to the more efficient
iomap infrastructure if they want, but we can't force them to do so.

As such, the generic DAX path can either remain as it is, or we can
move to iomap and use wrappers for converting get_block() +
bufferehead to iomaps on non-iomap filesystems.  (i.e. similar to
the existing iomap_to_bh() for allowing iomap lookups to be used to
replace bufferheads returned by get_block().)

I'd much prefer we move DAX to iomaps before there is wider uptake
of it in other filesystems - I've been saying we should use iomaps
for DAX right from the start. Now we have the iomap infrastructure
in place we should jump straight to it. If we have to drag ext4
kicking and screaming into the 1990s to get there then so be it - it
won't be the first time...

> These changes don't remove the things in XFS needed by the old I/O and fault
> paths (e.g.  xfs_get_blocks_direct() is still there an unchanged).  Is the

Yes, they'll remain until their functionality has been replaced by
iomap functions. e.g. xfs_get_blocks_direct() can't be removed
until the direct IO path has an iomap interface.

....

> 6) Regarding the "we don't even have the size hole problem" comment in your
>    mail, the current PMD logic requires us to know the size of the hole.  This
....
>    The current XFS code in the v4.8 tree tells me the size of the hole, and I
>    think we need to keep this functionality.

IOMAP_HOLE extents. It's a requirement of the iomap infrastructure
that the filesystem reports hole extents in full for the range being
mapped.

Cheers,

Dave.

-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
