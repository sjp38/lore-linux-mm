Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8FEE56B000D
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 04:31:46 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id j189-v6so4888317oih.11
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 01:31:46 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t75-v6si4666089oit.204.2018.08.09.01.31.44
        for <linux-mm@kvack.org>;
        Thu, 09 Aug 2018 01:31:44 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH] arm64: PCI: Remove node-local allocations when initialising host controller
References: <20180801173132.19739-1-punit.agrawal@arm.com>
	<38ad03ba-2658-98c8-1888-0aa3bfb59bd4@arm.com>
	<20180802143319.GA13512@red-moon>
	<CAErSpo5i7AAXq4vmfsH2WjheXpzzM1iaehdeM24eQZjzYY39Rg@mail.gmail.com>
	<87eff85364.fsf@e105922-lin.cambridge.arm.com>
	<20180808172211.GD49411@bhelgaas-glaptop.roam.corp.google.com>
Date: Thu, 09 Aug 2018 09:31:41 +0100
In-Reply-To: <20180808172211.GD49411@bhelgaas-glaptop.roam.corp.google.com>
	(Bjorn Helgaas's message of "Wed, 8 Aug 2018 12:22:11 -0500")
Message-ID: <871sb83pqq.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bjorn Helgaas <helgaas@kernel.org>
Cc: Bjorn Helgaas <bhelgaas@google.com>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, Jeremy Linton <jeremy.linton@arm.com>, linux-arm <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-acpi@vger.kernel.org, linux-mm@kvack.org

Bjorn Helgaas <helgaas@kernel.org> writes:

> On Wed, Aug 08, 2018 at 03:44:03PM +0100, Punit Agrawal wrote:
>> Bjorn Helgaas <bhelgaas@google.com> writes:
>> > On Thu, Aug 2, 2018 at 9:33 AM Lorenzo Pieralisi
>> > <lorenzo.pieralisi@arm.com> wrote:
>> >> On Wed, Aug 01, 2018 at 02:38:51PM -0500, Jeremy Linton wrote:
>> >>
>> >> Jiang Liu does not work on the kernel anymore so we won't know
>> >> anytime soon the reasoning behind commit 965cd0e4a5e5
>> >>
>> >> > On 08/01/2018 12:31 PM, Punit Agrawal wrote:
>> >> > >Memory for host controller data structures is allocated local to the
>> >> > >node to which the controller is associated with. This has been the
>> >> > >behaviour since support for ACPI was added in
>> >> > >commit 0cb0786bac15 ("ARM64: PCI: Support ACPI-based PCI host controller").
>> >> >
>> >> > Which was apparently influenced by:
>> >> >
>> >> > 965cd0e4a5e5 x86, PCI, ACPI: Use kmalloc_node() to optimize for performance
>> >> >
>> >> > Was there an actual use-case behind that change?
>> >> >
>> >> > I think this fixes the immediate boot problem, but if there is any
>> >> > perf advantage it seems wise to keep it... Particularly since x86
>> >> > seems to be doing the node sanitation in pci_acpi_root_get_node().
>> >>
>> >> I am struggling to see the perf advantage of allocating a struct
>> >> that the PCI controller will never read/write from a NUMA node that
>> >> is local to the PCI controller, happy to be corrected if there is
>> >> a sound rationale behind that.
>> >
>> > If there is no reason to use kzalloc_node() here, we shouldn't use it.
>> >
>> > But we should use it (or not use it) consistently across arches.  I do
>> > not believe there is an arch-specific reason to be different.
>> > Currently, pci_acpi_scan_root() uses kzalloc_node() on x86 and arm64,
>> > but kzalloc() on ia64.  They all ought to be the same.
>> 
>> From my understanding, arm64 use of kzalloc_node() was derived from the
>> x86 version. Maybe somebody familiar with behaviour on x86 can provide
>> input here.
>
> If you want to remove use of kzalloc_node(), I'm fine with that as
> long as you do it for x86 at the same time (maybe separate patches,
> but at least in the same series).
>
> I don't see any evidence in 965cd0e4a5e5 ("x86, PCI, ACPI: Use
> kmalloc_node() to optimize for performance") that it actually improves
> performance, so I'd be inclined to just use kzalloc().

Thanks for confirming.

I'm happy to add a patch updating x86 use of kzalloc_node() as
well. I'll post something once the merge window closes.

>
> Bjorn
