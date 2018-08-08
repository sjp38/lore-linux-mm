Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 333DB6B0003
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 05:45:05 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id w2-v6so1351295wrt.13
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 02:45:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u8-v6sor1516954wrq.10.2018.08.08.02.45.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Aug 2018 02:45:03 -0700 (PDT)
Date: Wed, 8 Aug 2018 11:45:02 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [RFC PATCH 2/3] mm/memory_hotplug: Create __shrink_pages and
 move it to offline_pages
Message-ID: <20180808094502.GA10068@techadventures.net>
References: <20180807133757.18352-1-osalvador@techadventures.net>
 <20180807133757.18352-3-osalvador@techadventures.net>
 <20180807135221.GA3301@redhat.com>
 <20180807145900.GH10003@dhcp22.suse.cz>
 <20180807151810.GB3301@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180807151810.GB3301@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, dan.j.williams@intel.com, david@redhat.com, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Tue, Aug 07, 2018 at 11:18:10AM -0400, Jerome Glisse wrote:
> Correct, you should not call release_mem_region_adjustable() the device
> region is not part of regular iomem resource as it might not necessarily
> be enumerated through known ways to the kernel (ie only the device driver
> can discover the region and core kernel do not know about it).
> 
> One of the issue to adding this region to iomem resource is that they
> really need to be ignored by core kernel because you can not assume that
> CPU can actually access them. Moreover, if CPU can access them it is
> likely that CPU can not do atomic operation on them (ie what happens on
> a CPU atomic instruction is undefined). So they are _special_ and only
> make sense to be use in conjunction with a device driver.
> 
> 
> Also in the case they do exist in iomem resource it is as PCIE BAR so
> as IORESOURCE_IO (iirc) and thus release_mem_region_adjustable() would
> return -EINVAL. Thought nothing bad happens because of that, only a
> warning message that might confuse the user.

Just to see if I understand this correctly.
I guess that these regions are being registered via devm_request_mem_region() calls.
Among other callers, devm_request_mem_region() is being called from:

dax_pmem_probe
hmm_devmem_add

AFAICS from the code, those regions will inherit the flags from the parent, which is iomem_resource:

#define devm_request_mem_region(dev,start,n,name) \
	__devm_request_region(dev, &iomem_resource, (start), (n), (name))

struct resource iomem_resource = {
	.name	= "PCI mem",
	.start	= 0,
	.end	= -1,
	.flags	= IORESOURCE_MEM,
};


struct resource * __request_region()
{
	...
	...
	res->flags = resource_type(parent) | resource_ext_type(parent);
	res->flags |= IORESOURCE_BUSY | flags;
	res->desc = parent->desc;
	...
	...
}

So the regions will not be tagged as IORESOURCE_IO but IORESOURCE_MEM.
>From the first glance release_mem_region_adjustable() looks like it does
more things than __release_region(), and I did not check it deeply
but maybe we can make it work.

Thanks
-- 
Oscar Salvador
SUSE L3
