Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.4 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACA13C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 21:08:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FE8A206C2
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 21:08:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FE8A206C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC1EC6B0007; Tue, 13 Aug 2019 17:08:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D714E6B0008; Tue, 13 Aug 2019 17:08:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C61616B000E; Tue, 13 Aug 2019 17:08:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0090.hostedemail.com [216.40.44.90])
	by kanga.kvack.org (Postfix) with ESMTP id 952BA6B0007
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 17:08:08 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 34580181AC9AE
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 21:08:08 +0000 (UTC)
X-FDA: 75818642256.01.ray94_46e838f22a93a
X-HE-Tag: ray94_46e838f22a93a
X-Filterd-Recvd-Size: 49082
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 21:08:07 +0000 (UTC)
Received: by mail-ot1-f71.google.com with SMTP id 88so14107343otc.19
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 14:08:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:date:message-id:subject:from:to;
        bh=mCvcXc2rClVVP29gxTet4gxy92I90eC1AEZNFxdO40I=;
        b=kFAEWp3WQbzsdvwEnHbiWmbHbKyPNLOEBqscST0MkOjwytxaldllNIeOibrzaN+bSu
         HHuxi6yiLEwY/wu/6kLn/y3+FOPeKaHJVCyQZSFzJZmgVpN6aaxGfTkIc6DsXJnJKndl
         kCGiAPbmuKzt5vf/YIaUdbJgXw/YvpoFkhnQXU1hI5sw6BCg3EdxhdJHEHMhW00rpbXx
         M3K3VpchaskmqeW1Os4CSJQoEIMjwqXykikTdHznHSllL+eB8FqcuL335xSwkdvcDh6T
         aekWjAuD3UGe+6aX2YUHtA7p4DletLv3wus/8BkyupmIjPS2DXDvwaaSsdixE1txzEqm
         2ZQQ==
X-Gm-Message-State: APjAAAVjdnGbZ/StkJ0gcNpRmSstVdM/KnIY97/4Bmgfa0Yr+wyK98FJ
	3rpi7CgCRJsok7VgfZVqgA+5LkneBqcSVTiWuD7vQISSnZhp
X-Google-Smtp-Source: APXvYqz0S9DUOiX+LxngFnA8kSoOw62sD4BX3kqFTwNERIr0M7U4Yn05DRwqD7VJPVXLKUMC221+YhKN9BQwrZ1bQPex4fspFiJP
MIME-Version: 1.0
X-Received: by 2002:a5d:888d:: with SMTP id d13mr2909822ioo.135.1565730486477;
 Tue, 13 Aug 2019 14:08:06 -0700 (PDT)
Date: Tue, 13 Aug 2019 14:08:06 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <00000000000075fa50059006098c@google.com>
Subject: memory leak in bio_clone_fast
From: syzbot <syzbot+0265846a0cb9a0547905@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, baijiaju1990@gmail.com, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, 
	rppt@linux.ibm.com, syzkaller-bugs@googlegroups.com, willy@infradead.org
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

syzbot found the following crash on:

HEAD commit:    d45331b0 Linux 5.3-rc4
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=1651e6d2600000
kernel config:  https://syzkaller.appspot.com/x/.config?x=6c5e70dcab57c6af
dashboard link: https://syzkaller.appspot.com/bug?extid=0265846a0cb9a0547905
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=12c9c336600000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=1766156a600000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+0265846a0cb9a0547905@syzkaller.appspotmail.com

executing program
executing program
executing program
executing program
BUG: memory leak
unreferenced object 0xffff8881226da6c0 (size 192):
   comm "syz-executor332", pid 6977, jiffies 4294941214 (age 15.840s)
   hex dump (first 32 bytes):
     00 00 00 00 00 00 00 00 00 f0 bc 28 81 88 ff ff  ...........(....
     01 c8 60 00 02 0b 00 00 00 00 00 00 00 00 00 00  ..`.............
   backtrace:
     [<00000000b06a638e>] kmemleak_alloc_recursive  
include/linux/kmemleak.h:43 [inline]
     [<00000000b06a638e>] slab_post_alloc_hook mm/slab.h:522 [inline]
     [<00000000b06a638e>] slab_alloc mm/slab.c:3319 [inline]
     [<00000000b06a638e>] kmem_cache_alloc+0x13f/0x2c0 mm/slab.c:3483
     [<00000000950a289d>] mempool_alloc_slab+0x1e/0x30 mm/mempool.c:513
     [<00000000bfcc27e2>] mempool_alloc+0x64/0x1b0 mm/mempool.c:393
     [<00000000cdf95a4a>] bio_alloc_bioset+0x180/0x2c0 block/bio.c:477
     [<00000000b239bb68>] bio_clone_fast+0x25/0x90 block/bio.c:609
     [<000000005d58c2dc>] bio_split+0x4a/0xd0 block/bio.c:1856
     [<00000000ab943734>] blk_bio_segment_split block/blk-merge.c:250  
[inline]
     [<00000000ab943734>] __blk_queue_split+0x355/0x730 block/blk-merge.c:272
     [<00000000e702c0ac>] blk_mq_make_request+0xb0/0x890 block/blk-mq.c:1943
     [<000000003c89773a>] generic_make_request block/blk-core.c:1052 [inline]
     [<000000003c89773a>] generic_make_request+0xf6/0x4a0  
block/blk-core.c:994
     [<00000000a4dcaf78>] submit_bio+0x5a/0x1e0 block/blk-core.c:1163
     [<000000003e1ce7f8>] __blkdev_direct_IO fs/block_dev.c:459 [inline]
     [<000000003e1ce7f8>] blkdev_direct_IO+0x2b3/0x6d0 fs/block_dev.c:515
     [<0000000087ec76a4>] generic_file_direct_write+0xb0/0x1a0  
mm/filemap.c:3230
     [<00000000ff259b44>] __generic_file_write_iter+0xec/0x230  
mm/filemap.c:3413
     [<00000000223d9b6c>] blkdev_write_iter fs/block_dev.c:2026 [inline]
     [<00000000223d9b6c>] blkdev_write_iter+0xbe/0x160 fs/block_dev.c:2003
     [<000000003c4a5c94>] call_write_iter include/linux/fs.h:1870 [inline]
     [<000000003c4a5c94>] aio_write+0x10b/0x1d0 fs/aio.c:1583
     [<00000000581f0c84>] __io_submit_one fs/aio.c:1815 [inline]
     [<00000000581f0c84>] io_submit_one+0x59b/0xe50 fs/aio.c:1862

BUG: memory leak
unreferenced object 0xffff8881226da600 (size 192):
   comm "syz-executor332", pid 6977, jiffies 4294941214 (age 15.840s)
   hex dump (first 32 bytes):
     00 00 00 00 00 00 00 00 00 f0 bc 28 81 88 ff ff  ...........(....
     01 c8 60 00 02 0b 00 00 00 00 00 00 00 00 00 00  ..`.............
   backtrace:
     [<00000000b06a638e>] kmemleak_alloc_recursive  
include/linux/kmemleak.h:43 [inline]
     [<00000000b06a638e>] slab_post_alloc_hook mm/slab.h:522 [inline]
     [<00000000b06a638e>] slab_alloc mm/slab.c:3319 [inline]
     [<00000000b06a638e>] kmem_cache_alloc+0x13f/0x2c0 mm/slab.c:3483
     [<00000000950a289d>] mempool_alloc_slab+0x1e/0x30 mm/mempool.c:513
     [<00000000bfcc27e2>] mempool_alloc+0x64/0x1b0 mm/mempool.c:393
     [<00000000cdf95a4a>] bio_alloc_bioset+0x180/0x2c0 block/bio.c:477
     [<00000000b239bb68>] bio_clone_fast+0x25/0x90 block/bio.c:609
     [<000000005d58c2dc>] bio_split+0x4a/0xd0 block/bio.c:1856
     [<00000000ab943734>] blk_bio_segment_split block/blk-merge.c:250  
[inline]
     [<00000000ab943734>] __blk_queue_split+0x355/0x730 block/blk-merge.c:272
     [<00000000e702c0ac>] blk_mq_make_request+0xb0/0x890 block/blk-mq.c:1943
     [<000000003c89773a>] generic_make_request block/blk-core.c:1052 [inline]
     [<000000003c89773a>] generic_make_request+0xf6/0x4a0  
block/blk-core.c:994
     [<00000000a4dcaf78>] submit_bio+0x5a/0x1e0 block/blk-core.c:1163
     [<000000003e1ce7f8>] __blkdev_direct_IO fs/block_dev.c:459 [inline]
     [<000000003e1ce7f8>] blkdev_direct_IO+0x2b3/0x6d0 fs/block_dev.c:515
     [<0000000087ec76a4>] generic_file_direct_write+0xb0/0x1a0  
mm/filemap.c:3230
     [<00000000ff259b44>] __generic_file_write_iter+0xec/0x230  
mm/filemap.c:3413
     [<00000000223d9b6c>] blkdev_write_iter fs/block_dev.c:2026 [inline]
     [<00000000223d9b6c>] blkdev_write_iter+0xbe/0x160 fs/block_dev.c:2003
     [<000000003c4a5c94>] call_write_iter include/linux/fs.h:1870 [inline]
     [<000000003c4a5c94>] aio_write+0x10b/0x1d0 fs/aio.c:1583
     [<00000000581f0c84>] __io_submit_one fs/aio.c:1815 [inline]
     [<00000000581f0c84>] io_submit_one+0x59b/0xe50 fs/aio.c:1862

BUG: memory leak
unreferenced object 0xffff8881226da540 (size 192):
   comm "syz-executor332", pid 6977, jiffies 4294941214 (age 15.840s)
   hex dump (first 32 bytes):
     00 00 00 00 00 00 00 00 00 f0 bc 28 81 88 ff ff  ...........(....
     01 c8 60 00 02 0b 00 00 00 00 00 00 00 00 00 00  ..`.............
   backtrace:
     [<00000000b06a638e>] kmemleak_alloc_recursive  
include/linux/kmemleak.h:43 [inline]
     [<00000000b06a638e>] slab_post_alloc_hook mm/slab.h:522 [inline]
     [<00000000b06a638e>] slab_alloc mm/slab.c:3319 [inline]
     [<00000000b06a638e>] kmem_cache_alloc+0x13f/0x2c0 mm/slab.c:3483
     [<00000000950a289d>] mempool_alloc_slab+0x1e/0x30 mm/mempool.c:513
     [<00000000bfcc27e2>] mempool_alloc+0x64/0x1b0 mm/mempool.c:393
     [<00000000cdf95a4a>] bio_alloc_bioset+0x180/0x2c0 block/bio.c:477
     [<00000000b239bb68>] bio_clone_fast+0x25/0x90 block/bio.c:609
     [<000000005d58c2dc>] bio_split+0x4a/0xd0 block/bio.c:1856
     [<00000000ab943734>] blk_bio_segment_split block/blk-merge.c:250  
[inline]
     [<00000000ab943734>] __blk_queue_split+0x355/0x730 block/blk-merge.c:272
     [<00000000e702c0ac>] blk_mq_make_request+0xb0/0x890 block/blk-mq.c:1943
     [<000000003c89773a>] generic_make_request block/blk-core.c:1052 [inline]
     [<000000003c89773a>] generic_make_request+0xf6/0x4a0  
block/blk-core.c:994
     [<00000000a4dcaf78>] submit_bio+0x5a/0x1e0 block/blk-core.c:1163
     [<000000003e1ce7f8>] __blkdev_direct_IO fs/block_dev.c:459 [inline]
     [<000000003e1ce7f8>] blkdev_direct_IO+0x2b3/0x6d0 fs/block_dev.c:515
     [<0000000087ec76a4>] generic_file_direct_write+0xb0/0x1a0  
mm/filemap.c:3230
     [<00000000ff259b44>] __generic_file_write_iter+0xec/0x230  
mm/filemap.c:3413
     [<00000000223d9b6c>] blkdev_write_iter fs/block_dev.c:2026 [inline]
     [<00000000223d9b6c>] blkdev_write_iter+0xbe/0x160 fs/block_dev.c:2003
     [<000000003c4a5c94>] call_write_iter include/linux/fs.h:1870 [inline]
     [<000000003c4a5c94>] aio_write+0x10b/0x1d0 fs/aio.c:1583
     [<00000000581f0c84>] __io_submit_one fs/aio.c:1815 [inline]
     [<00000000581f0c84>] io_submit_one+0x59b/0xe50 fs/aio.c:1862

BUG: memory leak
unreferenced object 0xffff8881226da6c0 (size 192):
   comm "syz-executor332", pid 6977, jiffies 4294941214 (age 16.750s)
   hex dump (first 32 bytes):
     00 00 00 00 00 00 00 00 00 f0 bc 28 81 88 ff ff  ...........(....
     01 c8 60 00 02 0b 00 00 00 00 00 00 00 00 00 00  ..`.............
   backtrace:
     [<00000000b06a638e>] kmemleak_alloc_recursive  
include/linux/kmemleak.h:43 [inline]
     [<00000000b06a638e>] slab_post_alloc_hook mm/slab.h:522 [inline]
     [<00000000b06a638e>] slab_alloc mm/slab.c:3319 [inline]
     [<00000000b06a638e>] kmem_cache_alloc+0x13f/0x2c0 mm/slab.c:3483
     [<00000000950a289d>] mempool_alloc_slab+0x1e/0x30 mm/mempool.c:513
     [<00000000bfcc27e2>] mempool_alloc+0x64/0x1b0 mm/mempool.c:393
     [<00000000cdf95a4a>] bio_alloc_bioset+0x180/0x2c0 block/bio.c:477
     [<00000000b239bb68>] bio_clone_fast+0x25/0x90 block/bio.c:609
     [<000000005d58c2dc>] bio_split+0x4a/0xd0 block/bio.c:1856
     [<00000000ab943734>] blk_bio_segment_split block/blk-merge.c:250  
[inline]
     [<00000000ab943734>] __blk_queue_split+0x355/0x730 block/blk-merge.c:272
     [<00000000e702c0ac>] blk_mq_make_request+0xb0/0x890 block/blk-mq.c:1943
     [<000000003c89773a>] generic_make_request block/blk-core.c:1052 [inline]
     [<000000003c89773a>] generic_make_request+0xf6/0x4a0  
block/blk-core.c:994
     [<00000000a4dcaf78>] submit_bio+0x5a/0x1e0 block/blk-core.c:1163
     [<000000003e1ce7f8>] __blkdev_direct_IO fs/block_dev.c:459 [inline]
     [<000000003e1ce7f8>] blkdev_direct_IO+0x2b3/0x6d0 fs/block_dev.c:515
     [<0000000087ec76a4>] generic_file_direct_write+0xb0/0x1a0  
mm/filemap.c:3230
     [<00000000ff259b44>] __generic_file_write_iter+0xec/0x230  
mm/filemap.c:3413
     [<00000000223d9b6c>] blkdev_write_iter fs/block_dev.c:2026 [inline]
     [<00000000223d9b6c>] blkdev_write_iter+0xbe/0x160 fs/block_dev.c:2003
     [<000000003c4a5c94>] call_write_iter include/linux/fs.h:1870 [inline]
     [<000000003c4a5c94>] aio_write+0x10b/0x1d0 fs/aio.c:1583
     [<00000000581f0c84>] __io_submit_one fs/aio.c:1815 [inline]
     [<00000000581f0c84>] io_submit_one+0x59b/0xe50 fs/aio.c:1862

BUG: memory leak
unreferenced object 0xffff8881226da600 (size 192):
   comm "syz-executor332", pid 6977, jiffies 4294941214 (age 16.750s)
   hex dump (first 32 bytes):
     00 00 00 00 00 00 00 00 00 f0 bc 28 81 88 ff ff  ...........(....
     01 c8 60 00 02 0b 00 00 00 00 00 00 00 00 00 00  ..`.............
   backtrace:
     [<00000000b06a638e>] kmemleak_alloc_recursive  
include/linux/kmemleak.h:43 [inline]
     [<00000000b06a638e>] slab_post_alloc_hook mm/slab.h:522 [inline]
     [<00000000b06a638e>] slab_alloc mm/slab.c:3319 [inline]
     [<00000000b06a638e>] kmem_cache_alloc+0x13f/0x2c0 mm/slab.c:3483
     [<00000000950a289d>] mempool_alloc_slab+0x1e/0x30 mm/mempool.c:513
     [<00000000bfcc27e2>] mempool_alloc+0x64/0x1b0 mm/mempool.c:393
     [<00000000cdf95a4a>] bio_alloc_bioset+0x180/0x2c0 block/bio.c:477
     [<00000000b239bb68>] bio_clone_fast+0x25/0x90 block/bio.c:609
     [<000000005d58c2dc>] bio_split+0x4a/0xd0 block/bio.c:1856
     [<00000000ab943734>] blk_bio_segment_split block/blk-merge.c:250  
[inline]
     [<00000000ab943734>] __blk_queue_split+0x355/0x730 block/blk-merge.c:272
     [<00000000e702c0ac>] blk_mq_make_request+0xb0/0x890 block/blk-mq.c:1943
     [<000000003c89773a>] generic_make_request block/blk-core.c:1052 [inline]
     [<000000003c89773a>] generic_make_request+0xf6/0x4a0  
block/blk-core.c:994
     [<00000000a4dcaf78>] submit_bio+0x5a/0x1e0 block/blk-core.c:1163
     [<000000003e1ce7f8>] __blkdev_direct_IO fs/block_dev.c:459 [inline]
     [<000000003e1ce7f8>] blkdev_direct_IO+0x2b3/0x6d0 fs/block_dev.c:515
     [<0000000087ec76a4>] generic_file_direct_write+0xb0/0x1a0  
mm/filemap.c:3230
     [<00000000ff259b44>] __generic_file_write_iter+0xec/0x230  
mm/filemap.c:3413
     [<00000000223d9b6c>] blkdev_write_iter fs/block_dev.c:2026 [inline]
     [<00000000223d9b6c>] blkdev_write_iter+0xbe/0x160 fs/block_dev.c:2003
     [<000000003c4a5c94>] call_write_iter include/linux/fs.h:1870 [inline]
     [<000000003c4a5c94>] aio_write+0x10b/0x1d0 fs/aio.c:1583
     [<00000000581f0c84>] __io_submit_one fs/aio.c:1815 [inline]
     [<00000000581f0c84>] io_submit_one+0x59b/0xe50 fs/aio.c:1862

BUG: memory leak
unreferenced object 0xffff8881226da540 (size 192):
   comm "syz-executor332", pid 6977, jiffies 4294941214 (age 16.750s)
   hex dump (first 32 bytes):
     00 00 00 00 00 00 00 00 00 f0 bc 28 81 88 ff ff  ...........(....
     01 c8 60 00 02 0b 00 00 00 00 00 00 00 00 00 00  ..`.............
   backtrace:
     [<00000000b06a638e>] kmemleak_alloc_recursive  
include/linux/kmemleak.h:43 [inline]
     [<00000000b06a638e>] slab_post_alloc_hook mm/slab.h:522 [inline]
     [<00000000b06a638e>] slab_alloc mm/slab.c:3319 [inline]
     [<00000000b06a638e>] kmem_cache_alloc+0x13f/0x2c0 mm/slab.c:3483
     [<00000000950a289d>] mempool_alloc_slab+0x1e/0x30 mm/mempool.c:513
     [<00000000bfcc27e2>] mempool_alloc+0x64/0x1b0 mm/mempool.c:393
     [<00000000cdf95a4a>] bio_alloc_bioset+0x180/0x2c0 block/bio.c:477
     [<00000000b239bb68>] bio_clone_fast+0x25/0x90 block/bio.c:609
     [<000000005d58c2dc>] bio_split+0x4a/0xd0 block/bio.c:1856
     [<00000000ab943734>] blk_bio_segment_split block/blk-merge.c:250  
[inline]
     [<00000000ab943734>] __blk_queue_split+0x355/0x730 block/blk-merge.c:272
     [<00000000e702c0ac>] blk_mq_make_request+0xb0/0x890 block/blk-mq.c:1943
     [<000000003c89773a>] generic_make_request block/blk-core.c:1052 [inline]
     [<000000003c89773a>] generic_make_request+0xf6/0x4a0  
block/blk-core.c:994
     [<00000000a4dcaf78>] submit_bio+0x5a/0x1e0 block/blk-core.c:1163
     [<000000003e1ce7f8>] __blkdev_direct_IO fs/block_dev.c:459 [inline]
     [<000000003e1ce7f8>] blkdev_direct_IO+0x2b3/0x6d0 fs/block_dev.c:515
     [<0000000087ec76a4>] generic_file_direct_write+0xb0/0x1a0  
mm/filemap.c:3230
     [<00000000ff259b44>] __generic_file_write_iter+0xec/0x230  
mm/filemap.c:3413
     [<00000000223d9b6c>] blkdev_write_iter fs/block_dev.c:2026 [inline]
     [<00000000223d9b6c>] blkdev_write_iter+0xbe/0x160 fs/block_dev.c:2003
     [<000000003c4a5c94>] call_write_iter include/linux/fs.h:1870 [inline]
     [<000000003c4a5c94>] aio_write+0x10b/0x1d0 fs/aio.c:1583
     [<00000000581f0c84>] __io_submit_one fs/aio.c:1815 [inline]
     [<00000000581f0c84>] io_submit_one+0x59b/0xe50 fs/aio.c:1862

BUG: memory leak
unreferenced object 0xffff8881226da6c0 (size 192):
   comm "syz-executor332", pid 6977, jiffies 4294941214 (age 17.650s)
   hex dump (first 32 bytes):
     00 00 00 00 00 00 00 00 00 f0 bc 28 81 88 ff ff  ...........(....
     01 c8 60 00 02 0b 00 00 00 00 00 00 00 00 00 00  ..`.............
   backtrace:
     [<00000000b06a638e>] kmemleak_alloc_recursive  
include/linux/kmemleak.h:43 [inline]
     [<00000000b06a638e>] slab_post_alloc_hook mm/slab.h:522 [inline]
     [<00000000b06a638e>] slab_alloc mm/slab.c:3319 [inline]
     [<00000000b06a638e>] kmem_cache_alloc+0x13f/0x2c0 mm/slab.c:3483
     [<00000000950a289d>] mempool_alloc_slab+0x1e/0x30 mm/mempool.c:513
     [<00000000bfcc27e2>] mempool_alloc+0x64/0x1b0 mm/mempool.c:393
     [<00000000cdf95a4a>] bio_alloc_bioset+0x180/0x2c0 block/bio.c:477
     [<00000000b239bb68>] bio_clone_fast+0x25/0x90 block/bio.c:609
     [<000000005d58c2dc>] bio_split+0x4a/0xd0 block/bio.c:1856
     [<00000000ab943734>] blk_bio_segment_split block/blk-merge.c:250  
[inline]
     [<00000000ab943734>] __blk_queue_split+0x355/0x730 block/blk-merge.c:272
     [<00000000e702c0ac>] blk_mq_make_request+0xb0/0x890 block/blk-mq.c:1943
     [<000000003c89773a>] generic_make_request block/blk-core.c:1052 [inline]
     [<000000003c89773a>] generic_make_request+0xf6/0x4a0  
block/blk-core.c:994
     [<00000000a4dcaf78>] submit_bio+0x5a/0x1e0 block/blk-core.c:1163
     [<000000003e1ce7f8>] __blkdev_direct_IO fs/block_dev.c:459 [inline]
     [<000000003e1ce7f8>] blkdev_direct_IO+0x2b3/0x6d0 fs/block_dev.c:515
     [<0000000087ec76a4>] generic_file_direct_write+0xb0/0x1a0  
mm/filemap.c:3230
     [<00000000ff259b44>] __generic_file_write_iter+0xec/0x230  
mm/filemap.c:3413
     [<00000000223d9b6c>] blkdev_write_iter fs/block_dev.c:2026 [inline]
     [<00000000223d9b6c>] blkdev_write_iter+0xbe/0x160 fs/block_dev.c:2003
     [<000000003c4a5c94>] call_write_iter include/linux/fs.h:1870 [inline]
     [<000000003c4a5c94>] aio_write+0x10b/0x1d0 fs/aio.c:1583
     [<00000000581f0c84>] __io_submit_one fs/aio.c:1815 [inline]
     [<00000000581f0c84>] io_submit_one+0x59b/0xe50 fs/aio.c:1862

BUG: memory leak
unreferenced object 0xffff8881226da600 (size 192):
   comm "syz-executor332", pid 6977, jiffies 4294941214 (age 17.650s)
   hex dump (first 32 bytes):
     00 00 00 00 00 00 00 00 00 f0 bc 28 81 88 ff ff  ...........(....
     01 c8 60 00 02 0b 00 00 00 00 00 00 00 00 00 00  ..`.............
   backtrace:
     [<00000000b06a638e>] kmemleak_alloc_recursive  
include/linux/kmemleak.h:43 [inline]
     [<00000000b06a638e>] slab_post_alloc_hook mm/slab.h:522 [inline]
     [<00000000b06a638e>] slab_alloc mm/slab.c:3319 [inline]
     [<00000000b06a638e>] kmem_cache_alloc+0x13f/0x2c0 mm/slab.c:3483
     [<00000000950a289d>] mempool_alloc_slab+0x1e/0x30 mm/mempool.c:513
     [<00000000bfcc27e2>] mempool_alloc+0x64/0x1b0 mm/mempool.c:393
     [<00000000cdf95a4a>] bio_alloc_bioset+0x180/0x2c0 block/bio.c:477
     [<00000000b239bb68>] bio_clone_fast+0x25/0x90 block/bio.c:609
     [<000000005d58c2dc>] bio_split+0x4a/0xd0 block/bio.c:1856
     [<00000000ab943734>] blk_bio_segment_split block/blk-merge.c:250  
[inline]
     [<00000000ab943734>] __blk_queue_split+0x355/0x730 block/blk-merge.c:272
     [<00000000e702c0ac>] blk_mq_make_request+0xb0/0x890 block/blk-mq.c:1943
     [<000000003c89773a>] generic_make_request block/blk-core.c:1052 [inline]
     [<000000003c89773a>] generic_make_request+0xf6/0x4a0  
block/blk-core.c:994
     [<00000000a4dcaf78>] submit_bio+0x5a/0x1e0 block/blk-core.c:1163
     [<000000003e1ce7f8>] __blkdev_direct_IO fs/block_dev.c:459 [inline]
     [<000000003e1ce7f8>] blkdev_direct_IO+0x2b3/0x6d0 fs/block_dev.c:515
     [<0000000087ec76a4>] generic_file_direct_write+0xb0/0x1a0  
mm/filemap.c:3230
     [<00000000ff259b44>] __generic_file_write_iter+0xec/0x230  
mm/filemap.c:3413
     [<00000000223d9b6c>] blkdev_write_iter fs/block_dev.c:2026 [inline]
     [<00000000223d9b6c>] blkdev_write_iter+0xbe/0x160 fs/block_dev.c:2003
     [<000000003c4a5c94>] call_write_iter include/linux/fs.h:1870 [inline]
     [<000000003c4a5c94>] aio_write+0x10b/0x1d0 fs/aio.c:1583
     [<00000000581f0c84>] __io_submit_one fs/aio.c:1815 [inline]
     [<00000000581f0c84>] io_submit_one+0x59b/0xe50 fs/aio.c:1862

BUG: memory leak
unreferenced object 0xffff8881226da540 (size 192):
   comm "syz-executor332", pid 6977, jiffies 4294941214 (age 17.650s)
   hex dump (first 32 bytes):
     00 00 00 00 00 00 00 00 00 f0 bc 28 81 88 ff ff  ...........(....
     01 c8 60 00 02 0b 00 00 00 00 00 00 00 00 00 00  ..`.............
   backtrace:
     [<00000000b06a638e>] kmemleak_alloc_recursive  
include/linux/kmemleak.h:43 [inline]
     [<00000000b06a638e>] slab_post_alloc_hook mm/slab.h:522 [inline]
     [<00000000b06a638e>] slab_alloc mm/slab.c:3319 [inline]
     [<00000000b06a638e>] kmem_cache_alloc+0x13f/0x2c0 mm/slab.c:3483
     [<00000000950a289d>] mempool_alloc_slab+0x1e/0x30 mm/mempool.c:513
     [<00000000bfcc27e2>] mempool_alloc+0x64/0x1b0 mm/mempool.c:393
     [<00000000cdf95a4a>] bio_alloc_bioset+0x180/0x2c0 block/bio.c:477
     [<00000000b239bb68>] bio_clone_fast+0x25/0x90 block/bio.c:609
     [<000000005d58c2dc>] bio_split+0x4a/0xd0 block/bio.c:1856
     [<00000000ab943734>] blk_bio_segment_split block/blk-merge.c:250  
[inline]
     [<00000000ab943734>] __blk_queue_split+0x355/0x730 block/blk-merge.c:272
     [<00000000e702c0ac>] blk_mq_make_request+0xb0/0x890 block/blk-mq.c:1943
     [<000000003c89773a>] generic_make_request block/blk-core.c:1052 [inline]
     [<000000003c89773a>] generic_make_request+0xf6/0x4a0  
block/blk-core.c:994
     [<00000000a4dcaf78>] submit_bio+0x5a/0x1e0 block/blk-core.c:1163
     [<000000003e1ce7f8>] __blkdev_direct_IO fs/block_dev.c:459 [inline]
     [<000000003e1ce7f8>] blkdev_direct_IO+0x2b3/0x6d0 fs/block_dev.c:515
     [<0000000087ec76a4>] generic_file_direct_write+0xb0/0x1a0  
mm/filemap.c:3230
     [<00000000ff259b44>] __generic_file_write_iter+0xec/0x230  
mm/filemap.c:3413
     [<00000000223d9b6c>] blkdev_write_iter fs/block_dev.c:2026 [inline]
     [<00000000223d9b6c>] blkdev_write_iter+0xbe/0x160 fs/block_dev.c:2003
     [<000000003c4a5c94>] call_write_iter include/linux/fs.h:1870 [inline]
     [<000000003c4a5c94>] aio_write+0x10b/0x1d0 fs/aio.c:1583
     [<00000000581f0c84>] __io_submit_one fs/aio.c:1815 [inline]
     [<00000000581f0c84>] io_submit_one+0x59b/0xe50 fs/aio.c:1862

BUG: memory leak
unreferenced object 0xffff8881226da6c0 (size 192):
   comm "syz-executor332", pid 6977, jiffies 4294941214 (age 18.550s)
   hex dump (first 32 bytes):
     00 00 00 00 00 00 00 00 00 f0 bc 28 81 88 ff ff  ...........(....
     01 c8 60 00 02 0b 00 00 00 00 00 00 00 00 00 00  ..`.............
   backtrace:
     [<00000000b06a638e>] kmemleak_alloc_recursive  
include/linux/kmemleak.h:43 [inline]
     [<00000000b06a638e>] slab_post_alloc_hook mm/slab.h:522 [inline]
     [<00000000b06a638e>] slab_alloc mm/slab.c:3319 [inline]
     [<00000000b06a638e>] kmem_cache_alloc+0x13f/0x2c0 mm/slab.c:3483
     [<00000000950a289d>] mempool_alloc_slab+0x1e/0x30 mm/mempool.c:513
     [<00000000bfcc27e2>] mempool_alloc+0x64/0x1b0 mm/mempool.c:393
     [<00000000cdf95a4a>] bio_alloc_bioset+0x180/0x2c0 block/bio.c:477
     [<00000000b239bb68>] bio_clone_fast+0x25/0x90 block/bio.c:609
     [<000000005d58c2dc>] bio_split+0x4a/0xd0 block/bio.c:1856
     [<00000000ab943734>] blk_bio_segment_split block/blk-merge.c:250  
[inline]
     [<00000000ab943734>] __blk_queue_split+0x355/0x730 block/blk-merge.c:272
     [<00000000e702c0ac>] blk_mq_make_request+0xb0/0x890 block/blk-mq.c:1943
     [<000000003c89773a>] generic_make_request block/blk-core.c:1052 [inline]
     [<000000003c89773a>] generic_make_request+0xf6/0x4a0  
block/blk-core.c:994
     [<00000000a4dcaf78>] submit_bio+0x5a/0x1e0 block/blk-core.c:1163
     [<000000003e1ce7f8>] __blkdev_direct_IO fs/block_dev.c:459 [inline]
     [<000000003e1ce7f8>] blkdev_direct_IO+0x2b3/0x6d0 fs/block_dev.c:515
     [<0000000087ec76a4>] generic_file_direct_write+0xb0/0x1a0  
mm/filemap.c:3230
     [<00000000ff259b44>] __generic_file_write_iter+0xec/0x230  
mm/filemap.c:3413
     [<00000000223d9b6c>] blkdev_write_iter fs/block_dev.c:2026 [inline]
     [<00000000223d9b6c>] blkdev_write_iter+0xbe/0x160 fs/block_dev.c:2003
     [<000000003c4a5c94>] call_write_iter include/linux/fs.h:1870 [inline]
     [<000000003c4a5c94>] aio_write+0x10b/0x1d0 fs/aio.c:1583
     [<00000000581f0c84>] __io_submit_one fs/aio.c:1815 [inline]
     [<00000000581f0c84>] io_submit_one+0x59b/0xe50 fs/aio.c:1862

BUG: memory leak
unreferenced object 0xffff8881226da600 (size 192):
   comm "syz-executor332", pid 6977, jiffies 4294941214 (age 18.550s)
   hex dump (first 32 bytes):
     00 00 00 00 00 00 00 00 00 f0 bc 28 81 88 ff ff  ...........(....
     01 c8 60 00 02 0b 00 00 00 00 00 00 00 00 00 00  ..`.............
   backtrace:
     [<00000000b06a638e>] kmemleak_alloc_recursive  
include/linux/kmemleak.h:43 [inline]
     [<00000000b06a638e>] slab_post_alloc_hook mm/slab.h:522 [inline]
     [<00000000b06a638e>] slab_alloc mm/slab.c:3319 [inline]
     [<00000000b06a638e>] kmem_cache_alloc+0x13f/0x2c0 mm/slab.c:3483
     [<00000000950a289d>] mempool_alloc_slab+0x1e/0x30 mm/mempool.c:513
     [<00000000bfcc27e2>] mempool_alloc+0x64/0x1b0 mm/mempool.c:393
     [<00000000cdf95a4a>] bio_alloc_bioset+0x180/0x2c0 block/bio.c:477
     [<00000000b239bb68>] bio_clone_fast+0x25/0x90 block/bio.c:609
     [<000000005d58c2dc>] bio_split+0x4a/0xd0 block/bio.c:1856
     [<00000000ab943734>] blk_bio_segment_split block/blk-merge.c:250  
[inline]
     [<00000000ab943734>] __blk_queue_split+0x355/0x730 block/blk-merge.c:272
     [<00000000e702c0ac>] blk_mq_make_request+0xb0/0x890 block/blk-mq.c:1943
     [<000000003c89773a>] generic_make_request block/blk-core.c:1052 [inline]
     [<000000003c89773a>] generic_make_request+0xf6/0x4a0  
block/blk-core.c:994
     [<00000000a4dcaf78>] submit_bio+0x5a/0x1e0 block/blk-core.c:1163
     [<000000003e1ce7f8>] __blkdev_direct_IO fs/block_dev.c:459 [inline]
     [<000000003e1ce7f8>] blkdev_direct_IO+0x2b3/0x6d0 fs/block_dev.c:515
     [<0000000087ec76a4>] generic_file_direct_write+0xb0/0x1a0  
mm/filemap.c:3230
     [<00000000ff259b44>] __generic_file_write_iter+0xec/0x230  
mm/filemap.c:3413
     [<00000000223d9b6c>] blkdev_write_iter fs/block_dev.c:2026 [inline]
     [<00000000223d9b6c>] blkdev_write_iter+0xbe/0x160 fs/block_dev.c:2003
     [<000000003c4a5c94>] call_write_iter include/linux/fs.h:1870 [inline]
     [<000000003c4a5c94>] aio_write+0x10b/0x1d0 fs/aio.c:1583
     [<00000000581f0c84>] __io_submit_one fs/aio.c:1815 [inline]
     [<00000000581f0c84>] io_submit_one+0x59b/0xe50 fs/aio.c:1862

BUG: memory leak
unreferenced object 0xffff8881226da540 (size 192):
   comm "syz-executor332", pid 6977, jiffies 4294941214 (age 18.550s)
   hex dump (first 32 bytes):
     00 00 00 00 00 00 00 00 00 f0 bc 28 81 88 ff ff  ...........(....
     01 c8 60 00 02 0b 00 00 00 00 00 00 00 00 00 00  ..`.............
   backtrace:
     [<00000000b06a638e>] kmemleak_alloc_recursive  
include/linux/kmemleak.h:43 [inline]
     [<00000000b06a638e>] slab_post_alloc_hook mm/slab.h:522 [inline]
     [<00000000b06a638e>] slab_alloc mm/slab.c:3319 [inline]
     [<00000000b06a638e>] kmem_cache_alloc+0x13f/0x2c0 mm/slab.c:3483
     [<00000000950a289d>] mempool_alloc_slab+0x1e/0x30 mm/mempool.c:513
     [<00000000bfcc27e2>] mempool_alloc+0x64/0x1b0 mm/mempool.c:393
     [<00000000cdf95a4a>] bio_alloc_bioset+0x180/0x2c0 block/bio.c:477
     [<00000000b239bb68>] bio_clone_fast+0x25/0x90 block/bio.c:609
     [<000000005d58c2dc>] bio_split+0x4a/0xd0 block/bio.c:1856
     [<00000000ab943734>] blk_bio_segment_split block/blk-merge.c:250  
[inline]
     [<00000000ab943734>] __blk_queue_split+0x355/0x730 block/blk-merge.c:272
     [<00000000e702c0ac>] blk_mq_make_request+0xb0/0x890 block/blk-mq.c:1943
     [<000000003c89773a>] generic_make_request block/blk-core.c:1052 [inline]
     [<000000003c89773a>] generic_make_request+0xf6/0x4a0  
block/blk-core.c:994
     [<00000000a4dcaf78>] submit_bio+0x5a/0x1e0 block/blk-core.c:1163
     [<000000003e1ce7f8>] __blkdev_direct_IO fs/block_dev.c:459 [inline]
     [<000000003e1ce7f8>] blkdev_direct_IO+0x2b3/0x6d0 fs/block_dev.c:515
     [<0000000087ec76a4>] generic_file_direct_write+0xb0/0x1a0  
mm/filemap.c:3230
     [<00000000ff259b44>] __generic_file_write_iter+0xec/0x230  
mm/filemap.c:3413
     [<00000000223d9b6c>] blkdev_write_iter fs/block_dev.c:2026 [inline]
     [<00000000223d9b6c>] blkdev_write_iter+0xbe/0x160 fs/block_dev.c:2003
     [<000000003c4a5c94>] call_write_iter include/linux/fs.h:1870 [inline]
     [<000000003c4a5c94>] aio_write+0x10b/0x1d0 fs/aio.c:1583
     [<00000000581f0c84>] __io_submit_one fs/aio.c:1815 [inline]
     [<00000000581f0c84>] io_submit_one+0x59b/0xe50 fs/aio.c:1862

BUG: memory leak
unreferenced object 0xffff8881226da6c0 (size 192):
   comm "syz-executor332", pid 6977, jiffies 4294941214 (age 19.450s)
   hex dump (first 32 bytes):
     00 00 00 00 00 00 00 00 00 f0 bc 28 81 88 ff ff  ...........(....
     01 c8 60 00 02 0b 00 00 00 00 00 00 00 00 00 00  ..`.............
   backtrace:
     [<00000000b06a638e>] kmemleak_alloc_recursive  
include/linux/kmemleak.h:43 [inline]
     [<00000000b06a638e>] slab_post_alloc_hook mm/slab.h:522 [inline]
     [<00000000b06a638e>] slab_alloc mm/slab.c:3319 [inline]
     [<00000000b06a638e>] kmem_cache_alloc+0x13f/0x2c0 mm/slab.c:3483
     [<00000000950a289d>] mempool_alloc_slab+0x1e/0x30 mm/mempool.c:513
     [<00000000bfcc27e2>] mempool_alloc+0x64/0x1b0 mm/mempool.c:393
     [<00000000cdf95a4a>] bio_alloc_bioset+0x180/0x2c0 block/bio.c:477
     [<00000000b239bb68>] bio_clone_fast+0x25/0x90 block/bio.c:609
     [<000000005d58c2dc>] bio_split+0x4a/0xd0 block/bio.c:1856
     [<00000000ab943734>] blk_bio_segment_split block/blk-merge.c:250  
[inline]
     [<00000000ab943734>] __blk_queue_split+0x355/0x730 block/blk-merge.c:272
     [<00000000e702c0ac>] blk_mq_make_request+0xb0/0x890 block/blk-mq.c:1943
     [<000000003c89773a>] generic_make_request block/blk-core.c:1052 [inline]
     [<000000003c89773a>] generic_make_request+0xf6/0x4a0  
block/blk-core.c:994
     [<00000000a4dcaf78>] submit_bio+0x5a/0x1e0 block/blk-core.c:1163
     [<000000003e1ce7f8>] __blkdev_direct_IO fs/block_dev.c:459 [inline]
     [<000000003e1ce7f8>] blkdev_direct_IO+0x2b3/0x6d0 fs/block_dev.c:515
     [<0000000087ec76a4>] generic_file_direct_write+0xb0/0x1a0  
mm/filemap.c:3230
     [<00000000ff259b44>] __generic_file_write_iter+0xec/0x230  
mm/filemap.c:3413
     [<00000000223d9b6c>] blkdev_write_iter fs/block_dev.c:2026 [inline]
     [<00000000223d9b6c>] blkdev_write_iter+0xbe/0x160 fs/block_dev.c:2003
     [<000000003c4a5c94>] call_write_iter include/linux/fs.h:1870 [inline]
     [<000000003c4a5c94>] aio_write+0x10b/0x1d0 fs/aio.c:1583
     [<00000000581f0c84>] __io_submit_one fs/aio.c:1815 [inline]
     [<00000000581f0c84>] io_submit_one+0x59b/0xe50 fs/aio.c:1862

BUG: memory leak
unreferenced object 0xffff8881226da600 (size 192):
   comm "syz-executor332", pid 6977, jiffies 4294941214 (age 19.450s)
   hex dump (first 32 bytes):
     00 00 00 00 00 00 00 00 00 f0 bc 28 81 88 ff ff  ...........(....
     01 c8 60 00 02 0b 00 00 00 00 00 00 00 00 00 00  ..`.............
   backtrace:
     [<00000000b06a638e>] kmemleak_alloc_recursive  
include/linux/kmemleak.h:43 [inline]
     [<00000000b06a638e>] slab_post_alloc_hook mm/slab.h:522 [inline]
     [<00000000b06a638e>] slab_alloc mm/slab.c:3319 [inline]
     [<00000000b06a638e>] kmem_cache_alloc+0x13f/0x2c0 mm/slab.c:3483
     [<00000000950a289d>] mempool_alloc_slab+0x1e/0x30 mm/mempool.c:513
     [<00000000bfcc27e2>] mempool_alloc+0x64/0x1b0 mm/mempool.c:393
     [<00000000cdf95a4a>] bio_alloc_bioset+0x180/0x2c0 block/bio.c:477
     [<00000000b239bb68>] bio_clone_fast+0x25/0x90 block/bio.c:609
     [<000000005d58c2dc>] bio_split+0x4a/0xd0 block/bio.c:1856
     [<00000000ab943734>] blk_bio_segment_split block/blk-merge.c:250  
[inline]
     [<00000000ab943734>] __blk_queue_split+0x355/0x730 block/blk-merge.c:272
     [<00000000e702c0ac>] blk_mq_make_request+0xb0/0x890 block/blk-mq.c:1943
     [<000000003c89773a>] generic_make_request block/blk-core.c:1052 [inline]
     [<000000003c89773a>] generic_make_request+0xf6/0x4a0  
block/blk-core.c:994
     [<00000000a4dcaf78>] submit_bio+0x5a/0x1e0 block/blk-core.c:1163
     [<000000003e1ce7f8>] __blkdev_direct_IO fs/block_dev.c:459 [inline]
     [<000000003e1ce7f8>] blkdev_direct_IO+0x2b3/0x6d0 fs/block_dev.c:515
     [<0000000087ec76a4>] generic_file_direct_write+0xb0/0x1a0  
mm/filemap.c:3230
     [<00000000ff259b44>] __generic_file_write_iter+0xec/0x230  
mm/filemap.c:3413
     [<00000000223d9b6c>] blkdev_write_iter fs/block_dev.c:2026 [inline]
     [<00000000223d9b6c>] blkdev_write_iter+0xbe/0x160 fs/block_dev.c:2003
     [<000000003c4a5c94>] call_write_iter include/linux/fs.h:1870 [inline]
     [<000000003c4a5c94>] aio_write+0x10b/0x1d0 fs/aio.c:1583
     [<00000000581f0c84>] __io_submit_one fs/aio.c:1815 [inline]
     [<00000000581f0c84>] io_submit_one+0x59b/0xe50 fs/aio.c:1862

BUG: memory leak
unreferenced object 0xffff8881226da540 (size 192):
   comm "syz-executor332", pid 6977, jiffies 4294941214 (age 19.450s)
   hex dump (first 32 bytes):
     00 00 00 00 00 00 00 00 00 f0 bc 28 81 88 ff ff  ...........(....
     01 c8 60 00 02 0b 00 00 00 00 00 00 00 00 00 00  ..`.............
   backtrace:
     [<00000000b06a638e>] kmemleak_alloc_recursive  
include/linux/kmemleak.h:43 [inline]
     [<00000000b06a638e>] slab_post_alloc_hook mm/slab.h:522 [inline]
     [<00000000b06a638e>] slab_alloc mm/slab.c:3319 [inline]
     [<00000000b06a638e>] kmem_cache_alloc+0x13f/0x2c0 mm/slab.c:3483
     [<00000000950a289d>] mempool_alloc_slab+0x1e/0x30 mm/mempool.c:513
     [<00000000bfcc27e2>] mempool_alloc+0x64/0x1b0 mm/mempool.c:393
     [<00000000cdf95a4a>] bio_alloc_bioset+0x180/0x2c0 block/bio.c:477
     [<00000000b239bb68>] bio_clone_fast+0x25/0x90 block/bio.c:609
     [<000000005d58c2dc>] bio_split+0x4a/0xd0 block/bio.c:1856
     [<00000000ab943734>] blk_bio_segment_split block/blk-merge.c:250  
[inline]
     [<00000000ab943734>] __blk_queue_split+0x355/0x730 block/blk-merge.c:272
     [<00000000e702c0ac>] blk_mq_make_request+0xb0/0x890 block/blk-mq.c:1943
     [<000000003c89773a>] generic_make_request block/blk-core.c:1052 [inline]
     [<000000003c89773a>] generic_make_request+0xf6/0x4a0  
block/blk-core.c:994
     [<00000000a4dcaf78>] submit_bio+0x5a/0x1e0 block/blk-core.c:1163
     [<000000003e1ce7f8>] __blkdev_direct_IO fs/block_dev.c:459 [inline]
     [<000000003e1ce7f8>] blkdev_direct_IO+0x2b3/0x6d0 fs/block_dev.c:515
     [<0000000087ec76a4>] generic_file_direct_write+0xb0/0x1a0  
mm/filemap.c:3230
     [<00000000ff259b44>] __generic_file_write_iter+0xec/0x230  
mm/filemap.c:3413
     [<00000000223d9b6c>] blkdev_write_iter fs/block_dev.c:2026 [inline]
     [<00000000223d9b6c>] blkdev_write_iter+0xbe/0x160 fs/block_dev.c:2003
     [<000000003c4a5c94>] call_write_iter include/linux/fs.h:1870 [inline]
     [<000000003c4a5c94>] aio_write+0x10b/0x1d0 fs/aio.c:1583
     [<00000000581f0c84>] __io_submit_one fs/aio.c:1815 [inline]
     [<00000000581f0c84>] io_submit_one+0x59b/0xe50 fs/aio.c:1862

BUG: memory leak
unreferenced object 0xffff8881226da6c0 (size 192):
   comm "syz-executor332", pid 6977, jiffies 4294941214 (age 19.510s)
   hex dump (first 32 bytes):
     00 00 00 00 00 00 00 00 00 f0 bc 28 81 88 ff ff  ...........(....
     01 c8 60 00 02 0b 00 00 00 00 00 00 00 00 00 00  ..`.............
   backtrace:
     [<00000000b06a638e>] kmemleak_alloc_recursive  
include/linux/kmemleak.h:43 [inline]
     [<00000000b06a638e>] slab_post_alloc_hook mm/slab.h:522 [inline]
     [<00000000b06a638e>] slab_alloc mm/slab.c:3319 [inline]
     [<00000000b06a638e>] kmem_cache_alloc+0x13f/0x2c0 mm/slab.c:3483
     [<00000000950a289d>] mempool_alloc_slab+0x1e/0x30 mm/mempool.c:513
     [<00000000bfcc27e2>] mempool_alloc+0x64/0x1b0 mm/mempool.c:393
     [<00000000cdf95a4a>] bio_alloc_bioset+0x180/0x2c0 block/bio.c:477
     [<00000000b239bb68>] bio_clone_fast+0x25/0x90 block/bio.c:609
     [<000000005d58c2dc>] bio_split+0x4a/0xd0 block/bio.c:1856
     [<00000000ab943734>] blk_bio_segment_split block/blk-merge.c:250  
[inline]
     [<00000000ab943734>] __blk_queue_split+0x355/0x730 block/blk-merge.c:272
     [<00000000e702c0ac>] blk_mq_make_request+0xb0/0x890 block/blk-mq.c:1943
     [<000000003c89773a>] generic_make_request block/blk-core.c:1052 [inline]
     [<000000003c89773a>] generic_make_request+0xf6/0x4a0  
block/blk-core.c:994
     [<00000000a4dcaf78>] submit_bio+0x5a/0x1e0 block/blk-core.c:1163
     [<000000003e1ce7f8>] __blkdev_direct_IO fs/block_dev.c:459 [inline]
     [<000000003e1ce7f8>] blkdev_direct_IO+0x2b3/0x6d0 fs/block_dev.c:515
     [<0000000087ec76a4>] generic_file_direct_write+0xb0/0x1a0  
mm/filemap.c:3230
     [<00000000ff259b44>] __generic_file_write_iter+0xec/0x230  
mm/filemap.c:3413
     [<00000000223d9b6c>] blkdev_write_iter fs/block_dev.c:2026 [inline]
     [<00000000223d9b6c>] blkdev_write_iter+0xbe/0x160 fs/block_dev.c:2003
     [<000000003c4a5c94>] call_write_iter include/linux/fs.h:1870 [inline]
     [<000000003c4a5c94>] aio_write+0x10b/0x1d0 fs/aio.c:1583
     [<00000000581f0c84>] __io_submit_one fs/aio.c:1815 [inline]
     [<00000000581f0c84>] io_submit_one+0x59b/0xe50 fs/aio.c:1862

BUG: memory leak
unreferenced object 0xffff8881226da600 (size 192):
   comm "syz-executor332", pid 6977, jiffies 4294941214 (age 19.510s)
   hex dump (first 32 bytes):
     00 00 00 00 00 00 00 00 00 f0 bc 28 81 88 ff ff  ...........(....
     01 c8 60 00 02 0b 00 00 00 00 00 00 00 00 00 00  ..`.............
   backtrace:
     [<00000000b06a638e>] kmemleak_alloc_recursive  
include/linux/kmemleak.h:43 [inline]
     [<00000000b06a638e>] slab_post_alloc_hook mm/slab.h:522 [inline]
     [<00000000b06a638e>] slab_alloc mm/slab.c:3319 [inline]
     [<00000000b06a638e>] kmem_cache_alloc+0x13f/0x2c0 mm/slab.c:3483
     [<00000000950a289d>] mempool_alloc_slab+0x1e/0x30 mm/mempool.c:513
     [<00000000bfcc27e2>] mempool_alloc+0x64/0x1b0 mm/mempool.c:393
     [<00000000cdf95a4a>] bio_alloc_bioset+0x180/0x2c0 block/bio.c:477
     [<00000000b239bb68>] bio_clone_fast+0x25/0x90 block/bio.c:609
     [<000000005d58c2dc>] bio_split+0x4a/0xd0 block/bio.c:1856
     [<00000000ab943734>] blk_bio_segment_split block/blk-merge.c:250  
[inline]
     [<00000000ab943734>] __blk_queue_split+0x355/0x730 block/blk-merge.c:272
     [<00000000e702c0ac>] blk_mq_make_request+0xb0/0x890 block/blk-mq.c:1943
     [<000000003c89773a>] generic_make_request block/blk-core.c:1052 [inline]
     [<000000003c89773a>] generic_make_request+0xf6/0x4a0  
block/blk-core.c:994
     [<00000000a4dcaf78>] submit_bio+0x5a/0x1e0 block/blk-core.c:1163
     [<000000003e1ce7f8>] __blkdev_direct_IO fs/block_dev.c:459 [inline]
     [<000000003e1ce7f8>] blkdev_direct_IO+0x2b3/0x6d0 fs/block_dev.c:515
     [<0000000087ec76a4>] generic_file_direct_write+0xb0/0x1a0  
mm/filemap.c:3230
     [<00000000ff259b44>] __generic_file_write_iter+0xec/0x230  
mm/filemap.c:3413
     [<00000000223d9b6c>] blkdev_write_iter fs/block_dev.c:2026 [inline]
     [<00000000223d9b6c>] blkdev_write_iter+0xbe/0x160 fs/block_dev.c:2003
     [<000000003c4a5c94>] call_write_iter include/linux/fs.h:1870 [inline]
     [<000000003c4a5c94>] aio_write+0x10b/0x1d0 fs/aio.c:1583
     [<00000000581f0c84>] __io_submit_one fs/aio.c:1815 [inline]
     [<00000000581f0c84>] io_submit_one+0x59b/0xe50 fs/aio.c:1862

BUG: memory leak
unreferenced object 0xffff8881226da540 (size 192):
   comm "syz-executor332", pid 6977, jiffies 4294941214 (age 19.510s)
   hex dump (first 32 bytes):
     00 00 00 00 00 00 00 00 00 f0 bc 28 81 88 ff ff  ...........(....
     01 c8 60 00 02 0b 00 00 00 00 00 00 00 00 00 00  ..`.............
   backtrace:
     [<00000000b06a638e>] kmemleak_alloc_recursive  
include/linux/kmemleak.h:43 [inline]
     [<00000000b06a638e>] slab_post_alloc_hook mm/slab.h:522 [inline]
     [<00000000b06a638e>] slab_alloc mm/slab.c:3319 [inline]
     [<00000000b06a638e>] kmem_cache_alloc+0x13f/0x2c0 mm/slab.c:3483
     [<00000000950a289d>] mempool_alloc_slab+0x1e/0x30 mm/mempool.c:513
     [<00000000bfcc27e2>] mempool_alloc+0x64/0x1b0 mm/mempool.c:393
     [<00000000cdf95a4a>] bio_alloc_bioset+0x180/0x2c0 block/bio.c:477
     [<00000000b239bb68>] bio_clone_fast+0x25/0x90 block/bio.c:609
     [<000000005d58c2dc>] bio_split+0x4a/0xd0 block/bio.c:1856
     [<00000000ab943734>] blk_bio_segment_split block/blk-merge.c:250  
[inline]
     [<00000000ab943734>] __blk_queue_split+0x355/0x730 block/blk-merge.c:272
     [<00000000e702c0ac>] blk_mq_make_request+0xb0/0x890 block/blk-mq.c:1943
     [<000000003c89773a>] generic_make_request block/blk-core.c:1052 [inline]
     [<000000003c89773a>] generic_make_request+0xf6/0x4a0  
block/blk-core.c:994
     [<00000000a4dcaf78>] submit_bio+0x5a/0x1e0 block/blk-core.c:1163
     [<000000003e1ce7f8>] __blkdev_direct_IO fs/block_dev.c:459 [inline]
     [<000000003e1ce7f8>] blkdev_direct_IO+0x2b3/0x6d0 fs/block_dev.c:515
     [<0000000087ec76a4>] generic_file_direct_write+0xb0/0x1a0  
mm/filemap.c:3230
     [<00000000ff259b44>] __generic_file_write_iter+0xec/0x230  
mm/filemap.c:3413
     [<00000000223d9b6c>] blkdev_write_iter fs/block_dev.c:2026 [inline]
     [<00000000223d9b6c>] blkdev_write_iter+0xbe/0x160 fs/block_dev.c:2003
     [<000000003c4a5c94>] call_write_iter include/linux/fs.h:1870 [inline]
     [<000000003c4a5c94>] aio_write+0x10b/0x1d0 fs/aio.c:1583
     [<00000000581f0c84>] __io_submit_one fs/aio.c:1815 [inline]
     [<00000000581f0c84>] io_submit_one+0x59b/0xe50 fs/aio.c:1862

BUG: memory leak
unreferenced object 0xffff8881226da6c0 (size 192):
   comm "syz-executor332", pid 6977, jiffies 4294941214 (age 19.560s)
   hex dump (first 32 bytes):
     00 00 00 00 00 00 00 00 00 f0 bc 28 81 88 ff ff  ...........(....
     01 c8 60 00 02 0b 00 00 00 00 00 00 00 00 00 00  ..`.............
   backtrace:
     [<00000000b06a638e>] kmemleak_alloc_recursive  
include/linux/kmemleak.h:43 [inline]
     [<00000000b06a638e>] slab_post_alloc_hook mm/slab.h:522 [inline]
     [<00000000b06a638e>] slab_alloc mm/slab.c:3319 [inline]
     [<00000000b06a638e>] kmem_cache_alloc+0x13f/0x2c0 mm/slab.c:3483
     [<00000000950a289d>] mempool_alloc_slab+0x1e/0x30 mm/mempool.c:513
     [<00000000bfcc27e2>] mempool_alloc+0x64/0x1b0 mm/mempool.c:393
     [<00000000cdf95a4a>] bio_alloc_bioset+0x180/0x2c0 block/bio.c:477
     [<00000000b239bb68>] bio_clone_fast+0x25/0x90 block/bio.c:609
     [<000000005d58c2dc>] bio_split+0x4a/0xd0 block/bio.c:1856
     [<00000000ab943734>] blk_bio_segment_split block/blk-merge.c:250  
[inline]
     [<00000000ab943734>] __blk_queue_split+0x355/0x730 block/blk-merge.c:272
     [<00000000e702c0ac>] blk_mq_make_request+0xb0/0x890 block/blk-mq.c:1943
     [<000000003c89773a>] generic_make_request block/blk-core.c:1052 [inline]
     [<000000003c89773a>] generic_make_request+0xf6/0x4a0  
block/blk-core.c:994
     [<00000000a4dcaf78>] submit_bio+0x5a/0x1e0 block/blk-core.c:1163
     [<000000003e1ce7f8>] __blkdev_direct_IO fs/block_dev.c:459 [inline]
     [<000000003e1ce7f8>] blkdev_direct_IO+0x2b3/0x6d0 fs/block_dev.c:515
     [<0000000087ec76a4>] generic_file_direct_write+0xb0/0x1a0  
mm/filemap.c:3230
     [<00000000ff259b44>] __generic_file_write_iter+0xec/0x230  
mm/filemap.c:3413
     [<00000000223d9b6c>] blkdev_write_iter fs/block_dev.c:2026 [inline]
     [<00000000223d9b6c>] blkdev_write_iter+0xbe/0x160 fs/block_dev.c:2003
     [<000000003c4a5c94>] call_write_iter include/linux/fs.h:1870 [inline]
     [<000000003c4a5c94>] aio_write+0x10b/0x1d0 fs/aio.c:1583
     [<00000000581f0c84>] __io_submit_one fs/aio.c:1815 [inline]
     [<00000000581f0c84>] io_submit_one+0x59b/0xe50 fs/aio.c:1862

BUG: memory leak
unreferenced object 0xffff8881226da600 (size 192):
   comm "syz-executor332", pid 6977, jiffies 4294941214 (age 19.560s)
   hex dump (first 32 bytes):
     00 00 00 00 00 00 00 00 00 f0 bc 28 81 88 ff ff  ...........(....
     01 c8 60 00 02 0b 00 00 00 00 00 00 00 00 00 00  ..`.............
   backtrace:
     [<00000000b06a638e>] kmemleak_alloc_recursive  
include/linux/kmemleak.h:43 [inline]
     [<00000000b06a638e>] slab_post_alloc_hook mm/slab.h:522 [inline]
     [<00000000b06a638e>] slab_alloc mm/slab.c:3319 [inline]
     [<00000000b06a638e>] kmem_cache_alloc+0x13f/0x2c0 mm/slab.c:3483
     [<00000000950a289d>] mempool_alloc_slab+0x1e/0x30 mm/mempool.c:513
     [<00000000bfcc27e2>] mempool_alloc+0x64/0x1b0 mm/mempool.c:393
     [<00000000cdf95a4a>] bio_alloc_bioset+0x180/0x2c0 block/bio.c:477
     [<00000000b239bb68>] bio_clone_fast+0x25/0x90 block/bio.c:609
     [<000000005d58c2dc>] bio_split+0x4a/0xd0 block/bio.c:1856
     [<00000000ab943734>] blk_bio_segment_split block/blk-merge.c:250  
[inline]
     [<00000000ab943734>] __blk_queue_split+0x355/0x730 block/blk-merge.c:272
     [<00000000e702c0ac>] blk_mq_make_request+0xb0/0x890 block/blk-mq.c:1943
     [<000000003c89773a>] generic_make_request block/blk-core.c:1052 [inline]
     [<000000003c89773a>] generic_make_request+0xf6/0x4a0  
block/blk-core.c:994
     [<00000000a4dcaf78>] submit_bio+0x5a/0x1e0 block/blk-core.c:1163
     [<000000003e1ce7f8>] __blkdev_direct_IO fs/block_dev.c:459 [inline]
     [<000000003e1ce7f8>] blkdev_direct_IO+0x2b3/0x6d0 fs/block_dev.c:515
     [<0000000087ec76a4>] generic_file_direct_write+0xb0/0x1a0  
mm/filemap.c:3230
     [<00000000ff259b44>] __generic_file_write_iter+0xec/0x230  
mm/filemap.c:3413
     [<00000000223d9b6c>] blkdev_write_iter fs/block_dev.c:2026 [inline]
     [<00000000223d9b6c>] blkdev_write_iter+0xbe/0x160 fs/block_dev.c:2003
     [<000000003c4a5c94>] call_write_iter include/linux/fs.h:1870 [inline]
     [<000000003c4a5c94>] aio_write+0x10b/0x1d0 fs/aio.c:1583
     [<00000000581f0c84>] __io_submit_one fs/aio.c:1815 [inline]
     [<00000000581f0c84>] io_submit_one+0x59b/0xe50 fs/aio.c:1862

BUG: memory leak
unreferenced object 0xffff8881226da540 (size 192):
   comm "syz-executor332", pid 6977, jiffies 4294941214 (age 19.560s)
   hex dump (first 32 bytes):
     00 00 00 00 00 00 00 00 00 f0 bc 28 81 88 ff ff  ...........(....
     01 c8 60 00 02 0b 00 00 00 00 00 00 00 00 00 00  ..`.............
   backtrace:
     [<00000000b06a638e>] kmemleak_alloc_recursive  
include/linux/kmemleak.h:43 [inline]
     [<00000000b06a638e>] slab_post_alloc_hook mm/slab.h:522 [inline]
     [<00000000b06a638e>] slab_alloc mm/slab.c:3319 [inline]
     [<00000000b06a638e>] kmem_cache_alloc+0x13f/0x2c0 mm/slab.c:3483
     [<00000000950a289d>] mempool_alloc_slab+0x1e/0x30 mm/mempool.c:513
     [<00000000bfcc27e2>] mempool_alloc+0x64/0x1b0 mm/mempool.c:393
     [<00000000cdf95a4a>] bio_alloc_bioset+0x180/0x2c0 block/bio.c:477
     [<00000000b239bb68>] bio_clone_fast+0x25/0x90 block/bio.c:609
     [<000000005d58c2dc>] bio_split+0x4a/0xd0 block/bio.c:1856
     [<00000000ab943734>] blk_bio_segment_split block/blk-merge.c:250  
[inline]
     [<00000000ab943734>] __blk_queue_split+0x355/0x730 block/blk-merge.c:272
     [<00000000e702c0ac>] blk_mq_make_request+0xb0/0x890 block/blk-mq.c:1943
     [<000000003c89773a>] generic_make_request block/blk-core.c:1052 [inline]
     [<000000003c89773a>] generic_make_request+0xf6/0x4a0  
block/blk-core.c:994
     [<00000000a4dcaf78>] submit_bio+0x5a/0x1e0 block/blk-core.c:1163
     [<000000003e1ce7f8>] __blkdev_direct_IO fs/block_dev.c:459 [inline]
     [<000000003e1ce7f8>] blkdev_direct_IO+0x2b3/0x6d0 fs/block_dev.c:515
     [<0000000087ec76a4>] generic_file_direct_write+0xb0/0x1a0  
mm/filemap.c:3230
     [<00000000ff259b44>] __generic_file_write_iter+0xec/0x230  
mm/filemap.c:3413
     [<00000000223d9b6c>] blkdev_write_iter fs/block_dev.c:2026 [inline]
     [<00000000223d9b6c>] blkdev_write_iter+0xbe/0x160 fs/block_dev.c:2003
     [<000000003c4a5c94>] call_write_iter include/linux/fs.h:1870 [inline]
     [<000000003c4a5c94>] aio_write+0x10b/0x1d0 fs/aio.c:1583
     [<00000000581f0c84>] __io_submit_one fs/aio.c:1815 [inline]
     [<00000000581f0c84>] io_submit_one+0x59b/0xe50 fs/aio.c:1862



---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#status for how to communicate with syzbot.
syzbot can test patches for this bug, for details see:
https://goo.gl/tpsmEJ#testing-patches

