Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id E0EA46B0389
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 23:46:36 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id s186so43484525qkb.5
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 20:46:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s63si3366258qkc.208.2017.02.28.20.46.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 20:46:36 -0800 (PST)
Date: Wed, 1 Mar 2017 12:46:34 +0800
From: Xiong Zhou <xzhou@redhat.com>
Subject: mm allocation failure and hang when running xfstests generic/269 on
 xfs
Message-ID: <20170301044634.rgidgdqqiiwsmfpj@XZHOUW.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

Hi,

It's reproduciable, not everytime though. Ext4 works fine.

Based on test logs, it's bad on Linus tree commit:
  e5d56ef Merge tag 'watchdog-for-linus-v4.11'

It's good on commit:
  f8e6859 Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc

Trying to narrow down a little bit.

Thanks,
Xiong

---

fsstress: vmalloc: allocation failure, allocated 12288 of 20480 bytes, mode:0x14080c2(GFP_KERNEL|__GFP_HIGHMEM|__GFP_ZERO), nodemask=(null)
fsstress cpuset=/ mems_allowed=0-1
CPU: 1 PID: 23460 Comm: fsstress Not tainted 4.10.0-master-45554b2+ #21
Hardware name: HP ProLiant DL380 Gen9/ProLiant DL380 Gen9, BIOS P89 10/05/2016
Call Trace:
 dump_stack+0x63/0x87
 warn_alloc+0x114/0x1c0
 ? alloc_pages_current+0x88/0x120
 __vmalloc_node_range+0x250/0x2a0
 ? kmem_zalloc_greedy+0x2b/0x40 [xfs]
 ? free_hot_cold_page+0x21f/0x280
 vzalloc+0x54/0x60
 ? kmem_zalloc_greedy+0x2b/0x40 [xfs]
 kmem_zalloc_greedy+0x2b/0x40 [xfs]
 xfs_bulkstat+0x11b/0x730 [xfs]
 ? xfs_bulkstat_one_int+0x340/0x340 [xfs]
 ? selinux_capable+0x20/0x30
 ? security_capable+0x48/0x60
 xfs_ioc_bulkstat+0xe4/0x190 [xfs]
 xfs_file_ioctl+0x9dd/0xad0 [xfs]
 ? do_filp_open+0xa5/0x100
 do_vfs_ioctl+0xa7/0x5e0
 SyS_ioctl+0x79/0x90
 do_syscall_64+0x67/0x180
 entry_SYSCALL64_slow_path+0x25/0x25
RIP: 0033:0x7f825023f577
RSP: 002b:00007ffffea76e58 EFLAGS: 00000246 ORIG_RAX: 0000000000000010
RAX: ffffffffffffffda RBX: 0000000000003f7e RCX: 00007f825023f577
RDX: 00007ffffea76e70 RSI: ffffffffc0205865 RDI: 0000000000000003
RBP: 0000000000000003 R08: 0000000000000008 R09: 0000000000000036
R10: 0000000000000069 R11: 0000000000000246 R12: 0000000000000036
R13: 00007f824c002d00 R14: 0000000000001209 R15: 0000000000000000
Mem-Info:
active_anon:23126 inactive_anon:1719 isolated_anon:0
 active_file:153709 inactive_file:356889 isolated_file:0
 unevictable:0 dirty:0 writeback:0 unstable:0
 slab_reclaimable:43829 slab_unreclaimable:45414
 mapped:14638 shmem:2470 pagetables:1599 bounce:0
 free:7463113 free_pcp:23729 free_cma:0
Node 0 active_anon:36372kB inactive_anon:140kB active_file:449540kB inactive_file:355288kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:21792kB dirty:0kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 10240kB anon_thp: 796kB writeback_tmp:0kB unstable:0kB pages_scanned:0 all_unreclaimable? no
Node 1 active_anon:56132kB inactive_anon:6736kB active_file:165296kB inactive_file:1072268kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:36760kB dirty:0kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 12288kB anon_thp: 9084kB writeback_tmp:0kB unstable:0kB pages_scanned:0 all_unreclaimable? no
Node 0 DMA free:15884kB min:40kB low:52kB high:64kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15992kB managed:15904kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:20kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
lowmem_reserve[]: 0 1821 15896 15896 15896
Node 0 DMA32 free:1860532kB min:4968kB low:6772kB high:8576kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:1948156kB managed:1865328kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:2132kB local_pcp:0kB free_cma:0kB
lowmem_reserve[]: 0 0 14074 14074 14074
Node 0 Normal free:13111616kB min:39660kB low:54072kB high:68484kB active_anon:36372kB inactive_anon:140kB active_file:449540kB inactive_file:355296kB unevictable:0kB writepending:0kB present:14680064kB managed:14412260kB mlocked:0kB slab_reclaimable:77256kB slab_unreclaimable:86096kB kernel_stack:8184kB pagetables:3132kB bounce:0kB free_pcp:45712kB local_pcp:212kB free_cma:0kB
lowmem_reserve[]: 0 0 0 0 0
Node 1 Normal free:14864424kB min:45432kB low:61940kB high:78448kB active_anon:56132kB inactive_anon:6736kB active_file:165296kB inactive_file:1072264kB unevictable:0kB writepending:0kB present:16777216kB managed:16508964kB mlocked:0kB slab_reclaimable:98060kB slab_unreclaimable:95540kB kernel_stack:7880kB pagetables:3264kB bounce:0kB free_pcp:46848kB local_pcp:640kB free_cma:0kB
lowmem_reserve[]: 0 0 0 0 0
Node 0 DMA: 1*4kB (U) 1*8kB (U) 0*16kB 0*32kB 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) = 15884kB
Node 0 DMA32: 13*4kB (UM) 10*8kB (UM) 13*16kB (UM) 11*32kB (M) 18*64kB (UM) 9*128kB (UM) 16*256kB (UM) 12*512kB (UM) 12*1024kB (UM) 10*2048kB (UM) 443*4096kB (M) = 1860532kB
Node 0 Normal: 2765*4kB (UME) 737*8kB (UME) 145*16kB (UME) 251*32kB (UME) 626*64kB (UM) 255*128kB (UME) 46*256kB (UME) 23*512kB (UE) 15*1024kB (U) 8*2048kB (U) 3163*4096kB (M) = 13110956kB
Node 1 Normal: 3422*4kB (UME) 1039*8kB (UME) 158*16kB (UME) 852*32kB (UME) 1125*64kB (UME) 617*128kB (UE) 329*256kB (UME) 117*512kB (UME) 18*1024kB (UM) 6*2048kB (U) 3537*4096kB (M) = 14865168kB
Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
Node 1 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
Node 1 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
513078 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 10485756kB
Total swap = 10485756kB
8355357 pages RAM
0 pages HighMem/MovableOnly
154743 pages reserved
0 pages cma reserved
0 pages hwpoisoned

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
