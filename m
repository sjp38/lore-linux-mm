Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 304A06B0032
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 10:52:42 -0500 (EST)
Received: by mail-la0-f46.google.com with SMTP id ge10so4549583lab.5
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 07:52:41 -0800 (PST)
Received: from forward-corp1f.mail.yandex.net (forward-corp1f.mail.yandex.net. [2a02:6b8:0:801::10])
        by mx.google.com with ESMTPS id w2si1766309laz.109.2015.01.15.07.52.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jan 2015 07:52:40 -0800 (PST)
Subject: [PATCH] page_writeback: put account_page_redirty() after
 set_page_dirty()
From: Konstantin Khebnikov <khlebnikov@yandex-team.ru>
Date: Thu, 15 Jan 2015 18:52:38 +0300
Message-ID: <20150115155238.31251.41331.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: koct9i@gmail.com

Helper account_page_redirty() fixes dirty pages counter for redirtied pages.
This patch puts it after dirtying and prevents temporary underflows of
dirtied pages counters on zone/bdi and current->nr_dirtied.

Signed-off-by: Konstantin Khebnikov <khlebnikov@yandex-team.ru>
---
 fs/btrfs/extent_io.c |    2 +-
 mm/page-writeback.c  |    5 ++++-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index 4ebabd2..281bc7e 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -1407,8 +1407,8 @@ int extent_range_redirty_for_io(struct inode *inode, u64 start, u64 end)
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
index 6f43352..4da3cd5 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2168,9 +2168,12 @@ EXPORT_SYMBOL(account_page_redirty);
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
