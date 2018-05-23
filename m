Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7526A6B0286
	for <linux-mm@kvack.org>; Wed, 23 May 2018 11:55:15 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id t1-v6so17307883oth.3
        for <linux-mm@kvack.org>; Wed, 23 May 2018 08:55:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 20-v6sor10041125otf.60.2018.05.23.08.55.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 May 2018 08:55:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <8f0cae82-130f-8a64-cfbd-fda5fd76bb79@deltatee.com>
References: <152705221686.21414.771870778478134768.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152705223396.21414.13388289577013917472.stgit@dwillia2-desk3.amr.corp.intel.com>
 <8f0cae82-130f-8a64-cfbd-fda5fd76bb79@deltatee.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 23 May 2018 08:55:13 -0700
Message-ID: <CAPcyv4jBq9BDXcidvR10YO_pb0uQNVK_qPZ=x=k9kDRtaB2few@mail.gmail.com>
Subject: Re: [PATCH v2 3/7] mm, devm_memremap_pages: Fix shutdown handling
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable <stable@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, May 23, 2018 at 8:47 AM, Logan Gunthorpe <logang@deltatee.com> wrote:
>
>
> On 22/05/18 11:10 PM, Dan Williams wrote:
>> diff --git a/include/linux/memremap.h b/include/linux/memremap.h
>> index 7b4899c06f49..b5e894133cf6 100644
>> --- a/include/linux/memremap.h
>> +++ b/include/linux/memremap.h
>> @@ -106,6 +106,7 @@ typedef void (*dev_page_free_t)(struct page *page, void *data);
>>   * @altmap: pre-allocated/reserved memory for vmemmap allocations
>>   * @res: physical address range covered by @ref
>>   * @ref: reference count that pins the devm_memremap_pages() mapping
>> + * @kill: callback to transition @ref to the dead state
>>   * @dev: host device of the mapping for debug
>>   * @data: private data pointer for page_free()
>>   * @type: memory type: see MEMORY_* in memory_hotplug.h
>> @@ -117,13 +118,15 @@ struct dev_pagemap {
>>       bool altmap_valid;
>>       struct resource res;
>>       struct percpu_ref *ref;
>> +     void (*kill)(struct percpu_ref *ref);
>>       struct device *dev;
>>       void *data;
>>       enum memory_type type;
>>  };
>>
>>  #ifdef CONFIG_ZONE_DEVICE
>> -void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap);
>> +void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap,
>> +             void (*kill)(struct percpu_ref *));
>
>
> It seems redundant to me to have the kill pointer both passed in as an
> argument and passed in as part of pgmap... Why not just expect the user
> to set it in the *pgmap that's passed in just like we expect ref to be
> set ahead of time?

I did this for grep-ability. Now you can grep for all
devm_memremap_pages and see the associated teardown actions,
everything else in pgmap is data. I'm not opposed to just requiring it
to be passed in with the pgmap, but I thought removing a step for
someone trying to grep through the code flow was worth it. Yes, not
the strongest argument, so if folks feel it adds too much clutter we
can switch it.

> Another thought (that may be too forward looking) is to pass the
> dev_pagemap struct to the kill function instead of the reference. That
> way, if some future user wants to do something extra on kill they can
> use container_of() to get extra context to work with.

We can cross that bridge if it comes to it, but as it stands being
able to get the container of the reference count seems to be enough
for all users.
