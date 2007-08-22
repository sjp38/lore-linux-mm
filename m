Message-Id: <20070822172101.138513000@sgi.com>
Date: Wed, 22 Aug 2007 10:21:01 -0700
From: travis@sgi.com
Subject: [PATCH 0/6] x86: Reduce Memory Usage and Inter-Node message traffic
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

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

Patches applied to: linux-2.6.23-rc2-mm2
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
