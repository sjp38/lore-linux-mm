Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 5EEEA6B01AD
	for <linux-mm@kvack.org>; Sun, 27 Jun 2010 00:46:58 -0400 (EDT)
Date: Sun, 27 Jun 2010 13:46:07 +0900
Subject: Re: [RFC] mm: iommu: An API to unify IOMMU, CPU and device memory
 management
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <4C245152.1090301@codeaurora.org>
References: <1277355096-15596-1-git-send-email-zpfeffer@codeaurora.org>
	<876318ager.fsf@basil.nowhere.org>
	<4C245152.1090301@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <20100627134401G.fujita.tomonori@lab.ntt.co.jp>
Sender: owner-linux-mm@kvack.org
To: zpfeffer@codeaurora.org
Cc: andi@firstfloor.org, mel@csn.ul.ie, dwalker@codeaurora.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-omap@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 24 Jun 2010 23:48:50 -0700
Zach Pfeffer <zpfeffer@codeaurora.org> wrote:

> Andi Kleen wrote:
> > Zach Pfeffer <zpfeffer@codeaurora.org> writes:
> > 
> >> This patch contains the documentation for and the main header file of
> >> the API, termed the Virtual Contiguous Memory Manager. Its use would
> >> allow all of the IOMMU to VM, VM to device and device to IOMMU
> >> interoperation code to be refactored into platform independent code.
> > 
> > I read all the description and it's still unclear what advantage
> > this all has over the current architecture? 
> > 
> > At least all the benefits mentioned seem to be rather nebulous.
> > 
> > Can you describe a concrete use case that is improved by this code
> > directly?
> 
> Sure. On a SoC with many IOMMUs (10-100), where each IOMMU may have
> its own set of page-tables or share page-tables, and where devices
> with and without IOMMUs and CPUs with or without MMUS want to
> communicate, an abstraction like the VCM helps manage all conceivable
> mapping topologies. In the same way that the Linux MM manages pages
> apart from page-frames, the VCMM allows the Linux MM to manage ideal
> memory regions, VCMs, apart from the actual memory region.
> 
> One real scenario would be video playback from a file on a memory
> card. To read and display the video, a DMA engine would read blocks of
> data from the memory card controller into memory. These would
> typically be managed using a scatter-gather list. This list would be
> mapped into a contiguous buffer of the video decoder's IOMMU. The
> video decoder would write into a buffer mapped by the display engine's
> IOMMU as well as the CPU (if the kernel needed to intercept the
> buffers). In this instance, the video decoder's IOMMU and the display
> engine's IOMMU use different page-table formats.
> 
> Using the VCM API, this topology can be created without worrying about
> the device's IOMMUs or how to map the buffers into the kernel, or how
> to interoperate with the scatter-gather list. The call flow would would go:

Can you explain how you can't do the above with the existing API?


> The general point of the VCMM is to allow users a higher level API
> than the current IOMMU abstraction provides that solves the general
> mapping problem. This means that all of the common mapping code would
> be written once. In addition, the API allows all the low level details
> of IOMMU programing and VM interoperation to be handled at the right
> level.
> 
> Eventually the following functions could all be reworked and their
> users could call VCM functions.

There are more IOMMUs (e.g. x86 has calgary, gart too). And what is
the point of converting old IOMMUs (the majority of the below)? are
there any potential users of your API for such old IOMMUs?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
