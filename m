Date: Sun, 25 Feb 2007 12:23:54 +0000
From: =?utf-8?B?SsO2cm4=?= Engel <joern@lazybastard.org>
Subject: Re: SLUB: The unqueued Slab allocator
Message-ID: <20070225122354.GB19047@lazybastard.org>
References: <Pine.LNX.4.64.0702221040140.2011@schroedinger.engr.sgi.com> <20070224142835.4c7a3207.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0702232145340.1872@schroedinger.engr.sgi.com> <20070223.215439.92580943.davem@davemloft.net> <Pine.LNX.4.64.0702240931030.3912@schroedinger.engr.sgi.com> <20070224193322.GA17276@lazybastard.org> <Pine.LNX.4.64.0702241613520.4891@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <Pine.LNX.4.64.0702241613520.4891@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: David Miller <davem@davemloft.net>, kamezawa.hiroyu@jp.fujitsu.com, andi@firstfloor.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 24 February 2007 16:14:48 -0800, Christoph Lameter wrote:
> 
> It eliminates 50% of the slab caches. Thus it reduces the management 
> overhead by half.

How much management overhead is there left with SLUB?  Is it just the
one per-node slab?  Is there runtime overhead as well?

In a slightly different approach, can we possibly get rid of some slab
caches, instead of merging them at boot time?  On my system I have 97
slab caches right now, ignoring the generic kmalloc() ones.  Of those,
28 are completely empty, 23 contain <=10 objects, 23 <=100 and 23
contain >100 objects.

It is fairly obvious to me that the highly populated slab caches are a
big win.  But is it worth it to have slab caches with a single object
inside?  Maybe some of these caches are populated for some systems.
But there could also be candidates for removal among them.

# <active_objs> <num_objs> name
0 0 dm-crypt_io
0 0 dm_io
0 0 dm_tio
0 0 ext3_xattr
0 0 fat_cache
0 0 fat_inode_cache
0 0 flow_cache
0 0 inet_peer_cache
0 0 ip_conntrack_expect
0 0 ip_mrt_cache
0 0 isofs_inode_cache
0 0 jbd_1k
0 0 jbd_4k
0 0 kiocb
0 0 kioctx
0 0 nfs_inode_cache
0 0 nfs_page
0 0 posix_timers_cache
0 0 request_sock_TCP
0 0 revoke_record
0 0 rpc_inode_cache
0 0 scsi_io_context
0 0 secpath_cache
0 0 skbuff_fclone_cache
0 0 tw_sock_TCP
0 0 udf_inode_cache
0 0 uhci_urb_priv
0 0 xfrm_dst_cache
1 169 dnotify_cache
1 30 arp_cache
1 7 mqueue_inode_cache
2 101 eventpoll_pwq
2 203 fasync_cache
2 254 revoke_table
2 30 eventpoll_epi
2 9 RAW
4 17 ip_conntrack
7 10 biovec-128
7 10 biovec-64
7 20 biovec-16
7 42 file_lock_cache
7 59 biovec-4
7 59 uid_cache
7 8 biovec-256
7 9 bdev_cache
8 127 inotify_event_cache
8 20 rpc_tasks
8 8 rpc_buffers
10 113 ip_fib_alias
10 113 ip_fib_hash
10 12 blkdev_queue
11 203 biovec-1
11 22 blkdev_requests
13 92 inotify_watch_cache
16 169 journal_handle
16 203 tcp_bind_bucket
16 72 journal_head
18 18 UDP
19 19 names_cache
19 28 TCP
22 30 mnt_cache
27 27 sigqueue
27 60 ip_dst_cache
32 32 sgpool-128
32 32 sgpool-32
32 32 sgpool-64
32 36 nfs_read_data
32 45 sgpool-16
32 60 sgpool-8
36 42 nfs_write_data
72 80 cfq_pool
74 127 blkdev_ioc
78 92 cfq_ioc_pool
94 94 pgd
107 113 fs_cache
108 108 mm_struct
108 140 files_cache
123 123 sighand_cache
125 140 UNIX
130 130 signal_cache
147 147 task_struct
154 174 idr_layer_cache
158 404 pid
190 190 sock_inode_cache
260 295 bio
273 273 proc_inode_cache
840 920 skbuff_head_cache
1234 1326 inode_cache
1507 1510 shmem_inode_cache
2871 3051 anon_vma
2910 3360 filp
5161 5292 sysfs_dir_cache
5762 6164 vm_area_struct
12056 19446 radix_tree_node
65776 151272 buffer_head
578304 578304 ext3_inode_cache
677490 677490 dentry_cache

JA?rn

-- 
And spam is a useful source of entropy for /dev/random too!
-- Jasmine Strong

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
