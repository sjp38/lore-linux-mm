Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E6D528D0001
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 16:43:31 -0400 (EDT)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id oA3KQrJ1001434
	for <linux-mm@kvack.org>; Wed, 3 Nov 2010 16:26:53 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oA3KhSAm1695812
	for <linux-mm@kvack.org>; Wed, 3 Nov 2010 16:43:28 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oA3KhSrG008123
	for <linux-mm@kvack.org>; Wed, 3 Nov 2010 18:43:28 -0200
Subject: Deadlocks with transparent huge pages and userspace fs daemons
From: Dave Hansen <dave@linux.vnet.ibm.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Wed, 03 Nov 2010 13:43:25 -0700
Message-ID: <1288817005.4235.11393.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Lin Feng Shen <shenlinf@cn.ibm.com>, Yuri L Volobuev <volobuev@us.ibm.com>, Mel Gorman <mel@linux.vnet.ibm.com>, dingc@cn.ibm.com, lnxninja <lnxninja@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Hey Miklos,

When testing with a transparent huge page kernel:

	http://git.kernel.org/gitweb.cgi?p=linux/kernel/git/andrea/aa.git;a=summary

some IBM testers ran into some deadlocks.  It appears that the
khugepaged process is trying to migrate one of a filesystem daemon's
pages while khugepaged holds the daemon's mmap_sem for write.

I think I've reproduced this issue in a slightly different form with
FUSE.  In my case, I think the FUSE process actually deadlocks on itself
instead of with khugepaged as in the IBM tester example that got me
looking at this.

Andrea put it this way:
> As long as page faults are needed to execute the I/O I doubt it's safe. But
> I'll definitely change khugepaged not to allocate memory. If nothing else
> because I don't want khugepaged to make easier to trigger issues like this. But
> it's hard for me to consider this a bug of khugepaged from a theoretical
> standpoint.

I tend to agree.  khugepaged makes the likelyhood of these things
happening much higher, but I don't think it fundamentally creates the
issue.

Should we do something like make page compaction always non-blocking on
lock_page()?  Should we teach the VM about fuse daemons somehow?

INFO: task unionfs:3527 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
message.
unionfs       D ffff88007d356ec0     0  3527   3478 0x00000000
 ffff88007b0db9a8 0000000000000082 ffffea00000650c8 ffff88007d356c70
 ffff88007d1286a0 000000000000000d 0000000000000000 0000000000000301
 ffff88007b0db978 ffffffff81098f70 ffff88007b0dba58 ffff880001db1f40
Call Trace:
 [<ffffffff81098f70>] ? vma_prio_tree_next+0x3c/0x52
 [<ffffffff813eb183>] io_schedule+0x38/0x4d
 [<ffffffff8108683a>] sync_page+0x44/0x48
 [<ffffffff813eb5e7>] __wait_on_bit_lock+0x42/0x8a
 [<ffffffff810867f6>] ? sync_page+0x0/0x48
 [<ffffffff810867e2>] __lock_page+0x64/0x6b
 [<ffffffff810467bb>] ? wake_bit_function+0x0/0x2a
 [<ffffffff810bce62>] migrate_pages+0x1df/0x66b
 [<ffffffff810b8b33>] ? compaction_alloc+0x0/0x2b9
 [<ffffffff8108fa2c>] ? ____pagevec_lru_add+0x13c/0x14f
 [<ffffffff810b85e5>] compact_zone+0x331/0x54d
 [<ffffffff810b89e4>] compact_zone_order+0xaa/0xb9
 [<ffffffff810b8acd>] try_to_compact_pages+0xda/0x140
 [<ffffffff8108c3f0>] __alloc_pages_nodemask+0x3a6/0x74b
 [<ffffffff810b5db5>] alloc_pages_vma+0x110/0x13d
 [<ffffffff810c6d6d>] do_huge_pmd_anonymous_page+0xc0/0x287
 [<ffffffff810a0ed7>] handle_mm_fault+0x15c/0x201
 [<ffffffff813efa5c>] do_page_fault+0x304/0x422
 [<ffffffff810a5e8a>] ? do_brk+0x282/0x2c8
 [<ffffffff813ed40f>] page_fault+0x1f/0x30

I had to make some changes to the transparent huge page code to get this
to happen.  First, I made the scanning *REALLY* aggressive:

echo 1 > /sys/kernel/mm/transparent_hugepage/khugepaged/alloc_sleep_millisecs
echo 1 > /sys/kernel/mm/transparent_hugepage/khugepaged/scan_sleep_millisecs
echo 65536 > /sys/kernel/mm/transparent_hugepage/khugepaged/pages_to_scan

Then, I hacked migrate_pages() call of unmap_and_move() to always
'force', so that it tries to lock_page() unconditionally.  That's just
to make this race more common.  I also created some large malloc()'d
memory areas in the unionfs daemon and touched them constantly to cause
lots of page faults.

Other relevant tasks:

INFO: task mmap-and-touch:3584 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
mmap-and-touc D ffff88007bd71510     0  3584   3542 0x00000000
 ffff88007a591b88 0000000000000086 ffff88007bd57400 ffff88007bd712c0
 ffff88007d01cd70 ffffffff00000004 ffff88007d22e578 ffff88005e5b7440
 ffff88007a591b58 0000000181182a8c ffff88007a591b88 ffff880001c91f40
Call Trace:
 [<ffffffff813eb183>] io_schedule+0x38/0x4d
 [<ffffffff8108683a>] sync_page+0x44/0x48
 [<ffffffff813eb5e7>] __wait_on_bit_lock+0x42/0x8a
 [<ffffffff810867f6>] ? sync_page+0x0/0x48
 [<ffffffff810867e2>] __lock_page+0x64/0x6b
 [<ffffffff810467bb>] ? wake_bit_function+0x0/0x2a
 [<ffffffff810868a1>] find_lock_page+0x39/0x5d
 [<ffffffff81087f60>] filemap_fault+0x1a6/0x30e
 [<ffffffff8109e5e0>] __do_fault+0x50/0x432
 [<ffffffff8109f636>] handle_pte_fault+0x2db/0x717
 [<ffffffff8108b67c>] ? __free_pages+0x1b/0x24
 [<ffffffff810a0d6c>] ? __pte_alloc+0x112/0x121
 [<ffffffff810a0f64>] handle_mm_fault+0x1e9/0x201
 [<ffffffff813efa5c>] do_page_fault+0x304/0x422
 [<ffffffff810cc83d>] ? sys_newfstat+0x29/0x34
 [<ffffffff813ed40f>] page_fault+0x1f/0x30
INFO: task memknobs:3599 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
memknobs      D ffff88007d305b20     0  3599   3573 0x00000000
 ffff88005e4539a8 0000000000000086 ffff88005e453978 ffff88007d3058d0
 ffff88007dbb60d0 ffffea0000000002 000000003963d000 ffff88007a4c11e8
 ffffea000033aa10 000000017b1e69e0 ffff88005e453988 ffff880001c51f40
Call Trace:
 [<ffffffff813eb183>] io_schedule+0x38/0x4d
 [<ffffffff8108683a>] sync_page+0x44/0x48
 [<ffffffff813eb5e7>] __wait_on_bit_lock+0x42/0x8a
 [<ffffffff810867f6>] ? sync_page+0x0/0x48
 [<ffffffff810867e2>] __lock_page+0x64/0x6b
 [<ffffffff810467bb>] ? wake_bit_function+0x0/0x2a
 [<ffffffff810bce62>] migrate_pages+0x1df/0x66b
 [<ffffffff810b8b33>] ? compaction_alloc+0x0/0x2b9
 [<ffffffff8108fa2c>] ? ____pagevec_lru_add+0x13c/0x14f
 [<ffffffff810b85e5>] compact_zone+0x331/0x54d
 [<ffffffff810b89e4>] compact_zone_order+0xaa/0xb9
 [<ffffffff810b8acd>] try_to_compact_pages+0xda/0x140
 [<ffffffff8108c3f0>] __alloc_pages_nodemask+0x3a6/0x74b
 [<ffffffff810b5db5>] alloc_pages_vma+0x110/0x13d
 [<ffffffff810c6d6d>] do_huge_pmd_anonymous_page+0xc0/0x287
 [<ffffffff810a0ed7>] handle_mm_fault+0x15c/0x201
 [<ffffffff813efa5c>] do_page_fault+0x304/0x422
 [<ffffffff81020e5e>] ? __dequeue_entity+0x2e/0x33
 [<ffffffff81000e25>] ? __switch_to+0x22a/0x23c
 [<ffffffff81020e7b>] ? set_next_entity+0x18/0x36
 [<ffffffff81022e83>] ? finish_task_switch+0x3c/0x81
 [<ffffffff813eb0a5>] ? schedule+0x6f4/0x79a
 [<ffffffff813ed40f>] page_fault+0x1f/0x30
INFO: task khugepaged:515 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
message.
khugepaged    D ffff88007d1e8360     0   515      2 0x00000000
 ffff88007cad5d00 0000000000000046 ffff88007cad5cc0 ffff88007d1e8110
 ffff88007d0986e0 0000000000000008 ffff88007cad5ce0 ffffffff81037e33
 00000000ffffffff 000000017cad5d50 00000001000dd090 0000000000000002
Call Trace:
 [<ffffffff81037e33>] ? lock_timer_base+0x26/0x4a
 [<ffffffff813ec8af>] rwsem_down_failed_common+0xcc/0xfe
 [<ffffffff813ec8f4>] rwsem_down_write_failed+0x13/0x15
 [<ffffffff811ccef3>] call_rwsem_down_write_failed+0x13/0x20
 [<ffffffff813ec09b>] ? down_write+0x20/0x22
 [<ffffffff810c6174>] khugepaged+0xee0/0xf5f
 [<ffffffff81046783>] ? autoremove_wake_function+0x0/0x38
 [<ffffffff810c5294>] ? khugepaged+0x0/0xf5f
 [<ffffffff810462ce>] kthread+0x81/0x89
 [<ffffffff81002cf4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8104624d>] ? kthread+0x0/0x89
 [<ffffffff81002cf0>] ? kernel_thread_helper+0x0/0x10


Original stack trace from GPFS deadlock:

> khugepaged    D ffff88007c823080     0    52      2 0x00000000
>  ffff8800378c98f0 0000000000000046 0000000000000000 001a7949f3208ca4
>  ffffffffffffff10 ffff880079efc670 000000002b6c79c0 00000001169be651
>  ffff88003780c638 ffff8800378c9fd8 0000000000010518 ffff88003780c638
> Call Trace:
>  [<ffffffff8110c060>] ? sync_page+0x0/0x50
>  [<ffffffff814c8a23>] io_schedule+0x73/0xc0
>  [<ffffffff8110c09d>] sync_page+0x3d/0x50
>  [<ffffffff814c914a>] __wait_on_bit_lock+0x5a/0xc0
>  [<ffffffff8110c037>] __lock_page+0x67/0x70
>  [<ffffffff81091ce0>] ? wake_bit_function+0x0/0x50
>  [<ffffffff81122461>] ? lru_cache_add_lru+0x21/0x40
>  [<ffffffff8115b730>] lock_page+0x30/0x40
>  [<ffffffff8115bdad>] migrate_pages+0x59d/0x5d0
>  [<ffffffff81152470>] ? compaction_alloc+0x0/0x370
>  [<ffffffff81151f1c>] compact_zone+0x4ac/0x5e0
>  [<ffffffff8111cd1c>] ? get_page_from_freelist+0x15c/0x820
>  [<ffffffff811522ce>] compact_zone_order+0x7e/0xb0
>  [<ffffffff81152409>] try_to_compact_pages+0x109/0x170
>  [<ffffffff8111e62c>] __alloc_pages_nodemask+0x55c/0x810
>  [<ffffffff81150374>] alloc_pages_vma+0x84/0x110
>  [<ffffffff8116530f>] khugepaged+0xa4f/0x1190
>  [<ffffffff81091ca0>] ? autoremove_wake_function+0x0/0x40
>  [<ffffffff811648c0>] ? khugepaged+0x0/0x1190
>  [<ffffffff81091936>] kthread+0x96/0xa0
>  [<ffffffff810141ca>] child_rip+0xa/0x20
>  [<ffffffff810918a0>] ? kthread+0x0/0xa0
>  [<ffffffff810141c0>] ? child_rip+0x0/0x20
> 
> 
> mmfsd         D ffff88007c823680     0  4453   4118 0x00000080          
>  ffff88001ad1ddf0 0000000000000082 0000000000000000 0000000000000000            
>  0000000000000000 ffff880037fcee40 ffff880079d40ab0 00000001169be9c1            
>  ffff8800782b7ad8 ffff88001ad1dfd8 0000000000010518 ffff8800782b7ad8            
> Call Trace:             
>  [<ffffffff814c8286>] ? thread_return+0x4e/0x778                
>  [<ffffffff81095da3>] ? __hrtimer_start_range_ns+0x1a3/0x430            
>  [<ffffffff814ca6b5>] rwsem_down_failed_common+0x95/0x1d0               
>  [<ffffffff814ca846>] rwsem_down_read_failed+0x26/0x30          
>  [<ffffffff81264224>] call_rwsem_down_read_failed+0x14/0x30             
>  [<ffffffff814c9d44>] ? down_read+0x24/0x30             
>  [<ffffffff814cd6fa>] do_page_fault+0x34a/0x3a0         
>  [<ffffffff814caf45>] page_fault+0x25/0x30              


-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
