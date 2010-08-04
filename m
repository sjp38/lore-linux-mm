Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DE3B0660019
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 22:21:54 -0400 (EDT)
Date: Wed, 4 Aug 2010 10:21:48 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Over-eager swapping
Message-ID: <20100804022148.GA5922@localhost>
References: <20100802124734.GI2486@arachsys.com>
 <AANLkTinnWQA-K6r_+Y+giEC9zs-MbY6GFs8dWadSq0kh@mail.gmail.com>
 <20100803033108.GA23117@arachsys.com>
 <AANLkTinjmZOOaq7FgwJOZ=UNGS8x8KtQWZg6nv7fqJMe@mail.gmail.com>
 <20100803042835.GA17377@localhost>
 <20100803214945.GA2326@arachsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100803214945.GA2326@arachsys.com>
Sender: owner-linux-mm@kvack.org
To: Chris Webb <chris@arachsys.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

Chris,

Your slabinfo does contain many order 1-3 slab caches, this is a major source
of high order allocations and hence lumpy reclaim. fork() is another.

In another thread, Pekka Enberg offers a tip:

        You can pass "slub_debug=o" as a kernel parameter to disable higher
        order allocations if you want to test things.

Note that the parameter works on a CONFIG_SLUB_DEBUG=y kernel.

Thanks,
Fengguang


On Wed, Aug 04, 2010 at 05:49:46AM +0800, Chris Webb wrote:
> Wu Fengguang <fengguang.wu@intel.com> writes:
> 
> > Chris, what's in your /proc/slabinfo?
> 
> Hi. Sorry for the slow reply. The exact machine from which I previously
> extracted that /proc/memstat has unfortunately had swap turned off by a
> colleague while I was away, presumably because its behaviour because too
> bad. However, here is info from another member of the cluster, this time
> with 5GB of buffers and 2GB of swap in use, i.e. the same general problem:
> 
> # cat /proc/meminfo 
> MemTotal:       33084008 kB
> MemFree:         2291464 kB
> Buffers:         4908468 kB
> Cached:            16056 kB
> SwapCached:      1427480 kB
> Active:         22885508 kB
> Inactive:        5719520 kB
> Active(anon):   20466488 kB
> Inactive(anon):  3215888 kB
> Active(file):    2419020 kB
> Inactive(file):  2503632 kB
> Unevictable:       10688 kB
> Mlocked:           10688 kB
> SwapTotal:      25165816 kB
> SwapFree:       22798248 kB
> Dirty:              2616 kB
> Writeback:             0 kB
> AnonPages:      23410296 kB
> Mapped:             6324 kB
> Shmem:                56 kB
> Slab:             692296 kB
> SReclaimable:     189032 kB
> SUnreclaim:       503264 kB
> KernelStack:        4568 kB
> PageTables:        65588 kB
> NFS_Unstable:          0 kB
> Bounce:                0 kB
> WritebackTmp:          0 kB
> CommitLimit:    41707820 kB
> Committed_AS:   34859884 kB
> VmallocTotal:   34359738367 kB
> VmallocUsed:      147616 kB
> VmallocChunk:   34342399496 kB
> HardwareCorrupted:     0 kB
> HugePages_Total:       0
> HugePages_Free:        0
> HugePages_Rsvd:        0
> HugePages_Surp:        0
> Hugepagesize:       2048 kB
> DirectMap4k:        5888 kB
> DirectMap2M:     2156544 kB
> DirectMap1G:    31457280 kB
> 
> # cat /proc/slabinfo 
> slabinfo - version: 2.1
> # name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
> kmalloc_dma-512       32     32    512   32    4 : tunables    0    0    0 : slabdata      1      1      0
> nf_conntrack_expect    312    312    208   39    2 : tunables    0    0    0 : slabdata      8      8      0
> nf_conntrack         240    240    272   30    2 : tunables    0    0    0 : slabdata      8      8      0
> dm_raid1_read_record      0      0   1064   30    8 : tunables    0    0    0 : slabdata      0      0      0
> dm_crypt_io          240    260    152   26    1 : tunables    0    0    0 : slabdata     10     10      0
> kcopyd_job             0      0    368   22    2 : tunables    0    0    0 : slabdata      0      0      0
> dm_uevent              0      0   2608   12    8 : tunables    0    0    0 : slabdata      0      0      0
> dm_rq_target_io        0      0    376   21    2 : tunables    0    0    0 : slabdata      0      0      0
> cfq_queue              0      0    168   24    1 : tunables    0    0    0 : slabdata      0      0      0
> bsg_cmd                0      0    312   26    2 : tunables    0    0    0 : slabdata      0      0      0
> mqueue_inode_cache     36     36    896   36    8 : tunables    0    0    0 : slabdata      1      1      0
> udf_inode_cache        0      0    640   25    4 : tunables    0    0    0 : slabdata      0      0      0
> fuse_request           0      0    632   25    4 : tunables    0    0    0 : slabdata      0      0      0
> fuse_inode             0      0    704   23    4 : tunables    0    0    0 : slabdata      0      0      0
> ntfs_big_inode_cache      0      0    832   39    8 : tunables    0    0    0 : slabdata      0      0      0
> ntfs_inode_cache       0      0    264   31    2 : tunables    0    0    0 : slabdata      0      0      0
> isofs_inode_cache      0      0    616   26    4 : tunables    0    0    0 : slabdata      0      0      0
> fat_inode_cache        0      0    648   25    4 : tunables    0    0    0 : slabdata      0      0      0
> fat_cache              0      0     40  102    1 : tunables    0    0    0 : slabdata      0      0      0
> hugetlbfs_inode_cache     28     28    584   28    4 : tunables    0    0    0 : slabdata      1      1      0
> squashfs_inode_cache      0      0    640   25    4 : tunables    0    0    0 : slabdata      0      0      0
> journal_handle      1360   1360     24  170    1 : tunables    0    0    0 : slabdata      8      8      0
> journal_head         288    288    112   36    1 : tunables    0    0    0 : slabdata      8      8      0
> revoke_table         512    512     16  256    1 : tunables    0    0    0 : slabdata      2      2      0
> revoke_record       1024   1024     32  128    1 : tunables    0    0    0 : slabdata      8      8      0
> ext4_inode_cache       0      0    896   36    8 : tunables    0    0    0 : slabdata      0      0      0
> ext4_free_block_extents      0      0     56   73    1 : tunables    0    0    0 : slabdata      0      0      0
> ext4_alloc_context      0      0    144   28    1 : tunables    0    0    0 : slabdata      0      0      0
> ext4_prealloc_space      0      0    104   39    1 : tunables    0    0    0 : slabdata      0      0      0
> ext4_system_zone       0      0     40  102    1 : tunables    0    0    0 : slabdata      0      0      0
> ext2_inode_cache       0      0    752   21    4 : tunables    0    0    0 : slabdata      0      0      0
> ext3_inode_cache    2371   2457    768   21    4 : tunables    0    0    0 : slabdata    117    117      0
> ext3_xattr             0      0     88   46    1 : tunables    0    0    0 : slabdata      0      0      0
> configfs_dir_cache      0      0     88   46    1 : tunables    0    0    0 : slabdata      0      0      0
> kioctx                 0      0    320   25    2 : tunables    0    0    0 : slabdata      0      0      0
> inotify_inode_mark_entry     36     36    112   36    1 : tunables    0    0    0 : slabdata      1      1      0
> posix_timers_cache    224    224    144   28    1 : tunables    0    0    0 : slabdata      8      8      0
> kvm_vcpu              38     45  10256    3    8 : tunables    0    0    0 : slabdata     15     15      0
> kvm_rmap_desc      19408  21828     40  102    1 : tunables    0    0    0 : slabdata    214    214      0
> kvm_pte_chain      14514  28543     56   73    1 : tunables    0    0    0 : slabdata    391    391      0
> UDP-Lite               0      0    768   21    4 : tunables    0    0    0 : slabdata      0      0      0
> ip_dst_cache         221    231    384   21    2 : tunables    0    0    0 : slabdata     11     11      0
> UDP                  168    168    768   21    4 : tunables    0    0    0 : slabdata      8      8      0
> tw_sock_TCP          256    256    256   32    2 : tunables    0    0    0 : slabdata      8      8      0
> TCP                  191    220   1472   22    8 : tunables    0    0    0 : slabdata     10     10      0
> blkdev_queue         178    210   2128   15    8 : tunables    0    0    0 : slabdata     14     14      0
> blkdev_requests      608    816    336   24    2 : tunables    0    0    0 : slabdata     34     34      0
> fsnotify_event         0      0    104   39    1 : tunables    0    0    0 : slabdata      0      0      0
> sock_inode_cache     250    300    640   25    4 : tunables    0    0    0 : slabdata     12     12      0
> file_lock_cache      176    176    184   22    1 : tunables    0    0    0 : slabdata      8      8      0
> shmem_inode_cache   1617   1827    776   21    4 : tunables    0    0    0 : slabdata     87     87      0
> Acpi-ParseExt       1692   1736     72   56    1 : tunables    0    0    0 : slabdata     31     31      0
> proc_inode_cache    1182   1326    616   26    4 : tunables    0    0    0 : slabdata     51     51      0
> sigqueue             200    200    160   25    1 : tunables    0    0    0 : slabdata      8      8      0
> radix_tree_node    65891  69542    560   29    4 : tunables    0    0    0 : slabdata   2398   2398      0
> bdev_cache           312    312    832   39    8 : tunables    0    0    0 : slabdata      8      8      0
> sysfs_dir_cache    21585  22287     80   51    1 : tunables    0    0    0 : slabdata    437    437      0
> inode_cache         2903   2996    568   28    4 : tunables    0    0    0 : slabdata    107    107      0
> dentry              8532   8631    192   21    1 : tunables    0    0    0 : slabdata    411    411      0
> buffer_head       1227688 1296648    112   36    1 : tunables    0    0    0 : slabdata  36018  36018      0
> vm_area_struct     18494  19389    176   23    1 : tunables    0    0    0 : slabdata    843    843      0
> files_cache          236    322    704   23    4 : tunables    0    0    0 : slabdata     14     14      0
> signal_cache         606    702    832   39    8 : tunables    0    0    0 : slabdata     18     18      0
> sighand_cache        415    480   2112   15    8 : tunables    0    0    0 : slabdata     32     32      0
> task_struct          671    840   1616   20    8 : tunables    0    0    0 : slabdata     42     42      0
> anon_vma            1511   1920     32  128    1 : tunables    0    0    0 : slabdata     15     15      0
> shared_policy_node    255    255     48   85    1 : tunables    0    0    0 : slabdata      3      3      0
> numa_policy        19205  20910     24  170    1 : tunables    0    0    0 : slabdata    123    123      0
> idr_layer_cache      373    390    544   30    4 : tunables    0    0    0 : slabdata     13     13      0
> kmalloc-8192          36     36   8192    4    8 : tunables    0    0    0 : slabdata      9      9      0
> kmalloc-4096        2284   2592   4096    8    8 : tunables    0    0    0 : slabdata    324    324      0
> kmalloc-2048         750    896   2048   16    8 : tunables    0    0    0 : slabdata     56     56      0
> kmalloc-1024        4025   4320   1024   32    8 : tunables    0    0    0 : slabdata    135    135      0
> kmalloc-512         1358   1760    512   32    4 : tunables    0    0    0 : slabdata     55     55      0
> kmalloc-256         1402   1952    256   32    2 : tunables    0    0    0 : slabdata     61     61      0
> kmalloc-128         8625   9280    128   32    1 : tunables    0    0    0 : slabdata    290    290      0
> kmalloc-64        7030122 7455232     64   64    1 : tunables    0    0    0 : slabdata 116488 116488      0
> kmalloc-32         18603  19712     32  128    1 : tunables    0    0    0 : slabdata    154    154      0
> kmalloc-16          8895   9728     16  256    1 : tunables    0    0    0 : slabdata     38     38      0
> kmalloc-8           9047  10752      8  512    1 : tunables    0    0    0 : slabdata     21     21      0
> kmalloc-192         5130   9135    192   21    1 : tunables    0    0    0 : slabdata    435    435      0
> kmalloc-96          1905   2940     96   42    1 : tunables    0    0    0 : slabdata     70     70      0
> kmem_cache_node      196    256     64   64    1 : tunables    0    0    0 : slabdata      4      4      0
> 
> # cat /proc/buddyinfo 
> Node 0, zone      DMA      2      0      2      2      2      2      2      1      2      2      2 
> Node 0, zone    DMA32  61877  10368    111     10      2      3      1      0      0      0      0 
> Node 0, zone   Normal   2036      0     14     12      6      3      3      0      1      0      0 
> Node 1, zone   Normal 483348     15      2      3      7      1      3      1      0      0      0 
>  
> Best wishes,
> 
> Chris.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
