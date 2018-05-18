Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 34DF96B05C7
	for <linux-mm@kvack.org>; Fri, 18 May 2018 05:06:41 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id y127-v6so6361612qka.5
        for <linux-mm@kvack.org>; Fri, 18 May 2018 02:06:41 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i6-v6sor5272195qvj.65.2018.05.18.02.06.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 May 2018 02:06:39 -0700 (PDT)
Date: Fri, 18 May 2018 05:06:36 -0400
From: Kent Overstreet <kent.overstreet@gmail.com>
Subject: Re: [PATCH 00/10] Misc block layer patches for bcachefs
Message-ID: <20180518090636.GA14738@kmo-pixel>
References: <20180509013358.16399-1-kent.overstreet@gmail.com>
 <a26feed52ec6ed371b3d3b0567e31d1ff4fc31cb.camel@wdc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a26feed52ec6ed371b3d3b0567e31d1ff4fc31cb.camel@wdc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <Bart.VanAssche@wdc.com>
Cc: "mingo@kernel.org" <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "axboe@kernel.dk" <axboe@kernel.dk>

On Thu, May 17, 2018 at 08:54:57PM +0000, Bart Van Assche wrote:
> On Tue, 2018-05-08 at 21:33 -0400, Kent Overstreet wrote:
> > [ ... ]
> 
> Hello Kent,
> 
> With Jens' latest for-next branch I hit the kernel warning shown below. Can
> you have a look?

Any hints on how to reproduce it?

> Thanks,
> 
> Bart.
> 
> 
> ==================================================================
> BUG: KASAN: use-after-free in bio_advance+0x110/0x1b0
> Read of size 4 at addr ffff880156c5e6d0 by task ksoftirqd/10/72
> 
> CPU: 10 PID: 72 Comm: ksoftirqd/10 Tainted: G        W         4.17.0-rc4-dbg+ #5
> Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS 1.0.0-prebuilt.qemu-project.org 04/01/2014
> Call Trace:
> dump_stack+0x9a/0xeb
> print_address_description+0x65/0x270
> kasan_report+0x232/0x350
> bio_advance+0x110/0x1b0
> blk_update_request+0x9d/0x5a0
> scsi_end_request+0x4c/0x300 [scsi_mod]
> scsi_io_completion+0x71e/0xa40 [scsi_mod]
> __blk_mq_complete_request+0x143/0x220
> srp_recv_done+0x454/0x1100 [ib_srp]
> __ib_process_cq+0x9a/0xf0 [ib_core]
> ib_poll_handler+0x2d/0x90 [ib_core]
> irq_poll_softirq+0xe5/0x1e0
> __do_softirq+0x112/0x5f0
> run_ksoftirqd+0x29/0x50
> smpboot_thread_fn+0x30f/0x410
> kthread+0x1b2/0x1d0
> ret_from_fork+0x24/0x30
> 
> Allocated by task 1356:
> kasan_kmalloc+0xa0/0xd0
> kmem_cache_alloc+0xed/0x320
> mempool_alloc+0xc6/0x210
> bio_alloc_bioset+0x128/0x2d0
> submit_bh_wbc+0x95/0x2d0
> __block_write_full_page+0x2a6/0x5c0
> __writepage+0x37/0x80
> write_cache_pages+0x305/0x7c0
> generic_writepages+0xb9/0x110
> do_writepages+0x96/0x180
> __filemap_fdatawrite_range+0x162/0x1b0
> file_write_and_wait_range+0x4d/0xb0
> blkdev_fsync+0x3c/0x70
> do_fsync+0x33/0x60
> __x64_sys_fsync+0x18/0x20
> do_syscall_64+0x6d/0x220
> entry_SYSCALL_64_after_hwframe+0x49/0xbe
> 
> Freed by task 72:
> __kasan_slab_free+0x130/0x180
> kmem_cache_free+0xcd/0x380
> blk_update_request+0xc4/0x5a0
> blk_update_request+0xc4/0x5a0
> scsi_end_request+0x4c/0x300 [scsi_mod]
> scsi_io_completion+0x71e/0xa40 [scsi_mod]
> __blk_mq_complete_request+0x143/0x220
> srp_recv_done+0x454/0x1100 [ib_srp]
> __ib_process_cq+0x9a/0xf0 [ib_core]
> ib_poll_handler+0x2d/0x90 [ib_core]
> irq_poll_softirq+0xe5/0x1e0
> __do_softirq+0x112/0x5f0
> 
> The buggy address belongs to the object at ffff880156c5e640
> which belongs to the cache bio-0 of size 200
> The buggy address is located 144 bytes inside of
> 200-byte region [ffff880156c5e640, ffff880156c5e708)
> The buggy address belongs to the page:
> page:ffffea00055b1780 count:1 mapcount:0 mapping:0000000000000000 index:0x0 compound_mapcount: 0
> ib_srpt:srpt_zerolength_write: ib_srpt 10.196.159.179-24: queued zerolength write
> flags: 0x8000000000008100(slab|head)
> raw: 8000000000008100 0000000000000000 0000000000000000 0000000100190019
> raw: ffffea000543a800 0000000200000002 ffff88015a8f3a00 0000000000000000
> ib_srpt:srpt_zerolength_write: ib_srpt 10.196.159.179-22: queued zerolength write
> page dumped because: kasan: bad access detected
> ib_srpt:srpt_zerolength_write: ib_srpt 10.196.159.179-20: queued zerolength write
> 
> Memory state around the buggy address:
> ib_srpt:srpt_zerolength_write: ib_srpt 10.196.159.179-18: queued zerolength write
> ffff880156c5e580: 00 00 00 00 00 00 00 00 00 fc fc fc fc fc fc fc
> ib_srpt:srpt_zerolength_write_done: ib_srpt 10.196.159.179-24 wc->status 5
> ffff880156c5e600: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
> ib_srpt:srpt_zerolength_write_done: ib_srpt 10.196.159.179-22 wc->status 5
> >ffff880156c5e680: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> ib_srpt:srpt_zerolength_write_done: ib_srpt 10.196.159.179-20 wc->status 5
>                                                 ^
> ffff880156c5e700: fb fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
> ib_srpt:srpt_zerolength_write_done: ib_srpt 10.196.159.179-18 wc->status 5
> ffff880156c5e780: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> ib_srpt:srpt_release_channel_work: ib_srpt 10.196.159.179-24
> ==================================================================
> 
> (gdb) list *(bio_advance+0x110)
> 0xffffffff81450090 is in bio_advance (./include/linux/bvec.h:82).
> 77                      iter->bi_size = 0;
> 78                      return false;
> 79              }
> 80
> 81              while (bytes) {
> 82                      unsigned iter_len = bvec_iter_len(bv, *iter);
> 83                      unsigned len = min(bytes, iter_len);
> 84
> 85                      bytes -= len;
> 86                      iter->bi_size -= len;
> 
> 
> 
> 
> 
> 
