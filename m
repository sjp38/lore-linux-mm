Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id A5BF56B0036
	for <linux-mm@kvack.org>; Tue, 19 Aug 2014 12:59:32 -0400 (EDT)
Received: by mail-ob0-f172.google.com with SMTP id wn1so5343048obc.17
        for <linux-mm@kvack.org>; Tue, 19 Aug 2014 09:59:32 -0700 (PDT)
Received: from g5t1626.atlanta.hp.com (g5t1626.atlanta.hp.com. [15.192.137.9])
        by mx.google.com with ESMTPS id q2si26888885obf.53.2014.08.19.09.59.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 19 Aug 2014 09:59:31 -0700 (PDT)
Message-ID: <1408466959.28990.23.camel@misato.fc.hp.com>
Subject: Re: [RFC 9/9] prd: Add support for page struct mapping
From: Toshi Kani <toshi.kani@hp.com>
Date: Tue, 19 Aug 2014 10:49:19 -0600
In-Reply-To: <53F30D71.9010107@plexistor.com>
References: <53EB5536.8020702@gmail.com> <53EB5960.50200@plexistor.com>
		 <1408134524.26567.38.camel@misato.fc.hp.com> <53F07342.30006@gmail.com>
	 <1408391280.26567.79.camel@misato.fc.hp.com>
	 <53F30D71.9010107@plexistor.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Boaz Harrosh <openosd@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, Yigal Korman <yigal@plexistor.com>

On Tue, 2014-08-19 at 11:40 +0300, Boaz Harrosh wrote:
> On 08/18/2014 10:48 PM, Toshi Kani wrote:
> > On Sun, 2014-08-17 at 12:17 +0300, Boaz Harrosh wrote:
> <>
> >> "System RAM" it is not. 
> > 
> > I think add_memory() can be easily extended (or modified to provide a
> > separate interface) for persistent memory, and avoid creating the sysfs
> > interface and change the handling with firmware_map.  But I can also see
> > your point that persistent memory should not be added to zone at all.
> > 
> 
> Right
> 
> > Anyway, I am a bit concerned with the way to create direct mappings with
> > map_vm_area() within the prd driver.  Can we use init_memory_mapping()
> > as it's used by add_memory() and supports large page size?  The size of
> > persistent memory will grow up quickly.
> 
> A bit about large page size. The principal reason of my effort here is
> that at some stage I need to send pmem blocks to block-layer or network.
> 
> The PAGE == 4K is pasted all over the block stack. Do you know how those
> can work together? will we need some kind of page_split thing how does
> that work?

I do not think there will be any problem. struct page's are still
allocated for each 4KB. When you change cache attribute with
set_memory_<type>(), it will split into 4K mappings if necessary.

> > Also, I'd prefer to have an mm
> > interface that takes care of page allocations and mappings, and avoid a
> > driver to deal with them.
> > 
> 
> This is a great idea you mean that I define:
> +	int mm_add_page_mapping(phys_addr_t phys_addr, size_t total_size,
> +				void **o_virt_addr)
> 
> At the mm level. OK It needs a much better name.
> 
> I know of 2 more drivers that will need the use of the same interface
> actually, so you are absolutely right. I didn't dare ask ;-)

I think the new interface should be analogous to add_memory(). Perhaps,
the name can be something like add_persistent_memory().

> >> And also I think that for DDR4 NvDIMMs we will fail with:
> >> 	ret = check_hotplug_memory_range(start, size);
> >>
> > 
> > Can you elaborate why DDR4 will fail with the function above?
> > 
> 
> I'm not at all familiar with the details, perhaps the Intel
> guys that knows better can chip in, but from the little I
> understood: Today with DDR3 these chips come up at the e820
> controller, as type 12 memory and, each vendor has a driver
> to drive proprietary enablement and persistence.
> With DDR4 it will all be standardized, but it will not come
> up through the e820 manager, but as a separate device on the
> SMBus/ACPI.
> So it is not clear to me that we want to plug this back into
> the ARCH's memory controllers. check_hotplug_memory_range is
> it per ARCH?

check_hotplug_memory_range() is a common function, but the section size
is defined per architecture. On x86, the size is 128MB. I do not think
the firmware interface is going to be a problem for this. Some NVDIMM
may allow a window size to be smaller than 128MB, but the driver can
manage to configure with a proper size. 

> I will produce a new Patchset that introduces a new API
> for drivers. And I will try to see about the use of
> init_memory_mapping(), as long as it is not using
> zones.
> 
> Do you think that the new code should sit in?
> 	mm/memory_hotplug.c
> 

Great.  Yes, I agree that the new code should sit in
mm/memory_hotplug.c.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
