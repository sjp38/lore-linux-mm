Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0FED48E0033
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 11:39:52 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id f31so6110704edf.17
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 08:39:52 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v11si2388417edj.211.2018.12.17.08.39.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 08:39:50 -0800 (PST)
Date: Mon, 17 Dec 2018 17:39:49 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [-next] lots of messages due to "mm, memory_hotplug: be more
 verbose for memory offline failures"
Message-ID: <20181217163949.GX30879@dhcp22.suse.cz>
References: <20181217155922.GC3560@osiris>
 <20181217160350.GV30879@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181217160350.GV30879@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <osalvador@suse.de>, Anshuman Khandual <anshuman.khandual@arm.com>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-next@vger.kernel.org, linux-s390@vger.kernel.org

On Mon 17-12-18 17:03:50, Michal Hocko wrote:
> On Mon 17-12-18 16:59:22, Heiko Carstens wrote:
> > Hi Michal,
> > 
> > with linux-next as of today on s390 I see tons of messages like
> > 
> > [   20.536664] page dumped because: has_unmovable_pages
> > [   20.536792] page:000003d081ff4080 count:1 mapcount:0 mapping:000000008ff88600 index:0x0 compound_mapcount: 0
> > [   20.536794] flags: 0x3fffe0000010200(slab|head)
> > [   20.536795] raw: 03fffe0000010200 0000000000000100 0000000000000200 000000008ff88600
> > [   20.536796] raw: 0000000000000000 0020004100000000 ffffffff00000001 0000000000000000
> > [   20.536797] page dumped because: has_unmovable_pages
> > [   20.536814] page:000003d0823b0000 count:1 mapcount:0 mapping:0000000000000000 index:0x0
> > [   20.536815] flags: 0x7fffe0000000000()
> > [   20.536817] raw: 07fffe0000000000 0000000000000100 0000000000000200 0000000000000000
> > [   20.536818] raw: 0000000000000000 0000000000000000 ffffffff00000001 0000000000000000
> > 
> > bisect points to b323c049a999 ("mm, memory_hotplug: be more verbose for memory offline failures")
> > which is the first commit with which the messages appear.
> 
> I would bet this is CMA allocator. How much is tons? Maybe we want a
> rate limit or the other user is not really interested in them at all?

In other words, this should silence those messages.

diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index 4ae347cbc36d..4eb26d278046 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -30,8 +30,11 @@ static inline bool is_migrate_isolate(int migratetype)
 }
 #endif
 
+#define SKIP_HWPOISON	0x1
+#define REPORT_FAILURE	0x2
+
 bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
-			 int migratetype, bool skip_hwpoisoned_pages);
+			 int migratetype, int flags);
 void set_pageblock_migratetype(struct page *page, int migratetype);
 int move_freepages_block(struct zone *zone, struct page *page,
 				int migratetype, int *num_movable);
@@ -44,10 +47,14 @@ int move_freepages_block(struct zone *zone, struct page *page,
  * For isolating all pages in the range finally, the caller have to
  * free all pages in the range. test_page_isolated() can be used for
  * test it.
+ *
+ * The following flags are allowed (they can be combined in a bit mask)
+ * SKIP_HWPOISON - ignore hwpoison pages
+ * REPORT_FAILURE - report details about the failure to isolate the range
  */
 int
 start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
-			 unsigned migratetype, bool skip_hwpoisoned_pages);
+			 unsigned migratetype, int flags);
 
 /*
  * Changes MIGRATE_ISOLATE to MIGRATE_MOVABLE.
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index c82193db4be6..8537429d33a6 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1226,7 +1226,7 @@ static bool is_pageblock_removable_nolock(struct page *page)
 	if (!zone_spans_pfn(zone, pfn))
 		return false;
 
-	return !has_unmovable_pages(zone, page, 0, MIGRATE_MOVABLE, true);
+	return !has_unmovable_pages(zone, page, 0, MIGRATE_MOVABLE, SKIP_HWPOISON);
 }
 
 /* Checks if this range of memory is likely to be hot-removable. */
@@ -1577,7 +1577,8 @@ static int __ref __offline_pages(unsigned long start_pfn,
 
 	/* set above range as isolated */
 	ret = start_isolate_page_range(start_pfn, end_pfn,
-				       MIGRATE_MOVABLE, true);
+				       MIGRATE_MOVABLE,
+				       SKIP_HWPOISON | REPORT_FAILURE);
 	if (ret) {
 		mem_hotplug_done();
 		reason = "failure to isolate range";
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ec2c7916dc2d..ee4043419791 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7754,8 +7754,7 @@ void *__init alloc_large_system_hash(const char *tablename,
  * race condition. So you can't expect this function should be exact.
  */
 bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
-			 int migratetype,
-			 bool skip_hwpoisoned_pages)
+			 int migratetype, int flags)
 {
 	unsigned long pfn, iter, found;
 
@@ -7818,7 +7817,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 		 * The HWPoisoned page may be not in buddy system, and
 		 * page_count() is not 0.
 		 */
-		if (skip_hwpoisoned_pages && PageHWPoison(page))
+		if ((flags & SKIP_HWPOISON) && PageHWPoison(page))
 			continue;
 
 		if (__PageMovable(page))
@@ -7845,7 +7844,8 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 	return false;
 unmovable:
 	WARN_ON_ONCE(zone_idx(zone) == ZONE_MOVABLE);
-	dump_page(pfn_to_page(pfn+iter), "unmovable page");
+	if (flags & REPORT_FAILURE)
+		dump_page(pfn_to_page(pfn+iter), "unmovable page");
 	return true;
 }
 
@@ -7972,8 +7972,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	 */
 
 	ret = start_isolate_page_range(pfn_max_align_down(start),
-				       pfn_max_align_up(end), migratetype,
-				       false);
+				       pfn_max_align_up(end), migratetype, 0);
 	if (ret)
 		return ret;
 
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 43e085608846..ce323e56b34d 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -15,8 +15,7 @@
 #define CREATE_TRACE_POINTS
 #include <trace/events/page_isolation.h>
 
-static int set_migratetype_isolate(struct page *page, int migratetype,
-				bool skip_hwpoisoned_pages)
+static int set_migratetype_isolate(struct page *page, int migratetype, int isol_flags)
 {
 	struct zone *zone;
 	unsigned long flags, pfn;
@@ -60,8 +59,7 @@ static int set_migratetype_isolate(struct page *page, int migratetype,
 	 * FIXME: Now, memory hotplug doesn't call shrink_slab() by itself.
 	 * We just check MOVABLE pages.
 	 */
-	if (!has_unmovable_pages(zone, page, arg.pages_found, migratetype,
-				 skip_hwpoisoned_pages))
+	if (!has_unmovable_pages(zone, page, arg.pages_found, migratetype, flags))
 		ret = 0;
 
 	/*
@@ -185,7 +183,7 @@ __first_valid_page(unsigned long pfn, unsigned long nr_pages)
  * prevents two threads from simultaneously working on overlapping ranges.
  */
 int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
-			     unsigned migratetype, bool skip_hwpoisoned_pages)
+			     unsigned migratetype, int flags)
 {
 	unsigned long pfn;
 	unsigned long undo_pfn;
@@ -199,7 +197,7 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 	     pfn += pageblock_nr_pages) {
 		page = __first_valid_page(pfn, pageblock_nr_pages);
 		if (page &&
-		    set_migratetype_isolate(page, migratetype, skip_hwpoisoned_pages)) {
+		    set_migratetype_isolate(page, migratetype, flags)) {
 			undo_pfn = pfn;
 			goto undo;
 		}
-- 
Michal Hocko
SUSE Labs
