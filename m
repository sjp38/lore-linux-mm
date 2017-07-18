Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3071F6B0279
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 23:33:45 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id b20so10419995itd.1
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 20:33:45 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id p206si1013277iod.10.2017.07.17.20.33.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 17 Jul 2017 20:33:44 -0700 (PDT)
Subject: Re: [PATCH 0/6] Cache coherent device memory (CDM) with HMM v5
References: <20170713211532.970-1-jglisse@redhat.com>
From: Bob Liu <liubo95@huawei.com>
Message-ID: <2d534afc-28c5-4c81-c452-7e4c013ab4d0@huawei.com>
Date: Tue, 18 Jul 2017 11:26:51 +0800
MIME-Version: 1.0
In-Reply-To: <20170713211532.970-1-jglisse@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@kernel.org>

On 2017/7/14 5:15, JA(C)rA'me Glisse wrote:
> Sorry i made horrible mistake on names in v4, i completly miss-
> understood the suggestion. So here i repost with proper naming.
> This is the only change since v3. Again sorry about the noise
> with v4.
> 
> Changes since v4:
>   - s/DEVICE_HOST/DEVICE_PUBLIC
> 
> Git tree:
> https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-cdm-v5
> 
> 
> Cache coherent device memory apply to architecture with system bus
> like CAPI or CCIX. Device connected to such system bus can expose
> their memory to the system and allow cache coherent access to it
> from the CPU.
> 
> Even if for all intent and purposes device memory behave like regular
> memory, we still want to manage it in isolation from regular memory.
> Several reasons for that, first and foremost this memory is less
> reliable than regular memory if the device hangs because of invalid
> commands we can loose access to device memory. Second CPU access to
> this memory is expected to be slower than to regular memory. Third
> having random memory into device means that some of the bus bandwith
> wouldn't be available to the device but would be use by CPU access.
> 
> This is why we want to manage such memory in isolation from regular
> memory. Kernel should not try to use this memory even as last resort
> when running out of memory, at least for now.
>

I think set a very large node distance for "Cache Coherent Device Memory" may be a easier way to address these concerns.

--
Regards,
Bob Liu


 
> This patchset add a new type of ZONE_DEVICE memory (DEVICE_HOST)
> that is use to represent CDM memory. This patchset build on top of
> the HMM patchset that already introduce a new type of ZONE_DEVICE
> memory for private device memory (see HMM patchset).
> 
> The end result is that with this patchset if a device is in use in
> a process you might have private anonymous memory or file back
> page memory using ZONE_DEVICE (DEVICE_HOST). Thus care must be
> taken to not overwritte lru fields of such pages.
> 
> Hence all core mm changes are done to address assumption that any
> process memory is back by a regular struct page that is part of
> the lru. ZONE_DEVICE page are not on the lru and the lru pointer
> of struct page are use to store device specific informations.
> 
> Thus this patchset update all code path that would make assumptions
> about lruness of a process page.
> 
> patch 01 - rename DEVICE_PUBLIC to DEVICE_HOST to free DEVICE_PUBLIC name
> patch 02 - add DEVICE_PUBLIC type to ZONE_DEVICE (all core mm changes)
> patch 03 - add an helper to HMM for hotplug of CDM memory
> patch 04 - preparatory patch for memory controller changes (memch)
> patch 05 - update memory controller to properly handle
>            ZONE_DEVICE pages when uncharging
> patch 06 - documentation patch
> 
> Previous posting:
> v1 https://lkml.org/lkml/2017/4/7/638
> v2 https://lwn.net/Articles/725412/
> v3 https://lwn.net/Articles/727114/
> v4 https://lwn.net/Articles/727692/
> 
> JA(C)rA'me Glisse (6):
>   mm/zone-device: rename DEVICE_PUBLIC to DEVICE_HOST
>   mm/device-public-memory: device memory cache coherent with CPU v4
>   mm/hmm: add new helper to hotplug CDM memory region v3
>   mm/memcontrol: allow to uncharge page without using page->lru field
>   mm/memcontrol: support MEMORY_DEVICE_PRIVATE and MEMORY_DEVICE_PUBLIC
>     v3
>   mm/hmm: documents how device memory is accounted in rss and memcg
> 
>  Documentation/vm/hmm.txt |  40 ++++++++
>  fs/proc/task_mmu.c       |   2 +-
>  include/linux/hmm.h      |   7 +-
>  include/linux/ioport.h   |   1 +
>  include/linux/memremap.h |  25 ++++-
>  include/linux/mm.h       |  20 ++--
>  kernel/memremap.c        |  19 ++--
>  mm/Kconfig               |  11 +++
>  mm/gup.c                 |   7 ++
>  mm/hmm.c                 |  89 ++++++++++++++++--
>  mm/madvise.c             |   2 +-
>  mm/memcontrol.c          | 231 ++++++++++++++++++++++++++++++-----------------
>  mm/memory.c              |  46 +++++++++-
>  mm/migrate.c             |  57 +++++++-----
>  mm/swap.c                |  11 +++
>  15 files changed, 434 insertions(+), 134 deletions(-)
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
