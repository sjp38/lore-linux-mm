Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 218F16B0099
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 20:48:01 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so13347470pab.4
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 17:48:00 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id gc7si9649538pac.58.2014.11.03.17.47.58
        for <linux-mm@kvack.org>;
        Mon, 03 Nov 2014 17:47:59 -0800 (PST)
Date: Tue, 4 Nov 2014 10:49:09 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: bdev_read_page
Message-ID: <20141104014909.GA8826@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, "karam.lee" <karam.lee@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

[1] b07b0aaf54ace05, zram: implement rw_page operation of zram

After I merged [1] and was testing zram, I got following warning.

[  179.987592] zram0: detected capacity change from 2147483648 to 0
[  179.987570] page:ffffea00008d6300 count:2 mapcount:0 mapping:ffff880025348e88 index:0x0
[  179.987570] flags: 0x100000000020002(error|mappedtodisk)
[  179.987570] page dumped because: VM_BUG_ON_PAGE(!PageLocked(page))
[  179.987570] ------------[ cut here ]------------
[  179.987570] kernel BUG at mm/filemap.c:747!
[  179.987570] invalid opcode: 0000 [#1] SMP 
[  179.987570] Dumping ftrace buffer:
[  179.987570]    (ftrace buffer empty)
[  179.987570] Modules linked in:
[  179.987570] CPU: 10 PID: 23080 Comm: udisks-part-id Not tainted 3.18.0-rc2+ #584
[  179.987570] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[  179.987570] task: ffff88001de74200 ti: ffff88001b220000 task.ti: ffff88001b220000
[  179.987570] RIP: 0010:[<ffffffff8114ae12>]  [<ffffffff8114ae12>] unlock_page+0x82/0x90
[  179.987570] RSP: 0018:ffff88001b223998  EFLAGS: 00010246
[  179.987570] RAX: 0000000000000036 RBX: ffff88001e009a50 RCX: 000000000910090f
[  179.987570] RDX: 0000000000000910 RSI: 0000000000000001 RDI: ffffffff81600a7f
[  179.987570] RBP: ffff88001b223998 R08: 0000000000000001 R09: 0000000000000001
[  179.987570] R10: 0000000000000001 R11: 0000000000000000 R12: 0000000000000001
[  179.987570] R13: ffff88001e0099c0 R14: 00000000fffffffb R15: ffff88001e0099c0
[  179.987570] FS:  00007fcb17c73800(0000) GS:ffff880027f40000(0000) knlGS:0000000000000000
[  179.987570] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  179.987570] CR2: 00007fff1629ebc8 CR3: 000000001dc4f000 CR4: 00000000000006e0
[  179.987570] Stack:
[  179.987570]  ffff88001b2239a8 ffffffff8114afde ffff88001b2239d8 ffffffff811f2e52
[  179.987570]  ffff88001e0099c0 00000000fffffffb 0000000000000000 ffff880025348e88
[  179.987570]  ffff88001b223a08 ffffffff812e9ad3 ffff88001b223a08 ffffffff8109b6b3
[  179.987570] Call Trace:
[  179.987570]  [<ffffffff8114afde>] page_endio+0x1e/0x80
[  179.987570]  [<ffffffff811f2e52>] mpage_end_io+0x42/0x60
[  179.987570]  [<ffffffff812e9ad3>] bio_endio+0x53/0xa0
[  179.987570]  [<ffffffff8109b6b3>] ? up_read+0x23/0x40
[  179.987570]  [<ffffffff81413f09>] zram_make_request+0x2a9/0x3c0
[  179.987570]  [<ffffffff812ee330>] generic_make_request+0xc0/0x100
[  179.987570]  [<ffffffff812ee3e5>] submit_bio+0x75/0x140
[  179.987570]  [<ffffffff812ee375>] ? submit_bio+0x5/0x140
[  179.987570]  [<ffffffff811f2e03>] mpage_bio_submit+0x33/0x40
[  179.987570]  [<ffffffff811f3de5>] mpage_readpages+0xf5/0x110
[  179.987570]  [<ffffffff811ed7a0>] ? I_BDEV+0x10/0x10
[  179.987570]  [<ffffffff811ed7a0>] ? I_BDEV+0x10/0x10
[  179.987570]  [<ffffffff81603241>] ? ftrace_call+0x5/0x2f
[  179.987570]  [<ffffffff81603241>] ? ftrace_call+0x5/0x2f
[  179.987570]  [<ffffffff811ee190>] ? blkdev_write_begin+0x30/0x30
[  179.987570]  [<ffffffff811ed7a0>] ? I_BDEV+0x10/0x10
[  179.987570]  [<ffffffff811ee1ad>] blkdev_readpages+0x1d/0x20
[  179.987570]  [<ffffffff81158ed4>] __do_page_cache_readahead+0x204/0x290
[  179.987570]  [<ffffffff81158d99>] ? __do_page_cache_readahead+0xc9/0x290
[  179.987570]  [<ffffffff8114b045>] ? find_get_entry+0x5/0x130
[  179.987570]  [<ffffffff811593cd>] force_page_cache_readahead+0x7d/0xb0
[  179.987570]  [<ffffffff81159443>] page_cache_sync_readahead+0x43/0x50
[  179.987570]  [<ffffffff8114d0e1>] generic_file_read_iter+0x451/0x650
[  179.987570]  [<ffffffff81603241>] ? ftrace_call+0x5/0x2f
[  179.987570]  [<ffffffff811ed947>] blkdev_read_iter+0x37/0x40
[  179.987570]  [<ffffffff811b4358>] new_sync_read+0x78/0xb0
[  179.987570]  [<ffffffff811b555b>] vfs_read+0xab/0x180
[  179.987570]  [<ffffffff811b5682>] SyS_read+0x52/0xb0
[  179.987570]  [<ffffffff816011d2>] system_call_fastpath+0x12/0x17
[  179.987570] Code: 00 4c 8b 82 f8 00 00 00 31 d2 48 d3 ee 48 8d 3c f6 48 89 c6 49 8d 3c f8 e8 dc 9f f4 ff 5d c3 48 c7 c6 88 2c a0 81 e8 1e a8 02 00 <0f> 0b 66 66 66 2e 0f 1f 84 00 00 00 00 00 e8 bb 83 4b 00 55 48 
[  179.987570] RIP  [<ffffffff8114ae12>] unlock_page+0x82/0x90
[  179.987570]  RSP <ffff88001b223998>
[  179.987570] ---[ end trace 39c73c1d9da87ec4 ]---
[

The reason was that read I/O caused bdev_read_page could be failed by
driver's internal problem so driver could set the page as PageError
and then unlock the page by page_endio. However, do_mpage_readpage
retry the I/O with BIO path without any locking/cleaning PG_error
so if it fails again, we could encounter above warning.

Should we solve it with introducing page_endio_nolock which
will not unlock the page in case of read-failure and use the function
in rw_page functions? It relies on retrying logic of caller so it's
ugly.

Another soulution is we can clean PG_error and locks the page
again before the going bio path but I'm not sure it doesn't have
any side-effect after releasing the lock. If it doesn't have any
side-effect, it would be best.

The simplest solution I can think of is to bail out in case of
fail of bdev_read_page without going on another route but you seem
to be careful when I saw the comment of bdev_read_page.

"Errors returned by this function are usually "soft", eg out of memory, or
 queue full; callers should try a different route to read this page rather
 than propagate an error back up the stack."

Actually, I'm not sure how much such fallback retrial really makes forward
progress?

Anyway, I'd like to listen the opinions.

Thanks.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
