Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5C8916B0006
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 11:00:50 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id 88-v6so1824565wrp.21
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 08:00:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y31-v6sor11369839wrd.50.2018.10.02.08.00.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Oct 2018 08:00:47 -0700 (PDT)
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [RFC PATCH v3 0/5] Do not touch pages/zones during hot-remove path
Date: Tue,  2 Oct 2018 17:00:24 +0200
Message-Id: <20181002150029.23461-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, yasu.isimatu@gmail.com, rppt@linux.vnet.ibm.com, malat@debian.org, linux-kernel@vger.kernel.org, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, david@redhat.com, dave.jiang@intel.com, Oscar Salvador <osalvador@techadventures.net>

I was about to send the patchset without RFC as suggested, but I wanted
to give it one more spin before sending it officially.

I rebased this patchset on top of [1] and [2].

I chose to rebase this on top of [1] because after that, HMM/devm got some
of their code unified, and the changes to be done were less.

Currently, the operations layout performed by the hot-add/remove and
offline/online stages looks like the following:

- hot-add memory:
  a) Allocate a new resouce based on the hot-added memory
  b) Add memory sections for the hot-added memory

- online memory:
  c) Re-adjust zone/pgdat nr of pages (managed, spanned, present)
  d) Initialize the pages from the new memory-range
  e) Online memory sections

- offline memory:
  f) Offline memory sections
  g) Re-adjust zone/pgdat nr of managed/present pages

- hot-remove memory:
  i) Re-adjust zone/pgdat nr of spanned pages
  j) Remove memory sections
  k) Release resource


This is not right for two reasons:

 1) If we do not get to online memory added by a hot-add operation,
    and we offline it right away, we can access steal pages as these
    are only initialized during the onlining stage.
    Two problems have been reported for this [3] and [4]
 2) hot-add/remove memory operations should only care about
    sections and memblock, nothing else.

This patchset moves the handling of the zones/pages
from the hot-remove path to the offline stage.

One of the things that made me scratch my head is the handling of the
memory-hotplug in regard of HMM/devm.
I really scratched my head to find out a way to handle it properly
and nicely, but let me be honest about this, my knowledge of that
part of the code tends to 0.

Jerome reviewed that part of the changes and it looked ok for him,
and Pavel did not see anything wrong in v2 either.

But I would like to get more feedback before sending it without RFC.

The picture we have after this is:

- hot-add memory:
  a) Allocate a new resouce based on the hot-added memory
  b) Add memory sections for the hot-added memory

- online memory:
  c) Re-adjust zone/pgdat nr of pages (managed, spanned, present)
  d) Initialize the pages from the new memory-range
  e) Online memory sections

- offline memory:
  f) Offline memory sections
  g) Re-adjust zone/pgdat nr of managed/present/spanned pages

- hot-remove memory:
  i) Remove memory sections
  j) Release resource


[1] https://patchwork.kernel.org/cover/10613425/
[2] https://patchwork.kernel.org/cover/10617699/
[3] https://patchwork.kernel.org/patch/10547445/
[4] https://www.spinics.net/lists/linux-mm/msg161316.html

Oscar Salvador (5):
  mm/memory_hotplug: Add nid parameter to arch_remove_memory
  mm/memory_hotplug: Create add/del_device_memory functions
  mm/memory_hotplug: Check for IORESOURCE_SYSRAM in
    release_mem_region_adjustable
  mm/memory_hotplug: Move zone/pages handling to offline stage
  mm/memory-hotplug: Rework unregister_mem_sect_under_nodes

 arch/ia64/mm/init.c            |   6 +-
 arch/powerpc/mm/mem.c          |  13 +---
 arch/s390/mm/init.c            |   2 +-
 arch/sh/mm/init.c              |   6 +-
 arch/x86/mm/init_32.c          |   6 +-
 arch/x86/mm/init_64.c          |  10 +--
 drivers/base/memory.c          |   9 ++-
 drivers/base/node.c            |  38 ++--------
 include/linux/memory.h         |   2 +-
 include/linux/memory_hotplug.h |  17 +++--
 include/linux/node.h           |   7 +-
 kernel/memremap.c              |  50 +++++---------
 kernel/resource.c              |  15 ++++
 mm/memory_hotplug.c            | 153 ++++++++++++++++++++++++++---------------
 mm/sparse.c                    |   4 +-
 15 files changed, 169 insertions(+), 169 deletions(-)

-- 
2.13.6
