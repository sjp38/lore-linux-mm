Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1A38E6B003D
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 06:17:46 -0400 (EDT)
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.14.3/8.13.8) with ESMTP id n2HAHeXi211822
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 10:17:40 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2HAHeqh2728186
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 10:17:40 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2HAHefW001467
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 10:17:40 GMT
Date: Tue, 17 Mar 2009 11:17:38 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: oom-killer killing even if memory is available?
Message-ID: <20090317111738.3cd32fa4@osiris.boeblingen.de.ibm.com>
In-Reply-To: <20090317024605.846420e1.akpm@linux-foundation.org>
References: <20090317100049.33f67964@osiris.boeblingen.de.ibm.com>
	<20090317024605.846420e1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@suse.de>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andreas Krebbel <krebbel@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Mar 2009 02:46:05 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:
> > Mar 16 21:40:40 t6360003 kernel: Active_anon:372 active_file:45 inactive_anon:154
> > Mar 16 21:40:40 t6360003 kernel:  inactive_file:152 unevictable:987 dirty:0 writeback:188 unstable:0
> > Mar 16 21:40:40 t6360003 kernel:  free:146348 slab:875833 mapped:805 pagetables:378 bounce:0
> > Mar 16 21:40:40 t6360003 kernel: DMA free:467728kB min:4064kB low:5080kB high:6096kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:116kB unevictable:0kB present:2068480kB pages_scanned:0 all_unreclaimable? no
> > Mar 16 21:40:40 t6360003 kernel: lowmem_reserve[]: 0 2020 2020
> > Mar 16 21:40:40 t6360003 kernel: Normal free:117664kB min:4064kB low:5080kB high:6096kB active_anon:1488kB inactive_anon:616kB active_file:188kB inactive_file:492kB unevictable:3948kB present:2068480kB pages_scanned:128 all_unreclaimable? no
> > Mar 16 21:40:40 t6360003 kernel: lowmem_reserve[]: 0 0 0
> 
> The scanner has wrung pretty much all it can out of the reclaimable pages -
> the LRUs are nearly empty.  There's a few hundred MB free and apparently we
> don't have four physically contiguous free pages anywhere.  It's
> believeable.
> 
> The question is: where the heck did all your memory go?  You have 2GB of
> ZONE_NORMAL memory in that machine, but only a tenth of it is visible to
> the page reclaim code.
> 
> Something must have allocated (and possibly leaked) it.

Looks like most of the memory went for dentries and inodes.
slabtop output:

 Active / Total Objects (% used)    : 8172165 / 8326954 (98.1%)
 Active / Total Slabs (% used)      : 903692 / 903698 (100.0%)
 Active / Total Caches (% used)     : 91 / 144 (63.2%)
 Active / Total Size (% used)       : 3251262.44K / 3281384.22K (99.1%)
 Minimum / Average / Maximum Object : 0.02K / 0.39K / 1024.00K

  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME                   
3960036 3960017  99%    0.59K 660006        6   2640024K inode_cache
4137155 3997581  96%    0.20K 217745       19    870980K dentry
 69776  69744  99%    0.80K  17444        4     69776K ext3_inode_cache
 96792  92892  95%    0.10K   2616       37     10464K buffer_head
 10024   9895  98%    0.54K   1432        7      5728K radix_tree_node
  1093   1087  99%    4.00K   1093        1      4372K size-4096
 14805  14711  99%    0.25K    987       15      3948K size-256
  2400   2381  99%    0.80K    480        5      1920K shmem_inode_cache
  1416   1416 100%    1.00K    354        4      1416K size-1024
   152    152 100%    5.59K    152        1      1216K task_struct
   370    359  97%    2.00K    185        2       740K size-2048
  9381   4359  46%    0.06K    159       59       636K size-64
     8      8 100%   64.00K      8        1       512K size-65536
   976    952  97%    0.50K    122        8       488K size-512
   177    156  88%    2.25K     59        3       472K sighand_cache
  6254   6070  97%    0.07K    118       53       472K sysfs_dir_cache
  1335    422  31%    0.25K     89       15       356K filp
  1830   1298  70%    0.12K     61       30       244K size-128
  1288   1061  82%    0.16K     56       23       224K vm_area_struct
   184    160  86%    1.00K     46        4       184K signal_cache
  4704   4548  96%    0.03K     42      112       168K size-32
   205    178  86%    0.75K     41        5       164K sock_inode_cache
   234    234 100%    0.64K     39        6       156K proc_inode_cache
   150    143  95%    0.75K     30        5       120K kmem_cache
   120     97  80%    1.00K     30        4       120K files_cache
     6      6 100%   16.00K      6        1        96K size-16384
   720    124  17%    0.12K     24       30        96K pid
   140    116  82%    0.53K     20        7        80K idr_layer_cache
    30     30 100%    2.11K     10        3        80K blkdev_queue
    18     18 100%    4.00K     18        1        72K biovec-256
    17     17 100%    4.00K     17        1        68K size-4096(DMA)
    68     67  98%    1.00K     17        4        68K RAWv6
     2      2 100%   32.00K      2        1        64K size-32768
    65     65 100%    0.75K     13        5        52K RAW
    48     48 100%    1.00K     12        4        48K mm_struct
    40     36  90%    1.00K     10        4        40K bdev_cache
    50     19  38%    0.75K     10        5        40K UNIX
   400     42  10%    0.09K     10       40        40K journal_head
    18     18 100%    2.00K      9        2        36K biovec-128
   472     96  20%    0.06K      8       59        32K fs_cache
   105    105 100%    0.25K      7       15        28K skbuff_head_cache
   210     18   8%    0.12K      7       30        28K bio
    24     21  87%    1.00K      6        4        24K size-1024(DMA)
   864    489  56%    0.02K      6      144        24K anon_vma
    24     18  75%    1.00K      6        4        24K biovec-64
    35     32  91%    0.50K      5        7        20K skbuff_fclone_cache
    32     18  56%    0.50K      4        8        16K size-512(DMA)
    60     26  43%    0.25K      4       15        16K mnt_cache
    60     18  30%    0.25K      4       15        16K biovec-16
     8      6  75%    1.75K      4        2        16K TCP
     8      8 100%    2.00K      4        2        16K rpc_buffers
    66      4   6%    0.17K      3       22        12K file_lock_cache
    30     20  66%    0.36K      3       10        12K blkdev_requests
    12      5  41%    1.00K      3        4        12K UDP
    45      4   8%    0.25K      3       15        12K uid_cache
    21     13  61%    0.50K      3        7        12K ip6_dst_cache
   336    256  76%    0.03K      3      112        12K dm_io
   432    256  59%    0.02K      3      144        12K dm_target_io
    30      7  23%    0.25K      2       15         8K size-256(DMA)
   118     18  15%    0.06K      2       59         8K biovec-4
    96      8   8%    0.08K      2       48         8K blkdev_ioc
    14      4  28%    0.50K      2        7         8K ip_dst_cache
     5      5 100%    1.50K      1        5         8K qdio_q
     4      3  75%    1.75K      2        2         8K TCPv6
     8      6  75%    1.00K      2        4         8K rpc_inode_cache
    14      8  57%    0.50K      2        7         8K rpc_tasks
   112      4   3%    0.03K      1      112         4K size-32(DMA)
    59     34  57%    0.06K      1       59         4K size-64(DMA)
     1      1 100%    4.00K      1        1         4K names_cache
   202     18   8%    0.02K      1      202         4K biovec-1
    30      2   6%    0.12K      1       30         4K sgpool-8
    15      2  13%    0.25K      1       15         4K sgpool-16
     8      2  25%    0.50K      1        8         4K sgpool-32

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
