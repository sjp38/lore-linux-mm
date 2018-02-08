Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 277256B0003
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 11:20:18 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 17so2872760wrm.10
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 08:20:18 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b204si175471wme.106.2018.02.08.08.20.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Feb 2018 08:20:16 -0800 (PST)
Date: Thu, 8 Feb 2018 17:20:16 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: INFO: task hung in sync_blockdev
Message-ID: <20180208162016.buvilelvl5rze7wr@quack2.suse.cz>
References: <001a11447070ac6fcb0564a08cb1@google.com>
 <20180207155229.GC10945@tassilo.jf.intel.com>
 <20180208092839.ebe5rk6mtvkk5da4@quack2.suse.cz>
 <20180208144918.GF10945@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180208144918.GF10945@tassilo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, syzbot <syzbot+283c3c447181741aea28@syzkaller.appspotmail.com>, akpm@linux-foundation.org, aryabinin@virtuozzo.com, jlayton@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@techsingularity.net, mingo@kernel.org, rgoldwyn@suse.com, syzkaller-bugs@googlegroups.com, linux-fsdevel@vger.kernel.org

On Thu 08-02-18 06:49:18, Andi Kleen wrote:
> > > It seems multiple processes deadlocked on the bd_mutex. 
> > > Unfortunately there's no backtrace for the lock acquisitions,
> > > so it's hard to see the exact sequence.
> > 
> > Well, all in the report points to a situation where some IO was submitted
> > to the block device and never completed (more exactly it took longer than
> > those 120s to complete that IO). It would need more digging into the
> 
> Are you sure? I didn't think outstanding IO would take bd_mutex.

The stack trace is:

 schedule+0xf5/0x430 kernel/sched/core.c:3480
 io_schedule+0x1c/0x70 kernel/sched/core.c:5096
 wait_on_page_bit_common+0x4b3/0x770 mm/filemap.c:1099
 wait_on_page_bit mm/filemap.c:1132 [inline]
 wait_on_page_writeback include/linux/pagemap.h:546 [inline]
 __filemap_fdatawait_range+0x282/0x430 mm/filemap.c:533
 filemap_fdatawait_range mm/filemap.c:558 [inline]
 filemap_fdatawait include/linux/fs.h:2590 [inline]
 filemap_write_and_wait+0x7a/0xd0 mm/filemap.c:624
 __sync_blockdev fs/block_dev.c:448 [inline]
 sync_blockdev.part.29+0x50/0x70 fs/block_dev.c:457
 sync_blockdev fs/block_dev.c:444 [inline]
 __blkdev_put+0x18b/0x7f0 fs/block_dev.c:1763
 blkdev_put+0x85/0x4f0 fs/block_dev.c:1835
 blkdev_close+0x8b/0xb0 fs/block_dev.c:1842
 __fput+0x327/0x7e0 fs/file_table.c:209
 ____fput+0x15/0x20 fs/file_table.c:243


So we are waiting for PageWriteback on some page. And bd_mutex is grabbed
by this process in __blkdev_put() before calling sync_blockdev().

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
