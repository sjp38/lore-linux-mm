Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id B81D76B005C
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 11:22:10 -0400 (EDT)
Date: Thu, 28 Jun 2012 17:22:08 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: memory leak in recent (3.x) kernels?
Message-ID: <20120628152208.GA16222@tiehlicka.suse.cz>
References: <20120622112614.GA17413@msgid.wurtel.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120622112614.GA17413@msgid.wurtel.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Slootman <paul@wurtel.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 22-06-12 13:26:14, Paul Slootman wrote:
> Perhaps I'm triggering something that exists since before 3.0, but
> anyway:
> 
> After some time, all swap space gets gradually used up, without a clear
> indication what's using it (at least, I haven't managed to find out).
> 
> System is running debian testing, and most usage is a lot of rxvt
> processes mostly ssh'ed out to other systems, and google chrome.
> I suspect google chrome may be the cause of the problem.
> Root is btrfs, /home is NFS.
> 
> The system earlier had 4GB RAM and swap is currently 5 x 2GB LVM
> partitions. With that config I needed to reboot after about a week, as
> the system ended up thrashing the swap.  I've added 8GB RAM, and now the
> uptime is 42 days, system still usable.
> 
> Stopping google-chrome at such a point in time usually does not help.
> 
> At every reboot I upgrade to the latest kernel :) Currently running
> 3.4.0-rc6, but I saw the same behaviour with all 3.x kernels I tried.
> 
> Situation now is:
> 
> # free
>              total       used       free     shared    buffers     cached
> Mem:      12179368   11600220     579148          0         12    9313200
> -/+ buffers/cache:    2287008    9892360
> Swap:      6291444    6238388      53056
> 
> Swap is now 6GB, as I did a swapoff of 2 swap partitions.
> Doing a swapoff of any of the remaining 3 partitions immediately gives:
> swapoff failed: Cannot allocate memory
> 
> I would have thought that with almost 10GB memory free (w/o cache) such
> a swapoff should succeed.  I also wonder why that 9GB cached memory is
> being held; it's not released after echo 3 > drop_caches .

Because the most of the memory is anonymous and shmem.
ipcs -pm should tell you about the current segments and pids behind.
[...]
> /proc/meminfo
> ----------------------------------------------------------------
> MemTotal:       12179368 kB
> MemFree:          620712 kB
> Buffers:              20 kB
> Cached:          9264392 kB
> SwapCached:        23644 kB
> Active:          1996988 kB
> Inactive:        9319588 kB
> Active(anon):    1919880 kB
> Inactive(anon):  9313300 kB
> Active(file):      77108 kB
> Inactive(file):     6288 kB
> Unevictable:           0 kB
> Mlocked:               0 kB
> SwapTotal:       6291444 kB
> SwapFree:          53056 kB
> Dirty:               368 kB
> Writeback:             0 kB
> AnonPages:       2028736 kB
> Mapped:            79584 kB
> Shmem:           9181016 kB	<<<
> Slab:             101360 kB
> SReclaimable:      66488 kB
> SUnreclaim:        34872 kB
> KernelStack:        4336 kB
> PageTables:        49176 kB
> NFS_Unstable:          0 kB
> Bounce:                0 kB
> WritebackTmp:          0 kB
> CommitLimit:    12381128 kB
> Committed_AS:   20465716 kB
> VmallocTotal:   34359738367 kB
> VmallocUsed:      345912 kB
> VmallocChunk:   34359371519 kB
> HardwareCorrupted:     0 kB
> DirectMap4k:      202372 kB
> DirectMap2M:    12249088 kB
> ----------------------------------------------------------------
> /proc/slabinfo
> ----------------------------------------------------------------
> slabinfo - version: 2.1
> # name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
> fat_inode_cache        0      0    664    6    1 : tunables   54   27    8 : slabdata      0      0      0
> fat_cache              0      0     32  112    1 : tunables  120   60    8 : slabdata      0      0      0
> pid_2                214    240    128   30    1 : tunables  120   60    8 : slabdata      8      8      0
> fuse_request           0      0    608    6    1 : tunables   54   27    8 : slabdata      0      0      0
> fuse_inode             0      0    704   11    2 : tunables   54   27    8 : slabdata      0      0      0
> nfsd4_delegations      0      0    368   10    1 : tunables   54   27    8 : slabdata      0      0      0
> nfsd4_stateids         0      0    120   32    1 : tunables  120   60    8 : slabdata      0      0      0
> nfsd4_files            0      0    128   30    1 : tunables  120   60    8 : slabdata      0      0      0
> nfsd4_lockowners       0      0    392   10    1 : tunables   54   27    8 : slabdata      0      0      0
> nfsd4_openowners       0      0    392   10    1 : tunables   54   27    8 : slabdata      0      0      0
> nfs_direct_cache       0      0    136   28    1 : tunables  120   60    8 : slabdata      0      0      0
> nfs_write_data        38     90    832    9    2 : tunables   54   27    8 : slabdata     10     10      0
> nfs_read_data          0      0    768    5    1 : tunables   54   27    8 : slabdata      0      0      0
> nfs_inode_cache      161    256   1000    4    1 : tunables   54   27    8 : slabdata     64     64      0
> nfs_page              92    120    128   30    1 : tunables  120   60    8 : slabdata      4      4      0
> fscache_cookie_jar      9     53     72   53    1 : tunables  120   60    8 : slabdata      1      1      0
> rpc_inode_cache       15     24    640    6    1 : tunables   54   27    8 : slabdata      4      4      0
> rpc_buffers            8     12   2048    2    1 : tunables   24   12    8 : slabdata      5      6      0
> rpc_tasks              9     30    256   15    1 : tunables  120   60    8 : slabdata      2      2      0
> ext2_inode_cache       8     10    744    5    1 : tunables   54   27    8 : slabdata      2      2      0
> ext2_xattr             0      0     88   44    1 : tunables  120   60    8 : slabdata      0      0      0
> sd_ext_cdb             2    112     32  112    1 : tunables  120   60    8 : slabdata      1      1      0
> fib6_nodes             6     59     64   59    1 : tunables  120   60    8 : slabdata      1      1      0
> ip6_dst_cache          5     12    320   12    1 : tunables   54   27    8 : slabdata      1      1      0
> ip6_mrt_cache          0      0    128   30    1 : tunables  120   60    8 : slabdata      0      0      0
> RAWv6                 14     14   1088    7    2 : tunables   24   12    8 : slabdata      2      2      0
> UDPLITEv6              0      0   1024    4    1 : tunables   54   27    8 : slabdata      0      0      0
> UDPv6                 10     12   1024    4    1 : tunables   54   27    8 : slabdata      3      3      0
> tw_sock_TCPv6          0      0    256   15    1 : tunables  120   60    8 : slabdata      0      0      0
> request_sock_TCPv6      0      0    192   20    1 : tunables  120   60    8 : slabdata      0      0      0
> TCPv6                 10     12   1856    2    1 : tunables   24   12    8 : slabdata      6      6      0
> flow_cache             0      0    104   37    1 : tunables  120   60    8 : slabdata      0      0      0
> kcopyd_job             0      0   3240    2    2 : tunables   24   12    8 : slabdata      0      0      0
> io                     0      0     64   59    1 : tunables  120   60    8 : slabdata      0      0      0
> dm_uevent              0      0   2608    3    2 : tunables   24   12    8 : slabdata      0      0      0
> dm_rq_clone_bio_info      0      0     16  202    1 : tunables  120   60    8 : slabdata      0      0      0
> dm_rq_target_io        0      0    400   10    1 : tunables   54   27    8 : slabdata      0      0      0
> dm_target_io        1853   3312     24  144    1 : tunables  120   60    8 : slabdata     23     23      0
> dm_io               1853   3312     40   92    1 : tunables  120   60    8 : slabdata     36     36      0
> uhci_urb_priv          1     67     56   67    1 : tunables  120   60    8 : slabdata      1      1      0
> scsi_sense_cache     120    120    128   30    1 : tunables  120   60    8 : slabdata      4      4      0
> scsi_cmd_cache       105    105    256   15    1 : tunables  120   60    8 : slabdata      7      7      0
> btree_node             0      0    128   30    1 : tunables  120   60    8 : slabdata      0      0      0
> cfq_io_cq            160    333    104   37    1 : tunables  120   60    8 : slabdata      9      9      0
> cfq_queue            161    306    232   17    1 : tunables  120   60    8 : slabdata     18     18      0
> bsg_cmd                0      0    312   12    1 : tunables   54   27    8 : slabdata      0      0      0
> mqueue_inode_cache      1      4    896    4    1 : tunables   54   27    8 : slabdata      1      1      0
> delayed_node         525   2899    288   13    1 : tunables   54   27    8 : slabdata    223    223      0
> extent_map         38088  49160     96   40    1 : tunables  120   60    8 : slabdata   1229   1229      0
> extent_buffers       314    396    344   11    1 : tunables   54   27    8 : slabdata     36     36      0
> extent_state        2674  13022    112   34    1 : tunables  120   60    8 : slabdata    383    383      0
> btrfs_free_space_cache   7574   8024     64   59    1 : tunables  120   60    8 : slabdata    136    136      0
> btrfs_path_cache      10     27    144   27    1 : tunables  120   60    8 : slabdata      1      1      0
> btrfs_transaction_cache      1     13    296   13    1 : tunables   54   27    8 : slabdata      1      1      0
> btrfs_trans_handle_cache     12     48     80   48    1 : tunables  120   60    8 : slabdata      1      1      0
> btrfs_inode_cache    750   1480    984    4    1 : tunables   54   27    8 : slabdata    370    370      0
> jbd2_transaction_s      0      0    256   15    1 : tunables  120   60    8 : slabdata      0      0      0
> jbd2_inode             0      0     48   77    1 : tunables  120   60    8 : slabdata      0      0      0
> jbd2_journal_handle      0      0     24  144    1 : tunables  120   60    8 : slabdata      0      0      0
> jbd2_journal_head      0      0    112   34    1 : tunables  120   60    8 : slabdata      0      0      0
> jbd2_revoke_table_s      0      0     16  202    1 : tunables  120   60    8 : slabdata      0      0      0
> jbd2_revoke_record_s      0      0     32  112    1 : tunables  120   60    8 : slabdata      0      0      0
> ext4_inode_cache       0      0    872    4    1 : tunables   54   27    8 : slabdata      0      0      0
> ext4_xattr             0      0     88   44    1 : tunables  120   60    8 : slabdata      0      0      0
> ext4_free_data         0      0     64   59    1 : tunables  120   60    8 : slabdata      0      0      0
> ext4_allocation_context      0      0    136   28    1 : tunables  120   60    8 : slabdata      0      0      0
> ext4_prealloc_space      0      0    104   37    1 : tunables  120   60    8 : slabdata      0      0      0
> ext4_system_zone       0      0     40   92    1 : tunables  120   60    8 : slabdata      0      0      0
> ext4_io_end            0      0   1128    3    1 : tunables   24   12    8 : slabdata      0      0      0
> ext4_io_page           0      0     16  202    1 : tunables  120   60    8 : slabdata      0      0      0
> dquot                  0      0    256   15    1 : tunables  120   60    8 : slabdata      0      0      0
> kioctx                 0      0    384   10    1 : tunables   54   27    8 : slabdata      0      0      0
> kiocb                  0      0    256   15    1 : tunables  120   60    8 : slabdata      0      0      0
> fanotify_response_event      0      0     32  112    1 : tunables  120   60    8 : slabdata      0      0      0
> fsnotify_mark          0      0    128   30    1 : tunables  120   60    8 : slabdata      0      0      0
> inotify_event_private_data      3    112     32  112    1 : tunables  120   60    8 : slabdata      1      1      0
> inotify_inode_mark     73     84    136   28    1 : tunables  120   60    8 : slabdata      3      3      0
> dnotify_mark           4     28    136   28    1 : tunables  120   60    8 : slabdata      1      1      0
> dnotify_struct         4    112     32  112    1 : tunables  120   60    8 : slabdata      1      1      0
> dio                    0      0    640    6    1 : tunables   54   27    8 : slabdata      0      0      0
> fasync_cache           4     77     48   77    1 : tunables  120   60    8 : slabdata      1      1      0
> pid_namespace          1      3   2128    3    2 : tunables   24   12    8 : slabdata      1      1      0
> user_namespace         0      0   1072    7    2 : tunables   24   12    8 : slabdata      0      0      0
> posix_timers_cache      1     27    144   27    1 : tunables  120   60    8 : slabdata      1      1      0
> uid_cache              7     60    128   30    1 : tunables  120   60    8 : slabdata      2      2      0
> UNIX                 531    540    832    9    2 : tunables   54   27    8 : slabdata     60     60      0
> ip_mrt_cache           0      0    128   30    1 : tunables  120   60    8 : slabdata      0      0      0
> UDP-Lite               0      0    896    4    1 : tunables   54   27    8 : slabdata      0      0      0
> tcp_bind_bucket       48    177     64   59    1 : tunables  120   60    8 : slabdata      3      3      0
> inet_peer_cache       49    160    192   20    1 : tunables  120   60    8 : slabdata      8      8      0
> secpath_cache          0      0     64   59    1 : tunables  120   60    8 : slabdata      0      0      0
> xfrm_dst_cache         0      0    448    8    1 : tunables   54   27    8 : slabdata      0      0      0
> ip_fib_trie            9     67     56   67    1 : tunables  120   60    8 : slabdata      1      1      0
> ip_fib_alias          10     77     48   77    1 : tunables  120   60    8 : slabdata      1      1      0
> ip_dst_cache         139    285    256   15    1 : tunables  120   60    8 : slabdata     19     19      0
> PING                   0      0    832    9    2 : tunables   54   27    8 : slabdata      0      0      0
> RAW                   11     18    832    9    2 : tunables   54   27    8 : slabdata      2      2      0
> UDP                   11     20    896    4    1 : tunables   54   27    8 : slabdata      5      5      0
> tw_sock_TCP            1     20    192   20    1 : tunables  120   60    8 : slabdata      1      1      0
> request_sock_TCP       0      0    128   30    1 : tunables  120   60    8 : slabdata      0      0      0
> TCP                   45     56   1664    4    2 : tunables   24   12    8 : slabdata     14     14      0
> eventpoll_pwq        289    424     72   53    1 : tunables  120   60    8 : slabdata      8      8      0
> eventpoll_epi        269    360    128   30    1 : tunables  120   60    8 : slabdata     12     12      0
> sgpool-128             2      2   4096    1    1 : tunables   24   12    8 : slabdata      2      2      0
> sgpool-64              2      2   2048    2    1 : tunables   24   12    8 : slabdata      1      1      0
> sgpool-32              2      4   1024    4    1 : tunables   54   27    8 : slabdata      1      1      0
> sgpool-16              3      8    512    8    1 : tunables   54   27    8 : slabdata      1      1      0
> sgpool-8             135    135    256   15    1 : tunables  120   60    8 : slabdata      9      9      0
> scsi_data_buffer       0      0     24  144    1 : tunables  120   60    8 : slabdata      0      0      0
> blkdev_queue          17     20   1784    4    2 : tunables   24   12    8 : slabdata      5      5      0
> blkdev_requests       64    132    360   11    1 : tunables   54   27    8 : slabdata     12     12      2
> blkdev_ioc           162    320     96   40    1 : tunables  120   60    8 : slabdata      8      8      0
> fsnotify_event_holder      0      0     24  144    1 : tunables  120   60    8 : slabdata      0      0      0
> fsnotify_event         4     34    112   34    1 : tunables  120   60    8 : slabdata      1      1      0
> bio-0                178    840    192   20    1 : tunables  120   60    8 : slabdata     42     42      0
> biovec-256           164    185   4096    1    1 : tunables   24   12    8 : slabdata    164    185     32
> biovec-128             0      0   2048    2    1 : tunables   24   12    8 : slabdata      0      0      0
> biovec-64              0      0   1024    4    1 : tunables   54   27    8 : slabdata      0      0      0
> biovec-16              0      0    256   15    1 : tunables  120   60    8 : slabdata      0      0      0
> sock_inode_cache     625    792    640    6    1 : tunables   54   27    8 : slabdata    132    132      0
> skbuff_fclone_cache      5     14    512    7    1 : tunables   54   27    8 : slabdata      2      2      0
> skbuff_head_cache    414    630    256   15    1 : tunables  120   60    8 : slabdata     42     42      0
> file_lock_cache       14     40    192   20    1 : tunables  120   60    8 : slabdata      2      2      0
> net_namespace          1      3   2624    3    2 : tunables   24   12    8 : slabdata      1      1      0
> shmem_inode_cache   4441   4788    616    6    1 : tunables   54   27    8 : slabdata    798    798      0
> Acpi-Operand        1411   1484     72   53    1 : tunables  120   60    8 : slabdata     28     28      0
> Acpi-ParseExt          0      0     72   53    1 : tunables  120   60    8 : slabdata      0      0      0
> Acpi-Parse             0      0     48   77    1 : tunables  120   60    8 : slabdata      0      0      0
> Acpi-State             0      0     80   48    1 : tunables  120   60    8 : slabdata      0      0      0
> Acpi-Namespace       939   1012     40   92    1 : tunables  120   60    8 : slabdata     11     11      0
> task_delay_info      561    680    112   34    1 : tunables  120   60    8 : slabdata     20     20      0
> taskstats              5     24    328   12    1 : tunables   54   27    8 : slabdata      2      2      0
> proc_inode_cache     843    852    616    6    1 : tunables   54   27    8 : slabdata    142    142      0
> sigqueue              37     48    160   24    1 : tunables  120   60    8 : slabdata      2      2      0
> bdev_cache            21     24    832    4    1 : tunables   54   27    8 : slabdata      6      6      0
> sysfs_dir_cache    13150  13430    112   34    1 : tunables  120   60    8 : slabdata    395    395      0
> mnt_cache             31     45    256   15    1 : tunables  120   60    8 : slabdata      3      3      0
> filp                8472   9870    256   15    1 : tunables  120   60    8 : slabdata    658    658    480
> inode_cache         1015   1183    552    7    1 : tunables   54   27    8 : slabdata    169    169      0
> dentry              8267  45240    192   20    1 : tunables  120   60    8 : slabdata   2262   2262     60
> names_cache           12     12   4096    1    1 : tunables   24   12    8 : slabdata     12     12      0
> key_jar                2     20    192   20    1 : tunables  120   60    8 : slabdata      1      1      0
> buffer_head           14    111    104   37    1 : tunables  120   60    8 : slabdata      3      3      0
> nsproxy                2     77     48   77    1 : tunables  120   60    8 : slabdata      1      1      0
> vm_area_struct     31533  31970    168   23    1 : tunables  120   60    8 : slabdata   1390   1390      0
> mm_struct            176    176    896    4    1 : tunables   54   27    8 : slabdata     44     44      0
> fs_cache             181    295     64   59    1 : tunables  120   60    8 : slabdata      5      5      0
> files_cache          181    209    704   11    2 : tunables   54   27    8 : slabdata     19     19      0
> signal_cache         267    272   1024    4    1 : tunables   54   27    8 : slabdata     68     68      0
> sighand_cache        261    261   2112    3    2 : tunables   24   12    8 : slabdata     87     87      0
> task_xstate          469    469    576    7    1 : tunables   54   27    8 : slabdata     67     67      0
> task_struct          555    555   1584    5    2 : tunables   24   12    8 : slabdata    111    111      0
> cred_jar             515    800    192   20    1 : tunables  120   60    8 : slabdata     40     40      0
> anon_vma_chain     31154  31878     48   77    1 : tunables  120   60    8 : slabdata    414    414      0
> anon_vma           14119  14455     64   59    1 : tunables  120   60    8 : slabdata    245    245      0
> pid                  388    570    128   30    1 : tunables  120   60    8 : slabdata     19     19      0
> radix_tree_node    63906  80227    560    7    1 : tunables   54   27    8 : slabdata  11461  11461      0
> idr_layer_cache      562    595    544    7    1 : tunables   54   27    8 : slabdata     85     85      0
> size-4194304(DMA)      0      0 4194304    1 1024 : tunables    1    1    0 : slabdata      0      0      0
> size-4194304           0      0 4194304    1 1024 : tunables    1    1    0 : slabdata      0      0      0
> size-2097152(DMA)      0      0 2097152    1  512 : tunables    1    1    0 : slabdata      0      0      0
> size-2097152           0      0 2097152    1  512 : tunables    1    1    0 : slabdata      0      0      0
> size-1048576(DMA)      0      0 1048576    1  256 : tunables    1    1    0 : slabdata      0      0      0
> size-1048576           0      0 1048576    1  256 : tunables    1    1    0 : slabdata      0      0      0
> size-524288(DMA)       0      0 524288    1  128 : tunables    1    1    0 : slabdata      0      0      0
> size-524288            0      0 524288    1  128 : tunables    1    1    0 : slabdata      0      0      0
> size-262144(DMA)       0      0 262144    1   64 : tunables    1    1    0 : slabdata      0      0      0
> size-262144            0      0 262144    1   64 : tunables    1    1    0 : slabdata      0      0      0
> size-131072(DMA)       0      0 131072    1   32 : tunables    8    4    0 : slabdata      0      0      0
> size-131072            0      0 131072    1   32 : tunables    8    4    0 : slabdata      0      0      0
> size-65536(DMA)        0      0  65536    1   16 : tunables    8    4    0 : slabdata      0      0      0
> size-65536            11     11  65536    1   16 : tunables    8    4    0 : slabdata     11     11      0
> size-32768(DMA)        0      0  32768    1    8 : tunables    8    4    0 : slabdata      0      0      0
> size-32768             1      1  32768    1    8 : tunables    8    4    0 : slabdata      1      1      0
> size-16384(DMA)        0      0  16384    1    4 : tunables    8    4    0 : slabdata      0      0      0
> size-16384            12     12  16384    1    4 : tunables    8    4    0 : slabdata     12     12      0
> size-8192(DMA)         0      0   8192    1    2 : tunables    8    4    0 : slabdata      0      0      0
> size-8192             27     27   8192    1    2 : tunables    8    4    0 : slabdata     27     27      0
> size-4096(DMA)         0      0   4096    1    1 : tunables   24   12    8 : slabdata      0      0      0
> size-4096            453    453   4096    1    1 : tunables   24   12    8 : slabdata    453    453      0
> size-2048(DMA)         0      0   2048    2    1 : tunables   24   12    8 : slabdata      0      0      0
> size-2048            684    708   2048    2    1 : tunables   24   12    8 : slabdata    354    354      0
> size-1024(DMA)         0      0   1024    4    1 : tunables   54   27    8 : slabdata      0      0      0
> size-1024           1427   1460   1024    4    1 : tunables   54   27    8 : slabdata    365    365      0
> size-512(DMA)          0      0    512    8    1 : tunables   54   27    8 : slabdata      0      0      0
> size-512            4018   4376    512    8    1 : tunables   54   27    8 : slabdata    547    547      0
> size-256(DMA)          0      0    256   15    1 : tunables  120   60    8 : slabdata      0      0      0
> size-256             579    660    256   15    1 : tunables  120   60    8 : slabdata     44     44      0
> size-192(DMA)          0      0    192   20    1 : tunables  120   60    8 : slabdata      0      0      0
> size-192            1532   1780    192   20    1 : tunables  120   60    8 : slabdata     89     89      0
> size-128(DMA)          0      0    128   30    1 : tunables  120   60    8 : slabdata      0      0      0
> size-64(DMA)           0      0     64   59    1 : tunables  120   60    8 : slabdata      0      0      0
> size-64             7338  33571     64   59    1 : tunables  120   60    8 : slabdata    569    569     30
> size-32(DMA)           0      0     32  112    1 : tunables  120   60    8 : slabdata      0      0      0
> size-128            7966  11160    128   30    1 : tunables  120   60    8 : slabdata    372    372      0
> size-32             8063  18368     32  112    1 : tunables  120   60    8 : slabdata    164    164      0
> kmem_cache           196    200    192   20    1 : tunables  120   60    8 : slabdata     10     10      0
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
