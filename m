Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id DF4606B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 16:12:00 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id o41so6972917qtf.8
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 13:12:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u48si885707qtc.278.2017.06.14.13.11.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 13:11:59 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM-CDM 0/5] Cache coherent device memory (CDM) with HMM
Date: Wed, 14 Jun 2017 16:11:39 -0400
Message-Id: <20170614201144.9306-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, cgroups@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Balbir Singh <balbirs@au1.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

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

patch 01 - deals with all the core mm functions
patch 02 - add an helper to HMM for hotplug of CDM memory
patch 03 - preparatory patch for memory controller changes
patch 04 - update memory controller to properly handle
           ZONE_DEVICE pages when uncharging
patch 05 - kernel configuration updates and cleanup

git tree:
https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-cdm-v2


Cc: cgroups@vger.kernel.org
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Balbir Singh <balbirs@au1.ibm.com>
Cc: Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>
Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>

JA(C)rA'me Glisse (5):
  mm/device-public-memory: device memory cache coherent with CPU
  mm/hmm: add new helper to hotplug CDM memory region
  mm/memcontrol: allow to uncharge page without using page->lru field
  mm/memcontrol: support MEMORY_DEVICE_PRIVATE and MEMORY_DEVICE_PUBLIC
  mm/hmm: simplify kconfig and enable HMM and DEVICE_PUBLIC for ppc64

 fs/proc/task_mmu.c       |   2 +-
 include/linux/hmm.h      |   7 +-
 include/linux/ioport.h   |   1 +
 include/linux/memremap.h |  21 +++++
 include/linux/mm.h       |  16 ++--
 kernel/memremap.c        |  13 ++-
 mm/Kconfig               |  30 +++----
 mm/gup.c                 |   7 ++
 mm/hmm.c                 |  89 +++++++++++++++++--
 mm/madvise.c             |   2 +-
 mm/memcontrol.c          | 226 ++++++++++++++++++++++++++++++-----------------
 mm/memory.c              |  46 ++++++++--
 mm/migrate.c             |  60 ++++++++-----
 mm/swap.c                |  11 +++
 14 files changed, 389 insertions(+), 142 deletions(-)

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
