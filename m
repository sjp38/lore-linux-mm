Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 07C0F6B0410
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 12:38:04 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id b2so121415939pgc.6
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 09:38:04 -0800 (PST)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id u79si394069pfa.27.2017.03.09.09.38.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 09:38:03 -0800 (PST)
Subject: Re: [PATCH 0/6] Enable parallel page migration
References: <20170217112453.307-1-khandual@linux.vnet.ibm.com>
 <ef5efef8-a8c5-a4e7-ffc7-44176abec65c@linux.vnet.ibm.com>
 <20170309150904.pnk6ejeug4mktxjv@suse.de>
From: David Nellans <dnellans@nvidia.com>
Message-ID: <2a2827d0-53d0-175b-8ed4-262629e01984@nvidia.com>
Date: Thu, 9 Mar 2017 11:38:00 -0600
MIME-Version: 1.0
In-Reply-To: <20170309150904.pnk6ejeug4mktxjv@suse.de>
Content-Type: text/plain; charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com, zi.yan@cs.rutgers.edu, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On 03/09/2017 09:09 AM, Mel Gorman wrote:
> I didn't look into the patches in detail except to get a general feel
> for how it works and I'm not convinced that it's a good idea at all.
>
> I accept that memory bandwidth utilisation may be higher as a result but
> consider the impact. THP migrations are relatively rare and when they
> occur, it's in the context of a single thread. To parallelise the copy,
> an allocation, kmap and workqueue invocation are required. There may be a
> long delay before the workqueue item can start which may exceed the time
> to do a single copy if the CPUs on a node are saturated. Furthermore, a
> single thread can preempt operations of other unrelated threads and incur
> CPU cache pollution and future misses on unrelated CPUs. It's compounded by
> the fact that a high priority system workqueue is used to do the operation,
> one that is used for CPU hotplug operations and rolling back when a netdevice
> fails to be registered. It treats a hugepage copy as an essential operation
> that can preempt all other work which is very questionable.
>
> The series leader has no details on a workload that is bottlenecked by
> THP migrations and even if it is, the primary question should be *why*
> THP migrations are so frequent and alleviating that instead of
> preempting multiple CPUs to do the work.
>
>
Mel - I sense on going frustration around some of the THP migration,
migration acceleration, CDM, and other patches.  Here is a 10k foot
description that I hope adds to what John & Anshuman have said in other
threads.

Vendors are currently providing systems that have both traditional
DDR3/4 memory (lets call it 100GB/s) and high bandwidth memory (HBM)
(lets call it 1TB/s) within a single system.  GPUs have been doing this
with HBM on the GPU and DDR on the CPU complex, but they've been
attached via PCIe and thus HBM has been GPU private memory.  The GPU has
managed this memory by effectively mlocking pages on the CPU and copying
the data into the GPU while its being computed on and then copying it
back to the CPU when CPU faults on trying to touch it or the GPU is
done.  Because HBM is limited in capacity (10's of GB max) versus DDR3
(100's+ GB), runtimes like Nvidia's unified memory dynamically page
memory in and out of the GPU to get the benefits of high bandwidth,
while still allowing access a total footprint of system memory.  Its
effectively page protection based CPU/GPU memory coherence.

PCIe attached GPUs+HBM are the bulk or whats out there today and will
continue to be, so there are efforts to try and improve how GPUs (and
other devices in the same PCIe boat) interact with -mm given the
limitations of PCIe (see HMM).

Jumping to what is essentially a different platform - there will be
systems where that same GPU HBM memory is now part of the OS controlled
memory (aka NUMA node) because these systems have a cache coherent link
attaching them (could be NVLINK, QPI, CAPI, HT, or something else)  This
HBM zone might have CPU cores in it, it might have GPU cores in it, or
an FPGA, its not necessarily GPU specific.  NVIDIA has talked about
systems that look like this, as has Intel (KNL with flat memory), and
there are likely others. Systems like this can be thought of (just for
exampke) as 2 NUMA node box where you've got 100GB/s of bandwidth on one
node, 1TB/s on the other, connected via some cache coherent link. That
link is probably order 100GB/s max too (maybe lower, but certainly not
1TB/s yet).

Cores (CPU/GPU/FPGA) can access either NUMA node via the coherent link
(just like a multi-socket CPU box) but you also want to be able to
optimize page placement so that hot pages physically get migrated into
the HBM node from the DDR node. The expectation is that on such systems
either the user, a daemon, or kernel/autonuma is going to be migrating
(TH)pages between the NUMA zones to optimize overall system
bandwidth/throughput.  Because of the 10x discrepancy in memory
bandwidth, despite the best paging policies to optimize for page
locality in the HBM nodes, pages will often still be moving at a high
rate between zones.  This differs from a traditional NUMA system where
moving a page from one 100GB/s node to the other 100GB/s node has
dubious value, like you say.

To your specific question - what workloads benefit from this improved
migration throughput and why THPs?  We have seen that there can be a
1.7x improvement in GPU perf by improving NVLink page migration
bandwidth from 6GB/s->32.5GB/s.  In comparison, 4KB page migration on
x86 over QPI (today) gets < 100MB/s of throughput even though QPI and
NVLink can provide 32GB/s+.  We couldn't cripple the link enough to get
down to ~100MB/s, but obviously using small base page sizes at 100MB/s
of migration throughput would kill performance.  So good THP
functionality + good migration throughput appear critical to us (and
maybe KNL too?).

https://devblogs.nvidia.com/parallelforall/beyond-gpu-memory-limits-unified-memory-pascal/

There's a laundry list of things to make it work well related to THPs,
migration policy and eviction, numa zone isolation, etc.  We hope
building functionality into mm + autonuma is useful for everyone so that
less of it needs to live in proprietary runtimes.

Hope that helps with 10k foot view and a specific use case on why at
least NVIDIA is very interested in optimizing kernel NUMA+THP functionality.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
