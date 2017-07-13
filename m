Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id BBDDA440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 17:15:37 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id o8so28314791qtc.1
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 14:15:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u64si6042065qka.284.2017.07.13.14.15.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 14:15:36 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 0/6] Cache coherent device memory (CDM) with HMM v5
Date: Thu, 13 Jul 2017 17:15:26 -0400
Message-Id: <20170713211532.970-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@kernel.org>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

Sorry i made horrible mistake on names in v4, i completly miss-
understood the suggestion. So here i repost with proper naming.
This is the only change since v3. Again sorry about the noise
with v4.

Changes since v4:
  - s/DEVICE_HOST/DEVICE_PUBLIC

Git tree:
https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-cdm-v5


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
memory. Kernel should not try to use this memory even as last resort
when running out of memory, at least for now.

This patchset add a new type of ZONE_DEVICE memory (DEVICE_HOST)
that is use to represent CDM memory. This patchset build on top of
the HMM patchset that already introduce a new type of ZONE_DEVICE
memory for private device memory (see HMM patchset).

The end result is that with this patchset if a device is in use in
a process you might have private anonymous memory or file back
page memory using ZONE_DEVICE (DEVICE_HOST). Thus care must be
taken to not overwritte lru fields of such pages.

Hence all core mm changes are done to address assumption that any
process memory is back by a regular struct page that is part of
the lru. ZONE_DEVICE page are not on the lru and the lru pointer
of struct page are use to store device specific informations.

Thus this patchset update all code path that would make assumptions
about lruness of a process page.

patch 01 - rename DEVICE_PUBLIC to DEVICE_HOST to free DEVICE_PUBLIC name
patch 02 - add DEVICE_PUBLIC type to ZONE_DEVICE (all core mm changes)
patch 03 - add an helper to HMM for hotplug of CDM memory
patch 04 - preparatory patch for memory controller changes (memch)
patch 05 - update memory controller to properly handle
           ZONE_DEVICE pages when uncharging
patch 06 - documentation patch

Previous posting:
v1 https://lkml.org/lkml/2017/4/7/638
v2 https://lwn.net/Articles/725412/
v3 https://lwn.net/Articles/727114/
v4 https://lwn.net/Articles/727692/

JA(C)rA'me Glisse (6):
  mm/zone-device: rename DEVICE_PUBLIC to DEVICE_HOST
  mm/device-public-memory: device memory cache coherent with CPU v4
  mm/hmm: add new helper to hotplug CDM memory region v3
  mm/memcontrol: allow to uncharge page without using page->lru field
  mm/memcontrol: support MEMORY_DEVICE_PRIVATE and MEMORY_DEVICE_PUBLIC
    v3
  mm/hmm: documents how device memory is accounted in rss and memcg

 Documentation/vm/hmm.txt |  40 ++++++++
 fs/proc/task_mmu.c       |   2 +-
 include/linux/hmm.h      |   7 +-
 include/linux/ioport.h   |   1 +
 include/linux/memremap.h |  25 ++++-
 include/linux/mm.h       |  20 ++--
 kernel/memremap.c        |  19 ++--
 mm/Kconfig               |  11 +++
 mm/gup.c                 |   7 ++
 mm/hmm.c                 |  89 ++++++++++++++++--
 mm/madvise.c             |   2 +-
 mm/memcontrol.c          | 231 ++++++++++++++++++++++++++++++-----------------
 mm/memory.c              |  46 +++++++++-
 mm/migrate.c             |  57 +++++++-----
 mm/swap.c                |  11 +++
 15 files changed, 434 insertions(+), 134 deletions(-)

-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
