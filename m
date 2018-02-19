Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B69C16B029D
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 14:46:27 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id m22so3695852pfg.15
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 11:46:27 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a14-v6si458239pls.623.2018.02.19.11.46.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 19 Feb 2018 11:46:26 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v7 43/61] pagevec: Use xa_tag_t
Date: Mon, 19 Feb 2018 11:45:38 -0800
Message-Id: <20180219194556.6575-44-willy@infradead.org>
In-Reply-To: <20180219194556.6575-1-willy@infradead.org>
References: <20180219194556.6575-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

Removes sparse warnings.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/btrfs/extent_io.c    | 4 ++--
 fs/ext4/inode.c         | 2 +-
 fs/f2fs/data.c          | 2 +-
 fs/gfs2/aops.c          | 2 +-
 include/linux/pagevec.h | 8 +++++---
 mm/swap.c               | 4 ++--
 6 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index 1f2739702518..54cef60dd79b 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -3789,7 +3789,7 @@ int btree_write_cache_pages(struct address_space *mapping,
 	pgoff_t index;
 	pgoff_t end;		/* Inclusive */
 	int scanned = 0;
-	int tag;
+	xa_tag_t tag;
 
 	pagevec_init(&pvec);
 	if (wbc->range_cyclic) {
@@ -3914,7 +3914,7 @@ static int extent_write_cache_pages(struct address_space *mapping,
 	pgoff_t done_index;
 	int range_whole = 0;
 	int scanned = 0;
-	int tag;
+	xa_tag_t tag;
 
 	/*
 	 * We have to hold onto the inode so that ordered extents can do their
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index c94780075b04..40000331fe5b 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -2615,7 +2615,7 @@ static int mpage_prepare_extent_to_map(struct mpage_da_data *mpd)
 	long left = mpd->wbc->nr_to_write;
 	pgoff_t index = mpd->first_page;
 	pgoff_t end = mpd->last_page;
-	int tag;
+	xa_tag_t tag;
 	int i, err = 0;
 	int blkbits = mpd->inode->i_blkbits;
 	ext4_lblk_t lblk;
diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index 4eee39befc67..ce029060acd0 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -1848,7 +1848,7 @@ static int f2fs_write_cache_pages(struct address_space *mapping,
 	pgoff_t last_idx = ULONG_MAX;
 	int cycled;
 	int range_whole = 0;
-	int tag;
+	xa_tag_t tag;
 
 	pagevec_init(&pvec);
 
diff --git a/fs/gfs2/aops.c b/fs/gfs2/aops.c
index 2f725b4a386b..e85ed63b87d6 100644
--- a/fs/gfs2/aops.c
+++ b/fs/gfs2/aops.c
@@ -371,7 +371,7 @@ static int gfs2_write_cache_jdata(struct address_space *mapping,
 	pgoff_t done_index;
 	int cycled;
 	int range_whole = 0;
-	int tag;
+	xa_tag_t tag;
 
 	pagevec_init(&pvec);
 	if (wbc->range_cyclic) {
diff --git a/include/linux/pagevec.h b/include/linux/pagevec.h
index 6dc456ac6136..955bd6425903 100644
--- a/include/linux/pagevec.h
+++ b/include/linux/pagevec.h
@@ -9,6 +9,8 @@
 #ifndef _LINUX_PAGEVEC_H
 #define _LINUX_PAGEVEC_H
 
+#include <linux/xarray.h>
+
 /* 15 pointers + header align the pagevec structure to a power of two */
 #define PAGEVEC_SIZE	15
 
@@ -40,12 +42,12 @@ static inline unsigned pagevec_lookup(struct pagevec *pvec,
 
 unsigned pagevec_lookup_range_tag(struct pagevec *pvec,
 		struct address_space *mapping, pgoff_t *index, pgoff_t end,
-		int tag);
+		xa_tag_t tag);
 unsigned pagevec_lookup_range_nr_tag(struct pagevec *pvec,
 		struct address_space *mapping, pgoff_t *index, pgoff_t end,
-		int tag, unsigned max_pages);
+		xa_tag_t tag, unsigned max_pages);
 static inline unsigned pagevec_lookup_tag(struct pagevec *pvec,
-		struct address_space *mapping, pgoff_t *index, int tag)
+		struct address_space *mapping, pgoff_t *index, xa_tag_t tag)
 {
 	return pagevec_lookup_range_tag(pvec, mapping, index, (pgoff_t)-1, tag);
 }
diff --git a/mm/swap.c b/mm/swap.c
index f62c5c7198f2..10c94ff9e542 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -990,7 +990,7 @@ EXPORT_SYMBOL(pagevec_lookup_range);
 
 unsigned pagevec_lookup_range_tag(struct pagevec *pvec,
 		struct address_space *mapping, pgoff_t *index, pgoff_t end,
-		int tag)
+		xa_tag_t tag)
 {
 	pvec->nr = find_get_pages_range_tag(mapping, index, end, tag,
 					PAGEVEC_SIZE, pvec->pages);
@@ -1000,7 +1000,7 @@ EXPORT_SYMBOL(pagevec_lookup_range_tag);
 
 unsigned pagevec_lookup_range_nr_tag(struct pagevec *pvec,
 		struct address_space *mapping, pgoff_t *index, pgoff_t end,
-		int tag, unsigned max_pages)
+		xa_tag_t tag, unsigned max_pages)
 {
 	pvec->nr = find_get_pages_range_tag(mapping, index, end, tag,
 		min_t(unsigned int, max_pages, PAGEVEC_SIZE), pvec->pages);
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
