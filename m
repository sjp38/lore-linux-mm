Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 4DA926B0096
	for <linux-mm@kvack.org>; Wed, 18 Feb 2015 09:30:50 -0500 (EST)
Received: by mail-qc0-f174.google.com with SMTP id c9so1044648qcz.5
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 06:30:50 -0800 (PST)
Received: from mail-qa0-x22b.google.com (mail-qa0-x22b.google.com. [2607:f8b0:400d:c00::22b])
        by mx.google.com with ESMTPS id 70si13026908qhq.21.2015.02.18.06.30.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Feb 2015 06:30:49 -0800 (PST)
Received: by mail-qa0-f43.google.com with SMTP id bm13so977055qab.2
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 06:30:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1424219432.21410.113.camel@kernel.crashing.org>
References: <1424157203-691-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1424157203-691-8-git-send-email-gwshan@linux.vnet.ibm.com>
 <20150217220916.GA26424@google.com> <20150218001620.GA22042@shangw> <1424219432.21410.113.camel@kernel.crashing.org>
From: Bjorn Helgaas <bhelgaas@google.com>
Date: Wed, 18 Feb 2015 08:30:28 -0600
Message-ID: <CAErSpo6vMyy2SoqZ4ca2D_BUxd3J4W5jASsQu0NM9opFzR5mfg@mail.gmail.com>
Subject: Re: [PATCH RESEND v2 7/7] PCI/hotplug: PowerPC PowerNV PCI hotplug driver
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>, linuxppc-dev@ozlabs.org, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

[+cc linux-mm, linux-kernel]

For context, the start of this discussion was here:
http://lkml.kernel.org/r/1424157203-691-8-git-send-email-gwshan@linux.vnet.ibm.com
where Gavin is adding a new PCI hotplug driver for PowerNV.  That new
driver calls vm_unmap_aliases() the same way we do in the existing RPA
hotplug driver here:

https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/drivers/pci/hotplug/rpaphp_core.c#n432

I'm trying to figure out whether it's correct to use
vm_unmap_aliases() here, but I'm not an mm person so all I have is my
gut feeling that something doesn't smell right.

On Tue, Feb 17, 2015 at 6:30 PM, Benjamin Herrenschmidt
<benh@kernel.crashing.org> wrote:
> On Wed, 2015-02-18 at 11:16 +1100, Gavin Shan wrote:
>> >What is vm_unmap_aliases() for?  I see this is probably copied from
>> >rpaphp_core.c, where it was added by b4a26be9f6f8 ("powerpc/pseries:
>> Flush
>> >lazy kernel mappings after unplug operations").
>> >
>> >But I don't know whether:
>> >
>> >  - this is something specific to powerpc,
>> >  - the lack of vm_unmap_aliases() in other hotplug paths is a bug,
>> >  - the fact that we only do this on powerpc is covering up a
>> >    powerpc bug somewhere
>>
>> Yes, I copied this piece of code from rpaphp_core.c. I think Ben might
>> help to answer the questions as he added the patch. I had very quick
>> check on mm/vmalloc.c and it's reasonable to have vm_unmap_aliases()
>> here to flush TLB entries for ioremap() regions, which were unmapped
>> previously. if I'm correct. I don't think it's powerpc specific.
>
> It's specific to running under the PowerVM hypervisor, and thus doesn't
> affect PowerNV, just don't copy it over.
>
> It comes from the fact that the generic ioremap code nowadays delays
> TLB flushing on unmap. The TLB flushing code is what, on powerpc,
> ensures that we remove the translations from the MMU hash table (the
> hash table is essentially treated as an extended in-memory TLB), which
> on pseries turns into hypervisor calls.
>
> When running under that hypervisor, the HV ensures that no translation
> still exists in the hash before allowing a device to be removed from
> a partition. If translations still exist, the removal fails.
>
> So we need to force the generic ioremap code to perform all the TLB
> flushes for iounmap'ed regions before we "complete" the unplug operation
> from a kernel perspective so that the device can be re-assigned to
> another partition.
>
> This is thus useless on platforms like powernv which do not run under
> such a hypervisor.

So the hypervisor call that removes the device from the partition will
fail if there are any translations that reference the memory of the
device.

Let me go through this in excruciating detail to see if I understand
what's going on:

  - PCI core enumerates device D1
  - PCI core sets device D1 BAR 0 = 0x1000
  - driver claims D1
  - driver ioremaps 0x1000 at virtual address V
  - translation V -> 0x1000 is in TLB
  - driver iounmaps V (but V -> 0x1000 translation may remain in TLB)
  - driver releases D1
  - hot-remove D1 (without vm_unmap_aliases(), hypervisor would fail this)
  - it would be a bug to reference V here, but if we did, the
virt-to-phys translation would succeed and we'd have a Master Abort or
Unsupported Request on PCI/PCIe
  - hot-add D2
  - PCI core enumerates device D2
  - PCI core sets device D2 BAR 0 = 0x1000
  - it would be a bug to reference V here (before ioremapping), but if
we did, the reference would reach D2

I don't see anything hypervisor-specific here except for the fact that
the hypervisor checks for existing translations and most other
platforms don't.  But it seems like the unexpected PCI aborts could
happen on any platform.

Are we saying that those PCI aborts are OK, since it's a bug to make
those references in the first place?  Or would we rather take a TLB
miss fault instead so the references never make it to PCI?

I would think there would be similar issues when unmapping and
re-mapping plain old physical memory.  But I don't see
vm_unmap_aliases() calls there, so those issues must be handled
differently.  Should we handle this PCI hotplug issue the same way we
handle RAM?

Bjorn

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
