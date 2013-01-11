Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id CBF5F6B005D
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 06:51:55 -0500 (EST)
Date: Fri, 11 Jan 2013 22:51:35 +1100
From: paul.szabo@sydney.edu.au
Message-Id: <201301111151.r0BBpZt1023276@como.maths.usyd.edu.au>
Subject: Re: [RFC] Reproducible OOM with partial workaround
In-Reply-To: <20130111000119.8e9bdf5d.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: 695182@bugs.debian.org, dave@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Dear Andrew,

> Check /proc/slabinfo, see if all your lowmem got eaten up by buffer_heads.

Please see below: I do not know what any of that means. This machine has
been running just fine, with all my users logging in here via XDMCP from
X-terminals, dozens logged in simultaneously. (But, I think I could make
it go OOM with more processes or logins.)

> If so, you *may* be able to work around this by setting
> /proc/sys/vm/dirty_ratio really low, so the system keeps a minimum
> amount of dirty pagecache around.  Then, with luck, if we haven't
> broken the buffer_heads_over_limit logic it in the past decade (we
> probably have), the VM should be able to reclaim those buffer_heads.

I tried setting dirty_ratio to "funny" values, that did not seem to
help. Did you notice my patch about bdi_position_ratio(), how it was
plain wrong half the time (for negative x)? Anyway that did not help.

> Alternatively, use a filesystem which doesn't attach buffer_heads to
> dirty pages.  xfs or btrfs, perhaps.

Seems there is also a problem not related to filesystem... or rather,
the essence does not seem to be filesystem or caches. The filesystem
thing now seems OK with my patch doing drop_caches.

Cheers, Paul

Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
School of Mathematics and Statistics   University of Sydney    Australia


---

root@como:~# free -lm
             total       used       free     shared    buffers     cached
Mem:         62936       2317      60618          0         41        635
Low:           367        271         95
High:        62569       2045      60523
-/+ buffers/cache:       1640      61295
Swap:       131071          0     131071
root@como:~# cat /proc/slabinfo
slabinfo - version: 2.1
# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
fuse_request           0      0    376   43    4 : tunables    0    0    0 : slabdata      0      0      0
fuse_inode             0      0    448   36    4 : tunables    0    0    0 : slabdata      0      0      0
bsg_cmd                0      0    288   28    2 : tunables    0    0    0 : slabdata      0      0      0
ntfs_big_inode_cache      0      0    512   32    4 : tunables    0    0    0 : slabdata      0      0      0
ntfs_inode_cache       0      0    176   46    2 : tunables    0    0    0 : slabdata      0      0      0
nfs_direct_cache       0      0     80   51    1 : tunables    0    0    0 : slabdata      0      0      0
nfs_inode_cache     5404   5404    584   28    4 : tunables    0    0    0 : slabdata    193    193      0
isofs_inode_cache      0      0    360   45    4 : tunables    0    0    0 : slabdata      0      0      0
fat_inode_cache        0      0    408   40    4 : tunables    0    0    0 : slabdata      0      0      0
fat_cache              0      0     24  170    1 : tunables    0    0    0 : slabdata      0      0      0
jbd2_revoke_record      0      0     32  128    1 : tunables    0    0    0 : slabdata      0      0      0
journal_handle      5440   5440     24  170    1 : tunables    0    0    0 : slabdata     32     32      0
journal_head       16768  16768     64   64    1 : tunables    0    0    0 : slabdata    262    262      0
revoke_record      20224  20224     16  256    1 : tunables    0    0    0 : slabdata     79     79      0
ext4_inode_cache       0      0    584   28    4 : tunables    0    0    0 : slabdata      0      0      0
ext4_free_data         0      0     40  102    1 : tunables    0    0    0 : slabdata      0      0      0
ext4_allocation_context      0      0    112   36    1 : tunables    0    0    0 : slabdata      0      0      0
ext4_prealloc_space      0      0     72   56    1 : tunables    0    0    0 : slabdata      0      0      0
ext4_io_end            0      0    576   28    4 : tunables    0    0    0 : slabdata      0      0      0
ext4_io_page           0      0      8  512    1 : tunables    0    0    0 : slabdata      0      0      0
ext2_inode_cache       0      0    480   34    4 : tunables    0    0    0 : slabdata      0      0      0
ext3_inode_cache   16531  19965    488   33    4 : tunables    0    0    0 : slabdata    605    605      0
ext3_xattr             0      0     48   85    1 : tunables    0    0    0 : slabdata      0      0      0
dquot                840    840    192   42    2 : tunables    0    0    0 : slabdata     20     20      0
rpc_inode_cache      144    144    448   36    4 : tunables    0    0    0 : slabdata      4      4      0
UDP-Lite               0      0    576   28    4 : tunables    0    0    0 : slabdata      0      0      0
xfrm_dst_cache         0      0    320   51    4 : tunables    0    0    0 : slabdata      0      0      0
UDP                  896    896    576   28    4 : tunables    0    0    0 : slabdata     32     32      0
tw_sock_TCP         1344   1344    128   32    1 : tunables    0    0    0 : slabdata     42     42      0
TCP                 1457   1624   1152   28    8 : tunables    0    0    0 : slabdata     58     58      0
eventpoll_pwq       3264   3264     40  102    1 : tunables    0    0    0 : slabdata     32     32      0
blkdev_queue         330    330    968   33    8 : tunables    0    0    0 : slabdata     10     10      0
blkdev_requests     2368   2368    216   37    2 : tunables    0    0    0 : slabdata     64     64      0
biovec-256           350    350   3072   10    8 : tunables    0    0    0 : slabdata     35     35      0
biovec-128           693    693   1536   21    8 : tunables    0    0    0 : slabdata     33     33      0
biovec-64           1890   1890    768   42    8 : tunables    0    0    0 : slabdata     45     45      0
sock_inode_cache    8206   9408    384   42    4 : tunables    0    0    0 : slabdata    224    224      0
skbuff_fclone_cache   1806   1806    384   42    4 : tunables    0    0    0 : slabdata     43     43      0
file_lock_cache     1692   1692    112   36    1 : tunables    0    0    0 : slabdata     47     47      0
shmem_inode_cache   2244   2244    368   44    4 : tunables    0    0    0 : slabdata     51     51      0
Acpi-State         76245  76245     48   85    1 : tunables    0    0    0 : slabdata    897    897      0
taskstats           1568   1568    328   49    4 : tunables    0    0    0 : slabdata     32     32      0
proc_inode_cache   10736  10736    368   44    4 : tunables    0    0    0 : slabdata    244    244      0
sigqueue            1120   1120    144   28    1 : tunables    0    0    0 : slabdata     40     40      0
bdev_cache           608    608    512   32    4 : tunables    0    0    0 : slabdata     19     19      0
sysfs_dir_cache    36057  36057     80   51    1 : tunables    0    0    0 : slabdata    707    707      0
inode_cache         7584   7584    336   48    4 : tunables    0    0    0 : slabdata    158    158      0
dentry             32995  43584    128   32    1 : tunables    0    0    0 : slabdata   1362   1362      0
buffer_head        83001  83001     56   73    1 : tunables    0    0    0 : slabdata   1137   1137      0
vm_area_struct     51480  83352     88   46    1 : tunables    0    0    0 : slabdata   1812   1812      0
mm_struct           2257   2556    448   36    4 : tunables    0    0    0 : slabdata     71     71      0
signal_cache        3584   3584    576   28    4 : tunables    0    0    0 : slabdata    128    128      0
sighand_cache       2664   2664   1344   24    8 : tunables    0    0    0 : slabdata    111    111      0
task_xstate         8154   8268    832   39    8 : tunables    0    0    0 : slabdata    212    212      0
task_struct         8896   8896   1008   32    8 : tunables    0    0    0 : slabdata    278    278      0
anon_vma_chain     70596  96050     24  170    1 : tunables    0    0    0 : slabdata    565    565      0
anon_vma           52113  62934     40  102    1 : tunables    0    0    0 : slabdata    617    617      0
radix_tree_node    15722  22578    304   53    4 : tunables    0    0    0 : slabdata    426    426      0
idr_layer_cache     9116   9116    152   53    2 : tunables    0    0    0 : slabdata    172    172      0
dma-kmalloc-8192       0      0   8192    4    8 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-4096       0      0   4096    8    8 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-2048       0      0   2048   16    8 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-1024       0      0   1024   32    8 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-512        0      0    512   32    4 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-256        0      0    256   32    2 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-128        0      0    128   32    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-64         0      0     64   64    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-32         0      0     32  128    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-16         0      0     16  256    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-8          0      0      8  512    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-192        0      0    192   42    2 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-96         0      0     96   42    1 : tunables    0    0    0 : slabdata      0      0      0
kmalloc-8192         272    272   8192    4    8 : tunables    0    0    0 : slabdata     68     68      0
kmalloc-4096         585    608   4096    8    8 : tunables    0    0    0 : slabdata     76     76      0
kmalloc-2048         714    832   2048   16    8 : tunables    0    0    0 : slabdata     52     52      0
kmalloc-1024        5351   5536   1024   32    8 : tunables    0    0    0 : slabdata    173    173      0
kmalloc-512         7776   8512    512   32    4 : tunables    0    0    0 : slabdata    266    266      0
kmalloc-256         3334   3936    256   32    2 : tunables    0    0    0 : slabdata    123    123      0
kmalloc-128         5375   7744    128   32    1 : tunables    0    0    0 : slabdata    242    242      0
kmalloc-64         28005  35584     64   64    1 : tunables    0    0    0 : slabdata    556    556      0
kmalloc-32         67453  68224     32  128    1 : tunables    0    0    0 : slabdata    533    533      0
kmalloc-16         78772  83968     16  256    1 : tunables    0    0    0 : slabdata    328    328      0
kmalloc-8          70656  70656      8  512    1 : tunables    0    0    0 : slabdata    138    138      0
kmalloc-192        38594  64050    192   42    2 : tunables    0    0    0 : slabdata   1525   1525      0
kmalloc-96         21630  21630     96   42    1 : tunables    0    0    0 : slabdata    515    515      0
kmem_cache            32     32    128   32    1 : tunables    0    0    0 : slabdata      1      1      0
kmem_cache_node      512    512     32  128    1 : tunables    0    0    0 : slabdata      4      4      0
root@como:~# 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
