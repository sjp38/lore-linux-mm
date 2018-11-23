Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id F2C896B2FAE
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 07:42:31 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id v4so5570481edm.18
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 04:42:31 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k7si1559456edb.132.2018.11.23.04.42.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 04:42:30 -0800 (PST)
Date: Fri, 23 Nov 2018 13:42:28 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/4] mm, memory_hotplug: allocate memmap from
 hotadded memory
Message-ID: <20181123124228.GI8625@dhcp22.suse.cz>
References: <20181116101222.16581-1-osalvador@suse.com>
 <2571308d-0460-e8b9-ad40-75d6b13b2d09@redhat.com>
 <20181123115519.2dnzscmmgv63fdub@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181123115519.2dnzscmmgv63fdub@d104.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@d104.suse.de>
Cc: David Hildenbrand <david@redhat.com>, Oscar Salvador <osalvador@suse.com>, linux-mm@kvack.org, rppt@linux.vnet.ibm.com, akpm@linux-foundation.org, arunks@codeaurora.org, bhe@redhat.com, dan.j.williams@intel.com, Pavel.Tatashin@microsoft.com, Jonathan.Cameron@huawei.com, jglisse@redhat.com, linux-kernel@vger.kernel.org

On Fri 23-11-18 12:55:41, Oscar Salvador wrote:
> On Thu, Nov 22, 2018 at 10:21:24AM +0100, David Hildenbrand wrote:
> > 1. How are we going to present such memory to the system statistics?
> > 
> > In my opinion, this vmemmap memory should
> > a) still account to total memory
> > b) show up as allocated
> > 
> > So just like before.
> 
> No, it does not show up under total memory and neither as allocated memory.
> This memory is not for use for anything but for creating the pagetables
> for the memmap array for the section/s.

I haven't read through your patches yet but wanted to clarfify few
points here.

This should essentially follow the bootmem allocated memory pattern. So
it is present and accounted to spanned pages but it is not managed.

> It is not memory that the system can use.

same as bootmem ;)
 
> I also guess that if there is a strong opinion on this, we could create
> a counter, something like NR_VMEMMAP_PAGES, and show it under /proc/meminfo.

Do we really have to? Isn't the number quite obvious from the size of
the hotpluged memory?

> 
> > 2. Is this optional, in other words, can a device driver decide to not
> > to it like that?
> 
> Right now, is a per arch setup.
> For example, x86_64/powerpc/arm64 will do it inconditionally.
> 
> If we want to restrict this a per device-driver thing, I guess that we could
> allow to pass a flag to add_memory()->add_memory_resource(), and there
> unset MHP_MEMMAP_FROM_RANGE in case that flag is enabled.

I believe we will need to make this opt-in. There are some usecases
which hotplug an expensive (per size) memory via hotplug and it would be
too wasteful to use it for struct pages. I haven't bothered to address
that with my previous patches because I just wanted to make the damn
thing work first.
-- 
Michal Hocko
SUSE Labs
