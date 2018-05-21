Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id B98D66B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 16:46:17 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id q13-v6so15693703qtk.8
        for <linux-mm@kvack.org>; Mon, 21 May 2018 13:46:17 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id c40-v6si864576qtk.393.2018.05.21.13.46.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 13:46:15 -0700 (PDT)
Date: Mon, 21 May 2018 13:46:10 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: buffered I/O without buffer heads in xfs and iomap v2
Message-ID: <20180521204610.GC4507@magnolia>
References: <20180518164830.1552-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180518164830.1552-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Fri, May 18, 2018 at 06:47:56PM +0200, Christoph Hellwig wrote:
> Hi all,
> 
> this series adds support for buffered I/O without buffer heads to
> the iomap and XFS code.
> 
> For now this series only contains support for block size == PAGE_SIZE,
> with the 4k support split into a separate series.
> 
> 
> A git tree is available at:
> 
>     git://git.infradead.org/users/hch/xfs.git xfs-iomap-read.2
> 
> Gitweb:
> 
>     http://git.infradead.org/users/hch/xfs.git/shortlog/refs/heads/xfs-iomap-read.2

Hmm, so I pulled this and ran my trivial stupid benchmark on for-next.
It's a stupid VM with a 2G of RAM and a 12GB virtio-scsi disk backed by
tmpfs:

# mkfs.xfs -f -m rmapbt=0,reflink=1 /dev/sda
meta-data=/dev/sda               isize=512    agcount=4, agsize=823296
blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=1,
rmapbt=1
         =                       reflink=1
data     =                       bsize=4096   blocks=3293184, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0, ftype=1
log      =internal log           bsize=4096   blocks=3693, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
# mount /dev/sda /mnt
# xfs_io -f -c 'pwrite -W -S 0x64 -b 83886080 0 734003200' /mnt/a
wrote 734003200/734003200 bytes at offset 0
700 MiB, 9 ops; 0:00:01.06 (655.500 MiB/sec and 8.4279 ops/sec)
# cp --reflink=always /mnt/a /mnt/b
# xfs_io -f -c 'pwrite -W -S 0x65 -b 83886080 0 734003200' /mnt/b
wrote 734003200/734003200 bytes at offset 0
700 MiB, 9 ops; 0.9620 sec (727.615 MiB/sec and 9.3551 ops/sec)

Then I applied your series (not including the blocksize < pagesize
series) and saw this big regression:

# mkfs.xfs -f -m rmapbt=0,reflink=1 /dev/sda
meta-data=/dev/sda               isize=512    agcount=4, agsize=823296
blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=1,
rmapbt=1
         =                       reflink=1
data     =                       bsize=4096   blocks=3293184, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0, ftype=1
log      =internal log           bsize=4096   blocks=3693, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
# mount /dev/sda /mnt
# xfs_io -f -c 'pwrite -W -S 0x64 -b 83886080 0 734003200' /mnt/a
wrote 734003200/734003200 bytes at offset 0
700 MiB, 9 ops; 0:00:08.04 (87.031 MiB/sec and 1.1190 ops/sec)
# cp --reflink=always /mnt/a /mnt/b
# xfs_io -f -c 'pwrite -W -S 0x65 -b 83886080 0 734003200' /mnt/b
wrote 734003200/734003200 bytes at offset 0
700 MiB, 9 ops; 0:00:21.61 (32.389 MiB/sec and 0.4164 ops/sec)

I'll see if I can spot the problem while I read through the v2 code...

--D

> 
> Changes since v1:
>  - fix the iomap_readpages error handling
>  - use unsigned file offsets in a few places to avoid arithmetic overflows
>  - allocate a iomap_page in iomap_page_mkwrite to fix generic/095
>  - improve a few comments
>  - add more asserts
>  - warn about truncated block numbers from ->bmap
>  - new patch to change the __do_page_cache_readahead return value to
>    unsigned int
>  - remove an incorrectly added empty line
>  - make inline data an explicit iomap type instead of a flag
>  - add a IOMAP_F_BUFFER_HEAD flag to force use of buffers heads for gfs2,
>    and keep the basic buffer head infrastructure around for now.
