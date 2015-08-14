Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 33BA46B0038
	for <linux-mm@kvack.org>; Fri, 14 Aug 2015 17:37:23 -0400 (EDT)
Received: by qkbm65 with SMTP id m65so29939601qkb.2
        for <linux-mm@kvack.org>; Fri, 14 Aug 2015 14:37:23 -0700 (PDT)
Received: from mail-qg0-x234.google.com (mail-qg0-x234.google.com. [2607:f8b0:400d:c04::234])
        by mx.google.com with ESMTPS id b69si11702966qgb.50.2015.08.14.14.37.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Aug 2015 14:37:22 -0700 (PDT)
Received: by qgeg42 with SMTP id g42so60768784qge.1
        for <linux-mm@kvack.org>; Fri, 14 Aug 2015 14:37:22 -0700 (PDT)
Date: Fri, 14 Aug 2015 17:37:15 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [RFC PATCH 1/7] x86, mm: ZONE_DEVICE for "device memory"
Message-ID: <20150814213714.GA3265@gmail.com>
References: <20150813031253.36913.29580.stgit@otcpl-skl-sds-2.jf.intel.com>
 <20150813035005.36913.77364.stgit@otcpl-skl-sds-2.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20150813035005.36913.77364.stgit@otcpl-skl-sds-2.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-kernel@vger.kernel.org, boaz@plexistor.com, riel@redhat.com, linux-nvdimm@lists.01.org, Dave Hansen <dave.hansen@linux.intel.com>, david@fromorbit.com, mingo@kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, mgorman@suse.de, "H. Peter Anvin" <hpa@zytor.com>, ross.zwisler@linux.intel.com, torvalds@linux-foundation.org, hch@lst.de

On Wed, Aug 12, 2015 at 11:50:05PM -0400, Dan Williams wrote:
> While pmem is usable as a block device or via DAX mappings to userspace
> there are several usage scenarios that can not target pmem due to its
> lack of struct page coverage. In preparation for "hot plugging" pmem
> into the vmemmap add ZONE_DEVICE as a new zone to tag these pages
> separately from the ones that are subject to standard page allocations.
> Importantly "device memory" can be removed at will by userspace
> unbinding the driver of the device.
> 
> Having a separate zone prevents allocation and otherwise marks these
> pages that are distinct from typical uniform memory.  Device memory has
> different lifetime and performance characteristics than RAM.  However,
> since we have run out of ZONES_SHIFT bits this functionality currently
> depends on sacrificing ZONE_DMA.
> 
> arch_add_memory() is reorganized a bit in preparation for a new
> arch_add_dev_memory() api, for now there is no functional change to the
> memory hotplug code.
> 
> Cc: H. Peter Anvin <hpa@zytor.com>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: linux-mm@kvack.org
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  arch/x86/Kconfig       |   13 +++++++++++++
>  arch/x86/mm/init_64.c  |   32 +++++++++++++++++++++-----------
>  include/linux/mmzone.h |   23 +++++++++++++++++++++++
>  mm/memory_hotplug.c    |    5 ++++-
>  mm/page_alloc.c        |    3 +++
>  5 files changed, 64 insertions(+), 12 deletions(-)
> 
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index b3a1a5d77d92..64829b17980b 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -308,6 +308,19 @@ config ZONE_DMA
>  
>  	  If unsure, say Y.
>  
> +config ZONE_DEVICE
> +	bool "Device memory (pmem, etc...) hotplug support" if EXPERT
> +	default !ZONE_DMA
> +	depends on !ZONE_DMA
> +	help
> +	  Device memory hotplug support allows for establishing pmem,
> +	  or other device driver discovered memory regions, in the
> +	  memmap. This allows pfn_to_page() lookups of otherwise
> +	  "device-physical" addresses which is needed for using a DAX
> +	  mapping in an O_DIRECT operation, among other things.
> +
> +	  If FS_DAX is enabled, then say Y.
> +
>  config SMP
>  	bool "Symmetric multi-processing support"
>  	---help---
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index 3fba623e3ba5..94f0fa56f0ed 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -683,15 +683,8 @@ static void  update_end_of_memory_vars(u64 start, u64 size)
>  	}
>  }
>  
> -/*
> - * Memory is added always to NORMAL zone. This means you will never get
> - * additional DMA/DMA32 memory.
> - */
> -int arch_add_memory(int nid, u64 start, u64 size)
> +static int __arch_add_memory(int nid, u64 start, u64 size, struct zone *zone)
>  {
> -	struct pglist_data *pgdat = NODE_DATA(nid);
> -	struct zone *zone = pgdat->node_zones +
> -		zone_for_memory(nid, start, size, ZONE_NORMAL);
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
>  	int ret;
> @@ -701,11 +694,28 @@ int arch_add_memory(int nid, u64 start, u64 size)
>  	ret = __add_pages(nid, zone, start_pfn, nr_pages);
>  	WARN_ON_ONCE(ret);
>  
> -	/* update max_pfn, max_low_pfn and high_memory */
> -	update_end_of_memory_vars(start, size);
> +	/*
> +	 * Update max_pfn, max_low_pfn and high_memory, unless we added
> +	 * "device memory" which should not effect max_pfn
> +	 */
> +	if (!is_dev_zone(zone))
> +		update_end_of_memory_vars(start, size);

What is the rational for not updating max_pfn, max_low_pfn, ... ?

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
