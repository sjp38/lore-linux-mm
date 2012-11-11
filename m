Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id D1E526B004D
	for <linux-mm@kvack.org>; Sun, 11 Nov 2012 14:01:53 -0500 (EST)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH v12 1/7] mm: adjust address_space_operations.migratepage() return code
Date: Sun, 11 Nov 2012 17:01:14 -0200
Message-Id: <92253be03db6dad679198d1ac6d782bb74274833.1352656285.git.aquini@redhat.com>
In-Reply-To: <cover.1352656285.git.aquini@redhat.com>
References: <cover.1352656285.git.aquini@redhat.com>
In-Reply-To: <cover.1352656285.git.aquini@redhat.com>
References: <cover.1352656285.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, "Michael S. Tsirkin" <mst@redhat.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>, aquini@redhat.com

This patch introduces MIGRATEPAGE_SUCCESS as the default return code
for address_space_operations.migratepage() method and documents the
expected return code for the same method in failure cases.

Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
 fs/hugetlbfs/inode.c    |  4 ++--
 include/linux/migrate.h |  7 +++++++
 mm/migrate.c            | 33 +++++++++++++++------------------
 3 files changed, 24 insertions(+), 20 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 14bc0c1..fed1cd5 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -582,11 +582,11 @@ static int hugetlbfs_migrate_page(struct address_space *mapping,
 	int rc;
 
 	rc = migrate_huge_page_move_mapping(mapping, newpage, page);
-	if (rc)
+	if (rc != MIGRATEPAGE_SUCCESS)
 		return rc;
 	migrate_page_copy(newpage, page);
 
-	return 0;
+	return MIGRATEPAGE_SUCCESS;
 }
 
 static int hugetlbfs_statfs(struct dentry *dentry, struct kstatfs *buf)
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 9a5afea..fab15ae 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -7,6 +7,13 @@
 
 typedef struct page *new_page_t(struct page *, unsigned long private, int **);
 
+/*
+ * Return values from addresss_space_operations.migratepage():
+ * - negative errno on page migration failure;
+ * - zero on page migration success;
+ */
+#define MIGRATEPAGE_SUCCESS		0
+
 #ifdef CONFIG_MIGRATION
 
 extern void putback_lru_pages(struct list_head *l);
diff --git a/mm/migrate.c b/mm/migrate.c
index 0c5ec37..6f408c7 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -286,7 +286,7 @@ static int migrate_page_move_mapping(struct address_space *mapping,
 		expected_count += 1;
 		if (page_count(page) != expected_count)
 			return -EAGAIN;
-		return 0;
+		return MIGRATEPAGE_SUCCESS;
 	}
 
 	spin_lock_irq(&mapping->tree_lock);
@@ -356,7 +356,7 @@ static int migrate_page_move_mapping(struct address_space *mapping,
 	}
 	spin_unlock_irq(&mapping->tree_lock);
 
-	return 0;
+	return MIGRATEPAGE_SUCCESS;
 }
 
 /*
@@ -372,7 +372,7 @@ int migrate_huge_page_move_mapping(struct address_space *mapping,
 	if (!mapping) {
 		if (page_count(page) != 1)
 			return -EAGAIN;
-		return 0;
+		return MIGRATEPAGE_SUCCESS;
 	}
 
 	spin_lock_irq(&mapping->tree_lock);
@@ -399,7 +399,7 @@ int migrate_huge_page_move_mapping(struct address_space *mapping,
 	page_unfreeze_refs(page, expected_count - 1);
 
 	spin_unlock_irq(&mapping->tree_lock);
-	return 0;
+	return MIGRATEPAGE_SUCCESS;
 }
 
 /*
@@ -486,11 +486,11 @@ int migrate_page(struct address_space *mapping,
 
 	rc = migrate_page_move_mapping(mapping, newpage, page, NULL, mode);
 
-	if (rc)
+	if (rc != MIGRATEPAGE_SUCCESS)
 		return rc;
 
 	migrate_page_copy(newpage, page);
-	return 0;
+	return MIGRATEPAGE_SUCCESS;
 }
 EXPORT_SYMBOL(migrate_page);
 
@@ -513,7 +513,7 @@ int buffer_migrate_page(struct address_space *mapping,
 
 	rc = migrate_page_move_mapping(mapping, newpage, page, head, mode);
 
-	if (rc)
+	if (rc != MIGRATEPAGE_SUCCESS)
 		return rc;
 
 	/*
@@ -549,7 +549,7 @@ int buffer_migrate_page(struct address_space *mapping,
 
 	} while (bh != head);
 
-	return 0;
+	return MIGRATEPAGE_SUCCESS;
 }
 EXPORT_SYMBOL(buffer_migrate_page);
 #endif
@@ -628,7 +628,7 @@ static int fallback_migrate_page(struct address_space *mapping,
  *
  * Return value:
  *   < 0 - error code
- *  == 0 - success
+ *  MIGRATEPAGE_SUCCESS - success
  */
 static int move_to_new_page(struct page *newpage, struct page *page,
 				int remap_swapcache, enum migrate_mode mode)
@@ -665,7 +665,7 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 	else
 		rc = fallback_migrate_page(mapping, newpage, page, mode);
 
-	if (rc) {
+	if (rc != MIGRATEPAGE_SUCCESS) {
 		newpage->mapping = NULL;
 	} else {
 		if (remap_swapcache)
@@ -814,7 +814,7 @@ skip_unmap:
 		put_anon_vma(anon_vma);
 
 uncharge:
-	mem_cgroup_end_migration(mem, page, newpage, rc == 0);
+	mem_cgroup_end_migration(mem, page, newpage, rc == MIGRATEPAGE_SUCCESS);
 unlock:
 	unlock_page(page);
 out:
@@ -987,7 +987,7 @@ int migrate_pages(struct list_head *from,
 			case -EAGAIN:
 				retry++;
 				break;
-			case 0:
+			case MIGRATEPAGE_SUCCESS:
 				break;
 			default:
 				/* Permanent failure */
@@ -996,15 +996,12 @@ int migrate_pages(struct list_head *from,
 			}
 		}
 	}
-	rc = 0;
+	rc = nr_failed + retry;
 out:
 	if (!swapwrite)
 		current->flags &= ~PF_SWAPWRITE;
 
-	if (rc)
-		return rc;
-
-	return nr_failed + retry;
+	return rc;
 }
 
 int migrate_huge_page(struct page *hpage, new_page_t get_new_page,
@@ -1024,7 +1021,7 @@ int migrate_huge_page(struct page *hpage, new_page_t get_new_page,
 			/* try again */
 			cond_resched();
 			break;
-		case 0:
+		case MIGRATEPAGE_SUCCESS:
 			goto out;
 		default:
 			rc = -EIO;
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
