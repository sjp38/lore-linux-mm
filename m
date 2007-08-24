Message-Id: <20070824222654.687510000@sgi.com>
Date: Fri, 24 Aug 2007 15:26:54 -0700
From: travis@sgi.com
Subject: [PATCH 0/6] x86: Reduce Memory Usage and Inter-Node message traffic (v2)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Changes for version v2:

> > Note the addtional change of the cpu_llc_id type from u8
> > to int for ARCH x86_64 to correspond with ARCH i386.

> At least currently it cannot be more than 8 bit. So why
> waste memory? It would be better to change i386

Done.  (x86_64 type => u8).

> > Fix four instances where cpu_to_node is referenced
> > > by array instead of via the cpu_to_node macro.  This
> > > is preparation to moving it to the per_cpu data area.

> Shouldn't this patch be logically before the per cpu 
> conversion (which is 3/6). This way the result would
> be git bisectable.

Done.  (Moved to PATCH 1/6).

> > processor_core.c currently tries to determine the apicid by special casing
> > for IA64 and x86. The desired information is readily available via
> > 
> > 	    cpu_physical_id()
> > 
> > on IA64, i386 and x86_64.
> 
> Have you tried this with a !CONFIG_SMP build? The drivers/dma code was doing
> the same and running into problems because it wasn't defined there.

Fixed. (New export in PATCH 6/6).


Previous Intro:

In x86_64 and i386 architectures most arrays that are sized
using NR_CPUS lay in local memory on node 0.  Not only will most
(99%?) of the systems not use all the slots in these arrays,
particularly when NR_CPUS is increased to accommodate future
very high cpu count systems, but a number of cache lines are
passed unnecessarily on the system bus when these arrays are
referenced by cpus on other nodes.

Typically, the values in these arrays are referenced by the cpu
accessing it's own values, though when passing IPI interrupts,
the cpu does access the data relevant to the targeted cpu/node.
Of course, if the referencing cpu is not on node 0, then the
reference will still require cross node exchanges of cache
lines.  A common use of this is for an interrupt service
routine to pass the interrupt to other cpus local to that node.

Ideally, all the elements in these arrays should be moved to the
per_cpu data area.  In some cases (such as x86_cpu_to_apicid)
the array is referenced before the per_cpu data areas are setup.
In this case, a static array is declared in the __initdata
area and initialized by the booting cpu (BSP).  The values are
then moved to the per_cpu area after it is initialized and the
original static array is freed with the rest of the __initdata.
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
