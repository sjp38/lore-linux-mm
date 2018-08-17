Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 148586B08EC
	for <linux-mm@kvack.org>; Fri, 17 Aug 2018 11:41:38 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id j6-v6so6181311wrr.15
        for <linux-mm@kvack.org>; Fri, 17 Aug 2018 08:41:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m16-v6sor1005572wmb.1.2018.08.17.08.41.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 Aug 2018 08:41:36 -0700 (PDT)
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [RFC v2 0/2] Do not touch pages in remove_memory path
Date: Fri, 17 Aug 2018 17:41:25 +0200
Message-Id: <20180817154127.28602-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, jglisse@redhat.com, david@redhat.com, jonathan.cameron@huawei.com, Pavel.Tatashin@microsoft.com, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

This patchset moves all zone/page handling from the remove_memory
path back to the offline_pages stage.
This has be done for two reasons:

1) We can access steal pages if we remove memory that was never online [1]
2) Code consistency

Currently, when we online memory, online_pages() takes care to initialize
the pages and put the memory range into its corresponding zone.
So, zone/pgdat's spanned/present pages get resized.

But the opposite does not happen when we offline memory.
Only present pages is decremented, and we wait to shrink zone/node's
spanned_pages until we remove that memory.
But as explained above, this is wrong.

So this patchset tries to cover this by moving this handling to the place 
it should be.

The main difficulty I faced here was in regard of HMM/devm, as it really handles
the hot-add/remove memory particulary, and what is more important,
also the resources.

I really scratched my head for ideas about how to handle this case, and
after some fails I came up with the idea that we could check for the
res->flags.

Memory resources that goes through the "official" memory-hotplug channels
have the IORESOURCE_SYSTEM_RAM flag.
This flag is made of (IORESOURCE_MEM|IORESOURCE_SYSRAM).

HMM/devm, on the other hand, request and release the resources
through devm_request_mem_region/devm_release_mem_region, and 
these resources do not contain the IORESOURCE_SYSRAM flag.

So what I ended up doing is to check for IORESOURCE_SYSRAM
in release_mem_region_adjustable.
If we see that a resource does not have such a flag, we know that
we are dealing with a resource coming from HMM/devm, and so,
we do not need to do anything as HMM/dev will take care of that part.

I online compiled the code, but I did not test it (I will do next week),
but I sent this RFCv2 mainly because I would like to get feedback,
and see if the direction I took is the right one.

This time I left out [2] because I am working on this in a separate patch,
and does not really belong to this patchset.

[1] https://patchwork.kernel.org/patch/10547445/ (Reported by David)
[2] https://patchwork.kernel.org/patch/10558723/

Oscar Salvador (2):
  mm/memory_hotplug: Add nid parameter to arch_remove_memory
  mm/memory_hotplug: Shrink spanned pages when offlining memory

 arch/ia64/mm/init.c            |   6 +-
 arch/powerpc/mm/mem.c          |  12 +---
 arch/s390/mm/init.c            |   2 +-
 arch/sh/mm/init.c              |   6 +-
 arch/x86/mm/init_32.c          |   6 +-
 arch/x86/mm/init_64.c          |  10 +--
 include/linux/memory_hotplug.h |  11 +++-
 kernel/memremap.c              |  16 ++---
 kernel/resource.c              |  16 +++++
 mm/hmm.c                       |  34 +++++-----
 mm/memory_hotplug.c            | 145 ++++++++++++++++++++++++++---------------
 mm/sparse.c                    |   4 +-
 12 files changed, 157 insertions(+), 111 deletions(-)

-- 
2.13.6
