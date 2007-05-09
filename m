Date: Wed, 09 May 2007 12:12:17 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [RFC] memory hotremove patch take 2 [09/10] (direct isolation for remove)
In-Reply-To: <20070509115506.B904.Y-GOTO@jp.fujitsu.com>
References: <20070509115506.B904.Y-GOTO@jp.fujitsu.com>
Message-Id: <20070509120913.B918.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

This patch is to isolate source page of migration ASAP in unmap_and_move(),
when memory-hotremove.

In old code, it uses just put_page(),
and we expected that migrated source page is catched in __free_one_page()
as isolated page. But, it is spooled in per_cpu_page and used soon 
for next destination page of migration. This was cause of eternal loop in
offline_pages().

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

 include/linux/page_isolation.h |   14 ++++++++++++
 mm/Kconfig                     |    1 
 mm/migrate.c                   |   46 +++++++++++++++++++++++++++++++++++++++--
 3 files changed, 59 insertions(+), 2 deletions(-)

Index: current_test/mm/migrate.c
===================================================================
--- current_test.orig/mm/migrate.c	2007-05-08 15:08:07.000000000 +0900
+++ current_test/mm/migrate.c	2007-05-08 15:08:21.000000000 +0900
@@ -249,6 +249,32 @@ static void remove_migration_ptes(struct
 		remove_file_migration_ptes(old, new);
 }
 
+
+static int
+is_page_isolated_noinfo(struct page *page)
+{
+	int ret = 0;
+	struct zone *zone;
+	unsigned long flags;
+	struct isolation_info *info;
+
+	if (unlikely(PageReserved(page) && PagePrivate(page) &&
+		     page_count(page) == 1)){
+		zone = page_zone(page);
+		spin_lock_irqsave(&zone->isolation_lock, flags);
+		list_for_each_entry(info, &zone->isolation_list, list) {
+			if (PageReserved(page) && PagePrivate(page) &&
+			    page_count(page) == 1 &&
+			    page->private == (unsigned long)info){
+				ret = 1;
+				break;
+			}
+		}
+		spin_unlock_irqrestore(&zone->isolation_lock, flags);
+
+	}
+	return ret;
+}
 /*
  * Something used the pte of a page under migration. We need to
  * get to the page and wait until migration is finished.
@@ -278,7 +304,14 @@ void migration_entry_wait(struct mm_stru
 	get_page(page);
 	pte_unmap_unlock(ptep, ptl);
 	wait_on_page_locked(page);
-	put_page(page);
+
+	/*
+	 * The page might be migrated and directly isolated.
+	 * If not, then release page.
+	 */
+	if (!is_page_isolated_noinfo(page))
+		put_page(page);
+
 	return;
 out:
 	pte_unmap_unlock(ptep, ptl);
@@ -653,6 +686,15 @@ static int unmap_and_move(new_page_t get
 			anon_vma_release(page);
 	}
 
+	if (rc != -EAGAIN && is_migrate_isolation(flag)) {
+		/* page must be removed sooner. */
+		list_del(&page->lru);
+		page_under_isolation(page_zone(page), page, 0);
+		__put_page(page);
+		unlock_page(page);
+		goto move_newpage;
+	}
+
 unlock:
 	unlock_page(page);
 
@@ -758,7 +800,7 @@ int migrate_pages_and_remove(struct list
 	new_page_t get_new_page, unsigned long private)
 {
 	return __migrate_pages(from, get_new_page, private,
-		MIGRATE_NOCONTEXT);
+		MIGRATE_NOCONTEXT | MIGRATE_ISOLATION);
 }
 #endif
 
Index: current_test/include/linux/page_isolation.h
===================================================================
--- current_test.orig/include/linux/page_isolation.h	2007-05-08 15:08:07.000000000 +0900
+++ current_test/include/linux/page_isolation.h	2007-05-08 15:08:09.000000000 +0900
@@ -33,12 +33,20 @@ is_page_isolated(struct isolation_info *
 }
 
 #define MIGRATE_NOCONTEXT 0x1
+#define MIGRATE_ISOLATION 0x2
+
 static inline int
 is_migrate_nocontext(int flag)
 {
 	return (flag & MIGRATE_NOCONTEXT) == MIGRATE_NOCONTEXT;
 }
 
+static inline int
+is_migrate_isolation(int flag)
+{
+	return (flag & MIGRATE_ISOLATION) == MIGRATE_ISOLATION;
+}
+
 extern struct isolation_info *
 register_isolation(unsigned long start, unsigned long end);
 
@@ -64,5 +72,11 @@ is_migrate_nocontext(int flag)
 	return 0;
 }
 
+static inline int
+is_migrate_isolation(int flag)
+{
+	return 0;
+}
+
 #endif
 #endif
Index: current_test/mm/Kconfig
===================================================================
--- current_test.orig/mm/Kconfig	2007-05-08 15:08:07.000000000 +0900
+++ current_test/mm/Kconfig	2007-05-08 15:08:09.000000000 +0900
@@ -169,6 +169,7 @@ config MIGRATION_REMOVE
 	  migration target pages. This has a small race condition.
 	  If this config is selected, some workaround for fix them is enabled.
 	  This may be add slight performance influence.
+	  In addition, page must be isolated sooner for remove.
 
 config RESOURCES_64BIT
 	bool "64 bit Memory and IO resources (EXPERIMENTAL)" if (!64BIT && EXPERIMENTAL)

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
