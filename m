Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 312C36B0037
	for <linux-mm@kvack.org>; Fri,  3 Jan 2014 09:54:04 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id ma3so15652768pbc.26
        for <linux-mm@kvack.org>; Fri, 03 Jan 2014 06:54:03 -0800 (PST)
Received: from eusmtp01.atmel.com (eusmtp01.atmel.com. [212.144.249.243])
        by mx.google.com with ESMTPS id ye6si45979906pbc.20.2014.01.03.06.54.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 03 Jan 2014 06:54:02 -0800 (PST)
Date: Fri, 3 Jan 2014 15:54:04 +0100
From: Ludovic Desroches <ludovic.desroches@atmel.com>
Subject: Re: possible regression on 3.13 when calling flush_dcache_page
Message-ID: <20140103145404.GC18002@ldesroches-Latitude-E6320>
References: <20131212143149.GI12099@ldesroches-Latitude-E6320>
 <20131212143618.GJ12099@ldesroches-Latitude-E6320>
 <20131213015909.GA8845@lge.com>
 <20131216144343.GD9627@ldesroches-Latitude-E6320>
 <20131218072117.GA2383@lge.com>
 <20131220080851.GC16592@ldesroches-Latitude-E6320>
 <20131223224435.GD16592@ldesroches-Latitude-E6320>
 <20131224063837.GA27156@lge.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="bp/iNruPH9dso1Pn"
Content-Disposition: inline
In-Reply-To: <20131224063837.GA27156@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-mmc@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Ludovic Desroches <ludovic.desroches@atmel.com>

--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline

Hi,

On Tue, Dec 24, 2013 at 03:38:37PM +0900, Joonsoo Kim wrote:

[...]

> > > > > > I think that this commit may not introduce a bug. This patch remove one
> > > > > > variable on slab management structure and replace variable name. So there
> > > > > > is no functional change.

You are right, the commit given by git bisect was not the good one...
Since I removed other patches done on top of it, I thought it really was
this one but in fact it is 8456a64.

 dd0f774  Fri Jan 3 12:33:55 2014 +0100  Revert "slab: remove useless
statement for checking pfmemalloc"  Ludovic Desroches 
 ff7487d  Fri Jan 3 12:32:33 2014 +0100  Revert "slab: rename
slab_bufctl to slab_freelist"  Ludovic Desroches 
 b963564  Fri Jan 3 12:32:13 2014 +0100  Revert "slab: fix to calm down
kmemleak warning"  Ludovic Desroches 
 3fcfe50  Fri Jan 3 12:30:32 2014 +0100  Revert "slab: replace
non-existing 'struct freelist *' with 'void *'"  Ludovic Desroches 
 750a795  Fri Jan 3 12:30:16 2014 +0100  Revert "memcg, kmem: rename
cache_from_memcg to cache_from_memcg_idx"  Ludovic Desroches 
 7e2de8a  Fri Jan 3 12:30:10 2014 +0100  mmc: atmel-mci: disable pdc
Ludovic Desroches

In this case I have the kernel oops. If I revert 8456a64 too, it
disappears.

I will try to test it on other devices because I couldn't reproduce it
with newer ones (but it's not the same ARM architecture so I would like
to see if it's also related to the device itself).

In attachment, there are the results of /proc/slabinfo before inserted the
sdio wifi module causing the oops.

Regards

Ludovic

--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: attachment; filename="8456a64_reverted.log"

# cat /proc/slabinfo 
slabinfo - version: 2.1
# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_sla>
ubi_wl_entry_slab      0      0     24  145    1 : tunables  120   60    0 : slabdata      0      0      0
ubifs_inode_slab       0      0    368   10    1 : tunables   54   27    0 : slabdata      0      0      0
fib6_nodes             1    113     32  113    1 : tunables  120   60    0 : slabdata      1      1      0
ip6_dst_cache          1     17    224   17    1 : tunables  120   60    0 : slabdata      1      1      0
PINGv6                 0      0    704   11    2 : tunables   54   27    0 : slabdata      0      0      0
RAWv6                  4     11    704   11    2 : tunables   54   27    0 : slabdata      1      1      0
UDPLITEv6              0      0    704   11    2 : tunables   54   27    0 : slabdata      0      0      0
UDPv6                  0      0    704   11    2 : tunables   54   27    0 : slabdata      0      0      0
tw_sock_TCPv6          0      0    160   24    1 : tunables  120   60    0 : slabdata      0      0      0
request_sock_TCPv6      0      0    192   20    1 : tunables  120   60    0 : slabdata      0      0      0
TCPv6                  0      0   1344    3    1 : tunables   24   12    0 : slabdata      0      0      0
sd_ext_cdb             2    113     32  113    1 : tunables  120   60    0 : slabdata      1      1      0
nfs_direct_cache       0      0     96   40    1 : tunables  120   60    0 : slabdata      0      0      0
nfs_commit_data        4      9    416    9    1 : tunables   54   27    0 : slabdata      1      1      0
nfs_write_data        32     36    608    6    1 : tunables   54   27    0 : slabdata      6      6      0
nfs_read_data          0      0    576    7    1 : tunables   54   27    0 : slabdata      0      0      0
nfs_inode_cache        0      0    536    7    1 : tunables   54   27    0 : slabdata      0      0      0
nfs_page               0      0     64   60    1 : tunables  120   60    0 : slabdata      0      0      0
fat_inode_cache        0      0    360   11    1 : tunables   54   27    0 : slabdata      0      0      0
fat_cache              0      0     24  145    1 : tunables  120   60    0 : slabdata      0      0      0
jbd2_transaction_s      0      0    160   24    1 : tunables  120   60    0 : slabdata      0      0      0
jbd2_inode             0      0     24  145    1 : tunables  120   60    0 : slabdata      0      0      0
jbd2_journal_handle      0      0     32  113    1 : tunables  120   60    0 : slabdata      0      0      0
jbd2_journal_head      0      0     64   60    1 : tunables  120   60    0 : slabdata      0      0      0
jbd2_revoke_table_s      0      0     16  204    1 : tunables  120   60    0 : slabdata      0      0      0
jbd2_revoke_record_s      0      0     32  113    1 : tunables  120   60    0 : slabdata      0      0      0
ext4_inode_cache       0      0    536    7    1 : tunables   54   27    0 : slabdata      0      0      0
ext4_xattr             0      0     48   78    1 : tunables  120   60    0 : slabdata      0      0      0
ext4_free_data         0      0     40   92    1 : tunables  120   60    0 : slabdata      0      0      0
ext4_allocation_context      0      0    112   35    1 : tunables  120   60    0 : slabdata      0      0      0
ext4_prealloc_space      0      0     64   60    1 : tunables  120   60    0 : slabdata      0      0      0
ext4_system_zone       0      0     32  113    1 : tunables  120   60    0 : slabdata      0      0      0
ext4_io_end            0      0     40   92    1 : tunables  120   60    0 : slabdata      0      0      0
ext4_extent_status      0      0     32  113    1 : tunables  120   60    0 : slabdata      0      0      0
configfs_dir_cache      1     68     56   68    1 : tunables  120   60    0 : slabdata      1      1      0
kioctx                 0      0    192   20    1 : tunables  120   60    0 : slabdata      0      0      0
kiocb                  0      0     64   60    1 : tunables  120   60    0 : slabdata      0      0      0
fanotify_response_event      0      0     16  204    1 : tunables  120   60    0 : slabdata      0      0      0
fsnotify_mark          0      0     64   60    1 : tunables  120   60    0 : slabdata      0      0      0
inotify_event_private_data      0      0     16  204    1 : tunables  120   60    0 : slabdata      0      0      0
inotify_inode_mark     12     60     64   60    1 : tunables  120   60    0 : slabdata      1      1      0
dnotify_mark           0      0     64   60    1 : tunables  120   60    0 : slabdata      0      0      0
dnotify_struct         0      0     24  145    1 : tunables  120   60    0 : slabdata      0      0      0
dio                    0      0    328   12    1 : tunables   54   27    0 : slabdata      0      0      0
fasync_cache           0      0     24  145    1 : tunables  120   60    0 : slabdata      0      0      0
posix_timers_cache      0      0    152   26    1 : tunables  120   60    0 : slabdata      0      0      0
uid_cache              0      0     64   60    1 : tunables  120   60    0 : slabdata      0      0      0
rpc_inode_cache        0      0    320   12    1 : tunables   54   27    0 : slabdata      0      0      0
rpc_buffers            8      8   2048    2    1 : tunables   24   12    0 : slabdata      4      4      0
rpc_tasks              8     30    128   30    1 : tunables  120   60    0 : slabdata      1      1      0
UNIX                   5      8    480    8    1 : tunables   54   27    0 : slabdata      1      1      0
UDP-Lite               0      0    608    6    1 : tunables   54   27    0 : slabdata      0      0      0
tcp_bind_bucket        0      0     32  113    1 : tunables  120   60    0 : slabdata      0      0      0
inet_peer_cache        0      0    128   30    1 : tunables  120   60    0 : slabdata      0      0      0
ip_fib_trie            3    113     32  113    1 : tunables  120   60    0 : slabdata      1      1      0
ip_fib_alias           4    145     24  145    1 : tunables  120   60    0 : slabdata      1      1      0
ip_dst_cache           0      0    128   30    1 : tunables  120   60    0 : slabdata      0      0      0
PING                   0      0    576    7    1 : tunables   54   27    0 : slabdata      0      0      0
RAW                    1      7    576    7    1 : tunables   54   27    0 : slabdata      1      1      0
UDP                    0      0    608    6    1 : tunables   54   27    0 : slabdata      0      0      0
tw_sock_TCP            0      0    160   24    1 : tunables  120   60    0 : slabdata      0      0      0
request_sock_TCP       0      0    192   20    1 : tunables  120   60    0 : slabdata      0      0      0
TCP                    0      0   1216    3    1 : tunables   24   12    0 : slabdata      0      0      0
eventpoll_pwq          9     92     40   92    1 : tunables  120   60    0 : slabdata      1      1      0
eventpoll_epi          9     80     96   40    1 : tunables  120   60    0 : slabdata      2      2      0
sgpool-128             2      2   2048    2    1 : tunables   24   12    0 : slabdata      1      1      0
sgpool-64              2      4   1024    4    1 : tunables   54   27    0 : slabdata      1      1      0
sgpool-32              2      8    512    8    1 : tunables   54   27    0 : slabdata      1     random: nonblocking pool is initialized
 1      0
sgpool-16              2     15    256   15    1 : tunables  120   60    0 : slabdata      1      1      0
sgpool-8               2     30    128   30    1 : tunables  120   60    0 : slabdata      1      1      0
scsi_data_buffer       0      0     24  145    1 : tunables  120   60    0 : slabdata      0      0      0
blkdev_queue          14     14   1032    7    2 : tunables   24   12    0 : slabdata      2      2      0
blkdev_requests        8     18    216   18    1 : tunables  120   60    0 : slabdata      1      1      0
blkdev_ioc             0      0     64   60    1 : tunables  120   60    0 : slabdata      0      0      0
fsnotify_event_holder      0      0     16  204    1 : tunables  120   60    0 : slabdata      0      0      0
fsnotify_event         1     60     64   60    1 : tunables  120   60    0 : slabdata      1      1      0
bio-0                  2     30    128   30    1 : tunables  120   60    0 : slabdata      1      1      0
biovec-256             2      2   3072    2    2 : tunables   24   12    0 : slabdata      1      1      0
biovec-128             0      0   1536    5    2 : tunables   24   12    0 : slabdata      0      0      0
biovec-64              0      0    768    5    1 : tunables   54   27    0 : slabdata      0      0      0
biovec-16              0      0    192   20    1 : tunables  120   60    0 : slabdata      0      0      0
sock_inode_cache      21     36    320   12    1 : tunables   54   27    0 : slabdata      3      3      0
skbuff_fclone_cache      0      0    352   11    1 : tunables   54   27    0 : slabdata      0      0      0
skbuff_head_cache      4     20    192   20    1 : tunables  120   60    0 : slabdata      1      1      0
file_lock_cache        4     35    112   35    1 : tunables  120   60    0 : slabdata      1      1      0
shmem_inode_cache    394    396    312   12    1 : tunables   54   27    0 : slabdata     33     33      0
pool_workqueue         6     15    256   15    1 : tunables  120   60    0 : slabdata      1      1      0
proc_inode_cache      48     48    312   12    1 : tunables   54   27    0 : slabdata      4      4      0
sigqueue               0      0    144   27    1 : tunables  120   60    0 : slabdata      0      0      0
bdev_cache            13     18    416    9    1 : tunables   54   27    0 : slabdata      2      2      0
sysfs_dir_cache     2926   2940     64   60    1 : tunables  120   60    0 : slabdata     49     49      0
mnt_cache             20     24    160   24    1 : tunables  120   60    0 : slabdata      1      1      0
filp                  96    120    160   24    1 : tunables  120   60    0 : slabdata      5      5      0
inode_cache         1563   1568    280   14    1 : tunables   54   27    0 : slabdata    112    112      0
dentry              2030   2030    136   29    1 : tunables  120   60    0 : slabdata     70     70      0
names_cache            1      1   4096    1    1 : tunables   24   12    0 : slabdata      1      1      0
buffer_head            0      0     56   68    1 : tunables  120   60    0 : slabdata      0      0      0
nsproxy                1    145     24  145    1 : tunables  120   60    0 : slabdata      1      1      0
vm_area_struct       215    396     88   44    1 : tunables  120   60    0 : slabdata      9      9      0
mm_struct             20     20    384   10    1 : tunables   54   27    0 : slabdata      2      2      0
fs_cache              11    113     32  113    1 : tunables  120   60    0 : slabdata      1      1      0
files_cache           11     40    192   20    1 : tunables  120   60    0 : slabdata      2      2      0
signal_cache          29     42    512    7    1 : tunables   54   27    0 : slabdata      6      6      0
sighand_cache         33     33   1312    3    1 : tunables   24   12    0 : slabdata     11     11      0
task_struct           29     42    672    6    1 : tunables   54   27    0 : slabdata      7      7      0
cred_jar              40    120     96   40    1 : tunables  120   60    0 : slabdata      3      3      0
anon_vma_chain       254    678     32  113    1 : tunables  120   60    0 : slabdata      6      6      0
anon_vma             193    435     24  145    1 : tunables  120   60    0 : slabdata      3      3      0
pid                   33     60     64   60    1 : tunables  120   60    0 : slabdata      1      1      0
radix_tree_node      130    143    296   13    1 : tunables   54   27    0 : slabdata     11     11      0
idr_layer_cache       62     63   1080    7    2 : tunables   24   12    0 : slabdata      9      9      0
kmalloc-4194304        0      0 4194304    1 1024 : tunables    1    1    0 : slabdata      0      0      0
kmalloc-2097152        0      0 2097152    1  512 : tunables    1    1    0 : slabdata      0      0      0
kmalloc-1048576        0      0 1048576    1  256 : tunables    1    1    0 : slabdata      0      0      0
kmalloc-524288         0      0 524288    1  128 : tunables    1    1    0 : slabdata      0      0      0
kmalloc-262144         0      0 262144    1   64 : tunables    1    1    0 : slabdata      0      0      0
kmalloc-131072         0      0 131072    1   32 : tunables    8    4    0 : slabdata      0      0      0
kmalloc-65536          0      0  65536    1   16 : tunables    8    4    0 : slabdata      0      0      0
kmalloc-32768          2      2  32768    1    8 : tunables    8    4    0 : slabdata      2      2      0
kmalloc-16384          1      1  16384    1    4 : tunables    8    4    0 : slabdata      1      1      0
kmalloc-8192           2      2   8192    1    2 : tunables    8    4    0 : slabdata      2      2      0
kmalloc-4096           4      4   4096    1    1 : tunables   24   12    0 : slabdata      4      4      0
kmalloc-2048          28     28   2048    2    1 : tunables   24   12    0 : slabdata     14     14      0
kmalloc-1024          39     44   1024    4    1 : tunables   54   27    0 : slabdata     11     11      0
kmalloc-512          204    208    512    8    1 : tunables   54   27    0 : slabdata     26     26      0
kmalloc-256          183    195    256   15    1 : tunables  120   60    0 : slabdata     13     13      0
kmalloc-192          134    140    192   20    1 : tunables  120   60    0 : slabdata      7      7      0
kmalloc-128          204    210    128   30    1 : tunables  120   60    0 : slabdata      7      7      0
kmalloc-96          1099   1120     96   40    1 : tunables  120   60    0 : slabdata     28     28      0
kmalloc-64           648    720     64   60    1 : tunables  120   60    0 : slabdata     12     12      0
kmalloc-32          3018   3164     32  113    1 : tunables  120   60    0 : slabdata     28     28      0
kmem_cache           131    160     96   40    1 : tunables  120   60    0 : slabdata      4      4      0


--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: attachment; filename="with_8456a64.log"

# cat /proc/slabinfo
slabinfo - version: 2.1
# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_sla>
ubi_wl_entry_slab      0      0     24  146    1 : tunables  120   60    0 : slabdata      0      0      0
ubifs_inode_slab       0      0    368   11    1 : tunables   54   27    0 : slabdata      0      0      0
fib6_nodes             1    113     32  113    1 : tunables  120   60    0 : slabdata      1      1      0
ip6_dst_cache          1     17    224   17    1 : tunables  120   60    0 : slabdata      1      1      0
PINGv6                 0      0    704   11    2 : tunables   54   27    0 : slabdata      0      0      0
RAWv6                  4     11    704   11    2 : tunables   54   27    0 : slabdata      1      1      0
UDPLITEv6              0      0    704   11    2 : tunables   54   27    0 : slabdata      0      0      0
UDPv6                  0      0    704   11    2 : tunables   54   27    0 : slabdata      0      0      0
tw_sock_TCPv6          0      0    160   24    1 : tunables  120   60    0 : slabdata      0      0      0
request_sock_TCPv6      0      0    192   20    1 : tunables  120   60    0 : slabdata      0      0      0
TCPv6                  0      0   1344    3    1 : tunables   24   12    0 : slabdata      0      0      0
sd_ext_cdb             2    113     32  113    1 : tunables  120   60    0 : slabdata      1      1      0
nfs_direct_cache       0      0     96   40    1 : tunables  120   60    0 : slabdata      0      0      0
nfs_commit_data        4      9    416    9    1 : tunables   54   27    0 : slabdata      1      1      0
nfs_write_data        32     36    608    6    1 : tunables   54   27    0 : slabdata      6      6      0
nfs_read_data          0      0    576    7    1 : tunables   54   27    0 : slabdata      0      0      0
nfs_inode_cache        0      0    536    7    1 : tunables   54   27    0 : slabdata      0      0      0
nfs_page               0      0     64   60    1 : tunables  120   60    0 : slabdata      0      0      0
fat_inode_cache        0      0    360   11    1 : tunables   54   27    0 : slabdata      0      0      0
fat_cache              0      0     24  146    1 : tunables  120   60    0 : slabdata      0      0      0
jbd2_transaction_s      0      0    160   24    1 : tunables  120   60    0 : slabdata      0      0      0
jbd2_inode             0      0     24  146    1 : tunables  120   60    0 : slabdata      0      0      0
jbd2_journal_handle      0      0     32  113    1 : tunables  120   60    0 : slabdata      0      0      0
jbd2_journal_head      0      0     64   60    1 : tunables  120   60    0 : slabdata      0      0      0
jbd2_revoke_table_s      0      0     16  204    1 : tunables  120   60    0 : slabdata      0      0      0
jbd2_revoke_record_s      0      0     32  113    1 : tunables  120   60    0 : slabdata      0      0      0
ext4_inode_cache       0      0    536    7    1 : tunables   54   27    0 : slabdata      0      0      0
ext4_xattr             0      0     48   78    1 : tunables  120   60    0 : slabdata      0      0      0
ext4_free_data         0      0     40   93    1 : tunables  120   60    0 : slabdata      0      0      0
ext4_allocation_context      0      0    112   35    1 : tunables  120   60    0 : slabdata      0      0      0
ext4_prealloc_space      0      0     64   60    1 : tunables  120   60    0 : slabdata      0      0      0
ext4_system_zone       0      0     32  113    1 : tunables  120   60    0 : slabdata      0      0      0
ext4_io_end            0      0     40   93    1 : tunables  120   60    0 : slabdata      0      0      0
ext4_extent_status      0      0     32  113    1 : tunables  120   60    0 : slabdata      0      0      0
configfs_dir_cache      1     68     56   68    1 : tunables  120   60    0 : slabdata      1      1      0
kioctx                 0      0    192   20    1 : tunables  120   60    0 : slabdata      0      0      0
kiocb                  0      0     64   60    1 : tunables  120   60    0 : slabdata      0      0      0
fanotify_response_event      0      0     16  204    1 : tunables  120   60    0 : slabdata      0      0      0
fsnotify_mark          0      0     64   60    1 : tunables  120   60    0 : slabdata      0      0      0
inotify_event_private_data      0      0     16  204    1 : tunables  120   60    0 : slabdata      0      0      0
inotify_inode_mark     12     60     64   60    1 : tunables  120   60    0 : slabdata      1      1      0
dnotify_mark           0      0     64   60    1 : tunables  120   60    0 : slabdata      0      0      0
dnotify_struct         0      0     24  146    1 : tunables  120   60    0 : slabdata      0      0      0
dio                    0      0    328   12    1 : tunables   54   27    0 : slabdata      0      0      0
fasync_cache           0      0     24  146    1 : tunables  120   60    0 : slabdata      0      0      0
posix_timers_cache      0      0    152   26    1 : tunables  120   60    0 : slabdata      0      0      0
uid_cache              0      0     64   60    1 : tunables  120   60    0 : slabdata      0      0      0
rpc_inode_cache        0      0    320   12    1 : tunables   54   27    0 : slabdata      0      0      0
rpc_buffers            8      8   2048    2    1 : tunables   24   12    0 : slabdata      4      4      0
rpc_tasks              8     31    128   31    1 : tunables  120   60    0 : slabdata      1      1      0
UNIX                   5      8    480    8    1 : tunables   54   27    0 : slabdata      1      1      0
UDP-Lite               0      0    608    6    1 : tunables   54   27    0 : slabdata      0      0      0
tcp_bind_bucket        0      0     32  113    1 : tunables  120   60    0 : slabdata      0      0      0
inet_peer_cache        0      0    128   31    1 : tunables  120   60    0 : slabdata      0      0      0
ip_fib_trie            3    113     32  113    1 : tunables  120   60    0 : slabdata      1      1      0
ip_fib_alias           4    146     24  146    1 : tunables  120   60    0 : slabdata      1      1      0
ip_dst_cache           0      0    128   31    1 : tunables  120   60    0 : slabdata      0      0      0
PING                   0      0    576    7    1 : tunables   54   27    0 : slabdata      0      0      0
RAW                    1      7    576    7    1 : tunables   54   27    0 : slabdata      1      1      0
UDP                    0      0    608    6    1 : tunables   54   27    0 : slabdata      0      0      0
tw_sock_TCP            0      0    160   24    1 : tunables  120   60    0 : slabdata      0      0      0
request_sock_TCP       0      0    192   20    1 : tunables  120   60    0 : slabdata      0      0      0
TCP                    0      0   1216    3    1 : tunables   24   12    0 : slabdata      0      0      0
eventpoll_pwq          9     93     40   93    1 : tunables  120   60    0 : slabdata      1      1      0
eventpoll_epi          9     80     96   40    1 : tunables  120   60    0 : slabdata      2      2      0
sgpool-128             2      2   2048    2    1 : tunables   24   12    0 : slabdata      1      1      0
sgpool-64              2      4   1024    4    1 : tunables   54   27    0 : slabdata      1      1      0
sgpool-32              2      8    512    8    1 : tunables   54   27    0 : slabdata      1      1      0
sgpool-16              2     15    256   15    1 : tunables  120   60    0 : slabdata      1      1      0
sgpool-8               2     31    128   31    1 : tunables  120   60    0 : slabdata      1      1      0
scsi_data_buffer       0      0     24  146    1 : tunables  120   60    0 : slabdata      0      0      0
blkdev_queue          14     14   1032    7    2 : tunables   24   12    0 : slabdata      2      2      0
blkdev_requests        8     18    216   18    1 : tunables  120   60    0 : slabdata      1      1      0
blkdev_ioc             0      0     64   60    1 : tunables  120   60    0 : slabdata      0      0      0
fsnotify_event_holder      0      0     16  204    1 : tunables  120   60    0 : slabdata      0      0      0
fsnotify_event         1     60     64   60    1 : tunables  120   60    0 : slabdata      1      1      0
bio-0                  2     31    128   31    1 : tunables  120   60    0 : slabdata      1      1      0
biovec-256             2      2   3072    2    2 : tunables   24   12    0 : slabdata      1      1      0
biovec-128             0      0   1536    5    2 : tunables   24   12    0 : slabdata      0      0      0
biovec-64              0      0    768    5    1 : tunables   54   27    0 : slabdata      0      0      0
biovec-16              0      0    192   20    1 : tunables  120   60    0 : slabdata      0      0      0
sock_inode_cache      19     36    320   12    1 : tunables   54   27    0 : slabdata      3      3      0
skbuff_fclone_cache      0      0    352   11    1 : tunables   54   27    0 : slabdata      0      0      0
skbuff_head_cache      0      0    192   20    1 : tunables  120   60    0 : slabdata      0      0      0
file_lock_cache        0      0    112   35    1 : tunables  120   60    0 : slabdata      0      0      0
shmem_inode_cache    394    396    312   12    1 : tunables   54   27    0 : slabdata     33     33      0
pool_workqueue         6     15    256   15    1 : tunables  120   60    0 : slabdata      1      1      0
proc_inode_cache      12     12    312   12    1 : tunables   54   27    0 : slabdata      1      1      0
sigqueue               0      0    144   27    1 : tunables  120   60    0 : slabdata      0      0      0
bdev_cache            13     18    416    9    1 : tunables   54   27    0 : slabdata      2      2      0
sysfs_dir_cache     2926   2940     64   60    1 : tunables  120   60    0 : slabdata     49     49      0
mnt_cache             20     24    160   24    1 : tunables  120   60    0 : slabdata      1      1      0
filp                  65    144    160   24    1 : tunables  120   60    0 : slabdata      6      6      0
inode_cache         1564   1568    280   14    1 : tunables   54   27    0 : slabdata    112    112      0
dentry              2001   2059    136   29    1 : tunables  120   60    0 : slabdata     71     71      0
names_cache            1      1   4096    1    1 : tunables   24   12    0 : slabdata      1      1      0
buffer_head            0      0     56   68    1 : tunables  120   60    0 : slabdata      0      0      0
nsproxy                1    146     24  146    1 : tunables  120   60    0 : slabdata      1      1      0
vm_area_struct       267    352     88   44    1 : tunables  120   60    0 : slabdata      8      8      0
mm_struct             20     20    384   10    1 : tunables   54   27    0 : slabdata      2      2      0
fs_cache              23    113     32  113    1 : tunables  120   60    0 : slabdata      1      1      0
files_cache           23     40    192   20    1 : tunables  120   60    0 : slabdata      2      2      0
signal_cache          42     42    512    7    1 : tunables   54   27    0 : slabdata      6      6      0
sighand_cache         33     33   1312    3    1 : tunables   24   12    0 : slabdata     11     11      0
task_struct           44     48    672    6    1 : tunables   54   27    0 : slabdata      8      8      0
cred_jar              53     80     96   40    1 : tunables  120   60    0 : slabdata      2      2      0
anon_vma_chain       304    791     32  113    1 : tunables  120   60    0 : slabdata      7      7      0
anon_vma             146    438     24  146    1 : tunables  120   60    0 : slabdata      3      3      0
pid                   45     60     64   60    1 : tunables  120   60    0 : slabdata      1      1      0
radix_tree_node      131    143    296   13    1 : tunables   54   27    0 : slabdata     11     11      0
idr_layer_cache       62     63   1080    7    2 : tunables   24   12    0 : slabdata      9      9      0
kmalloc-4194304        0      0 4194304    1 1024 : tunables    1    1    0 : slabdata      0      0      0
kmalloc-2097152        0      0 2097152    1  512 : tunables    1    1    0 : slabdata      0      0      0
kmalloc-1048576        0      0 1048576    1  256 : tunables    1    1    0 : slabdata      0      0      0
kmalloc-524288         0      0 524288    1  128 : tunables    1    1    0 : slabdata      0      0      0
kmalloc-262144         0      0 262144    1   64 : tunables    1    1    0 : slabdata      0      0      0
kmalloc-131072         0      0 131072    1   32 : tunables    8    4    0 : slabdata      0      0      0
kmalloc-65536          0      0  65536    1   16 : tunables    8    4    0 : slabdata      0      0      0
kmalloc-32768          2      2  32768    1    8 : tunables    8    4    0 : slabdata      2      2      0
kmalloc-16384          1      1  16384    1    4 : tunables    8    4    0 : slabdata      1      1      0
kmalloc-8192           2      2   8192    1    2 : tunables    8    4    0 : slabdata      2      2      0
kmalloc-4096           4      4   4096    1    1 : tunables   24   12    0 : slabdata      4      4      0
kmalloc-2048          28     28   2048    2    1 : tunables   24   12    0 : slabdata     14     14      0
kmalloc-1024          38     40   1024    4    1 : tunables   54   27    0 : slabdata     10     10      0
kmalloc-512          203    208    512    8    1 : tunables   54   27    0 : slabdata     26     26      0
kmalloc-256          195    195    256   15    1 : tunables  120   60    0 : slabdata     13     13      0
kmalloc-192          140    140    192   20    1 : tunables  120   60    0 : slabdata      7      7      0
kmalloc-128          217    217    128   31    1 : tunables  120   60    0 : slabdata      7      7      0
kmalloc-96          1111   1120     96   40    1 : tunables  120   60    0 : slabdata     28     28      0
kmalloc-64           621    660     64   60    1 : tunables  120   60    0 : slabdata     11     11      0
kmalloc-32          3056   3164     32  113    1 : tunables  120   60    0 : slabdata     28     28      0
kmem_cache           131    160     96   40    1 : tunables  120   60    0 : slabdata      4      4      0


--bp/iNruPH9dso1Pn--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
