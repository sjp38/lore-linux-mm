Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4C6A16B5830
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 07:23:46 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id x13so4049641wro.9
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 04:23:46 -0800 (PST)
Received: from mo6-p01-ob.smtp.rzone.de (mo6-p01-ob.smtp.rzone.de. [2a01:238:20a:202:5301::7])
        by mx.google.com with ESMTPS id o205si3925090wma.28.2018.11.30.04.23.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Nov 2018 04:23:44 -0800 (PST)
Subject: Re: use generic DMA mapping code in powerpc V4
References: <20181114082314.8965-1-hch@lst.de> <20181127074253.GB30186@lst.de>
 <87zhttfonk.fsf@concordia.ellerman.id.au>
 <4d4e3cdd-d1a9-affe-0f63-45b8c342bbd6@xenosoft.de>
 <20181129170351.GC27951@lst.de>
 <d0e04a85-f17d-414e-6fea-971414417430@xenosoft.de>
 <20181130105346.GB26765@lst.de>
From: Christian Zigotzky <chzigotzky@xenosoft.de>
Message-ID: <8694431d-c669-b7b9-99fa-e99db5d45a7d@xenosoft.de>
Date: Fri, 30 Nov 2018 13:23:20 +0100
MIME-Version: 1.0
In-Reply-To: <20181130105346.GB26765@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: de-DE
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-arch@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Olof Johansson <olof@lixom.net>

Hi Christoph,

Thanks a lot for your fast reply.

On 30 November 2018 at 11:53AM, Christoph Hellwig wrote:
> Hi Christian,
>
> for such a diverse architecture like powerpc we'll have to rely on
> users / non core developers like you to help with testing.
I see. I will help as good as I can.
>
> Can you try the patch below for he cyrus config?
Yes, of course. I patched your Git kernel and after that I compiled it 
again. U-Boot loads the kernel and the dtb file. Then the kernel starts 
but it doesn't find any hard disks (partitions).

@All
Could you please also test Christoph's kernel on your PASEMI and NXP 
boards? Download: 'git clone git://git.infradead.org/users/hch/misc.git 
-b powerpc-dma.4 a'
*PLEASE*
>
> For the nemo one I have no idea yet,
We had some problems with the PASEMI ethernet and DMA two years ago. I 
had to deactivate the option PASEMI_IOMMU_DMA_FORCE.

commit 416f37d0816b powerpc/pasemi: Fix coherent_dma_mask for dma engine:

Commit 817820b0 ("powerpc/iommu: Support "hybrid" iommu/direct DMA
ops for coherent_mask < dma_mask) adds a check of coherent_dma_mask for
dma allocations.

Unfortunately current PASemi code does not set this value for the DMA
engine, which ends up with the default value of 0xffffffff, the result
is on a PASemi system with >2Gb ram and iommu enabled the onboard
ethernet stops working due to an inability to allocate memory. Add an
initialisation to pci_dma_dev_setup_pasemi().
Signed-off-by: Darren Stevens <darren@stevens-zone.net>
Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>

Links:
https://lists.ozlabs.org/pipermail/linuxppc-dev/2016-July/146701.html
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=416f37d0816b9720b8227953e55954d81456f991

FYI: DMA handling has been rewritten in 2015. We had some problems with 
the new DMA code in 2015. I had to revert the commit ' [RFC/PATCH,v2] 
powerpc/iommu: Support "hybrid" iommu/direct DMA ops for coherent_mask < 
dma_mask' in 2015.

Link: https://patchwork.ozlabs.org/patch/472535/

I had to create a patch in 2015:

     diff -rupN linux-4.4/arch/powerpc/Kconfig 
linux-4.4-nemo/arch/powerpc/Kconfig
     --- linux-4.4/arch/powerpc/Kconfig    2015-12-07 00:43:12.000000000 
+0100
     +++ linux-4.4-nemo/arch/powerpc/Kconfig    2015-12-07 
14:48:23.371987988 +0100
     @@ -158,8 +155,6 @@ config PPC
          select HAVE_PERF_EVENTS_NMI if PPC64
          select EDAC_SUPPORT
          select EDAC_ATOMIC_SCRUB
     -    select ARCH_HAS_DMA_SET_COHERENT_MASK
     -    select HAVE_ARCH_SECCOMP_FILTER

      config GENERIC_CSUM
          def_bool CPU_LITTLE_ENDIAN
     @@ -419,8 +414,7 @@ config PPC64_SUPPORTS_MEMORY_FAILURE

      config KEXEC
          bool "kexec system call"
     -    depends on (PPC_BOOK3S || FSL_BOOKE || (44x && !SMP)) || 
PPC_BOOK3E
     -    select KEXEC_CORE
     +    depends on (PPC_BOOK3S || FSL_BOOKE || (44x && !SMP))
          help
            kexec is a system call that implements the ability to 
shutdown your
            current kernel, and to start another kernel.  It is like a 
reboot

     diff -rupN linux-4.4/arch/powerpc/kernel/dma.c 
linux-4.4-nemo/arch/powerpc/kernel/dma.c
     --- linux-4.4/arch/powerpc/kernel/dma.c    2015-12-07 
00:43:12.000000000 +0100
     +++ linux-4.4-nemo/arch/powerpc/kernel/dma.c    2015-12-07 
14:49:38.098286892 +0100
     @@ -40,31 +39,9 @@ static u64 __maybe_unused get_pfn_limit(
          return pfn;
      }

     -static int dma_direct_dma_supported(struct device *dev, u64 mask)
     -{
     -#ifdef CONFIG_PPC64
     -    u64 limit = get_dma_offset(dev) + (memblock_end_of_DRAM() - 1);
     -
     -    /* Limit fits in the mask, we are good */
     -    if (mask >= limit)
     -        return 1;
     -
     -#ifdef CONFIG_FSL_SOC
     -    /* Freescale gets another chance via ZONE_DMA/ZONE_DMA32, however
     -     * that will have to be refined if/when they support iommus
     -     */
     -    return 1;
     -#endif
     -    /* Sorry ... */
     -    return 0;
     -#else
     -    return 1;
     -#endif
     -}
     -
     -void *__dma_direct_alloc_coherent(struct device *dev, size_t size,
     -                  dma_addr_t *dma_handle, gfp_t flag,
     -                  struct dma_attrs *attrs)
     +void *dma_direct_alloc_coherent(struct device *dev, size_t size,
     +                dma_addr_t *dma_handle, gfp_t flag,
     +                struct dma_attrs *attrs)
      {
          void *ret;
      #ifdef CONFIG_NOT_COHERENT_CACHE
     @@ -119,9 +96,9 @@ void *__dma_direct_alloc_coherent(struct
      #endif
      }

     -void __dma_direct_free_coherent(struct device *dev, size_t size,
     -                void *vaddr, dma_addr_t dma_handle,
     -                struct dma_attrs *attrs)
     +void dma_direct_free_coherent(struct device *dev, size_t size,
     +                  void *vaddr, dma_addr_t dma_handle,
     +                  struct dma_attrs *attrs)
      {
      #ifdef CONFIG_NOT_COHERENT_CACHE
          __dma_free_coherent(size, vaddr);
     @@ -130,51 +107,6 @@ void __dma_direct_free_coherent(struct d
      #endif
      }

     -static void *dma_direct_alloc_coherent(struct device *dev, size_t 
size,
     -                       dma_addr_t *dma_handle, gfp_t flag,
     -                       struct dma_attrs *attrs)
     -{
     -    struct iommu_table *iommu;
     -
     -    /* The coherent mask may be smaller than the real mask, check if
     -     * we can really use the direct ops
     -     */
     -    if (dma_direct_dma_supported(dev, dev->coherent_dma_mask))
     -        return __dma_direct_alloc_coherent(dev, size, dma_handle,
     -                           flag, attrs);
     -
     -    /* Ok we can't ... do we have an iommu ? If not, fail */
     -    iommu = get_iommu_table_base(dev);
     -    if (!iommu)
     -        return NULL;
     -
     -    /* Try to use the iommu */
     -    return iommu_alloc_coherent(dev, iommu, size, dma_handle,
     -                    dev->coherent_dma_mask, flag,
     -                    dev_to_node(dev));
     -}
     -
     -static void dma_direct_free_coherent(struct device *dev, size_t size,
     -                     void *vaddr, dma_addr_t dma_handle,
     -                     struct dma_attrs *attrs)
     -{
     -    struct iommu_table *iommu;
     -
     -    /* See comments in dma_direct_alloc_coherent() */
     -    if (dma_direct_dma_supported(dev, dev->coherent_dma_mask))
     -        return __dma_direct_free_coherent(dev, size, vaddr, 
dma_handle,
     -                          attrs);
     -    /* Maybe we used an iommu ... */
     -    iommu = get_iommu_table_base(dev);
     -
     -    /* If we hit that we should have never allocated in the first
     -     * place so how come we are freeing ?
     -     */
     -    if (WARN_ON(!iommu))
     -        return;
     -    iommu_free_coherent(iommu, size, vaddr, dma_handle);
     -}
     -
      int dma_direct_mmap_coherent(struct device *dev, struct 
vm_area_struct *vma,
                       void *cpu_addr, dma_addr_t handle, size_t size,
                       struct dma_attrs *attrs)
     @@ -215,6 +147,18 @@ static void dma_direct_unmap_sg(struct d
      {
      }

     +static int dma_direct_dma_supported(struct device *dev, u64 mask)
     +{
     +#ifdef CONFIG_PPC64
     +    /* Could be improved so platforms can set the limit in case
     +     * they have limited DMA windows
     +     */
     +    return mask >= get_dma_offset(dev) + (memblock_end_of_DRAM() - 1);
     +#else
     +    return 1;
     +#endif
     +}
     +
      static u64 dma_direct_get_required_mask(struct device *dev)
      {
          u64 end, mask;
     @@ -286,25 +230,6 @@ struct dma_map_ops dma_direct_ops = {
      };
      EXPORT_SYMBOL(dma_direct_ops);

     -int dma_set_coherent_mask(struct device *dev, u64 mask)
     -{
     -    if (!dma_supported(dev, mask)) {
     -        /*
     -         * We need to special case the direct DMA ops which can
     -         * support a fallback for coherent allocations. There
     -         * is no dma_op->set_coherent_mask() so we have to do
     -         * things the hard way:
     -         */
     -        if (get_dma_ops(dev) != &dma_direct_ops ||
     -            get_iommu_table_base(dev) == NULL ||
     -            !dma_iommu_dma_supported(dev, mask))
     -            return -EIO;
     -    }
     -    dev->coherent_dma_mask = mask;
     -    return 0;
     -}
     -EXPORT_SYMBOL(dma_set_coherent_mask);
     -
      #define PREALLOC_DMA_DEBUG_ENTRIES (1 << 16)

      int __dma_set_mask(struct device *dev, u64 dma_mask)

Interesting PASEMI ethernet files:

arch/powerpc/platforms/pasemi/iommu.c
drivers/net/ethernet/pasemi/pasemi_mac.c
drivers/net/ethernet/pasemi/pasemi_mac.h
drivers/net/ethernet/pasemi/pasemi_mac_ethtool.c
drivers/net/ethernet/pasemi/Makefile
drivers/net/ethernet/pasemi/Kconfig

I know this is a lot of information but I hope it helps.

Thanks,
Christian
