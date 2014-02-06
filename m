Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f44.google.com (mail-oa0-f44.google.com [209.85.219.44])
	by kanga.kvack.org (Postfix) with ESMTP id 288836B0037
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 18:31:36 -0500 (EST)
Received: by mail-oa0-f44.google.com with SMTP id g12so3256340oah.3
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 15:31:35 -0800 (PST)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id si5si1097386oeb.139.2014.02.06.11.28.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 06 Feb 2014 11:28:59 -0800 (PST)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Thu, 6 Feb 2014 12:28:29 -0700
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 4B40EC90046
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 14:28:23 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp23033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s16JSQQP6554076
	for <linux-mm@kvack.org>; Thu, 6 Feb 2014 19:28:26 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s16JSPlJ027586
	for <linux-mm@kvack.org>; Thu, 6 Feb 2014 14:28:25 -0500
Date: Thu, 6 Feb 2014 11:28:12 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
Message-ID: <20140206192812.GC7845@linux.vnet.ibm.com>
References: <52e1da8f.86f7440a.120f.25f3SMTPIN_ADDED_BROKEN@mx.google.com>
 <alpine.DEB.2.10.1401240946530.12886@nuc>
 <alpine.DEB.2.02.1401241301120.10968@chino.kir.corp.google.com>
 <20140124232902.GB30361@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1401241543100.18620@chino.kir.corp.google.com>
 <20140125001643.GA25344@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1401241618500.20466@chino.kir.corp.google.com>
 <20140206020757.GC5433@linux.vnet.ibm.com>
 <20140206080418.GA19913@lge.com>
 <20140206185955.GA7845@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="8P1HSweYDcXXzwPJ"
Content-Disposition: inline
In-Reply-To: <20140206185955.GA7845@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, penberg@kernel.org, linux-mm@kvack.org, paulus@samba.org, Anton Blanchard <anton@samba.org>, mpm@selenic.com, Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>


--8P1HSweYDcXXzwPJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On 06.02.2014 [10:59:55 -0800], Nishanth Aravamudan wrote:
> On 06.02.2014 [17:04:18 +0900], Joonsoo Kim wrote:
> > On Wed, Feb 05, 2014 at 06:07:57PM -0800, Nishanth Aravamudan wrote:
> > > On 24.01.2014 [16:25:58 -0800], David Rientjes wrote:
> > > > On Fri, 24 Jan 2014, Nishanth Aravamudan wrote:
> > > > 
> > > > > Thank you for clarifying and providing  a test patch. I ran with this on
> > > > > the system showing the original problem, configured to have 15GB of
> > > > > memory.
> > > > > 
> > > > > With your patch after boot:
> > > > > 
> > > > > MemTotal:       15604736 kB
> > > > > MemFree:         8768192 kB
> > > > > Slab:            3882560 kB
> > > > > SReclaimable:     105408 kB
> > > > > SUnreclaim:      3777152 kB
> > > > > 
> > > > > With Anton's patch after boot:
> > > > > 
> > > > > MemTotal:       15604736 kB
> > > > > MemFree:        11195008 kB
> > > > > Slab:            1427968 kB
> > > > > SReclaimable:     109184 kB
> > > > > SUnreclaim:      1318784 kB
> > > > > 
> > > > > 
> > > > > I know that's fairly unscientific, but the numbers are reproducible. 
> > > > > 
> > > > 
> > > > I don't think the goal of the discussion is to reduce the amount of slab 
> > > > allocated, but rather get the most local slab memory possible by use of 
> > > > kmalloc_node().  When a memoryless node is being passed to kmalloc_node(), 
> > > > which is probably cpu_to_node() for a cpu bound to a node without memory, 
> > > > my patch is allocating it on the most local node; Anton's patch is 
> > > > allocating it on whatever happened to be the cpu slab.
> > > > 
> > > > > > diff --git a/mm/slub.c b/mm/slub.c
> > > > > > --- a/mm/slub.c
> > > > > > +++ b/mm/slub.c
> > > > > > @@ -2278,10 +2278,14 @@ redo:
> > > > > > 
> > > > > >  	if (unlikely(!node_match(page, node))) {
> > > > > >  		stat(s, ALLOC_NODE_MISMATCH);
> > > > > > -		deactivate_slab(s, page, c->freelist);
> > > > > > -		c->page = NULL;
> > > > > > -		c->freelist = NULL;
> > > > > > -		goto new_slab;
> > > > > > +		if (unlikely(!node_present_pages(node)))
> > > > > > +			node = numa_mem_id();
> > > > > > +		if (!node_match(page, node)) {
> > > > > > +			deactivate_slab(s, page, c->freelist);
> > > > > > +			c->page = NULL;
> > > > > > +			c->freelist = NULL;
> > > > > > +			goto new_slab;
> > > > > > +		}
> > > > > 
> > > > > Semantically, and please correct me if I'm wrong, this patch is saying
> > > > > if we have a memoryless node, we expect the page's locality to be that
> > > > > of numa_mem_id(), and we still deactivate the slab if that isn't true.
> > > > > Just wanting to make sure I understand the intent.
> > > > > 
> > > > 
> > > > Yeah, the default policy should be to fallback to local memory if the node 
> > > > passed is memoryless.
> > > > 
> > > > > What I find odd is that there are only 2 nodes on this system, node 0
> > > > > (empty) and node 1. So won't numa_mem_id() always be 1? And every page
> > > > > should be coming from node 1 (thus node_match() should always be true?)
> > > > > 
> > > > 
> > > > The nice thing about slub is its debugging ability, what is 
> > > > /sys/kernel/slab/cache/objects showing in comparison between the two 
> > > > patches?
> > > 
> > > Ok, I finally got around to writing a script that compares the objects
> > > output from both kernels.
> > > 
> > > log1 is with CONFIG_HAVE_MEMORYLESS_NODES on, my kthread locality patch
> > > and Joonsoo's patch.
> > > 
> > > log2 is with CONFIG_HAVE_MEMORYLESS_NODES on, my kthread locality patch
> > > and Anton's patch.
> > > 
> > > slab                           objects    objects   percent
> > >                                log1       log2      change
> > > -----------------------------------------------------------
> > > :t-0000104                     71190      85680      20.353982 %
> > > UDP                            4352       3392       22.058824 %
> > > inode_cache                    54302      41923      22.796582 %
> > > fscache_cookie_jar             3276       2457       25.000000 %
> > > :t-0000896                     438        292        33.333333 %
> > > :t-0000080                     310401     195323     37.073978 %
> > > ext4_inode_cache               335        201        40.000000 %
> > > :t-0000192                     89408      128898     44.168307 %
> > > :t-0000184                     151300     81880      45.882353 %
> > > :t-0000512                     49698      73648      48.191074 %
> > > :at-0000192                    242867     120948     50.199904 %
> > > xfs_inode                      34350      15221      55.688501 %
> > > :t-0016384                     11005      17257      56.810541 %
> > > proc_inode_cache               103868     34717      66.575846 %
> > > tw_sock_TCP                    768        256        66.666667 %
> > > :t-0004096                     15240      25672      68.451444 %
> > > nfs_inode_cache                1008       315        68.750000 %
> > > :t-0001024                     14528      24720      70.154185 %
> > > :t-0032768                     655        1312       100.305344%
> > > :t-0002048                     14242      30720      115.700042%
> > > :t-0000640                     1020       2550       150.000000%
> > > :t-0008192                     10005      27905      178.910545%
> > > 
> > > FWIW, the configuration of this LPAR has slightly changed. It is now configured
> > > for maximally 400 CPUs, of which 200 are present. The result is that even with
> > > Joonsoo's patch (log1 above), we OOM pretty easily and Anton's slab usage
> > > script reports:
> > > 
> > > slab                                   mem     objs    slabs
> > >                                       used   active   active
> > > ------------------------------------------------------------
> > > kmalloc-512                        1182 MB    2.03%  100.00%
> > > kmalloc-192                        1182 MB    1.38%  100.00%
> > > kmalloc-16384                       966 MB   17.66%  100.00%
> > > kmalloc-4096                        353 MB   15.92%  100.00%
> > > kmalloc-8192                        259 MB   27.28%  100.00%
> > > kmalloc-32768                       207 MB    9.86%  100.00%
> > > 
> > > In comparison (log2 above):
> > > 
> > > slab                                   mem     objs    slabs
> > >                                       used   active   active
> > > ------------------------------------------------------------
> > > kmalloc-16384                       273 MB   98.76%  100.00%
> > > kmalloc-8192                        225 MB   98.67%  100.00%
> > > pgtable-2^11                        114 MB  100.00%  100.00%
> > > pgtable-2^12                        109 MB  100.00%  100.00%
> > > kmalloc-4096                        104 MB   98.59%  100.00%
> > > 
> > > I appreciate all the help so far, if anyone has any ideas how best to
> > > proceed further, or what they'd like debugged more, I'm happy to get
> > > this fixed. We're hitting this on a couple of different systems and I'd
> > > like to find a good resolution to the problem.
> > 
> > Hello,
> > 
> > I have no memoryless system, so, to debug it, I need your help. :)
> > First, please let me know node information on your system.
> 
> [    0.000000] Node 0 Memory:
> [    0.000000] Node 1 Memory: 0x0-0x200000000
> 
> [    0.000000] On node 0 totalpages: 0
> [    0.000000] On node 1 totalpages: 131072
> [    0.000000]   DMA zone: 112 pages used for memmap
> [    0.000000]   DMA zone: 0 pages reserved
> [    0.000000]   DMA zone: 131072 pages, LIFO batch:1
> 
> [    0.638391] Node 0 CPUs: 0-199
> [    0.638394] Node 1 CPUs:
> 
> Do you need anything else?
> 
> > I'm preparing 3 another patches which are nearly same with previous patch,
> > but slightly different approach. Could you test them on your system?
> > I will send them soon.
> 
> Test results are in the attached tarball [1].
> 
> > And I think that same problem exists if CONFIG_SLAB is enabled. Could you
> > confirm that?
> 
> I will test and let you know.

Ok, with your patches applied and CONFIG_SLAB enabled:

MemTotal:        8264640 kB
MemFree:         7119680 kB
Slab:             207232 kB
SReclaimable:      32896 kB
SUnreclaim:       174336 kB

For reference, same kernel with CONFIG_SLUB:

MemTotal:        8264640 kB
MemFree:         4264000 kB
Slab:            3065408 kB
SReclaimable:     104704 kB
SUnreclaim:      2960704 kB

So CONFIG_SLAB is much better in this case.

Without your patches (but still CONFIG_HAVE_MEMORYLESS_NODES, kthread
locality patch and two other unrelated bugfix patches):

3.13.0-slub:

MemTotal:        8264704 kB
MemFree:         4404288 kB
Slab:            2963648 kB
SReclaimable:     106816 kB
SUnreclaim:      2856832 kB

3.13.0-slab:

MemTotal:        8264640 kB
MemFree:         7263168 kB
Slab:             206144 kB
SReclaimable:      32576 kB
SUnreclaim:       173568 kB

In case it's helpful, I've attached /proc/slabinfo from both kernels.

Thanks,
Nish

--8P1HSweYDcXXzwPJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="slabusage.3.13.SLAB"

slab                                   mem     objs    slabs
                                      used   active   active
------------------------------------------------------------
thread_info                          34 MB   96.33%  100.00%
kmalloc-1024                         22 MB   97.44%  100.00%
task_struct                          19 MB   95.15%  100.00%
kmalloc-16384                         9 MB   98.05%  100.00%
inode_cache                           8 MB   97.74%  100.00%
kmalloc-512                           7 MB   89.56%  100.00%
dentry                                7 MB   98.89%  100.00%
kmalloc-8192                          6 MB   98.64%  100.00%
proc_inode_cache                      6 MB   90.20%  100.00%
idr_layer_cache                       4 MB   94.76%  100.00%
sighand_cache                         4 MB   94.69%  100.00%
pgtable-2^12                          3 MB   72.58%  100.00%
xfs_inode                             3 MB   98.89%  100.00%
sysfs_dir_cache                       3 MB   98.29%  100.00%
radix_tree_node                       2 MB   97.19%  100.00%
kmalloc-32768                         2 MB   97.96%  100.00%
kmalloc-4096                          2 MB   97.68%  100.00%
filp                                  2 MB   20.71%  100.00%
signal_cache                          2 MB   72.35%  100.00%
pgtable-2^10                          2 MB   52.81%  100.00%
kmalloc-256                           2 MB   85.56%  100.00%
kmalloc-2048                          1 MB   84.95%  100.00%
shmem_inode_cache                     1 MB   89.59%  100.00%
dtl                                   1 MB   98.77%  100.00%
kmalloc-192                           1 MB   77.89%  100.00%
vm_area_struct                        1 MB   76.80%  100.00%
cred_jar                              1 MB   36.80%  100.00%
kmem_cache                            1 MB   97.69%  100.00%
kmalloc-65536                         0 MB  100.00%  100.00%
kmalloc-128                           0 MB   87.07%  100.00%
buffer_head                           0 MB   92.52%  100.00%
kmalloc-32                            0 MB   92.89%  100.00%
anon_vma_chain                        0 MB   47.46%  100.00%
sock_inode_cache                      0 MB   65.45%  100.00%
kmalloc-64                            0 MB   94.98%  100.00%
files_cache                           0 MB   60.85%  100.00%
names_cache                           0 MB   85.83%  100.00%
mm_struct                             0 MB   22.06%  100.00%
xfs_buf                               0 MB   91.50%  100.00%
UNIX                                  0 MB   37.90%  100.00%
task_delay_info                       0 MB   66.76%  100.00%
skbuff_head_cache                     0 MB   50.33%  100.00%
pid                                   0 MB   62.63%  100.00%
RAW                                   0 MB   92.59%  100.00%
kmalloc-96                            0 MB   63.71%  100.00%
anon_vma                              0 MB   52.25%  100.00%
xfs_ifork                             0 MB   88.60%  100.00%
biovec-256                            0 MB   75.56%  100.00%
TCP                                   0 MB   19.66%  100.00%
ftrace_event_field                    0 MB   63.17%  100.00%
fs_cache                              0 MB   24.30%  100.00%
file_lock_cache                       0 MB    5.24%  100.00%
eventpoll_epi                         0 MB   13.21%  100.00%
cifs_request                          0 MB   71.43%  100.00%
cfq_queue                             0 MB   26.90%  100.00%
blkdev_queue                          0 MB   48.39%  100.00%
UDP                                   0 MB   12.50%  100.00%
xfs_trans                             0 MB    4.33%  100.00%
xfs_log_ticket                        0 MB    3.45%  100.00%
xfs_log_item_desc                     0 MB    2.42%  100.00%
xfs_ioend                             0 MB   84.65%  100.00%
xfs_ili                               0 MB   66.20%  100.00%
xfs_buf_item                          0 MB    7.94%  100.00%
xfs_btree_cur                         0 MB    1.94%  100.00%
uid_cache                             0 MB    1.61%  100.00%
tcp_bind_bucket                       0 MB    2.18%  100.00%
taskstats                             0 MB    3.55%  100.00%
sigqueue                              0 MB    0.75%  100.00%
sgpool-8                              0 MB    1.59%  100.00%
sgpool-64                             0 MB    6.45%  100.00%
sgpool-32                             0 MB    3.17%  100.00%
sgpool-16                             0 MB    1.57%  100.00%
sgpool-128                            0 MB   13.33%  100.00%
sd_ext_cdb                            0 MB    0.11%  100.00%
scsi_sense_cache                      0 MB    0.60%  100.00%
scsi_cmd_cache                        0 MB    1.19%  100.00%
rpc_tasks                             0 MB    3.17%  100.00%
rpc_inode_cache                       0 MB   31.68%  100.00%
rpc_buffers                           0 MB   25.81%  100.00%
revoke_table                          0 MB    0.12%  100.00%
pool_workqueue                        0 MB    4.37%  100.00%
numa_policy                           0 MB   46.75%  100.00%
nsproxy                               0 MB    0.16%  100.00%
nfs_write_data                        0 MB   50.79%  100.00%
nfs_inode_cache                       0 MB   27.69%  100.00%
nfs_commit_data                       0 MB    4.76%  100.00%
nf_conntrack_c000000000cc9900         0 MB   45.22%  100.00%
mqueue_inode_cache                    0 MB    1.39%  100.00%
mnt_cache                             0 MB   53.57%  100.00%
key_jar                               0 MB    5.56%  100.00%
jbd2_revoke_table_s                   0 MB    0.06%  100.00%
ip_fib_trie                           0 MB    0.73%  100.00%
ip_fib_alias                          0 MB    0.71%  100.00%
ip_dst_cache                          0 MB   30.16%  100.00%
inotify_inode_mark                    0 MB   17.23%  100.00%
inet_peer_cache                       0 MB    3.97%  100.00%
hugetlbfs_inode_cache                 0 MB    2.59%  100.00%
ftrace_event_file                     0 MB   92.58%  100.00%
fsnotify_event                        0 MB    0.18%  100.00%
ext4_inode_cache                      0 MB    4.35%  100.00%
ext4_groupinfo_4k                     0 MB    8.55%  100.00%
ext4_extent_status                    0 MB    0.07%  100.00%
ext3_inode_cache                      0 MB    4.76%  100.00%
eventpoll_pwq                         0 MB   15.20%  100.00%
dnotify_struct                        0 MB    0.60%  100.00%
dnotify_mark                          0 MB    2.08%  100.00%
dm_io                                 0 MB    2.28%  100.00%
cifs_small_rq                         0 MB   23.62%  100.00%
cifs_mpx_ids                          0 MB    0.60%  100.00%
cfq_io_cq                             0 MB   26.42%  100.00%
blkdev_requests                       0 MB   10.56%  100.00%
blkdev_ioc                            0 MB   19.31%  100.00%
biovec-16                             0 MB    1.19%  100.00%
bio-1                                 0 MB   13.49%  100.00%
bio-0                                 0 MB    1.59%  100.00%
bdev_cache                            0 MB   52.78%  100.00%
xfs_mru_cache_elem                    0 MB    0.00%    0.00%
xfs_icr                               0 MB    0.00%    0.00%
xfs_efi_item                          0 MB    0.00%    0.00%
xfs_efd_item                          0 MB    0.00%    0.00%
xfs_da_state                          0 MB    0.00%    0.00%
xfs_bmap_free_item                    0 MB    0.00%    0.00%
xfrm_dst_cache                        0 MB    0.00%    0.00%
tw_sock_TCP                           0 MB    0.00%    0.00%
skbuff_fclone_cache                   0 MB    0.00%    0.00%
shared_policy_node                    0 MB    0.00%    0.00%
secpath_cache                         0 MB    0.00%    0.00%
scsi_data_buffer                      0 MB    0.00%    0.00%
revoke_record                         0 MB    0.00%    0.00%
request_sock_TCP                      0 MB    0.00%    0.00%
reiser_inode_cache                    0 MB    0.00%    0.00%
posix_timers_cache                    0 MB    0.00%    0.00%
pid_namespace                         0 MB    0.00%    0.00%
nfsd_drc                              0 MB    0.00%    0.00%
nfsd4_stateids                        0 MB    0.00%    0.00%
nfsd4_openowners                      0 MB    0.00%    0.00%
nfsd4_lockowners                      0 MB    0.00%    0.00%
nfsd4_files                           0 MB    0.00%    0.00%
nfsd4_delegations                     0 MB    0.00%    0.00%
nfs_read_data                         0 MB    0.00%    0.00%
nfs_page                              0 MB    0.00%    0.00%
nfs_direct_cache                      0 MB    0.00%    0.00%
nf_conntrack_expect                   0 MB    0.00%    0.00%
net_namespace                         0 MB    0.00%    0.00%
kmalloc-8388608                       0 MB    0.00%    0.00%
kmalloc-524288                        0 MB    0.00%    0.00%
kmalloc-4194304                       0 MB    0.00%    0.00%
kmalloc-262144                        0 MB    0.00%    0.00%
kmalloc-2097152                       0 MB    0.00%    0.00%
kmalloc-16777216                      0 MB    0.00%    0.00%
kmalloc-131072                        0 MB    0.00%    0.00%
kmalloc-1048576                       0 MB    0.00%    0.00%
kioctx                                0 MB    0.00%    0.00%
kiocb                                 0 MB    0.00%    0.00%
kcopyd_job                            0 MB    0.00%    0.00%
journal_head                          0 MB    0.00%    0.00%
journal_handle                        0 MB    0.00%    0.00%
jbd2_transaction_s                    0 MB    0.00%    0.00%
jbd2_revoke_record_s                  0 MB    0.00%    0.00%
jbd2_journal_head                     0 MB    0.00%    0.00%
jbd2_journal_handle                   0 MB    0.00%    0.00%
jbd2_inode                            0 MB    0.00%    0.00%
jbd2_4k                               0 MB    0.00%    0.00%
isofs_inode_cache                     0 MB    0.00%    0.00%
io                                    0 MB    0.00%    0.00%
inotify_event_private_data            0 MB    0.00%    0.00%
fstrm_item                            0 MB    0.00%    0.00%
fsnotify_event_holder                 0 MB    0.00%    0.00%
flow_cache                            0 MB    0.00%    0.00%
fat_inode_cache                       0 MB    0.00%    0.00%
fat_cache                             0 MB    0.00%    0.00%
fasync_cache                          0 MB    0.00%    0.00%
ext4_xattr                            0 MB    0.00%    0.00%
ext4_system_zone                      0 MB    0.00%    0.00%
ext4_prealloc_space                   0 MB    0.00%    0.00%
ext4_io_end                           0 MB    0.00%    0.00%
ext4_free_data                        0 MB    0.00%    0.00%
ext4_allocation_context               0 MB    0.00%    0.00%
ext3_xattr                            0 MB    0.00%    0.00%
ext2_xattr                            0 MB    0.00%    0.00%
ext2_inode_cache                      0 MB    0.00%    0.00%
dma-kmalloc-96                        0 MB    0.00%    0.00%
dma-kmalloc-8388608                   0 MB    0.00%    0.00%
dma-kmalloc-8192                      0 MB    0.00%    0.00%
dma-kmalloc-65536                     0 MB    0.00%    0.00%
dma-kmalloc-64                        0 MB    0.00%    0.00%
dma-kmalloc-524288                    0 MB    0.00%    0.00%
dma-kmalloc-512                       0 MB    0.00%    0.00%
dma-kmalloc-4194304                   0 MB    0.00%    0.00%
dma-kmalloc-4096                      0 MB    0.00%    0.00%
dma-kmalloc-32768                     0 MB    0.00%    0.00%
dma-kmalloc-32                        0 MB    0.00%    0.00%
dma-kmalloc-262144                    0 MB    0.00%    0.00%
dma-kmalloc-256                       0 MB    0.00%    0.00%
dma-kmalloc-2097152                   0 MB    0.00%    0.00%
dma-kmalloc-2048                      0 MB    0.00%    0.00%
dma-kmalloc-192                       0 MB    0.00%    0.00%
dma-kmalloc-16777216                  0 MB    0.00%    0.00%
dma-kmalloc-16384                     0 MB    0.00%    0.00%
dma-kmalloc-131072                    0 MB    0.00%    0.00%
dma-kmalloc-128                       0 MB    0.00%    0.00%
dma-kmalloc-1048576                   0 MB    0.00%    0.00%
dma-kmalloc-1024                      0 MB    0.00%    0.00%
dm_uevent                             0 MB    0.00%    0.00%
dm_rq_target_io                       0 MB    0.00%    0.00%
dio                                   0 MB    0.00%    0.00%
cifs_inode_cache                      0 MB    0.00%    0.00%
bsg_cmd                               0 MB    0.00%    0.00%
biovec-64                             0 MB    0.00%    0.00%
biovec-128                            0 MB    0.00%    0.00%
UDP-Lite                              0 MB    0.00%    0.00%
PING                                  0 MB    0.00%    0.00%

--8P1HSweYDcXXzwPJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="slabusage.3.13.SLUB"

slab                                   mem     objs    slabs
                                      used   active   active
------------------------------------------------------------
kmalloc-16384                      1018 MB   14.09%  100.00%
task_struct                         704 MB   17.20%  100.00%
pgtable-2^12                        110 MB  100.00%  100.00%
kmalloc-8192                        109 MB   49.21%  100.00%
pgtable-2^10                        105 MB  100.00%  100.00%
kmalloc-65536                        92 MB  100.00%  100.00%
kmalloc-512                          83 MB   16.68%  100.00%
kmalloc-128                          75 MB   17.55%  100.00%
kmalloc-4096                         52 MB   97.30%  100.00%
kmalloc-16                           38 MB   24.78%  100.00%
kmalloc-256                          33 MB   99.09%  100.00%
kmalloc-1024                         27 MB   60.45%  100.00%
sighand_cache                        27 MB  100.00%  100.00%
idr_layer_cache                      25 MB  100.00%  100.00%
kmalloc-2048                         25 MB   97.59%  100.00%
dentry                               23 MB  100.00%  100.00%
inode_cache                          20 MB  100.00%  100.00%
proc_inode_cache                     19 MB  100.00%  100.00%
sysfs_dir_cache                      16 MB  100.00%  100.00%
vm_area_struct                       14 MB  100.00%  100.00%
kmalloc-64                           14 MB   97.79%  100.00%
kmalloc-192                          13 MB   97.60%  100.00%
kmalloc-32                           12 MB   97.56%  100.00%
anon_vma                             12 MB  100.00%  100.00%
mm_struct                            12 MB  100.00%  100.00%
sigqueue                             12 MB  100.00%  100.00%
files_cache                          12 MB  100.00%  100.00%
cfq_queue                            11 MB  100.00%  100.00%
radix_tree_node                      11 MB  100.00%  100.00%
kmalloc-96                           10 MB   97.06%  100.00%
blkdev_requests                      10 MB  100.00%  100.00%
xfs_inode                             9 MB  100.00%  100.00%
shmem_inode_cache                     9 MB  100.00%  100.00%
ext4_system_zone                      9 MB  100.00%  100.00%
sock_inode_cache                      9 MB  100.00%  100.00%
RAW                                   8 MB  100.00%  100.00%
kmalloc-8                             8 MB  100.00%  100.00%
kmalloc-32768                         8 MB  100.00%  100.00%
blkdev_ioc                            7 MB  100.00%  100.00%
buffer_head                           6 MB  100.00%  100.00%
xfs_da_state                          6 MB  100.00%  100.00%
mnt_cache                             6 MB  100.00%  100.00%
numa_policy                           6 MB  100.00%  100.00%
dnotify_mark                          4 MB  100.00%  100.00%
TCP                                   3 MB  100.00%  100.00%
cifs_request                          3 MB  100.00%  100.00%
UDP                                   3 MB  100.00%  100.00%
xfs_ili                               3 MB  100.00%  100.00%
xfs_btree_cur                         3 MB  100.00%  100.00%
nf_conntrack_c000000000cb5480         2 MB  100.00%  100.00%
fsnotify_event_holder                 1 MB  100.00%  100.00%
dm_rq_target_io                       1 MB  100.00%  100.00%
bdev_cache                            1 MB  100.00%  100.00%
kmem_cache                            1 MB   89.09%  100.00%
blkdev_queue                          0 MB  100.00%  100.00%
dio                                   0 MB  100.00%  100.00%
taskstats                             0 MB  100.00%  100.00%
kmem_cache_node                       0 MB  100.00%  100.00%
shared_policy_node                    0 MB  100.00%  100.00%
rpc_inode_cache                       0 MB  100.00%  100.00%
nfs_inode_cache                       0 MB  100.00%  100.00%
revoke_table                          0 MB  100.00%  100.00%
ip_fib_trie                           0 MB  100.00%  100.00%
ext4_inode_cache                      0 MB  100.00%  100.00%
hugetlbfs_inode_cache                 0 MB  100.00%  100.00%
ext3_inode_cache                      0 MB  100.00%  100.00%
tw_sock_TCP                           0 MB  100.00%  100.00%
mqueue_inode_cache                    0 MB  100.00%  100.00%
ext4_extent_status                    0 MB  100.00%  100.00%
ext4_allocation_context               0 MB  100.00%  100.00%
xfs_icr                               0 MB    0.00%    0.00%
revoke_record                         0 MB    0.00%    0.00%
reiser_inode_cache                    0 MB    0.00%    0.00%
posix_timers_cache                    0 MB    0.00%    0.00%
pid_namespace                         0 MB    0.00%    0.00%
nfsd4_openowners                      0 MB    0.00%    0.00%
nfsd4_delegations                     0 MB    0.00%    0.00%
nfs_direct_cache                      0 MB    0.00%    0.00%
net_namespace                         0 MB    0.00%    0.00%
kmalloc-131072                        0 MB    0.00%    0.00%
kcopyd_job                            0 MB    0.00%    0.00%
journal_head                          0 MB    0.00%    0.00%
journal_handle                        0 MB    0.00%    0.00%
jbd2_transaction_s                    0 MB    0.00%    0.00%
jbd2_journal_handle                   0 MB    0.00%    0.00%
isofs_inode_cache                     0 MB    0.00%    0.00%
fat_inode_cache                       0 MB    0.00%    0.00%
fat_cache                             0 MB    0.00%    0.00%
ext4_io_end                           0 MB    0.00%    0.00%
ext4_free_data                        0 MB    0.00%    0.00%
ext3_xattr                            0 MB    0.00%    0.00%
ext2_inode_cache                      0 MB    0.00%    0.00%
dma-kmalloc-96                        0 MB    0.00%    0.00%
dma-kmalloc-8192                      0 MB    0.00%    0.00%
dma-kmalloc-8                         0 MB    0.00%    0.00%
dma-kmalloc-65536                     0 MB    0.00%    0.00%
dma-kmalloc-64                        0 MB    0.00%    0.00%
dma-kmalloc-512                       0 MB    0.00%    0.00%
dma-kmalloc-4096                      0 MB    0.00%    0.00%
dma-kmalloc-32768                     0 MB    0.00%    0.00%
dma-kmalloc-32                        0 MB    0.00%    0.00%
dma-kmalloc-256                       0 MB    0.00%    0.00%
dma-kmalloc-2048                      0 MB    0.00%    0.00%
dma-kmalloc-192                       0 MB    0.00%    0.00%
dma-kmalloc-16384                     0 MB    0.00%    0.00%
dma-kmalloc-16                        0 MB    0.00%    0.00%
dma-kmalloc-131072                    0 MB    0.00%    0.00%
dma-kmalloc-128                       0 MB    0.00%    0.00%
dma-kmalloc-1024                      0 MB    0.00%    0.00%
dm_uevent                             0 MB    0.00%    0.00%
cifs_inode_cache                      0 MB    0.00%    0.00%
bsg_cmd                               0 MB    0.00%    0.00%
UDP-Lite                              0 MB    0.00%    0.00%

--8P1HSweYDcXXzwPJ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
