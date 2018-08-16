Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1D76B6B0007
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 10:58:53 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r13-v6so2659282wmc.8
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 07:58:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q186-v6sor387627wmd.18.2018.08.16.07.58.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 Aug 2018 07:58:51 -0700 (PDT)
Date: Thu, 16 Aug 2018 16:58:49 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [RFC PATCH 2/3] mm/memory_hotplug: Create __shrink_pages and
 move it to offline_pages
Message-ID: <20180816145849.GA17638@techadventures.net>
References: <20180807133757.18352-3-osalvador@techadventures.net>
 <20180807135221.GA3301@redhat.com>
 <20180807145900.GH10003@dhcp22.suse.cz>
 <20180807151810.GB3301@redhat.com>
 <20180808064758.GB27972@dhcp22.suse.cz>
 <20180808165814.GB3429@redhat.com>
 <20180809082415.GB24884@dhcp22.suse.cz>
 <20180809142709.GA3386@redhat.com>
 <20180809150950.GB15611@dhcp22.suse.cz>
 <20180809165821.GC3386@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180809165821.GC3386@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, dan.j.williams@intel.com, Pavel.Tatashin@microsoft.com, david@redhat.com, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Thu, Aug 09, 2018 at 12:58:21PM -0400, Jerome Glisse wrote:
> I agree, i never thought about that before. Looking at existing resource
> management i think the simplest solution would be to use a refcount on the
> resources instead of the IORESOURCE_BUSY flags.
> 
> So when you release resource as part of hotremove you would only dec the
> refcount and a resource is not busy only when refcount is zero.
> 
> Just the idea i had in mind. Right now i am working on other thing, Oscar
> is this something you would like to work on ? Feel free to come up with
> something better than my first idea :)

So, I thought a bit about this.
First I talked a bit with Jerome about the refcount idea.
The problem with reconverting this to refcount is that it is too intrusive,
and I think it is not really needed.

I then thought about defining a new flag, something like

#define IORESOURCE_NO_HOTREMOVE	xxx

but we ran out of bits for the flag field.

I then thought about doing something like:

struct resource {
        resource_size_t start;
        resource_size_t end;
        const char *name;
        unsigned long flags;
        unsigned long desc;
        struct resource *parent, *sibling, *child;
#ifdef CONFIG_MEMORY_HOTREMOVE
        bool device_managed;
#endif
};

but it is just too awful, not needed, and bytes consuming.

The only idea I had left is:

register_memory_resource(), which defines a new resource for the added memory-chunk
is only called from add_memory().
This function is only being hit when we add memory-chunks.

HMM/devm gets the resources their own way, calling devm_request_mem_region().

So resources that are requested from HMM/devm, have the following flags:

 (IORESOURCE_MEM|IORESOURCE_BUSY)

while resources that are requested via mem-hotplug have:

 (IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY)

IORESOURCE_SYSTEM_RAM = (IORESOURCE_MEM|IORESOURCE_SYSRAM)


release_mem_region_adjustable() is only being called from hot-remove path, so
unless I am mistaken, all resources hitting that path should match IORESOURCE_SYSTEM_RAM.

That leaves me with the idea that we could check for the resource->flags to contain IORESOURCE_SYSRAM,
as I think it is only being set for memory-chunks that are added via memory-hot-add path.

In case it is not, we know that that resource belongs to HMM/devm, so we can back off since
they take care of releasing the resource via devm_release_mem_region.

I am working on a RFC v2 containing this, but, Jerome, could you confirm above assumption, please?

Of course, ideas/suggestions are also welcome.

Thanks
-- 
Oscar Salvador
SUSE L3
