Date: Tue, 6 Mar 2007 13:56:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC} memory unplug patchset prep [12/16] drain all pages
Message-Id: <20070306135605.3d036130.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@skynet.ie, clameter@engr.sgi.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

This patch add function drain_all_pages(void) to drain all 
pages on per-cpu-freelist.
Page isolation will catch them in free_one_page.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


---
 include/linux/page_isolation.h |    1 +
 mm/page_alloc.c                |   17 ++++++++++++++++-
 2 files changed, 17 insertions(+), 1 deletion(-)

Index: devel-tree-2.6.20-mm2/mm/page_alloc.c
===================================================================
--- devel-tree-2.6.20-mm2.orig/mm/page_alloc.c
+++ devel-tree-2.6.20-mm2/mm/page_alloc.c
@@ -822,6 +822,9 @@ void mark_free_pages(struct zone *zone)
 
 	spin_unlock_irqrestore(&zone->lock, flags);
 }
+#endif /* CONFIG_PM */
+
+#if defined(CONFIG_PM) || defined(CONFIG_PAGE_ISOLATION)
 
 /*
  * Spill all of this CPU's per-cpu pages back into the buddy allocator.
@@ -834,8 +837,20 @@ void drain_local_pages(void)
 	__drain_pages(smp_processor_id());
 	local_irq_restore(flags);	
 }
-#endif /* CONFIG_PM */
+#endif
 
+#ifdef CONFIG_PAGE_ISOLATION
+static void drain_local_zone_pages(struct work_struct *work)
+{
+	drain_local_pages();
+}
+
+void drain_all_pages(void)
+{
+	schedule_on_each_cpu(drain_local_zone_pages);
+}
+
+#endif
 /*
  * Free a 0-order page
  */
Index: devel-tree-2.6.20-mm2/include/linux/page_isolation.h
===================================================================
--- devel-tree-2.6.20-mm2.orig/include/linux/page_isolation.h
+++ devel-tree-2.6.20-mm2/include/linux/page_isolation.h
@@ -39,6 +39,7 @@ extern void detach_isolation_info_zone(s
 extern void free_isolation_info(struct isolation_info *info);
 extern void unuse_all_isolated_pages(struct isolation_info *info);
 extern void free_all_isolated_pages(struct isolation_info *info);
+extern void drain_all_pages(void);
 
 #else
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
