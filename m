Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 534E66B0285
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 17:05:54 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id r6so16774183itr.1
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 14:05:54 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id d189si5775273itg.40.2017.12.15.14.05.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 14:05:53 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 52/78] btrfs: Convert page cache to XArray
Date: Fri, 15 Dec 2017 14:04:24 -0800
Message-Id: <20171215220450.7899-53-willy@infradead.org>
In-Reply-To: <20171215220450.7899-1-willy@infradead.org>
References: <20171215220450.7899-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Howells <dhowells@redhat.com>, Shaohua Li <shli@kernel.org>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-raid@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/btrfs/compression.c | 4 +---
 fs/btrfs/extent_io.c   | 6 ++----
 2 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/fs/btrfs/compression.c b/fs/btrfs/compression.c
index e687d06cd97c..4174b166e235 100644
--- a/fs/btrfs/compression.c
+++ b/fs/btrfs/compression.c
@@ -449,9 +449,7 @@ static noinline int add_ra_bio_pages(struct inode *inode,
 		if (pg_index > end_index)
 			break;
 
-		rcu_read_lock();
-		page = radix_tree_lookup(&mapping->pages, pg_index);
-		rcu_read_unlock();
+		page = xa_load(&mapping->pages, pg_index);
 		if (page && !xa_is_value(page)) {
 			misses++;
 			if (misses > 4)
diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index 4301cbf4e31f..fd5e9d887328 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -5197,11 +5197,9 @@ void clear_extent_buffer_dirty(struct extent_buffer *eb)
 
 		clear_page_dirty_for_io(page);
 		xa_lock_irq(&page->mapping->pages);
-		if (!PageDirty(page)) {
-			radix_tree_tag_clear(&page->mapping->pages,
-						page_index(page),
+		if (!PageDirty(page))
+			__xa_clear_tag(&page->mapping->pages, page_index(page),
 						PAGECACHE_TAG_DIRTY);
-		}
 		xa_unlock_irq(&page->mapping->pages);
 		ClearPageError(page);
 		unlock_page(page);
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
