Date: Fri, 8 Jun 2007 13:13:03 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] numa: mempolicy: dynamic interleave map for system init.
Message-ID: <20070608041303.GA13603@linux-sh.org>
References: <20070607011701.GA14211@linux-sh.org> <20070607180108.0eeca877.akpm@linux-foundation.org> <Pine.LNX.4.64.0706071942240.26636@schroedinger.engr.sgi.com> <20070608032505.GA13227@linux-sh.org> <Pine.LNX.4.64.0706072027300.27295@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706072027300.27295@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, ak@suse.de, hugh@veritas.com, lee.schermerhorn@hp.com, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

On Thu, Jun 07, 2007 at 08:49:53PM -0700, Christoph Lameter wrote:
> On Fri, 8 Jun 2007, Paul Mundt wrote:
> 
> > obviously possible to try to work that in to SLOB or something similar,
> > if making SLUB or SLAB lighterweight and more tunable for these cases
> > ends up being a real barrier.
> 
> Its obviously possible and as far as I can tell the architecture you have 
> there requires it to operate. But the question is how much special casing 
> we will have to add to the core VM.
> 
> We would likely have to add a 
> 
> slub_nodes=
> 
> parameter that allows the specification of a nodelist that is allowed for 
> the slab allocator. Then modify slub to use its own nodemap instead of 
> the node online map. Modify get_partial_node to not try a node not in the 
> nodemap and go to get_any_partial immediately. In addition to checking 
> cpuset_zone_allowed we would need to check the slab node list.
> 
> Hmm.... That would also help to create isolated nodes that have no memory 
> on them.
> 
> See what evil things you drive me to...
> 
> Could you try this patch (untested)? Set the allowed nodes on boot
> with
> 
> slub_nodes=0
> 
> if you have only node 0 for SLUB.
> 
Yes, that works better (Note that node 1 interleave is disabled in both cases):

With patch:
/ # cat /sys/devices/system/node/node1/meminfo

Node 1 MemTotal:          128 kB
Node 1 MemFree:            72 kB
Node 1 MemUsed:            56 kB
Node 1 Active:              0 kB
Node 1 Inactive:            0 kB
Node 1 Dirty:               0 kB
Node 1 Writeback:           0 kB
Node 1 FilePages:           0 kB
Node 1 Mapped:              0 kB
Node 1 AnonPages:           0 kB
Node 1 PageTables:          0 kB
Node 1 NFS_Unstable:        0 kB
Node 1 Bounce:              0 kB
Node 1 Slab:                0 kB
Node 1 SReclaimable:        0 kB
Node 1 SUnreclaim:          0 kB
Node 1 HugePages_Total:     0
Node 1 HugePages_Free:      0

[  117.216293] Node 0 Normal free:55900kB min:1016kB low:1268kB high:1524kB active:692kB inactive:536kB present:65024kB pages_scanned:0 all_unreclaimable? no
[  117.230029] lowmem_reserve[]: 0
[  117.233140] Node 1 Normal free:72kB min:0kB low:0kB high:0kB active:0kB inactive:0kB present:128kB pages_scanned:0 all_unreclaimable? no
[  117.245322] lowmem_reserve[]: 0
[  117.248434] Node 0 Normal: 1*4kB 5*8kB 3*16kB 0*32kB 0*64kB 0*128kB 0*256kB 1*512kB 0*1024kB 1*2048kB 13*4096kB = 55900kB
[  117.259320] Node 1 Normal: 2*4kB 0*8kB 0*16kB 0*32kB 1*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 72kB

Without:
/ # cat /sys/devices/system/node/node1/meminfo

Node 1 MemTotal:          128 kB
Node 1 MemFree:            64 kB
Node 1 MemUsed:            64 kB
Node 1 Active:              0 kB
Node 1 Inactive:            0 kB
Node 1 Dirty:               0 kB
Node 1 Writeback:           0 kB
Node 1 FilePages:           0 kB
Node 1 Mapped:              0 kB
Node 1 AnonPages:           0 kB
Node 1 PageTables:          0 kB
Node 1 NFS_Unstable:        0 kB
Node 1 Bounce:              0 kB
Node 1 Slab:                8 kB
Node 1 SReclaimable:        0 kB
Node 1 SUnreclaim:          8 kB
Node 1 HugePages_Total:     0
Node 1 HugePages_Free:      0

[   87.000717] Node 0 Normal free:55912kB min:1016kB low:1268kB high:1524kB active:668kB inactive:556kB present:65024kB pages_scanned:0 all_unreclaimable? no
[   87.014453] lowmem_reserve[]: 0
[   87.017565] Node 1 Normal free:64kB min:0kB low:0kB high:0kB active:0kB inactive:0kB present:128kB pages_scanned:0 all_unreclaimable? no
[   87.029746] lowmem_reserve[]: 0
[   87.032858] Node 0 Normal: 0*4kB 9*8kB 2*16kB 0*32kB 0*64kB 0*128kB 0*256kB 1*512kB 0*1024kB 1*2048kB 13*4096kB = 55912kB
[   87.043744] Node 1 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 1*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 64kB

So at least that gets back the couple of slab pages!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
