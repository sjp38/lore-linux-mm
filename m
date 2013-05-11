Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 6D32B6B005C
	for <linux-mm@kvack.org>; Sat, 11 May 2013 13:41:42 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id bi5so3622153pad.22
        for <linux-mm@kvack.org>; Sat, 11 May 2013 10:41:41 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v6, part3 11/16] mm: use a dedicated lock to protect totalram_pages and zone->managed_pages
Date: Sun, 12 May 2013 01:34:44 +0800
Message-Id: <1368293689-16410-12-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1368293689-16410-1-git-send-email-jiang.liu@huawei.com>
References: <1368293689-16410-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>

Currently lock_memory_hotplug()/unlock_memory_hotplug() are used to
protect totalram_pages and zone->managed_pages. Other than the memory
hotplug driver, totalram_pages and zone->managed_pages may also be
modified at runtime by other drivers, such as Xen balloon,
virtio_balloon etc. For those cases, memory hotplug lock is a little
too heavy, so introduce a dedicated lock to protect totalram_pages
and zone->managed_pages.

Now we have a simplified locking rules totalram_pages and
zone->managed_pages as:
1) no locking for read accesses because they are unsigned long.
2) no locking for write accesses at boot time in single-threaded context.
3) serialize write accesses at runtime by acquiring the dedicated
   managed_page_count_lock.

Also adjust zone->managed_pages when freeing reserved pages into the
buddy system, to keep totalram_pages and zone->managed_pages in
consistence.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michel Lespinasse <walken@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org (open list:MEMORY MANAGEMENT)
Cc: linux-kernel@vger.kernel.org (open list)
---
 include/linux/mm.h     |  6 ++----
 include/linux/mmzone.h | 14 ++++++++++----
 mm/page_alloc.c        | 12 ++++++++++++
 3 files changed, 24 insertions(+), 8 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index a56bcaa..bfe3686 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1309,6 +1309,7 @@ extern void free_initmem(void);
  */
 extern unsigned long free_reserved_area(void *start, void *end,
 					int poison, char *s);
+
 #ifdef	CONFIG_HIGHMEM
 /*
  * Free a highmem page into the buddy system, adjusting totalhigh_pages
@@ -1317,10 +1318,7 @@ extern unsigned long free_reserved_area(void *start, void *end,
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
index 8c9f859..14ca1a9 100644
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
+	 * protected by managed_page_count_lock at runtime. Idealy only
+	 * adjust_managed_page_count() should be used instead of directly
+	 * touching zone->managed_pages and totalram_pages.
 	 */
 	unsigned long		spanned_pages;
 	unsigned long		present_pages;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0e681d3..14117a2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -100,6 +100,9 @@ nodemask_t node_states[NR_NODE_STATES] __read_mostly = {
 };
 EXPORT_SYMBOL(node_states);
 
+/* Protect totalram_pages and zone->managed_pages */
+static DEFINE_SPINLOCK(managed_page_count_lock);
+
 unsigned long totalram_pages __read_mostly;
 unsigned long totalreserve_pages __read_mostly;
 /*
@@ -5188,6 +5191,15 @@ early_param("movablecore", cmdline_parse_movablecore);
 
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
+void adjust_managed_page_count(struct page *page, long count)
+{
+	spin_lock(&managed_page_count_lock);
+	page_zone(page)->managed_pages += count;
+	totalram_pages += count;
+	spin_unlock(&managed_page_count_lock);
+}
+EXPORT_SYMBOL(adjust_managed_page_count);
+
 unsigned long free_reserved_area(void *start, void *end, int poison, char *s)
 {
 	void *pos;
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
