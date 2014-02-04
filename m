Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id 833866B004D
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 12:09:41 -0500 (EST)
Received: by mail-qa0-f52.google.com with SMTP id j15so12814937qaq.11
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 09:09:41 -0800 (PST)
Received: from mail-qc0-x22a.google.com (mail-qc0-x22a.google.com [2607:f8b0:400d:c01::22a])
        by mx.google.com with ESMTPS id i33si18207736qgf.80.2014.02.04.09.09.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 09:09:41 -0800 (PST)
Received: by mail-qc0-f170.google.com with SMTP id e9so14158766qcy.15
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 09:09:41 -0800 (PST)
From: kosaki.motohiro@gmail.com
Subject: [PATCH] __set_page_dirty uses spin_lock_irqsave instead of spin_lock_irq
Date: Tue,  4 Feb 2014 12:09:36 -0500
Message-Id: <1391533776-2425-1-git-send-email-kosaki.motohiro@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, stable@vger.kernel.org

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

To use spin_{un}lock_irq is dangerous if caller disabled interrupt.
During aio buffer migration, we have a possibility to see the
following call stack.

aio_migratepage  [disable interrupt]
  migrate_page_copy
    clear_page_dirty_for_io
      set_page_dirty
        __set_page_dirty_buffers
          __set_page_dirty
            spin_lock_irq

This mean, current aio migration is a deadlockable. spin_lock_irqsave
is a safer alternative and we should use it.

Reported-by: David Rientjes rientjes@google.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: stable@vger.kernel.org
---
 fs/buffer.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 651dba1..27265a8 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -654,14 +654,16 @@ EXPORT_SYMBOL(mark_buffer_dirty_inode);
 static void __set_page_dirty(struct page *page,
 		struct address_space *mapping, int warn)
 {
-	spin_lock_irq(&mapping->tree_lock);
+	unsigned long flags;
+
+	spin_lock_irqsave(&mapping->tree_lock, flags);
 	if (page->mapping) {	/* Race with truncate? */
 		WARN_ON_ONCE(warn && !PageUptodate(page));
 		account_page_dirtied(page, mapping);
 		radix_tree_tag_set(&mapping->page_tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);
 	}
-	spin_unlock_irq(&mapping->tree_lock);
+	spin_unlock_irqrestore(&mapping->tree_lock, flags);
 	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
