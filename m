From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Wed, 30 Jul 2008 16:06:55 -0400
Message-Id: <20080730200655.24272.39854.sendpatchset@lts-notebook>
In-Reply-To: <20080730200618.24272.31756.sendpatchset@lts-notebook>
References: <20080730200618.24272.31756.sendpatchset@lts-notebook>
Subject: [PATCH 6/7] mlocked-pages:  patch reject resolution and event renames
Sender: owner-linux-mm@kvack.org
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@surriel.com>, Eric.Whitney@hp.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Against:  [27-rc1+]mmotm-080730-0356

Replaces:  mlock-count-attempts-to-free-mlocked-page.patch in
the mmotm series.

Reworked to resolve patch conflicts introduced by other patches,
including rename of unevictable lru/mlocked pages events.

Allow free of mlock()ed pages.  This shouldn't happen, but during
developement, it occasionally did.

This patch allows us to survive that condition, while keeping the
statistics and events correct for debug.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

 include/linux/vmstat.h |    1 +
 mm/internal.h          |   17 +++++++++++++++++
 mm/page_alloc.c        |    1 +
 mm/vmstat.c            |    1 +
 4 files changed, 20 insertions(+)

Index: linux-2.6.27-rc1-mmotm-30jul/include/linux/vmstat.h
===================================================================
--- linux-2.6.27-rc1-mmotm-30jul.orig/include/linux/vmstat.h	2008-07-30 13:40:43.000000000 -0400
+++ linux-2.6.27-rc1-mmotm-30jul/include/linux/vmstat.h	2008-07-30 13:51:24.000000000 -0400
@@ -49,6 +49,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PS
 		UNEVICTABLE_PGMUNLOCKED,
 		UNEVICTABLE_PGCLEARED,	/* on COW, page truncate */
 		UNEVICTABLE_PGSTRANDED,	/* unable to isolate on unlock */
+		UNEVICTABLE_MLOCKFREED,
 #endif
 		NR_VM_EVENT_ITEMS
 };
Index: linux-2.6.27-rc1-mmotm-30jul/mm/internal.h
===================================================================
--- linux-2.6.27-rc1-mmotm-30jul.orig/mm/internal.h	2008-07-30 13:46:31.000000000 -0400
+++ linux-2.6.27-rc1-mmotm-30jul/mm/internal.h	2008-07-30 13:52:28.000000000 -0400
@@ -146,6 +146,22 @@ static inline void mlock_migrate_page(st
 	}
 }
 
+/*
+ * free_page_mlock() -- clean up attempts to free and mlocked() page.
+ * Page should not be on lru, so no need to fix that up.
+ * free_pages_check() will verify...
+ */
+static inline void free_page_mlock(struct page *page)
+{
+	if (unlikely(TestClearPageMlocked(page))) {
+		unsigned long flags;
+
+		local_irq_save(flags);
+		__dec_zone_page_state(page, NR_MLOCK);
+		__count_vm_event(UNEVICTABLE_MLOCKFREED);
+		local_irq_restore(flags);
+	}
+}
 
 #else /* CONFIG_UNEVICTABLE_LRU */
 static inline int is_mlocked_vma(struct vm_area_struct *v, struct page *p)
@@ -155,6 +171,7 @@ static inline int is_mlocked_vma(struct 
 static inline void clear_page_mlock(struct page *page) { }
 static inline void mlock_vma_page(struct page *page) { }
 static inline void mlock_migrate_page(struct page *new, struct page *old) { }
+static inline void free_page_mlock(struct page *page) { }
 
 #endif /* CONFIG_UNEVICTABLE_LRU */
 
Index: linux-2.6.27-rc1-mmotm-30jul/mm/page_alloc.c
===================================================================
--- linux-2.6.27-rc1-mmotm-30jul.orig/mm/page_alloc.c	2008-07-30 13:35:55.000000000 -0400
+++ linux-2.6.27-rc1-mmotm-30jul/mm/page_alloc.c	2008-07-30 13:50:04.000000000 -0400
@@ -451,6 +451,7 @@ static inline void __free_one_page(struc
 
 static inline int free_pages_check(struct page *page)
 {
+	free_page_mlock(page);
 	if (unlikely(page_mapcount(page) |
 		(page->mapping != NULL)  |
 		(page_get_page_cgroup(page) != NULL) |
Index: linux-2.6.27-rc1-mmotm-30jul/mm/vmstat.c
===================================================================
--- linux-2.6.27-rc1-mmotm-30jul.orig/mm/vmstat.c	2008-07-30 13:48:12.000000000 -0400
+++ linux-2.6.27-rc1-mmotm-30jul/mm/vmstat.c	2008-07-30 13:52:03.000000000 -0400
@@ -672,6 +672,7 @@ static const char * const vmstat_text[] 
 	"unevictable_pgs_munlocked",
 	"unevictable_pgs_cleared",
 	"unevictable_pgs_stranded",
+	"unevictable_pgs_mlockfreed",
 #endif
 #endif
 };

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
