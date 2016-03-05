Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 955EC6B0005
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 21:23:32 -0500 (EST)
Received: by mail-qg0-f47.google.com with SMTP id w104so58496598qge.1
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 18:23:32 -0800 (PST)
Received: from mail-qg0-x241.google.com (mail-qg0-x241.google.com. [2607:f8b0:400d:c04::241])
        by mx.google.com with ESMTPS id d77si1487927qkb.20.2016.03.04.18.23.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Mar 2016 18:23:31 -0800 (PST)
Received: by mail-qg0-x241.google.com with SMTP id t4so4527634qge.1
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 18:23:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1457146138.15454.277.camel@hpe.com>
References: <20160303215304.1014.69931.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20160303215315.1014.95661.stgit@dwillia2-desk3.amr.corp.intel.com>
	<1457146138.15454.277.camel@hpe.com>
Date: Fri, 4 Mar 2016 18:23:31 -0800
Message-ID: <CAA9_cmc9vjChKqs7P1NG9r66TGapw0cYHfcajWh_O+hk433MTg@mail.gmail.com>
Subject: Re: [PATCH v2 2/3] libnvdimm, pmem: adjust for section collisions
 with 'System RAM'
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Mar 4, 2016 at 6:48 PM, Toshi Kani <toshi.kani@hpe.com> wrote:
> On Thu, 2016-03-03 at 13:53 -0800, Dan Williams wrote:
>> On a platform where 'Persistent Memory' and 'System RAM' are mixed
>> within a given sparsemem section, trim the namespace and notify about the
>> sub-optimal alignment.
>>
>> Cc: Toshi Kani <toshi.kani@hpe.com>
>> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>> ---
>>  drivers/nvdimm/namespace_devs.c |    7 ++
>>  drivers/nvdimm/pfn.h            |   10 ++-
>>  drivers/nvdimm/pfn_devs.c       |    5 ++
>>  drivers/nvdimm/pmem.c           |  125 ++++++++++++++++++++++++++++-----
>> ------
>>  4 files changed, 111 insertions(+), 36 deletions(-)
>>
>> diff --git a/drivers/nvdimm/namespace_devs.c
>> b/drivers/nvdimm/namespace_devs.c
>> index 8ebfcaae3f5a..463756ca2d4b 100644
>> --- a/drivers/nvdimm/namespace_devs.c
>> +++ b/drivers/nvdimm/namespace_devs.c
>> @@ -133,6 +133,7 @@ bool nd_is_uuid_unique(struct device *dev, u8 *uuid)
>>  bool pmem_should_map_pages(struct device *dev)
>>  {
>>       struct nd_region *nd_region = to_nd_region(dev->parent);
>> +     struct nd_namespace_io *nsio;
>>
>>       if (!IS_ENABLED(CONFIG_ZONE_DEVICE))
>>               return false;
>> @@ -143,6 +144,12 @@ bool pmem_should_map_pages(struct device *dev)
>>       if (is_nd_pfn(dev) || is_nd_btt(dev))
>>               return false;
>>
>> +     nsio = to_nd_namespace_io(dev);
>> +     if (region_intersects(nsio->res.start, resource_size(&nsio-
>> >res),
>> +                             IORESOURCE_SYSTEM_RAM,
>> +                             IORES_DESC_NONE) == REGION_MIXED)
>
> Should this be != REGION_DISJOINT for safe?

Acutally, it's ok.  It doesn't need to be disjoint.  The problem is
mixing an mm-zone within a given section.  If the region intersects
system-ram then devm_memremap_pages() is a no-op and we can use the
existing page allocation and linear mapping.

>
>> +             return false;
>> +
>
>  :
>
>> @@ -304,21 +311,56 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
>>       }
>>
>>       memset(pfn_sb, 0, sizeof(*pfn_sb));
>> -     npfns = (pmem->size - SZ_8K) / SZ_4K;
>> +
>> +     /*
>> +      * Check if pmem collides with 'System RAM' when section aligned
>> and
>> +      * trim it accordingly
>> +      */
>> +     nsio = to_nd_namespace_io(&ndns->dev);
>> +     start = PHYS_SECTION_ALIGN_DOWN(nsio->res.start);
>> +     size = resource_size(&nsio->res);
>> +     if (region_intersects(start, size, IORESOURCE_SYSTEM_RAM,
>> +                             IORES_DESC_NONE) == REGION_MIXED) {
>> +
>> +             start = nsio->res.start;
>> +             start_pad = PHYS_SECTION_ALIGN_UP(start) - start;
>> +     }
>> +
>> +     start = nsio->res.start;
>> +     size = PHYS_SECTION_ALIGN_UP(start + size) - start;
>> +     if (region_intersects(start, size, IORESOURCE_SYSTEM_RAM,
>> +                             IORES_DESC_NONE) == REGION_MIXED) {
>> +             size = resource_size(&nsio->res);
>> +             end_trunc = start + size - PHYS_SECTION_ALIGN_DOWN(start
>> + size);
>> +     }
>
> This check seems to assume that guest's regular memory layout does not
> change.  That is, if there is no collision at first, there won't be any
> later.  Is this a valid assumption?

If platform firmware changes the physical alignment during the
lifetime of the namespace there's not much we can do.  Another problem
not addressed by this patch is firmware choosing to hot plug system
ram into the same section as persistent memory.  As far as I can see
all we do is ask firmware implementations to respect Linux section
boundaries and otherwise not change alignments.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
