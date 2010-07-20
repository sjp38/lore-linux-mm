Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 924AE6B02A5
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 18:31:33 -0400 (EDT)
Date: Tue, 20 Jul 2010 23:29:52 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFC 1/3 v3] mm: iommu: An API to unify IOMMU, CPU and device
	memory management
Message-ID: <20100720222952.GD10553@n2100.arm.linux.org.uk>
References: <20100714104353B.fujita.tomonori@lab.ntt.co.jp> <20100714201149.GA14008@codeaurora.org> <20100714220536.GE18138@n2100.arm.linux.org.uk> <20100715012958.GB2239@codeaurora.org> <20100715085535.GC26212@n2100.arm.linux.org.uk> <AANLkTinVZeaZxt_lWKhjKa0dqhu3_j3BRNySO-2LvMdw@mail.gmail.com> <20100716075856.GC16124@n2100.arm.linux.org.uk> <4C449183.20000@codeaurora.org> <20100719184002.GA21608@n2100.arm.linux.org.uk> <bb667e285fd8be82ea8cc9cc25cf335b.squirrel@www.codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bb667e285fd8be82ea8cc9cc25cf335b.squirrel@www.codeaurora.org>
Sender: owner-linux-mm@kvack.org
To: stepanm@codeaurora.org
Cc: Michael Bohan <mbohan@codeaurora.org>, Tim HRM <zt.tmzt@gmail.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, ebiederm@xmission.com, linux-arch@vger.kernel.org, dwalker@codeaurora.org, mel@csn.ul.ie, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andi@firstfloor.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 20, 2010 at 03:02:34PM -0700, stepanm@codeaurora.org wrote:
> Russell-
> 
> If a driver wants to allow a device to access memory (and cache coherency
> is off/not present for device addesses), the driver needs to remap that
> memory as non-cacheable.

If that memory is not part of the kernel's managed memory, then that's
fine.  But if it _is_ part of the kernel's managed memory, then it is
not permitted by the ARM architecture specification to allow maps of
the memory with differing [memory type, sharability, cache] attributes.

Basically, if a driver wants to create these kinds of mappings, then
they should expect the system to become unreliable and unpredictable.
That's not something any sane person should be aiming to do.

> Suppose there exists a chunk of
> physically-contiguous memory (say, memory reserved for device use) that
> happened to be already mapped into the kernel as normal memory (cacheable,
> etc). One way to remap this memory is to use ioremap (and then never touch
> the original virtual mapping, which would now have conflicting
> attributes).

This doesn't work, and is unpredictable on ARMv6 and ARMv7.  Not touching
the original mapping is _not_ _sufficient_ to guarantee that the mapping
is not used.  (We've seen problems on OMAP as a result of this.)

Any mapping which exists can be speculatively prefetched by such CPUs
at any time, which can lead it to be read into the cache.  Then, your
different attributes for your "other" mapping can cause problems if you
hit one of these cache lines - and then you can have (possibly silent)
data corruption.

> I feel as if there should be a better way to remap memory for
> device access, either by altering the attributes on the original mapping,
> or removing the original mapping and creating a new one with attributes
> set to non-cacheable.

This is difficult to achieve without remapping kernel memory using L2
page tables, so we can unmap pages on 4K page granularity.  That's
going to increase TLB overhead and result in lower system performance
as there'll be a greater number of MMU misses.

However, one obvious case would be to use highmem-only pages for
remapping - but you then have to ensure that those pages are never
kmapped in any way, because those mappings will fall into the same
unpredictable category that we're already trying to avoid.  This
may be possible, but you'll have to ensure that most of the system
RAM is in highmem - which poses other problems (eg, if lowmem gets
low.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
