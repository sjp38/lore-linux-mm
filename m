Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0AB686B000E
	for <linux-mm@kvack.org>; Tue, 22 May 2018 17:38:05 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id 8-v6so12862573oip.22
        for <linux-mm@kvack.org>; Tue, 22 May 2018 14:38:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d92-v6sor8422363otb.279.2018.05.22.14.38.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 22 May 2018 14:38:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <45b62e4b-ee9a-a2de-579f-24642bb1fbc7@deltatee.com>
References: <152694211402.5484.2277538346144115181.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152694213486.5484.5340142369038375338.stgit@dwillia2-desk3.amr.corp.intel.com>
 <45b62e4b-ee9a-a2de-579f-24642bb1fbc7@deltatee.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 22 May 2018 14:38:02 -0700
Message-ID: <CAPcyv4idV8JbwUQ8tkzFzMV-sfLY15zwE_Xp3F6C_+zajVbxng@mail.gmail.com>
Subject: Re: [PATCH 4/5] mm, hmm: replace hmm_devmem_pages_create() with devm_memremap_pages()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, May 22, 2018 at 10:13 AM, Logan Gunthorpe <logang@deltatee.com> wrote:
>
>
> On 21/05/18 04:35 PM, Dan Williams wrote:
>> +     /*
>> +      * For device private memory we call add_pages() as we only need to
>> +      * allocate and initialize struct page for the device memory. More-
>> +      * over the device memory is un-accessible thus we do not want to
>> +      * create a linear mapping for the memory like arch_add_memory()
>> +      * would do.
>> +      *
>> +      * For all other device memory types, which are accessible by
>> +      * the CPU, we do want the linear mapping and thus use
>> +      * arch_add_memory().
>> +      */
>> +     if (pgmap->type == MEMORY_DEVICE_PRIVATE) {
>> +             error = add_pages(nid, align_start >> PAGE_SHIFT,
>> +                             align_size >> PAGE_SHIFT, NULL, false);
>> +     } else {
>> +             struct zone *zone;
>> +
>> +             error = arch_add_memory(nid, align_start, align_size, altmap,
>> +                             false);
>> +             zone = &NODE_DATA(nid)->node_zones[ZONE_DEVICE];
>> +             if (!error)
>> +                     move_pfn_range_to_zone(zone, align_start >> PAGE_SHIFT,
>>                                       align_size >> PAGE_SHIFT, altmap);
>> +     }
>
> Maybe I missed it in the patch but, don't we need the same thing in
> devm_memremap_pages_release() such that it calls the correct remove
> function? Similar to the replaced hmm code:
>
>> -     mem_hotplug_begin();
>> -     if (resource->desc == IORES_DESC_DEVICE_PRIVATE_MEMORY)
>> -             __remove_pages(zone, start_pfn, npages, NULL);
>> -     else
>> -             arch_remove_memory(start_pfn << PAGE_SHIFT,
>> -                                npages << PAGE_SHIFT, NULL);
>> -     mem_hotplug_done();
>> -
>> -     hmm_devmem_radix_release(resource);
>
> Perhaps it should be a separate patch too as it would be easier to see
> outside the big removal of HMM code.
>

Yes, I'll split it out.
