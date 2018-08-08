Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7EB086B0008
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 10:44:08 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id s200-v6so2411030oie.6
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 07:44:08 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e129-v6si3005007oig.91.2018.08.08.07.44.06
        for <linux-mm@kvack.org>;
        Wed, 08 Aug 2018 07:44:06 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH] arm64: PCI: Remove node-local allocations when initialising host controller
References: <20180801173132.19739-1-punit.agrawal@arm.com>
	<38ad03ba-2658-98c8-1888-0aa3bfb59bd4@arm.com>
	<20180802143319.GA13512@red-moon>
	<CAErSpo5i7AAXq4vmfsH2WjheXpzzM1iaehdeM24eQZjzYY39Rg@mail.gmail.com>
Date: Wed, 08 Aug 2018 15:44:03 +0100
In-Reply-To: <CAErSpo5i7AAXq4vmfsH2WjheXpzzM1iaehdeM24eQZjzYY39Rg@mail.gmail.com>
	(Bjorn Helgaas's message of "Wed, 8 Aug 2018 08:54:28 -0500")
Message-ID: <87eff85364.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, Jeremy Linton <jeremy.linton@arm.com>, linux-arm <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-acpi@vger.kernel.org, linux-mm@kvack.org

[+cc linux-acpi, linux-mm]

Bjorn Helgaas <bhelgaas@google.com> writes:

> [+cc linux-pci, linux-kernel]
>
> On Thu, Aug 2, 2018 at 9:33 AM Lorenzo Pieralisi
> <lorenzo.pieralisi@arm.com> wrote:
>>
>> On Wed, Aug 01, 2018 at 02:38:51PM -0500, Jeremy Linton wrote:
>> > Hi,
>> >
>> > +CC Jiang Lui
>>
>> Jiang Liu does not work on the kernel anymore so we won't know
>> anytime soon the reasoning behind commit 965cd0e4a5e5
>>
>> > On 08/01/2018 12:31 PM, Punit Agrawal wrote:
>> > >Memory for host controller data structures is allocated local to the
>> > >node to which the controller is associated with. This has been the
>> > >behaviour since support for ACPI was added in
>> > >commit 0cb0786bac15 ("ARM64: PCI: Support ACPI-based PCI host controller").
>> >
>> > Which was apparently influenced by:
>> >
>> > 965cd0e4a5e5 x86, PCI, ACPI: Use kmalloc_node() to optimize for performance
>> >
>> > Was there an actual use-case behind that change?
>> >
>> > I think this fixes the immediate boot problem, but if there is any
>> > perf advantage it seems wise to keep it... Particularly since x86
>> > seems to be doing the node sanitation in pci_acpi_root_get_node().
>>
>> I am struggling to see the perf advantage of allocating a struct
>> that the PCI controller will never read/write from a NUMA node that
>> is local to the PCI controller, happy to be corrected if there is
>> a sound rationale behind that.
>
> If there is no reason to use kzalloc_node() here, we shouldn't use it.
>
> But we should use it (or not use it) consistently across arches.  I do
> not believe there is an arch-specific reason to be different.
> Currently, pci_acpi_scan_root() uses kzalloc_node() on x86 and arm64,
> but kzalloc() on ia64.  They all ought to be the same.

>From my understanding, arm64 use of kzalloc_node() was derived from the
x86 version. Maybe somebody familiar with behaviour on x86 can provide
input here.

>
>> > >Drop the node local allocation as there is no benefit from doing so -
>> > >the usage of these structures is independent from where the controller
>> > >is located. It also causes problem during probe if the associated numa
>> > >node hasn't been initialised due to booting with restricted cpus via
>> > >kernel command line or where the node doesn't have cpus or memory
>> > >associated with it.
>
> I do not support the avoidance of kzalloc_node() as a means of working
> around the problem of a NUMA node not being initialized correctly.

Agreed.

The patch is not meant as a work around for uninitialised NUMA nodes. I
mention it in the commit log as the context where this was
discovered. It seems to cause conflation of the issue addressed by the
patch - I'll drop it in future postings.

> We got that node number from acpi_get_node().  I think we should be
> able to pass it to kzalloc_node() and expect something reasonable,
> i.e., either a successful allocation from the desired node (or from a
> node that is present) or an error return.  I don't think the caller is
> in a position to figure out whether it's safe to use kzalloc_node() or
> not.

The problem is that acpi_get_node() just maps the proximity domain to a
node id, without initialising the node pglist_data or setting up the
zonelists. This happens in the case when the proximity domain is not
present in the SRAT (proximity domain has no attached cpus or memory)
but first encountered as part of _PXM() method for a device.

One approach to solve this problem would be to create
acpi_get_online_node() which attempts to online a NUMA node if it isn't
already or at the least return NUMA_NO_NODE.

Another would be to have kzalloc_node() perform the checks for online
node and return error if not.

It's not clear what the preferred approach is.

>
>> > >Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
>> > >Cc: Catalin Marinas <catalin.marinas@arm.com>
>> > >Cc: Will Deacon <will.deacon@arm.com>
>> > >Cc: Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>
>> > >---
>> > >Hi,
>> > >
>> > >This came up in the context of investigating the boot issues reported
>> > >due to restricted cpus or buggy firmware. Part of the problem is fixed
>> > >by Lorenzo's rework of NUMA initialisation[0].
>> > >
>> > >But there also doesn't seem to be any justification for using
>> > >node-local allocation to begin with.
>> > >
>> > >Thanks,
>> > >Punit
>> > >
>> > >[0] https://patchwork.kernel.org/patch/10486001/
>> > >
>> > >  arch/arm64/kernel/pci.c | 5 ++---
>> > >  1 file changed, 2 insertions(+), 3 deletions(-)
>> > >
>> > >diff --git a/arch/arm64/kernel/pci.c b/arch/arm64/kernel/pci.c
>> > >index 0e2ea1c78542..bb85e2f4603f 100644
>> > >--- a/arch/arm64/kernel/pci.c
>> > >+++ b/arch/arm64/kernel/pci.c
>> > >@@ -165,16 +165,15 @@ static void pci_acpi_generic_release_info(struct acpi_pci_root_info *ci)
>> > >  /* Interface called from ACPI code to setup PCI host controller */
>> > >  struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
>> > >  {
>> > >-    int node = acpi_get_node(root->device->handle);
>> > >     struct acpi_pci_generic_root_info *ri;
>> > >     struct pci_bus *bus, *child;
>> > >     struct acpi_pci_root_ops *root_ops;
>> > >-    ri = kzalloc_node(sizeof(*ri), GFP_KERNEL, node);
>> > >+    ri = kzalloc(sizeof(*ri), GFP_KERNEL);
>> > >     if (!ri)
>> > >             return NULL;
>> > >-    root_ops = kzalloc_node(sizeof(*root_ops), GFP_KERNEL, node);
>> > >+    root_ops = kzalloc(sizeof(*root_ops), GFP_KERNEL);
>> > >     if (!root_ops) {
>> > >             kfree(ri);
>> > >             return NULL;
>> > >
>> >
