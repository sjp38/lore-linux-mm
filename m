Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 58AC46B0005
	for <linux-mm@kvack.org>; Sat, 28 Apr 2018 15:46:57 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p1-v6so3567314wrm.7
        for <linux-mm@kvack.org>; Sat, 28 Apr 2018 12:46:57 -0700 (PDT)
Received: from mail3-relais-sop.national.inria.fr (mail3-relais-sop.national.inria.fr. [192.134.164.104])
        by mx.google.com with ESMTPS id j9-v6si3271718wrc.12.2018.04.28.12.46.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 28 Apr 2018 12:46:55 -0700 (PDT)
Date: Sat, 28 Apr 2018 21:46:52 +0200 (CEST)
From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [LSF/MM TOPIC NOTES] x86 ZONE_DMA love
In-Reply-To: <20180428185514.GW27853@wotan.suse.de>
Message-ID: <alpine.DEB.2.20.1804282145450.2532@hadrien>
References: <20180426215406.GB27853@wotan.suse.de> <20180427053556.GB11339@infradead.org> <20180427161456.GD27853@wotan.suse.de> <20180428084221.GD31684@infradead.org> <20180428185514.GW27853@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: Christoph Hellwig <hch@infradead.org>, Dan Carpenter <dan.carpenter@oracle.com>, Julia Lawall <julia.lawall@lip6.fr>, linux-mm@kvack.org, mhocko@kernel.org, cl@linux.com, Jan Kara <jack@suse.cz>, matthew@wil.cx, x86@kernel.org, luto@amacapital.net, martin.petersen@oracle.com, jthumshirn@suse.de, broonie@kernel.org, Juergen Gross <jgross@suse.com>, linux-spi@vger.kernel.org, Joerg Roedel <joro@8bytes.org>, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>



On Sat, 28 Apr 2018, Luis R. Rodriguez wrote:

> On Sat, Apr 28, 2018 at 01:42:21AM -0700, Christoph Hellwig wrote:
> > On Fri, Apr 27, 2018 at 04:14:56PM +0000, Luis R. Rodriguez wrote:
> > > Do we have a list of users for x86 with a small DMA mask?
> > > Or, given that I'm not aware of a tool to be able to look
> > > for this in an easy way, would it be good to find out which
> > > x86 drivers do have a small mask?
> >
> > Basically you'll have to grep for calls to dma_set_mask/
> > dma_set_coherent_mask/dma_set_mask_and_coherent and their pci_*
> > wrappers with masks smaller 32-bit.  Some use numeric values,
> > some use DMA_BIT_MASK and various places uses local variables
> > or struct members to parse them, so finding them will be a bit
> > more work.  Nothing a coccinelle expert couldn't solve, though :)
>
> Thing is unless we have a specific flag used consistently I don't believe we
> can do this search with Coccinelle. ie, if we have local variables and based on
> some series of variables things are set, this makes the grammatical expression
> difficult to express.  So Cocinelle is not designed for this purpose.
>
> But I believe smatch [0] is intended exactly for this sort of purpose, is that
> right Dan? I gave a cursory look and I think it'd take me significant time to
> get such hunt down.
>
> [0] https://lwn.net/Articles/691882/

FWIW, here is my semantic patch and the output - it reports on things that
appear to be too small and things that it doesn't know about.

What are the relevant pci wrappers?  I didn't find them.

julia

@initialize:ocaml@
@@

let clean s = String.concat "" (Str.split (Str.regexp " ") s)

let shorten s = List.nth (Str.split (Str.regexp "linux-next/") s) 1

@bad1 exists@
identifier i,x;
expression e;
position p;
@@

x = DMA_BIT_MASK(i)
...
\(dma_set_mask@p\|dma_set_coherent_mask@p\|dma_set_mask_and_coherent@p\)(e,x)

@bad2@
identifier i;
expression e;
position p;
@@

\(dma_set_mask@p\|dma_set_coherent_mask@p\|dma_set_mask_and_coherent@p\)
   (e,DMA_BIT_MASK(i))

@ok1 exists@
identifier x;
expression e;
constant c;
position p != bad1.p;
@@

x = \(DMA_BIT_MASK(c)\|0xffffffff\)
...
\(dma_set_mask@p\|dma_set_coherent_mask@p\|dma_set_mask_and_coherent@p\)(e,x)

@script:ocaml@
p << ok1.p;
c << ok1.c;
@@

let c = int_of_string c in
if c < 32
then
  let p = List.hd p in
  Printf.printf "too small: %s:%d: %d\n" (shorten p.file) p.line c

@ok2@
expression e;
constant c;
position p != bad2.p;
@@

\(dma_set_mask@p\|dma_set_coherent_mask@p\|dma_set_mask_and_coherent@p\)
   (e,\(DMA_BIT_MASK(c)\|0xffffffff\))

@script:ocaml@
p << ok2.p;
c << ok2.c;
@@

let c = int_of_string c in
if c < 32
then
  let p = List.hd p in
  Printf.printf "too small: %s:%d: %d\n" (shorten p.file) p.line c

@unk@
expression e,e1 != ATA_DMA_MASK;
position p != {ok1.p,ok2.p};
@@

\(dma_set_mask@p\|dma_set_coherent_mask@p\|dma_set_mask_and_coherent@p\)(e,e1)

@script:ocaml@
p << unk.p;
e1 << unk.e1;
@@

let p = List.hd p in
Printf.printf "unknown: %s:%d: %s\n" (shorten p.file) p.line (clean e1)

-----------------

too small: drivers/gpu/drm/i915/i915_drv.c:1138: 30
too small: drivers/net/wireless/broadcom/b43/dma.c:1068: 30
unknown: sound/pci/ctxfi/cthw20k2.c:2033: DMA_BIT_MASK(dma_bits)
unknown: sound/pci/ctxfi/cthw20k2.c:2034: DMA_BIT_MASK(dma_bits)
unknown: drivers/scsi/megaraid/megaraid_sas_base.c:6036: consistent_mask
unknown: drivers/net/wireless/ath/wil6210/txrx.c:200: DMA_BIT_MASK(wil->dma_addr_size)
unknown: drivers/net/ethernet/netronome/nfp/nfp_main.c:452: DMA_BIT_MASK(NFP_NET_MAX_DMA_BITS)
unknown: drivers/gpu/host1x/dev.c:199: host->info->dma_mask
unknown: drivers/iommu/arm-smmu-v3.c:2691: DMA_BIT_MASK(smmu->oas)
too small: sound/pci/es1968.c:2692: 28
too small: sound/pci/es1968.c:2693: 28
too small: drivers/net/wireless/broadcom/b43legacy/dma.c:809: 30
unknown: drivers/virtio/virtio_mmio.c:573: DMA_BIT_MASK(32+PAGE_SHIFT)
unknown: drivers/ata/sata_nv.c:762: pp->adma_dma_mask
unknown: drivers/dma/mmp_pdma.c:1094: pdev->dev->coherent_dma_mask
too small: sound/pci/maestro3.c:2557: 28
too small: sound/pci/maestro3.c:2558: 28
too small: sound/pci/ice1712/ice1712.c:2533: 28
too small: sound/pci/ice1712/ice1712.c:2534: 28
unknown: drivers/net/wireless/ath/wil6210/pmc.c:132: DMA_BIT_MASK(wil->dma_addr_size)
unknown: drivers/gpu/drm/nouveau/nvkm/engine/device/tegra.c:313: DMA_BIT_MASK(tdev->func->iommu_bit)
unknown: drivers/net/ethernet/synopsys/dwc-xlgmac-common.c:96: DMA_BIT_MASK(pdata->hw_feat.dma_width)
too small: sound/pci/als4000.c:874: 24
too small: sound/pci/als4000.c:875: 24
unknown: drivers/hwtracing/coresight/coresight-tmc.c:335: DMA_BIT_MASK(dma_mask)
unknown: drivers/dma/xilinx/xilinx_dma.c:2634: DMA_BIT_MASK(addr_width)
too small: sound/pci/sonicvibes.c:1262: 24
too small: sound/pci/sonicvibes.c:1263: 24
too small: sound/pci/es1938.c:1600: 24
too small: sound/pci/es1938.c:1601: 24
unknown: drivers/crypto/ccree/cc_driver.c:260: dma_mask
unknown: sound/pci/hda/hda_intel.c:1888: DMA_BIT_MASK(dma_bits)
unknown: sound/pci/hda/hda_intel.c:1889: DMA_BIT_MASK(dma_bits)
unknown: drivers/gpu/drm/nouveau/nvkm/engine/device/pci.c:1688: DMA_BIT_MASK(bits)
unknown: drivers/net/ethernet/amd/xgbe/xgbe-main.c:294: DMA_BIT_MASK(pdata->hw_feat.dma_width)
too small: sound/pci/ali5451/ali5451.c:2110: 31
too small: sound/pci/ali5451/ali5451.c:2111: 31
unknown: drivers/dma/pxa_dma.c:1375: op->dev.coherent_dma_mask
unknown: drivers/media/platform/qcom/venus/core.c:186: core->res->dma_mask
unknown: drivers/mtd/nand/raw/denali.c:1298: DMA_BIT_MASK(dma_bit)
unknown: drivers/net/wireless/ath/wil6210/pcie_bus.c:299: DMA_BIT_MASK(dma_addr_size[i])
unknown: drivers/gpu/drm/msm/msm_drv.c:1132: ~0
unknown: drivers/net/ethernet/altera/altera_tse_main.c:1449: DMA_BIT_MASK(priv->dmaops->dmamask)
unknown: drivers/net/ethernet/altera/altera_tse_main.c:1450: DMA_BIT_MASK(priv->dmaops->dmamask)
unknown: drivers/net/ethernet/sfc/efx.c:1298: dma_mask
too small: sound/pci/als300.c:661: 28
too small: sound/pci/als300.c:662: 28
unknown: drivers/hwtracing/intel_th/core.c:379: parent->coherent_dma_mask
too small: drivers/media/pci/sta2x11/sta2x11_vip.c:983: 26
too small: drivers/media/pci/sta2x11/sta2x11_vip.c:859: 29
too small: drivers/net/ethernet/broadcom/b44.c:2389: 30
too small: sound/pci/azt3328.c:2421: 24
too small: sound/pci/azt3328.c:2422: 24
too small: sound/pci/trident/trident_main.c:3552: 30
too small: sound/pci/trident/trident_main.c:3553: 30
unknown: drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c:128: DMA_BIT_MASK(NFP_NET_MAX_DMA_BITS)
unknown: drivers/net/ethernet/sfc/falcon/efx.c:1251: dma_mask
unknown: drivers/virtio/virtio_pci_legacy.c:226: DMA_BIT_MASK(32+VIRTIO_PCI_QUEUE_ADDR_SHIFT)
unknown: sound/pci/ctxfi/cthw20k1.c:1908: DMA_BIT_MASK(dma_bits)
unknown: sound/pci/ctxfi/cthw20k1.c:1909: DMA_BIT_MASK(dma_bits)
unknown: drivers/iommu/arm-smmu.c:1848: DMA_BIT_MASK(size)
unknown: drivers/scsi/aic7xxx/aic7xxx_osm_pci.c:242: mask_39bit
unknown: sound/pci/emu10k1/emu10k1_main.c:1910: emu->dma_mask
unknown: drivers/usb/gadget/udc/bdc/bdc_pci.c:86: pci->dev.coherent_dma_mask
too small: sound/pci/sis7019.c:1328: 30
