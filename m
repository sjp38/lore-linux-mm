Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id B84226B0069
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 02:41:09 -0400 (EDT)
From: wency@cn.fujitsu.com
Subject: [PATCH v3 0/9] bugfix for memory hotplug
Date: Fri, 19 Oct 2012 14:46:33 +0800
Message-Id: <1350629202-9664-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, Wen Congyang <wency@cn.fujitsu.com>

From: Wen Congyang <wency@cn.fujitsu.com>

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
  clear the memory to store struct page
  memory-hotplug: skip HWPoisoned page when offlining pages
  memory-hotplug: update mce_bad_pages when removing the memory
  memory-hotplug: auto offline page_cgroup when onlining memory block
    failed
  memory-hotplug: fix NR_FREE_PAGES mismatch
  memory-hotplug: allocate zone's pcp before onlining pages

Yasuaki Ishimatsu (3):
  suppress "Device memoryX does not have a release() function" warning
  suppress "Device nodeX does not have a release() function" warning
  memory-hotplug: flush the work for the node when the node is offlined

 drivers/base/memory.c          |    9 ++++++++-
 drivers/base/node.c            |   11 +++++++++++
 include/linux/page-isolation.h |   10 ++++++----
 mm/memory-failure.c            |    2 +-
 mm/memory_hotplug.c            |   14 ++++++++------
 mm/page_alloc.c                |   37 ++++++++++++++++++++++++++++---------
 mm/page_cgroup.c               |    3 +++
 mm/page_isolation.c            |   27 ++++++++++++++++++++-------
 mm/sparse.c                    |   22 +++++++++++++++++++++-
 9 files changed, 106 insertions(+), 29 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
