Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 6A3C56B0062
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 11:46:56 -0400 (EDT)
Received: by mail-we0-f177.google.com with SMTP id u57so10638388wes.8
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 08:46:55 -0700 (PDT)
Received: from alpha.arachsys.com (alpha.arachsys.com. [2001:9d8:200a:0:9f:9fff:fe90:dbe3])
        by mx.google.com with ESMTPS id en20si8334020wic.72.2014.04.16.08.46.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 16 Apr 2014 08:46:53 -0700 (PDT)
Date: Wed, 16 Apr 2014 16:46:50 +0100
From: Richard Davies <richard@arachsys.com>
Subject: memcg with kmem limit doesn't recover after disk i/o causes limit
 to be hit
Message-ID: <20140416154650.GA3034@alpha.arachsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, linux-mm@kvack.org

Hi all,

I have a simple reproducible test case in which untar in a memcg with a kmem
limit gets into trouble during heavy disk i/o (on ext3) and never properly
recovers. This is simplified from real world problems with heavy disk i/o
inside containers.

I feel there are probably two bugs here
- the disk i/o is not successfully managed within the kmem limit
- the cgroup never recovers, despite the untar i/o process exiting

I'm happy to help with any further debugging or try patches.


To replicate on Linux 3.14.0, run the following 6 commands:

# mkdir -p /sys/fs/cgroup/test/
# cat /sys/fs/cgroup/cpuset.cpus > /sys/fs/cgroup/test/cpuset.cpus
# cat /sys/fs/cgroup/cpuset.mems > /sys/fs/cgroup/test/cpuset.mems
# echo $((1<<26)) >/sys/fs/cgroup/test/memory.kmem.limit_in_bytes
# echo $$ > /sys/fs/cgroup/test/tasks
# tar xfz linux-3.14.1.tar.gz

Part way through the untar, the tar command exits after many errors:

...
linux-3.14.1/include/linux/ima.h: Can't create 'linux-3.14.1/include/linux/ima.h'
linux-3.14.1/include/linux/in.h: Can't create 'linux-3.14.1/include/linux/in.h'
linux-3.14.1/include/linux/in6.h: Can't create 'linux-3.14.1/include/linux/in6.h'
...

At the same time, many errors are logged in the kernel log, of the form:

14:58:45 kernel: SLUB: Unable to allocate memory on node -1 (gfp=0xd0)
14:58:45 kernel:  cache: radix_tree_node(3:test2), object size: 560, buffer size: 568, default order: 2, min order: 0
14:58:45 kernel:  node 0: slabs: 140, objs: 3920, free: 0
14:58:45 kernel:  node 1: slabs: 464, objs: 12992, free: 0

and

15:11:36 kernel: SLUB: Unable to allocate memory on node -1 (gfp=0x50)
15:11:36 kernel:  cache: ext4_inode_cache(2:test), object size: 920, buffer size: 928, default order: 3, min order: 0
15:11:36 kernel:  node 0: slabs: 946, objs: 33110, free: 0
15:11:36 kernel:  node 1: slabs: 78, objs: 2730, free: 0

and

15:31:15 kernel: ENOMEM in journal_alloc_journal_head, retrying.
15:31:20 kernel: __slab_alloc: 6946855 callbacks suppressed
15:31:20 kernel: SLUB: Unable to allocate memory on node -1 (gfp=0x8050)
15:31:20 kernel:  cache: jbd2_journal_head(2:test), object size: 112, buffer size: 112, default order: 0, min order: 0
15:31:20 kernel:  node 0: slabs: 80, objs: 2880, free: 0
15:31:20 kernel:  node 1: slabs: 0, objs: 0, free: 0


After this, the bash prompt in the cgroup is unusable:

# ls
-bash: fork: Cannot allocate memory

But typically the system outside the cgroup continues to work.


All of the above happens every time that I run these 6 commands.

I am happy to help with extra information on kernel configuration, but I
hope that the above is sufficient for others to replicate. I'm also happy to
try suggestions and patches.


In addition, sometimes these 6 commands trigger more serious issues beyond
the cgroup. I have copied a long kernel log of such an incident below.

Thanks in advance for your help,

Richard.


15:11:36 kernel: SLUB: Unable to allocate memory on node -1 (gfp=0x50)
15:11:36 kernel:  cache: ext4_inode_cache(2:test), object size: 920, buffer size: 928, default order: 3, min order: 0
15:11:36 kernel:  node 0: slabs: 946, objs: 33110, free: 0
15:11:36 kernel:  node 1: slabs: 78, objs: 2730, free: 0
15:11:36 kernel: SLUB: Unable to allocate memory on node -1 (gfp=0xd0)
15:11:36 kernel:  cache: radix_tree_node(2:test), object size: 560, buffer size: 568, default order: 2, min order: 0
15:11:36 kernel:  node 0: slabs: 558, objs: 15624, free: 0
15:11:36 kernel:  node 1: slabs: 56, objs: 1568, free: 0
15:11:36 kernel: SLUB: Unable to allocate memory on node -1 (gfp=0xd0)
15:11:36 kernel:  cache: radix_tree_node(2:test), object size: 560, buffer size: 568, default order: 2, min order: 0
15:11:36 kernel:  node 0: slabs: 558, objs: 15624, free: 0
15:11:36 kernel:  node 1: slabs: 56, objs: 1568, free: 0
15:11:36 kernel: SLUB: Unable to allocate memory on node -1 (gfp=0x50)
15:11:36 kernel:  cache: radix_tree_node(2:test), object size: 560, buffer size: 568, default order: 2, min order: 0
15:11:36 kernel:  node 0: slabs: 558, objs: 15624, free: 0
15:11:36 kernel:  node 1: slabs: 56, objs: 1568, free: 0
15:11:36 kernel: SLUB: Unable to allocate memory on node -1 (gfp=0xd0)
15:11:36 kernel:  cache: radix_tree_node(2:test), object size: 560, buffer size: 568, default order: 2, min order: 0
15:11:36 kernel:  node 0: slabs: 558, objs: 15624, free: 0
15:11:36 kernel:  node 1: slabs: 56, objs: 1568, free: 0
15:11:36 kernel: SLUB: Unable to allocate memory on node -1 (gfp=0x50)
15:11:36 kernel:  cache: radix_tree_node(2:test), object size: 560, buffer size: 568, default order: 2, min order: 0
15:11:36 kernel:  node 0: slabs: 558, objs: 15624, free: 0
15:11:36 kernel:  node 1: slabs: 56, objs: 1568, free: 0
15:11:36 kernel: SLUB: Unable to allocate memory on node -1 (gfp=0xd0)
15:11:36 kernel:  cache: radix_tree_node(2:test), object size: 560, buffer size: 568, default order: 2, min order: 0
15:11:36 kernel:  node 0: slabs: 558, objs: 15624, free: 0
15:11:36 kernel:  node 1: slabs: 56, objs: 1568, free: 0
15:11:36 kernel: SLUB: Unable to allocate memory on node -1 (gfp=0x50)
15:11:36 kernel:  cache: radix_tree_node(2:test), object size: 560, buffer size: 568, default order: 2, min order: 0
15:11:36 kernel:  node 0: slabs: 558, objs: 15624, free: 0
15:11:36 kernel:  node 1: slabs: 56, objs: 1568, free: 0
15:11:36 kernel: SLUB: Unable to allocate memory on node -1 (gfp=0xd0)
15:11:36 kernel:  cache: radix_tree_node(2:test), object size: 560, buffer size: 568, default order: 2, min order: 0
15:11:36 kernel:  node 0: slabs: 558, objs: 15624, free: 0
15:11:36 kernel:  node 1: slabs: 56, objs: 1568, free: 0
15:11:36 kernel: SLUB: Unable to allocate memory on node -1 (gfp=0x50)
15:11:36 kernel:  cache: radix_tree_node(2:test), object size: 560, buffer size: 568, default order: 2, min order: 0
15:11:36 kernel:  node 0: slabs: 558, objs: 15624, free: 0
15:11:36 kernel:  node 1: slabs: 56, objs: 1568, free: 0
15:11:36 kernel: tar invoked oom-killer: gfp_mask=0x0, order=0, oom_score_adj=0
15:11:36 kernel: tar cpuset=test mems_allowed=0-1
15:11:36 kernel: CPU: 3 PID: 5102 Comm: tar Not tainted 3.14.0-elastic #1
15:11:36 kernel: Hardware name: Supermicro H8DMT-IBX/H8DMT-IBX, BIOS 080014  10/17/2009
15:11:36 kernel: ffff8804119696a0 ffff8800d56dfbf8 ffffffff8185d77b ffff880411969080
15:11:36 kernel: ffff880411969080 ffff8800d56dfca8 ffffffff8112b820 ffff8800d56dfc28
15:11:36 kernel: ffffffff81133deb ffff880409060590 ffff88040f73c500 ffff8800d56dfc38
15:11:36 kernel: Call Trace:
15:11:36 kernel: [<ffffffff8185d77b>] dump_stack+0x51/0x77
15:11:36 kernel: [<ffffffff8112b820>] dump_header+0x7a/0x208
15:11:36 kernel: [<ffffffff81133deb>] ? __put_single_page+0x1b/0x1f
15:11:36 kernel: [<ffffffff8113448f>] ? put_page+0x22/0x24
15:11:36 kernel: [<ffffffff81129e38>] ? filemap_fault+0x2c2/0x36c
15:11:36 kernel: [<ffffffff813d146e>] ? ___ratelimit+0xe6/0x104
15:11:36 kernel: [<ffffffff8112bc1b>] oom_kill_process+0x6a/0x33b
15:11:36 kernel: [<ffffffff8112c306>] out_of_memory+0x41a/0x44d
15:11:36 kernel: [<ffffffff8112c39e>] pagefault_out_of_memory+0x65/0x77
15:11:36 kernel: [<ffffffff8106939e>] mm_fault_error+0xab/0x176
15:11:36 kernel: [<ffffffff810696f0>] __do_page_fault+0x287/0x3e2
15:11:36 kernel: [<ffffffff811017ad>] ? rcu_eqs_enter+0x70/0x83
15:11:36 kernel: [<ffffffff811017ce>] ? rcu_user_enter+0xe/0x10
15:11:36 kernel: [<ffffffff810f5018>] ? cpuacct_account_field+0x55/0x5d
15:11:36 kernel: [<ffffffff810e7816>] ? account_user_time+0x6e/0x97
15:11:36 kernel: [<ffffffff810e788c>] ? vtime_account_user+0x4d/0x52
15:11:36 kernel: [<ffffffff8106988f>] do_page_fault+0x44/0x61
15:11:36 kernel: [<ffffffff818618f8>] page_fault+0x28/0x30
15:11:36 kernel: Mem-Info:
15:11:36 kernel: Node 0 DMA per-cpu:
15:11:36 kernel: CPU    0: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    1: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    2: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    3: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    4: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    5: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    6: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    7: hi:    0, btch:   1 usd:   0
15:11:36 kernel: Node 0 DMA32 per-cpu:
15:11:36 kernel: CPU    0: hi:  186, btch:  31 usd: 133
15:11:36 kernel: CPU    1: hi:  186, btch:  31 usd: 155
15:11:36 kernel: CPU    2: hi:  186, btch:  31 usd:  55
15:11:36 kernel: CPU    3: hi:  186, btch:  31 usd: 162
15:11:36 kernel: CPU    4: hi:  186, btch:  31 usd:   0
15:11:36 kernel: CPU    5: hi:  186, btch:  31 usd:   0
15:11:36 kernel: CPU    6: hi:  186, btch:  31 usd:  18
15:11:36 kernel: CPU    7: hi:  186, btch:  31 usd:   0
15:11:36 kernel: Node 0 Normal per-cpu:
15:11:36 kernel: CPU    0: hi:  186, btch:  31 usd:  24
15:11:36 kernel: CPU    1: hi:  186, btch:  31 usd:  54
15:11:36 kernel: CPU    2: hi:  186, btch:  31 usd: 167
15:11:36 kernel: CPU    3: hi:  186, btch:  31 usd: 178
15:11:36 kernel: CPU    4: hi:  186, btch:  31 usd:   0
15:11:36 kernel: CPU    5: hi:  186, btch:  31 usd:   0
15:11:36 kernel: CPU    6: hi:  186, btch:  31 usd:   7
15:11:36 kernel: CPU    7: hi:  186, btch:  31 usd:   3
15:11:36 kernel: Node 1 Normal per-cpu:
15:11:36 kernel: CPU    0: hi:  186, btch:  31 usd:   0
15:11:36 kernel: CPU    1: hi:  186, btch:  31 usd:   1
15:11:36 kernel: CPU    2: hi:  186, btch:  31 usd:   0
15:11:36 kernel: CPU    3: hi:  186, btch:  31 usd: 115
15:11:36 kernel: CPU    4: hi:  186, btch:  31 usd:  80
15:11:36 kernel: CPU    5: hi:  186, btch:  31 usd: 167
15:11:36 kernel: CPU    6: hi:  186, btch:  31 usd: 183
15:11:36 kernel: CPU    7: hi:  186, btch:  31 usd:  46
15:11:36 kernel: active_anon:20251 inactive_anon:3312 isolated_anon:0
15:11:36 kernel: active_file:29061 inactive_file:151914 isolated_file:0
15:11:36 kernel: unevictable:621 dirty:354 writeback:38 unstable:0
15:11:36 kernel: free:7963301 slab_reclaimable:19802 slab_unreclaimable:7992
15:11:36 kernel: mapped:7165 shmem:1531 pagetables:1575 bounce:0
15:11:36 kernel: free_cma:0
15:11:36 kernel: Node 0 DMA free:15900kB min:40kB low:48kB high:60kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15984kB managed:15900kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
15:11:36 kernel: lowmem_reserve[]: 0 3425 16097 16097
15:11:36 kernel: Node 0 DMA32 free:3390912kB min:9572kB low:11964kB high:14356kB active_anon:7148kB inactive_anon:3572kB active_file:15064kB inactive_file:79976kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3522184kB managed:3509084kB mlocked:0kB dirty:4kB writeback:0kB mapped:4836kB shmem:1864kB slab_reclaimable:3504kB slab_unreclaimable:2268kB kernel_stack:880kB pagetables:1548kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
15:11:36 kernel: lowmem_reserve[]: 0 0 12671 12671
15:11:36 kernel: Node 0 Normal free:12257092kB min:35416kB low:44268kB high:53124kB active_anon:28044kB inactive_anon:6424kB active_file:63204kB inactive_file:435064kB unevictable:320kB isolated(anon):0kB isolated(file):0kB present:13238272kB managed:12975484kB mlocked:320kB dirty:0kB writeback:0kB mapped:12072kB shmem:3164kB slab_reclaimable:64444kB slab_unreclaimable:15760kB kernel_stack:1832kB pagetables:2584kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
15:11:36 kernel: lowmem_reserve[]: 0 0 0 0
15:11:36 kernel: Node 1 Normal free:16189300kB min:45076kB low:56344kB high:67612kB active_anon:45812kB inactive_anon:3252kB active_file:37976kB inactive_file:92616kB unevictable:2164kB isolated(anon):0kB isolated(file):0kB present:16777216kB managed:16514488kB mlocked:2164kB dirty:1412kB writeback:152kB mapped:11752kB shmem:1096kB slab_reclaimable:11260kB slab_unreclaimable:13940kB kernel_stack:1824kB pagetables:2168kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
15:11:36 kernel: lowmem_reserve[]: 0 0 0 0
15:11:36 kernel: Node 0 DMA: 1*4kB (U) 1*8kB (U) 1*16kB (U) 0*32kB 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) = 15900kB
15:11:36 kernel: Node 0 DMA32: 49*4kB (UEM) 62*8kB (U) 30*16kB (U) 12*32kB (UEM) 4*64kB (UM) 4*128kB (UE) 2*256kB (UM) 1*512kB (U) 0*1024kB 2*2048kB (MR) 826*4096kB (MR) = 3390740kB
15:11:36 kernel: Node 0 Normal: 112*4kB (UE) 57*8kB (UE) 12*16kB (UEM) 32*32kB (UEM) 15*64kB (UEM) 5*128kB (UM) 3*256kB (UEM) 3*512kB (UEM) 2*1024kB (UM) 1*2048kB (M) 2990*4096kB (MR) = 12257160kB
15:11:36 kernel: Node 1 Normal: 95*4kB (UM) 8*8kB (U) 0*16kB 8*32kB (U) 6*64kB (UM) 10*128kB (UM) 2*256kB (EM) 2*512kB (UE) 0*1024kB 1*2048kB (M) 3951*4096kB (MR) = 16189244kB
15:11:36 kernel: Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
15:11:36 kernel: Node 1 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
15:11:36 kernel: 183020 total pagecache pages
15:11:36 kernel: 0 pages in swap cache
15:11:36 kernel: Swap cache stats: add 0, delete 0, find 0/0
15:11:36 kernel: Free swap  = 16507900kB
15:11:36 kernel: Total swap = 16507900kB
15:11:36 kernel: 8388414 pages RAM
15:11:36 kernel: 0 pages HighMem/MovableOnly
15:11:36 kernel: 65682 pages reserved
15:11:36 kernel: 0 pages hwpoisoned
15:11:36 kernel: [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
15:11:36 kernel: [ 1345]     0  1345     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1346]     0  1346     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1347]     0  1347     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1348]     0  1348     3072      214      12        0             0 agetty
15:11:36 kernel: [ 1349]     0  1349     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1350]     0  1350     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1351]     0  1351     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1352]     0  1352     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1353]     0  1353     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1354]     0  1354     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1355]     0  1355     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1356]     0  1356     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1357]     0  1357     3072      214      11        0             0 agetty
15:11:36 kernel: [ 1358]     0  1358     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1359]     0  1359     3072      202      12        0             0 agetty
15:11:36 kernel: [ 1360]     0  1360     4928      157      14        0             0 rc.startup
15:11:36 kernel: [ 1361]     0  1361     3072      202      12        0             0 agetty
15:11:36 kernel: [ 1362]     0  1362     4928      157      14        0             0 rc.startup
15:11:36 kernel: [ 1430]     0  1430    29365      482      22        0             0 rsyslogd
15:11:36 kernel: [ 1436]     0  1436     7887      300      20        0         -1000 sshd
15:11:36 kernel: [ 1439]     0  1439     9030      343      18        0             0 automount
15:11:36 kernel: [ 1449]     0  1449     1012      113       8        0             0 iscsid
15:11:36 kernel: [ 1450]     0  1450     1135      623       8        0         -1000 iscsid
15:11:36 kernel: [ 1454] 65534  1454     3115      153      10        0             0 dnsmasq
15:11:36 kernel: [ 1456]     0  1456     3359      277      12        0             0 ntpd
15:11:36 kernel: [ 1509]     0  1509     3616      125       8        0         -1000 tgtd
15:11:36 kernel: [ 1511]     0  1511     1567       83       8        0         -1000 tgtd
15:11:36 kernel: [ 1526]     0  1526     7947      397      20        0             0 lighttpd
15:11:36 kernel: [ 1530]     0  1530     5651      423      17        0             0 elastic-sshd
15:11:36 kernel: [ 1968]     0  1968    36379      105      25        0             0 diod
15:11:36 kernel: [ 1995]    -2  1995     7972      824      20        0             0 httpd
15:11:36 kernel: [ 1997]    -2  1997     4921      372      15        0             0 elastic-poolio
15:11:36 kernel: [ 1999]    -2  1999    82317     1120      53        0             0 httpd
15:11:36 kernel: [ 2000]    -2  2000    82317     1119      53        0             0 httpd
15:11:36 kernel: [ 2001]    -2  2001    82317     1120      53        0             0 httpd
15:11:36 kernel: [ 2084]     0  2084     4928      219      14        0             0 elastic-floodwa
15:11:36 kernel: [ 2141]     0  2141     5130      446      15        0             0 elastic
15:11:36 kernel: [ 2283]     0  2283     5130      447      14        0             0 elastic
15:11:36 kernel: [ 2371]    -2  2371      962       93       7        0             0 contain
15:11:36 kernel: [ 2566]    -2  2566     2663      195      11        0             0 init
15:11:36 kernel: [ 2604]    -2  2604      962       93       7        0             0 contain
15:11:36 kernel: [ 2706]    -2  2706     2663      195      12        0             0 init
15:11:36 kernel: [ 3640]    -2  3640     2489      643       8        0             0 dhclient
15:11:36 kernel: [ 3727]    -2  3727     2489      643       8        0             0 dhclient
15:11:36 kernel: [ 3822]     0  3822     9614      689      24        0             0 sshd
15:11:36 kernel: [ 3834]    -2  3834    12147      384      22        0             0 rsyslogd
15:11:36 kernel: [ 3902]    -2  3902     4721      208      14        0             0 cron
15:11:36 kernel: [ 3912]    -2  3912    12147      384      22        0             0 rsyslogd
15:11:36 kernel: [ 3963]    -2  3963    12483      298      28        0             0 sshd
15:11:36 kernel: [ 3986]    -2  3986    12483      298      27        0             0 sshd
15:11:36 kernel: [ 3988]   102  3988    41432     4505      55        0             0 named
15:11:36 kernel: [ 4001]    -2  4001     3645      229      13        0             0 getty
15:11:36 kernel: [ 4019]    -2  4019     2335      365      10        0             0 mysqld_safe
15:11:36 kernel: [ 4353]   104  4353    88747    10609      59        0             0 mysqld
15:11:36 kernel: [ 4354]    -2  4354     1023      158       8        0             0 logger
15:11:36 kernel: [ 4357]   103  4357    24779     2424      40        0             0 postgres
15:11:36 kernel: [ 4386]     0  4386     4968      489      15        0             0 bash
15:11:36 kernel: [ 4392]   103  4392    24775      464      38        0             0 postgres
15:11:36 kernel: [ 4393]   103  4393    24775      406      36        0             0 postgres
15:11:36 kernel: [ 4394]   103  4394    24960      712      39        0             0 postgres
15:11:36 kernel: [ 4395]   103  4395    16883      418      34        0             0 postgres
15:11:36 kernel: [ 4540]    -2  4540    19001      793      41        0             0 apache2
15:11:36 kernel: [ 4548]    33  4548    18934      555      39        0             0 apache2
15:11:36 kernel: [ 4550]    33  4550    74860      663      68        0             0 apache2
15:11:36 kernel: [ 4551]    33  4551    74858      664      68        0             0 apache2
15:11:36 kernel: [ 4608]    -2  4608     4721      207      15        0             0 cron
15:11:36 kernel: [ 4625]    -2  4625     3645      229      13        0             0 getty
15:11:36 kernel: [ 5085]     0  5085     9579      689      24        0             0 sshd
15:11:36 kernel: [ 5088]     0  5088     4968      487      15        0             0 bash
15:11:36 kernel: [ 5098]     0  5098     2033      102      10        0             0 tail
15:11:36 kernel: [ 5102]     0  5102     7554      627      19        0             0 tar
15:11:36 kernel: [ 5163]     0  5163     1994      104       9        0             0 sleep
15:11:36 kernel: [ 5169]     0  5169     9579      690      23        0             0 sshd
15:11:36 kernel: [ 5172]     0  5172     3072      200      12        0             0 agetty
15:11:36 kernel: [ 5173]     0  5173     3072      201      12        0             0 agetty
15:11:36 kernel: [ 5174]     0  5174     4968      488      15        0             0 bash
15:11:36 kernel: Out of memory: Kill process 4353 (mysqld) score 0 or sacrifice child
15:11:36 kernel: Killed process 4353 (mysqld) total-vm:354988kB, anon-rss:35704kB, file-rss:6732kB
15:11:36 kernel: tar invoked oom-killer: gfp_mask=0x0, order=0, oom_score_adj=0
15:11:36 kernel: tar cpuset=test mems_allowed=0-1
15:11:36 kernel: CPU: 3 PID: 5102 Comm: tar Not tainted 3.14.0-elastic #1
15:11:36 kernel: Hardware name: Supermicro H8DMT-IBX/H8DMT-IBX, BIOS 080014  10/17/2009
15:11:36 kernel: ffff8804119696a0 ffff8800d56dfbf8 ffffffff8185d77b ffff880411969080
15:11:36 kernel: ffff880411969080 ffff8800d56dfca8 ffffffff8112b820 ffff8800d56dfc28
15:11:36 kernel: ffffffff81133deb ffff880409060590 ffff88040f73c500 ffff8800d56dfc38
15:11:36 kernel: Call Trace:
15:11:36 kernel: [<ffffffff8185d77b>] dump_stack+0x51/0x77
15:11:36 kernel: [<ffffffff8112b820>] dump_header+0x7a/0x208
15:11:36 kernel: [<ffffffff81133deb>] ? __put_single_page+0x1b/0x1f
15:11:36 kernel: [<ffffffff8113448f>] ? put_page+0x22/0x24
15:11:36 kernel: [<ffffffff81129e38>] ? filemap_fault+0x2c2/0x36c
15:11:36 kernel: [<ffffffff813d146e>] ? ___ratelimit+0xe6/0x104
15:11:36 kernel: [<ffffffff8112bc1b>] oom_kill_process+0x6a/0x33b
15:11:36 kernel: [<ffffffff810c9351>] ? has_capability_noaudit+0x12/0x14
15:11:36 kernel: [<ffffffff8112c306>] out_of_memory+0x41a/0x44d
15:11:36 kernel: [<ffffffff8112c39e>] pagefault_out_of_memory+0x65/0x77
15:11:36 kernel: [<ffffffff8106939e>] mm_fault_error+0xab/0x176
15:11:36 kernel: [<ffffffff810696f0>] __do_page_fault+0x287/0x3e2
15:11:36 kernel: [<ffffffff810f5018>] ? cpuacct_account_field+0x55/0x5d
15:11:36 kernel: [<ffffffff810f5018>] ? cpuacct_account_field+0x55/0x5d
15:11:36 kernel: [<ffffffff810e7816>] ? account_user_time+0x6e/0x97
15:11:36 kernel: [<ffffffff810e788c>] ? vtime_account_user+0x4d/0x52
15:11:36 kernel: [<ffffffff8106988f>] do_page_fault+0x44/0x61
15:11:36 kernel: [<ffffffff818618f8>] page_fault+0x28/0x30
15:11:36 kernel: Mem-Info:
15:11:36 kernel: Node 0 DMA per-cpu:
15:11:36 kernel: CPU    0: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    1: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    2: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    3: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    4: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    5: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    6: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    7: hi:    0, btch:   1 usd:   0
15:11:36 kernel: Node 0 DMA32 per-cpu:
15:11:36 kernel: CPU    0: hi:  186, btch:  31 usd: 133
15:11:36 kernel: CPU    1: hi:  186, btch:  31 usd: 155
15:11:36 kernel: CPU    2: hi:  186, btch:  31 usd:  55
15:11:36 kernel: CPU    3: hi:  186, btch:  31 usd: 162
15:11:36 kernel: CPU    4: hi:  186, btch:  31 usd:   0
15:11:36 kernel: CPU    5: hi:  186, btch:  31 usd: 160
15:11:36 kernel: CPU    6: hi:  186, btch:  31 usd:  18
15:11:36 kernel: CPU    7: hi:  186, btch:  31 usd:  35
15:11:36 kernel: Node 0 Normal per-cpu:
15:11:36 kernel: CPU    0: hi:  186, btch:  31 usd:  45
15:11:36 kernel: CPU    1: hi:  186, btch:  31 usd:  57
15:11:36 kernel: CPU    2: hi:  186, btch:  31 usd: 150
15:11:36 kernel: CPU    3: hi:  186, btch:  31 usd: 176
15:11:36 kernel: CPU    4: hi:  186, btch:  31 usd:  26
15:11:36 kernel: CPU    5: hi:  186, btch:  31 usd: 168
15:11:36 kernel: CPU    6: hi:  186, btch:  31 usd:   8
15:11:36 kernel: CPU    7: hi:  186, btch:  31 usd:  65
15:11:36 kernel: Node 1 Normal per-cpu:
15:11:36 kernel: CPU    0: hi:  186, btch:  31 usd:   1
15:11:36 kernel: CPU    1: hi:  186, btch:  31 usd:  12
15:11:36 kernel: CPU    2: hi:  186, btch:  31 usd:   0
15:11:36 kernel: CPU    3: hi:  186, btch:  31 usd: 115
15:11:36 kernel: CPU    4: hi:  186, btch:  31 usd:  12
15:11:36 kernel: CPU    5: hi:  186, btch:  31 usd: 131
15:11:36 kernel: CPU    6: hi:  186, btch:  31 usd: 174
15:11:36 kernel: CPU    7: hi:  186, btch:  31 usd: 113
15:11:36 kernel: active_anon:11418 inactive_anon:3312 isolated_anon:0
15:11:36 kernel: active_file:29061 inactive_file:151914 isolated_file:0
15:11:36 kernel: unevictable:621 dirty:354 writeback:38 unstable:0
15:11:36 kernel: free:7971790 slab_reclaimable:19802 slab_unreclaimable:7992
15:11:36 kernel: mapped:5661 shmem:1531 pagetables:1478 bounce:0
15:11:36 kernel: free_cma:0
15:11:36 kernel: Node 0 DMA free:15900kB min:40kB low:48kB high:60kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15984kB managed:15900kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
15:11:36 kernel: lowmem_reserve[]: 0 3425 16097 16097
15:11:36 kernel: Node 0 DMA32 free:3393084kB min:9572kB low:11964kB high:14356kB active_anon:4348kB inactive_anon:3572kB active_file:15064kB inactive_file:79976kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3522184kB managed:3509084kB mlocked:0kB dirty:4kB writeback:0kB mapped:4252kB shmem:1864kB slab_reclaimable:3504kB slab_unreclaimable:2268kB kernel_stack:880kB pagetables:1548kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
15:11:36 kernel: lowmem_reserve[]: 0 0 12671 12671
15:11:36 kernel: Node 0 Normal free:12258280kB min:35416kB low:44268kB high:53124kB active_anon:26212kB inactive_anon:6424kB active_file:63204kB inactive_file:435064kB unevictable:320kB isolated(anon):0kB isolated(file):0kB present:13238272kB managed:12975484kB mlocked:320kB dirty:0kB writeback:0kB mapped:6640kB shmem:3164kB slab_reclaimable:64444kB slab_unreclaimable:15760kB kernel_stack:1832kB pagetables:2584kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
15:11:36 kernel: lowmem_reserve[]: 0 0 0 0
15:11:36 kernel: Node 1 Normal free:16219896kB min:45076kB low:56344kB high:67612kB active_anon:15112kB inactive_anon:3252kB active_file:37976kB inactive_file:92616kB unevictable:2164kB isolated(anon):0kB isolated(file):0kB present:16777216kB managed:16514488kB mlocked:2164kB dirty:1412kB writeback:152kB mapped:11752kB shmem:1096kB slab_reclaimable:11260kB slab_unreclaimable:13940kB kernel_stack:1824kB pagetables:1780kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
15:11:36 kernel: lowmem_reserve[]: 0 0 0 0
15:11:36 kernel: Node 0 DMA: 1*4kB (U) 1*8kB (U) 1*16kB (U) 0*32kB 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) = 15900kB
15:11:36 kernel: Node 0 DMA32: 52*4kB (UEM) 66*8kB (UM) 35*16kB (UM) 13*32kB (UEM) 4*64kB (UM) 4*128kB (UE) 2*256kB (UM) 1*512kB (U) 0*1024kB 3*2048kB (MR) 826*4096kB (MR) = 3392944kB
15:11:36 kernel: Node 0 Normal: 51*4kB (UEM) 55*8kB (UEM) 14*16kB (UE) 31*32kB (UE) 14*64kB (UE) 5*128kB (UM) 2*256kB (UE) 2*512kB (UE) 2*1024kB (UM) 2*2048kB (M) 2990*4096kB (MR) = 12258116kB
15:11:36 kernel: Node 1 Normal: 245*4kB (UEM) 101*8kB (UEM) 21*16kB (UEM) 23*32kB (UEM) 19*64kB (UEM) 18*128kB (UEM) 9*256kB (M) 7*512kB (UEM) 2*1024kB (M) 3*2048kB (M) 3955*4096kB (MR) = 16220140kB
15:11:36 kernel: Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
15:11:36 kernel: Node 1 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
15:11:36 kernel: 183020 total pagecache pages
15:11:36 kernel: 0 pages in swap cache
15:11:36 kernel: Swap cache stats: add 0, delete 0, find 0/0
15:11:36 kernel: Free swap  = 16507900kB
15:11:36 kernel: Total swap = 16507900kB
15:11:36 kernel: 8388414 pages RAM
15:11:36 kernel: 0 pages HighMem/MovableOnly
15:11:36 kernel: 65682 pages reserved
15:11:36 kernel: 0 pages hwpoisoned
15:11:36 kernel: [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
15:11:36 kernel: [ 1345]     0  1345     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1346]     0  1346     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1347]     0  1347     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1348]     0  1348     3072      214      12        0             0 agetty
15:11:36 kernel: [ 1349]     0  1349     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1350]     0  1350     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1351]     0  1351     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1352]     0  1352     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1353]     0  1353     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1354]     0  1354     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1355]     0  1355     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1356]     0  1356     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1357]     0  1357     3072      214      11        0             0 agetty
15:11:36 kernel: [ 1358]     0  1358     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1359]     0  1359     3072      202      12        0             0 agetty
15:11:36 kernel: [ 1360]     0  1360     4928      157      14        0             0 rc.startup
15:11:36 kernel: [ 1361]     0  1361     3072      202      12        0             0 agetty
15:11:36 kernel: [ 1362]     0  1362     4928      157      14        0             0 rc.startup
15:11:36 kernel: [ 1430]     0  1430    29365      482      22        0             0 rsyslogd
15:11:36 kernel: [ 1436]     0  1436     7887      300      20        0         -1000 sshd
15:11:36 kernel: [ 1439]     0  1439     9030      343      18        0             0 automount
15:11:36 kernel: [ 1449]     0  1449     1012      113       8        0             0 iscsid
15:11:36 kernel: [ 1450]     0  1450     1135      623       8        0         -1000 iscsid
15:11:36 kernel: [ 1454] 65534  1454     3115      153      10        0             0 dnsmasq
15:11:36 kernel: [ 1456]     0  1456     3359      277      12        0             0 ntpd
15:11:36 kernel: [ 1509]     0  1509     3616      125       8        0         -1000 tgtd
15:11:36 kernel: [ 1511]     0  1511     1567       83       8        0         -1000 tgtd
15:11:36 kernel: [ 1526]     0  1526     7947      397      20        0             0 lighttpd
15:11:36 kernel: [ 1530]     0  1530     5651      423      17        0             0 elastic-sshd
15:11:36 kernel: [ 1968]     0  1968    36379      105      25        0             0 diod
15:11:36 kernel: [ 1995]    -2  1995     7972      824      20        0             0 httpd
15:11:36 kernel: [ 1997]    -2  1997     4921      372      15        0             0 elastic-poolio
15:11:36 kernel: [ 1999]    -2  1999    82317     1120      53        0             0 httpd
15:11:36 kernel: [ 2000]    -2  2000    82317     1119      53        0             0 httpd
15:11:36 kernel: [ 2001]    -2  2001    82317     1120      53        0             0 httpd
15:11:36 kernel: [ 2084]     0  2084     4928      219      14        0             0 elastic-floodwa
15:11:36 kernel: [ 2141]     0  2141     5130      446      15        0             0 elastic
15:11:36 kernel: [ 2283]     0  2283     5130      447      14        0             0 elastic
15:11:36 kernel: [ 2371]    -2  2371      962       93       7        0             0 contain
15:11:36 kernel: [ 2566]    -2  2566     2663      195      11        0             0 init
15:11:36 kernel: [ 2604]    -2  2604      962       93       7        0             0 contain
15:11:36 kernel: [ 2706]    -2  2706     2663      195      12        0             0 init
15:11:36 kernel: [ 3640]    -2  3640     2489      643       8        0             0 dhclient
15:11:36 kernel: [ 3727]    -2  3727     2489      643       8        0             0 dhclient
15:11:36 kernel: [ 3822]     0  3822     9614      689      24        0             0 sshd
15:11:36 kernel: [ 3834]    -2  3834    12147      384      22        0             0 rsyslogd
15:11:36 kernel: [ 3902]    -2  3902     4721      208      14        0             0 cron
15:11:36 kernel: [ 3912]    -2  3912    12147      384      22        0             0 rsyslogd
15:11:36 kernel: [ 3963]    -2  3963    12483      298      28        0             0 sshd
15:11:36 kernel: [ 3986]    -2  3986    12483      298      27        0             0 sshd
15:11:36 kernel: [ 3988]   102  3988    41432     4505      55        0             0 named
15:11:36 kernel: [ 4001]    -2  4001     3645      229      13        0             0 getty
15:11:36 kernel: [ 4019]    -2  4019     2335      365      10        0             0 mysqld_safe
15:11:36 kernel: [ 4357]   103  4357    24779     2424      40        0             0 postgres
15:11:36 kernel: [ 4386]     0  4386     4968      489      15        0             0 bash
15:11:36 kernel: [ 4392]   103  4392    24775      464      38        0             0 postgres
15:11:36 kernel: [ 4393]   103  4393    24775      406      36        0             0 postgres
15:11:36 kernel: [ 4394]   103  4394    24960      712      39        0             0 postgres
15:11:36 kernel: [ 4395]   103  4395    16883      418      34        0             0 postgres
15:11:36 kernel: [ 4540]    -2  4540    19001      793      41        0             0 apache2
15:11:36 kernel: [ 4548]    33  4548    18934      555      39        0             0 apache2
15:11:36 kernel: [ 4550]    33  4550    74860      663      68        0             0 apache2
15:11:36 kernel: [ 4551]    33  4551    74858      664      68        0             0 apache2
15:11:36 kernel: [ 4608]    -2  4608     4721      207      15        0             0 cron
15:11:36 kernel: [ 4625]    -2  4625     3645      229      13        0             0 getty
15:11:36 kernel: [ 5085]     0  5085     9579      689      24        0             0 sshd
15:11:36 kernel: [ 5088]     0  5088     4968      487      15        0             0 bash
15:11:36 kernel: [ 5098]     0  5098     2033      102      10        0             0 tail
15:11:36 kernel: [ 5102]     0  5102     7554      652      19        0             0 tar
15:11:36 kernel: [ 5163]     0  5163     1994      104       9        0             0 sleep
15:11:36 kernel: [ 5169]     0  5169     9579      690      23        0             0 sshd
15:11:36 kernel: [ 5172]     0  5172     3072      200      12        0             0 agetty
15:11:36 kernel: [ 5173]     0  5173     3072      201      12        0             0 agetty
15:11:36 kernel: [ 5174]     0  5174     4968      488      15        0             0 bash
15:11:36 kernel: Out of memory: Kill process 3988 (named) score 0 or sacrifice child
15:11:36 kernel: Killed process 3988 (named) total-vm:165728kB, anon-rss:15848kB, file-rss:2172kB
15:11:36 kernel: tar invoked oom-killer: gfp_mask=0x0, order=0, oom_score_adj=0
15:11:36 kernel: tar cpuset=test mems_allowed=0-1
15:11:36 kernel: CPU: 3 PID: 5102 Comm: tar Not tainted 3.14.0-elastic #1
15:11:36 kernel: Hardware name: Supermicro H8DMT-IBX/H8DMT-IBX, BIOS 080014  10/17/2009
15:11:36 kernel: ffff8804119696a0 ffff8800d56dfbf8 ffffffff8185d77b ffff880411969080
15:11:36 kernel: ffff880411969080 ffff8800d56dfca8 ffffffff8112b820 ffff8800d56dfc28
15:11:36 kernel: ffffffff81133deb ffff880409060590 ffff88040f73c500 ffff8800d56dfc38
15:11:36 kernel: Call Trace:
15:11:36 kernel: [<ffffffff8185d77b>] dump_stack+0x51/0x77
15:11:36 kernel: [<ffffffff8112b820>] dump_header+0x7a/0x208
15:11:36 kernel: [<ffffffff81133deb>] ? __put_single_page+0x1b/0x1f
15:11:36 kernel: [<ffffffff8113448f>] ? put_page+0x22/0x24
15:11:36 kernel: [<ffffffff81129e38>] ? filemap_fault+0x2c2/0x36c
15:11:36 kernel: [<ffffffff813d146e>] ? ___ratelimit+0xe6/0x104
15:11:36 kernel: [<ffffffff8112bc1b>] oom_kill_process+0x6a/0x33b
15:11:36 kernel: [<ffffffff810c9351>] ? has_capability_noaudit+0x12/0x14
15:11:36 kernel: [<ffffffff8112c306>] out_of_memory+0x41a/0x44d
15:11:36 kernel: [<ffffffff8112c39e>] pagefault_out_of_memory+0x65/0x77
15:11:36 kernel: [<ffffffff8106939e>] mm_fault_error+0xab/0x176
15:11:36 kernel: [<ffffffff810696f0>] __do_page_fault+0x287/0x3e2
15:11:36 kernel: [<ffffffff810f5018>] ? cpuacct_account_field+0x55/0x5d
15:11:36 kernel: [<ffffffff810f5018>] ? cpuacct_account_field+0x55/0x5d
15:11:36 kernel: [<ffffffff810e7816>] ? account_user_time+0x6e/0x97
15:11:36 kernel: [<ffffffff810e788c>] ? vtime_account_user+0x4d/0x52
15:11:36 kernel: [<ffffffff8106988f>] do_page_fault+0x44/0x61
15:11:36 kernel: [<ffffffff818618f8>] page_fault+0x28/0x30
15:11:36 kernel: Mem-Info:
15:11:36 kernel: Node 0 DMA per-cpu:
15:11:36 kernel: CPU    0: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    1: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    2: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    3: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    4: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    5: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    6: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    7: hi:    0, btch:   1 usd:   0
15:11:36 kernel: Node 0 DMA32 per-cpu:
15:11:36 kernel: CPU    0: hi:  186, btch:  31 usd: 133
15:11:36 kernel: CPU    1: hi:  186, btch:  31 usd: 155
15:11:36 kernel: CPU    2: hi:  186, btch:  31 usd:  55
15:11:36 kernel: CPU    3: hi:  186, btch:  31 usd: 162
15:11:36 kernel: CPU    4: hi:  186, btch:  31 usd:   0
15:11:36 kernel: CPU    5: hi:  186, btch:  31 usd: 160
15:11:36 kernel: CPU    6: hi:  186, btch:  31 usd:  18
15:11:36 kernel: CPU    7: hi:  186, btch:  31 usd:  35
15:11:36 kernel: Node 0 Normal per-cpu:
15:11:36 kernel: CPU    0: hi:  186, btch:  31 usd:  33
15:11:36 kernel: CPU    1: hi:  186, btch:  31 usd:  53
15:11:36 kernel: CPU    2: hi:  186, btch:  31 usd: 151
15:11:36 kernel: CPU    3: hi:  186, btch:  31 usd: 176
15:11:36 kernel: CPU    4: hi:  186, btch:  31 usd:  26
15:11:36 kernel: CPU    5: hi:  186, btch:  31 usd: 168
15:11:36 kernel: CPU    6: hi:  186, btch:  31 usd:   8
15:11:36 kernel: CPU    7: hi:  186, btch:  31 usd:  65
15:11:36 kernel: Node 1 Normal per-cpu:
15:11:36 kernel: CPU    0: hi:  186, btch:  31 usd:   1
15:11:36 kernel: CPU    1: hi:  186, btch:  31 usd:  12
15:11:36 kernel: CPU    2: hi:  186, btch:  31 usd:   0
15:11:36 kernel: CPU    3: hi:  186, btch:  31 usd: 115
15:11:36 kernel: CPU    4: hi:  186, btch:  31 usd: 100
15:11:36 kernel: CPU    5: hi:  186, btch:  31 usd:  44
15:11:36 kernel: CPU    6: hi:  186, btch:  31 usd: 155
15:11:36 kernel: CPU    7: hi:  186, btch:  31 usd: 137
15:11:36 kernel: active_anon:11808 inactive_anon:3312 isolated_anon:0
15:11:36 kernel: active_file:29061 inactive_file:151914 isolated_file:0
15:11:36 kernel: unevictable:621 dirty:354 writeback:38 unstable:0
15:11:36 kernel: free:7971490 slab_reclaimable:19802 slab_unreclaimable:7992
15:11:36 kernel: mapped:6534 shmem:1531 pagetables:1575 bounce:0
15:11:36 kernel: free_cma:0
15:11:36 kernel: Node 0 DMA free:15900kB min:40kB low:48kB high:60kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15984kB managed:15900kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
15:11:36 kernel: lowmem_reserve[]: 0 3425 16097 16097
15:11:36 kernel: Node 0 DMA32 free:3393084kB min:9572kB low:11964kB high:14356kB active_anon:4348kB inactive_anon:3572kB active_file:15064kB inactive_file:79976kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3522184kB managed:3509084kB mlocked:0kB dirty:4kB writeback:0kB mapped:4252kB shmem:1864kB slab_reclaimable:3504kB slab_unreclaimable:2268kB kernel_stack:880kB pagetables:1548kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
15:11:36 kernel: lowmem_reserve[]: 0 0 12671 12671
15:11:36 kernel: Node 0 Normal free:12258280kB min:35416kB low:44268kB high:53124kB active_anon:26212kB inactive_anon:6424kB active_file:63204kB inactive_file:435064kB unevictable:320kB isolated(anon):0kB isolated(file):0kB present:13238272kB managed:12975484kB mlocked:320kB dirty:0kB writeback:0kB mapped:10132kB shmem:3164kB slab_reclaimable:64444kB slab_unreclaimable:15760kB kernel_stack:1832kB pagetables:2584kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
15:11:36 kernel: lowmem_reserve[]: 0 0 0 0
15:11:36 kernel: Node 1 Normal free:16218696kB min:45076kB low:56344kB high:67612kB active_anon:16672kB inactive_anon:3252kB active_file:37976kB inactive_file:92616kB unevictable:2164kB isolated(anon):0kB isolated(file):0kB present:16777216kB managed:16514488kB mlocked:2164kB dirty:1412kB writeback:152kB mapped:11752kB shmem:1096kB slab_reclaimable:11260kB slab_unreclaimable:13940kB kernel_stack:1824kB pagetables:2168kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
15:11:36 kernel: lowmem_reserve[]: 0 0 0 0
15:11:36 kernel: Node 0 DMA: 1*4kB (U) 1*8kB (U) 1*16kB (U) 0*32kB 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) = 15900kB
15:11:36 kernel: Node 0 DMA32: 52*4kB (UEM) 66*8kB (UM) 35*16kB (UM) 13*32kB (UEM) 4*64kB (UM) 4*128kB (UE) 2*256kB (UM) 1*512kB (U) 0*1024kB 3*2048kB (MR) 826*4096kB (MR) = 3392944kB
15:11:36 kernel: Node 0 Normal: 51*4kB (UEM) 58*8kB (UEM) 14*16kB (UE) 31*32kB (UE) 14*64kB (UE) 5*128kB (UM) 2*256kB (UE) 2*512kB (UE) 2*1024kB (UM) 2*2048kB (M) 2990*4096kB (MR) = 12258140kB
15:11:36 kernel: Node 1 Normal: 90*4kB (UEM) 64*8kB (UEM) 7*16kB (UE) 12*32kB (UEM) 15*64kB (UEM) 17*128kB (UEM) 7*256kB (M) 7*512kB (UEM) 3*1024kB (M) 3*2048kB (M) 3955*4096kB (MR) = 16218776kB
15:11:36 kernel: Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
15:11:36 kernel: Node 1 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
15:11:36 kernel: 183020 total pagecache pages
15:11:36 kernel: 0 pages in swap cache
15:11:36 kernel: Swap cache stats: add 0, delete 0, find 0/0
15:11:36 kernel: Free swap  = 16507900kB
15:11:36 kernel: Total swap = 16507900kB
15:11:36 kernel: 8388414 pages RAM
15:11:36 kernel: 0 pages HighMem/MovableOnly
15:11:36 kernel: 65682 pages reserved
15:11:36 kernel: 0 pages hwpoisoned
15:11:36 kernel: [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
15:11:36 kernel: [ 1345]     0  1345     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1346]     0  1346     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1347]     0  1347     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1348]     0  1348     3072      214      12        0             0 agetty
15:11:36 kernel: [ 1349]     0  1349     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1350]     0  1350     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1351]     0  1351     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1352]     0  1352     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1353]     0  1353     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1354]     0  1354     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1355]     0  1355     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1356]     0  1356     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1357]     0  1357     3072      214      11        0             0 agetty
15:11:36 kernel: [ 1358]     0  1358     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1359]     0  1359     3072      202      12        0             0 agetty
15:11:36 kernel: [ 1360]     0  1360     4928      157      14        0             0 rc.startup
15:11:36 kernel: [ 1361]     0  1361     3072      202      12        0             0 agetty
15:11:36 kernel: [ 1362]     0  1362     4928      157      14        0             0 rc.startup
15:11:36 kernel: [ 1430]     0  1430    29365      482      22        0             0 rsyslogd
15:11:36 kernel: [ 1436]     0  1436     7887      300      20        0         -1000 sshd
15:11:36 kernel: [ 1439]     0  1439     9030      343      18        0             0 automount
15:11:36 kernel: [ 1449]     0  1449     1012      113       8        0             0 iscsid
15:11:36 kernel: [ 1450]     0  1450     1135      623       8        0         -1000 iscsid
15:11:36 kernel: [ 1454] 65534  1454     3115      153      10        0             0 dnsmasq
15:11:36 kernel: [ 1456]     0  1456     3359      277      12        0             0 ntpd
15:11:36 kernel: [ 1509]     0  1509     3616      125       8        0         -1000 tgtd
15:11:36 kernel: [ 1511]     0  1511     1567       83       8        0         -1000 tgtd
15:11:36 kernel: [ 1526]     0  1526     7947      397      20        0             0 lighttpd
15:11:36 kernel: [ 1530]     0  1530     5651      423      17        0             0 elastic-sshd
15:11:36 kernel: [ 1968]     0  1968    36379      105      25        0             0 diod
15:11:36 kernel: [ 1995]    -2  1995     7972      824      20        0             0 httpd
15:11:36 kernel: [ 1997]    -2  1997     4921      372      15        0             0 elastic-poolio
15:11:36 kernel: [ 1999]    -2  1999    82317     1120      53        0             0 httpd
15:11:36 kernel: [ 2000]    -2  2000    82317     1119      53        0             0 httpd
15:11:36 kernel: [ 2001]    -2  2001    82317     1120      53        0             0 httpd
15:11:36 kernel: [ 2084]     0  2084     4928      219      14        0             0 elastic-floodwa
15:11:36 kernel: [ 2141]     0  2141     5130      446      15        0             0 elastic
15:11:36 kernel: [ 2283]     0  2283     5130      447      14        0             0 elastic
15:11:36 kernel: [ 2371]    -2  2371      962       93       7        0             0 contain
15:11:36 kernel: [ 2566]    -2  2566     2663      195      11        0             0 init
15:11:36 kernel: [ 2604]    -2  2604      962       93       7        0             0 contain
15:11:36 kernel: [ 2706]    -2  2706     2663      195      12        0             0 init
15:11:36 kernel: [ 3640]    -2  3640     2489      643       8        0             0 dhclient
15:11:36 kernel: [ 3727]    -2  3727     2489      643       8        0             0 dhclient
15:11:36 kernel: [ 3822]     0  3822     9614      689      24        0             0 sshd
15:11:36 kernel: [ 3834]    -2  3834    12147      384      22        0             0 rsyslogd
15:11:36 kernel: [ 3902]    -2  3902     4721      208      14        0             0 cron
15:11:36 kernel: [ 3912]    -2  3912    12147      384      22        0             0 rsyslogd
15:11:36 kernel: [ 3963]    -2  3963    12483      298      28        0             0 sshd
15:11:36 kernel: [ 3986]    -2  3986    12483      298      27        0             0 sshd
15:11:36 kernel: [ 4001]    -2  4001     3645      229      13        0             0 getty
15:11:36 kernel: [ 4019]    -2  4019     2336      366      10        0             0 mysqld_safe
15:11:36 kernel: [ 4357]   103  4357    24779     2424      40        0             0 postgres
15:11:36 kernel: [ 4386]     0  4386     4968      489      15        0             0 bash
15:11:36 kernel: [ 4392]   103  4392    24775      464      38        0             0 postgres
15:11:36 kernel: [ 4393]   103  4393    24775      406      36        0             0 postgres
15:11:36 kernel: [ 4394]   103  4394    24960      712      39        0             0 postgres
15:11:36 kernel: [ 4395]   103  4395    16883      418      34        0             0 postgres
15:11:36 kernel: [ 4540]    -2  4540    19001      793      41        0             0 apache2
15:11:36 kernel: [ 4548]    33  4548    18934      555      39        0             0 apache2
15:11:36 kernel: [ 4550]    33  4550    74860      663      68        0             0 apache2
15:11:36 kernel: [ 4551]    33  4551    74858      664      68        0             0 apache2
15:11:36 kernel: [ 4608]    -2  4608     4721      207      15        0             0 cron
15:11:36 kernel: [ 4625]    -2  4625     3645      229      13        0             0 getty
15:11:36 kernel: [ 5085]     0  5085     9579      689      24        0             0 sshd
15:11:36 kernel: [ 5088]     0  5088     4968      487      15        0             0 bash
15:11:36 kernel: [ 5098]     0  5098     2033      102      10        0             0 tail
15:11:36 kernel: [ 5102]     0  5102     7554      652      19        0             0 tar
15:11:36 kernel: [ 5163]     0  5163     1994      104       9        0             0 sleep
15:11:36 kernel: [ 5169]     0  5169     9579      690      23        0             0 sshd
15:11:36 kernel: [ 5172]     0  5172     3072      200      12        0             0 agetty
15:11:36 kernel: [ 5173]     0  5173     3072      201      12        0             0 agetty
15:11:36 kernel: [ 5174]     0  5174     4968      488      15        0             0 bash
15:11:36 kernel: [ 5197]    -2  5197    12302     1440      25        0             0 mysqld
15:11:36 kernel: [ 5198]    -2  5198     1023      158       8        0             0 logger
15:11:36 kernel: Out of memory: Kill process 4357 (postgres) score 0 or sacrifice child
15:11:36 kernel: Killed process 4394 (postgres) total-vm:99840kB, anon-rss:1844kB, file-rss:1004kB
15:11:36 kernel: tar invoked oom-killer: gfp_mask=0x0, order=0, oom_score_adj=0
15:11:36 kernel: tar cpuset=test mems_allowed=0-1
15:11:36 kernel: CPU: 3 PID: 5102 Comm: tar Not tainted 3.14.0-elastic #1
15:11:36 kernel: Hardware name: Supermicro H8DMT-IBX/H8DMT-IBX, BIOS 080014  10/17/2009
15:11:36 kernel: ffff8804119696a0 ffff8800d56dfbf8 ffffffff8185d77b ffff880411969080
15:11:36 kernel: ffff880411969080 ffff8800d56dfca8 ffffffff8112b820 ffff8800d56dfc28
15:11:36 kernel: ffffffff81133deb ffff880409060590 ffff88040f73c500 ffff8800d56dfc38
15:11:36 kernel: Call Trace:
15:11:36 kernel: [<ffffffff8185d77b>] dump_stack+0x51/0x77
15:11:36 kernel: [<ffffffff8112b820>] dump_header+0x7a/0x208
15:11:36 kernel: [<ffffffff81133deb>] ? __put_single_page+0x1b/0x1f
15:11:36 kernel: [<ffffffff8113448f>] ? put_page+0x22/0x24
15:11:36 kernel: [<ffffffff81129e38>] ? filemap_fault+0x2c2/0x36c
15:11:36 kernel: [<ffffffff813d146e>] ? ___ratelimit+0xe6/0x104
15:11:36 kernel: [<ffffffff8112bc1b>] oom_kill_process+0x6a/0x33b
15:11:36 kernel: [<ffffffff810c9351>] ? has_capability_noaudit+0x12/0x14
15:11:36 kernel: [<ffffffff8112c306>] out_of_memory+0x41a/0x44d
15:11:36 kernel: [<ffffffff8112c39e>] pagefault_out_of_memory+0x65/0x77
15:11:36 kernel: [<ffffffff8106939e>] mm_fault_error+0xab/0x176
15:11:36 kernel: [<ffffffff810696f0>] __do_page_fault+0x287/0x3e2
15:11:36 kernel: [<ffffffff810f5018>] ? cpuacct_account_field+0x55/0x5d
15:11:36 kernel: [<ffffffff810f5018>] ? cpuacct_account_field+0x55/0x5d
15:11:36 kernel: [<ffffffff810e7816>] ? account_user_time+0x6e/0x97
15:11:36 kernel: [<ffffffff810e788c>] ? vtime_account_user+0x4d/0x52
15:11:36 kernel: [<ffffffff8106988f>] do_page_fault+0x44/0x61
15:11:36 kernel: [<ffffffff818618f8>] page_fault+0x28/0x30
15:11:36 kernel: Mem-Info:
15:11:36 kernel: Node 0 DMA per-cpu:
15:11:36 kernel: CPU    0: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    1: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    2: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    3: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    4: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    5: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    6: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    7: hi:    0, btch:   1 usd:   0
15:11:36 kernel: Node 0 DMA32 per-cpu:
15:11:36 kernel: CPU    0: hi:  186, btch:  31 usd: 133
15:11:36 kernel: CPU    1: hi:  186, btch:  31 usd: 155
15:11:36 kernel: CPU    2: hi:  186, btch:  31 usd:  55
15:11:36 kernel: CPU    3: hi:  186, btch:  31 usd: 162
15:11:36 kernel: CPU    4: hi:  186, btch:  31 usd:   3
15:11:36 kernel: CPU    5: hi:  186, btch:  31 usd: 160
15:11:36 kernel: CPU    6: hi:  186, btch:  31 usd:  18
15:11:36 kernel: CPU    7: hi:  186, btch:  31 usd: 162
15:11:36 kernel: Node 0 Normal per-cpu:
15:11:36 kernel: CPU    0: hi:  186, btch:  31 usd:  30
15:11:36 kernel: CPU    1: hi:  186, btch:  31 usd:  51
15:11:36 kernel: CPU    2: hi:  186, btch:  31 usd: 185
15:11:36 kernel: CPU    3: hi:  186, btch:  31 usd: 176
15:11:36 kernel: CPU    4: hi:  186, btch:  31 usd:  35
15:11:36 kernel: CPU    5: hi:  186, btch:  31 usd: 168
15:11:36 kernel: CPU    6: hi:  186, btch:  31 usd:   8
15:11:36 kernel: CPU    7: hi:  186, btch:  31 usd: 185
15:11:36 kernel: Node 1 Normal per-cpu:
15:11:36 kernel: CPU    0: hi:  186, btch:  31 usd:   1
15:11:36 kernel: CPU    1: hi:  186, btch:  31 usd:  12
15:11:36 kernel: CPU    2: hi:  186, btch:  31 usd:   1
15:11:36 kernel: CPU    3: hi:  186, btch:  31 usd: 115
15:11:36 kernel: CPU    4: hi:  186, btch:  31 usd: 104
15:11:36 kernel: CPU    5: hi:  186, btch:  31 usd:  47
15:11:36 kernel: CPU    6: hi:  186, btch:  31 usd: 155
15:11:36 kernel: CPU    7: hi:  186, btch:  31 usd: 173
15:11:36 kernel: active_anon:10570 inactive_anon:2937 isolated_anon:0
15:11:36 kernel: active_file:29061 inactive_file:151914 isolated_file:0
15:11:36 kernel: unevictable:621 dirty:354 writeback:38 unstable:0
15:11:36 kernel: free:7972794 slab_reclaimable:19802 slab_unreclaimable:7927
15:11:36 kernel: mapped:6267 shmem:1531 pagetables:1575 bounce:0
15:11:36 kernel: free_cma:0
15:11:36 kernel: Node 0 DMA free:15900kB min:40kB low:48kB high:60kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15984kB managed:15900kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
15:11:36 kernel: lowmem_reserve[]: 0 3425 16097 16097
15:11:36 kernel: Node 0 DMA32 free:3395828kB min:9572kB low:11964kB high:14356kB active_anon:1996kB inactive_anon:2592kB active_file:15064kB inactive_file:79976kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3522184kB managed:3509084kB mlocked:0kB dirty:4kB writeback:0kB mapped:3960kB shmem:1864kB slab_reclaimable:3504kB slab_unreclaimable:2268kB kernel_stack:880kB pagetables:1548kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
15:11:36 kernel: lowmem_reserve[]: 0 0 12671 12671
15:11:36 kernel: Node 0 Normal free:12270500kB min:35416kB low:44268kB high:53124kB active_anon:14252kB inactive_anon:5904kB active_file:63204kB inactive_file:435064kB unevictable:320kB isolated(anon):0kB isolated(file):0kB present:13238272kB managed:12975484kB mlocked:320kB dirty:0kB writeback:0kB mapped:10520kB shmem:3164kB slab_reclaimable:64444kB slab_unreclaimable:15760kB kernel_stack:1832kB pagetables:2584kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
15:11:36 kernel: lowmem_reserve[]: 0 0 0 0
15:11:36 kernel: Node 1 Normal free:16208948kB min:45076kB low:56344kB high:67612kB active_anon:26032kB inactive_anon:3252kB active_file:37976kB inactive_file:92616kB unevictable:2164kB isolated(anon):0kB isolated(file):0kB present:16777216kB managed:16514488kB mlocked:2164kB dirty:1412kB writeback:152kB mapped:10588kB shmem:1096kB slab_reclaimable:11260kB slab_unreclaimable:13680kB kernel_stack:1824kB pagetables:2168kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
15:11:36 kernel: lowmem_reserve[]: 0 0 0 0
15:11:36 kernel: Node 0 DMA: 1*4kB (U) 1*8kB (U) 1*16kB (U) 0*32kB 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) = 15900kB
15:11:36 kernel: Node 0 DMA32: 137*4kB (UEM) 92*8kB (UM) 49*16kB (UM) 26*32kB (UEM) 12*64kB (UM) 11*128kB (UEM) 3*256kB (UM) 1*512kB (U) 0*1024kB 3*2048kB (MR) 826*4096kB (MR) = 3395796kB
15:11:36 kernel: Node 0 Normal: 337*4kB (UM) 138*8kB (UEM) 47*16kB (UEM) 47*32kB (UEM) 22*64kB (UEM) 10*128kB (UM) 2*256kB (UE) 3*512kB (UEM) 4*1024kB (UM) 3*2048kB (M) 2991*4096kB (MR) = 12270820kB
15:11:36 kernel: Node 1 Normal: 44*4kB (UEM) 70*8kB (UE) 9*16kB (UEM) 9*32kB (U) 6*64kB (U) 10*128kB (UE) 0*256kB 3*512kB (UEM) 1*1024kB (M) 2*2048kB (M) 3955*4096kB (MR) = 16209168kB
15:11:36 kernel: Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
15:11:36 kernel: Node 1 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
15:11:36 kernel: 183117 total pagecache pages
15:11:36 kernel: 0 pages in swap cache
15:11:36 kernel: Swap cache stats: add 0, delete 0, find 0/0
15:11:36 kernel: Free swap  = 16507900kB
15:11:36 kernel: Total swap = 16507900kB
15:11:36 kernel: 8388414 pages RAM
15:11:36 kernel: 0 pages HighMem/MovableOnly
15:11:36 kernel: 65682 pages reserved
15:11:36 kernel: 0 pages hwpoisoned
15:11:36 kernel: [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
15:11:36 kernel: [ 1345]     0  1345     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1346]     0  1346     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1347]     0  1347     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1348]     0  1348     3072      214      12        0             0 agetty
15:11:36 kernel: [ 1349]     0  1349     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1350]     0  1350     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1351]     0  1351     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1352]     0  1352     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1353]     0  1353     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1354]     0  1354     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1355]     0  1355     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1356]     0  1356     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1357]     0  1357     3072      214      11        0             0 agetty
15:11:36 kernel: [ 1358]     0  1358     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1359]     0  1359     3072      202      12        0             0 agetty
15:11:36 kernel: [ 1360]     0  1360     4928      157      14        0             0 rc.startup
15:11:36 kernel: [ 1361]     0  1361     3072      202      12        0             0 agetty
15:11:36 kernel: [ 1362]     0  1362     4928      157      14        0             0 rc.startup
15:11:36 kernel: [ 1430]     0  1430    29365      482      22        0             0 rsyslogd
15:11:36 kernel: [ 1436]     0  1436     7887      300      20        0         -1000 sshd
15:11:36 kernel: [ 1439]     0  1439     9030      343      18        0             0 automount
15:11:36 kernel: [ 1449]     0  1449     1012      113       8        0             0 iscsid
15:11:36 kernel: [ 1450]     0  1450     1135      623       8        0         -1000 iscsid
15:11:36 kernel: [ 1454] 65534  1454     3115      153      10        0             0 dnsmasq
15:11:36 kernel: [ 1456]     0  1456     3359      277      12        0             0 ntpd
15:11:36 kernel: [ 1509]     0  1509     3616      125       8        0         -1000 tgtd
15:11:36 kernel: [ 1511]     0  1511     1567       83       8        0         -1000 tgtd
15:11:36 kernel: [ 1526]     0  1526     7947      397      20        0             0 lighttpd
15:11:36 kernel: [ 1530]     0  1530     5651      423      17        0             0 elastic-sshd
15:11:36 kernel: [ 1968]     0  1968    36379      105      25        0             0 diod
15:11:36 kernel: [ 1995]    -2  1995     7972      824      20        0             0 httpd
15:11:36 kernel: [ 1997]    -2  1997     4921      372      15        0             0 elastic-poolio
15:11:36 kernel: [ 1999]    -2  1999    82317     1120      53        0             0 httpd
15:11:36 kernel: [ 2000]    -2  2000    82317     1119      53        0             0 httpd
15:11:36 kernel: [ 2001]    -2  2001    82317     1120      53        0             0 httpd
15:11:36 kernel: [ 2084]     0  2084     4928      219      14        0             0 elastic-floodwa
15:11:36 kernel: [ 2141]     0  2141     5130      446      15        0             0 elastic
15:11:36 kernel: [ 2283]     0  2283     5130      447      14        0             0 elastic
15:11:36 kernel: [ 2371]    -2  2371      962       93       7        0             0 contain
15:11:36 kernel: [ 2566]    -2  2566     2663      195      11        0             0 init
15:11:36 kernel: [ 2604]    -2  2604      962       93       7        0             0 contain
15:11:36 kernel: [ 2706]    -2  2706     2663      195      12        0             0 init
15:11:36 kernel: [ 3640]    -2  3640     2489      643       8        0             0 dhclient
15:11:36 kernel: [ 3727]    -2  3727     2489      643       8        0             0 dhclient
15:11:36 kernel: [ 3822]     0  3822     9614      689      24        0             0 sshd
15:11:36 kernel: [ 3834]    -2  3834    12147      384      22        0             0 rsyslogd
15:11:36 kernel: [ 3902]    -2  3902     4721      208      14        0             0 cron
15:11:36 kernel: [ 3912]    -2  3912    12147      384      22        0             0 rsyslogd
15:11:36 kernel: [ 3963]    -2  3963    12483      298      28        0             0 sshd
15:11:36 kernel: [ 3986]    -2  3986    12483      298      27        0             0 sshd
15:11:36 kernel: [ 4001]    -2  4001     3645      229      13        0             0 getty
15:11:36 kernel: [ 4019]    -2  4019     2336      366      10        0             0 mysqld_safe
15:11:36 kernel: [ 4357]   103  4357    24779     2424      40        0             0 postgres
15:11:36 kernel: [ 4386]     0  4386     4968      489      15        0             0 bash
15:11:36 kernel: [ 4392]   103  4392    24775      464      38        0             0 postgres
15:11:36 kernel: [ 4393]   103  4393    24775      452      36        0             0 postgres
15:11:36 kernel: [ 4395]   103  4395    16883      418      34        0             0 postgres
15:11:36 kernel: [ 4540]    -2  4540    19001      793      41        0             0 apache2
15:11:36 kernel: [ 4548]    33  4548    18934      555      39        0             0 apache2
15:11:36 kernel: [ 4550]    33  4550    74860      663      68        0             0 apache2
15:11:36 kernel: [ 4551]    33  4551    74858      664      68        0             0 apache2
15:11:36 kernel: [ 4608]    -2  4608     4721      207      15        0             0 cron
15:11:36 kernel: [ 4625]    -2  4625     3645      229      13        0             0 getty
15:11:36 kernel: [ 5085]     0  5085     9579      689      24        0             0 sshd
15:11:36 kernel: [ 5088]     0  5088     4968      487      15        0             0 bash
15:11:36 kernel: [ 5098]     0  5098     2033      102      10        0             0 tail
15:11:36 kernel: [ 5102]     0  5102     7554      652      19        0             0 tar
15:11:36 kernel: [ 5163]     0  5163     1994      104       9        0             0 sleep
15:11:36 kernel: [ 5169]     0  5169     9579      690      23        0             0 sshd
15:11:36 kernel: [ 5172]     0  5172     3072      200      12        0             0 agetty
15:11:36 kernel: [ 5173]     0  5173     3072      201      12        0             0 agetty
15:11:36 kernel: [ 5174]     0  5174     4968      488      15        0             0 bash
15:11:36 kernel: [ 5197]   104  5197    57326     4132      35        0             0 mysqld
15:11:36 kernel: [ 5198]    -2  5198     1023      158       8        0             0 logger
15:11:36 kernel: Out of memory: Kill process 5197 (mysqld) score 0 or sacrifice child
15:11:36 kernel: Killed process 5197 (mysqld) total-vm:231548kB, anon-rss:17736kB, file-rss:5256kB
15:11:36 kernel: tar invoked oom-killer: gfp_mask=0x0, order=0, oom_score_adj=0
15:11:36 kernel: tar cpuset=test mems_allowed=0-1
15:11:36 kernel: CPU: 3 PID: 5102 Comm: tar Not tainted 3.14.0-elastic #1
15:11:36 kernel: Hardware name: Supermicro H8DMT-IBX/H8DMT-IBX, BIOS 080014  10/17/2009
15:11:36 kernel: ffff8804119696a0 ffff8800d56dfbf8 ffffffff8185d77b ffff880411969080
15:11:36 kernel: ffff880411969080 ffff8800d56dfca8 ffffffff8112b820 ffff8800d56dfc28
15:11:36 kernel: ffffffff81133deb ffff880409060590 ffff88040f73c500 ffff8800d56dfc38
15:11:36 kernel: Call Trace:
15:11:36 kernel: [<ffffffff8185d77b>] dump_stack+0x51/0x77
15:11:36 kernel: [<ffffffff8112b820>] dump_header+0x7a/0x208
15:11:36 kernel: [<ffffffff81133deb>] ? __put_single_page+0x1b/0x1f
15:11:36 kernel: [<ffffffff8113448f>] ? put_page+0x22/0x24
15:11:36 kernel: [<ffffffff81129e38>] ? filemap_fault+0x2c2/0x36c
15:11:36 kernel: [<ffffffff813d146e>] ? ___ratelimit+0xe6/0x104
15:11:36 kernel: [<ffffffff8112bc1b>] oom_kill_process+0x6a/0x33b
15:11:36 kernel: [<ffffffff8112c306>] out_of_memory+0x41a/0x44d
15:11:36 kernel: [<ffffffff8112c39e>] pagefault_out_of_memory+0x65/0x77
15:11:36 kernel: [<ffffffff8106939e>] mm_fault_error+0xab/0x176
15:11:36 kernel: [<ffffffff810696f0>] __do_page_fault+0x287/0x3e2
15:11:36 kernel: [<ffffffff810f5018>] ? cpuacct_account_field+0x55/0x5d
15:11:36 kernel: [<ffffffff810f5018>] ? cpuacct_account_field+0x55/0x5d
15:11:36 kernel: [<ffffffff810e7816>] ? account_user_time+0x6e/0x97
15:11:36 kernel: [<ffffffff810e788c>] ? vtime_account_user+0x4d/0x52
15:11:36 kernel: [<ffffffff8106988f>] do_page_fault+0x44/0x61
15:11:36 kernel: [<ffffffff818618f8>] page_fault+0x28/0x30
15:11:36 kernel: Mem-Info:
15:11:36 kernel: Node 0 DMA per-cpu:
15:11:36 kernel: CPU    0: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    1: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    2: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    3: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    4: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    5: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    6: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    7: hi:    0, btch:   1 usd:   0
15:11:36 kernel: Node 0 DMA32 per-cpu:
15:11:36 kernel: CPU    0: hi:  186, btch:  31 usd: 176
15:11:36 kernel: CPU    1: hi:  186, btch:  31 usd: 166
15:11:36 kernel: CPU    2: hi:  186, btch:  31 usd:  67
15:11:36 kernel: CPU    3: hi:  186, btch:  31 usd: 162
15:11:36 kernel: CPU    4: hi:  186, btch:  31 usd:   3
15:11:36 kernel: CPU    5: hi:  186, btch:  31 usd: 160
15:11:36 kernel: CPU    6: hi:  186, btch:  31 usd:  18
15:11:36 kernel: CPU    7: hi:  186, btch:  31 usd: 162
15:11:36 kernel: Node 0 Normal per-cpu:
15:11:36 kernel: CPU    0: hi:  186, btch:  31 usd: 197
15:11:36 kernel: CPU    1: hi:  186, btch:  31 usd:  82
15:11:36 kernel: CPU    2: hi:  186, btch:  31 usd: 185
15:11:36 kernel: CPU    3: hi:  186, btch:  31 usd: 176
15:11:36 kernel: CPU    4: hi:  186, btch:  31 usd:  35
15:11:36 kernel: CPU    5: hi:  186, btch:  31 usd: 168
15:11:36 kernel: CPU    6: hi:  186, btch:  31 usd:   8
15:11:36 kernel: CPU    7: hi:  186, btch:  31 usd: 185
15:11:36 kernel: Node 1 Normal per-cpu:
15:11:36 kernel: CPU    0: hi:  186, btch:  31 usd: 178
15:11:36 kernel: CPU    1: hi:  186, btch:  31 usd:  46
15:11:36 kernel: CPU    2: hi:  186, btch:  31 usd:   2
15:11:36 kernel: CPU    3: hi:  186, btch:  31 usd: 115
15:11:36 kernel: CPU    4: hi:  186, btch:  31 usd: 104
15:11:36 kernel: CPU    5: hi:  186, btch:  31 usd: 156
15:11:36 kernel: CPU    6: hi:  186, btch:  31 usd: 164
15:11:36 kernel: CPU    7: hi:  186, btch:  31 usd: 173
15:11:36 kernel: active_anon:7704 inactive_anon:1830 isolated_anon:0
15:11:36 kernel: active_file:29305 inactive_file:151670 isolated_file:0
15:11:36 kernel: unevictable:621 dirty:354 writeback:38 unstable:0
15:11:36 kernel: free:7976547 slab_reclaimable:19802 slab_unreclaimable:7927
15:11:36 kernel: mapped:4180 shmem:220 pagetables:1478 bounce:0
15:11:36 kernel: free_cma:0
15:11:36 kernel: Node 0 DMA free:15900kB min:40kB low:48kB high:60kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15984kB managed:15900kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
15:11:36 kernel: lowmem_reserve[]: 0 3425 16097 16097
15:11:36 kernel: Node 0 DMA32 free:3397200kB min:9572kB low:11964kB high:14356kB active_anon:1996kB inactive_anon:1024kB active_file:15260kB inactive_file:79780kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3522184kB managed:3509084kB mlocked:0kB dirty:4kB writeback:0kB mapped:2208kB shmem:112kB slab_reclaimable:3504kB slab_unreclaimable:2268kB kernel_stack:880kB pagetables:1548kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
15:11:36 kernel: lowmem_reserve[]: 0 0 12671 12671
15:11:36 kernel: Node 0 Normal free:12273064kB min:35416kB low:44268kB high:53124kB active_anon:14252kB inactive_anon:3304kB active_file:63984kB inactive_file:434284kB unevictable:320kB isolated(anon):0kB isolated(file):0kB present:13238272kB managed:12975484kB mlocked:320kB dirty:0kB writeback:0kB mapped:3924kB shmem:448kB slab_reclaimable:64444kB slab_unreclaimable:15760kB kernel_stack:1832kB pagetables:2196kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
15:11:36 kernel: lowmem_reserve[]: 0 0 0 0
15:11:36 kernel: Node 1 Normal free:16220024kB min:45076kB low:56344kB high:67612kB active_anon:14568kB inactive_anon:2992kB active_file:37976kB inactive_file:92616kB unevictable:2164kB isolated(anon):0kB isolated(file):0kB present:16777216kB managed:16514488kB mlocked:2164kB dirty:1412kB writeback:152kB mapped:10588kB shmem:320kB slab_reclaimable:11260kB slab_unreclaimable:13680kB kernel_stack:1824kB pagetables:2168kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
15:11:36 kernel: lowmem_reserve[]: 0 0 0 0
15:11:36 kernel: Node 0 DMA: 1*4kB (U) 1*8kB (U) 1*16kB (U) 0*32kB 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) = 15900kB
15:11:36 kernel: Node 0 DMA32: 229*4kB (UEM) 117*8kB (UEM) 56*16kB (UEM) 29*32kB (UEM) 13*64kB (UM) 12*128kB (UEM) 4*256kB (UM) 2*512kB (UM) 0*1024kB 3*2048kB (MR) 826*4096kB (MR) = 3397532kB
15:11:36 kernel: Node 0 Normal: 314*4kB (UEM) 156*8kB (UEM) 55*16kB (UEM) 51*32kB (UEM) 24*64kB (UEM) 11*128kB (UM) 5*256kB (UEM) 5*512kB (UEM) 4*1024kB (UM) 3*2048kB (M) 2991*4096kB (MR) = 12273176kB
15:11:36 kernel: Node 1 Normal: 276*4kB (UEM) 126*8kB (UEM) 31*16kB (UEM) 28*32kB (UEM) 20*64kB (UM) 20*128kB (UEM) 7*256kB (M) 9*512kB (UEM) 3*1024kB (M) 2*2048kB (M) 3955*4096kB (MR) = 16220592kB
15:11:36 kernel: Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
15:11:36 kernel: Node 1 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
15:11:36 kernel: 181806 total pagecache pages
15:11:36 kernel: 0 pages in swap cache
15:11:36 kernel: Swap cache stats: add 0, delete 0, find 0/0
15:11:36 kernel: Free swap  = 16507900kB
15:11:36 kernel: Total swap = 16507900kB
15:11:36 kernel: 8388414 pages RAM
15:11:36 kernel: 0 pages HighMem/MovableOnly
15:11:36 kernel: 65682 pages reserved
15:11:36 kernel: 0 pages hwpoisoned
15:11:36 kernel: [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
15:11:36 kernel: [ 1345]     0  1345     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1346]     0  1346     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1347]     0  1347     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1348]     0  1348     3072      214      12        0             0 agetty
15:11:36 kernel: [ 1349]     0  1349     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1350]     0  1350     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1351]     0  1351     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1352]     0  1352     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1353]     0  1353     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1354]     0  1354     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1355]     0  1355     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1356]     0  1356     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1357]     0  1357     3072      214      11        0             0 agetty
15:11:36 kernel: [ 1358]     0  1358     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1359]     0  1359     3072      202      12        0             0 agetty
15:11:36 kernel: [ 1360]     0  1360     4928      157      14        0             0 rc.startup
15:11:36 kernel: [ 1361]     0  1361     3072      202      12        0             0 agetty
15:11:36 kernel: [ 1362]     0  1362     4928      157      14        0             0 rc.startup
15:11:36 kernel: [ 1430]     0  1430    29365      482      22        0             0 rsyslogd
15:11:36 kernel: [ 1436]     0  1436     7887      300      20        0         -1000 sshd
15:11:36 kernel: [ 1439]     0  1439     9030      343      18        0             0 automount
15:11:36 kernel: [ 1449]     0  1449     1012      113       8        0             0 iscsid
15:11:36 kernel: [ 1450]     0  1450     1135      623       8        0         -1000 iscsid
15:11:36 kernel: [ 1454] 65534  1454     3115      153      10        0             0 dnsmasq
15:11:36 kernel: [ 1456]     0  1456     3359      277      12        0             0 ntpd
15:11:36 kernel: [ 1509]     0  1509     3616      125       8        0         -1000 tgtd
15:11:36 kernel: [ 1511]     0  1511     1567       83       8        0         -1000 tgtd
15:11:36 kernel: [ 1526]     0  1526     7947      397      20        0             0 lighttpd
15:11:36 kernel: [ 1530]     0  1530     5651      423      17        0             0 elastic-sshd
15:11:36 kernel: [ 1968]     0  1968    36379      105      25        0             0 diod
15:11:36 kernel: [ 1995]    -2  1995     7972      824      20        0             0 httpd
15:11:36 kernel: [ 1997]    -2  1997     4921      372      15        0             0 elastic-poolio
15:11:36 kernel: [ 1999]    -2  1999    82317     1120      53        0             0 httpd
15:11:36 kernel: [ 2000]    -2  2000    82317     1119      53        0             0 httpd
15:11:36 kernel: [ 2001]    -2  2001    82317     1120      53        0             0 httpd
15:11:36 kernel: [ 2084]     0  2084     4928      219      14        0             0 elastic-floodwa
15:11:36 kernel: [ 2141]     0  2141     5130      446      15        0             0 elastic
15:11:36 kernel: [ 2283]     0  2283     5130      447      14        0             0 elastic
15:11:36 kernel: [ 2371]    -2  2371      962       93       7        0             0 contain
15:11:36 kernel: [ 2566]    -2  2566     2663      195      11        0             0 init
15:11:36 kernel: [ 2604]    -2  2604      962       93       7        0             0 contain
15:11:36 kernel: [ 2706]    -2  2706     2663      195      12        0             0 init
15:11:36 kernel: [ 3640]    -2  3640     2489      643       8        0             0 dhclient
15:11:36 kernel: [ 3727]    -2  3727     2489      643       8        0             0 dhclient
15:11:36 kernel: [ 3822]     0  3822     9614      689      24        0             0 sshd
15:11:36 kernel: [ 3834]    -2  3834    12147      384      22        0             0 rsyslogd
15:11:36 kernel: [ 3902]    -2  3902     4721      208      14        0             0 cron
15:11:36 kernel: [ 3912]    -2  3912    12147      384      22        0             0 rsyslogd
15:11:36 kernel: [ 3963]    -2  3963    12483      298      28        0             0 sshd
15:11:36 kernel: [ 3986]    -2  3986    12483      298      27        0             0 sshd
15:11:36 kernel: [ 4001]    -2  4001     3645      229      13        0             0 getty
15:11:36 kernel: [ 4019]    -2  4019     2336      366      10        0             0 mysqld_safe
15:11:36 kernel: [ 4357]   103  4357    24779     1271      35        0             0 postgres
15:11:36 kernel: [ 4386]     0  4386     4968      489      15        0             0 bash
15:11:36 kernel: [ 4540]    -2  4540    19001      793      41        0             0 apache2
15:11:36 kernel: [ 4548]    33  4548    18934      555      39        0             0 apache2
15:11:36 kernel: [ 4550]    33  4550    74860      663      68        0             0 apache2
15:11:36 kernel: [ 4551]    33  4551    74858      664      68        0             0 apache2
15:11:36 kernel: [ 4608]    -2  4608     4721      207      15        0             0 cron
15:11:36 kernel: [ 4625]    -2  4625     3645      229      13        0             0 getty
15:11:36 kernel: [ 5085]     0  5085     9579      689      24        0             0 sshd
15:11:36 kernel: [ 5088]     0  5088     4968      487      15        0             0 bash
15:11:36 kernel: [ 5098]     0  5098     2033      102      10        0             0 tail
15:11:36 kernel: [ 5102]     0  5102     7554      652      19        0             0 tar
15:11:36 kernel: [ 5163]     0  5163     1994      104       9        0             0 sleep
15:11:36 kernel: [ 5169]     0  5169     9579      690      23        0             0 sshd
15:11:36 kernel: [ 5172]     0  5172     3072      200      12        0             0 agetty
15:11:36 kernel: [ 5173]     0  5173     3072      201      12        0             0 agetty
15:11:36 kernel: [ 5174]     0  5174     4968      488      15        0             0 bash
15:11:36 kernel: [ 5202]    -2  5202     2336       77       7        0             0 mysqld_safe
15:11:36 kernel: Out of memory: Kill process 4357 (postgres) score 0 or sacrifice child
15:11:36 kernel: Killed process 4357 (postgres) total-vm:99116kB, anon-rss:1232kB, file-rss:3852kB
15:11:36 kernel: tar invoked oom-killer: gfp_mask=0x0, order=0, oom_score_adj=0
15:11:36 kernel: tar cpuset=test mems_allowed=0-1
15:11:36 kernel: CPU: 3 PID: 5102 Comm: tar Not tainted 3.14.0-elastic #1
15:11:36 kernel: Hardware name: Supermicro H8DMT-IBX/H8DMT-IBX, BIOS 080014  10/17/2009
15:11:36 kernel: ffff8804119696a0 ffff8800d56dfbf8 ffffffff8185d77b ffff880411969080
15:11:36 kernel: ffff880411969080 ffff8800d56dfca8 ffffffff8112b820 ffff8800d56dfc28
15:11:36 kernel: ffffffff81133deb ffff880409060590 ffff88040f73c500 ffff8800d56dfc38
15:11:36 kernel: Call Trace:
15:11:36 kernel: [<ffffffff8185d77b>] dump_stack+0x51/0x77
15:11:36 kernel: [<ffffffff8112b820>] dump_header+0x7a/0x208
15:11:36 kernel: [<ffffffff81133deb>] ? __put_single_page+0x1b/0x1f
15:11:36 kernel: [<ffffffff8113448f>] ? put_page+0x22/0x24
15:11:36 kernel: [<ffffffff81129e38>] ? filemap_fault+0x2c2/0x36c
15:11:36 kernel: [<ffffffff813d146e>] ? ___ratelimit+0xe6/0x104
15:11:36 kernel: [<ffffffff8112bc1b>] oom_kill_process+0x6a/0x33b
15:11:36 kernel: [<ffffffff8112c306>] out_of_memory+0x41a/0x44d
15:11:36 kernel: [<ffffffff8112c39e>] pagefault_out_of_memory+0x65/0x77
15:11:36 kernel: [<ffffffff8106939e>] mm_fault_error+0xab/0x176
15:11:36 kernel: [<ffffffff810696f0>] __do_page_fault+0x287/0x3e2
15:11:36 kernel: [<ffffffff810f5018>] ? cpuacct_account_field+0x55/0x5d
15:11:36 kernel: [<ffffffff810f5018>] ? cpuacct_account_field+0x55/0x5d
15:11:36 kernel: [<ffffffff810e7816>] ? account_user_time+0x6e/0x97
15:11:36 kernel: [<ffffffff810e788c>] ? vtime_account_user+0x4d/0x52
15:11:36 kernel: [<ffffffff8106988f>] do_page_fault+0x44/0x61
15:11:36 kernel: [<ffffffff818618f8>] page_fault+0x28/0x30
15:11:36 kernel: Mem-Info:
15:11:36 kernel: Node 0 DMA per-cpu:
15:11:36 kernel: CPU    0: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    1: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    2: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    3: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    4: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    5: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    6: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    7: hi:    0, btch:   1 usd:   0
15:11:36 kernel: Node 0 DMA32 per-cpu:
15:11:36 kernel: CPU    0: hi:  186, btch:  31 usd: 150
15:11:36 kernel: CPU    1: hi:  186, btch:  31 usd: 166
15:11:36 kernel: CPU    2: hi:  186, btch:  31 usd:  98
15:11:36 kernel: CPU    3: hi:  186, btch:  31 usd: 162
15:11:36 kernel: CPU    4: hi:  186, btch:  31 usd:   3
15:11:36 kernel: CPU    5: hi:  186, btch:  31 usd: 163
15:11:36 kernel: CPU    6: hi:  186, btch:  31 usd:  18
15:11:36 kernel: CPU    7: hi:  186, btch:  31 usd: 162
15:11:36 kernel: Node 0 Normal per-cpu:
15:11:36 kernel: CPU    0: hi:  186, btch:  31 usd: 196
15:11:36 kernel: CPU    1: hi:  186, btch:  31 usd:  79
15:11:36 kernel: CPU    2: hi:  186, btch:  31 usd: 167
15:11:36 kernel: CPU    3: hi:  186, btch:  31 usd: 176
15:11:36 kernel: CPU    4: hi:  186, btch:  31 usd:  35
15:11:36 kernel: CPU    5: hi:  186, btch:  31 usd: 176
15:11:36 kernel: CPU    6: hi:  186, btch:  31 usd:   8
15:11:36 kernel: CPU    7: hi:  186, btch:  31 usd: 185
15:11:36 kernel: Node 1 Normal per-cpu:
15:11:36 kernel: CPU    0: hi:  186, btch:  31 usd: 178
15:11:36 kernel: CPU    1: hi:  186, btch:  31 usd:  46
15:11:36 kernel: CPU    2: hi:  186, btch:  31 usd: 173
15:11:36 kernel: CPU    3: hi:  186, btch:  31 usd: 115
15:11:36 kernel: CPU    4: hi:  186, btch:  31 usd:  64
15:11:36 kernel: CPU    5: hi:  186, btch:  31 usd: 179
15:11:36 kernel: CPU    6: hi:  186, btch:  31 usd: 156
15:11:36 kernel: CPU    7: hi:  186, btch:  31 usd: 106
15:11:36 kernel: active_anon:6997 inactive_anon:1812 isolated_anon:0
15:11:36 kernel: active_file:29590 inactive_file:151570 isolated_file:0
15:11:36 kernel: unevictable:621 dirty:389 writeback:38 unstable:0
15:11:36 kernel: free:7976969 slab_reclaimable:19834 slab_unreclaimable:7983
15:11:36 kernel: mapped:3222 shmem:164 pagetables:1400 bounce:0
15:11:36 kernel: free_cma:0
15:11:36 kernel: Node 0 DMA free:15900kB min:40kB low:48kB high:60kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15984kB managed:15900kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
15:11:36 kernel: lowmem_reserve[]: 0 3425 16097 16097
15:11:36 kernel: Node 0 DMA32 free:3397280kB min:9572kB low:11964kB high:14356kB active_anon:1744kB inactive_anon:1012kB active_file:15288kB inactive_file:79760kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3522184kB managed:3509084kB mlocked:0kB dirty:4kB writeback:0kB mapped:2088kB shmem:88kB slab_reclaimable:3504kB slab_unreclaimable:2404kB kernel_stack:864kB pagetables:1400kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
15:11:36 kernel: lowmem_reserve[]: 0 0 12671 12671
15:11:36 kernel: Node 0 Normal free:12273056kB min:35416kB low:44268kB high:53124kB active_anon:13500kB inactive_anon:3316kB active_file:64280kB inactive_file:434628kB unevictable:320kB isolated(anon):0kB isolated(file):0kB present:13238272kB managed:12975484kB mlocked:320kB dirty:364kB writeback:0kB mapped:3232kB shmem:256kB slab_reclaimable:64444kB slab_unreclaimable:15780kB kernel_stack:1840kB pagetables:2196kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
15:11:36 kernel: lowmem_reserve[]: 0 0 0 0
15:11:36 kernel: Node 1 Normal free:16221640kB min:45076kB low:56344kB high:67612kB active_anon:12744kB inactive_anon:2920kB active_file:38792kB inactive_file:91892kB unevictable:2164kB isolated(anon):0kB isolated(file):0kB present:16777216kB managed:16514488kB mlocked:2164kB dirty:1188kB writeback:152kB mapped:7568kB shmem:312kB slab_reclaimable:11388kB slab_unreclaimable:13748kB kernel_stack:1712kB pagetables:2004kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
15:11:36 kernel: lowmem_reserve[]: 0 0 0 0
15:11:36 kernel: Node 0 DMA: 1*4kB (U) 1*8kB (U) 1*16kB (U) 0*32kB 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) = 15900kB
15:11:36 kernel: Node 0 DMA32: 229*4kB (UEM) 119*8kB (UEM) 56*16kB (UEM) 23*32kB (UEM) 13*64kB (UM) 12*128kB (UEM) 4*256kB (UM) 2*512kB (UM) 0*1024kB 3*2048kB (MR) 826*4096kB (MR) = 3397356kB
15:11:36 kernel: Node 0 Normal: 357*4kB (UEM) 164*8kB (UEM) 64*16kB (UEM) 52*32kB (UEM) 24*64kB (UEM) 11*128kB (UM) 5*256kB (UEM) 5*512kB (UEM) 4*1024kB (UM) 3*2048kB (M) 2991*4096kB (MR) = 12273588kB
15:11:36 kernel: Node 1 Normal: 408*4kB (UEM) 141*8kB (UEM) 45*16kB (UEM) 28*32kB (UEM) 19*64kB (UM) 22*128kB (UEM) 8*256kB (M) 9*512kB (UEM) 3*1024kB (M) 2*2048kB (M) 3955*4096kB (MR) = 16221912kB
15:11:36 kernel: Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
15:11:36 kernel: Node 1 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
15:11:36 kernel: 181749 total pagecache pages
15:11:36 kernel: 0 pages in swap cache
15:11:36 kernel: Swap cache stats: add 0, delete 0, find 0/0
15:11:36 kernel: Free swap  = 16507900kB
15:11:36 kernel: Total swap = 16507900kB
15:11:36 kernel: 8388414 pages RAM
15:11:36 kernel: 0 pages HighMem/MovableOnly
15:11:36 kernel: 65682 pages reserved
15:11:36 kernel: 0 pages hwpoisoned
15:11:36 kernel: [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
15:11:36 kernel: [ 1345]     0  1345     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1346]     0  1346     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1347]     0  1347     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1348]     0  1348     3072      214      12        0             0 agetty
15:11:36 kernel: [ 1349]     0  1349     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1350]     0  1350     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1351]     0  1351     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1352]     0  1352     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1353]     0  1353     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1354]     0  1354     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1355]     0  1355     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1356]     0  1356     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1357]     0  1357     3072      214      11        0             0 agetty
15:11:36 kernel: [ 1358]     0  1358     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1359]     0  1359     3072      202      12        0             0 agetty
15:11:36 kernel: [ 1360]     0  1360     4928      157      14        0             0 rc.startup
15:11:36 kernel: [ 1361]     0  1361     3072      202      12        0             0 agetty
15:11:36 kernel: [ 1362]     0  1362     4928      157      14        0             0 rc.startup
15:11:36 kernel: [ 1430]     0  1430    29365      482      22        0             0 rsyslogd
15:11:36 kernel: [ 1436]     0  1436     7887      300      20        0         -1000 sshd
15:11:36 kernel: [ 1439]     0  1439     9030      343      18        0             0 automount
15:11:36 kernel: [ 1449]     0  1449     1012      113       8        0             0 iscsid
15:11:36 kernel: [ 1450]     0  1450     1135      623       8        0         -1000 iscsid
15:11:36 kernel: [ 1454] 65534  1454     3115      153      10        0             0 dnsmasq
15:11:36 kernel: [ 1456]     0  1456     3359      277      12        0             0 ntpd
15:11:36 kernel: [ 1509]     0  1509     3616      125       8        0         -1000 tgtd
15:11:36 kernel: [ 1511]     0  1511     1567       83       8        0         -1000 tgtd
15:11:36 kernel: [ 1526]     0  1526     7947      397      20        0             0 lighttpd
15:11:36 kernel: [ 1530]     0  1530     5651      423      17        0             0 elastic-sshd
15:11:36 kernel: [ 1968]     0  1968    36379      105      25        0             0 diod
15:11:36 kernel: [ 1995]    -2  1995     7972      824      20        0             0 httpd
15:11:36 kernel: [ 1997]    -2  1997     4921      372      15        0             0 elastic-poolio
15:11:36 kernel: [ 1999]    -2  1999    82317     1120      53        0             0 httpd
15:11:36 kernel: [ 2000]    -2  2000    82317     1119      53        0             0 httpd
15:11:36 kernel: [ 2001]    -2  2001    82317     1120      53        0             0 httpd
15:11:36 kernel: [ 2084]     0  2084     4928      219      14        0             0 elastic-floodwa
15:11:36 kernel: [ 2141]     0  2141     5130      446      15        0             0 elastic
15:11:36 kernel: [ 2283]     0  2283     5130      447      14        0             0 elastic
15:11:36 kernel: [ 2371]    -2  2371      962       93       7        0             0 contain
15:11:36 kernel: [ 2566]    -2  2566     2663      195      11        0             0 init
15:11:36 kernel: [ 2604]    -2  2604      962       93       7        0             0 contain
15:11:36 kernel: [ 2706]    -2  2706     2663      195      12        0             0 init
15:11:36 kernel: [ 3640]    -2  3640     2489      643       8        0             0 dhclient
15:11:36 kernel: [ 3727]    -2  3727     2489      643       8        0             0 dhclient
15:11:36 kernel: [ 3822]     0  3822     9614      689      24        0             0 sshd
15:11:36 kernel: [ 3834]    -2  3834    12147      384      22        0             0 rsyslogd
15:11:36 kernel: [ 3902]    -2  3902     4721      208      14        0             0 cron
15:11:36 kernel: [ 3912]    -2  3912    12147      384      22        0             0 rsyslogd
15:11:36 kernel: [ 3963]    -2  3963    12483      298      28        0             0 sshd
15:11:36 kernel: [ 3986]    -2  3986    12483      298      27        0             0 sshd
15:11:36 kernel: [ 4001]    -2  4001     3645      229      13        0             0 getty
15:11:36 kernel: [ 4386]     0  4386     4968      489      15        0             0 bash
15:11:36 kernel: [ 4540]    -2  4540    19001      793      41        0             0 apache2
15:11:36 kernel: [ 4548]    33  4548    18934      555      39        0             0 apache2
15:11:36 kernel: [ 4550]    33  4550    74860      663      68        0             0 apache2
15:11:36 kernel: [ 4551]    33  4551    74858      664      68        0             0 apache2
15:11:36 kernel: [ 4608]    -2  4608     4721      207      15        0             0 cron
15:11:36 kernel: [ 4625]    -2  4625     3645      229      13        0             0 getty
15:11:36 kernel: [ 5085]     0  5085     9613      689      24        0             0 sshd
15:11:36 kernel: [ 5088]     0  5088     4968      487      15        0             0 bash
15:11:36 kernel: [ 5098]     0  5098     2033      102      10        0             0 tail
15:11:36 kernel: [ 5102]     0  5102     7554      652      19        0             0 tar
15:11:36 kernel: [ 5163]     0  5163     1994      104       9        0             0 sleep
15:11:36 kernel: [ 5169]     0  5169     9579      690      23        0             0 sshd
15:11:36 kernel: [ 5172]     0  5172     3072      200      12        0             0 agetty
15:11:36 kernel: [ 5173]     0  5173     3072      201      12        0             0 agetty
15:11:36 kernel: [ 5174]     0  5174     4968      488      15        0             0 bash
15:11:36 kernel: Out of memory: Kill process 1999 (httpd) score 0 or sacrifice child
15:11:36 kernel: Killed process 1999 (httpd) total-vm:329268kB, anon-rss:3272kB, file-rss:1208kB
15:11:36 kernel: tar invoked oom-killer: gfp_mask=0x0, order=0, oom_score_adj=0
15:11:36 kernel: tar cpuset=test mems_allowed=0-1
15:11:36 kernel: CPU: 3 PID: 5102 Comm: tar Not tainted 3.14.0-elastic #1
15:11:36 kernel: Hardware name: Supermicro H8DMT-IBX/H8DMT-IBX, BIOS 080014  10/17/2009
15:11:36 kernel: ffff8804119696a0 ffff8800d56dfbf8 ffffffff8185d77b ffff880411969080
15:11:36 kernel: ffff880411969080 ffff8800d56dfca8 ffffffff8112b820 ffff8800d56dfc28
15:11:36 kernel: ffffffff81133deb ffff880409060590 ffff88040f73c500 ffff8800d56dfc38
15:11:36 kernel: Call Trace:
15:11:36 kernel: [<ffffffff8185d77b>] dump_stack+0x51/0x77
15:11:36 kernel: [<ffffffff8112b820>] dump_header+0x7a/0x208
15:11:36 kernel: [<ffffffff81133deb>] ? __put_single_page+0x1b/0x1f
15:11:36 kernel: [<ffffffff8113448f>] ? put_page+0x22/0x24
15:11:36 kernel: [<ffffffff81129e38>] ? filemap_fault+0x2c2/0x36c
15:11:36 kernel: [<ffffffff813d146e>] ? ___ratelimit+0xe6/0x104
15:11:36 kernel: [<ffffffff8112bc1b>] oom_kill_process+0x6a/0x33b
15:11:36 kernel: [<ffffffff8112c306>] out_of_memory+0x41a/0x44d
15:11:36 kernel: [<ffffffff8112c39e>] pagefault_out_of_memory+0x65/0x77
15:11:36 kernel: [<ffffffff8106939e>] mm_fault_error+0xab/0x176
15:11:36 kernel: [<ffffffff810696f0>] __do_page_fault+0x287/0x3e2
15:11:36 kernel: [<ffffffff810f5018>] ? cpuacct_account_field+0x55/0x5d
15:11:36 kernel: [<ffffffff810f5018>] ? cpuacct_account_field+0x55/0x5d
15:11:36 kernel: [<ffffffff810e7816>] ? account_user_time+0x6e/0x97
15:11:36 kernel: [<ffffffff810e788c>] ? vtime_account_user+0x4d/0x52
15:11:36 kernel: [<ffffffff8106988f>] do_page_fault+0x44/0x61
15:11:36 kernel: [<ffffffff818618f8>] page_fault+0x28/0x30
15:11:36 kernel: Mem-Info:
15:11:36 kernel: Node 0 DMA per-cpu:
15:11:36 kernel: CPU    0: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    1: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    2: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    3: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    4: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    5: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    6: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    7: hi:    0, btch:   1 usd:   0
15:11:36 kernel: Node 0 DMA32 per-cpu:
15:11:36 kernel: CPU    0: hi:  186, btch:  31 usd: 150
15:11:36 kernel: CPU    1: hi:  186, btch:  31 usd: 166
15:11:36 kernel: CPU    2: hi:  186, btch:  31 usd: 100
15:11:36 kernel: CPU    3: hi:  186, btch:  31 usd: 162
15:11:36 kernel: CPU    4: hi:  186, btch:  31 usd:   3
15:11:36 kernel: CPU    5: hi:  186, btch:  31 usd: 163
15:11:36 kernel: CPU    6: hi:  186, btch:  31 usd:  18
15:11:36 kernel: CPU    7: hi:  186, btch:  31 usd: 162
15:11:36 kernel: Node 0 Normal per-cpu:
15:11:36 kernel: CPU    0: hi:  186, btch:  31 usd: 195
15:11:36 kernel: CPU    1: hi:  186, btch:  31 usd:  75
15:11:36 kernel: CPU    2: hi:  186, btch:  31 usd: 185
15:11:36 kernel: CPU    3: hi:  186, btch:  31 usd: 176
15:11:36 kernel: CPU    4: hi:  186, btch:  31 usd:  35
15:11:36 kernel: CPU    5: hi:  186, btch:  31 usd: 176
15:11:36 kernel: CPU    6: hi:  186, btch:  31 usd:   8
15:11:36 kernel: CPU    7: hi:  186, btch:  31 usd: 185
15:11:36 kernel: Node 1 Normal per-cpu:
15:11:36 kernel: CPU    0: hi:  186, btch:  31 usd: 178
15:11:36 kernel: CPU    1: hi:  186, btch:  31 usd:  46
15:11:36 kernel: CPU    2: hi:  186, btch:  31 usd: 159
15:11:36 kernel: CPU    3: hi:  186, btch:  31 usd: 115
15:11:36 kernel: CPU    4: hi:  186, btch:  31 usd:  64
15:11:36 kernel: CPU    5: hi:  186, btch:  31 usd: 180
15:11:36 kernel: CPU    6: hi:  186, btch:  31 usd: 157
15:11:36 kernel: CPU    7: hi:  186, btch:  31 usd: 106
15:11:36 kernel: active_anon:6430 inactive_anon:1812 isolated_anon:0
15:11:36 kernel: active_file:29590 inactive_file:151570 isolated_file:0
15:11:36 kernel: unevictable:621 dirty:389 writeback:38 unstable:0
15:11:36 kernel: free:7977670 slab_reclaimable:19834 slab_unreclaimable:7983
15:11:36 kernel: mapped:3222 shmem:164 pagetables:1400 bounce:0
15:11:36 kernel: free_cma:0
15:11:36 kernel: Node 0 DMA free:15900kB min:40kB low:48kB high:60kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15984kB managed:15900kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
15:11:36 kernel: lowmem_reserve[]: 0 3425 16097 16097
15:11:36 kernel: Node 0 DMA32 free:3397280kB min:9572kB low:11964kB high:14356kB active_anon:1744kB inactive_anon:1012kB active_file:15288kB inactive_file:79760kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3522184kB managed:3509084kB mlocked:0kB dirty:4kB writeback:0kB mapped:2088kB shmem:88kB slab_reclaimable:3504kB slab_unreclaimable:2404kB kernel_stack:864kB pagetables:1400kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
15:11:36 kernel: lowmem_reserve[]: 0 0 12671 12671
15:11:36 kernel: Node 0 Normal free:12275340kB min:35416kB low:44268kB high:53124kB active_anon:11232kB inactive_anon:3316kB active_file:64280kB inactive_file:434628kB unevictable:320kB isolated(anon):0kB isolated(file):0kB present:13238272kB managed:12975484kB mlocked:320kB dirty:364kB writeback:0kB mapped:3232kB shmem:256kB slab_reclaimable:64444kB slab_unreclaimable:15780kB kernel_stack:1840kB pagetables:2196kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
15:11:36 kernel: lowmem_reserve[]: 0 0 0 0
15:11:36 kernel: Node 1 Normal free:16222160kB min:45076kB low:56344kB high:67612kB active_anon:12744kB inactive_anon:2920kB active_file:38792kB inactive_file:91892kB unevictable:2164kB isolated(anon):0kB isolated(file):0kB present:16777216kB managed:16514488kB mlocked:2164kB dirty:1188kB writeback:152kB mapped:7568kB shmem:312kB slab_reclaimable:11388kB slab_unreclaimable:13748kB kernel_stack:1712kB pagetables:2004kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
15:11:36 kernel: lowmem_reserve[]: 0 0 0 0
15:11:36 kernel: Node 0 DMA: 1*4kB (U) 1*8kB (U) 1*16kB (U) 0*32kB 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) = 15900kB
15:11:36 kernel: Node 0 DMA32: 229*4kB (UEM) 119*8kB (UEM) 56*16kB (UEM) 23*32kB (UEM) 13*64kB (UM) 12*128kB (UEM) 4*256kB (UM) 2*512kB (UM) 0*1024kB 3*2048kB (MR) 826*4096kB (MR) = 3397356kB
15:11:36 kernel: Node 0 Normal: 390*4kB (UEM) 183*8kB (UEM) 68*16kB (UEM) 56*32kB (UEM) 24*64kB (UEM) 11*128kB (UM) 5*256kB (UEM) 5*512kB (UEM) 4*1024kB (UM) 4*2048kB (M) 2991*4096kB (MR) = 12276112kB
15:11:36 kernel: Node 1 Normal: 431*4kB (UEM) 150*8kB (UEM) 46*16kB (UEM) 30*32kB (UEM) 19*64kB (UM) 23*128kB (UEM) 8*256kB (M) 9*512kB (UEM) 3*1024kB (M) 2*2048kB (M) 3955*4096kB (MR) = 16222284kB
15:11:36 kernel: Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
15:11:36 kernel: Node 1 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
15:11:36 kernel: 181749 total pagecache pages
15:11:36 kernel: 0 pages in swap cache
15:11:36 kernel: Swap cache stats: add 0, delete 0, find 0/0
15:11:36 kernel: Free swap  = 16507900kB
15:11:36 kernel: Total swap = 16507900kB
15:11:36 kernel: 8388414 pages RAM
15:11:36 kernel: 0 pages HighMem/MovableOnly
15:11:36 kernel: 65682 pages reserved
15:11:36 kernel: 0 pages hwpoisoned
15:11:36 kernel: [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
15:11:36 kernel: [ 1345]     0  1345     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1346]     0  1346     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1347]     0  1347     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1348]     0  1348     3072      214      12        0             0 agetty
15:11:36 kernel: [ 1349]     0  1349     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1350]     0  1350     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1351]     0  1351     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1352]     0  1352     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1353]     0  1353     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1354]     0  1354     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1355]     0  1355     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1356]     0  1356     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1357]     0  1357     3072      214      11        0             0 agetty
15:11:36 kernel: [ 1358]     0  1358     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1359]     0  1359     3072      202      12        0             0 agetty
15:11:36 kernel: [ 1360]     0  1360     4928      157      14        0             0 rc.startup
15:11:36 kernel: [ 1361]     0  1361     3072      202      12        0             0 agetty
15:11:36 kernel: [ 1362]     0  1362     4928      157      14        0             0 rc.startup
15:11:36 kernel: [ 1430]     0  1430    29365      482      22        0             0 rsyslogd
15:11:36 kernel: [ 1436]     0  1436     7887      300      20        0         -1000 sshd
15:11:36 kernel: [ 1439]     0  1439     9030      343      18        0             0 automount
15:11:36 kernel: [ 1449]     0  1449     1012      113       8        0             0 iscsid
15:11:36 kernel: [ 1450]     0  1450     1135      623       8        0         -1000 iscsid
15:11:36 kernel: [ 1454] 65534  1454     3115      153      10        0             0 dnsmasq
15:11:36 kernel: [ 1456]     0  1456     3359      277      12        0             0 ntpd
15:11:36 kernel: [ 1509]     0  1509     3616      125       8        0         -1000 tgtd
15:11:36 kernel: [ 1511]     0  1511     1567       83       8        0         -1000 tgtd
15:11:36 kernel: [ 1526]     0  1526     7947      397      20        0             0 lighttpd
15:11:36 kernel: [ 1530]     0  1530     5651      423      17        0             0 elastic-sshd
15:11:36 kernel: [ 1968]     0  1968    36379      105      25        0             0 diod
15:11:36 kernel: [ 1995]    -2  1995     7972      824      20        0             0 httpd
15:11:36 kernel: [ 1997]    -2  1997     4921      372      15        0             0 elastic-poolio
15:11:36 kernel: [ 2000]    -2  2000    82317     1119      53        0             0 httpd
15:11:36 kernel: [ 2001]    -2  2001    82317     1120      53        0             0 httpd
15:11:36 kernel: [ 2084]     0  2084     4928      219      14        0             0 elastic-floodwa
15:11:36 kernel: [ 2141]     0  2141     5130      446      15        0             0 elastic
15:11:36 kernel: [ 2283]     0  2283     5130      447      14        0             0 elastic
15:11:36 kernel: [ 2371]    -2  2371      962       93       7        0             0 contain
15:11:36 kernel: [ 2566]    -2  2566     2663      195      11        0             0 init
15:11:36 kernel: [ 2604]    -2  2604      962       93       7        0             0 contain
15:11:36 kernel: [ 2706]    -2  2706     2663      195      12        0             0 init
15:11:36 kernel: [ 3640]    -2  3640     2489      643       8        0             0 dhclient
15:11:36 kernel: [ 3727]    -2  3727     2489      643       8        0             0 dhclient
15:11:36 kernel: [ 3822]     0  3822     9614      689      24        0             0 sshd
15:11:36 kernel: [ 3834]    -2  3834    12147      384      22        0             0 rsyslogd
15:11:36 kernel: [ 3902]    -2  3902     4721      208      14        0             0 cron
15:11:36 kernel: [ 3912]    -2  3912    12147      384      22        0             0 rsyslogd
15:11:36 kernel: [ 3963]    -2  3963    12483      298      28        0             0 sshd
15:11:36 kernel: [ 3986]    -2  3986    12483      298      27        0             0 sshd
15:11:36 kernel: [ 4001]    -2  4001     3645      229      13        0             0 getty
15:11:36 kernel: [ 4386]     0  4386     4968      489      15        0             0 bash
15:11:36 kernel: [ 4540]    -2  4540    19001      793      41        0             0 apache2
15:11:36 kernel: [ 4548]    33  4548    18934      555      39        0             0 apache2
15:11:36 kernel: [ 4550]    33  4550    74860      663      68        0             0 apache2
15:11:36 kernel: [ 4551]    33  4551    74858      664      68        0             0 apache2
15:11:36 kernel: [ 4608]    -2  4608     4721      207      15        0             0 cron
15:11:36 kernel: [ 4625]    -2  4625     3645      229      13        0             0 getty
15:11:36 kernel: [ 5085]     0  5085     9613      689      24        0             0 sshd
15:11:36 kernel: [ 5088]     0  5088     4968      487      15        0             0 bash
15:11:36 kernel: [ 5098]     0  5098     2033      102      10        0             0 tail
15:11:36 kernel: [ 5102]     0  5102     7554      652      19        0             0 tar
15:11:36 kernel: [ 5163]     0  5163     1994      104       9        0             0 sleep
15:11:36 kernel: [ 5169]     0  5169     9579      690      23        0             0 sshd
15:11:36 kernel: [ 5172]     0  5172     3072      200      12        0             0 agetty
15:11:36 kernel: [ 5173]     0  5173     3072      201      12        0             0 agetty
15:11:36 kernel: [ 5174]     0  5174     4968      488      15        0             0 bash
15:11:36 kernel: Out of memory: Kill process 2001 (httpd) score 0 or sacrifice child
15:11:36 kernel: Killed process 2001 (httpd) total-vm:329268kB, anon-rss:3268kB, file-rss:1212kB
15:11:36 kernel: tar invoked oom-killer: gfp_mask=0x0, order=0, oom_score_adj=0
15:11:36 kernel: tar cpuset=test mems_allowed=0-1
15:11:36 kernel: CPU: 3 PID: 5102 Comm: tar Not tainted 3.14.0-elastic #1
15:11:36 kernel: Hardware name: Supermicro H8DMT-IBX/H8DMT-IBX, BIOS 080014  10/17/2009
15:11:36 kernel: ffff8804119696a0 ffff8800d56dfbf8 ffffffff8185d77b ffff880411969080
15:11:36 kernel: ffff880411969080 ffff8800d56dfca8 ffffffff8112b820 ffff8800d56dfc28
15:11:36 kernel: ffffffff81133deb ffff880409060590 ffff88040f73c500 ffff8800d56dfc38
15:11:36 kernel: Call Trace:
15:11:36 kernel: [<ffffffff8185d77b>] dump_stack+0x51/0x77
15:11:36 kernel: [<ffffffff8112b820>] dump_header+0x7a/0x208
15:11:36 kernel: [<ffffffff81133deb>] ? __put_single_page+0x1b/0x1f
15:11:36 kernel: [<ffffffff8113448f>] ? put_page+0x22/0x24
15:11:36 kernel: [<ffffffff81129e38>] ? filemap_fault+0x2c2/0x36c
15:11:36 kernel: [<ffffffff813d146e>] ? ___ratelimit+0xe6/0x104
15:11:36 kernel: [<ffffffff8112bc1b>] oom_kill_process+0x6a/0x33b
15:11:36 kernel: [<ffffffff8112c306>] out_of_memory+0x41a/0x44d
15:11:36 kernel: [<ffffffff8112c39e>] pagefault_out_of_memory+0x65/0x77
15:11:36 kernel: [<ffffffff8106939e>] mm_fault_error+0xab/0x176
15:11:36 kernel: [<ffffffff810696f0>] __do_page_fault+0x287/0x3e2
15:11:36 kernel: [<ffffffff810f5018>] ? cpuacct_account_field+0x55/0x5d
15:11:36 kernel: [<ffffffff810f5018>] ? cpuacct_account_field+0x55/0x5d
15:11:36 kernel: [<ffffffff810e7816>] ? account_user_time+0x6e/0x97
15:11:36 kernel: [<ffffffff810e788c>] ? vtime_account_user+0x4d/0x52
15:11:36 kernel: [<ffffffff8106988f>] do_page_fault+0x44/0x61
15:11:36 kernel: [<ffffffff818618f8>] page_fault+0x28/0x30
15:11:36 kernel: Mem-Info:
15:11:36 kernel: Node 0 DMA per-cpu:
15:11:36 kernel: CPU    0: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    1: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    2: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    3: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    4: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    5: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    6: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    7: hi:    0, btch:   1 usd:   0
15:11:36 kernel: Node 0 DMA32 per-cpu:
15:11:36 kernel: CPU    0: hi:  186, btch:  31 usd: 150
15:11:36 kernel: CPU    1: hi:  186, btch:  31 usd: 166
15:11:36 kernel: CPU    2: hi:  186, btch:  31 usd: 100
15:11:36 kernel: CPU    3: hi:  186, btch:  31 usd: 162
15:11:36 kernel: CPU    4: hi:  186, btch:  31 usd:   3
15:11:36 kernel: CPU    5: hi:  186, btch:  31 usd: 163
15:11:36 kernel: CPU    6: hi:  186, btch:  31 usd:  18
15:11:36 kernel: CPU    7: hi:  186, btch:  31 usd: 162
15:11:36 kernel: Node 0 Normal per-cpu:
15:11:36 kernel: CPU    0: hi:  186, btch:  31 usd: 195
15:11:36 kernel: CPU    1: hi:  186, btch:  31 usd:  72
15:11:36 kernel: CPU    2: hi:  186, btch:  31 usd: 180
15:11:36 kernel: CPU    3: hi:  186, btch:  31 usd: 176
15:11:36 kernel: CPU    4: hi:  186, btch:  31 usd:  35
15:11:36 kernel: CPU    5: hi:  186, btch:  31 usd: 176
15:11:36 kernel: CPU    6: hi:  186, btch:  31 usd:   8
15:11:36 kernel: CPU    7: hi:  186, btch:  31 usd: 185
15:11:36 kernel: Node 1 Normal per-cpu:
15:11:36 kernel: CPU    0: hi:  186, btch:  31 usd: 178
15:11:36 kernel: CPU    1: hi:  186, btch:  31 usd:  46
15:11:36 kernel: CPU    2: hi:  186, btch:  31 usd: 168
15:11:36 kernel: CPU    3: hi:  186, btch:  31 usd: 115
15:11:36 kernel: CPU    4: hi:  186, btch:  31 usd:  64
15:11:36 kernel: CPU    5: hi:  186, btch:  31 usd: 181
15:11:36 kernel: CPU    6: hi:  186, btch:  31 usd: 157
15:11:36 kernel: CPU    7: hi:  186, btch:  31 usd: 106
15:11:36 kernel: active_anon:5804 inactive_anon:1812 isolated_anon:0
15:11:36 kernel: active_file:29590 inactive_file:151570 isolated_file:0
15:11:36 kernel: unevictable:621 dirty:389 writeback:38 unstable:0
15:11:36 kernel: free:7978396 slab_reclaimable:19834 slab_unreclaimable:7983
15:11:36 kernel: mapped:3222 shmem:164 pagetables:1303 bounce:0
15:11:36 kernel: free_cma:0
15:11:36 kernel: Node 0 DMA free:15900kB min:40kB low:48kB high:60kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15984kB managed:15900kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
15:11:36 kernel: lowmem_reserve[]: 0 3425 16097 16097
15:11:36 kernel: Node 0 DMA32 free:3397280kB min:9572kB low:11964kB high:14356kB active_anon:1744kB inactive_anon:1012kB active_file:15288kB inactive_file:79760kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3522184kB managed:3509084kB mlocked:0kB dirty:4kB writeback:0kB mapped:2088kB shmem:88kB slab_reclaimable:3504kB slab_unreclaimable:2404kB kernel_stack:864kB pagetables:1400kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
15:11:36 kernel: lowmem_reserve[]: 0 0 12671 12671
15:11:36 kernel: Node 0 Normal free:12275600kB min:35416kB low:44268kB high:53124kB active_anon:11232kB inactive_anon:3316kB active_file:64280kB inactive_file:434628kB unevictable:320kB isolated(anon):0kB isolated(file):0kB present:13238272kB managed:12975484kB mlocked:320kB dirty:364kB writeback:0kB mapped:3232kB shmem:256kB slab_reclaimable:64444kB slab_unreclaimable:15780kB kernel_stack:1840kB pagetables:2196kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
15:11:36 kernel: lowmem_reserve[]: 0 0 0 0
15:11:36 kernel: Node 1 Normal free:16224804kB min:45076kB low:56344kB high:67612kB active_anon:10240kB inactive_anon:2920kB active_file:38792kB inactive_file:91892kB unevictable:2164kB isolated(anon):0kB isolated(file):0kB present:16777216kB managed:16514488kB mlocked:2164kB dirty:1188kB writeback:152kB mapped:7568kB shmem:312kB slab_reclaimable:11388kB slab_unreclaimable:13748kB kernel_stack:1712kB pagetables:1616kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
15:11:36 kernel: lowmem_reserve[]: 0 0 0 0
15:11:36 kernel: Node 0 DMA: 1*4kB (U) 1*8kB (U) 1*16kB (U) 0*32kB 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) = 15900kB
15:11:36 kernel: Node 0 DMA32: 229*4kB (UEM) 119*8kB (UEM) 56*16kB (UEM) 23*32kB (UEM) 13*64kB (UM) 12*128kB (UEM) 4*256kB (UM) 2*512kB (UM) 0*1024kB 3*2048kB (MR) 826*4096kB (MR) = 3397356kB
15:11:36 kernel: Node 0 Normal: 393*4kB (UEM) 180*8kB (UEM) 71*16kB (UEM) 56*32kB (UEM) 27*64kB (UEM) 11*128kB (UM) 5*256kB (UEM) 5*512kB (UEM) 4*1024kB (UM) 4*2048kB (M) 2991*4096kB (MR) = 12276340kB
15:11:36 kernel: Node 1 Normal: 506*4kB (UEM) 161*8kB (UEM) 49*16kB (UEM) 30*32kB (UEM) 20*64kB (UM) 22*128kB (UEM) 9*256kB (M) 9*512kB (UEM) 3*1024kB (M) 3*2048kB (M) 3955*4096kB (MR) = 16224960kB
15:11:36 kernel: Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
15:11:36 kernel: Node 1 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
15:11:36 kernel: 181749 total pagecache pages
15:11:36 kernel: 0 pages in swap cache
15:11:36 kernel: Swap cache stats: add 0, delete 0, find 0/0
15:11:36 kernel: Free swap  = 16507900kB
15:11:36 kernel: Total swap = 16507900kB
15:11:36 kernel: 8388414 pages RAM
15:11:36 kernel: 0 pages HighMem/MovableOnly
15:11:36 kernel: 65682 pages reserved
15:11:36 kernel: 0 pages hwpoisoned
15:11:36 kernel: [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
15:11:36 kernel: [ 1345]     0  1345     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1346]     0  1346     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1347]     0  1347     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1348]     0  1348     3072      214      12        0             0 agetty
15:11:36 kernel: [ 1349]     0  1349     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1350]     0  1350     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1351]     0  1351     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1352]     0  1352     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1353]     0  1353     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1354]     0  1354     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1355]     0  1355     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1356]     0  1356     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1357]     0  1357     3072      214      11        0             0 agetty
15:11:36 kernel: [ 1358]     0  1358     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1359]     0  1359     3072      202      12        0             0 agetty
15:11:36 kernel: [ 1360]     0  1360     4928      157      14        0             0 rc.startup
15:11:36 kernel: [ 1361]     0  1361     3072      202      12        0             0 agetty
15:11:36 kernel: [ 1362]     0  1362     4928      157      14        0             0 rc.startup
15:11:36 kernel: [ 1430]     0  1430    29365      482      22        0             0 rsyslogd
15:11:36 kernel: [ 1436]     0  1436     7887      300      20        0         -1000 sshd
15:11:36 kernel: [ 1439]     0  1439     9030      343      18        0             0 automount
15:11:36 kernel: [ 1449]     0  1449     1012      113       8        0             0 iscsid
15:11:36 kernel: [ 1450]     0  1450     1135      623       8        0         -1000 iscsid
15:11:36 kernel: [ 1454] 65534  1454     3115      153      10        0             0 dnsmasq
15:11:36 kernel: [ 1456]     0  1456     3359      277      12        0             0 ntpd
15:11:36 kernel: [ 1509]     0  1509     3616      125       8        0         -1000 tgtd
15:11:36 kernel: [ 1511]     0  1511     1567       83       8        0         -1000 tgtd
15:11:36 kernel: [ 1526]     0  1526     7947      397      20        0             0 lighttpd
15:11:36 kernel: [ 1530]     0  1530     5651      423      17        0             0 elastic-sshd
15:11:36 kernel: [ 1968]     0  1968    36379      105      25        0             0 diod
15:11:36 kernel: [ 1995]    -2  1995     7972      824      20        0             0 httpd
15:11:36 kernel: [ 1997]    -2  1997     4921      372      15        0             0 elastic-poolio
15:11:36 kernel: [ 2000]    -2  2000    82317     1119      53        0             0 httpd
15:11:36 kernel: [ 2084]     0  2084     4928      219      14        0             0 elastic-floodwa
15:11:36 kernel: [ 2141]     0  2141     5130      446      15        0             0 elastic
15:11:36 kernel: [ 2283]     0  2283     5130      447      14        0             0 elastic
15:11:36 kernel: [ 2371]    -2  2371      962       93       7        0             0 contain
15:11:36 kernel: [ 2566]    -2  2566     2663      195      11        0             0 init
15:11:36 kernel: [ 2604]    -2  2604      962       93       7        0             0 contain
15:11:36 kernel: [ 2706]    -2  2706     2663      195      12        0             0 init
15:11:36 kernel: [ 3640]    -2  3640     2489      643       8        0             0 dhclient
15:11:36 kernel: [ 3727]    -2  3727     2489      643       8        0             0 dhclient
15:11:36 kernel: [ 3822]     0  3822     9614      689      24        0             0 sshd
15:11:36 kernel: [ 3834]    -2  3834    12147      384      22        0             0 rsyslogd
15:11:36 kernel: [ 3902]    -2  3902     4721      208      14        0             0 cron
15:11:36 kernel: [ 3912]    -2  3912    12147      384      22        0             0 rsyslogd
15:11:36 kernel: [ 3963]    -2  3963    12483      298      28        0             0 sshd
15:11:36 kernel: [ 3986]    -2  3986    12483      298      27        0             0 sshd
15:11:36 kernel: [ 4001]    -2  4001     3645      229      13        0             0 getty
15:11:36 kernel: [ 4386]     0  4386     4968      489      15        0             0 bash
15:11:36 kernel: [ 4540]    -2  4540    19001      793      41        0             0 apache2
15:11:36 kernel: [ 4548]    33  4548    18934      555      39        0             0 apache2
15:11:36 kernel: [ 4550]    33  4550    74860      663      68        0             0 apache2
15:11:36 kernel: [ 4551]    33  4551    74858      664      68        0             0 apache2
15:11:36 kernel: [ 4608]    -2  4608     4721      207      15        0             0 cron
15:11:36 kernel: [ 4625]    -2  4625     3645      229      13        0             0 getty
15:11:36 kernel: [ 5085]     0  5085     9613      689      24        0             0 sshd
15:11:36 kernel: [ 5088]     0  5088     4968      487      15        0             0 bash
15:11:36 kernel: [ 5098]     0  5098     2033      102      10        0             0 tail
15:11:36 kernel: [ 5102]     0  5102     7554      652      19        0             0 tar
15:11:36 kernel: [ 5163]     0  5163     1994      104       9        0             0 sleep
15:11:36 kernel: [ 5169]     0  5169     9579      690      23        0             0 sshd
15:11:36 kernel: [ 5172]     0  5172     3072      200      12        0             0 agetty
15:11:36 kernel: [ 5173]     0  5173     3072      201      12        0             0 agetty
15:11:36 kernel: [ 5174]     0  5174     4968      488      15        0             0 bash
15:11:36 kernel: Out of memory: Kill process 2000 (httpd) score 0 or sacrifice child
15:11:36 kernel: Killed process 2000 (httpd) total-vm:329268kB, anon-rss:3268kB, file-rss:1208kB
15:11:36 kernel: tar invoked oom-killer: gfp_mask=0x0, order=0, oom_score_adj=0
15:11:36 kernel: tar cpuset=test mems_allowed=0-1
15:11:36 kernel: CPU: 3 PID: 5102 Comm: tar Not tainted 3.14.0-elastic #1
15:11:36 kernel: Hardware name: Supermicro H8DMT-IBX/H8DMT-IBX, BIOS 080014  10/17/2009
15:11:36 kernel: ffff8804119696a0 ffff8800d56dfbf8 ffffffff8185d77b ffff880411969080
15:11:36 kernel: ffff880411969080 ffff8800d56dfca8 ffffffff8112b820 ffff8800d56dfc28
15:11:36 kernel: ffffffff81133deb ffff880409060590 ffff88040f73c500 ffff8800d56dfc38
15:11:36 kernel: Call Trace:
15:11:36 kernel: [<ffffffff8185d77b>] dump_stack+0x51/0x77
15:11:36 kernel: [<ffffffff8112b820>] dump_header+0x7a/0x208
15:11:36 kernel: [<ffffffff81133deb>] ? __put_single_page+0x1b/0x1f
15:11:36 kernel: [<ffffffff8113448f>] ? put_page+0x22/0x24
15:11:36 kernel: [<ffffffff81129e38>] ? filemap_fault+0x2c2/0x36c
15:11:36 kernel: [<ffffffff813d146e>] ? ___ratelimit+0xe6/0x104
15:11:36 kernel: [<ffffffff8112bc1b>] oom_kill_process+0x6a/0x33b
15:11:36 kernel: [<ffffffff8112c306>] out_of_memory+0x41a/0x44d
15:11:36 kernel: [<ffffffff8112c39e>] pagefault_out_of_memory+0x65/0x77
15:11:36 kernel: [<ffffffff8106939e>] mm_fault_error+0xab/0x176
15:11:36 kernel: [<ffffffff810696f0>] __do_page_fault+0x287/0x3e2
15:11:36 kernel: [<ffffffff810f5018>] ? cpuacct_account_field+0x55/0x5d
15:11:36 kernel: [<ffffffff810f5018>] ? cpuacct_account_field+0x55/0x5d
15:11:36 kernel: [<ffffffff810e7816>] ? account_user_time+0x6e/0x97
15:11:36 kernel: [<ffffffff810e788c>] ? vtime_account_user+0x4d/0x52
15:11:36 kernel: [<ffffffff8106988f>] do_page_fault+0x44/0x61
15:11:36 kernel: [<ffffffff818618f8>] page_fault+0x28/0x30
15:11:36 kernel: Mem-Info:
15:11:36 kernel: Node 0 DMA per-cpu:
15:11:36 kernel: CPU    0: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    1: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    2: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    3: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    4: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    5: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    6: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    7: hi:    0, btch:   1 usd:   0
15:11:36 kernel: Node 0 DMA32 per-cpu:
15:11:36 kernel: CPU    0: hi:  186, btch:  31 usd: 150
15:11:36 kernel: CPU    1: hi:  186, btch:  31 usd: 166
15:11:36 kernel: CPU    2: hi:  186, btch:  31 usd: 100
15:11:36 kernel: CPU    3: hi:  186, btch:  31 usd: 162
15:11:36 kernel: CPU    4: hi:  186, btch:  31 usd:   3
15:11:36 kernel: CPU    5: hi:  186, btch:  31 usd: 163
15:11:36 kernel: CPU    6: hi:  186, btch:  31 usd:  18
15:11:36 kernel: CPU    7: hi:  186, btch:  31 usd: 162
15:11:36 kernel: Node 0 Normal per-cpu:
15:11:36 kernel: CPU    0: hi:  186, btch:  31 usd: 194
15:11:36 kernel: CPU    1: hi:  186, btch:  31 usd:  68
15:11:36 kernel: CPU    2: hi:  186, btch:  31 usd: 183
15:11:36 kernel: CPU    3: hi:  186, btch:  31 usd: 176
15:11:36 kernel: CPU    4: hi:  186, btch:  31 usd:  35
15:11:36 kernel: CPU    5: hi:  186, btch:  31 usd: 176
15:11:36 kernel: CPU    6: hi:  186, btch:  31 usd:   8
15:11:36 kernel: CPU    7: hi:  186, btch:  31 usd: 185
15:11:36 kernel: Node 1 Normal per-cpu:
15:11:36 kernel: CPU    0: hi:  186, btch:  31 usd: 178
15:11:36 kernel: CPU    1: hi:  186, btch:  31 usd:  46
15:11:36 kernel: CPU    2: hi:  186, btch:  31 usd: 173
15:11:36 kernel: CPU    3: hi:  186, btch:  31 usd: 115
15:11:36 kernel: CPU    4: hi:  186, btch:  31 usd:  64
15:11:36 kernel: CPU    5: hi:  186, btch:  31 usd: 182
15:11:36 kernel: CPU    6: hi:  186, btch:  31 usd: 157
15:11:36 kernel: CPU    7: hi:  186, btch:  31 usd: 106
15:11:36 kernel: active_anon:5143 inactive_anon:1812 isolated_anon:0
15:11:36 kernel: active_file:29590 inactive_file:151570 isolated_file:0
15:11:36 kernel: unevictable:621 dirty:389 writeback:38 unstable:0
15:11:36 kernel: free:7979097 slab_reclaimable:19834 slab_unreclaimable:7983
15:11:36 kernel: mapped:3222 shmem:164 pagetables:1303 bounce:0
15:11:36 kernel: free_cma:0
15:11:36 kernel: Node 0 DMA free:15900kB min:40kB low:48kB high:60kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15984kB managed:15900kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
15:11:36 kernel: lowmem_reserve[]: 0 3425 16097 16097
15:11:36 kernel: Node 0 DMA32 free:3397280kB min:9572kB low:11964kB high:14356kB active_anon:1744kB inactive_anon:1012kB active_file:15288kB inactive_file:79760kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3522184kB managed:3509084kB mlocked:0kB dirty:4kB writeback:0kB mapped:2088kB shmem:88kB slab_reclaimable:3504kB slab_unreclaimable:2404kB kernel_stack:864kB pagetables:1400kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
15:11:36 kernel: lowmem_reserve[]: 0 0 12671 12671
15:11:36 kernel: Node 0 Normal free:12275860kB min:35416kB low:44268kB high:53124kB active_anon:10972kB inactive_anon:3316kB active_file:64280kB inactive_file:434628kB unevictable:320kB isolated(anon):0kB isolated(file):0kB present:13238272kB managed:12975484kB mlocked:320kB dirty:364kB writeback:0kB mapped:3232kB shmem:256kB slab_reclaimable:64444kB slab_unreclaimable:15780kB kernel_stack:1840kB pagetables:2196kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
15:11:36 kernel: lowmem_reserve[]: 0 0 0 0
15:11:36 kernel: Node 1 Normal free:16227348kB min:45076kB low:56344kB high:67612kB active_anon:7856kB inactive_anon:2920kB active_file:38792kB inactive_file:91892kB unevictable:2164kB isolated(anon):0kB isolated(file):0kB present:16777216kB managed:16514488kB mlocked:2164kB dirty:1188kB writeback:152kB mapped:7568kB shmem:312kB slab_reclaimable:11388kB slab_unreclaimable:13748kB kernel_stack:1712kB pagetables:1616kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
15:11:36 kernel: lowmem_reserve[]: 0 0 0 0
15:11:36 kernel: Node 0 DMA: 1*4kB (U) 1*8kB (U) 1*16kB (U) 0*32kB 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) = 15900kB
15:11:36 kernel: Node 0 DMA32: 229*4kB (UEM) 119*8kB (UEM) 56*16kB (UEM) 23*32kB (UEM) 13*64kB (UM) 12*128kB (UEM) 4*256kB (UM) 2*512kB (UM) 0*1024kB 3*2048kB (MR) 826*4096kB (MR) = 3397356kB
15:11:36 kernel: Node 0 Normal: 433*4kB (UEM) 187*8kB (UEM) 73*16kB (UEM) 56*32kB (UEM) 27*64kB (UEM) 11*128kB (UM) 5*256kB (UEM) 5*512kB (UEM) 4*1024kB (UM) 4*2048kB (M) 2991*4096kB (MR) = 12276588kB
15:11:36 kernel: Node 1 Normal: 588*4kB (UEM) 182*8kB (UEM) 50*16kB (UEM) 30*32kB (UEM) 20*64kB (UM) 22*128kB (UEM) 9*256kB (M) 9*512kB (UEM) 3*1024kB (M) 2*2048kB (M) 3956*4096kB (MR) = 16227520kB
15:11:36 kernel: Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
15:11:36 kernel: Node 1 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
15:11:36 kernel: 181749 total pagecache pages
15:11:36 kernel: 0 pages in swap cache
15:11:36 kernel: Swap cache stats: add 0, delete 0, find 0/0
15:11:36 kernel: Free swap  = 16507900kB
15:11:36 kernel: Total swap = 16507900kB
15:11:36 kernel: 8388414 pages RAM
15:11:36 kernel: 0 pages HighMem/MovableOnly
15:11:36 kernel: 65682 pages reserved
15:11:36 kernel: 0 pages hwpoisoned
15:11:36 kernel: [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
15:11:36 kernel: [ 1345]     0  1345     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1346]     0  1346     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1347]     0  1347     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1348]     0  1348     3072      214      12        0             0 agetty
15:11:36 kernel: [ 1349]     0  1349     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1350]     0  1350     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1351]     0  1351     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1352]     0  1352     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1353]     0  1353     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1354]     0  1354     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1355]     0  1355     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1356]     0  1356     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1357]     0  1357     3072      214      11        0             0 agetty
15:11:36 kernel: [ 1358]     0  1358     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1359]     0  1359     3072      202      12        0             0 agetty
15:11:36 kernel: [ 1360]     0  1360     4928      157      14        0             0 rc.startup
15:11:36 kernel: [ 1361]     0  1361     3072      202      12        0             0 agetty
15:11:36 kernel: [ 1362]     0  1362     4928      157      14        0             0 rc.startup
15:11:36 kernel: [ 1430]     0  1430    29365      482      22        0             0 rsyslogd
15:11:36 kernel: [ 1436]     0  1436     7887      300      20        0         -1000 sshd
15:11:36 kernel: [ 1439]     0  1439     9030      343      18        0             0 automount
15:11:36 kernel: [ 1449]     0  1449     1012      113       8        0             0 iscsid
15:11:36 kernel: [ 1450]     0  1450     1135      623       8        0         -1000 iscsid
15:11:36 kernel: [ 1454] 65534  1454     3115      153      10        0             0 dnsmasq
15:11:36 kernel: [ 1456]     0  1456     3359      277      12        0             0 ntpd
15:11:36 kernel: [ 1509]     0  1509     3616      125       8        0         -1000 tgtd
15:11:36 kernel: [ 1511]     0  1511     1567       83       8        0         -1000 tgtd
15:11:36 kernel: [ 1526]     0  1526     7947      397      20        0             0 lighttpd
15:11:36 kernel: [ 1530]     0  1530     5651      423      17        0             0 elastic-sshd
15:11:36 kernel: [ 1968]     0  1968    36379      105      25        0             0 diod
15:11:36 kernel: [ 1995]    -2  1995     7972      824      20        0             0 httpd
15:11:36 kernel: [ 1997]    -2  1997     4921      372      15        0             0 elastic-poolio
15:11:36 kernel: [ 2084]     0  2084     4928      219      14        0             0 elastic-floodwa
15:11:36 kernel: [ 2141]     0  2141     5130      446      15        0             0 elastic
15:11:36 kernel: [ 2283]     0  2283     5130      447      14        0             0 elastic
15:11:36 kernel: [ 2371]    -2  2371      962       93       7        0             0 contain
15:11:36 kernel: [ 2566]    -2  2566     2663      195      11        0             0 init
15:11:36 kernel: [ 2604]    -2  2604      962       93       7        0             0 contain
15:11:36 kernel: [ 2706]    -2  2706     2663      195      12        0             0 init
15:11:36 kernel: [ 3640]    -2  3640     2489      643       8        0             0 dhclient
15:11:36 kernel: [ 3727]    -2  3727     2489      643       8        0             0 dhclient
15:11:36 kernel: [ 3822]     0  3822     9614      689      24        0             0 sshd
15:11:36 kernel: [ 3834]    -2  3834    12147      384      22        0             0 rsyslogd
15:11:36 kernel: [ 3902]    -2  3902     4721      208      14        0             0 cron
15:11:36 kernel: [ 3912]    -2  3912    12147      384      22        0             0 rsyslogd
15:11:36 kernel: [ 3963]    -2  3963    12483      298      28        0             0 sshd
15:11:36 kernel: [ 3986]    -2  3986    12483      298      27        0             0 sshd
15:11:36 kernel: [ 4001]    -2  4001     3645      229      13        0             0 getty
15:11:36 kernel: [ 4386]     0  4386     4968      489      15        0             0 bash
15:11:36 kernel: [ 4540]    -2  4540    19001      793      41        0             0 apache2
15:11:36 kernel: [ 4548]    33  4548    18934      555      39        0             0 apache2
15:11:36 kernel: [ 4550]    33  4550    74860      663      68        0             0 apache2
15:11:36 kernel: [ 4551]    33  4551    74858      664      68        0             0 apache2
15:11:36 kernel: [ 4608]    -2  4608     4721      207      15        0             0 cron
15:11:36 kernel: [ 4625]    -2  4625     3645      229      13        0             0 getty
15:11:36 kernel: [ 5085]     0  5085     9613      689      24        0             0 sshd
15:11:36 kernel: [ 5088]     0  5088     4968      487      15        0             0 bash
15:11:36 kernel: [ 5098]     0  5098     2033      102      10        0             0 tail
15:11:36 kernel: [ 5102]     0  5102     7554      652      19        0             0 tar
15:11:36 kernel: [ 5163]     0  5163     1994      104       9        0             0 sleep
15:11:36 kernel: [ 5169]     0  5169     9579      690      23        0             0 sshd
15:11:36 kernel: [ 5172]     0  5172     3072      200      12        0             0 agetty
15:11:36 kernel: [ 5173]     0  5173     3072      201      12        0             0 agetty
15:11:36 kernel: [ 5174]     0  5174     4968      488      15        0             0 bash
15:11:36 kernel: Out of memory: Kill process 1995 (httpd) score 0 or sacrifice child
15:11:36 kernel: Killed process 1997 (elastic-poolio) total-vm:19684kB, anon-rss:276kB, file-rss:1212kB
15:11:36 kernel: tar invoked oom-killer: gfp_mask=0x0, order=0, oom_score_adj=0
15:11:36 kernel: tar cpuset=test mems_allowed=0-1
15:11:36 kernel: CPU: 3 PID: 5102 Comm: tar Not tainted 3.14.0-elastic #1
15:11:36 kernel: Hardware name: Supermicro H8DMT-IBX/H8DMT-IBX, BIOS 080014  10/17/2009
15:11:36 kernel: ffff8804119696a0 ffff8800d56dfbf8 ffffffff8185d77b ffff880411969080
15:11:36 kernel: ffff880411969080 ffff8800d56dfca8 ffffffff8112b820 ffff8800d56dfc28
15:11:36 kernel: ffffffff81133deb ffff880409060590 ffff88040f73c500 ffff8800d56dfc38
15:11:36 kernel: Call Trace:
15:11:36 kernel: [<ffffffff8185d77b>] dump_stack+0x51/0x77
15:11:36 kernel: [<ffffffff8112b820>] dump_header+0x7a/0x208
15:11:36 kernel: [<ffffffff81133deb>] ? __put_single_page+0x1b/0x1f
15:11:36 kernel: [<ffffffff8113448f>] ? put_page+0x22/0x24
15:11:36 kernel: [<ffffffff81129e38>] ? filemap_fault+0x2c2/0x36c
15:11:36 kernel: [<ffffffff813d146e>] ? ___ratelimit+0xe6/0x104
15:11:36 kernel: [<ffffffff8112bc1b>] oom_kill_process+0x6a/0x33b
15:11:36 kernel: [<ffffffff8112c306>] out_of_memory+0x41a/0x44d
15:11:36 kernel: [<ffffffff8112c39e>] pagefault_out_of_memory+0x65/0x77
15:11:36 kernel: [<ffffffff8106939e>] mm_fault_error+0xab/0x176
15:11:36 kernel: [<ffffffff810696f0>] __do_page_fault+0x287/0x3e2
15:11:36 kernel: [<ffffffff810f5018>] ? cpuacct_account_field+0x55/0x5d
15:11:36 kernel: [<ffffffff810f5018>] ? cpuacct_account_field+0x55/0x5d
15:11:36 kernel: [<ffffffff810e7816>] ? account_user_time+0x6e/0x97
15:11:36 kernel: [<ffffffff810e788c>] ? vtime_account_user+0x4d/0x52
15:11:36 kernel: [<ffffffff8106988f>] do_page_fault+0x44/0x61
15:11:36 kernel: [<ffffffff818618f8>] page_fault+0x28/0x30
15:11:36 kernel: Mem-Info:
15:11:36 kernel: Node 0 DMA per-cpu:
15:11:36 kernel: CPU    0: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    1: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    2: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    3: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    4: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    5: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    6: hi:    0, btch:   1 usd:   0
15:11:36 kernel: CPU    7: hi:    0, btch:   1 usd:   0
15:11:36 kernel: Node 0 DMA32 per-cpu:
15:11:36 kernel: CPU    0: hi:  186, btch:  31 usd: 150
15:11:36 kernel: CPU    1: hi:  186, btch:  31 usd: 166
15:11:36 kernel: CPU    2: hi:  186, btch:  31 usd: 100
15:11:36 kernel: CPU    3: hi:  186, btch:  31 usd: 162
15:11:36 kernel: CPU    4: hi:  186, btch:  31 usd:   3
15:11:36 kernel: CPU    5: hi:  186, btch:  31 usd: 163
15:11:36 kernel: CPU    6: hi:  186, btch:  31 usd:  18
15:11:36 kernel: CPU    7: hi:  186, btch:  31 usd: 162
15:11:36 kernel: Node 0 Normal per-cpu:
15:11:36 kernel: CPU    0: hi:  186, btch:  31 usd: 194
15:11:36 kernel: CPU    1: hi:  186, btch:  31 usd: 159
15:11:36 kernel: CPU    2: hi:  186, btch:  31 usd: 180
15:11:36 kernel: CPU    3: hi:  186, btch:  31 usd: 176
15:11:36 kernel: CPU    4: hi:  186, btch:  31 usd:  35
15:11:36 kernel: CPU    5: hi:  186, btch:  31 usd: 176
15:11:36 kernel: CPU    6: hi:  186, btch:  31 usd:   8
15:11:36 kernel: CPU    7: hi:  186, btch:  31 usd: 185
15:11:36 kernel: Node 1 Normal per-cpu:
15:11:36 kernel: CPU    0: hi:  186, btch:  31 usd: 178
15:11:36 kernel: CPU    1: hi:  186, btch:  31 usd:  46
15:11:36 kernel: CPU    2: hi:  186, btch:  31 usd: 173
15:11:36 kernel: CPU    3: hi:  186, btch:  31 usd: 115
15:11:36 kernel: CPU    4: hi:  186, btch:  31 usd:  64
15:11:36 kernel: CPU    5: hi:  186, btch:  31 usd: 182
15:11:36 kernel: CPU    6: hi:  186, btch:  31 usd: 157
15:11:36 kernel: CPU    7: hi:  186, btch:  31 usd: 106
15:11:36 kernel: active_anon:5078 inactive_anon:1812 isolated_anon:0
15:11:36 kernel: active_file:29590 inactive_file:151570 isolated_file:0
15:11:36 kernel: unevictable:621 dirty:389 writeback:38 unstable:0
15:11:36 kernel: free:7979097 slab_reclaimable:19834 slab_unreclaimable:7983
15:11:36 kernel: mapped:3222 shmem:164 pagetables:1303 bounce:0
15:11:36 kernel: free_cma:0
15:11:36 kernel: Node 0 DMA free:15900kB min:40kB low:48kB high:60kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15984kB managed:15900kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
15:11:36 kernel: lowmem_reserve[]: 0 3425 16097 16097
15:11:36 kernel: Node 0 DMA32 free:3397280kB min:9572kB low:11964kB high:14356kB active_anon:1744kB inactive_anon:1012kB active_file:15288kB inactive_file:79760kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3522184kB managed:3509084kB mlocked:0kB dirty:4kB writeback:0kB mapped:2088kB shmem:88kB slab_reclaimable:3504kB slab_unreclaimable:2404kB kernel_stack:864kB pagetables:1400kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
15:11:36 kernel: lowmem_reserve[]: 0 0 12671 12671
15:11:36 kernel: Node 0 Normal free:12275860kB min:35416kB low:44268kB high:53124kB active_anon:10712kB inactive_anon:3316kB active_file:64280kB inactive_file:434628kB unevictable:320kB isolated(anon):0kB isolated(file):0kB present:13238272kB managed:12975484kB mlocked:320kB dirty:364kB writeback:0kB mapped:3232kB shmem:256kB slab_reclaimable:64444kB slab_unreclaimable:15780kB kernel_stack:1840kB pagetables:2196kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
15:11:36 kernel: lowmem_reserve[]: 0 0 0 0
15:11:36 kernel: Node 1 Normal free:16227348kB min:45076kB low:56344kB high:67612kB active_anon:7856kB inactive_anon:2920kB active_file:38792kB inactive_file:91892kB unevictable:2164kB isolated(anon):0kB isolated(file):0kB present:16777216kB managed:16514488kB mlocked:2164kB dirty:1188kB writeback:152kB mapped:7568kB shmem:312kB slab_reclaimable:11388kB slab_unreclaimable:13748kB kernel_stack:1712kB pagetables:1616kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
15:11:36 kernel: lowmem_reserve[]: 0 0 0 0
15:11:36 kernel: Node 0 DMA: 1*4kB (U) 1*8kB (U) 1*16kB (U) 0*32kB 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) = 15900kB
15:11:36 kernel: Node 0 DMA32: 229*4kB (UEM) 119*8kB (UEM) 56*16kB (UEM) 23*32kB (UEM) 13*64kB (UM) 12*128kB (UEM) 4*256kB (UM) 2*512kB (UM) 0*1024kB 3*2048kB (MR) 826*4096kB (MR) = 3397356kB
15:11:36 kernel: Node 0 Normal: 433*4kB (UEM) 187*8kB (UEM) 73*16kB (UEM) 56*32kB (UEM) 27*64kB (UEM) 11*128kB (UM) 5*256kB (UEM) 5*512kB (UEM) 4*1024kB (UM) 4*2048kB (M) 2991*4096kB (MR) = 12276588kB
15:11:36 kernel: Node 1 Normal: 588*4kB (UEM) 198*8kB (UEM) 55*16kB (UEM) 30*32kB (UEM) 20*64kB (UM) 22*128kB (UEM) 9*256kB (M) 9*512kB (UEM) 3*1024kB (M) 2*2048kB (M) 3956*4096kB (MR) = 16227728kB
15:11:36 kernel: Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
15:11:36 kernel: Node 1 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
15:11:36 kernel: 181749 total pagecache pages
15:11:36 kernel: 0 pages in swap cache
15:11:36 kernel: Swap cache stats: add 0, delete 0, find 0/0
15:11:36 kernel: Free swap  = 16507900kB
15:11:36 kernel: Total swap = 16507900kB
15:11:36 kernel: 8388414 pages RAM
15:11:36 kernel: 0 pages HighMem/MovableOnly
15:11:36 kernel: 65682 pages reserved
15:11:36 kernel: 0 pages hwpoisoned
15:11:36 kernel: [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
15:11:36 kernel: [ 1345]     0  1345     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1346]     0  1346     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1347]     0  1347     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1348]     0  1348     3072      214      12        0             0 agetty
15:11:36 kernel: [ 1349]     0  1349     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1350]     0  1350     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1351]     0  1351     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1352]     0  1352     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1353]     0  1353     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1354]     0  1354     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1355]     0  1355     3072      213      12        0             0 agetty
15:11:36 kernel: [ 1356]     0  1356     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1357]     0  1357     3072      214      11        0             0 agetty
15:11:36 kernel: [ 1358]     0  1358     4928      121      14        0             0 rc.startup
15:11:36 kernel: [ 1359]     0  1359     3072      202      12        0             0 agetty
15:11:36 kernel: [ 1360]     0  1360     4928      157      14        0             0 rc.startup
15:11:36 kernel: [ 1361]     0  1361     3072      202      12        0             0 agetty
15:11:36 kernel: [ 1362]     0  1362     4928      157      14        0             0 rc.startup
15:11:36 kernel: [ 1430]     0  1430    29365      482      22        0             0 rsyslogd
15:11:36 kernel: [ 1436]     0  1436     7887      300      20        0         -1000 sshd
15:11:36 kernel: [ 1439]     0  1439     9030      343      18        0             0 automount
15:11:36 kernel: [ 1449]     0  1449     1012      113       8        0             0 iscsid
15:11:36 kernel: [ 1450]     0  1450     1135      623       8        0         -1000 iscsid
15:11:36 kernel: [ 1454] 65534  1454     3115      153      10        0             0 dnsmasq
15:11:36 kernel: [ 1456]     0  1456     3359      277      12        0             0 ntpd
15:11:36 kernel: [ 1509]     0  1509     3616      125       8        0         -1000 tgtd
15:11:36 kernel: [ 1511]     0  1511     1567       83       8        0         -1000 tgtd
15:11:36 kernel: [ 1526]     0  1526     7947      397      20        0             0 lighttpd
15:11:36 kernel: [ 1530]     0  1530     5651      423      17        0             0 elastic-sshd
15:11:36 kernel: [ 1968]     0  1968    36379      105      25        0             0 diod
15:11:36 kernel: [ 1995]    -2  1995     7972      824      20        0             0 httpd
15:11:36 kernel: [ 2084]     0  2084     4928      219      14        0             0 elastic-floodwa
15:11:36 kernel: [ 2141]     0  2141     5130      446      15        0             0 elastic
15:11:36 kernel: [ 2283]     0  2283     5130      447      14        0             0 elastic
15:11:36 kernel: [ 2371]    -2  2371      962       93       7        0             0 contain
15:11:36 kernel: [ 2566]    -2  2566     2663      195      11        0             0 init
15:11:36 kernel: [ 2604]    -2  2604      962       93       7        0             0 contain
15:11:36 kernel: [ 2706]    -2  2706     2663      195      12        0             0 init
15:11:36 kernel: [ 3640]    -2  3640     2489      643       8        0             0 dhclient
15:11:36 kernel: [ 3727]    -2  3727     2489      643       8        0             0 dhclient
15:11:36 kernel: [ 3822]     0  3822     9614      689      24        0             0 sshd
15:11:36 kernel: [ 3834]    -2  3834    12147      384      22        0             0 rsyslogd
15:11:36 kernel: [ 3902]    -2  3902     4721      208      14        0             0 cron
15:11:36 kernel: [ 3912]    -2  3912    12147      384      22        0             0 rsyslogd
15:11:36 kernel: [ 3963]    -2  3963    12483      298      28        0             0 sshd
15:11:36 kernel: [ 3986]    -2  3986    12483      298      27        0             0 sshd
15:11:36 kernel: [ 4001]    -2  4001     3645      229      13        0             0 getty
15:11:36 kernel: [ 4386]     0  4386     4968      489      15        0             0 bash
15:11:36 kernel: [ 4540]    -2  4540    19001      793      41        0             0 apache2
15:11:36 kernel: [ 4548]    33  4548    18934      555      39        0             0 apache2
15:11:36 kernel: [ 4550]    33  4550    74860      663      68        0             0 apache2
15:11:36 kernel: [ 4551]    33  4551    74858      664      68        0             0 apache2
15:11:36 kernel: [ 4608]    -2  4608     4721      207      15        0             0 cron
15:11:36 kernel: [ 4625]    -2  4625     3645      229      13        0             0 getty
15:11:36 kernel: [ 5085]     0  5085     9613      689      24        0             0 sshd
15:11:36 kernel: [ 5088]     0  5088     4968      487      15        0             0 bash
15:11:36 kernel: [ 5098]     0  5098     2033      102      10        0             0 tail
15:11:36 kernel: [ 5102]     0  5102     7554      652      19        0             0 tar
15:11:36 kernel: [ 5163]     0  5163     1994      104       9        0             0 sleep
15:11:36 kernel: [ 5169]     0  5169     9579      690      23        0             0 sshd
15:11:36 kernel: [ 5172]     0  5172     3072      200      12        0             0 agetty
15:11:36 kernel: [ 5173]     0  5173     3072      201      12        0             0 agetty
15:11:36 kernel: [ 5174]     0  5174     4968      488      15        0             0 bash
15:11:36 kernel: Out of memory: Kill process 1995 (httpd) score 0 or sacrifice child
15:11:36 kernel: Killed process 1995 (httpd) total-vm:31888kB, anon-rss:952kB, file-rss:2344kB
15:11:36 kernel: Out of memory: Kill process 4540 (apache2) score 0 or sacrifice child
15:11:36 kernel: Killed process 4551 (apache2) total-vm:299432kB, anon-rss:1896kB, file-rss:760kB
15:11:36 kernel: Out of memory: Kill process 4540 (apache2) score 0 or sacrifice child
15:11:36 kernel: Killed process 4550 (apache2) total-vm:299440kB, anon-rss:1896kB, file-rss:756kB
15:11:36 kernel: Out of memory: Kill process 4540 (apache2) score 0 or sacrifice child
15:11:36 kernel: Killed process 4548 (apache2) total-vm:75736kB, anon-rss:1648kB, file-rss:572kB
15:11:36 kernel: Out of memory: Kill process 4540 (apache2) score 0 or sacrifice child
15:11:36 kernel: Killed process 4540 (apache2) total-vm:76004kB, anon-rss:1680kB, file-rss:1492kB
15:11:37 kernel: Out of memory: Kill process 3822 (sshd) score 0 or sacrifice child
15:11:37 kernel: Killed process 4386 (bash) total-vm:19872kB, anon-rss:484kB, file-rss:1472kB
15:11:37 kernel: Out of memory: Kill process 3822 (sshd) score 0 or sacrifice child

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
