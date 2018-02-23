Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 67AAB6B0003
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 14:51:46 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id 73so4749314oth.20
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 11:51:46 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d9sor1411462otc.256.2018.02.23.11.51.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Feb 2018 11:51:44 -0800 (PST)
From: Laura Abbott <labbott@redhat.com>
Subject: Hangs in balance_dirty_pages with arm-32 LPAE + highmem
Message-ID: <b77a6596-3b35-84fe-b65b-43d2e43950b3@redhat.com>
Date: Fri, 23 Feb 2018 11:51:41 -0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, linux-block@vger.kernel.org

Hi,

The Fedora arm-32 build VMs have a somewhat long standing problem
of hanging when running mkfs.ext4 with a bunch of processes stuck
in D state. This has been seen as far back as 4.13 but is still
present on 4.14:

sysrq: SysRq : Show Blocked State                                                [255/1885]
   task                PC stack   pid father
auditd          D    0   377      1 0x00000020
[<c0955e68>] (__schedule) from [<c0956070>] (schedule+0x98/0xbc)
[<c0956070>] (schedule) from [<c09598e4>] (schedule_timeout+0x328/0x3ac)
[<c09598e4>] (schedule_timeout) from [<c09564f8>] (io_schedule_timeout+0x24/0x38)
[<c09564f8>] (io_schedule_timeout) from [<c03720bc>] (balance_dirty_pages.constprop.6+0xac8
/0xc5c)
[<c03720bc>] (balance_dirty_pages.constprop.6) from [<c0372508>] (balance_dirty_pages_ratel
imited+0x2b8/0x43c)
[<c0372508>] (balance_dirty_pages_ratelimited) from [<c03637f8>] (generic_perform_write+0x1
74/0x1a4)
[<c03637f8>] (generic_perform_write) from [<c0365e98>] (__generic_file_write_iter+0x16c/0x1
98)
[<c0365e98>] (__generic_file_write_iter) from [<c046b398>] (ext4_file_write_iter+0x314/0x41
4)
[<c046b398>] (ext4_file_write_iter) from [<c03ddd68>] (__vfs_write+0x100/0x128)
[<c03ddd68>] (__vfs_write) from [<c03ddf5c>] (vfs_write+0xc0/0x194)
[<c03ddf5c>] (vfs_write) from [<c03de12c>] (SyS_write+0x44/0x7c)
[<c03de12c>] (SyS_write) from [<c0224ef0>] (__sys_trace_return+0x0/0x10)
rs:main Q:Reg   D    0   441      1 0x00000000
[<c0955e68>] (__schedule) from [<c0956070>] (schedule+0x98/0xbc)
[<c0956070>] (schedule) from [<c09598e4>] (schedule_timeout+0x328/0x3ac)
[<c09598e4>] (schedule_timeout) from [<c09564f8>] (io_schedule_timeout+0x24/0x38)
[<c09564f8>] (io_schedule_timeout) from [<c03720bc>] (balance_dirty_pages.constprop.6+0xac8
/0xc5c)
[<c03720bc>] (balance_dirty_pages.constprop.6) from [<c0372508>] (balance_dirty_pages_ratel
imited+0x2b8/0x43c)
[<c0372508>] (balance_dirty_pages_ratelimited) from [<c03637f8>] (generic_perform_write+0x1
74/0x1a4)
[<c03637f8>] (generic_perform_write) from [<c0365e98>] (__generic_file_write_iter+0x16c/0x1
98)
[<c0365e98>] (__generic_file_write_iter) from [<c046b398>] (ext4_file_write_iter+0x314/0x41
4)
[<c046b398>] (ext4_file_write_iter) from [<c03ddd68>] (__vfs_write+0x100/0x128)
[<c03ddd68>] (__vfs_write) from [<c03ddf5c>] (vfs_write+0xc0/0x194)
[<c03ddf5c>] (vfs_write) from [<c03de12c>] (SyS_write+0x44/0x7c)
[<c03de12c>] (SyS_write) from [<c0224d40>] (ret_fast_syscall+0x0/0x4c)
ntpd            D    0  1453      1 0x00000001
[<c0955e68>] (__schedule) from [<c0956070>] (schedule+0x98/0xbc)
[<c0956070>] (schedule) from [<c09598e4>] (schedule_timeout+0x328/0x3ac)
[<c09598e4>] (schedule_timeout) from [<c09564f8>] (io_schedule_timeout+0x24/0x38)
[<c09564f8>] (io_schedule_timeout) from [<c03720bc>] (balance_dirty_pages.constprop.6+0xac8
/0xc5c)
[<c03720bc>] (balance_dirty_pages.constprop.6) from [<c0372508>] (balance_dirty_pages_ratel
imited+0x2b8/0x43c)
[<c0372508>] (balance_dirty_pages_ratelimited) from [<c03637f8>] (generic_perform_write+0x1
74/0x1a4)
[<c03637f8>] (generic_perform_write) from [<c0365e98>] (__generic_file_write_iter+0x16c/0x1
98)
[<c0365e98>] (__generic_file_write_iter) from [<c046b398>] (ext4_file_write_iter+0x314/0x41
4)
[<c046b398>] (ext4_file_write_iter) from [<c03ddd68>] (__vfs_write+0x100/0x128)
[<c03ddd68>] (__vfs_write) from [<c03ddf5c>] (vfs_write+0xc0/0x194)
[<c046b398>] (ext4_file_write_iter) from [<c03ddd68>] (__vfs_write+0x100/0x128)  [203/1885]
[<c03ddd68>] (__vfs_write) from [<c03ddf5c>] (vfs_write+0xc0/0x194)
[<c03ddf5c>] (vfs_write) from [<c03de12c>] (SyS_write+0x44/0x7c)
[<c03de12c>] (SyS_write) from [<c0224d40>] (ret_fast_syscall+0x0/0x4c)
kojid           D    0  4616      1 0x00000000
[<c0955e68>] (__schedule) from [<c0956070>] (schedule+0x98/0xbc)
[<c0956070>] (schedule) from [<c09598e4>] (schedule_timeout+0x328/0x3ac)
[<c09598e4>] (schedule_timeout) from [<c09564f8>] (io_schedule_timeout+0x24/0x38)
[<c09564f8>] (io_schedule_timeout) from [<c03720bc>] (balance_dirty_pages.constprop.6+0xac8
/0xc5c)
[<c03720bc>] (balance_dirty_pages.constprop.6) from [<c0372508>] (balance_dirty_pages_ratel
imited+0x2b8/0x43c)
[<c0372508>] (balance_dirty_pages_ratelimited) from [<c03637f8>] (generic_perform_write+0x1
74/0x1a4)
[<c03637f8>] (generic_perform_write) from [<c0365e98>] (__generic_file_write_iter+0x16c/0x1
98)
[<c0365e98>] (__generic_file_write_iter) from [<c046b398>] (ext4_file_write_iter+0x314/0x41
4)
[<c046b398>] (ext4_file_write_iter) from [<c03ddd68>] (__vfs_write+0x100/0x128)
[<c03ddd68>] (__vfs_write) from [<c03ddf5c>] (vfs_write+0xc0/0x194)
[<c03ddf5c>] (vfs_write) from [<c03de12c>] (SyS_write+0x44/0x7c)
[<c03de12c>] (SyS_write) from [<c0224d40>] (ret_fast_syscall+0x0/0x4c)
kworker/u8:0    D    0 28525      2 0x00000000
Workqueue: writeback wb_workfn (flush-7:0)
[<c0955e68>] (__schedule) from [<c0956070>] (schedule+0x98/0xbc)
[<c0956070>] (schedule) from [<c0281c34>] (io_schedule+0x1c/0x2c)
[<c0281c34>] (io_schedule) from [<c055ff2c>] (wbt_wait+0x21c/0x300)
[<c055ff2c>] (wbt_wait) from [<c053ba14>] (blk_mq_make_request+0xac/0x560)
[<c053ba14>] (blk_mq_make_request) from [<c0530034>] (generic_make_request+0xd0/0x214)
[<c0530034>] (generic_make_request) from [<c053028c>] (submit_bio+0x114/0x16c)
[<c053028c>] (submit_bio) from [<c0412b98>] (submit_bh_wbc+0x190/0x1a0)
[<c0412b98>] (submit_bh_wbc) from [<c0412e90>] (__block_write_full_page+0x2e8/0x43c)
[<c0412e90>] (__block_write_full_page) from [<c0413150>] (block_write_full_page+0x80/0xec)
[<c0413150>] (block_write_full_page) from [<c0370380>] (__writepage+0x1c/0x4c)
[<c0370380>] (__writepage) from [<c0370d30>] (write_cache_pages+0x350/0x3f0)
[<c0370d30>] (write_cache_pages) from [<c03715d8>] (generic_writepages+0x44/0x60)
[<c03715d8>] (generic_writepages) from [<c0372eb4>] (do_writepages+0x3c/0x74)
[<c0372eb4>] (do_writepages) from [<c04098a8>] (__writeback_single_inode+0xb4/0x404)
[<c04098a8>] (__writeback_single_inode) from [<c040a118>] (writeback_sb_inodes+0x258/0x438)
[<c040a118>] (writeback_sb_inodes) from [<c040a364>] (__writeback_inodes_wb+0x6c/0xa8)
[<c040a364>] (__writeback_inodes_wb) from [<c040a564>] (wb_writeback+0x1c4/0x30c)
[<c040a564>] (wb_writeback) from [<c040ae98>] (wb_workfn+0x130/0x450)
[<c040ae98>] (wb_workfn) from [<c026f488>] (process_one_work+0x254/0x42c)
[<c026f488>] (process_one_work) from [<c02705c4>] (worker_thread+0x2d0/0x450)
[<c02705c4>] (worker_thread) from [<c02750cc>] (kthread+0x13c/0x154)
[<c02750cc>] (kthread) from [<c0224e18>] (ret_from_fork+0x14/0x3c)
kworker/u8:1    D    0 16594      2 0x00000000
Workqueue: writeback wb_workfn (flush-252:0)
[<c0955e68>] (__schedule) from [<c0956070>] (schedule+0x98/0xbc)
[<c0956070>] (schedule) from [<c0281c34>] (io_schedule+0x1c/0x2c)
[<c0281c34>] (io_schedule) from [<c055ff2c>] (wbt_wait+0x21c/0x300)
[<c055ff2c>] (wbt_wait) from [<c053ba14>] (blk_mq_make_request+0xac/0x560)
[<c053ba14>] (blk_mq_make_request) from [<c0530034>] (generic_make_request+0xd0/0x214)
[<c0530034>] (generic_make_request) from [<c053028c>] (submit_bio+0x114/0x16c)
[<c053ba14>] (blk_mq_make_request) from [<c0530034>] (generic_make_request+0xd0/0[151/1885]
[<c0530034>] (generic_make_request) from [<c053028c>] (submit_bio+0x114/0x16c)
[<c053028c>] (submit_bio) from [<c0412b98>] (submit_bh_wbc+0x190/0x1a0)
[<c0412b98>] (submit_bh_wbc) from [<c0412e90>] (__block_write_full_page+0x2e8/0x43c)
[<c0412e90>] (__block_write_full_page) from [<c0413150>] (block_write_full_page+0x80/0xec)
[<c0413150>] (block_write_full_page) from [<c0370380>] (__writepage+0x1c/0x4c)
[<c0370380>] (__writepage) from [<c0370d30>] (write_cache_pages+0x350/0x3f0)
[<c0370d30>] (write_cache_pages) from [<c03715d8>] (generic_writepages+0x44/0x60)
[<c03715d8>] (generic_writepages) from [<c0372eb4>] (do_writepages+0x3c/0x74)
[<c0372eb4>] (do_writepages) from [<c04098a8>] (__writeback_single_inode+0xb4/0x404)
[<c04098a8>] (__writeback_single_inode) from [<c040a118>] (writeback_sb_inodes+0x258/0x438)
[<c040a118>] (writeback_sb_inodes) from [<c040a364>] (__writeback_inodes_wb+0x6c/0xa8)
[<c040a364>] (__writeback_inodes_wb) from [<c040a564>] (wb_writeback+0x1c4/0x30c)
[<c040a564>] (wb_writeback) from [<c040ae98>] (wb_workfn+0x130/0x450)
[<c040ae98>] (wb_workfn) from [<c026f488>] (process_one_work+0x254/0x42c)
[<c026f488>] (process_one_work) from [<c02705c4>] (worker_thread+0x2d0/0x450)
[<c02705c4>] (worker_thread) from [<c02750cc>] (kthread+0x13c/0x154)
[<c02750cc>] (kthread) from [<c0224e18>] (ret_from_fork+0x14/0x3c)
loop0           D    0  9138      2 0x00000000
[<c0955e68>] (__schedule) from [<c0956070>] (schedule+0x98/0xbc)
[<c0956070>] (schedule) from [<c09598e4>] (schedule_timeout+0x328/0x3ac)
[<c09598e4>] (schedule_timeout) from [<c09564f8>] (io_schedule_timeout+0x24/0x38)
[<c09564f8>] (io_schedule_timeout) from [<c03720bc>] (balance_dirty_pages.constprop.6+0xac8
/0xc5c)
[<c03720bc>] (balance_dirty_pages.constprop.6) from [<c0372508>] (balance_dirty_pages_ratel
imited+0x2b8/0x43c)
[<c0372508>] (balance_dirty_pages_ratelimited) from [<c03637f8>] (generic_perform_write+0x1
74/0x1a4)
[<c03637f8>] (generic_perform_write) from [<c0365e98>] (__generic_file_write_iter+0x16c/0x1
98)
[<c0365e98>] (__generic_file_write_iter) from [<c046b398>] (ext4_file_write_iter+0x314/0x41
4)
[<c046b398>] (ext4_file_write_iter) from [<c03dbccc>] (do_iter_readv_writev+0x118/0x140)
[<c03dbccc>] (do_iter_readv_writev) from [<c03dd024>] (do_iter_write+0x84/0xf8)
[<c03dd024>] (do_iter_write) from [<bf38b19c>] (lo_write_bvec+0x70/0xec [loop])
[<bf38b19c>] (lo_write_bvec [loop]) from [<bf38c04c>] (loop_queue_work+0x3b4/0x92c [loop])
[<bf38c04c>] (loop_queue_work [loop]) from [<c0275234>] (kthread_worker_fn+0x114/0x1c8)
[<c0275234>] (kthread_worker_fn) from [<c02750cc>] (kthread+0x13c/0x154)
[<c02750cc>] (kthread) from [<c0224e18>] (ret_from_fork+0x14/0x3c)
mkfs.ext4       D    0  9142   1535 0x00000000
[<c0955e68>] (__schedule) from [<c0956070>] (schedule+0x98/0xbc)
[<c0956070>] (schedule) from [<c0281c34>] (io_schedule+0x1c/0x2c)
[<c0281c34>] (io_schedule) from [<c0362080>] (__lock_page+0x10c/0x144)
[<c0362080>] (__lock_page) from [<c0370bb8>] (write_cache_pages+0x1d8/0x3f0)
[<c0370bb8>] (write_cache_pages) from [<c03715d8>] (generic_writepages+0x44/0x60)
[<c03715d8>] (generic_writepages) from [<c0372eb4>] (do_writepages+0x3c/0x74)
[<c0372eb4>] (do_writepages) from [<c0364264>] (__filemap_fdatawrite_range+0xc0/0xe0)
[<c0364264>] (__filemap_fdatawrite_range) from [<c0364454>] (file_write_and_wait_range+0x40
/0x78)
[<c0364454>] (file_write_and_wait_range) from [<c0415868>] (blkdev_fsync+0x20/0x50)
[<c0415868>] (blkdev_fsync) from [<c040e26c>] (vfs_fsync+0x28/0x30)
[<c040e26c>] (vfs_fsync) from [<c040e2a4>] (do_fsync+0x30/0x4c)
[<c040e2a4>] (do_fsync) from [<c0224d40>] (ret_fast_syscall+0x0/0x4c)
python          D    0  9167   9165 0x00000000
Sun Feb 18 18:17:58 2018] [<c0955e68>] (__schedule) from [<c0956070>] (schedule+0x98/0xbc)
[<c0956070>] (schedule) from [<c09598e4>] (schedule_timeout+0x328/0x3ac)
[<c09598e4>] (schedule_timeout) from [<c09564f8>] (io_schedule_timeout+0x24/0x38)
[<c09564f8>] (io_schedule_timeout) from [<c03720bc>] (balance_dirty_pages.constprop.6+0xac8
/0xc5c)
[<c03720bc>] (balance_dirty_pages.constprop.6) from [<c0372508>] (balance_dirty_pages_ratel
imited+0x2b8/0x43c)
[<c0372508>] (balance_dirty_pages_ratelimited) from [<c0397724>] (fault_dirty_shared_page+0
x9c/0xb4)
[<c0397724>] (fault_dirty_shared_page) from [<c0399c48>] (do_wp_page+0x628/0x688)
[<c0399c48>] (do_wp_page) from [<c039cd0c>] (handle_mm_fault+0xd5c/0xe08)
[<c039cd0c>] (handle_mm_fault) from [<c095c7d8>] (do_page_fault+0x1f0/0x360)
[<c095c7d8>] (do_page_fault) from [<c0201384>] (do_DataAbort+0x34/0xb4)
[<c0201384>] (do_DataAbort) from [<c095c19c>] (__dabt_usr+0x3c/0x40)
Exception stack(0xc69dbfb0 to 0xc69dbff8)
bfa0:                                     019fec50 00000002 cc684d00 cc684d00
bfc0: 00000001 b4214cf4 019fec50 00000002 000587b8 00000000 00000001 b4214cf0
bfe0: b4f39584 bec32990 b4eee238 b4e799a0 600f0010 ffffffff
python          D    0  9313   9304 0x00000000
[<c0955e68>] (__schedule) from [<c0956070>] (schedule+0x98/0xbc)
[<c0956070>] (schedule) from [<c09598e4>] (schedule_timeout+0x328/0x3ac)
[<c09598e4>] (schedule_timeout) from [<c09564f8>] (io_schedule_timeout+0x24/0x38)
[<c09564f8>] (io_schedule_timeout) from [<c03720bc>] (balance_dirty_pages.constprop.6+0xac8
/0xc5c)
[<c03720bc>] (balance_dirty_pages.constprop.6) from [<c0372508>] (balance_dirty_pages_ratel
imited+0x2b8/0x43c)
[<c0372508>] (balance_dirty_pages_ratelimited) from [<c03637f8>] (generic_perform_write+0x1
74/0x1a4)
[<c03637f8>] (generic_perform_write) from [<c0365e98>] (__generic_file_write_iter+0x16c/0x1
98)
[<c0365e98>] (__generic_file_write_iter) from [<c046b398>] (ext4_file_write_iter+0x314/0x41
4)
[<c046b398>] (ext4_file_write_iter) from [<c03ddd68>] (__vfs_write+0x100/0x128)
[<c03ddd68>] (__vfs_write) from [<c03ddf5c>] (vfs_write+0xc0/0x194)
[<c03ddf5c>] (vfs_write) from [<c03de12c>] (SyS_write+0x44/0x7c)
[<c03de12c>] (SyS_write) from [<c0224d40>] (ret_fast_syscall+0x0/0x4c)
python          D    0  9326   9317 0x00000000
[<c0955e68>] (__schedule) from [<c0956070>] (schedule+0x98/0xbc)
[<c0956070>] (schedule) from [<c09598e4>] (schedule_timeout+0x328/0x3ac)
[<c09598e4>] (schedule_timeout) from [<c09564f8>] (io_schedule_timeout+0x24/0x38)
[<c09564f8>] (io_schedule_timeout) from [<c03720bc>] (balance_dirty_pages.constprop.6+0xac8
/0xc5c)
[<c03720bc>] (balance_dirty_pages.constprop.6) from [<c0372508>] (balance_dirty_pages_ratel
imited+0x2b8/0x43c)
[<c0372508>] (balance_dirty_pages_ratelimited) from [<c03637f8>] (generic_perform_write+0x1
74/0x1a4)
[<c03637f8>] (generic_perform_write) from [<c0365e98>] (__generic_file_write_iter+0x16c/0x1
98)
[<c0365e98>] (__generic_file_write_iter) from [<c046b398>] (ext4_file_write_iter+0x314/0x41
4)
[<c046b398>] (ext4_file_write_iter) from [<c03ddd68>] (__vfs_write+0x100/0x128)
[<c03ddd68>] (__vfs_write) from [<c03ddf5c>] (vfs_write+0xc0/0x194)
[<c03ddf5c>] (vfs_write) from [<c03de12c>] (SyS_write+0x44/0x7c)
[<c03de12c>] (SyS_write) from [<c0224d40>] (ret_fast_syscall+0x0/0x4c)
python          D    0  9351   9342 0x00000000
[<c0955e68>] (__schedule) from [<c0956070>] (schedule+0x98/0xbc)
[<c0956070>] (schedule) from [<c09598e4>] (schedule_timeout+0x328/0x3ac)
[<c09598e4>] (schedule_timeout) from [<c09564f8>] (io_schedule_timeout+0x24/0x38)
[<c09564f8>] (io_schedule_timeout) from [<c03720bc>] (balance_dirty_pages.constprop.6+0xac8
/0xc5c)
[<c03720bc>] (balance_dirty_pages.constprop.6) from [<c0372508>] (balance_dirty_pages_ratel
imited+0x2b8/0x43c)
[<c0372508>] (balance_dirty_pages_ratelimited) from [<c03637f8>] (generic_perform_write+0x1
74/0x1a4)
[<c03637f8>] (generic_perform_write) from [<c0365e98>] (__generic_file_write_iter+0x16c/0x1
98)
[<c0365e98>] (__generic_file_write_iter) from [<c046b398>] (ext4_file_write_iter+0x314/0x41
4)
[<c046b398>] (ext4_file_write_iter) from [<c03ddd68>] (__vfs_write+0x100/0x128)
[<c03ddd68>] (__vfs_write) from [<c03ddf5c>] (vfs_write+0xc0/0x194)
[<c03ddf5c>] (vfs_write) from [<c03de12c>] (SyS_write+0x44/0x7c)
[<c03de12c>] (SyS_write) from [<c0224d40>] (ret_fast_syscall+0x0/0x4c)
python          D    0  9361   9352 0x00000000
[<c0955e68>] (__schedule) from [<c0956070>] (schedule+0x98/0xbc)
[<c0956070>] (schedule) from [<c09598e4>] (schedule_timeout+0x328/0x3ac)
[<c09598e4>] (schedule_timeout) from [<c09564f8>] (io_schedule_timeout+0x24/0x38)
[<c09564f8>] (io_schedule_timeout) from [<c03720bc>] (balance_dirty_pages.constprop.6+0xac8
/0xc5c)
[<c03720bc>] (balance_dirty_pages.constprop.6) from [<c0372508>] (balance_dirty_pages_ratel
imited+0x2b8/0x43c)
[<c0372508>] (balance_dirty_pages_ratelimited) from [<c03637f8>] (generic_perform_write+0x1
74/0x1a4)
[<c03637f8>] (generic_perform_write) from [<c0365e98>] (__generic_file_write_iter+0x16c/0x1
98)
[<c0365e98>] (__generic_file_write_iter) from [<c046b398>] (ext4_file_write_iter+0x314/0x41
4)
[<c046b398>] (ext4_file_write_iter) from [<c03ddd68>] (__vfs_write+0x100/0x128)
[<c03ddd68>] (__vfs_write) from [<c03ddf5c>] (vfs_write+0xc0/0x194)
[<c03ddf5c>] (vfs_write) from [<c03de12c>] (SyS_write+0x44/0x7c)
[<c03de12c>] (SyS_write) from [<c0224d40>] (ret_fast_syscall+0x0/0x4c)
python          D    0  9374   9365 0x00000000
[<c0955e68>] (__schedule) from [<c0956070>] (schedule+0x98/0xbc)
[<c0956070>] (schedule) from [<c09598e4>] (schedule_timeout+0x328/0x3ac)
[<c09598e4>] (schedule_timeout) from [<c09564f8>] (io_schedule_timeout+0x24/0x38)
[<c09564f8>] (io_schedule_timeout) from [<c03720bc>] (balance_dirty_pages.constprop.6+0xac8
/0xc5c)
[<c03720bc>] (balance_dirty_pages.constprop.6) from [<c0372508>] (balance_dirty_pages_ratel
imited+0x2b8/0x43c)
[<c0372508>] (balance_dirty_pages_ratelimited) from [<c03637f8>] (generic_perform_write+0x1
74/0x1a4)
[<c03637f8>] (generic_perform_write) from [<c0365e98>] (__generic_file_write_iter+0x16c/0x1
98)
[<c0365e98>] (__generic_file_write_iter) from [<c046b398>] (ext4_file_write_iter+0x314/0x41
4)
[<c046b398>] (ext4_file_write_iter) from [<c03ddd68>] (__vfs_write+0x100/0x128)
[<c03ddd68>] (__vfs_write) from [<c03ddf5c>] (vfs_write+0xc0/0x194)
[<c03ddf5c>] (vfs_write) from [<c03de12c>] (SyS_write+0x44/0x7c)
[<c03de12c>] (SyS_write) from [<c0224d40>] (ret_fast_syscall+0x0/0x4c)
python          D    0  9385   9376 0x00000000
[<c0955e68>] (__schedule) from [<c0956070>] (schedule+0x98/0xbc)
[<c0956070>] (schedule) from [<c09598e4>] (schedule_timeout+0x328/0x3ac)
[<c09598e4>] (schedule_timeout) from [<c09564f8>] (io_schedule_timeout+0x24/0x38)
[<c09564f8>] (io_schedule_timeout) from [<c03720bc>] (balance_dirty_pages.constprop.6+0xac8
/0xc5c)
[<c03720bc>] (balance_dirty_pages.constprop.6) from [<c0372508>] (balance_dirty_pages_ratel
imited+0x2b8/0x43c)
[<c0372508>] (balance_dirty_pages_ratelimited) from [<c03637f8>] (generic_perform_write+0x1
74/0x1a4)
[<c03637f8>] (generic_perform_write) from [<c0365e98>] (__generic_file_write_iter+0x16c/0x1
98)
[<c0365e98>] (__generic_file_write_iter) from [<c046b398>] (ext4_file_write_iter+0x314/0x41
4)
[<c046b398>] (ext4_file_write_iter) from [<c03ddd68>] (__vfs_write+0x100/0x128)
[<c03ddd68>] (__vfs_write) from [<c03ddf5c>] (vfs_write+0xc0/0x194)
[<c03ddf5c>] (vfs_write) from [<c03de12c>] (SyS_write+0x44/0x7c)
[<c03de12c>] (SyS_write) from [<c0224d40>] (ret_fast_syscall+0x0/0x4c)
systemd-journal D    0  9678      1 0x00000080
[<c0955e68>] (__schedule) from [<c0956070>] (schedule+0x98/0xbc)
[<c0956070>] (schedule) from [<c09598e4>] (schedule_timeout+0x328/0x3ac)
[<c09598e4>] (schedule_timeout) from [<c09564f8>] (io_schedule_timeout+0x24/0x38)
[<c09564f8>] (io_schedule_timeout) from [<c03720bc>] (balance_dirty_pages.constprop.6+0xac8
/0xc5c)
[<c03720bc>] (balance_dirty_pages.constprop.6) from [<c0372508>] (balance_dirty_pages_ratel
imited+0x2b8/0x43c)
[<c0372508>] (balance_dirty_pages_ratelimited) from [<c0397724>] (fault_dirty_shared_page+0
x9c/0xb4)
[<c0397724>] (fault_dirty_shared_page) from [<c039cc34>] (handle_mm_fault+0xc84/0xe08)
[<c039cc34>] (handle_mm_fault) from [<c095c7d8>] (do_page_fault+0x1f0/0x360)
[<c095c7d8>] (do_page_fault) from [<c0201384>] (do_DataAbort+0x34/0xb4)
[<c0201384>] (do_DataAbort) from [<c095c19c>] (__dabt_usr+0x3c/0x40)
Exception stack(0xc40d9fb0 to 0xc40d9ff8)
9fa0:                                     b5e605e0 00000000 001c2b28 b5e64000
9fc0: 01b60ff0 00000000 be94e444 be94e448 001c6550 00000000 be94e660 be94e450
9fe0: 00000000 be94e400 b6cfffcc b6e94a50 20000010 ffffffff

This looks like everything is blocked on the writeback completing but
the writeback has been throttled. According to the infra team, this problem
is _not_ seen without LPAE (i.e. only 4G of RAM). I did see
https://patchwork.kernel.org/patch/10201593/ but that doesn't seem to
quite match since this seems to be completely stuck. Any suggestions to
narrow the problem down?

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
