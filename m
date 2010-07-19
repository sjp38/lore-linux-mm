Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 541016B02AC
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 03:45:26 -0400 (EDT)
Subject: Re: [RFC 1/3 v3] mm: iommu: An API to unify IOMMU, CPU and device memory management
References: <4C3C0032.5020702@codeaurora.org>
	<20100713150311B.fujita.tomonori@lab.ntt.co.jp>
	<20100713121420.GB4263@codeaurora.org>
	<20100714104353B.fujita.tomonori@lab.ntt.co.jp>
	<20100714201149.GA14008@codeaurora.org>
	<20100714220536.GE18138@n2100.arm.linux.org.uk>
	<20100715012958.GB2239@codeaurora.org>
	<20100715085535.GC26212@n2100.arm.linux.org.uk>
	<20100719065233.GD11054@codeaurora.org>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 19 Jul 2010 00:44:49 -0700
In-Reply-To: <20100719065233.GD11054@codeaurora.org> (Zach Pfeffer's message of "Sun\, 18 Jul 2010 23\:52\:33 -0700")
Message-ID: <m1mxtndifi.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Zach Pfeffer <zpfeffer@codeaurora.org>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, linux-arch@vger.kernel.org, dwalker@codeaurora.org, mel@csn.ul.ie, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andi@firstfloor.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

Zach Pfeffer <zpfeffer@codeaurora.org> writes:

> On Thu, Jul 15, 2010 at 09:55:35AM +0100, Russell King - ARM Linux wrote:
>> On Wed, Jul 14, 2010 at 06:29:58PM -0700, Zach Pfeffer wrote:
>> > The VCM ensures that all mappings that map a given physical buffer:
>> > IOMMU mappings, CPU mappings and one-to-one device mappings all map
>> > that buffer using the same (or compatible) attributes. At this point
>> > the only attribute that users can pass is CACHED. In the absence of
>> > CACHED all accesses go straight through to the physical memory.
>> 
>> So what you're saying is that if I have a buffer in kernel space
>> which I already have its virtual address, I can pass this to VCM and
>> tell it !CACHED, and it'll setup another mapping which is not cached
>> for me?
>
> Not quite. The existing mapping will be represented by a reservation
> from the prebuilt VCM of the VM. This reservation has been marked
> non-cached. Another reservation on a IOMMU VCM, also marked non-cached
> will be backed with the same physical memory. This is legal in ARM,
> allowing the vcm_back call to succeed. If you instead passed cached on
> the second mapping, the first mapping would be non-cached and the
> second would be cached. If the underlying architecture supported this
> than the vcm_back would go through.

How does this compare with the x86 pat code?

>> You are aware that multiple V:P mappings for the same physical page
>> with different attributes are being outlawed with ARMv6 and ARMv7
>> due to speculative prefetching.  The cache can be searched even for
>> a mapping specified as 'normal, uncached' and you can get cache hits
>> because the data has been speculatively loaded through a separate
>> cached mapping of the same physical page.
>
> I didn't know that. Thanks for the heads up.
>
>> FYI, during the next merge window, I will be pushing a patch which makes
>> ioremap() of system RAM fail, which should be the last core code creator
>> of mappings with different memory types.  This behaviour has been outlawed
>> (as unpredictable) in the architecture specification and does cause
>> problems on some CPUs.
>
> That's fair enough, but it seems like it should only be outlawed for
> those processors on which it breaks.

To my knowledge mismatch of mapping attributes is a problem on most
cpus on every architecture.  I don't see it making sense to encourage
coding constructs that will fail in the strangest most difficult to
debug ways.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
