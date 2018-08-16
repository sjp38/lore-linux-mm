Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 52C136B02AA
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 13:32:07 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id d194-v6so5109293qkb.12
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 10:32:07 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id t6-v6si3125484qvi.49.2018.08.16.10.32.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Aug 2018 10:32:06 -0700 (PDT)
Date: Thu, 16 Aug 2018 13:32:01 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 2/3] mm/memory_hotplug: Create __shrink_pages and
 move it to offline_pages
Message-ID: <20180816173201.GC28097@redhat.com>
References: <20180807135221.GA3301@redhat.com>
 <20180807145900.GH10003@dhcp22.suse.cz>
 <20180807151810.GB3301@redhat.com>
 <20180808064758.GB27972@dhcp22.suse.cz>
 <20180808165814.GB3429@redhat.com>
 <20180809082415.GB24884@dhcp22.suse.cz>
 <20180809142709.GA3386@redhat.com>
 <20180809150950.GB15611@dhcp22.suse.cz>
 <20180809165821.GC3386@redhat.com>
 <20180816145849.GA17638@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180816145849.GA17638@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, dan.j.williams@intel.com, Pavel.Tatashin@microsoft.com, david@redhat.com, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Thu, Aug 16, 2018 at 04:58:49PM +0200, Oscar Salvador wrote:
> On Thu, Aug 09, 2018 at 12:58:21PM -0400, Jerome Glisse wrote:
> > I agree, i never thought about that before. Looking at existing resource
> > management i think the simplest solution would be to use a refcount on the
> > resources instead of the IORESOURCE_BUSY flags.
> > 
> > So when you release resource as part of hotremove you would only dec the
> > refcount and a resource is not busy only when refcount is zero.
> > 
> > Just the idea i had in mind. Right now i am working on other thing, Oscar
> > is this something you would like to work on ? Feel free to come up with
> > something better than my first idea :)
> 
> So, I thought a bit about this.
> First I talked a bit with Jerome about the refcount idea.
> The problem with reconverting this to refcount is that it is too intrusive,
> and I think it is not really needed.
> 
> I then thought about defining a new flag, something like
> 
> #define IORESOURCE_NO_HOTREMOVE	xxx
> 
> but we ran out of bits for the flag field.
> 
> I then thought about doing something like:
> 
> struct resource {
>         resource_size_t start;
>         resource_size_t end;
>         const char *name;
>         unsigned long flags;
>         unsigned long desc;
>         struct resource *parent, *sibling, *child;
> #ifdef CONFIG_MEMORY_HOTREMOVE
>         bool device_managed;
> #endif
> };
> 
> but it is just too awful, not needed, and bytes consuming.

Agree the above is ugly.

> 
> The only idea I had left is:
> 
> register_memory_resource(), which defines a new resource for the added memory-chunk
> is only called from add_memory().
> This function is only being hit when we add memory-chunks.
> 
> HMM/devm gets the resources their own way, calling devm_request_mem_region().
> 
> So resources that are requested from HMM/devm, have the following flags:
> 
>  (IORESOURCE_MEM|IORESOURCE_BUSY)
> 
> while resources that are requested via mem-hotplug have:
> 
>  (IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY)
> 
> IORESOURCE_SYSTEM_RAM = (IORESOURCE_MEM|IORESOURCE_SYSRAM)
> 
> 
> release_mem_region_adjustable() is only being called from hot-remove path, so
> unless I am mistaken, all resources hitting that path should match IORESOURCE_SYSTEM_RAM.
> 
> That leaves me with the idea that we could check for the resource->flags to contain IORESOURCE_SYSRAM,
> as I think it is only being set for memory-chunks that are added via memory-hot-add path.
> 
> In case it is not, we know that that resource belongs to HMM/devm, so we can back off since
> they take care of releasing the resource via devm_release_mem_region.
> 
> I am working on a RFC v2 containing this, but, Jerome, could you confirm above assumption, please?

I think you nail it. I am not 100% sure about devm as i have not
followed closely how persistent memory can be reported by ACPI. But
i am pretty sure it should never end up as SYSRAM.

Thank you for scratching your head on this :)

Cheers,
Jerome
