Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id C3D646B0035
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 08:04:48 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id md12so4384917pbc.30
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 05:04:48 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [2001:44b8:8060:ff02:300:1:2:6])
        by mx.google.com with ESMTP id ui8si10459616pac.177.2014.01.31.05.04.46
        for <linux-mm@kvack.org>;
        Fri, 31 Jan 2014 05:04:47 -0800 (PST)
Date: Sat, 1 Feb 2014 00:04:22 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v5 00/22] Rewrite XIP code and add XIP support to ext4
Message-ID: <20140131130422.GL13997@dastard>
References: <cover.1389779961.git.matthew.r.wilcox@intel.com>
 <20140130064230.GG13997@dastard>
 <20140130092537.GH13997@dastard>
 <20140131030652.GK13997@dastard>
 <alpine.OSX.2.00.1401302227450.29315@scrumpy>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.OSX.2.00.1401302227450.29315@scrumpy>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org

On Thu, Jan 30, 2014 at 10:45:26PM -0700, Ross Zwisler wrote:
> On Fri, 31 Jan 2014, Dave Chinner wrote:
> > The read/write path is broken, Willy. We can't map arbitrary byte
> > ranges to the DIO subsystem. I'm now certain that the data
> > corruptions I'm seeing are in sub-sector regions from unaligned IOs
> > from userspace. We still need to use the buffered IO path for non
> > O_DIRECT IO to avoid these problems. I think I've worked out a way
> > to short-circuit page cache lookups for the buffered IO path, so
> > stay tuned....
> 
> Hi Dave,
> 
> I found an issue that would cause reads to return bad data earlier this week,
> and sent a response to "[PATCH v5 22/22] XIP: Add support for unwritten
> extents".  Just wanted to make sure you're not running into that issue.  

After having a couple of good strong bourbons, It came to me about
15 minutes ago that I've had a case of forest, trees and bears
today. What I said above is most likely wrong and I think there's
probably a simple reason for the bug I'm seeing: xip_io() does
not handle the buffer_new(bh) case correctly. i.e. this case:


	  newly allocated buffer
	+-------------------------------+
	+-zero-+----user data----+-zero-+

i.e. it doesn't zero the partial head and tail of the block
correctly if the block has just been allocated. If the block has
just been allocated, get_block() is supposed to return the bh marked
as buffer_new() to indicate to the caller it needs to have regions
that aren't covered with data zeroed.

Yes, makes fsx run for more than 36 operations. But it only makes it
to 79 operations, and then....

# xfs_io -tf -c "truncate 18k" -c "pwrite 19k 21k" -c "pread -v 18k 2k" -c "bmap -vp" /mnt/scr/foo
....
EXT: FILE-OFFSET      BLOCK-RANGE      AG AG-OFFSET        TOTAL FLAGS
   0: [0..31]:         hole                                    32
   1: [32..39]:        120..127          0 (120..127)           8 10000
   2: [40..71]:        128..159          0 (128..159)          32 00000
   3: [72..79]:        216..223          0 (216..223)           8 00000

Ok, it's leaving an unwritten extent where it shouldn't be. That
explains the zeros instead of data. I'll look further at it in the
morning now I think I'm on the right track...

> I'm also currently chasing a write corruption where we lose the data that we
> had just written because ext4 thinks the portion of the extent we had just
> written needs to be converted from an unwritten extent to a written extent, so
> it clears the data to all zeros via:
> 
> 	xip_clear_blocks+0x53/0xd7
> 	ext4_map_blocks+0x306/0x3d9 [ext4]
> 	jbd2__journal_start+0xbd/0x188 [jbd2]
> 	ext4_convert_unwritten_extents+0xf9/0x1ac [ext4]
> 	ext4_direct_IO+0x2ca/0x3a5 [ext4]
> 
> This bug can be easily reproduced by fallocating an empty file up to a page,
> and then writing into that page.  The first write is essentially lost, and the
> page remains all zeros.  Subsequent writes succeed.

I don't think that's what I'm seeing. As it is, ext4 should not
be zeroing the block during unwritten extent conversion. This looks
to have been added
to make the xip_fault() path work, but I think it's wrong. What I
had to do for XFS in the xip_fault() path to ensure that we returned
allocated, zeroed blocks from xfs_get_blocks_xip() was:

	allocate as unwritten
	xip_clear_blocks
	mark extent as written

so that it behaves like the direct IO path in terms of the
"allocate, write data, mark unwritten" process. But for direct IO,
xip_io() needs to be doing the block zeroing in response to
get_blocks setting buffer_new(bh) after allocating the unwritten
extent. Then it can copy in the data and call endio to convert it to
written....

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
