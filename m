Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5066A6B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 10:05:50 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id v85so247809972oia.4
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 07:05:50 -0800 (PST)
Received: from smtpbg202.qq.com (smtpbg202.qq.com. [184.105.206.29])
        by mx.google.com with ESMTPS id u129si9056537oia.40.2017.01.25.07.05.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 07:05:49 -0800 (PST)
From: ysxie@foxmail.com
Subject: [PATCH v4 0/2] HWPOISON: soft offlining for non-lru movable page
Date: Wed, 25 Jan 2017 23:05:36 +0800
Message-Id: <1485356738-4831-1-git-send-email-ysxie@foxmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: n-horiguchi@ah.jp.nec.com, mhocko@suse.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, guohanjun@huawei.com, qiuxishi@huawei.com

From: Yisheng Xie <xieyisheng1@huawei.com>

Hi Andrew,
Could you please help to abandon the v3 of this patch for it will compile
error with CONFIG_MIGRATION=n, and it also has error path handling problem.

Hi Michal, Minchan and all,
Could you please help to review it? 

Any suggestion is more than welcome.

The aim of this patchset is to support soft offlining of movable no-lru pages,
which already support migration after Minchan's commit bda807d44454 ("mm: migrate:
support non-lru movable page migration"). That means this patch heavily depend
on non-lru movable page migration.

So when memory corrected errors occur on a non-lru movable page, we can stop
to use it by migrating data onto another page and disable the original (maybe
half-broken) one.

--------
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

Yisheng Xie (2):
  mm/migration: make isolate_movable_page always defined
  HWPOISON: soft offlining for non-lru movable page

 include/linux/migrate.h |  2 ++
 mm/memory-failure.c     | 26 ++++++++++++++++----------
 2 files changed, 18 insertions(+), 10 deletions(-)

-- 
1.9.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
