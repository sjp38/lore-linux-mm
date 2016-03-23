Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id 342B36B0253
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 22:27:53 -0400 (EDT)
Received: by mail-oi0-f47.google.com with SMTP id r187so2754192oih.3
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 19:27:53 -0700 (PDT)
Received: from cmccmta3.chinamobile.com (cmccmta3.chinamobile.com. [221.176.66.81])
        by mx.google.com with ESMTP id nx7si119122obc.71.2016.03.22.19.27.50
        for <linux-mm@kvack.org>;
        Tue, 22 Mar 2016 19:27:52 -0700 (PDT)
From: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Subject: [PATCH 2/5] mm/memory_hotplug: is_mem_section_removable can be boolean
Date: Wed, 23 Mar 2016 10:26:06 +0800
Message-Id: <1458699969-3432-3-git-send-email-baiyaowei@cmss.chinamobile.com>
In-Reply-To: <1458699969-3432-1-git-send-email-baiyaowei@cmss.chinamobile.com>
References: <1458699969-3432-1-git-send-email-baiyaowei@cmss.chinamobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, rientjes@google.com, iamjoonsoo.kim@lge.com, hannes@cmpxchg.org, vdavydov@virtuozzo.com, kuleshovmail@gmail.com, vbabka@suse.cz, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, baiyaowei@cmss.chinamobile.com

This patch makes is_mem_section_removable return bool to improve
readability due to this particular function only using either
one or zero as its return value.

No functional change.

Signed-off-by: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
---
 include/linux/memory_hotplug.h | 6 +++---
 mm/memory_hotplug.c            | 6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index adbef58..20d8a5d 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -247,16 +247,16 @@ static inline void mem_hotplug_done(void) {}
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
 
-extern int is_mem_section_removable(unsigned long pfn, unsigned long nr_pages);
+extern bool is_mem_section_removable(unsigned long pfn, unsigned long nr_pages);
 extern void try_offline_node(int nid);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
 extern void remove_memory(int nid, u64 start, u64 size);
 
 #else
-static inline int is_mem_section_removable(unsigned long pfn,
+static inline bool is_mem_section_removable(unsigned long pfn,
 					unsigned long nr_pages)
 {
-	return 0;
+	return false;
 }
 
 static inline void try_offline_node(int nid) {}
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 24ea063..87be160 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1406,7 +1406,7 @@ static struct page *next_active_pageblock(struct page *page)
 }
 
 /* Checks if this range of memory is likely to be hot-removable. */
-int is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
+bool is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
 {
 	struct page *page = pfn_to_page(start_pfn);
 	struct page *end_page = page + nr_pages;
@@ -1414,12 +1414,12 @@ int is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
 	/* Check the starting page of each pageblock within the range */
 	for (; page < end_page; page = next_active_pageblock(page)) {
 		if (!is_pageblock_removable_nolock(page))
-			return 0;
+			return false;
 		cond_resched();
 	}
 
 	/* All pageblocks in the memory block are likely to be hot-removable */
-	return 1;
+	return true;
 }
 
 /*
-- 
1.9.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
