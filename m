Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 56CAF6B0035
	for <linux-mm@kvack.org>; Fri, 22 Aug 2014 10:36:21 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y10so15881777pdj.0
        for <linux-mm@kvack.org>; Fri, 22 Aug 2014 07:36:20 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id i5si41148689pdh.56.2014.08.22.07.36.19
        for <linux-mm@kvack.org>;
        Fri, 22 Aug 2014 07:36:20 -0700 (PDT)
Message-ID: <53F75562.7040100@intel.com>
Date: Fri, 22 Aug 2014 07:36:18 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [RFC 9/9] prd: Add support for page struct mapping
References: <53EB5536.8020702@gmail.com> <53EB5960.50200@plexistor.com>
In-Reply-To: <53EB5960.50200@plexistor.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, Sagi Manole <sagi@plexistor.com>, Yigal Korman <yigal@plexistor.com>

On 08/13/2014 05:26 AM, Boaz Harrosh wrote:
> +#ifdef CONFIG_BLK_DEV_PMEM_USE_PAGES
> +static int prd_add_page_mapping(phys_addr_t phys_addr, size_t total_size,
> +				void **o_virt_addr)
> +{
> +	int nid = memory_add_physaddr_to_nid(phys_addr);
> +	unsigned long start_pfn = phys_addr >> PAGE_SHIFT;
> +	unsigned long nr_pages = total_size >> PAGE_SHIFT;
> +	unsigned int start_sec = pfn_to_section_nr(start_pfn);
> +	unsigned int end_sec = pfn_to_section_nr(start_pfn + nr_pages - 1);

Nit: any chance you'd change this to be an exclusive end?  In the mm
code, we usually do:

	unsigned int end_sec = pfn_to_section_nr(start_pfn + nr_pages);

so the for loops end up <end_sec instead of <=end_sec.

> +	unsigned long phys_start_pfn;
> +	struct page **page_array, **mapped_page_array;
> +	unsigned long i;
> +	struct vm_struct *vm_area;
> +	void *virt_addr;
> +	int ret = 0;

This is a philosophical thing, but I don't see *ANY* block-specific code
in here.  Seems like this belongs in mm/ to me.

Is there a reason you don't just do this at boot and have to use hotplug
at runtime for it?  What are the ratio of pmem to RAM?  Is it possible
to exhaust all of RAM with 'struct page's for pmem?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
