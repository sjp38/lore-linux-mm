Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 51F946B005A
	for <linux-mm@kvack.org>; Sat, 16 Mar 2013 13:04:22 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id uo15so5097237pbc.5
        for <linux-mm@kvack.org>; Sat, 16 Mar 2013 10:04:21 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v2, part3 08/12] mm: use a dedicated lock to protect totalram_pages and zone->managed_pages
Date: Sun, 17 Mar 2013 01:03:29 +0800
Message-Id: <1363453413-8139-9-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1363453413-8139-1-git-send-email-jiang.liu@huawei.com>
References: <1363453413-8139-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>

Currently lock_memory_hotplug()/unlock_memory_hotplug() are used to
protect totalram_pages and zone->managed_pages. Other than the memory
hotplug driver, totalram_pages and zone->managed_pages may be modified
by Xen balloon, virtio_balloon etc at runtime. For those case, memory
hotplug lock is a little too heavy, so introduce a dedicated lock to
protect them.

Now the locking rules for totalram_pages and zone->managed_pages have
been simpilied as:
1) no locking for read accesses because they are unsigned long.
2) no locking for write accesses at boot time in single-threaded context.
3) serialize write accesses at run time by managed_page_count_lock.

Also adjust zone->managed_pages when dealing with reserved pages.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michel Lespinasse <walken@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org (open list:MEMORY MANAGEMENT)
Cc: linux-kernel@vger.kernel.org (open list)
---
 include/linux/mm.h     |    6 ++----
 include/linux/mmzone.h |   14 ++++++++++----
 mm/page_alloc.c        |   19 +++++++++++++++++++
 3 files changed, 31 insertions(+), 8 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index add5f0a..f1c0827 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1302,6 +1302,7 @@ extern void free_initmem(void);
  */
 extern unsigned long free_reserved_area(unsigned long start, unsigned long end,
 					int poison, char *s);
+
 #ifdef	CONFIG_HIGHMEM
 /*
  * Free a highmem page into the buddy system, adjusting totalhigh_pages
@@ -1310,10 +1311,7 @@ extern unsigned long free_reserved_area(unsigned long start, unsigned long end,
 extern void free_highmem_page(struct page *page);
 #endif
 
-static inline void adjust_managed_page_count(struct page *page, long count)
-{
-	totalram_pages += count;
-}
+extern void adjust_managed_page_count(struct page *page, long count);
 
 /* Free the reserved page into the buddy system, so it gets managed. */
 static inline void __free_reserved_page(struct page *page)
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index ab20a60..deb7377 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -474,10 +474,16 @@ struct zone {
 	 * frequently read in proximity to zone->lock.  It's good to
 	 * give them a chance of being in the same cacheline.
 	 *
-	 * Write access to present_pages and managed_pages at runtime should
-	 * be protected by lock_memory_hotplug()/unlock_memory_hotplug().
-	 * Any reader who can't tolerant drift of present_pages and
-	 * managed_pages should hold memory hotplug lock to get a stable value.
+	 * Write access to present_pages at runtime should be protected by
+	 * lock_memory_hotplug()/unlock_memory_hotplug().  Any reader who can't
+	 * tolerant drift of present_pages should hold memory hotplug lock to
+	 * get a stable value.
+	 *
+	 * Read access to managed_pages should be safe because it's unsigned
+	 * long. Write access to zone->managed_pages and totalram_pages are
+	 * protected by managed_page_count_lock at runtime. Basically only
+	 * adjust_managed_page_count() should be used instead of directly
+	 * touching zone->managed_pages and totalram_pages.
 	 */
 	unsigned long		spanned_pages;
 	unsigned long		present_pages;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 23bb4d7..9d08d06 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -98,6 +98,9 @@ nodemask_t node_states[NR_NODE_STATES] __read_mostly = {
 };
 EXPORT_SYMBOL(node_states);
 
+/* Protect totalram_pages and zone->managed_pages */
+static DEFINE_SPINLOCK(managed_page_count_lock);
+
 unsigned long totalram_pages __read_mostly;
 unsigned long totalreserve_pages __read_mostly;
 /*
@@ -5122,6 +5125,22 @@ early_param("movablecore", cmdline_parse_movablecore);
 
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
+void adjust_managed_page_count(struct page *page, long count)
+{
+	bool lock = (system_state != SYSTEM_BOOTING);
+
+	/* No need to acquire the lock during boot */
+	if (lock)
+		spin_lock(&managed_page_count_lock);
+
+	page_zone(page)->managed_pages += count;
+	totalram_pages += count;
+
+	if (lock)
+		spin_unlock(&managed_page_count_lock);
+}
+EXPORT_SYMBOL(adjust_managed_page_count);
+
 unsigned long free_reserved_area(unsigned long start, unsigned long end,
 				 int poison, char *s)
 {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
