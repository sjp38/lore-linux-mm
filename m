Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 1603B6B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 04:57:54 -0500 (EST)
Date: Tue, 20 Dec 2011 09:57:50 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: mm: compaction: Introduce sync-light migration for use by compaction
 fix
Message-ID: <20111220095750.GQ3487@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Consistently name enum migrate_mode parameters "mode" instead of "sync".

This is a fix for the patch
mm-compaction-introduce-sync-light-migration-for-use-by-compaction.patch
in mmotm.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Minchan Kim <minchan@kernel.org>
---
 fs/btrfs/disk-io.c      |    2 +-
 fs/nfs/write.c          |    2 +-
 include/linux/migrate.h |    8 ++++----
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index dbe9518..ff45cdf 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -873,7 +873,7 @@ static int btree_submit_bio_hook(struct inode *inode, int rw, struct bio *bio,
 #ifdef CONFIG_MIGRATION
 static int btree_migratepage(struct address_space *mapping,
 			struct page *newpage, struct page *page,
-			enum migrate_mode sync)
+			enum migrate_mode mode)
 {
 	/*
 	 * we can't safely write a btree page from here,
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index adb87d9..1f4f18f9 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1711,7 +1711,7 @@ out_error:
 
 #ifdef CONFIG_MIGRATION
 int nfs_migrate_page(struct address_space *mapping, struct page *newpage,
-		struct page *page, enum migrate_mode sync)
+		struct page *page, enum migrate_mode mode)
 {
 	/*
 	 * If PagePrivate is set, then the page is currently associated with
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 775787c..eaf8674 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -27,10 +27,10 @@ extern int migrate_page(struct address_space *,
 			struct page *, struct page *, enum migrate_mode);
 extern int migrate_pages(struct list_head *l, new_page_t x,
 			unsigned long private, bool offlining,
-			enum migrate_mode sync);
+			enum migrate_mode mode);
 extern int migrate_huge_pages(struct list_head *l, new_page_t x,
 			unsigned long private, bool offlining,
-			enum migrate_mode sync);
+			enum migrate_mode mode);
 
 extern int fail_migrate_page(struct address_space *,
 			struct page *, struct page *);
@@ -49,10 +49,10 @@ extern int migrate_huge_page_move_mapping(struct address_space *mapping,
 static inline void putback_lru_pages(struct list_head *l) {}
 static inline int migrate_pages(struct list_head *l, new_page_t x,
 		unsigned long private, bool offlining,
-		enum migrate_mode sync) { return -ENOSYS; }
+		enum migrate_mode mode) { return -ENOSYS; }
 static inline int migrate_huge_pages(struct list_head *l, new_page_t x,
 		unsigned long private, bool offlining,
-		enum migrate_mode sync) { return -ENOSYS; }
+		enum migrate_mode mode) { return -ENOSYS; }
 
 static inline int migrate_prep(void) { return -ENOSYS; }
 static inline int migrate_prep_local(void) { return -ENOSYS; }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
