Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0CBB58E0004
	for <linux-mm@kvack.org>; Sun,  9 Dec 2018 05:23:46 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id y88so7403583pfi.9
        for <linux-mm@kvack.org>; Sun, 09 Dec 2018 02:23:46 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id 90si7628458plb.17.2018.12.09.02.23.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 09 Dec 2018 02:23:44 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 12/34] powerpc/cell: move dma direct window setup out of dma_configure
In-Reply-To: <20181114082314.8965-13-hch@lst.de>
References: <20181114082314.8965-1-hch@lst.de> <20181114082314.8965-13-hch@lst.de>
Date: Sun, 09 Dec 2018 21:23:39 +1100
Message-ID: <871s6r3sno.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>
Cc: linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Christoph Hellwig <hch@lst.de> writes:

> Configure the dma settings at device setup time, and stop playing games
> with get_pci_dma_ops.  This prepares for using the common dma_configure
> code later on.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  arch/powerpc/platforms/cell/iommu.c | 20 +++++++++++---------
>  1 file changed, 11 insertions(+), 9 deletions(-)

This one's crashing, haven't dug into why yet:

  [    1.347085] Unable to handle kernel paging request for data at address 0x00000040
  [    1.391505] Faulting instruction address: 0xc0000000006b6e6c
  cpu 0x0: Vector: 380 (Data SLB Access) at [c0000007fc9032d0]
  pc: c0000000006b6e6c: .of_n_addr_cells+0x34/0xc0
  lr: c000000000070b30: .cell_iommu_get_fixed_address+0x58/0x2b0
  sp: c0000007fc903560
  msr: 9000000000009032
  dar: 40
  current = 0xc0000007fc8d0000
  paca    = 0xc000000000f60000	 irqmask: 0x03	 irq_happened: 0x01
  pid   = 1, comm = swapper/0
  Linux version 4.20.0-rc2-gcc7x-g1e32f48 (kerkins@p82) (gcc version 7.4.1 20181208 (Custom eb377405ab2d1900)) #1 SMP Sun Dec 9 12:16:48 AEDT 2018
  enter ? for help
  [c0000007fc9035f0] c000000000070b30 .cell_iommu_get_fixed_address+0x58/0x2b0
  [c0000007fc9036c0] c0000000000711ac .cell_dma_dev_setup.part.1+0x24/0x118
  [c0000007fc903740] c000000000071374 .cell_of_bus_notify+0x6c/0xbc
  [c0000007fc9037c0] c0000000000e7ef0 .notifier_call_chain+0x90/0xf8
  [c0000007fc903860] c0000000000e8c2c .blocking_notifier_call_chain+0x84/0xb8
  [c0000007fc9038f0] c000000000597544 .device_add+0x584/0x7b8
  [c0000007fc9039c0] c0000000005a0308 .platform_device_add+0x148/0x2f0
  [c0000007fc903a60] c0000000005a1508 .platform_device_register_full+0x148/0x168
  [c0000007fc903ae0] c000000000a9a8a0 .__machine_initcall_cell_cell_publish_devices+0x1bc/0x210
  [c0000007fc903be0] c00000000000eca4 .do_one_initcall+0x64/0x2d8
  [c0000007fc903cc0] c000000000a844ec .kernel_init_freeable+0x3dc/0x4e4
  [c0000007fc903da0] c00000000000f06c .kernel_init+0x24/0x150
  [c0000007fc903e20] c00000000000a9c0 .ret_from_kernel_thread+0x58/0x78

cheers

> diff --git a/arch/powerpc/platforms/cell/iommu.c b/arch/powerpc/platforms/cell/iommu.c
> index 12352a58072a..cce5bf9515e5 100644
> --- a/arch/powerpc/platforms/cell/iommu.c
> +++ b/arch/powerpc/platforms/cell/iommu.c
> @@ -657,14 +657,21 @@ static const struct dma_map_ops dma_iommu_fixed_ops = {
>  	.mapping_error	= dma_iommu_mapping_error,
>  };
>  
> +static u64 cell_iommu_get_fixed_address(struct device *dev);
> +
>  static void cell_dma_dev_setup(struct device *dev)
>  {
> -	if (get_pci_dma_ops() == &dma_iommu_ops)
> +	if (get_pci_dma_ops() == &dma_iommu_ops) {
> +		u64 addr = cell_iommu_get_fixed_address(dev);
> +
> +		if (addr != OF_BAD_ADDR)
> +			set_dma_offset(dev, addr + dma_iommu_fixed_base);
>  		set_iommu_table_base(dev, cell_get_iommu_table(dev));
> -	else if (get_pci_dma_ops() == &dma_nommu_ops)
> +	} else if (get_pci_dma_ops() == &dma_nommu_ops) {
>  		set_dma_offset(dev, cell_dma_nommu_offset);
> -	else
> +	} else {
>  		BUG();
> +	}
>  }
>  
>  static void cell_pci_dma_dev_setup(struct pci_dev *dev)
> @@ -950,19 +957,14 @@ static int dma_suported_and_switch(struct device *dev, u64 dma_mask)
>  {
>  	if (dma_mask == DMA_BIT_MASK(64) &&
>  	    cell_iommu_get_fixed_address(dev) != OF_BAD_ADDR) {
> -		u64 addr = cell_iommu_get_fixed_address(dev) +
> -			dma_iommu_fixed_base;
>  		dev_dbg(dev, "iommu: 64-bit OK, using fixed ops\n");
> -		dev_dbg(dev, "iommu: fixed addr = %llx\n", addr);
>  		set_dma_ops(dev, &dma_iommu_fixed_ops);
> -		set_dma_offset(dev, addr);
>  		return 1;
>  	}
>  
>  	if (dma_iommu_dma_supported(dev, dma_mask)) {
>  		dev_dbg(dev, "iommu: not 64-bit, using default ops\n");
> -		set_dma_ops(dev, get_pci_dma_ops());
> -		cell_dma_dev_setup(dev);
> +		set_dma_ops(dev, &dma_iommu_ops);
>  		return 1;
>  	}
>  
> -- 
> 2.19.1
