Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0673B6B0253
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 08:17:09 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id j82so400731194oih.6
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 05:17:09 -0800 (PST)
Received: from smtpbg.qq.com (SMTPBG353.QQ.COM. [183.57.50.164])
        by mx.google.com with ESMTPS id s8si6809329otb.189.2017.01.31.05.17.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 Jan 2017 05:17:08 -0800 (PST)
From: ysxie@foxmail.com
Subject: [PATCH v5 0/4] HWPOISON: soft offlining for non-lru movable page
Date: Tue, 31 Jan 2017 21:06:17 +0800
Message-Id: <1485867981-16037-1-git-send-email-ysxie@foxmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: n-horiguchi@ah.jp.nec.com, mhocko@suse.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, izumi.taku@jp.fujitsu.com, arbab@linux.vnet.ibm.com, vkuznets@redhat.com, ak@linux.intel.com, guohanjun@huawei.com, qiuxishi@huawei.com

From: Yisheng Xie <xieyisheng1@huawei.com>

Hi Andrew,
Could you please help to abandon the v3 of this patch for it will compile
error with CONFIG_MIGRATION=n, and it also has error path handling problem.
I am so sorry about troubling you.

Hi Michal, Minchan and all,
Could you please help to review it?

Any suggestion is more than welcome. And Thanks for all of you.

After Minchan's commit bda807d44454 ("mm: migrate: support non-lru movable
page migration"), some type of non-lru page like zsmalloc and virtio-balloon
page also support migration.

Therefore, we can:
1) soft offlining no-lru movable pages, which means when memory corrected
errors occur on a non-lru movable page, we can stop to use it by migrating
data onto another page and disable the original (maybe half-broken) one.

2) enable memory hotplug for non-lru movable pages, i.e. we may offline
blocks, which include such pages, by using non-lru page migration.

This patchset is heavily depend on non-lru movable page migration.
--------
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
 mm/migrate.c            | 11 +++++++----
 mm/page_alloc.c         |  8 ++++++--
 6 files changed, 50 insertions(+), 29 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
