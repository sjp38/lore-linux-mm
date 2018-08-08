Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 28B256B0003
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 13:33:32 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id d18-v6so2322811qtj.20
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 10:33:32 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id l23-v6si795177qtc.78.2018.08.08.10.33.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Aug 2018 10:33:30 -0700 (PDT)
Date: Wed, 8 Aug 2018 13:33:28 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 2/3] mm/memory_hotplug: Create __shrink_pages and
 move it to offline_pages
Message-ID: <20180808173328.GC3429@redhat.com>
References: <20180807133757.18352-1-osalvador@techadventures.net>
 <20180807133757.18352-3-osalvador@techadventures.net>
 <20180807135221.GA3301@redhat.com>
 <20180807145900.GH10003@dhcp22.suse.cz>
 <20180807151810.GB3301@redhat.com>
 <20180808094502.GA10068@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180808094502.GA10068@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, dan.j.williams@intel.com, david@redhat.com, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Wed, Aug 08, 2018 at 11:45:02AM +0200, Oscar Salvador wrote:
> On Tue, Aug 07, 2018 at 11:18:10AM -0400, Jerome Glisse wrote:
> > Correct, you should not call release_mem_region_adjustable() the device
> > region is not part of regular iomem resource as it might not necessarily
> > be enumerated through known ways to the kernel (ie only the device driver
> > can discover the region and core kernel do not know about it).
> > 
> > One of the issue to adding this region to iomem resource is that they
> > really need to be ignored by core kernel because you can not assume that
> > CPU can actually access them. Moreover, if CPU can access them it is
> > likely that CPU can not do atomic operation on them (ie what happens on
> > a CPU atomic instruction is undefined). So they are _special_ and only
> > make sense to be use in conjunction with a device driver.
> > 
> > 
> > Also in the case they do exist in iomem resource it is as PCIE BAR so
> > as IORESOURCE_IO (iirc) and thus release_mem_region_adjustable() would
> > return -EINVAL. Thought nothing bad happens because of that, only a
> > warning message that might confuse the user.
> 
> Just to see if I understand this correctly.
> I guess that these regions are being registered via devm_request_mem_region() calls.
> Among other callers, devm_request_mem_region() is being called from:
> 
> dax_pmem_probe
> hmm_devmem_add
> 
> AFAICS from the code, those regions will inherit the flags from the parent, which is iomem_resource:
> 
> #define devm_request_mem_region(dev,start,n,name) \
> 	__devm_request_region(dev, &iomem_resource, (start), (n), (name))
> 
> struct resource iomem_resource = {
> 	.name	= "PCI mem",
> 	.start	= 0,
> 	.end	= -1,
> 	.flags	= IORESOURCE_MEM,
> };
> 
> 
> struct resource * __request_region()
> {
> 	...
> 	...
> 	res->flags = resource_type(parent) | resource_ext_type(parent);
> 	res->flags |= IORESOURCE_BUSY | flags;
> 	res->desc = parent->desc;
> 	...
> 	...
> }

Yeah you right my recollection of this was wrong.

> 
> So the regions will not be tagged as IORESOURCE_IO but IORESOURCE_MEM.
> From the first glance release_mem_region_adjustable() looks like it does
> more things than __release_region(), and I did not check it deeply
> but maybe we can make it work.

The root issue here is not releasing the resource when hotremoving
the memory. The device driver still wants to keep owning the resource
after hotremove of memory. The device driver do not necessarily always
need struct page to make use of that resource.


Cheers,
Jerome
