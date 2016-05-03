Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7789A6B0005
	for <linux-mm@kvack.org>; Tue,  3 May 2016 01:23:06 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b203so18986597pfb.1
        for <linux-mm@kvack.org>; Mon, 02 May 2016 22:23:06 -0700 (PDT)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id x66si2286437pfx.231.2016.05.02.22.23.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 22:23:05 -0700 (PDT)
Received: by mail-pf0-x22b.google.com with SMTP id y69so5061255pfb.1
        for <linux-mm@kvack.org>; Mon, 02 May 2016 22:23:05 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 0/6] mm/page_owner: use tackdepot to store stacktrace
Date: Tue,  3 May 2016 14:22:58 +0900
Message-Id: <1462252984-8524-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

This patchset changes a way to store stacktrace in page_owner in order to
reduce memory usage. Below is motivation of this patchset coped
from the patch 6.

Currently, we store each page's allocation stacktrace on corresponding
page_ext structure and it requires a lot of memory. This causes the problem
that memory tight system doesn't work well if page_owner is enabled.
Moreover, even with this large memory consumption, we cannot get full
stacktrace because we allocate memory at boot time and just maintain
8 stacktrace slots to balance memory consumption. We could increase it
to more but it would make system unusable or change system behaviour.

To solve the problem, this patch uses stackdepot to store stacktrace.

Thanks.

Joonsoo Kim (6):
  mm/compaction: split freepages without holding the zone lock
  mm/page_owner: initialize page owner without holding the zone lock
  mm/page_owner: copy last_migrate_reason in copy_page_owner()
  mm/page_owner: introduce split_page_owner and replace manual handling
  tools/vm/page_owner: increase temporary buffer size
  mm/page_owner: use stackdepot to store stacktrace

 include/linux/mm.h         |   1 -
 include/linux/page_ext.h   |   4 +-
 include/linux/page_owner.h |  12 ++--
 lib/Kconfig.debug          |   1 +
 mm/compaction.c            |  45 +++++++++++----
 mm/page_alloc.c            |  37 +-----------
 mm/page_isolation.c        |   9 ++-
 mm/page_owner.c            | 136 ++++++++++++++++++++++++++++++++++++++-------
 tools/vm/page_owner_sort.c |   9 ++-
 9 files changed, 173 insertions(+), 81 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
