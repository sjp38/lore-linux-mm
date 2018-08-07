Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id CC5BF6B0008
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 09:38:22 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id v2-v6so13426350wrr.10
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 06:38:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g17-v6sor588431wrp.51.2018.08.07.06.38.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Aug 2018 06:38:21 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [RFC PATCH 0/3] Do not touch pages in remove_memory path
Date: Tue,  7 Aug 2018 15:37:54 +0200
Message-Id: <20180807133757.18352-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, pasha.tatashin@oracle.com, jglisse@redhat.com, david@redhat.com, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

This tries to fix [1], which was reported by David Hildenbrand, and also
does some cleanups/refactoring.

I am sending this as RFC to see if the direction I am going is right before
spending more time into it.
And also to gather feedback about hmm/zone_device stuff.
The code compiles and I tested it successfully with normal memory-hotplug operations.

Here we go:

With the following scenario:

1) We add memory
2) We do not online it
3) We remove the memory

an invalid access is being made to those pages.

The reason is that the pages are initialized in online_pages() path:

        /   online_pages
        |    move_pfn_range
ONLINE  |     move_pfn_range_to_zone
PAGES   |      ...
        |      memmap_init_zone

But depending on our policy about onlining the pages by default, we might not
online them right after having added the memory, and so, those pages might be
left unitialized.

This is a problem because we access those pages in arch_remove_memory:

...
if (altmap)
        page += vmem_altmap_offset(altmap);
        zone = page_zone(page);
...

So we are accessing unitialized data basically.


Currently, we need to have the zone from arch_remove_memory to all the way down
because

1) we call __remove_zone zo shrink spanned pages from pgdat/zone
2) we get the pgdat from the zone

Number 1 can be fixed by moving __remove_zone back to offline_pages(), where it should be.
This, besides fixing the bug, will make the code more consistent because all the reveserse
operations from online_pages() will be made in offline_pages().

Number 2 can be fixed by passing nid instead of zone.

The tricky part of all this is the hmm code and the zone_device stuff.

Fixing the calls to arch_remove_memory in the arch code is easy, but arch_remove_memory
is being used in:

kernel/memremap.c: devm_memremap_pages_release()
mm/hmm.c:          hmm_devmem_release()

I did my best to get my head around this, but my knowledge in that area is 0, so I am pretty sure
I did not get it right.

The thing is:

devm_memremap_pages(), which is the counterpart of devm_memremap_pages_release(),
calls arch_add_memory(), and then calls move_pfn_range_to_zone() (to ZONE_DEVICE).
So it does not go through online_pages().
So there I call shrink_pages() (it does pretty much as __remove_zone) before calling
to arch_remove_memory.
But as I said, I do now if that is right.

[1] https://patchwork.kernel.org/patch/10547445/

Oscar Salvador (3):
  mm/memory_hotplug: Add nid parameter to arch_remove_memory
  mm/memory_hotplug: Create __shrink_pages and move it to offline_pages
  mm/memory_hotplug: Refactor shrink_zone/pgdat_span

 arch/ia64/mm/init.c            |   6 +-
 arch/powerpc/mm/mem.c          |  13 +--
 arch/s390/mm/init.c            |   2 +-
 arch/sh/mm/init.c              |   6 +-
 arch/x86/mm/init_32.c          |   6 +-
 arch/x86/mm/init_64.c          |  10 +--
 include/linux/memory_hotplug.h |   8 +-
 kernel/memremap.c              |   9 +-
 mm/hmm.c                       |   6 +-
 mm/memory_hotplug.c            | 190 +++++++++++++++++++++--------------------
 mm/sparse.c                    |   4 +-
 11 files changed, 127 insertions(+), 133 deletions(-)

-- 
2.13.6
