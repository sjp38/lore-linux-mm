Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7E33B6B035A
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 01:16:57 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id n9-v6so6602837pfg.12
        for <linux-mm@kvack.org>; Sun, 28 Oct 2018 22:16:57 -0700 (PDT)
Received: from mailgw02.mediatek.com ([210.61.82.184])
        by mx.google.com with ESMTPS id u10-v6si19932553pgg.180.2018.10.28.22.16.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Oct 2018 22:16:56 -0700 (PDT)
From: <miles.chen@mediatek.com>
Subject: [PATCH v3] mm/page_owner: use kvmalloc instead of kmalloc
Date: Mon, 29 Oct 2018 13:16:16 +0800
Message-ID: <1540790176-32339-1-git-send-email-miles.chen@mediatek.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Joe Perches <joe@perches.com>, Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mediatek@lists.infradead.org, wsd_upstream@mediatek.com, Miles Chen <miles.chen@mediatek.com>, Michal
 Hocko <mhocko@kernel.org>

From: Miles Chen <miles.chen@mediatek.com>

The kbuf used by page owner is allocated by kmalloc(), which means it
can use only normal memory and there might be a "out of memory"
issue when we're out of normal memory.

To solve this problem, use kvmalloc() to allocate kbuf
from normal/highmem. But there is one problem here: kvmalloc()
does not fallback to vmalloc for sub page allocations. So sub
page allocation fails due to out of normal memory cannot fallback
to vmalloc.

Modify kvmalloc() to allow sub page allocations fallback to
vmalloc when CONFIG_HIGHMEM=y and use kvmalloc() to allocate
kbuf.

Clamp buffer size to PAGE_SIZE to avoid arbitrary size allocation.

Change since v2:
  - improve kvmalloc, allow sub page allocations fallback to
    vmalloc when CONFIG_HIGHMEM=y

Change since v1:
  - use kvmalloc()
  - clamp buffer size to PAGE_SIZE

Signed-off-by: Miles Chen <miles.chen@mediatek.com>
Cc: Joe Perches <joe@perches.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>
---
 mm/page_owner.c | 8 ++++----
 mm/util.c       | 6 +++---
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/page_owner.c b/mm/page_owner.c
index d80adfe702d3..a064cd046361 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -1,7 +1,6 @@
 // SPDX-License-Identifier: GPL-2.0
 #include <linux/debugfs.h>
 #include <linux/mm.h>
-#include <linux/slab.h>
 #include <linux/uaccess.h>
 #include <linux/bootmem.h>
 #include <linux/stacktrace.h>
@@ -351,7 +350,8 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
 		.skip = 0
 	};
 
-	kbuf = kmalloc(count, GFP_KERNEL);
+	count = count > PAGE_SIZE ? PAGE_SIZE : count;
+	kbuf = kvmalloc(count, GFP_KERNEL);
 	if (!kbuf)
 		return -ENOMEM;
 
@@ -397,11 +397,11 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
 	if (copy_to_user(buf, kbuf, ret))
 		ret = -EFAULT;
 
-	kfree(kbuf);
+	kvfree(kbuf);
 	return ret;
 
 err:
-	kfree(kbuf);
+	kvfree(kbuf);
 	return -ENOMEM;
 }
 
diff --git a/mm/util.c b/mm/util.c
index 8bf08b5b5760..7b1c59b9bfbf 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -416,10 +416,10 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
 	ret = kmalloc_node(size, kmalloc_flags, node);
 
 	/*
-	 * It doesn't really make sense to fallback to vmalloc for sub page
-	 * requests
+	 * It only makes sense to fallback to vmalloc for sub page
+	 * requests if we might be able to allocate highmem pages.
 	 */
-	if (ret || size <= PAGE_SIZE)
+	if (ret || (!IS_ENABLED(CONFIG_HIGHMEM) && size <= PAGE_SIZE))
 		return ret;
 
 	return __vmalloc_node_flags_caller(size, node, flags,
-- 
2.18.0
