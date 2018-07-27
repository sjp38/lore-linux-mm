Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 167076B000D
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 10:03:35 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id 40-v6so1580346wrb.23
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 07:03:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x25-v6sor1136791wmc.70.2018.07.27.07.03.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 27 Jul 2018 07:03:33 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [PATCH v4 0/4] Refactor free_area_init_core and add free_area_init_core_hotplug
Date: Fri, 27 Jul 2018 16:03:21 +0200
Message-Id: <20180727140325.11881-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, pasha.tatashin@oracle.com, mgorman@techsingularity.net, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.j.williams@intel.com, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

Changes:

v3 -> v4:
        - Unify patch-5 and patch-4
        - Make free_area_init_core __init (Suggested by Michal)
        - Make zone_init_internals __paginginit (Suggested by Pavel)
        - Add Reviewed-by/Acked-by:

v2 -> v3:
        - Think better about split free_area_init_core for
          memhotplug/early init context (Suggested by Michal)

This patchset does three things:

 1) Clean up/refactor free_area_init_core/free_area_init_node
    by moving the ifdefery out of the functions.
 2) Move the pgdat/zone initialization in free_area_init_core to its
    own function.
 3) Introduce free_area_init_core_hotplug, a small subset of free_area_init_core,
    which is only called from memhotlug code path.
    In this way, we have:

    free_area_init_core: called during early initialization
    free_area_init_core_hotplug: called whenever a new node is allocated/re-used (memhotplug path)

Oscar Salvador (3):
  mm/page_alloc: Move ifdefery out of free_area_init_core
  mm/page_alloc: Inline function to handle
    CONFIG_DEFERRED_STRUCT_PAGE_INIT
  mm/page_alloc: Introduce free_area_init_core_hotplug

Pavel Tatashin (1):
  mm: access zone->node via zone_to_nid() and zone_set_nid()

 include/linux/mm.h     |  13 ++---
 include/linux/mmzone.h |  26 +++++++---
 mm/memory_hotplug.c    |  16 ++----
 mm/mempolicy.c         |   4 +-
 mm/mm_init.c           |   9 +---
 mm/page_alloc.c        | 134 +++++++++++++++++++++++++++++++++++--------------
 6 files changed, 130 insertions(+), 72 deletions(-)

-- 
2.13.6
