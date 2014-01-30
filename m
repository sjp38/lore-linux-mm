Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0A2506B0037
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 01:42:36 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id rr13so2751668pbb.7
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 22:42:36 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [2001:44b8:8060:ff02:300:1:2:7])
        by mx.google.com with ESMTP id zk9si5172806pac.318.2014.01.29.22.42.34
        for <linux-mm@kvack.org>;
        Wed, 29 Jan 2014 22:42:35 -0800 (PST)
Date: Thu, 30 Jan 2014 17:42:30 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v5 00/22] Rewrite XIP code and add XIP support to ext4
Message-ID: <20140130064230.GG13997@dastard>
References: <cover.1389779961.git.matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1389779961.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org

On Wed, Jan 15, 2014 at 08:24:18PM -0500, Matthew Wilcox wrote:
> This series of patches add support for XIP to ext4.  Unfortunately,
> it turns out to be necessary to rewrite the existing XIP support code
> first due to races that are unfixable in the current design.
> 
> Since v4 of this patchset, I've improved the documentation, fixed a
> couple of warnings that a newer version of gcc emitted, and fixed a
> bug where we would read/write the wrong address for I/Os that were not
> aligned to PAGE_SIZE.

Looks like there's something fundamentally broken with the patch set
as it stands. I get this same data corruption on both ext4 and XFS
with XIP using fsx. It's as basic as it gets - the first read after
a mmapped write fails to see the data written by mmap:

$ sudo mkfs.xfs -f /dev/ram0
meta-data=/dev/ram0              isize=256    agcount=4, agsize=256000 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=0
data     =                       bsize=4096   blocks=1024000, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=0
log      =internal log           bsize=4096   blocks=12800, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
$ sudo mount -o xip /dev/ram0 /mnt/scr
$ sudo chmod 777 /mnt/scr
$ ltp/fsx -d -N 1000 -S 0 /mnt/scr/fsx
Seed set to 3774
1 mapwrite      0x3db39 thru    0x3ffff (0x24c7 bytes)
2 mapread       0x2e947 thru    0x33163 (0x481d bytes)
3 read  0x2e836 thru    0x3cba1 (0xe36c bytes)
4 punch from 0x2e7 to 0x5c43, (0x595c bytes)
5 mapwrite      0xcaea thru     0x13ba9 (0x70c0 bytes)
6 punch from 0x31645 to 0x38d1d, (0x76d8 bytes)
7 falloc        from 0x24f92 to 0x2f2b7 (0xa325 bytes)
fallocating to largest ever: 0x171ac
8 falloc        from 0xbcf1 to 0x171ac (0xb4bb bytes)
9 read  0x126f thru     0x11136 (0xfec8 bytes)
READ BAD DATA: offset = 0x126f, size = 0xfec8, fname = /mnt/scr/fsx
OFFSET  GOOD    BAD     RANGE
0x caea 0x05f9  0x0000  0x    0
operation# (mod 256) for the bad data unknown, check HOLE and EXTEND ops
0x caeb 0xf905  0x0000  0x    1
operation# (mod 256) for the bad data unknown, check HOLE and EXTEND ops
0x caec 0x0599  0x0000  0x    2
operation# (mod 256) for the bad data unknown, check HOLE and EXTEND ops
0x caed 0x9905  0x0000  0x    3
operation# (mod 256) for the bad data unknown, check HOLE and EXTEND ops
0x caee 0x05e8  0x0000  0x    4
operation# (mod 256) for the bad data unknown, check HOLE and EXTEND ops
0x caef 0xe805  0x0000  0x    5
operation# (mod 256) for the bad data unknown, check HOLE and EXTEND ops
0x caf0 0x0580  0x0000  0x    6
operation# (mod 256) for the bad data unknown, check HOLE and EXTEND ops
0x caf1 0x8005  0x0000  0x    7
operation# (mod 256) for the bad data unknown, check HOLE and EXTEND ops
0x caf2 0x056c  0x0000  0x    8
operation# (mod 256) for the bad data unknown, check HOLE and EXTEND ops
0x caf3 0x6c05  0x0000  0x    9
operation# (mod 256) for the bad data unknown, check HOLE and EXTEND ops
0x caf4 0x05ad  0x0000  0x    a
operation# (mod 256) for the bad data unknown, check HOLE and EXTEND ops
0x caf5 0xad05  0x0000  0x    b
operation# (mod 256) for the bad data unknown, check HOLE and EXTEND ops
0x caf6 0x0539  0x0000  0x    c
operation# (mod 256) for the bad data unknown, check HOLE and EXTEND ops
0x caf7 0x3905  0x0000  0x    d
operation# (mod 256) for the bad data unknown, check HOLE and EXTEND ops
0x caf8 0x05db  0x0000  0x    e
operation# (mod 256) for the bad data unknown, check HOLE and EXTEND ops
0x caf9 0xdb05  0x0000  0x    f
operation# (mod 256) for the bad data unknown, check HOLE and EXTEND ops
LOG DUMP (9 total operations):
1(  1 mod 256): MAPWRITE 0x3db39 thru 0x3ffff   (0x24c7 bytes)
2(  2 mod 256): MAPREAD  0x2e947 thru 0x33163   (0x481d bytes)
3(  3 mod 256): READ     0x2e836 thru 0x3cba1   (0xe36c bytes)
4(  4 mod 256): PUNCH    0x2e7 thru 0x5c42      (0x595c bytes)
5(  5 mod 256): MAPWRITE 0xcaea thru 0x13ba9    (0x70c0 bytes)  ******WWWW
6(  6 mod 256): PUNCH    0x31645 thru 0x38d1c   (0x76d8 bytes)
7(  7 mod 256): FALLOC   0x24f92 thru 0x2f2b7   (0xa325 bytes) INTERIOR
8(  8 mod 256): FALLOC   0xbcf1 thru 0x171ac    (0xb4bb bytes) INTERIOR ******FFFF
9(  9 mod 256): READ     0x126f thru 0x11136    (0xfec8 bytes)  ***RRRR***
Correct content saved for comparison
(maybe hexdump "/mnt/scr/fsx" vs "/mnt/scr/fsx.fsxgood")

XFS gives a good indication that we aren't doing something correctly
w.r.t. mapped XIP writes, as trying to fiemap the file ASSERT fails
with a delayed allocation extent somewhere inside the file after a
sync. I shall keep digging.

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
