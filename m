Date: Tue, 12 Feb 2008 15:46:30 -0800 (PST)
Message-Id: <20080212.154630.241691261.davem@davemloft.net>
Subject: Re: [PATCH]intel-iommu batched iotlb flushes
From: David Miller <davem@davemloft.net>
In-Reply-To: <20080212155448.GC27490@linux.intel.com>
References: <20080212085256.GF5750@rhun.haifa.ibm.com>
	<20080212.010006.255202479.davem@davemloft.net>
	<20080212155448.GC27490@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: mark gross <mgross@linux.intel.com>
Date: Tue, 12 Feb 2008 07:54:48 -0800
Return-Path: <owner-linux-mm@kvack.org>
To: mgross@linux.intel.com
Cc: muli@il.ibm.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Something could be done:
> we could enable drivers to have DMA-pools they manage that get mapped
> and are re-used.
> 
> I would rather the DMA-pools be tied to PID's that way any bad behavior
> would be limited to the address space of the process using the device.
> I haven't thought about how hard this would be to do but it would be
> nice.  I think this could be tricky.

Yes, this is a good idea especially for networking.

For transmit on 10GB links the IOMMU setup is near the top
of the profiles.

What a driver could do is determine the maximum number of
IOMMU pages it could need to map one maximally sized packet.
So then it allocates enough space for all such entries in
it's TX ring.

This eliminates the range allocation from the transmit path.
All that's left is "remap DMA range X to scatterlist Y"

And yes it would be nice to have dma_map_skb() type interfaces
so that we don't walk into the IOMMU code N times per packet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
