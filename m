Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id A97726B2ABB
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 08:30:16 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id e68so13576659plb.3
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 05:30:16 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s24si17731630plq.41.2018.11.22.05.30.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 05:30:15 -0800 (PST)
Date: Thu, 22 Nov 2018 14:30:13 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v8 1/7] mm, devm_memremap_pages: Mark
 devm_memremap_pages() EXPORT_SYMBOL_GPL
Message-ID: <20181122133013.GG18011@dhcp22.suse.cz>
References: <154275556908.76910.8966087090637564219.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154275557457.76910.16923571232582744134.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <154275557457.76910.16923571232582744134.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@lst.de>, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org

On Tue 20-11-18 15:12:54, Dan Williams wrote:
> devm_memremap_pages() is a facility that can create struct page entries
> for any arbitrary range and give drivers the ability to subvert core
> aspects of page management.
> 
> Specifically the facility is tightly integrated with the kernel's memory
> hotplug functionality. It injects an altmap argument deep into the
> architecture specific vmemmap implementation to allow allocating from
> specific reserved pages, and it has Linux specific assumptions about
> page structure reference counting relative to get_user_pages() and
> get_user_pages_fast(). It was an oversight and a mistake that this was
> not marked EXPORT_SYMBOL_GPL from the outset.
> 
> Again, devm_memremap_pagex() exposes and relies upon core kernel
> internal assumptions and will continue to evolve along with 'struct
> page', memory hotplug, and support for new memory types / topologies.
> Only an in-kernel GPL-only driver is expected to keep up with this
> ongoing evolution. This interface, and functionality derived from this
> interface, is not suitable for kernel-external drivers.

As I've said earlier I do not buy this justification because there is
simply no stable API for modules by definition
(Documentation/process/stable-api-nonsense.rst). I do understand
your reasoning that you as an author never intended to export the symbol
this way. That is fair and justified reason for this patch.

Whoever needs a wrapper around arch_add_memory can do so because this
symbol has no restriction for the usage. It will be still the same
fiddling with struct page and deep mm internals. Do we care? I am not
convinced because once we grow any in tree user we have to cope with any
potential abuse like we have in other areas in the past. And out-of-tree
modules? Who cares. Those are on their own completely and have their
ways to go around.

> Cc: Michal Hocko <mhocko@suse.com>
> Cc: "J�r�me Glisse" <jglisse@redhat.com>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

That being said
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  kernel/memremap.c                 |    2 +-
>  tools/testing/nvdimm/test/iomap.c |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index 9eced2cc9f94..61dbcaa95530 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -233,7 +233,7 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>   err_array:
>  	return ERR_PTR(error);
>  }
> -EXPORT_SYMBOL(devm_memremap_pages);
> +EXPORT_SYMBOL_GPL(devm_memremap_pages);
>  
>  unsigned long vmem_altmap_offset(struct vmem_altmap *altmap)
>  {
> diff --git a/tools/testing/nvdimm/test/iomap.c b/tools/testing/nvdimm/test/iomap.c
> index ff9d3a5825e1..ed18a0cbc0c8 100644
> --- a/tools/testing/nvdimm/test/iomap.c
> +++ b/tools/testing/nvdimm/test/iomap.c
> @@ -113,7 +113,7 @@ void *__wrap_devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>  		return nfit_res->buf + offset - nfit_res->res.start;
>  	return devm_memremap_pages(dev, pgmap);
>  }
> -EXPORT_SYMBOL(__wrap_devm_memremap_pages);
> +EXPORT_SYMBOL_GPL(__wrap_devm_memremap_pages);
>  
>  pfn_t __wrap_phys_to_pfn_t(phys_addr_t addr, unsigned long flags)
>  {

-- 
Michal Hocko
SUSE Labs
