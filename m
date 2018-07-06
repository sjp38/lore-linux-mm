Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5B90D6B000D
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 14:46:54 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id y7-v6so5123810plt.17
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 11:46:54 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z2-v6si7863772pgp.681.2018.07.06.11.46.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 06 Jul 2018 11:46:53 -0700 (PDT)
Subject: Re: [RFC PATCH 2/2] mm/pmem: Add memblock based e820 platform driver
References: <20180706082911.13405-1-aneesh.kumar@linux.ibm.com>
 <20180706082911.13405-2-aneesh.kumar@linux.ibm.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <0a28ed01-fc76-0f08-3f8a-c2dd7f5fcd2f@infradead.org>
Date: Fri, 6 Jul 2018 11:46:48 -0700
MIME-Version: 1.0
In-Reply-To: <20180706082911.13405-2-aneesh.kumar@linux.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, akpm@linux-foundation.org, Dan Williams <dan.j.williams@intel.com>, Oliver <oohall@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/06/18 01:29, Aneesh Kumar K.V wrote:
> This patch steal system RAM and use that to emulate pmem device using the
> e820 platform driver.
> 
> This adds a new kernel command line 'pmemmap' which takes the format <size[KMG]>
> to allocate memory early in the boot. This memory is later registered as
> persistent memory range.
> 
> Based on original patch from Oliver OHalloran <oliveroh@au1.ibm.com>
> 
> Not-Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> ---
>  drivers/nvdimm/Kconfig        |  13 ++++
>  drivers/nvdimm/Makefile       |   1 +
>  drivers/nvdimm/memblockpmem.c | 115 ++++++++++++++++++++++++++++++++++
>  3 files changed, 129 insertions(+)
>  create mode 100644 drivers/nvdimm/memblockpmem.c
> 
> diff --git a/drivers/nvdimm/Kconfig b/drivers/nvdimm/Kconfig
> index 50d2a33de441..cbbbcbd4506b 100644
> --- a/drivers/nvdimm/Kconfig
> +++ b/drivers/nvdimm/Kconfig
> @@ -115,4 +115,17 @@ config OF_PMEM
>  config PMEM_PLATFORM_DEVICE
>         bool
>  
> +config MEMBLOCK_PMEM
> +	bool "pmemmap= parameter support"
> +	default y
> +	depends on HAVE_MEMBLOCK
> +	select PMEM_PLATFORM_DEVICE
> +	help
> +	  Add support for the pmemmap= kernel command line parameter. This is similar
> +	  to the memmap= parameter available on ACPI platforms, but it uses generic
> +	  kernel facilities (the memblock allocator) to reserve memory rather than adding
> +	  to the e820 table.
> +
> +	  Select Y if unsure.
> +
>  endif


There's a high barrier for "default y", something like if the platform or device
cannot boot without it, it can be "default y".  I have doubts that this is OK.


-- 
~Randy
