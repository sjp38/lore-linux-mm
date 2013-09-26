Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id C8AF26B0038
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 10:16:26 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kp14so1361075pab.6
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 07:16:26 -0700 (PDT)
Received: by mail-pb0-f53.google.com with SMTP id up15so1183949pbc.26
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 07:16:24 -0700 (PDT)
Message-Id: <20130926141614.283085918@kernel.org>
Date: Thu, 26 Sep 2013 22:14:31 +0800
From: Shaohua Li <shli@kernel.org>
Subject: [RFC 3/4] cleancache: invalidate cache at dirty page
References: <20130926141428.392345308@kernel.org>
Content-Disposition: inline; filename=cleancache-invalidate-cache-dirty-page.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: sjenning@linux.vnet.ibm.com, bob.liu@oracle.com, dan.magenheimer@oracle.com

Previously if a get_page is called we must invalidate cache of the page in
cleancache backend, because at next put_page we don't know if the page's
content is changed. If we know whether the page content is changed, we don't
need always invalidate cache in get_page of cleancache backend, which could
save a lot of IO if we do put_page/get_page later. The detection can be done at
page dirty, where the page content is changed. If we dirty a page, we
invalidate the page's cache in cleancache backend, get_page doesn't need do
invalidation any more. Of course, it's ok if get_page insists doing
invalidation.

Signed-off-by: Shaohua Li <shli@kernel.org>
---
 fs/buffer.c         |    2 ++
 mm/page-writeback.c |    3 +++
 2 files changed, 5 insertions(+)

Index: linux/fs/buffer.c
===================================================================
--- linux.orig/fs/buffer.c	2013-09-26 21:25:03.671450043 +0800
+++ linux/fs/buffer.c	2013-09-26 21:25:03.663449708 +0800
@@ -40,6 +40,7 @@
 #include <linux/cpu.h>
 #include <linux/bitops.h>
 #include <linux/mpage.h>
+#include <linux/cleancache.h>
 #include <linux/bit_spinlock.h>
 #include <trace/events/block.h>
 
@@ -661,6 +662,7 @@ static void __set_page_dirty(struct page
 		radix_tree_tag_set(&mapping->page_tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);
 	}
+	cleancache_invalidate_page(mapping, page);
 	spin_unlock_irq(&mapping->tree_lock);
 	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
 }
Index: linux/mm/page-writeback.c
===================================================================
--- linux.orig/mm/page-writeback.c	2013-09-26 21:25:03.671450043 +0800
+++ linux/mm/page-writeback.c	2013-09-26 21:25:03.667449885 +0800
@@ -37,6 +37,7 @@
 #include <linux/timer.h>
 #include <linux/sched/rt.h>
 #include <linux/mm_inline.h>
+#include <linux/cleancache.h>
 #include <trace/events/writeback.h>
 
 #include "internal.h"
@@ -2191,6 +2192,8 @@ int __set_page_dirty_nobuffers(struct pa
 			radix_tree_tag_set(&mapping->page_tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);
 		}
+		if (mapping->host)
+			cleancache_invalidate_page(mapping, page);
 		spin_unlock_irq(&mapping->tree_lock);
 		if (mapping->host) {
 			/* !PageAnon && !swapper_space */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
