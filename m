Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C9F296B026A
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 04:17:56 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b34-v6so16081206ede.5
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 01:17:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s23-v6si339667edd.31.2018.10.17.01.17.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 01:17:55 -0700 (PDT)
Date: Wed, 17 Oct 2018 10:17:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v7 1/7] mm, devm_memremap_pages: Mark
 devm_memremap_pages() EXPORT_SYMBOL_GPL
Message-ID: <20181017081753.GG18839@dhcp22.suse.cz>
References: <153936657159.1198040.4489957977352276272.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153936657702.1198040.119388737535638846.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <153936657702.1198040.119388737535638846.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 12-10-18 10:49:37, Dan Williams wrote:
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

One thing is still not clear to me. Both devm_memremap_* and
hmm_devmem_add essentially do the same thing AFAICS. They both allow to
hotplug a device memory. Both rely on the hotplug code (namely
add_pages) which itself is not exported to modules. One is GPL only
while the later is a general export. Is this mismatch desirable?

API exported by the core hotplug is ad-hoc to say the least. Symbols
that we actually export are GPL mostly (only try_offline_node is
EXPORT_SYMBOL without any explanation whatsoever). So I would call it a
general mess tweaked for specific usecases.

I personally do not care about EXPORT_SYMBOL vs. EXPORT_SYMBOL_GPL
much to be honest. I understand an argument that we do not care about
out-of-tree modules a wee bit. I would just be worried those will find a
way around and my experience tells me that it would be much uglier than
what the core kernel can provide. But this seems more political than
technical discussion.
 
> Again, devm_memremap_pagex() exposes and relies upon core kernel
> internal assumptions and will continue to evolve along with 'struct
> page', memory hotplug, and support for new memory types / topologies.
> Only an in-kernel GPL-only driver is expected to keep up with this
> ongoing evolution. This interface, and functionality derived from this
> interface, is not suitable for kernel-external drivers.

I do not follow this line of argumentation though. We generally do not
care about out-of-tree modules and breaking them if the interface has to
be updated. Also what about GPL out of tree modules?

That being said, I do not mind this patch. You and Christoph are the
authors and therefore it is you to decide. I just find the current
situation confusing to say the least.

> Cc: Michal Hocko <mhocko@suse.com>
> Cc: "Jerome Glisse" <jglisse@redhat.com>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  kernel/memremap.c                 |    2 +-
>  tools/testing/nvdimm/test/iomap.c |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index 6ec81e0d7a33..1bbb2e892941 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -232,7 +232,7 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
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
> 

-- 
Michal Hocko
SUSE Labs
