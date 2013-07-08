Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id CD67E6B005A
	for <linux-mm@kvack.org>; Mon,  8 Jul 2013 05:52:21 -0400 (EDT)
Received: by mail-lb0-f171.google.com with SMTP id 13so3511823lba.2
        for <linux-mm@kvack.org>; Mon, 08 Jul 2013 02:52:20 -0700 (PDT)
Subject: [PATCH 5/5] page_writeback: put account_page_redirty() after
 set_page_dirty()
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 08 Jul 2013 13:52:17 +0400
Message-ID: <20130708095217.13810.22999.stgit@zurg>
In-Reply-To: <20130708095202.13810.11659.stgit@zurg>
References: <20130708095202.13810.11659.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org

Function account_page_redirty() fixes dirty pages counter for redieried pages.
This patch prevents temporary underflows of dirty pages counters on zone/bdi
and current->nr_dirtied. This puts decrement after increment.

__set_page_dirty_nobuffers() in redirty_page_for_writeback() always returns true
because this page is locked and all ptes are write-protected by previously
called clear_page_dirty_for_io(). Thus nobody can mark it dirty except current
task. This prevents multy-threaded scenarios of taks->nr_dirtied underflows.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 fs/btrfs/extent_io.c |    2 +-
 mm/page-writeback.c  |    7 ++++++-
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index 6bca947..d17fb9b 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -1311,8 +1311,8 @@ int extent_range_redirty_for_io(struct inode *inode, u64 start, u64 end)
 	while (index <= end_index) {
 		page = find_get_page(inode->i_mapping, index);
 		BUG_ON(!page); /* Pages should be in the extent_io_tree */
-		account_page_redirty(page);
 		__set_page_dirty_nobuffers(page);
+		account_page_redirty(page);
 		page_cache_release(page);
 		index++;
 	}
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 4514ad7..a599f38 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2061,6 +2061,8 @@ EXPORT_SYMBOL(__set_page_dirty_nobuffers);
  * counters (NR_WRITTEN, BDI_WRITTEN) in long term. The mismatches will lead to
  * systematic errors in balanced_dirty_ratelimit and the dirty pages position
  * control.
+ *
+ * Must be called after marking page dirty.
  */
 void account_page_redirty(struct page *page)
 {
@@ -2080,9 +2082,12 @@ EXPORT_SYMBOL(account_page_redirty);
  */
 int redirty_page_for_writepage(struct writeback_control *wbc, struct page *page)
 {
+	int ret;
+
 	wbc->pages_skipped++;
+	ret = __set_page_dirty_nobuffers(page);
 	account_page_redirty(page);
-	return __set_page_dirty_nobuffers(page);
+	return ret;
 }
 EXPORT_SYMBOL(redirty_page_for_writepage);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
