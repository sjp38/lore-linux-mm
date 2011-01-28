Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3CD758D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 09:36:42 -0500 (EST)
Date: Fri, 28 Jan 2011 09:36:37 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <10770737.209952.1296225397411.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <1939528112.209753.1296225228879.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Subject: Re: known oom issues on numa in -mm tree?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>



----- Original Message -----
> ----- Original Message -----
> > On Fri, 28 Jan 2011, CAI Qian wrote:
> >
> > > I can still reproduce this similar failure on both AMD and Intel
> > > NUMA
> > > systems using the latest linus tree with the commit you mentioned.
> > > Unfortunately, I can't get a clear sysrq/console output of it but
> > > only
> > > a part of it (screenshot attached).
> > >
> > > It at least very easy to reproduce it for me by running LTP oom01
> > > test
> > > for both Magny-Cours and Nehalem-EX NUMA systems.
> > >
> >
> > Are you sure this is the same issue? The picture you provided
> > doesn't
> > show the top of the stack so I don't know what it's doing, but the
> > original report had this:
> >
> > oom02 R running task 0 2023 1969 0x00000088
> > 0000000000000282 ffff88041d219df0 ffff88041fbf8ef0 ffffffff81100800
> > ffff880418ab5b18 0000000000000282 ffffffff8100c9ee ffff880418ab5ba8
> > 0000000087654321 0000000000000000 ffff880000000000 0000000000000001
> > Call Trace:
> > [<ffffffff81100800>] ? drain_local_pages+0x0/0x20
> > [<ffffffff8100c9ee>] ? apic_timer_interrupt+0xe/0x20
> > [<ffffffff81097ea6>] ? smp_call_function_many+0x1b6/0x210
> > [<ffffffff81097e82>] ? smp_call_function_many+0x192/0x210
> > [<ffffffff81100800>] ? drain_local_pages+0x0/0x20
> > [<ffffffff81097f22>] ? smp_call_function+0x22/0x30
> > [<ffffffff81068184>] ? on_each_cpu+0x24/0x50
> > [<ffffffff810fe68c>] ? drain_all_pages+0x1c/0x20
> > [<ffffffff81100d04>] ? __alloc_pages_nodemask+0x4e4/0x840
> > [<ffffffff81138e09>] ? alloc_page_vma+0x89/0x140
> > [<ffffffff8111c481>] ? handle_mm_fault+0x871/0xd80
> > [<ffffffff814a4ecd>] ? schedule+0x3fd/0x980
> > [<ffffffff8100c9ee>] ? apic_timer_interrupt+0xe/0x20
> > [<ffffffff8100c9ee>] ? apic_timer_interrupt+0xe/0x20
> > [<ffffffff814aadd3>] ? do_page_fault+0x143/0x4b0
> > [<ffffffff8100a7b4>] ? __switch_to+0x194/0x320
> > [<ffffffff814a4ecd>] ? schedule+0x3fd/0x980
> > [<ffffffff814a7ad5>] ? page_fault+0x25/0x30
> >
> > and the reported symptom was kswapd running excessively. I'm pretty
> > sure
> > I fixed that with 2ff754fa8f41 (mm: clear pages_scanned only if
> > draining a
> > pcp adds pages to the buddy allocator).
> >
> > Absent the dmesg, it's going to be very difficult to diagnose an
> > issue
> > that isn't a panic.
> Finally, have been able to get a sysrq-t output when oom01 is
> allocating
> memory while used/free swap remained unchanged. All kswapd stopped at
> zone_reclaim.
> 
> # free -m
> total used free shared buffers cached
> Mem: 48392 48050 341 0 26 31
> -/+ buffers/cache: 47993 399
> Swap: 50447 29560 20887
> 
> 
> oom01 R running task 0 14534 14249 0x00000088
> ffff88063fc17d58 0000000000000086 ffff88063fc17d20 000000020000000e
> 0000000000014d40 ffffea0013cc72d8 ffffea0013cc7188 ffffea0013cc7188
> 0000000000000297 ffff88063fc17d20 ffff8806371a7788 0000000000000297
> Call Trace:
> [<ffffffff811043be>] ? release_pages+0x24e/0x260
> [<ffffffff81223591>] ? cpumask_any_but+0x31/0x50
> [<ffffffff81042552>] ? flush_tlb_mm+0x42/0xa0
> [<ffffffff811048c6>] ? __pagevec_release+0x26/0x40
> [<ffffffff8110890f>] ? move_active_pages_to_lru+0x19f/0x1d0
> [<ffffffff8100c96e>] ? apic_timer_interrupt+0xe/0x20
> [<ffffffff8100c96e>] ? apic_timer_interrupt+0xe/0x20
> [<ffffffff8100c96e>] ? apic_timer_interrupt+0xe/0x20
> [<ffffffff8100c96e>] ? apic_timer_interrupt+0xe/0x20
> [<ffffffff810fc51f>] ? zone_watermark_ok+0x1f/0x30
> [<ffffffff81139efc>] ? compaction_suitable+0x3c/0xc0
> [<ffffffff81109647>] ? shrink_zone+0x1a7/0x520
> [<ffffffff811095cd>] ? shrink_zone+0x12d/0x520
> [<ffffffff8108cc43>] ? ktime_get_ts+0xb3/0xf0
> [<ffffffff81109a7f>] ? do_try_to_free_pages+0xbf/0x4a0
> [<ffffffff8110a0d2>] ? try_to_free_pages+0x92/0x130
> [<ffffffff81100ccf>] ? __alloc_pages_nodemask+0x45f/0x850
> [<ffffffff811395d3>] ? alloc_pages_vma+0x93/0x150
> [<ffffffff81148bda>] ? do_huge_pmd_anonymous_page+0x13a/0x330
> [<ffffffff8111e79d>] ? handle_mm_fault+0x24d/0x320
> [<ffffffff814b21a3>] ? do_page_fault+0x143/0x4b0
> [<ffffffff814ac0ce>] ? schedule+0x44e/0xa10
> [<ffffffff814aef15>] ? page_fault+0x25/0x30
> 
> kswapd0 S ffff88022e28d000 0 275 2 0x00000000
> ffff88022e2edda0 0000000000000046 ffffffff81e642c0 ffffffff00000000
> 0000000000014d40 ffff88022e28ca70 ffff88022e28d000 ffff88022e2edfd8
> ffff88022e28d008 0000000000014d40 ffff88022e2ec010 0000000000014d40
> Call Trace:
> [<ffffffff8110a600>] ? zone_reclaim+0x380/0x400
> [<ffffffff8110b196>] kswapd+0xb16/0xc10
> [<ffffffff8110a680>] ? kswapd+0x0/0xc10
> [<ffffffff814ac0ce>] ? schedule+0x44e/0xa10
> [<ffffffff81082fa0>] ? autoremove_wake_function+0x0/0x40
> [<ffffffff8110a680>] ? kswapd+0x0/0xc10
> [<ffffffff81082916>] kthread+0x96/0xa0
> [<ffffffff8100cdc4>] kernel_thread_helper+0x4/0x10
> [<ffffffff81082880>] ? kthread+0x0/0xa0
> [<ffffffff8100cdc0>] ? kernel_thread_helper+0x0/0x10
> kswapd1 S ffff88022e28da30 0 276 2 0x00000000
> ffff88022e2efda0 0000000000000046 ffff880337174000 ffff880300000000
> 0000000000014d40 ffff88022e28d4a0 ffff88022e28da30 ffff88022e2effd8
> ffff88022e28da38 0000000000014d40 ffff88022e2ee010 0000000000014d40
> Call Trace:
> [<ffffffff8110a600>] ? zone_reclaim+0x380/0x400
> [<ffffffff8110b196>] kswapd+0xb16/0xc10
> [<ffffffff8110a680>] ? kswapd+0x0/0xc10
> [<ffffffff814ac0ce>] ? schedule+0x44e/0xa10
> [<ffffffff81082fa0>] ? autoremove_wake_function+0x0/0x40
> [<ffffffff8110a680>] ? kswapd+0x0/0xc10
> [<ffffffff81082916>] kthread+0x96/0xa0
> [<ffffffff8100cdc4>] kernel_thread_helper+0x4/0x10
> [<ffffffff81082880>] ? kthread+0x0/0xa0
> [<ffffffff8100cdc0>] ? kernel_thread_helper+0x0/0x10
> kswapd2 S ffff88022e282690 0 277 2 0x00000000
> ffff88022e2d9da0 0000000000000046 ffff88052f904000 ffff880500000000
> 0000000000014d40 ffff88022e282100 ffff88022e282690 ffff88022e2d9fd8
> ffff88022e282698 0000000000014d40 ffff88022e2d8010 0000000000014d40
> Call Trace:
> [<ffffffff8110a600>] ? zone_reclaim+0x380/0x400
> [<ffffffff8110b196>] kswapd+0xb16/0xc10
> [<ffffffff8110a680>] ? kswapd+0x0/0xc10
> [<ffffffff814ac0ce>] ? schedule+0x44e/0xa10
> [<ffffffff81082fa0>] ? autoremove_wake_function+0x0/0x40
> [<ffffffff8110a680>] ? kswapd+0x0/0xc10
> [<ffffffff81082916>] kthread+0x96/0xa0
> [<ffffffff8100cdc4>] kernel_thread_helper+0x4/0x10
> [<ffffffff81082880>] ? kthread+0x0/0xa0
> [<ffffffff8100cdc0>] ? kernel_thread_helper+0x0/0x10
> kswapd3 S ffff88022e2830c0 0 278 2 0x00000000
> ffff88022e2dbda0 0000000000000046 ffff880637124000 ffff880600000000
> 0000000000014d40 ffff88022e282b30 ffff88022e2830c0 ffff88022e2dbfd8
> ffff88022e2830c8 0000000000014d40 ffff88022e2da010 0000000000014d40
> Call Trace:
> [<ffffffff8110a600>] ? zone_reclaim+0x380/0x400
> [<ffffffff8110b196>] kswapd+0xb16/0xc10
> [<ffffffff8110a680>] ? kswapd+0x0/0xc10
> [<ffffffff814ac0ce>] ? schedule+0x44e/0xa10
> [<ffffffff81082fa0>] ? autoremove_wake_function+0x0/0x40
> [<ffffffff8110a680>] ? kswapd+0x0/0xc10
> [<ffffffff81082916>] kthread+0x96/0xa0
> [<ffffffff8100cdc4>] kernel_thread_helper+0x4/0x10
> [<ffffffff81082880>] ? kthread+0x0/0xa0
> [<ffffffff8100cdc0>] ? kernel_thread_helper+0x0/0x10
> kswapd4 S ffff88022e283af0 0 279 2 0x00000000
> ffff88022e301da0 0000000000000046 ffff88082f908000 ffff880800000000
> 0000000000014d40 ffff88022e283560 ffff88022e283af0 ffff88022e301fd8
> ffff88022e283af8 0000000000014d40 ffff88022e300010 0000000000014d40
> Call Trace:
> [<ffffffff8110a600>] ? zone_reclaim+0x380/0x400
> [<ffffffff8110b196>] kswapd+0xb16/0xc10
> [<ffffffff8110a680>] ? kswapd+0x0/0xc10
> [<ffffffff814ac0ce>] ? schedule+0x44e/0xa10
> [<ffffffff81082fa0>] ? autoremove_wake_function+0x0/0x40
> [<ffffffff8110a680>] ? kswapd+0x0/0xc10
> [<ffffffff81082916>] kthread+0x96/0xa0
> [<ffffffff8100cdc4>] kernel_thread_helper+0x4/0x10
> [<ffffffff81082880>] ? kthread+0x0/0xa0
> [<ffffffff8100cdc0>] ? kernel_thread_helper+0x0/0x10
> kswapd5 S ffff88022e278650 0 280 2 0x00000000
> ffff88022e303da0 0000000000000046 ffff880937134000 ffff880900000000
> 0000000000014d40 ffff88022e2780c0 ffff88022e278650 ffff88022e303fd8
> ffff88022e278658 0000000000014d40 ffff88022e302010 0000000000014d40
> Call Trace:
> [<ffffffff8110a600>] ? zone_reclaim+0x380/0x400
> [<ffffffff8110b196>] kswapd+0xb16/0xc10
> [<ffffffff8110a680>] ? kswapd+0x0/0xc10
> [<ffffffff814ac0ce>] ? schedule+0x44e/0xa10
> [<ffffffff81082fa0>] ? autoremove_wake_function+0x0/0x40
> [<ffffffff8110a680>] ? kswapd+0x0/0xc10
> [<ffffffff81082916>] kthread+0x96/0xa0
> [<ffffffff8100cdc4>] kernel_thread_helper+0x4/0x10
> [<ffffffff81082880>] ? kthread+0x0/0xa0
> [<ffffffff8100cdc0>] ? kernel_thread_helper+0x0/0x10
> kswapd6 S ffff88022e279080 0 281 2 0x00000000
> ffff88022e2c5da0 0000000000000046 ffff880a37134000 ffff880a00000000
> 0000000000014d40 ffff88022e278af0 ffff88022e279080 ffff88022e2c5fd8
> ffff88022e279088 0000000000014d40 ffff88022e2c4010 0000000000014d40
> Call Trace:
> [<ffffffff8110a600>] ? zone_reclaim+0x380/0x400
> [<ffffffff8110b196>] kswapd+0xb16/0xc10
> [<ffffffff8110a680>] ? kswapd+0x0/0xc10
> [<ffffffff814ac0ce>] ? schedule+0x44e/0xa10
> [<ffffffff81082fa0>] ? autoremove_wake_function+0x0/0x40
> [<ffffffff8110a680>] ? kswapd+0x0/0xc10
> [<ffffffff81082916>] kthread+0x96/0xa0
> [<ffffffff8100cdc4>] kernel_thread_helper+0x4/0x10
> [<ffffffff81082880>] ? kthread+0x0/0xa0
> [<ffffffff8100cdc0>] ? kernel_thread_helper+0x0/0x10
> kswapd7 S ffff88022e279ab0 0 282 2 0x00000000
> ffff88022e289da0 0000000000000046 ffff880c2f934000 ffff880c00000000
> 0000000000014d40 ffff88022e279520 ffff88022e279ab0 ffff88022e289fd8
> ffff88022e279ab8 0000000000014d40 ffff88022e288010 0000000000014d40
> Call Trace:
> [<ffffffff8110a600>] ? zone_reclaim+0x380/0x400
> [<ffffffff8110b196>] kswapd+0xb16/0xc10
> [<ffffffff8110a680>] ? kswapd+0x0/0xc10
> [<ffffffff814ac0ce>] ? schedule+0x44e/0xa10
> [<ffffffff81082fa0>] ? autoremove_wake_function+0x0/0x40
> [<ffffffff8110a680>] ? kswapd+0x0/0xc10
> [<ffffffff81082916>] kthread+0x96/0xa0
> [<ffffffff8100cdc4>] kernel_thread_helper+0x4/0x10
> [<ffffffff81082880>] ? kthread+0x0/0xa0
> [<ffffffff8100cdc0>] ? kernel_thread_helper+0x0/0x10
> 
> migration/25 R running task 0 90 2 0x00000000
> ffff88022f1d9de0 0000000000000046 ffff88083fc54d40 0000000000000000
> 0000000000014d40 ffff88022f1d2ab0 ffff88022f1d3040 ffff88022f1d9fd8
> ffff88022f1d3048 0000000000014d40 ffff88022f1d8010 0000000000014d40
> Call Trace:
> [<ffffffff810b43d0>] ? stop_machine_cpu_stop+0x0/0xe0
> [<ffffffff810b433d>] cpu_stopper_thread+0x13d/0x1d0
> [<ffffffff810b4200>] ? cpu_stopper_thread+0x0/0x1d0
> [<ffffffff810b4200>] ? cpu_stopper_thread+0x0/0x1d0
> [<ffffffff81082916>] kthread+0x96/0xa0
> [<ffffffff8100cdc4>] kernel_thread_helper+0x4/0x10
> [<ffffffff81082880>] ? kthread+0x0/0xa0
> [<ffffffff8100cdc0>] ? kernel_thread_helper+0x0/0x10
> 
> kworker/25:0 S ffff88022f1d2610 0 91 2 0x00000000
> ffff88022f1fbe50 0000000000000046 ffff88063fc112c8 0000000000000082
> 0000000000014d40 ffff88022f1d2080 ffff88022f1d2610 ffff88022f1fbfd8
> ffff88022f1d2618 0000000000014d40 ffff88022f1fa010 0000000000014d40
> Call Trace:
> [<ffffffff8107e301>] worker_thread+0x261/0x3c0
> [<ffffffff8107e0a0>] ? worker_thread+0x0/0x3c0
> [<ffffffff81082916>] kthread+0x96/0xa0
> [<ffffffff8100cdc4>] kernel_thread_helper+0x4/0x10
> [<ffffffff81082880>] ? kthread+0x0/0xa0
> [<ffffffff8100cdc0>] ? kernel_thread_helper+0x0/0x10
> 
> ...
> 
> runnable tasks:
> task PID tree-key switches prio exec-runtime sum-exec sum-sleep
> ----------------------------------------------------------------------------------------------------------
> migration/25 90 2150.833956 29 0 2150.833956 0.000920 0.000000 /
> R oom01 14534 582482.371064 96026 120 582482.371064 519502.918710
> 91644.125770 /
> kworker/25:2 14592 582470.371064 4811 120 582470.371064 108.496370
> 207368.125892 /
Then, hung tasks killed off.

INFO: task jbd2/dm-0-8:618 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
jbd2/dm-0-8     D ffff88022c5dfa30     0   618      2 0x00000000
 ffff88022c601b30 0000000000000046 ffff88022c601ae0 ffffffff00000000
 0000000000014d40 ffff88022c5df4a0 ffff88022c5dfa30 ffff88022c601fd8
 ffff88022c5dfa38 0000000000014d40 ffff88022c600010 0000000000014d40
Call Trace:
 [<ffffffff810f8570>] ? sync_page+0x0/0x50
 [<ffffffff814ac700>] io_schedule+0x70/0xc0
 [<ffffffff810f85b0>] sync_page+0x40/0x50
 [<ffffffff814acfbf>] __wait_on_bit+0x5f/0x90
 [<ffffffff810f8773>] wait_on_page_bit+0x73/0x80
 [<ffffffff81082fe0>] ? wake_bit_function+0x0/0x50
 [<ffffffff81103a95>] ? pagevec_lookup_tag+0x25/0x40
 [<ffffffff810f8bb3>] filemap_fdatawait_range+0x113/0x1a0
 [<ffffffff8120c6d6>] ? submit_bio+0x86/0x110
 [<ffffffff811847bb>] ? bio_alloc_bioset+0x5b/0xf0
 [<ffffffff810f8c6b>] filemap_fdatawait+0x2b/0x30
 [<ffffffffa01abe2c>] jbd2_journal_commit_transaction+0x74c/0x13f0 [jbd2]
 [<ffffffff810714c3>] ? try_to_del_timer_sync+0x83/0xe0
 [<ffffffffa01b12c8>] kjournald2+0xb8/0x220 [jbd2]
 [<ffffffff81082fa0>] ? autoremove_wake_function+0x0/0x40
 [<ffffffffa01b1210>] ? kjournald2+0x0/0x220 [jbd2]
 [<ffffffff81082916>] kthread+0x96/0xa0
 [<ffffffff8100cdc4>] kernel_thread_helper+0x4/0x10
 [<ffffffff81082880>] ? kthread+0x0/0xa0
 [<ffffffff8100cdc0>] ? kernel_thread_helper+0x0/0x10
INFO: task flush-253:0:1626 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
flush-253:0     D ffff88022e34c5d0     0  1626      2 0x00000080
 ffff88022e873630 0000000000000046 ffff880337397c80 ffff880300000000
 0000000000014d40 ffff88022e34c040 ffff88022e34c5d0 ffff88022e873fd8
 ffff88022e34c5d8 0000000000014d40 ffff88022e872010 0000000000014d40
Call Trace:
 [<ffffffff8117fdd0>] ? sync_buffer+0x0/0x50
 [<ffffffff814ac700>] io_schedule+0x70/0xc0
 [<ffffffff8117fe10>] sync_buffer+0x40/0x50
 [<ffffffff814acfbf>] __wait_on_bit+0x5f/0x90
 [<ffffffff8117fdd0>] ? sync_buffer+0x0/0x50
 [<ffffffff814ad068>] out_of_line_wait_on_bit+0x78/0x90
 [<ffffffff81082fe0>] ? wake_bit_function+0x0/0x50
 [<ffffffff8117fdce>] __wait_on_buffer+0x2e/0x30
 [<ffffffff81180ce8>] bh_submit_read+0x68/0x90
 [<ffffffffa01ccb86>] ext4_read_block_bitmap+0x176/0x390 [ext4]
 [<ffffffffa01fa346>] ext4_mb_mark_diskspace_used+0x56/0x320 [ext4]
 [<ffffffffa020064d>] ? ext4_mb_new_group_pa+0x1ed/0x2d0 [ext4]
 [<ffffffffa0201a39>] ext4_mb_new_blocks+0x249/0x500 [ext4]
 [<ffffffffa01f400d>] ? ext4_ext_find_extent+0x12d/0x320 [ext4]
 [<ffffffff81180290>] ? end_buffer_async_write+0x0/0x1a0
 [<ffffffffa01f69ae>] ext4_ext_map_blocks+0x58e/0x1f40 [ext4]
 [<ffffffff8113eb00>] ? ____cache_alloc_node+0x100/0x150
 [<ffffffff812289a5>] ? radix_tree_gang_lookup_tag_slot+0x95/0xe0
 [<ffffffff81103a95>] ? pagevec_lookup_tag+0x25/0x40
 [<ffffffffa01d4ed4>] ext4_map_blocks+0xf4/0x210 [ext4]
 [<ffffffffa01d6379>] mpage_da_map_and_submit+0xb9/0x440 [ext4]
 [<ffffffffa01aa393>] ? jbd2_journal_start+0x13/0x20 [jbd2]
 [<ffffffffa01eac00>] ? ext4_journal_start_sb+0xf0/0x130 [ext4]
 [<ffffffffa01d6f85>] ext4_da_writepages+0x2f5/0x640 [ext4]
 [<ffffffff81102c71>] do_writepages+0x21/0x40
 [<ffffffff81177698>] writeback_single_inode+0x98/0x240
 [<ffffffff81177cde>] writeback_sb_inodes+0xce/0x170
 [<ffffffff811786e9>] writeback_inodes_wb+0x99/0x160
 [<ffffffff81178a6b>] wb_writeback+0x2bb/0x430
 [<ffffffff81178e0c>] wb_do_writeback+0x22c/0x280
 [<ffffffff81178f12>] bdi_writeback_thread+0xb2/0x260
 [<ffffffff81178e60>] ? bdi_writeback_thread+0x0/0x260
 [<ffffffff81178e60>] ? bdi_writeback_thread+0x0/0x260
 [<ffffffff81082916>] kthread+0x96/0xa0
 [<ffffffff8100cdc4>] kernel_thread_helper+0x4/0x10
 [<ffffffff81082880>] ? kthread+0x0/0xa0
 [<ffffffff8100cdc0>] ? kernel_thread_helper+0x0/0x10
INFO: task master:2115 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
master          D ffff880335951000     0  2115      1 0x00000080
 ffff8803359e1a88 0000000000000082 ffff8803359e1cb4 0000000000000000
 0000000000014d40 ffff880335950a70 ffff880335951000 ffff8803359e1fd8
 ffff880335951008 0000000000014d40 ffff8803359e0010 0000000000014d40
Call Trace:
 [<ffffffffa01aafed>] do_get_write_access+0x29d/0x510 [jbd2]
 [<ffffffff81082fe0>] ? wake_bit_function+0x0/0x50
 [<ffffffffa01ab3b1>] jbd2_journal_get_write_access+0x31/0x50 [jbd2]
 [<ffffffffa01f8b0e>] __ext4_journal_get_write_access+0x3e/0x80 [ext4]
 [<ffffffffa01d4418>] ext4_reserve_inode_write+0x78/0xa0 [ext4]
 [<ffffffffa01aa33b>] ? jbd2__journal_start+0xbb/0x100 [jbd2]
 [<ffffffffa01d47cd>] ? ext4_dirty_inode+0x3d/0x60 [ext4]
 [<ffffffffa01d449d>] ext4_mark_inode_dirty+0x5d/0x230 [ext4]
 [<ffffffffa01aa393>] ? jbd2_journal_start+0x13/0x20 [jbd2]
 [<ffffffffa01eac00>] ? ext4_journal_start_sb+0xf0/0x130 [ext4]
 [<ffffffffa01d47cd>] ext4_dirty_inode+0x3d/0x60 [ext4]
 [<ffffffff81178308>] __mark_inode_dirty+0x38/0x1e0
 [<ffffffff8116afdc>] file_update_time+0xec/0x170
 [<ffffffff8115c04f>] pipe_write+0x32f/0x680
 [<ffffffff81152e5a>] do_sync_write+0xda/0x120
 [<ffffffff811e4063>] ? selinux_file_permission+0xf3/0x150
 [<ffffffff811dd083>] ? security_file_permission+0x23/0x90
 [<ffffffff811533f8>] vfs_write+0xc8/0x190
 [<ffffffff811535c1>] sys_write+0x51/0x90
 [<ffffffff8100bf82>] system_call_fastpath+0x16/0x1b
INFO: task pickup:2124 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
pickup          D ffff880635fd25d0     0  2124   2115 0x00000080
 ffff880635feda98 0000000000000086 0000000000000006 0000000000000000
 0000000000014d40 ffff880635fd2040 ffff880635fd25d0 ffff880635fedfd8
 ffff880635fd25d8 0000000000014d40 ffff880635fec010 0000000000014d40
Call Trace:
 [<ffffffffa01aafed>] do_get_write_access+0x29d/0x510 [jbd2]
 [<ffffffff81082fe0>] ? wake_bit_function+0x0/0x50
 [<ffffffffa01ab3b1>] jbd2_journal_get_write_access+0x31/0x50 [jbd2]
 [<ffffffffa01f8b0e>] __ext4_journal_get_write_access+0x3e/0x80 [ext4]
 [<ffffffffa01d4418>] ext4_reserve_inode_write+0x78/0xa0 [ext4]
 [<ffffffffa01aa33b>] ? jbd2__journal_start+0xbb/0x100 [jbd2]
 [<ffffffffa01d47cd>] ? ext4_dirty_inode+0x3d/0x60 [ext4]
 [<ffffffffa01d449d>] ext4_mark_inode_dirty+0x5d/0x230 [ext4]
 [<ffffffffa01aa393>] ? jbd2_journal_start+0x13/0x20 [jbd2]
 [<ffffffffa01eac00>] ? ext4_journal_start_sb+0xf0/0x130 [ext4]
 [<ffffffffa01d47cd>] ext4_dirty_inode+0x3d/0x60 [ext4]
 [<ffffffff81178308>] __mark_inode_dirty+0x38/0x1e0
 [<ffffffff8116b18b>] touch_atime+0x12b/0x170
 [<ffffffff8115c6b4>] pipe_read+0x2b4/0x4c0
 [<ffffffff81152f7a>] do_sync_read+0xda/0x120
 [<ffffffff811dd0eb>] ? security_file_permission+0x8b/0x90
 [<ffffffff811536c5>] vfs_read+0xc5/0x190
 [<ffffffff81153891>] sys_read+0x51/0x90
 [<ffffffff8100bf82>] system_call_fastpath+0x16/0x1b
INFO: task sadc:14685 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
sadc            D ffff88022b929af0     0 14685  14683 0x00000084
 ffff88022ae73e08 0000000000000086 0000000000000001 0000000000000000
 0000000000014d40 ffff88022b929560 ffff88022b929af0 ffff88022ae73fd8
 ffff88022b929af8 0000000000014d40 ffff88022ae72010 0000000000014d40
Call Trace:
 [<ffffffffa01b0f5d>] jbd2_log_wait_commit+0xbd/0x130 [jbd2]
 [<ffffffff81082fa0>] ? autoremove_wake_function+0x0/0x40
 [<ffffffffa01ce3bd>] ext4_sync_file+0x12d/0x330 [ext4]
 [<ffffffff8117cd99>] vfs_fsync_range+0x79/0x90
 [<ffffffff8117ce1c>] vfs_fsync+0x1c/0x20
 [<ffffffff8117ce5a>] do_fsync+0x3a/0x60
 [<ffffffff8117ce93>] sys_fdatasync+0x13/0x20
 [<ffffffff8100bf82>] system_call_fastpath+0x16/0x1b
INFO: task jbd2/dm-0-8:618 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
jbd2/dm-0-8     D ffff88022c5dfa30     0   618      2 0x00000000
 ffff88022c601b30 0000000000000046 ffff88022c601ae0 ffffffff00000000
 0000000000014d40 ffff88022c5df4a0 ffff88022c5dfa30 ffff88022c601fd8
 ffff88022c5dfa38 0000000000014d40 ffff88022c600010 0000000000014d40
Call Trace:
 [<ffffffff810f8570>] ? sync_page+0x0/0x50
 [<ffffffff814ac700>] io_schedule+0x70/0xc0
 [<ffffffff810f85b0>] sync_page+0x40/0x50
 [<ffffffff814acfbf>] __wait_on_bit+0x5f/0x90
 [<ffffffff810f8773>] wait_on_page_bit+0x73/0x80
 [<ffffffff81082fe0>] ? wake_bit_function+0x0/0x50
 [<ffffffff81103a95>] ? pagevec_lookup_tag+0x25/0x40
 [<ffffffff810f8bb3>] filemap_fdatawait_range+0x113/0x1a0
 [<ffffffff8120c6d6>] ? submit_bio+0x86/0x110
 [<ffffffff811847bb>] ? bio_alloc_bioset+0x5b/0xf0
 [<ffffffff810f8c6b>] filemap_fdatawait+0x2b/0x30
 [<ffffffffa01abe2c>] jbd2_journal_commit_transaction+0x74c/0x13f0 [jbd2]
 [<ffffffff810714c3>] ? try_to_del_timer_sync+0x83/0xe0
 [<ffffffffa01b12c8>] kjournald2+0xb8/0x220 [jbd2]
 [<ffffffff81082fa0>] ? autoremove_wake_function+0x0/0x40
 [<ffffffffa01b1210>] ? kjournald2+0x0/0x220 [jbd2]
 [<ffffffff81082916>] kthread+0x96/0xa0
 [<ffffffff8100cdc4>] kernel_thread_helper+0x4/0x10
 [<ffffffff81082880>] ? kthread+0x0/0xa0
 [<ffffffff8100cdc0>] ? kernel_thread_helper+0x0/0x10
INFO: task flush-253:0:1626 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
flush-253:0     D ffff88022e34c5d0     0  1626      2 0x00000080
 ffff88022e873630 0000000000000046 ffff880337397c80 ffff880300000000
 0000000000014d40 ffff88022e34c040 ffff88022e34c5d0 ffff88022e873fd8
 ffff88022e34c5d8 0000000000014d40 ffff88022e872010 0000000000014d40
Call Trace:
 [<ffffffff8117fdd0>] ? sync_buffer+0x0/0x50
 [<ffffffff814ac700>] io_schedule+0x70/0xc0
 [<ffffffff8117fe10>] sync_buffer+0x40/0x50
 [<ffffffff814acfbf>] __wait_on_bit+0x5f/0x90
 [<ffffffff8117fdd0>] ? sync_buffer+0x0/0x50
 [<ffffffff814ad068>] out_of_line_wait_on_bit+0x78/0x90
 [<ffffffff81082fe0>] ? wake_bit_function+0x0/0x50
 [<ffffffff8117fdce>] __wait_on_buffer+0x2e/0x30
 [<ffffffff81180ce8>] bh_submit_read+0x68/0x90
 [<ffffffffa01ccb86>] ext4_read_block_bitmap+0x176/0x390 [ext4]
 [<ffffffffa01fa346>] ext4_mb_mark_diskspace_used+0x56/0x320 [ext4]
 [<ffffffffa020064d>] ? ext4_mb_new_group_pa+0x1ed/0x2d0 [ext4]
 [<ffffffffa0201a39>] ext4_mb_new_blocks+0x249/0x500 [ext4]
 [<ffffffffa01f400d>] ? ext4_ext_find_extent+0x12d/0x320 [ext4]
 [<ffffffff81180290>] ? end_buffer_async_write+0x0/0x1a0
 [<ffffffffa01f69ae>] ext4_ext_map_blocks+0x58e/0x1f40 [ext4]
 [<ffffffff8113eb00>] ? ____cache_alloc_node+0x100/0x150
 [<ffffffff812289a5>] ? radix_tree_gang_lookup_tag_slot+0x95/0xe0
 [<ffffffff81103a95>] ? pagevec_lookup_tag+0x25/0x40
 [<ffffffffa01d4ed4>] ext4_map_blocks+0xf4/0x210 [ext4]
 [<ffffffffa01d6379>] mpage_da_map_and_submit+0xb9/0x440 [ext4]
 [<ffffffffa01aa393>] ? jbd2_journal_start+0x13/0x20 [jbd2]
 [<ffffffffa01eac00>] ? ext4_journal_start_sb+0xf0/0x130 [ext4]
 [<ffffffffa01d6f85>] ext4_da_writepages+0x2f5/0x640 [ext4]
 [<ffffffff81102c71>] do_writepages+0x21/0x40
 [<ffffffff81177698>] writeback_single_inode+0x98/0x240
 [<ffffffff81177cde>] writeback_sb_inodes+0xce/0x170
 [<ffffffff811786e9>] writeback_inodes_wb+0x99/0x160
 [<ffffffff81178a6b>] wb_writeback+0x2bb/0x430
 [<ffffffff81178e0c>] wb_do_writeback+0x22c/0x280
 [<ffffffff81178f12>] bdi_writeback_thread+0xb2/0x260
 [<ffffffff81178e60>] ? bdi_writeback_thread+0x0/0x260
 [<ffffffff81178e60>] ? bdi_writeback_thread+0x0/0x260
 [<ffffffff81082916>] kthread+0x96/0xa0
 [<ffffffff8100cdc4>] kernel_thread_helper+0x4/0x10
 [<ffffffff81082880>] ? kthread+0x0/0xa0
 [<ffffffff8100cdc0>] ? kernel_thread_helper+0x0/0x10
INFO: task ntpd:2039 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
ntpd            D ffff88093661f080     0  2039      1 0x00000080
 ffff880935f33ab8 0000000000000082 ffff880337397c80 ffff880335e344f8
 0000000000014d40 ffff88093661eaf0 ffff88093661f080 ffff880935f33fd8
 ffff88093661f088 0000000000014d40 ffff880935f32010 0000000000014d40
Call Trace:
 [<ffffffff8117fdd0>] ? sync_buffer+0x0/0x50
 [<ffffffff814ac700>] io_schedule+0x70/0xc0
 [<ffffffff8117fe10>] sync_buffer+0x40/0x50
 [<ffffffff814acfbf>] __wait_on_bit+0x5f/0x90
 [<ffffffff811847bb>] ? bio_alloc_bioset+0x5b/0xf0
 [<ffffffff8117fdd0>] ? sync_buffer+0x0/0x50
 [<ffffffff814ad068>] out_of_line_wait_on_bit+0x78/0x90
 [<ffffffff81082fe0>] ? wake_bit_function+0x0/0x50
 [<ffffffff8117fdce>] __wait_on_buffer+0x2e/0x30
 [<ffffffffa01dd578>] ext4_find_entry+0x3e8/0x4b0 [ext4]
 [<ffffffff811e0611>] ? inode_has_perm+0x51/0xa0
 [<ffffffffa01dd6f8>] ? ext4_lookup+0xb8/0x130 [ext4]
 [<ffffffffa01dd68d>] ext4_lookup+0x4d/0x130 [ext4]
 [<ffffffff8115db35>] d_alloc_and_lookup+0x45/0x90
 [<ffffffff81168215>] ? d_lookup+0x35/0x60
 [<ffffffff8115f436>] __lookup_hash+0x106/0x1c0
 [<ffffffff8116010d>] do_last+0x14d/0x380
 [<ffffffff811625e8>] do_filp_open+0x3d8/0x770
 [<ffffffff81067798>] ? sys_adjtimex+0x78/0x90
 [<ffffffff8116df25>] ? alloc_fd+0x95/0x160
 [<ffffffff81151489>] do_sys_open+0x69/0x110
 [<ffffffff81151570>] sys_open+0x20/0x30
 [<ffffffff8100bf82>] system_call_fastpath+0x16/0x1b
INFO: task master:2115 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
master          D ffff880335951000     0  2115      1 0x00000084
 ffff8803359e1a88 0000000000000082 ffff8803359e1cb4 0000000000000000
 0000000000014d40 ffff880335950a70 ffff880335951000 ffff8803359e1fd8
 ffff880335951008 0000000000014d40 ffff8803359e0010 0000000000014d40
Call Trace:
 [<ffffffffa01aafed>] do_get_write_access+0x29d/0x510 [jbd2]
 [<ffffffff81082fe0>] ? wake_bit_function+0x0/0x50
 [<ffffffffa01ab3b1>] jbd2_journal_get_write_access+0x31/0x50 [jbd2]
 [<ffffffffa01f8b0e>] __ext4_journal_get_write_access+0x3e/0x80 [ext4]
 [<ffffffffa01d4418>] ext4_reserve_inode_write+0x78/0xa0 [ext4]
 [<ffffffffa01aa33b>] ? jbd2__journal_start+0xbb/0x100 [jbd2]
 [<ffffffffa01d47cd>] ? ext4_dirty_inode+0x3d/0x60 [ext4]
 [<ffffffffa01d449d>] ext4_mark_inode_dirty+0x5d/0x230 [ext4]
 [<ffffffffa01aa393>] ? jbd2_journal_start+0x13/0x20 [jbd2]
 [<ffffffffa01eac00>] ? ext4_journal_start_sb+0xf0/0x130 [ext4]
 [<ffffffffa01d47cd>] ext4_dirty_inode+0x3d/0x60 [ext4]
 [<ffffffff81178308>] __mark_inode_dirty+0x38/0x1e0
 [<ffffffff8116afdc>] file_update_time+0xec/0x170
 [<ffffffff8115c04f>] pipe_write+0x32f/0x680
 [<ffffffff81152e5a>] do_sync_write+0xda/0x120
 [<ffffffff811e4063>] ? selinux_file_permission+0xf3/0x150
 [<ffffffff811dd083>] ? security_file_permission+0x23/0x90
 [<ffffffff811533f8>] vfs_write+0xc8/0x190
 [<ffffffff811535c1>] sys_write+0x51/0x90
 [<ffffffff8100bf82>] system_call_fastpath+0x16/0x1b
INFO: task pickup:2124 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
pickup          D ffff880635fd25d0     0  2124   2115 0x00000080
 ffff880635feda98 0000000000000086 0000000000000006 0000000000000000
 0000000000014d40 ffff880635fd2040 ffff880635fd25d0 ffff880635fedfd8
 ffff880635fd25d8 0000000000014d40 ffff880635fec010 0000000000014d40
Call Trace:
 [<ffffffffa01aafed>] do_get_write_access+0x29d/0x510 [jbd2]
 [<ffffffff81082fe0>] ? wake_bit_function+0x0/0x50
 [<ffffffffa01ab3b1>] jbd2_journal_get_write_access+0x31/0x50 [jbd2]
 [<ffffffffa01f8b0e>] __ext4_journal_get_write_access+0x3e/0x80 [ext4]
 [<ffffffffa01d4418>] ext4_reserve_inode_write+0x78/0xa0 [ext4]
 [<ffffffffa01aa33b>] ? jbd2__journal_start+0xbb/0x100 [jbd2]
 [<ffffffffa01d47cd>] ? ext4_dirty_inode+0x3d/0x60 [ext4]
 [<ffffffffa01d449d>] ext4_mark_inode_dirty+0x5d/0x230 [ext4]
 [<ffffffffa01aa393>] ? jbd2_journal_start+0x13/0x20 [jbd2]
 [<ffffffffa01eac00>] ? ext4_journal_start_sb+0xf0/0x130 [ext4]
 [<ffffffffa01d47cd>] ext4_dirty_inode+0x3d/0x60 [ext4]
 [<ffffffff81178308>] __mark_inode_dirty+0x38/0x1e0
 [<ffffffff8116b18b>] touch_atime+0x12b/0x170
 [<ffffffff8115c6b4>] pipe_read+0x2b4/0x4c0
 [<ffffffff81152f7a>] do_sync_read+0xda/0x120
 [<ffffffff811dd0eb>] ? security_file_permission+0x8b/0x90
 [<ffffffff811536c5>] vfs_read+0xc5/0x190
 [<ffffffff81153891>] sys_read+0x51/0x90
 [<ffffffff8100bf82>] system_call_fastpath+0x16/0x1b

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
