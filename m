Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2063E6B0005
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 11:30:55 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id y203-v6so14565651wmg.9
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 08:30:55 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l23-v6sor5704589wmc.6.2018.10.15.08.30.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Oct 2018 08:30:53 -0700 (PDT)
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [PATCH 0/5] Do not touch pages/zones during hot-remove path
Date: Mon, 15 Oct 2018 17:30:29 +0200
Message-Id: <20181015153034.32203-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, yasu.isimatu@gmail.com, rppt@linux.vnet.ibm.com, malat@debian.org, linux-kernel@vger.kernel.org, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, david@redhat.com, dave.jiang@intel.com, linux-mm@kvack.org, alexander.h.duyck@linux.intel.com, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

This patchset aims to solve [1] and [2] issues.
Due to the lack of feedback of previous versions, I decided to go safe,
so I reverted some of the changes I did in RFCv3:

 1) It is no longer based on [3], although the code would be easier and
    the changes less.

 2) hotplug lock stays in HMM/devm, mainly because I am not sure whether
    it is ok to leave the kasan calls out of lock or not.
    If we think that this can be done, the hotplug lock can be moved
    within add/del_device_memory, which would be nicer IMHO.

 3) Although I think that init_currently_empty_zone should be protected
    by the spanlock since it touches zone_start_pfn, I decided to leave
    it as it is right now.
    The main point of moving it within the lock was to be able to move
    move_pfn_range_to_zone out of the hotplug lock for HMM/devm code.
    
The main point of this patchset is to move all the page/zone handling
from the hot-remove path, back to the offlining stage.
In this way, we can better split up what each part does:

  * hot-add path:
    - Create a new resource for the hot-added memory
    - Create memory sections for the hot-added memory
    - Create the memblocks representing the hot-added memory

  * online path:
    - Re-adjust zone/pgdat nr of pages (managed, spanned, present)
    - Initialize the pages from the new memory-range
    - Online memory sections

  * offline path:
    - Offline memory sections
    - Re-adjust zone/pgdat nr of pages (managed, spanned, present)

  * hot-remove path:
    - Remove memory sections
    - Remove memblocks
    - Remove resources

So, hot-add/remove stages should only care about sections and memblocks.
While all the zone/page handling should belong to the online/offline stage.

Another thing is that for the sake of reviewability, I split the patchset
in 5 parts, but pathc3 could be combined into patch4.
 
This patchset is based on top of mmotm.

[1] https://patchwork.kernel.org/patch/10547445/
[2] https://www.spinics.net/lists/linux-mm/msg161316.html
[3] https://patchwork.kernel.org/cover/10613425/

Oscar Salvador (5):
  mm/memory_hotplug: Add nid parameter to arch_remove_memory
  mm/memory_hotplug: Create add/del_device_memory functions
  mm/memory_hotplug: Check for IORESOURCE_SYSRAM in
    release_mem_region_adjustable
  mm/memory_hotplug: Move zone/pages handling to offline stage
  mm/memory-hotplug: Rework unregister_mem_sect_under_nodes

 arch/ia64/mm/init.c            |   6 +-
 arch/powerpc/mm/mem.c          |  14 +---
 arch/s390/mm/init.c            |   2 +-
 arch/sh/mm/init.c              |   6 +-
 arch/x86/mm/init_32.c          |   6 +-
 arch/x86/mm/init_64.c          |  11 +---
 drivers/base/memory.c          |   9 ++-
 drivers/base/node.c            |  38 ++---------
 include/linux/memory.h         |   2 +-
 include/linux/memory_hotplug.h |  21 ++++--
 include/linux/node.h           |   9 ++-
 kernel/memremap.c              |  13 ++--
 kernel/resource.c              |  16 +++++
 mm/hmm.c                       |  35 +++++-----
 mm/memory_hotplug.c            | 142 +++++++++++++++++++++++++----------------
 mm/sparse.c                    |   6 +-
 16 files changed, 177 insertions(+), 159 deletions(-)

-- 
2.13.6
