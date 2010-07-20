Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 26A5F6B024D
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 16:56:01 -0400 (EDT)
Date: Tue, 20 Jul 2010 21:54:33 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFC 1/3 v3] mm: iommu: An API to unify IOMMU, CPU and device
	memory management
Message-ID: <20100720205433.GA10553@n2100.arm.linux.org.uk>
References: <20100713150311B.fujita.tomonori@lab.ntt.co.jp> <20100713121420.GB4263@codeaurora.org> <20100714104353B.fujita.tomonori@lab.ntt.co.jp> <20100714201149.GA14008@codeaurora.org> <20100714220536.GE18138@n2100.arm.linux.org.uk> <20100715012958.GB2239@codeaurora.org> <20100715085535.GC26212@n2100.arm.linux.org.uk> <AANLkTinVZeaZxt_lWKhjKa0dqhu3_j3BRNySO-2LvMdw@mail.gmail.com> <20100716075856.GC16124@n2100.arm.linux.org.uk> <20100720204515.GA12250@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100720204515.GA12250@codeaurora.org>
Sender: owner-linux-mm@kvack.org
To: Zach Pfeffer <zpfeffer@codeaurora.org>
Cc: Tim HRM <zt.tmzt@gmail.com>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, ebiederm@xmission.com, linux-arch@vger.kernel.org, dwalker@codeaurora.org, mel@csn.ul.ie, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andi@firstfloor.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 20, 2010 at 01:45:17PM -0700, Zach Pfeffer wrote:
> As you mention in your patch the things that can't conflict are memory
> type (strongly- ordered/device/normal), cache policy
> (cacheable/non-cacheable, copy- back/write-through), and coherency
> realm (non-shareable/inner- shareable/outer-shareable). You can
> conflict in allocation preferences (write-allocate/write-no-allocate),
> as those are just "hints".

What you refer to as "hints" I refer to as cache policy - practically
on ARM they're all tied up into the same set of bits.

> You can also conflict in access permissions which can and do conflict
> (which are what multiple mappings are all about...some buffer can get
> some access, while others get different access).

Access permissions don't conflict between mappings - each mapping has
unique access permissions.

> The VCM API allows the same memory to be mapped as long as it makes
> sense and allows those attributes that can change to be specified. It
> could be the alternative, globally applicable approach, your looking
> for and request in your patch.

I very much doubt it - there's virtually no call for creating an
additional mapping of existing kernel memory with different permissions.
The only time kernel memory gets remapped is with vmalloc(), where we
want to create a virtually contiguous mapping from a collection of
(possibly) non-contiguous pages.  Such allocations are always created
with R/W permissions.

There are some cases where the vmalloc APIs are used to create mappings
with different memory properties, but as already covered, this has become
illegal with ARMv6 and v7 architectures.

So no, VCM doesn't help because there's nothing that could be solved here.
Creating read-only mappings is pointless, and creating mappings with
different memory type, sharability or cache attributes is illegal.

> Without the VCM API (or something like it) there will just be a bunch
> of duplicated code that's basically doing ioremap. This code will
> probably fail to configure its mappings correctly, in which case your
> patch is a bad idea because it'll spawn bugs all over the place
> instead of at a know location. We could instead change ioremap to
> match the attributes of System RAM if that's what its mapping.

And as I say, what is the point of creating another identical mapping to
the one we already have?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
