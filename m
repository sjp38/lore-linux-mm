Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2F15E6B000E
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 17:54:09 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id p1-v6so5457369wrm.7
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 14:54:09 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v37-v6si143169edm.63.2018.04.26.14.54.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Apr 2018 14:54:07 -0700 (PDT)
Date: Thu, 26 Apr 2018 21:54:06 +0000
From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: [LSF/MM TOPIC NOTES] x86 ZONE_DMA love
Message-ID: <20180426215406.GB27853@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@kernel.org, cl@linux.com, Jan Kara <jack@suse.cz>, matthew@wil.cx, x86@kernel.org, luto@amacapital.net, martin.petersen@oracle.com, jthumshirn@suse.de, broonie@kernel.org, linux-spi@vger.kernel.org, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, mcgrof@kernel.org

Below are my notes on the ZONE_DMA discussion at LSF/MM 2018. There were some
earlier discussion prior to my arrival to the session about moving around
ZOME_DMA around, if someone has notes on that please share too :)

PS. I'm not subscribed to linux-mm

  Luis

Determining you don't need to support ZONE_DMA on x86 at run time
=================================================================

In practice if you don't have a floppy device on x86, you don't need ZONE_DMA,
in that case you dont need to support ZONE_DMA, however currently disabling it
is only possible at compile time, and we won't know for sure until boot time if
you have such a device. If you don't need ZONE_DMA though means we would not
have to deal with slab allocators for them and special casings for it in a slew
of places. In particular even kmalloc() has a branch which is always run if
CONFIG_ZONE_DMA is enabled.

ZONE_DMA is needed for old devices that requires lower addresses since it allows
allocations more reliably. There should be more devices that require this,
not just floppy though.

Christoph Lameter added CONFIG_ZONE_DMA to disable ZONE_DMA at build time but
most distributions enable this. If we could disable ZONE_DMA at run time once
we know we don't have any device present requiring it we could get the same
benefit of compiling without CONFIG_ZONE_DMA at run time.

It used to be that disabling CONFIG_ZONE_DMA could help with performance, we
don't seem to have modern benchmarks over possible gains on removing it.
Are the gains no longer expected to be significant? Very likely there are
no performance gains. The assumption then is that the main advantage over
being able to disable ZONE_DMA on x86 these days would be pure aesthetics, and
having x86 work more like other architectures with allocations. Use of ZONE_DMA
on drivers are also good signs these drivers are old, or may be deprecated.
Perhaps some of these on x86 should be moved to staging.

Note that some architectures rely on ZONE_DMA as well, the above notes
only applies to x86.

We can use certain kernel mechanisms to disable usage of x86 certain features
at run time. Below are a few options:

  * x86 binary patching
  * ACPI_SIG_FADT
  * static keys
  * compiler multiverse (at least the R&D gcc proof of concept is now complete)

Detecting legacy x86 devices with ACPI ACPI_SIG_FADT
----------------------------------------------------

We could expand on ACPI_SIG_FADT with more legacy devices. This mechanism was
used to help determine if certain legacy x86 devices are present or not with
paravirtualization. For instance:

  * ACPI_FADT_NO_VGA
  * ACPI_FADT_NO_CMOS_RTC

CONFIG_ZONE_DMA
---------------

Christoph Lameter added CONFIG_ZONE_DMA through commit 4b51d66989218
("[PATCH] optional ZONE_DMA: optional ZONE_DMA in the VM") merged on
v2.6.21.

On x86 ZONE_DMA is defined as follows:

config ZONE_DMA
        bool "DMA memory allocation support" if EXPERT
        default y
        help
          DMA memory allocation support allows devices with less than 32-bit
          addressing to allocate within the first 16MB of address space.
          Disable if no such devices will be used.
                                                                                
          If unsure, say Y.

Most distributions enable CONFIG_ZONE_DMA.

Immediate impact of CONFIG_ZONE_DMA
-----------------------------------

CONFIG_ZONE_DMA implicaates kmalloc() as follows:

struct kmem_cache *kmalloc_slab(size_t size, gfp_t flags)
{
	...
#ifdef CONFIG_ZONE_DMA
	if (unlikely((flags & GFP_DMA)))
		return kmalloc_dma_caches[index];
#endif
	...
}

ZONE_DMA users
==============

Turns out there are much more users of ZONE_DMA than expected even on x86.

Explicit requirements for ZONE_DMA with gfp flags
-------------------------------------------------

All drivers which explicitly use any of these flags implicate use
of ZONE_DMA for allocations:

  * GFP_DMA
  * __GFP_DMA

Implicit ZONE_DMA users
-----------------------

There are a series of implicit users of ZONE_DMA which use helpers. These are,
with details documented further below:

  * blk_queue_bounce()
  * blk_queue_bounce_limit()
  * dma_alloc_coherent_gfp_flags()
  * dma_generic_alloc_coherent()
  * intel_alloc_coherent()
  * _regmap_raw_write()
  * mempool_alloc_pages_isa()

x86 implicit and explicit ZONE_DMA users
-----------------------------------------

We list below all x86 implicit and explicit ZONE_DMA users.

# Explicit x86 users of GFP_DMA or __GFP_DMA

  * drivers/iio/common/ssp_sensors - wonder if enabling this on x86 was a mistake.
    Note that this needs SPI and SPI needs HAS_IOMEM. I only see HAS_IOMEM on
    s390 ? But I do think the Intel Minnowboard has SPI, but doubt it has
   the ssp sensor stuff.

 * drivers/input/rmi4/rmi_spi.c - same SPI question
 * drivers/media/common/siano/ - make allyesconfig yields it enabled, but
   not sure if this should ever be on x86
 * drivers/media/platform/sti/bdisp/ - likewise
  * drivers/media/platform/sti/hva/ - likewise
  * drivers/media/usb/gspca/ - likewise
  * drivers/mmc/host/wbsd.c - likewise
  * drivers/mtd/nand/gpmi-nand/ - likewise
  * drivers/net/can/spi/hi311x.c - likewise
  * drivers/net/can/spi/mcp251x.c - likewise
  * drivers/net/ethernet/agere/ - likewise
  * drivers/net/ethernet/neterion/vxge/ - likewise
  * drivers/net/ethernet/rocker/ - likewise
  * drivers/net/usb/kalmia.c - likewise
  * drivers/net/ethernet/neterion/vxge/ - likewise
  * drivers/spi/spi-pic32-sqi.c - likewise
  * drivers/spi/spi-sh-msiof.c - likewise
  * drivers/spi/spi-ti-qspi.c - likewise

  * drivers/tty/serial/mxs-auart.c - likewise - MXS AUART support
  * drivers/tty/synclink.c - likewise Microgate SyncLink card support
  * drivers/uio/uio_pruss - Texas Instruments PRUSS driver
  * drivers/usb/dwc2 - CONFIG_USB_DWC2_DUAL_ROLE - DesignWare USB2 DRD Core Support for dual role mode
  * drivers/usb/gadget/udc/ USB_GR_UDC - Aeroflex Gaisler GRUSBDC USB Peripheral Controller Driver
  * drivers/video/fbdev/da8xx-fb.c -  FB_DA8XX DA8xx/OMAP-L1xx/AM335x Framebuffer support
  * drivers/video/fbdev/mb862xx/mb862xxfb_accel.c - CONFIG_FB_MB862XX - Fujitsu MB862xx GDC support
  * drivers/video/fbdev/vermilion/vermilion.c - Intel LE80578 (Vermilion) support

Then we have a few drivers which we know we need on x86 but for these
we could use a run time flip to enable ZONE_DMA.

  * drivers/net/ethernet/broadcom/b44.c - bleh, yeah and there are some work hw bug
    work arounds for this, *but* again since its also odd, we could deal with this
    at run time
  * drivers/net/wimax/i2400m/ - ugh, who cares about this crap anyway nowadays, my
   point being another run time oddity
  * drivers/net/wireless/broadcom/b43legacy/ - ugh, same
  * drivers/platform/x86/asus-wmi.c - ugh same
  * drivers/platform/x86/dell-smbios.c - ugh same

Staging drivers are expected to have flaws, but worth noting.

  * drivers/staging/ - scattered drivers, rtlwifi/ is probably the only relevant one for x86                                                                                                  
SCSI is *severely* affected:                                                                                                                                                                                   
  * drivers/scsi/aacraid/ - crap Adaptec AACRAID support
  * drivers/scsi/ch.c - SCSI media changer support...
  * drivers/scsi/initio.c - Initio INI-9X00U/UW SCSI device driver...
  * drivers/scsi/osst.c - CHR_DEV_OSST  - SCSI OnStream SC-x0 tape support...
  * drivers/scsi/pmcraid.c - CONFIG_SCSI_PMCRAID - PMC SIERRA Linux MaxRAID adapter support
  * drivers/scsi/snic/ - Cisco SNIC Driver
  * drivers/mmc/core/mmc_test.c - MMC_TEST - MMC host test driver
 * drivers/net/wireless/broadcom/b43/ - means we'd have to at least use
   static keys
             
Larger blockers (now I see one reason why SCSI is a disaster):

  * drivers/scsi/hosts.c - scsi_host_alloc() always uses
    __GFP_DMA if (sht->unchecked_isa_dma && privsize)
    this could likely be adjusted or split off to other
    callers where we know this to be true.
 * drivers/scsi/scsi_scan.c - scsi_probe_and_add_lun() has a similar check
  * drivers/scsi/sg.c - sg_build_indirect() has similar check
  * drivers/scsi/sr.c - get_capabilities() *always* uses GFP_DMA
    which is called on sr_probe() WTF
    Don't drop this -- its cdrom
  * drivers/scsi/sr_ioctl.c - seriously...
  * drivers/scsi/sr_vendor.c - sr_cd_check() - checks if the CD is
    multisession, asks for offset etc 
  * drivers/scsi/st.c - SCSI tape support - on enlarge_buffer() this
    call BTW is recursive..  called on st_open(), the struct
    file_operations open()...

Larger blockers (SPI is also severely affected):
  * drivers/spi/spi.c - spi_pump_messages() which processes spi message queue

Larger blockers:

  * drivers/tty/hvc/hvc_iucv.c - hyperv console

And finally a non-issue:

  * drivers/xen/swiotlb-xen.c - used on struct dma_map_ops
    xen_swiotlb_dma_ops alloc() for only to check if the caller
    used it to se the dma_mask:                                                                                                                                   
        dma_mask = dev->coherent_dma_mask;
        if (!dma_mask)
                dma_mask = (gfp & GFP_DMA) ? DMA_BIT_MASK(24) : DMA_BIT_MASK(32);

That's the end of the review of all current explicit callers on x86.

# dma_alloc_coherent_gfp_flags() and dma_generic_alloc_coherent()

dma_alloc_coherent_gfp_flags() and dma_generic_alloc_coherent() set
GFP_DMA if if (dma_mask <= DMA_BIT_MASK(24))

# blk_queue_bounce()

void blk_queue_bounce(struct request_queue *q, struct bio **bio_orig)           
{
	...
	/*
	 * for non-isa bounce case, just check if the bounce pfn is equal
	 * to or bigger than the highest pfn in the system -- in that case,
	 * don't waste time iterating over bio segments
	 */
	if (!(q->bounce_gfp & GFP_DMA)) {
		if (q->limits.bounce_pfn >= blk_max_pfn)
			return;
		pool = page_pool;
	} else {
		BUG_ON(!isa_page_pool);
		pool = isa_page_pool;
	}
...
}

# blk_queue_bounce_limit()

void blk_queue_bounce_limit(struct request_queue *q, u64 max_addr)
{
        unsigned long b_pfn = max_addr >> PAGE_SHIFT;
        int dma = 0;
                                                                                
        q->bounce_gfp = GFP_NOIO;
#if BITS_PER_LONG == 64
        /*
         * Assume anything <= 4GB can be handled by IOMMU.  Actually
         * some IOMMUs can handle everything, but I don't know of a
         * way to test this here.
         */
        if (b_pfn < (min_t(u64, 0xffffffffUL, BLK_BOUNCE_HIGH) >> PAGE_SHIFT))
                dma = 1;
        q->limits.bounce_pfn = max(max_low_pfn, b_pfn);
#else
        if (b_pfn < blk_max_low_pfn)
                dma = 1;
        q->limits.bounce_pfn = b_pfn;
#endif
        if (dma) {
                init_emergency_isa_pool();
                q->bounce_gfp = GFP_NOIO | GFP_DMA;
                q->limits.bounce_pfn = b_pfn;
        }
}

# dma_alloc_coherent_gfp_flags() and dma_generic_alloc_coherent()

dma_alloc_coherent_gfp_flags() sets GFP_DMA if if (dma_mask <= DMA_BIT_MASK(24)).                                                                                                             
Likewise for dma_generic_alloc_coherent().

# intel_alloc_coherent()

intel_alloc_coherent() on drivers/iommu/intel-iommu.c also uses GFP_DMA                                                                                                                       
for DMA_BIT_MASK(32), part of the struct dma_map_ops intel_dma_ops on alloc().                                                                                                                

# _regmap_raw_write()

_regmap_raw_write() seems to always use GFP_DMA for async writes.                                                                                                                             

# mempool_alloc_pages_isa()

It implies you use GFP_DMA.

Architectures removed which used ZONE_DMA
-----------------------------------------

Although this topic pertains to x86, its worth mentioning that on the v4.17-rc1
release 8 architectures were removed: blackfin, cris, frv, m32r, metag,
mn10300, score, tile. Of these 8 architectures, 3 defined and used their own
ZONE_DMA:

  * blackfin
  * cris
  * m32r
