Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 866B86B0005
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 13:46:30 -0500 (EST)
Received: by mail-pf0-f174.google.com with SMTP id 65so46256841pff.2
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 10:46:30 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id s137si11129372pfs.11.2016.01.22.10.46.28
        for <linux-mm@kvack.org>;
        Fri, 22 Jan 2016 10:46:28 -0800 (PST)
Date: Fri, 22 Jan 2016 13:46:26 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH] phys_to_pfn_t: use phys_addr_t
Message-ID: <20160122184626.GF2948@linux.intel.com>
References: <20160122175114.38521.76801.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160122175114.38521.76801.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


Missed one:

static inline dma_addr_t pfn_t_to_phys(pfn_t pfn)
{
        return PFN_PHYS(pfn_t_to_pfn(pfn));
}

On Fri, Jan 22, 2016 at 09:51:14AM -0800, Dan Williams wrote:
> A dma_addr_t is potentially smaller than a phys_addr_t on some archs.
> Don't truncate the address when doing the pfn conversion.
> 
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> Reported-by: Matthew Wilcox <willy@linux.intel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  include/linux/pfn_t.h             |    2 +-
>  kernel/memremap.c                 |    2 +-
>  tools/testing/nvdimm/test/iomap.c |    2 +-
>  3 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/pfn_t.h b/include/linux/pfn_t.h
> index 0703b5360d31..98145a17c1eb 100644
> --- a/include/linux/pfn_t.h
> +++ b/include/linux/pfn_t.h
> @@ -29,7 +29,7 @@ static inline pfn_t pfn_to_pfn_t(unsigned long pfn)
>  	return __pfn_to_pfn_t(pfn, 0);
>  }
>  
> -extern pfn_t phys_to_pfn_t(dma_addr_t addr, unsigned long flags);
> +extern pfn_t phys_to_pfn_t(phys_addr_t addr, unsigned long flags);
>  
>  static inline bool pfn_t_has_page(pfn_t pfn)
>  {
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index e517a16cb426..7f6d08f41d72 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -150,7 +150,7 @@ void devm_memunmap(struct device *dev, void *addr)
>  }
>  EXPORT_SYMBOL(devm_memunmap);
>  
> -pfn_t phys_to_pfn_t(dma_addr_t addr, unsigned long flags)
> +pfn_t phys_to_pfn_t(phys_addr_t addr, unsigned long flags)
>  {
>  	return __pfn_to_pfn_t(addr >> PAGE_SHIFT, flags);
>  }
> diff --git a/tools/testing/nvdimm/test/iomap.c b/tools/testing/nvdimm/test/iomap.c
> index 7ec7df9e7fc7..0c1a7e65bb81 100644
> --- a/tools/testing/nvdimm/test/iomap.c
> +++ b/tools/testing/nvdimm/test/iomap.c
> @@ -113,7 +113,7 @@ void *__wrap_devm_memremap_pages(struct device *dev, struct resource *res,
>  }
>  EXPORT_SYMBOL(__wrap_devm_memremap_pages);
>  
> -pfn_t __wrap_phys_to_pfn_t(dma_addr_t addr, unsigned long flags)
> +pfn_t __wrap_phys_to_pfn_t(phys_addr_t addr, unsigned long flags)
>  {
>  	struct nfit_test_resource *nfit_res = get_nfit_res(addr);
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
