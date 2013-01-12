Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 5216B6B0068
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 22:32:20 -0500 (EST)
Date: Sat, 12 Jan 2013 14:31:59 +1100
From: paul.szabo@sydney.edu.au
Message-Id: <201301120331.r0C3VxXc016220@como.maths.usyd.edu.au>
Subject: [RFC] Reproducible OOM with just a few sleeps
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: 695182@bugs.debian.org, linux-kernel@vger.kernel.org

Dear Linux-MM,

Seems that any i386 PAE machine will go OOM just by running a few
processes. To reproduce:
  sh -c 'n=0; while [ $n -lt 19999 ]; do sleep 600 & ((n=n+1)); done'
My machine has 64GB RAM. With previous OOM episodes, it seemed that
running (booting) it with mem=32G might avoid OOM; but an OOM was
obtained just the same, and also with lower memory:
  Memory    sleeps to OOM       free shows total
  (mem=64G)  5300               64447796
  mem=32G   10200               31155512
  mem=16G   13400               14509364
  mem=8G    14200               6186296
  mem=6G    15200               4105532
  mem=4G    16400               2041364
The machine does not run out of highmem, nor does it use any swap.

Comparing with my desktop PC: has 4GB RAM installed, free shows 3978592
total. Running the "sleep test", it simply froze after 16400 running...
no response to ping, will need to press the RESET button.

---

On my large machine, 'free' fails to show about 2GB memory, e.g. with
mem=16G it shows:

root@zeno:~# free -l
             total       used       free     shared    buffers     cached
Mem:      14509364     435440   14073924          0       4068     111328
Low:        769044     120232     648812
High:     13740320     315208   13425112
-/+ buffers/cache:     320044   14189320
Swap:    134217724          0  134217724

---

Please let me know of any ideas, or if you want me to run some other
test or want to see some other output.

Thanks, Paul

Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
School of Mathematics and Statistics   University of Sydney    Australia


-----

Details for when my machine was running with 64GB RAM:

In another window I was running
  cat /proc/slabinfo; free -l
repeatedly, and output of that (just before OOM) was:

+ cat /proc/slabinfo
slabinfo - version: 2.1
# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
fuse_request           0      0    376   43    4 : tunables    0    0    0 : slabdata      0      0      0
fuse_inode             0      0    448   36    4 : tunables    0    0    0 : slabdata      0      0      0
bsg_cmd                0      0    288   28    2 : tunables    0    0    0 : slabdata      0      0      0
ntfs_big_inode_cache      0      0    512   32    4 : tunables    0    0    0 : slabdata      0      0      0
ntfs_inode_cache       0      0    176   46    2 : tunables    0    0    0 : slabdata      0      0      0
nfs_direct_cache       0      0     80   51    1 : tunables    0    0    0 : slabdata      0      0      0
nfs_inode_cache       28     28    584   28    4 : tunables    0    0    0 : slabdata      1      1      0
isofs_inode_cache      0      0    360   45    4 : tunables    0    0    0 : slabdata      0      0      0
fat_inode_cache        0      0    408   40    4 : tunables    0    0    0 : slabdata      0      0      0
fat_cache              0      0     24  170    1 : tunables    0    0    0 : slabdata      0      0      0
jbd2_revoke_record      0      0     32  128    1 : tunables    0    0    0 : slabdata      0      0      0
journal_handle      4080   4080     24  170    1 : tunables    0    0    0 : slabdata     24     24      0
journal_head        1024   1024     64   64    1 : tunables    0    0    0 : slabdata     16     16      0
revoke_record        768    768     16  256    1 : tunables    0    0    0 : slabdata      3      3      0
ext4_inode_cache       0      0    584   28    4 : tunables    0    0    0 : slabdata      0      0      0
ext4_free_data         0      0     40  102    1 : tunables    0    0    0 : slabdata      0      0      0
ext4_allocation_context      0      0    112   36    1 : tunables    0    0    0 : slabdata      0      0      0
ext4_prealloc_space      0      0     72   56    1 : tunables    0    0    0 : slabdata      0      0      0
ext4_io_end            0      0    576   28    4 : tunables    0    0    0 : slabdata      0      0      0
ext4_io_page           0      0      8  512    1 : tunables    0    0    0 : slabdata      0      0      0
ext2_inode_cache       0      0    480   34    4 : tunables    0    0    0 : slabdata      0      0      0
ext3_inode_cache    1467   2079    488   33    4 : tunables    0    0    0 : slabdata     63     63      0
ext3_xattr             0      0     48   85    1 : tunables    0    0    0 : slabdata      0      0      0
dquot                168    168    192   42    2 : tunables    0    0    0 : slabdata      4      4      0
rpc_inode_cache      108    108    448   36    4 : tunables    0    0    0 : slabdata      3      3      0
UDP-Lite               0      0    576   28    4 : tunables    0    0    0 : slabdata      0      0      0
xfrm_dst_cache         0      0    320   51    4 : tunables    0    0    0 : slabdata      0      0      0
UDP                  336    336    576   28    4 : tunables    0    0    0 : slabdata     12     12      0
tw_sock_TCP           32     32    128   32    1 : tunables    0    0    0 : slabdata      1      1      0
TCP                  504    504   1152   28    8 : tunables    0    0    0 : slabdata     18     18      0
eventpoll_pwq          0      0     40  102    1 : tunables    0    0    0 : slabdata      0      0      0
blkdev_queue         264    264    968   33    8 : tunables    0    0    0 : slabdata      8      8      0
blkdev_requests      925    925    216   37    2 : tunables    0    0    0 : slabdata     25     25      0
biovec-256            10     10   3072   10    8 : tunables    0    0    0 : slabdata      1      1      0
biovec-128           105    105   1536   21    8 : tunables    0    0    0 : slabdata      5      5      0
biovec-64            588    588    768   42    8 : tunables    0    0    0 : slabdata     14     14      0
sock_inode_cache    1512   1512    384   42    4 : tunables    0    0    0 : slabdata     36     36      0
skbuff_fclone_cache    966    966    384   42    4 : tunables    0    0    0 : slabdata     23     23      0
file_lock_cache      648    648    112   36    1 : tunables    0    0    0 : slabdata     18     18      0
shmem_inode_cache   1716   1716    368   44    4 : tunables    0    0    0 : slabdata     39     39      0
Acpi-State         75990  75990     48   85    1 : tunables    0    0    0 : slabdata    894    894      0
taskstats              0      0    328   49    4 : tunables    0    0    0 : slabdata      0      0      0
proc_inode_cache    5326   5588    368   44    4 : tunables    0    0    0 : slabdata    127    127      0
sigqueue             980    980    144   28    1 : tunables    0    0    0 : slabdata     35     35      0
bdev_cache           544    544    512   32    4 : tunables    0    0    0 : slabdata     17     17      0
sysfs_dir_cache    25245  25245     80   51    1 : tunables    0    0    0 : slabdata    495    495      0
inode_cache         2083   2592    336   48    4 : tunables    0    0    0 : slabdata     54     54      0
dentry              7956  10944    128   32    1 : tunables    0    0    0 : slabdata    342    342      0
buffer_head         2847   2847     56   73    1 : tunables    0    0    0 : slabdata     39     39      0
vm_area_struct    103684 103684     88   46    1 : tunables    0    0    0 : slabdata   2254   2254      0
mm_struct           6444   6444    448   36    4 : tunables    0    0    0 : slabdata    179    179      0
signal_cache        6692   6692    576   28    4 : tunables    0    0    0 : slabdata    239    239      0
sighand_cache       6312   6312   1344   24    8 : tunables    0    0    0 : slabdata    263    263      0
task_xstate         6357   6357    832   39    8 : tunables    0    0    0 : slabdata    163    163      0
task_struct         6720   6720   1008   32    8 : tunables    0    0    0 : slabdata    210    210      0
anon_vma_chain     91970  91970     24  170    1 : tunables    0    0    0 : slabdata    541    541      0
anon_vma           57018  57018     40  102    1 : tunables    0    0    0 : slabdata    559    559      0
radix_tree_node     2357   2862    304   53    4 : tunables    0    0    0 : slabdata     54     54      0
idr_layer_cache     1908   1908    152   53    2 : tunables    0    0    0 : slabdata     36     36      0
dma-kmalloc-8192       0      0   8192    4    8 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-4096       0      0   4096    8    8 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-2048       0      0   2048   16    8 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-1024       0      0   1024   32    8 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-512       64     64    512   32    4 : tunables    0    0    0 : slabdata      2      2      0
dma-kmalloc-256        0      0    256   32    2 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-128        0      0    128   32    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-64         0      0     64   64    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-32         0      0     32  128    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-16         0      0     16  256    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-8          0      0      8  512    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-192        0      0    192   42    2 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-96         0      0     96   42    1 : tunables    0    0    0 : slabdata      0      0      0
kmalloc-8192          88     88   8192    4    8 : tunables    0    0    0 : slabdata     22     22      0
kmalloc-4096         408    408   4096    8    8 : tunables    0    0    0 : slabdata     51     51      0
kmalloc-2048         512    512   2048   16    8 : tunables    0    0    0 : slabdata     32     32      0
kmalloc-1024        3264   3264   1024   32    8 : tunables    0    0    0 : slabdata    102    102      0
kmalloc-512         2048   2048    512   32    4 : tunables    0    0    0 : slabdata     64     64      0
kmalloc-256         6816   6816    256   32    2 : tunables    0    0    0 : slabdata    213    213      0
kmalloc-128        14432  14432    128   32    1 : tunables    0    0    0 : slabdata    451    451      0
kmalloc-64         17728  17728     64   64    1 : tunables    0    0    0 : slabdata    277    277      0
kmalloc-32         27008  27008     32  128    1 : tunables    0    0    0 : slabdata    211    211      0
kmalloc-16         11520  11520     16  256    1 : tunables    0    0    0 : slabdata     45     45      0
kmalloc-8          18432  18432      8  512    1 : tunables    0    0    0 : slabdata     36     36      0
kmalloc-192        33514  33810    192   42    2 : tunables    0    0    0 : slabdata    805    805      0
kmalloc-96          7014   7014     96   42    1 : tunables    0    0    0 : slabdata    167    167      0
kmem_cache            32     32    128   32    1 : tunables    0    0    0 : slabdata      1      1      0
kmem_cache_node      384    384     32  128    1 : tunables    0    0    0 : slabdata      3      3      0
+ free -l
             total       used       free     shared    buffers     cached
Mem:      64447796    1086840   63360956          0        664      16428
Low:        375828     367556       8272
High:     64071968     719284   63352684
-/+ buffers/cache:    1069748   63378048
Swap:    134217724          0  134217724
+ 


Lines in syslog from just before OOM (my patched kernel with
drop_caches):

Jan 12 11:04:25 zeno kernel: drop_caches with zone=1 nr_slab=0 reclaimed_slab=0 RECLAIMABLE=1852 FREE=911
Jan 12 11:04:25 zeno kernel: after drop_caches reclaimed_slab=0 RECLAIMABLE=1852 FREE=911
Jan 12 11:04:25 zeno kernel: sh invoked oom-killer: gfp_mask=0xd0, order=1, oom_adj=0, oom_score_adj=0
Jan 12 11:04:25 zeno kernel: Pid: 6344, comm: sh Not tainted 3.2.32-pk06.11-i386 #1
Jan 12 11:04:25 zeno kernel: Call Trace:
Jan 12 11:04:25 zeno kernel:  [<c1607653>] ? printk+0x18/0x1a
Jan 12 11:04:25 zeno kernel:  [<c10776b8>] dump_header.isra.10+0x68/0x180
Jan 12 11:04:25 zeno kernel:  [<c1069807>] ? delayacct_end+0x97/0xb0
Jan 12 11:04:25 zeno kernel:  [<c11d676e>] ? ___ratelimit+0x7e/0xf0
Jan 12 11:04:25 zeno kernel:  [<c1077929>] oom_kill_process.constprop.15+0x49/0x230
Jan 12 11:04:25 zeno kernel:  [<c107a188>] ? get_page_from_freelist+0x2f8/0x4c0
Jan 12 11:04:25 zeno kernel:  [<c1077e03>] out_of_memory+0x1d3/0x2c0
Jan 12 11:04:25 zeno kernel:  [<c107a8a8>] __alloc_pages_nodemask+0x558/0x570
Jan 12 11:04:25 zeno kernel:  [<c102f4bb>] copy_process.part.39+0x5b/0xfa0
Jan 12 11:04:25 zeno kernel:  [<c103054c>] do_fork+0x12c/0x260
Jan 12 11:04:25 zeno kernel:  [<c103e9de>] ? set_current_blocked+0x2e/0x50
Jan 12 11:04:25 zeno kernel:  [<c1009a7f>] sys_clone+0x2f/0x40
Jan 12 11:04:25 zeno kernel:  [<c160ff15>] ptregs_clone+0x15/0x40
Jan 12 11:04:25 zeno kernel:  [<c160fe14>] ? sysenter_do_call+0x12/0x26
Jan 12 11:04:25 zeno kernel: Mem-Info:
Jan 12 11:04:25 zeno kernel: DMA per-cpu:
Jan 12 11:04:25 zeno kernel: CPU    0: hi:    0, btch:   1 usd:   0
Jan 12 11:04:25 zeno kernel: CPU    1: hi:    0, btch:   1 usd:   0
Jan 12 11:04:25 zeno kernel: CPU    2: hi:    0, btch:   1 usd:   0
Jan 12 11:04:25 zeno kernel: CPU    3: hi:    0, btch:   1 usd:   0
Jan 12 11:04:25 zeno kernel: CPU    4: hi:    0, btch:   1 usd:   0
Jan 12 11:04:25 zeno kernel: CPU    5: hi:    0, btch:   1 usd:   0
Jan 12 11:04:25 zeno kernel: CPU    6: hi:    0, btch:   1 usd:   0
Jan 12 11:04:25 zeno kernel: CPU    7: hi:    0, btch:   1 usd:   0
Jan 12 11:04:25 zeno kernel: CPU    8: hi:    0, btch:   1 usd:   0
Jan 12 11:04:25 zeno kernel: CPU    9: hi:    0, btch:   1 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   10: hi:    0, btch:   1 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   11: hi:    0, btch:   1 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   12: hi:    0, btch:   1 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   13: hi:    0, btch:   1 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   14: hi:    0, btch:   1 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   15: hi:    0, btch:   1 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   16: hi:    0, btch:   1 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   17: hi:    0, btch:   1 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   18: hi:    0, btch:   1 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   19: hi:    0, btch:   1 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   20: hi:    0, btch:   1 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   21: hi:    0, btch:   1 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   22: hi:    0, btch:   1 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   23: hi:    0, btch:   1 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   24: hi:    0, btch:   1 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   25: hi:    0, btch:   1 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   26: hi:    0, btch:   1 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   27: hi:    0, btch:   1 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   28: hi:    0, btch:   1 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   29: hi:    0, btch:   1 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   30: hi:    0, btch:   1 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   31: hi:    0, btch:   1 usd:   0
Jan 12 11:04:25 zeno kernel: Normal per-cpu:
Jan 12 11:04:25 zeno kernel: CPU    0: hi:  186, btch:  31 usd:  30
Jan 12 11:04:25 zeno kernel: CPU    1: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU    2: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU    3: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU    4: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU    5: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU    6: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU    7: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU    8: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU    9: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   10: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   11: hi:  186, btch:  31 usd:   6
Jan 12 11:04:25 zeno kernel: CPU   12: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   13: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   14: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   15: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   16: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   17: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   18: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   19: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   20: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   21: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   22: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   23: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   24: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   25: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   26: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   27: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   28: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   29: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   30: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   31: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: HighMem per-cpu:
Jan 12 11:04:25 zeno kernel: CPU    0: hi:  186, btch:  31 usd:  30
Jan 12 11:04:25 zeno kernel: CPU    1: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU    2: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU    3: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU    4: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU    5: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU    6: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU    7: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU    8: hi:  186, btch:  31 usd:  29
Jan 12 11:04:25 zeno kernel: CPU    9: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   10: hi:  186, btch:  31 usd:  29
Jan 12 11:04:25 zeno kernel: CPU   11: hi:  186, btch:  31 usd:  20
Jan 12 11:04:25 zeno kernel: CPU   12: hi:  186, btch:  31 usd:  29
Jan 12 11:04:25 zeno kernel: CPU   13: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   14: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   15: hi:  186, btch:  31 usd:  29
Jan 12 11:04:25 zeno kernel: CPU   16: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   17: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   18: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   19: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   20: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   21: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   22: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   23: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   24: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   25: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   26: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   27: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   28: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   29: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   30: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: CPU   31: hi:  186, btch:  31 usd:   0
Jan 12 11:04:25 zeno kernel: active_anon:160474 inactive_anon:6747 isolated_anon:0
Jan 12 11:04:25 zeno kernel:  active_file:1283 inactive_file:2866 isolated_file:0
Jan 12 11:04:25 zeno kernel:  unevictable:0 dirty:6 writeback:0 unstable:0
Jan 12 11:04:25 zeno kernel:  free:15839916 slab_reclaimable:1852 slab_unreclaimable:17519
Jan 12 11:04:25 zeno kernel:  mapped:4059 shmem:144 pagetables:24767 bounce:0
Jan 12 11:04:25 zeno kernel: DMA free:3516kB min:64kB low:80kB high:96kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15780kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:1908kB kernel_stack:2024kB pagetables:4440kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
Jan 12 11:04:25 zeno kernel: lowmem_reserve[]: 0 867 62932 62932
Jan 12 11:04:25 zeno kernel: Normal free:3644kB min:3732kB low:4664kB high:5596kB active_anon:0kB inactive_anon:0kB active_file:248kB inactive_file:280kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:887976kB mlocked:0kB dirty:0kB writeback:0kB mapped:4kB shmem:0kB slab_reclaimable:7408kB slab_unreclaimable:68168kB kernel_stack:43256kB pagetables:94628kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:1197 all_unreclaimable? yes
Jan 12 11:04:25 zeno kernel: lowmem_reserve[]: 0 0 496521 496521
Jan 12 11:04:25 zeno kernel: HighMem free:63352504kB min:512kB low:67316kB high:134124kB active_anon:641896kB inactive_anon:26988kB active_file:4884kB inactive_file:11184kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:63554796kB mlocked:0kB dirty:24kB writeback:0kB mapped:16232kB shmem:576kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
Jan 12 11:04:25 zeno kernel: lowmem_reserve[]: 0 0 0 0
Jan 12 11:04:25 zeno kernel: DMA: 11*4kB 2*8kB 0*16kB 0*32kB 0*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 0*4096kB = 3516kB
Jan 12 11:04:25 zeno kernel: Normal: 217*4kB 10*8kB 0*16kB 0*32kB 1*64kB 1*128kB 0*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 3700kB
Jan 12 11:04:25 zeno kernel: HighMem: 151*4kB 136*8kB 232*16kB 198*32kB 43*64kB 9*128kB 4*256kB 1*512kB 2*1024kB 2*2048kB 15461*4096kB = 63351580kB
Jan 12 11:04:25 zeno kernel: 4156 total pagecache pages
Jan 12 11:04:25 zeno kernel: 0 pages in swap cache
Jan 12 11:04:25 zeno kernel: Swap cache stats: add 0, delete 0, find 0/0
Jan 12 11:04:25 zeno kernel: Free swap  = 134217724kB
Jan 12 11:04:25 zeno kernel: Total swap = 134217724kB
Jan 12 11:04:25 zeno kernel: 16777200 pages RAM
Jan 12 11:04:25 zeno kernel: 16549378 pages HighMem
Jan 12 11:04:25 zeno kernel: 665251 pages reserved
Jan 12 11:04:25 zeno kernel: 635488 pages shared
Jan 12 11:04:25 zeno kernel: 261163 pages non-shared
Jan 12 11:04:25 zeno kernel: Out of memory (oom_kill_allocating_task): Kill process 6344 (sh) score 0 or sacrifice child
Jan 12 11:04:25 zeno kernel: Killed process 6345 (sleep) total-vm:1736kB, anon-rss:44kB, file-rss:200kB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
