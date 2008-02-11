Date: Mon, 11 Feb 2008 15:27:16 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH]intel-iommu batched iotlb flushes
Message-Id: <20080211152716.65f5a753.randy.dunlap@oracle.com>
In-Reply-To: <20080211224105.GB24412@linux.intel.com>
References: <20080211224105.GB24412@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mgross@linux.intel.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Feb 2008 14:41:05 -0800 mark gross wrote:

> The hole is the following scenarios: 
> do many map_signal operations, do some unmap_signals, reuse a recently
> unmapped page, <errant DMA hardware sneaks through and steps on reused
> memory>
> 
> Or: you have rouge hardware using DMA's to look at pages: do many

  or rogue hardware?

> map_signal's, do many unmap_singles, reuse some unmapped pages : 

  signal .................... single

> <rouge hardware looks at reused page>

   why rouge?

> Note : these holes are very hard to get too, as the IOTLB is small and
> only the PTE's still in the IOTLB can be accessed through this
> mechanism.
> 
> Its recommended that strict is used when developing drivers that do DMA
> operations to catch bugs early.  For production code where performance
> is desired running with the batched IOTLB flushing is a good way to
> go.
> 
> 
> --mgross
> 
> 
> Signed-off-by: <mgross@linux.intel.com>
> 
> 
> 
> Index: linux-2.6.24-mm1/drivers/pci/intel-iommu.c
> ===================================================================
> --- linux-2.6.24-mm1.orig/drivers/pci/intel-iommu.c	2008-02-07 13:03:10.000000000 -0800
> +++ linux-2.6.24-mm1/drivers/pci/intel-iommu.c	2008-02-11 10:38:49.000000000 -0800

> @@ -50,11 +52,39 @@
>  
>  #define DOMAIN_MAX_ADDR(gaw) ((((u64)1) << gaw) - 1)
>  
> +
> +static void flush_unmaps_timeout(unsigned long data);
> +
> +static struct timer_list unmap_timer =
> +	TIMER_INITIALIZER(flush_unmaps_timeout, 0, 0);
> +
> +struct unmap_list {
> +	struct list_head list;
> +	struct dmar_domain *domain;
> +	struct iova *iova;
> +};
> +
> +static struct intel_iommu *g_iommus;
> +/* bitmap for indexing intel_iommus */
> +static unsigned long 	*g_iommus_to_flush;
> +static int g_num_of_iommus;
> +
> +static DEFINE_SPINLOCK(async_umap_flush_lock);
> +static LIST_HEAD(unmaps_to_do);
> +
> +static int timer_on;
> +static long list_size;
> +static int high_watermark;
> +
> +static struct dentry *intel_iommu_debug, *debug;
> +
> +
>  static void domain_remove_dev_info(struct dmar_domain *domain);
>  
>  static int dmar_disabled;
>  static int __initdata dmar_map_gfx = 1;
>  static int dmar_forcedac;
> +static int intel_iommu_strict;
>  
>  #define DUMMY_DEVICE_DOMAIN_INFO ((struct device_domain_info *)(-1))
>  static DEFINE_SPINLOCK(device_domain_lock);
> @@ -73,9 +103,13 @@
>  			printk(KERN_INFO
>  				"Intel-IOMMU: disable GFX device mapping\n");
>  		} else if (!strncmp(str, "forcedac", 8)) {
> -			printk (KERN_INFO
> +			printk(KERN_INFO
>  				"Intel-IOMMU: Forcing DAC for PCI devices\n");
>  			dmar_forcedac = 1;
> +		} else if (!strncmp(str, "strict", 8)) {
> +			printk(KERN_INFO
> +				"Intel-IOMMU: disable bached IOTLB flush\n");

                                                      batched

> +			intel_iommu_strict = 1;
>  		}
>  
>  		str += strcspn(str, ",");

> @@ -1672,7 +1702,29 @@
>  	for_each_drhd_unit(drhd) {
>  		if (drhd->ignored)
>  			continue;
> -		iommu = alloc_iommu(drhd);
> +		g_num_of_iommus++;
> +	}
> +
> +	nlongs = BITS_TO_LONGS(g_num_of_iommus);
> +	g_iommus_to_flush = kzalloc(nlongs * sizeof(unsigned long), GFP_KERNEL);
> +	if (!g_iommus_to_flush) {
> +		printk(KERN_ERR "Allocating bitmap array failed\n");

                identify:       "IOMMU:

> +		return -ENOMEM;
> +	}
> +
> +	g_iommus = kzalloc(g_num_of_iommus * sizeof(*iommu), GFP_KERNEL);
> +	if (!g_iommus) {
> +		kfree(g_iommus_to_flush);
> +		ret = -ENOMEM;
> +		goto error;
> +	}
> +
> +	i = 0;
> +	for_each_drhd_unit(drhd) {
> +		if (drhd->ignored)
> +			continue;
> +		iommu = alloc_iommu(&g_iommus[i], drhd);
> +		i++;
>  		if (!iommu) {
>  			ret = -ENOMEM;
>  			goto error;

> Index: linux-2.6.24-mm1/Documentation/kernel-parameters.txt
> ===================================================================
> --- linux-2.6.24-mm1.orig/Documentation/kernel-parameters.txt	2008-02-11 13:44:23.000000000 -0800
> +++ linux-2.6.24-mm1/Documentation/kernel-parameters.txt	2008-02-11 14:23:37.000000000 -0800
> @@ -822,6 +822,10 @@
>  			than 32 bit addressing. The default is to look
>  			for translation below 32 bit and if not available
>  			then look in the higher range.
> +		strict [Default Off]
> +			With this option on every umap_signle will

                                         on, every unmap_si{ngle,gnal} ??

> +			result in a hardware IOTLB flush opperation as
> +			opposed to batching them for performance.
>  
>  	io_delay=	[X86-32,X86-64] I/O delay method
>  		0x80


---
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
