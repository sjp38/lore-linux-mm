Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id A7BCD6B0006
	for <linux-mm@kvack.org>; Sat, 23 Feb 2013 17:58:04 -0500 (EST)
From: Phillip Susi <psusi@ubuntu.com>
Subject: [PATCH 1/2] mm: fadvise: fix POSIX_FADV_DONTNEED
Date: Sat, 23 Feb 2013 17:58:00 -0500
Message-Id: <1361660281-22165-2-git-send-email-psusi@ubuntu.com>
In-Reply-To: <1361660281-22165-1-git-send-email-psusi@ubuntu.com>
References: <1361660281-22165-1-git-send-email-psusi@ubuntu.com>
In-Reply-To: <5127E8B7.9080202@ubuntu.com>
References: <5127E8B7.9080202@ubuntu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

The previous implementation initiated writeout for a non congested bdi, and
then discarded any clean pages.   This had 3 problems:

1) The writeout would spin up the disk unnecessarily
2) Discarding pages under low cache pressure is a waste
3) It was useless on files being written, and thus full of dirty pages

Now we just move the pages to the inactive list so they will be reclaimed
sooner.
---
 include/linux/fs.h |  2 ++
 mm/fadvise.c       |  8 ++------
 mm/filemap.c       | 43 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 47 insertions(+), 6 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 7d2e893..2abd193 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2198,6 +2198,8 @@ extern int __filemap_fdatawrite_range(struct address_space *mapping,
 				loff_t start, loff_t end, int sync_mode);
 extern int filemap_fdatawrite_range(struct address_space *mapping,
 				loff_t start, loff_t end);
+extern void filemap_deactivate_range(struct address_space *mapping, pgoff_t start,
+				     pgoff_t end);
 
 extern int vfs_fsync_range(struct file *file, loff_t start, loff_t end,
 			   int datasync);
diff --git a/mm/fadvise.c b/mm/fadvise.c
index a47f0f5..fbd58b0 100644
--- a/mm/fadvise.c
+++ b/mm/fadvise.c
@@ -112,17 +112,13 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset, loff_t len, int advice)
 	case POSIX_FADV_NOREUSE:
 		break;
 	case POSIX_FADV_DONTNEED:
-		if (!bdi_write_congested(mapping->backing_dev_info))
-			__filemap_fdatawrite_range(mapping, offset, endbyte,
-						   WB_SYNC_NONE);
-
 		/* First and last FULL page! */
 		start_index = (offset+(PAGE_CACHE_SIZE-1)) >> PAGE_CACHE_SHIFT;
 		end_index = (endbyte >> PAGE_CACHE_SHIFT);
 
 		if (end_index >= start_index)
-			invalidate_mapping_pages(mapping, start_index,
-						end_index);
+			filemap_deactivate_range(mapping, start_index,
+						 end_index);
 		break;
 	default:
 		ret = -EINVAL;
diff --git a/mm/filemap.c b/mm/filemap.c
index c610076..bcdcdbf 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -217,7 +217,49 @@ int __filemap_fdatawrite_range(struct address_space *mapping, loff_t start,
 	return ret;
 }
 
+/**
+ * filemap_deactivate_range - moves pages in range to the inactive list
+ * @mapping:	the address_space which holds the pages to deactivate
+ * @start:	offset where the range starts
+ * @end:	offset where the range ends (inclusive)
+ */
+void filemap_deactivate_range(struct address_space *mapping, pgoff_t start,
+			      pgoff_t end)
+{
+	struct pagevec pvec;
+	pgoff_t index = start;
+	int i;
+
+	/*
+	 * Note: this function may get called on a shmem/tmpfs mapping:
+	 * pagevec_lookup() might then return 0 prematurely (because it
+	 * got a gangful of swap entries); but it's hardly worth worrying
+	 * about - it can rarely have anything to free from such a mapping
+	 * (most pages are dirty), and already skips over any difficulties.
+	 */
+
+	pagevec_init(&pvec, 0);
+	while (index <= end && pagevec_lookup(&pvec, mapping, index,
+			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
+		mem_cgroup_uncharge_start();
+		for (i = 0; i < pagevec_count(&pvec); i++) {
+			struct page *page = pvec.pages[i];
+
+			/* We rely upon deletion not changing page->index */
+			index = page->index;
+			if (index > end)
+				break;
+
+			WARN_ON(page->index != index);
+			deactivate_page(page);
+		}
+		pagevec_release(&pvec);
+		mem_cgroup_uncharge_end();
+		cond_resched();
+		index++;
+	}
+}
+
 static inline int __filemap_fdatawrite(struct address_space *mapping,
 	int sync_mode)
 {
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
