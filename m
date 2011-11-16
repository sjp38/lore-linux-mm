Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 0D0DE6B006E
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 08:47:52 -0500 (EST)
Received: by faas10 with SMTP id s10so2069950faa.14
        for <linux-mm@kvack.org>; Wed, 16 Nov 2011 05:47:49 -0800 (PST)
Subject: [PATCH RFC] mm: abort inode pruning if it has active pages
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Wed, 16 Nov 2011 17:47:47 +0300
Message-ID: <20111116134747.8958.11569.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>

Inode cache pruning can throw out some usefull data from page cache.
This patch aborts inode invalidation and keep inode alive if it still has
active pages. It improves interaction between inode cache and page cache.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 fs/inode.c         |    4 ++--
 include/linux/fs.h |    2 ++
 mm/truncate.c      |   46 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 50 insertions(+), 2 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 1f6c48d..8d55a63 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -663,8 +663,8 @@ void prune_icache_sb(struct super_block *sb, int nr_to_scan)
 			spin_unlock(&inode->i_lock);
 			spin_unlock(&sb->s_inode_lru_lock);
 			if (remove_inode_buffers(inode))
-				reap += invalidate_mapping_pages(&inode->i_data,
-								0, -1);
+				reap += invalidate_inode_inactive_pages(
+						&inode->i_data, 0, -1);
 			iput(inode);
 			spin_lock(&sb->s_inode_lru_lock);
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 0c4df26..05875d7 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2211,6 +2211,8 @@ extern int invalidate_partition(struct gendisk *, int);
 #endif
 unsigned long invalidate_mapping_pages(struct address_space *mapping,
 					pgoff_t start, pgoff_t end);
+unsigned long invalidate_inode_inactive_pages(struct address_space *mapping,
+					pgoff_t start, pgoff_t end);
 
 static inline void invalidate_remote_inode(struct inode *inode)
 {
diff --git a/mm/truncate.c b/mm/truncate.c
index 632b15e..ac739bc 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -379,6 +379,52 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 EXPORT_SYMBOL(invalidate_mapping_pages);
 
 /*
+ * This is like invalidate_mapping_pages(),
+ * except it aborts invalidation at the first active page.
+ */
+unsigned long invalidate_inode_inactive_pages(struct address_space *mapping,
+					    pgoff_t start, pgoff_t end)
+{
+	struct pagevec pvec;
+	pgoff_t index = start;
+	unsigned long ret;
+	unsigned long count = 0;
+	int i;
+
+	pagevec_init(&pvec, 0);
+	while (index <= end && pagevec_lookup(&pvec, mapping, index,
+			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
+
+		mem_cgroup_uncharge_start();
+		for (i = 0; i < pagevec_count(&pvec); i++) {
+			struct page *page = pvec.pages[i];
+
+			if (PageActive(page)) {
+				index = end;
+				break;
+			}
+
+			/* We rely upon deletion not changing page->index */
+			index = page->index;
+			if (index > end)
+				break;
+
+			if (!trylock_page(page))
+				continue;
+			WARN_ON(page->index != index);
+			ret = invalidate_inode_page(page);
+			unlock_page(page);
+			count += ret;
+		}
+		pagevec_release(&pvec);
+		mem_cgroup_uncharge_end();
+		cond_resched();
+		index++;
+	}
+	return count;
+}
+
+/*
  * This is like invalidate_complete_page(), except it ignores the page's
  * refcount.  We do this because invalidate_inode_pages2() needs stronger
  * invalidation guarantees, and cannot afford to leave pages behind because

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
