Message-Id: <200102092004.MAA08263@milano.cup.hp.com>
Subject: Re: IOMMU setup vs DAC (PCI) 
In-reply-to: Your message of "Fri, 09 Feb 2001 11:42:56 PST."
             <14980.18496.329382.393791@pizda.ninka.net>
Date: Fri, 09 Feb 2001 12:04:00 -0800
From: Grant Grundler <grundler@cup.hp.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"David S. Miller" wrote:
> You are going into unchartered territory.  IA64 supports 64-bit
> DMA as a HACK at best (see qla20xx driver) and uses a software
> iommu implementation to handle all normal drivers using the
> supported 32-bit pci_*() interfaces.

Ah ok. that's what I was afraid of.

> The 64-bit support API will appear in 2.5.x, no sooner.
> 
> And all that talk of IOMMU overhead assumes a shit implementation of
> TLB flushing.

Yup. That's us. :^(
For "SBA" IOMMU, CPU has to invalidate TLB entries since the board
designers *botched* the implementation. TLB and IOPdir were *supposed*
to be coherent.

Future implementations are promised to work correctly.
I'll believe it when I see it.

> With a sane setup you only flush once per circle walk
> of the page tables, see the tricks in sparc64/kernel/pci_iommu.c to
> see what I'm talking about.  I can push 2 gigabytes to a disk over
> SCSI and only take 18 PIOs to the IOMMU.

I've been able to reduce PIO *read* overhead a bunch.
Normally every PIO write to TLB invalidate has to be followed by a read
to guarantee the IOMMU sees the write.  I bundle several (32 or more)
PIO writes together and follow with one read. The read overhead
disappears in mix with other overhead. So while it sucks, it's not
*really* bad...

> Also, many IOMMU based PCI
> implementations do not offer the software managed
> prefetching/write-behind facilities when 64-bit DAC is used.
>
> I say stay at 32-bit IOMMU based stuff for now.

ok - tnx!

grant

Grant Grundler
parisc-linux {PCI|IOMMU|SMP} hacker
+1.408.447.7253
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
