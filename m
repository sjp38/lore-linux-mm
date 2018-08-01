Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 66BBC6B0006
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 08:23:59 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id s18-v6so3756813wmc.5
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 05:23:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 137-v6sor1462135wmo.65.2018.08.01.05.23.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Aug 2018 05:23:56 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [PATCH v6 0/5] Refactor free_area_init_core and add free_area_init_core_hotplug
Date: Wed,  1 Aug 2018 14:23:43 +0200
Message-Id: <20180801122348.21588-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, pasha.tatashin@oracle.com, mgorman@techsingularity.net, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.j.williams@intel.com, david@redhat.com, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

Changes:

v5 -> v6:
        - Added patch from Pavel that removes __paginginit
        - Convert all __meminit(old __paginginit) to __init
          for functions we do not need after initialization.
        - Move definition of free_area_init_core_hotplug
          to include/linux/memory_hotplug.h
        - Add Acked-by from Michal Hocko

v4 -> v5:
        - Remove __ref from hotadd_new_pgdat and placed it to
          free_area_init_core_hotplug. (Suggested by Pavel)
        - Since free_area_init_core_hotplug is now allowed to be in a different
          section (__ref), remove the __paginginit.)
        - Stylecode in free_area_init_core_hotplug (Suggested by Pavel)
        - Replace s/@__paginginit/@__init for free_area_init_node/free_area_init_core
          as these functions are now only called during early init.
        - Add Reviewd-by from Pavel

v3 -> v4:
        - Unify patch-5 and patch-4.
        - Make free_area_init_core __init (Suggested by Michal).
        - Make zone_init_internals __paginginit (Suggested by Pavel).
        - Add Reviewed-by/Acked-by:

v2 -> v3:
        - Think better about split free_area_init_core for
          memhotplug/early init context (Suggested by Michal).

This patchset does the following things:

 1) Clean up/refactor free_area_init_core/free_area_init_node
    by moving the ifdefery out of the functions.
 2) Move the pgdat/zone initialization in free_area_init_core to its
    own function.
 3) Introduce free_area_init_core_hotplug, a small subset of free_area_init_core,
    which is only called from memhotlug code path.
    In this way, we have:
 4) Remove __paginginit and convert it to __meminit
 5) Reconvert all __meminit to __init for functions we do not need after
    initialization.

After this, we have:

    free_area_init_core: called during early initialization
    free_area_init_core_hotplug: called whenever a new node is allocated/re-used (memhotplug path)

Oscar Salvador (3):
  mm/page_alloc: Move ifdefery out of free_area_init_core
  mm/page_alloc: Inline function to handle
    CONFIG_DEFERRED_STRUCT_PAGE_INIT
  mm/page_alloc: Introduce free_area_init_core_hotplug

Pavel Tatashin (2):
  mm: access zone->node via zone_to_nid() and zone_set_nid()
  mm: remove __paginginit

 include/linux/memory_hotplug.h |   1 +
 include/linux/mm.h             |  11 +--
 include/linux/mmzone.h         |  26 +++++--
 mm/internal.h                  |  12 ----
 mm/memory_hotplug.c            |  16 ++---
 mm/mempolicy.c                 |   4 +-
 mm/mm_init.c                   |   9 +--
 mm/page_alloc.c                | 151 +++++++++++++++++++++++++++++------------
 8 files changed, 137 insertions(+), 93 deletions(-)

-- 
2.13.6
