Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate8.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m1C8r1bN262076
	for <linux-mm@kvack.org>; Tue, 12 Feb 2008 08:53:01 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1C8r1Mg1183922
	for <linux-mm@kvack.org>; Tue, 12 Feb 2008 08:53:01 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1C8qw5j015153
	for <linux-mm@kvack.org>; Tue, 12 Feb 2008 08:52:58 GMT
Date: Tue, 12 Feb 2008 10:52:56 +0200
From: Muli Ben-Yehuda <muli@il.ibm.com>
Subject: Re: [PATCH]intel-iommu batched iotlb flushes
Message-ID: <20080212085256.GF5750@rhun.haifa.ibm.com>
References: <20080211224105.GB24412@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080211224105.GB24412@linux.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mark gross <mgross@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2008 at 02:41:05PM -0800, mark gross wrote:

> The intel-iommu hardware requires a polling operation to flush IOTLB
> PTE's after an unmap operation.  Through some TSC instrumentation of
> a netperf UDP stream with small packets test case it was seen that
> the flush operations where sucking up to 16% of the CPU time doing
> iommu_flush_iotlb's
> 
> The following patch batches the IOTLB flushes removing most of the
> overhead in flushing the IOTLB's.  It works by building a list of to
> be released IOVA's that is iterated over when a timer goes off or
> when a high water mark is reached.
> 
> The wrinkle this has is that the memory protection and page fault
> warnings from errant DMA operations is somewhat reduced, hence a kernel
> parameter is added to revert back to the "strict" page flush / unmap
> behavior. 
> 
> The hole is the following scenarios: 
> do many map_signal operations, do some unmap_signals, reuse a recently
> unmapped page, <errant DMA hardware sneaks through and steps on reused
> memory>
> 
> Or: you have rouge hardware using DMA's to look at pages: do many
> map_signal's, do many unmap_singles, reuse some unmapped pages : 
> <rouge hardware looks at reused page>
> 
> Note : these holes are very hard to get too, as the IOTLB is small
> and only the PTE's still in the IOTLB can be accessed through this
> mechanism.
> 
> Its recommended that strict is used when developing drivers that do
> DMA operations to catch bugs early.  For production code where
> performance is desired running with the batched IOTLB flushing is a
> good way to go.

While I don't disagree with this patch in principle (Calgary does the
same thing due to expensive IOTLB flushes) the right way to fix it
IMHO is to fix the drivers to batch mapping and unmapping operations
or map up-front and unmap when done. The streaming DMA-API was
designed to conserve IOMMU mappings for machines where IOMMU mappings
are a scarce resource, and is a poor fit for a modern IOMMU such as
VT-d with a 64-bit IO address space (or even an IOMMU with a 32-bit
address space such as Calgary) where there are plenty of IOMMU
mappings available.

Cheers,
Muli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
