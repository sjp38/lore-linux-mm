Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9CD706B0003
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 04:28:44 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r82so1952598wme.0
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 01:28:44 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y3si2617843wme.174.2018.02.08.01.28.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Feb 2018 01:28:43 -0800 (PST)
Date: Thu, 8 Feb 2018 10:28:39 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: INFO: task hung in sync_blockdev
Message-ID: <20180208092839.ebe5rk6mtvkk5da4@quack2.suse.cz>
References: <001a11447070ac6fcb0564a08cb1@google.com>
 <20180207155229.GC10945@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180207155229.GC10945@tassilo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: syzbot <syzbot+283c3c447181741aea28@syzkaller.appspotmail.com>, akpm@linux-foundation.org, aryabinin@virtuozzo.com, jack@suse.cz, jlayton@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@techsingularity.net, mingo@kernel.org, rgoldwyn@suse.com, syzkaller-bugs@googlegroups.com, linux-fsdevel@vger.kernel.org

On Wed 07-02-18 07:52:29, Andi Kleen wrote:
> >  #0:  (&bdev->bd_mutex){+.+.}, at: [<0000000040269370>]
> > __blkdev_put+0xbc/0x7f0 fs/block_dev.c:1757
> > 1 lock held by blkid/19199:
> >  #0:  (&bdev->bd_mutex){+.+.}, at: [<00000000b4dcaa18>]
> > __blkdev_get+0x158/0x10e0 fs/block_dev.c:1439
> >  #1:  (&ldata->atomic_read_lock){+.+.}, at: [<0000000033edf9f2>]
> > n_tty_read+0x2ef/0x1a00 drivers/tty/n_tty.c:2131
> > 1 lock held by syz-executor5/19330:
> >  #0:  (&bdev->bd_mutex){+.+.}, at: [<00000000b4dcaa18>]
> > __blkdev_get+0x158/0x10e0 fs/block_dev.c:1439
> > 1 lock held by syz-executor5/19331:
> >  #0:  (&bdev->bd_mutex){+.+.}, at: [<00000000b4dcaa18>]
> > __blkdev_get+0x158/0x10e0 fs/block_dev.c:1439
> 
> It seems multiple processes deadlocked on the bd_mutex. 
> Unfortunately there's no backtrace for the lock acquisitions,
> so it's hard to see the exact sequence.

Well, all in the report points to a situation where some IO was submitted
to the block device and never completed (more exactly it took longer than
those 120s to complete that IO). It would need more digging into the
syzkaller program to find out what kind of device that was and possibly why
the IO took so long to complete...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
