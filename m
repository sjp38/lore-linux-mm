Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 75B474402FE
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 17:21:51 -0400 (EDT)
Received: by ioii196 with SMTP id i196so133540789ioi.3
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 14:21:51 -0700 (PDT)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id e14si10192906ioi.65.2015.10.02.14.21.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Oct 2015 14:21:50 -0700 (PDT)
Date: Fri, 2 Oct 2015 15:21:37 -0600
From: Logan Gunthorpe <logang@deltatee.com>
Subject: Re: [PATCH 14/15] mm, dax, pmem: introduce {get|put}_dev_pagemap()
 for dax-gup
Message-ID: <20151002212137.GB30448@deltatee.com>
References: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
 <20150923044227.36490.99741.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150923044227.36490.99741.stgit@dwillia2-desk3.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Dave Hansen <dave@sr71.net>, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Stephen Bates <Stephen.Bates@pmcs.com>

Hi Dan,

We've been doing some experimenting and testing with this patchset.
Specifically, we are trying to use you're ZONE_DEVICE work to enable
peer to peer PCIe transfers. This is actually working pretty well
(though we're still testing and working through some things).

However, we've found a couple of issues:

On Wed, Sep 23, 2015 at 12:42:27AM -0400, Dan Williams wrote:
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 3d6baa7d4534..20097e7b679a 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -49,12 +49,16 @@ struct page {
>  					 * updated asynchronously */
>  	union {
>  		struct address_space *mapping;	/* If low bit clear, points to
> -						 * inode address_space, or NULL.
> +						 * inode address_space, unless
> +						 * the page is in ZONE_DEVICE
> +						 * then it points to its parent
> +						 * dev_pagemap, otherwise NULL.
>  						 * If page mapped as anonymous
>  						 * memory, low bit is set, and
>  						 * it points to anon_vma object:
>  						 * see PAGE_MAPPING_ANON below.
>  						 */
> +		struct dev_pagemap *pgmap;
>  		void *s_mem;			/* slab first object */
>  	};


When you add to this union and overide the mapping value, we see bugs
in calls to set_page_dirty when it tries to dereference mapping. I believe
a change to page_mapping is required such as the patch that's at the end of
this email.


> diff --git a/mm/gup.c b/mm/gup.c
> index a798293fc648..1064e9a489a4 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -98,7 +98,16 @@ retry:
>  	}
>
>  	page = vm_normal_page(vma, address, pte);
> -	if (unlikely(!page)) {
> +	if (!page && pte_devmap(pte) && (flags & FOLL_GET)) {
> +		/*
> +		 * Only return device mapping pages in the FOLL_GET case since
> +		 * they are only valid while holding the pgmap reference.
> +		 */
> +		if (get_dev_pagemap(pte_pfn(pte), NULL))
> +			page = pte_page(pte);
> +		else
> +			goto no_page;
> +	} else if (unlikely(!page)) {

I've found that if a driver creates a ZONE_DEVICE mapping but doesn't
create the pagemap (using devm_register_pagemap) then the get_user_pages code
will go into an infinite loop. I'm not really sure if this as an issue or
not but it seems a bit undesirable for a buggy driver to be able to cause this.

My thoughts are that either devm_register_pagemap needs to be done by
devm_memremap_pages so a driver cannot use one without the other,
or the GUP code needs to return EFAULT if no pagemap was registered so
it doesn't loop forever.

Thanks!

Logan



diff --git a/mm/util.c b/mm/util.c
index 68ff8a5..19af683 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -368,6 +368,9 @@ struct address_space *page_mapping(struct page *page)
 		return swap_address_space(entry);
 	}

+	if (unlikely(is_zone_device_page(page)))
+		return NULL;
+
 	mapping = (unsigned long)page->mapping;
 	if (mapping & PAGE_MAPPING_FLAGS)
 		return NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
