From: "David S. Miller" <davem@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14980.18496.329382.393791@pizda.ninka.net>
Date: Fri, 9 Feb 2001 11:42:56 -0800 (PST)
Subject: Re: IOMMU setup vs DAC (PCI)
In-Reply-To: <200102091939.LAA08207@milano.cup.hp.com>
References: <200102091939.LAA08207@milano.cup.hp.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Grant Grundler <grundler@cup.hp.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Grant Grundler writes:
 > My original quest was for an architecturally neutral way to pass
 > 64-bit physical memory addresses back to a 64-bit capable card.
 > 
 > pci_dma_supported() interface provides the right hook for the
 > driver to advertise device capabilities. dma_addr_t is defined
 > in most arches (read x86) to be 32-bit. But IA64 (u64) and mips*
 > (unsigned long) have broken ground here already. I'll explore
 > further to see if parisc*-linux can in fact use "unsigned long".
 > 
 > But I'm still interested in any comments or insights.
 > (ie am I out to lunch? ;^)

You are going into unchartered territory.  IA64 supports 64-bit
DMA as a HACK at best (see qla20xx driver) and uses a software
iommu implementation to handle all normal drivers using the
supported 32-bit pci_*() interfaces.

The 64-bit support API will appear in 2.5.x, no sooner.

And all that talk of IOMMU overhead assumes a shit implementation of
TLB flushing.  With a sane setup you only flush once per circle walk
of the page tables, see the tricks in sparc64/kernel/pci_iommu.c to
see what I'm talking about.  I can push 2 gigabytes to a disk over
SCSI and only take 18 PIOs to the IOMMU.  Also, many IOMMU based PCI
implementations do not offer the software managed
prefetching/write-behind facilities when 64-bit DAC is used.

I say stay at 32-bit IOMMU based stuff for now.

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
