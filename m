Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3AB256B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 02:42:03 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id v10so7240097pde.27
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 23:42:02 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id mj6si17999048pab.304.2014.02.10.23.42.01
        for <linux-mm@kvack.org>;
        Mon, 10 Feb 2014 23:42:02 -0800 (PST)
Date: Tue, 11 Feb 2014 16:42:00 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for
 determining the fallback node
Message-ID: <20140211074159.GB27870@lge.com>
References: <20140206020757.GC5433@linux.vnet.ibm.com>
 <1391674026-20092-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1391674026-20092-2-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.02.1402060041040.21148@chino.kir.corp.google.com>
 <CAAmzW4PXkdpNi5pZ=4BzdXNvqTEAhcuw-x0pWidqrxzdePxXxA@mail.gmail.com>
 <alpine.DEB.2.02.1402061248450.9567@chino.kir.corp.google.com>
 <20140207054819.GC28952@lge.com>
 <alpine.DEB.2.10.1402071150090.15168@nuc>
 <alpine.DEB.2.10.1402071245040.20246@nuc>
 <20140210191321.GD1558@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140210191321.GD1558@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Mon, Feb 10, 2014 at 11:13:21AM -0800, Nishanth Aravamudan wrote:
> Hi Christoph,
> 
> On 07.02.2014 [12:51:07 -0600], Christoph Lameter wrote:
> > Here is a draft of a patch to make this work with memoryless nodes.
> > 
> > The first thing is that we modify node_match to also match if we hit an
> > empty node. In that case we simply take the current slab if its there.
> > 
> > If there is no current slab then a regular allocation occurs with the
> > memoryless node. The page allocator will fallback to a possible node and
> > that will become the current slab. Next alloc from a memoryless node
> > will then use that slab.
> > 
> > For that we also add some tracking of allocations on nodes that were not
> > satisfied using the empty_node[] array. A successful alloc on a node
> > clears that flag.
> > 
> > I would rather avoid the empty_node[] array since its global and there may
> > be thread specific allocation restrictions but it would be expensive to do
> > an allocation attempt via the page allocator to make sure that there is
> > really no page available from the page allocator.
> 
> With this patch on our test system (I pulled out the numa_mem_id()
> change, since you Acked Joonsoo's already), on top of 3.13.0 + my
> kthread locality change + CONFIG_HAVE_MEMORYLESS_NODES + Joonsoo's RFC
> patch 1):
> 
> MemTotal:        8264704 kB
> MemFree:         5924608 kB
> ...
> Slab:            1402496 kB
> SReclaimable:     102848 kB
> SUnreclaim:      1299648 kB
> 
> And Anton's slabusage reports:
> 
> slab                                   mem     objs    slabs
>                                       used   active   active
> ------------------------------------------------------------
> kmalloc-16384                       207 MB   98.60%  100.00%
> task_struct                         134 MB   97.82%  100.00%
> kmalloc-8192                        117 MB  100.00%  100.00%
> pgtable-2^12                        111 MB  100.00%  100.00%
> pgtable-2^10                        104 MB  100.00%  100.00%
> 
> For comparison, Anton's patch applied at the same point in the series:
> 
> meminfo:
> 
> MemTotal:        8264704 kB
> MemFree:         4150464 kB
> ...
> Slab:            1590336 kB
> SReclaimable:     208768 kB
> SUnreclaim:      1381568 kB
> 
> slabusage:
> 
> slab                                   mem     objs    slabs
>                                       used   active   active
> ------------------------------------------------------------
> kmalloc-16384                       227 MB   98.63%  100.00%
> kmalloc-8192                        130 MB  100.00%  100.00%
> task_struct                         129 MB   97.73%  100.00%
> pgtable-2^12                        112 MB  100.00%  100.00%
> pgtable-2^10                        106 MB  100.00%  100.00%
> 
> 
> Consider this patch:
> 
> Acked-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
> Tested-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>

Hello,

I still think that there is another problem.
Your report about CONFIG_SLAB said that SLAB uses just 200MB.
Below is your previous report.

  Ok, with your patches applied and CONFIG_SLAB enabled:

  MemTotal:        8264640 kB
  MemFree:         7119680 kB
  Slab:             207232 kB
  SReclaimable:      32896 kB
  SUnreclaim:       174336 kB

The number on CONFIG_SLUB with these patches tell us that SLUB uses 1.4GB.
There is large difference on slab usage.

And, I should note that number of active objects on slabinfo can be wrong
on some situation, since it doesn't consider cpu slab (and cpu partial slab).

I recommend to confirm page_to_nid() and other things as I mentioned earlier.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
