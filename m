Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id E13CD4402FE
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 17:53:25 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so50651323wic.0
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 14:53:25 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com. [209.85.212.179])
        by mx.google.com with ESMTPS id bk3si1144704wib.79.2015.10.02.14.53.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Oct 2015 14:53:24 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so51063671wic.0
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 14:53:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151002212137.GB30448@deltatee.com>
References: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
	<20150923044227.36490.99741.stgit@dwillia2-desk3.jf.intel.com>
	<20151002212137.GB30448@deltatee.com>
Date: Fri, 2 Oct 2015 14:53:24 -0700
Message-ID: <CAPcyv4iwJJX-rSgC0ramLrvccdzDXgnUAUMQbTMpoODo2f7kOw@mail.gmail.com>
Subject: Re: [PATCH 14/15] mm, dax, pmem: introduce {get|put}_dev_pagemap()
 for dax-gup
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@sr71.net>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Stephen Bates <Stephen.Bates@pmcs.com>

On Fri, Oct 2, 2015 at 2:21 PM, Logan Gunthorpe <logang@deltatee.com> wrote:
> Hi Dan,
>
> We've been doing some experimenting and testing with this patchset.
> Specifically, we are trying to use you're ZONE_DEVICE work to enable
> peer to peer PCIe transfers. This is actually working pretty well
> (though we're still testing and working through some things).

Hmm, I didn't have peer-to-peer PCI-E in mind for this mechanism, but
the test report is welcome nonetheless.  The definition of dma_addr_t
is the device view of host memory, not necessarily the device view of
a peer device's memory range, so I expect you'll run into issues with
IOMMUs and other parts of the kernel that assume this definition.

>
> However, we've found a couple of issues:
>
> On Wed, Sep 23, 2015 at 12:42:27AM -0400, Dan Williams wrote:
>> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
>> index 3d6baa7d4534..20097e7b679a 100644
>> --- a/include/linux/mm_types.h
>> +++ b/include/linux/mm_types.h
>> @@ -49,12 +49,16 @@ struct page {
>>                                        * updated asynchronously */
>>       union {
>>               struct address_space *mapping;  /* If low bit clear, points to
>> -                                              * inode address_space, or NULL.
>> +                                              * inode address_space, unless
>> +                                              * the page is in ZONE_DEVICE
>> +                                              * then it points to its parent
>> +                                              * dev_pagemap, otherwise NULL.
>>                                                * If page mapped as anonymous
>>                                                * memory, low bit is set, and
>>                                                * it points to anon_vma object:
>>                                                * see PAGE_MAPPING_ANON below.
>>                                                */
>> +             struct dev_pagemap *pgmap;
>>               void *s_mem;                    /* slab first object */
>>       };
>
>
> When you add to this union and overide the mapping value, we see bugs
> in calls to set_page_dirty when it tries to dereference mapping. I believe
> a change to page_mapping is required such as the patch that's at the end of
> this email.

Yes, this location for dev_pagemap will not work.  I've since moved it
to a union with the lru list_head since ZONE_DEVICE pages memory
should always have an elevated page count and never land on a slab
allocator lru.

>> diff --git a/mm/gup.c b/mm/gup.c
>> index a798293fc648..1064e9a489a4 100644
>> --- a/mm/gup.c
>> +++ b/mm/gup.c
>> @@ -98,7 +98,16 @@ retry:
>>       }
>>
>>       page = vm_normal_page(vma, address, pte);
>> -     if (unlikely(!page)) {
>> +     if (!page && pte_devmap(pte) && (flags & FOLL_GET)) {
>> +             /*
>> +              * Only return device mapping pages in the FOLL_GET case since
>> +              * they are only valid while holding the pgmap reference.
>> +              */
>> +             if (get_dev_pagemap(pte_pfn(pte), NULL))
>> +                     page = pte_page(pte);
>> +             else
>> +                     goto no_page;
>> +     } else if (unlikely(!page)) {
>
> I've found that if a driver creates a ZONE_DEVICE mapping but doesn't
> create the pagemap (using devm_register_pagemap) then the get_user_pages code
> will go into an infinite loop. I'm not really sure if this as an issue or
> not but it seems a bit undesirable for a buggy driver to be able to cause this.
>
> My thoughts are that either devm_register_pagemap needs to be done by
> devm_memremap_pages so a driver cannot use one without the other,
> or the GUP code needs to return EFAULT if no pagemap was registered so
> it doesn't loop forever.

Exactly, we should fail (-EFAULT)  get_user_pages() in that case since
we don't have a mechanism to pin down the mapping.  I'll track down
what's causing the loop.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
