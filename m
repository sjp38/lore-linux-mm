Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 39AFD5F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 20:11:25 -0400 (EDT)
Date: Tue, 7 Apr 2009 19:11:33 -0500
From: Russ Anderson <rja@sgi.com>
Subject: [PATCH 1/2] Avoid putting a bad page back on the LRU
Message-ID: <20090408001133.GB27170@sgi.com>
Reply-To: Russ Anderson <rja@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
Cc: Russ Anderson <rja@sgi.com>
List-ID: <linux-mm.kvack.org>

Prevent a page with a physical memory error from being placed back
on the LRU.  This patch applies on top of Andi Kleen's POISON
patchset.


Signed-off-by: Russ Anderson <rja@sgi.com>

---
 include/linux/page-flags.h |    8 +++++++-
 mm/migrate.c               |   39 ++++++++++++++++++++++++++++++++++++++-
 2 files changed, 45 insertions(+), 2 deletions(-)

Index: linux-next/mm/migrate.c
===================================================================
--- linux-next.orig/mm/migrate.c	2009-04-07 18:32:12.781949840 -0500
+++ linux-next/mm/migrate.c	2009-04-07 18:34:19.169736260 -0500
@@ -72,6 +72,7 @@ int putback_lru_pages(struct list_head *
 	}
 	return count;
 }
+EXPORT_SYMBOL(isolate_lru_page);
 
 /*
  * Restore a potential migration pte to a working pte entry
@@ -139,6 +140,7 @@ static void remove_migration_pte(struct 
 out:
 	pte_unmap_unlock(ptep, ptl);
 }
+EXPORT_SYMBOL(migrate_prep);
 
 /*
  * Note that remove_file_migration_ptes will only work on regular mappings,
@@ -161,6 +163,7 @@ static void remove_file_migration_ptes(s
 
 	spin_unlock(&mapping->i_mmap_lock);
 }
+EXPORT_SYMBOL(putback_lru_pages);
 
 /*
  * Must hold mmap_sem lock on at least one of the vmas containing
@@ -693,6 +696,26 @@ unlock:
  		 * restored.
  		 */
  		list_del(&page->lru);
+#ifdef CONFIG_MEMORY_FAILURE
+		if (PagePoison(page)) {
+			if (rc == 0)
+				/*
+				 * A page with a memory error that has
+				 * been migrated will not be moved to
+				 * the LRU.
+				 */
+				goto move_newpage;
+			else
+				/*
+				 * The page failed to migrate and will not
+				 * be added to the bad page list.  Clearing
+				 * the error bit will allow another attempt
+				 * to migrate if it gets another correctable
+				 * error.
+				 */
+				ClearPagePoison(page);
+		}
+#endif
 		putback_lru_page(page);
 	}
 
@@ -736,7 +759,7 @@ int migrate_pages(struct list_head *from
 	struct page *page;
 	struct page *page2;
 	int swapwrite = current->flags & PF_SWAPWRITE;
-	int rc;
+	int rc = 0;
 
 	if (!swapwrite)
 		current->flags |= PF_SWAPWRITE;
@@ -765,6 +788,19 @@ int migrate_pages(struct list_head *from
 			}
 		}
 	}
+
+#ifdef CONFIG_MEMORY_FAILURE
+	if (rc != 0)
+		list_for_each_entry_safe(page, page2, from, lru)
+			if (PagePoison(page))
+				/*
+				 * The page failed to migrate.  Clearing
+				 * the error bit will allow another attempt
+				 * to migrate if it gets another correctable
+				 * error.
+				 */
+				ClearPagePoison(page);
+#endif
 	rc = 0;
 out:
 	if (!swapwrite)
@@ -777,6 +813,7 @@ out:
 
 	return nr_failed + retry;
 }
+EXPORT_SYMBOL(migrate_pages);
 
 #ifdef CONFIG_NUMA
 /*
Index: linux-next/include/linux/page-flags.h
===================================================================
--- linux-next.orig/include/linux/page-flags.h	2009-04-07 18:32:12.789950956 -0500
+++ linux-next/include/linux/page-flags.h	2009-04-07 18:34:19.197737925 -0500
@@ -169,15 +169,21 @@ static inline int TestSetPage##uname(str
 static inline int TestClearPage##uname(struct page *page)		\
 		{ return test_and_clear_bit(PG_##lname, &page->flags); }
 
+#define PAGEFLAGMASK(uname, lname)					\
+static inline int PAGEMASK_##uname(void)				\
+		{ return (1 << PG_##lname); }
 
 #define PAGEFLAG(uname, lname) TESTPAGEFLAG(uname, lname)		\
-	SETPAGEFLAG(uname, lname) CLEARPAGEFLAG(uname, lname)
+	SETPAGEFLAG(uname, lname) CLEARPAGEFLAG(uname, lname)		\
+	PAGEFLAGMASK(uname, lname)
 
 #define __PAGEFLAG(uname, lname) TESTPAGEFLAG(uname, lname)		\
 	__SETPAGEFLAG(uname, lname)  __CLEARPAGEFLAG(uname, lname)
 
 #define PAGEFLAG_FALSE(uname) 						\
 static inline int Page##uname(struct page *page) 			\
+			{ return 0; }					\
+static inline int PAGEMASK_##uname(void)				\
 			{ return 0; }
 
 #define TESTSCFLAG(uname, lname)					\
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
