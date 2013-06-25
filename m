Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 28BDF6B0032
	for <linux-mm@kvack.org>; Tue, 25 Jun 2013 06:16:10 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 25 Jun 2013 15:37:27 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id CDE333940043
	for <linux-mm@kvack.org>; Tue, 25 Jun 2013 15:46:03 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5PAGEgc29360288
	for <linux-mm@kvack.org>; Tue, 25 Jun 2013 15:46:18 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5PAFwHZ030906
	for <linux-mm@kvack.org>; Tue, 25 Jun 2013 20:15:59 +1000
Message-ID: <51C96DBC.3070807@linux.vnet.ibm.com>
Date: Tue, 25 Jun 2013 15:45:24 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/3] mm/cma: Move dma contiguous changes into a seperate
 config
References: <1372062327-7028-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1372062327-7028-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, benh@kernel.crashing.org, paulus@samba.org, linuxppc-dev@lists.ozlabs.org

> diff --git a/drivers/base/Makefile b/drivers/base/Makefile
> index 4e22ce3..5d93bb5 100644
> --- a/drivers/base/Makefile
> +++ b/drivers/base/Makefile
> @@ -6,7 +6,7 @@ obj-y			:= core.o bus.o dd.o syscore.o \
>  			   attribute_container.o transport_class.o \
>  			   topology.o
>  obj-$(CONFIG_DEVTMPFS)	+= devtmpfs.o
> -obj-$(CONFIG_CMA) += dma-contiguous.o
> +obj-$(CONFIG_DMA_CMA) += dma-contiguous.o
>  obj-y			+= power/
>  obj-$(CONFIG_HAS_DMA)	+= dma-mapping.o
>  obj-$(CONFIG_HAVE_GENERIC_DMA_COHERENT) += dma-coherent.o
> diff --git a/include/linux/dma-contiguous.h b/include/linux/dma-contiguous.h
> index 01b5c84..00141d3 100644
> --- a/include/linux/dma-contiguous.h
> +++ b/include/linux/dma-contiguous.h
> @@ -57,7 +57,7 @@ struct cma;
>  struct page;
>  struct device;
> 
> -#ifdef CONFIG_CMA
> +#ifdef CONFIG_DMA_CMA
> 

We have some generic CMA documentation available in this file which need
to be moved to a more generic place (generic MM) as we are differentiating
it from DMA specific usage. Ideally we should have two documentation

(1) CMA usage for any subsystem
(2) DMA specific CMA usage


>  /*
>   * There is always at least global CMA area and a few optional device
> diff --git a/mm/Kconfig b/mm/Kconfig
> index e742d06..b362369 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -477,3 +477,23 @@ config FRONTSWAP
>  	  and swap data is stored as normal on the matching swap device.
> 
>  	  If unsure, say Y to enable frontswap.
> +
> +config CMA
> +	bool "Contiguous Memory Allocator"
> +	depends on HAVE_MEMBLOCK
> +	select MIGRATION
> +	select MEMORY_ISOLATION
> +	help
> +	  This enables the Contiguous Memory Allocator which allows other
> +	  subsystem to allocate big physically-contiguous blocks of memory

Should be "any subsystem" instead of "other subsystem"

> +
> +	  If unsure, say "n".
> +
> +config CMA_DEBUG
> +	bool "CMA debug messages (DEVELOPMENT)"
> +	depends on DEBUG_KERNEL && CMA
> +	help
> +	  Turns on debug messages in CMA.  This produces KERN_DEBUG
> +	  messages for every CMA call as well as various messages while
> +	  processing calls such as dma_alloc_from_contiguous().
> +	  This option does not affect warning and error messages.
> 

We should probably split up these debug configs as well to differentiate between
generic CMA_DEBUG and DMA_CMA_DEBUG options.


Regards
Anshuman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
