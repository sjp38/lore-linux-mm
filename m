Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id EE7E166002F
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 23:24:01 -0400 (EDT)
Date: Wed, 4 Aug 2010 11:24:00 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Over-eager swapping
Message-ID: <20100804032400.GA14141@localhost>
References: <20100802124734.GI2486@arachsys.com>
 <AANLkTinnWQA-K6r_+Y+giEC9zs-MbY6GFs8dWadSq0kh@mail.gmail.com>
 <20100803033108.GA23117@arachsys.com>
 <AANLkTinjmZOOaq7FgwJOZ=UNGS8x8KtQWZg6nv7fqJMe@mail.gmail.com>
 <20100803042835.GA17377@localhost>
 <20100803214945.GA2326@arachsys.com>
 <20100804022148.GA5922@localhost>
 <AANLkTi=wRPXY9BTuoCe_sDCwhnRjmmwtAf_bjDKG3kXQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTi=wRPXY9BTuoCe_sDCwhnRjmmwtAf_bjDKG3kXQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Chris Webb <chris@arachsys.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 04, 2010 at 11:10:46AM +0800, Minchan Kim wrote:
> On Wed, Aug 4, 2010 at 11:21 AM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > Chris,
> >
> > Your slabinfo does contain many order 1-3 slab caches, this is a major source
> > of high order allocations and hence lumpy reclaim. fork() is another.
> >
> > In another thread, Pekka Enberg offers a tip:
> >
> > A  A  A  A You can pass "slub_debug=o" as a kernel parameter to disable higher
> > A  A  A  A order allocations if you want to test things.
> >
> > Note that the parameter works on a CONFIG_SLUB_DEBUG=y kernel.
> >
> > Thanks,
> > Fengguang
> 
> He said following as.
> "After running swapoff -a, the machine is immediately much healthier. Even
> while the swap is still being reduced, load goes down and response times in
> virtual machines are much improved. Once the swap is completely gone, there
> are still several gigabytes of RAM left free which are used for buffers, and
> the virtual machines are no longer laggy because they are no longer swapped
> out.
>
> Running swapon -a again, the affected machine waits for about a minute
> with zero swap in use,

This is interesting. Why is it waiting for 1m here? Are there high CPU
loads? Would you do a

        echo t > /proc/sysrq-trigger

and show us the dmesg?

Thanks,
Fengguang

> before the amount of swap in use very rapidly
> increases to around 2GB and then continues to increase more steadily to 3GB."
> 
> 1. His system works well without swap.
> 2. His system increase swap by 2G rapidly and more steadily to 3GB.
> 
> So I thought it isn't likely to relate normal lumpy.
> 
> Of course, without swap, lumpy can scan more file pages to make
> contiguous page frames. so it could work well, still. But I can't
> understand 2.
> 
> Hmm, I have no idea. :(
> 
> Off-Topic:
> 
> Hi, Pekka.
> 
> Document says.
> "Debugging options may require the minimum possible slab order to increase as
> a result of storing the metadata (for example, caches with PAGE_SIZE object
> sizes). A This has a higher liklihood of resulting in slab allocation errors
> in low memory situations or if there's high fragmentation of memory. A To
> switch off debugging for such caches by default, use
> 
> A  A  A  A slub_debug=O"
> 
> But when I tested it in my machine(2.6.34), A with slub_debug=O, it
> increase objsize and pagesperslab. Even it increase the number of
> slab(But I am not sure this part since it might not the same time from
> booting)
> What am I missing now?
> 
> But SLAB seems to be consumed small pages than SLUB. Hmm.
> SLAB is more proper than SLUBin small memory system(ex, embedded)?
> 
> 
> --
> Kind regards,
> Minchan Kim

> 
> slabinfo - version: 2.1
> # name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
> kvm_vcpu               0      0   9200    3    8 : tunables    0    0    0 : slabdata      0      0      0
> kmalloc_dma-512       16     16    512   16    2 : tunables    0    0    0 : slabdata      1      1      0
> RAWv6                 17     17    960   17    4 : tunables    0    0    0 : slabdata      1      1      0
> UDPLITEv6              0      0    960   17    4 : tunables    0    0    0 : slabdata      0      0      0
> UDPv6                 51     51    960   17    4 : tunables    0    0    0 : slabdata      3      3      0
> TCPv6                 72     72   1728   18    8 : tunables    0    0    0 : slabdata      4      4      0
> nf_conntrack_c10a8540      0      0    280   29    2 : tunables    0    0    0 : slabdata      0      0      0
> dm_raid1_read_record      0      0   1056   31    8 : tunables    0    0    0 : slabdata      0      0      0
> dm_uevent              0      0   2464   13    8 : tunables    0    0    0 : slabdata      0      0      0
> mqueue_inode_cache     18     18    896   18    4 : tunables    0    0    0 : slabdata      1      1      0
> fuse_request          18     18    432   18    2 : tunables    0    0    0 : slabdata      1      1      0
> fuse_inode            21     21    768   21    4 : tunables    0    0    0 : slabdata      1      1      0
> nfsd4_stateowners      0      0    344   23    2 : tunables    0    0    0 : slabdata      0      0      0
> nfs_read_data         72     72    448   18    2 : tunables    0    0    0 : slabdata      4      4      0
> nfs_inode_cache        0      0   1040   31    8 : tunables    0    0    0 : slabdata      0      0      0
> ecryptfs_inode_cache      0      0   1280   25    8 : tunables    0    0    0 : slabdata      0      0      0
> hugetlbfs_inode_cache     24     24    656   24    4 : tunables    0    0    0 : slabdata      1      1      0
> ext4_inode_cache       0      0   1128   29    8 : tunables    0    0    0 : slabdata      0      0      0
> ext2_inode_cache       0      0    944   17    4 : tunables    0    0    0 : slabdata      0      0      0
> ext3_inode_cache    5032   5032    928   17    4 : tunables    0    0    0 : slabdata    296    296      0
> rpc_inode_cache       18     18    896   18    4 : tunables    0    0    0 : slabdata      1      1      0
> UNIX                 532    532    832   19    4 : tunables    0    0    0 : slabdata     28     28      0
> UDP-Lite               0      0    832   19    4 : tunables    0    0    0 : slabdata      0      0      0
> UDP                   76     76    832   19    4 : tunables    0    0    0 : slabdata      4      4      0
> TCP                   60     60   1600   20    8 : tunables    0    0    0 : slabdata      3      3      0
> sgpool-128            48     48   2560   12    8 : tunables    0    0    0 : slabdata      4      4      0
> sgpool-64            100    100   1280   25    8 : tunables    0    0    0 : slabdata      4      4      0
> blkdev_queue          76     76   1688   19    8 : tunables    0    0    0 : slabdata      4      4      0
> biovec-256            10     10   3072   10    8 : tunables    0    0    0 : slabdata      1      1      0
> biovec-128            21     21   1536   21    8 : tunables    0    0    0 : slabdata      1      1      0
> biovec-64             84     84    768   21    4 : tunables    0    0    0 : slabdata      4      4      0
> bip-256               10     10   3200   10    8 : tunables    0    0    0 : slabdata      1      1      0
> bip-128                0      0   1664   19    8 : tunables    0    0    0 : slabdata      0      0      0
> bip-64                 0      0    896   18    4 : tunables    0    0    0 : slabdata      0      0      0
> bip-16               100    100    320   25    2 : tunables    0    0    0 : slabdata      4      4      0
> sock_inode_cache     609    609    768   21    4 : tunables    0    0    0 : slabdata     29     29      0
> skbuff_fclone_cache     84     84    384   21    2 : tunables    0    0    0 : slabdata      4      4      0
> shmem_inode_cache   1835   1840    784   20    4 : tunables    0    0    0 : slabdata     92     92      0
> taskstats             96     96    328   24    2 : tunables    0    0    0 : slabdata      4      4      0
> proc_inode_cache    1584   1584    680   24    4 : tunables    0    0    0 : slabdata     66     66      0
> bdev_cache            72     72    896   18    4 : tunables    0    0    0 : slabdata      4      4      0
> inode_cache         7126   7128    656   24    4 : tunables    0    0    0 : slabdata    297    297      0
> signal_cache         332    350    640   25    4 : tunables    0    0    0 : slabdata     14     14      0
> sighand_cache        246    253   1408   23    8 : tunables    0    0    0 : slabdata     11     11      0
> task_xstate          193    196    576   28    4 : tunables    0    0    0 : slabdata      7      7      0
> task_struct          274    285   5472    5    8 : tunables    0    0    0 : slabdata     57     57      0
> radix_tree_node     3208   3213    296   27    2 : tunables    0    0    0 : slabdata    119    119      0
> kmalloc-8192          20     20   8192    4    8 : tunables    0    0    0 : slabdata      5      5      0
> kmalloc-4096          78     80   4096    8    8 : tunables    0    0    0 : slabdata     10     10      0
> kmalloc-2048         400    400   2048   16    8 : tunables    0    0    0 : slabdata     25     25      0
> kmalloc-1024         326    336   1024   16    4 : tunables    0    0    0 : slabdata     21     21      0
> kmalloc-512          758    784    512   16    2 : tunables    0    0    0 : slabdata     49     49      0

> slabinfo - version: 2.1
> # name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
> kvm_vcpu               0      0   9248    3    8 : tunables    0    0    0 : slabdata      0      0      0
> kmalloc_dma-512       29     29    560   29    4 : tunables    0    0    0 : slabdata      1      1      0
> clip_arp_cache         0      0    320   25    2 : tunables    0    0    0 : slabdata      0      0      0
> ip6_dst_cache         25     25    320   25    2 : tunables    0    0    0 : slabdata      1      1      0
> ndisc_cache           25     25    320   25    2 : tunables    0    0    0 : slabdata      1      1      0
> RAWv6                 16     16   1024   16    4 : tunables    0    0    0 : slabdata      1      1      0
> UDPLITEv6              0      0    960   17    4 : tunables    0    0    0 : slabdata      0      0      0
> UDPv6                 68     68    960   17    4 : tunables    0    0    0 : slabdata      4      4      0
> tw_sock_TCPv6          0      0    320   25    2 : tunables    0    0    0 : slabdata      0      0      0
> TCPv6                 36     36   1792   18    8 : tunables    0    0    0 : slabdata      2      2      0
> nf_conntrack_c10a8540      0      0    320   25    2 : tunables    0    0    0 : slabdata      0      0      0
> dm_raid1_read_record      0      0   1096   29    8 : tunables    0    0    0 : slabdata      0      0      0
> kcopyd_job             0      0    376   21    2 : tunables    0    0    0 : slabdata      0      0      0
> dm_uevent              0      0   2504   13    8 : tunables    0    0    0 : slabdata      0      0      0
> dm_rq_target_io        0      0    272   30    2 : tunables    0    0    0 : slabdata      0      0      0
> mqueue_inode_cache     17     17    960   17    4 : tunables    0    0    0 : slabdata      1      1      0
> fuse_request          17     17    480   17    2 : tunables    0    0    0 : slabdata      1      1      0
> fuse_inode            19     19    832   19    4 : tunables    0    0    0 : slabdata      1      1      0
> nfsd4_stateowners      0      0    392   20    2 : tunables    0    0    0 : slabdata      0      0      0
> nfs_write_data        48     48    512   16    2 : tunables    0    0    0 : slabdata      3      3      0
> nfs_read_data         32     32    512   16    2 : tunables    0    0    0 : slabdata      2      2      0
> nfs_inode_cache        0      0   1080   30    8 : tunables    0    0    0 : slabdata      0      0      0
> ecryptfs_key_record_cache      0      0    576   28    4 : tunables    0    0    0 : slabdata      0      0      0
> ecryptfs_sb_cache      0      0    640   25    4 : tunables    0    0    0 : slabdata      0      0      0
> ecryptfs_inode_cache      0      0   1280   25    8 : tunables    0    0    0 : slabdata      0      0      0
> ecryptfs_auth_tok_list_item      0      0    896   18    4 : tunables    0    0    0 : slabdata      0      0      0
> hugetlbfs_inode_cache     23     23    696   23    4 : tunables    0    0    0 : slabdata      1      1      0
> ext4_inode_cache       0      0   1168   28    8 : tunables    0    0    0 : slabdata      0      0      0
> ext2_inode_cache       0      0    984   16    4 : tunables    0    0    0 : slabdata      0      0      0
> ext3_inode_cache    5391   5392    968   16    4 : tunables    0    0    0 : slabdata    337    337      0
> dquot                  0      0    320   25    2 : tunables    0    0    0 : slabdata      0      0      0
> kioctx                 0      0    384   21    2 : tunables    0    0    0 : slabdata      0      0      0
> rpc_buffers           30     30   2112   15    8 : tunables    0    0    0 : slabdata      2      2      0
> rpc_inode_cache       18     18    896   18    4 : tunables    0    0    0 : slabdata      1      1      0
> UNIX                 556    558    896   18    4 : tunables    0    0    0 : slabdata     31     31      0
> UDP-Lite               0      0    832   19    4 : tunables    0    0    0 : slabdata      0      0      0
> ip_dst_cache         125    125    320   25    2 : tunables    0    0    0 : slabdata      5      5      0
> arp_cache            100    100    320   25    2 : tunables    0    0    0 : slabdata      4      4      0
> RAW                   19     19    832   19    4 : tunables    0    0    0 : slabdata      1      1      0
> UDP                   76     76    832   19    4 : tunables    0    0    0 : slabdata      4      4      0
> TCP                   76     76   1664   19    8 : tunables    0    0    0 : slabdata      4      4      0
> sgpool-128            48     48   2624   12    8 : tunables    0    0    0 : slabdata      4      4      0
> sgpool-64             96     96   1344   24    8 : tunables    0    0    0 : slabdata      4      4      0
> sgpool-32             92     92    704   23    4 : tunables    0    0    0 : slabdata      4      4      0
> sgpool-16             84     84    384   21    2 : tunables    0    0    0 : slabdata      4      4      0
> blkdev_queue          72     72   1736   18    8 : tunables    0    0    0 : slabdata      4      4      0
> biovec-256            10     10   3136   10    8 : tunables    0    0    0 : slabdata      1      1      0
> biovec-128            20     20   1600   20    8 : tunables    0    0    0 : slabdata      1      1      0
> biovec-64             76     76    832   19    4 : tunables    0    0    0 : slabdata      4      4      0
> bip-256               10     10   3200   10    8 : tunables    0    0    0 : slabdata      1      1      0
> bip-128                0      0   1664   19    8 : tunables    0    0    0 : slabdata      0      0      0
> bip-64                 0      0    896   18    4 : tunables    0    0    0 : slabdata      0      0      0
> bip-16                 0      0    320   25    2 : tunables    0    0    0 : slabdata      0      0      0
> sock_inode_cache     629    630    768   21    4 : tunables    0    0    0 : slabdata     30     30      0
> skbuff_fclone_cache     72     72    448   18    2 : tunables    0    0    0 : slabdata      4      4      0
> shmem_inode_cache   1862   1862    824   19    4 : tunables    0    0    0 : slabdata     98     98      0
> taskstats             84     84    376   21    2 : tunables    0    0    0 : slabdata      4      4      0
> proc_inode_cache    1623   1650    720   22    4 : tunables    0    0    0 : slabdata     75     75      0
> bdev_cache            68     68    960   17    4 : tunables    0    0    0 : slabdata      4      4      0
> inode_cache         7125   7130    696   23    4 : tunables    0    0    0 : slabdata    310    310      0
> mm_struct            135    138    704   23    4 : tunables    0    0    0 : slabdata      6      6      0
> files_cache          142    150    320   25    2 : tunables    0    0    0 : slabdata      6      6      0
> signal_cache         229    230    704   23    4 : tunables    0    0    0 : slabdata     10     10      0
> sighand_cache        228    230   1408   23    8 : tunables    0    0    0 : slabdata     10     10      0
> task_xstate          195    200    640   25    4 : tunables    0    0    0 : slabdata      8      8      0
> task_struct          271    285   5520    5    8 : tunables    0    0    0 : slabdata     57     57      0
> radix_tree_node     3484   3504    336   24    2 : tunables    0    0    0 : slabdata    146    146      0
> kmalloc-8192          20     20   8192    4    8 : tunables    0    0    0 : slabdata      5      5      0
> kmalloc-4096          79     80   4096    8    8 : tunables    0    0    0 : slabdata     10     10      0
> kmalloc-2048         388    390   2096   15    8 : tunables    0    0    0 : slabdata     26     26      0
> kmalloc-1024         382    390   1072   30    8 : tunables    0    0    0 : slabdata     13     13      0
> kmalloc-512          796    812    560   29    4 : tunables    0    0    0 : slabdata     28     28      0
> kmalloc-256          153    156    304   26    2 : tunables    0    0    0 : slabdata      6      6      0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
