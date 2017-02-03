Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C270A6B0253
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 03:04:08 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id ez4so2796582wjd.2
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 00:04:08 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id j12si31667602wrb.75.2017.02.03.00.04.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Feb 2017 00:04:06 -0800 (PST)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [PATCH v6 0/4] HWPOISON: soft offlining for non-lru movable page
Date: Fri, 3 Feb 2017 15:59:26 +0800
Message-ID: <1486108770-630-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Cc: mhocko@kernel.org, minchan@kernel.org, ak@linux.intel.com, guohanjun@huawei.com, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, arbab@linux.vnet.ibm.com, izumi.taku@jp.fujitsu.com, vkuznets@redhat.com, vbabka@suse.cz, qiuxishi@huawei.com

Hi Michal, Minchan and all,
Could you please help to review it?

Any suggestion is more than welcome. And Thanks for all of you.

After Minchan's commit bda807d44454 ("mm: migrate: support non-lru movable
page migration"), some type of non-lru page like zsmalloc and
virtio-balloon page also support migration.

Therefore, we can:

1) soft offlining no-lru movable pages, which means when memory
   corrected errors occur on a non-lru movable page, we can stop to use it
   by migrating data onto another page and disable the original (maybe
   half-broken) one.

2) enable memory hotplug for non-lru movable pages, i.e.  we may
   offline blocks, which include such pages, by using non-lru page
   migration.

This patchset is heavily dependent on non-lru movable page migration.
--------
v6:
 * just return -EBUSY for isolate_movable_page when it failed to isolate
   a non-lru movable page, which suggested by Minchan.

v5:
 * change the return type of isolate_movable_page() from bool to int as
   Michal's suggestion.
 * add "enable memory hotplug for non-lru movable pages" to this patchset,
   which also make some change as Michal's suggestion here.

v4:
 * make isolate_movable_page always defined to avoid compile error with
   CONFIG_MIGRATION = n
 * return -EBUSY when isolate_movable_page return false which means failed
   to isolate movable page.

v3:
  * delete some unneed limitation and use !__PageMovable instead of PageLRU
    after isolate page to avoid isolated count mismatch, as Minchan Kim's suggestion.

v2:
 * delete function soft_offline_movable_page() and hanle non-lru movable
   page in __soft_offline_page() as Michal Hocko suggested.

Yisheng Xie (4):
  mm/migration: make isolate_movable_page() return int type
  mm/migration: make isolate_movable_page always defined
  HWPOISON: soft offlining for non-lru movable page
  mm/hotplug: enable memory hotplug for non-lru movable pages

 include/linux/migrate.h |  4 +++-
 mm/compaction.c         |  2 +-
 mm/memory-failure.c     | 26 ++++++++++++++++----------
 mm/memory_hotplug.c     | 28 +++++++++++++++++-----------
 mm/migrate.c            |  6 +++---
 mm/page_alloc.c         |  8 ++++++--
 6 files changed, 46 insertions(+), 28 deletions(-)

-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
