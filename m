From: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Message-Id: <200102092111.NAA78240@google.engr.sgi.com>
Subject: Re: IOMMU setup vs DAC (PCI)
Date: Fri, 9 Feb 2001 13:11:49 -0800 (PST)
In-Reply-To: <14980.20915.447995.650580@pizda.ninka.net> from "David S. Miller" at Feb 09, 2001 12:23:15 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: Grant Grundler <grundler@cup.hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> 
> Kanoj Sarcar writes:
>  > In some cases (in 2.4, prior to dma64_addr_t), if arch 
>  > code can figure out a device is A64, the driver does support
>  > A64, then it can privately decide to use A64 style mapping
>  > and pci_dma operations for that pci_dev. Is there a problem
>  > with this approach?
> 
> Only device code can determine if a device is A64 and will
> actually spit out DAC addressing.
> 
> Let me give you one example.  On the Syskonnect Gigabit cards,
> if any of the top 32-bits of an address are non-zero, DAC will
> be used else a SAC cycle will be used for the address.
> 
> Alpha and Sparc64 PCI controllers interpret DAC and SAC addresses
> differently.  For example, on sparc64, a DAC address to physical
> memory should be formed by software with this equation:
> 
> 	DAC_ADDR = (0x03fff00000000000 + PHYS_ADDR)
> 
> Alpha, if I remember correctly, uses a different upper constant.
> For these two platforms, if SAC is used by the device then
> normal IOMMU translation occurs (unless the IOMMU is disabled
> thus putting the PCI controller into a bypass mode).
> 
> So it is not just "A64 capable", it is "will spit out DAC for
> _this_ PCI dma address" and "can arch handle DACs appropriately."
> 

As a counter example, see the much simpler-to-handle qlogicisp.c
driver, which is programmed at start to use DAC or SAC (via
config option CONFIG_QL_ISP_A64). Also, qlogicfc.c is quite
similar (PCI64_DMA_BITS).

So, if your arch can handle A64, it would build this driver in 
CONFIG_QL_ISP_A64 mode, and the pci_dma implementations would know
that this device/driver can do A64.

> You have to use a different type due to all of these variables.
> So we will have dma64_addr_t and pci64_map_single et a.
> The driver has to make a conscious decision to use 64-bit
> DACs, and all devices I know of supporting DAC must be specifically
> told to use DACs.  See things like SCSI_NCR_USE_64BIT_DAC in the
> sym53c8xx driver.
> 

If the Symbios chips behave similar to Qlogic chips, then 
SCSI_NCR_USE_64BIT_DAC should really be a config option. 

> The reason these interfaces don't and will not exist in 2.4.x is
> precisely because I've had to track down and figure out all of these
> arch and device specific details before deciding on an interface
> that can work for everyone.  The PCI dma API in 2.4.x is frozen.
> 
> In short trying to get 64-bit DAC'able addresses with pci_map_single()
> is illegal and any driver doing it is flat out non-portable.
> 

Yes, understood. As you point out, the Syskonnect Gigabit card is
probably best operated in A32 mode. 

All I am trying to say is that performance of certain drivers on 
certain architectures might be improvable by certain tricks, even in
2.4.

Kanoj

> Later,
> David S. Miller
> davem@redhat.com
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
