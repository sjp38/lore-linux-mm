Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5A87D6B01CE
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 18:00:21 -0400 (EDT)
Message-ID: <4C2D0FF1.6010206@codeaurora.org>
Date: Thu, 01 Jul 2010 15:00:17 -0700
From: Zach Pfeffer <zpfeffer@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [RFC 3/3] mm: iommu: The Virtual Contiguous Memory Manager
References: <1277877350-2147-1-git-send-email-zpfeffer@codeaurora.org> <1277877350-2147-3-git-send-email-zpfeffer@codeaurora.org> <20100701101746.3810cc3b.randy.dunlap@oracle.com> <20100701180241.GA3594@basil.fritz.box> <1278012503.7738.17.camel@c-dwalke-linux.qualcomm.com> <20100701193850.GB3594@basil.fritz.box>
In-Reply-To: <20100701193850.GB3594@basil.fritz.box>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Daniel Walker <dwalker@codeaurora.org>, Randy Dunlap <randy.dunlap@oracle.com>, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:

>>> Also for me it's still quite unclear why we would want this code at all...
>>> It doesn't seem to do anything you couldn't do with the existing interfaces.
>> I don't know all that much about what Zach's done here, but from what
>> he's said so far it looks like this help to manage lots of IOMMUs on a
>> single system.. On x86 it seems like there's not all that many IOMMUs in
>> comparison .. Zach mentioned 10 to 100 IOMMUs ..
> 
> The current code can manage multiple IOMMUs fine.

That's fair. The current code does manage multiple IOMMUs without issue
for a static map topology. Its core function 'map' maps a physical chunk
of some size into a IOMMU's address space and the kernel's address
space for some domain.

The VCMM provides a more abstract, global view with finer-grained
control of each mapping a user wants to create. For instance, the
symantics of iommu_map preclude its use in setting up just the IOMMU
side of a mapping. With a one-sided map, two IOMMU devices can be
pointed to the same physical memory without mapping that same memory
into the kernel's address space.

Additionally, the current IOMMU interface does not allow users to
associate one page table with multiple IOMMUs unless the user explicitly
wrote a muxed device underneith the IOMMU interface. This also could be
done, but would have to be done for every such use case. Since the
particular topology is run-time configurable all of these use-cases and
more can be expressed without pushing the topology into the low-level
IOMMU driver.

The VCMM takes the long view. Its designed for a future in which the
number of IOMMUs will go up and the ways in which these IOMMUs are
composed will vary from system to system, and may vary at
runtime. Already, there are ~20 different IOMMU map implementations in
the kernel. Had the Linux kernel had the VCMM, many of those
implementations could have leveraged the mapping and topology management
of a VCMM, while focusing on a few key hardware specific functions (map
this physical address, program the page table base register).

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
