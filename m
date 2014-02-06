Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id EAEB16B0035
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 21:08:13 -0500 (EST)
Received: by mail-qc0-f180.google.com with SMTP id i17so2162218qcy.11
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 18:08:13 -0800 (PST)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id jj3si1792598qcb.38.2014.02.05.18.08.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 05 Feb 2014 18:08:13 -0800 (PST)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Wed, 5 Feb 2014 19:08:11 -0700
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 8E57E38C804F
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 21:08:09 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp22036.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s162890v7274822
	for <linux-mm@kvack.org>; Thu, 6 Feb 2014 02:08:09 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s16289Hm000791
	for <linux-mm@kvack.org>; Wed, 5 Feb 2014 21:08:09 -0500
Date: Wed, 5 Feb 2014 18:07:57 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
Message-ID: <20140206020757.GC5433@linux.vnet.ibm.com>
References: <52dce7fe.e5e6420a.5ff6.ffff84a0SMTPIN_ADDED_BROKEN@mx.google.com>
 <alpine.DEB.2.10.1401201612340.28048@nuc>
 <52e1d960.2715420a.3569.1013SMTPIN_ADDED_BROKEN@mx.google.com>
 <52e1da8f.86f7440a.120f.25f3SMTPIN_ADDED_BROKEN@mx.google.com>
 <alpine.DEB.2.10.1401240946530.12886@nuc>
 <alpine.DEB.2.02.1401241301120.10968@chino.kir.corp.google.com>
 <20140124232902.GB30361@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1401241543100.18620@chino.kir.corp.google.com>
 <20140125001643.GA25344@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1401241618500.20466@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1401241618500.20466@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Han Pingtian <hanpt@linux.vnet.ibm.com>, penberg@kernel.org, linux-mm@kvack.org, paulus@samba.org, Anton Blanchard <anton@samba.org>, mpm@selenic.com, Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On 24.01.2014 [16:25:58 -0800], David Rientjes wrote:
> On Fri, 24 Jan 2014, Nishanth Aravamudan wrote:
> 
> > Thank you for clarifying and providing  a test patch. I ran with this on
> > the system showing the original problem, configured to have 15GB of
> > memory.
> > 
> > With your patch after boot:
> > 
> > MemTotal:       15604736 kB
> > MemFree:         8768192 kB
> > Slab:            3882560 kB
> > SReclaimable:     105408 kB
> > SUnreclaim:      3777152 kB
> > 
> > With Anton's patch after boot:
> > 
> > MemTotal:       15604736 kB
> > MemFree:        11195008 kB
> > Slab:            1427968 kB
> > SReclaimable:     109184 kB
> > SUnreclaim:      1318784 kB
> > 
> > 
> > I know that's fairly unscientific, but the numbers are reproducible. 
> > 
> 
> I don't think the goal of the discussion is to reduce the amount of slab 
> allocated, but rather get the most local slab memory possible by use of 
> kmalloc_node().  When a memoryless node is being passed to kmalloc_node(), 
> which is probably cpu_to_node() for a cpu bound to a node without memory, 
> my patch is allocating it on the most local node; Anton's patch is 
> allocating it on whatever happened to be the cpu slab.
> 
> > > diff --git a/mm/slub.c b/mm/slub.c
> > > --- a/mm/slub.c
> > > +++ b/mm/slub.c
> > > @@ -2278,10 +2278,14 @@ redo:
> > > 
> > >  	if (unlikely(!node_match(page, node))) {
> > >  		stat(s, ALLOC_NODE_MISMATCH);
> > > -		deactivate_slab(s, page, c->freelist);
> > > -		c->page = NULL;
> > > -		c->freelist = NULL;
> > > -		goto new_slab;
> > > +		if (unlikely(!node_present_pages(node)))
> > > +			node = numa_mem_id();
> > > +		if (!node_match(page, node)) {
> > > +			deactivate_slab(s, page, c->freelist);
> > > +			c->page = NULL;
> > > +			c->freelist = NULL;
> > > +			goto new_slab;
> > > +		}
> > 
> > Semantically, and please correct me if I'm wrong, this patch is saying
> > if we have a memoryless node, we expect the page's locality to be that
> > of numa_mem_id(), and we still deactivate the slab if that isn't true.
> > Just wanting to make sure I understand the intent.
> > 
> 
> Yeah, the default policy should be to fallback to local memory if the node 
> passed is memoryless.
> 
> > What I find odd is that there are only 2 nodes on this system, node 0
> > (empty) and node 1. So won't numa_mem_id() always be 1? And every page
> > should be coming from node 1 (thus node_match() should always be true?)
> > 
> 
> The nice thing about slub is its debugging ability, what is 
> /sys/kernel/slab/cache/objects showing in comparison between the two 
> patches?

Ok, I finally got around to writing a script that compares the objects
output from both kernels.

log1 is with CONFIG_HAVE_MEMORYLESS_NODES on, my kthread locality patch
and Joonsoo's patch.

log2 is with CONFIG_HAVE_MEMORYLESS_NODES on, my kthread locality patch
and Anton's patch.

slab                           objects    objects   percent
                               log1       log2      change
-----------------------------------------------------------
:t-0000104                     71190      85680      20.353982 %
UDP                            4352       3392       22.058824 %
inode_cache                    54302      41923      22.796582 %
fscache_cookie_jar             3276       2457       25.000000 %
:t-0000896                     438        292        33.333333 %
:t-0000080                     310401     195323     37.073978 %
ext4_inode_cache               335        201        40.000000 %
:t-0000192                     89408      128898     44.168307 %
:t-0000184                     151300     81880      45.882353 %
:t-0000512                     49698      73648      48.191074 %
:at-0000192                    242867     120948     50.199904 %
xfs_inode                      34350      15221      55.688501 %
:t-0016384                     11005      17257      56.810541 %
proc_inode_cache               103868     34717      66.575846 %
tw_sock_TCP                    768        256        66.666667 %
:t-0004096                     15240      25672      68.451444 %
nfs_inode_cache                1008       315        68.750000 %
:t-0001024                     14528      24720      70.154185 %
:t-0032768                     655        1312       100.305344%
:t-0002048                     14242      30720      115.700042%
:t-0000640                     1020       2550       150.000000%
:t-0008192                     10005      27905      178.910545%

FWIW, the configuration of this LPAR has slightly changed. It is now configured
for maximally 400 CPUs, of which 200 are present. The result is that even with
Joonsoo's patch (log1 above), we OOM pretty easily and Anton's slab usage
script reports:

slab                                   mem     objs    slabs
                                      used   active   active
------------------------------------------------------------
kmalloc-512                        1182 MB    2.03%  100.00%
kmalloc-192                        1182 MB    1.38%  100.00%
kmalloc-16384                       966 MB   17.66%  100.00%
kmalloc-4096                        353 MB   15.92%  100.00%
kmalloc-8192                        259 MB   27.28%  100.00%
kmalloc-32768                       207 MB    9.86%  100.00%

In comparison (log2 above):

slab                                   mem     objs    slabs
                                      used   active   active
------------------------------------------------------------
kmalloc-16384                       273 MB   98.76%  100.00%
kmalloc-8192                        225 MB   98.67%  100.00%
pgtable-2^11                        114 MB  100.00%  100.00%
pgtable-2^12                        109 MB  100.00%  100.00%
kmalloc-4096                        104 MB   98.59%  100.00%

I appreciate all the help so far, if anyone has any ideas how best to
proceed further, or what they'd like debugged more, I'm happy to get
this fixed. We're hitting this on a couple of different systems and I'd
like to find a good resolution to the problem.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
