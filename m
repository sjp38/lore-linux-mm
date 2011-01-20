Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3FAF08D003A
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 03:55:50 -0500 (EST)
Date: Thu, 20 Jan 2011 03:55:48 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1150342867.83404.1295513748640.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <2056664954.83361.1295513496286.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Subject: kswapd hung tasks in 2.6.38-rc1
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

When running LTP oom01 [1] testing, the allocation process stopped
processing right after starting to swap.

# free -m
             total       used       free     shared    buffers     cached
Mem:         64307      64059        248          0          4         61
-/+ buffers/cache:      63993        314
Swap:        66139        754      65385

# ./oom01
oom01       0  TINFO  :  start testing overcommit_memory=2.
oom01       0  TINFO  :  expected victim is 7276.
oom01       0  TINFO  :  allocating 3221225472 bytes.
oom01       0  TINFO  :  allocating 3221225472 bytes.
oom01       0  TINFO  :  allocating 3221225472 bytes.
oom01       0  TINFO  :  allocating 3221225472 bytes.
oom01       0  TINFO  :  allocating 3221225472 bytes.
oom01       0  TINFO  :  allocating 3221225472 bytes.
oom01       0  TINFO  :  allocating 3221225472 bytes.
oom01       0  TINFO  :  allocating 3221225472 bytes.
oom01       0  TINFO  :  allocating 3221225472 bytes.
oom01       0  TINFO  :  allocating 3221225472 bytes.
oom01       0  TINFO  :  allocating 3221225472 bytes.
oom01       0  TINFO  :  allocating 3221225472 bytes.
oom01       0  TINFO  :  allocating 3221225472 bytes.
oom01       0  TINFO  :  allocating 3221225472 bytes.
oom01       0  TINFO  :  allocating 3221225472 bytes.
oom01       0  TINFO  :  allocating 3221225472 bytes.
oom01       0  TINFO  :  allocating 3221225472 bytes.
oom01       0  TINFO  :  allocating 3221225472 bytes.
oom01       0  TINFO  :  allocating 3221225472 bytes.
oom01       0  TINFO  :  allocating 3221225472 bytes.
oom01       0  TINFO  :  allocating 3221225472 bytes.
<hung...>

INFO: task kswapd0:274 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
kswapd0         D ffff88045dd07000     0   274      2 0x00000000
 ffff88045dd0d810 0000000000000046 0000000000000000 ffff88002e366e40
 0000000000014d40 ffff88045dd06a70 ffff88045dd07000 ffff88045dd0dfd8
 ffff88045dd07008 0000000000014d40 ffff88045dd0c010 0000000000014d40
Call Trace:
 [<ffffffff814ae420>] io_schedule+0x70/0xc0
 [<ffffffff8120f285>] get_request_wait+0xc5/0x190
 [<ffffffff810836e0>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff81207db7>] ? elv_merge+0x1d7/0x210
 [<ffffffff8120f3bb>] __make_request+0x6b/0x4c0
 [<ffffffff8120d28a>] generic_make_request+0x2ea/0x5d0
 [<ffffffff810423a6>] ? native_flush_tlb_others+0x76/0x90
 [<ffffffff8120d5f6>] submit_bio+0x86/0x110
 [<ffffffff811040b6>] ? test_set_page_writeback+0x106/0x190
 [<ffffffff8112d0d3>] swap_writepage+0x83/0xd0
 [<ffffffff81108f7e>] pageout+0x12e/0x310
 [<ffffffff8110957a>] shrink_page_list+0x41a/0x5a0
 [<ffffffff81109dc2>] shrink_inactive_list+0x172/0x460
 [<ffffffff81102cfa>] ? determine_dirtyable_memory+0x1a/0x30
 [<ffffffff8110a76b>] shrink_zone+0x36b/0x520
 [<ffffffff810fe805>] ? zone_watermark_ok_safe+0xb5/0xd0
 [<ffffffff8110bee9>] kswapd+0x969/0xc20
 [<ffffffff8110b580>] ? kswapd+0x0/0xc20
 [<ffffffff81083046>] kthread+0x96/0xa0
 [<ffffffff8100cdc4>] kernel_thread_helper+0x4/0x10
 [<ffffffff81082fb0>] ? kthread+0x0/0xa0
 [<ffffffff8100cdc0>] ? kernel_thread_helper+0x0/0x10
INFO: task kswapd2:276 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
kswapd2         D ffff88045dd13a70     0   276      2 0x00000000
 ffff88045dd15810 0000000000000046 0000000000000000 ffff880c5fa63240
 0000000000014d40 ffff88045dd134e0 ffff88045dd13a70 ffff88045dd15fd8
 ffff88045dd13a78 0000000000014d40 ffff88045dd14010 0000000000014d40
Call Trace:
 [<ffffffff814ae420>] io_schedule+0x70/0xc0
 [<ffffffff8120f285>] get_request_wait+0xc5/0x190
 [<ffffffff810836e0>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff81207db7>] ? elv_merge+0x1d7/0x210
 [<ffffffff8120f3bb>] __make_request+0x6b/0x4c0
 [<ffffffff8120d28a>] generic_make_request+0x2ea/0x5d0
 [<ffffffff810423a6>] ? native_flush_tlb_others+0x76/0x90
 [<ffffffff8120d5f6>] submit_bio+0x86/0x110
 [<ffffffff811040b6>] ? test_set_page_writeback+0x106/0x190
 [<ffffffff8112d0d3>] swap_writepage+0x83/0xd0
 [<ffffffff81108f7e>] pageout+0x12e/0x310
 [<ffffffff8110957a>] shrink_page_list+0x41a/0x5a0
 [<ffffffff81109dc2>] shrink_inactive_list+0x172/0x460
 [<ffffffff81071cda>] ? del_timer_sync+0x3a/0x60
 [<ffffffff8110a76b>] shrink_zone+0x36b/0x520
 [<ffffffff810fe805>] ? zone_watermark_ok_safe+0xb5/0xd0
 [<ffffffff8110bee9>] kswapd+0x969/0xc20
 [<ffffffff8110b580>] ? kswapd+0x0/0xc20
 [<ffffffff81083046>] kthread+0x96/0xa0
 [<ffffffff8100cdc4>] kernel_thread_helper+0x4/0x10
 [<ffffffff81082fb0>] ? kthread+0x0/0xa0
 [<ffffffff8100cdc0>] ? kernel_thread_helper+0x0/0x10
INFO: task kswapd3:277 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
kswapd3         D ffff88045dd13040     0   277      2 0x00000000
 ffff88045dd19810 0000000000000046 0000000000000000 ffff880857ed9d40
 0000000000014d40 ffff88045dd12ab0 ffff88045dd13040 ffff88045dd19fd8
 ffff88045dd13048 0000000000014d40 ffff88045dd18010 0000000000014d40
Call Trace:
 [<ffffffff814ae420>] io_schedule+0x70/0xc0
 [<ffffffff8120f285>] get_request_wait+0xc5/0x190
 [<ffffffff810836e0>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff81207c27>] ? elv_merge+0x47/0x210
 [<ffffffff8120f3bb>] __make_request+0x6b/0x4c0
 [<ffffffff8120d28a>] generic_make_request+0x2ea/0x5d0
 [<ffffffff810423a6>] ? native_flush_tlb_others+0x76/0x90
 [<ffffffff8120d5f6>] submit_bio+0x86/0x110
 [<ffffffff811040b6>] ? test_set_page_writeback+0x106/0x190
 [<ffffffff8112d0d3>] swap_writepage+0x83/0xd0
 [<ffffffff81108f7e>] pageout+0x12e/0x310
 [<ffffffff8110957a>] shrink_page_list+0x41a/0x5a0
 [<ffffffff81109dc2>] shrink_inactive_list+0x172/0x460
 [<ffffffff81071cda>] ? del_timer_sync+0x3a/0x60
 [<ffffffff8110a76b>] shrink_zone+0x36b/0x520
 [<ffffffff810fe805>] ? zone_watermark_ok_safe+0xb5/0xd0
 [<ffffffff8110bee9>] kswapd+0x969/0xc20
 [<ffffffff8110b580>] ? kswapd+0x0/0xc20
 [<ffffffff81083046>] kthread+0x96/0xa0
 [<ffffffff8100cdc4>] kernel_thread_helper+0x4/0x10
 [<ffffffff81082fb0>] ? kthread+0x0/0xa0
 [<ffffffff8100cdc0>] ? kernel_thread_helper+0x0/0x10
INFO: task jbd2/dm-0-8:1002 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
jbd2/dm-0-8     D ffff88045d33d080     0  1002      2 0x00000000
 ffff88045d53bc20 0000000000000046 ffff88085f044900 ffff88085f0da4f8
 0000000000014d40 ffff88045d33caf0 ffff88045d33d080 ffff88045d53bfd8
 ffff88045d33d088 0000000000014d40 ffff88045d53a010 0000000000014d40
Call Trace:
 [<ffffffff81180990>] ? sync_buffer+0x0/0x50
 [<ffffffff814ae420>] io_schedule+0x70/0xc0
 [<ffffffff811809d0>] sync_buffer+0x40/0x50
 [<ffffffff814aecdf>] __wait_on_bit+0x5f/0x90
 [<ffffffff81180990>] ? sync_buffer+0x0/0x50
 [<ffffffff814aed88>] out_of_line_wait_on_bit+0x78/0x90
 [<ffffffff81083720>] ? wake_bit_function+0x0/0x50
 [<ffffffff8118098e>] __wait_on_buffer+0x2e/0x30
 [<ffffffffa0082fd8>] jbd2_journal_commit_transaction+0x8e8/0x13d0 [jbd2]
 [<ffffffff81071c41>] ? try_to_del_timer_sync+0x81/0xe0
 [<ffffffffa00882b8>] kjournald2+0xb8/0x220 [jbd2]
 [<ffffffff810836e0>] ? autoremove_wake_function+0x0/0x40
 [<ffffffffa0088200>] ? kjournald2+0x0/0x220 [jbd2]
 [<ffffffff81083046>] kthread+0x96/0xa0
 [<ffffffff8100cdc4>] kernel_thread_helper+0x4/0x10
 [<ffffffff81082fb0>] ? kthread+0x0/0xa0
 [<ffffffff8100cdc0>] ? kernel_thread_helper+0x0/0x10
INFO: task flush-253:0:2030 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
flush-253:0     D ffff88045d2a0610     0  2030      2 0x00000000
 ffff88045e5ab4f0 0000000000000046 ffff88085f044900 ffff88085f0da4f8
 0000000000014d40 ffff88045d2a0080 ffff88045d2a0610 ffff88045e5abfd8
 ffff88045d2a0618 0000000000014d40 ffff88045e5aa010 0000000000014d40
Call Trace:
 [<ffffffff81180990>] ? sync_buffer+0x0/0x50
 [<ffffffff814ae420>] io_schedule+0x70/0xc0
 [<ffffffff811809d0>] sync_buffer+0x40/0x50
 [<ffffffff814aecdf>] __wait_on_bit+0x5f/0x90
 [<ffffffff81180990>] ? sync_buffer+0x0/0x50
 [<ffffffff814aed88>] out_of_line_wait_on_bit+0x78/0x90
 [<ffffffff81083720>] ? wake_bit_function+0x0/0x50
 [<ffffffff8118098e>] __wait_on_buffer+0x2e/0x30
 [<ffffffffa00d9275>] ext4_mb_init_cache+0x345/0x9f0 [ext4]
 [<ffffffffa00d9b28>] ext4_mb_init_group+0x208/0x390 [ext4]
 [<ffffffffa00d9d7e>] ext4_mb_good_group+0xce/0x110 [ext4]
 [<ffffffffa00dd5ab>] ext4_mb_regular_allocator+0x19b/0x410 [ext4]
 [<ffffffffa00ddbc5>] ext4_mb_new_blocks+0x3a5/0x510 [ext4]
 [<ffffffffa00d020b>] ? ext4_ext_find_extent+0x2bb/0x320 [ext4]
 [<ffffffffa00d2a1e>] ext4_ext_map_blocks+0x58e/0x1f40 [ext4]
 [<ffffffff8113edf6>] ? transfer_objects+0x56/0x80
 [<ffffffff81104a25>] ? pagevec_lookup_tag+0x25/0x40
 [<ffffffffa00b0ec4>] ext4_map_blocks+0xf4/0x210 [ext4]
 [<ffffffffa00b2379>] mpage_da_map_and_submit+0xb9/0x450 [ext4]
 [<ffffffffa0081393>] ? jbd2_journal_start+0x13/0x20 [jbd2]
 [<ffffffffa00c6c70>] ? ext4_journal_start_sb+0xf0/0x130 [ext4]
 [<ffffffffa00b2fe9>] ext4_da_writepages+0x349/0x680 [ext4]
 [<ffffffff811026b0>] ? __writepage+0x0/0x40
 [<ffffffff81103c01>] do_writepages+0x21/0x40
 [<ffffffff81178238>] writeback_single_inode+0x98/0x240
 [<ffffffff8117887e>] writeback_sb_inodes+0xce/0x170
 [<ffffffff81179289>] writeback_inodes_wb+0x99/0x160
 [<ffffffff81179660>] wb_writeback+0x310/0x440
 [<ffffffff810710fc>] ? lock_timer_base+0x3c/0x70
 [<ffffffff811799ef>] wb_do_writeback+0x25f/0x270
 [<ffffffff81179aa2>] bdi_writeback_thread+0xa2/0x280
 [<ffffffff81179a00>] ? bdi_writeback_thread+0x0/0x280
 [<ffffffff81179a00>] ? bdi_writeback_thread+0x0/0x280
 [<ffffffff81083046>] kthread+0x96/0xa0
 [<ffffffff8100cdc4>] kernel_thread_helper+0x4/0x10
 [<ffffffff81082fb0>] ? kthread+0x0/0xa0
 [<ffffffff8100cdc0>] ? kernel_thread_helper+0x0/0x10
INFO: task rsyslogd:3246 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
rsyslogd        D ffff880c5e992610     0  3246      1 0x00000080
 ffff880c5cdbda28 0000000000000082 00000037ffffffc8 ffff88107ffd9c00
 0000000000014d40 ffff880c5e992080 ffff880c5e992610 ffff880c5cdbdfd8
 ffff880c5e992618 0000000000014d40 ffff880c5cdbc010 0000000000014d40
Call Trace:
 [<ffffffff810f9570>] ? sync_page+0x0/0x50
 [<ffffffff814ae420>] io_schedule+0x70/0xc0
 [<ffffffff810f95b0>] sync_page+0x40/0x50
 [<ffffffff814aecdf>] __wait_on_bit+0x5f/0x90
 [<ffffffff8112d3bf>] ? read_swap_cache_async+0x4f/0x140
 [<ffffffff810f9773>] wait_on_page_bit+0x73/0x80
 [<ffffffff81083720>] ? wake_bit_function+0x0/0x50
 [<ffffffff810f981a>] __lock_page_or_retry+0x3a/0x60
 [<ffffffff8111f433>] handle_pte_fault+0xac3/0xb20
 [<ffffffff8111f641>] handle_mm_fault+0x1b1/0x320
 [<ffffffff81058c5a>] ? load_balance+0x10a/0x880
 [<ffffffff814b3ee5>] do_page_fault+0x135/0x460
 [<ffffffff8100a876>] ? __switch_to+0x256/0x320
 [<ffffffff814b0c55>] page_fault+0x25/0x30
 [<ffffffff81063926>] ? do_syslog+0x406/0x540
 [<ffffffff810638d5>] ? do_syslog+0x3b5/0x540
 [<ffffffff810836e0>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff811b90f7>] kmsg_read+0x37/0x70
 [<ffffffff811ae2e6>] proc_reg_read+0x76/0xb0
 [<ffffffff811542a5>] vfs_read+0xc5/0x190
 [<ffffffff81154471>] sys_read+0x51/0x90
 [<ffffffff8100bf82>] system_call_fastpath+0x16/0x1b
INFO: task rs:main Q:Reg:7286 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
rs:main Q:Reg   D ffff88045d5bc650     0  7286      1 0x00000080
 ffff88045d35bb08 0000000000000082 ffff880400000000 ffffffffa00040ac
 0000000000014d40 ffff88045d5bc0c0 ffff88045d5bc650 ffff88045d35bfd8
 ffff88045d5bc658 0000000000014d40 ffff88045d35a010 0000000000014d40
Call Trace:
 [<ffffffffa00040ac>] ? dm_table_unplug_all+0x5c/0x110 [dm_mod]
 [<ffffffff810f9570>] ? sync_page+0x0/0x50
 [<ffffffff814ae420>] io_schedule+0x70/0xc0
 [<ffffffff810f95b0>] sync_page+0x40/0x50
 [<ffffffff814aecdf>] __wait_on_bit+0x5f/0x90
 [<ffffffff810f9773>] wait_on_page_bit+0x73/0x80
 [<ffffffff81083720>] ? wake_bit_function+0x0/0x50
 [<ffffffff810f981a>] __lock_page_or_retry+0x3a/0x60
 [<ffffffff810fa847>] filemap_fault+0x2d7/0x4c0
 [<ffffffff8111e454>] __do_fault+0x54/0x570
 [<ffffffff8111ea67>] handle_pte_fault+0xf7/0xb20
 [<ffffffff8110236d>] ? __free_pages+0x2d/0x40
 [<ffffffff8111f641>] handle_mm_fault+0x1b1/0x320
 [<ffffffff814b3ee5>] do_page_fault+0x135/0x460
 [<ffffffff8109768b>] ? sys_futex+0x7b/0x180
 [<ffffffff814b0c55>] page_fault+0x25/0x30
INFO: task automount:6638 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
automount       D ffff88105cd6ba70     0  6638      1 0x00000080
 ffff88105b8ebc18 0000000000000082 00000037ffffffff ffff88087ffdac00
 0000000000014d40 ffff88105cd6b4e0 ffff88105cd6ba70 ffff88105b8ebfd8
 ffff88105cd6ba78 0000000000014d40 ffff88105b8ea010 0000000000014d40
Call Trace:
 [<ffffffff810f9570>] ? sync_page+0x0/0x50
 [<ffffffff814ae420>] io_schedule+0x70/0xc0
 [<ffffffff810f95b0>] sync_page+0x40/0x50
 [<ffffffff814aecdf>] __wait_on_bit+0x5f/0x90
 [<ffffffff8112d3bf>] ? read_swap_cache_async+0x4f/0x140
 [<ffffffff810f9773>] wait_on_page_bit+0x73/0x80
 [<ffffffff81083720>] ? wake_bit_function+0x0/0x50
 [<ffffffff810f981a>] __lock_page_or_retry+0x3a/0x60
 [<ffffffff8111f433>] handle_pte_fault+0xac3/0xb20
 [<ffffffff8111f641>] handle_mm_fault+0x1b1/0x320
 [<ffffffff814b3ee5>] do_page_fault+0x135/0x460
 [<ffffffff8109768b>] ? sys_futex+0x7b/0x180
 [<ffffffff814b0c55>] page_fault+0x25/0x30
INFO: task master:6753 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
master          D ffff88085d4a65d0     0  6753      1 0x00000080
 ffff88085da87c18 0000000000000082 0000003700000000 ffffffff8113edf6
 0000000000014d40 ffff88085d4a6040 ffff88085d4a65d0 ffff88085da87fd8
 ffff88085d4a65d8 0000000000014d40 ffff88085da86010 0000000000014d40
Call Trace:
 [<ffffffff8113edf6>] ? transfer_objects+0x56/0x80
 [<ffffffff810f9570>] ? sync_page+0x0/0x50
 [<ffffffff814ae420>] io_schedule+0x70/0xc0
 [<ffffffff810f95b0>] sync_page+0x40/0x50
 [<ffffffff814aecdf>] __wait_on_bit+0x5f/0x90
 [<ffffffff8112d3bf>] ? read_swap_cache_async+0x4f/0x140
 [<ffffffff810f9773>] wait_on_page_bit+0x73/0x80
 [<ffffffff81083720>] ? wake_bit_function+0x0/0x50
 [<ffffffff810f981a>] __lock_page_or_retry+0x3a/0x60
 [<ffffffff8111f433>] handle_pte_fault+0xac3/0xb20
 [<ffffffff8111f641>] handle_mm_fault+0x1b1/0x320
 [<ffffffff814b3ee5>] do_page_fault+0x135/0x460
 [<ffffffff8118fae0>] ? sys_epoll_wait+0xa0/0x450
 [<ffffffff81059c90>] ? default_wake_function+0x0/0x20
 [<ffffffff814b0c55>] page_fault+0x25/0x30
INFO: task qmgr:6760 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
qmgr            D ffff88105bb5baf0     0  6760   6753 0x00000084
 ffff88105ce93c18 0000000000000082 0000003700000000 ffff88047ffdac00
 0000000000014d40 ffff88105bb5b560 ffff88105bb5baf0 ffff88105ce93fd8
 ffff88105bb5baf8 0000000000014d40 ffff88105ce92010 0000000000014d40
Call Trace:
 [<ffffffff810f9570>] ? sync_page+0x0/0x50
 [<ffffffff814ae420>] io_schedule+0x70/0xc0
 [<ffffffff810f95b0>] sync_page+0x40/0x50
 [<ffffffff814aecdf>] __wait_on_bit+0x5f/0x90
 [<ffffffff8112d3bf>] ? read_swap_cache_async+0x4f/0x140
 [<ffffffff810f9773>] wait_on_page_bit+0x73/0x80
 [<ffffffff81083720>] ? wake_bit_function+0x0/0x50
 [<ffffffff810f981a>] __lock_page_or_retry+0x3a/0x60
 [<ffffffff8111f433>] handle_pte_fault+0xac3/0xb20
 [<ffffffff8111f641>] handle_mm_fault+0x1b1/0x320
 [<ffffffff814b3ee5>] do_page_fault+0x135/0x460
 [<ffffffff8118fae0>] ? sys_epoll_wait+0xa0/0x450
 [<ffffffff81059c90>] ? default_wake_function+0x0/0x20
 [<ffffffff814b0c55>] page_fault+0x25/0x30

[1] http://ltp.git.sourceforge.net/git/gitweb.cgi?p=ltp/ltp.git;a=blob;f=testcases/kernel/mem/oom/oom01.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
