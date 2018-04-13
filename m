Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1F7556B0005
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 09:16:36 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id i204so5373052ywb.14
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 06:16:36 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id q53si6319350qtc.276.2018.04.13.06.16.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Apr 2018 06:16:34 -0700 (PDT)
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.rdu2.redhat.com [10.11.54.4])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E18258DC44
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 13:16:33 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH RFC 0/8] mm: online/offline 4MB chunks controlled by device driver
Date: Fri, 13 Apr 2018 15:16:24 +0200
Message-Id: <20180413131632.1413-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: David Hildenbrand <david@redhat.com>

I am right now working on a paravirtualized memory device ("virtio-mem").
These devices control a memory region and the amount of memory available
via it. Memory will not be indicated via ACPI and friends, the device
driver is responsible for it.

When the device driver starts up, it will add and online the requested
amount of memory from its assigned physical memory region. On request, it can
add (online) either more memory or try to remove (offline) memory.

As we want to be able to add small chunks of memory to a VM, it looks
like we can do that under Linux in a 4MB granularity. At least with
these patches on top of Linus tree :)

We add a segment and online only 4MB parts of it on demand. So the other
memory might not be accessible. For kdump and offline code, we have to
mark pages as offline (e.g. as these pages might not be backed by real
memory in the hypervisor).

In contrast to existing balloon solutions:
- The device is responsible for its own memory only.
- Works on a coarser granularity (e.g. 4MB because that's what we can
  online/offline in Linux). We are not using the buddy allocator when unplugging
  but really search for chunks of memory we can offline.
- A device can belong to exactly one NUMA node. This way we can online/offline
  memory in a fine granularity NUMA aware.
- Architectures that don't have proper memory hotplug interfaces (e.g. s390x)
  get memory hotplug support. I have a prototype for s390x.
- Once all 4MB chunks of a memory block are offline, we can remove the
  memory block and therefore the struct pages (seems to work in my prototype),
  which is nice.

Todo:
- We might have to add a parameter to offline_pages(), telling it to not
  try forever but abort in case it takes too long.
- Performance improvements. But I don't care about that right now.

Latest work d0dc12e86b31 "mm/memory_hotplug: optimize memory hotplug"
collides with my work and I wasn't able to get it running within 30min,
so I simply revert it to not stop discussion of this O:-)

On request I can post the current virtio-mem prototype.

Feelings? Recommandations? Things I am ignoring?


David Hildenbrand (8):
  mm/memory_hotplug: Revert "mm/memory_hotplug: optimize memory hotplug"
  mm: introduce PG_offline
  mm: use PG_offline in online/offlining code
  kdump: expose PG_offline
  mm: only mark section offline when all pages are offline
  mm: offline_pages() is also limited by MAX_ORDER
  mm: allow to control onlining/offlining of memory by a driver
  mm: export more functions used to online/offline memory

 drivers/base/memory.c          | 22 ++++++----
 drivers/base/node.c            |  2 -
 drivers/hv/hv_balloon.c        |  2 +-
 drivers/xen/balloon.c          |  2 +-
 include/linux/memory.h         |  2 +-
 include/linux/memory_hotplug.h |  4 +-
 include/linux/page-flags.h     | 10 +++++
 include/trace/events/mmflags.h |  9 +++-
 kernel/crash_core.c            |  3 ++
 mm/memory_hotplug.c            | 93 +++++++++++++++++++++++++++++++++++-------
 mm/page_alloc.c                | 35 ++++++++++------
 mm/sparse.c                    | 33 +++++++++++----
 12 files changed, 168 insertions(+), 49 deletions(-)

-- 
2.14.3
