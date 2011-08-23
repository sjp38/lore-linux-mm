Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id EBDEC6B016A
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 00:10:32 -0400 (EDT)
Date: Tue, 23 Aug 2011 13:08:49 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [BUG] deadlock about mmap_sem
Message-Id: <20110823130849.8a2692cb.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi,

I found a deadlock problem about mmap_sem on RHEL6.1 kernel,
and I've not verified yet, the problem will still exist in latest kernel, IIUC.

- summary
  I did a page migration test via cpuset I/F. I tried to move a process which
  used too big memory for the destination cpuset.
  The process and the "/bin/echo" are usually oom-killed successfully, but
  the processe and khugepaged are sometimes stuck after the oom.

- detail
  (On 8CPU, 4NODES(1GB/NODE), noswap system)
  1. create a cpuset directories
[root@RHEL6 ~]# mkdir /cgroup/cpuset/src
[root@RHEL6 ~]# mkdir /cgroup/cpuset/dst
[root@RHEL6 ~]#
[root@RHEL6 ~]# echo 1-2,5-6 >/cgroup/cpuset/src/cpuset.cpus
[root@RHEL6 ~]# echo 3,7 >/cgroup/cpuset/dst/cpuset.cpus
[root@RHEL6 ~]#
[root@RHEL6 ~]# echo 1-2 >/cgroup/cpuset/src/cpuset.mems
[root@RHEL6 ~]# echo 3 >/cgroup/cpuset/dst/cpuset.mems
[root@RHEL6 ~]#
[root@RHEL6 ~]# echo 1 >/cgroup/cpuset/dst/cpuset.memory_migrate

  2. register the shell to src(2NODES) directory
[root@RHEL6 ~]# echo $$ >/cgroup/cpuset/src/tasks

  3. run a program which uses 1GB anonymous memory
[root@RHEL6 ~]# ~nishimura/c/malloc 1024

  4. (In another terminal) move the process to dst(1NODES) directory
[root@RHEL6 ~]# /bin/echo `pidof malloc` >/cgroup/cpuset/dst/tasks

  5. oom-killer killed "malloc", but both "malloc" and "khugepaged" are stuck.
[  815.353853] echo invoked oom-killer: gfp_mask=0x200da, order=0, oom_adj=0
[  815.356779] echo cpuset=/ mems_allowed=3
[  815.358313] Pid: 2000, comm: echo Tainted: G           ---------------- T 2.6.32-131.0.15.el6.x86_64 #1
[  815.362078] Call Trace:
[  815.363139]  [<ffffffff810c0101>] ? cpuset_print_task_mems_allowed+0x91/0xb0
[  815.365912]  [<ffffffff811102bb>] ? oom_kill_process+0xcb/0x2e0
[  815.368303]  [<ffffffff81110880>] ? select_bad_process+0xd0/0x110
[  815.370681]  [<ffffffff81110918>] ? __out_of_memory+0x58/0xc0
[  815.372996]  [<ffffffff81110b19>] ? out_of_memory+0x199/0x210
[  815.375274]  [<ffffffff811202dd>] ? __alloc_pages_nodemask+0x80d/0x8b0
[  815.377982]  [<ffffffff81150b99>] ? new_node_page+0x29/0x30
[  815.380253]  [<ffffffff8115fb4f>] ? migrate_pages+0xaf/0x4c0
[  815.382557]  [<ffffffff81150b70>] ? new_node_page+0x0/0x30
[  815.384714]  [<ffffffff811524ed>] ? migrate_to_node+0xbd/0xd0
[  815.386977]  [<ffffffff8115269e>] ? do_migrate_pages+0x19e/0x210
[  815.389559]  [<ffffffff810c1198>] ? cpuset_migrate_mm+0x78/0xa0
[  815.392080]  [<ffffffff810c25e7>] ? cpuset_attach+0x197/0x1d0
[  815.394532]  [<ffffffff810be87e>] ? cgroup_attach_task+0x21e/0x660
[  815.397230]  [<ffffffff810bf00c>] ? cgroup_tasks_write+0x5c/0xf0
[  815.399584]  [<ffffffff810bc01a>] ? cgroup_file_write+0x2ba/0x320
[  815.402101]  [<ffffffff8113e17a>] ? do_mmap_pgoff+0x33a/0x380
[  815.404580]  [<ffffffff81172718>] ? vfs_write+0xb8/0x1a0
[  815.406975]  [<ffffffff810d1b62>] ? audit_syscall_entry+0x272/0x2a0
[  815.409956]  [<ffffffff81173151>] ? sys_write+0x51/0x90
[  815.412542]  [<ffffffff8100b172>] ? system_call_fastpath+0x16/0x1b
[  815.415442] Mem-Info:
[  815.416653] Node 0 DMA per-cpu:
[  815.418303] CPU    0: hi:    0, btch:   1 usd:   0
[  815.420658] CPU    1: hi:    0, btch:   1 usd:   0
[  815.422824] CPU    2: hi:    0, btch:   1 usd:   0
[  815.425148] CPU    3: hi:    0, btch:   1 usd:   0
[  815.427334] CPU    4: hi:    0, btch:   1 usd:   0
[  815.429560] CPU    5: hi:    0, btch:   1 usd:   0
[  815.431638] CPU    6: hi:    0, btch:   1 usd:   0
[  815.433772] CPU    7: hi:    0, btch:   1 usd:   0
[  815.435893] Node 0 DMA32 per-cpu:
[  815.437550] CPU    0: hi:  186, btch:  31 usd:  75
[  815.439680] CPU    1: hi:  186, btch:  31 usd:   0
[  815.441929] CPU    2: hi:  186, btch:  31 usd:   0
[  815.443979] CPU    3: hi:  186, btch:  31 usd:   0
[  815.446172] CPU    4: hi:  186, btch:  31 usd: 167
[  815.448317] CPU    5: hi:  186, btch:  31 usd:   2
[  815.450592] CPU    6: hi:  186, btch:  31 usd:  17
[  815.452708] CPU    7: hi:  186, btch:  31 usd:   2
[  815.454845] Node 1 DMA32 per-cpu:
[  815.456623] CPU    0: hi:  186, btch:  31 usd:   0
[  815.458773] CPU    1: hi:  186, btch:  31 usd:  83
[  815.460964] CPU    2: hi:  186, btch:  31 usd:   0
[  815.463183] CPU    3: hi:  186, btch:  31 usd:  41
[  815.465387] CPU    4: hi:  186, btch:  31 usd:   0
[  815.467330] CPU    5: hi:  186, btch:  31 usd:  51
[  815.469392] CPU    6: hi:  186, btch:  31 usd:  24
[  815.471383] CPU    7: hi:  186, btch:  31 usd: 170
[  815.473307] Node 2 DMA32 per-cpu:
[  815.474903] CPU    0: hi:  186, btch:  31 usd:   0
[  815.476899] CPU    1: hi:  186, btch:  31 usd:   0
[  815.478838] CPU    2: hi:  186, btch:  31 usd: 178
[  815.480822] CPU    3: hi:  186, btch:  31 usd:   0
[  815.482828] CPU    4: hi:  186, btch:  31 usd:   0
[  815.484750] CPU    5: hi:  186, btch:  31 usd: 137
[  815.486746] CPU    6: hi:  186, btch:  31 usd: 185
[  815.488759] CPU    7: hi:  186, btch:  31 usd: 169
[  815.490770] Node 3 DMA32 per-cpu:
[  815.492238] CPU    0: hi:  186, btch:  31 usd:   0
[  815.494280] CPU    1: hi:  186, btch:  31 usd:   0
[  815.496273] CPU    2: hi:  186, btch:  31 usd: 128
[  815.498229] CPU    3: hi:  186, btch:  31 usd: 177
[  815.500208] CPU    4: hi:  186, btch:  31 usd: 125
[  815.502160] CPU    5: hi:  186, btch:  31 usd:   0
[  815.504046] CPU    6: hi:  186, btch:  31 usd:  10
[  815.506003] CPU    7: hi:  186, btch:  31 usd:  30
[  815.507917] Node 3 Normal per-cpu:
[  815.509546] CPU    0: hi:  186, btch:  31 usd:   0
[  815.511588] CPU    1: hi:  186, btch:  31 usd:   1
[  815.513599] CPU    2: hi:  186, btch:  31 usd: 113
[  815.515592] CPU    3: hi:  186, btch:  31 usd: 162
[  815.517509] CPU    4: hi:  186, btch:  31 usd: 131
[  815.519363] CPU    5: hi:  186, btch:  31 usd:  66
[  815.521372] CPU    6: hi:  186, btch:  31 usd: 111
[  815.523314] CPU    7: hi:  186, btch:  31 usd:  81
[  815.525329] active_anon:229332 inactive_anon:11795 isolated_anon:22914
[  815.525332]  active_file:2555 inactive_file:5002 isolated_file:0
[  815.525333]  unevictable:0 dirty:0 writeback:0 unstable:0
[  815.525335]  free:707140 slab_reclaimable:1756 slab_unreclaimable:23190
[  815.525336]  mapped:1240 shmem:49 pagetables:943 bounce:0
[  815.537613] Node 0 DMA free:15720kB min:500kB low:624kB high:748kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15328kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  815.552215] lowmem_reserve[]: 0 994 994 994
[  815.554229] Node 0 DMA32 free:887236kB min:33328kB low:41660kB high:49992kB active_anon:2108kB inactive_anon:8kB active_file:3836kB inactive_file:8860kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:1018080kB mlocked:0kB dirty:0kB writeback:0kB mapped:2088kB shmem:52kB slab_reclaimable:1788kB slab_unreclaimable:26864kB kernel_stack:1312kB pagetables:476kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  815.570204] lowmem_reserve[]: 0 0 0 0
[  815.572056] Node 1 DMA32 free:992108kB min:33856kB low:42320kB high:50784kB active_anon:1424kB inactive_anon:0kB active_file:2832kB inactive_file:5312kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:1034240kB mlocked:0kB dirty:0kB writeback:0kB mapped:1036kB shmem:56kB slab_reclaimable:1756kB slab_unreclaimable:22516kB kernel_stack:80kB pagetables:160kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  815.587848] lowmem_reserve[]: 0 0 0 0
[  815.589745] Node 2 DMA32 free:897996kB min:33856kB low:42320kB high:50784kB active_anon:1408kB inactive_anon:0kB active_file:3444kB inactive_file:5832kB unevictable:0kB isolated(anon):91656kB isolated(file):0kB present:1034240kB mlocked:0kB dirty:0kB writeback:0kB mapped:1788kB shmem:40kB slab_reclaimable:1728kB slab_unreclaimable:21344kB kernel_stack:80kB pagetables:2572kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  815.605725] lowmem_reserve[]: 0 0 0 0
[  815.607589] Node 3 DMA32 free:18664kB min:16692kB low:20864kB high:25036kB active_anon:486584kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:509940kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[  815.622718] lowmem_reserve[]: 0 0 505 505
[  815.624728] Node 3 Normal free:16836kB min:16928kB low:21160kB high:25392kB active_anon:425804kB inactive_anon:47172kB active_file:108kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:517120kB mlocked:0kB dirty:0kB writeback:0kB mapped:48kB shmem:48kB slab_reclaimable:1752kB slab_unreclaimable:22036kB kernel_stack:72kB pagetables:564kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:11168 all_unreclaimable? yes
[  815.640879] lowmem_reserve[]: 0 0 0 0
[  815.642694] Node 0 DMA: 2*4kB 0*8kB 2*16kB 2*32kB 2*64kB 1*128kB 0*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15720kB
[  815.647939] Node 0 DMA32: 687*4kB 529*8kB 220*16kB 84*32kB 39*64kB 19*128kB 11*256kB 6*512kB 3*1024kB 2*2048kB 209*4096kB = 887236kB
[  815.653880] Node 1 DMA32: 779*4kB 598*8kB 271*16kB 119*32kB 33*64kB 11*128kB 9*256kB 9*512kB 7*1024kB 4*2048kB 232*4096kB = 992108kB
[  815.659720] Node 2 DMA32: 324*4kB 291*8kB 278*16kB 130*32kB 44*64kB 25*128kB 19*256kB 13*512kB 6*1024kB 5*2048kB 208*4096kB = 898120kB
[  815.665564] Node 3 DMA32: 0*4kB 1*8kB 0*16kB 1*32kB 1*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 1*2048kB 4*4096kB = 18664kB
[  815.670913] Node 3 Normal: 267*4kB 285*8kB 141*16kB 77*32kB 27*64kB 9*128kB 7*256kB 0*512kB 0*1024kB 0*2048kB 1*4096kB = 16836kB
[  815.676648] 7605 total pagecache pages
[  815.678217] 0 pages in swap cache
[  815.679620] Swap cache stats: add 0, delete 0, find 0/0
[  815.681834] Free swap  = 0kB
[  815.683028] Total swap = 0kB
[  815.718410] 1048575 pages RAM
[  815.719786] 34946 pages reserved
[  815.721251] 30969 pages shared
[  815.722574] 255845 pages non-shared
[  815.724017] Out of memory: kill process 1992 (malloc) score 16445 or a child
[  815.726946] Killed process 1992 (malloc) vsz:1052484kB, anon-rss:1048640kB, file-rss:288kB

[  961.025171] INFO: task khugepaged:1967 blocked for more than 120 seconds.
[  961.028371] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  961.031434] khugepaged    D 0000000000000001     0  1967      2 0x00000080
[  961.034394]  ffff88003db7bc90 0000000000000046 0000000000000000 ffff8800c0010e40
[  961.037555]  0000000000015f80 0000000000000002 0000000000000003 000000010007d852
[  961.040758]  ffff88003d6bf078 ffff88003db7bfd8 000000000000f598 ffff88003d6bf078
[  961.043758] Call Trace:
[  961.044676]  [<ffffffff814dd755>] rwsem_down_failed_common+0x95/0x1d0
[  961.046956]  [<ffffffff814dd8b3>] rwsem_down_write_failed+0x23/0x30
[  961.049783]  [<ffffffff8126e573>] call_rwsem_down_write_failed+0x13/0x20
[  961.052957]  [<ffffffff814dcdb2>] ? down_write+0x32/0x40
[  961.055573]  [<ffffffff8116ad67>] khugepaged+0x847/0x1200
[  961.058148]  [<ffffffff814db337>] ? thread_return+0x4e/0x777
[  961.060995]  [<ffffffff8108e160>] ? autoremove_wake_function+0x0/0x40
[  961.063992]  [<ffffffff8116a520>] ? khugepaged+0x0/0x1200
[  961.066763]  [<ffffffff8108ddf6>] kthread+0x96/0xa0
[  961.069008]  [<ffffffff8100c1ca>] child_rip+0xa/0x20
[  961.071600]  [<ffffffff8108dd60>] ? kthread+0x0/0xa0
[  961.073958]  [<ffffffff8100c1c0>] ? child_rip+0x0/0x20
[  961.076522] INFO: task malloc:1992 blocked for more than 120 seconds.
[  961.079588] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  961.083502] malloc        D 0000000000000003     0  1992   1780 0x00100080
[  961.086867]  ffff8800be25fba0 0000000000000086 0000000000000002 ffff8800bef716f0
[  961.090925]  000280da00000000 0000000000000286 0000000000000030 ffff880080010790
[  961.094932]  ffff8800bd6565f8 ffff8800be25ffd8 000000000000f598 ffff8800bd6565f8
[  961.098926] Call Trace:
[  961.100127]  [<ffffffff8111fbe1>] ? __alloc_pages_nodemask+0x111/0x8b0
[  961.103422]  [<ffffffff814dd755>] rwsem_down_failed_common+0x95/0x1d0
[  961.106451]  [<ffffffff8110d1de>] ? find_get_page+0x1e/0xa0
[  961.109089]  [<ffffffff8110e5f3>] ? filemap_fault+0xd3/0x500
[  961.111797]  [<ffffffff814dd8e6>] rwsem_down_read_failed+0x26/0x30
[  961.114869]  [<ffffffff8126e544>] call_rwsem_down_read_failed+0x14/0x30
[  961.117958]  [<ffffffff814dcde4>] ? down_read+0x24/0x30
[  961.120636]  [<ffffffff810b53d8>] acct_collect+0x48/0x1b0
[  961.123166]  [<ffffffff8106c422>] do_exit+0x7e2/0x860
[  961.125793]  [<ffffffff8107d94d>] ? __sigqueue_free+0x3d/0x50
[  961.128583]  [<ffffffff8108126f>] ? __dequeue_signal+0xdf/0x1f0
[  961.131500]  [<ffffffff8106c4f8>] do_group_exit+0x58/0xd0
[  961.133925]  [<ffffffff81081946>] get_signal_to_deliver+0x1f6/0x460
[  961.136957]  [<ffffffff8100a365>] do_signal+0x75/0x800
[  961.139483]  [<ffffffff81055dcf>] ? finish_task_switch+0x4f/0xf0
[  961.142407]  [<ffffffff814db337>] ? thread_return+0x4e/0x777
[  961.145037]  [<ffffffff8100ab80>] do_notify_resume+0x90/0xc0
[  961.147830]  [<ffffffff8100b440>] int_signal+0x12/0x17


- investigation
  From the call traces above, "malloc" and "khugepaged" are stuck at:
(malloc)
0xffffffff810b53d8 is in acct_collect (kernel/acct.c:613).
608             unsigned long vsize = 0;
609
610             if (group_dead && current->mm) {
611                     struct vm_area_struct *vma;
612                     down_read(&current->mm->mmap_sem);
613                     vma = current->mm->mmap;
614                     while (vma) {
615                             vsize += vma->vm_end - vma->vm_start;
616                             vma = vma->vm_next;
617                     }

(khugepaged)
0xffffffff8116ad62 is in khugepaged (mm/huge_memory.c:1696).
1691            /*
1692             * Prevent all access to pagetables with the exception of
1693             * gup_fast later hanlded by the ptep_clear_flush and the VM
1694             * handled by the anon_vma lock + PG_lock.
1695             */
1696            down_write(&mm->mmap_sem);
1697            if (unlikely(khugepaged_test_exit(mm)))
1698                    goto out;
1699
1700            vma = find_vma(mm, address);

  And "echo" seems to be trying to allocate memory, calling out_of_memory() repeatedly.

crash> bt 2000
PID: 2000   TASK: ffff88007e0dd580  CPU: 4   COMMAND: "echo"
 #0 [ffff88007d7e9728] schedule at ffffffff814db2e9
 #1 [ffff88007d7e97f0] schedule_timeout at ffffffff814dbfe2
 #2 [ffff88007d7e98a0] schedule_timeout_uninterruptible at ffffffff814dc14e
 #3 [ffff88007d7e98b0] out_of_memory at ffffffff81110b3c
 #4 [ffff88007d7e9950] __alloc_pages_nodemask at ffffffff811202dd
 #5 [ffff88007d7e9a70] new_node_page at ffffffff81150b99
 #6 [ffff88007d7e9a80] migrate_pages at ffffffff8115fb4f
 #7 [ffff88007d7e9b30] migrate_to_node at ffffffff811524ed
 #8 [ffff88007d7e9ba0] do_migrate_pages at ffffffff8115269e
 #9 [ffff88007d7e9c40] cpuset_migrate_mm at ffffffff810c1198
#10 [ffff88007d7e9c60] cpuset_attach at ffffffff810c25e7
#11 [ffff88007d7e9d20] cgroup_attach_task at ffffffff810be87e
#12 [ffff88007d7e9e10] cgroup_tasks_write at ffffffff810bf00c
#13 [ffff88007d7e9e40] cgroup_file_write at ffffffff810bc01a
#14 [ffff88007d7e9ef0] vfs_write at ffffffff81172718
#15 [ffff88007d7e9f30] sys_write at ffffffff81173151
#16 [ffff88007d7e9f80] system_call_fastpath at ffffffff8100b172
    RIP: 00000030cc4d95e0  RSP: 00007fffdbc44e58  RFLAGS: 00010206
    RAX: 0000000000000001  RBX: ffffffff8100b172  RCX: 00000030cc78c330
    RDX: 0000000000000005  RSI: 00007fcdc9e89000  RDI: 0000000000000001
    RBP: 00007fcdc9e89000   R8: 00007fcdc9e73700   R9: 0000000000000000
    R10: 00000000ffffffff  R11: 0000000000000246  R12: 0000000000000005
    R13: 00000030cc78b780  R14: 0000000000000005  R15: 00000030cc78b780
    ORIG_RAX: 0000000000000001  CS: 0033  SS: 002b


  So, I think what's happening is:

  1. "echo" tries to allocate memory while it's holding(down_read) mmap_sem
     of "malloc" at do_migrate_pages() and invokes oom-killer.
  2. "malloc" is oom-killed and tries to exit.
  3. Before "malloc" aquires(down_read) its mmap_sem, "khugepaged" tries to
     aquire(down_write) the mmap_sem of "malloc", and fails.
  4. Because "khugepaged" has been waiting the mmap_sem already, "malloc"
     cannot aquire(down_read) the mmap_sem, so it cannot exit.
     IOW, it cannot free its memory.
  5. "echo" calls out_of_memory() repeatedly, but select_bad_process() returns
     ERR_PTR(-1UL), so it doesn't do anything.


Any ideas how to fix this problem?

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
