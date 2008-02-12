Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.8/8.13.8) with ESMTP id m1C97ljK127130
	for <linux-mm@kvack.org>; Tue, 12 Feb 2008 09:07:47 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1C97luN2199778
	for <linux-mm@kvack.org>; Tue, 12 Feb 2008 10:07:47 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1C97lWg028150
	for <linux-mm@kvack.org>; Tue, 12 Feb 2008 10:07:47 +0100
Date: Tue, 12 Feb 2008 11:07:45 +0200
From: Muli Ben-Yehuda <muli@il.ibm.com>
Subject: Re: [PATCH]intel-iommu batched iotlb flushes
Message-ID: <20080212090745.GH5750@rhun.haifa.ibm.com>
References: <20080211224105.GB24412@linux.intel.com> <20080212085256.GF5750@rhun.haifa.ibm.com> <20080212.010006.255202479.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080212.010006.255202479.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: mgross@linux.intel.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2008 at 01:00:06AM -0800, David Miller wrote:
> From: Muli Ben-Yehuda <muli@il.ibm.com>
> Date: Tue, 12 Feb 2008 10:52:56 +0200
> 
> > The streaming DMA-API was designed to conserve IOMMU mappings for
> > machines where IOMMU mappings are a scarce resource, and is a poor
> > fit for a modern IOMMU such as VT-d with a 64-bit IO address space
> > (or even an IOMMU with a 32-bit address space such as Calgary)
> > where there are plenty of IOMMU mappings available.
> 
> For the 64-bit case what you are suggesting eventually amounts to
> mapping all available RAM in the IOMMU.
> 
> Although an extreme version of your suggestion, it would be the most
> efficient as it would require zero IOMMU flush operations.
>
> But we'd lose things like protection and other benefits.

For the extreme case you are correct. There's an inherent trade-off
between IOMMU performance and protection guarantees, where one end of
the spectrum is represented by the streaming DMA-API and the other end
is represented by simply mapping all available memory. It's an open
question what is the right point in between. I think that an optimal
strategy might be "keep the mapping around for as long as it is safe",
i.e., keep a mapping to a frame for as long as the frame is owned by
whoever requested the mapping in the first place. Once ownership of
the frame is passed to another entity (e.g., from the driver to the
stack), revoke the original mapping. This implies a way for the kernel
to track frame ownership and communicate frame ownership changes to
the DMA-API layer, which we don't currently have.

Cheers,
Muli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
