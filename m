Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B34426B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 21:09:24 -0500 (EST)
Received: from rcsinet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by rcsinet10.oracle.com (Switch-3.4.2/Switch-3.4.2) with ESMTP id oAJ29LQI004024
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 02:09:22 GMT
From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH] mm: Use spin_lock_irqsave in __set_page_dirty_nobuffers
Date: Thu, 18 Nov 2010 18:08:47 -0800
Message-Id: <1290132527-14495-1-git-send-email-andy.grover@oracle.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: rds-devel@oss.oracle.com, Andy Grover <andy.grover@oracle.com>
List-ID: <linux-mm.kvack.org>

RDS is calling set_page_dirty from interrupt context, which
ends up calling this function. Using irqsave ensures irqs
are not re-enabled by this function.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 mm/page-writeback.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index b840afa..c6c381b 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1155,11 +1155,12 @@ int __set_page_dirty_nobuffers(struct page *page)
 	if (!TestSetPageDirty(page)) {
 		struct address_space *mapping = page_mapping(page);
 		struct address_space *mapping2;
+		unsigned long flags;
 
 		if (!mapping)
 			return 1;
 
-		spin_lock_irq(&mapping->tree_lock);
+		spin_lock_irqsave(&mapping->tree_lock, flags);
 		mapping2 = page_mapping(page);
 		if (mapping2) { /* Race with truncate? */
 			BUG_ON(mapping2 != mapping);
@@ -1168,7 +1169,7 @@ int __set_page_dirty_nobuffers(struct page *page)
 			radix_tree_tag_set(&mapping->page_tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);
 		}
-		spin_unlock_irq(&mapping->tree_lock);
+		spin_unlock_irqrestore(&mapping->tree_lock, flags);
 		if (mapping->host) {
 			/* !PageAnon && !swapper_space */
 			__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
