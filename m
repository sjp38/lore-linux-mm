Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6BA146B0031
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 04:25:44 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so2904553pab.32
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 01:25:44 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [2001:44b8:8060:ff02:300:1:2:7])
        by mx.google.com with ESMTP id ye6si5665375pbc.320.2014.01.30.01.25.42
        for <linux-mm@kvack.org>;
        Thu, 30 Jan 2014 01:25:43 -0800 (PST)
Date: Thu, 30 Jan 2014 20:25:37 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v5 00/22] Rewrite XIP code and add XIP support to ext4
Message-ID: <20140130092537.GH13997@dastard>
References: <cover.1389779961.git.matthew.r.wilcox@intel.com>
 <20140130064230.GG13997@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140130064230.GG13997@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org

On Thu, Jan 30, 2014 at 05:42:30PM +1100, Dave Chinner wrote:
> On Wed, Jan 15, 2014 at 08:24:18PM -0500, Matthew Wilcox wrote:
> > This series of patches add support for XIP to ext4.  Unfortunately,
> > it turns out to be necessary to rewrite the existing XIP support code
> > first due to races that are unfixable in the current design.
> > 
> > Since v4 of this patchset, I've improved the documentation, fixed a
> > couple of warnings that a newer version of gcc emitted, and fixed a
> > bug where we would read/write the wrong address for I/Os that were not
> > aligned to PAGE_SIZE.
> 
> Looks like there's something fundamentally broken with the patch set
> as it stands. I get this same data corruption on both ext4 and XFS
> with XIP using fsx. It's as basic as it gets - the first read after
> a mmapped write fails to see the data written by mmap:
> 
> $ sudo mkfs.xfs -f /dev/ram0
> meta-data=/dev/ram0              isize=256    agcount=4, agsize=256000 blks
>          =                       sectsz=512   attr=2, projid32bit=1
>          =                       crc=0
> data     =                       bsize=4096   blocks=1024000, imaxpct=25
>          =                       sunit=0      swidth=0 blks
> naming   =version 2              bsize=4096   ascii-ci=0 ftype=0
> log      =internal log           bsize=4096   blocks=12800, version=2
>          =                       sectsz=512   sunit=0 blks, lazy-count=1
> realtime =none                   extsz=4096   blocks=0, rtextents=0
> $ sudo mount -o xip /dev/ram0 /mnt/scr
> $ sudo chmod 777 /mnt/scr
> $ ltp/fsx -d -N 1000 -S 0 /mnt/scr/fsx
....
> operation# (mod 256) for the bad data unknown, check HOLE and EXTEND ops
> LOG DUMP (9 total operations):
> 1(  1 mod 256): MAPWRITE 0x3db39 thru 0x3ffff   (0x24c7 bytes)
> 2(  2 mod 256): MAPREAD  0x2e947 thru 0x33163   (0x481d bytes)
> 3(  3 mod 256): READ     0x2e836 thru 0x3cba1   (0xe36c bytes)
> 4(  4 mod 256): PUNCH    0x2e7 thru 0x5c42      (0x595c bytes)
> 5(  5 mod 256): MAPWRITE 0xcaea thru 0x13ba9    (0x70c0 bytes)  ******WWWW
> 6(  6 mod 256): PUNCH    0x31645 thru 0x38d1c   (0x76d8 bytes)
> 7(  7 mod 256): FALLOC   0x24f92 thru 0x2f2b7   (0xa325 bytes) INTERIOR
> 8(  8 mod 256): FALLOC   0xbcf1 thru 0x171ac    (0xb4bb bytes) INTERIOR ******FFFF
> 9(  9 mod 256): READ     0x126f thru 0x11136    (0xfec8 bytes)  ***RRRR***
> Correct content saved for comparison
> (maybe hexdump "/mnt/scr/fsx" vs "/mnt/scr/fsx.fsxgood")
> 
> XFS gives a good indication that we aren't doing something correctly
> w.r.t. mapped XIP writes, as trying to fiemap the file ASSERT fails
> with a delayed allocation extent somewhere inside the file after a
> sync. I shall keep digging.

Ok, I understand the XFS ASSERT failure, but I don't really
understand the reason for the read failure. XFS assert failed
because I was using the delayed allocation enabled xfs_get_blocks()
to xip_fault/xip_mkwrite, so it was creating a delalloc extent
rather than allocating blocks, and then not having any pages in the
page cache to write back to convert the delalloc extent. This
doesn't explain the zeros being read, though.

So I changed to use the direct IO version, and that leaves me with
an unwritten extent over the mapped write code. Why? Because there's
no IO completion being run from either xip_fault() or xip_mkwrite()
to zero the buffers and run IO completion to convert the extent to
written....

$ xfs_io -f -c "truncate 8k" -c "mmap 0 8k" -c "mwrite 0 4k" \
> -c "bmap -vp" -c "pread -v 0 8k" -c "bmap -vp" /mnt/scr/foo
....
/mnt/scr/foo:
 EXT: FILE-OFFSET      BLOCK-RANGE      AG AG-OFFSET        TOTAL FLAGS
   0: [0..7]:          224..231          0 (224..231)           8 10000
   1: [8..15]:         hole                                     8
$

We're trying to do something that the get_block callback has never
supported.  I note that you added zeroing to ext4_map_blocks() when
an unwritten extent is found and call xip_clear_blocks() from there
to try and handle this within the allocation context without
actually making it obvious why it is necessary.

Essentially what we need get_blocks(create = 1) to do here is this:

	if (hole)
		transactionally allocate and zero block in requested region
	if (unwritten)
		transactionally convert to written and zero block
	if (written)
		map blocks

I think we can get away with this from a crash recovery perspective
because the zeroing of the blocks is synchronous and within the
allocation transaction. I'm implementing a new xfs_get_blocks_xip to
do keep this new behaviour "separate" from the direct IO path
semantics.

I also got rid of the read block map followed by the "create" block
map. Just a single call with create set appropriately for the caller
context is all that is required - the getblock call will do the
correct thing for allocation/conversion cases and if there's already
a block there it will just return the mapping....

<hack, hack>

OK, I've fixed something. The above xfs_io test returns the correct
data on read now, fsx still fails. I'll keep working on it in the
morning, and when I have something that works I'll post it....

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
