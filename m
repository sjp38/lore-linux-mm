Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3EC686B024D
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 12:25:57 -0400 (EDT)
Date: Thu, 22 Jul 2010 09:25:53 -0700
From: Zach Pfeffer <zpfeffer@codeaurora.org>
Subject: Re: [RFC 1/3 v3] mm: iommu: An API to unify IOMMU, CPU and device
 memory management
Message-ID: <20100722162551.GC10255@codeaurora.org>
References: <20100713121420.GB4263@codeaurora.org>
 <20100714104353B.fujita.tomonori@lab.ntt.co.jp>
 <20100714201149.GA14008@codeaurora.org>
 <20100714220536.GE18138@n2100.arm.linux.org.uk>
 <20100715012958.GB2239@codeaurora.org>
 <20100715085535.GC26212@n2100.arm.linux.org.uk>
 <20100719065233.GD11054@codeaurora.org>
 <m1mxtndifi.fsf@fess.ebiederm.org>
 <20100722042528.GB22559@codeaurora.org>
 <20100722073455.GB6802@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100722073455.GB6802@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, linux-arch@vger.kernel.org, dwalker@codeaurora.org, mel@csn.ul.ie, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andi@firstfloor.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 22, 2010 at 08:34:55AM +0100, Russell King - ARM Linux wrote:
> On Wed, Jul 21, 2010 at 09:25:28PM -0700, Zach Pfeffer wrote:
> > Yes it is a problem, as Russell has brought up, but there's something
> > I probably haven't communicated well. I'll use the following example:
> > 
> > There are 3 devices: A CPU, a decoder and a video output device. All 3
> > devices need to map the same 12 MB buffer at the same time.
> 
> Why do you need the same buffer mapped by the CPU?
> 
> Let's take your example of a video decoder and video output device.
> Surely the CPU doesn't want to be writing to the same memory region
> used for the output picture as the decoder is writing to.  So what's
> the point of mapping that memory into the CPU's address space?

It may, especially if you're doing some software post processing. Also
by mapping all the buffers its extremly fast to "pass the buffers"
around in this senario - the buffer passing becomes a simple signal.

> 
> Surely the video output device doesn't need to see the input data to
> the decoder either?

No, but other devices may (like the CPU).

> 
> Surely, all you need is:
> 
> 1. a mapping for the CPU for a chunk of memory to pass data to the
>    decoder.
> 2. a mapping for the decoder to see the chunk of memory to receive data
>    from the CPU.
> 3. a mapping for the decoder to see a chunk of memory used for the output
>    video buffer.
> 4. a mapping for the output device to see the video buffer.
> 
> So I don't see why everything needs to be mapped by everything else.

That's fair, but we do share buffers and we do have many, very large
mappings, and we do need to pull these from a separate pools because
they need to exhibit a particular allocation profile. I agree with you
that things should work like you've listed, but with Qualcomm's ARM
multimedia engines we're seeing some different usage scenarios. Its
the giant buffers, needing to use our own buffer allocator, the need
to share and the need to swap out virtual IOMMU space (which we
haven't talked about much) which make the DMA API seem like a
mismatch. (we haven't even talked about graphics usage ;) ).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
