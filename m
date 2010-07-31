Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D39A26B02B4
	for <linux-mm@kvack.org>; Sat, 31 Jul 2010 13:09:50 -0400 (EDT)
Date: Sun, 1 Aug 2010 00:13:58 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] vmscan: raise the bar to PAGEOUT_IO_SYNC stalls
Message-ID: <20100731161358.GA5147@localhost>
References: <20100728071705.GA22964@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100728071705.GA22964@localhost>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org
Cc: Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Andreas Mohr <andi@lisas.de>, Bill Davidsen <davidsen@tmr.com>, Ben Gamari <bgamari.foss@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 28, 2010 at 03:17:05PM +0800, Wu Fengguang wrote:
> Fix "system goes unresponsive under memory pressure and lots of
> dirty/writeback pages" bug.
> 
> 	http://lkml.org/lkml/2010/4/4/86
> 
> In the above thread, Andreas Mohr described that
> 
> 	Invoking any command locked up for minutes (note that I'm
> 	talking about attempted additional I/O to the _other_,
> 	_unaffected_ main system HDD - such as loading some shell
> 	binaries -, NOT the external SSD18M!!).
> 
> This happens when the two conditions are both meet:
> - under memory pressure
> - writing heavily to a slow device
> 
> OOM also happens in Andreas' system. The OOM trace shows that 3
> processes are stuck in wait_on_page_writeback() in the direct reclaim
> path. One in do_fork() and the other two in unix_stream_sendmsg(). They
> are blocked on this condition:
> 
> 	(sc->order && priority < DEF_PRIORITY - 2)
> 
> which was introduced in commit 78dc583d (vmscan: low order lumpy reclaim
> also should use PAGEOUT_IO_SYNC) one year ago. That condition may be too
> permissive. In Andreas' case, 512MB/1024 = 512KB. If the direct reclaim
> for the order-1 fork() allocation runs into a range of 512KB
> hard-to-reclaim LRU pages, it will be stalled.
> 
> It's a severe problem in three ways.

FYI I did some memory stress test and find there are much more order-1
(and higher) users than fork(). This means lots of running applications
may stall on direct reclaim.

Basically all of these slab caches will do high order allocations:

$ grep -v '1 :' /proc/slabinfo
slabinfo - version: 2.1
# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
nf_conntrack_expect      0      0    352   23    2 : tunables    0    0    0 : slabdata      0      0      0
nf_conntrack_ffffffff826e7340     57    102    472   17    2 : tunables    0    0    0 : slabdata      6      6      0
ip6_dst_cache         52     72    448   18    2 : tunables    0    0    0 : slabdata      4      4      0
ndisc_cache           32     32    512   16    2 : tunables    0    0    0 : slabdata      2      2      0
RAWv6                 20     20   1600   20    8 : tunables    0    0    0 : slabdata      1      1      0
UDPLITEv6              0      0   1600   20    8 : tunables    0    0    0 : slabdata      0      0      0
UDPv6                 40     40   1600   20    8 : tunables    0    0    0 : slabdata      2      2      0
TCPv6                 24     24   2688   12    8 : tunables    0    0    0 : slabdata      2      2      0
btrfs_transaction_cache     13     13    592   13    2 : tunables    0    0    0 : slabdata      1      1      0
btrfs_inode_cache     29     42   2256   14    8 : tunables    0    0    0 : slabdata      3      3      0
fat_inode_cache        0      0   1376   23    8 : tunables    0    0    0 : slabdata      0      0      0
reiser_inode_cache 276868 278300   1592   20    8 : tunables    0    0    0 : slabdata  13915  13915      0
kvm_vcpu               0      0  10608    3    8 : tunables    0    0    0 : slabdata      0      0      0
mqueue_inode_cache     19     19   1664   19    8 : tunables    0    0    0 : slabdata      1      1      0
fuse_request           0      0    760   21    4 : tunables    0    0    0 : slabdata      0      0      0
fuse_inode             0      0   1472   22    8 : tunables    0    0    0 : slabdata      0      0      0
nfs_write_data        38     38    832   19    4 : tunables    0    0    0 : slabdata      2      2      0
nfs_read_data         42     42    768   21    4 : tunables    0    0    0 : slabdata      2      2      0
nfs_inode_cache        0      0   1648   19    8 : tunables    0    0    0 : slabdata      0      0      0
hugetlbfs_inode_cache     12     12   1312   12    4 : tunables    0    0    0 : slabdata      1      1      0
ext4_inode_cache   68415  68748   1912   17    8 : tunables    0    0    0 : slabdata   4044   4044      0
ext3_inode_cache  232870 237481   1664   19    8 : tunables    0    0    0 : slabdata  12499  12499      0
kioctx                 0      0    704   23    4 : tunables    0    0    0 : slabdata      0      0      0
rpc_buffers           15     15   2176   15    8 : tunables    0    0    0 : slabdata      1      1      0
rpc_tasks             21     21    384   21    2 : tunables    0    0    0 : slabdata      1      1      0
rpc_inode_cache       20     20   1600   20    8 : tunables    0    0    0 : slabdata      1      1      0
UNIX                 205    240   1600   20    8 : tunables    0    0    0 : slabdata     12     12      0
UDP-Lite               0      0   1472   22    8 : tunables    0    0    0 : slabdata      0      0      0
xfrm_dst_cache         0      0    448   18    2 : tunables    0    0    0 : slabdata      0      0      0
ip_dst_cache          75     90    448   18    2 : tunables    0    0    0 : slabdata      5      5      0
arp_cache             32     32    512   16    2 : tunables    0    0    0 : slabdata      2      2      0
RAW                   46     46   1408   23    8 : tunables    0    0    0 : slabdata      2      2      0
UDP                   49     66   1472   22    8 : tunables    0    0    0 : slabdata      3      3      0
TCP                   37     60   2560   12    8 : tunables    0    0    0 : slabdata      5      5      0
sgpool-128            16     21   4224    7    8 : tunables    0    0    0 : slabdata      3      3      0
sgpool-64             30     30   2176   15    8 : tunables    0    0    0 : slabdata      2      2      0
sgpool-32             28     28   1152   14    4 : tunables    0    0    0 : slabdata      2      2      0
sgpool-16             24     24    640   12    2 : tunables    0    0    0 : slabdata      2      2      0
sgpool-8              44     63    384   21    2 : tunables    0    0    0 : slabdata      3      3      0
blkdev_queue          30     30   2984   10    8 : tunables    0    0    0 : slabdata      3      3      0
blkdev_requests       48     60    408   20    2 : tunables    0    0    0 : slabdata      3      3      0
biovec-256             7      7   4224    7    8 : tunables    0    0    0 : slabdata      1      1      0
biovec-128            30     30   2176   15    8 : tunables    0    0    0 : slabdata      2      2      0
biovec-64             28     28   1152   14    4 : tunables    0    0    0 : slabdata      2      2      0
biovec-16             42     42    384   21    2 : tunables    0    0    0 : slabdata      2      2      0
bip-256                7      7   4288    7    8 : tunables    0    0    0 : slabdata      1      1      0
bip-128                0      0   2240   14    8 : tunables    0    0    0 : slabdata      0      0      0
bip-64                 0      0   1216   13    4 : tunables    0    0    0 : slabdata      0      0      0
bip-16                 0      0    448   18    2 : tunables    0    0    0 : slabdata      0      0      0
sock_inode_cache     283    322   1408   23    8 : tunables    0    0    0 : slabdata     14     14      0
skbuff_fclone_cache     28     28    576   14    2 : tunables    0    0    0 : slabdata      2      2      0
shmem_inode_cache   2632   2646   1560   21    8 : tunables    0    0    0 : slabdata    126    126      0
taskstats             40     40    400   20    2 : tunables    0    0    0 : slabdata      2      2      0
proc_inode_cache     848    888   1288   12    4 : tunables    0    0    0 : slabdata     74     74      0
bdev_cache            54     54   1728   18    8 : tunables    0    0    0 : slabdata      3      3      0
filp                3704   3948    384   21    2 : tunables    0    0    0 : slabdata    188    188      0
inode_cache         4546   4836   1240   13    4 : tunables    0    0    0 : slabdata    372    372      0
names_cache           14     14   4224    7    8 : tunables    0    0    0 : slabdata      2      2      0
radix_tree_node    37173  37817    624   13    2 : tunables    0    0    0 : slabdata   2909   2909      0
mm_struct            125    144   1280   12    4 : tunables    0    0    0 : slabdata     12     12      0
files_cache          129    144    896   18    4 : tunables    0    0    0 : slabdata      8      8      0
signal_cache         227    247   1216   13    4 : tunables    0    0    0 : slabdata     19     19      0
sighand_cache        227    238   2304   14    8 : tunables    0    0    0 : slabdata     17     17      0
task_xstate          210    228    640   12    2 : tunables    0    0    0 : slabdata     19     19      0
task_struct          310    318   9104    3    8 : tunables    0    0    0 : slabdata    106    106      0
idr_layer_cache      336    338    616   13    2 : tunables    0    0    0 : slabdata     26     26      0
kmalloc-8192          41     42   8264    3    8 : tunables    0    0    0 : slabdata     14     14      0
kmalloc-4096         546    560   4168    7    8 : tunables    0    0    0 : slabdata     80     80      0
kmalloc-2048         451    495   2120   15    8 : tunables    0    0    0 : slabdata     33     33      0
kmalloc-1024         928    986   1096   29    8 : tunables    0    0    0 : slabdata     34     34      0
kmalloc-512         5011   5012    584   14    2 : tunables    0    0    0 : slabdata    358    358      0

In particular the radix_tree_node slab cache turns up a lot as in the
below trace. It happens when the process tries to swap in a page (this
happens a lot!) and need to allocate a new radix tree node for the
swapper_space.

Imagine the user want to switch to an application which involves many
swap-in reads, and many of them will stall in wait_on_page_writeback()
for seconds waiting for some unrelated dirty page to be synced!


[ 8603.802898] usemem        D 00000001001f68a1  2224  3920      1 0x00000004
[ 8603.803028]  ffff8800aac3b5c8 0000000000000006 00000000ffffffff 00000000001d55c0
[ 8603.803246]  ffff8800b4d1a350 00000000001d55c0 ffff8800aac3bfd8 ffff8800aac3bfd8
[ 8603.803464]  00000000001d55c0 ffff8800b4d1a6b8 00000000001d55c0 00000000001d55c0
[ 8603.803681] Call Trace:
[ 8603.803747]  [<ffffffff811a5ee0>] ? sync_page+0x0/0xb0
[ 8603.803820]  [<ffffffff81b7e046>] io_schedule+0x96/0x110
[ 8603.803896]  [<ffffffff811a5f4f>] sync_page+0x6f/0xb0
[ 8603.803966]  [<ffffffff81b7ee0d>] __wait_on_bit+0x8d/0xe0
[ 8603.804037]  [<ffffffff811a62ff>] wait_on_page_bit+0x8f/0xa0
[ 8603.804108]  [<ffffffff810e4530>] ? wake_bit_function+0x0/0x70
[ 8603.804179]  [<ffffffff811bc331>] shrink_page_list+0x241/0xcf0
[ 8603.804250]  [<ffffffff810e46ef>] ? finish_wait+0x7f/0xb0
[ 8603.804322]  [<ffffffff810e44d0>] ? autoremove_wake_function+0x0/0x60
[ 8603.804393]  [<ffffffff811bd3bc>] shrink_inactive_list+0x27c/0x4b0
[ 8603.804465]  [<ffffffff811023e0>] ? mark_held_locks+0x90/0xd0
[ 8603.804536]  [<ffffffff811bdea9>] shrink_zone+0x499/0x610
[ 8603.804608]  [<ffffffff811be52b>] do_try_to_free_pages+0x13b/0x540
[ 8603.804679]  [<ffffffff811beb59>] try_to_free_pages+0x99/0x180
[ 8603.804751]  [<ffffffff811b1e50>] __alloc_pages_nodemask+0x6f0/0xb50
[ 8603.804824]  [<ffffffff811f759b>] alloc_pages_current+0xcb/0x160
[ 8603.804895]  [<ffffffff81204b74>] new_slab+0x274/0x3b0
[ 8603.804965]  [<ffffffff8120581f>] __slab_alloc+0x4bf/0x840
[ 8603.805036]  [<ffffffff81578bd4>] ? radix_tree_preload+0x44/0xd0
[ 8603.805108]  [<ffffffff8120665b>] kmem_cache_alloc+0x22b/0x240
[ 8603.805179]  [<ffffffff81578bd4>] ? radix_tree_preload+0x44/0xd0
[ 8603.805250]  [<ffffffff81578bd4>] radix_tree_preload+0x44/0xd0
[ 8603.805322]  [<ffffffff811e94d3>] read_swap_cache_async+0x83/0x1f0
[ 8603.805393]  [<ffffffff811ef20f>] ? valid_swaphandles+0x1cf/0x240
[ 8603.805465]  [<ffffffff811e96eb>] swapin_readahead+0xab/0xf0
[ 8603.805536]  [<ffffffff811a5be0>] ? find_get_page+0x0/0x1c0
[ 8603.805606]  [<ffffffff811d2bdd>] handle_mm_fault+0xabd/0xe70
[ 8603.805677]  [<ffffffff81b88534>] ? do_page_fault+0x144/0x770
[ 8603.805749]  [<ffffffff81b885c9>] do_page_fault+0x1d9/0x770
[ 8603.805820]  [<ffffffff81b83d56>] ? error_sti+0x5/0x6
[ 8603.805889]  [<ffffffff81b82056>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[ 8603.805962]  [<ffffffff81b83b45>] page_fault+0x25/0x30


Thanks,
Fengguang

The more sysrq-t output after `shutdown`. The system is so
stressed that it cannot be shutdown at all..

[ 8603.783334] cp            D 00000001001fb070  1832  3528   3513 0x00000004
[ 8603.783464]  ffff88009f505a08 0000000000000006 0000000000000000 00000000001d55c0
[ 8603.783681]  ffff8800b9a3a350 00000000001d55c0 ffff88009f505fd8 ffff88009f505fd8
[ 8603.783898]  00000000001d55c0 ffff8800b9a3a6b8 00000000001d55c0 00000000001d55c0
[ 8603.784117] Call Trace:
[ 8603.784183]  [<ffffffff8123f890>] ? inode_wait+0x0/0x20
[ 8603.784253]  [<ffffffff8123f8a5>] inode_wait+0x15/0x20
[ 8603.784323]  [<ffffffff81b7ee0d>] __wait_on_bit+0x8d/0xe0
[ 8603.784395]  [<ffffffff81251279>] inode_wait_for_writeback+0xb9/0xf0
[ 8603.784467]  [<ffffffff810e4530>] ? wake_bit_function+0x0/0x70
[ 8603.784538]  [<ffffffff8115992c>] ? check_for_new_grace_period+0x1ac/0x1e0
[ 8603.784612]  [<ffffffff8125133f>] writeback_single_inode+0x8f/0x3e0
[ 8603.784684]  [<ffffffff812516d1>] sync_inode+0x41/0x70
[ 8603.784753]  [<ffffffff81384d2a>] nfs_wb_all+0x4a/0x60
[ 8603.784824]  [<ffffffff81370108>] nfs_do_fsync+0x38/0x90
[ 8603.784894]  [<ffffffff813703fa>] nfs_file_flush+0x8a/0xd0
[ 8603.784965]  [<ffffffff8121d164>] filp_close+0x54/0xd0
[ 8603.785036]  [<ffffffff810b9881>] put_files_struct+0x111/0x210
[ 8603.785106]  [<ffffffff810b97b0>] ? put_files_struct+0x40/0x210
[ 8603.785178]  [<ffffffff810b9a7e>] exit_files+0x6e/0x90
[ 8603.785248]  [<ffffffff810ba1b6>] do_exit+0x1e6/0xc40
[ 8603.785319]  [<ffffffff810fee3b>] ? trace_hardirqs_off+0x1b/0x30
[ 8603.785390]  [<ffffffff81b8342c>] ? _raw_spin_unlock_irq+0x4c/0x70
[ 8603.785461]  [<ffffffff810baf7d>] do_group_exit+0x6d/0x130
[ 8603.785533]  [<ffffffff810d1e9e>] get_signal_to_deliver+0x3de/0x6a0
[ 8603.785606]  [<ffffffff8104c843>] do_signal+0x83/0xae0
[ 8603.785676]  [<ffffffff8126d1fe>] ? fsnotify+0x35e/0x3d0
[ 8603.785747]  [<ffffffff811cdb46>] ? might_fault+0xd6/0xf0
[ 8603.785818]  [<ffffffff8104d35c>] do_notify_resume+0x8c/0xc0
[ 8603.785889]  [<ffffffff81b82017>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[ 8603.785961]  [<ffffffff8104dec3>] int_signal+0x12/0x17
[ 8603.786030] flush-0:23    D 00000001001f6fae  2440  3529      2 0x00000000
[ 8603.786160]  ffff88003deeba50 0000000000000006 ffff880000000000 00000000001d55c0
[ 8603.786379]  ffff8800b9a3c6a0 00000000001d55c0 ffff88003deebfd8 ffff88003deebfd8
[ 8603.786597]  00000000001d55c0 ffff8800b9a3ca08 00000000001d55c0 00000000001d55c0
[ 8603.786814] Call Trace:
[ 8603.786881]  [<ffffffff811a5ee0>] ? sync_page+0x0/0xb0
[ 8603.786951]  [<ffffffff81b7e046>] io_schedule+0x96/0x110
[ 8603.787020]  [<ffffffff811a5f4f>] sync_page+0x6f/0xb0
[ 8603.787090]  [<ffffffff81b7ee0d>] __wait_on_bit+0x8d/0xe0
[ 8603.787160]  [<ffffffff811a565d>] ? find_get_pages_tag+0x16d/0x280
[ 8603.787231]  [<ffffffff811a54f0>] ? find_get_pages_tag+0x0/0x280
[ 8603.787302]  [<ffffffff811a62ff>] wait_on_page_bit+0x8f/0xa0
[ 8603.787373]  [<ffffffff810e4530>] ? wake_bit_function+0x0/0x70
[ 8603.787444]  [<ffffffff811b5b3c>] ? pagevec_lookup_tag+0x2c/0x40
[ 8603.787515]  [<ffffffff811a756e>] filemap_fdatawait_range+0x1de/0x250
[ 8603.787587]  [<ffffffff811a7611>] filemap_fdatawait+0x31/0x40
[ 8603.787658]  [<ffffffff8125158f>] writeback_single_inode+0x2df/0x3e0
[ 8603.787730]  [<ffffffff81251cc6>] generic_writeback_sb_inodes+0x106/0x230
[ 8603.787802]  [<ffffffff81251e2f>] do_writeback_sb_inodes+0x3f/0x50
[ 8603.787874]  [<ffffffff81252ca2>] wb_writeback+0x172/0x510
[ 8603.787944]  [<ffffffff810fee3b>] ? trace_hardirqs_off+0x1b/0x30
[ 8603.788015]  [<ffffffff812531ae>] wb_do_writeback+0xce/0x290
[ 8603.788086]  [<ffffffff8125351a>] bdi_writeback_thread+0x1aa/0x3e0
[ 8603.788157]  [<ffffffff81253370>] ? bdi_writeback_thread+0x0/0x3e0
[ 8603.788229]  [<ffffffff810e3dad>] kthread+0xcd/0xe0
[ 8603.788299]  [<ffffffff8104e9e4>] kernel_thread_helper+0x4/0x10
[ 8603.788370]  [<ffffffff81b83910>] ? restore_args+0x0/0x30
[ 8603.788440]  [<ffffffff810e3ce0>] ? kthread+0x0/0xe0
[ 8603.788510]  [<ffffffff8104e9e0>] ? kernel_thread_helper+0x0/0x10
[ 8603.788580] mem-stress-te S 000000010015b965  4056  3605   3202 0x00000000
[ 8603.788710]  ffff880067ccde78 0000000000000002 0000000000000000 00000000001d55c0
[ 8603.788928]  ffff8800b9b446a0 00000000001d55c0 ffff880067ccdfd8 ffff880067ccdfd8
[ 8603.789146]  00000000001d55c0 ffff8800b9b44a08 00000000001d55c0 00000000001d55c0
[ 8603.789364] Call Trace:
[ 8603.789429]  [<ffffffff810b9475>] do_wait+0x245/0x340
[ 8603.789500]  [<ffffffff810bb436>] sys_wait4+0x86/0x150
[ 8603.789570]  [<ffffffff810b7860>] ? child_wait_callback+0x0/0xb0
[ 8603.789641]  [<ffffffff8104db72>] system_call_fastpath+0x16/0x1b
[ 8603.789712] cp            D 00000001001fb07b  1904  3612   3605 0x00000004
[ 8603.789843]  ffff880008c41a08 0000000000000006 0000000000000000 00000000001d55c0
[ 8603.790061]  ffff8800b4d40000 00000000001d55c0 ffff880008c41fd8 ffff880008c41fd8
[ 8603.790280]  00000000001d55c0 ffff8800b4d40368 00000000001d55c0 00000000001d55c0
[ 8603.790498] Call Trace:
[ 8603.790565]  [<ffffffff8123f890>] ? inode_wait+0x0/0x20
[ 8603.790636]  [<ffffffff8123f8a5>] inode_wait+0x15/0x20
[ 8603.790706]  [<ffffffff81b7ee0d>] __wait_on_bit+0x8d/0xe0
[ 8603.790777]  [<ffffffff81251279>] inode_wait_for_writeback+0xb9/0xf0
[ 8603.790849]  [<ffffffff810e4530>] ? wake_bit_function+0x0/0x70
[ 8603.790921]  [<ffffffff8115992c>] ? check_for_new_grace_period+0x1ac/0x1e0
[ 8603.790994]  [<ffffffff8125133f>] writeback_single_inode+0x8f/0x3e0
[ 8603.791065]  [<ffffffff812516d1>] sync_inode+0x41/0x70
[ 8603.791135]  [<ffffffff81384d2a>] nfs_wb_all+0x4a/0x60
[ 8603.791206]  [<ffffffff81370108>] nfs_do_fsync+0x38/0x90
[ 8603.791276]  [<ffffffff813703fa>] nfs_file_flush+0x8a/0xd0
[ 8603.791346]  [<ffffffff8121d164>] filp_close+0x54/0xd0
[ 8603.791988]  [<ffffffff810b9881>] put_files_struct+0x111/0x210
[ 8603.792059]  [<ffffffff810b97b0>] ? put_files_struct+0x40/0x210
[ 8603.792130]  [<ffffffff810b9a7e>] exit_files+0x6e/0x90
[ 8603.792200]  [<ffffffff810ba1b6>] do_exit+0x1e6/0xc40
[ 8603.792269]  [<ffffffff810fee3b>] ? trace_hardirqs_off+0x1b/0x30
[ 8603.792340]  [<ffffffff81b8342c>] ? _raw_spin_unlock_irq+0x4c/0x70
[ 8603.792412]  [<ffffffff810baf7d>] do_group_exit+0x6d/0x130
[ 8603.792482]  [<ffffffff810d1e9e>] get_signal_to_deliver+0x3de/0x6a0
[ 8603.792555]  [<ffffffff8104c843>] do_signal+0x83/0xae0
[ 8603.792625]  [<ffffffff8126d1fe>] ? fsnotify+0x35e/0x3d0
[ 8603.792695]  [<ffffffff8104d35c>] do_notify_resume+0x8c/0xc0
[ 8603.792766]  [<ffffffff81b82017>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[ 8603.792837]  [<ffffffff8104dec3>] int_signal+0x12/0x17
[ 8603.792907] su            S 000000010012dd7d  4136  3857   3417 0x00000000
[ 8603.793037]  ffff880099a71e78 0000000000000002 0000000000000000 00000000001d55c0
[ 8603.793254]  ffff880073db2350 00000000001d55c0 ffff880099a71fd8 ffff880099a71fd8
[ 8603.793473]  00000000001d55c0 ffff880073db26b8 00000000001d55c0 00000000001d55c0
[ 8603.793690] Call Trace:
[ 8603.793755]  [<ffffffff810b9475>] do_wait+0x245/0x340
[ 8603.793826]  [<ffffffff810bb436>] sys_wait4+0x86/0x150
[ 8603.793895]  [<ffffffff810b7860>] ? child_wait_callback+0x0/0xb0
[ 8603.793967]  [<ffffffff8104db72>] system_call_fastpath+0x16/0x1b
[ 8603.794037] zsh           S 0000000100196400  3760  3860   3857 0x00000000
[ 8603.794166]  ffff880016f37f38 0000000000000006 0000000000000000 00000000001d55c0
[ 8603.794383]  ffff8800a6180000 00000000001d55c0 ffff880016f37fd8 ffff880016f37fd8
[ 8603.794601]  00000000001d55c0 ffff8800a6180368 00000000001d55c0 00000000001d55c0
[ 8603.794820] Call Trace:
[ 8603.794886]  [<ffffffff810d3cad>] sys_rt_sigsuspend+0xfd/0x150
[ 8603.794957]  [<ffffffff8104db72>] system_call_fastpath+0x16/0x1b
[ 8603.795027] mem-stress-te S 00000001001fa536  4056  3907   3202 0x00000000
[ 8603.795157]  ffff8800489b3e78 0000000000000006 0000000000000000 00000000001d55c0
[ 8603.795376]  ffff880073db0000 00000000001d55c0 ffff8800489b3fd8 ffff8800489b3fd8
[ 8603.795593]  00000000001d55c0 ffff880073db0368 00000000001d55c0 00000000001d55c0
[ 8603.795811] Call Trace:
[ 8603.795876]  [<ffffffff810b9475>] do_wait+0x245/0x340
[ 8603.795946]  [<ffffffff810bb436>] sys_wait4+0x86/0x150
[ 8603.796017]  [<ffffffff810b7860>] ? child_wait_callback+0x0/0xb0
[ 8603.796089]  [<ffffffff8104db72>] system_call_fastpath+0x16/0x1b
[ 8603.796159] cp            D 00000001001b3f13  2152  3917   3907 0x00000004
[ 8603.796289]  ffff880033ae7338 0000000000000006 ffff880000000000 00000000001d55c0
[ 8603.796507]  ffff880073db46a0 00000000001d55c0 ffff880033ae7fd8 ffff880033ae7fd8
[ 8603.796725]  00000000001d55c0 ffff880073db4a08 00000000001d55c0 00000000001d55c0
[ 8603.796943] Call Trace:
[ 8603.797010]  [<ffffffff811a5ee0>] ? sync_page+0x0/0xb0
[ 8603.797079]  [<ffffffff81b7e046>] io_schedule+0x96/0x110
[ 8603.797150]  [<ffffffff811a5f4f>] sync_page+0x6f/0xb0
[ 8603.797220]  [<ffffffff81b7ee0d>] __wait_on_bit+0x8d/0xe0
[ 8603.797291]  [<ffffffff811a62ff>] wait_on_page_bit+0x8f/0xa0
[ 8603.797362]  [<ffffffff810e4530>] ? wake_bit_function+0x0/0x70
[ 8603.797433]  [<ffffffff811bc331>] shrink_page_list+0x241/0xcf0
[ 8603.797505]  [<ffffffff810e46ef>] ? finish_wait+0x7f/0xb0
[ 8603.797576]  [<ffffffff810e44d0>] ? autoremove_wake_function+0x0/0x60
[ 8603.797647]  [<ffffffff811bd3bc>] shrink_inactive_list+0x27c/0x4b0
[ 8603.797719]  [<ffffffff811bdea9>] shrink_zone+0x499/0x610
[ 8603.797790]  [<ffffffff811be52b>] do_try_to_free_pages+0x13b/0x540
[ 8603.797862]  [<ffffffff811beb59>] try_to_free_pages+0x99/0x180
[ 8603.797933]  [<ffffffff81104f08>] ? __lock_acquire+0x618/0x2a20
[ 8603.798004]  [<ffffffff811b1e50>] __alloc_pages_nodemask+0x6f0/0xb50
[ 8603.798076]  [<ffffffff810ee46d>] ? local_clock+0x9d/0xb0
[ 8603.798147]  [<ffffffff811f759b>] alloc_pages_current+0xcb/0x160
[ 8603.798218]  [<ffffffff81204b74>] new_slab+0x274/0x3b0
[ 8603.798288]  [<ffffffff8120581f>] __slab_alloc+0x4bf/0x840
[ 8603.798360]  [<ffffffff81578bd4>] ? radix_tree_preload+0x44/0xd0
[ 8603.798431]  [<ffffffff8120665b>] kmem_cache_alloc+0x22b/0x240
[ 8603.798502]  [<ffffffff81578bd4>] ? radix_tree_preload+0x44/0xd0
[ 8603.798573]  [<ffffffff81578bd4>] radix_tree_preload+0x44/0xd0
[ 8603.798644]  [<ffffffff811a650a>] add_to_page_cache_locked+0x8a/0x210
[ 8603.798716]  [<ffffffff811a66d9>] add_to_page_cache_lru+0x49/0xc0
[ 8603.798787]  [<ffffffff8126ac75>] mpage_readpages+0xd5/0x190
[ 8603.798859]  [<ffffffff812f4960>] ? ext4_get_block+0x0/0x30
[ 8603.798929]  [<ffffffff812f4960>] ? ext4_get_block+0x0/0x30
[ 8603.799000]  [<ffffffff812eec04>] ext4_readpages+0x24/0x30
[ 8603.799071]  [<ffffffff811b4f97>] __do_page_cache_readahead+0x1e7/0x300
[ 8603.799142]  [<ffffffff811b4e7b>] ? __do_page_cache_readahead+0xcb/0x300
[ 8603.799215]  [<ffffffff810fec5d>] ? trace_hardirqs_off_caller+0x2d/0x1f0
[ 8603.799287]  [<ffffffff811b5568>] ra_submit+0x28/0x40
[ 8603.799357]  [<ffffffff811b5657>] ondemand_readahead+0xd7/0x3b0
[ 8603.799429]  [<ffffffff811b59ef>] page_cache_async_readahead+0xbf/0x140
[ 8603.799501]  [<ffffffff811a5cf3>] ? find_get_page+0x113/0x1c0
[ 8603.799572]  [<ffffffff811a5be0>] ? find_get_page+0x0/0x1c0
[ 8603.799643]  [<ffffffff811a88fb>] generic_file_aio_read+0x67b/0xa50
[ 8603.799715]  [<ffffffff810fee3b>] ? trace_hardirqs_off+0x1b/0x30
[ 8603.799787]  [<ffffffff810ee46d>] ? local_clock+0x9d/0xb0
[ 8603.799858]  [<ffffffff8121f700>] do_sync_read+0xf0/0x140
[ 8603.799929]  [<ffffffff8126d1fe>] ? fsnotify+0x35e/0x3d0
[ 8603.799999]  [<ffffffff812201d1>] vfs_read+0xc1/0x240
[ 8603.800069]  [<ffffffff812203b6>] sys_read+0x66/0xb0
[ 8603.800139]  [<ffffffff8104db72>] system_call_fastpath+0x16/0x1b
[ 8603.800209] cp            D 00000001001fb07e  2184  3919   3907 0x00000004
[ 8603.800339]  ffff88006b77fa08 0000000000000002 0000000000000000 00000000001d55c0
[ 8603.800557]  ffff8800b988c6a0 00000000001d55c0 ffff88006b77ffd8 ffff88006b77ffd8
[ 8603.800776]  00000000001d55c0 ffff8800b988ca08 00000000001d55c0 00000000001d55c0
[ 8603.800993] Call Trace:
[ 8603.801059]  [<ffffffff8123f890>] ? inode_wait+0x0/0x20
[ 8603.801129]  [<ffffffff8123f8a5>] inode_wait+0x15/0x20
[ 8603.801199]  [<ffffffff81b7ee0d>] __wait_on_bit+0x8d/0xe0
[ 8603.801270]  [<ffffffff81251279>] inode_wait_for_writeback+0xb9/0xf0
[ 8603.801342]  [<ffffffff810e4530>] ? wake_bit_function+0x0/0x70
[ 8603.801413]  [<ffffffff8115992c>] ? check_for_new_grace_period+0x1ac/0x1e0
[ 8603.801486]  [<ffffffff8125133f>] writeback_single_inode+0x8f/0x3e0
[ 8603.801557]  [<ffffffff812516d1>] sync_inode+0x41/0x70
[ 8603.801627]  [<ffffffff81384d2a>] nfs_wb_all+0x4a/0x60
[ 8603.801697]  [<ffffffff81370108>] nfs_do_fsync+0x38/0x90
[ 8603.801767]  [<ffffffff813703fa>] nfs_file_flush+0x8a/0xd0
[ 8603.801837]  [<ffffffff8121d164>] filp_close+0x54/0xd0
[ 8603.801907]  [<ffffffff810b9881>] put_files_struct+0x111/0x210
[ 8603.801978]  [<ffffffff810b97b0>] ? put_files_struct+0x40/0x210
[ 8603.802048]  [<ffffffff810b9a7e>] exit_files+0x6e/0x90
[ 8603.802118]  [<ffffffff810ba1b6>] do_exit+0x1e6/0xc40
[ 8603.802188]  [<ffffffff810fee3b>] ? trace_hardirqs_off+0x1b/0x30
[ 8603.802259]  [<ffffffff81b8342c>] ? _raw_spin_unlock_irq+0x4c/0x70
[ 8603.802330]  [<ffffffff810baf7d>] do_group_exit+0x6d/0x130
[ 8603.802401]  [<ffffffff810d1e9e>] get_signal_to_deliver+0x3de/0x6a0
[ 8603.802473]  [<ffffffff8104c843>] do_signal+0x83/0xae0
[ 8603.802543]  [<ffffffff8126d1fe>] ? fsnotify+0x35e/0x3d0
[ 8603.802614]  [<ffffffff811cdb46>] ? might_fault+0xd6/0xf0
[ 8603.802685]  [<ffffffff8104d35c>] do_notify_resume+0x8c/0xc0
[ 8603.802756]  [<ffffffff81b82017>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[ 8603.802828]  [<ffffffff8104dec3>] int_signal+0x12/0x17
[ 8603.802898] usemem        D 00000001001f68a1  2224  3920      1 0x00000004
[ 8603.803028]  ffff8800aac3b5c8 0000000000000006 00000000ffffffff 00000000001d55c0
[ 8603.803246]  ffff8800b4d1a350 00000000001d55c0 ffff8800aac3bfd8 ffff8800aac3bfd8
[ 8603.803464]  00000000001d55c0 ffff8800b4d1a6b8 00000000001d55c0 00000000001d55c0
[ 8603.803681] Call Trace:
[ 8603.803747]  [<ffffffff811a5ee0>] ? sync_page+0x0/0xb0
[ 8603.803820]  [<ffffffff81b7e046>] io_schedule+0x96/0x110
[ 8603.803896]  [<ffffffff811a5f4f>] sync_page+0x6f/0xb0
[ 8603.803966]  [<ffffffff81b7ee0d>] __wait_on_bit+0x8d/0xe0
[ 8603.804037]  [<ffffffff811a62ff>] wait_on_page_bit+0x8f/0xa0
[ 8603.804108]  [<ffffffff810e4530>] ? wake_bit_function+0x0/0x70
[ 8603.804179]  [<ffffffff811bc331>] shrink_page_list+0x241/0xcf0
[ 8603.804250]  [<ffffffff810e46ef>] ? finish_wait+0x7f/0xb0
[ 8603.804322]  [<ffffffff810e44d0>] ? autoremove_wake_function+0x0/0x60
[ 8603.804393]  [<ffffffff811bd3bc>] shrink_inactive_list+0x27c/0x4b0
[ 8603.804465]  [<ffffffff811023e0>] ? mark_held_locks+0x90/0xd0
[ 8603.804536]  [<ffffffff811bdea9>] shrink_zone+0x499/0x610
[ 8603.804608]  [<ffffffff811be52b>] do_try_to_free_pages+0x13b/0x540
[ 8603.804679]  [<ffffffff811beb59>] try_to_free_pages+0x99/0x180
[ 8603.804751]  [<ffffffff811b1e50>] __alloc_pages_nodemask+0x6f0/0xb50
[ 8603.804824]  [<ffffffff811f759b>] alloc_pages_current+0xcb/0x160
[ 8603.804895]  [<ffffffff81204b74>] new_slab+0x274/0x3b0
[ 8603.804965]  [<ffffffff8120581f>] __slab_alloc+0x4bf/0x840
[ 8603.805036]  [<ffffffff81578bd4>] ? radix_tree_preload+0x44/0xd0
[ 8603.805108]  [<ffffffff8120665b>] kmem_cache_alloc+0x22b/0x240
[ 8603.805179]  [<ffffffff81578bd4>] ? radix_tree_preload+0x44/0xd0
[ 8603.805250]  [<ffffffff81578bd4>] radix_tree_preload+0x44/0xd0
[ 8603.805322]  [<ffffffff811e94d3>] read_swap_cache_async+0x83/0x1f0
[ 8603.805393]  [<ffffffff811ef20f>] ? valid_swaphandles+0x1cf/0x240
[ 8603.805465]  [<ffffffff811e96eb>] swapin_readahead+0xab/0xf0
[ 8603.805536]  [<ffffffff811a5be0>] ? find_get_page+0x0/0x1c0
[ 8603.805606]  [<ffffffff811d2bdd>] handle_mm_fault+0xabd/0xe70
[ 8603.805677]  [<ffffffff81b88534>] ? do_page_fault+0x144/0x770
[ 8603.805749]  [<ffffffff81b885c9>] do_page_fault+0x1d9/0x770
[ 8603.805820]  [<ffffffff81b83d56>] ? error_sti+0x5/0x6
[ 8603.805889]  [<ffffffff81b82056>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[ 8603.805962]  [<ffffffff81b83b45>] page_fault+0x25/0x30
[ 8603.806032] usemem        D 00000001001f66b7  2560  3921      1 0x00000004
[ 8603.806163]  ffff88006c98b5c8 0000000000000006 0000000000000000 00000000001d55c0
[ 8603.806383]  ffff880008d5c6a0 00000000001d55c0 ffff88006c98bfd8 ffff88006c98bfd8
[ 8603.806602]  00000000001d55c0 ffff880008d5ca08 00000000001d55c0 00000000001d55c0
[ 8603.807389] Call Trace:
[ 8603.807455]  [<ffffffff811a5ee0>] ? sync_page+0x0/0xb0
[ 8603.807526]  [<ffffffff81b7e046>] io_schedule+0x96/0x110
[ 8603.807596]  [<ffffffff811a5f4f>] sync_page+0x6f/0xb0
[ 8603.807665]  [<ffffffff81b7ee0d>] __wait_on_bit+0x8d/0xe0
[ 8603.807736]  [<ffffffff811a62ff>] wait_on_page_bit+0x8f/0xa0
[ 8603.807807]  [<ffffffff810e4530>] ? wake_bit_function+0x0/0x70
[ 8603.807878]  [<ffffffff811bc331>] shrink_page_list+0x241/0xcf0
[ 8603.807949]  [<ffffffff810e46ef>] ? finish_wait+0x7f/0xb0
[ 8603.808019]  [<ffffffff810e44d0>] ? autoremove_wake_function+0x0/0x60
[ 8603.808092]  [<ffffffff811bd3bc>] shrink_inactive_list+0x27c/0x4b0
[ 8603.808163]  [<ffffffff811023e0>] ? mark_held_locks+0x90/0xd0
[ 8603.808234]  [<ffffffff811bdea9>] shrink_zone+0x499/0x610
[ 8603.808305]  [<ffffffff811be52b>] do_try_to_free_pages+0x13b/0x540
[ 8603.808377]  [<ffffffff811beb59>] try_to_free_pages+0x99/0x180
[ 8603.808448]  [<ffffffff811b1e50>] __alloc_pages_nodemask+0x6f0/0xb50
[ 8603.808520]  [<ffffffff811f759b>] alloc_pages_current+0xcb/0x160
[ 8603.808591]  [<ffffffff81204b74>] new_slab+0x274/0x3b0
[ 8603.808662]  [<ffffffff8120581f>] __slab_alloc+0x4bf/0x840
[ 8603.808733]  [<ffffffff81578bd4>] ? radix_tree_preload+0x44/0xd0
[ 8603.808803]  [<ffffffff8120665b>] kmem_cache_alloc+0x22b/0x240
[ 8603.808875]  [<ffffffff81578bd4>] ? radix_tree_preload+0x44/0xd0
[ 8603.808946]  [<ffffffff81578bd4>] radix_tree_preload+0x44/0xd0
[ 8603.809017]  [<ffffffff811e94d3>] read_swap_cache_async+0x83/0x1f0
[ 8603.809089]  [<ffffffff811ef20f>] ? valid_swaphandles+0x1cf/0x240
[ 8603.809161]  [<ffffffff811e96eb>] swapin_readahead+0xab/0xf0
[ 8603.809231]  [<ffffffff811a5be0>] ? find_get_page+0x0/0x1c0
[ 8603.809302]  [<ffffffff811d2bdd>] handle_mm_fault+0xabd/0xe70
[ 8603.809372]  [<ffffffff81b88534>] ? do_page_fault+0x144/0x770
[ 8603.809444]  [<ffffffff81b885c9>] do_page_fault+0x1d9/0x770
[ 8603.809514]  [<ffffffff81b83d56>] ? error_sti+0x5/0x6
[ 8603.809584]  [<ffffffff81b82056>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[ 8603.809656]  [<ffffffff81b83b45>] page_fault+0x25/0x30
[ 8603.809725] usemem        D 00000001001f6ec4  2616  3922      1 0x00000004
[ 8603.809855]  ffff8800954ff5c8 0000000000000006 00000000ffffffff 00000000001d55c0
[ 8603.810073]  ffff880003540000 00000000001d55c0 ffff8800954fffd8 ffff8800954fffd8
[ 8603.810290]  00000000001d55c0 ffff880003540368 00000000001d55c0 00000000001d55c0
[ 8603.810507] Call Trace:
[ 8603.810573]  [<ffffffff811a5ee0>] ? sync_page+0x0/0xb0
[ 8603.810643]  [<ffffffff81b7e046>] io_schedule+0x96/0x110
[ 8603.810713]  [<ffffffff811a5f4f>] sync_page+0x6f/0xb0
[ 8603.810783]  [<ffffffff81b7ee0d>] __wait_on_bit+0x8d/0xe0
[ 8603.810854]  [<ffffffff811a62ff>] wait_on_page_bit+0x8f/0xa0
[ 8603.810924]  [<ffffffff810e4530>] ? wake_bit_function+0x0/0x70
[ 8603.810996]  [<ffffffff811bc331>] shrink_page_list+0x241/0xcf0
[ 8603.811066]  [<ffffffff8115eb48>] ? delayacct_end+0xa8/0xd0
[ 8603.811137]  [<ffffffff8115ed04>] ? __delayacct_blkio_end+0x64/0x70
[ 8603.811208]  [<ffffffff81b7e660>] ? io_schedule_timeout+0xe0/0x130
[ 8603.811280]  [<ffffffff810e44d0>] ? autoremove_wake_function+0x0/0x60
[ 8603.811352]  [<ffffffff811bd3bc>] shrink_inactive_list+0x27c/0x4b0
[ 8603.811424]  [<ffffffff811023e0>] ? mark_held_locks+0x90/0xd0
[ 8603.811495]  [<ffffffff811bdea9>] shrink_zone+0x499/0x610
[ 8603.811566]  [<ffffffff811be52b>] do_try_to_free_pages+0x13b/0x540
[ 8603.811637]  [<ffffffff811beb59>] try_to_free_pages+0x99/0x180
[ 8603.811709]  [<ffffffff811b1e50>] __alloc_pages_nodemask+0x6f0/0xb50
[ 8603.811781]  [<ffffffff811f759b>] alloc_pages_current+0xcb/0x160
[ 8603.811853]  [<ffffffff81204b74>] new_slab+0x274/0x3b0
[ 8603.811924]  [<ffffffff8120581f>] __slab_alloc+0x4bf/0x840
[ 8603.811994]  [<ffffffff81578bd4>] ? radix_tree_preload+0x44/0xd0
[ 8603.812065]  [<ffffffff8120665b>] kmem_cache_alloc+0x22b/0x240
[ 8603.812137]  [<ffffffff81578bd4>] ? radix_tree_preload+0x44/0xd0
[ 8603.812208]  [<ffffffff81578bd4>] radix_tree_preload+0x44/0xd0
[ 8603.812281]  [<ffffffff811e94d3>] read_swap_cache_async+0x83/0x1f0
[ 8603.812355]  [<ffffffff811ef20f>] ? valid_swaphandles+0x1cf/0x240
[ 8603.812429]  [<ffffffff811e96eb>] swapin_readahead+0xab/0xf0
[ 8603.812499]  [<ffffffff811a5be0>] ? find_get_page+0x0/0x1c0
[ 8603.812570]  [<ffffffff811d2bdd>] handle_mm_fault+0xabd/0xe70
[ 8603.812641]  [<ffffffff81b88534>] ? do_page_fault+0x144/0x770
[ 8603.812712]  [<ffffffff81b885c9>] do_page_fault+0x1d9/0x770
[ 8603.812783]  [<ffffffff81b83d56>] ? error_sti+0x5/0x6
[ 8603.812853]  [<ffffffff81b82056>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[ 8603.812925]  [<ffffffff81b83b45>] page_fault+0x25/0x30
[ 8603.812995] usemem        D 00000001001f6604  2616  3923      1 0x00000004
[ 8603.813125]  ffff8800229d75c8 0000000000000006 0000000000000000 00000000001d55c0
[ 8603.813343]  ffff880003542350 00000000001d55c0 ffff8800229d7fd8 ffff8800229d7fd8
[ 8603.813561]  00000000001d55c0 ffff8800035426b8 00000000001d55c0 00000000001d55c0
[ 8603.813779] Call Trace:
[ 8603.813845]  [<ffffffff811a5ee0>] ? sync_page+0x0/0xb0
[ 8603.813915]  [<ffffffff81b7e046>] io_schedule+0x96/0x110
[ 8603.813985]  [<ffffffff811a5f4f>] sync_page+0x6f/0xb0
[ 8603.814055]  [<ffffffff81b7ee0d>] __wait_on_bit+0x8d/0xe0
[ 8603.814125]  [<ffffffff811a62ff>] wait_on_page_bit+0x8f/0xa0
[ 8603.814197]  [<ffffffff810e4530>] ? wake_bit_function+0x0/0x70
[ 8603.814268]  [<ffffffff811bc331>] shrink_page_list+0x241/0xcf0
[ 8603.814340]  [<ffffffff810e46ef>] ? finish_wait+0x7f/0xb0
[ 8603.814410]  [<ffffffff810e44d0>] ? autoremove_wake_function+0x0/0x60
[ 8603.814482]  [<ffffffff811bd3bc>] shrink_inactive_list+0x27c/0x4b0
[ 8603.814554]  [<ffffffff811023e0>] ? mark_held_locks+0x90/0xd0
[ 8603.814625]  [<ffffffff811bdea9>] shrink_zone+0x499/0x610
[ 8603.814695]  [<ffffffff811be52b>] do_try_to_free_pages+0x13b/0x540
[ 8603.814766]  [<ffffffff811beb59>] try_to_free_pages+0x99/0x180
[ 8603.814838]  [<ffffffff811b1e50>] __alloc_pages_nodemask+0x6f0/0xb50
[ 8603.814910]  [<ffffffff811f759b>] alloc_pages_current+0xcb/0x160
[ 8603.814980]  [<ffffffff81204b74>] new_slab+0x274/0x3b0
[ 8603.815050]  [<ffffffff8120581f>] __slab_alloc+0x4bf/0x840
[ 8603.815121]  [<ffffffff81578bd4>] ? radix_tree_preload+0x44/0xd0
[ 8603.815192]  [<ffffffff8120665b>] kmem_cache_alloc+0x22b/0x240
[ 8603.815263]  [<ffffffff81578bd4>] ? radix_tree_preload+0x44/0xd0
[ 8603.815334]  [<ffffffff81578bd4>] radix_tree_preload+0x44/0xd0
[ 8603.815405]  [<ffffffff811e94d3>] read_swap_cache_async+0x83/0x1f0
[ 8603.815477]  [<ffffffff811ef20f>] ? valid_swaphandles+0x1cf/0x240
[ 8603.815548]  [<ffffffff811e96eb>] swapin_readahead+0xab/0xf0
[ 8603.815619]  [<ffffffff811a5be0>] ? find_get_page+0x0/0x1c0
[ 8603.815689]  [<ffffffff811d2bdd>] handle_mm_fault+0xabd/0xe70
[ 8603.815760]  [<ffffffff81b88534>] ? do_page_fault+0x144/0x770
[ 8603.815831]  [<ffffffff81b885c9>] do_page_fault+0x1d9/0x770
[ 8603.815902]  [<ffffffff81b83d56>] ? error_sti+0x5/0x6
[ 8603.815971]  [<ffffffff81b82056>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[ 8603.816043]  [<ffffffff81b83b45>] page_fault+0x25/0x30
[ 8603.816112] usemem        D 00000001001f663a  2616  3924      1 0x00000004
[ 8603.816242]  ffff88000341d5c8 0000000000000002 00000000ffffffff 00000000001d55c0
[ 8603.816459]  ffff8800035446a0 00000000001d55c0 ffff88000341dfd8 ffff88000341dfd8
[ 8603.816677]  00000000001d55c0 ffff880003544a08 00000000001d55c0 00000000001d55c0
[ 8603.816895] Call Trace:
[ 8603.816961]  [<ffffffff811a5ee0>] ? sync_page+0x0/0xb0
[ 8603.817032]  [<ffffffff81b7e046>] io_schedule+0x96/0x110
[ 8603.817101]  [<ffffffff811a5f4f>] sync_page+0x6f/0xb0
[ 8603.817171]  [<ffffffff81b7ee0d>] __wait_on_bit+0x8d/0xe0
[ 8603.817242]  [<ffffffff811a62ff>] wait_on_page_bit+0x8f/0xa0
[ 8603.817313]  [<ffffffff810e4530>] ? wake_bit_function+0x0/0x70
[ 8603.817384]  [<ffffffff811bc331>] shrink_page_list+0x241/0xcf0
[ 8603.817455]  [<ffffffff810e46ef>] ? finish_wait+0x7f/0xb0
[ 8603.817526]  [<ffffffff810e44d0>] ? autoremove_wake_function+0x0/0x60
[ 8603.817598]  [<ffffffff811bd3bc>] shrink_inactive_list+0x27c/0x4b0
[ 8603.817669]  [<ffffffff811023e0>] ? mark_held_locks+0x90/0xd0
[ 8603.817740]  [<ffffffff811bdea9>] shrink_zone+0x499/0x610
[ 8603.817811]  [<ffffffff811be52b>] do_try_to_free_pages+0x13b/0x540
[ 8603.817883]  [<ffffffff811beb59>] try_to_free_pages+0x99/0x180
[ 8603.817954]  [<ffffffff811b1e50>] __alloc_pages_nodemask+0x6f0/0xb50
[ 8603.818026]  [<ffffffff811f759b>] alloc_pages_current+0xcb/0x160
[ 8603.818097]  [<ffffffff81204b74>] new_slab+0x274/0x3b0
[ 8603.818167]  [<ffffffff8120581f>] __slab_alloc+0x4bf/0x840
[ 8603.818238]  [<ffffffff81578bd4>] ? radix_tree_preload+0x44/0xd0
[ 8603.818309]  [<ffffffff8120665b>] kmem_cache_alloc+0x22b/0x240
[ 8603.818381]  [<ffffffff81578bd4>] ? radix_tree_preload+0x44/0xd0
[ 8603.818452]  [<ffffffff81578bd4>] radix_tree_preload+0x44/0xd0
[ 8603.818523]  [<ffffffff811e94d3>] read_swap_cache_async+0x83/0x1f0
[ 8603.818595]  [<ffffffff811ef20f>] ? valid_swaphandles+0x1cf/0x240
[ 8603.818666]  [<ffffffff811e96eb>] swapin_readahead+0xab/0xf0
[ 8603.818737]  [<ffffffff811a5be0>] ? find_get_page+0x0/0x1c0
[ 8603.818807]  [<ffffffff811d2bdd>] handle_mm_fault+0xabd/0xe70
[ 8603.818878]  [<ffffffff81b88534>] ? do_page_fault+0x144/0x770
[ 8603.818950]  [<ffffffff81b885c9>] do_page_fault+0x1d9/0x770
[ 8603.819020]  [<ffffffff81b83d56>] ? error_sti+0x5/0x6
[ 8603.819090]  [<ffffffff81b82056>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[ 8603.819162]  [<ffffffff81b83b45>] page_fault+0x25/0x30
[ 8603.819231] usemem        D 00000001001eefd8  2144  3925      1 0x00000004
[ 8603.819362]  ffff880015edd5c8 0000000000000006 0000000000000000 00000000001d55c0
[ 8603.819581]  ffff8800034e0000 00000000001d55c0 ffff880015eddfd8 ffff880015eddfd8
[ 8603.819800]  00000000001d55c0 ffff8800034e0368 00000000001d55c0 00000000001d55c0
[ 8603.820018] Call Trace:
[ 8603.820084]  [<ffffffff811a5ee0>] ? sync_page+0x0/0xb0
[ 8603.820155]  [<ffffffff81b7e046>] io_schedule+0x96/0x110
[ 8603.820225]  [<ffffffff811a5f4f>] sync_page+0x6f/0xb0
[ 8603.820295]  [<ffffffff81b7ee0d>] __wait_on_bit+0x8d/0xe0
[ 8603.820366]  [<ffffffff811a62ff>] wait_on_page_bit+0x8f/0xa0
[ 8603.820437]  [<ffffffff810e4530>] ? wake_bit_function+0x0/0x70
[ 8603.820508]  [<ffffffff811bc331>] shrink_page_list+0x241/0xcf0
[ 8603.820580]  [<ffffffff810e46ef>] ? finish_wait+0x7f/0xb0
[ 8603.820650]  [<ffffffff810e44d0>] ? autoremove_wake_function+0x0/0x60
[ 8603.820723]  [<ffffffff811bd3bc>] shrink_inactive_list+0x27c/0x4b0
[ 8603.820794]  [<ffffffff811023e0>] ? mark_held_locks+0x90/0xd0
[ 8603.820866]  [<ffffffff811bdea9>] shrink_zone+0x499/0x610
[ 8603.820936]  [<ffffffff811be52b>] do_try_to_free_pages+0x13b/0x540
[ 8603.821008]  [<ffffffff811beb59>] try_to_free_pages+0x99/0x180
[ 8603.821080]  [<ffffffff811b1e50>] __alloc_pages_nodemask+0x6f0/0xb50
[ 8603.821152]  [<ffffffff811f759b>] alloc_pages_current+0xcb/0x160
[ 8603.821795]  [<ffffffff81204b74>] new_slab+0x274/0x3b0
[ 8603.821865]  [<ffffffff8120581f>] __slab_alloc+0x4bf/0x840
[ 8603.821936]  [<ffffffff81578bd4>] ? radix_tree_preload+0x44/0xd0
[ 8603.822008]  [<ffffffff8120665b>] kmem_cache_alloc+0x22b/0x240
[ 8603.822079]  [<ffffffff81578bd4>] ? radix_tree_preload+0x44/0xd0
[ 8603.822150]  [<ffffffff81578bd4>] radix_tree_preload+0x44/0xd0
[ 8603.822221]  [<ffffffff811e94d3>] read_swap_cache_async+0x83/0x1f0
[ 8603.822292]  [<ffffffff811ef20f>] ? valid_swaphandles+0x1cf/0x240
[ 8603.822364]  [<ffffffff811e96eb>] swapin_readahead+0xab/0xf0
[ 8603.822435]  [<ffffffff811a5be0>] ? find_get_page+0x0/0x1c0
[ 8603.822506]  [<ffffffff811d2bdd>] handle_mm_fault+0xabd/0xe70
[ 8603.822577]  [<ffffffff81b88534>] ? do_page_fault+0x144/0x770
[ 8603.822648]  [<ffffffff81b885c9>] do_page_fault+0x1d9/0x770
[ 8603.822719]  [<ffffffff81b83d56>] ? error_sti+0x5/0x6
[ 8603.822789]  [<ffffffff81b82056>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[ 8603.822861]  [<ffffffff81b83b45>] page_fault+0x25/0x30
[ 8603.822930] usemem        D 00000001001f6a75  2616  3926      1 0x00000004
[ 8603.823059]  ffff88007c4bf5c8 0000000000000002 00000000ffffffff 00000000001d55c0
[ 8603.823276]  ffff8800034e2350 00000000001d55c0 ffff88007c4bffd8 ffff88007c4bffd8
[ 8603.823495]  00000000001d55c0 ffff8800034e26b8 00000000001d55c0 00000000001d55c0
[ 8603.823713] Call Trace:
[ 8603.823779]  [<ffffffff811a5ee0>] ? sync_page+0x0/0xb0
[ 8603.823849]  [<ffffffff81b7e046>] io_schedule+0x96/0x110
[ 8603.823919]  [<ffffffff811a5f4f>] sync_page+0x6f/0xb0
[ 8603.823989]  [<ffffffff81b7ee0d>] __wait_on_bit+0x8d/0xe0
[ 8603.824060]  [<ffffffff811a62ff>] wait_on_page_bit+0x8f/0xa0
[ 8603.824131]  [<ffffffff810e4530>] ? wake_bit_function+0x0/0x70
[ 8603.824202]  [<ffffffff811bc331>] shrink_page_list+0x241/0xcf0
[ 8603.824274]  [<ffffffff810e46ef>] ? finish_wait+0x7f/0xb0
[ 8603.824345]  [<ffffffff810e44d0>] ? autoremove_wake_function+0x0/0x60
[ 8603.824416]  [<ffffffff811bd3bc>] shrink_inactive_list+0x27c/0x4b0
[ 8603.824488]  [<ffffffff811023e0>] ? mark_held_locks+0x90/0xd0
[ 8603.824559]  [<ffffffff811bdea9>] shrink_zone+0x499/0x610
[ 8603.824630]  [<ffffffff811be52b>] do_try_to_free_pages+0x13b/0x540
[ 8603.824701]  [<ffffffff811beb59>] try_to_free_pages+0x99/0x180
[ 8603.824772]  [<ffffffff811b1e50>] __alloc_pages_nodemask+0x6f0/0xb50
[ 8603.824845]  [<ffffffff811f759b>] alloc_pages_current+0xcb/0x160
[ 8603.824916]  [<ffffffff81204b74>] new_slab+0x274/0x3b0
[ 8603.824986]  [<ffffffff8120581f>] __slab_alloc+0x4bf/0x840
[ 8603.825056]  [<ffffffff81578bd4>] ? radix_tree_preload+0x44/0xd0
[ 8603.825127]  [<ffffffff8120665b>] kmem_cache_alloc+0x22b/0x240
[ 8603.825199]  [<ffffffff81578bd4>] ? radix_tree_preload+0x44/0xd0
[ 8603.825270]  [<ffffffff81578bd4>] radix_tree_preload+0x44/0xd0
[ 8603.825341]  [<ffffffff811e94d3>] read_swap_cache_async+0x83/0x1f0
[ 8603.825412]  [<ffffffff811ef20f>] ? valid_swaphandles+0x1cf/0x240
[ 8603.825484]  [<ffffffff811e96eb>] swapin_readahead+0xab/0xf0
[ 8603.825554]  [<ffffffff811a5be0>] ? find_get_page+0x0/0x1c0
[ 8603.825625]  [<ffffffff811d2bdd>] handle_mm_fault+0xabd/0xe70
[ 8603.825696]  [<ffffffff81b88534>] ? do_page_fault+0x144/0x770
[ 8603.825767]  [<ffffffff81b885c9>] do_page_fault+0x1d9/0x770
[ 8603.825838]  [<ffffffff81b83d56>] ? error_sti+0x5/0x6
[ 8603.825908]  [<ffffffff81b82056>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[ 8603.825980]  [<ffffffff81b83b45>] page_fault+0x25/0x30
[ 8603.826050] usemem        D 00000001001ec073  2552  3927      1 0x00000004
[ 8603.826181]  ffff8800325415c8 0000000000000002 0000000000000000 00000000001d55c0
[ 8603.826399]  ffff8800034e46a0 00000000001d55c0 ffff880032541fd8 ffff880032541fd8
[ 8603.826618]  00000000001d55c0 ffff8800034e4a08 00000000001d55c0 00000000001d55c0
[ 8603.826837] Call Trace:
[ 8603.826903]  [<ffffffff811a5ee0>] ? sync_page+0x0/0xb0
[ 8603.826974]  [<ffffffff81b7e046>] io_schedule+0x96/0x110
[ 8603.827044]  [<ffffffff811a5f4f>] sync_page+0x6f/0xb0
[ 8603.827113]  [<ffffffff81b7ee0d>] __wait_on_bit+0x8d/0xe0
[ 8603.827184]  [<ffffffff811a62ff>] wait_on_page_bit+0x8f/0xa0
[ 8603.827256]  [<ffffffff810e4530>] ? wake_bit_function+0x0/0x70
[ 8603.827327]  [<ffffffff811bc331>] shrink_page_list+0x241/0xcf0
[ 8603.827398]  [<ffffffff810e46ef>] ? finish_wait+0x7f/0xb0
[ 8603.827468]  [<ffffffff810e44d0>] ? autoremove_wake_function+0x0/0x60
[ 8603.827540]  [<ffffffff811bd3bc>] shrink_inactive_list+0x27c/0x4b0
[ 8603.827612]  [<ffffffff811023e0>] ? mark_held_locks+0x90/0xd0
[ 8603.827683]  [<ffffffff811bdea9>] shrink_zone+0x499/0x610
[ 8603.827754]  [<ffffffff811be52b>] do_try_to_free_pages+0x13b/0x540
[ 8603.827825]  [<ffffffff811beb59>] try_to_free_pages+0x99/0x180
[ 8603.827897]  [<ffffffff811b1e50>] __alloc_pages_nodemask+0x6f0/0xb50
[ 8603.827969]  [<ffffffff811f759b>] alloc_pages_current+0xcb/0x160
[ 8603.828041]  [<ffffffff81204b74>] new_slab+0x274/0x3b0
[ 8603.828111]  [<ffffffff8120581f>] __slab_alloc+0x4bf/0x840
[ 8603.828182]  [<ffffffff81578bd4>] ? radix_tree_preload+0x44/0xd0
[ 8603.828253]  [<ffffffff8120665b>] kmem_cache_alloc+0x22b/0x240
[ 8603.828324]  [<ffffffff81578bd4>] ? radix_tree_preload+0x44/0xd0
[ 8603.828396]  [<ffffffff81578bd4>] radix_tree_preload+0x44/0xd0
[ 8603.828467]  [<ffffffff811e94d3>] read_swap_cache_async+0x83/0x1f0
[ 8603.828538]  [<ffffffff811ef20f>] ? valid_swaphandles+0x1cf/0x240
[ 8603.828610]  [<ffffffff811e96eb>] swapin_readahead+0xab/0xf0
[ 8603.828681]  [<ffffffff811a5be0>] ? find_get_page+0x0/0x1c0
[ 8603.828752]  [<ffffffff811d2bdd>] handle_mm_fault+0xabd/0xe70
[ 8603.828822]  [<ffffffff81b88534>] ? do_page_fault+0x144/0x770
[ 8603.828893]  [<ffffffff81b885c9>] do_page_fault+0x1d9/0x770
[ 8603.828964]  [<ffffffff81b83d56>] ? error_sti+0x5/0x6
[ 8603.829033]  [<ffffffff81b82056>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[ 8603.829105]  [<ffffffff81b83b45>] page_fault+0x25/0x30
[ 8603.829175] flush-8:0     S ffff8800b9320000  3296  3971      2 0x00000000
[ 8603.829304]  ffff88008a509d50 0000000000000002 0000000000000002 00000000001d55c0
[ 8603.829522]  ffff8800b9320000 00000000001d55c0 ffff88008a509fd8 ffff88008a509fd8
[ 8603.829740]  00000000001d55c0 ffff8800b9320368 00000000001d55c0 00000000001d55c0
[ 8603.829956] Call Trace:
[ 8603.830022]  [<ffffffff81b7e930>] schedule_timeout+0x230/0x450
[ 8603.830093]  [<ffffffff810cb150>] ? process_timeout+0x0/0x20
[ 8603.830164]  [<ffffffff81b7ebd5>] schedule_timeout_interruptible+0x25/0x30
[ 8603.830236]  [<ffffffff8125361b>] bdi_writeback_thread+0x2ab/0x3e0
[ 8603.830307]  [<ffffffff81253370>] ? bdi_writeback_thread+0x0/0x3e0
[ 8603.830379]  [<ffffffff810e3dad>] kthread+0xcd/0xe0
[ 8603.830449]  [<ffffffff8104e9e4>] kernel_thread_helper+0x4/0x10
[ 8603.830519]  [<ffffffff81b83910>] ? restore_args+0x0/0x30
[ 8603.830590]  [<ffffffff810e3ce0>] ? kthread+0x0/0xe0
[ 8603.830659]  [<ffffffff8104e9e0>] ? kernel_thread_helper+0x0/0x10
[ 8603.830730] shutdown      D 000000010019756c  4120  3972   3860 0x00000000
[ 8603.830859]  ffff880042b5bc48 0000000000000002 0000000000000000 00000000001d55c0
[ 8603.831077]  ffff880042a5c6a0 00000000001d55c0 ffff880042b5bfd8 ffff880042b5bfd8
[ 8603.831295]  00000000001d55c0 ffff880042a5ca08 00000000001d55c0 00000000001d55c0
[ 8603.831512] Call Trace:
[ 8603.831578]  [<ffffffff81b7ea0c>] schedule_timeout+0x30c/0x450
[ 8603.831649]  [<ffffffff811023e0>] ? mark_held_locks+0x90/0xd0
[ 8603.831720]  [<ffffffff81b8342c>] ? _raw_spin_unlock_irq+0x4c/0x70
[ 8603.831792]  [<ffffffff81b7e333>] wait_for_common+0x183/0x220
[ 8603.831863]  [<ffffffff810ac590>] ? default_wake_function+0x0/0x30
[ 8603.831935]  [<ffffffff81b7e524>] wait_for_completion+0x24/0x30
[ 8603.832007]  [<ffffffff81251f6d>] sync_inodes_sb+0x12d/0x2d0
[ 8603.832078]  [<ffffffff81b7e216>] ? wait_for_common+0x66/0x220
[ 8603.832149]  [<ffffffff812585b0>] ? sync_one_sb+0x0/0x40
[ 8603.832220]  [<ffffffff8125857f>] __sync_filesystem+0xcf/0x100
[ 8603.832291]  [<ffffffff812585e5>] sync_one_sb+0x35/0x40
[ 8603.832361]  [<ffffffff812241fb>] iterate_supers+0x8b/0x130
[ 8603.832432]  [<ffffffff81258447>] sync_filesystems+0x27/0x30
[ 8603.832502]  [<ffffffff812586c6>] sys_sync+0x36/0x60
[ 8603.832572]  [<ffffffff8104db72>] system_call_fastpath+0x16/0x1b
[ 8603.832643] su            S 00000001001fbdf1  4456  4049   3202 0x00000000
[ 8603.832774]  ffff880017bf1e78 0000000000000002 0000000000000000 00000000001d55c0
[ 8603.832991]  ffff8800b918a350 00000000001d55c0 ffff880017bf1fd8 ffff880017bf1fd8
[ 8603.833209]  00000000001d55c0 ffff8800b918a6b8 00000000001d55c0 00000000001d55c0
[ 8603.833427] Call Trace:
[ 8603.833494]  [<ffffffff810b9475>] do_wait+0x245/0x340
[ 8603.833564]  [<ffffffff810bb436>] sys_wait4+0x86/0x150
[ 8603.833634]  [<ffffffff810b7860>] ? child_wait_callback+0x0/0xb0
[ 8603.833705]  [<ffffffff8104db72>] system_call_fastpath+0x16/0x1b
[ 8603.833776] zsh           R  running task     4216  4052   4049 0x00000000
[ 8603.833906]  ffff880077ba5858 ffffffff81056c98 0000000000000020 ffff880077ba5898
[ 8603.834124]  ffffc90000663758 000000000000002f ffff880077ba5928 ffffffff817c1a0d
[ 8603.834343]  0000000000000020 00000000b996d800 ffff88000000006e 0000002f810fec5d
[ 8603.834562] Call Trace:
[ 8603.834628]  [<ffffffff81056c98>] ? nommu_map_page+0x58/0xb0
[ 8603.834699]  [<ffffffff817c1a0d>] ? e1000_xmit_frame+0xc6d/0x1030
[ 8603.834772]  [<ffffffff81056c40>] ? nommu_map_page+0x0/0xb0
[ 8603.834843]  [<ffffffff81a6b6a6>] ? netpoll_send_skb+0x356/0x3b0
[ 8603.834915]  [<ffffffff810fec5d>] ? trace_hardirqs_off_caller+0x2d/0x1f0
[ 8603.834988]  [<ffffffff810fee3b>] ? trace_hardirqs_off+0x1b/0x30
[ 8603.835059]  [<ffffffff81a6b6a6>] ? netpoll_send_skb+0x356/0x3b0
[ 8603.835130]  [<ffffffff81b834ed>] ? _raw_spin_unlock_irqrestore+0x9d/0xb0
[ 8603.835203]  [<ffffffff810fec5d>] ? trace_hardirqs_off_caller+0x2d/0x1f0
[ 8603.835276]  [<ffffffff810fee3b>] ? trace_hardirqs_off+0x1b/0x30
[ 8603.835347]  [<ffffffff81b8261b>] ? _raw_spin_lock_irqsave+0x4b/0xf0
[ 8603.835419]  [<ffffffff81b834ed>] ? _raw_spin_unlock_irqrestore+0x9d/0xb0
[ 8603.835491]  [<ffffffff81b834ed>] ? _raw_spin_unlock_irqrestore+0x9d/0xb0
[ 8603.835564]  [<ffffffff810fec5d>] ? trace_hardirqs_off_caller+0x2d/0x1f0
[ 8603.835636]  [<ffffffff810fee3b>] ? trace_hardirqs_off+0x1b/0x30
[ 8603.835707]  [<ffffffff81b834ed>] ? _raw_spin_unlock_irqrestore+0x9d/0xb0
[ 8603.835779]  [<ffffffff810b4e25>] ? release_console_sem+0x2f5/0x390
[ 8603.835851]  [<ffffffff81b8261b>] ? _raw_spin_lock_irqsave+0x4b/0xf0
[ 8603.835922]  [<ffffffff81b834ed>] ? _raw_spin_unlock_irqrestore+0x9d/0xb0
[ 8603.835995]  [<ffffffff81b834ed>] ? _raw_spin_unlock_irqrestore+0x9d/0xb0
[ 8603.836067]  [<ffffffff81b834ed>] ? _raw_spin_unlock_irqrestore+0x9d/0xb0
[ 8603.836139]  [<ffffffff81b7ce94>] ? printk+0x48/0x51
[ 8603.836209]  [<ffffffff81b7ce94>] ? printk+0x48/0x51
[ 8603.836849]  [<ffffffff81116a39>] ? __module_text_address+0x19/0xb0
[ 8603.836920]  [<ffffffff81052c6f>] ? printk_address+0x2f/0x50
[ 8603.836992]  [<ffffffff8111c965>] ? is_module_text_address+0x15/0x30
[ 8603.837063]  [<ffffffff810dfdf7>] ? __kernel_text_address+0x47/0xb0
[ 8603.837135]  [<ffffffff81052b32>] ? print_context_stack+0xc2/0x1d0
[ 8603.837207]  [<ffffffff81051200>] ? dump_trace+0x2d0/0x4d0
[ 8603.837278]  [<ffffffff81052d6a>] show_trace_log_lvl+0x6a/0x90
[ 8603.837349]  [<ffffffff810514c6>] show_stack_log_lvl+0xc6/0x210
[ 8603.837420]  [<ffffffff81052de3>] show_stack+0x23/0x30
[ 8603.837490]  [<ffffffff810aef4c>] sched_show_task+0xec/0x180
[ 8603.837561]  [<ffffffff810af081>] show_state_filter+0xa1/0x120
[ 8603.837632]  [<ffffffff81675dcc>] ? __handle_sysrq+0x3c/0x250
[ 8603.837703]  [<ffffffff816757e7>] sysrq_handle_showstate+0x17/0x20
[ 8603.837775]  [<ffffffff81675f3c>] __handle_sysrq+0x1ac/0x250
[ 8603.837846]  [<ffffffff81675fe0>] ? write_sysrq_trigger+0x0/0x80
[ 8603.837916]  [<ffffffff8167604a>] write_sysrq_trigger+0x6a/0x80
[ 8603.837988]  [<ffffffff81296ebe>] proc_reg_write+0x9e/0x100
[ 8603.838059]  [<ffffffff8121ff94>] vfs_write+0xc4/0x240
[ 8603.838129]  [<ffffffff81220466>] sys_write+0x66/0xb0
[ 8603.838199]  [<ffffffff8104db72>] system_call_fastpath+0x16/0x1b
[ 8603.838270] Sched Debug Version: v0.09, 2.6.35-rc6-mm1+ #1
[ 8603.838339] now at 8628482.555712 msecs
[ 8603.838406]   .jiffies                                 : 4297049416
[ 8603.838477]   .sysctl_sched_latency                    : 24.000000
[ 8603.838546]   .sysctl_sched_min_granularity            : 8.000000
[ 8603.838617]   .sysctl_sched_wakeup_granularity         : 4.000000
[ 8603.838686]   .sysctl_sched_child_runs_first           : 0
[ 8603.838756]   .sysctl_sched_features                   : 15471
[ 8603.838825]   .sysctl_sched_tunable_scaling            : 1 (logaritmic)
[ 8603.838896]
[ 8603.838897] cpu#0, 3200.784 MHz
[ 8603.839023]   .nr_running                    : 0
[ 8603.839090]   .load                          : 0
[ 8603.839158]   .nr_switches                   : 1156603
[ 8603.839227]   .nr_load_updates               : 294710
[ 8603.839295]   .nr_uninterruptible            : 7
[ 8603.839363]   .next_balance                  : 4297.049409
[ 8603.839432]   .curr->pid                     : 0
[ 8603.839499]   .clock                         : 8603803.856528
[ 8603.839569]   .cpu_load[0]                   : 0
[ 8603.839636]   .cpu_load[1]                   : 0
[ 8603.839704]   .cpu_load[2]                   : 0
[ 8603.839772]   .cpu_load[3]                   : 0
[ 8603.839839]   .cpu_load[4]                   : 0
[ 8603.839906]   .yld_count                     : 0
[ 8603.839974]   .sched_switch                  : 0
[ 8603.840041]   .sched_count                   : 1473751
[ 8603.840110]   .sched_goidle                  : 517579
[ 8603.840178]   .avg_idle                      : 1000000
[ 8603.840247]   .ttwu_count                    : 623917
[ 8603.840315]   .ttwu_local                    : 514058
[ 8603.840383]   .bkl_count                     : 56
[ 8603.840451]
[ 8603.840452] cfs_rq[0]:
[ 8603.840577]   .exec_clock                    : 322781.673156
[ 8603.840648]   .MIN_vruntime                  : 0.000001
[ 8603.840718]   .min_vruntime                  : 305286.495000
[ 8603.840788]   .max_vruntime                  : 0.000001
[ 8603.840857]   .spread                        : 0.000000
[ 8603.840925]   .spread0                       : 0.000000
[ 8603.840993]   .nr_running                    : 0
[ 8603.841062]   .load                          : 0
[ 8603.841130]   .nr_spread_over                : 159
[ 8603.841199]
[ 8603.841199] rt_rq[0]:
[ 8603.841325]   .rt_nr_running                 : 0
[ 8603.841393]   .rt_throttled                  : 0
[ 8603.841460]   .rt_time                       : 0.000000
[ 8603.841529]   .rt_runtime                    : 950.000000
[ 8603.841598]
[ 8603.841598] runnable tasks:
[ 8603.841599]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 8603.841600] ----------------------------------------------------------------------------------------------------------
[ 8603.841950]
[ 8603.841950] cpu#1, 3200.784 MHz
[ 8603.842077]   .nr_running                    : 0
[ 8603.842144]   .load                          : 0
[ 8603.842212]   .nr_switches                   : 391795
[ 8603.842280]   .nr_load_updates               : 142602
[ 8603.842348]   .nr_uninterruptible            : 1
[ 8603.842415]   .next_balance                  : 4297.048752
[ 8603.842484]   .curr->pid                     : 0
[ 8603.842552]   .clock                         : 8601183.612562
[ 8603.842621]   .cpu_load[0]                   : 0
[ 8603.842689]   .cpu_load[1]                   : 0
[ 8603.842756]   .cpu_load[2]                   : 0
[ 8603.842824]   .cpu_load[3]                   : 0
[ 8603.842891]   .cpu_load[4]                   : 0
[ 8603.842959]   .yld_count                     : 0
[ 8603.843026]   .sched_switch                  : 0
[ 8603.843094]   .sched_count                   : 396119
[ 8603.843162]   .sched_goidle                  : 169313
[ 8603.843230]   .avg_idle                      : 1000000
[ 8603.843298]   .ttwu_count                    : 208609
[ 8603.843367]   .ttwu_local                    : 69252
[ 8603.843435]   .bkl_count                     : 1
[ 8603.843503]
[ 8603.843503] cfs_rq[1]:
[ 8603.843629]   .exec_clock                    : 245715.789291
[ 8603.843699]   .MIN_vruntime                  : 0.000001
[ 8603.843768]   .min_vruntime                  : 271798.833400
[ 8603.843837]   .max_vruntime                  : 0.000001
[ 8603.843905]   .spread                        : 0.000000
[ 8603.843974]   .spread0                       : -33487.661600
[ 8603.844043]   .nr_running                    : 0
[ 8603.844110]   .load                          : 0
[ 8603.844178]   .nr_spread_over                : 199
[ 8603.844246]
[ 8603.844246] rt_rq[1]:
[ 8603.844372]   .rt_nr_running                 : 0
[ 8603.844440]   .rt_throttled                  : 0
[ 8603.844507]   .rt_time                       : 0.000000
[ 8603.844575]   .rt_runtime                    : 950.000000
[ 8603.844644]
[ 8603.844644] runnable tasks:
[ 8603.844645]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 8603.844646] ----------------------------------------------------------------------------------------------------------
[ 8603.844992]
[ 8603.844992] cpu#2, 3200.784 MHz
[ 8603.845118]   .nr_running                    : 0
[ 8603.845186]   .load                          : 0
[ 8603.845253]   .nr_switches                   : 560256
[ 8603.845322]   .nr_load_updates               : 165111
[ 8603.845390]   .nr_uninterruptible            : 0
[ 8603.845457]   .next_balance                  : 4297.049442
[ 8603.845526]   .curr->pid                     : 0
[ 8603.845593]   .clock                         : 8603812.358700
[ 8603.845663]   .cpu_load[0]                   : 1024
[ 8603.845731]   .cpu_load[1]                   : 512
[ 8603.845799]   .cpu_load[2]                   : 256
[ 8603.845866]   .cpu_load[3]                   : 128
[ 8603.845934]   .cpu_load[4]                   : 64
[ 8603.846002]   .yld_count                     : 0
[ 8603.846070]   .sched_switch                  : 0
[ 8603.846137]   .sched_count                   : 780384
[ 8603.846206]   .sched_goidle                  : 266659
[ 8603.846274]   .avg_idle                      : 1000000
[ 8603.846341]   .ttwu_count                    : 285780
[ 8603.846409]   .ttwu_local                    : 258161
[ 8603.846478]   .bkl_count                     : 20
[ 8603.846546]
[ 8603.846547] cfs_rq[2]:
[ 8603.846673]   .exec_clock                    : 280267.553066
[ 8603.846743]   .MIN_vruntime                  : 0.000001
[ 8603.846811]   .min_vruntime                  : 294921.089281
[ 8603.846880]   .max_vruntime                  : 0.000001
[ 8603.846949]   .spread                        : 0.000000
[ 8603.847018]   .spread0                       : -10365.405719
[ 8603.847087]   .nr_running                    : 0
[ 8603.847155]   .load                          : 0
[ 8603.847222]   .nr_spread_over                : 2
[ 8603.847290]
[ 8603.847290] rt_rq[2]:
[ 8603.847416]   .rt_nr_running                 : 0
[ 8603.847483]   .rt_throttled                  : 0
[ 8603.847551]   .rt_time                       : 0.000000
[ 8603.847620]   .rt_runtime                    : 950.000000
[ 8603.847690]
[ 8603.847690] runnable tasks:
[ 8603.847691]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 8603.847692] ----------------------------------------------------------------------------------------------------------
[ 8603.848039]
[ 8603.848040] cpu#3, 3200.784 MHz
[ 8603.848167]   .nr_running                    : 0
[ 8603.848234]   .load                          : 0
[ 8603.848302]   .nr_switches                   : 229642
[ 8603.848370]   .nr_load_updates               : 115984
[ 8603.848438]   .nr_uninterruptible            : 0
[ 8603.848507]   .next_balance                  : 4297.049306
[ 8603.848576]   .curr->pid                     : 0
[ 8603.848643]   .clock                         : 8603812.390353
[ 8603.848712]   .cpu_load[0]                   : 1024
[ 8603.848780]   .cpu_load[1]                   : 512
[ 8603.848848]   .cpu_load[2]                   : 256
[ 8603.849487]   .cpu_load[3]                   : 128
[ 8603.849555]   .cpu_load[4]                   : 68
[ 8603.849624]   .yld_count                     : 0
[ 8603.849692]   .sched_switch                  : 0
[ 8603.849759]   .sched_count                   : 234049
[ 8603.849827]   .sched_goidle                  : 94559
[ 8603.849895]   .avg_idle                      : 1000000
[ 8603.849964]   .ttwu_count                    : 120423
[ 8603.850032]   .ttwu_local                    : 49148
[ 8603.850100]   .bkl_count                     : 1
[ 8603.850168]
[ 8603.850168] cfs_rq[3]:
[ 8603.850294]   .exec_clock                    : 169922.393756
[ 8603.850363]   .MIN_vruntime                  : 0.000001
[ 8603.850432]   .min_vruntime                  : 220358.984921
[ 8603.850501]   .max_vruntime                  : 0.000001
[ 8603.850570]   .spread                        : 0.000000
[ 8603.850639]   .spread0                       : -84927.510079
[ 8603.850708]   .nr_running                    : 0
[ 8603.850775]   .load                          : 0
[ 8603.850870]   .nr_spread_over                : 55
[ 8603.850939]
[ 8603.850939] rt_rq[3]:
[ 8603.851065]   .rt_nr_running                 : 0
[ 8603.851133]   .rt_throttled                  : 0
[ 8603.851201]   .rt_time                       : 0.000000
[ 8603.851269]   .rt_runtime                    : 950.000000
[ 8603.851338]
[ 8603.851339] runnable tasks:
[ 8603.851339]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 8603.851340] ----------------------------------------------------------------------------------------------------------
[ 8603.851686]
[ 8603.851686] cpu#4, 3200.784 MHz
[ 8603.851813]   .nr_running                    : 1
[ 8603.851880]   .load                          : 1024
[ 8603.851948]   .nr_switches                   : 269553
[ 8603.852016]   .nr_load_updates               : 155276
[ 8603.852084]   .nr_uninterruptible            : 4
[ 8603.852152]   .next_balance                  : 4297.049127
[ 8603.852220]   .curr->pid                     : 4052
[ 8603.852289]   .clock                         : 8603554.183086
[ 8603.852358]   .cpu_load[0]                   : 0
[ 8603.852425]   .cpu_load[1]                   : 0
[ 8603.852493]   .cpu_load[2]                   : 0
[ 8603.852560]   .cpu_load[3]                   : 0
[ 8603.852628]   .cpu_load[4]                   : 0
[ 8603.852695]   .yld_count                     : 0
[ 8603.852763]   .sched_switch                  : 0
[ 8603.852830]   .sched_count                   : 274122
[ 8603.852898]   .sched_goidle                  : 107904
[ 8603.852967]   .avg_idle                      : 906404
[ 8603.853036]   .ttwu_count                    : 144344
[ 8603.853104]   .ttwu_local                    : 77278
[ 8603.853173]   .bkl_count                     : 8
[ 8603.853241]
[ 8603.853241] cfs_rq[4]:
[ 8603.853367]   .exec_clock                    : 159892.509962
[ 8603.853437]   .MIN_vruntime                  : 0.000001
[ 8603.853505]   .min_vruntime                  : 181519.598867
[ 8603.853575]   .max_vruntime                  : 0.000001
[ 8603.853644]   .spread                        : 0.000000
[ 8603.853713]   .spread0                       : -123766.896133
[ 8603.853782]   .nr_running                    : 1
[ 8603.853849]   .load                          : 1024
[ 8603.853917]   .nr_spread_over                : 14
[ 8603.853986]
[ 8603.853986] rt_rq[4]:
[ 8603.854113]   .rt_nr_running                 : 0
[ 8603.854184]   .rt_throttled                  : 0
[ 8603.854255]   .rt_time                       : 0.000000
[ 8603.854324]   .rt_runtime                    : 950.000000
[ 8603.854393]
[ 8603.854394] runnable tasks:
[ 8603.854394]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 8603.854395] ----------------------------------------------------------------------------------------------------------
[ 8603.854741] R            zsh  4052    181519.598867       244   120    181519.598867       136.870513      6324.549747
[ 8603.854938]
[ 8603.854939] cpu#5, 3200.784 MHz
[ 8603.855066]   .nr_running                    : 0
[ 8603.855133]   .load                          : 0
[ 8603.855201]   .nr_switches                   : 185920
[ 8603.855269]   .nr_load_updates               : 122336
[ 8603.855337]   .nr_uninterruptible            : 0
[ 8603.855404]   .next_balance                  : 4297.049252
[ 8603.855473]   .curr->pid                     : 0
[ 8603.855541]   .clock                         : 8603177.836247
[ 8603.855610]   .cpu_load[0]                   : 0
[ 8603.855678]   .cpu_load[1]                   : 0
[ 8603.855745]   .cpu_load[2]                   : 0
[ 8603.855812]   .cpu_load[3]                   : 0
[ 8603.855880]   .cpu_load[4]                   : 0
[ 8603.855947]   .yld_count                     : 1
[ 8603.856015]   .sched_switch                  : 0
[ 8603.856082]   .sched_count                   : 190458
[ 8603.856150]   .sched_goidle                  : 78018
[ 8603.856218]   .avg_idle                      : 1000000
[ 8603.856286]   .ttwu_count                    : 94704
[ 8603.856353]   .ttwu_local                    : 55316
[ 8603.856422]   .bkl_count                     : 3
[ 8603.856491]
[ 8603.856491] cfs_rq[5]:
[ 8603.856618]   .exec_clock                    : 108412.314731
[ 8603.856688]   .MIN_vruntime                  : 0.000001
[ 8603.856757]   .min_vruntime                  : 163961.230573
[ 8603.856826]   .max_vruntime                  : 0.000001
[ 8603.856895]   .spread                        : 0.000000
[ 8603.856964]   .spread0                       : -141325.264427
[ 8603.857033]   .nr_running                    : 0
[ 8603.857101]   .load                          : 0
[ 8603.857169]   .nr_spread_over                : 6
[ 8603.857236]
[ 8603.857237] rt_rq[5]:
[ 8603.857362]   .rt_nr_running                 : 0
[ 8603.857430]   .rt_throttled                  : 0
[ 8603.857497]   .rt_time                       : 0.000000
[ 8603.857566]   .rt_runtime                    : 950.000000
[ 8603.857634]
[ 8603.857635] runnable tasks:
[ 8603.857635]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 8603.857636] ----------------------------------------------------------------------------------------------------------
[ 8603.857983]
[ 8603.857983] cpu#6, 3200.784 MHz
[ 8603.858110]   .nr_running                    : 0
[ 8603.858177]   .load                          : 0
[ 8603.858244]   .nr_switches                   : 276975
[ 8603.858312]   .nr_load_updates               : 155233
[ 8603.858380]   .nr_uninterruptible            : 1
[ 8603.858447]   .next_balance                  : 4297.049377
[ 8603.858516]   .curr->pid                     : 0
[ 8603.858584]   .clock                         : 8603676.300923
[ 8603.858653]   .cpu_load[0]                   : 0
[ 8603.858721]   .cpu_load[1]                   : 0
[ 8603.858788]   .cpu_load[2]                   : 0
[ 8603.858855]   .cpu_load[3]                   : 0
[ 8603.858922]   .cpu_load[4]                   : 0
[ 8603.858989]   .yld_count                     : 0
[ 8603.859056]   .sched_switch                  : 0
[ 8603.859124]   .sched_count                   : 13643133
[ 8603.859192]   .sched_goidle                  : 109193
[ 8603.859260]   .avg_idle                      : 1000000
[ 8603.859328]   .ttwu_count                    : 142634
[ 8603.859396]   .ttwu_local                    : 60067
[ 8603.859464]   .bkl_count                     : 6
[ 8603.859532]
[ 8603.859532] cfs_rq[6]:
[ 8603.859658]   .exec_clock                    : 273546.895137
[ 8603.859728]   .MIN_vruntime                  : 0.000001
[ 8603.859797]   .min_vruntime                  : 314787.690335
[ 8603.859866]   .max_vruntime                  : 0.000001
[ 8603.859934]   .spread                        : 0.000000
[ 8603.860004]   .spread0                       : 9501.195335
[ 8603.860072]   .nr_running                    : 0
[ 8603.860141]   .load                          : 0
[ 8603.860209]   .nr_spread_over                : 85
[ 8603.860277]
[ 8603.860277] rt_rq[6]:
[ 8603.860402]   .rt_nr_running                 : 0
[ 8603.860469]   .rt_throttled                  : 0
[ 8603.860537]   .rt_time                       : 0.000000
[ 8603.860606]   .rt_runtime                    : 950.000000
[ 8603.860675]
[ 8603.860676] runnable tasks:
[ 8603.860676]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 8603.860677] ----------------------------------------------------------------------------------------------------------
[ 8603.861024]
[ 8603.861024] cpu#7, 3200.784 MHz
[ 8603.861151]   .nr_running                    : 0
[ 8603.861218]   .load                          : 0
[ 8603.861286]   .nr_switches                   : 134607
[ 8603.861354]   .nr_load_updates               : 108783
[ 8603.861423]   .nr_uninterruptible            : 1
[ 8603.862060]   .next_balance                  : 4297.048502
[ 8603.862128]   .curr->pid                     : 0
[ 8603.862196]   .clock                         : 8600186.437864
[ 8603.862265]   .cpu_load[0]                   : 0
[ 8603.862332]   .cpu_load[1]                   : 0
[ 8603.862399]   .cpu_load[2]                   : 0
[ 8603.862467]   .cpu_load[3]                   : 0
[ 8603.862533]   .cpu_load[4]                   : 0
[ 8603.862601]   .yld_count                     : 0
[ 8603.862668]   .sched_switch                  : 0
[ 8603.862735]   .sched_count                   : 138870
[ 8603.862803]   .sched_goidle                  : 55637
[ 8603.862871]   .avg_idle                      : 1000000
[ 8603.862939]   .ttwu_count                    : 69313
[ 8603.863007]   .ttwu_local                    : 36525
[ 8603.863075]   .bkl_count                     : 1
[ 8603.863143]
[ 8603.863144] cfs_rq[7]:
[ 8603.863269]   .exec_clock                    : 88588.952951
[ 8603.863339]   .MIN_vruntime                  : 0.000001
[ 8603.863408]   .min_vruntime                  : 128455.709256
[ 8603.863477]   .max_vruntime                  : 0.000001
[ 8603.863545]   .spread                        : 0.000000
[ 8603.863614]   .spread0                       : -176830.785744
[ 8603.863683]   .nr_running                    : 0
[ 8603.863751]   .load                          : 0
[ 8603.863819]   .nr_spread_over                : 3
[ 8603.863887]
[ 8603.863887] rt_rq[7]:
[ 8603.864013]   .rt_nr_running                 : 0
[ 8603.864080]   .rt_throttled                  : 0
[ 8603.864148]   .rt_time                       : 0.000000
[ 8603.864217]   .rt_runtime                    : 950.000000
[ 8603.864286]
[ 8603.864287] runnable tasks:
[ 8603.864287]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 8603.864288] ----------------------------------------------------------------------------------------------------------
[ 8603.864635]
[ 8603.864698]
[ 8603.864699] Showing all locks held in the system:
[ 8603.864831] 1 lock held by getty/3094:
[ 8603.864898]  #0:  (&tty->atomic_read_lock){+.+.+.}, at: [<ffffffff81657b70>] n_tty_read+0x7e0/0xca0
[ 8603.865121] 1 lock held by getty/3095:
[ 8603.865187]  #0:  (&tty->atomic_read_lock){+.+.+.}, at: [<ffffffff81657b70>] n_tty_read+0x7e0/0xca0
[ 8603.865409] 1 lock held by getty/3096:
[ 8603.865475]  #0:  (&tty->atomic_read_lock){+.+.+.}, at: [<ffffffff81657b70>] n_tty_read+0x7e0/0xca0
[ 8603.865696] 1 lock held by getty/3097:
[ 8603.865762]  #0:  (&tty->atomic_read_lock){+.+.+.}, at: [<ffffffff81657b70>] n_tty_read+0x7e0/0xca0
[ 8603.865982] 1 lock held by getty/3098:
[ 8603.866048]  #0:  (&tty->atomic_read_lock){+.+.+.}, at: [<ffffffff81657b70>] n_tty_read+0x7e0/0xca0
[ 8603.866269] 1 lock held by getty/3099:
[ 8603.866335]  #0:  (&tty->atomic_read_lock){+.+.+.}, at: [<ffffffff81657b70>] n_tty_read+0x7e0/0xca0
[ 8603.866556] 1 lock held by usemem/3920:
[ 8603.866623]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff81b88534>] do_page_fault+0x144/0x770
[ 8603.866845] 1 lock held by usemem/3921:
[ 8603.866911]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff81b88534>] do_page_fault+0x144/0x770
[ 8603.867132] 1 lock held by usemem/3922:
[ 8603.867198]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff81b88534>] do_page_fault+0x144/0x770
[ 8603.867419] 1 lock held by usemem/3923:
[ 8603.867485]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff81b88534>] do_page_fault+0x144/0x770
[ 8603.867705] 1 lock held by usemem/3924:
[ 8603.867772]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff81b88534>] do_page_fault+0x144/0x770
[ 8603.867992] 1 lock held by usemem/3925:
[ 8603.868059]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff81b88534>] do_page_fault+0x144/0x770
[ 8603.868278] 1 lock held by usemem/3926:
[ 8603.868345]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff81b88534>] do_page_fault+0x144/0x770
[ 8603.868565] 1 lock held by usemem/3927:
[ 8603.868631]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff81b88534>] do_page_fault+0x144/0x770
[ 8603.868852] 1 lock held by shutdown/3972:
[ 8603.868918]  #0:  (&type->s_umount_key#41){.+.+..}, at: [<ffffffff812241dd>] iterate_supers+0x6d/0x130
[ 8603.869168] 2 locks held by zsh/4052:
[ 8603.869234]  #0:  (sysrq_key_table_lock){......}, at: [<ffffffff81675dcc>] __handle_sysrq+0x3c/0x250
[ 8603.869454]  #1:  (tasklist_lock){.+.+..}, at: [<ffffffff810ffa3c>] debug_show_all_locks+0x4c/0x280
[ 8603.869676]
[ 8603.869739] =============================================
[ 8603.869740]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
