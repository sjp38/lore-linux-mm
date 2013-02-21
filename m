Return-Path: <owner-linux-mm@kvack.org>
From: Lin Feng <linfeng@cn.fujitsu.com>
Subject: [PATCH V3 1/2] mm: hotplug: implement non-movable version of get_user_pages() called get_user_pages_non_movable()
Date: Thu, 21 Feb 2013 19:01:43 +0800
Message-Id: <1361444504-31888-2-git-send-email-linfeng@cn.fujitsu.com>
In-Reply-To: <1361444504-31888-1-git-send-email-linfeng@cn.fujitsu.com>
References: <1361444504-31888-1-git-send-email-linfeng@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, bcrl@kvack.org, viro@zeniv.linux.org.uk
Cc: khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, tangchen@cn.fujitsu.com, guz.fnst@cn.fujitsu.com, jiang.liu@huawei.com, zab@redhat.com, jmoyer@redhat.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Lin Feng <linfeng@cn.fujitsu.com>

get_user_pages() always tries to allocate pages from movable zone, which is not
 reliable to memory hotremove framework in some case.

This patch introduces a new library function called get_user_pages_non_movable()
 to pin pages only from zone non-movable in memory.
It's a wrapper of get_user_pages() but it makes sure that all pages come from
non-movable zone via additional page migration. But if migration fails it
will at least keep the base functionality of get_user_pages().

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Jeff Moyer <jmoyer@redhat.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Zach Brown <zab@redhat.com>
Reviewed-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>
---
 include/linux/mm.h     |   14 ++++++
 include/linux/mmzone.h |    4 ++
 mm/memory.c            |  103 ++++++++++++++++++++++++++++++++++++++++++++++++
 mm/page_isolation.c    |    8 ++++
 4 files changed, 129 insertions(+), 0 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5625c1c..737dc39 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1025,6 +1025,20 @@ long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		    struct vm_area_struct **vmas);
 int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			struct page **pages);
+#ifdef CONFIG_MEMORY_HOTREMOVE
+int get_user_pages_non_movable(struct task_struct *tsk, struct mm_struct *mm,
+		unsigned long start, int nr_pages, int write, int force,
+		struct page **pages, struct vm_area_struct **vmas);
+#else
+static inline
+int get_user_pages_non_movable(struct task_struct *tsk, struct mm_struct *mm,
+		unsigned long start, int nr_pages, int write, int force,
+		struct page **pages, struct vm_area_struct **vmas)
+{
+	return get_user_pages(tsk, mm, start, nr_pages, write, force, pages,
+				vmas);
+}
+#endif
 struct kvec;
 int get_kernel_pages(const struct kvec *iov, int nr_pages, int write,
 			struct page **pages);
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index ab20a60..c31007e 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -851,6 +851,10 @@ static inline int is_normal_idx(enum zone_type idx)
 	return (idx == ZONE_NORMAL);
 }
 
+static inline int zone_is_movable(struct zone *zone)
+{
+	return zone_idx(zone) == ZONE_MOVABLE;
+}
 /**
  * is_highmem - helper function to quickly check if a struct zone is a 
  *              highmem zone or not.  This is an attempt to keep references
diff --git a/mm/memory.c b/mm/memory.c
index 16ca5d0..83db7dd 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -58,6 +58,8 @@
 #include <linux/elf.h>
 #include <linux/gfp.h>
 #include <linux/migrate.h>
+#include <linux/page-isolation.h>
+#include <linux/mm_inline.h>
 #include <linux/string.h>
 
 #include <asm/io.h>
@@ -2014,6 +2016,107 @@ long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 }
 EXPORT_SYMBOL(get_user_pages);
 
+#ifdef CONFIG_MEMORY_HOTREMOVE
+/**
+ * It's a wrapper of get_user_pages() but it makes sure that all pages come from
+ * non-movable zone via additional page migration. It's designed for memory
+ * hotremove framework.
+ *
+ * Currently get_user_pages() always tries to allocate pages from movable zone,
+ * in some case users of get_user_pages() is easy to pin user pages for a long
+ * time(for now we found that pages pinned as aio ring pages is such case),
+ * which is fatal for memory hotremove framework.
+ *
+ * This function first calls get_user_pages() to get the candidate pages, and
+ * then check to ensure all pages are from non movable zone. Otherwise migrate
+ * them to non movable zone, then retry. It will at most retry once. If
+ * migration fails, it will keep the base functionality of get_user_pages()
+ * and issue WARN message for memory hot-remove people.
+ *
+ * Fixme: now we don't support non movable version of GUP for hugepage.
+ */
+int get_user_pages_non_movable(struct task_struct *tsk, struct mm_struct *mm,
+		unsigned long start, int nr_pages, int write, int force,
+		struct page **pages, struct vm_area_struct **vmas)
+{
+	int ret, i, tried = 0;
+	bool isolate_err, migrate_prepped;
+	LIST_HEAD(pagelist);
+
+retry:
+	BUG_ON(tried == 2);
+	ret = get_user_pages(tsk, mm, start, nr_pages, write, force, pages,
+				vmas);
+	/* No ZONE_MOVABLE populated, all pages are from non movable zone */
+	if (movable_zone == ZONE_MOVABLE || ret <= 0)
+		return ret;
+
+	isolate_err = false;
+	migrate_prepped = false;
+
+	for (i = 0; i < ret; i++) {
+		if (zone_is_movable(page_zone(pages[i]))) {
+			/* Fixme: improve for hugepage non movable support */
+			if (PageHuge(pages[i])) {
+				WARN_ONCE(1, "Non movable GUP for hugepages "
+					"haven't been implemented yet, it may "
+					"lead to memory hot-remove failure.\n");
+				continue;
+			}
+
+			/* Hugepage or THP's head page has covered tail pages */
+			if (PageTail(pages[i]) && (page_count(pages[i]) == 1))
+				continue;
+
+			if (!migrate_prepped) {
+				BUG_ON(migrate_prep());
+				migrate_prepped = true;
+			}
+
+			/* Fixme: isolate_lru_page() takes the LRU lock every
+			 * time, batching the lock could avoid potential lock
+			 * contention problems. -Mel Gorman
+			 */
+			if (!isolate_lru_page(pages[i])) {
+				inc_zone_page_state(pages[i], NR_ISOLATED_ANON +
+						 page_is_file_cache(pages[i]));
+				list_add(&pages[i]->lru, &pagelist);
+			} else {
+				isolate_err = true;
+				break;
+			}
+		}
+	}
+
+	/* All pages are non movable, we are done :) */
+	if (i == ret && list_empty(&pagelist))
+		return ret;
+
+	/* Undo the effects of former get_user_pages(), ready for another try */
+	release_pages(pages, ret, 1);
+
+	if (!isolate_err) {
+		ret = migrate_pages(&pagelist, alloc_migrate_target, 1,
+					MIGRATE_SYNC, MR_SYSCALL);
+		/* Steal pages from non-movable zone successfully? */
+		if (!ret) {
+			tried++;
+			goto retry;
+		}
+	}
+
+	putback_lru_pages(&pagelist);
+	/* Migration failed, in order to keep at least the base functionality of
+	 * get_user_pages(), we pin pages again but give WARN info to remind
+	 * memory hot-remove people, which is a trade-off.
+	 */
+	WARN_ONCE(1, "Non movable zone migration failed, "
+		"it may lead to memroy hot-remove failure.\n");
+	return get_user_pages(tsk, mm, start, nr_pages, write, force, pages,
+				vmas);
+}
+EXPORT_SYMBOL(get_user_pages_non_movable);
+#endif
 /**
  * get_dump_page() - pin user page in memory while writing it to core dump
  * @addr: user address
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 383bdbb..7823ea5 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -247,6 +247,9 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
 	return ret ? 0 : -EBUSY;
 }
 
+/**
+ * @private: 0 means page can be alloced from movable zone, otherwise forbidden
+ */
 struct page *alloc_migrate_target(struct page *page, unsigned long private,
 				  int **resultp)
 {
@@ -254,6 +257,11 @@ struct page *alloc_migrate_target(struct page *page, unsigned long private,
 
 	if (PageHighMem(page))
 		gfp_mask |= __GFP_HIGHMEM;
+#if defined(CONFIG_MEMORY_HOTREMOVE) && defined(CONFIG_HIGHMEM)
+	BUILD_BUG_ON(1);
+#endif
+	if (unlikely(private != 0))
+		gfp_mask &= ~__GFP_HIGHMEM;
 
 	return alloc_page(gfp_mask);
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
