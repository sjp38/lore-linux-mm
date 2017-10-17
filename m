Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id B8DB96B0266
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 12:21:35 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id m55so1059667wrf.6
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 09:21:35 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m28si1926468wmc.149.2017.10.17.09.21.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Oct 2017 09:21:34 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 1/7] mm: Speedup cancel_dirty_page() for clean pages
Date: Tue, 17 Oct 2017 18:21:14 +0200
Message-Id: <20171017162120.30990-2-jack@suse.cz>
In-Reply-To: <20171017162120.30990-1-jack@suse.cz>
References: <20171017162120.30990-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>

cancel_dirty_page() does quite some work even for clean pages (fetching
of mapping, locking of memcg, atomic bit op on page flags) so it
accounts for ~2.5% of cost of truncation of a clean page. That is not
much but still dumb for something we don't need at all. Check whether
a page is actually dirty and avoid any work if not.

Acked-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Andi Kleen <ak@linux.intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/mm.h  | 8 +++++++-
 mm/page-writeback.c | 4 ++--
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 065d99deb847..d14a9bb2a3d7 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1430,7 +1430,13 @@ void account_page_cleaned(struct page *page, struct address_space *mapping,
 			  struct bdi_writeback *wb);
 int set_page_dirty(struct page *page);
 int set_page_dirty_lock(struct page *page);
-void cancel_dirty_page(struct page *page);
+void __cancel_dirty_page(struct page *page);
+static inline void cancel_dirty_page(struct page *page)
+{
+	/* Avoid atomic ops, locking, etc. when not actually needed. */
+	if (PageDirty(page))
+		__cancel_dirty_page(page);
+}
 int clear_page_dirty_for_io(struct page *page);
 
 int get_cmdline(struct task_struct *task, char *buffer, int buflen);
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 0b9c5cbe8eba..c3bed3f5cd24 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2623,7 +2623,7 @@ EXPORT_SYMBOL(set_page_dirty_lock);
  * page without actually doing it through the VM. Can you say "ext3 is
  * horribly ugly"? Thought you could.
  */
-void cancel_dirty_page(struct page *page)
+void __cancel_dirty_page(struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
 
@@ -2644,7 +2644,7 @@ void cancel_dirty_page(struct page *page)
 		ClearPageDirty(page);
 	}
 }
-EXPORT_SYMBOL(cancel_dirty_page);
+EXPORT_SYMBOL(__cancel_dirty_page);
 
 /*
  * Clear a page's dirty flag, while caring for dirty memory accounting.
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
