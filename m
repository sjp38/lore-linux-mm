Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id 672736B0039
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 17:43:27 -0400 (EDT)
Received: by mail-qa0-f46.google.com with SMTP id v10so338255qac.5
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 14:43:27 -0700 (PDT)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id ik5si608705qab.96.2014.07.22.14.43.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Jul 2014 14:43:26 -0700 (PDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Tue, 22 Jul 2014 15:43:25 -0600
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id AF6253E40048
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 15:43:22 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08025.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s6MLhMT810617258
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 23:43:22 +0200
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s6MLhMqZ019007
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 15:43:22 -0600
Date: Tue, 22 Jul 2014 14:43:11 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for
 determining the fallback node
Message-ID: <20140722214311.GM4156@linux.vnet.ibm.com>
References: <1391674026-20092-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1391674026-20092-2-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.02.1402060041040.21148@chino.kir.corp.google.com>
 <CAAmzW4PXkdpNi5pZ=4BzdXNvqTEAhcuw-x0pWidqrxzdePxXxA@mail.gmail.com>
 <alpine.DEB.2.02.1402061248450.9567@chino.kir.corp.google.com>
 <20140207054819.GC28952@lge.com>
 <alpine.DEB.2.02.1402080154140.9668@chino.kir.corp.google.com>
 <20140210010936.GA12574@lge.com>
 <20140722010305.GJ4156@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1407211809140.9778@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1407211809140.9778@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>

Hi David,

On 21.07.2014 [18:16:58 -0700], David Rientjes wrote:
> On Mon, 21 Jul 2014, Nishanth Aravamudan wrote:
> 
> > Sorry for bringing up this old thread again, but I had a question for
> > you, David. node_to_mem_node(), which does seem like a useful API,
> > doesn't seem like it can just node_distance() solely, right? Because
> > that just tells us the relative cost (or so I think about it) of using
> > resources from that node. But we also need to know if that node itself
> > has memory, etc. So using the zonelists is required no matter what? And
> > upon memory hotplug (or unplug), the topology can change in a way that
> > affects things, so node online time isn't right either?
> > 
> 
> I think there's two use cases of interest:
> 
>  - allocating from a memoryless node where numa_node_id() is memoryless, 
>    and
> 
>  - using node_to_mem_node() for a possibly-memoryless node for kmalloc().
> 
> I believe the first should have its own node_zonelist[0], whether it's 
> memoryless or not, that points to a list of zones that start with those 
> with the smallest distance.

Ok, and that would be used for falling back in the appropriate priority?

> I think its own node_zonelist[1], for __GFP_THISNODE allocations,
> should point to the node with present memory that has the smallest
> distance.

And so would this, but with the caveat that we can fail here and don't
go further? Semantically, __GFP_THISNODE then means "as close as
physically possible ignoring run-time memory constraints". I say that
because obviously we might get off-node memory without memoryless nodes,
but that shouldn't be used to satisfy __GPF_THISNODE allocations.

> For sure node_zonelist[0] cannot be NULL since things like 
> first_online_pgdat() would break and it should be unnecessary to do 
> node_to_mem_node() for all allocations when CONFIG_HAVE_MEMORYLESS_NODES 
> since the zonelists should already be defined properly.  All nodes, 
> regardless of whether they have memory or not, should probably end up 
> having a struct pglist_data unless there's a reason for another level of 
> indirection.

So I've re-tested Joonsoo's patch 2 and 3 from the series he sent, and
on powerpc now, things look really good. On a KVM instance with the
following topology:

available: 2 nodes (0-1)
node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49
node 0 size: 0 MB
node 0 free: 0 MB
node 1 cpus: 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99
node 1 size: 16336 MB
node 1 free: 14274 MB
node distances:
node   0   1 
  0:  10  40 
  1:  40  10 

3.16.0-rc6 gives:

        Slab:            1039744 kB
	SReclaimable:      38976 kB
	SUnreclaim:      1000768 kB

Joonsoo's patches give:

        Slab:             366144 kB
	SReclaimable:      36928 kB
	SUnreclaim:       329216 kB

For reference, CONFIG_SLAB gives:

        Slab:             122496 kB
	SReclaimable:      14912 kB
	SUnreclaim:       107584 kB

At Tejun's request [adding him to Cc], I also partially reverted
81c98869faa5 ("kthread: ensure locality of task_struct allocations"): 

	Slab:             428864 kB
	SReclaimable:      44288 kB
	SUnreclaim:       384576 kB

This seems slightly worse, but I think it's because of the same
root-cause that I indicated in my RFC patch 2/2, quoting it here:

"    There is an issue currently where NUMA information is used on powerpc
    (and possibly ia64) before it has been read from the device-tree, which
    leads to large slab consumption with CONFIG_SLUB and memoryless nodes.
    
    NUMA powerpc non-boot CPU's cpu_to_node/cpu_to_mem is only accurate
    after start_secondary(), similar to ia64, which is invoked via
    smp_init().
    
    Commit 6ee0578b4daae ("workqueue: mark init_workqueues() as
    early_initcall()") made init_workqueues() be invoked via
    do_pre_smp_initcalls(), which is obviously before the secondary
    processors are online.
    ...
    Therefore, when init_workqueues() runs, it sees all CPUs as being on
    Node 0. On LPARs or KVM guests where Node 0 is memoryless, this leads to
    a high number of slab deactivations
    (http://www.spinics.net/lists/linux-mm/msg67489.html)."

Christoph/Tejun, do you see the issue I'm referring to? Is my analysis
correct? It seems like regardless of CONFIG_USE_PERCPU_NUMA_NODE_ID, we
have to be especially careful that users of cpu_to_{node,mem} and
related APIs run *after* correct values are stored for all used CPUs?

In any case, with Joonsoo's patches, we shouldn't see slab deactivations
*if* the NUMA topology information is stored correctly. The full
changelog and patch is at http://patchwork.ozlabs.org/patch/371266/.

Adding my patch on top of Joonsoo's and the revert, I get:

	Slab:             411776 kB
	SReclaimable:      40960 kB
	SUnreclaim:       370816 kB

So CONFIG_SLUB still uses about 3x as much slab memory, but it's not so
much that we are close to OOM with small VM/LPAR sizes.

Thoughts?

I would like to push:

1) Joonsoo's patch to add get_numa_mem, renamed to node_to_mem_node(),
which is caching the result of local_memory_node() for each node.

2) Joonsoo's patch to use node_to_mem_node in __slab_alloc() and
get_partial() when memoryless nodes are encountered.

3) Partial revert of 81c98869faa5 ("kthread: ensure locality of
task_struct allocations") to remove a reference to cpu_to_mem() from the
kthread code. After this, the only references to cpu_to_mem() are in
headers, mm/slab.c, and kernel/profile.c (the last of which is because
of the use of alloc_pages_exact_node(), it seems).

4) Re-post of my patch to fix an ordering issue for the per-CPU NUMA
information on powerpc

I understand your concerns, I think, about Joonsoo's patches, but we're
hitting this pretty regularly in the field and it would be nice to have
something workable in the short-term, while I try and follow-up on these
more invasive ideas.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
