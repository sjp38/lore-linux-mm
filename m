Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp2.linux-foundation.org (8.13.5.20060308/8.13.5/Debian-3ubuntu1.1) with ESMTP id l4I7dMHg004514
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Fri, 18 May 2007 00:40:00 -0700
Message-Id: <200705180737.l4I7bAMQ010778@shell0.pdx.osdl.net>
Subject: [patch 8/8] invalidate_mapping_pages(): add cond_resched
From: akpm@linux-foundation.org
Date: Fri, 18 May 2007 00:37:11 -0700
Sender: owner-linux-mm@kvack.org
From: Andrew Morton <akpm@linux-foundation.org>
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@linux-foundation.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

invalidate_mapping_pages() can sometimes take a long time (millions of pages
to free).  Long enough for the softlockup detector to trigger.

We used to have a cond_resched() in there but I took it out because the
drop_caches code calls invalidate_mapping_pages() under inode_lock.

The patch adds a nasty flag and puts the cond_resched() back.

Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/drop_caches.c   |    2 +-
 include/linux/fs.h |    3 +++
 mm/truncate.c      |   38 +++++++++++++++++++++++---------------
 3 files changed, 27 insertions(+), 16 deletions(-)

diff -puN fs/drop_caches.c~invalidate_mapping_pages-add-cond_resched fs/drop_caches.c
--- a/fs/drop_caches.c~invalidate_mapping_pages-add-cond_resched
+++ a/fs/drop_caches.c
@@ -20,7 +20,7 @@ static void drop_pagecache_sb(struct sup
 	list_for_each_entry(inode, &sb->s_inodes, i_sb_list) {
 		if (inode->i_state & (I_FREEING|I_WILL_FREE))
 			continue;
-		invalidate_mapping_pages(inode->i_mapping, 0, -1);
+		__invalidate_mapping_pages(inode->i_mapping, 0, -1, true);
 	}
 	spin_unlock(&inode_lock);
 }
diff -puN include/linux/fs.h~invalidate_mapping_pages-add-cond_resched include/linux/fs.h
--- a/include/linux/fs.h~invalidate_mapping_pages-add-cond_resched
+++ a/include/linux/fs.h
@@ -1583,6 +1583,9 @@ extern int __invalidate_device(struct bl
 extern int invalidate_partition(struct gendisk *, int);
 #endif
 extern int invalidate_inodes(struct super_block *);
+unsigned long __invalidate_mapping_pages(struct address_space *mapping,
+					pgoff_t start, pgoff_t end,
+					bool be_atomic);
 unsigned long invalidate_mapping_pages(struct address_space *mapping,
 					pgoff_t start, pgoff_t end);
 
diff -puN mm/truncate.c~invalidate_mapping_pages-add-cond_resched mm/truncate.c
--- a/mm/truncate.c~invalidate_mapping_pages-add-cond_resched
+++ a/mm/truncate.c
@@ -263,21 +263,8 @@ void truncate_inode_pages(struct address
 }
 EXPORT_SYMBOL(truncate_inode_pages);
 
-/**
- * invalidate_mapping_pages - Invalidate all the unlocked pages of one inode
- * @mapping: the address_space which holds the pages to invalidate
- * @start: the offset 'from' which to invalidate
- * @end: the offset 'to' which to invalidate (inclusive)
- *
- * This function only removes the unlocked pages, if you want to
- * remove all the pages of one inode, you must call truncate_inode_pages.
- *
- * invalidate_mapping_pages() will not block on IO activity. It will not
- * invalidate pages which are dirty, locked, under writeback or mapped into
- * pagetables.
- */
-unsigned long invalidate_mapping_pages(struct address_space *mapping,
-				pgoff_t start, pgoff_t end)
+unsigned long __invalidate_mapping_pages(struct address_space *mapping,
+				pgoff_t start, pgoff_t end, bool be_atomic)
 {
 	struct pagevec pvec;
 	pgoff_t next = start;
@@ -318,9 +305,30 @@ unlock:
 				break;
 		}
 		pagevec_release(&pvec);
+		if (likely(!be_atomic))
+			cond_resched();
 	}
 	return ret;
 }
+
+/**
+ * invalidate_mapping_pages - Invalidate all the unlocked pages of one inode
+ * @mapping: the address_space which holds the pages to invalidate
+ * @start: the offset 'from' which to invalidate
+ * @end: the offset 'to' which to invalidate (inclusive)
+ *
+ * This function only removes the unlocked pages, if you want to
+ * remove all the pages of one inode, you must call truncate_inode_pages.
+ *
+ * invalidate_mapping_pages() will not block on IO activity. It will not
+ * invalidate pages which are dirty, locked, under writeback or mapped into
+ * pagetables.
+ */
+unsigned long invalidate_mapping_pages(struct address_space *mapping,
+				pgoff_t start, pgoff_t end)
+{
+	return __invalidate_mapping_pages(mapping, start, end, false);
+}
 EXPORT_SYMBOL(invalidate_mapping_pages);
 
 /*
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
