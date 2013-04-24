Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 4461C6B0002
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 05:47:35 -0400 (EDT)
Date: Wed, 24 Apr 2013 11:47:32 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: OOM-killer and strange RSS value in 3.9-rc7
Message-ID: <20130424094732.GB31960@dhcp22.suse.cz>
References: <alpine.DEB.2.02.1304161315290.30779@chino.kir.corp.google.com>
 <20130417094750.GB2672@localhost.localdomain>
 <20130417141909.GA24912@dhcp22.suse.cz>
 <20130418101541.GC2672@localhost.localdomain>
 <20130418175513.GA12581@dhcp22.suse.cz>
 <20130423131558.GH8001@dhcp22.suse.cz>
 <20130424044848.GI2672@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130424044848.GI2672@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Han Pingtian <hanpt@linux.vnet.ibm.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

[CCing SL.B people and linux-mm list]

Just for quick summary. The reporter sees OOM situations with almost
whole memory filled with slab memory. This is a powerpc machine with 4G
RAM.
/proc/slabinfo shows that almost whole slab occupied memory is on
free lists which for some reason don't get freed under memory pressure.
kmalloc-* caches seem to be most affected. For reference:
$ awk '{active_size=$2*$4;num_size=$3*$4;active_sum+=active_size;num_sum+=num_size; printf "%s: %d %d\n", $1, active_size, num_size}END{printf "sum: %d %d\n", active_sum, num_sum}' a | sort -k3 -n | tail -n10
kmemleak_object: 94664384 112746000
pgtable-2^12: 107937792 113246208
kmalloc-8192: 59334656 122159104
kmalloc-32768: 36175872 137887744
task_struct: 27080016 241293920
kmalloc-2048: 17317888 306446336
kmalloc-96: 8734848 307652928
kmalloc-16384: 54919168 516620288
kmalloc-512: 17211392 1226833920
sum: 865488272 3598335904

It is not clear who consumes that memory and the reporter claims this is
vanilla 3.9-rc7 kernel without any third party modules loaded. The issue
seems to be present only with CONFIG_SLUB.

On Wed 24-04-13 12:48:48, Han Pingtian wrote:
> On Tue, Apr 23, 2013 at 03:15:58PM +0200, Michal Hocko wrote:
> > On Tue 23-04-13 12:22:34, Han Pingtian wrote:
> > > On Mon, Apr 22, 2013 at 01:40:52PM +0200, Michal Hocko wrote:
> > > > [...]
> > > > > -CONFIG_SLUB_DEBUG=y
> > > > > -# CONFIG_COMPAT_BRK is not set
> > > > > -# CONFIG_SLAB is not set
> > > > > -CONFIG_SLUB=y
> > > > > +CONFIG_COMPAT_BRK=y
> > > > > +CONFIG_SLAB=y
> > > > 
> > > > I would start with the bad config and SLUB changed to SLAB in the first
> > > > step, though.
> > > > 
> > > Yep, after I changed bad config to use SLAB, the problem disppears after
> > > using the new kernel. Looks like something wrong in SLUB?
> > 
> > It seems so or maybe there is a different issue which is just made
> > visible by SLUB or it is an arch specific problem.
> > What is the workload that triggers this behavior? Can you reduce it to a
> > minimum test case?
> > 
> I can trigger this behavior just with "make -j 64" to rebuild kernel
> from source code. In fact, just after a fresh reboot, I haven't run
> anything, the memory is almost all used or leaked:

The following is right after boot or make -j64?

> # uname -a
> Linux riblp3.upt.austin.ibm.com 3.9.0-rc7 #7 SMP Tue Apr 23 22:49:09 CDT 2013 ppc64 ppc64 ppc64 GNU/Linux
> # free -m
>              total       used       free     shared    buffers     cached
> Mem:          3788       3697         90          0          1        143
> -/+ buffers/cache:       3552        235
> Swap:         4031          5       4026
> # awk '{print $1":", $2*$4/1024/1024, $3*$4/1024/1024}' /proc/slabinfo |sort -k 3 -n
> #: 0 0
> bip-128: 0 0
> bsg_cmd: 0 0
> configfs_dir_cache: 0 0
> dma-kmalloc-1024: 0 0
> dma-kmalloc-128: 0 0
> dma-kmalloc-131072: 0 0
> dma-kmalloc-16: 0 0
> dma-kmalloc-16384: 0 0
> dma-kmalloc-192: 0 0
> dma-kmalloc-2048: 0 0
> dma-kmalloc-256: 0 0
> dma-kmalloc-32: 0 0
> dma-kmalloc-32768: 0 0
> dma-kmalloc-4096: 0 0
> dma-kmalloc-512: 0 0
> dma-kmalloc-64: 0 0
> dma-kmalloc-65536: 0 0
> dma-kmalloc-8: 0 0
> dma-kmalloc-8192: 0 0
> dma-kmalloc-96: 0 0
> dm_rq_target_io: 0 0
> dm_uevent: 0 0
> dquot: 0 0
> ext4_allocation_context: 0 0
> ext4_extent_status: 0 0
> ext4_free_data: 0 0
> ext4_inode_cache: 0 0
> ext4_io_end: 0 0
> ext4_io_page: 0 0
> ext4_xattr: 0 0
> isofs_inode_cache: 0 0
> jbd2_journal_head: 0 0
> jbd2_revoke_record_s: 0 0
> kcopyd_job: 0 0
> kmalloc-131072: 0 0
> net_namespace: 0 0
> nfsd4_delegations: 0 0
> nfsd4_openowners: 0 0
> nfs_direct_cache: 0 0
> pid_namespace: 0 0
> rtas_flash_cache: 0 0
> scsi_tgt_cmd: 0 0
> slabinfo: 0 0
> tw_sock_TCPv6: 0 0
> UDP-Lite: 0 0
> UDPLITEv6: 0 0
> xfs_dquot: 0 0
> mqueue_inode_cache: 0.0623779 0.0623779
> tw_sock_TCP: 0.0625 0.0625
> hugetlbfs_inode_cache: 0.124146 0.124146
> taskstats: 0.186745 0.186745
> fscache_cookie_jar: 0.187454 0.187454
> ip_fib_trie: 0.187454 0.187454
> bip-256: 0.249756 0.249756
> shared_policy_node: 0.249939 0.249939
> nfs_inode_cache: 0.25 0.25
> rpc_inode_cache: 0.311279 0.311279
> UDPv6: 0.553711 0.553711
> kmem_cache_node: 0.5625 0.5625
> dio: 0.622559 0.622559
> TCPv6: 0.622559 0.622559
> blkdev_queue: 0.679443 0.679443
> bdev_cache: 0.748535 0.748535
> xfs_efd_item: 0.994873 0.994873
> fsnotify_event_holder: 1.18721 1.18721
> nf_conntrack_c00000000102d400: 1.18721 1.18721
> kmem_cache: 1.23047 1.23047
> TCP: 1.96875 1.96875
> UDP: 2.12085 2.12085
> xfs_btree_cur: 2.24945 2.24945
> buffer_head: 2.4369 2.4369
> posix_timers_cache: 2.55812 2.55812
> xfs_ili: 3.36841 3.36841
> blkdev_ioc: 3.37418 3.37418
> bip-16: 3.6731 3.6731
> xfs_da_state: 3.99121 3.99121
> xfs_trans: 3.99902 3.99902
> shmem_inode_cache: 4.24429 4.24429
> blkdev_requests: 4.67949 4.67949
> ext4_system_zone: 4.68636 4.68636
> radix_tree_node: 4.79664 4.79664
> sigqueue: 4.93027 4.93027
> fsnotify_event: 4.93629 4.93629
> kmalloc-8: 4.9375 4.9375
> files_cache: 4.98047 4.98047
> RAW: 4.99023 4.99023
> pgtable-2^6: 5 5
> sock_inode_cache: 5.10498 5.10498
> anon_vma: 5.25 5.25
> numa_policy: 5.3112 5.3112
> kmalloc-32: 5.00131 5.625
> xfs_inode: 5.86353 5.86353
> signal_cache: 5.90625 5.90625
> kmalloc-64: 5.72687 6.375
> sysfs_dir_cache: 6.74835 6.74835
> vm_area_struct: 7.05905 7.05905
> dentry: 9.11609 9.11609
> inode_cache: 10.6849 10.6849
> sighand_cache: 11.2061 11.2061
> proc_inode_cache: 11.3722 11.3722
> idr_layer_cache: 11.9883 11.9883
> kmalloc-4096: 10.7812 12
> kmalloc-256: 13.1768 16.0625
> kmalloc-16: 9.19449 16.25
> kmalloc-1024: 6.83789 22.0625
> kmalloc-192: 9.17725 28.8468
> kmalloc-128: 9.43066 31.125
> kmalloc-65536: 40 40
> pgtable-2^12: 88.25 91.5
> kmalloc-8192: 28.3672 117.5
> kmalloc-32768: 20.4375 131.5
> task_struct: 25.5788 230.002
> kmalloc-2048: 16.8555 299.688
> kmalloc-96: 7.84653 300.956
> kmalloc-16384: 54.125 504.25
> kmalloc-512: 17.2104 1170.56
> # cat /proc/meminfo
> MemTotal:        3879104 kB
> MemFree:           90624 kB
> Buffers:            1920 kB
> Cached:           173888 kB
> SwapCached:         5184 kB
> Active:           240064 kB
> Inactive:         152256 kB
> Active(anon):     153088 kB
> Inactive(anon):    68608 kB
> Active(file):      86976 kB
> Inactive(file):    83648 kB
> Unevictable:           0 kB
> Mlocked:               0 kB
> SwapTotal:       4128704 kB
> SwapFree:        4123520 kB
> Dirty:                64 kB
> Writeback:             0 kB
> AnonPages:        213056 kB
> Mapped:            71808 kB
> Shmem:              3200 kB
> Slab:            3275968 kB
> SReclaimable:      52864 kB
> SUnreclaim:      3223104 kB
> KernelStack:       14352 kB
> PageTables:        14464 kB
> NFS_Unstable:          0 kB
> Bounce:                0 kB
> WritebackTmp:          0 kB
> CommitLimit:     6068224 kB
> Committed_AS:    2497728 kB
> VmallocTotal:   8589934592 kB
> VmallocUsed:       17984 kB
> VmallocChunk:   8589641856 kB
> HugePages_Total:       0
> HugePages_Free:        0
> HugePages_Rsvd:        0
> HugePages_Surp:        0
> Hugepagesize:      16384 kB
> 
> > I guess that you are still testing with vanilla 3.9-rc? kernel without
> > any additional patches or 3rd party modules, right?
> > 
> Right. I'm testing with vanilla 3.9-rc7 kernel without any additional
> patches and 3rd party modules.

Could you send the full config which you are using right now, please?
Also the full dmesg output since boot might turn up helpful.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
