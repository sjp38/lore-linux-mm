Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 9F3236B004D
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 05:24:53 -0500 (EST)
Date: Wed, 21 Dec 2011 11:24:49 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Kswapd in 3.2.0-rc5 is a CPU hog
Message-ID: <20111221102449.GE27137@tiehlicka.suse.cz>
References: <1324437036.4677.5.camel@hakkenden.homenet>
 <20111221095249.GA28474@tiehlicka.suse.cz>
 <1324462521.17322.12.camel@rybalov.eng.ttk.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1324462521.17322.12.camel@rybalov.eng.ttk.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nowhere <nowhere@hakkenden.ath.cx>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, xfs@oss.sgi.com, Ben Myers <bpm@sgi.com>, Alex Elder <elder@kernel.org>

[Let's cc also some fs and xfs people]

On Wed 21-12-11 14:15:21, nowhere wrote:
> D? D!N?., 21/12/2011 D2 10:52 +0100, Michal Hocko D?D,N?DuN?:
> > [Let's CC linux-mm]
> > 
> > On Wed 21-12-11 07:10:36, Nikolay S. wrote:
> > > Hello,
> > > 
> > > I'm using 3.2-rc5 on a machine, which atm does almost nothing except
> > > file system operations and network i/o (i.e. file server). And there is
> > > a problem with kswapd.
> > 
> > What kind of filesystem do you use?
> 
> Well, that is XFS.
> I have a large volume with ~200000 files, and a periodic job, which
> checks all file's timestamps once per 30 minutes and makes actions if
> timestamp has changed.

Is it the first time you are seeing this? I am not familiar with xfs at
all but the number of files sounds like dcache shrinker might be really
busy...

> > > I'm playing with dd:
> > > dd if=/some/big/file of=/dev/null bs=8M
> > > 
> > > I.e. I'm filling page cache.
> > > 
> > > So when the machine is just rebooted, kswapd during this operation is
> > > almost idle, just 5-8 percent according to top.
> > > 
> > > After ~5 days of uptime (5 days,  2:10), the same operation demands ~70%
> > > for kswapd:
> > > 
> > >   PID USER      S %CPU %MEM    TIME+  SWAP COMMAND
> > >   420 root      R   70  0.0  22:09.60    0 kswapd0
> > > 17717 nowhere   D   27  0.2   0:01.81  10m dd
> > > 
> > > In fact, kswapd cpu usage on this operation steadily increases over
> > > time.
> > > 
> > > Also read performance degrades over time. After reboot:
> > > dd if=/some/big/file of=/dev/null bs=8M
> > > 1019+1 records in
> > > 1019+1 records out
> > > 8553494018 bytes (8.6 GB) copied, 16.211 s, 528 MB/s
> > > 
> > > After ~5 days uptime:
> > > dd if=/some/big/file of=/dev/null bs=8M
> > > 1019+1 records in
> > > 1019+1 records out
> > > 8553494018 bytes (8.6 GB) copied, 29.0507 s, 294 MB/s
> > > 
> > > Whereas raw disk sequential read performance stays the same:
> > > dd if=/some/big/file of=/dev/null bs=8M iflag=direct
> > > 1019+1 records in
> > > 1019+1 records out
> > > 8553494018 bytes (8.6 GB) copied, 14.7286 s, 581 MB/s
> > > 
> > > Also after dropping caches, situation somehow improves, but not to the
> > > state of freshly restarted system:
> > >   PID USER      S %CPU %MEM    TIME+  SWAP COMMAND
> > >   420 root      S   39  0.0  23:31.17    0 kswapd0
> > > 19829 nowhere   D   24  0.2   0:02.72 7764 dd
> > > 
> > > perf shows:
> > > 
> > >     31.24%  kswapd0  [kernel.kallsyms]  [k] _raw_spin_lock
> > >     26.19%  kswapd0  [kernel.kallsyms]  [k] shrink_slab
> > >     16.28%  kswapd0  [kernel.kallsyms]  [k] prune_super
> > >      6.55%  kswapd0  [kernel.kallsyms]  [k] grab_super_passive
> > >      5.35%  kswapd0  [kernel.kallsyms]  [k] down_read_trylock
> > >      4.03%  kswapd0  [kernel.kallsyms]  [k] up_read
> > >      2.31%  kswapd0  [kernel.kallsyms]  [k] put_super
> > >      1.81%  kswapd0  [kernel.kallsyms]  [k] drop_super
> > >      0.99%  kswapd0  [kernel.kallsyms]  [k] __put_super
> > >      0.25%  kswapd0  [kernel.kallsyms]  [k] __isolate_lru_page
> > >      0.23%  kswapd0  [kernel.kallsyms]  [k] free_pcppages_bulk
> > >      0.19%  kswapd0  [r8169]            [k] rtl8169_interrupt
> > >      0.15%  kswapd0  [kernel.kallsyms]  [k] twa_interrupt
> > 
> > Quite a lot of time spent shrinking slab (dcache I guess) and a lot of
> > spin lock contention.
> 
> This is slabinfo, sorted by num objects:
> 
> xfs_inode         192941 193205    960   17    4 : tunables    0    0    0 : slabdata  11365  11365      0
> dentry            118818 118818    192   21    1 : tunables    0    0    0 : slabdata   5658   5658      0
> kmalloc-256       107920 107920    256   16    1 : tunables    0    0    0 : slabdata   6745   6745      0
> kmalloc-64         59912 102656     64   64    1 : tunables    0    0    0 : slabdata   1604   1604      0
> radix_tree_node    30618  33474    568   14    2 : tunables    0    0    0 : slabdata   2391   2391      0
> kmalloc-96         27092  41202     96   42    1 : tunables    0    0    0 : slabdata    981    981      0
> buffer_head        24892  63843    104   39    1 : tunables    0    0    0 : slabdata   1637   1637      0
> kmalloc-192        23332  34503    192   21    1 : tunables    0    0    0 : slabdata   1643   1643      0
> sysfs_dir_cache    17444  17444    144   28    1 : tunables    0    0    0 : slabdata    623    623      0
> arp_cache          12863  14796    320   12    1 : tunables    0    0    0 : slabdata   1233   1233      0
> kmalloc-512        11051  11440    512   16    2 : tunables    0    0    0 : slabdata    715    715      0
> kmalloc-128        10611  13152    128   32    1 : tunables    0    0    0 : slabdata    411    411      0
> ext4_inode_cache    9660  18018    880   18    4 : tunables    0    0    0 : slabdata   1001   1001      0
> kmalloc-8           8704   8704      8  512    1 : tunables    0    0    0 : slabdata     17     17      0
> ext4_io_page        6912   6912     16  256    1 : tunables    0    0    0 : slabdata     27     27      0
> anon_vma_chain      6701  10880     48   85    1 : tunables    0    0    0 : slabdata    128    128      0
> Acpi-Namespace      6611   8058     40  102    1 : tunables    0    0    0 : slabdata     79     79      0
> fsnotify_event_holder   6290   6970     24  170    1 : tunables    0    0    0 : slabdata     41     41      0
> kmalloc-1024        5813   5888   1024   16    4 : tunables    0    0    0 : slabdata    368    368      0
> vm_area_struct      5664   5664    168   24    1 : tunables    0    0    0 : slabdata    236    236      0
> reiser_inode_cache   3992   5198    704   23    4 : tunables    0    0    0 : slabdata    226    226      0
> Acpi-ParseExt       3808   3808     72   56    1 : tunables    0    0    0 : slabdata     68     68      0
> kmalloc-2048        3587   3888   2048   16    8 : tunables    0    0    0 : slabdata    243    243      0
> proc_inode_cache    3498   3510    624   13    2 : tunables    0    0    0 : slabdata    270    270      0
> anon_vma            3380   3640     72   56    1 : tunables    0    0    0 : slabdata     65     65      0
> kmalloc-16          3072   3072     16  256    1 : tunables    0    0    0 : slabdata     12     12      0
> inode_cache         3024   3024    560   14    2 : tunables    0    0    0 : slabdata    216    216      0
> ext4_allocation_context   3000   3000    136   30    1 : tunables    0    0    0 : slabdata    100    100      0
> nf_conntrack_ffffffff81776d40   2910   3549    312   13    1 : tunables    0    0    0 : slabdata    273    273      0
> kmalloc-4096        2792   3136   4096    8    8 : tunables    0    0    0 : slabdata    392    392      0
> ext4_free_data      2701   2701     56   73    1 : tunables    0    0    0 : slabdata     37     37      0
> pid_namespace       2130   2130   2112   15    8 : tunables    0    0    0 : slabdata    142    142      0
> mqueue_inode_cache   2124   2124    896   18    4 : tunables    0    0    0 : slabdata    118    118      0
> jbd2_revoke_record   1664   1664     32  128    1 : tunables    0    0    0 : slabdata     13     13      0
> kmalloc-32          1434   3072     32  128    1 : tunables    0    0    0 : slabdata     24     24      0
> shmem_inode_cache   1400   1521    624   13    2 : tunables    0    0    0 : slabdata    117    117      0
> xfs_ili             1139   1260    216   18    1 : tunables    0    0    0 : slabdata     70     70      0
> nfsd4_stateids      1131   1496    120   34    1 : tunables    0    0    0 : slabdata     44     44      0
> idr_layer_cache      900    900    544   15    2 : tunables    0    0    0 : slabdata     60     60      0
> jbd2_journal_head    742   1008    112   36    1 : tunables    0    0    0 : slabdata     28     28      0
> fsnotify_event       648    648    112   36    1 : tunables    0    0    0 : slabdata     18     18      0
> sock_inode_cache     577    624    640   12    2 : tunables    0    0    0 : slabdata     52     52      0
> tw_sock_TCP          504    504    192   21    1 : tunables    0    0    0 : slabdata     24     24      0
> TCP                  356    414   1728   18    8 : tunables    0    0    0 : slabdata     23     23      0
> RAW                  342    342    832   19    4 : tunables    0    0    0 : slabdata     18     18      0
> jbd2_journal_handle    340    340     24  170    1 : tunables    0    0    0 : slabdata      2      2      0
> blkdev_requests      322    322    344   23    2 : tunables    0    0    0 : slabdata     14     14      0
> task_struct          293    357   1504   21    8 : tunables    0    0    0 : slabdata     17     17      0
> UDP                  285    285    832   19    4 : tunables    0    0    0 : slabdata     15     15      0
> files_cache          276    276    704   23    4 : tunables    0    0    0 : slabdata     12     12      0
> nfsd4_openowners     220    320    392   20    2 : tunables    0    0    0 : slabdata     16     16      0
> mm_struct            216    216    896   18    4 : tunables    0    0    0 : slabdata     12     12      0
> sighand_cache        199    225   2112   15    8 : tunables    0    0    0 : slabdata     15     15      0
> nfsd4_delegations    198    198    368   22    2 : tunables    0    0    0 : slabdata      9      9      0
> kmem_cache_node      192    192     64   64    1 : tunables    0    0    0 : slabdata      3      3      0
> xfs_buf_item         162    162    224   18    1 : tunables    0    0    0 : slabdata      9      9      0
> ip_fib_trie          146    146     56   73    1 : tunables    0    0    0 : slabdata      2      2      0
> ext4_io_end          140    154   1128   14    4 : tunables    0    0    0 : slabdata     11     11      0
> dnotify_mark         120    120    136   30    1 : tunables    0    0    0 : slabdata      4      4      0
> TCPv6                104    119   1856   17    8 : tunables    0    0    0 : slabdata      7      7      0
> cfq_queue            102    102    232   17    1 : tunables    0    0    0 : slabdata      6      6      0
> Acpi-State           102    102     80   51    1 : tunables    0    0    0 : slabdata      2      2      0
> sigqueue             100    100    160   25    1 : tunables    0    0    0 : slabdata      4      4      0
> xfs_efd_item          80     80    400   20    2 : tunables    0    0    0 : slabdata      4      4      0
> tw_sock_TCPv6         64    144    256   16    1 : tunables    0    0    0 : slabdata      9      9      0
> bdev_cache            57     57    832   19    4 : tunables    0    0    0 : slabdata      3      3      0
> blkdev_queue          54     54   1744   18    8 : tunables    0    0    0 : slabdata      3      3      0
> net_namespace         52     52   2432   13    8 : tunables    0    0    0 : slabdata      4      4      0
> kmalloc-8192          52     52   8192    4    8 : tunables    0    0    0 : slabdata     13     13      0
> kmem_cache            42     42    192   21    1 : tunables    0    0    0 : slabdata      2      2      0
> xfs_log_ticket        40     40    200   20    1 : tunables    0    0    0 : slabdata      2      2      0
> xfs_btree_cur         38     38    208   19    1 : tunables    0    0    0 : slabdata      2      2      0
> rpc_inode_cache       38     38    832   19    4 : tunables    0    0    0 : slabdata      2      2      0
> nf_conntrack_expect     34     34    240   17    1 : tunables    0    0    0 : slabdata      2      2      0
> xfs_da_state          32     32    488   16    2 : tunables    0    0    0 : slabdata      2      2      0
> UDPv6                 32     32   1024   16    4 : tunables    0    0    0 : slabdata      2      2      0
> xfs_trans             28     28    280   14    1 : tunables    0    0    0 : slabdata      2      2      0
> taskstats             24     24    328   12    1 : tunables    0    0    0 : slabdata      2      2      0
> dio                   24     24    640   12    2 : tunables    0    0    0 : slabdata      2      2      0
> posix_timers_cache     23     23    176   23    1 : tunables    0    0    0 : slabdata      1      1      0
> hugetlbfs_inode_cache     14     14    560   14    2 : tunables    0    0    0 : slabdata      1      1      0
> xfrm_dst_cache         0      0    384   21    2 : tunables    0    0    0 : slabdata      0      0      0
> user_namespace         0      0   1072   15    4 : tunables    0    0    0 : slabdata      0      0      0
> UDPLITEv6              0      0   1024   16    4 : tunables    0    0    0 : slabdata      0      0      0
> UDP-Lite               0      0    832   19    4 : tunables    0    0    0 : slabdata      0      0      0
> kcopyd_job             0      0   3240   10    8 : tunables    0    0    0 : slabdata      0      0      0
> flow_cache             0      0    104   39    1 : tunables    0    0    0 : slabdata      0      0      0
> ext2_xattr             0      0     88   46    1 : tunables    0    0    0 : slabdata      0      0      0
> ext2_inode_cache       0      0    752   21    4 : tunables    0    0    0 : slabdata      0      0      0
> dquot                  0      0    256   16    1 : tunables    0    0    0 : slabdata      0      0      0
> dm_uevent              0      0   2608   12    8 : tunables    0    0    0 : slabdata      0      0      0
> dma-kmalloc-96         0      0     96   42    1 : tunables    0    0    0 : slabdata      0      0      0
> dma-kmalloc-8192       0      0   8192    4    8 : tunables    0    0    0 : slabdata      0      0      0
> dma-kmalloc-8          0      0      8  512    1 : tunables    0    0    0 : slabdata      0      0      0
> dma-kmalloc-64         0      0     64   64    1 : tunables    0    0    0 : slabdata      0      0      0
> dma-kmalloc-512        0      0    512   16    2 : tunables    0    0    0 : slabdata      0      0      0
> dma-kmalloc-4096       0      0   4096    8    8 : tunables    0    0    0 : slabdata      0      0      0
> dma-kmalloc-32         0      0     32  128    1 : tunables    0    0    0 : slabdata      0      0      0
> dma-kmalloc-256        0      0    256   16    1 : tunables    0    0    0 : slabdata      0      0      0
> dma-kmalloc-2048       0      0   2048   16    8 : tunables    0    0    0 : slabdata      0      0      0
> dma-kmalloc-192        0      0    192   21    1 : tunables    0    0    0 : slabdata      0      0      0
> dma-kmalloc-16         0      0     16  256    1 : tunables    0    0    0 : slabdata      0      0      0
> dma-kmalloc-128        0      0    128   32    1 : tunables    0    0    0 : slabdata      0      0      0
> dma-kmalloc-1024       0      0   1024   16    4 : tunables    0    0    0 : slabdata      0      0      0
> bsg_cmd                0      0    312   13    1 : tunables    0    0    0 : slabdata      0      0      0
> 
> > Could you also take few snapshots of /proc/420/stack to see what kswapd
> > is doing.
> 
> Uhm, there is no such entry in proc. Guess I need to enable some kernel
> option and recompile?

Yes, you need CONFIG_STACKTRACE. But you can get a similar information
by sysrq+t

> This will reset uptime and a problem for another 5-10 days..

Then don't do that ;)

> > > P.S.: The message above was written couple of days ago. Now I'm at 10
> > > days uptime, and this is the result as of today
> > >   PID USER      S %CPU %MEM    TIME+  SWAP COMMAND
> > >   420 root      R   93  0.0 110:48.48    0 kswapd0
> > > 30085 nowhere   D   42  0.2   0:04.36  10m dd
> > > 
> > > PPS: Please CC me.

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
