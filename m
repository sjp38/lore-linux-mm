Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E2B3B6B308C
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 08:00:46 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id v4so5588009edm.18
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 05:00:46 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h28si5497233ede.371.2018.11.23.05.00.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 05:00:45 -0800 (PST)
Date: Fri, 23 Nov 2018 14:00:43 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/4] mm, memory_hotplug: provide a more generic
 restrictions for memory hotplug
Message-ID: <20181123130043.GM8625@dhcp22.suse.cz>
References: <20181116101222.16581-1-osalvador@suse.com>
 <20181116101222.16581-3-osalvador@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181116101222.16581-3-osalvador@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@suse.com>
Cc: linux-mm@kvack.org, david@redhat.com, rppt@linux.vnet.ibm.com, akpm@linux-foundation.org, arunks@codeaurora.org, bhe@redhat.com, dan.j.williams@intel.com, Pavel.Tatashin@microsoft.com, Jonathan.Cameron@huawei.com, jglisse@redhat.com, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>, Alexander Duyck <alexander.h.duyck@linux.intel.com>

[Cc Alexander - email thread starts http://lkml.kernel.org/r/20181116101222.16581-1-osalvador@suse.com]

On Fri 16-11-18 11:12:20, Oscar Salvador wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> arch_add_memory, __add_pages take a want_memblock which controls whether
> the newly added memory should get the sysfs memblock user API (e.g.
> ZONE_DEVICE users do not want/need this interface). Some callers even
> want to control where do we allocate the memmap from by configuring
> altmap. This is currently done quite ugly by searching for altmap down
> in memory hotplug (to_vmem_altmap). It should be the caller to provide
> the altmap down the call chain.
> 
> Add a more generic hotplug context for arch_add_memory and __add_pages.
> struct mhp_restrictions contains flags which contains additional
> features to be enabled by the memory hotplug (MHP_MEMBLOCK_API
> currently) and altmap for alternative memmap allocator.

One note here as well. In the retrospect the API I have come up
with here is quite hackish. Considering the recent discussion about
special needs ZONE_DEVICE has for both initialization and struct page
allocations with Alexander Duyck I believe we wanted a more abstracted
API with allocator and constructor callbacks. This would allow different
usecases to fine tune their needs without specialcasing deep in the core
hotplug code paths.
-- 
Michal Hocko
SUSE Labs
