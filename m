Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 258D36B0568
	for <linux-mm@kvack.org>; Wed,  9 May 2018 15:00:13 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id v2-v6so34853wmc.0
        for <linux-mm@kvack.org>; Wed, 09 May 2018 12:00:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s59-v6sor12906390wrc.52.2018.05.09.12.00.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 May 2018 12:00:11 -0700 (PDT)
From: Mathieu Malaterre <malat@debian.org>
Subject: [PATCH v2] =?UTF-8?q?mm:=20move=20function=20=E2=80=98is=5Fpagebl?= =?UTF-8?q?ock=5Fremovable=5Fnolock=E2=80=99=20to=20mm/memory=5Fhotplug.c?=
Date: Wed,  9 May 2018 20:59:57 +0200
Message-Id: <20180509190001.24789-1-malat@debian.org>
In-Reply-To: <20180505201107.21070-1-malat@debian.org>
References: <20180505201107.21070-1-malat@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mathieu Malaterre <malat@debian.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Reza Arbab <arbab@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Mel Gorman <mgorman@techsingularity.net>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Function a??is_pageblock_removable_nolocka?? is not used outside of
mm/memory_hotplug.c. Move it next to unique caller:
a??is_mem_section_removablea?? and make it static.
Remove prototype in <linux/memory_hotplug.h>. Silence gcc warning (W=1):

  mm/page_alloc.c:7704:6: warning: no previous prototype for a??is_pageblock_removable_nolocka?? [-Wmissing-prototypes]

Suggested-by: Michal Hocko <mhocko@kernel.org>
Signed-off-by: Mathieu Malaterre <malat@debian.org>
---
v2: this function can be made static, make it so

 include/linux/memory_hotplug.h |  1 -
 mm/memory_hotplug.c            | 23 +++++++++++++++++++++++
 mm/page_alloc.c                | 23 -----------------------
 3 files changed, 23 insertions(+), 24 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index e0e49b5b1ee1..9566d551a41b 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -107,7 +107,6 @@ static inline bool movable_node_is_enabled(void)
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-extern bool is_pageblock_removable_nolock(struct page *page);
 extern int arch_remove_memory(u64 start, u64 size,
 		struct vmem_altmap *altmap);
 extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index f74826cdceea..9342e120518a 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1237,6 +1237,29 @@ static struct page *next_active_pageblock(struct page *page)
 	return page + pageblock_nr_pages;
 }
 
+static bool is_pageblock_removable_nolock(struct page *page)
+{
+	struct zone *zone;
+	unsigned long pfn;
+
+	/*
+	 * We have to be careful here because we are iterating over memory
+	 * sections which are not zone aware so we might end up outside of
+	 * the zone but still within the section.
+	 * We have to take care about the node as well. If the node is offline
+	 * its NODE_DATA will be NULL - see page_zone.
+	 */
+	if (!node_online(page_to_nid(page)))
+		return false;
+
+	zone = page_zone(page);
+	pfn = page_to_pfn(page);
+	if (!zone_spans_pfn(zone, pfn))
+		return false;
+
+	return !has_unmovable_pages(zone, page, 0, MIGRATE_MOVABLE, true);
+}
+
 /* Checks if this range of memory is likely to be hot-removable. */
 bool is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
 {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 905db9d7962f..52731601ca5a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7701,29 +7701,6 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 	return false;
 }
 
-bool is_pageblock_removable_nolock(struct page *page)
-{
-	struct zone *zone;
-	unsigned long pfn;
-
-	/*
-	 * We have to be careful here because we are iterating over memory
-	 * sections which are not zone aware so we might end up outside of
-	 * the zone but still within the section.
-	 * We have to take care about the node as well. If the node is offline
-	 * its NODE_DATA will be NULL - see page_zone.
-	 */
-	if (!node_online(page_to_nid(page)))
-		return false;
-
-	zone = page_zone(page);
-	pfn = page_to_pfn(page);
-	if (!zone_spans_pfn(zone, pfn))
-		return false;
-
-	return !has_unmovable_pages(zone, page, 0, MIGRATE_MOVABLE, true);
-}
-
 #if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
 
 static unsigned long pfn_max_align_down(unsigned long pfn)
-- 
2.11.0
