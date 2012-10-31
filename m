Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 293576B0044
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 07:48:21 -0400 (EDT)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [Patch v4 0/8] bugfix for memory hotplug
Date: Wed, 31 Oct 2012 19:23:06 +0800
Message-Id: <1351682594-17347-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org
Cc: Jiang Liu <liuj97@gmail.com>, Len Brown <len.brown@intel.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, rjw@sisk.pl, Lai Jiangshan <laijs@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>

The last version is here:
    https://lkml.org/lkml/2012/10/19/56

Note: patch 1-3 are in -mm tree and I don't touch them. The other patches
except patch6 are also in mm tree. Patch 6 is not touched.

Changes from v3 to v4:
  Patch4: use dynamically allocated memory instead of static array.
  Patch5: merge [patchv3 2-3] into a single patch, and update it as we use
          dynamically allocated memory
  Patch7: merge [patchv3 5-6] into a single patch
  Patch8: merge [patchv3 9] and its fix into a patch

Changes from v2 to v3:
  Merge the bug fix from ishimatsu to this patchset(Patch 1-3)
  Patch 3: split it from patch as it fixes another bug.
  Patch 4: new patch, and fix bad-page state when hotadding a memory
           device after hotremoving it. I forgot to post this patch in v2.
  Patch 6: update it according to Dave Hansen's comment.

Changes from v1 to v2:
  Patch 1: updated according to kosaki's suggestion

  Patch 2: new patch, and update mce_bad_pages when removing memory.

  Patch 4: new patch, and fix a NR_FREE_PAGES mismatch, and this bug
           cause oom in my test.

  Patch 5: new patch, and fix a new bug. When repeating to online/offline
           pages, the free pages will continue to decrease. 

Wen Congyang (6):
  memory-hotplug: auto offline page_cgroup when onlining memory block
    failed
  memory-hotplug: fix NR_FREE_PAGES mismatch
  numa: convert static memory to dynamically allocated memory for per
    node device
  clear the memory to store struct page
  memory-hotplug: current hwpoison doesn't support memory offline
  memory-hotplug: allocate zone's pcp before onlining pages

Yasuaki Ishimatsu (2):
  memory hotplug: suppress "Device memoryX does not have a release()
    function" warning
  suppress "Device nodeX does not have a release() function" warning

 arch/powerpc/kernel/sysfs.c    |  4 +--
 drivers/base/memory.c          |  9 ++++++-
 drivers/base/node.c            | 56 ++++++++++++++++++++++++++++++------------
 include/linux/node.h           |  2 +-
 include/linux/page-isolation.h | 10 +++++---
 mm/hugetlb.c                   |  4 +--
 mm/memory-failure.c            |  2 +-
 mm/memory_hotplug.c            | 13 +++++++---
 mm/page_alloc.c                | 37 +++++++++++++++++++++-------
 mm/page_cgroup.c               |  3 +++
 mm/page_isolation.c            | 27 ++++++++++++++------
 mm/sparse.c                    | 25 ++++++++++++++++++-
 12 files changed, 144 insertions(+), 48 deletions(-)

-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
