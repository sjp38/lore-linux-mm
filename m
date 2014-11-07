Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 44D70800CA
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 23:53:41 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id ft15so2574732pdb.11
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 20:53:40 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id nt8si7801208pdb.253.2014.11.06.20.53.38
        for <linux-mm@kvack.org>;
        Thu, 06 Nov 2014 20:53:39 -0800 (PST)
Date: Fri, 7 Nov 2014 13:55:01 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zram: make rw_page opeartion return 0
Message-ID: <20141107045501.GA16460@bbox>
References: <1415146209-22747-1-git-send-email-minchan@kernel.org>
 <20141106134342.GA984@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20141106134342.GA984@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Nick Piggin <npiggin@kernel.dk>, linux-kernel@vger.kernel.org, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Karam Lee <karam.lee@lge.com>

Hello Sergey,

On Thu, Nov 06, 2014 at 10:43:42PM +0900, Sergey Senozhatsky wrote:
> Hello,
> 
> On (11/05/14 09:10), Minchan Kim wrote:
> > zram_rw_page returns error code to upper layer with PG_error flag
> > of the page but it should be wrong usage. If submitted IO is
> > hard fail(ie, I/O again will not succeed), we should return 0,
> > indicating that the submission was successful but the IO operation
> > failed.
> > 
> > http://marc.info/?l=linux-mm&m=141511693112734&w=2
> > 
> 
> well, `don't return error in case of an error' is a bit misleading.

Yes, it was. It would be better to make it with "boolean"
and return true if sumission was successful. Anyway, it's not out of
the patch.

> 
> apart from zram there seems to be one block driver that does the
> same: brd.c [git grep page_endio]. so I Cc Nick Piggin.
> 
> > This patch fixes below BUG.
> > 
> > [  179.987592] zram0: detected capacity change from 2147483648 to 0
> > [  179.987570] page:ffffea00008d6300 count:2 mapcount:0 mapping:ffff880025348e88 index:0x0
> > [  179.987570] flags: 0x100000000020002(error|mappedtodisk)
> > [  179.987570] page dumped because: VM_BUG_ON_PAGE(!PageLocked(page))
> > [  179.987570] ------------[ cut here ]------------
> > [  179.987570] kernel BUG at mm/filemap.c:747!
> > [  179.987570] invalid opcode: 0000 [#1] SMP
> > [  179.987570] Dumping ftrace buffer:
> > [  179.987570]    (ftrace buffer empty)
> > [  179.987570] Modules linked in:
> > [  179.987570] CPU: 10 PID: 23080 Comm: udisks-part-id Not tainted 3.18.0-rc2+ #584
> > [  179.987570] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> > [  179.987570] task: ffff88001de74200 ti: ffff88001b220000 task.ti: ffff88001b220000
> > [  179.987570] RIP: 0010:[<ffffffff8114ae12>]  [<ffffffff8114ae12>] unlock_page+0x82/0x90
> > [  179.987570] RSP: 0018:ffff88001b223998  EFLAGS: 00010246
> > [  179.987570] RAX: 0000000000000036 RBX: ffff88001e009a50 RCX: 000000000910090f
> > [  179.987570] RDX: 0000000000000910 RSI: 0000000000000001 RDI: ffffffff81600a7f
> > [  179.987570] RBP: ffff88001b223998 R08: 0000000000000001 R09: 0000000000000001
> > [  179.987570] R10: 0000000000000001 R11: 0000000000000000 R12: 0000000000000001
> > [  179.987570] R13: ffff88001e0099c0 R14: 00000000fffffffb R15: ffff88001e0099c0
> > [  179.987570] FS:  00007fcb17c73800(0000) GS:ffff880027f40000(0000) knlGS:0000000000000000
> > [  179.987570] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > [  179.987570] CR2: 00007fff1629ebc8 CR3: 000000001dc4f000 CR4: 00000000000006e0
> > [  179.987570] Stack:
> > [  179.987570]  ffff88001b2239a8 ffffffff8114afde ffff88001b2239d8 ffffffff811f2e52
> > [  179.987570]  ffff88001e0099c0 00000000fffffffb 0000000000000000 ffff880025348e88
> > [  179.987570]  ffff88001b223a08 ffffffff812e9ad3 ffff88001b223a08 ffffffff8109b6b3
> > [  179.987570] Call Trace:
> > [  179.987570]  [<ffffffff8114afde>] page_endio+0x1e/0x80
> > [  179.987570]  [<ffffffff811f2e52>] mpage_end_io+0x42/0x60
> > [  179.987570]  [<ffffffff812e9ad3>] bio_endio+0x53/0xa0
> > [  179.987570]  [<ffffffff8109b6b3>] ? up_read+0x23/0x40
> > [  179.987570]  [<ffffffff81413f09>] zram_make_request+0x2a9/0x3c0
> > [  179.987570]  [<ffffffff812ee330>] generic_make_request+0xc0/0x100
> > [  179.987570]  [<ffffffff812ee3e5>] submit_bio+0x75/0x140
> > [  179.987570]  [<ffffffff812ee375>] ? submit_bio+0x5/0x140
> > [  179.987570]  [<ffffffff811f2e03>] mpage_bio_submit+0x33/0x40
> > [  179.987570]  [<ffffffff811f3de5>] mpage_readpages+0xf5/0x110
> > [  179.987570]  [<ffffffff811ed7a0>] ? I_BDEV+0x10/0x10
> > [  179.987570]  [<ffffffff811ed7a0>] ? I_BDEV+0x10/0x10
> > [  179.987570]  [<ffffffff81603241>] ? ftrace_call+0x5/0x2f
> > [  179.987570]  [<ffffffff81603241>] ? ftrace_call+0x5/0x2f
> > [  179.987570]  [<ffffffff811ee190>] ? blkdev_write_begin+0x30/0x30
> > [  179.987570]  [<ffffffff811ed7a0>] ? I_BDEV+0x10/0x10
> > [  179.987570]  [<ffffffff811ee1ad>] blkdev_readpages+0x1d/0x20
> > [  179.987570]  [<ffffffff81158ed4>] __do_page_cache_readahead+0x204/0x290
> > [  179.987570]  [<ffffffff81158d99>] ? __do_page_cache_readahead+0xc9/0x290
> > [  179.987570]  [<ffffffff8114b045>] ? find_get_entry+0x5/0x130
> > [  179.987570]  [<ffffffff811593cd>] force_page_cache_readahead+0x7d/0xb0
> > [  179.987570]  [<ffffffff81159443>] page_cache_sync_readahead+0x43/0x50
> > [  179.987570]  [<ffffffff8114d0e1>] generic_file_read_iter+0x451/0x650
> > [  179.987570]  [<ffffffff81603241>] ? ftrace_call+0x5/0x2f
> > [  179.987570]  [<ffffffff811ed947>] blkdev_read_iter+0x37/0x40
> > [  179.987570]  [<ffffffff811b4358>] new_sync_read+0x78/0xb0
> > [  179.987570]  [<ffffffff811b555b>] vfs_read+0xab/0x180
> > [  179.987570]  [<ffffffff811b5682>] SyS_read+0x52/0xb0
> > [  179.987570]  [<ffffffff816011d2>] system_call_fastpath+0x12/0x17
> > [  179.987570] Code: 00 4c 8b 82 f8 00 00 00 31 d2 48 d3 ee 48 8d 3c f6 48 89 c6 49 8d 3c f8 e8 dc 9f f4 ff 5d c3 48 c7 c6 88 2c a0 81 e8 1e a8 02 00 <0f> 0b 66 66 66 2e 0f 1f 84 00 00 00 00 00 e8 bb 83 4b 00 55 48
> > [  179.987570] RIP  [<ffffffff8114ae12>] unlock_page+0x82/0x90
> > [  179.987570]  RSP <ffff88001b223998>
> > [  179.987570] ---[ end trace 39c73c1d9da87ec4 ]---
> > [  180.030327] zram0: detected capacity change from 0 to 2147483648
> > [  180.033795] Adding 2097148k swap on /dev/zram0.  Priority:-1 extents:1 across:2097148k SSFS
> > [  181.978291] zram_kern_compi (2685): drop_caches: 3
> > 
> > Cc: Matthew Wilcox <willy@linux.intel.com>
> > Cc: Dave Chinner <david@fromorbit.com>
> > Cc: Karam Lee <karam.lee@lge.com>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  drivers/block/zram/zram_drv.c | 17 +++++++++++------
> >  1 file changed, 11 insertions(+), 6 deletions(-)
> > 
> > diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> > index 05e8e54551de..004d758f0c39 100644
> > --- a/drivers/block/zram/zram_drv.c
> > +++ b/drivers/block/zram/zram_drv.c
> > @@ -947,7 +947,7 @@ static void zram_slot_free_notify(struct block_device *bdev,
> >  static int zram_rw_page(struct block_device *bdev, sector_t sector,
> >  		       struct page *page, int rw)
> >  {
> > -	int offset, ret;
> > +	int offset, err;
> >  	u32 index;
> >  	struct zram *zram;
> >  	struct bio_vec bv;
> > @@ -955,13 +955,13 @@ static int zram_rw_page(struct block_device *bdev, sector_t sector,
> >  	zram = bdev->bd_disk->private_data;
> >  	if (!valid_io_request(zram, sector, PAGE_SIZE)) {
> >  		atomic64_inc(&zram->stats.invalid_io);
> > -		ret = -EINVAL;
> > +		err = -EINVAL;
> >  		goto out;
> >  	}
> >  
> >  	down_read(&zram->init_lock);
> >  	if (unlikely(!init_done(zram))) {
> > -		ret = -EIO;
> > +		err = -EIO;
> >  		goto out_unlock;
> >  	}
> >  
> > @@ -972,13 +972,18 @@ static int zram_rw_page(struct block_device *bdev, sector_t sector,
> >  	bv.bv_len = PAGE_SIZE;
> >  	bv.bv_offset = 0;
> >  
> > -	ret = zram_bvec_rw(zram, &bv, index, offset, rw);
> > +	err = zram_bvec_rw(zram, &bv, index, offset, rw);
> >  
> >  out_unlock:
> >  	up_read(&zram->init_lock);
> >  out:
> > -	page_endio(page, rw, ret);
> > -	return ret;
> > +	page_endio(page, rw, err);
> > +
> > +	/*
> > +	 * Return 0 prevents I/O fallback trial caused by rw_page fail
> > +	 * and upper layer can handle this IO error via page error.
> > +	 */
> > +	return 0;
> 
> 
> so, the patch is a one-liner. is there any reason to rename `err' to `ret'?

'ret' is not return value any more so I want to make it clear.
While I read this mail, I found to miss write-fail case.
if zram_bvec_rw returns error, we shouldn't invoke page_endio. :(
Will send a patch.

Thanks.

> 
> 	-ss
> 
> >  }
> >  
> >  static const struct block_device_operations zram_devops = {
> > -- 
> > 2.0.0
> > 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
