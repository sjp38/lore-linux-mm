Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 221228E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 08:03:04 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id 2-v6so45513ljs.15
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 05:03:04 -0800 (PST)
Received: from bastet.se.axis.com (bastet.se.axis.com. [195.60.68.11])
        by mx.google.com with ESMTPS id z135si52671290lfd.128.2019.01.07.05.03.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 05:03:02 -0800 (PST)
From: Vincent Whitchurch <vincent.whitchurch@axis.com>
Subject: [PATCH] drop_caches: Allow unmapping pages
Date: Mon,  7 Jan 2019 14:02:39 +0100
Message-Id: <20190107130239.3417-1-vincent.whitchurch@axis.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mcgrof@kernel.org, keescook@chromium.org, corbet@lwn.net, linux-doc@vger.kernel.org, Vincent Whitchurch <rabinv@axis.com>

drop_caches does not drop pages which are currently mapped.  Add an
option to try to unmap and drop even these pages.  This provides a
simple way to obtain a rough estimate of how many file pages are used in
a particular use case: drop everything and check how much gets read
back.

 # cat /proc/meminfo | grep file
 Active(file):      16608 kB
 Inactive(file):    23424 kB
 # echo 3 > /proc/sys/vm/drop_caches && cat /proc/meminfo | grep file
 Active(file):      10624 kB
 Inactive(file):    15060 kB
 # echo 11 > /proc/sys/vm/drop_caches && cat /proc/meminfo | grep file
 Active(file):        240 kB
 Inactive(file):     2344 kB

Signed-off-by: Vincent Whitchurch <vincent.whitchurch@axis.com>
---
 Documentation/sysctl/vm.txt |  4 ++++
 fs/drop_caches.c            |  3 ++-
 include/linux/fs.h          | 10 ++++++++--
 kernel/sysctl.c             |  4 ++--
 mm/truncate.c               | 39 ++++++++++++++++++++++++-------------
 5 files changed, 41 insertions(+), 19 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 187ce4f599a2..6ea06c2c973b 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -222,6 +222,10 @@ To increase the number of objects freed by this operation, the user may run
 number of dirty objects on the system and create more candidates to be
 dropped.
 
+By default, pages which are currently mapped are not dropped from the
+pagecache.  If you want to unmap and drop these pages too, echo 9 or 11 instead
+of 1 or 3 respectively (set bit 4).
+
 This file is not a means to control the growth of the various kernel caches
 (inodes, dentries, pagecache, etc...)  These objects are automatically
 reclaimed by the kernel when memory is needed elsewhere on the system.
diff --git a/fs/drop_caches.c b/fs/drop_caches.c
index 82377017130f..9faaa1e3a672 100644
--- a/fs/drop_caches.c
+++ b/fs/drop_caches.c
@@ -17,6 +17,7 @@ int sysctl_drop_caches;
 static void drop_pagecache_sb(struct super_block *sb, void *unused)
 {
 	struct inode *inode, *toput_inode = NULL;
+	bool unmap = sysctl_drop_caches & 8;
 
 	spin_lock(&sb->s_inode_list_lock);
 	list_for_each_entry(inode, &sb->s_inodes, i_sb_list) {
@@ -30,7 +31,7 @@ static void drop_pagecache_sb(struct super_block *sb, void *unused)
 		spin_unlock(&inode->i_lock);
 		spin_unlock(&sb->s_inode_list_lock);
 
-		invalidate_mapping_pages(inode->i_mapping, 0, -1);
+		__invalidate_mapping_pages(inode->i_mapping, 0, -1, unmap);
 		iput(toput_inode);
 		toput_inode = inode;
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 811c77743dad..503e176654ce 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2675,8 +2675,14 @@ extern int check_disk_change(struct block_device *);
 extern int __invalidate_device(struct block_device *, bool);
 extern int invalidate_partition(struct gendisk *, int);
 #endif
-unsigned long invalidate_mapping_pages(struct address_space *mapping,
-					pgoff_t start, pgoff_t end);
+unsigned long __invalidate_mapping_pages(struct address_space *mapping,
+					pgoff_t start, pgoff_t end, bool unmap);
+
+static inline unsigned long invalidate_mapping_pages(struct address_space *mapping,
+						     pgoff_t start, pgoff_t end)
+{
+	return __invalidate_mapping_pages(mapping, start, end, false);
+}
 
 static inline void invalidate_remote_inode(struct inode *inode)
 {
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index ba4d9e85feb8..f12c2a8d84fb 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -125,7 +125,7 @@ static int __maybe_unused neg_one = -1;
 static int zero;
 static int __maybe_unused one = 1;
 static int __maybe_unused two = 2;
-static int __maybe_unused four = 4;
+static int __maybe_unused fifteen = 15;
 static unsigned long one_ul = 1;
 static int one_hundred = 100;
 static int one_thousand = 1000;
@@ -1431,7 +1431,7 @@ static struct ctl_table vm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= drop_caches_sysctl_handler,
 		.extra1		= &one,
-		.extra2		= &four,
+		.extra2		= &fifteen,
 	},
 #ifdef CONFIG_COMPACTION
 	{
diff --git a/mm/truncate.c b/mm/truncate.c
index 798e7ccfb030..613b02e02146 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -245,6 +245,22 @@ int generic_error_remove_page(struct address_space *mapping, struct page *page)
 }
 EXPORT_SYMBOL(generic_error_remove_page);
 
+static int __invalidate_inode_page(struct page *page, bool unmap)
+{
+	struct address_space *mapping = page_mapping(page);
+	if (!mapping)
+		return 0;
+	if (PageDirty(page) || PageWriteback(page))
+		return 0;
+	if (page_mapped(page)) {
+		if (!unmap)
+			return 0;
+		if (!try_to_unmap(page, TTU_IGNORE_ACCESS))
+			return 0;
+	}
+	return invalidate_complete_page(mapping, page);
+}
+
 /*
  * Safely invalidate one page from its pagecache mapping.
  * It only drops clean, unused pages. The page must be locked.
@@ -253,16 +269,10 @@ EXPORT_SYMBOL(generic_error_remove_page);
  */
 int invalidate_inode_page(struct page *page)
 {
-	struct address_space *mapping = page_mapping(page);
-	if (!mapping)
-		return 0;
-	if (PageDirty(page) || PageWriteback(page))
-		return 0;
-	if (page_mapped(page))
-		return 0;
-	return invalidate_complete_page(mapping, page);
+	return __invalidate_inode_page(page, false);
 }
 
+
 /**
  * truncate_inode_pages_range - truncate range of pages specified by start & end byte offsets
  * @mapping: mapping to truncate
@@ -532,16 +542,17 @@ EXPORT_SYMBOL(truncate_inode_pages_final);
  * @mapping: the address_space which holds the pages to invalidate
  * @start: the offset 'from' which to invalidate
  * @end: the offset 'to' which to invalidate (inclusive)
+ * @unmap: try to unmap pages
  *
  * This function only removes the unlocked pages, if you want to
  * remove all the pages of one inode, you must call truncate_inode_pages.
  *
  * invalidate_mapping_pages() will not block on IO activity. It will not
- * invalidate pages which are dirty, locked, under writeback or mapped into
- * pagetables.
+ * invalidate pages which are dirty, locked, under writeback or, if unmap is
+ * false, mapped into pagetables.
  */
-unsigned long invalidate_mapping_pages(struct address_space *mapping,
-		pgoff_t start, pgoff_t end)
+unsigned long __invalidate_mapping_pages(struct address_space *mapping,
+		pgoff_t start, pgoff_t end, bool unmap)
 {
 	pgoff_t indices[PAGEVEC_SIZE];
 	struct pagevec pvec;
@@ -591,7 +602,7 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 				}
 			}
 
-			ret = invalidate_inode_page(page);
+			ret = __invalidate_inode_page(page, unmap);
 			unlock_page(page);
 			/*
 			 * Invalidation is a hint that the page is no longer
@@ -608,7 +619,7 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 	}
 	return count;
 }
-EXPORT_SYMBOL(invalidate_mapping_pages);
+EXPORT_SYMBOL(__invalidate_mapping_pages);
 
 /*
  * This is like invalidate_complete_page(), except it ignores the page's
-- 
2.20.0
