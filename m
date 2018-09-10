Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7EE8E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 10:00:02 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c25-v6so7033576edb.12
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 07:00:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q24-v6si1924437eda.181.2018.09.10.07.00.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 07:00:00 -0700 (PDT)
Date: Mon, 10 Sep 2018 15:59:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memory_hotplug: fix the panic when memory end is not on
 the section boundary
Message-ID: <20180910135959.GI10951@dhcp22.suse.cz>
References: <20180910123527.71209-1-zaslonko@linux.ibm.com>
 <20180910131754.GG10951@dhcp22.suse.cz>
 <e8d75768-9122-332b-3b16-cad032aeb27f@microsoft.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e8d75768-9122-332b-3b16-cad032aeb27f@microsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Cc: Mikhail Zaslonko <zaslonko@linux.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "osalvador@suse.de" <osalvador@suse.de>, "gerald.schaefer@de.ibm.com" <gerald.schaefer@de.ibm.com>

On Mon 10-09-18 13:46:45, Pavel Tatashin wrote:
> 
> 
> On 9/10/18 9:17 AM, Michal Hocko wrote:
> > [Cc Pavel]
> > 
> > On Mon 10-09-18 14:35:27, Mikhail Zaslonko wrote:
> >> If memory end is not aligned with the linux memory section boundary, such
> >> a section is only partly initialized. This may lead to VM_BUG_ON due to
> >> uninitialized struct pages access from is_mem_section_removable() or
> >> test_pages_in_a_zone() function.
> >>
> >> Here is one of the panic examples:
> >>  CONFIG_DEBUG_VM_PGFLAGS=y
> >>  kernel parameter mem=3075M
> > 
> > OK, so the last memory section is not full and we have a partial memory
> > block right?
> > 
> >>  page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
> > 
> > OK, this means that the struct page is not fully initialized. Do you
> > have a specific place which has triggered this assert?
> > 
> >>  ------------[ cut here ]------------
> >>  Call Trace:
> >>  ([<000000000039b8a4>] is_mem_section_removable+0xcc/0x1c0)
> >>   [<00000000009558ba>] show_mem_removable+0xda/0xe0
> >>   [<00000000009325fc>] dev_attr_show+0x3c/0x80
> >>   [<000000000047e7ea>] sysfs_kf_seq_show+0xda/0x160
> >>   [<00000000003fc4e0>] seq_read+0x208/0x4c8
> >>   [<00000000003cb80e>] __vfs_read+0x46/0x180
> >>   [<00000000003cb9ce>] vfs_read+0x86/0x148
> >>   [<00000000003cc06a>] ksys_read+0x62/0xc0
> >>   [<0000000000c001c0>] system_call+0xdc/0x2d8
> >>
> >> This fix checks if the page lies within the zone boundaries before
> >> accessing the struct page data. The check is added to both functions.
> >> Actually similar check has already been present in
> >> is_pageblock_removable_nolock() function but only after the struct page
> >> is accessed.
> >>
> > 
> > Well, I am afraid this is not the proper solution. We are relying on the
> > full pageblock worth of initialized struct pages at many other place. We
> > used to do that in the past because we have initialized the full
> > section but this has been changed recently. Pavel, do you have any ideas
> > how to deal with this partial mem sections now?
> 
> We have:
> 
> remove_memory()
> 	BUG_ON(check_hotplug_memory_range(start, size))
> 
> That supposed to safely check for this condition: if [start, start +
> size) not block size aligned (and we know block size is section
> aligned), hot remove is not allowed. The problem is this check is late,
> and only happens when invalid range has already passed through previous
> checks.
> 
> We could add check_hotplug_memory_range() to is_mem_section_removable():
> 
> is_mem_section_removable(start_pfn, nr_pages)
>  if (check_hotplug_memory_range(PFN_PHYS(start_pfn), PFN_PHYS(nr_pages)))
>   return false;
> 
> I think it should work.

I do not think we want to sprinkle these tests over all pfn walkers. Can
we simply initialize those uninitialized holes as well and make them
reserved without handing them over to the page allocator? That would be
much more robust approach IMHO.
-- 
Michal Hocko
SUSE Labs
