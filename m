Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 431776B48ED
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 11:20:37 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id 89so24032480ple.19
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 08:20:37 -0800 (PST)
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id q8si4042134pgc.580.2018.11.27.08.20.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 08:20:35 -0800 (PST)
From: Oscar Salvador <osalvador@suse.de>
Subject: [PATCH v2 0/5] Do not touch pages in hot-remove path
Date: Tue, 27 Nov 2018 17:20:00 +0100
Message-Id: <20181127162005.15833-1-osalvador@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, david@redhat.com, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.com>

From: Oscar Salvador <osalvador@suse.com>

This patchset is based on Dan's HMM/devm refactorization [1].

----

This patchset aims for two things:

 1) A better definition about offline and hot-remove stage
 2) Solving bugs where we can access non-initialized pages
    during hot-remove operations [2] [3].

This is achieved by moving all page/zone handling to the offline
stage, so we do not need to access pages when hot-removing memory.

[1] https://patchwork.kernel.org/cover/10691415/
[2] https://patchwork.kernel.org/patch/10547445/
[3] https://www.spinics.net/lists/linux-mm/msg161316.html

Oscar Salvador (5):
  mm, memory_hotplug: Add nid parameter to arch_remove_memory
  kernel, resource: Check for IORESOURCE_SYSRAM in
    release_mem_region_adjustable
  mm, memory_hotplug: Move zone/pages handling to offline stage
  mm, memory-hotplug: Rework unregister_mem_sect_under_nodes
  mm, memory_hotplug: Refactor shrink_zone/pgdat_span

 arch/ia64/mm/init.c            |   2 +-
 arch/powerpc/mm/mem.c          |  14 +--
 arch/s390/mm/init.c            |   2 +-
 arch/sh/mm/init.c              |   6 +-
 arch/x86/mm/init_32.c          |   5 +-
 arch/x86/mm/init_64.c          |  11 +-
 drivers/base/memory.c          |   9 +-
 drivers/base/node.c            |  39 +------
 include/linux/memory.h         |   2 +-
 include/linux/memory_hotplug.h |  12 +-
 include/linux/node.h           |   9 +-
 kernel/memremap.c              |  19 ++-
 kernel/resource.c              |  15 +++
 mm/memory_hotplug.c            | 254 +++++++++++++++++++----------------------
 mm/sparse.c                    |   4 +-
 15 files changed, 182 insertions(+), 221 deletions(-)

-- 
2.13.6
