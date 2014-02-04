Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id 280096B0035
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 11:59:02 -0500 (EST)
Received: by mail-qc0-f181.google.com with SMTP id e9so14143677qcy.12
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 08:59:01 -0800 (PST)
Received: from mail-qc0-x22f.google.com (mail-qc0-x22f.google.com [2607:f8b0:400d:c01::22f])
        by mx.google.com with ESMTPS id o46si18154497qgo.158.2014.02.04.08.59.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 08:59:01 -0800 (PST)
Received: by mail-qc0-f175.google.com with SMTP id x13so13829331qcv.20
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 08:59:01 -0800 (PST)
From: kosaki.motohiro@gmail.com
Subject: [PATCH] __set_page_dirty uses spin_lock_irqsave instead of spin_lock_irq
Date: Tue,  4 Feb 2014 11:58:54 -0500
Message-Id: <1391533134-2234-1-git-send-email-kosaki.motohiro@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

To use spin_{un}lock_irq is dangerous if caller disabled interrupt.
spin_lock_irqsave is a safer alternative. Luckily, now there is no
caller that has such usage but it would be nice to fix.

Reported-by: David Rientjes rientjes@google.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
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
