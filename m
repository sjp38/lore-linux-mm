Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 96FF96B0036
	for <linux-mm@kvack.org>; Wed, 14 May 2014 11:22:12 -0400 (EDT)
Received: by mail-wg0-f51.google.com with SMTP id x13so2100775wgg.10
        for <linux-mm@kvack.org>; Wed, 14 May 2014 08:22:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id ca11si910067wib.94.2014.05.14.08.22.09
        for <linux-mm@kvack.org>;
        Wed, 14 May 2014 08:22:10 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] mm/memory-failure.c: fix memory leak by race between poison and unpoison
Date: Wed, 14 May 2014 11:21:31 -0400
Message-Id: <1400080891-5145-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

When a memory error happens on an in-use page or (free and in-use) hugepage,
the victim page is isolated with its refcount set to one. When you try to
unpoison it later, unpoison_memory() calls put_page() for it twice in order to
bring the page back to free page pool (buddy or free hugepage list.)
However, if another memory error occurs on the page which we are unpoisoning,
memory_failure() returns without releasing the refcount which was incremented
in the same call at first, which results in memory leak and unconsistent
num_poisoned_pages statistics. This patch fixes it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: <stable@vger.kernel.org>    [2.6.32+]
---
 mm/memory-failure.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git next-20140512.orig/mm/memory-failure.c next-20140512/mm/memory-failure.c
index 9872af1b1e9d..93a08bd78c78 100644
--- next-20140512.orig/mm/memory-failure.c
+++ next-20140512/mm/memory-failure.c
@@ -1153,6 +1153,8 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 	 */
 	if (!PageHWPoison(p)) {
 		printk(KERN_ERR "MCE %#lx: just unpoisoned\n", pfn);
+		atomic_long_sub(nr_pages, &num_poisoned_pages);
+		put_page(hpage);
 		res = 0;
 		goto out;
 	}
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
