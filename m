Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id 9B49182F65
	for <linux-mm@kvack.org>; Sun, 27 Dec 2015 14:02:45 -0500 (EST)
Received: by mail-yk0-f170.google.com with SMTP id a85so11440893ykb.1
        for <linux-mm@kvack.org>; Sun, 27 Dec 2015 11:02:45 -0800 (PST)
Received: from mail-yk0-x231.google.com (mail-yk0-x231.google.com. [2607:f8b0:4002:c07::231])
        by mx.google.com with ESMTPS id l190si29278525ywf.319.2015.12.27.11.02.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Dec 2015 11:02:44 -0800 (PST)
Received: by mail-yk0-x231.google.com with SMTP id k129so66081320yke.0
        for <linux-mm@kvack.org>; Sun, 27 Dec 2015 11:02:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAA_GA1cYJhpqJkceYzJBpUj9Uvr68zGZzmphopu+7U+dEqCN3w@mail.gmail.com>
References: <20151221054406.34542.64393.stgit@dwillia2-desk3.jf.intel.com>
	<20151221054521.34542.62283.stgit@dwillia2-desk3.jf.intel.com>
	<CAA_GA1cYJhpqJkceYzJBpUj9Uvr68zGZzmphopu+7U+dEqCN3w@mail.gmail.com>
Date: Sun, 27 Dec 2015 11:02:44 -0800
Message-ID: <CAPcyv4jvE3bB=oqjFRquHWV8f_o2XOX1oB9h_xMzA82sYVMOVQ@mail.gmail.com>
Subject: Re: [-mm PATCH v4 14/18] mm, dax, pmem: introduce {get|put}_dev_pagemap()
 for dax-gup
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@sr71.net>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux-MM <linux-mm@kvack.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Logan Gunthorpe <logang@deltatee.com>

On Sun, Dec 27, 2015 at 12:46 AM, Bob Liu <lliubbo@gmail.com> wrote:
> On Mon, Dec 21, 2015 at 1:45 PM, Dan Williams <dan.j.williams@intel.com> wrote:
>> get_dev_page() enables paths like get_user_pages() to pin a dynamically
>> mapped pfn-range (devm_memremap_pages()) while the resulting struct page
>> objects are in use.  Unlike get_page() it may fail if the device is, or
>> is in the process of being, disabled.  While the initial lookup of the
>> range may be an expensive list walk, the result is cached to speed up
>> subsequent lookups which are likely to be in the same mapped range.
>>
>> devm_memremap_pages() now requires a reference counter to be specified
>> at init time.  For pmem this means moving request_queue allocation into
>> pmem_alloc() so the existing queue usage counter can track "device
>> pages".
>>
>> ZONE_DEVICE pages always have an elevated count and will never be on an
>> lru reclaim list.  That space in 'struct page' can be redirected for
>> other uses, but for safety introduce a poison value that will always
>> trip __list_add() to assert.  This allows half of the struct list_head
>> storage to be reclaimed with some assurance to back up the assumption
>> that the page count never goes to zero and a list_add() is never
>> attempted.
>>
>> Cc: Dave Hansen <dave@sr71.net>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Matthew Wilcox <willy@linux.intel.com>
>> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
>> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
>> Tested-by: Logan Gunthorpe <logang@deltatee.com>
>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>> ---
[..]
>> +static inline struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
>> +               struct dev_pagemap *pgmap)
>> +{
>> +       const struct resource *res = pgmap ? pgmap->res : NULL;
>> +       resource_size_t phys = PFN_PHYS(pfn);
>> +
>> +       /*
>> +        * In the cached case we're already holding a live reference so
>> +        * we can simply do a blind increment
>> +        */
>> +       if (res && phys >= res->start && phys <= res->end) {
>> +               percpu_ref_get(pgmap->ref);
>> +               return pgmap;
>> +       }
>> +
>> +       /* fall back to slow path lookup */
>> +       rcu_read_lock();
>> +       pgmap = find_dev_pagemap(phys);
>
> Is it possible just use pfn_to_page() and then return page->pgmap?
> Then we can get rid of the pgmap_radix tree totally.

No, for two reasons:

1/ find_dev_pagemap() is used in places where pfn_to_page() is not yet
established (see: to_vmem_altmap())

2/ at shutdown, new get_dev_pagemap() requests can race the memmap
being torn down.  So, unless we already have a reference against the
page_map, we always need to look it up under a lock to know that
pfn_to_page() is returning a valid page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
