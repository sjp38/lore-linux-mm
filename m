Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id E750B6B0325
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 10:52:44 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id f1-v6so162887plb.7
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 07:52:44 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id w3si1084745pgv.486.2018.02.07.07.52.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Feb 2018 07:52:43 -0800 (PST)
Date: Wed, 7 Feb 2018 07:52:29 -0800
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: INFO: task hung in sync_blockdev
Message-ID: <20180207155229.GC10945@tassilo.jf.intel.com>
References: <001a11447070ac6fcb0564a08cb1@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <001a11447070ac6fcb0564a08cb1@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+283c3c447181741aea28@syzkaller.appspotmail.com>
Cc: akpm@linux-foundation.org, aryabinin@virtuozzo.com, jack@suse.cz, jlayton@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@techsingularity.net, mingo@kernel.org, rgoldwyn@suse.com, syzkaller-bugs@googlegroups.com, linux-fsdevel@vger.kernel.org

>  #0:  (&bdev->bd_mutex){+.+.}, at: [<0000000040269370>]
> __blkdev_put+0xbc/0x7f0 fs/block_dev.c:1757
> 1 lock held by blkid/19199:
>  #0:  (&bdev->bd_mutex){+.+.}, at: [<00000000b4dcaa18>]
> __blkdev_get+0x158/0x10e0 fs/block_dev.c:1439
>  #1:  (&ldata->atomic_read_lock){+.+.}, at: [<0000000033edf9f2>]
> n_tty_read+0x2ef/0x1a00 drivers/tty/n_tty.c:2131
> 1 lock held by syz-executor5/19330:
>  #0:  (&bdev->bd_mutex){+.+.}, at: [<00000000b4dcaa18>]
> __blkdev_get+0x158/0x10e0 fs/block_dev.c:1439
> 1 lock held by syz-executor5/19331:
>  #0:  (&bdev->bd_mutex){+.+.}, at: [<00000000b4dcaa18>]
> __blkdev_get+0x158/0x10e0 fs/block_dev.c:1439

It seems multiple processes deadlocked on the bd_mutex. 
Unfortunately there's no backtrace for the lock acquisitions,
so it's hard to see the exact sequence.

It seems lockdep is already active, so it's likely not
just an ordering violation, but something else.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
