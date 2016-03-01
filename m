Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 265586B0255
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 16:44:57 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id bj10so50278989pad.2
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 13:44:57 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id 184si52945552pfa.13.2016.03.01.13.44.56
        for <linux-mm@kvack.org>;
        Tue, 01 Mar 2016 13:44:56 -0800 (PST)
Subject: [PATCH] list: kill list_force_poison()
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 01 Mar 2016 13:44:32 -0800
Message-ID: <20160301214432.4473.76919.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Eryu Guan <eguan@redhat.com>, xfs@oss.sgi.com

Given we have uninitialized list_heads being passed to list_add() it
will always be the case that those uninitialized values randomly trigger
the poison value.  Especially since a list_add() operation will seed the
stack with the poison value for later stack allocations to trip over.
For example, see these two false positive reports:

 list_add attempted on force-poisoned entry
 WARNING: at lib/list_debug.c:34
 [..]
 NIP [c00000000043c390] __list_add+0xb0/0x150
 LR [c00000000043c38c] __list_add+0xac/0x150
 Call Trace:
 [c000000fb5fc3320] [c00000000043c38c] __list_add+0xac/0x150 (unreliable)
 [c000000fb5fc33a0] [c00000000081b454] __down+0x4c/0xf8
 [c000000fb5fc3410] [c00000000010b6f8] down+0x68/0x70
 [c000000fb5fc3450] [d0000000201ebf4c] xfs_buf_lock+0x4c/0x150 [xfs]

 list_add attempted on force-poisoned entry(0000000000000500),
  new->next == d0000000059ecdb0, new->prev == 0000000000000500
 WARNING: at lib/list_debug.c:33
 [..]
 NIP [c00000000042db78] __list_add+0xa8/0x140
 LR [c00000000042db74] __list_add+0xa4/0x140
 Call Trace:
 [c0000004c749f620] [c00000000042db74] __list_add+0xa4/0x140 (unreliable)
 [c0000004c749f6b0] [c0000000008010ec] rwsem_down_read_failed+0x6c/0x1a0
 [c0000004c749f760] [c000000000800828] down_read+0x58/0x60
 [c0000004c749f7e0] [d000000005a1a6bc] xfs_log_commit_cil+0x7c/0x600 [xfs]

Reported-by: Eryu Guan <eguan@redhat.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: <xfs@oss.sgi.com>
Fixes: commit 5c2c2587b132 ("mm, dax, pmem: introduce {get|put}_dev_pagemap() for dax-gup")
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/list.h |   11 -----------
 kernel/memremap.c    |    9 +++++++--
 lib/list_debug.c     |    9 ---------
 3 files changed, 7 insertions(+), 22 deletions(-)

diff --git a/include/linux/list.h b/include/linux/list.h
index 30cf4200ab40..5356f4d661a7 100644
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -113,17 +113,6 @@ extern void __list_del_entry(struct list_head *entry);
 extern void list_del(struct list_head *entry);
 #endif
 
-#ifdef CONFIG_DEBUG_LIST
-/*
- * See devm_memremap_pages() which wants DEBUG_LIST=y to assert if one
- * of the pages it allocates is ever passed to list_add()
- */
-extern void list_force_poison(struct list_head *entry);
-#else
-/* fallback to the less strict LIST_POISON* definitions */
-#define list_force_poison list_del
-#endif
-
 /**
  * list_replace - replace old entry by new one
  * @old : the element to be replaced
diff --git a/kernel/memremap.c b/kernel/memremap.c
index b981a7b023f0..778191e3e887 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -351,8 +351,13 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	for_each_device_pfn(pfn, page_map) {
 		struct page *page = pfn_to_page(pfn);
 
-		/* ZONE_DEVICE pages must never appear on a slab lru */
-		list_force_poison(&page->lru);
+		/*
+		 * ZONE_DEVICE pages union ->lru with a ->pgmap back
+		 * pointer.  It is a bug if a ZONE_DEVICE page is ever
+		 * freed or placed on a driver-private list.  Seed the
+		 * storage with LIST_POISON* values.
+		 */
+		list_del(&page->lru);
 		page->pgmap = pgmap;
 	}
 	devres_add(dev, page_map);
diff --git a/lib/list_debug.c b/lib/list_debug.c
index 3345a089ef7b..3859bf63561c 100644
--- a/lib/list_debug.c
+++ b/lib/list_debug.c
@@ -12,13 +12,6 @@
 #include <linux/kernel.h>
 #include <linux/rculist.h>
 
-static struct list_head force_poison;
-void list_force_poison(struct list_head *entry)
-{
-	entry->next = &force_poison;
-	entry->prev = &force_poison;
-}
-
 /*
  * Insert a new entry between two known consecutive entries.
  *
@@ -30,8 +23,6 @@ void __list_add(struct list_head *new,
 			      struct list_head *prev,
 			      struct list_head *next)
 {
-	WARN(new->next == &force_poison || new->prev == &force_poison,
-		"list_add attempted on force-poisoned entry\n");
 	WARN(next->prev != prev,
 		"list_add corruption. next->prev should be "
 		"prev (%p), but was %p. (next=%p).\n",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
