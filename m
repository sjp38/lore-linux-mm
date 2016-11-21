Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 23F72280260
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 07:34:58 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id j65so36669247iof.1
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 04:34:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v83si13793516iod.8.2016.11.21.04.34.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Nov 2016 04:34:57 -0800 (PST)
Date: Mon, 21 Nov 2016 07:34:52 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM v13 04/18] mm/ZONE_DEVICE/free-page: callback when page is
 freed
Message-ID: <20161121123451.GD2392@redhat.com>
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-5-git-send-email-jglisse@redhat.com>
 <5832AF9A.8020808@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5832AF9A.8020808@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Mon, Nov 21, 2016 at 01:56:02PM +0530, Anshuman Khandual wrote:
> On 11/18/2016 11:48 PM, Jerome Glisse wrote:
> > When a ZONE_DEVICE page refcount reach 1 it means it is free and nobody
> > is holding a reference on it (only device to which the memory belong do).
> > Add a callback and call it when that happen so device driver can implement
> > their own free page management.
> > 
> > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> > Cc: Dan Williams <dan.j.williams@intel.com>
> > Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> > ---
> >  include/linux/memremap.h | 4 ++++
> >  kernel/memremap.c        | 8 ++++++++
> >  2 files changed, 12 insertions(+)
> > 
> > diff --git a/include/linux/memremap.h b/include/linux/memremap.h
> > index fe61dca..469c88d 100644
> > --- a/include/linux/memremap.h
> > +++ b/include/linux/memremap.h
> > @@ -37,17 +37,21 @@ static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
> >  
> >  /**
> >   * struct dev_pagemap - metadata for ZONE_DEVICE mappings
> > + * @free_devpage: free page callback when page refcount reach 1
> >   * @altmap: pre-allocated/reserved memory for vmemmap allocations
> >   * @res: physical address range covered by @ref
> >   * @ref: reference count that pins the devm_memremap_pages() mapping
> >   * @dev: host device of the mapping for debug
> > + * @data: privata data pointer for free_devpage
> >   * @flags: memory flags (look for MEMORY_FLAGS_NONE in memory_hotplug.h)
> >   */
> >  struct dev_pagemap {
> > +	void (*free_devpage)(struct page *page, void *data);
> >  	struct vmem_altmap *altmap;
> >  	const struct resource *res;
> >  	struct percpu_ref *ref;
> >  	struct device *dev;
> > +	void *data;
> >  	int flags;
> >  };
> >  
> > diff --git a/kernel/memremap.c b/kernel/memremap.c
> > index 438a73aa2..3d28048 100644
> > --- a/kernel/memremap.c
> > +++ b/kernel/memremap.c
> > @@ -190,6 +190,12 @@ EXPORT_SYMBOL(get_zone_device_page);
> >  
> >  void put_zone_device_page(struct page *page)
> >  {
> > +	/*
> > +	 * If refcount is 1 then page is freed and refcount is stable as nobody
> > +	 * holds a reference on the page.
> > +	 */
> > +	if (page->pgmap->free_devpage && page_count(page) == 1)
> > +		page->pgmap->free_devpage(page, page->pgmap->data);
> >  	put_dev_pagemap(page->pgmap);
> >  }
> >  EXPORT_SYMBOL(put_zone_device_page);
> > @@ -326,6 +332,8 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
> >  	pgmap->ref = ref;
> >  	pgmap->res = &page_map->res;
> >  	pgmap->flags = flags | MEMORY_DEVICE;
> > +	pgmap->free_devpage = NULL;
> > +	pgmap->data = NULL;
> 
> When is the driver expected to load up pgmap->free_devpage ? I thought
> this function is one of the right places. Though as all the pages in
> the same hotplug operation point to the same dev_pagemap structure this
> loading can be done at later point of time as well.
> 

I wanted to avoid adding more argument to devm_memremap_pages() as it already
has a long list. Hence why i let the caller set those afterward.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
