Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id C49A56B004A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 16:53:24 -0400 (EDT)
Date: Thu, 26 Apr 2012 16:53:20 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: 3.4-rc4 oom killer out of control.
Message-ID: <20120426205320.GA30741@redhat.com>
References: <20120426193551.GA24968@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120426193551.GA24968@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>

I rebooted, and reran the test, and within minutes, got it into a state
where it was killing things again fairly quickly.
This time however, it seems to have killed almost everything on the box,
but is still alive. The problem is that all the memory is eaten up by
something, and kswapd/ksmd is eating all the cpu.
(Attempting to profile with perf causes perf to be oom-killed).


# free
             total       used       free     shared    buffers     cached
Mem:       8149440    8046560     102880          0        272       3316
-/+ buffers/cache:    8042972     106468
Swap:      1023996    1023996          0

Attempting to flush the buffers with drop_caches made no difference.



A lot of VMAs in slab..

 Active / Total Objects (% used)    : 467327 / 494733 (94.5%)
 Active / Total Slabs (% used)      : 18195 / 18195 (100.0%)
 Active / Total Caches (% used)     : 145 / 207 (70.0%)
 Active / Total Size (% used)       : 241177.72K / 263399.54K (91.6%)
 Minimum / Average / Maximum Object : 0.33K / 0.53K / 9.16K

  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME    
213216 213167  99%    0.49K   6663       32    106608K vm_area_struct
 74718  74674  99%    0.37K   3558       21     28464K anon_vma_chain
 37820  37663  99%    0.52K   1220       31     19520K anon_vma
 33263  33188  99%    0.51K   1073       31     17168K kmalloc-192
 25344  25340  99%    0.48K    768       33     12288K sysfs_dir_cache
 12740  12660  99%    0.38K    637       20      5096K btrfs_free_space_cache
 18981   9213  48%    0.58K    703       27     11248K dentry
  8112   8075  99%    0.33K    338       24      2704K kmalloc-8
  9982   6064  60%    1.34K    434       23     13888K inode_cache
  5768   5605  97%    0.57K    206       28      3296K kmalloc-256
  5640   5201  92%    0.38K    282       20      2256K kmalloc-64
  4600   4577  99%    0.34K    200       23      1600K kmalloc-16
  6182   4002  64%    0.36K    281       22      2248K debug_objects_cache
  3002   2980  99%    1.62K    158       19      5056K mm_struct



ps axf shows there's hardly anything left running after all the oom killing:
 http://fpaste.org/Dd9p/raw/

sysrq-t traces.. 

ksmd            D ffff88021b81c940  5760    46      2 0x00000000
 ffff88021b847b20 0000000000000046 0000000000000000 0000000000000000
 ffff88021b81c940 ffff88021b847fd8 ffff88021b847fd8 ffff88021b847fd8
 ffff8802232f24a0 ffff88021b81c940 ffff88021b847b50 ffff88021b847d20
Call Trace:
 [<ffffffff816ace99>] schedule+0x29/0x70
 [<ffffffff816aad75>] schedule_timeout+0x385/0x4f0
 [<ffffffff816ac23f>] ? wait_for_common+0x3f/0x160
 [<ffffffff816ae6da>] ? _raw_spin_unlock_irqrestore+0x4a/0x90
 [<ffffffff810a591d>] ? try_to_wake_up+0x26d/0x310
 [<ffffffff810a2981>] ? get_parent_ip+0x11/0x50
 [<ffffffff816ac313>] wait_for_common+0x113/0x160
 [<ffffffff810a59c0>] ? try_to_wake_up+0x310/0x310
 [<ffffffff81166c30>] ? __pagevec_release+0x40/0x40
 [<ffffffff816ac43d>] wait_for_completion+0x1d/0x20
 [<ffffffff81086b76>] flush_work+0x46/0x70
 [<ffffffff81085740>] ? do_work_for_cpu+0x30/0x30
 [<ffffffff8108a37b>] schedule_on_each_cpu+0xeb/0x130
 [<ffffffff81166c55>] lru_add_drain_all+0x15/0x20
 [<ffffffff811a5e45>] ksm_scan_thread+0x8c5/0xd90
 [<ffffffff81090040>] ? __init_waitqueue_head+0x60/0x60
 [<ffffffff811a5580>] ? run_store+0x2b0/0x2b0
 [<ffffffff8108f397>] kthread+0xb7/0xc0
 [<ffffffff816b2b2d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff816b7f34>] kernel_thread_helper+0x4/0x10
 [<ffffffff8109c08c>] ? finish_task_switch+0x7c/0x120
 [<ffffffff816af034>] ? retint_restore_args+0x13/0x13
 [<ffffffff8108f2e0>] ? __init_kthread_worker+0x70/0x70
 [<ffffffff816b7f30>] ? gs_change+0x13/0x13

kswapd0         R  running task     4152    45      2 0x00000008
 ffff88021b833c80 0000000000000000 ffff88021b833b60 ffffffff8116d6df
 ffff880200000000 ffff880200000001 0000000000000000 0000000000000002
 0000000200000001 ffff88022ffebc40 ffff880226035598 000000000000001e
Call Trace:
 [<ffffffff8116d6df>] ? shrink_inactive_list+0x17f/0x590
 [<ffffffff8116e2d8>] ? shrink_mem_cgroup_zone+0x448/0x5d0
 [<ffffffff8116e4d6>] ? shrink_zone+0x76/0xa0
 [<ffffffff8116fd35>] ? balance_pgdat+0x555/0x7a0
 [<ffffffff8117011c>] ? kswapd+0x19c/0x5f0
 [<ffffffff81090040>] ? __init_waitqueue_head+0x60/0x60
 [<ffffffff8116ff80>] ? balance_pgdat+0x7a0/0x7a0
 [<ffffffff8108f397>] ? kthread+0xb7/0xc0
 [<ffffffff816b2b2d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff816b7f34>] ? kernel_thread_helper+0x4/0x10
 [<ffffffff8109c08c>] ? finish_task_switch+0x7c/0x120
 [<ffffffff816af034>] ? retint_restore_args+0x13/0x13
 [<ffffffff8108f2e0>] ? __init_kthread_worker+0x70/0x70
 [<ffffffff816b7f30>] ? gs_change+0x13/0x13


khugepaged      S 000000010039c99c  5728    47      2 0x00000000
 ffff88021ba1bc60 0000000000000046 ffff88021ba1bc98 ffffffff81c28be0
 ffff88021ba48000 ffff88021ba1bfd8 ffff88021ba1bfd8 ffff88021ba1bfd8
 ffff8802232f24a0 ffff88021ba48000 ffff88021ba1bc50 ffff88021ba1bc98
Call Trace:
 [<ffffffff816ace99>] schedule+0x29/0x70
 [<ffffffff816aaba9>] schedule_timeout+0x1b9/0x4f0
 [<ffffffff81076370>] ? lock_timer_base+0x70/0x70
 [<ffffffff811b2233>] khugepaged+0x273/0x14a0
 [<ffffffff8109c08c>] ? finish_task_switch+0x7c/0x120
 [<ffffffff81090040>] ? __init_waitqueue_head+0x60/0x60
 [<ffffffff811b1fc0>] ? khugepaged_alloc_sleep+0x160/0x160
 [<ffffffff8108f397>] kthread+0xb7/0xc0
 [<ffffffff816b2b2d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff816b7f34>] kernel_thread_helper+0x4/0x10
 [<ffffffff8109c08c>] ? finish_task_switch+0x7c/0x120
 [<ffffffff816af034>] ? retint_restore_args+0x13/0x13
 [<ffffffff8108f2e0>] ? __init_kthread_worker+0x70/0x70
 [<ffffffff816b7f30>] ? gs_change+0x13/0x13



sysrq-M ...

Mem-Info:
Node 0 DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
CPU    2: hi:    0, btch:   1 usd:   0
CPU    3: hi:    0, btch:   1 usd:   0
Node 0 DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd:  27
CPU    1: hi:  186, btch:  31 usd:   0
CPU    2: hi:  186, btch:  31 usd:  24
CPU    3: hi:  186, btch:  31 usd:   1
Node 0 Normal per-cpu:
CPU    0: hi:  186, btch:  31 usd:  67
CPU    1: hi:  186, btch:  31 usd:   3
CPU    2: hi:  186, btch:  31 usd:  55
CPU    3: hi:  186, btch:  31 usd:  13
active_anon:1565586 inactive_anon:283198 isolated_anon:0
 active_file:241 inactive_file:505 isolated_file:0
 unevictable:1414 dirty:14 writeback:0 unstable:0
 free:25817 slab_reclaimable:10704 slab_unreclaimable:56662
 mapped:262 shmem:45 pagetables:45795 bounce:0
Node 0 DMA free:15876kB min:128kB low:160kB high:192kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15652kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
lowmem_reserve[]: 0 3246 8034 8034
Node 0 DMA32 free:47320kB min:27252kB low:34064kB high:40876kB active_anon:2651136kB inactive_anon:530560kB active_file:244kB inactive_file:232kB unevictable:788kB isolated(anon):0kB isolated(file):0kB present:3324200kB mlocked:788kB dirty:0kB writeback:0kB mapped:268kB shmem:68kB slab_reclaimable:1200kB slab_unreclaimable:24680kB kernel_stack:336kB pagetables:29924kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:2 all_unreclaimable? no
lowmem_reserve[]: 0 0 4788 4788
Node 0 Normal free:40072kB min:40196kB low:50244kB high:60292kB active_anon:3611208kB inactive_anon:602232kB active_file:720kB inactive_file:1404kB unevictable:4868kB isolated(anon):0kB isolated(file):0kB present:4902912kB mlocked:4868kB dirty:56kB writeback:0kB mapped:780kB shmem:112kB slab_reclaimable:41616kB slab_unreclaimable:201936kB kernel_stack:2960kB pagetables:153256kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:123 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
Node 0 DMA: 1*4kB 0*8kB 0*16kB 0*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15876kB
Node 0 DMA32: 84*4kB 76*8kB 27*16kB 16*32kB 4*64kB 5*128kB 5*256kB 2*512kB 5*1024kB 2*2048kB 8*4096kB = 47072kB
Node 0 Normal: 64*4kB 171*8kB 279*16kB 384*32kB 135*64kB 54*128kB 18*256kB 3*512kB 0*1024kB 0*2048kB 0*4096kB = 40072kB
1774 total pagecache pages
1040 pages in swap cache
Swap cache stats: add 1966902, delete 1965862, find 483713/484292
Free swap  = 0kB
Total swap = 1023996kB
2097136 pages RAM
59776 pages reserved
996409 pages shared
2007653 pages non-shared

sysrq-l traces show ksmd is doing *lots* of scanning..

Process ksmd (pid: 46, threadinfo ffff88021b846000, task ffff88021b81c940)
Stack:
 ffff88021b847de0 ffffffff811a4881 ffff8800136a5260 ffffea0006236f00
 ffff88021b847e90 ffffffff811a5f7d 0000000000000000 ffff88018ef64780
 ffff88021b81c940 ffff88021b847fd8 ffff88021b847e50 ffff88018ef64828
Call Trace:
 [<ffffffff811a4881>] memcmp_pages+0x61/0xc0
 [<ffffffff811a5f7d>] ksm_scan_thread+0x9fd/0xd90
 [<ffffffff81090040>] ? __init_waitqueue_head+0x60/0x60
 [<ffffffff811a5580>] ? run_store+0x2b0/0x2b0
 [<ffffffff8108f397>] kthread+0xb7/0xc0
 [<ffffffff816b2b2d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff816b7f34>] kernel_thread_helper+0x4/0x10
 [<ffffffff8109c08c>] ? finish_task_switch+0x7c/0x120
 [<ffffffff816af034>] ? retint_restore_args+0x13/0x13
 [<ffffffff8108f2e0>] ? __init_kthread_worker+0x70/0x70
 [<ffffffff816b7f30>] ? gs_change+0x13/0x13


The machine is still alive, though somewhat crippled due to the oom-killer kicking in a lot,
but I can keep it up for additional debug info gathering..

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
