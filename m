Date: Wed, 23 May 2007 22:07:23 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/3] slob: rework freelist handling
In-Reply-To: <20070524044932.GD12121@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0705232159430.24918@schroedinger.engr.sgi.com>
References: <20070523193547.GE11115@waste.org>
 <Pine.LNX.4.64.0705231256001.21541@schroedinger.engr.sgi.com>
 <20070524033925.GD14349@wotan.suse.de> <Pine.LNX.4.64.0705232052040.24352@schroedinger.engr.sgi.com>
 <20070524041339.GC20252@wotan.suse.de> <Pine.LNX.4.64.0705232115140.24618@schroedinger.engr.sgi.com>
 <20070524043144.GB12121@wotan.suse.de> <Pine.LNX.4.64.0705232133130.24738@schroedinger.engr.sgi.com>
 <20070524043928.GC12121@wotan.suse.de> <Pine.LNX.4.64.0705232143570.24864@schroedinger.engr.sgi.com>
 <20070524044932.GD12121@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Booted with full slub in 16M. The additional sysfs support etc distorts
the numbers a bit (300k more data) but it allows to run slabinfo.

Seems that we have high kmalloc array use of 64, 128, 256, 1k, 2k and 4k. 
There already is a 92 and 192 sized kmalloc cache. Hmmm..... Looks like
we cannot do much about this. Maybe add some odd sized slabs? A 768 byte 
sized? 


root@(none):/# mount /proc
root@(none):/# mount /sys
root@(none):/# free
             total       used       free     shared    buffers     cached
Mem:         11636       9976       1660          0        256       3240
-/+ buffers/cache:       6480       5156
Swap:            0          0          0
root@(none):/# slabinfo -S
Name                   Objects Objsize    Space Slabs/Part/Cpu  O/S O %Fr  %Ef Flg
inode_cache               2471     528     1.4M        354/0/1    7 0   0  89 a
:0000128                  7070     128   905.2K        221/1/1   32 0   0  99 *
:0001024                   646    1024   663.5K        162/1/1    4 0   0  99 *
:a-0000192                2730     192   536.5K        131/0/1   21 0   0  97 *a
:0002048                    82    2048   167.9K         41/0/1    2 0   0 100 *
:0000256                   528     256   139.2K         34/0/1   16 0   0  97 *
:0000064                  1675      64   110.5K         27/2/1   64 0   7  96 *
:0004096                    26    4096   106.4K         26/0/1    1 0   0 100 *
radix_tree_node            148     552    90.1K         22/4/1    7 0  18  90
sighand_cache               20    2072    81.9K         20/0/1    1 0   0  50 A
task_struct                 20    1856    53.2K         13/6/1    2 0  46  69
:0000192                   231     192    45.0K         11/0/1   21 0   0  98 *
reiser_inode_cache          66     632    45.0K         11/0/1    6 0   0  92 a
kmalloc-8192                 5    8192    40.9K          5/0/1    1 1   0 100
:0000512                    72     512    36.8K          9/0/1    8 0   0 100 *
idr_layer_cache             30     528    24.5K          6/3/1    7 0  50  64
:0000032                   623      32    20.4K          5/2/1  128 0  40  97 *
:0000704                    25     696    20.4K          5/0/1    5 0   0  84 *A
:0000016                  1280      16    20.4K          5/0/1  256 0   0 100 *
kmalloc-8                 2046       8    16.3K          4/1/1  512 0  25  99
buffer_head                111     104    12.2K          3/1/1   39 0  33  93 a
vm_area_struct              48     168     8.1K          2/0/1   24 0   0  98
:0000096                    84      96     8.1K          2/0/1   42 0   0  98 *
sock_inode_cache            12     600     8.1K          2/0/1    6 0   0  87 Aa
blkdev_requests             26     280     8.1K          2/1/1   14 0  50  88
blkdev_queue                 4    1448     8.1K          2/0/1    2 0   0  70
revokefs_inode_cache         7     552     4.0K          1/0/1    7 0   0  94 Aa
bdev_cache                   5     720     4.0K          1/0/1    5 0   0  87 Aa
mm_struct                    4     792     4.0K          1/0/1    4 0   0  77 A
sigqueue                    25     160     4.0K          1/0/1   25 0   0  97
proc_inode_cache             7     560     4.0K          1/0/1    7 0   0  95 a
Acpi-State                  51      80     4.0K          1/0/1   51 0   0  99
mqueue_inode_cache           4     800     4.0K          1/0/1    4 0   0  78 A
anon_vma                   170      16     4.0K          1/0/1  170 0   0  66
:0000640                     6     616     4.0K          1/0/1    6 0   0  90 *A
shmem_inode_cache            1     712     4.0K          1/1/0    5 0 100  17

root@(none):/# slabinfo -a

:0000016     <- biovec-1 kmalloc-16
:0000024     <- xfs_dabuf xfs_bmap_free_item fasync_cache swapped_entry
:0000032     <- tcp_bind_bucket kmalloc-32 Acpi-Namespace
:0000040     <- inotify_event_cache xfs_chashlist Acpi-Parse dnotify_cache
:0000064     <- blkdev_ioc secpath_cache inet_peer_cache fs_cache 
uid_cache xfs_ifork Acpi-ParseExt Acpi-Operand kmalloc-64 pid biovec-4
:0000072     <- eventpoll_pwq inotify_watch_cache
:0000096     <- xfs_ioend kmalloc-96
:0000128     <- kmalloc-128 request_sock_TCP sysfs_dir_cache flow_cache 
bio eventpoll_epi
:0000192     <- xfs_ili xfs_btree_cur kmalloc-192 tw_sock_TCP
:0000256     <- filp sgpool-8 mnt_cache kiocb biovec-16 kmalloc-256 
arp_cache
:0000320     <- ip_dst_cache kioctx xfs_buf
:0000512     <- kmalloc-512 sgpool-16
:0000640     <- files_cache UNIX
:0000704     <- RAW UDP-Lite UDP signal_cache
:0001024     <- kmalloc-1024 biovec-64 sgpool-32
:0002048     <- kmalloc-2048 sgpool-64 biovec-128
:0004096     <- sgpool-128 biovec-256 kmalloc-4096 names_cache
:a-0000192   <- skbuff_head_cache dentry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
