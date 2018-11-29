Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5ACF56B51DA
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 04:29:15 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id y35so799435edb.5
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 01:29:15 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Thu, 29 Nov 2018 10:29:12 +0100
From: osalvador@suse.de
Subject: Re: [PATCH v2 5/5] mm, memory_hotplug: Refactor
 shrink_zone/pgdat_span
In-Reply-To: <20181128155030.GM6923@dhcp22.suse.cz>
References: <20181127162005.15833-1-osalvador@suse.de>
 <20181127162005.15833-6-osalvador@suse.de>
 <20181128065018.GG6923@dhcp22.suse.cz> <1543388866.2920.5.camel@suse.de>
 <20181128101426.GH6923@dhcp22.suse.cz>
 <ddee6546c35aaada14b196c83f5205e0@suse.de>
 <20181128123120.GJ6923@dhcp22.suse.cz>
 <ddd7474af7162dcfa3ce328587b4a916@suse.de>
 <20181128130824.GL6923@dhcp22.suse.cz>
 <bac2ab7c71bf8b14535a8d1031e219d9@suse.de>
 <20181128155030.GM6923@dhcp22.suse.cz>
Message-ID: <55c58e62b03845420883f914e14c9855@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, david@redhat.com, linux-mm@kvack.org, owner-linux-mm@kvack.org

> OK, so let me try again. What is the difference for a pfn walker to
> start at an offline pfn start from any other offlined section withing a
> zone boundary? I believe there is none because the pfn walker needs to
> skip over offline pfns anyway whether they start at a zone boundary or
> not.

I checked most of the users of zone_start_pnf:

* split_huge_pages_set:
   - It uses pfn_valid().
     I guess this is fine as it will check if the section still has a 
map.

* __reset_isolation_suitable():
   - Safe as it uses pfn_to_online_page().

* isolate_freepages_range():
* isolate_migratepages_range():
* isolate_migratepages():
   - They use pageblock_pfn_to_page().
     If !zone->contiguos, it will use 
__pageblock_pfn_to_page()->pfn_to_online_page()
     If zone->contiguos is true, it will use 
pageblock_pfn_to_page()->pfn_to_page(),
     which is bad because it will not skip over offlined pfns.

* count_highmem_pages:
* count_data_pages:
* copy_data_pages:
   - page_is_saveable()->pfn_valid().
     I guess this is fine as it will check if the section still has a 
map.


So, leaving out isolate_* functions, it seems that we should be safe.
isolate_* functions would depend on !zone->contiguos to call 
__pageblock_pfn_to_page()->pfn_to_online_page().
So whenever we remove a section in a zone, we should clear 
zone->contiguos.
But this really calls for some deep check that we will not shoot in the 
foot.

What I can do for now is to drop this patch from the patchset and 
re-send
v3 without it.
