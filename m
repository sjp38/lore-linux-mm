Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id C42374403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 19:49:31 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id n128so58379838pfn.3
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 16:49:31 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id wg9si19855077pab.242.2016.02.04.16.49.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 16:49:30 -0800 (PST)
Date: Thu, 4 Feb 2016 16:49:29 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 3/3] mm/compaction: speed up pageblock_pfn_to_page()
 when zone is contiguous
Message-Id: <20160204164929.a2f12b8a7edcdfa596abd850@linux-foundation.org>
In-Reply-To: <1454566775-30973-3-git-send-email-iamjoonsoo.kim@lge.com>
References: <1454566775-30973-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1454566775-30973-3-git-send-email-iamjoonsoo.kim@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Aaron Lu <aaron.lu@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Thu,  4 Feb 2016 15:19:35 +0900 Joonsoo Kim <js1304@gmail.com> wrote:

> There is a performance drop report due to hugepage allocation and in there
> half of cpu time are spent on pageblock_pfn_to_page() in compaction [1].
> In that workload, compaction is triggered to make hugepage but most of
> pageblocks are un-available for compaction due to pageblock type and
> skip bit so compaction usually fails. Most costly operations in this case
> is to find valid pageblock while scanning whole zone range. To check
> if pageblock is valid to compact, valid pfn within pageblock is required
> and we can obtain it by calling pageblock_pfn_to_page(). This function
> checks whether pageblock is in a single zone and return valid pfn
> if possible. Problem is that we need to check it every time before
> scanning pageblock even if we re-visit it and this turns out to
> be very expensive in this workload.
> 
> Although we have no way to skip this pageblock check in the system
> where hole exists at arbitrary position, we can use cached value for
> zone continuity and just do pfn_to_page() in the system where hole doesn't
> exist. This optimization considerably speeds up in above workload.
> 
> Before vs After
> Max: 1096 MB/s vs 1325 MB/s
> Min: 635 MB/s 1015 MB/s
> Avg: 899 MB/s 1194 MB/s
> 
> Avg is improved by roughly 30% [2].
> 
> [1]: http://www.spinics.net/lists/linux-mm/msg97378.html
> [2]: https://lkml.org/lkml/2015/12/9/23
> 
> ...
>
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -196,6 +196,9 @@ void put_online_mems(void);
>  void mem_hotplug_begin(void);
>  void mem_hotplug_done(void);
>  
> +extern void set_zone_contiguous(struct zone *zone);
> +extern void clear_zone_contiguous(struct zone *zone);
> +
>  #else /* ! CONFIG_MEMORY_HOTPLUG */
>  /*
>   * Stub functions for when hotplug is off

Was it really intended that these declarations only exist if
CONFIG_MEMORY_HOTPLUG?  Seems unrelated.

The i386 allnocofnig build fails in preditable ways so I fixed that up
as below, but it seems wrong.


From: Andrew Morton <akpm@linux-foundation.org>

Move CONFIG_MEMORY_HOTPLUG code into memory_hotplug.c, fix
CONFIG_MEMORY_HOTPLUG=n build.

Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Aaron Lu <aaron.lu@intel.com>
Cc: Aaron Lu <aaron.lu@intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/memory_hotplug.h |   12 +++++++++++-
 include/linux/mmzone.h         |    2 ++
 mm/memory_hotplug.c            |   27 +++++++++++++++++++++++++++
 mm/page_alloc.c                |   27 ---------------------------
 4 files changed, 40 insertions(+), 28 deletions(-)

diff -puN include/linux/memory_hotplug.h~mm-compaction-speed-up-pageblock_pfn_to_page-when-zone-is-contiguous-fix include/linux/memory_hotplug.h
--- a/include/linux/memory_hotplug.h~mm-compaction-speed-up-pageblock_pfn_to_page-when-zone-is-contiguous-fix
+++ a/include/linux/memory_hotplug.h
@@ -200,7 +200,10 @@ void mem_hotplug_done(void);
 
 extern void set_zone_contiguous(struct zone *zone);
 extern void clear_zone_contiguous(struct zone *zone);
-
+static inline bool zone_contiguous(struct zone *zone)
+{
+	return zone->contiguous;
+}
 #else /* ! CONFIG_MEMORY_HOTPLUG */
 /*
  * Stub functions for when hotplug is off
@@ -243,6 +246,13 @@ static inline void put_online_mems(void)
 static inline void mem_hotplug_begin(void) {}
 static inline void mem_hotplug_done(void) {}
 
+static inline void set_zone_contiguous(struct zone *zone) {}
+static inline void clear_zone_contiguous(struct zone *zone) {}
+static inline bool zone_contiguous(struct zone *zone)
+{
+	return false;
+}
+
 #endif /* ! CONFIG_MEMORY_HOTPLUG */
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
diff -puN include/linux/mmzone.h~mm-compaction-speed-up-pageblock_pfn_to_page-when-zone-is-contiguous-fix include/linux/mmzone.h
--- a/include/linux/mmzone.h~mm-compaction-speed-up-pageblock_pfn_to_page-when-zone-is-contiguous-fix
+++ a/include/linux/mmzone.h
@@ -522,7 +522,9 @@ struct zone {
 	bool			compact_blockskip_flush;
 #endif
 
+#ifdef CONFIG_MEMORY_HOTPLUG
 	bool			contiguous;
+#endif
 
 	ZONE_PADDING(_pad3_)
 	/* Zone statistics */
diff -puN mm/memory_hotplug.c~mm-compaction-speed-up-pageblock_pfn_to_page-when-zone-is-contiguous-fix mm/memory_hotplug.c
--- a/mm/memory_hotplug.c~mm-compaction-speed-up-pageblock_pfn_to_page-when-zone-is-contiguous-fix
+++ a/mm/memory_hotplug.c
@@ -130,6 +130,33 @@ void mem_hotplug_done(void)
 	memhp_lock_release();
 }
 
+void set_zone_contiguous(struct zone *zone)
+{
+	unsigned long block_start_pfn = zone->zone_start_pfn;
+	unsigned long block_end_pfn;
+	unsigned long pfn;
+
+	block_end_pfn = ALIGN(block_start_pfn + 1, pageblock_nr_pages);
+	for (; block_start_pfn < zone_end_pfn(zone);
+		block_start_pfn = block_end_pfn,
+		block_end_pfn += pageblock_nr_pages) {
+
+		block_end_pfn = min(block_end_pfn, zone_end_pfn(zone));
+
+		if (!__pageblock_pfn_to_page(block_start_pfn,
+					block_end_pfn, zone))
+			return;
+	}
+
+	/* We confirm that there is no hole */
+	zone->contiguous = true;
+}
+
+void clear_zone_contiguous(struct zone *zone)
+{
+	zone->contiguous = false;
+}
+
 /* add this memory to iomem resource */
 static struct resource *register_memory_resource(u64 start, u64 size)
 {
diff -puN mm/page_alloc.c~mm-compaction-speed-up-pageblock_pfn_to_page-when-zone-is-contiguous-fix mm/page_alloc.c
--- a/mm/page_alloc.c~mm-compaction-speed-up-pageblock_pfn_to_page-when-zone-is-contiguous-fix
+++ a/mm/page_alloc.c
@@ -1347,33 +1347,6 @@ struct page *__pageblock_pfn_to_page(uns
 	return start_page;
 }
 
-void set_zone_contiguous(struct zone *zone)
-{
-	unsigned long block_start_pfn = zone->zone_start_pfn;
-	unsigned long block_end_pfn;
-	unsigned long pfn;
-
-	block_end_pfn = ALIGN(block_start_pfn + 1, pageblock_nr_pages);
-	for (; block_start_pfn < zone_end_pfn(zone);
-		block_start_pfn = block_end_pfn,
-		block_end_pfn += pageblock_nr_pages) {
-
-		block_end_pfn = min(block_end_pfn, zone_end_pfn(zone));
-
-		if (!__pageblock_pfn_to_page(block_start_pfn,
-					block_end_pfn, zone))
-			return;
-	}
-
-	/* We confirm that there is no hole */
-	zone->contiguous = true;
-}
-
-void clear_zone_contiguous(struct zone *zone)
-{
-	zone->contiguous = false;
-}
-
 #ifdef CONFIG_CMA
 /* Free whole pageblock and set its migration type to MIGRATE_CMA. */
 void __init init_cma_reserved_pageblock(struct page *page)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
