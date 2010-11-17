Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 827B76B012C
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 11:22:56 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 5/8] mm: migration: Cleanup migrate_pages API by matching types for offlining and sync
Date: Wed, 17 Nov 2010 16:22:46 +0000
Message-Id: <1290010969-26721-6-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1290010969-26721-1-git-send-email-mel@csn.ul.ie>
References: <1290010969-26721-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

With the introduction of the boolean sync parameter, the API looks a
little inconsistent as offlining is still an int. Convert offlining to a
bool for the sake of being tidy.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/migrate.h |    8 ++++----
 mm/compaction.c         |    2 +-
 mm/mempolicy.c          |    6 ++++--
 mm/migrate.c            |    8 ++++----
 4 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index fa31902..e39aeec 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -13,10 +13,10 @@ extern void putback_lru_pages(struct list_head *l);
 extern int migrate_page(struct address_space *,
 			struct page *, struct page *);
 extern int migrate_pages(struct list_head *l, new_page_t x,
-			unsigned long private, int offlining,
+			unsigned long private, bool offlining,
 			bool sync);
 extern int migrate_huge_pages(struct list_head *l, new_page_t x,
-			unsigned long private, int offlining,
+			unsigned long private, bool offlining,
 			bool sync);
 
 extern int fail_migrate_page(struct address_space *,
@@ -35,10 +35,10 @@ extern int migrate_huge_page_move_mapping(struct address_space *mapping,
 
 static inline void putback_lru_pages(struct list_head *l) {}
 static inline int migrate_pages(struct list_head *l, new_page_t x,
-		unsigned long private, int offlining,
+		unsigned long private, bool offlining,
 		bool sync) { return -ENOSYS; }
 static inline int migrate_huge_pages(struct list_head *l, new_page_t x,
-		unsigned long private, int offlining,
+		unsigned long private, bool offlining,
 		bool sync) { return -ENOSYS; }
 
 static inline int migrate_prep(void) { return -ENOSYS; }
diff --git a/mm/compaction.c b/mm/compaction.c
index b8e27cc..75d46d8 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -450,7 +450,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 
 		nr_migrate = cc->nr_migratepages;
 		migrate_pages(&cc->migratepages, compaction_alloc,
-				(unsigned long)cc, 0,
+				(unsigned long)cc, false,
 				cc->sync);
 		update_nr_listpages(cc);
 		nr_remaining = cc->nr_migratepages;
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 8b1a490..9beb008 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -935,7 +935,8 @@ static int migrate_to_node(struct mm_struct *mm, int source, int dest,
 		return PTR_ERR(vma);
 
 	if (!list_empty(&pagelist)) {
-		err = migrate_pages(&pagelist, new_node_page, dest, 0, true);
+		err = migrate_pages(&pagelist, new_node_page, dest,
+								false, true);
 		if (err)
 			putback_lru_pages(&pagelist);
 	}
@@ -1155,7 +1156,8 @@ static long do_mbind(unsigned long start, unsigned long len,
 
 		if (!list_empty(&pagelist)) {
 			nr_failed = migrate_pages(&pagelist, new_vma_page,
-						(unsigned long)vma, 0, true);
+						(unsigned long)vma,
+						false, true);
 			if (nr_failed)
 				putback_lru_pages(&pagelist);
 		}
diff --git a/mm/migrate.c b/mm/migrate.c
index ea684ab..c30c847 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -612,7 +612,7 @@ static int move_to_new_page(struct page *newpage, struct page *page,
  * to the newly allocated page in newpage.
  */
 static int unmap_and_move(new_page_t get_new_page, unsigned long private,
-			struct page *page, int force, int offlining, bool sync)
+			struct page *page, int force, bool offlining, bool sync)
 {
 	int rc = 0;
 	int *result = NULL;
@@ -808,7 +808,7 @@ move_newpage:
  */
 static int unmap_and_move_huge_page(new_page_t get_new_page,
 				unsigned long private, struct page *hpage,
-				int force, int offlining, bool sync)
+				int force, bool offlining, bool sync)
 {
 	int rc = 0;
 	int *result = NULL;
@@ -890,7 +890,7 @@ out:
  * Return: Number of pages not migrated or error code.
  */
 int migrate_pages(struct list_head *from,
-		new_page_t get_new_page, unsigned long private, int offlining,
+		new_page_t get_new_page, unsigned long private, bool offlining,
 		bool sync)
 {
 	int retry = 1;
@@ -941,7 +941,7 @@ out:
 }
 
 int migrate_huge_pages(struct list_head *from,
-		new_page_t get_new_page, unsigned long private, int offlining,
+		new_page_t get_new_page, unsigned long private, bool offlining,
 		bool sync)
 {
 	int retry = 1;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
