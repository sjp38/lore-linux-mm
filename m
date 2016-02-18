Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 725356B0005
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 19:12:28 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id x65so20204320pfb.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 16:12:28 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id hs10si5140626pad.75.2016.02.17.16.12.26
        for <linux-mm@kvack.org>;
        Wed, 17 Feb 2016 16:12:27 -0800 (PST)
Date: Thu, 18 Feb 2016 11:12:23 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v3 3/6] ext4: Online defrag not supported with DAX
Message-ID: <20160218001223.GJ19486@dastard>
References: <1455680059-20126-1-git-send-email-ross.zwisler@linux.intel.com>
 <1455680059-20126-4-git-send-email-ross.zwisler@linux.intel.com>
 <20160217215037.GB30126@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160217215037.GB30126@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Jens Axboe <axboe@kernel.dk>, Matthew Wilcox <willy@linux.intel.com>, linux-block@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, xfs@oss.sgi.com

On Wed, Feb 17, 2016 at 02:50:37PM -0700, Ross Zwisler wrote:
> On Tue, Feb 16, 2016 at 08:34:16PM -0700, Ross Zwisler wrote:
> > Online defrag operations for ext4 are hard coded to use the page cache.
> > See ext4_ioctl() -> ext4_move_extents() -> move_extent_per_page()
> > 
> > When combined with DAX I/O, which circumvents the page cache, this can
> > result in data corruption.  This was observed with xfstests ext4/307 and
> > ext4/308.
> > 
> > Fix this by only allowing online defrag for non-DAX files.
> 
> Jan,
> 
> Thinking about this a bit more, it's probably the case that the data
> corruption I was observing was due to us skipping the writeback of the dirty
> page cache pages because S_DAX was set.
> 
> I do think we have a problem with defrag because it is doing the extent
> swapping using the page cache, and we won't flush the dirty pages due to
> S_DAX being set.
> 
> This patch is the quick and easy answer, and is perhaps appropriate for v4.5.
> 
> Looking forward, though, what do you think the correct solution is?  Making an
> extent swapper that doesn't use the page cache (as I believe XFS has? see
> xfs_swap_extents()),

XFS does the data copy in userspace using direct IO so we don't
care about whether DAX is enabled or not on either the source or
destination inode. i.e. xfs_swap_extents() is a pure
metadata operation, swapping the entire extent tree between two
inodes if the source data has not changed while the copy was in
progress.

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
