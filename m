Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 29A326B02C3
	for <linux-mm@kvack.org>; Mon,  3 Jul 2017 17:14:25 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id d78so95632008qkb.0
        for <linux-mm@kvack.org>; Mon, 03 Jul 2017 14:14:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c77si15294067qkb.328.2017.07.03.14.14.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jul 2017 14:14:24 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 0/5] Cache coherent device memory (CDM) with HMM v3
Date: Mon,  3 Jul 2017 17:14:10 -0400
Message-Id: <20170703211415.11283-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Balbir Singh <bsingharora@gmail.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

Only Kconfig and comments changes since since v2, git tree:
https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-cdm-v3


Cache coherent device memory apply to architecture with system bus
like CAPI or CCIX. Device connected to such system bus can expose
their memory to the system and allow cache coherent access to it
from the CPU.

Even if for all intent and purposes device memory behave like regular
memory, we still want to manage it in isolation from regular memory.
Several reasons for that, first and foremost this memory is less
reliable than regular memory if the device hangs because of invalid
commands we can loose access to device memory. Second CPU access to
this memory is expected to be slower than to regular memory. Third
having random memory into device means that some of the bus bandwith
wouldn't be available to the device but would be use by CPU access.

This is why we want to manage such memory in isolation from regular
memory. Kernel should not try to use this memory as last resort
when running out of memory, at least for now.

This patchset add a new type of ZONE_DEVICE memory (DEVICE_PUBLIC)
that is use to represent CDM memory. This patchset build on top of
the HMM patchset that already introduce a new type of ZONE_DEVICE
memory for private device memory (see HMM patchset).

The end result is that with this patch if a device is in use in
a process you might have private anonymous memory or file back
page memory using ZONE_DEVICE (MEMORY_PUBLIC). Thus care must be
taken to not overwritte lru fields of such pages.

Hence all core mm changes are done to address assumption that any
process memory is back by a regular struct page that is part of
the lru. ZONE_DEVICE page are not on the lru and the lru pointer
of struct page are use to store device specific informations.

Thus this patch update all code path that would make assumptions
about lruness of a process page.

patch 01 - consolidate naming of different device memory type
patch 02 - deals with all the core mm functions
patch 03 - add an helper to HMM for hotplug of CDM memory
patch 04 - preparatory patch for memory controller changes
patch 05 - update memory controller to properly handle
           ZONE_DEVICE pages when uncharging

Previous posting:
v1 https://lkml.org/lkml/2017/4/7/638
v2 https://lwn.net/Articles/725412/

JA(C)rA'me Glisse (5):
  mm/persistent-memory: match IORES_DESC name and enum memory_type one
  mm/device-public-memory: device memory cache coherent with CPU v2
  mm/hmm: add new helper to hotplug CDM memory region
  mm/memcontrol: allow to uncharge page without using page->lru field
  mm/memcontrol: support MEMORY_DEVICE_PRIVATE and MEMORY_DEVICE_PUBLIC

 fs/proc/task_mmu.c       |   2 +-
 include/linux/hmm.h      |   7 +-
 include/linux/ioport.h   |   1 +
 include/linux/memremap.h |  25 +++++-
 include/linux/mm.h       |  16 ++--
 kernel/memremap.c        |  15 +++-
 mm/Kconfig               |  11 +++
 mm/gup.c                 |   7 ++
 mm/hmm.c                 |  89 +++++++++++++++++--
 mm/madvise.c             |   2 +-
 mm/memcontrol.c          | 226 ++++++++++++++++++++++++++++++-----------------
 mm/memory.c              |  46 ++++++++--
 mm/migrate.c             |  60 ++++++++-----
 mm/swap.c                |  11 +++
 14 files changed, 389 insertions(+), 129 deletions(-)

-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
