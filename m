Return-Path: <owner-linux-mm@kvack.org>
From: Lin Feng <linfeng@cn.fujitsu.com>
Subject: [PATCH 1/2] mm: hotplug: implement non-movable version of get_user_pages() called get_user_pages_non_movable()
Date: Mon, 4 Feb 2013 18:04:07 +0800
Message-Id: <1359972248-8722-2-git-send-email-linfeng@cn.fujitsu.com>
In-Reply-To: <1359972248-8722-1-git-send-email-linfeng@cn.fujitsu.com>
References: <1359972248-8722-1-git-send-email-linfeng@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, bcrl@kvack.org, viro@zeniv.linux.org.uk
Cc: khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Lin Feng <linfeng@cn.fujitsu.com>

get_user_pages() always tries to allocate pages from movable zone, which is not
 reliable to memory hotremove framework in some case.

This patch introduces a new library function called get_user_pages_non_movable()
 to pin pages only from zone non-movable in memory.
It's a wrapper of get_user_pages() but it makes sure that all pages come from
non-movable zone via additional page migration.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Reviewed-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>
---
 include/linux/mm.h     |  5 ++++
 include/linux/mmzone.h |  4 ++++
 mm/memory.c            | 63 ++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/page_isolation.c    |  5 ++++
 4 files changed, 77 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 66e2f7c..2a25d0e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1049,6 +1049,11 @@ int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 			struct page **pages, struct vm_area_struct **vmas);
 int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			struct page **pages);
+#ifdef CONFIG_MEMORY_HOTREMOVE
+int get_user_pages_non_movable(struct task_struct *tsk, struct mm_struct *mm,
+		unsigned long start, int nr_pages, int write, int force,
+		struct page **pages, struct vm_area_struct **vmas);
+#endif
 struct kvec;
 int get_kernel_pages(const struct kvec *iov, int nr_pages, int write,
 			struct page **pages);
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 73b64a3..5db811e 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -838,6 +838,10 @@ static inline int is_normal_idx(enum zone_type idx)
 	return (idx == ZONE_NORMAL);
 }
 
+static inline int is_movable(struct zone *zone)
+{
+	return zone == zone->zone_pgdat->node_zones + ZONE_MOVABLE;
+}
 /**
  * is_highmem - helper function to quickly check if a struct zone is a 
  *              highmem zone or not.  This is an attempt to keep references
diff --git a/mm/memory.c b/mm/memory.c
index bb1369f..e3b8e19 100644
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
@@ -1995,6 +1997,67 @@ int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 }
 EXPORT_SYMBOL(get_user_pages);
 
+#ifdef CONFIG_MEMORY_HOTREMOVE
+/**
+ * It's a wrapper of get_user_pages() but it makes sure that all pages come from
+ * non-movable zone via additional page migration.
+ */
+int get_user_pages_non_movable(struct task_struct *tsk, struct mm_struct *mm,
+		unsigned long start, int nr_pages, int write, int force,
+		struct page **pages, struct vm_area_struct **vmas)
+{
+	int ret, i, isolate_err, migrate_pre_flag;
+	LIST_HEAD(pagelist);
+
+retry:
+	ret = get_user_pages(tsk, mm, start, nr_pages, write, force, pages,
+				vmas);
+
+	isolate_err = 0;
+	migrate_pre_flag = 0;
+
+	for (i = 0; i < ret; i++) {
+		if (is_movable(page_zone(pages[i]))) {
+			if (!migrate_pre_flag) {
+				if (migrate_prep())
+					goto put_page;
+				migrate_pre_flag = 1;
+			}
+
+			if (!isolate_lru_page(pages[i])) {
+				inc_zone_page_state(pages[i], NR_ISOLATED_ANON +
+						 page_is_file_cache(pages[i]));
+				list_add_tail(&pages[i]->lru, &pagelist);
+			} else {
+				isolate_err = 1;
+				goto put_page;
+			}
+		}
+	}
+
+	/* All pages are non movable, we are done :) */
+	if (i == ret && list_empty(&pagelist))
+		return ret;
+
+put_page:
+	/* Undo the effects of former get_user_pages(), we won't pin anything */
+	for (i = 0; i < ret; i++)
+		put_page(pages[i]);
+
+	if (migrate_pre_flag && !isolate_err) {
+		ret = migrate_pages(&pagelist, alloc_migrate_target, 1,
+					false, MIGRATE_SYNC, MR_SYSCALL);
+		/* Steal pages from non-movable zone successfully? */
+		if (!ret)
+			goto retry;
+	}
+
+	putback_lru_pages(&pagelist);
+	return 0;
+}
+EXPORT_SYMBOL(get_user_pages_non_movable);
+#endif
+
 /**
  * get_dump_page() - pin user page in memory while writing it to core dump
  * @addr: user address
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 383bdbb..1b7bd17 100644
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
@@ -254,6 +257,8 @@ struct page *alloc_migrate_target(struct page *page, unsigned long private,
 
 	if (PageHighMem(page))
 		gfp_mask |= __GFP_HIGHMEM;
+	if (unlikely(private != 0))
+		gfp_mask &= ~__GFP_MOVABLE;
 
 	return alloc_page(gfp_mask);
 }
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
