Message-ID: <47B1CA9F.80004@oracle.com>
Date: Tue, 12 Feb 2008 08:34:39 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH]intel-iommu batched iotlb flushes
References: <20080211224105.GB24412@linux.intel.com> <20080211152716.65f5a753.randy.dunlap@oracle.com> <20080212160553.GD27490@linux.intel.com>
In-Reply-To: <20080212160553.GD27490@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mgross@linux.intel.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

mark gross wrote:
>  
> Index: linux-2.6.24-mm1/drivers/pci/intel-iommu.c
> ===================================================================
> --- linux-2.6.24-mm1.orig/drivers/pci/intel-iommu.c	2008-02-12 07:12:06.000000000 -0800
> +++ linux-2.6.24-mm1/drivers/pci/intel-iommu.c	2008-02-12 07:47:04.000000000 -0800

> @@ -1672,7 +1702,30 @@
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
> +		printk(KERN_ERR "Intel-IOMMU: \
> +			Allocating bitmap array failed\n");

I think that will make a string like below:
Intel-IOMMU: 			Allocating bitmap array failed

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
> --- linux-2.6.24-mm1.orig/Documentation/kernel-parameters.txt	2008-02-12 07:12:06.000000000 -0800
> +++ linux-2.6.24-mm1/Documentation/kernel-parameters.txt	2008-02-12 07:47:02.000000000 -0800
> @@ -822,6 +822,10 @@
>  			than 32 bit addressing. The default is to look
>  			for translation below 32 bit and if not available
>  			then look in the higher range.
> +		strict [Default Off]
> +			With this option on every umap_signal opperation will

			                          unmap_single operation

> +			result in a hardware IOTLB flush opperation as opposed
> +			to batching them for performance.
>  
>  	io_delay=	[X86-32,X86-64] I/O delay method
>  		0x80


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
