Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 947A16B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 03:03:14 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa1so2871442pad.0
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 00:03:14 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id sj5si3996542pab.313.2014.02.07.00.03.11
        for <linux-mm@kvack.org>;
        Fri, 07 Feb 2014 00:03:12 -0800 (PST)
Date: Fri, 7 Feb 2014 17:03:09 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
Message-ID: <20140207080309.GA29393@lge.com>
References: <alpine.DEB.2.10.1401240946530.12886@nuc>
 <alpine.DEB.2.02.1401241301120.10968@chino.kir.corp.google.com>
 <20140124232902.GB30361@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1401241543100.18620@chino.kir.corp.google.com>
 <20140125001643.GA25344@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1401241618500.20466@chino.kir.corp.google.com>
 <20140206020757.GC5433@linux.vnet.ibm.com>
 <20140206080418.GA19913@lge.com>
 <20140206185955.GA7845@linux.vnet.ibm.com>
 <20140206192812.GC7845@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140206192812.GC7845@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, penberg@kernel.org, linux-mm@kvack.org, paulus@samba.org, Anton Blanchard <anton@samba.org>, mpm@selenic.com, Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Thu, Feb 06, 2014 at 11:28:12AM -0800, Nishanth Aravamudan wrote:
> On 06.02.2014 [10:59:55 -0800], Nishanth Aravamudan wrote:
> > On 06.02.2014 [17:04:18 +0900], Joonsoo Kim wrote:
> > > On Wed, Feb 05, 2014 at 06:07:57PM -0800, Nishanth Aravamudan wrote:
> > > > On 24.01.2014 [16:25:58 -0800], David Rientjes wrote:
> > > > > On Fri, 24 Jan 2014, Nishanth Aravamudan wrote:
> > > > > 
> > > > > > Thank you for clarifying and providing  a test patch. I ran with this on
> > > > > > the system showing the original problem, configured to have 15GB of
> > > > > > memory.
> > > > > > 
> > > > > > With your patch after boot:
> > > > > > 
> > > > > > MemTotal:       15604736 kB
> > > > > > MemFree:         8768192 kB
> > > > > > Slab:            3882560 kB
> > > > > > SReclaimable:     105408 kB
> > > > > > SUnreclaim:      3777152 kB
> > > > > > 
> > > > > > With Anton's patch after boot:
> > > > > > 
> > > > > > MemTotal:       15604736 kB
> > > > > > MemFree:        11195008 kB
> > > > > > Slab:            1427968 kB
> > > > > > SReclaimable:     109184 kB
> > > > > > SUnreclaim:      1318784 kB
> > > > > > 
> > > > > > 
> > > > > > I know that's fairly unscientific, but the numbers are reproducible. 
> > > > > > 
> > > > > 
> > > > > I don't think the goal of the discussion is to reduce the amount of slab 
> > > > > allocated, but rather get the most local slab memory possible by use of 
> > > > > kmalloc_node().  When a memoryless node is being passed to kmalloc_node(), 
> > > > > which is probably cpu_to_node() for a cpu bound to a node without memory, 
> > > > > my patch is allocating it on the most local node; Anton's patch is 
> > > > > allocating it on whatever happened to be the cpu slab.
> > > > > 
> > > > > > > diff --git a/mm/slub.c b/mm/slub.c
> > > > > > > --- a/mm/slub.c
> > > > > > > +++ b/mm/slub.c
> > > > > > > @@ -2278,10 +2278,14 @@ redo:
> > > > > > > 
> > > > > > >  	if (unlikely(!node_match(page, node))) {
> > > > > > >  		stat(s, ALLOC_NODE_MISMATCH);
> > > > > > > -		deactivate_slab(s, page, c->freelist);
> > > > > > > -		c->page = NULL;
> > > > > > > -		c->freelist = NULL;
> > > > > > > -		goto new_slab;
> > > > > > > +		if (unlikely(!node_present_pages(node)))
> > > > > > > +			node = numa_mem_id();
> > > > > > > +		if (!node_match(page, node)) {
> > > > > > > +			deactivate_slab(s, page, c->freelist);
> > > > > > > +			c->page = NULL;
> > > > > > > +			c->freelist = NULL;
> > > > > > > +			goto new_slab;
> > > > > > > +		}
> > > > > > 
> > > > > > Semantically, and please correct me if I'm wrong, this patch is saying
> > > > > > if we have a memoryless node, we expect the page's locality to be that
> > > > > > of numa_mem_id(), and we still deactivate the slab if that isn't true.
> > > > > > Just wanting to make sure I understand the intent.
> > > > > > 
> > > > > 
> > > > > Yeah, the default policy should be to fallback to local memory if the node 
> > > > > passed is memoryless.
> > > > > 
> > > > > > What I find odd is that there are only 2 nodes on this system, node 0
> > > > > > (empty) and node 1. So won't numa_mem_id() always be 1? And every page
> > > > > > should be coming from node 1 (thus node_match() should always be true?)
> > > > > > 
> > > > > 
> > > > > The nice thing about slub is its debugging ability, what is 
> > > > > /sys/kernel/slab/cache/objects showing in comparison between the two 
> > > > > patches?
> > > > 
> > > > Ok, I finally got around to writing a script that compares the objects
> > > > output from both kernels.
> > > > 
> > > > log1 is with CONFIG_HAVE_MEMORYLESS_NODES on, my kthread locality patch
> > > > and Joonsoo's patch.
> > > > 
> > > > log2 is with CONFIG_HAVE_MEMORYLESS_NODES on, my kthread locality patch
> > > > and Anton's patch.
> > > > 
> > > > slab                           objects    objects   percent
> > > >                                log1       log2      change
> > > > -----------------------------------------------------------
> > > > :t-0000104                     71190      85680      20.353982 %
> > > > UDP                            4352       3392       22.058824 %
> > > > inode_cache                    54302      41923      22.796582 %
> > > > fscache_cookie_jar             3276       2457       25.000000 %
> > > > :t-0000896                     438        292        33.333333 %
> > > > :t-0000080                     310401     195323     37.073978 %
> > > > ext4_inode_cache               335        201        40.000000 %
> > > > :t-0000192                     89408      128898     44.168307 %
> > > > :t-0000184                     151300     81880      45.882353 %
> > > > :t-0000512                     49698      73648      48.191074 %
> > > > :at-0000192                    242867     120948     50.199904 %
> > > > xfs_inode                      34350      15221      55.688501 %
> > > > :t-0016384                     11005      17257      56.810541 %
> > > > proc_inode_cache               103868     34717      66.575846 %
> > > > tw_sock_TCP                    768        256        66.666667 %
> > > > :t-0004096                     15240      25672      68.451444 %
> > > > nfs_inode_cache                1008       315        68.750000 %
> > > > :t-0001024                     14528      24720      70.154185 %
> > > > :t-0032768                     655        1312       100.305344%
> > > > :t-0002048                     14242      30720      115.700042%
> > > > :t-0000640                     1020       2550       150.000000%
> > > > :t-0008192                     10005      27905      178.910545%
> > > > 
> > > > FWIW, the configuration of this LPAR has slightly changed. It is now configured
> > > > for maximally 400 CPUs, of which 200 are present. The result is that even with
> > > > Joonsoo's patch (log1 above), we OOM pretty easily and Anton's slab usage
> > > > script reports:
> > > > 
> > > > slab                                   mem     objs    slabs
> > > >                                       used   active   active
> > > > ------------------------------------------------------------
> > > > kmalloc-512                        1182 MB    2.03%  100.00%
> > > > kmalloc-192                        1182 MB    1.38%  100.00%
> > > > kmalloc-16384                       966 MB   17.66%  100.00%
> > > > kmalloc-4096                        353 MB   15.92%  100.00%
> > > > kmalloc-8192                        259 MB   27.28%  100.00%
> > > > kmalloc-32768                       207 MB    9.86%  100.00%
> > > > 
> > > > In comparison (log2 above):
> > > > 
> > > > slab                                   mem     objs    slabs
> > > >                                       used   active   active
> > > > ------------------------------------------------------------
> > > > kmalloc-16384                       273 MB   98.76%  100.00%
> > > > kmalloc-8192                        225 MB   98.67%  100.00%
> > > > pgtable-2^11                        114 MB  100.00%  100.00%
> > > > pgtable-2^12                        109 MB  100.00%  100.00%
> > > > kmalloc-4096                        104 MB   98.59%  100.00%
> > > > 
> > > > I appreciate all the help so far, if anyone has any ideas how best to
> > > > proceed further, or what they'd like debugged more, I'm happy to get
> > > > this fixed. We're hitting this on a couple of different systems and I'd
> > > > like to find a good resolution to the problem.
> > > 
> > > Hello,
> > > 
> > > I have no memoryless system, so, to debug it, I need your help. :)
> > > First, please let me know node information on your system.
> > 
> > [    0.000000] Node 0 Memory:
> > [    0.000000] Node 1 Memory: 0x0-0x200000000
> > 
> > [    0.000000] On node 0 totalpages: 0
> > [    0.000000] On node 1 totalpages: 131072
> > [    0.000000]   DMA zone: 112 pages used for memmap
> > [    0.000000]   DMA zone: 0 pages reserved
> > [    0.000000]   DMA zone: 131072 pages, LIFO batch:1
> > 
> > [    0.638391] Node 0 CPUs: 0-199
> > [    0.638394] Node 1 CPUs:
> > 
> > Do you need anything else?
> > 
> > > I'm preparing 3 another patches which are nearly same with previous patch,
> > > but slightly different approach. Could you test them on your system?
> > > I will send them soon.
> > 
> > Test results are in the attached tarball [1].
> > 
> > > And I think that same problem exists if CONFIG_SLAB is enabled. Could you
> > > confirm that?
> > 
> > I will test and let you know.
> 
> Ok, with your patches applied and CONFIG_SLAB enabled:
> 
> MemTotal:        8264640 kB
> MemFree:         7119680 kB
> Slab:             207232 kB
> SReclaimable:      32896 kB
> SUnreclaim:       174336 kB
> 
> For reference, same kernel with CONFIG_SLUB:
> 
> MemTotal:        8264640 kB
> MemFree:         4264000 kB
> Slab:            3065408 kB
> SReclaimable:     104704 kB
> SUnreclaim:      2960704 kB
> 


Hello,

First of all, thanks for testing!

My patch only affects CONFIG_SLUB. Request to test on CONFIG_SLAB is just
for reference. It seems that my patches doesn't have any effect to your case.
Could you check that numa_mem_id() and get_numa_mem() returns correctly?
I think that numa_mem_id() for all cpus and get_numa_mem() for all nodes
should return 1 on your system.

I will investigate further on my side.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
