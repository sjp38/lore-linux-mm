Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 796118E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 14:25:39 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id u13-v6so14977707pfm.8
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 11:25:39 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id p1-v6si6021186plk.294.2018.09.26.11.25.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Sep 2018 11:25:38 -0700 (PDT)
Subject: Re: [PATCH v5 4/4] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
References: <20180925200551.3576.18755.stgit@localhost.localdomain>
 <20180925202053.3576.66039.stgit@localhost.localdomain>
 <20180926075540.GD6278@dhcp22.suse.cz>
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Message-ID: <6f87a5d7-05e2-00f4-8568-bb3521869cea@linux.intel.com>
Date: Wed, 26 Sep 2018 11:25:37 -0700
MIME-Version: 1.0
In-Reply-To: <20180926075540.GD6278@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pavel.tatashin@microsoft.com, dave.jiang@intel.com, dave.hansen@intel.com, jglisse@redhat.com, rppt@linux.vnet.ibm.com, dan.j.williams@intel.com, logang@deltatee.com, mingo@kernel.org, kirill.shutemov@linux.intel.com



On 9/26/2018 12:55 AM, Michal Hocko wrote:
> On Tue 25-09-18 13:21:24, Alexander Duyck wrote:
>> The ZONE_DEVICE pages were being initialized in two locations. One was with
>> the memory_hotplug lock held and another was outside of that lock. The
>> problem with this is that it was nearly doubling the memory initialization
>> time. Instead of doing this twice, once while holding a global lock and
>> once without, I am opting to defer the initialization to the one outside of
>> the lock. This allows us to avoid serializing the overhead for memory init
>> and we can instead focus on per-node init times.
>>
>> One issue I encountered is that devm_memremap_pages and
>> hmm_devmmem_pages_create were initializing only the pgmap field the same
>> way. One wasn't initializing hmm_data, and the other was initializing it to
>> a poison value. Since this is something that is exposed to the driver in
>> the case of hmm I am opting for a third option and just initializing
>> hmm_data to 0 since this is going to be exposed to unknown third party
>> drivers.
> 
> Why cannot you pull move_pfn_range_to_zone out of the hotplug lock? In
> other words why are you making zone device even more special in the
> generic hotplug code when it already has its own means to initialize the
> pfn range by calling move_pfn_range_to_zone. Not to mention the code
> duplication.

So there were a few things I wasn't sure we could pull outside of the 
hotplug lock. One specific example is the bits related to resizing the 
pgdat and zone. I wanted to avoid pulling those bits outside of the 
hotplug lock.

The other bit that I left inside the hot-plug lock with this approach 
was the initialization of the pages that contain the vmemmap.

> That being said I really dislike this patch.

In my mind this was a patch that "killed two birds with one stone". I 
had two issues to address, the first one being the fact that we were 
performing the memmap_init_zone while holding the hotplug lock, and the 
other being the loop that was going through and initializing pgmap in 
the hmm and memremap calls essentially added another 20 seconds 
(measured for 3TB of memory per node) to the init time. With this patch 
I was able to cut my init time per node by that 20 seconds, and then 
made it so that we could scale as we added nodes as they could run in 
parallel.

With that said I am open to suggestions if you still feel like I need to 
follow this up with some additional work. I just want to avoid 
introducing any regressions in regards to functionality or performance.

Thanks.

- Alex
