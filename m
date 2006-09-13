Received: from smtp2.fc.hp.com (smtp.fc.hp.com [15.11.136.114])
	by atlrel7.hp.com (Postfix) with ESMTP id D6EBC36DAF
	for <linux-mm@kvack.org>; Wed, 13 Sep 2006 15:35:18 -0400 (EDT)
Received: from ldl.fc.hp.com (ldl.fc.hp.com [15.11.146.30])
	by smtp2.fc.hp.com (Postfix) with ESMTP id 7A77D718A3
	for <linux-mm@kvack.org>; Wed, 13 Sep 2006 19:35:18 +0000 (UTC)
Received: from localhost (ldl.lart [127.0.0.1])
	by ldl.fc.hp.com (Postfix) with ESMTP id 518A61344C7
	for <linux-mm@kvack.org>; Wed, 13 Sep 2006 13:35:18 -0600 (MDT)
Received: from ldl.fc.hp.com ([127.0.0.1])
	by localhost (ldl [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
	id 10961-07 for <linux-mm@kvack.org>;
	Wed, 13 Sep 2006 13:35:15 -0600 (MDT)
Received: from [16.116.117.0] (unknown [16.116.117.0])
	(using SSLv3 with cipher RC4-MD5 (128/128 bits))
	(No client certificate requested)
	by ldl.fc.hp.com (Postfix) with ESMTP id D75521344C5
	for <linux-mm@kvack.org>; Wed, 13 Sep 2006 13:35:14 -0600 (MDT)
Subject: [RFC] Don't set/test/wait-for radix tree tags if no capability
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Wed, 13 Sep 2006 15:35:14 -0400
Message-Id: <1158176114.5328.52.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

While debugging a problem [in the out-of-tree migration cache], I
noticed a lot of radix-tree tag activity for address spaces that have
the BDI_CAP_NO_{ACCT_DIRTY|WRITEBACK} capability flags set--effectively
disabling these capabilities--in their backing device.  Altho'
functionally benign, I believe that this unnecessary overhead.  Seeking
contrary opinions.

Would this patch, if correct, be worthwhile?  Seems not to cause any
problem, and does eliminate the tag handling for swap space and similar
address spaces.

---

page-writeback functions are setting/testing radix-tree tags for
mappings whose backing device has the corresponding "capabilities"
turned off via the BDI_CAP_NO_{ACCT_DIRTY|WRITEBACK} flags.

This patch makes all setting/getting/waiting-on the radix-tree
tags conditional on the corresponding mapping capability, 
eliminating a lot of unnecessary radix tree traversal--e.g.,
for swap cache.

Note:  perhaps all of the tags should be conditional on the 
'_WRITEBACK capability alone, because if the mapping doesn't
support writeback, there is no need to track dirty pages in the
cache, whether or not dirty page accounting is enabled.  However,
currently, all mappings that have one of the capability flags set
also have the other flag set.  Might not always be the case, tho.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/filemap.c        |    2 +-
 mm/page-writeback.c |   21 ++++++++++++---------
 2 files changed, 13 insertions(+), 10 deletions(-)

Index: linux-2.6.18-rc6-mm2/mm/page-writeback.c
===================================================================
--- linux-2.6.18-rc6-mm2.orig/mm/page-writeback.c	2006-09-13 11:46:50.000000000 -0400
+++ linux-2.6.18-rc6-mm2/mm/page-writeback.c	2006-09-13 14:44:57.000000000 -0400
@@ -766,11 +766,13 @@ int __set_page_dirty_nobuffers(struct pa
 			mapping2 = page_mapping(page);
 			if (mapping2) { /* Race with truncate? */
 				BUG_ON(mapping2 != mapping);
-				if (mapping_cap_account_dirty(mapping))
+				if (mapping_cap_account_dirty(mapping)) {
 					__inc_zone_page_state(page,
 								NR_FILE_DIRTY);
-				radix_tree_tag_set(&mapping->page_tree,
-					page_index(page), PAGECACHE_TAG_DIRTY);
+					radix_tree_tag_set(&mapping->page_tree,
+							page_index(page),
+							PAGECACHE_TAG_DIRTY);
+				}
 			}
 			write_unlock_irq(&mapping->tree_lock);
 			if (mapping->host) {
@@ -855,9 +857,10 @@ int test_clear_page_dirty(struct page *p
 	if (mapping) {
 		write_lock_irqsave(&mapping->tree_lock, flags);
 		if (TestClearPageDirty(page)) {
-			radix_tree_tag_clear(&mapping->page_tree,
-						page_index(page),
-						PAGECACHE_TAG_DIRTY);
+			if (mapping_cap_account_dirty(mapping))
+				radix_tree_tag_clear(&mapping->page_tree,
+							page_index(page),
+							PAGECACHE_TAG_DIRTY);
 			write_unlock_irqrestore(&mapping->tree_lock, flags);
 			/*
 			 * We can continue to use `mapping' here because the
@@ -919,7 +922,7 @@ int test_clear_page_writeback(struct pag
 
 		write_lock_irqsave(&mapping->tree_lock, flags);
 		ret = TestClearPageWriteback(page);
-		if (ret)
+		if (ret && mapping_cap_writeback_dirty(mapping))
 			radix_tree_tag_clear(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_WRITEBACK);
@@ -940,11 +943,11 @@ int test_set_page_writeback(struct page 
 
 		write_lock_irqsave(&mapping->tree_lock, flags);
 		ret = TestSetPageWriteback(page);
-		if (!ret)
+		if (!ret && mapping_cap_writeback_dirty(mapping))
 			radix_tree_tag_set(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_WRITEBACK);
-		if (!PageDirty(page))
+		if (!PageDirty(page) && mapping_cap_account_dirty(mapping))
 			radix_tree_tag_clear(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_DIRTY);
Index: linux-2.6.18-rc6-mm2/mm/filemap.c
===================================================================
--- linux-2.6.18-rc6-mm2.orig/mm/filemap.c	2006-09-13 14:44:44.000000000 -0400
+++ linux-2.6.18-rc6-mm2/mm/filemap.c	2006-09-13 14:44:57.000000000 -0400
@@ -258,7 +258,7 @@ int wait_on_page_writeback_range(struct 
 	int ret = 0;
 	pgoff_t index;
 
-	if (end < start)
+	if (end < start || !mapping_cap_writeback_dirty(mapping))
 		return 0;
 
 	pagevec_init(&pvec, 0);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
