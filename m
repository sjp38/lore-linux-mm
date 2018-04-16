Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4685E6B0266
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:01:42 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id k3so7772650pff.23
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 09:01:42 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id p21-v6si3580901plo.199.2018.04.16.09.01.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 09:01:39 -0700 (PDT)
Date: Mon, 16 Apr 2018 10:01:33 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v11 00/63] Convert page cache to XArray
Message-ID: <20180416160133.GA12434@linux.intel.com>
References: <20180414141316.7167-1-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180414141316.7167-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

On Sat, Apr 14, 2018 at 07:12:13AM -0700, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> This conversion keeps the radix tree and XArray data structures in sync
> at all times.  That allows us to convert the page cache one function at
> a time and should allow for easier bisection.  Other than renaming some
> elements of the structures, the data structures are fundamentally
> unchanged; a radix tree walk and an XArray walk will touch the same
> number of cachelines.  I have changes planned to the XArray data
> structure, but those will happen in future patches.

I've hit a few failures when throwing this into my test setup.  The first two
seem like similar bugs hit in two different ways, the third seems unique.
I've verified that these don't seem to happen with the next-20180413 baseline.

1) Just run some parted commands in a loop:

# while true; do
> parted -s /dev/pmem0 mktable msdos
> parted -s -a optimal /dev/pmem0 mkpart Primary 2MiB 12GiB
> parted -s -a optimal /dev/pmem0 mkpart Primary 12GiB 16382MiB
> done

Within a few seconds I hit:

page:ffffea0004293040 count:0 mapcount:0 mapping:0000000000000000 index:0x0
flags: 0x2fffc000000001(locked)
raw: 002fffc000000001 0000000000000000 0000000000000000 00000000ffffffff
raw: dead000000000100 dead000000000200 0000000000000000 0000000000000000
page dumped because: VM_BUG_ON_PAGE(page_ref_count(page) <= 0)
------------[ cut here ]------------
kernel BUG at ./include/linux/mm.h:853!
invalid opcode: 0000 [#1] PREEMPT SMP PTI
Modules linked in: dax_pmem device_dax nd_pmem nd_btt nfit libnvdimm
CPU: 10 PID: 1539 Comm: systemd-udevd Not tainted 4.16.0-next-20180413-00063-gbbcfa4572878 #2
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-2.fc27 04/01/2014
RIP: 0010:__add_to_page_cache_locked+0x34b/0x400
RSP: 0018:ffffc90003427a58 EFLAGS: 00010246
RAX: 000000000000003e RBX: ffffea0004293040 RCX: 0000000000000001
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 00000000ffffffff
RBP: ffffc90003427ac8 R08: 0000001ff3fd4371 R09: 0000000000000000
R10: 0000000000000001 R11: 0000000000000000 R12: ffff88010cd82210
R13: 0000000000000000 R14: 0000000000000000 R15: ffffc90003427ad8
FS:  00007ff6e400c1c0(0000) GS:ffff880115800000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000055af28d0e390 CR3: 000000010a64e000 CR4: 00000000000006e0
Call Trace:
 ? memcg_drain_all_list_lrus+0x260/0x260
 add_to_page_cache_lru+0x4f/0xe0
 mpage_readpages+0xde/0x1d0
 ? check_disk_change+0x70/0x70
 ? xa_load+0xbe/0x150
 blkdev_readpages+0x1d/0x20
 __do_page_cache_readahead+0x203/0x2f0
 force_page_cache_readahead+0xb8/0x110
 ? force_page_cache_readahead+0xb8/0x110
 page_cache_sync_readahead+0x43/0x50
 generic_file_read_iter+0x842/0xb70
 blkdev_read_iter+0x35/0x40
 __vfs_read+0xfe/0x170
 vfs_read+0xa3/0x150
 ksys_read+0x58/0xc0
 __x64_sys_read+0x1a/0x20
 do_syscall_64+0x65/0x220
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x7ff6e3bf2d31
RSP: 002b:00007ffc54c38a78 EFLAGS: 00000246 ORIG_RAX: 0000000000000000
RAX: ffffffffffffffda RBX: 000055af28cdb7c0 RCX: 00007ff6e3bf2d31
RDX: 0000000000040000 RSI: 000055af28de66d8 RDI: 000000000000000f
RBP: 0000000000000000 R08: 000055af28de66b0 R09: 00007ff6e3bdd090
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000040000
R13: 000055af28de66b0 R14: 000055af28cdb810 R15: 000055af28de66c8
Code: 88 fb 55 82 48 89 df e8 64 42 04 00 0f 0b 48 c7 c6 a8 fc 55 82 48 89 df e8 53 42 04 00 0f 0b 48 c7 c6 18 b5 52 82 e8 45 42 04 00 <0f> 0b 48 c1 f8 02 85 c0 0f 84 59 fe ff ff 45 85 ed 48 c7 43 08
RIP: __add_to_page_cache_locked+0x34b/0x400 RSP: ffffc90003427a58
---[ end trace 0a2ff3a36c6cabde ]---

2) xfs + DAX + generic/095

A spew of this new message:

Page cache invalidation failure on direct I/O.  Possible data corruption due to collision with buffered I/O!

Then a bug similar to the one hit with parted:

BUG: Bad page state in process fio  pfn:11e38c
page:ffffea000478e300 count:0 mapcount:0 mapping:0000000000000000 index:0x60
page:ffffea000478e300 count:0 mapcount:0 mapping:0000000000000000 index:0x60
flags: 0x3fffc000010068(uptodate|lru|active|mappedtodisk)
raw: 003fffc000010068 0000000000000000 0000000000000060 00000000ffffffff
raw: ffffea0004ed6220 ffff88011a04d830 0000000000000000 0000000000000000
page dumped because: VM_BUG_ON_PAGE(page_ref_count(page) == 0)
------------[ cut here ]------------
kernel BUG at ./include/linux/mm.h:492!
invalid opcode: 0000 [#1] PREEMPT SMP PTI
Modules linked in: nd_pmem nd_btt dax_pmem device_dax nfit libnvdimm
CPU: 5 PID: 599 Comm: systemd-journal Tainted: G        W         4.16.0-next-20180413-00063-gbbcfa4572878 #2
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-2.fc27 04/01/2014
RIP: 0010:release_pages+0x30e/0x3f0
RSP: 0018:ffffc90001223a68 EFLAGS: 00010046
RAX: 000000000000003e RBX: ffffea000478e300 RCX: 0000000000000003
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 00000000ffffffff
RBP: ffffc90001223ae8 R08: 0000000000000000 R09: 0000000000000001
R10: ffffffffffffffff R11: 0000000000000000 R12: ffff88013ffe6000
R13: 0000000000000001 R14: ffff880114fdf058 R15: ffffffff82a1a238
FS:  00007f2765945940(0000) GS:ffff880114e00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f2760933010 CR3: 000000010d1b6000 CR4: 00000000000006e0
Call Trace:
 pagevec_lru_move_fn+0xc5/0xe0
 ? get_kernel_page+0x60/0x60
 lru_add_drain_cpu+0x100/0x130
 lru_add_drain+0x1f/0x40
 __pagevec_release+0x18/0x30
 write_cache_pages+0x442/0x600
 ? xfs_vm_readpage+0x150/0x150
 ? lock_acquire+0xa3/0x210
 ? xfs_vm_writepages+0x48/0xa0
 xfs_vm_writepages+0x6b/0xa0
 do_writepages+0x4b/0xf0
 __filemap_fdatawrite_range+0xc1/0x100
 ? __filemap_fdatawrite_range+0xc1/0x100
 file_write_and_wait_range+0x5a/0xb0
 xfs_file_fsync+0x7c/0x310
 vfs_fsync_range+0x48/0x80
 do_fsync+0x3d/0x70
 __x64_sys_fsync+0x14/0x20
 do_syscall_64+0x65/0x220
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x7f276552e4cc
RSP: 002b:00007ffd018b1e20 EFLAGS: 00000293 ORIG_RAX: 000000000000004a
RAX: ffffffffffffffda RBX: 00005576c169b030 RCX: 00007f276552e4cc
RDX: 0000000000000000 RSI: 00005576c169b220 RDI: 0000000000000017
RBP: 0000000000000001 R08: 00000000000000ca R09: 00007f275f9329d0
R10: 0000000000000000 R11: 0000000000000293 R12: 00007ffd018b1f80
R13: 00007ffd018b1f78 R14: 00005576c169b030 R15: 00007ffd018b20e8
Code: 1e 45 31 e4 eb cb 48 8b 75 a8 49 8d bc 24 80 66 01 00 45 31 e4 e8 43 37 a3 00 eb b5 48 c7 c6 50 aa 52 82 48 89 df e8 a2 b8 02 00 <0f> 0b 4d 85 e4 74 11 48 8b 75 a8 49 8d bc 24 80 66 01 00 e8 1a
RIP: release_pages+0x30e/0x3f0 RSP: ffffc90001223a68
---[ end trace e0459ef6b39fc1a5 ]---

3) xfs + generic/270 without DAX

This seems to hit a deadlock:

generic/270	run fstests generic/270 at 2018-04-16 09:23:39
XFS (pmem0p2): Mounting V5 Filesystem
XFS (pmem0p2): Ending clean mount
XFS (pmem0p2): Quotacheck needed: Please wait.
XFS (pmem0p2): Quotacheck: Done.
INFO: rcu_preempt detected stalls on CPUs/tasks:
	Tasks blocked on level-0 rcu_node (CPUs 0-11): P15438
	(detected by 9, t=65002 jiffies, g=315489, c=315488, q=363)
270             R  running task        0 15438   1007 0x00000000
Call Trace:
 __schedule+0x2b4/0xab0
 ? trace_hardirqs_on_thunk+0x1a/0x1c
 trace_hardirqs_on_thunk+0x1a/0x1c
 ? retint_kernel+0x2d/0x2d
 ? xas_descend+0x3a/0x160
 ? xas_load+0x53/0x100
 ? xas_find+0x19e/0x230
 ? find_get_entries+0x1cc/0x2d0
 ? pagevec_lookup_entries+0x1e/0x30
 ? invalidate_mapping_pages+0x8d/0x360
 ? trace_hardirqs_on_thunk+0x1a/0x1c
 ? lock_acquire+0xa3/0x210
 ? drop_pagecache_sb+0xa3/0xf0
 ? drop_pagecache_sb+0x6e/0xf0
 ? do_coredump+0x1030/0x1030
 ? iterate_supers+0x96/0x100
 ? drop_caches_sysctl_handler+0x6e/0xb0
 ? proc_sys_call_handler+0x101/0x120
 ? proc_sys_write+0x14/0x20
 ? __vfs_write+0x3a/0x180
 ? rcu_sync_lockdep_assert+0x12/0x60
 ? __sb_start_write+0x184/0x200
 ? vfs_write+0xc6/0x1c0
 ? ksys_write+0x58/0xc0
 ? __x64_sys_write+0x1a/0x20
 ? do_syscall_64+0x65/0x220
 ? entry_SYSCALL_64_after_hwframe+0x49/0xbe
270             R  running task        0 15438   1007 0x00000000
Call Trace:
 __schedule+0x2b4/0xab0
 ? trace_hardirqs_on_thunk+0x1a/0x1c
 ? trace_hardirqs_on_thunk+0x1a/0x1c
 ? trace_hardirqs_on_thunk+0x1a/0x1c
 ? retint_kernel+0x2d/0x2d
 ? xas_descend+0x35/0x160
 ? xas_descend+0x3a/0x160
 ? xas_load+0x53/0x100
 ? xas_find+0x19e/0x230
 ? find_get_entries+0x1cc/0x2d0
 ? pagevec_lookup_entries+0x1e/0x30
 ? invalidate_mapping_pages+0x8d/0x360
 ? trace_hardirqs_on_thunk+0x1a/0x1c
 ? lock_acquire+0xa3/0x210
 ? drop_pagecache_sb+0xa3/0xf0
 ? drop_pagecache_sb+0x6e/0xf0
 ? do_coredump+0x1030/0x1030
 ? iterate_supers+0x96/0x100
 ? drop_caches_sysctl_handler+0x6e/0xb0
 ? proc_sys_call_handler+0x101/0x120
 ? proc_sys_write+0x14/0x20
 ? __vfs_write+0x3a/0x180
 ? rcu_sync_lockdep_assert+0x12/0x60
 ? __sb_start_write+0x184/0x200
 ? vfs_write+0xc6/0x1c0
 ? ksys_write+0x58/0xc0
 ? __x64_sys_write+0x1a/0x20
 ? do_syscall_64+0x65/0x220
 ? entry_SYSCALL_64_after_hwframe+0x49/0xbe


# echo w > /proc/sysrq-trigger   # shows the following blocked task
sysrq: SysRq : Show Blocked State
  task                        PC stack   pid father
kworker/9:3     D    0 15778      2 0x80000000
Workqueue: events key_garbage_collector
Call Trace:
 __schedule+0x2ac/0xab0
 ? wait_for_completion+0x109/0x1a0
 schedule+0x36/0x90
 schedule_timeout+0x251/0x5c0
 ? lock_acquire+0xa3/0x210
 ? wait_for_completion+0x47/0x1a0
 ? wait_for_completion+0x109/0x1a0
 wait_for_completion+0x131/0x1a0
 ? wake_up_q+0x80/0x80
 __wait_rcu_gp+0x144/0x180
 synchronize_rcu.part.59+0x41/0x60
 ? kfree_call_rcu+0x30/0x30
 ? __bpf_trace_rcu_utilization+0x10/0x10
 synchronize_rcu+0x2c/0xa0
 key_garbage_collector+0x16a/0x410
 process_one_work+0x217/0x670
 worker_thread+0x3d/0x3b0
 kthread+0x12f/0x150
 ? process_one_work+0x670/0x670
 ? kthread_create_worker_on_cpu+0x70/0x70
 ret_from_fork+0x3a/0x50
